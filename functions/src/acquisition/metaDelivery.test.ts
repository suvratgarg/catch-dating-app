import assert from "node:assert/strict";
import test from "node:test";
import {Timestamp, type Firestore} from "firebase-admin/firestore";
import {newHostConsentAuthority} from "./consentPolicy";
import {
  deliverHostMetaLead, expireHostMetaDeliveries,
  HOST_DELIVERY_COLLECTION, prepareHostMetaDelivery,
  stopHostMetaDeliveriesForConsent,
} from "./metaDelivery";

const now = 1792512000000;
const eventId = `host_lead_${now}_00000000-0000-4000-8000-000000000001`;
const consentId = "a".repeat(64);
const intentId = "b".repeat(64);
const authority = newHostConsentAuthority({version: 1,
  purpose: "host_acquisition_measurement", analytics: true,
  advertising: true, chosenAt: now}, now);
const consentDocument = {
  schemaVersion: 1, classification: "sales_private", consentId,
  status: "active", authority, createdAt: Timestamp.fromMillis(now),
  updatedAt: Timestamp.fromMillis(now),
  expiresAt: Timestamp.fromMillis(authority.expiresAt),
};
const input = {enabled: true, isNew: true, eventId, intentId, consentId,
  consentDocument, context: {clientId: "123.1792512000",
    userAgent: "Synthetic Host browser"}, now};
const deliveryPath = `${HOST_DELIVERY_COLLECTION}/${eventId}`;
const consentPath = `hostAcquisitionConsents/${consentId}`;
const intentPath = `salesInboundIntents/${intentId}`;

test("withdrawal erases only the matching capability's retained context",
  async () => {
    const store = database();
    const originalCollection = store.db.collection.bind(store.db);
    const db = {
      runTransaction: store.db.runTransaction.bind(store.db),
      collection: (name: string) => ({
        ...originalCollection(name),
        where: (field: string, operator: string, value: string) => {
          assert.equal(name, HOST_DELIVERY_COLLECTION);
          assert.equal(field, "consentId");
          assert.equal(operator, "==");
          assert.equal(value, consentId);
          return {limit: (limit: number) => {
            assert.equal(limit, 500);
            return {get: async () => ({docs: [{
              id: eventId, ref: {path: deliveryPath},
            }]})};
          }};
        },
      }),
    } as unknown as Firestore;
    await stopHostMetaDeliveriesForConsent(db, consentId);
    assert.equal(store.rows.get(deliveryPath)?.context, null);
    assert.equal(store.rows.get(deliveryPath)?.status, "stopped");
    assert.deepEqual(store.rows.get(consentPath)?.authority, authority);
  });

function database() {
  const row = prepareHostMetaDelivery(input)!;
  const rows = new Map<string, Record<string, unknown>>([
    [deliveryPath, structuredClone({...row})],
    [consentPath, structuredClone(consentDocument)],
    [intentPath, {classification: "sales_private", source: "website",
      hostLead: {eventId, isNew: true}}],
  ]);
  let queue: Promise<unknown> = Promise.resolve();
  let count = 0;
  let beforeTransaction: (count: number) => void = () => {};
  const db = {
    collection: (name: string) => ({
      doc: (id: string) => ({path: `${name}/${id}`}),
    }),
    runTransaction: (run: (tx: unknown) => Promise<unknown>) => {
      const result = queue.then(async () => {
        beforeTransaction(++count);
        let writes = false;
        const pending = new Map<string, Record<string, unknown>>();
        const value = await run({
          get: async (ref: {path: string}) => {
            assert.equal(writes, false, "all reads precede writes");
            return {exists: rows.has(ref.path),
              data: () => structuredClone(rows.get(ref.path))};
          },
          update: (ref: {path: string}, update: Record<string, unknown>) => {
            writes = true;
            pending.set(ref.path, {...rows.get(ref.path), ...update});
          },
        });
        for (const [key, value] of pending) rows.set(key, value);
        return value;
      });
      queue = result.catch(() => undefined);
      return result;
    },
  } as unknown as Firestore;
  return {db, rows, before: (fn: typeof beforeTransaction) => {
    beforeTransaction = fn;
  }};
}
test("only a new, permission-bound Host lead prepares the closed delivery",
  () => {
    const row = prepareHostMetaDelivery({...input,
      context: {...input.context, email: "private@example.test",
        answers: "never forward"}});
    assert.ok(row);
    assert.deepEqual(row.context, input.context);
    assert.equal(JSON.stringify(row).includes("private@example.test"), false);
    for (const override of [{enabled: false}, {isNew: false},
      {consentDocument: {...consentDocument, status: "revoked",
        attributionCleanupPending: true}},
      {consentDocument: {...consentDocument, authority: {...authority,
        advertising: false}}}, {eventId: "a-business-id"},
      {consentId: "c".repeat(64)}]) {
      assert.equal(prepareHostMetaDelivery({...input, ...override}), null);
    }
  });
test("disabled delivery never accesses the database or provider", async () => {
  assert.equal(await deliverHostMetaLead({enabled: false, eventId,
    get db(): never {
      throw new Error("disabled");
    }, send: async () => {
      throw new Error("disabled");
    }}), "disabled");
});
test("two workers reserve one send and accepted receipts never resend",
  async () => {
    const store = database();
    let sends = 0;
    const send = async () => {
      sends++; return {status: 200, body: {events_received: 1, messages: []}};
    };
    const delivery = {...store, eventId, enabled: true, now: () => now, send};
    await Promise.all([deliverHostMetaLead(delivery),
      deliverHostMetaLead(delivery)]);
    assert.equal(sends, 1);
    assert.equal(store.rows.get(deliveryPath)?.status, "accepted");
    assert.equal(store.rows.get(deliveryPath)?.context, null);
    await deliverHostMetaLead(delivery);
    assert.equal(sends, 1);
  });
test("withdrawal or intake deletion before dispatch stops send",
  async () => {
    for (const path of [consentPath, intentPath]) {
      const store = database();
      store.before((count) => {
        if (count === 2) store.rows.delete(path);
      });
      let sends = 0;
      assert.equal(await deliverHostMetaLead({...store, eventId,
        enabled: true, now: () => now, send: async () => {
          sends++; return {status: 200, body: {}};
        }}), "stopped");
      assert.equal(sends, 0);
      assert.equal(store.rows.get(deliveryPath)?.context, null);
    }
  });
test("network ambiguity and interrupted sends never automatically retry",
  async () => {
    for (const interrupted of [false, true]) {
      const store = database();
      if (interrupted) {
        store.rows.set(deliveryPath, {
          ...store.rows.get(deliveryPath), status: "sending", attempts: 1,
          attemptId: "00000000-0000-4000-8000-000000000002",
          lastAttemptAt: now - 60_000,
        });
      }
      let sends = 0;
      const delivery = {...store, eventId, enabled: true, now: () => now,
        send: async (): Promise<never> => {
          sends++; throw new Error("timeout with unknown provider receipt");
        }};
      await deliverHostMetaLead(delivery);
      await deliverHostMetaLead(delivery);
      assert.equal(sends, interrupted ? 0 : 1);
      assert.equal(store.rows.get(deliveryPath)?.status, "unknown");
      assert.equal(store.rows.get(deliveryPath)?.context, null);
    }
  });
test("explicit rejection retries are delayed, bounded and permission checked",
  async () => {
    const store = database();
    let clock = now;
    let sends = 0;
    const delivery = {...store, eventId, enabled: true, now: () => clock,
      send: async () => {
        sends++; return {status: 429, body: {error: {code: 4}}};
      }};
    assert.equal(await deliverHostMetaLead(delivery), "pending");
    await deliverHostMetaLead(delivery);
    assert.equal(sends, 1);
    clock += 120_000;
    assert.equal(await deliverHostMetaLead(delivery), "pending");
    store.rows.set(consentPath, {...consentDocument, status: "revoked",
      attributionCleanupPending: true});
    clock += 240_000;
    await deliverHostMetaLead(delivery);
    assert.equal(sends, 2);
    assert.equal(store.rows.get(deliveryPath)?.status, "stopped");
    assert.equal(store.rows.get(deliveryPath)?.context, null);
  });
test("missing receipt and expired delivery cannot send", async () => {
  for (const expired of [false, true]) {
    const store = database();
    if (!expired) {
      store.rows.set(intentPath, {classification: "sales_private",
        source: "website", hostLead: {eventId, isNew: false}});
    }
    await deliverHostMetaLead({...store, eventId, enabled: true,
      now: () => now + (expired ? 24 * 60 * 60 * 1000 : 0),
      send: async () => {
        assert.fail("must not send");
      }});
    assert.equal(store.rows.get(deliveryPath)?.status, "stopped");
  }
});

test("the fifth throttled attempt stops and erases its browser context",
  async () => {
    const store = database();
    store.rows.set(deliveryPath, {
      ...store.rows.get(deliveryPath), attempts: 4,
    });
    assert.equal(await deliverHostMetaLead({...store, eventId, enabled: true,
      now: () => now, send: async () =>
        ({status: 429, body: {error: {code: 4}}})}), "stopped");
    assert.equal(store.rows.get(deliveryPath)?.attempts, 5);
    assert.equal(store.rows.get(deliveryPath)?.context, null);
  });

test("expiry rechecks source time and removes terminal private context",
  async () => {
    const row = prepareHostMetaDelivery(input)!;
    const deleted: string[] = [];
    const db = {
      collection: (name: string) => {
        assert.equal(name, HOST_DELIVERY_COLLECTION);
        return {where: () => ({limit: (limit: number) => {
          assert.equal(limit, 500);
          return {get: async () => ({docs: [{id: eventId,
            ref: {path: deliveryPath}}]})};
        }})};
      },
      runTransaction: async (run: (tx: unknown) => Promise<unknown>) => run({
        get: async () => ({data: () => row}),
        delete: (ref: {path: string}) => deleted.push(ref.path),
      }),
    } as unknown as Firestore;
    assert.equal(await expireHostMetaDeliveries(db, now), 0);
    assert.equal(await expireHostMetaDeliveries(db,
      now + 24 * 60 * 60 * 1000), 1);
    assert.deepEqual(deleted, [deliveryPath]);
  });
