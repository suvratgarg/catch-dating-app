import {strict as assert} from "node:assert";
import {test} from "node:test";
import type {Firestore} from "firebase-admin/firestore";
import {
  hostConsentKey, HOST_ATTRIBUTION_LIFETIME_MS,
} from "./consentPolicy";
import {recordHostConsent} from "./consentStore";

const now = 1792512000000;
const capability = "a".repeat(64);
const request = {action: "grant" as const, capability, choice: {
  version: 1 as const, purpose: "host_acquisition_measurement" as const,
  analytics: true as const, advertising: true, chosenAt: now,
}};

function database() {
  const rows = new Map<string, Record<string, unknown>>();
  let writes = 0;
  let queue: Promise<unknown> = Promise.resolve();
  const db = {
    collection: (name: string) => ({
      doc: (id: string) => ({path: `${name}/${id}`}),
    }),
    runTransaction: (run: (tx: unknown) => Promise<unknown>) => {
      const result = queue.then(async () => {
        const pending = new Map<string, Record<string, unknown>>();
        const tx = {
          get: async (ref: {path: string}) => ({
            exists: rows.has(ref.path),
            data: () => structuredClone(rows.get(ref.path)),
          }),
          set: (ref: {path: string}, row: Record<string, unknown>) => {
            pending.set(ref.path, structuredClone(row));
          },
          create: (ref: {path: string}, row: Record<string, unknown>) => {
            assert.equal(rows.has(ref.path), false);
            pending.set(ref.path, structuredClone(row));
          },
        };
        const value = await run(tx);
        for (const [key, row] of pending) rows.set(key, row);
        writes += pending.size;
        return value;
      });
      queue = result.catch(() => undefined);
      return result;
    },
  } as unknown as Firestore;
  return {db, rows, writes: () => writes};
}

test("disabled handshake never opens Firestore", async () => {
  const result = await recordHostConsent({request, enabled: false,
    get db(): never {
      throw new Error("Disabled permission must not access storage.");
    }});
  assert.deepEqual(result, {ok: true, status: "disabled", expiresAt: null});
});

test("grant replay preserves expiry and hashed identity", async () => {
  const store = database();
  const first = await recordHostConsent({...store, request, enabled: true,
    now: () => now});
  assert.deepEqual(first, {ok: true, status: "active",
    expiresAt: now + HOST_ATTRIBUTION_LIFETIME_MS});
  assert.equal(store.writes(), 1);
  assert.deepEqual(await recordHostConsent({...store, request, enabled: true,
    now: () => now + 24 * 60 * 60 * 1000}), first);
  assert.equal(store.writes(), 1);
  const serialized = JSON.stringify([...store.rows]);
  assert.equal(serialized.includes(capability), false);
  assert.equal(serialized.includes(hostConsentKey(capability)!), true);
  assert.deepEqual(await recordHostConsent({...store, request, enabled: true,
    now: () => now + HOST_ATTRIBUTION_LIFETIME_MS}),
  {ok: true, status: "revoked", expiresAt: null});
});

test("withdrawal tombstone rejects a delayed grant and repeated withdrawal",
  async () => {
    const store = database();
    const revoke = {action: "revoke" as const, capability};
    const result = await recordHostConsent({...store, request: revoke,
      enabled: true, now: () => now});
    assert.deepEqual(await recordHostConsent({...store, request,
      enabled: true, now: () => now + 1}), result);
    assert.deepEqual(await recordHostConsent({...store, request: revoke,
      enabled: false, now: () => now + 1000}), result);
    assert.equal(store.writes(), 1);
    assert.equal([...store.rows.values()][0].authority, null);
  });

test("grant and withdrawal converge to revoked in either transaction order",
  async () => {
    for (const revokeFirst of [true, false]) {
      const store = database();
      const grant = () => recordHostConsent({...store, request, enabled: true,
        now: () => now});
      const revoke = () => recordHostConsent({...store,
        request: {action: "revoke", capability}, enabled: true,
        now: () => now});
      const actions = revokeFirst ? [revoke(), grant()] : [grant(), revoke()];
      await Promise.all(actions);
      assert.equal([...store.rows.values()][0].status, "revoked");
      assert.equal((await grant() as {status: string}).status, "revoked");
    }
  });

test("a capability cannot silently acquire different permission", async () => {
  const store = database();
  await recordHostConsent({...store, request, enabled: true, now: () => now});
  await assert.rejects(recordHostConsent({...store, enabled: true,
    request: {...request, choice: {...request.choice, advertising: false}},
    now: () => now}), {code: "failed-precondition"});
  assert.equal(store.writes(), 1);
});

test("malformed stored permissions and stale new choices fail closed",
  async () => {
    const store = database();
    await assert.rejects(recordHostConsent({...store, request, enabled: true,
      now: () => now + 300001}), {code: "invalid-argument"});
    assert.equal(store.writes(), 0);
    store.rows.set(`hostAcquisitionConsents/${hostConsentKey(capability)}`,
      {consentId: hostConsentKey(capability), status: "active"});
    await assert.rejects(recordHostConsent({...store, request, enabled: true,
      now: () => now}), {code: "failed-precondition"});
    assert.equal(store.writes(), 0);
  });
