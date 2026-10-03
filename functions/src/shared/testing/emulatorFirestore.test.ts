import assert from "node:assert/strict";
import {randomUUID} from "node:crypto";
import test, {TestContext} from "node:test";
import {deleteApp, initializeApp} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";
import * as admin from "firebase-admin";
import {getEmulatorFirestore} from "./emulatorFirestore";

function emulator(t: TestContext) {
  const original = process.env.FIRESTORE_EMULATOR_HOST;
  process.env.FIRESTORE_EMULATOR_HOST = "127.0.0.1:8080";
  t.after(() => {
    if (original === undefined) delete process.env.FIRESTORE_EMULATOR_HOST;
    else process.env.FIRESTORE_EMULATOR_HOST = original;
  });
}

function namedApp(t: TestContext) {
  const app = initializeApp({projectId: "demo-catch-emulator-client"},
    "emulator-client-" + randomUUID());
  t.after(async () => deleteApp(app));
  return app;
}

test("emulator clients reject absent and nonlocal emulator endpoints", (t) => {
  emulator(t);
  for (const host of [undefined, "firestore.googleapis.com:443",
    "192.0.2.1:8080", "localhost:0", "localhost:65536"]) {
    if (host === undefined) delete process.env.FIRESTORE_EMULATOR_HOST;
    else process.env.FIRESTORE_EMULATOR_HOST = host;
    assert.throws(() => getEmulatorFirestore(),
      /A local Firestore emulator is required/u);
  }
});

test("named emulator clients keep canonical identity and configure once",
  (t) => {
    emulator(t);
    const app = admin.initializeApp({projectId: "demo-catch-emulator-client"},
      "namespace-emulator-client-" + randomUUID());
    t.after(async () => deleteApp(app));
    const db = getEmulatorFirestore(app);
    assert.equal(db, getFirestore(app));
    assert.equal(db, admin.firestore(app));
    assert.equal(db, getEmulatorFirestore(app));
    const modular = namedApp(t);
    assert.equal(getEmulatorFirestore(modular), getFirestore(modular));
    assert.equal(getEmulatorFirestore(modular), getEmulatorFirestore(modular));
  });

test("default clients configure internal Admin consumers", (t) => {
  emulator(t);
  const app = initializeApp({projectId: "demo-catch-emulator-client"});
  t.after(async () => deleteApp(app));
  const db = getEmulatorFirestore();
  assert.equal(db, getFirestore());
  assert.equal(db, admin.firestore());
  assert.equal(db, getEmulatorFirestore());
});

test("independent emulator clients each receive their configuration", (t) => {
  emulator(t);
  const first = getEmulatorFirestore(namedApp(t));
  const second = getEmulatorFirestore(namedApp(t));
  assert.notEqual(first, second);
  assert.throws(() => first.settings({}), /already been initialized/u);
  assert.throws(() => second.settings({}), /already been initialized/u);
});

test("failed configuration propagates and does not remember the instance",
  (t) => {
    emulator(t);
    const app = namedApp(t);
    const db = getFirestore(app);
    const failure = new Error("Synthetic settings failure");
    t.mock.method(db, "settings", () => {
      throw failure;
    });
    assert.throws(() => getEmulatorFirestore(app),
      (error) => error === failure);
    t.mock.restoreAll();
    assert.equal(getEmulatorFirestore(app), db);
    assert.equal(getEmulatorFirestore(app), db);
  });
