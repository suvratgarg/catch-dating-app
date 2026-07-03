import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {
  extractCheckRateLimitActions,
  extractRateLimitKeys,
  scanFunctionRateLimits,
} from "./check_fn_rate_limits.mjs";

test("extractRateLimitKeys reads RATE_LIMITS object keys", () => {
  const keys = extractRateLimitKeys(`
    export const RATE_LIMITS: Record<string, RateLimitConfig> = {
      createClub: {maxRequests: 3, windowMs: 60 * 1000},
      "joinWaitlist": {
        maxRequests: 3,
        windowMs: 60 * 1000,
      },
    };
  `);

  assert.deepEqual([...keys].sort(), ["createClub", "joinWaitlist"]);
});

test("extractCheckRateLimitActions reads literal actions from nested calls", () => {
  const actions = extractCheckRateLimitActions(`
    await checkRateLimit(admin.firestore(), userId, "placesAutocomplete");
    await deps.checkRateLimit(db, hostUid, "decideEventJoinRequest");
  `);

  assert.deepEqual(actions.map((action) => action.value), [
    "placesAutocomplete",
    "decideEventJoinRequest",
  ]);
});

test("scanFunctionRateLimits flags checkRateLimit actions missing entries", () => {
  const root = createFixture({
    "functions/src/shared/rateLimit.ts": `
      export const RATE_LIMITS: Record<string, RateLimitConfig> = {
        createClub: {maxRequests: 3, windowMs: 60 * 1000},
      };
    `,
    "functions/src/clubs/createClub.ts": `
      await checkRateLimit(db, uid, "createClub");
      await checkRateLimit(db, uid, "missingAction");
    `,
  });

  const result = scanFunctionRateLimits({root});

  assert.deepEqual(result.findings.map((finding) => finding.action), [
    "missingAction",
  ]);
});

test("scanFunctionRateLimits passes when actions have explicit entries", () => {
  const root = createFixture({
    "functions/src/shared/rateLimit.ts": `
      export const RATE_LIMITS: Record<string, RateLimitConfig> = {
        createClub: {maxRequests: 3, windowMs: 60 * 1000},
      };
    `,
    "functions/src/clubs/createClub.ts": `
      await checkRateLimit(db, uid, "createClub");
    `,
  });

  assert.deepEqual(scanFunctionRateLimits({root}).findings, []);
});

function createFixture(files) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-fn-rate-"));
  for (const [relativePath, source] of Object.entries(files)) {
    const file = path.join(root, relativePath);
    fs.mkdirSync(path.dirname(file), {recursive: true});
    fs.writeFileSync(file, source);
  }
  return root;
}
