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

import {FakeFirestore, timestampMillis, type FakeData} from
  "../shared/testing/programFirestore";

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

for (const status of ["revoked", "expired"] as const) {
  test(`claim does not restore ${status} duties or their expiry`, async () => {
    const store = new FakeFirestore(seed());
    store.setDoc("programStaffGrants/program-1__greeter-1", {
      programId: "program-1", organizerId: "org-1", uid: "greeter-1",
      status: status === "revoked" ? "revoked" : "active",
      duties: [{duty: "programCoordinator", pickupPointIds: [], hotelIds: []}],
      expiresAt: ts(status === "revoked" ? EXPIRES + 3600_000 : NOW - 1),
      revision: 8,
    });
    const invite = await inviteProgramStaffHandler(
      request(invitePayload), deps(store));
    await claimProgramStaffInviteHandler(
      request({inviteId: invite.entityId}, "greeter-1", "+919900001111"),
      deps(store));
    const grant = store.getDoc("programStaffGrants/program-1__greeter-1")!;
    assert.deepEqual(grant.duties, invitePayload.duties);
    assert.equal(timestampMillis(grant.expiresAt), EXPIRES);
    assert.equal(grant.status, "active");
    assert.ok((grant.revision as number) > 8);
  });
}

test("claim preserves only still-active existing authority", async () => {
  const store = new FakeFirestore(seed());
  store.setDoc("programStaffGrants/program-1__greeter-1", {
    programId: "program-1", organizerId: "org-1", uid: "greeter-1",
    status: "active", expiresAt: ts(EXPIRES + 3600_000), revision: 8,
    duties: [{duty: "airportGreeter", pickupPointIds: [], hotelIds: []}],
  });
  const invite = await inviteProgramStaffHandler(
    request(invitePayload), deps(store));
  await claimProgramStaffInviteHandler(
    request({inviteId: invite.entityId}, "greeter-1", "+919900001111"),
    deps(store));
  const grant = store.getDoc("programStaffGrants/program-1__greeter-1")!;
  assert.deepEqual(grant.duties, [
    {duty: "airportGreeter", pickupPointIds: [], hotelIds: []},
  ]);
  assert.equal(timestampMillis(grant.expiresAt), EXPIRES + 3600_000);
});

test("claim fails when the program no longer belongs to the invite owner",
  async () => {
    const store = new FakeFirestore(seed());
    const invite = await inviteProgramStaffHandler(
      request(invitePayload), deps(store));
    store.setDoc("organizerPrograms/program-1", {organizerId: "org-2"});
    store.setDoc("organizers/org-2", {ownerUserId: "another-manager"});
    await assert.rejects(claimProgramStaffInviteHandler(
      request({inviteId: invite.entityId}, "greeter-1", "+919900001111"),
      deps(store)), (error: unknown) =>
      error instanceof HttpsError && error.code === "failed-precondition");
    assert.equal(store.getDoc(`programStaffInvites/${invite.entityId}`)?.status,
      "pending");
    assert.equal(store.getDoc("programStaffGrants/program-1__greeter-1"),
      undefined);
  });
