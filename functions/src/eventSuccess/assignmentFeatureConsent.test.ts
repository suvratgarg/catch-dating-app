import assert from "node:assert/strict";
import test from "node:test";
import type {OrganizerFormResponseDocument as Response,
  OrganizerFormVersionDocument as Version} from
  "../shared/generated/firestoreAdminTypes";
import {authorizedAssignmentFeatureSnapshot,
  type AssignmentFeatureConsentDecision} from "./assignmentFeatureConsent";
import type {AssignmentFeatureRule} from "./assignmentFeatureScoring";

const rule: AssignmentFeatureRule = {featureId: "pace", formId: "form",
  versionId: "version", questionId: "question", transformVersion: 1,
  kind: "category", mode: "preferSimilar", weight: 10,
  optionIds: ["option-slow", "option-fast"]};
const decision: AssignmentFeatureConsentDecision = {eventId: "event",
  organizerId: "organizer", uid: "person", responseId: "response",
  featureId: "pace", formId: "form", versionId: "version",
  questionId: "question", transformVersion: 1,
  purpose: "eventAssignmentMatching", status: "granted",
  receiptId: "receipt"};
const response = {organizerId: "organizer", formId: "form",
  versionId: "version", status: "submitted", withdrawnAt: null,
  respondentUid: "person", identityKind: "phoneVerified",
  answers: {question: "slow"}} as unknown as Response;
const version = {organizerId: "organizer", formId: "form",
  definition: {sections: [{questions: [{questionId: "question",
    kind: "singleChoice", privacyClass: "organizerCustom", options: [
      {optionId: "option-slow", value: "slow"},
      {optionId: "option-fast", value: "fast"},
    ]}]}]}} as unknown as Version;

function resolve(overrides: Partial<Parameters<
  typeof authorizedAssignmentFeatureSnapshot>[0]> = {}) {
  return authorizedAssignmentFeatureSnapshot({eventId: "event",
    organizerId: "organizer", uid: "person", rule, decision,
    responseId: "response", response, versionId: "version",
    version, ...overrides});
}

test("exact owned submitted answer maps versioned value to option ID", () => {
  assert.deepEqual(resolve(), {eventId: "event", organizerId: "organizer",
    uid: "person", featureId: "pace", formId: "form",
    versionId: "version", questionId: "question", transformVersion: 1,
    responseId: "response", consentReceiptId: "receipt",
    value: {kind: "category", optionId: "option-slow"}});
});

test("withdrawal, foreign event, foreign subject and changed source deny use",
  () => {
    assert.equal(resolve({decision: {...decision, status: "withdrawn"}}), null);
    assert.equal(resolve({eventId: "other-event"}), null);
    assert.equal(resolve({uid: "other-person"}), null);
    assert.equal(resolve({decision: {...decision, versionId: "other"}}), null);
    assert.equal(resolve({versionId: "other"}), null);
    assert.equal(resolve({response: {...response, status: "withdrawn"}}), null);
    assert.equal(resolve({response: {...response, respondentUid: null}}), null);
    assert.equal(resolve({response: {...response,
      identityKind: "anonymous"}}), null);
  });

test("unmapped, missing and sensitive answers remain absent", () => {
  assert.equal(resolve({response: {...response,
    answers: {question: "stale-choice"}}}), null);
  assert.equal(resolve({response: {...response, answers: {}}}), null);
  assert.equal(resolve({version: {...version, definition: {
    ...version.definition, sections: [{...version.definition.sections[0],
      questions: [{...version.definition.sections[0].questions[0],
        privacyClass: "sensitive"}]}]}}}), null);
});
