import type {ResolveOrganizerCommunicationPlanCallableResponse} from
  "../shared/generated/resolveOrganizerCommunicationPlanCallableResponse";

export const organizerCommunicationPlanCapabilityVersion = 2;

export type IndividualCommunicationContactFacts = Readonly<{
  contactId: string;
  displayName: string;
  linkedUid: string | null;
  identityState: "unlinked" | "verified" | "ambiguous";
  ambiguousCandidateCount: number;
  phoneE164: string | null;
  email: string | null;
  whatsappStatus: "unknown" | "optedIn" | "optedOut";
  whatsappAdminSuppressed: boolean;
}>;

type RecipientPlan =
  ResolveOrganizerCommunicationPlanCallableResponse["recipients"][number];
type RouteOption = RecipientPlan["routes"][number];

/**
 * Derives the available routes for one individual conversation intent.
 *
 * This is a momentary projection. It is never persisted as a property of the
 * contact, and every mutation must recheck the underlying facts.
 */
export function resolveIndividualCommunicationPlan(
  contact: IndividualCommunicationContactFacts
): RecipientPlan {
  const catchChat = catchChatRoute(contact);
  const personalHandoff = personalHandoffRoute(contact);
  const emailHandoff = emailHandoffRoute(contact);
  const recommended = catchChat.availability === "available" ? catchChat :
    personalHandoff.availability === "available" ? personalHandoff :
      emailHandoff.availability === "available" ? emailHandoff : null;
  return {
    contactId: contact.contactId,
    displayName: contact.displayName,
    outcome: recommended?.routeId === "catchChat" ? "inCatch" :
      recommended?.routeId === "personalWhatsappHandoff" ||
        recommended?.routeId === "personalEmailHandoff" ? "byHand" :
        "unavailable",
    recommendedRouteId: recommended?.routeId ?? null,
    routes: [catchChat, personalHandoff, emailHandoff],
  };
}

function catchChatRoute(
  contact: IndividualCommunicationContactFacts
): RouteOption {
  const blocker = contact.identityState === "ambiguous" ||
    contact.ambiguousCandidateCount > 0 ? "identityAmbiguous" :
    contact.linkedUid === null || contact.identityState !== "verified" ?
      "catchAccountRequired" : null;
  return {
    routeId: "catchChat",
    executionMode: "managedDelivery",
    availability: blocker === null ? "available" : "unavailable",
    blocker,
  };
}

function personalHandoffRoute(
  contact: IndividualCommunicationContactFacts
): RouteOption {
  const blocker = contact.phoneE164 === null ? "missingPhone" :
    contact.whatsappAdminSuppressed ? "organizerSuppressed" :
      contact.whatsappStatus === "optedOut" ? "contactOptedOut" : null;
  return {
    routeId: "personalWhatsappHandoff",
    executionMode: "externalHandoff",
    availability: blocker === null ? "available" : "unavailable",
    blocker,
  };
}

/**
 * Email is a handoff to the host's own mail app. Channel-state suppression
 * only tracks the WhatsApp transport today, so availability depends solely
 * on a recorded address.
 */
function emailHandoffRoute(
  contact: IndividualCommunicationContactFacts
): RouteOption {
  const blocker = contact.email?.trim() ? null : "missingEmail";
  return {
    routeId: "personalEmailHandoff",
    executionMode: "externalHandoff",
    availability: blocker === null ? "available" : "unavailable",
    blocker,
  };
}
