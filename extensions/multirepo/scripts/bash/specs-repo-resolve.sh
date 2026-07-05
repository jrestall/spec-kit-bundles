#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"
JSON_MODE=false
SPECS_REPO_ID=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --json) JSON_MODE=true; shift ;;
    --specs-repo|--id) SPECS_REPO_ID="${2:-}"; shift 2 ;;
    *) SPECS_REPO_ID="$1"; shift ;;
  esac
done
[[ -n "$SPECS_REPO_ID" ]] || die_json "specs_repo_required" "Specs repo id is required." "Run speckit.multirepo.specs-repo-list."
ROOT="$(resolve_active_root "$SPECS_REPO_ID")"
if $JSON_MODE; then
  SPECS_REPO_ID="$SPECS_REPO_ID" ROOT="$ROOT" python3 - <<'PY'
import json, os
print(json.dumps({"specsRepo": {"id": os.environ["SPECS_REPO_ID"], "path": os.environ["ROOT"]}, "status": []}, indent=2))
PY
else
  echo "$ROOT"
fi
