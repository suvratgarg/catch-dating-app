/* eslint-disable require-jsdoc */
import assert from "node:assert/strict";
import test from "node:test";
import {EventDoc, MatchDoc} from "../shared/firestore";
import {
  buildEventSuccessScorecard,
  writeEventSafetyReportIfNeeded,
} from "./eventSuccessScorecards";

test("buildEventSuccessScorecard computes event aggregates", () => {
  const scorecard = buildEventSuccessScorecard({
    eventId: "event-1",
    event: {
      clubId: "club-1",
      bookedCount: 10,
      checkedInCount: 8,
    } as EventDoc,
    feedback: [
      {
        eventId: "event-1",
        clubId: "club-1",
        uid: "user-1",
        welcomeRating: 5,
        structureRating: 4,
        metNewPeopleCount: 3,
        safetyConcern: false,
      },
      {
        eventId: "event-1",
        clubId: "club-1",
        uid: "user-2",
        welcomeRating: 3,
        structureRating: 2,
        metNewPeopleCount: 1,
        safetyConcern: true,
      },
    ],
    matches: [
      match("match-1", "LAST_MESSAGE_AT" as never),
      match("match-2", null),
    ],
    updatedAt: "SERVER_TIMESTAMP" as never,
  });

  assert.deepEqual(scorecard, {
    eventId: "event-1",
    clubId: "club-1",
    bookedCount: 10,
    checkedInCount: 8,
    feedbackCount: 2,
    attendeesWhoMetTwoPlusPeople: 1,
    mutualMatchCount: 2,
    chatStartedCount: 1,
    repeatSignupCount: 0,
    averageWelcomeRating: 4,
    averageStructureRating: 3,
    safetyIncidentCount: 0,
    updatedAt: "SERVER_TIMESTAMP",
  });
});

test("buildEventSuccessScorecard exposes safety count after sample", () => {
  const scorecard = buildEventSuccessScorecard({
    eventId: "event-1",
    event: {
      clubId: "club-1",
      bookedCount: 10,
      checkedInCount: 8,
    } as EventDoc,
    feedback: Array.from({length: 5}, (_, index) => ({
      eventId: "event-1",
      clubId: "club-1",
      uid: `user-${index}`,
      welcomeRating: 5,
      structureRating: 4,
      metNewPeopleCount: 3,
      safetyConcern: index === 0,
    })),
    matches: [],
    updatedAt: "SERVER_TIMESTAMP" as never,
  });

  assert.equal(scorecard.safetyIncidentCount, 1);
});

test("writeEventSafetyReportIfNeeded stores safety review", async () => {
  const writes: Record<string, unknown> = {};
  await writeEventSafetyReportIfNeeded(
    "event-1_user-1",
    {
      eventId: "event-1",
      clubId: "club-1",
      uid: "user-1",
      welcomeRating: 3,
      structureRating: 2,
      metNewPeopleCount: 1,
      safetyConcern: true,
      privateNote: "  Needs review.  ",
    },
    {
      firestore: () => ({
        collection: (collectionId: string) => ({
          doc: (docId: string) => ({
            set: async (data: unknown) => {
              writes[`${collectionId}/${docId}`] = data;
            },
          }),
        }),
      } as unknown as FirebaseFirestore.Firestore),
      serverTimestamp: () => "SERVER_TIMESTAMP" as never,
    }
  );

  assert.deepEqual(writes["eventSafetyReports/event-1_user-1"], {
    eventId: "event-1",
    clubId: "club-1",
    reporterUserId: "user-1",
    feedbackId: "event-1_user-1",
    source: "event_success_feedback",
    status: "open",
    createdAt: "SERVER_TIMESTAMP",
    updatedAt: "SERVER_TIMESTAMP",
    note: "Needs review.",
  });
});

function match(
  id: string,
  lastMessageAt: FirebaseFirestore.Timestamp | null
): MatchDoc {
  return {
    user1Id: `${id}-a`,
    user2Id: `${id}-b`,
    participantIds: [`${id}-a`, `${id}-b`],
    eventIds: ["event-1"],
    createdAt: "CREATED_AT" as never,
    lastMessageAt,
    unreadCounts: {},
    status: "active",
  };
}
