import {listSalesInboundIntents} from "../admin/sales/intents";
import type {Timestamp} from "firebase-admin/firestore";
import assert from "node:assert/strict";
import test from "node:test";
import {FakeFirestore} from "../operations/testFirestore";
import {assignPartner, decideAssignment, getPartnerWorkspace, nominateOrganizer,
  registerPartner, revokePartnerAccess, requireAssignment, updateAssignment} from "./service";
import {PARTNER_TERMS_VERSION, type PartnerActor, type PartnerDeps} from "./model";

const partner: PartnerActor = {uid: "partner-one", roles: []};
const employee: PartnerActor = {uid: "employee-one", roles: ["admin"]};
const initial = "2026-10-04T00:00:00.000Z";
function fixture() {
  const fake = new FakeFirestore();
  let now = new Date(initial); let revoked = false;
  const deps: PartnerDeps = {db: fake as unknown as FirebaseFirestore.Firestore,
    now: () => now, checkAuth: async () => {if (revoked) throw new Error("revoked Auth");}};
  fake.write("organizers/organizer-one", {name: "Synthetic organizer", cityName: "Mumbai",
    appVisibility: "hidden", publicPage: {publicationStatus: "draft"}, claim: {state: "unclaimed"}});
  fake.write("organizerSalesAccounts/organizer-one", {schemaVersion: 1,
    classification: "sales_private", organizerId: "organizer-one", researchStatus: "new",
    suppressionStatus: "clear", duplicateReviewRequired: false, summary: "Private employee note"});
  return {fake, deps, advance: (ms: number) => {now = new Date(now.getTime() + ms);},
    revokeAuth: () => {revoked = true;}};
}
const registration = {requestId: "registration-one", displayName: "Prospective collaborator",
  termsVersion: PARTNER_TERMS_VERSION};
const offer = {requestId: "assignment-one", organizerId: "organizer-one",
  partnerUid: "partner-one", expectedRevision: 0, nextAction: "Review introduction fit",
  reviewAt: "2026-10-05T00:00:00.000Z", expiresAt: "2026-10-10T00:00:00.000Z",
  reason: "Reviewed official identity", originatorUid: null};
const accept = {requestId: "acceptance-one", organizerId: "organizer-one",
  expectedRevision: 1, decision: "accept", channel: "whatsapp",
  relationshipContext: "I know the organizer through a prior event."};

test("self-serve membership never grants employee, organizer, or marketing authority", async () => {
  const {fake, deps} = fixture();
  const before = fake.read("organizers/organizer-one");
  await registerPartner(deps, partner, registration);
  assert.deepEqual(await registerPartner(deps, partner, registration), {uid: partner.uid, status: "active", revision: 1});
  assert.deepEqual(fake.read("salesPartnerMemberships/partner-one")?.marketingGrants, []);
  assert.deepEqual(fake.read("organizers/organizer-one"), before);
  await assert.rejects(assignPartner(deps, partner, offer), {code: "permission-denied"});
});

test("nomination is immutable own self-report and cannot assert verified canonical identity", async () => {
  const {fake, deps} = fixture(); await registerPartner(deps, partner, registration);
  const nomination = {requestId: "nomination-one", name: "Synthetic events", city: "Mumbai",
    url: "https://synthetic.example/events", relationshipContext: "We have not met."};
  const result = await nominateOrganizer(deps, partner, nomination);
  assert.equal(result.organizerId, null);
  assert.deepEqual(await nominateOrganizer(deps, partner, nomination), result);
  await assert.rejects(nominateOrganizer(deps, partner, {...nomination, name: "Different"}), {code: "already-exists"});
  await assert.rejects(nominateOrganizer(deps, partner, {...nomination, verifiedAt: initial}), {code: "invalid-argument"});
  const rows = fake.entries().filter(([p]) => p.startsWith("salesInboundIntents/"));
  assert.equal(rows.length, 1); assert.equal(rows[0][1].source, "partner");
  assert.equal(rows[0][1].evidenceStatus, "self_reported"); assert.equal(rows[0][1].organizerId, null);
  assert.equal(fake.entries().filter(([p]) => p.startsWith("organizers/")).length, 1);
});

test("assignment acceptance shares the canonical ID and withholds employee notes", async () => {
  const {fake, deps} = fixture(); await registerPartner(deps, partner, registration);
  const before = fake.read("organizers/organizer-one");
  await assignPartner(deps, employee, offer); await decideAssignment(deps, partner, accept);
  const workspace = await getPartnerWorkspace(deps, partner, {});
  assert.equal((workspace.leads as unknown[]).length, 1);
  assert.ok(!JSON.stringify(workspace).includes("Private employee note"));
  assert.ok(!JSON.stringify(workspace).includes("Reviewed official identity"));
  assert.ok(!JSON.stringify(workspace).includes("employee-one"));
  assert.deepEqual(fake.read("organizers/organizer-one"), before);
  assert.deepEqual(await decideAssignment(deps, partner, accept), {organizerId: "organizer-one", revision: 2, status: "accepted"});
  await assert.rejects(deps.db.runTransaction((tx) => requireAssignment(deps,
    {uid: "partner-two", roles: []}, tx, "organizer-one")), {code: "permission-denied"});
});

test("foreign reservations require explicit resolution rather than first-submission credit", async () => {
  const {deps} = fixture(); await registerPartner(deps, partner, registration);
  await registerPartner(deps, {uid: "partner-two", roles: []}, {...registration, requestId: "registration-two"});
  await assignPartner(deps, employee, offer);
  await assert.rejects(assignPartner(deps, employee, {...offer, requestId: "assignment-two",
    partnerUid: "partner-two", expectedRevision: 1}), {code: "failed-precondition"});
});

test("replay rechecks revocation, suppression, expiry and permanent privacy fence", async () => {
  for (const gate of ["membership", "assignment", "suppression", "expiry", "privacy", "auth"]) {
    const f = fixture(); await registerPartner(f.deps, partner, registration);
    await assignPartner(f.deps, employee, offer); await decideAssignment(f.deps, partner, accept);
    if (gate === "membership") await revokePartnerAccess(f.deps, employee,
      {requestId: "revoke-membership", organizerId: null, partnerUid: partner.uid, expectedRevision: 1, reason: "Access revoked"});
    if (gate === "assignment") await revokePartnerAccess(f.deps, employee,
      {requestId: "revoke-assignment", organizerId: "organizer-one", partnerUid: partner.uid, expectedRevision: 2, reason: "Host preference"});
    if (gate === "suppression") f.fake.write("organizerSalesAccounts/organizer-one",
      {...f.fake.read("organizerSalesAccounts/organizer-one"), suppressionStatus: "suppressed"});
    if (gate === "privacy") f.fake.write("salesPrivacyRestrictions/organizer-one", {status: "restricted"});
    if (gate === "expiry") f.advance(7 * 86400000);
    if (gate === "auth") f.revokeAuth();
    await assert.rejects(decideAssignment(f.deps, partner, accept));
  }
});

test("interrupted transaction does not partially join or reserve; exact retry recovers", async () => {
  const {fake, deps} = fixture(); fake.failNextCommit = true;
  await assert.rejects(registerPartner(deps, partner, registration));
  assert.equal(fake.read("salesPartnerMemberships/partner-one"), undefined);
  await registerPartner(deps, partner, registration);
  fake.failNextCommit = true; await assert.rejects(assignPartner(deps, employee, offer));
  assert.equal(fake.read("salesPartnerAssignments/organizer-one"), undefined);
  await assignPartner(deps, employee, offer);
  assert.equal(fake.read("salesPartnerAssignments/organizer-one")?.revision, 1);
});

test("decline receipt recovers exactly but cannot authorize fresh work or a later reassignment", async () => {
  const {fake, deps} = fixture(); await registerPartner(deps, partner, registration);
  await assignPartner(deps, employee, offer);
  const decline = {...accept, decision: "decline", channel: null};
  const result = await decideAssignment(deps, partner, decline);
  assert.deepEqual(await decideAssignment(deps, partner, decline), result);
  await assert.rejects(decideAssignment(deps, partner, {...decline, requestId: "fresh-decline"}), {code: "permission-denied"});
  fake.write("salesPartnerAssignments/organizer-one", {...fake.read("salesPartnerAssignments/organizer-one"),
    partnerUid: "different-partner", revision: 3, status: "offered"});
  await assert.rejects(decideAssignment(deps, partner, decline), {code: "permission-denied"});
});

test("linked submissions are withheld immediately after organizer privacy restriction", async () => {
  const {fake, deps} = fixture(); await registerPartner(deps, partner, registration);
  fake.write("salesInboundIntents/nomination-one", {partnerUid: partner.uid,
    status: "linked", organizerId: "organizer-one", hostApplication: {organizationName: "Private nominee"}});
  assert.equal((await getPartnerWorkspace(deps, partner, {})).submissions instanceof Array, true);
  fake.write("salesPrivacyRestrictions/organizer-one", {restricted: true});
  assert.deepEqual((await getPartnerWorkspace(deps, partner, {})).submissions, []);
});

test("partner nomination uses Firestore timestamps through the existing employee pagination path", async () => {
  const {deps} = fixture(); await registerPartner(deps, partner, registration);
  const original = deps.db;
  type NominationRow = Record<string, unknown> & {intentId: string;
    createdAt: Timestamp; updatedAt: Timestamp};
  const captured: NominationRow[] = [];
  deps.db = new Proxy(original, {get(target, key) {
    if (key === "runTransaction") return (callback: (tx: FirebaseFirestore.Transaction) => Promise<unknown>) =>
      target.runTransaction((tx) => callback(new Proxy(tx, {get(t, member) {
        if (member === "create") return (ref: FirebaseFirestore.DocumentReference, row: Record<string, unknown>) => {
          if (ref.path.startsWith("salesInboundIntents/")) captured.push(row as NominationRow);
          return t.create(ref, row);
        };
        const value = Reflect.get(t, member); return typeof value === "function" ? value.bind(t) : value;
      }})));
    const value = Reflect.get(target, key); return typeof value === "function" ? value.bind(target) : value;
  }});
  await nominateOrganizer(deps, partner, {requestId: "timestamp-nomination", name: "Synthetic events",
    city: "Mumbai", url: "https://synthetic.example/events", relationshipContext: null});
  const created = captured[0];
  assert.ok(created);
  assert.equal(created.createdAt.toDate().toISOString(), initial);
  assert.equal(created.updatedAt.toDate().toISOString(), initial);
  let cursor: unknown[] = [];
  const document = {id: created.intentId, data: () => created!, get: (key: string) => created![key]};
  const query = {orderBy() {return this;}, limit() {return this;},
    startAfter(...args: unknown[]) {cursor = args; return this;},
    get: async () => ({docs: [document, document], size: 2})};
  const db = {collection: () => query} as unknown as FirebaseFirestore.Firestore;
  const principal: Parameters<typeof listSalesInboundIntents>[1] = {uid: employee.uid, roles: ["admin"]};
  const page = await listSalesInboundIntents(db, principal, {limit: 1});
  assert.equal((page.rows as Array<Record<string, unknown>>)[0].createdAt, initial);
  assert.equal((page.rows as Array<Record<string, unknown>>)[0].source, "partner");
  await listSalesInboundIntents(db, principal, {limit: 1, cursor: page.nextCursor});
  assert.equal((cursor[0] as {toDate(): Date}).toDate().toISOString(), initial);
  assert.equal(cursor[1], created.intentId);
});


test("own accepted lead next steps are versioned self-report without claim, publication or send", async () => {
  const {fake, deps} = fixture(); await registerPartner(deps, partner, registration);
  await assignPartner(deps, employee, offer); await decideAssignment(deps, partner, accept);
  const before = fake.read("organizers/organizer-one");
  const input = {requestId: "next-action-one", organizerId: "organizer-one", expectedRevision: 2,
    relationshipContext: "We have not established a personal relationship.", channel: "email",
    nextAction: "Review the private preparation before considering an introduction.",
    reviewAt: "2026-10-06T00:00:00.000Z"};
  const saved = await updateAssignment(deps, partner, input);
  assert.deepEqual(await updateAssignment(deps, partner, input), saved);
  assert.deepEqual(fake.read("organizers/organizer-one"), before);
  assert.equal(fake.entries().some(([path]) => /^(salesOutreachDrafts|salesActivities|organizerForms)\//u.test(path)), false);
  await assert.rejects(updateAssignment(deps, {uid: "foreign", roles: []}, input), {code: "permission-denied"});
  await assert.rejects(updateAssignment(deps, partner, {...input, nextAction: "Different"}), {code: "already-exists"});
  await assert.rejects(updateAssignment(deps, partner, {...input, requestId: "past-review-one", expectedRevision: 3,
    reviewAt: initial}), {code: "invalid-argument"});
  fake.write("salesPrivacyRestrictions/organizer-one", {status: "restricted"});
  await assert.rejects(updateAssignment(deps, partner, input), {code: "failed-precondition"});
});
