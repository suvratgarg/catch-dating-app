import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";

import {
  claimProgramStaffInviteHandler,
  inviteProgramStaffHandler,
  revokeProgramStaffInviteHandler,
} from "./programStaffInvites";

const ts = (millis: number) => admin.firestore.Timestamp.fromMillis(millis);
const NOW = 1_800_000_000_000;
const EXPIRES = NOW + 7 * 24 * 3600_000;

type FakeData = Record<string, unknown>;
type Where = {field: string; op: string; value: unknown};

function timestampMillis(value: unknown): number {
  if (value && typeof value === "object") {
    const stamp = value as {toMillis?: () => number; _seconds?: number};
    if (typeof stamp.toMillis === "function") return stamp.toMillis();
    if (typeof stamp._seconds === "number") return stamp._seconds * 1000;
  }
  return typeof value === "number" ? value : 0;
}

function matchWhere(data: FakeData, where: Where): boolean {
  const value = data[where.field];
  if (where.op === "==") return value === where.value;
  if (where.op === ">") {
    return timestampMillis(value) > timestampMillis(where.value);
  }
  throw new Error(`Unsupported where op: ${where.op}`);
}

class FakeDocRef {
  constructor(readonly firestore: FakeFirestore, readonly path: string) {}
  get id() {
    return this.path.split("/").pop()!;
  }
  async get() {
    const data = this.firestore.getDoc(this.path);
    return {exists: data !== undefined, data: () => data, id: this.id};
  }
  async set(data: FakeData) {
    this.firestore.setDoc(this.path, data);
  }
}

class FakeQuery {
  constructor(readonly firestore: FakeFirestore,
    readonly collectionPath: string,
    readonly wheres: Where[] = [],
    readonly limitN: number | null = null) {}
  where(field: string, op: string, value: unknown) {
    return new FakeQuery(this.firestore, this.collectionPath,
      [...this.wheres, {field, op, value}], this.limitN);
  }
  limit(n: number) {
    return new FakeQuery(this.firestore, this.collectionPath,
      this.wheres, n);
  }
  async get() {
    const prefix = `${this.collectionPath}/`;
    const docs: Array<{id: string; data: () => FakeData}> = [];
    for (const [path, data] of this.firestore.docs) {
      if (!path.startsWith(prefix) ||
          path.slice(prefix.length).includes("/")) continue;
      if (this.wheres.every((where) => matchWhere(data, where))) {
        docs.push({id: path.slice(prefix.length), data: () => data});
      }
    }
    const limited = this.limitN === null ? docs : docs.slice(0, this.limitN);
    return {docs: limited, size: limited.length};
  }
}

class FakeCollectionRef extends FakeQuery {
  doc(id?: string) {
    return new FakeDocRef(this.firestore,
      `${this.collectionPath}/${id ?? `auto-${this.firestore.docs.size}`}`);
  }
}

class FakeTransaction {
  private readonly writes: Array<() => void> = [];
  constructor(private readonly firestore: FakeFirestore) {}
  async get(source: FakeDocRef | FakeQuery) {
    return source.get();
  }
  set(ref: FakeDocRef, data: FakeData) {
    this.writes.push(() => this.firestore.setDoc(ref.path, data));
  }
  commit() {
    for (const write of this.writes) write();
  }
}

class FakeFirestore {
  readonly docs = new Map<string, FakeData>();
  constructor(seed: Record<string, FakeData>) {
    for (const [k, v] of Object.entries(seed)) this.docs.set(k, v);
  }
  collection(path: string) {
    return new FakeCollectionRef(this, path);
  }
  getDoc(path: string) {
    return this.docs.get(path);
  }
  setDoc(path: string, data: FakeData) {
    this.docs.set(path, {...data});
  }
  async runTransaction<T>(callback: (tx: FakeTransaction) => Promise<T>) {
    const tx = new FakeTransaction(this);
    const result = await callback(tx);
    tx.commit();
    return result;
  }
}

function seed(): Record<string, FakeData> {
  return {
    "organizerPrograms/program-1": {
      organizerId: "org-1", timezone: "Asia/Kolkata",
    },
    "organizers/org-1": {
      hostUserId: "manager-1",
      ownerUserId: "manager-1",
      hostUserIds: ["manager-1"],
      hostProfiles: [],
    },
    "programPickupPoints/pickup-1": {
      programId: "program-1", organizerId: "org-1",
      label: "DEL T3 Arrivals", kind: "airport", active: true,
    },
  };
}

function request(data: unknown, uid = "manager-1", phone?: string) {
  return {
    data,
    auth: {uid, token: phone ? {phone_number: phone} : {}},
  } as CallableRequest<unknown>;
}

function deps(store: FakeFirestore, now = NOW) {
  return {
    firestore: () => store as unknown as FirebaseFirestore.Firestore,
    checkRateLimit: async () => undefined,
    now: () => ts(now),
  } as never;
}

const invitePayload = {
  programId: "program-1",
  phoneNumber: "+91 99000 01111",
  displayName: "Priya Greeter",
  duties: [{duty: "airportGreeter", pickupPointIds: ["pickup-1"],
    hotelIds: []}],
  expiresAtMillis: EXPIRES,
};

test("invite writes a pending invite bound to the normalized phone",
  async () => {
    const store = new FakeFirestore(seed());
    const result = await inviteProgramStaffHandler(
      request(invitePayload), deps(store));
    assert.equal(result.alreadyApplied, false);
    const invite = store.docs.get(`programStaffInvites/${result.entityId}`);
    assert.ok(invite);
    assert.equal(invite.phoneE164, "+919900001111");
    assert.equal(invite.status, "pending");
    assert.equal(invite.programId, "program-1");
  });

test("a second invite for the same phone returns the pending invite",
  async () => {
    const store = new FakeFirestore(seed());
    const first = await inviteProgramStaffHandler(
      request(invitePayload), deps(store));
    const second = await inviteProgramStaffHandler(
      request({...invitePayload, displayName: "Renamed"}), deps(store));
    assert.equal(second.entityId, first.entityId);
    assert.equal(second.alreadyApplied, true);
  });

test("claim binds the grant to the verified phone and consumes the invite",
  async () => {
    const store = new FakeFirestore(seed());
    const invite = await inviteProgramStaffHandler(
      request(invitePayload), deps(store));
    const result = await claimProgramStaffInviteHandler(
      request({inviteId: invite.entityId}, "greeter-1", "+919900001111"),
      deps(store));
    assert.equal(result.programId, "program-1");
    assert.equal(result.alreadyApplied, false);
    const grant = store.docs.get("programStaffGrants/program-1__greeter-1");
    assert.ok(grant);
    assert.equal(grant.status, "active");
    assert.equal(grant.displayName, "Priya Greeter");
    assert.equal(grant.phoneLastFour, "1111");
    const claimed =
      store.docs.get(`programStaffInvites/${invite.entityId}`);
    assert.equal(claimed?.status, "claimed");
    assert.equal(claimed?.claimedByUid, "greeter-1");
  });

test("claim from a different phone is denied", async () => {
  const store = new FakeFirestore(seed());
  const invite = await inviteProgramStaffHandler(
    request(invitePayload), deps(store));
  await assert.rejects(
    claimProgramStaffInviteHandler(
      request({inviteId: invite.entityId}, "greeter-2", "+14155550100"),
      deps(store)),
    (error: unknown) => {
      assert.ok(error instanceof HttpsError);
      assert.equal(error.code, "permission-denied");
      return true;
    });
  assert.equal(store.docs.has("programStaffGrants/program-1__greeter-2"),
    false);
});

test("claim without a verified phone fails closed", async () => {
  const store = new FakeFirestore(seed());
  const invite = await inviteProgramStaffHandler(
    request(invitePayload), deps(store));
  await assert.rejects(
    claimProgramStaffInviteHandler(
      request({inviteId: invite.entityId}, "greeter-3"), deps(store)),
    (error: unknown) => {
      assert.ok(error instanceof HttpsError);
      assert.equal(error.code, "failed-precondition");
      return true;
    });
});

test("re-claim by the same account replays; another account fails",
  async () => {
    const store = new FakeFirestore(seed());
    const invite = await inviteProgramStaffHandler(
      request(invitePayload), deps(store));
    await claimProgramStaffInviteHandler(
      request({inviteId: invite.entityId}, "greeter-1", "+919900001111"),
      deps(store));
    const replay = await claimProgramStaffInviteHandler(
      request({inviteId: invite.entityId}, "greeter-1", "+919900001111"),
      deps(store));
    assert.equal(replay.alreadyApplied, true);
    await assert.rejects(
      claimProgramStaffInviteHandler(
        request({inviteId: invite.entityId}, "greeter-2", "+919900001111"),
        deps(store)),
      (error: unknown) => {
        assert.ok(error instanceof HttpsError);
        assert.equal(error.code, "failed-precondition");
        return true;
      });
  });

test("expired invites cannot be claimed", async () => {
  const store = new FakeFirestore(seed());
  const invite = await inviteProgramStaffHandler(
    request(invitePayload), deps(store));
  await assert.rejects(
    claimProgramStaffInviteHandler(
      request({inviteId: invite.entityId}, "greeter-1", "+919900001111"),
      deps(store, EXPIRES + 1)),
    (error: unknown) => {
      assert.ok(error instanceof HttpsError);
      assert.equal(error.code, "failed-precondition");
      return true;
    });
});

test("revoked invites cannot be claimed", async () => {
  const store = new FakeFirestore(seed());
  const invite = await inviteProgramStaffHandler(
    request(invitePayload), deps(store));
  const revoked = await revokeProgramStaffInviteHandler(
    request({programId: "program-1", inviteId: invite.entityId}),
    deps(store));
  assert.equal(revoked.alreadyApplied, false);
  await assert.rejects(
    claimProgramStaffInviteHandler(
      request({inviteId: invite.entityId}, "greeter-1", "+919900001111"),
      deps(store)),
    (error: unknown) => {
      assert.ok(error instanceof HttpsError);
      assert.equal(error.code, "failed-precondition");
      return true;
    });
});

test("non-managers cannot invite or revoke", async () => {
  const store = new FakeFirestore(seed());
  const invite = await inviteProgramStaffHandler(
    request(invitePayload), deps(store));
  await assert.rejects(
    inviteProgramStaffHandler(
      request(invitePayload, "greeter-9"), deps(store)),
    (error: unknown) => {
      assert.ok(error instanceof HttpsError);
      assert.equal(error.code, "permission-denied");
      return true;
    });
  await assert.rejects(
    revokeProgramStaffInviteHandler(
      request({programId: "program-1", inviteId: invite.entityId},
        "greeter-9"), deps(store)),
    (error: unknown) => {
      assert.ok(error instanceof HttpsError);
      assert.equal(error.code, "permission-denied");
      return true;
    });
});
