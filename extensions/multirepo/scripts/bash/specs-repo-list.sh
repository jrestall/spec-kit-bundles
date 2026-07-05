#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"
JSON_MODE=false
[[ "${1:-}" == "--json" ]] && JSON_MODE=true
ensure_registry
REGISTRY="$(specs_repo_registry_path)"
if $JSON_MODE; then
  python3 - "$REGISTRY" <<'PY'
import json, sys
try:
    data = json.load(open(sys.argv[1], encoding="utf-8"))
except Exception:
    data = {"version": 1, "specsRepos": {}}
specs_repos = [{"id": k, **v} for k, v in sorted((data.get("specsRepos") or {}).items())]
print(json.dumps({"specsRepos": specs_repos, "status": []}, indent=2))
PY
else
  python3 - "$REGISTRY" <<'PY'
import json, sys
data = json.load(open(sys.argv[1], encoding="utf-8"))
specs_repos = data.get("specsRepos") or {}
if not specs_repos:
    print("No specs repos registered.")
for sid, entry in sorted(specs_repos.items()):
    print(f"{sid}\t{entry.get('path','')}")
PY
fi
