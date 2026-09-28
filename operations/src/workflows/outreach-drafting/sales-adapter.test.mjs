import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import {test} from "node:test";
import {FileOperationsStore} from "../../platform/storage/file-store.mjs";
import {hashValue} from "../../platform/canonical-json.mjs";
import {createSalesOutreachRunner, currentProjection} from "./sales-adapter.mjs";

const at = "2026-09-28T10:00:00.000Z";
function input() {
  return {schemaVersion: 1,
    organizer: {organizerId: "org-1", name: "Example Collective", revision: 2,
      identityStatus: "verified"},
    contact: {contactId: "contact-1", revision: 3, role: "organizer",
      eligibility: "eligible", suppressionStatus: "clear", claimStatus: "not_required"},
    opportunity: {opportunityId: "opp-1", revision: 4,
      stage: "ready_to_contact", motion: "first_pilot"},
    language: "en", channel: "email", purpose: "first_message",
    evaluatedAt: at, evidenceConflictStatus: "clear",
    policy: {promptVersion: "prompt-v1", playbookVersion: "playbook-v1",
      modelId: "disabled"},
    observations: [{id: "obs-1", text: "Your October event has an application step.",
      revision: 1, organizerId: "org-1", approved: true,
      validUntil: "2026-11-01T00:00:00.000Z"}],
    capabilities: [{id: "cap-1", text: "Catch can collect applications for review.",
      revision: 1, organizerId: "org-1", approved: true,
      validUntil: "2026-11-01T00:00:00.000Z"}],
    references: [],
    ctas: [{id: "cta-1", text: "Would a short walkthrough be useful?", revision: 1}],
    priorInteraction: null};
}
async function fixture(t, refresh = (row) => row) {
  const directory = await fs.mkdtemp(path.join(os.tmpdir(), "sales-outreach-"));
  t.after(() => fs.rm(directory, {recursive: true, force: true}));
  const store = await new FileOperationsStore(directory).initialize();
  const bundle = input();
  const saves = [];
  const runner = createSalesOutreachRunner({store,
    source: {prepare: async () => ({bundle, sourceHash: hashValue(bundle)}),
      current: async () => {const current = refresh(structuredClone(bundle));
        return {bundle: current, sourceHash: hashValue(current)};}},
    save: async (value) => {saves.push(value); return value.rendered;},
    clock: () => new Date(at)});
  return {runner, store, bundle, saves};
}

test("trusted Sales adapter runs the existing zero-model workflow and persists exact approved prose", async (t) => {
  const f = await fixture(t);
  const request = {requestId: "request-123", actor: {uid: "employee-1"},
    sourceRequest: {organizerId: "org-1", contactId: "contact-1",
      opportunityId: "opp-1"}};
  const first = await f.runner.run(request);
  assert.equal(first.sendAuthority, false);
  assert.equal(first.draft.sendAuthority, false);
  assert.equal(first.draft.model.modelId, "deterministic");
  assert.equal(first.draft.text, [f.bundle.observations[0].text,
    f.bundle.capabilities[0].text, f.bundle.ctas[0].text].join("\n\n"));
  assert.equal(f.saves.length, 1);
  const replay = await f.runner.run(request);
  assert.equal(replay.idempotentReplay, true);
  assert.equal(replay.draft.draftId, first.draft.draftId);
  assert.equal((await f.store.listRuns()).length, 1);
});

test("current-source drift or suppression blocks Operations before a draft is saved", async (t) => {
  for (const change of [
    (row) => {row.capabilities[0].revision += 1; return row;},
    (row) => {row.contact.suppressionStatus = "suppressed"; return row;},
    (row) => {row.opportunity.stage = "closed_lost"; return row;},
  ]) {
    const f = await fixture(t, change);
    await assert.rejects(f.runner.run({requestId: "request-123",
      actor: {uid: "employee-1"}, sourceRequest: {organizerId: "org-1",
        contactId: "contact-1", opportunityId: "opp-1"}}));
    assert.equal(f.saves.length, 0);
  }
});

test("projection carries only frozen ids, revisions and current eligibility", () => {
  const current = currentProjection(input());
  assert.equal(current.approvedClauseRevisions["obs-1"], 1);
  assert.deepEqual(current.permittedReferenceIds, []);
  assert.equal(current.contactEligible, true);
  assert.equal(current.suppressed, false);
  assert.equal("email" in current, false);
});
