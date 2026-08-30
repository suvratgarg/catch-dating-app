import {ResolveOrganizerCommunicationPlanCallableResponse} from
  "../shared/generated/resolveOrganizerCommunicationPlanCallableResponse";

export const organizerCommunicationPlanCapabilityVersion = 1;

export type IndividualCommunicationContactFacts = Readonly<{
  contactId: string;
  displayName: string;
  linkedUid: string | null;
  identityState: "unlinked" | "verified" | "ambiguous";
  ambiguousCandidateCount: number;
  phoneE164: string | null;
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
  const recommended = catchChat.availability === "available" ? catchChat :
    personalHandoff.availability === "available" ? personalHandoff : null;
  return {
    contactId: contact.contactId,
    displayName: contact.displayName,
    outcome: recommended?.routeId === "catchChat" ? "inCatch" :
      recommended?.routeId === "personalWhatsappHandoff" ? "byHand" :
        "unavailable",
    recommendedRouteId: recommended?.routeId ?? null,
    routes: [catchChat, personalHandoff],
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
