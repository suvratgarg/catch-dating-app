import assert from "node:assert/strict";
import test from "node:test";
import {buildAssignmentFeatureAudit} from "./assignmentFeatureAudit";
import type {EventAssignmentFeatureSnapshot} from
  "./assignmentFeatureScoring";

const source = (uid: string): EventAssignmentFeatureSnapshot => ({
  eventId: "event-1", organizerId: "org-1", uid,
  featureId: "pace", formId: "form-1", versionId: "version-1",
  questionId: "question-1", transformVersion: 1,
  responseId: `response-${uid}`, consentReceiptId: `receipt-${uid}`,
  value: {kind: "category", optionId: "private-answer"},
});

test("audit identifies exact sources without exposing answer values", () => {
  const a = source("a");
  const b = source("b");
  const input = {eventId: "event-1", organizerId: "org-1",
    configHash: "config-1", snapshots: [a, b]};
  const audit = buildAssignmentFeatureAudit(input);
  assert.deepEqual(audit, buildAssignmentFeatureAudit({
    ...input, snapshots: [b, a]}));
  for (const changed of [
    {...input, configHash: "config-2"},
    {...input, snapshots: [{...a, responseId: "response-new"}, b]},
    {...input, snapshots: [{...a, consentReceiptId: "receipt-new"}, b]},
    {...input, snapshots: [{...a, transformVersion: 2}, b]},
  ]) {
    assert.notEqual(buildAssignmentFeatureAudit(changed).inputSnapshotId,
      audit.inputSnapshotId);
  }
  assert.equal(audit.inputSnapshotId.length, 64);
  for (const privateValue of ["private-answer", "response-a", "receipt-a",
    "org-1", "event-1"]) {
    assert.equal(JSON.stringify(audit).includes(privateValue), false);
  }
});
