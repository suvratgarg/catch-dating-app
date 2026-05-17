/* eslint-disable require-jsdoc */
import assert from "node:assert/strict";
import test from "node:test";
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {signUpForFreeEventHandler} from "./signUpForFreeEvent";

test(
  "signUpForFreeEventHandler books a free event through shared signer",
  async () => {
    const signUpCalls: Array<{eventId: string; userId: string}> = [];
    const rateLimitCalls: Array<{uid: string; action: string}> = [];

    const result = await signUpForFreeEventHandler(
      request("runner-1", {eventId: " event-1 "}),
      deps({
        events: {
          "event-1": {
            priceInPaise: 0,
          },
        },
        signUpCalls,
        rateLimitCalls,
      })
    );

    assert.deepEqual(result, {success: true});
    assert.deepEqual(rateLimitCalls, [
      {uid: "runner-1", action: "signUpForFreeEvent"},
    ]);
    assert.deepEqual(signUpCalls, [{eventId: "event-1", userId: "runner-1"}]);
  }
);

test("signUpForFreeEventHandler rejects paid events", async () => {
  await assert.rejects(
    () => signUpForFreeEventHandler(
      request("runner-1", {eventId: "event-1"}),
      deps({
        events: {
          "event-1": {
            priceInPaise: 10000,
          },
        },
      })
    ),
    isHttpsError(
      "permission-denied",
      "This event requires payment. Use the payment flow instead."
    )
  );
});

test("signUpForFreeEventHandler rate limits before reading events", async (
) => {
  let readCount = 0;

  await assert.rejects(
    () => signUpForFreeEventHandler(
      request("runner-1", {eventId: "event-1"}),
      deps({
        onEventRead: () => {
          readCount += 1;
        },
        checkRateLimit: async () => {
          throw new HttpsError(
            "resource-exhausted",
            "Too many free event sign-up attempts."
          );
        },
      })
    ),
    isHttpsError(
      "resource-exhausted",
      "Too many free event sign-up attempts."
    )
  );

  assert.equal(readCount, 0);
});

function request(
  uid: string | null,
  data: Record<string, unknown>
): CallableRequest<unknown> {
  return {
    auth: uid ? {uid, token: {}} as CallableRequest["auth"] : undefined,
    data,
    rawRequest: {} as CallableRequest["rawRequest"],
  } as CallableRequest<unknown>;
}

function deps({
  events = {},
  users = {
    "runner-1": {
      gender: "man",
      interestedInGenders: ["woman"],
    },
  },
  signUpCalls = [],
  rateLimitCalls = [],
  onEventRead,
  checkRateLimit,
}: {
  events?: Record<string, Record<string, unknown>>;
  users?: Record<string, Record<string, unknown>>;
  signUpCalls?: Array<{eventId: string; userId: string}>;
  rateLimitCalls?: Array<{uid: string; action: string}>;
  onEventRead?: () => void;
  checkRateLimit?: (
    db: FirebaseFirestore.Firestore,
    uid: string,
    action: string
  ) => Promise<void>;
}) {
  const firestore = {
    collection: (path: string) => {
      assert.match(path, /^(events|users)$/);
      return {
        doc: (id: string) => ({
          get: async () => {
            if (path === "events") onEventRead?.();
            const data = path === "events" ? events[id] : users[id];
            return {
              exists: data !== undefined,
              data: () => data,
            };
          },
        }),
      };
    },
  } as unknown as FirebaseFirestore.Firestore;

  return {
    firestore: () => firestore,
    checkRateLimit: checkRateLimit ?? (async (_db, uid, action) => {
      rateLimitCalls.push({uid, action});
    }),
    signUpForEvent: async (
      _db: FirebaseFirestore.Firestore,
      eventId: string,
      userId: string
    ) => {
      signUpCalls.push({eventId, userId});
    },
  };
}

function isHttpsError(expectedCode: string, expectedMessage: string) {
  return (error: unknown) =>
    error instanceof HttpsError &&
    error.code === expectedCode &&
    error.message === expectedMessage;
}
