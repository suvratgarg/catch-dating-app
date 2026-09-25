import type {OrganizerFormVersionDocument, ParticipantIntakeProfileDocument,
  UserProfileDocument} from "../shared/generated/firestoreAdminTypes";
import {canonicalMarkets, marketForIdOrAlias} from "../locations/marketConfig";

type Definition = OrganizerFormVersionDocument["definition"];
type Question = Definition["sections"][number]["questions"][number];
type Answer = string | number | boolean | null | string[];
type IntakeField = ParticipantIntakeProfileDocument["fields"][number];

/** Uses the market records shared by people, organizers, and events. */
export function publicFormCityOptions() {
  return canonicalMarkets.filter((market) =>
    market.countryIsoCode === "IN").map((market) => ({
    marketId: market.marketId,
    cityId: market.cityId,
    label: market.cityLabel,
    regionName: market.regionName,
    countryIsoCode: market.countryIsoCode,
  }));
}

export function canonicalCityMarketId(value: unknown): string | null {
  if (typeof value !== "string") return null;
  const market = marketForIdOrAlias(value);
  return market?.countryIsoCode === "IN" ? market.marketId : null;
}

/** Returns private suggestions to a verified respondent. */
export function publicFormPrefillSuggestions(params: {
  definition: Definition;
  intake?: ParticipantIntakeProfileDocument;
  profile?: UserProfileDocument;
  verifiedPhone: string | null;
}): Record<string, Answer> {
  const suggestions: Record<string, Answer> = {};
  const portable = new Map(params.intake?.fields.map((field) =>
    [field.canonicalFieldId, field]) ?? []);
  for (const section of params.definition.sections) {
    for (const question of section.questions) {
      if (question.answerDestination !== "catchProfile" ||
          question.prefillPolicy !== "participantReviewRequired" ||
          !question.canonicalFieldId) continue;
      const value = question.canonicalFieldId === "phoneNumber" ?
        params.verifiedPhone :
        portableAnswer(portable.get(question.canonicalFieldId)) ??
          profileAnswer(question.canonicalFieldId, params.profile);
      const normalized = question.canonicalFieldId === "city" ?
        canonicalCityMarketId(value) : value;
      if (matchesQuestion(question, normalized)) {
        suggestions[question.questionId] = normalized as Answer;
      }
    }
  }
  return suggestions;
}

/** Submission is the participant's review point for reusable private fields. */
export function reusablePublicFormFields(
  definition: Definition,
  answers: Record<string, Answer>,
  now: FirebaseFirestore.Timestamp
): IntakeField[] {
  const fields: IntakeField[] = [];
  for (const section of definition.sections) {
    for (const question of section.questions) {
      if (question.answerDestination !== "catchProfile" ||
          question.prefillPolicy !== "participantReviewRequired" ||
          !question.canonicalFieldId) continue;
      const answer = answers[question.questionId];
      if (!matchesQuestion(question, answer)) continue;
      const normalized = question.canonicalFieldId === "city" ?
        canonicalCityMarketId(answer) : answer;
      if (!matchesQuestion(question, normalized)) continue;
      const value = intakeValue(question, normalized as Answer);
      if (!value) continue;
      fields.push({canonicalFieldId: question.canonicalFieldId, value,
        sourceApplicationId: null, reviewedByParticipantAt: now,
        updatedAt: now});
    }
  }
  return fields;
}

function portableAnswer(field?: IntakeField): Answer | undefined {
  if (!field) return undefined;
  const value = field.value;
  switch (value.valueKind) {
  case "text": return value.textValue ?? undefined;
  case "date": return value.dateValue ?? undefined;
  case "number": return value.numberValue ?? undefined;
  case "boolean": return value.booleanValue ?? undefined;
  case "options": return value.optionValues.length === 1 ?
    value.optionValues[0] : value.optionValues;
  default: return undefined;
  }
}

function profileAnswer(fieldId: string, profile?: UserProfileDocument):
  Answer | undefined {
  if (!profile || profile.deleted) return undefined;
  switch (fieldId) {
  case "givenName": return profile.firstName;
  case "familyName": return profile.lastName;
  case "displayName": return profile.displayName;
  case "email": return profile.email;
  case "city": return profile.city ?? undefined;
  case "gender": return profile.gender;
  case "dateOfBirth": return profile.dateOfBirth?.toDate()
    .toISOString().slice(0, 10);
  case "instagramHandle": return profile.instagramHandle ?? undefined;
  case "occupation": return profile.occupation ?? undefined;
  case "company": return profile.company ?? undefined;
  default: return undefined;
  }
}

function matchesQuestion(question: Question, value: unknown): value is Answer {
  if (value === undefined || value === null || value === "") return false;
  if (question.canonicalFieldId === "city") {
    return typeof value === "string" &&
      canonicalCityMarketId(value) === value;
  }
  switch (question.kind) {
  case "shortText": case "longText": case "email": case "phone":
  case "url": case "date": return typeof value === "string";
  case "number": return typeof value === "number" && Number.isFinite(value);
  case "boolean": case "acknowledgement": return typeof value === "boolean";
  case "singleChoice": return typeof value === "string" &&
    question.options.some((option) => option.value === value);
  case "multiChoice": return Array.isArray(value) && value.every((item) =>
    typeof item === "string" && question.options.some((option) =>
      option.value === item));
  default: return false;
  }
}

function intakeValue(question: Question, value: Answer):
  IntakeField["value"] | null {
  const base: IntakeField["value"] = {valueKind: "empty", textValue: null,
    numberValue: null, booleanValue: null, dateValue: null, optionValues: [],
    assetIds: []};
  if (typeof value === "string") {
    return question.kind === "date" ? {...base, valueKind: "date",
      dateValue: value} : question.kind === "singleChoice" ?
      {...base, valueKind: "options", optionValues: [value]} :
      {...base, valueKind: "text", textValue: value};
  }
  if (typeof value === "number") {
    return {...base, valueKind: "number",
      numberValue: value};
  }
  if (typeof value === "boolean") {
    return {...base, valueKind: "boolean",
      booleanValue: value};
  }
  if (Array.isArray(value)) {
    return {...base, valueKind: "options",
      optionValues: value};
  }
  return null;
}
