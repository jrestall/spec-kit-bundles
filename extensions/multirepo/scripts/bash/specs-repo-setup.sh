#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

JSON_MODE=false
SPECS_REPO_ID=""
REMOTE=""
ROOT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --json) JSON_MODE=true; shift ;;
    --id) SPECS_REPO_ID="${2:-}"; shift 2 ;;
    --remote) REMOTE="${2:-}"; shift 2 ;;
    --path) ROOT="${2:-}"; shift 2 ;;
    --help|-h)
      echo "Usage: specs-repo-setup.sh [--id <id>] [--remote <url>] [--path <path>] [--json]"
      exit 0
      ;;
    *) [[ -z "$SPECS_REPO_ID" ]] && SPECS_REPO_ID="$1" || die_json "unexpected_argument" "Unexpected argument '$1'."; shift ;;
  esac
done

[[ -n "$ROOT" ]] || ROOT="$(resolve_active_root "")"
ROOT="$(cd "$ROOT" && pwd)"
[[ -d "$ROOT/.specify" ]] || die_json "not_specify_project" "Path is not a Spec Kit project: $ROOT" "Run specify init in the specs repo first."
[[ -n "$SPECS_REPO_ID" ]] || SPECS_REPO_ID="$(basename "$ROOT")"

mkdir -p "$ROOT/.specify"
GITIGNORE="$ROOT/.gitignore"
touch "$GITIGNORE"
NEEDS_IGNORE_HEADER=false
grep -qxF "specs/**/workset.local.yml" "$GITIGNORE" || NEEDS_IGNORE_HEADER=true
if $NEEDS_IGNORE_HEADER; then
  [[ ! -s "$GITIGNORE" ]] || printf '\n' >> "$GITIGNORE"
  printf '# Local multi-repo planning overrides\n' >> "$GITIGNORE"
  grep -qxF "specs/**/workset.local.yml" "$GITIGNORE" || printf 'specs/**/workset.local.yml\n' >> "$GITIGNORE"
fi

SPECS_REPO_ID="$SPECS_REPO_ID" REMOTE="$REMOTE" python3 - "$ROOT/.specify/specs-repo.json" <<'PY'
import json, os, sys
path = sys.argv[1]
payload = {"version": 1, "id": os.environ["SPECS_REPO_ID"], "kind": "specs-repo"}
if os.environ.get("REMOTE"):
    payload["remote"] = os.environ["REMOTE"]
with open(path, "w", encoding="utf-8") as fh:
    json.dump(payload, fh, indent=2)
    fh.write("\n")
PY

ensure_registry
REGISTRY="$(specs_repo_registry_path)"
SPECS_REPO_ID="$SPECS_REPO_ID" ROOT="$ROOT" REMOTE="$REMOTE" python3 - "$REGISTRY" <<'PY'
import json, os, sys
path = sys.argv[1]
try:
    data = json.load(open(path, encoding="utf-8"))
except Exception:
    data = {"version": 1, "specsRepos": {}}
data.setdefault("version", 1)
specs_repos = data.setdefault("specsRepos", {})
entry = {"path": os.environ["ROOT"]}
if os.environ.get("REMOTE"):
    entry["remote"] = os.environ["REMOTE"]
specs_repos[os.environ["SPECS_REPO_ID"]] = entry
with open(path, "w", encoding="utf-8") as fh:
    json.dump(data, fh, indent=2)
    fh.write("\n")
PY

if $JSON_MODE; then
  SPECS_REPO_ID="$SPECS_REPO_ID" ROOT="$ROOT" REGISTRY="$REGISTRY" python3 - <<'PY'
import json, os
print(json.dumps({
  "specsRepo": {"id": os.environ["SPECS_REPO_ID"], "path": os.environ["ROOT"]},
  "registry": {"path": os.environ["REGISTRY"], "registered": True},
  "status": []
}, indent=2))
PY
else
  echo "Specs repo '$SPECS_REPO_ID' registered at $ROOT"
fi
