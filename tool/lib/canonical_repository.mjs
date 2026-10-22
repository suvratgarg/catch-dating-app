import assert from "node:assert/strict";

// The canonical repository's immutable GitHub ID. Its owner/name changes on a
// rename or organization transfer; the ID does not, and a fork never shares it.
export const CANONICAL_REPOSITORY_ID = 1170579691;

/** Returns the current owner/name after proving this job runs in the canonical repository. */
export function canonicalRepository(env = process.env) {
  assert.equal(env.GITHUB_REPOSITORY_ID, String(CANONICAL_REPOSITORY_ID),
    "Release must run in the canonical repository");
  assert.match(env.GITHUB_REPOSITORY ?? "", /^[A-Za-z0-9][A-Za-z0-9-]*\/[A-Za-z0-9_.-]+$/u);
  return env.GITHUB_REPOSITORY;
}
