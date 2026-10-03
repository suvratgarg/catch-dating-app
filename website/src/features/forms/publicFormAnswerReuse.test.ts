import {describe, expect, it} from "vitest";
import {publicFormsCopy} from "../../content/forms";
import type {PublicOrganizerForm, PublicOrganizerFormDraft,
  ParticipantFormActivityPage} from "../../firebase";
import type {PublicFormQuestion} from "./publicFormModel";
import {acceptReviewedReuseAnswers, hasReusableOrganizerQuestions,
  reviewedReuseSuggestions, sameFormReuseSources} from "./publicFormAnswerReuse";

const question: PublicFormQuestion = {questionId: "intro", key: "intro",
  label: publicFormsCopy.reuseTitle, helpText: null, kind: "longText", required: false,
  options: [], canonicalFieldId: null, privacyClass: "organizerCustom",
  hostPresentation: "detailOnly", prefillPolicy: "participantReviewRequired",
  answerDestination: "organizerOnly",
  validation: {minLength: null, maxLength: null, minNumber: null, maxNumber: null,
    earliestDate: null, latestDate: null, minSelections: null, maxSelections: null,
    maxFileCount: null, maxFileSizeBytes: null, allowedMimeTypes: [],
    patternPreset: null, customError: null}};
const form = {formId: "form", versionId: "current", organizer: {organizerId: "organizer"},
  definition: {sections: [{questions: [question]}]}} as PublicOrganizerForm;
const source: ParticipantFormActivityPage["items"][number] = {
  sourceKind: "formResponse", sourceId: "old", organizerId: "organizer", formId: "form",
  versionId: "old-version", eventId: null, formTitle: "Old form",
  purpose: "application", submittedAtMillis: 1000};
const draft = {draftId: "draft", form} as PublicOrganizerFormDraft;
const result = {...draft, prefillSource: {responseId: "old", versionId: "old-version",
  submittedAtMillis: 1000}, prefillSuggestions: {intro: "Previous introduction"}};
function withQuestion(q: PublicFormQuestion) {
  return {...form, definition: {...form.definition, sections: [{sectionId: "section",
    title: publicFormsCopy.reviewKicker, description: null, pageBreak: false, questions: [q]}]}};
}

describe("source-bound reuse review", () => {
  it("filters exact organizer/form and deduplicates metadata across bounded pages", () => {
    const page = {items: [source, {...source, sourceId: "foreign", organizerId: "other"},
      {...source, sourceId: "other-form", formId: "other"},
      {...source, sourceId: "bad-date", submittedAtMillis: NaN}], nextCursor: "page"};
    expect(sameFormReuseSources([page, {items: [source,
      {...source, sourceId: "recent", submittedAtMillis: 2000}], nextCursor: null}],
    form).map((item) => item.sourceId)).toEqual(["recent", "old"]);
  });
  it("requires immutable origin even when a prefiller sends extra private fields", () => {
    expect(reviewedReuseSuggestions({...draft,
      prefillSuggestions: result.prefillSuggestions}, draft, source)).toEqual({});
  });
  it.each(["draft", "organizer", "form", "version", "origin", "origin-version", "origin-time"])(
    "rejects a mismatched %s before values enter the draft", (scope) => {
      const altered = {...result, form: {...form, organizer: {...form.organizer}},
        prefillSource: {...result.prefillSource}};
      if (scope === "draft") altered.draftId = "foreign";
      if (scope === "organizer") altered.form.organizer.organizerId = "foreign";
      if (scope === "form") altered.form.formId = "foreign";
      if (scope === "version") altered.form.versionId = "foreign";
      if (scope === "origin") altered.prefillSource.responseId = "foreign";
      if (scope === "origin-version") altered.prefillSource.versionId = "foreign";
      if (scope === "origin-time") altered.prefillSource.submittedAtMillis = 2000;
      expect(() => reviewedReuseSuggestions(altered, draft, source)).toThrow();
    });
  it.each(["catchProfile", "organizerCard", "file", "signature", "acknowledgement", "never"])(
    "does not offer %s through organizer-answer reuse", (mode) => {
      const changed = {...question};
      if (mode === "catchProfile" || mode === "organizerCard") changed.answerDestination = mode;
      else if (mode === "never") changed.prefillPolicy = "never";
      else changed.kind = mode as PublicFormQuestion["kind"];
      const target = withQuestion(changed);
      expect(hasReusableOrganizerQuestions(target)).toBe(false);
      expect(reviewedReuseSuggestions({...result, form: target},
        {...draft, form: target}, source)).toEqual({});
    });
  it("reuses the current answer validator and excludes stale constraints", () => {
    const target = withQuestion({...question, validation: {...question.validation, maxLength: 2}});
    expect(reviewedReuseSuggestions({...result, form: target},
      {...draft, form: target}, source)).toEqual({});
  });
  it("preserves typed answers and deliberate clears; copies only selected answer values", () => {
    const current = {intro: "Updated", cleared: "", optedOut: false};
    const previous = {intro: "Old", cleared: "Old", optedOut: true,
      interests: ["Walking"], other: "Not selected"};
    const accepted = acceptReviewedReuseAnswers(current, previous,
      ["intro", "cleared", "optedOut", "interests", "unknown"]);
    expect(accepted).toEqual({...current, interests: ["Walking"]});
    (accepted.interests as string[]).push("Music");
    expect(previous.interests).toEqual(["Walking"]);
    expect(current).toEqual({intro: "Updated", cleared: "", optedOut: false});
  });
});
