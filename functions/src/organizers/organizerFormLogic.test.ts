import assert from "node:assert/strict";
import test from "node:test";
import {
  answersForSubmission,
  reachableFormSections,
} from "./organizerFormLogic";
import type {OrganizerFormVersionDocument} from
  "../shared/generated/firestoreAdminTypes";

type Definition = OrganizerFormVersionDocument["definition"];
type Rule = Definition["logicRules"][number];

test("show rules gate their targets until a condition matches", () => {
  const value = definition([
    rule("show-details", "showSection", "attending", [true], null, "details"),
    rule("show-note", "showQuestion", "attending", [true], "note", null),
  ]);

  assert.deepEqual(sectionIds(value, {}), ["intro", "end"]);
  assert.deepEqual(sectionIds(value, {attending: true}), [
    "intro", "details", "end",
  ]);
  assert.deepEqual(
    reachableFormSections(value, {attending: true})[0].questions
      .map((question) => question.questionId),
    ["attending", "note"]
  );
});

test("matching hide rules override ordinary visibility", () => {
  const value = definition([
    rule("hide-details", "hideSection", "attending", [false], null, "details"),
    rule("hide-note", "hideQuestion", "attending", [false], "note", null),
  ]);

  assert.deepEqual(sectionIds(value, {attending: false}), ["intro", "end"]);
  assert.deepEqual(
    reachableFormSections(value, {attending: false})[0].questions
      .map((question) => question.questionId),
    ["attending"]
  );
});

test("a matching route skips intermediate sections deterministically", () => {
  const value = definition([
    rule("route-end", "routeToSection", "attending", [true], null, "end"),
  ]);

  assert.deepEqual(sectionIds(value, {attending: true}), ["intro", "end"]);
  assert.deepEqual(sectionIds(value, {attending: false}), [
    "intro", "details", "end",
  ]);
});

test("finish truncates the path and submission removes stale answers", () => {
  const value = definition([
    rule("finish", "finish", "attending", [false], null, null),
  ]);
  const answers = {
    attending: false,
    note: "Keep this",
    email: "stale@example.com",
    final: "stale",
  };

  assert.deepEqual(sectionIds(value, answers), ["intro"]);
  assert.deepEqual(answersForSubmission(value, answers), {
    attending: false,
    note: "Keep this",
  });
});

function sectionIds(
  value: Definition,
  answers: Record<string, string | boolean>
) {
  return reachableFormSections(value, answers)
    .map((section) => section.sectionId);
}

function definition(logicRules: Rule[]): Definition {
  return {
    title: "Form",
    description: null,
    purpose: "survey",
    defaultTargetKind: "organizer",
    defaultTargetId: null,
    identityPolicy: "anonymous",
    sections: [
      section("intro", [question("attending"), question("note")]),
      section("details", [question("email")]),
      section("end", [question("final")]),
    ],
    logicRules,
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
      consentCopy: "Consent",
      consentVersion: "v1",
      retentionCopy: "Retention",
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

function section(sectionId: string, questions: ReturnType<typeof question>[]) {
  return {sectionId, title: sectionId, description: null, pageBreak: true,
    questions};
}

function question(questionId: string) {
  return {
    questionId,
    key: questionId,
    label: questionId,
    helpText: null,
    kind: "shortText" as const,
    required: false,
    options: [],
    canonicalFieldId: null,
    privacyClass: "organizerCustom" as const,
    prefillPolicy: "never" as const,
    hostPresentation: "detailOnly" as const,
    validation: {
      minLength: null,
      maxLength: null,
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

function rule(
  ruleId: string,
  action: Rule["action"],
  questionId: string,
  expectedValues: Array<string | number | boolean>,
  targetQuestionId: string | null,
  targetSectionId: string | null
): Rule {
  return {
    ruleId,
    conditionMode: "all",
    conditions: [{questionId, operator: "equals", expectedValues}],
    action,
    targetQuestionId,
    targetSectionId,
  };
}
