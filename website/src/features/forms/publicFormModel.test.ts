import {describe, expect, it} from "vitest";
import {publicFormsCopy} from "../../content/forms";
import {
  answerSummary,
  validatePublicFormAnswers,
  visiblePublicFormSections,
  type PublicFormDefinition,
  type PublicFormQuestion,
} from "./publicFormModel";

describe("public form model", () => {
  it("applies matching question and section visibility rules", () => {
    const value = definition();
    value.logicRules = [
      {
        ruleId: "hide-details",
        conditionMode: "all",
        conditions: [{
          questionId: "attending",
          operator: "equals",
          expectedValues: [false],
        }],
        action: "hideSection",
        targetQuestionId: null,
        targetSectionId: "details",
      },
      {
        ruleId: "hide-note",
        conditionMode: "all",
        conditions: [{
          questionId: "attending",
          operator: "notAnswered",
          expectedValues: [],
        }],
        action: "hideQuestion",
        targetQuestionId: "note",
        targetSectionId: null,
      },
    ];

    expect(visiblePublicFormSections(value, {})).toHaveLength(2);
    expect(visiblePublicFormSections(value, {})[0].questions).toHaveLength(1);
    expect(visiblePublicFormSections(value, {attending: false})).toHaveLength(1);
  });

  it("validates required, contact, and numeric answers", () => {
    const email = question("email", "Email", "email", true);
    const count = question("count", "Group size", "number", false);
    count.validation.minNumber = 2;
    const errors = validatePublicFormAnswers(
      [email, count],
      {email: "invalid", count: 1}
    );
    expect(errors.email).toBe("Email is invalid.");
    expect(errors.count).toBe("Group size is invalid.");
    expect(validatePublicFormAnswers([email], {})).toEqual({
      email: "Email is required.",
    });
  });

  it("renders stable human-readable answer summaries", () => {
    expect(answerSummary(["Walks", "Quiz nights"])).toBe(
      "Walks, Quiz nights"
    );
    expect(answerSummary(true)).toBe("Yes");
    expect(answerSummary(null)).toBe("");
  });

  it("routes and finishes with the same forward-only semantics as submission", () => {
    const value = definition();
    value.sections.push({
      sectionId: "finish",
      title: publicFormsCopy.completionKicker,
      description: null,
      pageBreak: true,
      questions: [question("final", "Final", "shortText", false)],
    });
    value.logicRules = [{
      ruleId: "route",
      conditionMode: "all",
      conditions: [{
        questionId: "attending",
        operator: "equals",
        expectedValues: [true],
      }],
      action: "routeToSection",
      targetQuestionId: null,
      targetSectionId: "finish",
    }];
    expect(visiblePublicFormSections(value, {attending: true})
      .map((section) => section.sectionId)).toEqual(["intro", "finish"]);
    value.logicRules[0].action = "finish";
    value.logicRules[0].targetSectionId = null;
    expect(visiblePublicFormSections(value, {attending: true})
      .map((section) => section.sectionId)).toEqual(["intro"]);
  });

  it("validates dates, option limits, patterns, and answer types", () => {
    const date = question("date", "Date", "date", false);
    date.validation.earliestDate = "2026-01-01";
    date.validation.latestDate = "2026-12-31";
    const choices = question("choices", "Choices", "multiChoice", false);
    choices.options = [
      {optionId: "a", label: publicFormsCopy.yes, value: "a"},
      {optionId: "b", label: publicFormsCopy.no, value: "b"},
    ];
    choices.validation.minSelections = 1;
    choices.validation.maxSelections = 1;
    const handle = question("handle", "Handle", "shortText", false);
    handle.validation.patternPreset = "handle";
    const errors = validatePublicFormAnswers([date, choices, handle], {
      date: "2027-01-01",
      choices: ["a", "b"],
      handle: "bad handle",
    });
    expect(Object.keys(errors)).toEqual(["date", "choices", "handle"]);
    expect(validatePublicFormAnswers([date], {date: 20260101})).toHaveProperty(
      "date"
    );
  });
});

function definition(): PublicFormDefinition {
  return {
    title: publicFormsCopy.brand,
    description: null,
    purpose: "intake",
    defaultTargetKind: "organizer",
    defaultTargetId: null,
    identityPolicy: "anonymous",
    sections: [
      {
        sectionId: "intro",
        title: publicFormsCopy.previous,
        description: null,
        pageBreak: false,
        questions: [
          question("attending", "Are you attending?", "boolean", false),
          question("note", "Anything else?", "shortText", false),
        ],
      },
      {
        sectionId: "details",
        title: publicFormsCopy.identityTitle,
        description: null,
        pageBreak: true,
        questions: [question("email", "Email", "email", true)],
      },
    ],
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
      consentCopy: "I consent.",
      consentVersion: "v1",
      retentionCopy: "Retained for this form purpose.",
    },
    completion: {
      title: publicFormsCopy.completionKicker,
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
  kind: PublicFormQuestion["kind"],
  required: boolean
): PublicFormQuestion {
  return {
    questionId,
    key: questionId,
    label,
    helpText: null,
    kind,
    required,
    options: [],
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
