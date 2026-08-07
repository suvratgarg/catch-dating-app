export const taskCommandTemplates = Object.freeze({
  start: "node tool/harness.mjs task start --task-id <task-id> --base-sha <40-character-sha> --stack-parent <ref> --owned-paths <path[,path...]> --context-pack <pack.json> [--budget-mib 256]",
  doctor: "node tool/harness.mjs task doctor --worktree <task-worktree>",
  finish: "node tool/harness.mjs task finish --worktree <task-worktree>",
  reap: "node tool/harness.mjs task reap --dry-run [--merged-into origin/main] [--stale-days 7]",
});
