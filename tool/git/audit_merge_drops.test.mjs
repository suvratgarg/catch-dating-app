import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import {execFileSync, spawnSync} from "node:child_process";
import {fileURLToPath} from "node:url";
import test from "node:test";
import {
  buildMergeAuditReport,
  classifyMergeTrees,
  evaluateDiscardReceipts,
  parseLsTree,
} from "./audit_merge_drops.mjs";

const scriptPath = fileURLToPath(new URL("./audit_merge_drops.mjs", import.meta.url));

test("parseLsTree preserves exact object identity and paths containing spaces", () => {
  const rows = parseLsTree(
    "100644 blob aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\tdocs/a file.md\0" +
      "100755 blob bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb\ttool/run.sh\0",
  );

  assert.deepEqual(rows.get("docs/a file.md"), {
    mode: "100644",
    type: "blob",
    oid: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
  });
  assert.equal(rows.get("tool/run.sh").mode, "100755");
});

test("classifyMergeTrees reports exact discards, divergence, equivalence, add, and delete", () => {
  const blob = (oid, mode = "100644") => ({mode, type: "blob", oid});
  const base = {
    "discard-ours.txt": blob("base-a"),
    "discard-theirs.txt": blob("base-b"),
    "diverged.txt": blob("base-c"),
    "equivalent.txt": blob("base-d"),
    "delete-discarded.txt": blob("base-e"),
  };
  const ours = {
    "discard-ours.txt": blob("ours-a"),
    "discard-theirs.txt": blob("ours-b"),
    "diverged.txt": blob("ours-c"),
    "equivalent.txt": blob("same-d"),
    "new-theirs-discarded.txt": null,
  };
  const theirs = {
    "discard-ours.txt": blob("theirs-a"),
    "discard-theirs.txt": blob("theirs-b"),
    "diverged.txt": blob("theirs-c"),
    "equivalent.txt": blob("same-d"),
    "delete-discarded.txt": blob("base-e"),
    "new-theirs-discarded.txt": blob("theirs-new"),
  };
  const merged = {
    "discard-ours.txt": blob("theirs-a"),
    "discard-theirs.txt": blob("ours-b"),
    "diverged.txt": blob("merged-c"),
    "equivalent.txt": blob("same-d"),
    "delete-discarded.txt": blob("base-e"),
  };

  const rows = classifyMergeTrees({base, ours, theirs, merged});
  const categories = Object.fromEntries(rows.map((row) => [row.path, row.category]));

  assert.equal(categories["discard-ours.txt"], "discarded-ours");
  assert.equal(categories["discard-theirs.txt"], "discarded-theirs");
  assert.equal(categories["diverged.txt"], "both-diverged");
  assert.equal(categories["equivalent.txt"], "resolved-equivalent");
  assert.equal(categories["delete-discarded.txt"], "discarded-ours");
  assert.equal(categories["new-theirs-discarded.txt"], "discarded-theirs");
  assert.equal(
    rows.find((row) => row.path === "delete-discarded.txt").entries.ours,
    null,
  );
  assert.equal(
    rows.find((row) => row.path === "new-theirs-discarded.txt").entries.base,
    null,
  );
});

test("evaluateDiscardReceipts requires a reason for every exact discard", () => {
  const paths = [
    {path: "a.txt", category: "discarded-ours"},
    {path: "b.txt", category: "discarded-theirs"},
    {path: "c.txt", category: "both-diverged"},
  ];
  const result = evaluateDiscardReceipts(paths, {
    schemaVersion: 1,
    discardedFiles: [
      {path: "a.txt", category: "discarded-ours", reason: "theirs is canonical"},
    ],
  });

  assert.deepEqual(result.missing, [{path: "b.txt", category: "discarded-theirs"}]);
  assert.equal(result.strictPass, false);
  assert.equal(
    evaluateDiscardReceipts(paths, {
      schemaVersion: 1,
      discardedFiles: [
        {path: "a.txt", category: "discarded-ours", reason: "theirs is canonical"},
        {path: "b.txt", category: "discarded-theirs", reason: "ours is canonical"},
      ],
    }).strictPass,
    true,
  );
});

test("buildMergeAuditReport exposes stable categories and strict receipt summary", () => {
  const entry = (oid) => ({mode: "100644", type: "blob", oid});
  const report = buildMergeAuditReport({
    refs: {base: "B", ours: "O", theirs: "T", merged: "M"},
    trees: {
      base: {"file.txt": entry("base")},
      ours: {"file.txt": entry("ours")},
      theirs: {"file.txt": entry("theirs")},
      merged: {"file.txt": entry("theirs")},
    },
  });

  assert.equal(report.schemaVersion, 1);
  assert.deepEqual(report.categories["discarded-ours"], ["file.txt"]);
  assert.equal(report.summary.unreceiptedDiscardedPaths, 1);
});

test("CLI audits temporary Git refs and strict mode rejects then accepts a receipt", () => {
  const repo = fs.mkdtempSync(path.join(os.tmpdir(), "catch-merge-audit-"));
  git(repo, ["init", "-q"]);
  git(repo, ["config", "user.email", "test@example.com"]);
  git(repo, ["config", "user.name", "Catch Test"]);

  write(repo, "choice.txt", "base\n");
  write(repo, "delete choice.txt", "base\n");
  commitAll(repo, "base");
  const base = git(repo, ["rev-parse", "HEAD"]);

  git(repo, ["switch", "-q", "-c", "ours"]);
  write(repo, "choice.txt", "ours\n");
  fs.rmSync(path.join(repo, "delete choice.txt"));
  commitAll(repo, "ours");

  git(repo, ["switch", "-q", "-c", "theirs", base]);
  write(repo, "choice.txt", "theirs\n");
  write(repo, "new from theirs.txt", "theirs\n");
  commitAll(repo, "theirs");

  git(repo, ["switch", "-q", "-c", "merged", base]);
  write(repo, "choice.txt", "theirs\n");
  write(repo, "new from theirs.txt", "theirs\n");
  commitAll(repo, "merged");

  const cliArgs = [
    scriptPath,
    "--repo",
    repo,
    "--base",
    base,
    "--ours",
    "ours",
    "--theirs",
    "theirs",
    "--merged",
    "merged",
    "--strict",
    "--json",
  ];
  const rejected = spawnSync(process.execPath, cliArgs, {encoding: "utf8"});
  assert.equal(rejected.status, 1);
  const rejectedReport = JSON.parse(rejected.stdout);
  assert.deepEqual(rejectedReport.categories["discarded-ours"], [
    "choice.txt",
    "delete choice.txt",
  ]);

  const receiptPath = path.join(repo, "receipt.json");
  fs.writeFileSync(
    receiptPath,
    JSON.stringify({
      schemaVersion: 1,
      discardedFiles: rejectedReport.receipts.expected.map((row) => ({
        ...row,
        reason: "reviewed by fixture",
      })),
    }),
  );
  const accepted = spawnSync(process.execPath, [...cliArgs, "--receipt", receiptPath], {
    encoding: "utf8",
  });
  assert.equal(accepted.status, 0, accepted.stderr);
  assert.equal(JSON.parse(accepted.stdout).receipts.strictPass, true);
});

function git(repo, args) {
  return execFileSync("git", args, {cwd: repo, encoding: "utf8"}).trim();
}

function write(repo, relativePath, source) {
  const file = path.join(repo, relativePath);
  fs.mkdirSync(path.dirname(file), {recursive: true});
  fs.writeFileSync(file, source);
}

function commitAll(repo, message) {
  git(repo, ["add", "-A"]);
  git(repo, ["commit", "-q", "-m", message]);
}
