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

# Refuse to publish a ref that is behind its remote. See the incident note in
# check_deploy_ref.mjs: deploying from a stale local `main` silently removed
# five match blocks from the live Firestore ruleset.
deploy_ref_args=(--env "$environment")
if [[ "${CATCH_DEPLOY_ALLOW_BEHIND:-0}" == "1" ]]; then
  deploy_ref_args+=(--allow-behind)
fi
node "$repo_root/tool/firebase/check_deploy_ref.mjs" "${deploy_ref_args[@]}"

deploy_target() {
  local phase="$1"
  local deploy_only="$2"
  shift
  shift

  if [[ "$phase" == "storage" ]]; then
    echo "::group::Verify Storage rules cross-service IAM"
    node "$repo_root/tool/firebase/storage_rules_firestore_iam.mjs" \
      --env "$environment"
    echo "::endgroup::"
  fi

  echo "::group::Deploy Firebase target: $phase"
  "$repo_root/tool/firebase_with_env.sh" \
    "$environment" deploy --only "$deploy_only" --non-interactive "$@"
  echo "::endgroup::"
}

sync_callable_invokers() {
  local project_id
  local functions_dir
  functions_dir="${CATCH_DELIVERY_FUNCTIONS_DIR:-$repo_root/functions}"
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
  npm --prefix "$functions_dir" run sync:callable-invokers -- "$project_id"
}

plan_output="$(
  node "$repo_root/tool/firebase/plan_firebase_deploy_targets.mjs" \
    "$targets_csv" --tsv
)"

while IFS=$'\t' read -r phase deploy_only; do
  [[ -z "$phase" || -z "$deploy_only" ]] && continue
  if [[ "$phase" == "functions" ]]; then
    function_batches="$(
      CATCH_FIREBASE_SOURCE_ROOT="${CATCH_FIREBASE_SOURCE_ROOT:-$repo_root}" \
        node "$repo_root/tool/firebase/plan_firebase_deploy_targets.mjs" \
          "$deploy_only" --function-batches
    )"
    [[ -n "$function_batches" ]]
    while IFS= read -r function_batch; do
      [[ -z "$function_batch" ]] && continue
      function_batch_status=1
      for function_batch_attempt in 1 2 3; do
        function_batch_status=0
        deploy_target "$phase" "$function_batch" "$@" || \
          function_batch_status=$?
        if [[ "$function_batch_status" == "0" ]]; then
          break
        fi
        echo "Firebase Function batch attempt ${function_batch_attempt} failed; cooling down before the same exact retry." >&2
        sleep 60
      done
      if [[ "$function_batch_status" != "0" ]]; then
        exit "$function_batch_status"
      fi
      # Firebase CLI currently starts up to 40 mutations at once. Keeping each
      # invocation at ten exact targets avoids the per-region mutation and
      # temporary Cloud Run CPU limits without changing the authorized set.
      sleep 10
    done <<< "$function_batches"
    sync_callable_invokers
    node "$repo_root/tool/firebase/check_deploy_parity.mjs" \
      --env "$environment" \
      --repo-root "${CATCH_FIREBASE_SOURCE_ROOT:-$repo_root}"
  else
    deploy_target "$phase" "$deploy_only" "$@"
  fi
done <<< "$plan_output"
