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
      createdBy: "manager-1",
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
      createdBy: "manager-1",
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
    createdBy: "manager-1",
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
    createdBy: "manager-1",
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
      createdBy: "manager-1",
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
    createdBy: "manager-1",
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

test("deleted creator during issuance prevents the invite commit",
  async () => {
    const store = new FakeFirestore(seed());
    store.beforeCommit = async () => {
      store.beforeCommit = undefined;
      store.setDoc("deletedUsers/manager-1", {deletedAt: ts(NOW)});
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

for (const organizerId of ["org-1", "foreign"]) {
  test(`invite quota counts current owner only: ${organizerId}`, async () => {
    const store = new FakeFirestore(seed());
    for (let i = 0; i < 100; i++) {
      const uid = `quota-${i}`;
      store.setDoc(`programStaffGrants/program-1__${uid}`, {
        programId: "program-1", organizerId, uid,
        status: "active", expiresAt: ts(EXPIRES),
      });
    }
    const invite = await inviteProgramStaffHandler(
      request(invitePayload), deps(store));
    const claim = claimProgramStaffInviteHandler(
      request({inviteId: invite.entityId}, "greeter-1", "+919900001111"),
      deps(store));
    if (organizerId === "org-1") {
      await assert.rejects(claim, code("resource-exhausted"));
      assert.equal(store.getDoc(`programStaffInvites/${invite.entityId}`)
        ?.status, "pending");
    } else {
      assert.equal((await claim).programId, "program-1");
      assert.equal(store.getDoc("programStaffGrants/program-1__greeter-1")
        ?.status, "active");
    }
  });
}

function withAdmin(store: FakeFirestore, deadline = EXPIRES) {
  store.setDoc("programStaffGrants/program-1__admin-1", {
    programId: "program-1", organizerId: "org-1", uid: "admin-1",
    createdBy: "manager-1", status: "active", revision: 1,
    expiresAt: ts(deadline),
    duties: [{duty: "programAdmin", pickupPointIds: [], hotelIds: [],
      expiresAtMillis: deadline}],
    programAuthorization: {ownerUid: "manager-1", approvedByUid: "manager-1",
      approvedAtMillis: NOW - 1, authorizedUntilMillis: deadline},
  });
  return store;
}

test("creator issues and claims invitations after losing organizer roles",
  async () => {
    const store = new FakeFirestore(seed());
    store.setDoc("organizers/org-1", {ownerUserId: "other"});
    const invite = await inviteProgramStaffHandler(
      request(invitePayload), deps(store));
    await claimProgramStaffInviteHandler(request({inviteId: invite.entityId},
      "greeter-1", "+919900001111"), deps(store));
    assert.equal(store.getDoc("programStaffGrants/program-1__greeter-1")
      ?.status, "active");
  });

test("organizer-only manager and coordinator cannot issue admin invitations",
  async () => {
    const store = withAdmin(new FakeFirestore(seed()));
    store.setDoc("organizers/org-1", {ownerUserId: "organizer-only"});
    store.setDoc("programStaffGrants/program-1__coordinator-1", {
      ...store.getDoc("programStaffGrants/program-1__admin-1"),
      uid: "coordinator-1", duties: [{duty: "programCoordinator",
        pickupPointIds: [], hotelIds: [], expiresAtMillis: EXPIRES}],
    });
    for (const uid of ["organizer-only", "coordinator-1"]) {
      await assert.rejects(inviteProgramStaffHandler(request({...invitePayload,
        duties: [{duty: "programAdmin", pickupPointIds: [], hotelIds: []}]},
      uid), deps(store)), code("permission-denied"));
    }
    assert.equal(pending(store).length, 0);
  });

for (const patch of [
  {status: "revoked"}, {expiresAt: ts(NOW)},
  {duties: [{duty: "programCoordinator", pickupPointIds: [], hotelIds: [],
    expiresAtMillis: EXPIRES}]},
]) {
  test("pending claim rejects changed issuer admin access", async () => {
    const store = withAdmin(new FakeFirestore(seed()));
    const invite = await inviteProgramStaffHandler(
      request(invitePayload, "admin-1"), deps(store));
    store.updateDoc("programStaffGrants/program-1__admin-1", patch);
    await assert.rejects(claimProgramStaffInviteHandler(
      request({inviteId: invite.entityId}, "greeter-1", "+919900001111"),
      deps(store)), code("permission-denied"));
    assert.equal(pending(store).length, 1);
    assert.equal(store.getDoc("programStaffGrants/program-1__greeter-1"),
      undefined);
  });
}

test("admin cannot create or claim beyond its current inherited deadline",
  async () => {
    const store = withAdmin(new FakeFirestore(seed()));
    await assert.rejects(inviteProgramStaffHandler(request({...invitePayload,
      expiresAtMillis: EXPIRES + 1}, "admin-1"), deps(store)),
    code("permission-denied"));
    const invite = await inviteProgramStaffHandler(
      request(invitePayload, "admin-1"), deps(store));
    store.updateDoc("programStaffGrants/program-1__admin-1", {duties: [{
      duty: "programAdmin", pickupPointIds: [], hotelIds: [],
      expiresAtMillis: EXPIRES - 1,
    }]});
    await assert.rejects(claimProgramStaffInviteHandler(
      request({inviteId: invite.entityId}, "greeter-1", "+919900001111"),
      deps(store)), code("permission-denied"));
  });

test("creator explicitly reapproves a legacy pending invite, preserving audit",
  async () => {
    const store = withAdmin(new FakeFirestore(seed()));
    const original = await inviteProgramStaffHandler(
      request(invitePayload), deps(store));
    const path = `programStaffInvites/${original.entityId}`;
    const legacy: FakeData = {...store.getDoc(path),
      createdBy: "organizer-only"};
    delete legacy.programAuthorization;
    store.setDoc(path, legacy);
    await assert.rejects(inviteProgramStaffHandler(
      request(invitePayload, "admin-1"), deps(store)),
    code("permission-denied"));
    await assert.rejects(claimProgramStaffInviteHandler(
      request({inviteId: original.entityId}, "greeter-1", "+919900001111"),
      deps(store)), code("permission-denied"));
    const approved = await inviteProgramStaffHandler(
      request(invitePayload), deps(store));
    assert.equal(approved.entityId, original.entityId);
    assert.equal(approved.alreadyApplied, false);
    assert.equal(store.getDoc(path)?.createdBy, "organizer-only");
    await claimProgramStaffInviteHandler(
      request({inviteId: original.entityId}, "greeter-1", "+919900001111"),
      deps(store));
  });

test("owner-approved invitation never adopts unauthorized legacy duties",
  async () => {
    const store = new FakeFirestore(seed());
    store.setDoc("programStaffGrants/program-1__greeter-1", {
      uid: "greeter-1", programId: "program-1", organizerId: "org-1",
      createdBy: "organizer-only", status: "active", revision: 1,
      expiresAt: ts(EXPIRES + 1000), duties: [{duty: "programCoordinator",
        pickupPointIds: [], hotelIds: [], expiresAtMillis: EXPIRES + 1000}],
    });
    const invite = await inviteProgramStaffHandler(
      request(invitePayload), deps(store));
    await claimProgramStaffInviteHandler(
      request({inviteId: invite.entityId}, "greeter-1", "+919900001111"),
      deps(store));
    const grant = store.getDoc("programStaffGrants/program-1__greeter-1")!;
    assert.equal(grant.createdBy, "organizer-only");
    assert.deepEqual(grant.duties, invitePayload.duties.map((duty) =>
      ({...duty, expiresAtMillis: EXPIRES})));
  });

for (const patch of [{status: "revoked"}, {expiresAt: ts(NOW)}]) {
  test("claimed replay does not promise revoked or expired recipient access",
    async () => {
      const store = new FakeFirestore(seed());
      const invite = await inviteProgramStaffHandler(
        request(invitePayload), deps(store));
      const claim = () => claimProgramStaffInviteHandler(
        request({inviteId: invite.entityId}, "greeter-1", "+919900001111"),
        deps(store));
      await claim();
      store.updateDoc("programStaffGrants/program-1__greeter-1", patch);
      await assert.rejects(claim(), code("permission-denied"));
    });
}

test("deleted recipient cannot consume a pending invitation", async () => {
  const store = new FakeFirestore(seed());
  const invite = await inviteProgramStaffHandler(
    request(invitePayload), deps(store));
  store.setDoc("deletedUsers/greeter-1", {deletedAt: ts(NOW)});
  await assert.rejects(claimProgramStaffInviteHandler(
    request({inviteId: invite.entityId}, "greeter-1", "+919900001111"),
    deps(store)), code("permission-denied"));
  assert.equal(pending(store).length, 1);
});

for (const deadline of [NOW, EXPIRES - 1]) {
  test("redemption deadline cannot exceed the invite's owner approval",
    async () => {
      const store = withAdmin(new FakeFirestore(seed()));
      const invite = await inviteProgramStaffHandler(
        request(invitePayload, "admin-1"), deps(store));
      store.updateDoc(`programStaffInvites/${invite.entityId}`, {
        programAuthorization: {ownerUid: "manager-1", approvedByUid: "admin-1",
          approvedAtMillis: NOW - 1, authorizedUntilMillis: deadline},
      });
      await assert.rejects(claimProgramStaffInviteHandler(
        request({inviteId: invite.entityId}, "greeter-1", "+919900001111"),
        deps(store)), code("permission-denied"));
      assert.equal(pending(store).length, 1);
    });
}

test("merging long operations with short admin never extends delegation",
  async () => {
    const short = NOW + 60_000;
    const long = EXPIRES + 3600_000;
    const store = withAdmin(new FakeFirestore(seed()), short);
    store.setDoc("programStaffGrants/program-1__greeter-1", {
      programId: "program-1", organizerId: "org-1", uid: "greeter-1",
      createdBy: "manager-1", status: "active", revision: 1,
      expiresAt: ts(long), duties: [{duty: "hotelDesk", pickupPointIds: [],
        hotelIds: [], expiresAtMillis: long}],
    });
    const adminDuties = [{duty: "programAdmin", pickupPointIds: [],
      hotelIds: []}];
    const invite = await inviteProgramStaffHandler(request({...invitePayload,
      duties: adminDuties, expiresAtMillis: short}, "admin-1"), deps(store));
    await claimProgramStaffInviteHandler(request({inviteId: invite.entityId},
      "greeter-1", "+919900001111"), deps(store));
    const merged = store.getDoc("programStaffGrants/program-1__greeter-1")!;
    assert.equal(timestampMillis(merged.expiresAt), long);
    assert.equal((merged.programAuthorization as
      {authorizedUntilMillis: number}).authorizedUntilMillis, long);
    assert.deepEqual(merged.duties, [
      {duty: "hotelDesk", pickupPointIds: [], hotelIds: [],
        expiresAtMillis: long},
      {duty: "programAdmin", pickupPointIds: [], hotelIds: [],
        expiresAtMillis: short},
    ]);
    const child = {...invitePayload, phoneNumber: "+919900002222",
      duties: adminDuties, expiresAtMillis: short};
    await assert.rejects(inviteProgramStaffHandler(request({...child,
      expiresAtMillis: short + 1}, "greeter-1"), deps(store)),
    code("permission-denied"));
    const peer = await inviteProgramStaffHandler(
      request(child, "greeter-1"), deps(store));
    await claimProgramStaffInviteHandler(request({inviteId: peer.entityId},
      "peer-1", "+919900002222"), deps(store));
    await assert.rejects(inviteProgramStaffHandler(request({...invitePayload,
      duties: adminDuties, expiresAtMillis: short + 1}, "peer-1"), deps(store)),
    code("permission-denied"));
  });

for (const marker of [{revokedAt: ts(NOW)}, {revokedBy: "manager-1"}]) {
  test("pending status cannot revive an invite revocation marker", async () => {
    const store = new FakeFirestore(seed());
    const invite = await inviteProgramStaffHandler(
      request(invitePayload), deps(store));
    store.updateDoc(`programStaffInvites/${invite.entityId}`, marker);
    await assert.rejects(inviteProgramStaffHandler(
      request(invitePayload), deps(store)), {code: "failed-precondition"});
    await assert.rejects(claimProgramStaffInviteHandler(
      request({inviteId: invite.entityId}, "greeter-1", "+919900001111"),
      deps(store)), {code: "failed-precondition"});
    assert.equal(store.docs.has("programStaffGrants/program-1__greeter-1"),
      false);
  });
}

test("invite claim discards previously revoked duties", async () => {
  const store = new FakeFirestore(seed());
  store.setDoc("programStaffGrants/program-1__greeter-1", {
    programId: "program-1", organizerId: "org-1", uid: "greeter-1",
    status: "active", createdBy: "manager-1", expiresAt: ts(EXPIRES),
    revokedBy: "manager-1", revokedAt: ts(NOW - 1),
    duties: [{duty: "programAdmin", pickupPointIds: [], hotelIds: [],
      expiresAtMillis: EXPIRES}], revision: 1,
  });
  const invite = await inviteProgramStaffHandler(
    request(invitePayload), deps(store));
  await claimProgramStaffInviteHandler(
    request({inviteId: invite.entityId}, "greeter-1", "+919900001111"),
    deps(store));
  const grant = store.docs.get("programStaffGrants/program-1__greeter-1")!;
  assert.deepEqual((grant.duties as Array<{duty: string}>).map((d) => d.duty),
    ["airportGreeter"]);
});
