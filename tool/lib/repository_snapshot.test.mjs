import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import {spawnSync} from "node:child_process";
import test from "node:test";
import {
  createRepositorySnapshot,
  parseBatchBlobs,
  parseIndexEntries,
  parseNulPaths,
  parseWorktreePaths,
} from "./repository_snapshot.mjs";

test("registered nested worktrees are excluded before repository path normalization", (context) => {
  const root = createFixtureRepository(context);
  const nestedWorktree = path.join(root, ".codex", "worktrees", "nested");
  git(root, [
    "worktree",
    "add",
    "-q",
    "-b",
    "nested-worktree-fixture",
    nestedWorktree,
  ]);
  const rawUntracked = gitBuffer(root, [
    "ls-files",
    "-z",
    "--others",
    "--exclude-standard",
    "--full-name",
    "--",
  ]);
  assert.match(rawUntracked.toString("utf8"), /\.codex\/worktrees\/nested\//u);

  const snapshot = createRepositorySnapshot({root});
  assert.equal(
    snapshot.listPaths().some((relativePath) =>
      relativePath.startsWith(".codex/worktrees/nested")),
    false,
  );
  assert.equal(snapshot.readText("tracked.txt", {required: true}), "tracked\n");
});

test("working-tree edits and untracked files override the stage-0 index", (context) => {
  const root = createFixtureRepository(context);
  fs.writeFileSync(path.join(root, "tracked.txt"), "working edit\n");
  fs.writeFileSync(path.join(root, "untracked.txt"), "untracked\n");
  fs.writeFileSync(path.join(root, "ignored.txt"), "ignored\n");

  const snapshot = createRepositorySnapshot({root});
  assert.equal(snapshot.readText("tracked.txt", {required: true}), "working edit\n");
  assert.equal(snapshot.readText("untracked.txt", {required: true}), "untracked\n");
  assert.deepEqual(snapshot.listFiles(), [
    ".gitignore",
    "deleted.txt",
    "hidden.txt",
    "tracked.txt",
    "untracked.txt",
    "visible.txt",
  ]);
  assert.equal(snapshot.exists("ignored.txt"), false);
  assert.equal(snapshot.readText("ignored.txt"), null);
  assert.equal(snapshot.listPaths().includes("ignored.txt"), false);
  assert.equal(Object.isFrozen(snapshot.paths), true);

  const capturedPaths = snapshot.listPaths();
  fs.writeFileSync(path.join(root, "late.txt"), "late\n");
  fs.rmSync(path.join(root, "tracked.txt"));
  assert.deepEqual(snapshot.listPaths(), capturedPaths);
  assert.equal(snapshot.exists("late.txt"), false);
  assert.equal(snapshot.exists("tracked.txt"), true);
  assert.throws(
    () => snapshot.readText("tracked.txt", {required: true}),
    {name: "RepositorySnapshotStaleError"},
  );
});

test("normal and staged deletions are never resurrected from the index", (context) => {
  const root = createFixtureRepository(context);
  fs.rmSync(path.join(root, "deleted.txt"));

  const unstaged = createRepositorySnapshot({root});
  assert.equal(unstaged.exists("deleted.txt"), false);
  assert.equal(unstaged.readText("deleted.txt"), null);
  assert.throws(
    () => unstaged.readText("deleted.txt", {required: true}),
    /Required repository path is missing/,
  );

  git(root, ["add", "-u", "deleted.txt"]);
  const staged = createRepositorySnapshot({root});
  assert.equal(staged.exists("deleted.txt"), false);
  assert.equal(staged.listFiles().includes("deleted.txt"), false);

  fs.appendFileSync(path.join(root, ".gitignore"), "deleted.txt\n");
  fs.writeFileSync(path.join(root, "deleted.txt"), "ignored resurrection\n");
  const ignoredResurrection = createRepositorySnapshot({root});
  assert.equal(ignoredResurrection.exists("deleted.txt"), false);
  assert.equal(ignoredResurrection.readText("deleted.txt"), null);
});

test("sparse-omitted regular files read from local index blobs", (context) => {
  const root = createFixtureRepository(context);
  fs.mkdirSync(path.join(root, "nested"));
  fs.writeFileSync(path.join(root, "nested", "deep.txt"), "deep\n");
  fs.symlinkSync("hidden.txt", path.join(root, "linked.txt"));
  git(root, ["add", "linked.txt", "nested/deep.txt"]);
  git(root, ["commit", "-qm", "add symlink"]);
  git(root, ["sparse-checkout", "init", "--no-cone"]);
  git(root, ["sparse-checkout", "set", "--no-cone", "/visible.txt"]);

  assert.equal(fs.existsSync(path.join(root, "hidden.txt")), false);
  const snapshot = createRepositorySnapshot({root});
  assert.equal(snapshot.exists("hidden.txt"), true);
  assert.equal(snapshot.readText("hidden.txt", {required: true}), "hidden\n");
  assert.equal(snapshot.exists("linked.txt"), true);
  assert.throws(
    () => snapshot.readText("linked.txt", {required: true}),
    /not a regular text file/,
  );
  assert.equal(snapshot.listFiles().includes("hidden.txt"), true);
  assert.equal(snapshot.listFiles().includes("linked.txt"), false);
  assert.equal(snapshot.listPaths().includes("linked.txt"), true);
  assert.deepEqual(
    snapshot.listRootEntries().find(({name}) => name === "nested"),
    {name: "nested", kind: "directory"},
  );
});

test("readTexts hydrates a readiness-sized closure with one cached batch process", (context) => {
  const fixtures = Array.from({length: 820}, (_, index) => ({
    path: `lib/source_${index}.dart`,
    oid: (index + 1).toString(16).padStart(40, "0"),
    source: `source-${index}\n`,
  }));
  let batchCalls = 0;
  let batchInput = "";
  const snapshot = createRepositorySnapshot({
    root: createEmptyRoot(context),
    gitRunner(args, options) {
      if (args.includes("--stage")) {
        return {
          status: 0,
          stdout: Buffer.from(fixtures.map(
            ({path: relativePath, oid}) => `S 100644 ${oid} 0\t${relativePath}\0`,
          ).join("")),
          stderr: Buffer.alloc(0),
        };
      }
      if (args.includes("--others")) {
        return {status: 0, stdout: Buffer.alloc(0), stderr: Buffer.alloc(0)};
      }
      if (args[0] === "worktree") {
        return {status: 0, stdout: Buffer.alloc(0), stderr: Buffer.alloc(0)};
      }
      if (args[0] === "cat-file") {
        batchCalls += 1;
        batchInput = options.input.toString("utf8");
        assert.equal(options.env.GIT_NO_LAZY_FETCH, "1");
        return {
          status: 0,
          stdout: Buffer.concat(fixtures.flatMap(({oid, source}) => [
            Buffer.from(`${oid} blob ${Buffer.byteLength(source)}\n`),
            Buffer.from(source),
            Buffer.from("\n"),
          ])),
          stderr: Buffer.alloc(0),
        };
      }
      throw new Error(`Unexpected Git call: ${args.join(" ")}`);
    },
  });

  const paths = fixtures.map(({path: relativePath}) => relativePath);
  const texts = snapshot.readTexts(paths, {required: true});
  assert.equal(texts.size, 820);
  assert.equal(texts.get("lib/source_0.dart"), "source-0\n");
  assert.equal(texts.get("lib/source_819.dart"), "source-819\n");
  assert.equal(snapshot.readText("lib/source_0.dart", {required: true}), "source-0\n");
  assert.equal(batchCalls, 1);
  assert.equal(batchInput, `${fixtures.map(({oid}) => oid).join("\n")}\n`);
});

test("missing gitlinks remain visible metadata but are never text", (context) => {
  const oid = "a".repeat(40);
  const snapshot = createRepositorySnapshot({
    root: createEmptyRoot(context),
    gitRunner(args) {
      if (args.includes("--stage")) {
        return {
          status: 0,
          stdout: Buffer.from(`H 160000 ${oid} 0\tpackages/shared\0`),
          stderr: Buffer.alloc(0),
        };
      }
      if (args.includes("--others")) {
        return {status: 0, stdout: Buffer.alloc(0), stderr: Buffer.alloc(0)};
      }
      if (args[0] === "worktree") {
        return {status: 0, stdout: Buffer.alloc(0), stderr: Buffer.alloc(0)};
      }
      throw new Error(`Unexpected Git call: ${args.join(" ")}`);
    },
  });

  assert.equal(snapshot.exists("packages/shared"), true);
  assert.deepEqual(snapshot.listPaths(), ["packages/shared"]);
  assert.throws(
    () => snapshot.readText("packages/shared", {required: true}),
    /not a regular text file/,
  );
});

test("unmerged stages and malformed NUL output fail closed", () => {
  const oid = "a".repeat(40);
  assert.deepEqual(
    [...parseIndexEntries(Buffer.from(
      `H 100644 ${oid} 0\tfirst.txt\0S 100755 ${oid} 0\tsecond.txt\0`,
    )).keys()],
    ["first.txt", "second.txt"],
  );
  assert.throws(
    () => parseIndexEntries(
      Buffer.from(`M 100644 ${"a".repeat(40)} 1\tconflicted.txt\0`),
    ),
    /unresolved stage 1/,
  );
  assert.throws(
    () => parseNulPaths(Buffer.from("not-terminated")),
    /not NUL terminated/,
  );
  assert.deepEqual(
    parseWorktreePaths(Buffer.from(
      "worktree /repo\0HEAD abc\0\0worktree /repo/nested\0detached\0\0",
    )),
    ["/repo", "/repo/nested"],
  );
  assert.deepEqual(
    parseNulPaths(
      Buffer.from(".codex/worktrees/nested/\0kept.txt\0"),
      "fixture",
      {excludedPrefixes: [".codex/worktrees/nested"]},
    ),
    ["kept.txt"],
  );
});

test("cat-file batch framing fails closed", () => {
  const oid = "a".repeat(40);
  const otherOid = "b".repeat(40);
  assert.throws(
    () => parseBatchBlobs(Buffer.from(`${oid} missing\n`), [oid]),
    /is missing/,
  );
  assert.throws(
    () => parseBatchBlobs(Buffer.from(`${oid} commit 0\n\n`), [oid]),
    /unsupported type/,
  );
  assert.throws(
    () => parseBatchBlobs(Buffer.from(`${otherOid} blob 0\n\n`), [oid]),
    /Malformed cat-file batch header/,
  );
  assert.throws(
    () => parseBatchBlobs(Buffer.from(`${oid} blob 10\na\n`), [oid]),
    /malformed batch framing/,
  );
  assert.throws(
    () => parseBatchBlobs(Buffer.from(`${oid} blob 1\na`), [oid]),
    /malformed batch framing/,
  );
  assert.throws(
    () => parseBatchBlobs(Buffer.from(`${oid} blob 1\na\nextra`), [oid]),
    /unexpected trailing bytes/,
  );
  assert.deepEqual(
    parseBatchBlobs(Buffer.concat([
      Buffer.from(`${oid} blob 3\n`),
      Buffer.from([0x61, 0x00, 0x0a, 0x0a]),
    ]), [oid]).get(oid),
    Buffer.from([0x61, 0x00, 0x0a]),
  );
});

test("sparse index reads refuse hidden lazy network fetches", (context) => {
  const oid = "b".repeat(40);
  let catFileEnvironment = null;
  const snapshot = createRepositorySnapshot({
    root: createEmptyRoot(context),
    gitRunner(args, options) {
      if (args.includes("--stage")) {
        return {
          status: 0,
          stdout: Buffer.from(`S 100644 ${oid} 0\tomitted.txt\0`),
          stderr: Buffer.alloc(0),
        };
      }
      if (args.includes("--others")) {
        return {status: 0, stdout: Buffer.alloc(0), stderr: Buffer.alloc(0)};
      }
      if (args[0] === "worktree") {
        return {status: 0, stdout: Buffer.alloc(0), stderr: Buffer.alloc(0)};
      }
      if (args[0] === "cat-file") {
        catFileEnvironment = options.env;
        return {
          status: 1,
          stdout: Buffer.alloc(0),
          stderr: Buffer.from("missing promisor object"),
        };
      }
      throw new Error(`Unexpected Git call: ${args.join(" ")}`);
    },
  });

  assert.equal(snapshot.exists("omitted.txt"), true);
  assert.throws(
    () => snapshot.readText("omitted.txt", {required: true}),
    /cannot be read from local Git object.*missing promisor object/,
  );
  assert.equal(catFileEnvironment.GIT_NO_LAZY_FETCH, "1");
});

test("repository paths reject traversal, absolute paths, and binary text", (context) => {
  const root = createFixtureRepository(context);
  fs.writeFileSync(path.join(root, "binary.txt"), Buffer.from([0x61, 0x00, 0x62]));
  const snapshot = createRepositorySnapshot({root});
  assert.throws(() => snapshot.exists("../secret"), /relative and canonical/);
  assert.throws(() => snapshot.exists("/absolute"), /relative and canonical/);
  assert.throws(() => snapshot.readText("binary.txt"), /contains NUL bytes/);
});

function createFixtureRepository(context) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-repository-snapshot-"));
  context.after(() => fs.rmSync(root, {recursive: true, force: true}));
  git(root, ["init", "-q"]);
  git(root, ["config", "user.email", "snapshot@example.com"]);
  git(root, ["config", "user.name", "Snapshot Test"]);
  for (const [relativePath, source] of Object.entries({
    ".gitignore": "ignored.txt\n",
    "deleted.txt": "delete me\n",
    "hidden.txt": "hidden\n",
    "tracked.txt": "tracked\n",
    "visible.txt": "visible\n",
  })) {
    fs.writeFileSync(path.join(root, relativePath), source);
  }
  git(root, ["add", "."]);
  git(root, ["commit", "-qm", "fixture"]);
  return root;
}

function createEmptyRoot(context) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-repository-snapshot-empty-"));
  context.after(() => fs.rmSync(root, {recursive: true, force: true}));
  return root;
}

function git(root, args) {
  const result = spawnSync("git", args, {cwd: root, encoding: "utf8"});
  assert.equal(result.status, 0, result.stderr || `git ${args.join(" ")} failed`);
  return result.stdout;
}

function gitBuffer(root, args) {
  const result = spawnSync("git", args, {cwd: root});
  assert.equal(
    result.status,
    0,
    result.stderr?.toString() || `git ${args.join(" ")} failed`,
  );
  return result.stdout;
}
