import {seedWorkspaceFieldAssertions} from
  "../workspaces/workspaceFieldFixture";
import assert from "node:assert/strict";
import test from "node:test";
import type {Firestore} from "firebase-admin/firestore";
import {FakeFirestore} from "../shared/testing/programFirestore";
import type {AnchorFacts, MomentAction, MomentDefinition,
  RunRecord} from "../moments/momentModel";
import type {ResolvedRecipient} from "../moments/momentDocuments";
import type {ProgramDeliveryMessageDocument}
  from "../shared/generated/programDeliveryMessageDocument";
import {deliverProgramReminder} from "./programReminderDelivery";

const NOW = 1_000_000;

const moment: MomentDefinition = {
  momentId: "m_reminder",
  scope: {kind: "program", programId: "prog"},
  name: "Travel window opens soon",
  initiation: {kind: "scheduled", atMillis: NOW},
  sense: "audience",
  audience: {kind: "households", rsvpPendingOnly: false},
  action: {kind: "sendTemplate", connectionId: "conn1",
    templateId: "tpl1", variables: {}},
  status: "armed",
  approval: {approvedByUid: "mgr", approvedAtMillis: 1},
  origin: "organizer",
  revision: 3,
};

const run: RunRecord = {
  runId: "m_reminder_run_1",
  momentId: "m_reminder",
  dueAtMillis: NOW,
  anchorRevision: 1,
  status: "planned",
};

const facts: AnchorFacts = {
  scope: {startsAtMillis: NOW + 90 * 86_400_000, endsAtMillis: null,
    rsvpDeadlineAtMillis: null, revision: 1, messagingEnabled: true,
    cancelled: false, organizerId: "org-1"},
  functions: {},
  travelLegs: {},
};

const recipient: ResolvedRecipient = {
  recipientKey: "household:hh1",
  endpoint: {kind: "phone", e164: "+911234567001"},
  householdId: "hh1",
};

const action = moment.action as Extract<MomentAction,
  {kind: "sendTemplate"}>;

function seedProgram(db: FakeFirestore): void {
  db.setDoc("organizerPrograms/prog", {
    organizerId: "org-1", kind: "wedding", title: "Mehta × Rao",
    status: "active", revision: 2,
  });
  db.setDoc("organizerMoments/m_reminder", {...moment});
  db.setDoc("organizerSenderConnections/conn1", {
    organizerId: "org-1", status: "active", phoneNumberId: "2002",
    wabaId: "1001", secretVersionResource: "sec/1", revision: 2,
  });
  db.setDoc("organizerMessageTemplates/tpl1", {
    organizerId: "org-1", status: "APPROVED", name: "reminder",
    language: "en", parameterBindings: [],
  });
  db.setDoc("programHouseholds/hh1", {
    programId: "prog", organizerId: "org-1", label: "Sharma",
    primaryPhoneE164: "+911234567001", memberGuestIds: ["g1"],
    messagingConsent: {granted: true}, revision: 4,
  });
  const acquired = seedWorkspaceFieldAssertions(Object.fromEntries(db.docs));
  for (const [path, doc] of Object.entries(acquired)) db.setDoc(path, doc);
}

function harness(db: FakeFirestore, resolved = recipient) {
  const calls: Array<{toE164: string; phoneNumberId: string}> = [];
  const clock = {now: NOW};
  const provider = {
    sendTemplate: async (p: {toE164: string; phoneNumberId: string}) => {
      calls.push(p);
      return {providerMessageId: "wamid-1"};
    },
  };
  const credentials = {accessBound: async () => "token-1"};
  const deliver = () => deliverProgramReminder({
    db: db as unknown as Firestore,
    provider, credentials, moment, run, facts, recipient: resolved, action,
    now: () => clock.now,
  });
  return {calls, clock, deliver};
}

function record(db: FakeFirestore): ProgramDeliveryMessageDocument {
  const entries = [...db.docs.entries()]
    .filter(([path]) => path.startsWith("programDeliveryMessages/"));
  assert.equal(entries.length, 1);
  return entries[0][1] as unknown as ProgramDeliveryMessageDocument;
}

test("a program reminder reserves, claims, submits and receipts durably",
  async () => {
    const db = new FakeFirestore({});
    seedProgram(db);
    const h = harness(db);
    const outcome = await h.deliver();
    assert.equal(outcome.kind, "sent");
    assert.equal(h.calls.length, 1);
    assert.equal(h.calls[0].toE164, "+911234567001");
    assert.equal(h.calls[0].phoneNumberId, "2002");
    const doc = record(db);
    assert.equal(doc.lifecycle, "active");
    assert.equal(doc.attempts.length, 1);
    const attempt = doc.attempts[0];
    assert.equal(attempt.state.kind, "accepted");
    assert.equal(attempt.binding.routeId, "organizerProgramWhatsapp");
    assert.equal(attempt.authorization.instructionRevision, 3);
    assert.equal(doc.intent.kind, "programReminder");
    assert.equal(doc.intent.recipient.recipientKey, "hh1");
  });

test("a re-fired sweep reconciles the existing attempt, never resends",
  async () => {
    const db = new FakeFirestore({});
    seedProgram(db);
    const h = harness(db);
    await h.deliver();
    // The attempt sits in `accepted` awaiting a delivery receipt; a
    // second fire must wait on reconciliation rather than re-submit.
    const again = await h.deliver();
    assert.equal(again.kind, "retry");
    assert.equal(h.calls.length, 1);
    assert.equal(record(db).attempts.length, 1);
  });

test("consent revoked before claim suppresses without provider I/O",
  async () => {
    const db = new FakeFirestore({});
    seedProgram(db);
    db.updateDoc("programHouseholds/hh1",
      {messagingConsent: {granted: false}});
    const h = harness(db);
    const outcome = await h.deliver();
    assert.equal(outcome.kind, "suppressed");
    assert.equal(h.calls.length, 0);
    assert.equal(record(db).attempts.length, 0);
  });

test("a moment edited after enqueue fences the stale instruction revision",
  async () => {
    const db = new FakeFirestore({});
    seedProgram(db);
    const h = harness(db);
    // The intent freezes the moment's revision at compose time; the live
    // moment doc having moved to revision 4 must fence this dispatch.
    db.setDoc("organizerMoments/m_reminder",
      {...moment, revision: 4});
    const outcome = await h.deliver();
    assert.equal(outcome.kind, "suppressed");
    if (outcome.kind === "suppressed") {
      assert.equal(outcome.reason, "superseded");
    }
    assert.equal(h.calls.length, 0);
  });

test("a post-acceptance interruption leaves an unknown attempt, " +
    "not a resend", async () => {
  const db = new FakeFirestore({});
  seedProgram(db);
  const calls: unknown[] = [];
  const clock = {now: NOW};
  const provider = {
    sendTemplate: async (p: {toE164: string}) => {
      calls.push(p);
      // Worker cannot know whether Meta accepted — a generic error is
      // held as `unknown` for reconciliation, never auto-retried here.
      throw new Error("socket hangup");
    },
  };
  const outcome = await deliverProgramReminder({
    db: db as unknown as Firestore,
    provider, credentials: {accessBound: async () => "token-1"},
    moment, run, facts, recipient, action, now: () => clock.now,
  });
  assert.equal(outcome.kind, "sent");
  assert.equal(calls.length, 1);
  const doc = record(db);
  assert.equal(doc.attempts.length, 1);
  assert.equal(doc.attempts[0].state.kind, "unknown");
});

for (const modification of ["missingAssertion", "foreignScope", "unassigned"]) {
  test(`household phone evidence ${modification} prevents provider I/O`,
    async () => {
      const db = new FakeFirestore({});
      seedProgram(db);
      const selected = (db.getDoc("programHouseholds/hh1")!.fieldSelections as
        {phoneE164: string}).phoneE164;
      if (modification === "missingAssertion") {
        db.deleteDoc(`workspaceFieldAssertions/${selected}`);
      } else if (modification === "foreignScope") {
        db.updateDoc(`workspaceFieldAssertions/${selected}`, {
          workspaceRef: {kind: "program", id: "another-wedding"}});
      } else {
        db.updateDoc("programHouseholds/hh1", {fieldSelections: {}});
      }
      const h = harness(db);
      await h.deliver();
      assert.equal(h.calls.length, 0);
      assert.equal(record(db).attempts.length, 0);
    });
}

test("household evidence cannot authorize an unassigned guest phone",
  async () => {
    const db = new FakeFirestore({});
    seedProgram(db);
    db.setDoc("programGuests/g1", {programId: "prog", organizerId: "org-1",
      householdId: "hh1", phoneE164: "+911234567001"});
    const h = harness(db, {...recipient, recipientKey: "guest:g1"});
    await h.deliver();
    assert.equal(h.calls.length, 0);
  });

for (const change of ["assertionDeleted", "consentRevoked"]) {
  test(`program reminder ${change} between reserve and claim never sends`,
    async () => {
      const db = new FakeFirestore({});
      seedProgram(db);
      let changed = false;
      let sends = 0;
      const outcome = await deliverProgramReminder({
        db: db as unknown as Firestore, moment, run, facts, recipient, action,
        credentials: {accessBound: async () => "synthetic-token"},
        provider: {sendTemplate: async () => {
          sends++;
          return {providerMessageId: "unexpected-send"};
        }},
        now: () => {
          const doc = [...db.docs.entries()].find(([path]) =>
            path.startsWith("programDeliveryMessages/"))?.[1] as
            ProgramDeliveryMessageDocument | undefined;
          if (!changed && doc?.attempts.some((attempt) =>
            attempt.state.kind === "reserved")) {
            changed = true;
            if (change === "consentRevoked") {
              db.updateDoc("programHouseholds/hh1", {
                messagingConsent: {granted: false}});
            } else {
              const id = (db.getDoc("programHouseholds/hh1")!
                .fieldSelections as {phoneE164: string}).phoneE164;
              db.deleteDoc(`workspaceFieldAssertions/${id}`);
            }
          }
          return NOW;
        },
      });
      assert.equal(changed, true);
      assert.equal(sends, 0);
      assert.equal(outcome.kind, "retry");
      assert.equal([...db.docs.keys()].filter((path) =>
        path.startsWith("programWhatsappDispatches/")).length, 0);
    });
}
