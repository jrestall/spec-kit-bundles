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
    *) shift ;;
  esac
done
ARGS=()
$JSON_MODE && ARGS+=(--json)
[[ -z "$SPECS_REPO_ID" ]] || ARGS+=(--specs-repo "$SPECS_REPO_ID")
[[ -z "$SPEC_ID" ]] || ARGS+=(--spec "$SPEC_ID")
"$SCRIPT_DIR/spec-resolve.sh" "${ARGS[@]}"
