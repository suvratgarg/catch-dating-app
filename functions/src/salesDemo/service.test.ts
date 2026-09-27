import assert from "node:assert/strict";
import test from "node:test";
import {readFileSync} from "node:fs";
import {resolve} from "node:path";
import Ajv from "ajv";
import addFormats from "ajv-formats";
import {HttpsError} from "firebase-functions/v2/https";
import {Identity, CurrentUser} from "./model";
import {DemoDeps, advanceSession, getPreview, getSession,
  issueInvitation, reviewBlueprint, revokeInvitation, saveBlueprint,
  startSession, withdrawBlueprint} from "./service";

interface Ref {path: string; id: string}
class MemoryDb {
  docs = new Map<string, Record<string, unknown>>();
  versions = new Map<string, number>();
  writes = 0;
  put(path: string, value: Record<string, unknown>): void {
    this.docs.set(path, structuredClone(value));
    this.versions.set(path, (this.versions.get(path) ?? 0) + 1);
    this.writes++;
  }
  collection(name: string) {
    return {doc: (id: string) => {
      const ref = {path: `${name}/${id}`, id};
      return {...ref, get: async () => this.snap(ref)};
    }};
  }
  snap(ref: Ref) {
    const data = this.docs.get(ref.path);
    return {exists: Boolean(data), id: ref.id,
      data: () => data ? structuredClone(data) : undefined};
  }
  async runTransaction<T>(callback: (tx: {
    get(ref: Ref): Promise<ReturnType<MemoryDb["snap"]>>;
    create(ref: Ref, value: Record<string, unknown>): void;
    set(ref: Ref, value: Record<string, unknown>): void;
    update(ref: Ref, value: Record<string, unknown>): void;
  }) => Promise<T>): Promise<T> {
    for (let attempt = 0; attempt < 3; attempt++) {
      const reads = new Map<string, number>();
      const writes: Array<{kind: "create" | "set" | "update";
        ref: Ref; value: Record<string, unknown>}> = [];
      const result = await callback({
        get: async (ref) => {
          reads.set(ref.path, this.versions.get(ref.path) ?? 0);
          return this.snap(ref);
        },
        create: (ref, value) => writes.push({kind: "create", ref, value}),
        set: (ref, value) => writes.push({kind: "set", ref, value}),
        update: (ref, value) => writes.push({kind: "update", ref, value}),
      });
      if ([...reads].some(([path, version]) =>
        (this.versions.get(path) ?? 0) !== version)) continue;
      for (const write of writes) {
        const existing = this.docs.get(write.ref.path);
        if (write.kind === "create" && existing) {
          throw new Error("duplicate create");
        }
        if (write.kind === "update" && !existing) {
          throw new Error("missing update");
        }
        this.put(write.ref.path, write.kind === "update" ?
          {...existing, ...write.value} : write.value);
      }
      return result;
    }
    throw new Error("transaction contention");
  }
}
const owner: Identity = {uid: "owner-uid", token: {}};
const intended: Identity = {uid: "intended-uid", token: {
  email: "host@example.invalid", email_verified: true}};
const other: Identity = {uid: "other-uid", token: {
  email: "other@example.invalid", email_verified: true}};
const samplePreview = {brandName: "Example Host", headline: "Try a sample",
  scenario: "Sample application review", steps: ["Review a sample application",
    "Prepare a sample reply", "Admit a sample guest"],
  retainedTools: ["External form remains in place"],
  limitations: ["Simulation only; no real message or admission"],
  cta: "Try sample workflow"};
function fixture() {
  const db = new MemoryDb();
  db.put("salesDemoCapabilities/synthetic_forms_v1",
    {schemaVersion: 1, classification: "sales_private",
      capability: "synthetic_forms_v1", revision: "revision-001",
      evidenceRevision: "evidence-001",
      enabled: true, reviewedByUid: "product-owner-uid",
      reviewedAt: "2026-09-28T09:00:00.000Z"});
  let clock = new Date("2026-09-28T10:00:00.000Z");
  const users = new Map<string, CurrentUser>([
    ["owner-uid", {disabled: false, customClaims: {adminOwner: true}}],
    ["intended-uid", {disabled: false, email: "host@example.invalid",
      emailVerified: true}],
    ["other-uid", {disabled: false, email: "other@example.invalid",
      emailVerified: true}],
  ]);
  const deps: DemoDeps = {db: db as unknown as FirebaseFirestore.Firestore,
    now: () => clock, getUser: async (uid) => users.get(uid) ??
      {disabled: true}, tokenKey: () => Buffer.alloc(32, 7)};
  return {db, deps, users, setTime: (value: string) => {
    clock = new Date(value);
  }};
}
async function blueprint(deps: DemoDeps) {
  await saveBlueprint(deps, owner, {requestId: "save-demo-001",
    blueprintId: "blueprint-001", expectedRevision: 0,
    organizerId: null, candidateId: "candidate-001",
    opportunityId: null, evidenceRevision: "evidence-001",
    formCapabilityReview: {questionTypes: "manual", branching: "unsupported",
      requiredFields: "manual", scoringApproval: "unsupported",
      uploads: "retained"}, fieldMappings: [],
    preview: samplePreview});
  await reviewBlueprint(deps, owner, {requestId: "review-demo-001",
    blueprintId: "blueprint-001", expectedRevision: 1});
}
const intendedBinding = {kind: "email", value: "host@example.invalid"};
async function invite(deps: DemoDeps, binding: unknown = intendedBinding) {
  return issueInvitation(deps, owner, {requestId: "issue-demo-001",
    blueprintId: "blueprint-001", blueprintRevision: 2,
    contactBinding: binding, expiresAt: "2026-09-30T10:00:00.000Z",
    sessionCap: 2});
}
async function rejectsCode(promise: Promise<unknown>, code: string) {
  await assert.rejects(promise, (error: unknown) =>
    error instanceof HttpsError && error.code === code);
}

test("preview is minimal and does not mutate or consume an invitation",
  async () => {
    const {db, deps} = fixture();
    await blueprint(deps);
    const issued = await invite(deps);
    const before = db.writes;
    const first = await getPreview(deps,
      {invitationId: issued.invitationId});
    const second = await getPreview(deps,
      {invitationId: issued.invitationId});
    assert.deepEqual(second, first);
    assert.equal(db.writes, before);
    assert.deepEqual(Object.keys(first).sort(),
      ["expiresAt", "interactiveAvailable", "invitationId", "notice",
        "preview", "schemaVersion", "synthetic"]);
    assert.equal(JSON.stringify(first).includes("host@example.invalid"),
      false);
    assert.equal([...db.docs.keys()].some((key) =>
      key.startsWith("salesDemoSessions/")), false);
  });

test("preview-only invitation cannot start without contact binding",
  async () => {
    const {deps} = fixture();
    await blueprint(deps);
    const issued = await invite(deps, null);
    const preview = await getPreview(deps,
      {invitationId: issued.invitationId});
    assert.equal(preview.interactiveAvailable, false);
    await rejectsCode(startSession(deps, intended,
      {invitationId: issued.invitationId,
        grantToken: issued.grantToken, requestId: "start-demo-001"}),
    "permission-denied");
  });

test("verified intended contact gets one bounded synthetic session",
  async () => {
    const {db, deps} = fixture();
    await blueprint(deps);
    const issued = await invite(deps);
    const input = {invitationId: issued.invitationId,
      grantToken: issued.grantToken, requestId: "start-demo-001"};
    const first = await startSession(deps, intended, input);
    const retry = await startSession(deps, intended, input);
    const doubleClick = await startSession(deps, intended,
      {...input, requestId: "start-demo-002"});
    assert.equal(first.sessionId, retry.sessionId);
    assert.equal(first.sessionId, doubleClick.sessionId);
    assert.equal([...db.docs.keys()].filter((key) =>
      key.startsWith("salesDemoSessions/")).length, 1);
    const sessionId = first.sessionId;
    assert.equal(typeof sessionId, "string");
    let next = await advanceSession(deps, intended, {sessionId,
      grantToken: issued.grantToken, requestId: "review-step-001",
      expectedRevision: 1, action: "reviewApplication", choice: "approve"});
    assert.equal(next.step, "reply");
    assert.deepEqual(await advanceSession(deps, intended, {sessionId,
      grantToken: issued.grantToken, requestId: "review-step-001",
      expectedRevision: 1, action: "reviewApplication", choice: "approve"}),
    next);
    next = await advanceSession(deps, intended, {sessionId,
      grantToken: issued.grantToken, requestId: "reply-step-001",
      expectedRevision: 2, action: "prepareReply", choice: "welcome"});
    assert.equal(next.reply &&
      (next.reply as Record<string, unknown>).status, "prepared");
    next = await advanceSession(deps, intended, {sessionId,
      grantToken: issued.grantToken, requestId: "admit-step-001",
      expectedRevision: 3, action: "admitGuest"});
    assert.equal(next.status, "completed");
    assert.equal(JSON.stringify(next).includes("host@example.invalid"),
      false);
    const forbidden = [...db.docs.keys()].filter((key) =>
      /^(eventRehearsal|organizers|events|bookings|payments|messages|guests)/u
        .test(key));
    assert.deepEqual(forbidden, []);
    const allowed = ["salesDemoBlueprints/", "salesDemoCapabilities/",
      "salesDemoInvitations/", "salesDemoSessions/",
      "salesDemoReceipts/", "adminAuditLogs/"];
    assert.ok([...db.docs.keys()].every((path) =>
      allowed.some((prefix) => path.startsWith(prefix))));
  });

test("completed sessions renew only within the invitation cap",
  async () => {
    const {db, deps} = fixture();
    await blueprint(deps);
    const issued = await invite(deps);
    const complete = async (sessionId: unknown, suffix: string) => {
      await advanceSession(deps, intended, {sessionId,
        grantToken: issued.grantToken, requestId: `review-${suffix}`,
        expectedRevision: 1, action: "reviewApplication",
        choice: "approve"});
      await advanceSession(deps, intended, {sessionId,
        grantToken: issued.grantToken, requestId: `reply-${suffix}`,
        expectedRevision: 2, action: "prepareReply",
        choice: "welcome"});
      await advanceSession(deps, intended, {sessionId,
        grantToken: issued.grantToken, requestId: `admit-${suffix}`,
        expectedRevision: 3, action: "admitGuest"});
    };
    const first = await startSession(deps, intended,
      {invitationId: issued.invitationId,
        grantToken: issued.grantToken, requestId: "start-demo-001"});
    await complete(first.sessionId, "one-001");
    const second = await startSession(deps, intended,
      {invitationId: issued.invitationId,
        grantToken: issued.grantToken, requestId: "start-demo-002"});
    assert.notEqual(second.sessionId, first.sessionId);
    await complete(second.sessionId, "two-002");
    await rejectsCode(startSession(deps, intended,
      {invitationId: issued.invitationId,
        grantToken: issued.grantToken, requestId: "start-demo-003"}),
    "resource-exhausted");
    assert.equal(db.docs.get(`salesDemoInvitations/${issued.invitationId}`)
      ?.sessionCount, 2);
  });

test("needs-info branch prepares a reply without admitting a guest",
  async () => {
    const {deps} = fixture();
    await blueprint(deps);
    const issued = await invite(deps);
    const started = await startSession(deps, intended,
      {invitationId: issued.invitationId,
        grantToken: issued.grantToken, requestId: "start-demo-001"});
    await advanceSession(deps, intended, {sessionId: started.sessionId,
      grantToken: issued.grantToken, requestId: "review-step-001",
      expectedRevision: 1, action: "reviewApplication",
      choice: "needs_info"});
    await rejectsCode(advanceSession(deps, intended,
      {sessionId: started.sessionId, grantToken: issued.grantToken,
        requestId: "reply-step-bad", expectedRevision: 2,
        action: "prepareReply", choice: "welcome"}),
    "failed-precondition");
    const final = await advanceSession(deps, intended,
      {sessionId: started.sessionId, grantToken: issued.grantToken,
        requestId: "reply-step-001", expectedRevision: 2,
        action: "prepareReply", choice: "clarify"});
    assert.equal(final.status, "completed");
    assert.equal((final.guest as Record<string, unknown>).status,
      "not_admitted");
  });

test("cross-account, token, and unverified contact attempts fail",
  async () => {
    const {deps} = fixture();
    await blueprint(deps);
    const issued = await invite(deps);
    const input = {invitationId: issued.invitationId,
      grantToken: issued.grantToken, requestId: "start-demo-001"};
    await rejectsCode(startSession(deps, other, input), "permission-denied");
    await rejectsCode(startSession(deps, intended,
      {...input, grantToken: "x".repeat(43)}), "permission-denied");
    await rejectsCode(startSession(deps, {uid: intended.uid, token: {
      email: "host@example.invalid", email_verified: false}}, input),
    "permission-denied");
    await rejectsCode(startSession(deps, intended,
      {...input, phoneVerified: true}), "invalid-argument");
  });

test("expiry and blueprint revision invalidate preview and trial",
  async () => {
    const {deps, setTime} = fixture();
    await blueprint(deps);
    const issued = await invite(deps);
    setTime("2026-10-01T00:00:00.000Z");
    await rejectsCode(getPreview(deps,
      {invitationId: issued.invitationId}), "permission-denied");
    await rejectsCode(startSession(deps, intended, {invitationId:
      issued.invitationId, grantToken: issued.grantToken,
    requestId: "start-demo-001"}), "permission-denied");
  });

test("trusted capability gate drift invalidates preview and future actions",
  async () => {
    const {db, deps} = fixture();
    await blueprint(deps);
    const issued = await invite(deps);
    const started = await startSession(deps, intended,
      {invitationId: issued.invitationId,
        grantToken: issued.grantToken, requestId: "start-demo-001"});
    const path = "salesDemoCapabilities/synthetic_forms_v1";
    db.put(path, {...db.docs.get(path), revision: "revision-002"});
    await rejectsCode(getPreview(deps,
      {invitationId: issued.invitationId}), "permission-denied");
    await rejectsCode(advanceSession(deps, intended,
      {sessionId: started.sessionId, grantToken: issued.grantToken,
        requestId: "review-step-001", expectedRevision: 1,
        action: "reviewApplication", choice: "approve"}),
    "permission-denied");
    db.docs.delete(path);
    await rejectsCode(getPreview(deps,
      {invitationId: issued.invitationId}), "failed-precondition");
  });

test("editing or withdrawing a reviewed blueprint invalidates invitation",
  async () => {
    const {db, deps} = fixture();
    await blueprint(deps);
    const issued = await invite(deps);
    const gatePath = "salesDemoCapabilities/synthetic_forms_v1";
    db.put(gatePath, {...db.docs.get(gatePath),
      evidenceRevision: "evidence-002"});
    await saveBlueprint(deps, owner, {requestId: "save-demo-002",
      blueprintId: "blueprint-001", expectedRevision: 2,
      organizerId: null, candidateId: "candidate-001",
      opportunityId: null, evidenceRevision: "evidence-002",
      formCapabilityReview: {questionTypes: "manual",
        branching: "unsupported", requiredFields: "manual",
        scoringApproval: "unsupported", uploads: "retained"},
      fieldMappings: [], preview: samplePreview});
    await rejectsCode(getPreview(deps,
      {invitationId: issued.invitationId}), "permission-denied");
    await reviewBlueprint(deps, owner, {requestId: "review-demo-002",
      blueprintId: "blueprint-001", expectedRevision: 3});
    await withdrawBlueprint(deps, owner, {requestId: "withdraw-demo-001",
      blueprintId: "blueprint-001", expectedRevision: 4});
    await rejectsCode(issueInvitation(deps, owner,
      {requestId: "issue-demo-002", blueprintId: "blueprint-001",
        blueprintRevision: 5, contactBinding: null,
        expiresAt: "2026-09-30T10:00:00.000Z", sessionCap: 1}),
    "failed-precondition");
  });

test("verified phone claim must match bound current Auth phone",
  async () => {
    const {deps, users} = fixture();
    await blueprint(deps);
    users.set(intended.uid, {disabled: false,
      phoneNumber: "+15550001111"});
    const issued = await invite(deps,
      {kind: "phone", value: "+15550001111"});
    const input = {invitationId: issued.invitationId,
      grantToken: issued.grantToken, requestId: "start-demo-001"};
    await rejectsCode(startSession(deps, intended, input),
      "permission-denied");
    const phoneIdentity: Identity = {uid: intended.uid,
      token: {phone_number: "+15550001112"}};
    await rejectsCode(startSession(deps, phoneIdentity, input),
      "permission-denied");
    phoneIdentity.token.phone_number = "+15550001111";
    assert.equal((await startSession(deps, phoneIdentity, input)).status,
      "active");
  });

test("revocation during a transaction prevents a trial commit",
  async () => {
    const {db, deps} = fixture();
    await blueprint(deps);
    const issued = await invite(deps);
    const original = deps.getUser;
    let changed = false;
    deps.getUser = async (uid) => {
      if (uid === intended.uid && !changed) {
        changed = true;
        const path = `salesDemoInvitations/${issued.invitationId}`;
        db.put(path, {...db.docs.get(path), revoked: true});
      }
      return original(uid);
    };
    await rejectsCode(startSession(deps, intended,
      {invitationId: issued.invitationId,
        grantToken: issued.grantToken, requestId: "start-demo-001"}),
    "permission-denied");
    assert.equal([...db.docs.keys()].some((path) =>
      path.startsWith("salesDemoSessions/")), false);
  });

test("revocation during a session action prevents its commit",
  async () => {
    const {db, deps} = fixture();
    await blueprint(deps);
    const issued = await invite(deps);
    const started = await startSession(deps, intended,
      {invitationId: issued.invitationId,
        grantToken: issued.grantToken, requestId: "start-demo-001"});
    const original = deps.getUser;
    let changed = false;
    deps.getUser = async (uid) => {
      if (uid === intended.uid && !changed) {
        changed = true;
        const path = `salesDemoInvitations/${issued.invitationId}`;
        db.put(path, {...db.docs.get(path), revoked: true});
      }
      return original(uid);
    };
    await rejectsCode(advanceSession(deps, intended,
      {sessionId: started.sessionId, grantToken: issued.grantToken,
        requestId: "review-step-001", expectedRevision: 1,
        action: "reviewApplication", choice: "approve"}),
    "permission-denied");
    assert.equal(db.docs.get(`salesDemoSessions/${started.sessionId}`)
      ?.revision, 1);
  });

test("revoke and changed blueprint stop downstream session actions",
  async () => {
    const {deps} = fixture();
    await blueprint(deps);
    const issued = await invite(deps);
    const started = await startSession(deps, intended,
      {invitationId: issued.invitationId,
        grantToken: issued.grantToken, requestId: "start-demo-001"});
    await revokeInvitation(deps, owner, {requestId: "revoke-demo-001",
      invitationId: issued.invitationId, expectedRevision: 1});
    await rejectsCode(advanceSession(deps, intended,
      {sessionId: started.sessionId, grantToken: issued.grantToken,
        requestId: "review-step-001", expectedRevision: 1,
        action: "reviewApplication", choice: "approve"}),
    "permission-denied");
    await rejectsCode(getSession(deps, intended,
      {sessionId: started.sessionId, grantToken: issued.grantToken}),
    "permission-denied");
  });

test("unsafe action injection, stale revision, and changed request fail",
  async () => {
    const {deps} = fixture();
    await blueprint(deps);
    const issued = await invite(deps);
    const started = await startSession(deps, intended,
      {invitationId: issued.invitationId,
        grantToken: issued.grantToken, requestId: "start-demo-001"});
    const base = {sessionId: started.sessionId,
      grantToken: issued.grantToken, requestId: "review-step-001",
      expectedRevision: 1};
    await rejectsCode(advanceSession(deps, intended,
      {...base, action: "publish"}), "invalid-argument");
    await rejectsCode(advanceSession(deps, intended,
      {...base, action: "reviewApplication", choice: "approve",
        paymentStatus: "paid"}), "invalid-argument");
    await advanceSession(deps, intended,
      {...base, action: "reviewApplication", choice: "approve"});
    await rejectsCode(advanceSession(deps, intended,
      {...base, action: "reviewApplication", choice: "needs_info"}),
    "already-exists");
    await rejectsCode(advanceSession(deps, intended,
      {...base, requestId: "review-step-002",
        action: "reviewApplication", choice: "approve"}),
    "failed-precondition");
  });

test("management retry returns same grant without persisting token",
  async () => {
    const {db, deps, users} = fixture();
    await blueprint(deps);
    const issued = await invite(deps);
    const revoked = await revokeInvitation(deps, owner,
      {requestId: "revoke-demo-001",
        invitationId: issued.invitationId, expectedRevision: 1});
    const retry = await invite(deps);
    assert.deepEqual(retry, issued);
    assert.equal((await revokeInvitation(deps, owner,
      {requestId: "revoke-demo-001", invitationId: issued.invitationId,
        expectedRevision: 1})).revokedAt, revoked.revokedAt);
    assert.equal(JSON.stringify([...db.docs.values()])
      .includes(String(issued.grantToken)), false);
    assert.equal([...db.docs.keys()].filter((path) =>
      path.startsWith("adminAuditLogs/sales_demo_")).length, 4);
    users.set(owner.uid, {disabled: false, customClaims: {}});
    await rejectsCode(invite(deps), "permission-denied");
  });

test("grant key rotation fails replay instead of returning unusable token",
  async () => {
    const {deps} = fixture();
    await blueprint(deps);
    await invite(deps);
    deps.tokenKey = () => Buffer.alloc(32, 8);
    await rejectsCode(invite(deps), "failed-precondition");
  });

test("persisted demo records satisfy their strict private contracts",
  async () => {
    const {db, deps} = fixture();
    await blueprint(deps);
    const issued = await invite(deps);
    const started = await startSession(deps, intended,
      {invitationId: issued.invitationId,
        grantToken: issued.grantToken, requestId: "start-demo-001"});
    await advanceSession(deps, intended, {sessionId: started.sessionId,
      grantToken: issued.grantToken, requestId: "review-step-001",
      expectedRevision: 1, action: "reviewApplication", choice: "approve"});
    const ajv = new Ajv({allErrors: true, strict: false});
    addFormats(ajv);
    const schemas = new Map([
      ["salesDemoCapabilities", "sales_demo_capabilities"],
      ["salesDemoBlueprints", "sales_demo_blueprints"],
      ["salesDemoInvitations", "sales_demo_invitations"],
      ["salesDemoSessions", "sales_demo_sessions"],
      ["salesDemoReceipts", "sales_demo_receipts"],
    ]);
    for (const [collection, filename] of schemas) {
      const schema = JSON.parse(readFileSync(
        resolve(__dirname, "../../../contracts/firestore",
          `${filename}.schema.json`), "utf8"));
      const validate = ajv.compile(schema);
      const docs = [...db.docs].filter(([path]) =>
        path.startsWith(`${collection}/`));
      assert.ok(docs.length > 0, collection);
      for (const [path, doc] of docs) {
        assert.ok(validate(doc), `${path}: ${JSON.stringify(validate.errors)}`);
      }
    }
  });
