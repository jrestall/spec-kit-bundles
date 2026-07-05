#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"
JSON_MODE=false
SPECS_REPO_ID=""
SPEC_ID=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --json) JSON_MODE=true; shift ;;
    --specs-repo) SPECS_REPO_ID="${2:-}"; shift 2 ;;
    --spec) SPEC_ID="${2:-}"; shift 2 ;;
    *) [[ -z "$SPEC_ID" ]] && SPEC_ID="$1"; shift ;;
  esac
done
ROOT="$(resolve_active_root "$SPECS_REPO_ID")"
SPEC_DIR="$(resolve_spec_dir "$ROOT" "$SPEC_ID")"
[[ -d "$SPEC_DIR" ]] || die_json "spec_not_found" "Spec directory not found: $SPEC_DIR" "Pass --spec <feature-dir> or create it with speckit.specify."
REL="$(relpath_from_root "$ROOT" "$SPEC_DIR")"
SPECS_REPO_META_ID=""
[[ -f "$ROOT/.specify/specs-repo.json" ]] && SPECS_REPO_META_ID="$(read_specs_repo_field "$ROOT" id)"
if $JSON_MODE; then
  ROOT="$ROOT" SPEC_DIR="$SPEC_DIR" REL="$REL" SPECS_REPO_META_ID="$SPECS_REPO_META_ID" python3 - <<'PY'
import json, os
spec_dir = os.environ["SPEC_DIR"]
payload = {
  "specsRepo": {"id": os.environ.get("SPECS_REPO_META_ID") or None, "path": os.environ["ROOT"]},
  "feature": {
    "id": os.path.basename(spec_dir),
    "directory": spec_dir,
    "spec": os.path.join(spec_dir, "spec.md"),
    "plan": os.path.join(spec_dir, "plan.md"),
    "tasks": os.path.join(spec_dir, "tasks.md"),
    "workset": os.path.join(spec_dir, "workset.yml"),
    "worksetLocal": os.path.join(spec_dir, "workset.local.yml"),
  },
  "env": {
    "SPECIFY_INIT_DIR": os.environ["ROOT"],
    "SPECIFY_FEATURE_DIRECTORY": os.environ["REL"],
  },
  "status": []
}
if payload["specsRepo"]["id"] is None:
    del payload["specsRepo"]["id"]
print(json.dumps(payload, indent=2))
PY
else
  echo "$SPEC_DIR"
fi
