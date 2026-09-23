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
      request({...invitePayload, displayName: " Priya Greeter "}), deps(store));
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
    assert.deepEqual(grant.duties, invitePayload.duties.map((duty) =>
      ({...duty, expiresAtMillis: EXPIRES})));
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
    duties: [{duty: "airportGreeter", pickupPointIds: [], hotelIds: [],
      expiresAtMillis: EXPIRES + 3600_000}],
  });
  const invite = await inviteProgramStaffHandler(
    request(invitePayload), deps(store));
  await claimProgramStaffInviteHandler(
    request({inviteId: invite.entityId}, "greeter-1", "+919900001111"),
    deps(store));
  const grant = store.getDoc("programStaffGrants/program-1__greeter-1")!;
  assert.deepEqual(grant.duties, [
    {duty: "airportGreeter", pickupPointIds: [], hotelIds: [],
      expiresAtMillis: EXPIRES + 3600_000},
    {...invitePayload.duties[0], expiresAtMillis: EXPIRES},
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

test("later hotel invite preserves the airport deadline", async () => {
  const store = new FakeFirestore(seed());
  const early = NOW + 60_000;
  store.setDoc("programStaffGrants/program-1__greeter-1", {
    programId: "program-1", organizerId: "org-1", uid: "greeter-1",
    status: "active", expiresAt: ts(early), revision: 8,
    duties: [{duty: "airportGreeter", pickupPointIds: ["pickup-1"],
      hotelIds: [], expiresAtMillis: early}],
  });
  const invite = await inviteProgramStaffHandler(request({...invitePayload,
    duties: [{duty: "hotelDesk", pickupPointIds: [], hotelIds: []}]}),
  deps(store));
  await claimProgramStaffInviteHandler(
    request({inviteId: invite.entityId}, "greeter-1", "+919900001111"),
    deps(store));
  const grant = store.getDoc("programStaffGrants/program-1__greeter-1")!;
  assert.deepEqual(grant.duties, [
    {duty: "airportGreeter", pickupPointIds: ["pickup-1"],
      hotelIds: [], expiresAtMillis: early},
    {duty: "hotelDesk", pickupPointIds: [], hotelIds: [],
      expiresAtMillis: EXPIRES},
  ]);
  assert.equal(timestampMillis(grant.expiresAt), EXPIRES);
});

test("claim cannot recover legacy duty deadlines from the grant maximum",
  async () => {
    const store = new FakeFirestore(seed());
    store.setDoc("programStaffGrants/program-1__greeter-1", {
      programId: "program-1", organizerId: "org-1", uid: "greeter-1",
      status: "active", expiresAt: ts(EXPIRES + 3600_000), revision: 8,
      duties: [{duty: "programCoordinator", pickupPointIds: [], hotelIds: []}],
    });
    const invite = await inviteProgramStaffHandler(
      request(invitePayload), deps(store));
    await claimProgramStaffInviteHandler(
      request({inviteId: invite.entityId}, "greeter-1", "+919900001111"),
      deps(store));
    const grant = store.getDoc("programStaffGrants/program-1__greeter-1")!;
    assert.deepEqual(grant.duties, invitePayload.duties.map((duty) =>
      ({...duty, expiresAtMillis: EXPIRES})));
    assert.equal(timestampMillis(grant.expiresAt), EXPIRES);
  });

test("an invite exceeding eight scope tuples remains unclaimed", async () => {
  const store = new FakeFirestore(seed());
  const existing = Array.from({length: 8}, (_, i) => ({duty: "hotelDesk",
    pickupPointIds: [], hotelIds: [`h${i}`], expiresAtMillis: EXPIRES}));
  store.setDoc("programStaffGrants/program-1__greeter-1", {
    programId: "program-1", organizerId: "org-1", uid: "greeter-1",
    status: "active", expiresAt: ts(EXPIRES), revision: 8, duties: existing,
  });
  const invite = await inviteProgramStaffHandler(
    request(invitePayload), deps(store));
  await assert.rejects(claimProgramStaffInviteHandler(
    request({inviteId: invite.entityId}, "greeter-1", "+919900001111"),
    deps(store)), (error: unknown) =>
    error instanceof HttpsError && error.code === "resource-exhausted");
  assert.equal(store.getDoc(`programStaffInvites/${invite.entityId}`)?.status,
    "pending");
  assert.deepEqual(store.getDoc("programStaffGrants/program-1__greeter-1")!
    .duties, existing);
});

const code = (expected: string) => (error: unknown) =>
  (error as {code?: string}).code === expected;
const pending = (store: FakeFirestore) => [...store.docs.entries()]
  .filter(([path, doc]) => path.startsWith("programStaffInvites/") &&
    doc.status === "pending");

for (const patch of [
  {displayName: "Changed Name"},
  {expiresAtMillis: EXPIRES + 1},
  {duties: [{duty: "airportGreeter", pickupPointIds: [], hotelIds: []}]},
]) {
  test("changed request cannot replay a different pending invite", async () => {
    const store = new FakeFirestore(seed());
    const first = await inviteProgramStaffHandler(
      request(invitePayload), deps(store));
    const before = store.getDoc(`programStaffInvites/${first.entityId}`);
    await assert.rejects(inviteProgramStaffHandler(
      request({...invitePayload, ...patch}), deps(store)),
    code("failed-precondition"));
    assert.deepEqual(store.getDoc(`programStaffInvites/${first.entityId}`),
      before);
    assert.equal(pending(store).length, 1);
  });
}

test("simultaneous equivalent invite requests create one pending link",
  async () => {
    const store = new FakeFirestore(seed());
    const results = await Promise.all(Array.from({length: 4}, () =>
      inviteProgramStaffHandler(request(invitePayload), deps(store))));
    assert.equal(new Set(results.map((r) => r.entityId)).size, 1);
    assert.equal(results.filter((r) => !r.alreadyApplied).length, 1);
    assert.equal(pending(store).length, 1);
  });

test("expired invites cannot hide a live pending invite beyond an old cap",
  async () => {
    const store = new FakeFirestore(seed());
    const first = await inviteProgramStaffHandler(
      request(invitePayload), deps(store, NOW - 1000));
    const original = store.getDoc(`programStaffInvites/${first.entityId}`)!;
    store.docs.delete(`programStaffInvites/${first.entityId}`);
    for (let i = 0; i < 6; i++) {
      store.setDoc(`programStaffInvites/expired-${i}`,
        {...original, expiresAt: ts(NOW)});
    }
    store.setDoc(`programStaffInvites/${first.entityId}`, original);
    const replay = await inviteProgramStaffHandler(
      request(invitePayload), deps(store));
    assert.equal(replay.entityId, first.entityId);
    assert.equal(replay.alreadyApplied, true);
  });

test("conflicting legacy pending links require explicit reconciliation",
  async () => {
    const store = new FakeFirestore(seed());
    const first = await inviteProgramStaffHandler(
      request(invitePayload), deps(store));
    store.setDoc("programStaffInvites/duplicate",
      store.getDoc(`programStaffInvites/${first.entityId}`)!);
    await assert.rejects(inviteProgramStaffHandler(
      request(invitePayload), deps(store)), code("failed-precondition"));
    assert.equal(pending(store).length, 2);
  });

test("manager revocation during issuance prevents the invite commit",
  async () => {
    const store = new FakeFirestore(seed());
    store.beforeCommit = async () => {
      store.beforeCommit = undefined;
      store.setDoc("organizers/org-1", {ownerUserId: "someone-else",
        hostUserId: "someone-else", hostUserIds: [], hostProfiles: []});
    };
    await assert.rejects(inviteProgramStaffHandler(
      request(invitePayload), deps(store)), code("permission-denied"));
    assert.equal(pending(store).length, 0);
  });

for (const patch of [{active: false}, {organizerId: "foreign"},
  {programId: "foreign"}]) {
  for (const phase of ["issue", "claim"] as const) {
    test(`${phase} retries observe resource changes: ${JSON.stringify(patch)}`,
      async () => {
        const store = new FakeFirestore(seed());
        const invite = phase === "claim" ? await inviteProgramStaffHandler(
          request(invitePayload), deps(store)) : null;
        store.beforeCommit = async () => {
          store.beforeCommit = undefined;
          store.updateDoc("programPickupPoints/pickup-1", patch);
        };
        const call = invite ? claimProgramStaffInviteHandler(
          request({inviteId: invite.entityId}, "greeter-1", "+919900001111"),
          deps(store)) : inviteProgramStaffHandler(
          request(invitePayload), deps(store));
        await assert.rejects(call, code("invalid-argument"));
        assert.equal(store.getDoc("programStaffGrants/program-1__greeter-1"),
          undefined);
        assert.equal(pending(store).length, invite ? 1 : 0);
      });
  }
}

test("invite claim cannot overwrite a mismatched grant owner", async () => {
  const store = new FakeFirestore(seed());
  const invite = await inviteProgramStaffHandler(
    request(invitePayload), deps(store));
  const other = {programId: "program-1", organizerId: "foreign",
    uid: "greeter-1", status: "active", expiresAt: ts(EXPIRES), duties: []};
  store.setDoc("programStaffGrants/program-1__greeter-1", other);
  await assert.rejects(claimProgramStaffInviteHandler(
    request({inviteId: invite.entityId}, "greeter-1", "+919900001111"),
    deps(store)), code("failed-precondition"));
  assert.deepEqual(store.getDoc("programStaffGrants/program-1__greeter-1"),
    other);
  assert.equal(pending(store).length, 1);
});

test("equivalent scope ordering replays the same invite", async () => {
  const store = new FakeFirestore(seed());
  store.setDoc("programPickupPoints/pickup-2",
    store.getDoc("programPickupPoints/pickup-1")!);
  const greeter = {duty: "airportGreeter", hotelIds: [],
    pickupPointIds: ["pickup-1", "pickup-2"]};
  const hotel = {duty: "hotelDesk", pickupPointIds: [], hotelIds: []};
  const first = await inviteProgramStaffHandler(request({...invitePayload,
    duties: [greeter, hotel]}), deps(store));
  const replay = await inviteProgramStaffHandler(request({...invitePayload,
    duties: [hotel, {...greeter, pickupPointIds: ["pickup-2", "pickup-1"]}]}),
  deps(store));
  assert.equal(replay.entityId, first.entityId);
  assert.equal(replay.alreadyApplied, true);
});

test("invite replay and revoke cannot touch a foreign organizer binding",
  async () => {
    const store = new FakeFirestore(seed());
    const first = await inviteProgramStaffHandler(
      request(invitePayload), deps(store));
    const path = `programStaffInvites/${first.entityId}`;
    store.updateDoc(path, {organizerId: "foreign"});
    const before = store.getDoc(path);
    await assert.rejects(inviteProgramStaffHandler(
      request(invitePayload), deps(store)), code("failed-precondition"));
    await assert.rejects(revokeProgramStaffInviteHandler(request({
      programId: "program-1", inviteId: first.entityId,
    }), deps(store)), code("not-found"));
    assert.deepEqual(store.getDoc(path), before);
  });

for (const patch of [{active: false}, {organizerId: "foreign"}]) {
  test(`hotel claim revalidates destination: ${JSON.stringify(patch)}`,
    async () => {
      const store = new FakeFirestore(seed());
      store.setDoc("programHotels/hotel-1", {organizerId: "org-1",
        programId: "program-1", active: true});
      const invite = await inviteProgramStaffHandler(request({...invitePayload,
        duties: [{duty: "hotelDesk", pickupPointIds: [],
          hotelIds: ["hotel-1"]}],
      }), deps(store));
      store.beforeCommit = async () => {
        store.beforeCommit = undefined;
        store.updateDoc("programHotels/hotel-1", patch);
      };
      await assert.rejects(claimProgramStaffInviteHandler(
        request({inviteId: invite.entityId}, "greeter-1", "+919900001111"),
        deps(store)), code("invalid-argument"));
      const saved = store.getDoc(`programStaffInvites/${invite.entityId}`);
      assert.equal(saved?.status,
        "pending");
    });
}
