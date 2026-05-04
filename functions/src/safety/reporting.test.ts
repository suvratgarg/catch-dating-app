/* eslint-disable require-jsdoc */
import assert from "node:assert/strict";
import test from "node:test";
import {HttpsError} from "firebase-functions/v2/https";
import {normalizeReportText, reportUserHandler} from "./reporting";

test("normalizeReportText trims and bounds optional text", () => {
  assert.equal(normalizeReportText("  harassment  ", 64), "harassment");
  assert.equal(normalizeReportText("   ", 64), undefined);
  assert.equal(normalizeReportText("abcdef", 3), "abc");
});

test("reportUserHandler rejects self reports", async () => {
  await assert.rejects(
    reportUserHandler(
      {
        auth: {uid: "user-1"},
        data: {targetUserId: "user-1"},
      } as never,
      createReportingDeps()
    ),
    (error) =>
      error instanceof HttpsError && error.code === "invalid-argument"
  );
});

test("reportUserHandler writes a bounded open report", async () => {
  const writes: unknown[] = [];

  const result = await reportUserHandler(
    {
      auth: {uid: "reporter-1"},
      data: {
        targetUserId: "target-1",
        source: "chat",
        reasonCode: "abusive_messages",
        contextId: "match-1",
        notes: "x".repeat(2000),
      },
    } as never,
    createReportingDeps(writes)
  );

  assert.deepEqual(result, {reported: true});
  assert.equal(writes.length, 1);
  assert.deepEqual(writes[0], {
    reporterUserId: "reporter-1",
    targetUserId: "target-1",
    createdAt: "SERVER_TIMESTAMP",
    source: "chat",
    status: "open",
    reasonCode: "abusive_messages",
    contextId: "match-1",
    notes: "x".repeat(2000),
  });
});

function createReportingDeps(writes: unknown[] = []) {
  return {
    firestore: () => ({
      collection: (path: string) => {
        assert.equal(path, "reports");
        return {
          add: async (data: unknown) => {
            writes.push(data);
            return {id: "report-1"};
          },
        };
      },
    }),
    serverTimestamp: () => "SERVER_TIMESTAMP",
  } as never;
}
