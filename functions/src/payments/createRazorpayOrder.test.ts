/* eslint-disable require-jsdoc */
import assert from "node:assert/strict";
import test from "node:test";
import {HttpsError, type CallableRequest} from "firebase-functions/v2/https";
import Razorpay from "razorpay";
import {createRazorpayOrderHandler} from "./createRazorpayOrder";
import {EventDoc} from "../shared/firestore";

function buildEventDoc(overrides: Partial<EventDoc> = {}): EventDoc {
  return {
    clubId: "club-1",
    startTime: timestamp("2026-05-02T01:30:00.000Z"),
    endTime: timestamp("2026-05-02T02:30:00.000Z"),
    meetingPoint: "Carter Road",
    distanceKm: 5,
    pace: "easy",
    capacityLimit: 20,
    description: "Easy paced seaside event.",
    priceInPaise: 25000,
    status: "active",
    cancelledAt: null,
    cancellationReason: null,
    constraints: {
      minAge: 0,
      maxAge: 99,
    },
    genderCounts: {},
    cohortCounts: {},
    ...overrides,
  };
}

test("createRazorpayOrderHandler uses trusted order data", async () => {
  let capturedPayload: Record<string, unknown> | undefined;
  const order = await createRazorpayOrderHandler(
    buildRequest({
      data: {eventId: "event-1"},
      auth: {uid: "runner-1"},
    }),
    {
      firestore: () => createEventFirestore(buildEventDoc()),
      createClient: () => ({
        orders: {
          create: async (payload: Record<string, unknown>) => {
            capturedPayload = payload;
            return {
              id: "order_123",
              amount: 25000,
              currency: "INR",
            };
          },
        },
      }) as unknown as Razorpay,
      now: () => 123,
    }
  );

  assert.deepEqual(capturedPayload, {
    amount: 25000,
    currency: "INR",
    receipt: "event_event-1_123",
    notes: {
      eventId: "event-1",
      userId: "runner-1",
      quotedAmountInPaise: 25000,
    },
  });
  assert.deepEqual(order, {
    orderId: "order_123",
    amount: 25000,
    currency: "INR",
  });
});

test(
  "createRazorpayOrderHandler rejects duplicate bookings and full events",
  async () => {
    await assert.rejects(
      createRazorpayOrderHandler(
        buildRequest({
          data: {eventId: "event-1"},
          auth: {uid: "runner-1"},
        }),
        {
          firestore: () =>
            createEventFirestore(buildEventDoc(), [
              {uid: "runner-1", status: "signedUp"},
            ]),
          createClient: failOnClientUse,
          now: () => 0,
        }
      ),
      isHttpsError("already-exists", "You are already booked for this event.")
    );

    await assert.rejects(
      createRazorpayOrderHandler(
        buildRequest({
          data: {eventId: "event-1"},
          auth: {uid: "runner-1"},
        }),
        {
          firestore: () =>
            createEventFirestore(
              buildEventDoc({
                capacityLimit: 1,
                bookedCount: 1,
              })
            ),
          createClient: failOnClientUse,
          now: () => 0,
        }
      ),
      isHttpsError(
        "failed-precondition",
        "This event is full. You can join the waitlist instead."
      )
    );
  }
);

test(
  "createRazorpayOrderHandler rejects policy-blocked cohorts before payment",
  async () => {
    await assert.rejects(
      createRazorpayOrderHandler(
        buildRequest({
          data: {eventId: "event-1"},
          auth: {uid: "runner-1"},
        }),
        {
          firestore: () =>
            createEventFirestore(buildEventDoc({
              bookedCount: 11,
              cohortCounts: {
                menInterestedInWomen: 10,
                womenInterestedInMen: 1,
              },
              eventPolicy: {
                version: 1,
                admission: {
                  format: "balancedRatio",
                  capacityLimit: 20,
                  waitlistPolicy: {
                    mode: "rankedOffer",
                    offerWindowMinutes: 20,
                  },
                  inviteRequired: false,
                  membershipRequired: false,
                  manualApprovalRequired: false,
                  cohortCapacityLimits: {},
                  balancedRatioPolicy: {
                    leftCohortId: "menInterestedInWomen",
                    rightCohortId: "womenInterestedInMen",
                    maxSkew: 1,
                    openingBufferPerCohort: 1,
                    outOfRatioCohortPolicy: "waitlist",
                  },
                },
                pricing: {
                  basePriceInPaise: 25000,
                  cohortAdjustmentsInPaise: {},
                  demandPricingRules: [],
                },
                cancellation: {policyId: "standard"},
                settlement: {hostPayoutTiming: "afterEventCompletion"},
              },
            })),
          createClient: failOnClientUse,
          now: () => 0,
        }
      ),
      isHttpsError(
        "failed-precondition",
        "A balanced spot is not available right now. Join the waitlist."
      )
    );
  }
);

function buildRequest({
  data,
  auth,
}: {
  data: Record<string, unknown> | null;
  auth?: {uid: string};
}): CallableRequest<Record<string, unknown> | null> {
  return {
    data,
    auth: auth ?
      ({uid: auth.uid, token: {}} as CallableRequest["auth"]) :
      undefined,
    rawRequest: {} as CallableRequest["rawRequest"],
    acceptsStreaming: false,
  };
}

function createEventFirestore(
  event: EventDoc | null,
  participations: Array<{uid: string; status: string}> = []
): FirebaseFirestore.Firestore {
  return {
    collection: (collectionName: string) => {
      if (collectionName === "events") {
        return {
          doc: () => ({
            get: async () => ({
              exists: event !== null,
              data: () => event,
            }),
          }),
        };
      }
      if (collectionName === "users") {
        return {
          doc: () => ({
            get: async () => ({
              exists: true,
              data: () => ({
                gender: "man",
                interestedInGenders: ["woman"],
              }),
            }),
          }),
        };
      }
      if (collectionName === "eventParticipations") {
        return {
          doc: (id: string) => ({
            get: async () => {
              const participation = participations.find((candidate) =>
                id.endsWith(`_${candidate.uid}`));
              return {
                exists: participation !== undefined,
                data: () => participation,
              };
            },
          }),
          where: () => ({
            where: () => ({
              get: async () => ({
                docs: participations.map((participation) => ({
                  data: () => participation,
                })),
              }),
            }),
          }),
        };
      }
      if (collectionName === "userEventScheduleLocks") {
        return {
          doc: () => ({
            get: async () => ({
              exists: false,
              data: () => undefined,
            }),
          }),
        };
      }
      throw new Error(`Unexpected collection ${collectionName}`);
    },
  } as unknown as FirebaseFirestore.Firestore;
}

function timestamp(iso: string): FirebaseFirestore.Timestamp {
  return {
    toMillis: () => Date.parse(iso),
  } as FirebaseFirestore.Timestamp;
}

function failOnClientUse(): Razorpay {
  throw new Error("Razorpay client should not be created in this test.");
}

function isHttpsError(expectedCode: string, expectedMessage: string) {
  return (error: unknown) =>
    error instanceof HttpsError &&
    error.code === expectedCode &&
    error.message === expectedMessage;
}
