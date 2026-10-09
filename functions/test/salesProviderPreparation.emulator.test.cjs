"use strict";
const assert = require("node:assert/strict");
const {before, after, test: nodeTest} = require("node:test");
const admin = require("firebase-admin");
const {getEmulatorFirestore} = require("../lib/shared/testing/emulatorFirestore");
const {createSalesWritingPreparationWorker} = require("../lib/admin/salesIntelligence/providerRuntime");
const {providerAttemptId, providerBudgetIds, reserveProviderAttempt,
  completeProviderAttempt} = require("../lib/admin/salesIntelligence/providerAttempt");
const {validateSalesProviderAttemptDocument} = require("../lib/shared/generated/validators/salesProviderAttemptDocument");
const {claimDraftJob, claimPartnerDraftJob} = require("../lib/admin/salesIntelligence/job");
const {hash, parsePolicy} = require("../lib/admin/salesIntelligence/model");
const {qualificationPolicyHash} = require("../lib/admin/sales/qualificationPolicy");
const {salesRelationshipId} = require("../lib/admin/sales/records");
const {PARTNER_TERMS_VERSION} = require("../lib/partners/model");
const {inventorySalesOrganizer, firestoreInventoryPort} = require("../lib/admin/salesPrivacy/inventory");
const {restrictSalesOrganizer, reviewSalesPrivacyPolicy, previewSalesPrivacyPlan,
  reviewSalesPrivacyPlan, applySalesPrivacyBatch} = require("../lib/admin/salesPrivacy/service");
const enabled = Boolean(process.env.FIRESTORE_EMULATOR_HOST);
const test = (name, fn) => nodeTest(name, {skip: !enabled}, fn);
let app, db, serial = 0;
const at = "2026-10-07T20:00:00.000Z";
const later = "2026-11-02T00:00:00.000Z";
const limits = {modelCalls: 1, networkRequests: 1, modelInputTokens: 1000,
  modelOutputTokens: 64, modelCostMicros: 1000};
const wireSelection = {observationAlias: "option_0", capabilityAlias: "option_1",
  referenceAlias: null, ctaAlias: "option_2", reasonToBlock: null, omittedAliases: []};
before(() => {
  if (!enabled) return;
  app = admin.initializeApp({projectId: "demo-catch-provider-writing"}, "provider-writing-integration");
  db = getEmulatorFirestore(app);
});
after(async () => { await app?.delete(); });
function response(provider, output = wireSelection, usage = true) {
  const text = JSON.stringify(output);
  if (provider === "deepseek") return new Response(JSON.stringify({id: "synthetic_native",
    model: "deepseek-flash", choices: [{index: 0, finish_reason: "stop",
      message: {role: "assistant", content: text}}], ...(usage ? {usage: {
      prompt_tokens: 12, completion_tokens: 3, total_tokens: 15,
      prompt_cache_hit_tokens: 4, prompt_cache_miss_tokens: 8}} : {})}));
  if (provider === "openai") return new Response(JSON.stringify({id: "resp_synthetic",
    object: "response", model: "gpt-4.1-mini-2025-04-14", status: "completed",
    output: [{type: "message", role: "assistant", status: "completed",
      content: [{type: "output_text", text}]}], usage: {input_tokens: 12,
      output_tokens: 3, total_tokens: 15, input_tokens_details: {cached_tokens: 4},
      output_tokens_details: {reasoning_tokens: 0}}}));
  return new Response(JSON.stringify({id: "msg_synthetic", type: "message", role: "assistant",
    model: "claude-haiku-4-5-20251001",
    stop_reason: "end_turn", content: [{type: "text", text}], usage: {input_tokens: 8,
      cache_read_input_tokens: 3, cache_creation_input_tokens: 1, output_tokens: 3}}));
}
async function fixture({provider = "deepseek", billing, monthly = limits, participant = false, start = at} = {}) {
  const tag = `p${++serial}`;
  const organizerId = `org-${tag}`, uid = `worker-${tag}`;
  const ids = {observation: `observation-${tag}`, capability: `capability-${tag}`, cta: `cta-${tag}`};
  const actor = participant ? {uid, roles: []} : {uid, roles: ["salesStaff"], organizerIds: [organizerId]};
  let time = new Date(start), calls = 0, secrets = 0;
  const now = () => new Date(time);
  const qualification = {policyId: "synthetic-qualified", version: "v1", rules: [{ruleId: "identity-rule",
    claimKey: "identity", sourceTypes: ["first_party"], confidence: ["high"], minimumCount: 1,
    distinctSignalIds: false, distinctSourceRoots: false, maxAgeDays: 30}]};
  const qualified = {...qualification, policyHash: qualificationPolicyHash(qualification)};
  const intel = parsePolicy({policyId: "synthetic-intelligence", version: "v1", status: "active",
    promptVersion: "prompt-v1", playbookVersion: "playbook-v1", priorityBands: {high: 80, medium: 50},
    factors: ["a", "b", "c", "d", "e", "f", "g"].map((id, i) => ({id,
      weight: i === 6 ? 16 : 14, claimKeys: ["identity"], maxAgeDays: 30}))});
  const values = {
    "salesSettings/qualificationPolicy": {schemaVersion: 1, classification: "sales_private", status: "active", ...qualified},
    "salesIntelligencePolicies/current": {schemaVersion: 1, classification: "sales_private", policyRecordId: "current",
      ...intel, revision: 1, updatedAt: at, updatedBy: "owner-synthetic"},
    [`adminUsers/${uid}`]: {roles: actor.roles, active: true},
    [`organizers/${organizerId}`]: {name: "Synthetic host", appVisibility: "hidden"},
    [`organizerSalesAccounts/${organizerId}`]: {classification: "sales_private", organizerId,
      revision: 2, name: `PRIVATE-NAME-${tag}`, assignedOwnerUid: uid,
      suppressionStatus: "clear", duplicateReviewRequired: false, researchStatus: "qualified",
      qualificationPolicy: {policyId: qualified.policyId, version: qualified.version, policyHash: qualified.policyHash}},
    [`salesContacts/contact-${tag}`]: {classification: "sales_private", contactId: `contact-${tag}`, revision: 1},
    [`salesContactRelationships/${salesRelationshipId(organizerId, `contact-${tag}`)}`]: {
      classification: "sales_private", organizerId, contactId: `contact-${tag}`, revision: 3,
      role: `PRIVATE-ROLE-${tag}`, contactabilityStatus: "draft_reviewed", draftReviewEvidenceId: `contact-evidence-${tag}`},
    [`salesOpportunities/opportunity-${tag}`]: {classification: "sales_private", organizerId,
      opportunityId: `opportunity-${tag}`, revision: 4, stage: "ready_to_contact", motion: "first_pilot"},
  };
  for (const [prefix, claimKey] of [["identity", "identity"], ["observation", "operation"],
    ["capability", "operation"], ["contact", "identity"]]) {
    const evidenceId = `${prefix}-evidence-${tag}`;
    values[`salesEvidence/${evidenceId}`] = {classification: "sales_private", evidenceId, organizerId,
      ...(prefix === "contact" ? {contactId: `contact-${tag}`} : {}), claimKey,
      sourceType: "first_party", confidence: "high", sourceRef: "synthetic-only",
      observedAt: at, validThrough: later, reviewedAt: at, reviewerUid: "owner-synthetic"};
  }
  const publicClauses = [];
  for (const [kind, text] of [["observation", "Synthetic public events use applications."],
    ["capability", "Synthetic public capability supports reviewed applications."], ["cta", "Review a synthetic walkthrough?"]]) {
    const clauseId = ids[kind];
    publicClauses.push({dataClassification: "reviewed_public", approved: true, kind, id: clauseId, text});
    values[`salesIntelligenceClauses/${clauseId}`] = {schemaVersion: 1, classification: "sales_private",
      clauseId, organizerId, revision: 1, kind, text, state: "approved",
      evidenceIds: kind === "cta" ? [] : [`${kind}-evidence-${tag}`], validUntil: later,
      permission: "not_required", reviewedAt: at, reviewedBy: "owner-synthetic", updatedAt: at, updatedBy: "owner-synthetic"};
  }
  const modelId = {deepseek: "deepseek-flash", openai: "gpt-4.1-mini-2025-04-14",
    anthropic: "claude-haiku-4-5-20251001"}[provider];
  const policy = {schemaVersion: 1, revision: 1,
    research: {executionMode: "deterministic", providerId: null, modelId: null, billingSourceId: null,
      promptVersion: "research-v1", prompt: "Synthetic disabled research.", budget: Object.fromEntries(Object.keys(limits).map(k => [k, 0])), fallback: "disabled"},
    writing: {executionMode: "api", providerId: provider, modelId, billingSourceId: billing ?? `billing-${tag}`,
      promptVersion: "writing-v1", prompt: "Select only supplied reviewed public options as JSON.", budget: limits, fallback: "disabled"}};
  const authorityPath = `salesSettings/synthetic-writing-${tag}`;
  values[authorityPath] = {policy, ownerUid: "owner-synthetic", activation: {status: "active",
    ownerUid: "owner-synthetic", stage: "writing", policyHash: hash(policy), stageHash: hash(policy.writing),
    billingSourceId: policy.writing.billingSourceId, authorizationId: `authorization-${tag}`, expiresAt: later},
    monthlyLimits: monthly, monthlyLimitsVersion: "monthly-v1", inputTokenCeiling: 1000,
    publicReview: {reviewId: `public-review-${tag}`, reviewedByUid: "owner-synthetic", expiresAt: later,
      dataClassification: "reviewed_public", promptHash: hash(policy.writing.prompt), clauses: publicClauses}};
  if (participant) {
    values[`salesPartnerMemberships/${uid}`] = {schemaVersion: 1, classification: "sales_private",
      uid, status: "active", termsVersion: PARTNER_TERMS_VERSION, expiresAt: later};
    values[`salesPartnerAssignments/${organizerId}`] = {schemaVersion: 1, classification: "sales_private",
      organizerId, partnerUid: uid, revision: 2, status: "accepted", expiresAt: later};
  }
  const batch = db.batch();
  for (const [key, value] of Object.entries(values)) batch.set(db.doc(key), value);
  await batch.commit();
  const authorize = async () => {
    const row = (await db.doc(`adminUsers/${uid}`).get()).data();
    if (!row?.active || (!participant && !row.roles.includes("salesStaff"))) {
      const error = new Error("Synthetic private revoked detail"); error.code = "permission-denied"; throw error;
    }
  };
  const deps = participant ? {db, now, checkAuth: authorize} : {db, now, authorize};
  const sourceRequest = {organizerId, contactId: `contact-${tag}`, opportunityId: `opportunity-${tag}`,
    observationIds: [ids.observation], capabilityIds: [ids.capability], referenceIds: [], ctaIds: [ids.cta],
    channel: "email", purpose: "first_message"};
  const payload = {requestId: `synthetic-writing-request-${tag}`, sourceRequest,
    ...(participant ? {expectedAssignmentRevision: 2} : {})};
  const claim = () => participant ? claimPartnerDraftJob(deps, actor, payload) : claimDraftJob(deps, actor, payload);
  let job = (await claim()).job;
  const makeOptions = ({database = db, transport, resolver, timeoutMs = 8000, actorOverride = actor} = {}) => ({enabled: true,
    access: participant ? {kind: "participant", actor: actorOverride, deps: {...deps, db: database}, expectedAssignmentRevision: 2} :
      {kind: "employee", actor: actorOverride, deps: {...deps, db: database}},
    authority: {read: async (tx) => {
      // This synthetic trusted source makes Auth changes part of the tx read set.
      const auth = (await tx.get(db.doc(`adminUsers/${uid}`))).data();
      if (!auth?.active) {const error = new Error("Synthetic private detail"); error.code = "permission-denied"; throw error;}
      return (await tx.get(db.doc(authorityPath))).data();
    }},
    provider: {serverSecretRef: "synthetic/credential-fixture", timeoutMs,
      resolveSecret: async (ref, options) => {secrets++; return resolver ? resolver(ref, options) : "synthetic-not-a-key";},
      transport: async (url, input) => {
        calls++;
        const body = String(input.body);
        for (const forbidden of [organizerId, uid, `PRIVATE-NAME-${tag}`, `PRIVATE-ROLE-${tag}`,
          ...Object.values(ids), sourceRequest.contactId, sourceRequest.opportunityId]) assert.equal(body.includes(forbidden), false);
        assert.equal(input.redirect, "error");
        return transport ? transport(url, input) : response(provider);
      }},
  });
  return {tag, actor, organizerId, authorityPath, deps, ids, policy,
    request: () => ({jobId: job.jobId, leaseOwner: job.leaseOwner}),
    options: makeOptions, run: (overrides, extra = {}) => createSalesWritingPreparationWorker(makeOptions(overrides)).run({...extra, jobId: job.jobId, leaseOwner: job.leaseOwner}),
    attempt: async () => (await db.doc(`salesProviderAttempts/${providerAttemptId(job.jobId)}`).get()).data(),
    budgets: async () => (await db.collection("salesProviderBudgets").get()).docs.map(x => x.data()),
    calls: () => calls, secrets: () => secrets,
    advance: (iso) => {time = new Date(iso);},
    renew: async () => {job = (await claim()).job;},
    job: () => job,
    restore: async () => {
      const batch = db.batch();
      for (const [path, value] of Object.entries(values)) batch.set(db.doc(path), value);
      await batch.commit();
    },
  };
}
function crashDatabase(mode) {
  let crashed = false;
  return new Proxy(db, {get(target, key) {
    if (key !== "runTransaction") return typeof target[key] === "function" ? target[key].bind(target) : target[key];
    return async (callback) => {
      let intent = false, completion = false;
      const result = await target.runTransaction(async tx => callback(new Proxy(tx, {get(original, method) {
        if (method !== "create" && method !== "set") return typeof original[method] === "function" ? original[method].bind(original) : original[method];
        return (ref, data) => {
          if (ref.path.startsWith("salesProviderAttempts/")) {
            intent = data.status === "intent";
            completion = data.status === "completed";
            if (!crashed && ((mode === "before-intent" && intent) || (mode === "before-completion" && completion))) {
              crashed = true; throw new Error("Synthetic private crash before commit");
            }
          }
          return original[method](ref, data);
        };
      }})));
      if (!crashed && ((mode === "after-intent" && intent) || (mode === "after-completion" && completion))) {
        crashed = true; throw new Error("Synthetic private crash after commit");
      }
      return result;
    };
  }});
}

function abortDuringBudgetRead(controller, shouldAbort) {
  let fired = false;
  return new Proxy(db, {get(target, key) {
    if (key !== "runTransaction") return typeof target[key] === "function" ? target[key].bind(target) : target[key];
    return callback => target.runTransaction(tx => callback(new Proxy(tx, {get(original, method) {
      if (method !== "get") return typeof original[method] === "function" ? original[method].bind(original) : original[method];
      return async ref => {
        const snapshot = await original.get(ref);
        if (!fired && typeof ref.path === "string" && ref.path.startsWith("salesProviderBudgets/") && shouldAbort()) {
          fired = true;
          controller.abort("SYNTHETIC-PRIVATE-TRANSACTION-CANCEL");
        }
        return snapshot;
      };
    }})));
  }});
}

test("compiled native adapters persist canonical selections and replay without spending", async () => {
  for (const provider of ["deepseek", "openai", "anthropic"]) {
    const f = await fixture({provider});
    const first = await f.run({resolver: async () => {
      const intent = await f.attempt(); assert.equal(intent.status, "intent");
      for (const bucketId of [intent.runBucketId, intent.monthlyBucketId]) {
        assert.deepEqual((await db.doc(`salesProviderBudgets/${bucketId}`).get()).data().consumed, limits);
      }
      return "synthetic-not-a-key";
    }});
    assert.equal(first.cacheHit, false); assert.equal(first.preparation.sendAuthority, false);
    assert.equal(first.preparation.selection.observationId, f.ids.observation);
    assert.equal(first.preparation.selection.organizerId, f.organizerId);
    assert.equal(first.metadata.providerId, provider); assert.equal(first.metadata.costBasis, "reserved_ceiling");
    assert.deepEqual(first.usage, {inputTokens: 12, outputTokens: 3, costMicros: 1000});
    const row = await f.attempt();
    assert.equal(row.status, "completed");
    for (const bucketId of [row.runBucketId, row.monthlyBucketId]) {
      assert.deepEqual((await db.doc(`salesProviderBudgets/${bucketId}`).get()).data().consumed,
        {modelCalls: 1, networkRequests: 1, modelInputTokens: 12, modelOutputTokens: 3, modelCostMicros: 1000});
    }
    const replay = await f.run();
    assert.equal(replay.cacheHit, true); assert.deepEqual(replay.preparation, first.preparation);
    assert.equal(f.calls(), 1); assert.equal(f.secrets(), 1);
    assert.equal((await db.doc(`salesOutreachJobs/${f.job().jobId}`).get()).data().status, "running");
  }
});

test("concurrent workers create one paid intent and one reservation", async () => {
  const f = await fixture();
  const results = await Promise.allSettled([f.run(), f.run(), f.run()]);
  assert.ok(results.some(x => x.status === "fulfilled"));
  assert.equal(f.calls(), 1); assert.equal(f.secrets(), 1);
  const row = await f.attempt();
  assert.equal((await db.doc(`salesProviderBudgets/${row.monthlyBucketId}`).get()).data().consumed.modelCalls, 1);
});

test("concurrent distinct jobs share one monthly ceiling without partial run reservation", async () => {
  const one = await fixture({billing: "synthetic-shared-cap"});
  const two = await fixture({billing: "synthetic-shared-cap"});
  const results = await Promise.allSettled([one.run(), two.run()]);
  assert.equal(results.filter(x => x.status === "fulfilled").length, 1);
  assert.equal(one.calls() + two.calls(), 1);
  const loser = results[0].status === "rejected" ? one : two;
  assert.equal(await loser.attempt(), undefined);
  assert.equal((await db.doc(`salesProviderBudgets/provider-run-${hash([loser.job().jobId, "writing"]).slice(0, 40)}`).get()).exists, false);
});

test("known pre-intent crash permits one later call; uncertain intent commit blocks restart", async () => {
  const before = await fixture();
  await assert.rejects(before.run({database: crashDatabase("before-intent")}));
  assert.equal(await before.attempt(), undefined); assert.equal(before.calls(), 0);
  await before.run(); assert.equal(before.calls(), 1);
  const after = await fixture();
  await assert.rejects(after.run({database: crashDatabase("after-intent")}));
  assert.equal((await after.attempt()).status, "intent"); assert.equal(after.calls(), 0);
  await assert.rejects(after.run()); assert.equal(after.calls(), 0);
});

test("crash around completion retains intent or replays committed receipt without another call", async () => {
  for (const mode of ["before-completion", "after-completion"]) {
    const f = await fixture();
    await assert.rejects(f.run({database: crashDatabase(mode)}));
    const row = await f.attempt();
    assert.equal(row.status, mode === "before-completion" ? "intent" : "completed");
    if (mode === "before-completion") {
      await assert.rejects(f.run()); assert.equal(row.result, null);
      assert.equal((await db.doc(`salesProviderBudgets/${row.monthlyBucketId}`).get()).data().consumed.modelInputTokens, 1000);
    } else assert.equal((await f.run()).cacheHit, true);
    assert.equal(f.calls(), 1);
  }
});

test("lease renewal and source/policy drift cannot create another identity after unknown outcome", async () => {
  const f = await fixture();
  await assert.rejects(f.run({transport: async () => {throw new Error("SYNTHETIC-PRIVATE-RAW-ERROR");}}),
    error => !JSON.stringify(error).includes("SYNTHETIC-PRIVATE-RAW-ERROR"));
  const original = await f.attempt();
  f.advance("2026-10-07T20:01:01.000Z"); await f.renew();
  await assert.rejects(f.run()); assert.equal(f.calls(), 1);
  assert.equal((await f.attempt()).attemptId, original.attemptId);
  const grant = (await db.doc(f.authorityPath).get()).data();
  grant.policy.revision++; grant.activation.policyHash = hash(grant.policy);
  await db.doc(f.authorityPath).set(grant);
  await assert.rejects(f.run()); assert.equal(f.calls(), 1);
});

test("role, assignment, source and public review changes prevent paid calls and cached replay", async () => {
  for (const change of ["role", "assignment", "source", "public"]) {
    const f = await fixture(); await f.run();
    if (change === "role") await db.doc(`adminUsers/${f.actor.uid}`).update({active: false});
    if (change === "assignment") await db.doc(`organizerSalesAccounts/${f.organizerId}`).update({assignedOwnerUid: "other-worker"});
    if (change === "source") await db.doc(`salesIntelligenceClauses/${f.ids.observation}`).update({revision: 2});
    if (change === "public") await db.doc(f.authorityPath).update({"publicReview.dataClassification": "sales_private"});
    await assert.rejects(f.run()); assert.equal(f.calls(), 1);
  }
  const cross = await fixture();
  await assert.rejects(cross.run({actorOverride: {...cross.actor, uid: "other-worker"}}));
  assert.equal(cross.calls(), 0);
});

test("participant preparation uses own current assignment and does not borrow employee access", async () => {
  const f = await fixture({participant: true});
  const result = await f.run(); assert.equal(result.preparation.selection.organizerId, f.organizerId);
  await db.doc(`salesPartnerAssignments/${f.organizerId}`).update({revision: 3});
  await assert.rejects(f.run()); assert.equal(f.calls(), 1);
  const staff = await fixture();
  const wrong = staff.options(); wrong.access.kind = "participant";
  wrong.access.expectedAssignmentRevision = 2;
  await assert.rejects(createSalesWritingPreparationWorker(wrong).run(staff.request()));
  assert.equal(staff.calls(), 0);
});

test("revocation or month rollover after provider output blocks publication and retains ceilings", async () => {
  for (const change of ["revoke", "month"]) {
    const f = await fixture({start: change === "month" ? "2026-10-31T23:59:59.000Z" : at});
    await assert.rejects(f.run({transport: async () => {
      if (change === "revoke") await db.doc(`adminUsers/${f.actor.uid}`).update({active: false});
      else f.advance("2026-11-01T00:00:00.000Z");
      return response("deepseek");
    }}));
    const row = await f.attempt(); assert.equal(row.status, "intent"); assert.equal(row.result, null);
    assert.equal((await db.doc(`salesProviderBudgets/${row.monthlyBucketId}`).get()).data().consumed.modelInputTokens, 1000);
    assert.equal(f.calls(), 1);
  }
});

test("malformed canonical output, usage gaps, refusal and rate rejection retain intent without retry", async () => {
  for (const kind of ["alias", "usage", "refusal", "rate"]) {
    const f = await fixture();
    await assert.rejects(f.run({transport: async () => {
      if (kind === "alias") return response("deepseek", {...wireSelection, observationAlias: "option_99"});
      if (kind === "usage") return response("deepseek", wireSelection, false);
      if (kind === "rate") return new Response("SYNTHETIC-RAW-PRIVATE-VENDOR", {status: 429});
      const body = await response("deepseek").json();
      body.choices[0].message.refusal = "Synthetic refusal";
      return new Response(JSON.stringify(body));
    }}));
    await assert.rejects(f.run()); assert.equal(f.calls(), 1);
    assert.equal((await f.attempt()).status, "intent");
  }
});

test("cancellation after submission blocks a second call even if transport ignores the signal", async () => {
  const f = await fixture(); const controller = new AbortController();
  let entered; const started = new Promise(resolve => {entered = resolve;});
  const running = f.run({transport: async () => {entered(); return new Promise(() => {});}}, {signal: controller.signal});
  const rejection = assert.rejects(running, error => !JSON.stringify(error).includes("SYNTHETIC-PRIVATE-CANCEL"));
  await started; controller.abort("SYNTHETIC-PRIVATE-CANCEL"); await rejection;
  await assert.rejects(f.run()); assert.equal(f.calls(), 1); assert.equal((await f.attempt()).status, "intent");
});

test("cancellation during final budget reads blocks intent and completion writes", async () => {
  for (const phase of ["reservation", "completion"]) {
    const f = await fixture(); const controller = new AbortController();
    let providerReturned = false;
    const database = abortDuringBudgetRead(controller,
      () => phase === "reservation" || providerReturned);
    await assert.rejects(f.run({database, transport: async () => {
      providerReturned = true; return response("deepseek");
    }}, {signal: controller.signal}), error => error.code === "aborted" &&
      !JSON.stringify(error).includes("SYNTHETIC-PRIVATE-TRANSACTION-CANCEL"));
    assert.equal(controller.signal.aborted, true);
    const row = await f.attempt();
    if (phase === "reservation") {
      assert.equal(row, undefined); assert.equal(f.calls(), 0); assert.equal(f.secrets(), 0);
      const runId = `provider-run-${hash([f.job().jobId, "writing"]).slice(0, 40)}`;
      assert.equal((await db.doc(`salesProviderBudgets/${runId}`).get()).exists, false);
      await f.run(); assert.equal(f.calls(), 1);
    } else {
      assert.equal(row.status, "intent"); assert.equal(row.cache, null); assert.equal(row.result, null);
      for (const bucketId of [row.runBucketId, row.monthlyBucketId]) {
        assert.deepEqual((await db.doc(`salesProviderBudgets/${bucketId}`).get()).data().consumed, limits);
      }
      await assert.rejects(f.run()); assert.equal(f.calls(), 1); assert.equal(f.secrets(), 1);
    }
  }
});

test("changed monthly limits cannot replace an existing bucket or bypass a reservation", async () => {
  const one = await fixture({billing: "synthetic-immutable-limit"}); await one.run();
  const two = await fixture({billing: "synthetic-immutable-limit", monthly: {...limits, modelCalls: 2, networkRequests: 2}});
  await assert.rejects(two.run()); assert.equal(two.calls(), 0); assert.equal(await two.attempt(), undefined);
});

test("authorization revocation during secret wait prevents transport and retains intent", async () => {
  const f = await fixture();
  await assert.rejects(f.run({resolver: async () => {
    await db.doc(`adminUsers/${f.actor.uid}`).update({active: false});
    return "synthetic-not-a-key";
  }}));
  assert.equal(f.calls(), 0); assert.equal((await f.attempt()).status, "intent");
});

test("worker timeout covers uncooperative secret lookup and blocks future submission", async () => {
  const f = await fixture();
  await assert.rejects(f.run({timeoutMs: 1500, resolver: async () => new Promise(() => {})}));
  assert.equal(f.calls(), 0); assert.equal((await f.attempt()).status, "intent");
  await assert.rejects(f.run()); assert.equal(f.secrets(), 1);
});

test("over-reservation usage cannot complete or refund a submitted attempt", async () => {
  const f = await fixture();
  await assert.rejects(f.run({transport: async () => {
    const body = await response("deepseek").json();
    body.usage = {prompt_tokens: 1001, completion_tokens: 3, total_tokens: 1004};
    return new Response(JSON.stringify(body));
  }}));
  const row = await f.attempt(); assert.equal(row.status, "intent");
  assert.equal((await db.doc(`salesProviderBudgets/${row.monthlyBucketId}`).get()).data().consumed.modelInputTokens, 1000);
  await assert.rejects(f.run()); assert.equal(f.calls(), 1);
});

test("completion is idempotent and malformed usage cannot reconcile twice", async () => {
  const f = await fixture(); await f.run(); const row = await f.attempt();
  const current = {jobId: row.jobId, actorUid: row.actorUid, organizerId: row.organizerId,
    leaseOwner: row.leaseOwner, deadline: Date.parse(f.job().leaseUntil), month: row.month,
    binding: row.binding, reservation: row.reservation, runLimits: limits, monthlyLimits: limits,
    billingScopeHash: hash(f.policy.writing.billingSourceId)};
  const deps = {db, now: f.deps.now, current: async () => current, assertActive: () => {}};
  assert.deepEqual(await completeProviderAttempt(deps, row, row.cache, row.result), row);
  assert.deepEqual(await completeProviderAttempt(deps, row, row.cache, row.result), row);
  const bad = structuredClone(row.cache); bad.provenance.usage.inputTokens = 1001;
  await assert.rejects(completeProviderAttempt(deps, row, bad, row.result));
  assert.equal((await db.doc(`salesProviderBudgets/${row.monthlyBucketId}`).get()).data().consumed.modelCalls, 1);
  const reopened = await reserveProviderAttempt(deps); assert.equal(reopened.dispatch, false);
  assert.equal(providerBudgetIds(current).month, row.monthlyBucketId);
});

test("schema-valid corrupted receipts cannot replay beyond the frozen reservation", async () => {
  for (const change of ["input", "request-cost", "reservation", "bucket"]) {
    const f = await fixture(); await f.run(); const row = await f.attempt();
    const bucketIds = [row.runBucketId, row.monthlyBucketId];
    const before = await Promise.all(bucketIds.map(async id => (await db.doc(`salesProviderBudgets/${id}`).get()).data()));
    if (change === "input") {
      row.cache.provenance.usage.inputTokens = 1001;
      row.cache.provenance.metadata.tokens.inputTotal = 1001;
    }
    if (change === "request-cost") {
      row.cache.provenance.request.maxCostMicros = 1001;
      row.cache.provenance.usage.costMicros = 1001;
    }
    if (change === "reservation") row.reservation.modelCostMicros = 1001;
    if (change === "bucket") row.monthlyBucketId = `provider-month-${"a".repeat(40)}`;
    assert.equal(validateSalesProviderAttemptDocument(row), true);
    await db.doc(`salesProviderAttempts/${row.attemptId}`).set(row);
    await assert.rejects(f.run()); assert.equal(f.calls(), 1); assert.equal(f.secrets(), 1);
    const after = await Promise.all(bucketIds.map(async id => (await db.doc(`salesProviderBudgets/${id}`).get()).data()));
    assert.deepEqual(after, before);
  }
});

test("reviewed privacy cleanup removes result content while permanent fence prevents renewed I/O", async () => {
  const f = await fixture();
  await assert.rejects(f.run({transport: async () => {throw new Error("Synthetic uncertain request");}}));
  const attempt = await f.attempt();
  const owner = {uid: "owner-synthetic", roles: ["adminOwner"]};
  const inventory = await inventorySalesOrganizer(firestoreInventoryPort(db), f.organizerId);
  assert.ok(inventory.items.some(x => x.path === `salesProviderAttempts/${attempt.attemptId}`));
  const privacy = {db, now: f.deps.now, authorizeOwner: async () => {}};
  await reviewSalesPrivacyPolicy(privacy, owner, {requestId: "provider-privacy-policy-0001",
    expectedRevision: 0, sourceReference: "Synthetic reviewed retention", sourceHash: "b".repeat(64),
    financeReason: "Retain aggregate accounting", auditReason: "Retain aggregate hashes"});
  await restrictSalesOrganizer(privacy, owner, {organizerId: f.organizerId,
    requestId: "provider-privacy-restrict-0001", reason: "Synthetic permanent fence"});
  const preview = await previewSalesPrivacyPlan(privacy, owner, {organizerId: f.organizerId});
  const reviewed = await reviewSalesPrivacyPlan(privacy, owner, {organizerId: f.organizerId,
    requestId: "provider-privacy-plan-0001", restrictionRevision: preview.restrictionRevision,
    expectedActivePlanId: preview.activePlanId, policyHash: preview.policyHash, inventoryHash: preview.inventoryHash});
  let cursor = 0;
  while (cursor < reviewed.plan.itemCount) {
    const result = await applySalesPrivacyBatch(privacy, owner, {organizerId: f.organizerId,
      planId: reviewed.plan.planId, requestId: `provider-privacy-batch-${cursor}`, expectedCursor: cursor});
    cursor = result.batch.nextCursor;
  }
  assert.equal(await f.attempt(), undefined);
  assert.equal((await db.doc(`salesProviderBudgets/${attempt.monthlyBucketId}`).get()).data().consumed.modelCalls, 1);
  assert.equal((await db.doc(`salesPrivacyRestrictions/${f.organizerId}`).get()).exists, true);
  // Recreate the synthetic job/account to prove missing attempt state alone is insufficient.
  await f.restore();
  await db.doc(`salesOutreachJobs/${f.job().jobId}`).set(f.job());
  await assert.rejects(f.run()); assert.equal(f.calls(), 1);
});
