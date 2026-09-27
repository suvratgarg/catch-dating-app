const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const test = require("node:test");
const Ajv = require("ajv");
const addFormats = require("ajv-formats");

const schemas = path.resolve(__dirname, "../../contracts/firestore");
const ajv = new Ajv({allErrors: true, strict: false});
addFormats(ajv);
const validators = new Map();
const at = "2026-09-28T10:00:00.000Z";
const hash = "a".repeat(64);
const base = {schemaVersion: 1, classification: "sales_private"};
const account = {
  ...base, organizerId: "org-1", revision: 1, researchStatus: "new",
  assignedOwnerUid: "employee-1", summary: null, nextAction: null,
  suppressionStatus: "clear", suppressionReason: null,
  suppressionAt: null, suppressionBy: null,
  duplicateReviewRequired: false, qualificationPolicy: null,
  name: "Sample Host", city: "Sample City", market: "market-1",
  marketLabel: null, eventTypes: [], cohortIds: [],
  searchTokens: ["sample", "host"], createdAt: at,
  updatedAt: at, updatedBy: "employee-1",
};
const relationship = {
  ...base, relationshipId: "relationship-1", contactId: "contact-1",
  organizerId: "org-1", revision: 1, role: "Operations lead",
  decisionInfluence: "operator", primary: true,
  contactabilityStatus: "unknown", contactabilityReason: null,
  contactabilityAt: null, contactabilityBy: null,
  draftReviewEvidenceId: null, sendAuthority: false, endpoints: [{
    kind: "email", value: "contact@example.invalid",
    verificationStatus: "unverified",
  }], createdAt: at, updatedAt: at, updatedBy: "employee-1",
};
const evidence = {
  ...base, evidenceId: "evidence-1", organizerId: "org-1",
  contactId: null, claimKey: "other", signalId: null,
  sourceType: "human_note", sourceRef: "sample-source-1",
  observedAt: at, validThrough: null, confidence: "medium",
  normalizedValue: null, excerpt: "Sample source text",
  reviewedAt: at, reviewerUid: "employee-1", createdAt: at,
  createdBy: "employee-1",
};
const task = {
  ...base, taskId: "task-1", organizerId: "org-1", contactId: null,
  revision: 1, kind: "research", title: "Review sample host",
  dueAt: null, ownerUid: "employee-1", status: "open",
  createdAt: at, updatedAt: at, updatedBy: "employee-1",
};
const opportunity = {
  ...base, opportunityId: "opportunity-1", organizerId: "org-1",
  revision: 1, motion: "Sample motion", stage: "new_enquiry",
  ownerUid: "employee-1", nextStep: null, nextStepAt: null,
  stageEnteredAt: at, createdAt: at, updatedAt: at,
  updatedBy: "employee-1",
};
const activity = {
  ...base, activityId: "activity-1", organizerId: "org-1",
  opportunityId: null, type: "note", channel: null,
  outcome: null, providerConfirmed: false,
  occurredAt: at, recordedAt: at, note: "Synthetic review note",
  actorUid: "employee-1",
};
const field = {
  ...base, fieldId: "sales.sample", label: "Sample field",
  normalizedLabel: "sample field", type: "string", recordType: "account",
  helpText: null, enumOptions: [], revision: 1,
  createdAt: at, createdBy: "employee-1",
};
const lineage = {
  ...base, importId: "import-1", sourceId: "sample-source",
  sourceRowId: "row-1", sourceContentHash: hash,
  mappingVersion: "mapping-1", organizerId: "org-1",
  disposition: "created", reason: "new_private_account",
  originalScore: {"Legacy fit": 4},
  originalCells: [{column: "Old note", value: "Sample value"}],
  originalResearchStatus: "new", originalSummary: null,
  importedAt: at, importedBy: "employee-1",
};
const fixtures = {
  organizer_sales_accounts: account,
  sales_contacts: {
    ...base, contactId: "contact-1", displayName: "Sample Person",
    revision: 1, createdAt: at, updatedAt: at,
    createdBy: "employee-1",
  },
  sales_contact_relationships: relationship,
  sales_evidence: evidence,
  sales_tasks: task,
  sales_opportunities: opportunity,
  sales_activities: activity,
  sales_custom_fields: field,
  sales_custom_field_values: {
    ...base, organizerId: "org-1", fieldId: "sales.sample",
    value: "Sample value", revision: 1,
    updatedAt: at, updatedBy: "employee-1",
  },
  sales_action_receipts: {
    ...base, requestId: "request-1", requestHash: hash,
    action: "hosts.create", actorUid: "employee-1",
    clientId: null, clientAuthUid: null, delegationId: null,
    organizerId: "org-1", createdAt: at,
    result: {account, receipt: {requestId: "request-1", revision: 1}},
  },
  sales_import_jobs: {
    ...base, importId: "import-1", sourceId: "sample-source",
    contentHash: hash, mappingVersion: "mapping-1", previewHash: hash,
    rowCount: 1, counts: {created: 1, matched: 0, duplicate: 0,
      unresolved: 0, rejected: 0}, status: "applied",
    createdAt: at, createdBy: "employee-1",
  },
  sales_import_rows: lineage,
  sales_import_job_rows: lineage,
  sales_settings: {
    ...base, normalizedLabels: ["sample field"], updatedAt: at,
  },
  sales_suppression_decisions: {
    ...base, decisionId: "suppression-1", targetType: "account",
    organizerId: "org-1", contactId: null, previousStatus: "clear",
    status: "held", reason: "Needs human review", actorUid: "employee-1",
    recordedAt: at, accountRevision: 2,
  },
};

function validator(name) {
  if (validators.has(name)) return validators.get(name);
  const source = JSON.parse(fs.readFileSync(
    path.join(schemas, `${name}.schema.json`), "utf8"));
  const compiled = ajv.compile(source);
  validators.set(name, compiled);
  return compiled;
}

test("all private Sales persisted shapes accept source-backed synthetic writes", () => {
  for (const [name, value] of Object.entries(fixtures)) {
    const validate = validator(name);
    assert.equal(validate(value), true, `${name}: ${ajv.errorsText(validate.errors)}`);
  }
});

test("stored documents reject public classification and undocumented side effects", () => {
  for (const [name, value] of Object.entries(fixtures)) {
    const validate = validator(name);
    assert.equal(validate({...value, classification: "public"}), false, name);
    assert.equal(validate({...value, sendNow: true}), false, name);
  }
});

test("claim activity source is mandatory and unavailable on staff activity", () => {
  const validate = validator("sales_activities");
  const claim = {...activity, type: "claim_requested", source: {
    kind: "organizer_claim", claimRequestId: "claim-1",
    transitionId: "claim-1:requested",
  }};
  assert.equal(validate(claim), true, ajv.errorsText(validate.errors));
  assert.equal(validate({...claim, source: undefined}), false);
  assert.equal(validate({...activity, source: claim.source}), false);
  assert.equal(validate({...activity, type: "outreach_sent_manual"}), false);
  assert.equal(validate({...activity, type: "outreach_sent_manual",
    channel: "email", outcome: "actor_attested_sent"}), true);
});

test("draft review cannot imply send authority or omit evidence", () => {
  const validate = validator("sales_contact_relationships");
  assert.equal(validate({...relationship, contactabilityStatus: "draft_reviewed",
    draftReviewEvidenceId: "evidence-1"}), true);
  assert.equal(validate({...relationship, contactabilityStatus: "draft_reviewed"}), false);
  assert.equal(validate({...relationship, sendAuthority: true}), false);
});

test("import lineage retains bounded original cells", () => {
  const validate = validator("sales_import_rows");
  assert.equal(validate(lineage), true);
  assert.equal(validate({...lineage, originalCells: Array(61).fill({
    column: "Column", value: "x",
  })}), false);
  assert.equal(validate({...lineage, originalScore: {"Legacy fit": {
    unsafe: true,
  }}}), false);
});

test("runtime qualification settings accept only bounded generic rules", () => {
  const validate = validator("sales_settings");
  const policy = {...base, status: "active", policyId: "sample-policy",
    version: "v1", policyHash: hash, rules: [{
      ruleId: "sample-rule", claimKey: "other", sourceTypes: ["human_note"],
      confidence: ["medium"], minimumCount: 1,
      distinctSignalIds: false, distinctSourceRoots: false,
      maxAgeDays: null,
    }]};
  assert.equal(validate(policy), true, ajv.errorsText(validate.errors));
  assert.equal(validate({...policy, normalizedLabels: []}), false);
  assert.equal(validate({...policy, rules: []}), false);
});

test("new proposal actions remain inside persisted receipt and delegation contracts", () => {
  for (const action of ["evidence.propose", "evidence.reviewProposal"]) {
    const validate = validator("sales_action_receipts");
    assert.equal(validate({...fixtures.sales_action_receipts, action}), true,
      ajv.errorsText(validate.errors));
  }
  const schema = JSON.parse(fs.readFileSync(path.join(schemas,
    "assistant_delegations.schema.json"), "utf8"));
  assert.ok(schema.properties.allowedActions.items.enum.includes("evidence.propose"));
  assert.ok(!schema.properties.allowedActions.items.enum.includes("evidence.add"));
  assert.ok(!schema.properties.allowedActions.items.enum.includes("evidence.reviewProposal"));
});
