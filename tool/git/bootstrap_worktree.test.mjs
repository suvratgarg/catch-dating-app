import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import {spawnSync} from "node:child_process";
import test from "node:test";
import {fileURLToPath} from "node:url";

const testDirectory = path.dirname(fileURLToPath(import.meta.url));
const scriptPath = path.join(testDirectory, "bootstrap_worktree.sh");

test("worktree bootstrap installs isolated dependencies in the required order", (context) => {
  const fixtureRoot = fs.mkdtempSync(path.join(os.tmpdir(), "catch-bootstrap-worktree-"));
  context.after(() => fs.rmSync(fixtureRoot, {recursive: true, force: true}));
  fs.mkdirSync(path.join(fixtureRoot, "functions"));
  for (const relativePath of [
    "package-lock.json",
    "functions/package-lock.json",
    "pubspec.yaml",
  ]) {
    fs.writeFileSync(path.join(fixtureRoot, relativePath), "fixture\n");
  }

  const binDirectory = path.join(fixtureRoot, "bin");
  const logPath = path.join(fixtureRoot, "commands.log");
  fs.mkdirSync(binDirectory);
  writeExecutable(path.join(binDirectory, "git"), `#!/usr/bin/env bash
printf '%s\\n' "$CATCH_BOOTSTRAP_TEST_ROOT"
`);
  writeExecutable(path.join(binDirectory, "npm"), `#!/usr/bin/env bash
printf '%s|npm|%s\\n' "$PWD" "$*" >> "$CATCH_BOOTSTRAP_TEST_LOG"
`);
  writeExecutable(path.join(binDirectory, "flutter"), `#!/usr/bin/env bash
printf '%s|flutter|%s\\n' "$PWD" "$*" >> "$CATCH_BOOTSTRAP_TEST_LOG"
`);

  const result = spawnSync("bash", [scriptPath], {
    cwd: fixtureRoot,
    encoding: "utf8",
    env: {
      ...process.env,
      PATH: `${binDirectory}:${process.env.PATH}`,
      CATCH_BOOTSTRAP_TEST_ROOT: fixtureRoot,
      CATCH_BOOTSTRAP_TEST_LOG: logPath,
    },
  });

  assert.equal(result.status, 0, result.stderr);
  assert.match(result.stdout, /Worktree bootstrap complete/u);
  assert.deepEqual(fs.readFileSync(logPath, "utf8").trim().split("\n"), [
    `${fixtureRoot}|npm|ci`,
    `${path.join(fixtureRoot, "functions")}|npm|ci`,
    `${fixtureRoot}|flutter|pub get`,
  ]);
});

test("worktree bootstrap help is dependency-free", () => {
  const result = spawnSync("bash", [scriptPath, "--help"], {encoding: "utf8"});
  assert.equal(result.status, 0, result.stderr);
  assert.match(result.stdout, /root npm workspace dependencies/u);
  assert.match(result.stdout, /Firebase Functions npm dependencies/u);
  assert.match(result.stdout, /Flutter\/Dart packages/u);
});

function writeExecutable(filePath, source) {
  fs.writeFileSync(filePath, source, {mode: 0o755});
}
