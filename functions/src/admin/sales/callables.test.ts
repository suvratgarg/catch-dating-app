import assert from "node:assert/strict";
import test from "node:test";
import type {CallableRequest} from "firebase-functions/v2/https";
import {HttpsError} from "firebase-functions/v2/https";
import {currentSalesEmployee} from "./callables";

function request(authTime = 1_780_000_000): CallableRequest<unknown> {
  return {
    auth: {
      uid: "admin-1",
      token: {
        admin: true,
        auth_time: authTime,
      },
    },
  } as unknown as CallableRequest<unknown>;
}

test("Sales callable rechecks role and disabled state", async () => {
  const active = await currentSalesEmployee(request(), async () => ({
    disabled: false,
    customClaims: {admin: true},
  }));
  assert.equal(active.uid, "admin-1");
  await assert.rejects(
    currentSalesEmployee(request(), async () => ({
      disabled: false,
      customClaims: {support: true},
    })),
    (error: unknown) =>
      error instanceof HttpsError && error.code === "permission-denied",
  );
  await assert.rejects(
    currentSalesEmployee(request(), async () => ({
      disabled: true,
      customClaims: {admin: true},
    })),
    (error: unknown) =>
      error instanceof HttpsError && error.code === "permission-denied",
  );
});

test("Sales callable rejects a session revoked after token issue", async () => {
  await assert.rejects(
    currentSalesEmployee(request(), async () => ({
      disabled: false,
      customClaims: {adminOwner: true},
      tokensValidAfterTime: "2026-09-28T00:00:00.000Z",
    })),
    (error: unknown) =>
      error instanceof HttpsError && error.code === "permission-denied",
  );
});
