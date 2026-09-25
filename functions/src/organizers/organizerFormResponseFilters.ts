import {HttpsError} from "firebase-functions/v2/https";
import type {OrganizerFormResponseDocument, OrganizerFormVersionDocument} from
  "../shared/generated/firestoreAdminTypes";

export interface AnswerFilter {
  questionId: string;
  values: string[];
}

/** Only explicitly promoted categorical questions become inbox filters. */
export function responseFilterOptions(
  definition: OrganizerFormVersionDocument["definition"]
) {
  return definition.sections.flatMap((section) => section.questions)
    .filter((question) => question.hostPresentation === "filterable" &&
      question.privacyClass !== "sensitive" &&
      ["singleChoice", "multiChoice"].includes(question.kind))
    .map((question) => ({questionId: question.questionId, label: question.label,
      options: question.options.map(({value, label}) => ({value, label}))}));
}

export function validateResponseFilters(
  filters: AnswerFilter[],
  options: ReturnType<typeof responseFilterOptions>
) {
  const seen = new Set<string>();
  for (const filter of filters) {
    const question = options.find((item) =>
      item.questionId === filter.questionId);
    if (seen.has(filter.questionId) || !question ||
        filter.values.some((value) =>
          !question.options.some((option) => option.value === value))) {
      throw new HttpsError("invalid-argument", "Response filter is invalid.");
    }
    seen.add(filter.questionId);
  }
}

/** AND across questions, OR across values; never match withdrawn answers. */
export function matchesAnswerFilters(
  response: Pick<OrganizerFormResponseDocument, "status" | "answerSnapshots">,
  definition: OrganizerFormVersionDocument["definition"],
  filters: AnswerFilter[]
): boolean {
  if (filters.length === 0) return true;
  if (response.status === "withdrawn") return false;
  const allowed = new Set(responseFilterOptions(definition)
    .map((question) => question.questionId));
  return filters.every((filter) => {
    if (!allowed.has(filter.questionId)) return false;
    const answer = response.answerSnapshots.find((item) =>
      item.questionId === filter.questionId)?.answer;
    const values = Array.isArray(answer) ? answer : [answer];
    return filter.values.some((value) => values.includes(value));
  });
}
