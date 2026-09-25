import type {OrganizerFormDraftDocument} from
  "../shared/generated/organizerFormDraftDocument";
import {personFieldCatalog} from
  "../shared/generated/catalogs/personFieldCatalog";
import {HttpsError} from "firebase-functions/v2/https";

type Definition = Pick<OrganizerFormDraftDocument["definition"],
  "identityPolicy" | "sections" | "payment" | "messagingConsent" |
  "eventProfile" | "logicRules">;
type Question = Definition["sections"][number]["questions"][number];
type AddIssue = (code: string, path: string, message: string) => void;

/** Legacy mappings are classification only, never a sharing instruction. */
export function formAnswerDestination(question: Question):
  NonNullable<Question["answerDestination"]> {
  return question.answerDestination ?? "organizerOnly";
}

/** The free endpoint can never bypass a published fee. */
export function requireFreeFormSubmission(definition: Pick<Definition,
  "payment">): void {
  if (definition.payment) {
    throw new HttpsError("failed-precondition",
      "Complete the form payment before submitting this response.");
  }
}

export function validateFormCapabilities(definition: Definition,
  add: AddIssue): void {
  const questions = definition.sections.flatMap((section) => section.questions);
  const profileQuestions = questions.filter((question) =>
    formAnswerDestination(question) !== "organizerOnly");
  if (profileQuestions.length > 100) {
    add("tooManyProfileFields", "sections",
      "Use at most 100 Catch profile and organizer card fields in one form.");
  }
  const profileFields = new Set<string>();
  for (const question of profileQuestions) {
    if (formAnswerDestination(question) !== "catchProfile" ||
        !question.canonicalFieldId) continue;
    if (profileFields.has(question.canonicalFieldId)) {
      add("duplicateProfileField", "sections",
        "Use each Catch profile building block once in a form.");
    }
    profileFields.add(question.canonicalFieldId);
  }
  const catchQuestions = new Set(questions.filter((question) =>
    formAnswerDestination(question) === "catchProfile")
    .map((question) => question.questionId));
  const reusableCatchQuestions = new Set(questions.filter((question) =>
    catchQuestions.has(question.questionId) &&
    question.prefillPolicy === "participantReviewRequired")
    .map((question) => question.questionId));
  for (const rule of definition.logicRules) {
    if (rule.conditions.some((condition) =>
      catchQuestions.has(condition.questionId)) ||
      (rule.targetQuestionId !== null &&
        catchQuestions.has(rule.targetQuestionId))) {
      add("catchFieldCustomLogic", "logicRules",
        "Catch fields use built-in behavior and cannot be used " +
        "in custom logic.");
    }
  }
  const preparesProfile = questions.some((question) =>
    formAnswerDestination(question) !== "organizerOnly");
  const proposedProfileRows = questions.filter((question) =>
    question.answerAudience?.mode === "eventMembersWithConsent");
  if (proposedProfileRows.length >
      (definition.eventProfile?.maxCustomRows ?? 0)) {
    add("tooManyEventProfileRows", "eventProfile.maxCustomRows",
      "Keep shared custom rows within the event profile limit.");
  }
  const asksWhatsapp =
    definition.messagingConsent?.organizerWhatsapp === true ||
    definition.messagingConsent?.catchWhatsapp === true;
  const asksPendingWhatsapp =
    definition.messagingConsent?.organizerOperationsWhatsapp === true ||
    definition.messagingConsent?.organizerMarketingWhatsapp === true ||
    definition.messagingConsent?.catchMarketingWhatsapp === true;
  if (asksWhatsapp && asksPendingWhatsapp) {
    add("mixedMessagingTerms", "messagingConsent",
      "Publish either legacy messaging copy or separately scoped " +
      "purpose choices.");
  }
  if ((preparesProfile || asksWhatsapp || definition.payment) &&
      definition.identityPolicy !== "phoneVerified") {
    add("verifiedPhoneRequired", "identityPolicy",
      "Use phone verification for payments, profiles or WhatsApp consent.");
  }
  if (definition.payment) {
    const payment = definition.payment;
    if (!Number.isSafeInteger(payment.amountPaise) ||
        payment.amountPaise < 100 || payment.amountPaise > 10_000_000 ||
        payment.currency !== "INR") {
      add("invalidFormFee", "payment.amountPaise",
        "Enter a fee in Indian rupees within the supported range.");
    }
    if (!payment.description.trim()) {
      add("missingFeeDescription", "payment.description",
        "Explain what this fee is for.");
    }
    if (!payment.refundPolicy.trim()) {
      add("missingRefundPolicy", "payment.refundPolicy",
        "Explain when the organizer will refund this fee.");
    }
  }
  definition.sections.forEach((section, sectionIndex) => {
    section.questions.forEach((question, questionIndex) => {
      const path = `sections.${sectionIndex}.questions.${questionIndex}`;
      const destination = formAnswerDestination(question);
      const audience = question.answerAudience;
      if (audience?.mode === "organizerOnly" &&
          audience.eventProfileSlot !== null) {
        add("privateAudienceSlot", `${path}.answerAudience`,
          "Private answers cannot name an attendee profile slot.");
      }
      if (audience?.mode === "eventMembersWithConsent" &&
          (audience.eventProfileSlot !== "customRow" ||
            destination !== "organizerCard" ||
            definition.eventProfile?.enabled !== true ||
            !definition.eventProfile.allowedSlots.includes("customRow"))) {
        add("invalidEventProfileAudience", `${path}.answerAudience`,
          "Enable event profile custom rows and choose an organizer card " +
          "answer.");
      }
      if (destination === "catchProfile" && !question.canonicalFieldId) {
        add("profileFieldRequired", `${path}.canonicalFieldId`,
          "Choose a Catch profile building block for this answer.");
      }
      if (destination === "catchProfile" && question.canonicalFieldId) {
        const field = personFieldCatalog.fields.find((candidate) =>
          candidate.id === question.canonicalFieldId);
        if (!field || field.authority === "derived") {
          add("profileSourceRequired", `${path}.canonicalFieldId`,
            "Use a source profile field, such as date of birth for age.");
        } else if (field.questionKind !== question.kind &&
            !(field.questionKind === "shortText" &&
              question.kind === "singleChoice")) {
          add("profileKindMismatch", `${path}.kind`,
            "Use the answer type supported by this Catch profile field.");
        }
      }
      if (catchQuestions.has(question.questionId)) {
        if (question.validation.patternPreset !== null ||
            question.validation.customError !== null) {
          add("catchFieldCustomValidation", `${path}.validation`,
            "Catch fields use their built-in validation.");
        }
      }
      if (reusableCatchQuestions.has(question.questionId) &&
          sectionIndex !== 0) {
        add("catchFieldFirstPage", path,
          "Place reusable Catch fields on the first page.");
      }
      if (destination !== "organizerOnly" &&
          (question.kind === "acknowledgement" ||
            question.kind === "signature")) {
        add("privateResponseOnly", `${path}.answerDestination`,
          "Acknowledgements and signatures belong only in the form response.");
      }
      if (destination !== "organizerOnly" && question.kind === "file") {
        const validation = question.validation;
        const mimeTypes = validation.allowedMimeTypes;
        if ((destination === "catchProfile" &&
              question.canonicalFieldId !== "profilePhoto") ||
            validation.maxFileCount !== 1 ||
            validation.maxFileSizeBytes === null ||
            validation.maxFileSizeBytes > 10 * 1024 * 1024 ||
            mimeTypes.length === 0 || mimeTypes.some((mime) =>
          !["image/jpeg", "image/png", "image/webp"].includes(mime))) {
          add("profileImageOnly", `${path}.validation`,
            "Use one JPEG, PNG or WebP image up to 10 MB for a profile card.");
        }
      }
    });
  });
}
