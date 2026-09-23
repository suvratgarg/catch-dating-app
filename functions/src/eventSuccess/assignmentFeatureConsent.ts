import type {OrganizerFormResponseDocument as Response,
  OrganizerFormVersionDocument as Version} from
  "../shared/generated/firestoreAdminTypes";
import type {AssignmentFeatureRule, AssignmentFeatureValue,
  EventAssignmentFeatureSnapshot} from "./assignmentFeatureScoring";

/** A participant decision is bound to one event and one immutable answer. */
export interface AssignmentFeatureConsentDecision {
  eventId: string;
  organizerId: string;
  uid: string;
  responseId: string;
  featureId: string;
  formId: string;
  versionId: string;
  questionId: string;
  transformVersion: number;
  purpose: "eventAssignmentMatching";
  status: "granted" | "withdrawn";
  receiptId: string;
}

/** Host rules and responses alone never grant answer use. */
export function authorizedAssignmentFeatureSnapshot(params: {
  eventId: string;
  organizerId: string;
  uid: string;
  rule: AssignmentFeatureRule;
  decision: AssignmentFeatureConsentDecision | null;
  responseId: string;
  response: Response | null;
  version: Version | null;
}): EventAssignmentFeatureSnapshot | null {
  const {eventId, organizerId, uid, rule, decision, responseId,
    response, version} = params;
  if (!decision || decision.purpose !== "eventAssignmentMatching" ||
      decision.status !== "granted" || !decision.receiptId ||
      decision.eventId !== eventId || decision.organizerId !== organizerId ||
      decision.uid !== uid || decision.responseId !== responseId ||
      decision.featureId !== rule.featureId ||
      decision.formId !== rule.formId ||
      decision.versionId !== rule.versionId ||
      decision.questionId !== rule.questionId ||
      decision.transformVersion !== rule.transformVersion ||
      !response || !version || response.status !== "submitted" ||
      response.withdrawnAt !== null || response.respondentUid !== uid ||
      response.identityKind !== "phoneVerified" ||
      response.organizerId !== organizerId ||
      response.formId !== rule.formId ||
      response.versionId !== rule.versionId ||
      version.organizerId !== organizerId ||
      version.formId !== rule.formId) return null;

  const question = version.definition.sections.flatMap((section) =>
    section.questions).find((item) => item.questionId === rule.questionId);
  if (!question || question.privacyClass === "sensitive" ||
      question.privacyClass === "contact") return null;
  const answer = response.answers[rule.questionId];
  const value = answerFeatureValue(rule, question, answer);
  if (!value) return null;
  return {eventId, organizerId, uid, featureId: rule.featureId,
    formId: rule.formId, versionId: rule.versionId,
    questionId: rule.questionId, transformVersion: rule.transformVersion,
    consentReceiptId: decision.receiptId, value};
}

function answerFeatureValue(
  rule: AssignmentFeatureRule,
  question: Version["definition"]["sections"][number]["questions"][number],
  answer: Response["answers"][string] | undefined
): AssignmentFeatureValue | null {
  if (rule.kind === "number") {
    return question.kind === "number" && typeof answer === "number" &&
      Number.isFinite(answer) ? {kind: "number", value: answer} : null;
  }
  if (rule.kind === "set") {
    if (question.kind !== "multiChoice" || !Array.isArray(answer) ||
        answer.length === 0) return null;
    const optionIds = answer.map((value) =>
      question.options.find((option) => option.value === value)?.optionId);
    return optionIds.every((id): id is string => typeof id === "string") ?
      {kind: "set", optionIds: optionIds as string[]} : null;
  }
  if (question.kind !== "singleChoice" || typeof answer !== "string") {
    return null;
  }
  const optionId = question.options.find((option) =>
    option.value === answer)?.optionId;
  return optionId ? {kind: rule.kind, optionId} : null;
}
