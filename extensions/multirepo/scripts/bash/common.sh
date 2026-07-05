#!/usr/bin/env bash
set -euo pipefail

specs_repo_registry_path() {
  if [[ -n "${SPECKIT_SPECS_REPO_REGISTRY:-}" ]]; then
    printf '%s\n' "$SPECKIT_SPECS_REPO_REGISTRY"
    return
  fi
  printf '%s\n' "${HOME}/.specify/specs-repos/registry.json"
}

json_escape() {
  python3 -c 'import json,sys; print(json.dumps(sys.stdin.read())[1:-1])'
}

die_json() {
  local code="$1"
  local message="$2"
  local fix="${3:-}"
  if [[ "${JSON_MODE:-false}" == "true" ]]; then
    CODE="$code" MESSAGE="$message" FIX="$fix" python3 - <<'PY'
import json, os
diag = {
    "severity": "error",
    "code": os.environ["CODE"],
    "message": os.environ["MESSAGE"],
}
if os.environ.get("FIX"):
    diag["fix"] = os.environ["FIX"]
print(json.dumps({"status": [diag]}, indent=2))
PY
  else
    printf 'ERROR: %s\n' "$message" >&2
    [[ -z "$fix" ]] || printf 'FIX: %s\n' "$fix" >&2
  fi
  exit 1
}

find_specify_root() {
  local dir="${1:-$(pwd)}"
  dir="$(cd "$dir" 2>/dev/null && pwd)" || return 1
  local prev=""
  while true; do
    if [[ -d "$dir/.specify" ]]; then
      printf '%s\n' "$dir"
      return 0
    fi
    [[ "$dir" == "/" || "$dir" == "$prev" ]] && return 1
    prev="$dir"
    dir="$(dirname "$dir")"
  done
}

read_specs_repo_field() {
  local root="$1"
  local field="$2"
  python3 - "$root/.specify/specs-repo.json" "$field" <<'PY'
import json, sys
path, field = sys.argv[1], sys.argv[2]
try:
    data = json.load(open(path, encoding="utf-8"))
except Exception:
    print("")
    sys.exit(0)
value = data.get(field, "")
print(value if isinstance(value, str) else "")
PY
}

is_specs_repo_root() {
  local root="$1"
  [[ -f "$root/.specify/specs-repo.json" ]] || return 1
  [[ "$(read_specs_repo_field "$root" kind)" == "specs-repo" ]] || return 1
}

ensure_registry() {
  local registry
  registry="$(specs_repo_registry_path)"
  mkdir -p "$(dirname "$registry")"
  if [[ ! -f "$registry" ]]; then
    printf '{"version":1,"specsRepos":{}}\n' > "$registry"
  fi
}

registry_get_specs_repo() {
  local specs_repo_id="$1"
  local registry
  registry="$(specs_repo_registry_path)"
  python3 - "$registry" "$specs_repo_id" <<'PY'
import json, sys
path, specs_repo_id = sys.argv[1], sys.argv[2]
try:
    data = json.load(open(path, encoding="utf-8"))
except Exception:
    sys.exit(1)
specs_repo = (data.get("specsRepos") or {}).get(specs_repo_id)
if not isinstance(specs_repo, dict):
    sys.exit(1)
print(json.dumps(specs_repo))
PY
}

resolve_specs_repo_root_by_id() {
  local specs_repo_id="$1"
  local specs_repo_json
  specs_repo_json="$(registry_get_specs_repo "$specs_repo_id")" || return 1
  SPECS_REPO_JSON="$specs_repo_json" python3 - <<'PY'
import json, os
specs_repo = json.loads(os.environ["SPECS_REPO_JSON"])
print(specs_repo.get("path", ""))
PY
}

resolve_active_root() {
  local specs_repo_id="${1:-}"
  if [[ -n "$specs_repo_id" ]]; then
    local root
    root="$(resolve_specs_repo_root_by_id "$specs_repo_id")" || die_json "unknown_specs_repo" "Specs repo '$specs_repo_id' is not registered." "Run speckit.multirepo.specs-repo-register <path> --id $specs_repo_id."
    [[ -d "$root/.specify" ]] || die_json "specs_repo_root_unhealthy" "Registered specs repo '$specs_repo_id' is not a Spec Kit project: $root" "Run speckit.multirepo.specs-repo-doctor."
    printf '%s\n' "$root"
    return
  fi

  local nearest
  nearest="$(find_specify_root "$(pwd)")" || die_json "no_specify_root" "No Spec Kit project found in this directory or its ancestors." "Run specify init, cd into a specs repo, or pass --specs-repo <id>."
  printf '%s\n' "$nearest"
}

feature_dir_from_feature_json() {
  local root="$1"
  local file="$root/.specify/feature.json"
  [[ -f "$file" ]] || return 1
  python3 - "$file" <<'PY'
import json, sys
try:
    data = json.load(open(sys.argv[1], encoding="utf-8"))
except Exception:
    sys.exit(1)
value = data.get("feature_directory")
if not isinstance(value, str) or not value:
    sys.exit(1)
print(value)
PY
}

resolve_spec_dir() {
  local root="$1"
  local spec="${2:-}"
  local rel
  if [[ -n "$spec" ]]; then
    case "$spec" in
      /*) printf '%s\n' "$spec"; return ;;
      specs/*) rel="$spec" ;;
      *) rel="specs/$spec" ;;
    esac
  else
    rel="$(feature_dir_from_feature_json "$root")" || die_json "spec_required" "No spec selected." "Pass --spec <feature-dir> or run from a specs repo with .specify/feature.json."
  fi
  printf '%s\n' "$root/$rel"
}

relpath_from_root() {
  local root="$1"
  local target="$2"
  python3 - "$root" "$target" <<'PY'
import os, sys
print(os.path.relpath(os.path.abspath(sys.argv[2]), os.path.abspath(sys.argv[1])))
PY
}
