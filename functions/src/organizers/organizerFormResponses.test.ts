import assert from "node:assert/strict";
import test from "node:test";
import {HttpsError} from "firebase-functions/v2/https";
import {validateAnswerShape} from "./organizerFormResponses";
import type {OrganizerFormVersionDocument} from
  "../shared/generated/firestoreAdminTypes";

type Definition = OrganizerFormVersionDocument["definition"];
type Question = Definition["sections"][number]["questions"][number];

test("respondent validation accepts valid partial and complete answers", () => {
  const value = definition([
    question("name", "Name", "shortText", true),
    question("contact", "Email", "email", true),
    question("interests", "Interests", "multiChoice", false, [
      ["walks", "Walks"],
      ["quiz", "Quiz nights"],
    ]),
  ]);

  assert.doesNotThrow(() => validateAnswerShape(value, {name: "Ada"}, false));
  assert.doesNotThrow(() => validateAnswerShape(value, {
    name: "Ada",
    contact: "ada@example.com",
    interests: ["walks"],
  }, true));
});

test("respondent validation rejects unknown and missing answers", () => {
  const value = definition([
    question("name", "Name", "shortText", true),
  ]);

  assertHttpsCode(
    () => validateAnswerShape(value, {unknown: "answer"}, false),
    "invalid-argument"
  );
  assertHttpsCode(
    () => validateAnswerShape(value, {}, true),
    "invalid-argument"
  );
});

test("respondent validation enforces typed option and numeric bounds", () => {
  const count = question("count", "Group size", "number", false);
  count.validation.minNumber = 2;
  count.validation.maxNumber = 8;
  const format = question("format", "Format", "singleChoice", false, [
    ["walk", "Walk"],
    ["run", "Run"],
  ]);
  const value = definition([count, format]);

  assertHttpsCode(
    () => validateAnswerShape(value, {count: 1}, false),
    "invalid-argument"
  );
  assertHttpsCode(
    () => validateAnswerShape(value, {format: "crawl"}, false),
    "invalid-argument"
  );
});

test("respondent validation checks contact and consent shapes", () => {
  const value = definition([
    question("email", "Email", "email", false),
    question("phone", "Phone", "phone", false),
    question("site", "Website", "url", false),
    question("date", "Date", "date", false),
    question("agree", "Agreement", "acknowledgement", true),
  ]);

  const invalidAnswers: Array<Record<string, string | boolean>> = [
    {email: "not-an-email"},
    {phone: "123"},
    {site: "javascript:alert(1)"},
    {date: "18/08/2026"},
    {agree: false},
  ];
  for (const answers of invalidAnswers) {
    assertHttpsCode(
      () => validateAnswerShape(value, answers, false),
      "invalid-argument"
    );
  }
});

function definition(questions: Question[]): Definition {
  return {
    title: "Pilot form",
    description: null,
    purpose: "survey",
    defaultTargetKind: "organizer",
    defaultTargetId: null,
    identityPolicy: "anonymous",
    sections: [{
      sectionId: "section-main",
      title: "Details",
      description: null,
      pageBreak: false,
      questions,
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
      consentCopy: "I consent to sharing these answers.",
      consentVersion: "v1",
      retentionCopy: "The organizer retains this response for its purpose.",
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

function question(
  questionId: string,
  label: string,
  kind: Question["kind"],
  required: boolean,
  choices: Array<[string, string]> = []
): Question {
  return {
    questionId,
    key: questionId,
    label,
    helpText: null,
    kind,
    required,
    options: choices.map(([value, optionLabel]) => ({
      optionId: `option-${value}`,
      label: optionLabel,
      value,
    })),
    canonicalFieldId: null,
    privacyClass: "organizerCustom",
    prefillPolicy: "never",
    hostPresentation: "detailOnly",
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

function assertHttpsCode(action: () => void, code: HttpsError["code"]): void {
  assert.throws(action, (error: unknown) =>
    error instanceof HttpsError && error.code === code);
}
