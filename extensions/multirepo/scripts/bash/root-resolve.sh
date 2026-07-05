#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"
JSON_MODE=false
SPECS_REPO_ID=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --json) JSON_MODE=true; shift ;;
    --specs-repo) SPECS_REPO_ID="${2:-}"; shift 2 ;;
    *) shift ;;
  esac
done
ROOT="$(resolve_active_root "$SPECS_REPO_ID")"
SOURCE="nearest"
[[ -n "$SPECS_REPO_ID" ]] && SOURCE="specs-repo"
SPECS_REPO_META_ID=""
SPECS_REPO_KIND=""
if [[ -f "$ROOT/.specify/specs-repo.json" ]]; then
  SPECS_REPO_META_ID="$(read_specs_repo_field "$ROOT" id)"
  SPECS_REPO_KIND="$(read_specs_repo_field "$ROOT" kind)"
fi
if $JSON_MODE; then
  ROOT="$ROOT" SOURCE="$SOURCE" SPECS_REPO_META_ID="$SPECS_REPO_META_ID" SPECS_REPO_KIND="$SPECS_REPO_KIND" python3 - <<'PY'
import json, os
root = {"path": os.environ["ROOT"], "source": os.environ["SOURCE"]}
if os.environ.get("SPECS_REPO_META_ID"):
    root["specs_repo_id"] = os.environ["SPECS_REPO_META_ID"]
if os.environ.get("SPECS_REPO_KIND"):
    root["kind"] = os.environ["SPECS_REPO_KIND"]
print(json.dumps({"root": root, "status": []}, indent=2))
PY
else
  echo "$ROOT"
fi
