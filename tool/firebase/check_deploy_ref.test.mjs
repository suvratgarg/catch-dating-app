import assert from "node:assert/strict";
import test from "node:test";

import {inspectDeployRef} from "./check_deploy_ref.mjs";

/** Build a fake `git` whose answers are keyed by the joined argument list. */
const fakeGit = (answers) => (...args) => {
  const key = args.join(" ");
  if (!(key in answers)) return {ok: false, out: "", err: `unstubbed: ${key}`};
  const value = answers[key];
  return typeof value === "string" ? {ok: true, out: value, err: ""} : value;
};

test("reports behind when the remote has commits HEAD lacks", () => {
  const result = inspectDeployRef({
    runGit: fakeGit({
      "rev-parse HEAD": "aaaa",
      "rev-parse --abbrev-ref HEAD": "main",
      "rev-parse --abbrev-ref main@{upstream}": "origin/main",
      "rev-parse --verify -q origin/main": "bbbb",
      "rev-list --count HEAD..origin/main": "17",
    }),
  });
  assert.equal(result.verdict, "behind");
  assert.equal(result.behindBy, 17);
  assert.equal(result.remoteRef, "origin/main");
});

test("reports current when nothing is missing", () => {
  const result = inspectDeployRef({
    runGit: fakeGit({
      "rev-parse HEAD": "aaaa",
      "rev-parse --abbrev-ref HEAD": "main",
      "rev-parse --abbrev-ref main@{upstream}": "origin/main",
      "rev-parse --verify -q origin/main": "aaaa",
      "rev-list --count HEAD..origin/main": "0",
    }),
  });
  assert.equal(result.verdict, "current");
  assert.equal(result.behindBy, 0);
});

test("falls back to origin/main for a detached HEAD", () => {
  const result = inspectDeployRef({
    runGit: fakeGit({
      "rev-parse HEAD": "aaaa",
      "rev-parse --abbrev-ref HEAD": "HEAD",
      "rev-parse --verify -q origin/main": "bbbb",
      "rev-list --count HEAD..origin/main": "3",
    }),
  });
  assert.equal(result.verdict, "behind");
  assert.equal(result.remoteRef, "origin/main");
});

test("falls back to origin/<branch> when no upstream is configured", () => {
  const result = inspectDeployRef({
    runGit: fakeGit({
      "rev-parse HEAD": "aaaa",
      "rev-parse --abbrev-ref HEAD": "release",
      "rev-parse --abbrev-ref release@{upstream}": {ok: false, out: "", err: "no upstream"},
      "rev-parse --verify -q origin/release": "bbbb",
      "rev-list --count HEAD..origin/release": "2",
    }),
  });
  assert.equal(result.verdict, "behind");
  assert.equal(result.remoteRef, "origin/release");
});

test("allows the deploy when no remote ref exists to compare against", () => {
  // Blocking on ambiguity would get the guard disabled; it must only stop a
  // deploy it can prove is stale.
  const result = inspectDeployRef({
    runGit: fakeGit({
      "rev-parse HEAD": "aaaa",
      "rev-parse --abbrev-ref HEAD": "local-only",
      "rev-parse --abbrev-ref local-only@{upstream}": {ok: false, out: "", err: "none"},
      "rev-parse --verify -q origin/local-only": {ok: false, out: "", err: "none"},
      "rev-parse --verify -q origin/main": {ok: false, out: "", err: "none"},
    }),
  });
  assert.equal(result.verdict, "unknown");
});

test("treats an unparseable count as unknown rather than current", () => {
  // A silent parse failure that read as "current" would reopen the exact hole
  // this guard closes.
  const result = inspectDeployRef({
    runGit: fakeGit({
      "rev-parse HEAD": "aaaa",
      "rev-parse --abbrev-ref HEAD": "main",
      "rev-parse --abbrev-ref main@{upstream}": "origin/main",
      "rev-parse --verify -q origin/main": "bbbb",
      "rev-list --count HEAD..origin/main": "",
    }),
  });
  assert.equal(result.verdict, "unknown");
});
