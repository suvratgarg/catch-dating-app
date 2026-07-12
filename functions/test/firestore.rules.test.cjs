const fs = require("node:fs");
const path = require("node:path");
const {after, before, beforeEach, describe, it} = require("node:test");
const {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} = require("@firebase/rules-unit-testing");
const {
  Timestamp,
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  increment,
  limit,
  orderBy,
  query,
  serverTimestamp,
  setDoc,
  updateDoc,
  where,
} = require("firebase/firestore");

const projectRoot = path.resolve(__dirname, "..", "..");
const firestoreRules = fs.readFileSync(
  path.join(projectRoot, "firestore.rules"),
  "utf8",
);

const projectId = "demo-catch-rules";

let testEnv;

function authedDb(uid) {
  return testEnv.authenticatedContext(uid).firestore();
}

function club(overrides = {}) {
  return {
    name: "Sunset Striders",
    description: "Easy city loops.",
    location: "mumbai",
    area: "Bandra",
    hostUserId: "host-1",
    hostName: "Priya",
    hostAvatarUrl: null,
    createdAt: Timestamp.fromDate(new Date("2026-04-28T10:00:00.000Z")),
    imageUrl: null,
    tags: [],
    memberCount: 1,
    rating: 0,
    reviewCount: 0,
    nextEventAt: null,
    nextEventLabel: null,
    ...overrides,
  };
}

function event(overrides = {}) {
  return {
    clubId: "club-1",
    startTime: Timestamp.fromDate(new Date("2026-05-02T01:30:00.000Z")),
    endTime: Timestamp.fromDate(new Date("2026-05-02T02:30:00.000Z")),
    meetingPoint: "Carter Road",
    startingPointLat: null,
    startingPointLng: null,
    locationDetails: null,
    distanceKm: 5,
    pace: "easy",
    capacityLimit: 20,
    description: "Easy seaside event.",
    priceInPaise: 0,
    constraints: {},
    genderCounts: {},
    ...overrides,
  };
}

function externalEvent(overrides = {}) {
  return {
    schemaVersion: 1,
    eventId: "external-event-1",
    canonicalHostId: "host-afterfly",
    compatibilityClubId: "club-afterfly",
    title: "External mixer",
    description: "Reviewed external supply.",
    startTime: Timestamp.fromDate(new Date("2026-06-26T14:30:00.000Z")),
    endTime: Timestamp.fromDate(new Date("2026-06-26T16:30:00.000Z")),
    timezone: "Asia/Kolkata",
    meetingPoint: "Bandra Amphitheatre",
    meetingLocation: {
      name: "Bandra Amphitheatre",
      address: "Bandra, Mumbai",
      placeId: null,
      latitude: 19.05,
      longitude: 72.82,
      notes: null,
    },
    locationDetails: null,
    photoUrl: null,
    activity: {
      version: 1,
      activityKind: "singlesMixer",
      interactionModel: "freeFormMixer",
      source: "admin",
    },
    price: {
      displayText: null,
      parsedPriceInPaise: 0,
      currency: "INR",
    },
    status: "active",
    publicationStatus: "public",
    booking: {
      mode: "external_outbound_only",
      catchBookingEnabled: false,
      catchPaymentsEnabled: false,
      catchReservationsEnabled: false,
      catchWaitlistEnabled: false,
      externalLinks: [{
        platform: "luma",
        url: "https://luma.com/e",
        linkType: "booking_or_event_page",
        sourceEventKey: "external-event-1",
        candidateId: "candidate-external-event-1",
        primary: true,
      }],
    },
    discovery: {
      citySlug: "mumbai",
      countryCode: "IN",
      availability: "read_only_external",
      manualApprovalRequired: true,
    },
    dedupe: {
      normalizedEventKey: "external-event-1",
      primaryCandidateId: "candidate-external-event-1",
      duplicateCandidateIds: [],
      conflictPolicy: "single_read_only_event_with_multiple_outbound_links",
    },
    externalSource: {
      candidateId: "candidate-external-event-1",
      sourceEventKey: "external-event-1",
      sourceEventId: "external-event-1",
      platform: "luma",
      eventUrl: "https://luma.com/e",
      sourceUrl: "https://example.com/source",
    },
    review: {
      eventReviewBatchId: "batch-1",
      reviewer: "ops",
      decidedAt: "2026-06-25",
      note: null,
      importPolicyAcknowledged: true,
      ownerSafeCopyReviewed: true,
    },
    createdAt: Timestamp.fromDate(new Date("2026-06-25T10:00:00.000Z")),
    updatedAt: Timestamp.fromDate(new Date("2026-06-25T10:00:00.000Z")),
    ...overrides,
  };
}

function eventParticipation(overrides = {}) {
  return {
    eventId: "event-1",
    clubId: "club-1",
    uid: "runner-1",
    status: "attended",
    createdAt: Timestamp.fromDate(new Date("2026-05-02T01:30:00.000Z")),
    updatedAt: Timestamp.fromDate(new Date("2026-05-02T02:30:00.000Z")),
    attendedAt: Timestamp.fromDate(new Date("2026-05-02T02:30:00.000Z")),
    ...overrides,
  };
}

function userProfile(overrides = {}) {
  return {
    name: "Runner One",
    firstName: "Runner",
    lastName: "One",
    displayName: "Runner",
    email: "",
    profilePrompts: [],
    instagramHandle: null,
    phoneNumber: "+919999999999",
    dateOfBirth: Timestamp.fromDate(new Date("1998-01-01T00:00:00.000Z")),
    gender: "woman",
    profileComplete: true,
    profilePhotos: [],
    city: "in-mh-mumbai",
    latitude: null,
    longitude: null,
    interestedInGenders: ["man"],
    minAgePreference: 24,
    maxAgePreference: 34,
    height: null,
    occupation: null,
    company: null,
    education: null,
    religion: null,
    languages: [],
    relationshipGoal: null,
    drinking: null,
    smoking: null,
    workout: null,
    diet: null,
    children: null,
    activityPreferences: activityPreferences(),
    prefsNewCatches: true,
    prefsMessages: true,
    prefsEventReminders: true,
    prefsRunStatusUpdates: true,
    prefsClubUpdates: true,
    prefsWeeklyDigest: false,
    prefsShowOnMap: true,
    ...overrides,
  };
}

function activityPreferences(overrides = {}) {
  return {
    running: {
      paceMinSecsPerKm: 300,
      paceMaxSecsPerKm: 420,
      preferredDistances: [],
      runningReasons: [],
      preferredRunTimes: [],
      version: 1,
      ...overrides,
    },
  };
}

function match(overrides = {}) {
  return {
    user1Id: "runner-1",
    user2Id: "runner-2",
    participantIds: ["runner-1", "runner-2"],
    eventId: "event-1",
    createdAt: Timestamp.fromDate(new Date("2026-05-01T10:00:00.000Z")),
    lastMessageAt: null,
    lastMessagePreview: null,
    lastMessageSenderId: null,
    unreadCounts: { "runner-1": 2, "runner-2": 1 },
    status: "active",
    blockedBy: null,
    blockedAt: null,
    ...overrides,
  };
}

function swipe(overrides = {}) {
  return {
    swiperId: "runner-1",
    targetId: "runner-2",
    eventId: "event-1",
    direction: "like",
    createdAt: serverTimestamp(),
    ...overrides,
  };
}

function review(overrides = {}) {
  return {
    clubId: "club-1",
    eventId: "event-1",
    reviewerUserId: "runner-1",
    reviewerName: "Runner One",
    rating: 5,
    comment: "Great event.",
    createdAt: Timestamp.fromDate(new Date("2026-05-02T05:00:00.000Z")),
    ...overrides,
  };
}

function clubMembership(overrides = {}) {
  return {
    clubId: "club-1",
    uid: "runner-1",
    role: "member",
    status: "active",
    joinedAt: Timestamp.fromDate(new Date("2026-05-01T10:00:00.000Z")),
    leftAt: null,
    deletedAt: null,
    ...overrides,
  };
}

function eventParticipation(overrides = {}) {
  return {
    eventId: "event-1",
    clubId: "club-1",
    uid: "runner-1",
    status: "signedUp",
    createdAt: Timestamp.fromDate(new Date("2026-05-01T10:00:00.000Z")),
    updatedAt: Timestamp.fromDate(new Date("2026-05-01T10:00:00.000Z")),
    signedUpAt: Timestamp.fromDate(new Date("2026-05-01T10:00:00.000Z")),
    waitlistedAt: null,
    attendedAt: null,
    cancelledAt: null,
    deletedAt: null,
    genderAtSignup: "woman",
    paymentId: null,
    ...overrides,
  };
}

function savedEvent(overrides = {}) {
  return {
    uid: "runner-1",
    eventId: "event-1",
    savedAt: Timestamp.fromDate(new Date("2026-05-01T10:00:00.000Z")),
    ...overrides,
  };
}

function activityNotification(overrides = {}) {
  return {
    uid: "runner-1",
    type: "match",
    title: "It's a catch",
    body: "You and Runner Two matched. Say hi!",
    createdAt: Timestamp.fromDate(new Date("2026-05-01T10:00:00.000Z")),
    readAt: null,
    matchId: "match-1",
    eventId: "event-1",
    clubId: null,
    actorUid: "runner-2",
    actorName: "Runner Two",
    ...overrides,
  };
}

function eventSuccessPlan(overrides = {}) {
  return {
    eventId: "event-1",
    clubId: "club-1",
    playbookId: "run_social",
    selectedModuleIds: ["arrival", "wingman_requests"],
    targetAttendeeCount: 20,
    structureConfig: {
      unitKind: "pods",
      unitSize: 4,
      unitCount: 5,
      revealCountdownSeconds: 10,
    },
    hostGoal: "Help everyone meet three new people.",
    wingmanRequestsEnabled: true,
    contextualOpenersEnabled: true,
    compatibilityAffectsRanking: false,
    activeStepIndex: 0,
    status: "setup",
    revealStatus: "idle",
    activeRevealRoundIndex: 0,
    revealStartedAt: null,
    attendeePrompt: "Look for someone who runs your pace.",
    createdAt: Timestamp.fromDate(new Date("2026-05-01T10:00:00.000Z")),
    updatedAt: Timestamp.fromDate(new Date("2026-05-01T10:00:00.000Z")),
    frozenAt: null,
    completedAt: null,
    ...overrides,
  };
}

function eventSuccessFeedback(overrides = {}) {
  return {
    eventId: "event-1",
    clubId: "club-1",
    uid: "runner-1",
    welcomeRating: 5,
    structureRating: 4,
    metNewPeopleCount: 3,
    safetyConcern: false,
    privateNote: "Good pacing and useful prompts.",
    createdAt: Timestamp.fromDate(new Date("2026-05-02T04:00:00.000Z")),
    updatedAt: Timestamp.fromDate(new Date("2026-05-02T04:00:00.000Z")),
    ...overrides,
  };
}

function eventSuccessAssignment(overrides = {}) {
  return {
    eventId: "event-1",
    clubId: "club-1",
    uid: "runner-1",
    moduleId: "micro_pods",
    label: "Pod A",
    displayTitle: "Pod A",
    displaySubtitle: "4 people in this event pod.",
    peerUids: ["runner-2", "runner-3", "runner-4"],
    source: "server_v1",
    createdAt: Timestamp.fromDate(new Date("2026-05-01T10:00:00.000Z")),
    updatedAt: Timestamp.fromDate(new Date("2026-05-01T10:00:00.000Z")),
    ...overrides,
  };
}

function eventSuccessPreference(overrides = {}) {
  return {
    eventId: "event-1",
    clubId: "club-1",
    uid: "runner-1",
    microPodsOptedOut: true,
    guidedRotationsOptedOut: false,
    createdAt: Timestamp.fromDate(new Date("2026-05-01T10:00:00.000Z")),
    updatedAt: Timestamp.fromDate(new Date("2026-05-01T10:00:00.000Z")),
    ...overrides,
  };
}

function eventSuccessCompatibilityResponse(overrides = {}) {
  return {
    eventId: "event-1",
    clubId: "club-1",
    uid: "runner-1",
    answerIds: [
      "event_energy_new_people",
      "first_conversation_activity",
    ],
    createdAt: Timestamp.fromDate(new Date("2026-05-01T10:00:00.000Z")),
    updatedAt: Timestamp.fromDate(new Date("2026-05-01T10:00:00.000Z")),
    ...overrides,
  };
}

function eventSuccessWingmanRequest(overrides = {}) {
  return {
    eventId: "event-1",
    clubId: "club-1",
    requesterUid: "runner-1",
    targetUid: "runner-2",
    status: "active",
    hostVisibleConsent: true,
    note: "Please pair us in a rotation.",
    createdAt: Timestamp.fromDate(new Date("2026-05-01T10:00:00.000Z")),
    updatedAt: Timestamp.fromDate(new Date("2026-05-01T10:00:00.000Z")),
    ...overrides,
  };
}

function eventSuccessArrivalMission(overrides = {}) {
  return {
    eventId: "event-1",
    clubId: "club-1",
    observerUid: "runner-1",
    targetUid: "runner-2",
    targetDisplayName: "Rhea",
    targetContext: "They are checked in and ready for the same room.",
    question: "Ask them: what made this event sound fun?",
    answerOptions: [
      {id: "people", label: "The people"},
      {id: "activity", label: "The activity"},
      {id: "venue", label: "The venue"},
      {id: "friend", label: "A friend"},
    ],
    status: "active",
    createdAt: Timestamp.fromDate(new Date("2026-05-01T10:00:00.000Z")),
    updatedAt: Timestamp.fromDate(new Date("2026-05-01T10:00:00.000Z")),
    ...overrides,
  };
}

function eventReviewId(eventId, reviewerUserId) {
  return `${eventId}~${reviewerUserId}`;
}

async function seed(pathSegments, data) {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), ...pathSegments), data);
  });
}

describe("firestore.rules", () => {
  before(async () => {
    testEnv = await initializeTestEnvironment({
      projectId,
      firestore: {
        rules: firestoreRules,
        host: "127.0.0.1",
        port: 8080,
      },
    });
  });

  beforeEach(async () => {
    await testEnv.clearFirestore();
  });

  after(async () => {
    await testEnv.cleanup();
  });

  describe("clubs", () => {
    it("denies direct club creates because creation is callable-owned", async () => {
      await assertFails(
        setDoc(doc(authedDb("host-1"), "clubs", "club-1"), club()),
      );
    });

    it("denies direct host profile edits because updates are callable-owned", async () => {
      await seed(["clubs", "club-1"], club());

      await assertFails(
        updateDoc(doc(authedDb("host-1"), "clubs", "club-1"), {
          description: "Updated city loops.",
          tags: ["easy"],
          instagramHandle: "@sunsetstriders",
        }),
      );
    });

    it("rejects the older incomplete Club schema", async () => {
      const legacyClub = {
        name: "Legacy Club",
        description: "Old shape.",
        location: "mumbai",
        hostUserId: "host-1",
        createdAt: Timestamp.fromDate(new Date("2026-04-28T10:00:00.000Z")),
        imageUrl: null,
        rating: 0,
        reviewCount: 0,
      };

      await assertFails(
        setDoc(doc(authedDb("host-1"), "clubs", "club-legacy"), legacyClub),
      );
    });

    it("denies direct member joins because membership is callable-owned", async () => {
      await seed(["clubs", "club-1"], club());

      await assertFails(
        setDoc(
          doc(authedDb("runner-1"), "clubs", "club-1"),
          club({
            memberCount: 2,
          }),
        ),
      );
    });

    it("rejects member updates that tamper with club profile fields", async () => {
      await seed(["clubs", "club-1"], club());

      await assertFails(
        setDoc(
          doc(authedDb("runner-1"), "clubs", "club-1"),
          club({
            hostName: "Mallory",
            memberCount: 2,
          }),
        ),
      );
    });

    it("denies direct member count repairs", async () => {
      await seed(["clubs", "club-1"], club());

      await assertFails(
        setDoc(
          doc(authedDb("runner-1"), "clubs", "club-1"),
          club({
            memberCount: 2,
          }),
        ),
      );
    });

    it("denies direct member leaves because membership is callable-owned", async () => {
      await seed(
        ["clubs", "club-1"],
        club({
          memberCount: 3,
        }),
      );

      await assertFails(
        setDoc(
          doc(authedDb("runner-1"), "clubs", "club-1"),
          club({
            memberCount: 2,
          }),
        ),
      );
    });

    it("rejects members changing aggregate membership count", async () => {
      await seed(
        ["clubs", "club-1"],
        club({
          memberCount: 3,
        }),
      );

      await assertFails(
        setDoc(
          doc(authedDb("runner-1"), "clubs", "club-1"),
          club({
            memberCount: 2,
          }),
        ),
      );
    });

    it("denies joining via direct aggregate updates", async () => {
      await seed(["clubs", "club-1"], club());

      await assertFails(
        updateDoc(doc(authedDb("runner-1"), "clubs", "club-1"), {
          memberCount: increment(1),
        }),
      );
    });

    it("denies leaving via direct aggregate updates", async () => {
      await seed(
        ["clubs", "club-1"],
        club({
          memberCount: 3,
        }),
      );

      await assertFails(
        updateDoc(doc(authedDb("runner-1"), "clubs", "club-1"), {
          memberCount: increment(-1),
        }),
      );
    });

    it("denies direct club deletes", async () => {
      await seed(["clubs", "club-1"], club());

      await assertFails(
        deleteDoc(doc(authedDb("host-1"), "clubs", "club-1")),
      );
    });
  });

  describe("relationship documents", () => {
    it("keeps club host claims server-only", async () => {
      await seed(["clubHostClaims", "host-1"], {
        uid: "host-1",
        clubId: "club-1",
        createdAt: Timestamp.fromDate(new Date("2026-05-08T00:00:00.000Z")),
      });

      await assertFails(
        getDoc(doc(authedDb("host-1"), "clubHostClaims", "host-1")),
      );
      await assertFails(
        setDoc(doc(authedDb("host-1"), "clubHostClaims", "host-1"), {
          uid: "host-1",
          clubId: "club-2",
        }),
      );
    });

    it("allows active club membership reads but keeps writes callable-owned", async () => {
      await seed(
        ["clubMemberships", "club-1_runner-1"],
        clubMembership(),
      );
      await seed(
        ["clubMemberships", "club-1_runner-2"],
        clubMembership({
          uid: "runner-2",
          status: "left",
          leftAt: Timestamp.fromDate(new Date("2026-05-02T10:00:00.000Z")),
        }),
      );

      await assertSucceeds(
        getDoc(doc(authedDb("runner-3"), "clubMemberships", "club-1_runner-1")),
      );
      await assertSucceeds(
        getDoc(doc(authedDb("runner-2"), "clubMemberships", "club-1_runner-2")),
      );
      await assertFails(
        getDoc(doc(authedDb("runner-3"), "clubMemberships", "club-1_runner-2")),
      );
      await assertFails(
        setDoc(
          doc(authedDb("runner-1"), "clubMemberships", "club-1_runner-1"),
          clubMembership(),
        ),
      );
    });

    it("allows users to query their own missing club membership edge", async () => {
      await assertSucceeds(
        getDocs(
          query(
            collection(authedDb("runner-1"), "clubMemberships"),
            where("clubId", "==", "club-1"),
            where("uid", "==", "runner-1"),
            limit(1),
          ),
        ),
      );
    });

    it("allows participants, hosts, and authenticated roster viewers to read active event participation edges", async () => {
      await seed(["clubs", "club-1"], club());
      await seed(["events", "event-1"], event());
      await seed(
        ["eventParticipations", "event-1_runner-1"],
        eventParticipation(),
      );

      await assertSucceeds(
        getDoc(doc(authedDb("runner-1"), "eventParticipations", "event-1_runner-1")),
      );
      await assertSucceeds(
        getDoc(doc(authedDb("host-1"), "eventParticipations", "event-1_runner-1")),
      );
      await assertSucceeds(
        getDoc(doc(authedDb("runner-3"), "eventParticipations", "event-1_runner-1")),
      );
      await assertFails(
        setDoc(
          doc(authedDb("runner-1"), "eventParticipations", "event-1_runner-1"),
          eventParticipation(),
        ),
      );
    });

    it("allows users to query their own missing event participation edge", async () => {
      await assertSucceeds(
        getDocs(
          query(
            collection(authedDb("runner-1"), "eventParticipations"),
            where("eventId", "==", "event-404"),
            where("uid", "==", "runner-1"),
          ),
        ),
      );
    });

    it("keeps event broadcast delivery receipts server-only", async () => {
      await seed(["eventBroadcasts", "broadcast-1"], {
        eventId: "event-1",
        clubId: "club-1",
        actorUid: "host-1",
        targetUids: ["runner-1"],
        deliveries: {hashed: {pushStatus: "accepted"}},
      });

      await assertFails(
        getDoc(doc(authedDb("host-1"), "eventBroadcasts", "broadcast-1")),
      );
      await assertFails(
        getDoc(doc(authedDb("runner-1"), "eventBroadcasts", "broadcast-1")),
      );
      await assertFails(
        getDocs(collection(authedDb("host-1"), "eventBroadcasts")),
      );
      await assertFails(
        setDoc(
          doc(authedDb("host-1"), "eventBroadcasts", "broadcast-2"),
          {eventId: "event-1"},
        ),
      );
      await assertFails(
        updateDoc(
          doc(authedDb("host-1"), "eventBroadcasts", "broadcast-1"),
          {status: "completed"},
        ),
      );
      await assertFails(
        deleteDoc(
          doc(authedDb("host-1"), "eventBroadcasts", "broadcast-1"),
        ),
      );
    });

    it("allows authenticated users to query active event rosters", async () => {
      await seed(["clubs", "club-1"], club());
      await seed(["events", "event-1"], event());
      await seed(
        ["eventParticipations", "event-1_runner-1"],
        eventParticipation({uid: "runner-1", status: "signedUp"}),
      );
      await seed(
        ["eventParticipations", "event-1_runner-2"],
        eventParticipation({
          uid: "runner-2",
          status: "waitlisted",
          signedUpAt: null,
          waitlistedAt: Timestamp.fromDate(new Date("2026-05-01T10:00:00.000Z")),
        }),
      );

      await assertSucceeds(
        getDocs(
          query(
            collection(authedDb("runner-3"), "eventParticipations"),
            where("eventId", "==", "event-1"),
            where("status", "in", ["signedUp", "waitlisted", "attended"]),
          ),
        ),
      );
    });

    it("keeps cancelled event participation edges private", async () => {
      await seed(["clubs", "club-1"], club());
      await seed(["events", "event-1"], event());
      await seed(
        ["eventParticipations", "event-1_runner-1"],
        eventParticipation({
          status: "cancelled",
          signedUpAt: null,
          cancelledAt: Timestamp.fromDate(new Date("2026-05-01T11:00:00.000Z")),
        }),
      );

      await assertSucceeds(
        getDoc(doc(authedDb("runner-1"), "eventParticipations", "event-1_runner-1")),
      );
      await assertFails(
        getDoc(doc(authedDb("runner-3"), "eventParticipations", "event-1_runner-1")),
      );
      await assertFails(
        getDocs(
          query(
            collection(authedDb("runner-3"), "eventParticipations"),
            where("eventId", "==", "event-1"),
          ),
        ),
      );
    });

    it("lets users own saved-event edges with deterministic document ids", async () => {
      await seed(["events", "event-1"], event());

      await assertSucceeds(
        setDoc(
          doc(authedDb("runner-1"), "savedEvents", "runner-1_event-1"),
          {
            uid: "runner-1",
            eventId: "event-1",
            savedAt: serverTimestamp(),
          },
        ),
      );
      await assertFails(
        setDoc(
          doc(authedDb("runner-1"), "savedEvents", "runner-2_event-1"),
          {
            uid: "runner-2",
            eventId: "event-1",
            savedAt: serverTimestamp(),
          },
        ),
      );

      await seed(["savedEvents", "runner-1_event-2"], savedEvent({eventId: "event-2"}));

      await assertSucceeds(
        getDoc(doc(authedDb("runner-1"), "savedEvents", "runner-1_event-2")),
      );
      await assertFails(
        getDoc(doc(authedDb("runner-2"), "savedEvents", "runner-1_event-2")),
      );
      await assertSucceeds(
        deleteDoc(doc(authedDb("runner-1"), "savedEvents", "runner-1_event-2")),
      );
      await seed(["savedEvents", "runner-1_event-3"], savedEvent({eventId: "event-3"}));
      await assertFails(
        updateDoc(doc(authedDb("runner-1"), "savedEvents", "runner-1_event-3"), {
          savedAt: serverTimestamp(),
        }),
      );
    });

    it("allows users to query their own missing saved-event edge", async () => {
      await assertSucceeds(
        getDocs(
          query(
            collection(authedDb("runner-1"), "savedEvents"),
            where("uid", "==", "runner-1"),
            where("eventId", "==", "event-404"),
          ),
        ),
      );
    });
  });

  describe("public config", () => {
    it("allows public reads of config/cities and denies other config docs", async () => {
      await seed(["config", "cities"], {
        version: 2,
        cityNames: ["in-mh-mumbai", "in-mp-indore"],
        marketIds: ["in-mh-mumbai", "in-mp-indore"],
        launchMarketIds: ["in-mh-mumbai", "in-mp-indore"],
        cities: [],
        markets: [],
      });
      await seed(["config", "private"], {secret: true});

      await assertSucceeds(getDoc(doc(testEnv.unauthenticatedContext().firestore(), "config", "cities")));
      await assertFails(getDoc(doc(authedDb("runner-1"), "config", "private")));
    });
  });

  describe("users", () => {
    it("allows owners to create the current UserProfile schema without legacy sexualOrientation", async () => {
      await assertSucceeds(
        setDoc(doc(authedDb("runner-1"), "users", "runner-1"), userProfile()),
      );
    });

    it("rejects legacy sexualOrientation on profile create", async () => {
      await assertFails(
        setDoc(
          doc(authedDb("runner-1"), "users", "runner-1"),
          userProfile({sexualOrientation: "straight"}),
        ),
      );
    });

    it("requires a non-empty profile display name on create", async () => {
      await assertFails(
        setDoc(
          doc(authedDb("runner-1"), "users", "runner-1"),
          userProfile({displayName: "   "}),
        ),
      );
    });

    it("requires at least one interested-in gender on create", async () => {
      await assertFails(
        setDoc(
          doc(authedDb("runner-1"), "users", "runner-1"),
          userProfile({interestedInGenders: []}),
        ),
      );
    });

    it("enforces schema-owned profile list bounds on create", async () => {
      await assertSucceeds(
        setDoc(
          doc(authedDb("runner-1"), "users", "runner-1"),
          userProfile({profilePhotos: values(6, {})}),
        ),
      );
      await assertSucceeds(
        setDoc(
          doc(authedDb("runner-3"), "users", "runner-3"),
          userProfile({
            activityPreferences: activityPreferences({
              preferredRunTimes: values(8, "morning"),
            }),
          }),
        ),
      );

      await assertFails(
        setDoc(
          doc(authedDb("runner-4"), "users", "runner-4"),
          userProfile({profilePhotos: values(7, {})}),
        ),
      );
      await assertFails(
        setDoc(
          doc(authedDb("runner-6"), "users", "runner-6"),
          userProfile({
            activityPreferences: activityPreferences({
              preferredRunTimes: values(9, "morning"),
            }),
          }),
        ),
      );
    });

    it("enforces profile age preference bounds on create", async () => {
      await assertSucceeds(
        setDoc(
          doc(authedDb("runner-1"), "users", "runner-1"),
          userProfile({minAgePreference: 18, maxAgePreference: 99}),
        ),
      );
      await assertFails(
        setDoc(
          doc(authedDb("runner-2"), "users", "runner-2"),
          userProfile({minAgePreference: 17}),
        ),
      );
      await assertFails(
        setDoc(
          doc(authedDb("runner-3"), "users", "runner-3"),
          userProfile({maxAgePreference: 100}),
        ),
      );
    });

    it("enforces profile height bounds on create", async () => {
      await assertSucceeds(
        setDoc(
          doc(authedDb("runner-1"), "users", "runner-1"),
          userProfile({height: 120}),
        ),
      );
      await assertSucceeds(
        setDoc(
          doc(authedDb("runner-2"), "users", "runner-2"),
          userProfile({height: 220}),
        ),
      );
      await assertFails(
        setDoc(
          doc(authedDb("runner-3"), "users", "runner-3"),
          userProfile({height: 119}),
        ),
      );
      await assertFails(
        setDoc(
          doc(authedDb("runner-4"), "users", "runner-4"),
          userProfile({height: 221}),
        ),
      );
    });

    it("denies direct profile edits but allows runtime FCM token updates", async () => {
      await seed(["users", "runner-1"], userProfile());

      await assertFails(
        updateDoc(doc(authedDb("runner-1"), "users", "runner-1"), {
          instagramHandle: "@runnerone",
          prefsWeeklyDigest: true,
        }),
      );
      await assertSucceeds(
        updateDoc(doc(authedDb("runner-1"), "users", "runner-1"), {
          fcmToken: "token-1",
        }),
      );
    });

    it("tolerates retained server-owned lifecycle fields on profile updates", async () => {
      await seed(["users", "runner-1"], userProfile({
        deleted: false,
        deletedAt: null,
      }));

      await assertSucceeds(
        updateDoc(doc(authedDb("runner-1"), "users", "runner-1"), {
          fcmToken: "token-1",
        }),
      );
    });

    it("allows owners to persist push installation tokens", async () => {
      await seed(["users", "runner-1"], userProfile());
      const installationRef = doc(
        authedDb("runner-1"),
        "users",
        "runner-1",
        "pushInstallations",
        "host_ios_installation_1",
      );

      await assertSucceeds(
        setDoc(installationRef, {
          token: "token-1",
          appRole: "host",
          environment: "prod",
          platform: "ios",
          appVersion: "1.0.0",
          buildNumber: "42",
          locale: "en-IN",
          timeZone: "IST",
          updatedAt: serverTimestamp(),
        }),
      );
      await assertSucceeds(
        updateDoc(installationRef, {
          token: "token-2",
          updatedAt: serverTimestamp(),
        }),
      );
      await assertSucceeds(getDoc(installationRef));
      await assertSucceeds(deleteDoc(installationRef));
    });

    it("denies invalid or cross-user push installation writes", async () => {
      await seed(["users", "runner-1"], userProfile());
      const ownerDb = authedDb("runner-1");
      const otherDb = authedDb("runner-2");
      const installationPath = [
        "users",
        "runner-1",
        "pushInstallations",
        "host_ios_installation_1",
      ];

      await assertFails(
        setDoc(doc(ownerDb, ...installationPath), {
          token: "token-1",
          appRole: "admin",
          environment: "prod",
          platform: "ios",
          updatedAt: serverTimestamp(),
        }),
      );
      await assertFails(
        setDoc(doc(otherDb, ...installationPath), {
          token: "token-1",
          appRole: "host",
          environment: "prod",
          platform: "ios",
          updatedAt: serverTimestamp(),
        }),
      );
      await assertFails(getDoc(doc(otherDb, ...installationPath)));
    });

    it("denies direct profile field updates regardless of field shape", async () => {
      await seed(["users", "runner-1"], userProfile());
      const userRef = doc(authedDb("runner-1"), "users", "runner-1");

      await assertFails(updateDoc(userRef, {name: "Runner Updated"}));
      await assertFails(updateDoc(userRef, {photoUrls: ["https://example.test/a.jpg"]}));
      await assertFails(updateDoc(userRef, {prefsWeeklyDigest: true}));
      await assertFails(updateDoc(userRef, {dateOfBirth: "1998-01-01"}));
    });

    it("denies client writes to account-deletion lifecycle fields", async () => {
      await seed(["users", "runner-1"], userProfile());

      await assertFails(
        setDoc(doc(authedDb("runner-2"), "users", "runner-2"), userProfile({
          deleted: false,
        })),
      );
      await assertFails(
        updateDoc(doc(authedDb("runner-1"), "users", "runner-1"), {
          deleted: true,
        }),
      );
      await assertFails(
        updateDoc(doc(authedDb("runner-1"), "users", "runner-1"), {
          deletedAt: serverTimestamp(),
        }),
      );
    });

    it("denies owner updates after account-deletion tombstone exists", async () => {
      await seed(["users", "runner-1"], userProfile({
        deleted: true,
        deletedAt: Timestamp.fromDate(new Date("2026-04-28T10:00:00.000Z")),
      }));
      await seed(["deletedUsers", "runner-1"], {
        uid: "runner-1",
        deletedAt: Timestamp.fromDate(new Date("2026-04-28T10:00:00.000Z")),
      });

      await assertFails(
        updateDoc(doc(authedDb("runner-1"), "users", "runner-1"), {
          prefsWeeklyDigest: true,
        }),
      );
    });
  });

  function values(count, value) {
    return Array.from({length: count}, () => value);
  }

  describe("onboarding drafts", () => {
    it("allows only the owner to read, write, and delete their draft", async () => {
      const draft = {
        step: 2,
        draftVersion: 0,
        firstName: "Runner",
        lastName: "One",
        dateOfBirth: null,
        phoneNumber: "9999999999",
        countryCode: "+91",
        gender: "woman",
        interestedInGenders: ["man"],
        instagramHandle: null,
      };

      await assertSucceeds(
        setDoc(doc(authedDb("runner-1"), "onboarding_drafts", "runner-1"), draft),
      );
      await assertSucceeds(
        setDoc(doc(authedDb("runner-1"), "onboarding_drafts", "runner-1"), {
          ...draft,
          futureStepPayload: {canEvolveWithoutRulesDeploy: true},
        }),
      );
      await assertSucceeds(
        getDoc(doc(authedDb("runner-1"), "onboarding_drafts", "runner-1")),
      );
      await assertFails(
        getDoc(doc(authedDb("runner-2"), "onboarding_drafts", "runner-1")),
      );
      await assertSucceeds(
        deleteDoc(doc(authedDb("runner-1"), "onboarding_drafts", "runner-1")),
      );
    });
  });

  describe("chat and match writes", () => {
    it("allows participants to create messages but keeps match previews server-owned", async () => {
      await seed(["matches", "match-1"], match());

      await assertSucceeds(
        setDoc(
          doc(
            authedDb("runner-1"),
            "matches",
            "match-1",
            "messages",
            "message-1",
          ),
          {
            senderId: "runner-1",
            text: "hello",
            sentAt: serverTimestamp(),
          },
        ),
      );
      await assertSucceeds(
        setDoc(
          doc(
            authedDb("runner-1"),
            "matches",
            "match-1",
            "messages",
            "image-message-1",
          ),
          {
            senderId: "runner-1",
            text: "",
            imageUrl: "https://storage.test/chat-image.jpg",
            sentAt: serverTimestamp(),
          },
        ),
      );
      await assertFails(
        updateDoc(doc(authedDb("runner-1"), "matches", "match-1"), {
          lastMessagePreview: "client-owned preview",
        }),
      );
    });

    it("denies messages from non-participants and blocked matches", async () => {
      await seed(["matches", "match-1"], match());
      await seed(["matches", "blocked-match"], match({status: "blocked"}));

      await assertFails(
        setDoc(
          doc(
            authedDb("runner-3"),
            "matches",
            "match-1",
            "messages",
            "message-1",
          ),
          {
            senderId: "runner-3",
            text: "hello",
            sentAt: serverTimestamp(),
          },
        ),
      );
      await assertFails(
        setDoc(
          doc(
            authedDb("runner-1"),
            "matches",
            "blocked-match",
            "messages",
            "message-1",
          ),
          {
            senderId: "runner-1",
            text: "hello",
            sentAt: serverTimestamp(),
          },
        ),
      );
      await assertFails(
        setDoc(
          doc(
            authedDb("runner-1"),
            "matches",
            "match-1",
            "messages",
            "empty-message",
          ),
          {
            senderId: "runner-1",
            text: "",
            sentAt: serverTimestamp(),
          },
        ),
      );
    });

    it("allows participants to reset only their own unread count", async () => {
      await seed(["matches", "match-1"], match());

      await assertSucceeds(
        updateDoc(doc(authedDb("runner-1"), "matches", "match-1"), {
          "unreadCounts.runner-1": 0,
        }),
      );
      await assertFails(
        updateDoc(doc(authedDb("runner-1"), "matches", "match-1"), {
          "unreadCounts.runner-2": 0,
        }),
      );
    });
  });

  describe("activity notifications", () => {
    it("allows users to read only their own notification timeline", async () => {
      await seed(
        ["notifications", "runner-1", "items", "notification-1"],
        activityNotification(),
      );

      await assertSucceeds(
        getDocs(collection(authedDb("runner-1"), "notifications", "runner-1", "items")),
      );
      await assertFails(
        getDocs(collection(authedDb("runner-2"), "notifications", "runner-1", "items")),
      );
    });

    it("allows users to mark notifications read but not edit content", async () => {
      await seed(
        ["notifications", "runner-1", "items", "notification-1"],
        activityNotification(),
      );
      const notificationRef = doc(
        authedDb("runner-1"),
        "notifications",
        "runner-1",
        "items",
        "notification-1",
      );

      await assertSucceeds(updateDoc(notificationRef, {readAt: serverTimestamp()}));
      await assertFails(updateDoc(notificationRef, {title: "Updated"}));
      await assertFails(
        updateDoc(
          doc(
            authedDb("runner-2"),
            "notifications",
            "runner-1",
            "items",
            "notification-1",
          ),
          {readAt: serverTimestamp()},
        ),
      );
    });

    it("denies client-created notification timeline items", async () => {
      await assertFails(
        setDoc(
          doc(
            authedDb("runner-1"),
            "notifications",
            "runner-1",
            "items",
            "notification-1",
          ),
          activityNotification(),
        ),
      );
    });
  });

  describe("swipes", () => {
    it("allows attended users to create valid outgoing swipes", async () => {
      await seed(["publicProfiles", "runner-2"], {name: "Runner Two"});
      await seed(["events", "event-1"], event());
      await seed(
        ["eventParticipations", "event-1_runner-1"],
        eventParticipation({
          status: "attended",
          attendedAt: Timestamp.fromDate(new Date("2026-05-02T02:30:00.000Z")),
        }),
      );
      await seed(
        ["eventParticipations", "event-1_runner-2"],
        eventParticipation({
          uid: "runner-2",
          status: "attended",
          attendedAt: Timestamp.fromDate(new Date("2026-05-02T02:30:00.000Z")),
        }),
      );
      await assertSucceeds(
        getDoc(doc(authedDb("runner-1"), "eventParticipations", "event-1_runner-1")),
      );

      await assertSucceeds(
        setDoc(
          doc(
            authedDb("runner-1"),
            "profileDecisions",
            "runner-1",
            "outgoing",
            "runner-2",
          ),
          swipe(),
        ),
      );
      await seed(["publicProfiles", "runner-2-reaction"], {name: "Runner R"});
      await seed(
        ["eventParticipations", "event-1_runner-2-reaction"],
        eventParticipation({
          uid: "runner-2-reaction",
          status: "attended",
          attendedAt: Timestamp.fromDate(new Date("2026-05-02T02:30:00.000Z")),
        }),
      );
      await assertSucceeds(
        setDoc(
          doc(
            authedDb("runner-1"),
            "profileDecisions",
            "runner-1",
            "outgoing",
            "runner-2-reaction",
          ),
          swipe({
            targetId: "runner-2-reaction",
            reactionTargetId: "profile-prompt-perfectRun",
            reactionTargetType: "profilePrompt",
            reactionTargetLabel: "A perfect event with me looks like...",
            reactionTargetPreview: "Always up for a sunrise event.",
            comment: "Same here.",
          }),
        ),
      );
      await seed(["publicProfiles", "runner-2-compatibility"], {name: "Runner C"});
      await seed(
        ["eventParticipations", "event-1_runner-2-compatibility"],
        eventParticipation({
          uid: "runner-2-compatibility",
          status: "attended",
          attendedAt: Timestamp.fromDate(new Date("2026-05-02T02:30:00.000Z")),
        }),
      );
      await assertSucceeds(
        setDoc(
          doc(
            authedDb("runner-1"),
            "profileDecisions",
            "runner-1",
            "outgoing",
            "runner-2-compatibility",
          ),
          swipe({
            targetId: "runner-2-compatibility",
            reactionTargetId: "compatibility",
            reactionTargetType: "compatibility",
            reactionTargetLabel: "Why you might click",
            reactionTargetPreview: "Your pace ranges overlap.",
          }),
        ),
      );
    });

    it("denies malformed swipe payloads", async () => {
      await seed(["publicProfiles", "runner-2"], {name: "Runner Two"});
      await seed(["events", "event-1"], event());
      await seed(
        ["eventParticipations", "event-1_runner-1"],
        eventParticipation({
          status: "attended",
          attendedAt: Timestamp.fromDate(new Date("2026-05-02T02:30:00.000Z")),
        }),
      );
      await assertSucceeds(
        getDoc(doc(authedDb("runner-1"), "eventParticipations", "event-1_runner-1")),
      );
      await seed(
        ["eventParticipations", "event-1_runner-2"],
        eventParticipation({
          uid: "runner-2",
          status: "attended",
          attendedAt: Timestamp.fromDate(new Date("2026-05-02T02:30:00.000Z")),
        }),
      );

      const swipeRef = doc(
        authedDb("runner-1"),
        "profileDecisions",
        "runner-1",
        "outgoing",
        "runner-2",
      );

      await assertFails(setDoc(swipeRef, swipe({swiperId: "runner-3"})));
      await assertFails(setDoc(swipeRef, swipe({targetId: "runner-3"})));
      await assertFails(setDoc(swipeRef, swipe({direction: "superlike"})));
      await assertFails(setDoc(swipeRef, swipe({eventId: 123})));
      await assertFails(
        setDoc(swipeRef, swipe({reactionTargetType: "superlike"})),
      );
      await assertFails(
        setDoc(swipeRef, swipe({direction: "pass", comment: "Nope."})),
      );
      await assertFails(setDoc(swipeRef, {...swipe(), extraField: true}));
    });

    it("denies swipes outside the eligible event candidate relationship", async () => {
      await seed(["publicProfiles", "runner-1"], {name: "Runner One"});
      await seed(["publicProfiles", "runner-2"], {name: "Runner Two"});
      await seed(["publicProfiles", "runner-3"], {name: "Runner Three"});
      await seed(["events", "event-1"], event());
      await seed(["events", "event-2"], event());
      await seed(
        ["eventParticipations", "event-1_runner-1"],
        eventParticipation({
          status: "attended",
          attendedAt: Timestamp.fromDate(new Date("2026-05-02T02:30:00.000Z")),
        }),
      );
      await seed(
        ["eventParticipations", "event-1_runner-2"],
        eventParticipation({
          uid: "runner-2",
          status: "attended",
          attendedAt: Timestamp.fromDate(new Date("2026-05-02T02:30:00.000Z")),
        }),
      );
      await seed(
        ["eventParticipations", "event-2_runner-1"],
        eventParticipation({
          eventId: "event-2",
          status: "attended",
          attendedAt: Timestamp.fromDate(new Date("2026-05-02T02:30:00.000Z")),
        }),
      );

      await assertFails(
        setDoc(
          doc(authedDb("runner-1"), "profileDecisions", "runner-1", "outgoing", "runner-1"),
          swipe({targetId: "runner-1"}),
        ),
      );
      await assertFails(
        setDoc(
          doc(authedDb("runner-1"), "profileDecisions", "runner-1", "outgoing", "runner-3"),
          swipe({targetId: "runner-3"}),
        ),
      );
      await assertFails(
        setDoc(
          doc(authedDb("runner-1"), "profileDecisions", "runner-1", "outgoing", "runner-2"),
          swipe({eventId: "event-2"}),
        ),
      );

      await seed(["blocks", "runner-2__runner-1"], {
        blockerUserId: "runner-2",
        blockedUserId: "runner-1",
      });
      await assertFails(
        setDoc(
          doc(authedDb("runner-1"), "profileDecisions", "runner-1", "outgoing", "runner-2"),
          swipe(),
        ),
      );
    });
  });

  describe("reviews", () => {
    it("allows authenticated users to read reviews", async () => {
      await seed(
        ["reviews", eventReviewId("event-1", "runner-1")],
        review(),
      );

      await assertSucceeds(getDoc(doc(
        authedDb("runner-1"),
        "reviews",
        eventReviewId("event-1", "runner-1"),
      )));
    });

    it("denies direct review writes because reviews are callable-owned", async () => {
      await seed(
        ["reviews", eventReviewId("event-1", "runner-1")],
        review(),
      );

      const ownReviewRef = doc(
        authedDb("runner-1"),
        "reviews",
        eventReviewId("event-1", "runner-1"),
      );

      await assertFails(
        setDoc(
          doc(authedDb("runner-1"), "reviews", "event-2~runner-1"),
          review({eventId: "event-2"}),
        ),
      );
      await assertFails(updateDoc(ownReviewRef, {
        rating: 4,
        comment: "Updated review.",
        updatedAt: serverTimestamp(),
      }));
      await assertFails(deleteDoc(ownReviewRef));
    });
  });

  describe("events", () => {
    it("denies direct event creates because creation is callable-owned", async () => {
      await seed(["clubs", "club-1"], club());

      await assertFails(
        setDoc(doc(authedDb("host-1"), "events", "event-new"), event()),
      );
    });

    it("denies direct host event detail edits because updates are callable-owned", async () => {
      await seed(["clubs", "club-1"], club());
      await seed(["events", "event-1"], event());

      await assertFails(
        updateDoc(doc(authedDb("host-1"), "events", "event-1"), {
          startTime: Timestamp.fromDate(new Date("2026-05-02T02:00:00.000Z")),
          endTime: Timestamp.fromDate(new Date("2026-05-02T03:00:00.000Z")),
          meetingPoint: "Joggers Park gate",
          startingPointLat: 19.0701,
          startingPointLng: 72.8267,
          locationDetails: "Meet by the main entrance.",
          distanceKm: 6,
          pace: "moderate",
          description: "Updated route and timing.",
        }),
      );
    });

    it("denies hosts changing booking-sensitive or ownership event fields", async () => {
      await seed(["clubs", "club-1"], club());
      await seed(["events", "event-1"], event());

      const runRef = doc(authedDb("host-1"), "events", "event-1");

      await assertFails(updateDoc(runRef, {clubId: "club-2"}));
      await assertFails(updateDoc(runRef, {capacityLimit: 50}));
      await assertFails(updateDoc(runRef, {priceInPaise: 10000}));
      await assertFails(updateDoc(runRef, {constraints: {gender: "woman"}}));
      await assertFails(updateDoc(runRef, {bookedCount: 1}));
      await assertFails(updateDoc(runRef, {waitlistedCount: 1}));
      await assertFails(updateDoc(runRef, {checkedInCount: 1}));
      await assertFails(updateDoc(runRef, {genderCounts: {woman: 1}}));
    });

    it("denies direct event aggregate rewrites because roster actions are callable-owned", async () => {
      await seed(["events", "event-1"], event());

      await assertFails(
        setDoc(
          doc(authedDb("runner-1"), "events", "event-1"),
          event({bookedCount: 1, waitlistedCount: 1}),
        ),
      );
    });

    it("denies direct event deletes", async () => {
      await seed(["clubs", "club-1"], club());
      await seed(["events", "event-1"], event());

      await assertFails(
        deleteDoc(doc(authedDb("host-1"), "events", "event-1")),
      );
    });

    it("allows only public active external event reads", async () => {
      await seed(["externalEvents", "external-public"], externalEvent({
        eventId: "external-public",
      }));
      await seed(["externalEvents", "external-draft"], externalEvent({
        eventId: "external-draft",
        publicationStatus: "draft",
      }));
      await seed(["externalEvents", "external-cancelled"], externalEvent({
        eventId: "external-cancelled",
        status: "cancelled",
      }));

      const db = authedDb("runner-1");
      await assertSucceeds(getDoc(doc(db, "externalEvents", "external-public")));
      await assertFails(getDoc(doc(db, "externalEvents", "external-draft")));
      await assertFails(getDoc(doc(db, "externalEvents", "external-cancelled")));
      await assertSucceeds(getDocs(query(
        collection(db, "externalEvents"),
        where("publicationStatus", "==", "public"),
        where("status", "==", "active"),
        orderBy("startTime"),
        limit(10),
      )));
      await assertFails(getDocs(query(
        collection(db, "externalEvents"),
        where("publicationStatus", "==", "draft"),
      )));
      await assertFails(
        setDoc(doc(db, "externalEvents", "external-new"), externalEvent({
          eventId: "external-new",
        })),
      );
      await assertFails(updateDoc(doc(db, "externalEvents", "external-public"), {
        title: "Client edit",
      }));
      await assertFails(deleteDoc(doc(db, "externalEvents", "external-public")));
    });
  });

  describe("event success", () => {
    it("allows only the event club host to create and update event success plans", async () => {
      await seed(["clubs", "club-1"], club());
      await seed(["events", "event-1"], event({
        startTime: Timestamp.fromDate(new Date("2099-05-02T01:30:00.000Z")),
        endTime: Timestamp.fromDate(new Date("2099-05-02T02:30:00.000Z")),
      }));

      const planRef = doc(authedDb("host-1"), "eventSuccessPlans", "event-1");

      await assertSucceeds(setDoc(planRef, eventSuccessPlan()));
      await assertSucceeds(updateDoc(planRef, {
        activeStepIndex: 1,
        status: "live",
        compatibilityAffectsRanking: true,
        revealStatus: "countingDown",
        activeRevealRoundIndex: 0,
        revealStartedAt: serverTimestamp(),
        updatedAt: serverTimestamp(),
        frozenAt: serverTimestamp(),
      }));
      await assertFails(
        setDoc(
          doc(authedDb("runner-1"), "eventSuccessPlans", "event-1"),
          eventSuccessPlan(),
        ),
      );
      await assertFails(
        setDoc(
          doc(authedDb("host-1"), "eventSuccessPlans", "event-2"),
          eventSuccessPlan({eventId: "event-1"}),
        ),
      );
      await assertFails(
        updateDoc(planRef, {
          hostGoal: "Rewrite the locked setup.",
          updatedAt: serverTimestamp(),
        }),
      );
      await assertFails(
        updateDoc(planRef, {
          selectedModuleIds: Array.from({length: 25}, (_, index) => `m-${index}`),
          updatedAt: serverTimestamp(),
        }),
      );
      await assertFails(
        updateDoc(planRef, {
          structureConfig: {
            unitKind: "pairs",
            unitSize: 2,
            rotationIntervalMinutes: 2,
            revealCountdownSeconds: 10,
          },
          updatedAt: serverTimestamp(),
        }),
      );
      await assertFails(
        updateDoc(planRef, {
          revealStatus: "spoiled",
          updatedAt: serverTimestamp(),
        }),
      );
      await assertFails(
        updateDoc(planRef, {
          compatibilityAffectsRanking: "yes",
          updatedAt: serverTimestamp(),
        }),
      );
    });

    it("freezes event success setup after participant activity or event start", async () => {
      await seed(["clubs", "club-1"], club());
      await seed(["events", "event-1"], event({
        startTime: Timestamp.fromDate(new Date("2099-05-02T01:30:00.000Z")),
        endTime: Timestamp.fromDate(new Date("2099-05-02T02:30:00.000Z")),
        bookedCount: 1,
      }));
      await seed(["events", "event-started"], event({
        clubId: "club-1",
        startTime: Timestamp.fromDate(new Date("2026-05-02T01:30:00.000Z")),
        endTime: Timestamp.fromDate(new Date("2026-05-02T02:30:00.000Z")),
      }));

      await assertFails(
        setDoc(
          doc(authedDb("host-1"), "eventSuccessPlans", "event-1"),
          eventSuccessPlan(),
        ),
      );
      await assertFails(
        setDoc(
          doc(authedDb("host-1"), "eventSuccessPlans", "event-started"),
          eventSuccessPlan({
            eventId: "event-started",
          }),
        ),
      );

      await seed(["eventSuccessPlans", "event-1"], eventSuccessPlan());
      const planRef = doc(authedDb("host-1"), "eventSuccessPlans", "event-1");

      await assertFails(
        updateDoc(planRef, {
          hostGoal: "Late rewrite.",
          updatedAt: serverTimestamp(),
        }),
      );
      await assertSucceeds(
        updateDoc(planRef, {
          activeStepIndex: 1,
          status: "live",
          updatedAt: serverTimestamp(),
          frozenAt: serverTimestamp(),
        }),
      );
    });

    it("allows hosts and active participants to read event success plans", async () => {
      await seed(["clubs", "club-1"], club());
      await seed(["events", "event-1"], event());
      await seed(["eventSuccessPlans", "event-1"], eventSuccessPlan());
      await seed(
        ["eventParticipations", "event-1_runner-1"],
        eventParticipation({status: "signedUp"}),
      );
      await seed(
        ["eventParticipations", "event-1_runner-2"],
        eventParticipation({
          uid: "runner-2",
          status: "cancelled",
          cancelledAt: Timestamp.fromDate(new Date("2026-05-01T11:00:00.000Z")),
        }),
      );

      await assertSucceeds(
        getDoc(doc(authedDb("host-1"), "eventSuccessPlans", "event-1")),
      );
      await assertSucceeds(
        getDoc(doc(authedDb("runner-1"), "eventSuccessPlans", "event-1")),
      );
      await assertFails(
        getDoc(doc(authedDb("runner-2"), "eventSuccessPlans", "event-1")),
      );
      await assertFails(
        getDoc(doc(authedDb("runner-3"), "eventSuccessPlans", "event-1")),
      );
    });

    it("allows attended users to submit feedback only after the event has ended", async () => {
      await seed(["clubs", "club-1"], club());
      await seed(["events", "event-1"], event());
      await seed(
        ["eventParticipations", "event-1_runner-1"],
        eventParticipation({
          status: "attended",
          attendedAt: Timestamp.fromDate(new Date("2026-05-02T02:30:00.000Z")),
        }),
      );
      await seed(
        ["eventParticipations", "event-1_runner-2"],
        eventParticipation({
          uid: "runner-2",
          status: "signedUp",
        }),
      );

      await assertSucceeds(
        setDoc(
          doc(authedDb("runner-1"), "eventSuccessFeedback", "event-1_runner-1"),
          eventSuccessFeedback(),
        ),
      );
      await assertSucceeds(
        updateDoc(
          doc(authedDb("runner-1"), "eventSuccessFeedback", "event-1_runner-1"),
          {
            privateNote: "Even better after the second loop.",
            updatedAt: serverTimestamp(),
          },
        ),
      );
      await assertFails(
        setDoc(
          doc(authedDb("runner-2"), "eventSuccessFeedback", "event-1_runner-2"),
          eventSuccessFeedback({uid: "runner-2"}),
        ),
      );
      await assertFails(
        setDoc(
          doc(authedDb("runner-1"), "eventSuccessFeedback", "event-1_runner-2"),
          eventSuccessFeedback(),
        ),
      );

      await seed(
        ["events", "event-future"],
        event({
          startTime: Timestamp.fromDate(new Date("2099-05-02T01:30:00.000Z")),
          endTime: Timestamp.fromDate(new Date("2099-05-02T02:30:00.000Z")),
        }),
      );
      await seed(
        ["eventParticipations", "event-future_runner-1"],
        eventParticipation({
          eventId: "event-future",
          status: "attended",
          attendedAt: Timestamp.fromDate(new Date("2099-05-02T02:30:00.000Z")),
        }),
      );
      await assertFails(
        setDoc(
          doc(authedDb("runner-1"), "eventSuccessFeedback", "event-future_runner-1"),
          eventSuccessFeedback({eventId: "event-future"}),
        ),
      );
    });

    it("keeps raw attendee feedback private from hosts and unrelated users", async () => {
      await seed(["clubs", "club-1"], club());
      await seed(["events", "event-1"], event());
      await seed(
        ["eventSuccessFeedback", "event-1_runner-1"],
        eventSuccessFeedback(),
      );

      await assertSucceeds(
        getDoc(doc(authedDb("runner-1"), "eventSuccessFeedback", "event-1_runner-1")),
      );
      await assertFails(
        getDoc(doc(authedDb("host-1"), "eventSuccessFeedback", "event-1_runner-1")),
      );
      await assertFails(
        getDocs(
          query(
            collection(authedDb("host-1"), "eventSuccessFeedback"),
            where("eventId", "==", "event-1"),
          ),
        ),
      );
      await assertFails(
        getDoc(doc(authedDb("runner-2"), "eventSuccessFeedback", "event-1_runner-1")),
      );
    });

    it("keeps event safety reports server-owned", async () => {
      await seed(["eventSafetyReports", "event-1_runner-1"], {
        eventId: "event-1",
        clubId: "club-1",
        reporterUserId: "runner-1",
        feedbackId: "event-1_runner-1",
        source: "event_success_feedback",
        status: "open",
        createdAt: Timestamp.fromDate(new Date("2026-05-02T03:00:00.000Z")),
        updatedAt: Timestamp.fromDate(new Date("2026-05-02T03:00:00.000Z")),
      });

      await assertFails(
        getDoc(doc(authedDb("runner-1"), "eventSafetyReports", "event-1_runner-1")),
      );
      await assertFails(
        getDoc(doc(authedDb("host-1"), "eventSafetyReports", "event-1_runner-1")),
      );
      await assertFails(
        setDoc(
          doc(authedDb("runner-1"), "eventSafetyReports", "event-1_runner-2"),
          {
            eventId: "event-1",
            clubId: "club-1",
            reporterUserId: "runner-1",
            feedbackId: "event-1_runner-1",
            source: "event_success_feedback",
            status: "open",
            createdAt: serverTimestamp(),
            updatedAt: serverTimestamp(),
          },
        ),
      );
    });

    it("allows participants to manage only their own event-success preferences", async () => {
      await seed(["clubs", "club-1"], club());
      await seed(["events", "event-1"], event());
      await seed(
        ["eventParticipations", "event-1_runner-1"],
        eventParticipation({status: "signedUp"}),
      );
      await seed(
        ["eventParticipations", "event-1_runner-2"],
        eventParticipation({uid: "runner-2", status: "cancelled"}),
      );

      const preferenceRef = doc(
        authedDb("runner-1"),
        "eventSuccessPreferences",
        "event-1_runner-1",
      );

      await assertSucceeds(setDoc(preferenceRef, eventSuccessPreference()));
      await assertSucceeds(updateDoc(preferenceRef, {
        microPodsOptedOut: false,
        updatedAt: serverTimestamp(),
      }));
      await assertSucceeds(
        getDoc(
          doc(
            authedDb("host-1"),
            "eventSuccessPreferences",
            "event-1_runner-1",
          ),
        ),
      );
      await assertSucceeds(
        getDocs(
          query(
            collection(authedDb("host-1"), "eventSuccessPreferences"),
            where("eventId", "==", "event-1"),
          ),
        ),
      );
      await assertFails(
        setDoc(
          doc(
            authedDb("runner-2"),
            "eventSuccessPreferences",
            "event-1_runner-2",
          ),
          eventSuccessPreference({uid: "runner-2"}),
        ),
      );
      await assertFails(
        setDoc(
          doc(
            authedDb("runner-1"),
            "eventSuccessPreferences",
            "event-1_runner-2",
          ),
          eventSuccessPreference({uid: "runner-2"}),
        ),
      );
    });

    it("lets participants manage private compatibility answers without host read access", async () => {
      await seed(["clubs", "club-1"], club());
      await seed(["events", "event-1"], event());
      await seed(
        ["eventParticipations", "event-1_runner-1"],
        eventParticipation({status: "signedUp"}),
      );
      await seed(
        ["eventParticipations", "event-1_runner-2"],
        eventParticipation({uid: "runner-2", status: "cancelled"}),
      );

      const responseRef = doc(
        authedDb("runner-1"),
        "eventSuccessCompatibilityResponses",
        "event-1_runner-1",
      );

      await assertSucceeds(
        setDoc(responseRef, eventSuccessCompatibilityResponse()),
      );
      await assertSucceeds(updateDoc(responseRef, {
        answerIds: ["event_energy_playful_competition"],
        updatedAt: serverTimestamp(),
      }));
      await assertSucceeds(
        getDoc(
          doc(
            authedDb("runner-1"),
            "eventSuccessCompatibilityResponses",
            "event-1_runner-1",
          ),
        ),
      );
      await assertFails(
        getDoc(
          doc(
            authedDb("host-1"),
            "eventSuccessCompatibilityResponses",
            "event-1_runner-1",
          ),
        ),
      );
      await assertFails(
        getDocs(
          query(
            collection(
              authedDb("host-1"),
              "eventSuccessCompatibilityResponses",
            ),
            where("eventId", "==", "event-1"),
          ),
        ),
      );
      await assertFails(
        setDoc(
          doc(
            authedDb("runner-2"),
            "eventSuccessCompatibilityResponses",
            "event-1_runner-2",
          ),
          eventSuccessCompatibilityResponse({uid: "runner-2"}),
        ),
      );
      await assertFails(
        setDoc(
          doc(
            authedDb("runner-1"),
            "eventSuccessCompatibilityResponses",
            "event-1_runner-2",
          ),
          eventSuccessCompatibilityResponse({uid: "runner-2"}),
        ),
      );
      await assertFails(
        setDoc(
          responseRef,
          eventSuccessCompatibilityResponse({
            answerIds: Array.from({length: 9}, (_, index) => `answer-${index}`),
          }),
        ),
      );
    });

    it("keeps wingman requests server-owned and host-visible", async () => {
      await seed(["clubs", "club-1"], club());
      await seed(["events", "event-1"], event());
      await seed(
        ["eventParticipations", "event-1_runner-1"],
        eventParticipation({
          status: "attended",
          attendedAt: Timestamp.fromDate(new Date("2026-05-01T10:00:00.000Z")),
        }),
      );
      await seed(
        ["eventParticipations", "event-1_runner-2"],
        eventParticipation({
          uid: "runner-2",
          status: "attended",
          attendedAt: Timestamp.fromDate(new Date("2026-05-01T10:00:00.000Z")),
        }),
      );
      await seed(
        ["eventParticipations", "event-1_runner-3"],
        eventParticipation({
          uid: "runner-3",
          status: "signedUp",
        }),
      );

      await seed(
        ["eventSuccessWingmanRequests", "event-1_runner-1"],
        eventSuccessWingmanRequest(),
      );
      await assertSucceeds(
        getDoc(
          doc(
            authedDb("host-1"),
            "eventSuccessWingmanRequests",
            "event-1_runner-1",
          ),
        ),
      );
      await assertSucceeds(
        getDocs(
          query(
            collection(authedDb("host-1"), "eventSuccessWingmanRequests"),
            where("eventId", "==", "event-1"),
            where("status", "==", "active"),
            where("hostVisibleConsent", "==", true),
          ),
        ),
      );
      await assertSucceeds(
        getDoc(
          doc(
            authedDb("runner-1"),
            "eventSuccessWingmanRequests",
            "event-1_runner-1",
          ),
        ),
      );
      await seed(
        ["eventSuccessWingmanRequests", "event-1_runner-1"],
        eventSuccessWingmanRequest({
          status: "withdrawn",
          updatedAt: Timestamp.fromDate(new Date("2026-05-01T10:05:00.000Z")),
        }),
      );
      await assertFails(
        getDoc(
          doc(
            authedDb("host-1"),
            "eventSuccessWingmanRequests",
            "event-1_runner-1",
          ),
        ),
      );
      await assertFails(
        getDoc(
          doc(
            authedDb("runner-2"),
            "eventSuccessWingmanRequests",
            "event-1_runner-1",
          ),
        ),
      );
      await assertFails(
        setDoc(
          doc(
            authedDb("runner-1"),
            "eventSuccessWingmanRequests",
            "event-1_runner-1",
          ),
          eventSuccessWingmanRequest(),
        ),
      );
      await assertFails(
        updateDoc(
          doc(
            authedDb("runner-1"),
            "eventSuccessWingmanRequests",
            "event-1_runner-1",
          ),
          {status: "active", updatedAt: serverTimestamp()},
        ),
      );
      await assertFails(
        setDoc(
          doc(
            authedDb("runner-1"),
            "eventSuccessWingmanRequests",
            "event-1_runner-1",
          ),
          eventSuccessWingmanRequest({hostVisibleConsent: false}),
        ),
      );
      await assertFails(
        setDoc(
          doc(
            authedDb("runner-1"),
            "eventSuccessWingmanRequests",
            "event-1_runner-1",
          ),
          eventSuccessWingmanRequest({targetUid: "runner-3"}),
        ),
      );
      await assertFails(
        setDoc(
          doc(
            authedDb("runner-3"),
            "eventSuccessWingmanRequests",
            "event-1_runner-3",
          ),
          eventSuccessWingmanRequest({
            requesterUid: "runner-3",
            targetUid: "runner-1",
          }),
        ),
      );
      await assertFails(
        setDoc(
          doc(
            authedDb("runner-1"),
            "eventSuccessWingmanRequests",
            "event-1_runner-2",
          ),
          eventSuccessWingmanRequest(),
        ),
      );
    });

    it("keeps First Hello arrival missions server-owned and attendee-private", async () => {
      await seed(["clubs", "club-1"], club());
      await seed(["events", "event-1"], event());
      await seed(
        ["eventParticipations", "event-1_runner-1"],
        eventParticipation({status: "signedUp"}),
      );
      await seed(
        ["eventParticipations", "event-1_runner-2"],
        eventParticipation({uid: "runner-2", status: "attended"}),
      );
      await seed(
        ["eventSuccessArrivalMissions", "event-1_runner-1"],
        eventSuccessArrivalMission(),
      );

      await assertSucceeds(
        getDoc(
          doc(
            authedDb("runner-1"),
            "eventSuccessArrivalMissions",
            "event-1_runner-1",
          ),
        ),
      );
      await assertFails(
        getDoc(
          doc(
            authedDb("runner-2"),
            "eventSuccessArrivalMissions",
            "event-1_runner-1",
          ),
        ),
      );
      await assertFails(
        getDoc(
          doc(
            authedDb("host-1"),
            "eventSuccessArrivalMissions",
            "event-1_runner-1",
          ),
        ),
      );
      await assertFails(
        getDocs(
          query(
            collection(authedDb("runner-1"), "eventSuccessArrivalMissions"),
            where("eventId", "==", "event-1"),
          ),
        ),
      );
      await assertFails(
        setDoc(
          doc(
            authedDb("runner-1"),
            "eventSuccessArrivalMissions",
            "event-1_runner-1",
          ),
          eventSuccessArrivalMission(),
        ),
      );
      await assertFails(
        updateDoc(
          doc(
            authedDb("runner-1"),
            "eventSuccessArrivalMissions",
            "event-1_runner-1",
          ),
          {status: "completed", updatedAt: serverTimestamp()},
        ),
      );
      await seed(
        ["eventSuccessArrivalMissions", "event-1_runner-2"],
        eventSuccessArrivalMission({observerUid: "runner-2"}),
      );
      await assertFails(
        getDoc(
          doc(
            authedDb("runner-1"),
            "eventSuccessArrivalMissions",
            "event-1_runner-2",
          ),
        ),
      );
    });

    it("keeps event-success assignments server-owned and scoped to the attendee", async () => {
      await seed(["clubs", "club-1"], club());
      await seed(["events", "event-1"], event());
      await seed(
        ["eventParticipations", "event-1_runner-1"],
        eventParticipation({status: "signedUp"}),
      );
      await seed(
        ["eventParticipations", "event-1_runner-2"],
        eventParticipation({uid: "runner-2", status: "signedUp"}),
      );
      await seed(
        ["eventSuccessAssignments", "event-1_micro_pods_runner-1"],
        eventSuccessAssignment(),
      );

      await assertSucceeds(
        getDoc(
          doc(
            authedDb("runner-1"),
            "eventSuccessAssignments",
            "event-1_micro_pods_runner-1",
          ),
        ),
      );
      await assertSucceeds(
        getDoc(
          doc(
            authedDb("host-1"),
            "eventSuccessAssignments",
            "event-1_micro_pods_runner-1",
          ),
        ),
      );
      await assertSucceeds(
        getDocs(
          query(
            collection(authedDb("host-1"), "eventSuccessAssignments"),
            where("eventId", "==", "event-1"),
            where("moduleId", "==", "micro_pods"),
          ),
        ),
      );
      await assertSucceeds(
        getDocs(
          query(
            collection(authedDb("host-1"), "eventSuccessAssignments"),
            where("eventId", "==", "event-1"),
            where("moduleId", "==", "guided_rotations"),
          ),
        ),
      );
      await assertFails(
        getDocs(
          query(
            collection(authedDb("runner-1"), "eventSuccessAssignments"),
            where("eventId", "==", "event-1"),
            where("moduleId", "==", "micro_pods"),
          ),
        ),
      );
      await assertFails(
        getDoc(
          doc(
            authedDb("runner-2"),
            "eventSuccessAssignments",
            "event-1_micro_pods_runner-1",
          ),
        ),
      );
      await assertFails(
        setDoc(
          doc(
            authedDb("host-1"),
            "eventSuccessAssignments",
            "event-1_micro_pods_runner-2",
          ),
          eventSuccessAssignment({uid: "runner-2"}),
        ),
      );
    });

    it("exposes event scorecards only to the event host", async () => {
      await seed(["clubs", "club-1"], club());
      await seed(["events", "event-1"], event());
      await seed(
        ["eventParticipations", "event-1_runner-1"],
        eventParticipation({status: "signedUp"}),
      );
      await seed(["eventSuccessScorecards", "event-1"], {
        eventId: "event-1",
        clubId: "club-1",
        feedbackCount: 2,
        updatedAt: Timestamp.fromDate(new Date("2026-05-02T03:00:00.000Z")),
      });

      await assertSucceeds(
        getDoc(doc(authedDb("host-1"), "eventSuccessScorecards", "event-1")),
      );
      await assertFails(
        getDoc(doc(authedDb("runner-1"), "eventSuccessScorecards", "event-1")),
      );
      await assertFails(
        getDoc(doc(authedDb("runner-2"), "eventSuccessScorecards", "event-1")),
      );
      await assertFails(
        setDoc(
          doc(authedDb("host-1"), "eventSuccessScorecards", "event-1"),
          {eventId: "event-1"},
        ),
      );
    });
  });

  describe("participant success metrics", () => {
    it("keeps raw and admin participant metrics server-owned", async () => {
      await seed(["participantSignalFacts", "fact-1"], {
        uid: "runner-1",
        type: "incoming_like",
        source: "swipe",
      });
      await seed(["participantMetricCounters", "runner-1"], {
        uid: "runner-1",
        counters: {incoming_like: 1},
      });
      await seed(["participantMarketplaceMetrics", "runner-1"], {
        uid: "runner-1",
        demandPercentile: 80,
      });

      await assertFails(
        getDoc(doc(authedDb("runner-1"), "participantSignalFacts", "fact-1")),
      );
      await assertFails(
        getDoc(doc(authedDb("runner-1"), "participantMetricCounters", "runner-1")),
      );
      await assertFails(
        getDoc(
          doc(authedDb("runner-1"), "participantMarketplaceMetrics", "runner-1"),
        ),
      );
      await assertFails(
        setDoc(doc(authedDb("runner-1"), "participantSignalFacts", "fact-2"), {
          uid: "runner-1",
        }),
      );
    });

    it("lets users read only their own materialized momentum summary", async () => {
      await seed(["participantMomentum", "runner-1"], {
        uid: "runner-1",
        profileMomentum: 0.7,
      });

      await assertSucceeds(
        getDoc(doc(authedDb("runner-1"), "participantMomentum", "runner-1")),
      );
      await assertFails(
        getDoc(doc(authedDb("runner-2"), "participantMomentum", "runner-1")),
      );
      await assertFails(
        setDoc(doc(authedDb("runner-1"), "participantMomentum", "runner-1"), {
          uid: "runner-1",
        }),
      );
    });
  });

  describe("safety privacy rules", () => {
    it("keeps private profiles owner-only while public profiles remain readable", async () => {
      await seed(["users", "target-1"], userProfile({name: "Target"}));
      await seed(["publicProfiles", "target-1"], {name: "Target"});

      await assertSucceeds(getDoc(doc(authedDb("target-1"), "users", "target-1")));
      await assertFails(getDoc(doc(authedDb("viewer-1"), "users", "target-1")));
      await assertSucceeds(
        getDoc(doc(authedDb("viewer-1"), "publicProfiles", "target-1")),
      );
    });

    it("denies profile reads after either user blocks the other", async () => {
      await seed(["users", "target-1"], {name: "Target"});
      await seed(["publicProfiles", "target-1"], {name: "Target"});
      await seed(["blocks", "target-1__viewer-1"], {
        blockerUserId: "target-1",
        blockedUserId: "viewer-1",
      });

      await assertFails(getDoc(doc(authedDb("viewer-1"), "users", "target-1")));
      await assertFails(
        getDoc(doc(authedDb("viewer-1"), "publicProfiles", "target-1")),
      );
    });

    it("denies reads for deleted private and public profiles", async () => {
      await seed(["users", "target-1"], {name: "Target"});
      await seed(["publicProfiles", "target-1"], {name: "Target"});
      await seed(["deletedUsers", "target-1"], {
        uid: "target-1",
        deletedAt: Timestamp.fromDate(new Date("2026-04-28T10:00:00.000Z")),
      });

      await assertFails(getDoc(doc(authedDb("viewer-1"), "users", "target-1")));
      await assertFails(
        getDoc(doc(authedDb("viewer-1"), "publicProfiles", "target-1")),
      );
    });

    it("allows users to read only block edges involving themselves", async () => {
      await seed(["blocks", "user-1__user-2"], {
        blockerUserId: "user-1",
        blockedUserId: "user-2",
      });

      await assertSucceeds(
        getDoc(doc(authedDb("user-1"), "blocks", "user-1__user-2")),
      );
      await assertSucceeds(
        getDoc(doc(authedDb("user-2"), "blocks", "user-1__user-2")),
      );
      await assertFails(
        getDoc(doc(authedDb("user-3"), "blocks", "user-1__user-2")),
      );
    });

    it("keeps reports, deletion tombstones, and event receipts server-owned", async () => {
      await seed(["reports", "report-1"], {reportedUserId: "target-1"});
      await seed(["deletedUsers", "target-1"], {uid: "target-1"});
      await seed(["functionEventReceipts", "event-1"], {
        handler: "onMessageCreated",
      });

      await assertFails(getDoc(doc(authedDb("user-1"), "reports", "report-1")));
      await assertFails(
        setDoc(doc(authedDb("user-1"), "reports", "report-2"), {
          reportedUserId: "target-1",
        }),
      );
      await assertFails(
        getDoc(doc(authedDb("target-1"), "deletedUsers", "target-1")),
      );
      await assertFails(
        deleteDoc(doc(authedDb("target-1"), "deletedUsers", "target-1")),
      );
      await assertFails(
        getDoc(doc(authedDb("user-1"), "functionEventReceipts", "event-1")),
      );
      await assertFails(
        setDoc(doc(authedDb("user-1"), "functionEventReceipts", "event-2"), {
          handler: "onMessageCreated",
        }),
      );
    });

    it("hides blocked matches from participants", async () => {
      await seed(["matches", "match-1"], {
        user1Id: "user-1",
        user2Id: "user-2",
        participantIds: ["user-1", "user-2"],
        status: "blocked",
      });

      await assertFails(getDoc(doc(authedDb("user-1"), "matches", "match-1")));
    });

    it("allows participants to query their active matches by user fields", async () => {
      await seed(["matches", "match-1"], {
        user1Id: "user-1",
        user2Id: "user-2",
        participantIds: ["user-1", "user-2"],
        status: "active",
        createdAt: Timestamp.fromDate(new Date("2026-04-28T10:00:00.000Z")),
      });

      await assertSucceeds(
        getDocs(
          query(
            collection(authedDb("user-1"), "matches"),
            where("user1Id", "==", "user-1"),
            where("status", "==", "active"),
            orderBy("createdAt", "desc"),
          ),
        ),
      );
      await assertSucceeds(
        getDocs(
          query(
            collection(authedDb("user-2"), "matches"),
            where("user2Id", "==", "user-2"),
            where("status", "==", "active"),
            orderBy("createdAt", "desc"),
          ),
        ),
      );
      await assertFails(
        getDocs(
          query(
            collection(authedDb("user-3"), "matches"),
            where("user1Id", "==", "user-1"),
            where("status", "==", "active"),
            orderBy("createdAt", "desc"),
          ),
        ),
      );
    });
  });

});
