import assert from "node:assert/strict";
import test from "node:test";
import {
  assertRazorpayOrderOwnership,
  OwnedRazorpayOrderEvidence,
  razorpayOwnershipNotes,
  resolveRazorpayOrderOwnership,
  resolveRazorpayRuntimeProject,
} from "./razorpayOrderOwnership";

const project = "catchdates-dev";
const foreign = "catch-dating-app-64e51";
const ownContext = {projectId: project, schema: "1"};

test("runtime identity has no default and rejects ambiguous authorities",
  () => {
    for (const input of [{}, {gcloudProject: ""},
      {adminProjectId: "574779808785"},
      {adminProjectId: project, gcloudProject: foreign}]) {
      assert.throws(() => resolveRazorpayRuntimeProject(input), /unavailable/);
    }
    assert.equal(resolveRazorpayRuntimeProject({adminProjectId: project,
      gcloudProject: project, legacyGcloudProject: project}), project);
  });

test("foreign provider marker wins over cloned local origin/context", () => {
  const result = resolveRazorpayOrderOwnership({runtimeProjectId: project,
    order: {id: "order_1", notes: {...razorpayOwnershipNotes(foreign),
      eventId: "cloned_event", userId: "cloned_user"}},
    frozenContexts: [ownContext]});
  assert.equal(result.kind, "foreign");
});

test("bare legacy records never establish origin for an unmarked order",
  () => {
    assert.equal(resolveRazorpayOrderOwnership({runtimeProjectId: project,
      order: {id: "order_1", notes: {
        eventId: "local_event", userId: "local_user"}},
      frozenContexts: [ownContext]}).kind, "unknown");
  });

test("own new marker establishes origin without best-effort pending record",
  () => {
    const result = resolveRazorpayOrderOwnership({runtimeProjectId: project,
      order: {id: "order_1", notes: razorpayOwnershipNotes(project)}});
    assert.equal(result.kind, "owned");
    if (result.kind !== "owned") assert.fail("Expected owned evidence");
    assert.deepEqual(assertRazorpayOrderOwnership({evidence: result.evidence,
      orderId: "order_1", runtimeProjectId: project}), ownContext);
  });

test("partial, unsupported or malformed markers never fall back to local rows",
  () => {
    for (const notes of [
      {catchBookingProject: project}, {catchBookingSchema: "1"},
      {catchBookingProject: project, catchBookingSchema: "999"},
      {catchBookingProject: project, catchBookingSchema: 1},
      {catchBookingProject: " " + project, catchBookingSchema: "1"},
    ]) {
      assert.equal(resolveRazorpayOrderOwnership({runtimeProjectId: project,
        order: {id: "order_1", notes}, frozenContexts: [ownContext]}).kind,
      "invalid");
    }
  });

test("mutable provider notes conflict with frozen local ownership", () => {
  for (const context of [{projectId: foreign, schema: "1"},
    {projectId: project, schema: "999"}, null, {}]) {
    assert.equal(resolveRazorpayOrderOwnership({runtimeProjectId: project,
      order: {id: "order_1", notes: razorpayOwnershipNotes(project)},
      frozenContexts: [context]}).kind, "conflict");
  }
});

test("resolved authority cannot be copied, forged or retargeted by a caller",
  () => {
    const result = resolveRazorpayOrderOwnership({runtimeProjectId: project,
      order: {id: "order_1", notes: razorpayOwnershipNotes(project)}});
    if (result.kind !== "owned") assert.fail("Expected owned evidence");
    for (const evidence of [JSON.parse(JSON.stringify(result.evidence)),
      {...result.evidence}, {orderId: "order_1", context: ownContext}]) {
      assert.throws(() => assertRazorpayOrderOwnership({
        evidence: evidence as OwnedRazorpayOrderEvidence,
        orderId: "order_1", runtimeProjectId: project}), /reconciliation/);
    }
    assert.throws(() => assertRazorpayOrderOwnership({evidence: result.evidence,
      orderId: "order_other", runtimeProjectId: project}), /reconciliation/);
    assert.throws(() => assertRazorpayOrderOwnership({evidence: result.evidence,
      orderId: "order_1", runtimeProjectId: foreign}), /reconciliation/);
    assert.equal(Object.isFrozen(result.evidence), true);
    assert.equal(Object.isFrozen(result.evidence.context), true);
  });
