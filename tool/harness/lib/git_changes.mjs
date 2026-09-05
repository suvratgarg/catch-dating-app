import {spawnSync} from "node:child_process";
import {repoRoot} from "../../lib/repo_paths.mjs";

// Harness and Tools must see the same window. Endpoint diffs alone erase a
// change followed by a reversion while an earlier main CI is still running.
export function changedPathsSince({
  base, head = "HEAD", cwd = repoRoot, commitWindow = false,
}) {
  const git = (args) => {
    const result = spawnSync("git", args, {
      cwd, encoding: "utf8", maxBuffer: 32 * 1024 * 1024,
    });
    if (result.status !== 0) {
      throw new Error(result.stderr || `Unable to resolve Git changes from ${base}.`);
    }
    return result.stdout;
  };
  let commands;
  if (commitWindow) {
    const resolve = (ref) => git([
      "rev-parse", "--verify", "--end-of-options", `${ref}^{commit}`,
    ]).trim();
    const before = resolve(base);
    const after = resolve(head);
    git(["merge-base", "--is-ancestor", before, after]);
    // Separate merge-parent diffs retain changes introduced by merges, even
    // when the contributing branch forked before the selected baseline.
    commands = [[
      "log", "--format=", "--name-only", "--no-renames", "-m", "-z",
      `${before}..${after}`, "--",
    ]];
  } else {
    commands = [
      ["diff", "--name-only", "--no-renames", "-z", `${base}...${head}`, "--"],
      ["diff", "--name-only", "--no-renames", "-z"],
      ["diff", "--cached", "--name-only", "--no-renames", "-z"],
      ["ls-files", "--others", "--exclude-standard", "-z"],
    ];
  }
  return [...new Set(commands.flatMap((args) => git(args).split("\0").filter(Boolean)))].sort();
}
