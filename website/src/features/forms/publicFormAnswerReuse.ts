import {publicFormsCopy} from "../../content/forms";
import type {ParticipantFormActivityPage, PublicOrganizerForm,
  PublicOrganizerFormDraft} from "../../firebase";
import {validatePublicFormAnswers, type PublicFormAnswers,
  type PublicFormQuestion} from "./publicFormModel";

export type PublicFormReuseSource = ParticipantFormActivityPage["items"][number];

export function hasReusableOrganizerQuestions(form: PublicOrganizerForm) {
  return form.definition.sections.some((section) =>
    section.questions.some(reusableQuestion));
}

function reusableQuestion(question: PublicFormQuestion) {
  return (question.answerDestination ?? "organizerOnly") === "organizerOnly" &&
    question.prefillPolicy === "participantReviewRequired" &&
    !["file", "signature", "acknowledgement"].includes(question.kind);
}

/** Metadata is a chooser; the begin endpoint rechecks source authority. */
export function sameFormReuseSources(
  pages: readonly ParticipantFormActivityPage[], form: PublicOrganizerForm
): PublicFormReuseSource[] {
  const sources = new Map<string, PublicFormReuseSource>();
  for (const page of pages) {
    for (const item of page.items) {
      if (item.sourceKind !== "formResponse" ||
          item.organizerId !== form.organizer.organizerId ||
          item.formId !== form.formId ||
          !Number.isSafeInteger(item.submittedAtMillis) ||
          item.submittedAtMillis < 0 ||
          item.submittedAtMillis > 8640000000000000) continue;
      if (!sources.has(item.sourceId)) sources.set(item.sourceId, item);
    }
  }
  return [...sources.values()].sort((a, b) =>
    b.submittedAtMillis - a.submittedAtMillis ||
    a.sourceId.localeCompare(b.sourceId));
}

/** Keep the server's current-question decision; never infer historical matches. */
export function reviewedReuseSuggestions(
  result: PublicOrganizerFormDraft, current: PublicOrganizerFormDraft,
  source: PublicFormReuseSource
): PublicFormAnswers {
  if (result.draftId !== current.draftId ||
      result.form.formId !== current.form.formId ||
      result.form.versionId !== current.form.versionId ||
      result.form.organizer.organizerId !== current.form.organizer.organizerId) {
    throw new Error(publicFormsCopy.reuseFormChanged);
  }
  if (!result.prefillSource) return {};
  if (result.prefillSource.responseId !== source.sourceId ||
      result.prefillSource.versionId !== source.versionId ||
      result.prefillSource.submittedAtMillis !== source.submittedAtMillis) {
    throw new Error(publicFormsCopy.reuseSourceUnavailable);
  }
  const answers: PublicFormAnswers = {};
  for (const question of current.form.definition.sections.flatMap((section) =>
    section.questions)) {
    const value = result.prefillSuggestions?.[question.questionId];
    if (!reusableQuestion(question) || value === undefined || value === null ||
        value === "" || (Array.isArray(value) && value.length === 0) ||
        Object.keys(validatePublicFormAnswers([question],
          {[question.questionId]: value})).length > 0) continue;
    answers[question.questionId] = Array.isArray(value) ? [...value] : value;
  }
  return answers;
}

/** Existing answers, including deliberate clears, always win over suggestions. */
export function acceptReviewedReuseAnswers(
  current: PublicFormAnswers, suggestions: PublicFormAnswers,
  selectedQuestionIds: readonly string[]
): PublicFormAnswers {
  const answers = {...current};
  for (const id of selectedQuestionIds) {
    if (Object.hasOwn(answers, id) || !Object.hasOwn(suggestions, id)) continue;
    const value = suggestions[id];
    answers[id] = Array.isArray(value) ? [...value] : value;
  }
  return answers;
}
