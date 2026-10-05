import assert from "node:assert/strict";
import {spawnSync} from "node:child_process";
import {fileURLToPath} from "node:url";

// This permits only the exact reviewed PR552 source delta. The deployment
// still consumes the older immutable CI artifact, never current-main source.
export const OPERATOR_SOURCE_SHA = "656f093d1910afdbe4d93d31565d1782c39aab63";
export const COMPATIBILITY_CHECKPOINT = "f509e144579403bd3dd66fc39ae0ee821ca0ab30";
export const GUARDED_PATHS = Object.freeze([
  "functions/src", "functions/package.json", "functions/package-lock.json",
  "functions/scripts/set-callable-invokers-public.cjs", "firebase.json",
  ".firebaserc", "firestore.indexes.json",
]);
export const REVIEWED_DELTA = Object.freeze([
  {
    "path": "functions/src/index.ts",
    "candidateGitBlob": "b70e781a90d0afb9f32f742d39b75587c8ca9cef",
    "mergedGitBlob": "4b2469d39d2268bb6f6417b86aab04714dabd001"
  },
  {
    "path": "functions/src/programs/programManifestImport.test.ts",
    "candidateGitBlob": "541253ef48407190856d89abb18e2aac75202e5c",
    "mergedGitBlob": "42c86bba63dae9f415046d253aff13dad397a08d"
  },
  {
    "path": "functions/src/programs/programManifestImport.ts",
    "candidateGitBlob": "06e3e8c1f0874c57da03d390187581ef9e3a3ea1",
    "mergedGitBlob": "957ea77454c7311a4811ddeeab11d4b298bf8b5b"
  },
  {
    "path": "functions/src/shared/generated/schemas/importProgramManifestInput.ts",
    "candidateGitBlob": "574c587f38d4e86f6770f0b7170c4ff2be1b74b8",
    "mergedGitBlob": "ce2ff3c2c8492399a446b9c6af6be9a4e1445986"
  },
  {
    "path": "functions/src/shared/generated/schemas/programManifestImportOutput.ts",
    "candidateGitBlob": "5aac51d88e0df0f2f9d497233c88b12219d6b2bd",
    "mergedGitBlob": "e02da57dba0786b98e2a3a7f7dd050ab1c796996"
  },
  {
    "path": "functions/src/shared/privateEventReleaseConfig.test.ts",
    "candidateGitBlob": "c30d6645c55f8f54e6bf0d99a5343d24e45327bf",
    "mergedGitBlob": "a8de823a576d110f19384db18ed8d5024dc173b3"
  },
  {
    "path": "functions/src/shared/privateEventReleaseConfig.ts",
    "candidateGitBlob": "604e3c4993f4db53bc65ac27a320acf325cadca6",
    "mergedGitBlob": "238862646211e0675ec393c84e80e175f2f58903"
  }
]);

export function verifySourceCompatibility(evidence) {
  assert.equal(evidence.sourceSha, OPERATOR_SOURCE_SHA);
  assert.match(evidence.currentSha, /^[0-9a-f]{40}$/);
  assert.equal(evidence.sourceAncestor, true);
  assert.equal(evidence.checkpointAncestor, true);
  assert.deepEqual([...evidence.changedPaths].sort(), REVIEWED_DELTA.map((row) => row.path).sort());
  assert.deepEqual(evidence.currentDifference, []);
  assert.equal(evidence.rows.length, REVIEWED_DELTA.length);
  for (const expected of REVIEWED_DELTA) {
    const row = evidence.rows.find((item) => item.path === expected.path);
    assert.deepEqual(row, {...expected, candidateMode: "100644", checkpointMode: "100644"});
  }
  return {sourceSha: OPERATOR_SOURCE_SHA, compatibilityCheckpoint: COMPATIBILITY_CHECKPOINT};
}

export function checkGitCompatibility(sourceSha, currentSha, cwd = process.cwd()) {
  assert.equal(sourceSha, OPERATOR_SOURCE_SHA);
  assert.match(currentSha, /^[0-9a-f]{40}$/);
  function git(args) {
    const result = spawnSync("git", args, {cwd, encoding: "utf8", timeout: 10000, maxBuffer: 1024 * 1024});
    assert.ifError(result.error);
    assert.equal(result.status, 0, "Operator compatibility Git proof failed.");
    return result.stdout;
  }
  for (const sha of [sourceSha, currentSha, COMPATIBILITY_CHECKPOINT]) {
    assert.equal(git(["rev-parse", "--verify", `${sha}^{commit}`]).trim(), sha);
  }
  git(["merge-base", "--is-ancestor", sourceSha, currentSha]);
  git(["merge-base", "--is-ancestor", COMPATIBILITY_CHECKPOINT, currentSha]);
  function differences(before, after) {
    return git(["diff", "--name-only", "-z", before, after, "--", ...GUARDED_PATHS]).split("\0").filter(Boolean);
  }
  function entry(sha, path) {
    const value = git(["ls-tree", sha, "--", path]).trim();
    const match = /^(\d{6}) blob ([0-9a-f]{40})\t/.exec(value);
    assert.ok(match, "Operator compatibility requires regular tracked source.");
    return {mode: match[1], blob: match[2]};
  }
  const rows = REVIEWED_DELTA.map(({path}) => {
    const candidate = entry(sourceSha, path);
    const checkpoint = entry(COMPATIBILITY_CHECKPOINT, path);
    return {path, candidateGitBlob: candidate.blob, mergedGitBlob: checkpoint.blob,
      candidateMode: candidate.mode, checkpointMode: checkpoint.mode};
  });
  return verifySourceCompatibility({sourceSha, currentSha, sourceAncestor: true, checkpointAncestor: true,
    changedPaths: differences(sourceSha, COMPATIBILITY_CHECKPOINT), rows,
    currentDifference: differences(COMPATIBILITY_CHECKPOINT, currentSha)});
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  assert.ok(process.argv.length === 4 || process.argv.length === 5);
  console.log(JSON.stringify(checkGitCompatibility(process.argv[2], process.argv[3], process.argv[4])));
}
