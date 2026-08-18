import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";
import {validateOrganizerFormDefinition} from "./organizerForms";

type Definition = Parameters<typeof validateOrganizerFormDefinition>[0];
type Question = Definition["sections"][number]["questions"][number];

test("form validator accepts a minimal publishable survey", () => {
  assert.deepEqual(validateOrganizerFormDefinition(definition()), []);
});

test("form validator rejects identity, option, and range conflicts", () => {
  const value = definition();
  value.sections[0].questions.push({
    ...question(),
    questionId: "question-1",
    key: "feedback",
    kind: "singleChoice",
    options: [],
    validation: {
      ...question().validation,
      minSelections: 2,
      maxSelections: 1,
    },
  });
  const codes = new Set(
    validateOrganizerFormDefinition(value).map((issue) => issue.code)
  );
  assert.equal(codes.has("duplicateQuestionId"), true);
  assert.equal(codes.has("duplicateQuestionKey"), true);
  assert.equal(codes.has("missingOptions"), true);
  assert.equal(codes.has("invalidSelectionRange"), true);
});

test("form validator enforces purpose and lifecycle-safe semantics", () => {
  const value = definition();
  value.purpose = "waiver";
  value.defaultTargetKind = "event";
  value.defaultTargetId = null;
  value.availability.opensAt = admin.firestore.Timestamp.fromMillis(2000);
  value.availability.closesAt = admin.firestore.Timestamp.fromMillis(1000);
  value.completion = {
    title: "Done",
    message: null,
    actionKind: "none",
    actionLabel: "Unexpected",
    actionUrl: null,
  };
  const codes = new Set(
    validateOrganizerFormDefinition(value).map((issue) => issue.code)
  );
  assert.equal(codes.has("invalidTarget"), true);
  assert.equal(codes.has("invalidAvailability"), true);
  assert.equal(codes.has("unexpectedCompletionAction"), true);
  assert.equal(codes.has("waiverAcknowledgement"), true);
  assert.equal(codes.has("waiverSignature"), true);
});

test("form validator prevents backward section routing", () => {
  const value = definition();
  value.sections.push({
    sectionId: "section-2",
    title: "Second",
    description: null,
    pageBreak: true,
    questions: [{...question(), questionId: "question-2", key: "second"}],
  });
  value.logicRules = [{
    ruleId: "rule-1",
    conditionMode: "all",
    conditions: [{
      questionId: "question-2",
      operator: "answered",
      expectedValues: [],
    }],
    action: "routeToSection",
    targetQuestionId: null,
    targetSectionId: "section-1",
  }];
  assert.equal(
    validateOrganizerFormDefinition(value)
      .some((issue) => issue.code === "backwardRoute"),
    true
  );
});

test("form validator rejects stale and type-incompatible logic", () => {
  const value = definition();
  value.sections[0].questions[0] = {
    ...question(),
    kind: "singleChoice",
    options: [
      {optionId: "yes", label: "Yes", value: "yes"},
      {optionId: "no", label: "No", value: "no"},
    ],
  };
  value.logicRules = [{
    ruleId: "rule-1",
    conditionMode: "all",
    conditions: [{
      questionId: "question-1",
      operator: "equals",
      expectedValues: ["removed-option"],
    }],
    action: "finish",
    targetQuestionId: null,
    targetSectionId: null,
  }, {
    ruleId: "rule-1",
    conditionMode: "all",
    conditions: [{
      questionId: "question-1",
      operator: "greaterThan",
      expectedValues: [3],
    }],
    action: "finish",
    targetQuestionId: null,
    targetSectionId: null,
  }];
  const codes = new Set(
    validateOrganizerFormDefinition(value).map((issue) => issue.code)
  );
  assert.equal(codes.has("unknownConditionOption"), true);
  assert.equal(codes.has("duplicateLogicRuleId"), true);
  assert.equal(codes.has("invalidNumericCondition"), true);
  assert.equal(codes.has("ambiguousNavigation"), true);
});

test("form validator requires identity when collecting a signature", () => {
  const value = definition();
  value.sections[0].questions.push({
    ...question(),
    questionId: "signature",
    key: "signature",
    kind: "signature",
    privacyClass: "sensitive",
  });
  assert.equal(
    validateOrganizerFormDefinition(value)
      .some((issue) => issue.code === "anonymousSignature"),
    true
  );
});

test("form validator prevents self-referential visibility", () => {
  const value = definition();
  value.logicRules = [{
    ruleId: "rule-1",
    conditionMode: "all",
    conditions: [{
      questionId: "question-1",
      operator: "answered",
      expectedValues: [],
    }],
    action: "showQuestion",
    targetQuestionId: "question-1",
    targetSectionId: null,
  }];
  assert.equal(
    validateOrganizerFormDefinition(value)
      .some((issue) => issue.code === "selfReferentialVisibility"),
    true
  );
});

function definition(): Definition {
  return {
    title: "Feedback",
    description: null,
    purpose: "survey",
    defaultTargetKind: "organizer",
    defaultTargetId: null,
    identityPolicy: "anonymous",
    sections: [{
      sectionId: "section-1",
      title: "Your feedback",
      description: null,
      pageBreak: false,
      questions: [question()],
    }],
    logicRules: [],
    appearance: {
      preset: "minimal",
      logoAssetId: null,
      coverAssetId: null,
      activityKind: null,
    },
    availability: {
      opensAt: null,
      closesAt: null,
      responseLimit: null,
      closedMessage: null,
    },
    consent: {
      consentCopy: "I consent to this organizer receiving my answers.",
      consentVersion: "survey-v1",
      retentionCopy: "Answers are retained only for the stated purpose.",
    },
    completion: {
      title: "Thanks",
      message: null,
      actionKind: "none",
      actionLabel: null,
      actionUrl: null,
    },
  };
}

function question(): Question {
  return {
    questionId: "question-1",
    key: "feedback",
    label: "What should we know?",
    helpText: null,
    kind: "shortText",
    required: true,
    options: [],
    canonicalFieldId: null,
    privacyClass: "organizerCustom",
    prefillPolicy: "never",
    hostPresentation: "detailOnly",
    validation: {
      minLength: null,
      maxLength: 500,
      minNumber: null,
      maxNumber: null,
      earliestDate: null,
      latestDate: null,
      minSelections: null,
      maxSelections: null,
      maxFileCount: null,
      maxFileSizeBytes: null,
      allowedMimeTypes: [],
      patternPreset: null,
      customError: null,
    },
  };
}
