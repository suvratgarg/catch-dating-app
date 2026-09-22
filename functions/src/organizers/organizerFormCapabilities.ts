import type {OrganizerFormDraftDocument} from
  "../shared/generated/organizerFormDraftDocument";
import {personFieldCatalog} from
  "../shared/generated/catalogs/personFieldCatalog";

type Definition = Pick<OrganizerFormDraftDocument["definition"],
  "identityPolicy" | "sections" | "payment" | "messagingConsent">;
type Question = Definition["sections"][number]["questions"][number];
type AddIssue = (code: string, path: string, message: string) => void;

/** Legacy mappings are classification only, never a sharing instruction. */
export function formAnswerDestination(question: Question):
  NonNullable<Question["answerDestination"]> {
  return question.answerDestination ?? "organizerOnly";
}

export function validateFormCapabilities(definition: Definition,
  add: AddIssue): void {
  const questions = definition.sections.flatMap((section) => section.questions);
  const preparesProfile = questions.some((question) =>
    formAnswerDestination(question) !== "organizerOnly");
  const asksWhatsapp =
    definition.messagingConsent?.organizerWhatsapp === true ||
    definition.messagingConsent?.catchWhatsapp === true;
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
