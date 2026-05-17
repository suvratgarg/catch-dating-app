import assert from "node:assert/strict";
import test from "node:test";
import {
  buildCheckInEventPlan,
  buildDemoChecklist,
  buildLaunchCleanupPlan,
  buildMarkAttendedPlan,
  buildMatchPhonePlan,
  buildResetUserDemoStatePlan,
  buildStaleEventCleanupPlan,
  buildValidateDemoStateReport,
  buildWarmUserPlan,
  isDemoOwned,
  matchIdFor,
  normalizePhone,
} from "./demo_ops_core.mjs";

const fakeAdmin = {
  firestore: {
    Timestamp: {
      fromDate: (date) => ({
        ...fakeTimestamp(date.toISOString()),
        iso: date.toISOString(),
      }),
    },
  },
};

test("normalizePhone requires E.164 input", () => {
  assert.equal(normalizePhone("+919876543210"), "+919876543210");
  assert.equal(normalizePhone("+91 98765 43210"), "+919876543210");
  assert.throws(() => normalizePhone("9876543210"), /Invalid E.164/);
});

test("matchIdFor is deterministic and rejects self matches", () => {
  assert.equal(matchIdFor("b", "a"), "a_b");
  assert.equal(matchIdFor("a", "b"), "a_b");
  assert.throws(() => matchIdFor("a", "a"), /distinct/);
});

test("buildMatchPhonePlan creates a deterministic direct demo match", async () => {
  const db = fakeFirestore({
    users: {
      uid_a: {phoneNumber: "+910000000001", displayName: "Asha"},
      uid_b: {phoneNumber: "+910000000002", displayName: "Ben"},
    },
    publicProfiles: {
      uid_a: {name: "Asha"},
      uid_b: {name: "Ben"},
    },
    eventParticipations: {
      run_1_uid_a: {uid: "uid_a", eventId: "run_1", status: "attended"},
      run_1_uid_b: {uid: "uid_b", eventId: "run_1", status: "attended"},
    },
  });

  const plan = await buildMatchPhonePlan({
    db,
    admin: fakeAdmin,
    phoneA: "+910000000001",
    phoneB: "+910000000002",
    now: new Date("2026-05-08T12:00:00.000Z"),
  });

  assert.equal(plan.matchId, "uid_a_uid_b");
  assert.equal(plan.eventId, "run_1");
  const matchDoc = plan.docs.find((doc) => doc.path === "matches/uid_a_uid_b");
  assert.equal(matchDoc.data.status, "active");
  assert.equal(matchDoc.data.demoOpsEntityType, "matchThread");
  assert.equal(matchDoc.data.demoOpsDisposalPolicy, "deleteThreadWithMessages");
  assert.equal(plan.docs.filter((doc) => doc.path.includes("/messages/")).length, 0);
  assert.equal(plan.docs.filter((doc) => doc.path.startsWith("notifications/")).length, 2);
});

test("buildMatchPhonePlan creates starter messages only when requested", async () => {
  const db = fakeFirestore({
    users: {
      uid_a: {phoneNumber: "+910000000001", displayName: "Asha"},
      uid_b: {phoneNumber: "+910000000002", displayName: "Ben"},
    },
    publicProfiles: {
      uid_a: {name: "Asha"},
      uid_b: {name: "Ben"},
    },
    eventParticipations: {
      run_1_uid_a: {uid: "uid_a", eventId: "run_1", status: "attended"},
      run_1_uid_b: {uid: "uid_b", eventId: "run_1", status: "attended"},
    },
  });

  const plan = await buildMatchPhonePlan({
    db,
    admin: fakeAdmin,
    phoneA: "+910000000001",
    phoneB: "+910000000002",
    withMessages: true,
    now: new Date("2026-05-08T12:00:00.000Z"),
  });

  assert.equal(plan.docs.filter((doc) => doc.path.includes("/messages/")).length, 3);
  assert.deepEqual(
    plan.docs
      .filter((doc) => doc.path.includes("/messages/"))
      .map((doc) => doc.data.sentAt.iso),
    [
      "2026-05-08T11:48:00.000Z",
      "2026-05-08T11:52:00.000Z",
      "2026-05-08T11:56:00.000Z",
    ]
  );
});

test("buildMatchPhonePlan can write reciprocal swipe docs", async () => {
  const db = fakeFirestore({
    users: {
      uid_a: {phoneNumber: "+910000000001"},
      uid_b: {phoneNumber: "+910000000002"},
    },
    publicProfiles: {
      uid_a: {name: "Asha"},
      uid_b: {name: "Ben"},
    },
    eventParticipations: {
      run_1_uid_a: {uid: "uid_a", eventId: "run_1", status: "attended"},
      run_1_uid_b: {uid: "uid_b", eventId: "run_1", status: "attended"},
    },
  });

  const plan = await buildMatchPhonePlan({
    db,
    admin: fakeAdmin,
    phoneA: "+910000000001",
    phoneB: "+910000000002",
    viaSwipes: true,
    direct: false,
    withMessages: false,
    now: new Date("2026-05-08T12:00:00.000Z"),
  });

  assert.deepEqual(
    plan.docs.map((doc) => doc.path).sort(),
    [
      "swipes/uid_a/outgoing/uid_b",
      "swipes/uid_b/outgoing/uid_a",
    ]
  );
});

test("reset-user-demo-state deletes only demo-owned relationship docs", async () => {
  const db = fakeFirestore({
    users: {
      uid_a: {phoneNumber: "+910000000001"},
    },
    eventParticipations: {
      demo_run_uid_a: {uid: "uid_a", synthetic: true},
      real_run_uid_a: {uid: "uid_a"},
    },
    savedEvents: {
      demo_saved: {uid: "uid_a", demoOps: true},
      from_manifest: {uid: "uid_a"},
    },
    demoOpsEvents: {
      op_1: {
        users: ["uid_a"],
        paths: ["savedEvents/from_manifest"],
      },
    },
    payments: {
      demo_payment: {userId: "uid_a", seedPrefix: "demo_ops_2026"},
    },
    matches: {
      match_1: {
        participantIds: ["uid_a", "uid_b"],
        demoOps: true,
        messages: {
          demo_message: {demoOps: true},
          dogfood_message: {text: "real message inside disposable match"},
        },
      },
      match_2: {participantIds: ["uid_a", "uid_c"]},
    },
    swipes: {
      uid_a: {
        outgoing: {
          uid_b: {targetId: "uid_b", synthetic: true},
          uid_c: {targetId: "uid_c"},
        },
      },
      uid_b: {
        outgoing: {
          uid_a: {targetId: "uid_a", synthetic: true},
        },
      },
    },
    notifications: {
      uid_a: {
        items: {
          demo: {demoOps: true},
          trigger_owned: {matchId: "match_1"},
          real: {},
        },
      },
    },
  });

  const plan = await buildResetUserDemoStatePlan({db, phone: "+910000000001"});

  assert.deepEqual(plan.paths, [
    "demoOpsEvents/op_1",
    "matches/match_1",
    "matches/match_1/messages/demo_message",
    "matches/match_1/messages/dogfood_message",
    "notifications/uid_a/items/demo",
    "notifications/uid_a/items/trigger_owned",
    "payments/demo_payment",
    "eventParticipations/demo_run_uid_a",
    "savedEvents/demo_saved",
    "savedEvents/from_manifest",
    "swipes/uid_a/outgoing/uid_b",
    "swipes/uid_b/outgoing/uid_a",
  ]);
});

test("validate report surfaces demo readiness gaps", async () => {
  const db = fakeFirestore({
    users: {
      uid_a: {phoneNumber: "+910000000001"},
    },
    publicProfiles: {
      uid_a: {name: "Asha"},
    },
    matches: {},
    eventParticipations: {},
    savedEvents: {},
    payments: {},
    swipes: {uid_a: {outgoing: {}}},
    notifications: {uid_a: {items: {}}},
  });

  const report = await buildValidateDemoStateReport({db, phone: "+910000000001"});

  assert.equal(report.demoReady, false);
  assert.match(report.issues.join(" "), /Fewer than 3 active matches/);
});

test("buildMarkAttendedPlan creates attended edge for one real user", async () => {
  const db = fakeFirestore({
    users: {
      uid_a: {phoneNumber: "+910000000001", gender: "woman"},
    },
    events: {
      run_1: {
        clubId: "club_1",
        startTime: new Date("2026-05-08T13:00:00.000Z"),
        endTime: new Date("2026-05-08T14:00:00.000Z"),
      },
    },
  });

  const plan = await buildMarkAttendedPlan({
    db,
    admin: fakeAdmin,
    phone: "+910000000001",
    eventId: "run_1",
    now: new Date("2026-05-08T12:00:00.000Z"),
  });

  assert.equal(plan.docs[0].path, "eventParticipations/run_1_uid_a");
  assert.equal(plan.docs[0].data.status, "attended");
  assert.equal(plan.docs[0].data.genderAtSignup, "woman");
  assert.equal(
    plan.docs.filter((doc) => doc.path.startsWith("userEventScheduleLocks/")).length,
    60
  );
});

test("buildDemoChecklist converts validation counts into capabilities", async () => {
  const db = fakeFirestore({
    users: {
      uid_a: {phoneNumber: "+910000000001"},
    },
    publicProfiles: {
      uid_a: {name: "Asha"},
    },
    matches: {
      match_1: {
        participantIds: ["uid_a", "uid_b"],
        status: "active",
        messages: {message_1: {text: "Hi"}},
      },
    },
    eventParticipations: {
      run_1_uid_a: {uid: "uid_a", eventId: "run_1", status: "attended"},
      run_checkin_uid_a: {
        uid: "uid_a",
        eventId: "run_checkin",
        status: "signedUp",
      },
    },
    events: {
      run_checkin: {
        status: "active",
        startTime: "2026-05-12T12:05:00.000Z",
        startingPointLat: 28.6129,
        startingPointLng: 77.2295,
      },
    },
    savedEvents: {
      saved_1: {uid: "uid_a"},
    },
    payments: {
      payment_1: {userId: "uid_a"},
    },
    swipes: {uid_a: {outgoing: {}}},
    notifications: {uid_a: {items: {n1: {}}}},
  });
  for (const event of Object.values(db.data.events)) {
    event.startTime = fakeTimestamp(event.startTime);
  }

  const checklist = await buildDemoChecklist({
    db,
    phone: "+910000000001",
    now: new Date("2026-05-12T12:00:00.000Z"),
  });

  assert(checklist.canDemo.includes("chat thread"));
  assert(checklist.canDemo.includes("payment history"));
  assert(checklist.canDemo.includes("event map pins"));
  assert(checklist.canDemo.includes("location-gated self check-in"));
  assert.equal(checklist.gaps.length, 0);
});

test("buildWarmUserPlan prefers events in the user's city", async () => {
  const db = fakeFirestore({
    users: {
      uid_a: {
        phoneNumber: "+910000000001",
        city: "delhi",
        gender: "woman",
      },
    },
    publicProfiles: {
      uid_a: {name: "Asha"},
    },
    clubs: {
      club_mumbai: {location: "mumbai"},
      club_delhi: {location: "delhi"},
    },
    events: {
      mumbai_soon: {
        clubId: "club_mumbai",
        status: "active",
        startTime: "2026-05-13T06:00:00.000Z",
        endTime: "2026-05-13T07:00:00.000Z",
        priceInPaise: 0,
      },
      delhi_soon: {
        clubId: "club_delhi",
        status: "active",
        startTime: "2026-05-13T07:00:00.000Z",
        endTime: "2026-05-13T08:00:00.000Z",
        priceInPaise: 0,
      },
      delhi_waitlist: {
        clubId: "club_delhi",
        status: "active",
        startTime: "2026-05-14T07:00:00.000Z",
        endTime: "2026-05-14T08:00:00.000Z",
        priceInPaise: 29900,
      },
      delhi_past: {
        clubId: "club_delhi",
        status: "active",
        startTime: "2026-05-10T07:00:00.000Z",
        endTime: "2026-05-10T08:00:00.000Z",
        priceInPaise: 0,
      },
    },
    eventParticipations: {},
  });
  for (const event of Object.values(db.data.events)) {
    event.startTime = fakeTimestamp(event.startTime);
    event.endTime = fakeTimestamp(event.endTime);
  }

  const plan = await buildWarmUserPlan({
    db,
    admin: fakeAdmin,
    phone: "+910000000001",
    syntheticMatchCount: 0,
    now: new Date("2026-05-12T12:00:00.000Z"),
  });

  const participationPaths = plan.docs
    .map((doc) => doc.path)
    .filter((path) => path.startsWith("eventParticipations/"))
    .sort();
  assert.deepEqual(participationPaths, [
    "eventParticipations/delhi_past_uid_a",
    "eventParticipations/delhi_soon_uid_a",
    "eventParticipations/delhi_waitlist_uid_a",
  ]);
  assert.equal(
    plan.docs.some((doc) => doc.path === "eventParticipations/mumbai_soon_uid_a"),
    false
  );
});

test("buildLaunchCleanupPlan finds demo-owned top-level and nested docs", async () => {
  const db = fakeFirestore({
    users: {
      demo_ops_2026_user: {},
      real_user: {},
    },
    matches: {
      match_1: {
        demoOps: true,
        messages: {
          message_1: {},
        },
      },
    },
    swipes: {
      real_user: {
        outgoing: {
          demo_ops_2026_user: {targetId: "demo_ops_2026_user"},
          other: {targetId: "other"},
        },
      },
    },
    notifications: {
      real_user: {
        items: {
          demo: {matchId: "demo_ops_2026_match"},
          real: {},
        },
      },
    },
  });

  const plan = await buildLaunchCleanupPlan({db});

  assert.deepEqual(plan.paths, [
    "matches/match_1",
    "matches/match_1/messages/message_1",
    "notifications/real_user/items/demo",
    "swipes/real_user/outgoing/demo_ops_2026_user",
    "users/demo_ops_2026_user",
  ]);
});

test("buildStaleEventCleanupPlan removes stale seeded events and their edges", async () => {
  const db = fakeFirestore({
    events: {
      demo_past: {
        seedPrefix: "demo_beta_2026",
        status: "active",
        startTime: "2026-05-10T06:00:00.000Z",
      },
      demo_cancelled: {
        seedPrefix: "demo_beta_2026",
        status: "cancelled",
        startTime: "2026-05-20T06:00:00.000Z",
      },
      demo_future: {
        seedPrefix: "demo_beta_2026",
        status: "active",
        startTime: "2026-05-20T06:00:00.000Z",
      },
      real_past: {
        status: "active",
        startTime: "2026-05-10T06:00:00.000Z",
      },
    },
    eventParticipations: {
      p1: {eventId: "demo_past"},
      p2: {eventId: "demo_future"},
    },
    clubScheduleLocks: {
      club_lock: {eventId: "demo_past"},
    },
    userEventScheduleLocks: {
      user_lock: {eventId: "demo_cancelled"},
    },
    savedEvents: {
      saved: {eventId: "demo_past"},
    },
    payments: {
      payment: {eventId: "demo_past"},
    },
    reviews: {
      review: {eventId: "demo_past"},
    },
    matches: {
      match_1: {
        demoOps: true,
        eventIds: ["demo_past"],
        messages: {m1: {}},
      },
      match_2: {
        eventIds: ["demo_past"],
        messages: {m2: {}},
      },
    },
    swipes: {
      uid_a: {
        outgoing: {
          uid_b: {eventId: "demo_past"},
          uid_c: {eventId: "demo_future"},
        },
      },
    },
    notifications: {
      uid_a: {
        items: {
          run_note: {eventId: "demo_past"},
          match_note: {matchId: "match_1"},
          future_note: {eventId: "demo_future"},
        },
      },
    },
  });
  for (const event of Object.values(db.data.events)) {
    event.startTime = fakeTimestamp(event.startTime);
  }

  const plan = await buildStaleEventCleanupPlan({
    db,
    now: new Date("2026-05-12T12:00:00.000Z"),
  });

  assert.deepEqual(plan.staleEventIds, ["demo_cancelled", "demo_past"]);
  assert.deepEqual(plan.paths, [
    "matches/match_1",
    "matches/match_1/messages/m1",
    "notifications/uid_a/items/match_note",
    "notifications/uid_a/items/run_note",
    "payments/payment",
    "reviews/review",
    "clubScheduleLocks/club_lock",
    "eventParticipations/p1",
    "events/demo_cancelled",
    "events/demo_past",
    "savedEvents/saved",
    "swipes/uid_a/outgoing/uid_b",
    "userEventScheduleLocks/user_lock",
  ]);
});

test("buildCheckInEventPlan creates a signed-up event inside the check-in window", async () => {
  const db = fakeFirestore({
    users: {
      uid_a: {
        phoneNumber: "+910000000001",
        city: "delhi",
        gender: "woman",
      },
    },
    publicProfiles: {
      uid_a: {name: "Asha"},
    },
    eventParticipations: {},
    events: {},
  });

  const plan = await buildCheckInEventPlan({
    db,
    admin: fakeAdmin,
    phone: "+910000000001",
    latitude: 28.6129,
    longitude: 77.2295,
    meetingPoint: "India Gate",
    now: new Date("2026-05-12T12:00:00.000Z"),
  });

  assert.equal(plan.eventId, "demo_ops_2026_checkin_run_uid_a");
  assert.equal(plan.checkInWindowOpensAt, "2026-05-12T11:55:00.000Z");
  const eventDoc = plan.docs.find((doc) => doc.path === `events/${plan.eventId}`);
  assert.equal(eventDoc.data.startingPointLat, 28.6129);
  assert.equal(eventDoc.data.startingPointLng, 77.2295);
  assert.equal(eventDoc.data.bookedCount, 1);
  assert.equal(
    plan.docs.some((doc) => doc.path === `eventParticipations/${plan.eventId}_uid_a`),
    true
  );
});

test("isDemoOwned recognizes all supported demo markers", () => {
  assert.equal(isDemoOwned({demoOps: true}), true);
  assert.equal(isDemoOwned({synthetic: true}), true);
  assert.equal(isDemoOwned({seedPrefix: "demo_beta_2026"}), true);
  assert.equal(isDemoOwned({demoOpsEntityType: "matchThread"}), false);
  assert.equal(isDemoOwned({}), false);
});

function fakeFirestore(initialData) {
  const data = structuredClone(initialData);
  return {
    data,
    collection: (collectionName) => collectionRef(data, collectionName),
    collectionGroup: (collectionId) => collectionGroupQuery(data, collectionId),
  };
}

function fakeTimestamp(iso) {
  const date = new Date(iso);
  return {
    toDate: () => new Date(date),
    toMillis: () => date.getTime(),
  };
}

function collectionRef(data, collectionName) {
  return {
    doc: (id) => documentRef(data, `${collectionName}/${id}`),
    where: (field, op, value) => query(data, collectionName, [{field, op, value}]),
    limit: () => collectionRef(data, collectionName),
    get: async () => querySnapshot(data, collectionName, []),
  };
}

function query(data, collectionName, filters) {
  return {
    where: (field, op, value) => query(data, collectionName, [...filters, {field, op, value}]),
    limit: () => query(data, collectionName, filters),
    get: async () => querySnapshot(data, collectionName, filters),
  };
}

function collectionGroupQuery(data, collectionId, filters = []) {
  return {
    where: (field, op, value) => collectionGroupQuery(data, collectionId, [...filters, {field, op, value}]),
    get: async () => {
      const entries = [];
      for (const [parentId, parent] of Object.entries(data.swipes ?? {})) {
        const nested = parent[collectionId] ?? {};
        for (const [docId, value] of Object.entries(nested)) {
          entries.push({
            id: docId,
            ref: {path: `swipes/${parentId}/${collectionId}/${docId}`},
            data: () => structuredClone(value),
          });
        }
      }
      return snapshot(entries.filter((doc) => matchesFilters(doc.data(), filters)));
    },
  };
}

function querySnapshot(data, collectionName, filters) {
  const docs = Object.entries(data[collectionName] ?? {})
    .map(([id, value]) => docSnapshot(`${collectionName}/${id}`, id, value))
    .filter((doc) => matchesFilters(doc.data(), filters));
  return snapshot(docs);
}

function documentRef(data, documentPath) {
  return {
    path: documentPath,
    get: async () => {
      const value = readPath(data, documentPath);
      return {
        exists: value !== undefined,
        id: documentPath.split("/").at(-1),
        ref: {path: documentPath},
        data: () => structuredClone(value),
      };
    },
    collection: (collectionName) => nestedCollectionRef(data, documentPath, collectionName),
  };
}

function nestedCollectionRef(data, documentPath, collectionName) {
  return {
    get: async () => {
      const parent = readPath(data, documentPath) ?? {};
      const docs = Object.entries(parent[collectionName] ?? {})
        .map(([id, value]) =>
          docSnapshot(`${documentPath}/${collectionName}/${id}`, id, value)
        );
      return snapshot(docs);
    },
  };
}

function docSnapshot(path, id, value) {
  return {
    id,
    ref: {
      path,
      collection: (collectionName) => nestedCollectionRefFromValue(path, value, collectionName),
    },
    data: () => cloneValue(value),
  };
}

function nestedCollectionRefFromValue(documentPath, value, collectionName) {
  return {
    get: async () => snapshot(
      Object.entries(value[collectionName] ?? {})
        .map(([id, doc]) =>
          docSnapshot(`${documentPath}/${collectionName}/${id}`, id, doc)
        )
    ),
  };
}

function snapshot(docs) {
  return {
    docs,
    size: docs.length,
    empty: docs.length === 0,
  };
}

function matchesFilters(value, filters) {
  return filters.every(({field, op, value: expected}) => {
    const actual = value[field];
    if (op === "==") return actual === expected;
    if (op === "array-contains") return Array.isArray(actual) && actual.includes(expected);
    throw new Error(`Unsupported fake query op ${op}`);
  });
}

function readPath(data, documentPath) {
  const parts = documentPath.split("/");
  let cursor = data;
  for (const part of parts) {
    cursor = cursor?.[part];
    if (cursor === undefined) return undefined;
  }
  return cursor;
}

function cloneValue(value) {
  try {
    return structuredClone(value);
  } catch (_) {
    return value;
  }
}
