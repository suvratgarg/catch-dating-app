import * as admin from "firebase-admin";
import type {
  OrganizerContactDocument,
} from "../shared/generated/firestoreAdminTypes";
import assert from "node:assert/strict";
import test from "node:test";
import {
  isWhatsappServiceWindowOpen,
  listOrganizerWhatsappThreadsHandler,
  organizerWhatsappMessageId,
  organizerWhatsappReplyOperationId,
  organizerWhatsappThreadId,
  verifiedWhatsappContactUid,
  whatsappServiceWindowMillis,
  whatsappThreadRetentionMillis,
} from "./organizerWhatsappThreads";

test("WhatsApp reply window is open for 24 hours after last inbound", () => {
  const inboundAt = 1_000;
  assert.equal(isWhatsappServiceWindowOpen(inboundAt, inboundAt), true);
  assert.equal(
    isWhatsappServiceWindowOpen(
      inboundAt,
      inboundAt + whatsappServiceWindowMillis - 1
    ),
    true
  );
  assert.equal(
    isWhatsappServiceWindowOpen(
      inboundAt,
      inboundAt + whatsappServiceWindowMillis
    ),
    false
  );
  assert.equal(isWhatsappServiceWindowOpen(inboundAt, inboundAt - 1), false);
});

test("WhatsApp retained bodies use the settled 12-month TTL", () => {
  assert.equal(whatsappThreadRetentionMillis, 365 * 24 * 60 * 60 * 1000);
});

test("WhatsApp thread and message ids are deterministic and scoped", () => {
  const thread = organizerWhatsappThreadId("organizer-1", "contact-1");
  assert.equal(
    thread,
    organizerWhatsappThreadId("organizer-1", "contact-1")
  );
  assert.notEqual(
    thread,
    organizerWhatsappThreadId("organizer-2", "contact-1")
  );
  assert.match(thread, /^owt_[a-f0-9]{48}$/);
  assert.match(
    organizerWhatsappMessageId("organizer-1", "wamid.1"),
    /^owm_[a-f0-9]{48}$/
  );
  const operation = organizerWhatsappReplyOperationId(
    "organizer-1",
    thread,
    "reply-key-1"
  );
  assert.equal(
    operation,
    organizerWhatsappReplyOperationId(
      "organizer-1",
      thread,
      "reply-key-1"
    )
  );
  assert.match(operation, /^owro_[a-f0-9]{48}$/);
});


test("person joins require verified organizer-scoped identity", () => {
  const verified = {
    organizerId: "organizer-1", linkedUid: "person-1",
    identityState: "verified", identityConfidence: "verified",
    deletedAt: null, hiddenAt: null, mergedIntoContactId: null,
  } as OrganizerContactDocument;
  assert.equal(verifiedWhatsappContactUid(verified, "organizer-1"), "person-1");
  assert.equal(verifiedWhatsappContactUid(verified, "organizer-2"), null);
  assert.equal(verifiedWhatsappContactUid(undefined, "organizer-1"), null);
  for (const override of [
    {identityState: "unverified"}, {identityConfidence: "ambiguous"},
    {deletedAt: {}}, {hiddenAt: {}}, {mergedIntoContactId: "another"},
    {linkedUid: null},
  ]) {
    assert.equal(verifiedWhatsappContactUid(
      {...verified, ...override} as OrganizerContactDocument, "organizer-1"
    ), null);
  }
});


test("expired list prefixes advance the authorized cursor", async () => {
  const timestamp = (value: number) =>
    admin.firestore.Timestamp.fromMillis(value);
  const now = 10_000;
  const rows = [3, 2, 1].map((n) => ({
    id: organizerWhatsappThreadId("org", `person-${n}`),
    data: () => ({
      organizerId: "org", contactId: "person", eventIds: [],
      lastMessageBody: "Hello", lastMessageDirection: "inbound",
      lastMessageAt: timestamp(n * 100), lastInboundAt: timestamp(n * 100),
      serviceWindowExpiresAt: timestamp(90_000),
      expiresAt: timestamp(n > 1 ? 5_000 : 90_000),
    }),
  }));
  function query(after = Infinity, limit = Infinity): unknown {
    return {
      where: (field: string, op: string, value: string) => {
        assert.equal(field, "organizerId");
        assert.equal(op, "==");
        assert.equal(value, "org");
        return query(after, limit);
      },
      orderBy: () => query(after, limit),
      startAfter: (time: FirebaseFirestore.Timestamp) =>
        query(time.toMillis(), limit),
      limit: (cap: number) => query(after, cap),
      get: async () => ({
        docs: rows
          .filter((row) => row.data().lastMessageAt.toMillis() < after)
          .slice(0, limit),
      }),
    };
  }
  const db = {
    collection: (name: string) =>
      name === "organizerWhatsappThreads" ? query() : {
        doc: (id: string) => ({
          id,
          get: async () => ({
            exists: true,
            data: () => ({
              ownerUserId: "manager", hostUserIds: [], hostProfiles: [],
            }),
          }),
        }),
      },
    getAll: async () => [{exists: true, id: "person", data: () => ({
      organizerId: "org", displayName: "Riya", linkedUid: "riya",
      identityState: "verified", identityConfidence: "verified",
    })}],
  } as unknown as FirebaseFirestore.Firestore;
  type Handler = typeof listOrganizerWhatsappThreadsHandler;
  type Deps = NonNullable<Parameters<Handler>[1]>;
  const deps: Deps = {
    firestore: () => db,
    now: () => timestamp(now),
    checkRateLimit: async () => {},
    provider: () => {
      throw new Error("No send in this test");
    },
    tokenStore: {} as Deps["tokenStore"],
  };
  type Request = Parameters<typeof listOrganizerWhatsappThreadsHandler>[0];
  const request = (cursor: string | null, uid = "manager") => ({
    auth: {uid, token: {}}, data: {organizerId: "org", limit: 2, cursor},
  }) as Request;
  const first = await listOrganizerWhatsappThreadsHandler(request(null), deps);
  assert.deepEqual(first.threads, []);
  assert.ok(first.nextCursor);
  const second = await listOrganizerWhatsappThreadsHandler(
    request(first.nextCursor), deps
  );
  assert.equal(second.threads.length, 1);
  assert.equal(second.threads[0].linkedUid, "riya");
  assert.equal(second.nextCursor, null);
  await assert.rejects(
    listOrganizerWhatsappThreadsHandler(request(null, "outsider"), deps),
    {code: "permission-denied"}
  );
});
