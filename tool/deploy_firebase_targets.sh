#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <environment> <comma-separated-targets> [firebase deploy args...]" >&2
  exit 64
fi

environment="$1"
targets_csv="$2"
shift 2

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"

deploy_target() {
  local phase="$1"
  local deploy_only="$2"
  shift
  shift

  echo "::group::Deploy Firebase target: $phase"
  "$repo_root/tool/firebase_with_env.sh" \
    "$environment" deploy --only "$deploy_only" --non-interactive "$@"
  echo "::endgroup::"
}

sync_callable_invokers() {
  local project_id
  project_id="$(
    node -e '
      const fs = require("fs");
      const env = process.argv[1];
      const rc = JSON.parse(fs.readFileSync(process.argv[2], "utf8"));
      const project = rc.projects && rc.projects[env];
      if (!project) process.exit(2);
      process.stdout.write(project);
    ' "$environment" "$repo_root/.firebaserc"
  )"
  npm --prefix "$repo_root/functions" run sync:callable-invokers -- "$project_id"
}

plan_output="$(
  node "$repo_root/tool/firebase/plan_firebase_deploy_targets.mjs" \
    "$targets_csv" --tsv
)"

while IFS=$'\t' read -r phase deploy_only; do
  [[ -z "$phase" || -z "$deploy_only" ]] && continue
  deploy_target "$phase" "$deploy_only" "$@"
  if [[ "$phase" == "functions" ]]; then
    sync_callable_invokers
  fi
done <<< "$plan_output"
