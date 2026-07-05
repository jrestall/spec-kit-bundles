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
    *) [[ -z "$SPECS_REPO_ID" ]] && SPECS_REPO_ID="$1"; shift ;;
  esac
done
ensure_registry
REGISTRY="$(specs_repo_registry_path)"
python3 - "$REGISTRY" "$SPECS_REPO_ID" "$JSON_MODE" <<'PY'
import json, os, sys
registry, only_id, json_mode = sys.argv[1], sys.argv[2], sys.argv[3] == "true"
try:
    data = json.load(open(registry, encoding="utf-8"))
except Exception as exc:
    payload = {"specsRepos": [], "status": [{"severity": "error", "code": "registry_unreadable", "message": str(exc)}]}
else:
    specs_repos = data.get("specsRepos") or {}
    rows = []
    for sid, entry in sorted(specs_repos.items()):
        if only_id and sid != only_id:
            continue
        root = entry.get("path", "")
        meta = os.path.join(root, ".specify", "specs-repo.json") if root else ""
        status = []
        if not root or not os.path.isdir(root):
            status.append({"severity": "error", "code": "specs_repo_root_missing", "message": f"Specs repo root is missing: {root}"})
        elif not os.path.isfile(meta):
            status.append({"severity": "error", "code": "specs_repo_metadata_missing", "message": f"Missing {meta}"})
        else:
            try:
                m = json.load(open(meta, encoding="utf-8"))
                if m.get("id") != sid:
                    status.append({"severity": "error", "code": "specs_repo_id_mismatch", "message": f"Metadata id '{m.get('id')}' does not match registry id '{sid}'."})
                if m.get("kind") != "specs-repo":
                    status.append({"severity": "error", "code": "specs_repo_kind_invalid", "message": "Metadata kind must be specs-repo."})
            except Exception as exc:
                status.append({"severity": "error", "code": "specs_repo_metadata_invalid", "message": str(exc)})
        rows.append({"id": sid, "path": root, "status": status})
    payload = {"specsRepos": rows, "status": []}
if json_mode:
    print(json.dumps(payload, indent=2))
else:
    if payload.get("status"):
        for diag in payload["status"]:
            print(f"ERROR {diag['code']}: {diag['message']}")
    elif not payload["specsRepos"]:
        print("No matching specs repos.")
    else:
        for row in payload["specsRepos"]:
            health = "ok" if not row["status"] else "unhealthy"
            print(f"{row['id']}\t{health}\t{row['path']}")
            for diag in row["status"]:
                print(f"  - {diag['code']}: {diag['message']}")
PY
