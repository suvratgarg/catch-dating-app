/* eslint-disable require-jsdoc */
import assert from "node:assert/strict";
import test from "node:test";
import {EventDoc, MatchDoc} from "../shared/firestore";
import {buildEventSuccessScorecard} from "./eventSuccessScorecards";

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
        markedPrivateCrush: true,
        safetyConcern: false,
      },
      {
        eventId: "event-1",
        clubId: "club-1",
        uid: "user-2",
        welcomeRating: 3,
        structureRating: 2,
        metNewPeopleCount: 1,
        markedPrivateCrush: false,
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
    privateCrushCount: 1,
    mutualMatchCount: 2,
    chatStartedCount: 1,
    repeatSignupCount: 0,
    averageWelcomeRating: 4,
    averageStructureRating: 3,
    safetyIncidentCount: 1,
    updatedAt: "SERVER_TIMESTAMP",
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
