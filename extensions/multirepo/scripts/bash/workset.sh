#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

ACTION="${1:-doctor}"
[[ $# -gt 0 ]] && shift

JSON_MODE=false
SPECS_REPO_ID=""
SPEC_ID=""
TOOL=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --json) JSON_MODE=true; shift ;;
    --specs-repo) SPECS_REPO_ID="${2:-}"; shift 2 ;;
    --spec) SPEC_ID="${2:-}"; shift 2 ;;
    --tool) TOOL="${2:-}"; shift 2 ;;
    --help|-h)
      echo "Usage: workset.sh <doctor|open> [--specs-repo <id>] [--spec <id>] [--tool code|cursor|claude|codex|workspace] [--json]"
      exit 0
      ;;
    *) shift ;;
  esac
done

ROOT="$(resolve_active_root "$SPECS_REPO_ID")"
SPEC_DIR="$(resolve_spec_dir "$ROOT" "$SPEC_ID")"
[[ -d "$SPEC_DIR" ]] || die_json "spec_not_found" "Spec directory not found: $SPEC_DIR" "Pass --spec <feature-dir>."
WORKSET="$SPEC_DIR/workset.yml"
LOCAL_WORKSET="$SPEC_DIR/workset.local.yml"
[[ -f "$WORKSET" ]] || die_json "workset_missing" "No workset.yml found for spec: $SPEC_DIR" "Create $WORKSET with planning and implementation members, then run speckit.workset-open so planning has all repo context."

WORKSET_JSON="$(
  python3 - "$WORKSET" "$LOCAL_WORKSET" <<'PY'
import json, os, re, sys

workset_path, local_path = sys.argv[1], sys.argv[2]
base = os.path.dirname(os.path.abspath(workset_path))

def scalar(raw):
    raw = raw.strip()
    if (raw.startswith('"') and raw.endswith('"')) or (raw.startswith("'") and raw.endswith("'")):
        return raw[1:-1]
    return raw

def parse_members(path):
    members = []
    lines = open(path, encoding="utf-8").read().splitlines()
    in_members = False
    current = None
    for line in lines:
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        if re.match(r"^[A-Za-z0-9_-]+:", line):
            in_members = stripped == "members:"
            if not in_members and current:
                members.append(current)
                current = None
            continue
        if not in_members:
            continue
        m = re.match(r"^\s*-\s+name:\s*(.+)$", line)
        if m:
            if current:
                members.append(current)
            current = {"name": scalar(m.group(1))}
            continue
        m = re.match(r"^\s{2,}([A-Za-z0-9_-]+):\s*(.*)$", line)
        if m and current is not None:
            current[m.group(1)] = scalar(m.group(2))
    if current:
        members.append(current)
    return members

def parse_local_overrides(path):
    overrides = {}
    if not os.path.exists(path):
        return overrides
    lines = open(path, encoding="utf-8").read().splitlines()
    in_members = False
    current_name = None
    for line in lines:
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        if re.match(r"^[A-Za-z0-9_-]+:", line):
            in_members = stripped == "members:"
            current_name = None
            continue
        if not in_members:
            continue
        m = re.match(r"^\s{2}([A-Za-z0-9_.-]+):\s*$", line)
        if m:
            current_name = m.group(1)
            overrides.setdefault(current_name, {})
            continue
        m = re.match(r"^\s{4}([A-Za-z0-9_-]+):\s*(.*)$", line)
        if m and current_name:
            overrides[current_name][m.group(1)] = scalar(m.group(2))
    return overrides

members = parse_members(workset_path)
overrides = parse_local_overrides(local_path)
for member in members:
    name = member.get("name")
    if name in overrides:
        member.update(overrides[name])
    raw_path = member.get("path", "")
    if raw_path:
        member["raw_path"] = raw_path
        member["path"] = raw_path if os.path.isabs(raw_path) else os.path.abspath(os.path.join(base, raw_path))
print(json.dumps({"members": members, "workset": workset_path, "local": local_path if os.path.exists(local_path) else None}))
PY
)"

MEMBER_COUNT="$(WORKSET_JSON="$WORKSET_JSON" python3 - <<'PY'
import json, os
print(len(json.loads(os.environ["WORKSET_JSON"])["members"]))
PY
)"
[[ "$MEMBER_COUNT" != "0" ]] || die_json "workset_empty" "workset.yml has no members." "Add planning and implementation members."

WORKSPACE_FILE="$SPEC_DIR/workset.code-workspace"
WORKSET_JSON="$WORKSET_JSON" WORKSPACE_FILE="$WORKSPACE_FILE" python3 - <<'PY'
import json, os
data = json.loads(os.environ["WORKSET_JSON"])
folders = []
for member in data["members"]:
    path = member.get("path")
    if path and os.path.isdir(path):
        folders.append({"name": member.get("name") or os.path.basename(path), "path": path})
with open(os.environ["WORKSPACE_FILE"], "w", encoding="utf-8") as fh:
    json.dump({"folders": folders}, fh, indent=2)
    fh.write("\n")
PY

if [[ "$ACTION" == "doctor" ]]; then
  if $JSON_MODE; then
    WORKSET_JSON="$WORKSET_JSON" WORKSPACE_FILE="$WORKSPACE_FILE" python3 - <<'PY'
import json, os
data = json.loads(os.environ["WORKSET_JSON"])
members = []
for member in data["members"]:
    path = member.get("path")
    members.append({**member, "available": bool(path and os.path.isdir(path))})
print(json.dumps({
    "workset": data["workset"],
    "local": data["local"],
    "codeWorkspace": os.environ["WORKSPACE_FILE"],
    "members": members,
    "status": []
}, indent=2))
PY
  else
    WORKSET_JSON="$WORKSET_JSON" WORKSPACE_FILE="$WORKSPACE_FILE" python3 - <<'PY'
import json, os
data = json.loads(os.environ["WORKSET_JSON"])
print(f"Workset: {data['workset']}")
if data.get("local"):
    print(f"Local overrides: {data['local']}")
print(f"Workspace file: {os.environ['WORKSPACE_FILE']}")
for member in data["members"]:
    path = member.get("path", "")
    status = "ok" if path and os.path.isdir(path) else "missing"
    print(f"  {member.get('name','?')}: {status} {path}")
PY
  fi
  exit 0
fi

[[ "$ACTION" == "open" ]] || die_json "unknown_workset_action" "Unknown workset action '$ACTION'." "Use doctor or open."

if [[ -z "$TOOL" ]]; then
  if command -v code >/dev/null 2>&1; then
    TOOL="code"
  elif command -v cursor >/dev/null 2>&1; then
    TOOL="cursor"
  else
    TOOL="workspace"
  fi
fi

if [[ "$TOOL" == "workspace" ]]; then
  echo "$WORKSPACE_FILE"
  exit 0
fi

case "$TOOL" in
  code|cursor)
    command -v "$TOOL" >/dev/null 2>&1 || die_json "workset_tool_unavailable" "'$TOOL' is not on PATH." "Install $TOOL or rerun with --tool workspace."
    "$TOOL" "$WORKSPACE_FILE"
    ;;
  claude|codex)
    command -v "$TOOL" >/dev/null 2>&1 || die_json "workset_tool_unavailable" "'$TOOL' is not on PATH." "Install $TOOL or open the workspace file: $WORKSPACE_FILE"
    DIRS=()
    while IFS= read -r dir; do
      DIRS+=("$dir")
    done < <(WORKSET_JSON="$WORKSET_JSON" python3 - <<'PY'
import json, os
for member in json.loads(os.environ["WORKSET_JSON"])["members"]:
    path = member.get("path")
    if path and os.path.isdir(path):
        print(path)
PY
)
    [[ "${#DIRS[@]}" -gt 0 ]] || die_json "workset_no_members_available" "No workset member folders exist on this machine." "Check workset.local.yml or clone the sibling repos."
    ARGS=()
    if [[ "$TOOL" == "codex" ]]; then
      ARGS+=(--sandbox workspace-write)
    fi
    for dir in "${DIRS[@]}"; do
      ARGS+=(--add-dir "$dir")
    done
    exec "$TOOL" "${ARGS[@]}"
    ;;
  *)
    die_json "workset_tool_unknown" "Unknown tool '$TOOL'." "Use code, cursor, claude, codex, or workspace."
    ;;
esac
