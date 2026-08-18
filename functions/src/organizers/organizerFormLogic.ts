import type {
  OrganizerFormResponseDraftDocument,
  OrganizerFormVersionDocument,
} from "../shared/generated/firestoreAdminTypes";

type FormDefinition = OrganizerFormVersionDocument["definition"];
type AnswerMap = OrganizerFormResponseDraftDocument["answers"];
type FormSection = FormDefinition["sections"][number];

interface IndexedSection {
  section: FormSection;
  originalIndex: number;
}

/**
 * Resolves visibility gates and forward-only navigation into the exact ordered
 * section path a respondent can review and submit for one answer snapshot.
 */
export function reachableFormSections(
  definition: FormDefinition,
  answers: AnswerMap
): FormSection[] {
  const matchingRules = definition.logicRules.filter((rule) =>
    formLogicRuleMatches(rule, answers));
  const visible = visibleSections(definition, matchingRules);
  const questionSection = questionSectionIndexes(definition);
  const result: FormSection[] = [];
  let cursor = 0;
  while (cursor < visible.length) {
    const current = visible[cursor];
    result.push(current.section);
    const navigation = matchingRules.find((rule) => {
      if (rule.action !== "routeToSection" && rule.action !== "finish") {
        return false;
      }
      const sourceIndex = Math.max(...rule.conditions.map((condition) =>
        questionSection.get(condition.questionId) ?? -1));
      return sourceIndex === current.originalIndex;
    });
    if (navigation?.action === "finish") break;
    if (navigation?.action === "routeToSection" &&
        navigation.targetSectionId) {
      const targetIndex = definition.sections.findIndex((section) =>
        section.sectionId === navigation.targetSectionId);
      const next = visible.findIndex((section) =>
        section.originalIndex >= targetIndex);
      if (next < 0 || next <= cursor) break;
      cursor = next;
      continue;
    }
    cursor += 1;
  }
  return result;
}

/** Removes stale answers that are not on the respondent's resolved path. */
export function answersForSubmission(
  definition: FormDefinition,
  answers: AnswerMap
): AnswerMap {
  const reachableQuestionIds = new Set(
    reachableFormSections(definition, answers).flatMap((section) =>
      section.questions.map((question) => question.questionId))
  );
  return Object.fromEntries(
    Object.entries(answers).filter(([questionId]) =>
      reachableQuestionIds.has(questionId))
  );
}

function visibleSections(
  definition: FormDefinition,
  matchingRules: FormDefinition["logicRules"]
): IndexedSection[] {
  const allShowSections = ruleTargets(definition, "showSection", "section");
  const shownSections = ruleTargetsFrom(
    matchingRules, "showSection", "section"
  );
  const hiddenSections = ruleTargetsFrom(
    matchingRules, "hideSection", "section"
  );
  const allShowQuestions = ruleTargets(definition, "showQuestion", "question");
  const shownQuestions = ruleTargetsFrom(
    matchingRules, "showQuestion", "question"
  );
  const hiddenQuestions = ruleTargetsFrom(
    matchingRules, "hideQuestion", "question"
  );
  return definition.sections.flatMap((section, originalIndex) => {
    const gated = allShowSections.has(section.sectionId) &&
      !shownSections.has(section.sectionId);
    if (gated || hiddenSections.has(section.sectionId)) return [];
    return [{
      originalIndex,
      section: {
        ...section,
        questions: section.questions.filter((question) => {
          const questionGated = allShowQuestions.has(question.questionId) &&
            !shownQuestions.has(question.questionId);
          return !questionGated && !hiddenQuestions.has(question.questionId);
        }),
      },
    }];
  });
}

function ruleTargets(
  definition: FormDefinition,
  action: "showSection" | "showQuestion",
  kind: "section" | "question"
): Set<string> {
  return ruleTargetsFrom(definition.logicRules, action, kind);
}

function ruleTargetsFrom(
  rules: FormDefinition["logicRules"],
  action: "showSection" | "hideSection" | "showQuestion" | "hideQuestion",
  kind: "section" | "question"
): Set<string> {
  return new Set(rules.flatMap((rule) => {
    if (rule.action !== action) return [];
    const target = kind === "section" ?
      rule.targetSectionId : rule.targetQuestionId;
    return target ? [target] : [];
  }));
}

function questionSectionIndexes(
  definition: FormDefinition
): Map<string, number> {
  const indexes = new Map<string, number>();
  definition.sections.forEach((section, sectionIndex) => {
    section.questions.forEach((question) =>
      indexes.set(question.questionId, sectionIndex));
  });
  return indexes;
}

function formLogicRuleMatches(
  rule: FormDefinition["logicRules"][number],
  answers: AnswerMap
): boolean {
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
    case "notContains":
      return expected.every((value) => !values.includes(value));
    case "greaterThan":
      return typeof answer === "number" &&
        typeof expected[0] === "number" && answer > expected[0];
    case "lessThan":
      return typeof answer === "number" &&
        typeof expected[0] === "number" && answer < expected[0];
    }
  });
  return rule.conditionMode === "all" ?
    matches.every(Boolean) : matches.some(Boolean);
}

function isEmptyAnswer(value: AnswerMap[string] | undefined): boolean {
  return value === undefined || value === null || value === "" ||
    (Array.isArray(value) && value.length === 0);
}
