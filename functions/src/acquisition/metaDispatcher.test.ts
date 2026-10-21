import assert from "node:assert/strict";
import test from "node:test";
import type {Firestore} from "firebase-admin/firestore";
import {dispatchDueHostMetaLeads, dispatchHostAcquisitionMeta} from
  "./metaDispatcher";

test("Meta runtime uses its dedicated identity and credential", () => {
  const endpoint = dispatchHostAcquisitionMeta.__endpoint;
  assert.equal(endpoint.serviceAccountEmail, "catch-host-meta-delivery@");
  assert.deepEqual(endpoint.secretEnvironmentVariables,
    [{key: "CATCH_HOST_META_CONVERSIONS_TOKEN"}]);
  assert.deepEqual(endpoint.region, ["asia-south1"]);
  assert.equal(endpoint.maxInstances, 1);
  assert.equal(endpoint.timeoutSeconds, 300);
  assert.equal(endpoint.scheduleTrigger?.retryConfig?.retryCount, 0);
});

test("disabled dispatcher touches neither queue nor provider", async () => {
  assert.deepEqual(await dispatchDueHostMetaLeads({enabled: false,
    get db(): never {
      throw new Error("must not read");
    }, send: async () => {
      throw new Error("must not send");
    }}), {examined: 0, accepted: 0, unknown: 0});
  // The deployed wrapper also returns before resolving credentials/Firestore.
  await dispatchHostAcquisitionMeta.run({} as never);
});

test("due scan is bounded, excludes terminal rows and rechecks every row",
  async () => {
    const calls: unknown[][] = [];
    const query = {
      where: (...args: unknown[]) => {
        calls.push(args); return query;
      },
      orderBy: (...args: unknown[]) => {
        calls.push(args); return query;
      },
      limit: (value: number) => {
        calls.push([value]); return query;
      },
      get: async () => ({docs: [{id: "deleted-before-reservation"}]}),
    };
    let reads = 0;
    const db = {
      collection: () => ({...query, doc: (id: string) => ({id})}),
      runTransaction: async (run: (tx: unknown) => Promise<unknown>) => run({
        get: async () => {
          reads++; return {data: () => undefined};
        },
      }),
    } as unknown as Firestore;
    const counts = await dispatchDueHostMetaLeads({enabled: true, db,
      now: () => 1792512000000, send: async () => {
        assert.fail("a stale query row cannot authorize delivery");
      }});
    assert.equal(reads, 1);
    assert.deepEqual(counts, {examined: 1, accepted: 0, unknown: 0});
    assert.deepEqual(calls, [["status", "in", ["pending", "sending"]],
      ["nextAttemptAt", "<=", 1792512000000], ["nextAttemptAt", "asc"], [20]]);
  });
