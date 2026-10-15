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

test("Sales staff uses current assignments and bounded actions", async () => {
  const staffRequest = {auth: {uid: "staff-1", token: {
    salesStaff: true, auth_time: 1_800_000_000,
  }}} as unknown as CallableRequest<unknown>;
  let lookups = 0;
  const active = await currentSalesEmployee(staffRequest, async () => ({
    disabled: false, customClaims: {salesStaff: true},
  }), async (uid) => {
    assert.equal(uid, "staff-1"); lookups++; return ["org-1"];
  });
  assert.deepEqual(active.organizerIds, ["org-1"]);
  assert.equal(lookups, 1);
  assert(active.allowedActions?.includes("activities.log"));
  assert(!active.allowedActions?.includes("hosts.create"));
  for (const user of [
    {disabled: true, customClaims: {salesStaff: true}},
    {disabled: false, customClaims: {support: true}},
    {disabled: false, customClaims: {salesStaff: true},
      tokensValidAfterTime: "2027-02-01T00:00:00.000Z"},
  ]) {
    await assert.rejects(currentSalesEmployee(staffRequest, async () => user,
      async () => {
        throw new Error("Must deny before assignment lookup");
      }),
    (error: unknown) =>
      error instanceof HttpsError && error.code === "permission-denied");
  }
});
