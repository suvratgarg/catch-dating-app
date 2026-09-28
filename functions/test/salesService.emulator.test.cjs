const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const Ajv = require("ajv");
const addFormats = require("ajv-formats");
const {after, before, test: nodeTest} = require("node:test");
const emulatorEnabled = Boolean(process.env.FIRESTORE_EMULATOR_HOST);
const test = (name, fn) => nodeTest(name, {skip: !emulatorEnabled}, fn);
const admin = require("firebase-admin");
const {executeSalesAction: write, executeSalesRead: read} =
  require("../lib/admin/sales/service");

let app;
let db;
let deps;
const actor = {uid: "sales-emulator-employee", roles: ["admin"]};

before(() => {
  if (!emulatorEnabled) return;
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


test("actual persisted service writes satisfy their private schemas", async () => {
  const ajv = new Ajv({allErrors: true, strict: false});
  addFormats(ajv);
  const collections = {
    organizerSalesAccounts: "organizer_sales_accounts",
    salesContacts: "sales_contacts",
    salesContactRelationships: "sales_contact_relationships",
    salesEvidence: "sales_evidence", salesTasks: "sales_tasks",
    salesActionReceipts: "sales_action_receipts",
    salesImportJobs: "sales_import_jobs", salesImportRows: "sales_import_rows",
    salesSuppressionDecisions: "sales_suppression_decisions",
  };
  let checked = 0;
  for (const [collection, schemaName] of Object.entries(collections)) {
    const validate = ajv.compile(JSON.parse(fs.readFileSync(path.resolve(
      __dirname, `../../contracts/firestore/${schemaName}.schema.json`), "utf8")));
    const snapshot = await db.collection(collection).get();
    for (const doc of snapshot.docs) {
      assert.equal(validate(doc.data()), true,
        `${doc.ref.path}: ${ajv.errorsText(validate.errors)}`);
      checked++;
      if (collection === "salesImportJobs") {
        const rows = await doc.ref.collection("rows").get();
        const rowSchema = JSON.parse(fs.readFileSync(path.resolve(__dirname,
          "../../contracts/firestore/sales_import_job_rows.schema.json"), "utf8"));
        const validateRow = ajv.getSchema(rowSchema.$id) ?? ajv.compile(rowSchema);
        for (const row of rows.docs) {
          assert.equal(validateRow(row.data()), true,
            `${row.ref.path}: ${ajv.errorsText(validateRow.errors)}`);
          checked++;
        }
      }
    }
  }
  assert.ok(checked > 20, "Validate actual writes from the service journeys.");
});

test("private demo uses real atomic start limits and only synthetic records", async () => {
  const demo = require("../lib/salesDemo/service");
  const authTime = Date.parse("2026-09-28T10:00:00.000Z") / 1000;
  const owner = {uid: "demo-owner", token: {auth_time: authTime}};
  const viewer = {uid: "demo-viewer", token: {auth_time: authTime,
    email: "synthetic@example.invalid", email_verified: true}};
  const runtime = {db, now: () => new Date("2026-09-28T10:00:00.000Z"),
    tokenKey: () => Buffer.alloc(32, 9), getUser: async (uid) => ({
      disabled: false, customClaims: uid === owner.uid ? {adminOwner: true} : {},
      tokensValidAfterTime: "2026-09-28T09:00:00.000Z",
      email: "synthetic@example.invalid", emailVerified: true})};
  const beforeCollections = (await db.listCollections()).map((ref) => ref.id);
  const publicBefore = (await db.collection("organizers").get()).docs
    .map((doc) => [doc.id, doc.data()]);
  await db.doc("salesDemoCapabilities/synthetic_forms_v1").set({
    schemaVersion: 1, classification: "sales_private",
    capability: "synthetic_forms_v1", revision: "revision-001",
    evidenceRevision: "evidence-001", enabled: true,
    reviewedByUid: "product-owner", reviewedAt: "2026-09-28T09:00:00.000Z"});
  await demo.saveBlueprint(runtime, owner, {requestId: "emulator-save-demo",
    blueprintId: "emulator-blueprint", expectedRevision: 0,
    organizerId: null, candidateId: "synthetic-candidate", opportunityId: null,
    evidenceRevision: "evidence-001", formCapabilityReview: {
      questionTypes: "manual", branching: "unsupported", requiredFields: "manual",
      scoringApproval: "unsupported", uploads: "retained"}, fieldMappings: [],
    preview: {brandName: "Synthetic Host", headline: "Sample workflow",
      scenario: "Review a synthetic application", steps: ["Review", "Reply", "Admit"],
      retainedTools: [], limitations: ["Synthetic records only"], cta: "Try sample"}});
  await demo.reviewBlueprint(runtime, owner, {requestId: "emulator-review-demo",
    blueprintId: "emulator-blueprint", expectedRevision: 1});
  const issued = await demo.issueInvitation(runtime, owner, {
    requestId: "emulator-issue-demo", blueprintId: "emulator-blueprint",
    blueprintRevision: 2, contactBinding: {kind: "email",
      value: "synthetic@example.invalid"},
    expiresAt: "2026-09-30T10:00:00.000Z", sessionCap: 2});
  const access = {invitationId: issued.invitationId, grantToken: issued.grantToken};
  await demo.getPreview(runtime, {invitationId: issued.invitationId});
  assert.equal((await db.collection("salesDemoSessions").get()).size, 0);
  const starts = await Promise.allSettled(Array.from({length: 8}, (_, index) =>
    demo.startSession(runtime, viewer, {...access,
      requestId: `emulator-start-${index}`})));
  assert.equal(starts.filter((result) => result.status === "fulfilled").length, 6);
  assert.ok(starts.filter((result) => result.status === "rejected")
    .every((result) => result.reason.code === "resource-exhausted"));
  const active = starts.find((result) => result.status === "fulfilled").value;
  assert.equal((await db.collection("salesDemoSessions").get()).size, 1);
  const invitation = (await db.doc(`salesDemoInvitations/${issued.invitationId}`)
    .get()).data();
  assert.equal(invitation.sessionCount, 1);
  assert.equal(invitation.startReceiptCount, 6);
  let session = active;
  for (const [index, action] of ["reviewApplication", "prepareReply", "admitGuest"].entries()) {
    session = await demo.advanceSession(runtime, viewer, {sessionId: session.sessionId,
      grantToken: issued.grantToken, expectedRevision: session.revision,
      requestId: `emulator-action-${index}`, action,
      ...(index === 0 ? {choice: "approve"} : index === 1 ? {choice: "welcome"} : {})});
  }
  assert.equal(session.status, "completed");
  await demo.revokeInvitation(runtime, owner, {requestId: "emulator-revoke-demo",
    invitationId: issued.invitationId, expectedRevision: 1});
  await assert.rejects(demo.getSession(runtime, viewer, {sessionId: session.sessionId,
    grantToken: issued.grantToken}), {code: "permission-denied"});
  const ajv = new Ajv({allErrors: true, strict: false}); addFormats(ajv);
  const collections = {salesDemoBlueprints: "sales_demo_blueprints",
    salesDemoCapabilities: "sales_demo_capabilities",
    salesDemoInvitations: "sales_demo_invitations",
    salesDemoSessions: "sales_demo_sessions", salesDemoReceipts: "sales_demo_receipts"};
  for (const [collection, schema] of Object.entries(collections)) {
    const validate = ajv.compile(JSON.parse(fs.readFileSync(path.resolve(__dirname,
      `../../contracts/firestore/${schema}.schema.json`), "utf8")));
    for (const record of (await db.collection(collection).get()).docs) {
      assert.equal(validate(record.data()), true,
        `${record.ref.path}: ${ajv.errorsText(validate.errors)}`);
      assert.equal(JSON.stringify(record.data()).includes(issued.grantToken), false);
    }
  }
  assert.deepEqual((await db.collection("organizers").get()).docs
    .map((doc) => [doc.id, doc.data()]), publicBefore);
  const added = (await db.listCollections()).map((ref) => ref.id)
    .filter((name) => !beforeCollections.includes(name));
  assert.ok(added.every((name) => name in collections || name === "adminAuditLogs"));
});
