const assert = require("node:assert/strict");
const {after, before, test} = require("node:test");
const admin = require("firebase-admin");
const {executeSalesAction: write, executeSalesRead: read} =
  require("../lib/admin/sales/service");

let app;
let db;
let deps;
const actor = {uid: "sales-emulator-employee", roles: ["admin"]};

before(() => {
  assert.ok(process.env.FIRESTORE_EMULATOR_HOST,
    "This integration test requires the local Firestore emulator.");
  app = admin.initializeApp({projectId: "demo-catch-sales-service"},
    "sales-service-integration");
  db = app.firestore();
  deps = {firestore: () => db,
    now: () => new Date("2026-09-28T00:00:00.000Z")};
});
after(async () => { await app?.delete(); });

test("private account creation replays without changing public identity", async () => {
  const organizerId = "service-public-host";
  const publicHost = {name: "Synthetic Public Host", cityName: "Mumbai",
    appVisibility: "hidden", entitySubtypes: ["event_organizer"]};
  await db.doc(`organizers/${organizerId}`).set(publicHost);
  const request = {organizerId, requestId: "service-create-0001"};
  const created = await write(actor, "hosts.create", request, deps);
  assert.deepEqual(await write(actor, "hosts.create", request, deps), created);
  assert.deepEqual((await db.doc(`organizers/${organizerId}`).get()).data(),
    publicHost);
  const detail = await read(actor, "hosts.get", {organizerId}, deps);
  assert.deepEqual(detail.organizerSummary.eventTypes, [],
    "Deprecated organizer classifications are not reviewed event types.");
  await assert.rejects(write(actor, "hosts.update", {organizerId,
    requestId: "service-update-0001", expectedRevision: 0,
    patch: {summary: "Stale change"}}, deps), {code: "aborted"});
});

test("import reconciles every row and retries without a second import", async () => {
  await db.doc("organizers/service-import-one").set({name: "Synthetic One"});
  await db.doc("organizers/service-import-two").set({name: "Synthetic Two"});
  await write(actor, "hosts.create", {organizerId: "service-import-one",
    requestId: "service-import-create"}, deps);
  const packet = {sourceId: "synthetic-source", contentHash: "a".repeat(64),
    mappingVersion: "synthetic-v1", rows: [
      {sourceRowId: "one", organizerId: "service-import-one",
        name: "Synthetic One", researchStatus: "qualified",
        originalScore: {model: "historical-example", value: 43},
        originalCells: [{column: "Legacy score", value: "43"},
          {column: "Unmapped note", value: "Retain this research"}]},
      {sourceRowId: "two", organizerId: "service-import-two",
        name: "Synthetic Two", researchStatus: "new"},
      {sourceRowId: "three", organizerId: null,
        name: "Unresolved Example", researchStatus: "new"},
    ]};
  const preview = await read(actor, "imports.preview", packet, deps);
  const request = {...packet, requestId: "service-import-0001",
    previewHash: preview.previewHash};
  const applied = await write(actor, "imports.apply", request, deps);
  assert.deepEqual(applied.counts,
    {created: 1, matched: 1, duplicate: 0, unresolved: 1, rejected: 0});
  assert.deepEqual(await write(actor, "imports.apply", request, deps), applied);
  const lineage = await db.doc(`salesImportJobs/${applied.importId}/rows/000`).get();
  assert.deepEqual(lineage.data().originalCells, packet.rows[0].originalCells);
  assert.deepEqual(lineage.data().originalScore, packet.rows[0].originalScore);
  await assert.rejects(write(actor, "imports.apply", {...request,
    mappingVersion: "changed-material"}, deps), {code: "already-exists"});
});

test("shared contacts retain endpoints but scoped reads reveal one relationship", async () => {
  for (const organizerId of ["service-contact-one", "service-contact-two"]) {
    await db.doc(`organizers/${organizerId}`).set({name: "Synthetic Host"});
    await write(actor, "hosts.create", {organizerId,
      requestId: `create-${organizerId}`}, deps);
  }
  const organizerId = "service-contact-one";
  const created = await write(actor, "contacts.upsert", {organizerId,
    requestId: "service-contact-0001", expectedRevision: 0,
    contact: {displayName: "Synthetic Contact"},
    relationship: {role: "Organizer", decisionInfluence: "decision_maker",
      primary: true, endpoints: [{kind: "email",
        value: "synthetic@example.invalid", verificationStatus: "unverified"}]}}, deps);
  const contactId = created.contact.contactId;
  await write(actor, "contacts.upsert", {organizerId, contactId,
    requestId: "service-contact-0002", expectedRevision: 1,
    contact: {displayName: "Synthetic Contact"},
    relationship: {role: "Program manager", decisionInfluence: "decision_maker",
      primary: true}}, deps);
  const contacts = await read(actor, "contacts.list", {organizerId}, deps);
  assert.equal(contacts.rows[0].relationship.endpoints.length, 1);
  await write(actor, "contacts.upsert", {organizerId: "service-contact-two",
    contactId, requestId: "service-contact-0003", expectedRevision: 0,
    linkExisting: true, contact: {displayName: "Synthetic Contact"},
    relationship: {role: "Other private role", decisionInfluence: "influencer",
      primary: false}}, deps);
  const scoped = {...actor, clientId: "synthetic-client",
    clientAuthUid: "synthetic-service", delegationId: "synthetic-grant",
    organizerIds: [organizerId],
    allowedActions: ["contacts.list", "hosts.get"], fieldIds: [],
    readEndpoints: false};
  // Delegation authority itself is exercised by gateway tests. This integration
  // tests the shared service's actual query projection under a resolved scope.
  const scopedDeps = {...deps, authorizeRead: async () => {},
    authorizeInTransaction: async () => {}};
  const projected = await read(scoped, "contacts.list", {organizerId}, scopedDeps);
  assert.equal(projected.rows.length, 1);
  assert.equal("endpoints" in projected.rows[0].relationship, false);
  assert.equal(JSON.stringify(projected).includes("Other private role"), false);
  await assert.rejects(read(scoped, "contacts.list",
    {organizerId: "service-contact-two"}, scopedDeps), {code: "permission-denied"});
  await write(actor, "tasks.upsert", {organizerId,
    requestId: "service-task-0001", expectedRevision: 0,
    task: {kind: "research", title: "Synthetic next step",
      dueAt: "2026-09-29T05:30:00.000Z", ownerUid: actor.uid, status: "open"}}, deps);
  const detail = await read(actor, "hosts.get", {organizerId}, deps);
  assert.equal(detail.tasks.length, 1);
});

test("expired contact evidence hides outbound work but preserves service replies", async () => {
  const organizerId = "service-expiring-contact";
  await db.doc(`organizers/${organizerId}`).set({name: "Synthetic Expiry Host"});
  await write(actor, "hosts.create", {organizerId,
    requestId: "expiry-create-0001"}, deps);
  const contact = await write(actor, "contacts.upsert", {organizerId,
    requestId: "expiry-contact-0001", expectedRevision: 0,
    contact: {displayName: "Synthetic Contact"},
    relationship: {role: "Organizer", decisionInfluence: "decision_maker",
      primary: true}}, deps);
  const contactId = contact.contact.contactId;
  const evidence = await write(actor, "evidence.add", {organizerId, contactId,
    requestId: "expiry-evidence-0001", claimKey: "identity",
    sourceType: "human_note", sourceRef: "synthetic:employee-review",
    observedAt: "2026-09-27T00:00:00.000Z",
    validThrough: "2026-09-29T00:00:00.000Z", confidence: "medium"}, deps);
  const review = {organizerId, contactId, requestId: "expiry-review-0001",
    expectedRevision: 1, status: "draft_reviewed",
    reason: "Review limited to drafting", evidenceId: evidence.evidence.evidenceId};
  await write(actor, "contacts.setContactability", review, deps);
  const followUp = {organizerId, requestId: "expiry-task-0001", expectedRevision: 0,
    task: {contactId, kind: "follow_up", title: "Synthetic follow-up",
      dueAt: "2026-09-28T05:30:00.000Z", ownerUid: actor.uid, status: "open"}};
  await write(actor, "tasks.upsert", followUp, deps);
  await write(actor, "tasks.upsert", {...followUp, requestId: "expiry-reply-0001",
    task: {...followUp.task, kind: "reply", title: "Answer inbound question"}}, deps);
  assert.equal((await read(actor, "hosts.get", {organizerId}, deps)).tasks.length, 2);
  const expired = {...deps, now: () => new Date("2026-09-29T00:00:00.000Z")};
  const detail = await read(actor, "hosts.get", {organizerId}, expired);
  assert.deepEqual(detail.tasks.map((task) => task.kind), ["reply"]);
  const queue = await read(actor, "tasks.list", {ownerUid: actor.uid,
    status: "open", limit: 50}, expired);
  assert.deepEqual(queue.rows.filter((task) => task.organizerId === organizerId)
    .map((task) => task.kind), ["reply"]);
  await assert.rejects(write(actor, "tasks.upsert", {...followUp,
    requestId: "expiry-task-0002"}, expired), {code: "failed-precondition"});
  await assert.rejects(write(actor, "contacts.setContactability", {...review,
    expectedRevision: 2, requestId: "expiry-review-0002"}, expired),
  {code: "failed-precondition"});
});
