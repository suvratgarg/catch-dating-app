import assert from "node:assert/strict";
import test from "node:test";
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {
  createPrivateEventSetupHandler,
  getPrivateEventSetupHandler,
  SetupCallableDependencies,
  updatePrivateEventBasicsHandler,
} from "./callables";

const request = (data: unknown, uid?: string) => ({
  data, ...(uid ? {auth: {uid, token: {}}} : {}),
}) as CallableRequest<unknown>;

const create = {organizerId: "org1", requestId: "request-1", basics: {
  name: "Mixer", city: {mode: "set", value: {
    cityId: "in-mh-mumbai", marketId: "in-mh-mumbai",
  }}, localDate: "2026-10-01", localStartTime: "18:30",
  timezone: {mode: "set", value: "Asia/Kolkata"},
}};

test("callable auth and payload validation precede rate or database access",
  async () => {
    const deps: SetupCallableDependencies = {
      firestore: () => {
        throw new Error("Unexpected database access");
      },
      checkRateLimit: async () => {
        throw new Error("Unexpected rate charge");
      },
      service: () => {
        throw new Error("Unexpected service access");
      },
    };
    for (const handler of [createPrivateEventSetupHandler,
      updatePrivateEventBasicsHandler, getPrivateEventSetupHandler]) {
      await assert.rejects(handler(request({}), deps),
        (e) => e instanceof HttpsError && e.code === "unauthenticated");
      await assert.rejects(handler(request({}, "host1"), deps),
        (e) => e instanceof HttpsError && e.code === "invalid-argument");
    }
  });

test("create and edit use separate budgets and cannot bypass migration gate",
  async () => {
    const actions: string[] = [];
    const deps: SetupCallableDependencies = {
      firestore: () => ({}) as FirebaseFirestore.Firestore,
      checkRateLimit: async (_db, _uid, action) => {
        actions.push(action);
      },
      service: (db) => ({db, privacyMigrationReady: () => false,
        timestampFromMillis: () => {
          throw new Error("Unexpected timestamp");
        },
        serverTimestamp: () => {
          throw new Error("Unexpected write");
        }}),
    };
    await assert.rejects(createPrivateEventSetupHandler(
      request(create, "host1"), deps),
    (e) => e instanceof HttpsError && e.code === "failed-precondition");
    await assert.rejects(updatePrivateEventBasicsHandler(request({
      ...create, eventId: "event1", expectedSetupRevision: 1,
    }, "host1"), deps),
    (e) => e instanceof HttpsError && e.code === "failed-precondition");
    assert.deepEqual(actions,
      ["createPrivateEventSetup", "updatePrivateEventBasics"]);
    await assert.rejects(createPrivateEventSetupHandler(request({
      ...create, privacyMigrationReady: true,
    }, "host1"), deps),
    (e) => e instanceof HttpsError && e.code === "invalid-argument");
    assert.equal(actions.length, 2);
  });
