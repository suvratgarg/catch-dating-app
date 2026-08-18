import type {PublicOrganizerForm} from "../../firebase";

export type PublicFormDefinition = PublicOrganizerForm["definition"];
export type PublicFormQuestion =
  PublicFormDefinition["sections"][number]["questions"][number];
export type PublicFormAnswer = string | number | boolean | null | string[];
export type PublicFormAnswers = Record<string, PublicFormAnswer>;

export function visiblePublicFormSections(
  definition: PublicFormDefinition,
  answers: PublicFormAnswers
) {
  const hiddenSections = new Set<string>();
  const shownSections = new Set<string>();
  const hiddenQuestions = new Set<string>();
  const shownQuestions = new Set<string>();

  for (const rule of definition.logicRules) {
    if (!ruleMatches(rule, answers)) continue;
    if (rule.action === "hideSection" && rule.targetSectionId) {
      hiddenSections.add(rule.targetSectionId);
    }
    if (rule.action === "showSection" && rule.targetSectionId) {
      shownSections.add(rule.targetSectionId);
    }
    if (rule.action === "hideQuestion" && rule.targetQuestionId) {
      hiddenQuestions.add(rule.targetQuestionId);
    }
    if (rule.action === "showQuestion" && rule.targetQuestionId) {
      shownQuestions.add(rule.targetQuestionId);
    }
  }

  return definition.sections
    .filter((section) => !hiddenSections.has(section.sectionId) ||
      shownSections.has(section.sectionId))
    .map((section) => ({
      ...section,
      questions: section.questions.filter((question) =>
        !hiddenQuestions.has(question.questionId) ||
        shownQuestions.has(question.questionId)),
    }));
}

export function validatePublicFormAnswers(
  questions: readonly PublicFormQuestion[],
  answers: PublicFormAnswers
): Record<string, string> {
  const errors: Record<string, string> = {};
  for (const question of questions) {
    const answer = answers[question.questionId];
    if (question.required && isEmptyAnswer(answer)) {
      errors[question.questionId] = `${question.label} is required.`;
      continue;
    }
    if (isEmptyAnswer(answer)) continue;
    const error = validateQuestion(question, answer);
    if (error) errors[question.questionId] = error;
  }
  return errors;
}

export function answerSummary(answer: PublicFormAnswer | undefined): string {
  if (answer === undefined || answer === null || answer === "") return "";
  if (Array.isArray(answer)) return answer.join(", ");
  if (typeof answer === "boolean") return answer ? "Yes" : "No";
  return String(answer);
}

function ruleMatches(
  rule: PublicFormDefinition["logicRules"][number],
  answers: PublicFormAnswers
) {
  const matches = rule.conditions.map((condition) => {
    const answer = answers[condition.questionId];
    const values = Array.isArray(answer) ? answer : [answer];
    const expected = condition.expectedValues;
    switch (condition.operator) {
    case "answered": return !isEmptyAnswer(answer);
    case "notAnswered": return isEmptyAnswer(answer);
    case "equals": return expected.some((value) => answer === value);
    case "notEquals": return expected.every((value) => answer !== value);
    case "contains": return expected.some((value) => values.includes(value));
    case "notContains": return expected.every((value) => !values.includes(value));
    case "greaterThan": return typeof answer === "number" &&
        typeof expected[0] === "number" && answer > expected[0];
    case "lessThan": return typeof answer === "number" &&
        typeof expected[0] === "number" && answer < expected[0];
    }
  });
  return rule.conditionMode === "all" ? matches.every(Boolean) :
    matches.some(Boolean);
}

function validateQuestion(
  question: PublicFormQuestion,
  answer: PublicFormAnswer
): string | null {
  const invalid = question.validation.customError ??
    `${question.label} is invalid.`;
  if (question.kind === "email" &&
      (typeof answer !== "string" ||
       !/^[^\s@]+@[^\s@]+\.[^\s@]+$/u.test(answer))) return invalid;
  if (question.kind === "phone" &&
      (typeof answer !== "string" ||
       !/^\+[1-9][0-9]{7,14}$/u.test(answer.replace(/[\s()-]/gu, "")))) {
    return invalid;
  }
  if (question.kind === "url" && typeof answer === "string") {
    try {
      const url = new URL(answer);
      if (url.protocol !== "https:" && url.protocol !== "http:") return invalid;
    } catch {
      return invalid;
    }
  }
  if (typeof answer === "string") {
    const length = answer.trim().length;
    if (question.validation.minLength !== null &&
        length < question.validation.minLength) return invalid;
    if (question.validation.maxLength !== null &&
        length > question.validation.maxLength) return invalid;
  }
  if (typeof answer === "number") {
    if (question.validation.minNumber !== null &&
        answer < question.validation.minNumber) return invalid;
    if (question.validation.maxNumber !== null &&
        answer > question.validation.maxNumber) return invalid;
  }
  if (question.kind === "acknowledgement" && question.required &&
      answer !== true) return invalid;
  return null;
}

function isEmptyAnswer(answer: PublicFormAnswer | undefined) {
  return answer === undefined || answer === null || answer === "" ||
    (Array.isArray(answer) && answer.length === 0);
}
