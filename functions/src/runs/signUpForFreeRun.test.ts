/* eslint-disable require-jsdoc */
import assert from "node:assert/strict";
import test from "node:test";
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {signUpForFreeRunHandler} from "./signUpForFreeRun";

test(
  "signUpForFreeRunHandler books a free run through shared signer",
  async () => {
    const signUpCalls: Array<{runId: string; userId: string}> = [];
    const rateLimitCalls: Array<{uid: string; action: string}> = [];

    const result = await signUpForFreeRunHandler(
      request("runner-1", {runId: " run-1 "}),
      deps({
        runs: {
          "run-1": {
            priceInPaise: 0,
          },
        },
        signUpCalls,
        rateLimitCalls,
      })
    );

    assert.deepEqual(result, {success: true});
    assert.deepEqual(rateLimitCalls, [
      {uid: "runner-1", action: "signUpForFreeRun"},
    ]);
    assert.deepEqual(signUpCalls, [{runId: "run-1", userId: "runner-1"}]);
  }
);

test("signUpForFreeRunHandler rejects paid runs", async () => {
  await assert.rejects(
    () => signUpForFreeRunHandler(
      request("runner-1", {runId: "run-1"}),
      deps({
        runs: {
          "run-1": {
            priceInPaise: 10000,
          },
        },
      })
    ),
    isHttpsError(
      "permission-denied",
      "This run requires payment. Use the payment flow instead."
    )
  );
});

test("signUpForFreeRunHandler rate limits before reading runs", async () => {
  let readCount = 0;

  await assert.rejects(
    () => signUpForFreeRunHandler(
      request("runner-1", {runId: "run-1"}),
      deps({
        onRunRead: () => {
          readCount += 1;
        },
        checkRateLimit: async () => {
          throw new HttpsError(
            "resource-exhausted",
            "Too many free run sign-up attempts."
          );
        },
      })
    ),
    isHttpsError(
      "resource-exhausted",
      "Too many free run sign-up attempts."
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
  runs = {},
  signUpCalls = [],
  rateLimitCalls = [],
  onRunRead,
  checkRateLimit,
}: {
  runs?: Record<string, Record<string, unknown>>;
  signUpCalls?: Array<{runId: string; userId: string}>;
  rateLimitCalls?: Array<{uid: string; action: string}>;
  onRunRead?: () => void;
  checkRateLimit?: (
    db: FirebaseFirestore.Firestore,
    uid: string,
    action: string
  ) => Promise<void>;
}) {
  const firestore = {
    collection: (path: string) => {
      assert.equal(path, "runs");
      return {
        doc: (runId: string) => ({
          get: async () => {
            onRunRead?.();
            const data = runs[runId];
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
    signUpForRun: async (
      _db: FirebaseFirestore.Firestore,
      runId: string,
      userId: string
    ) => {
      signUpCalls.push({runId, userId});
    },
  };
}

function isHttpsError(expectedCode: string, expectedMessage: string) {
  return (error: unknown) =>
    error instanceof HttpsError &&
    error.code === expectedCode &&
    error.message === expectedMessage;
}
