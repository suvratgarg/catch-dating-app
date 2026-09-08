import type {SourceWork, ReadinessSourceScope} from "./sourceWorkRecords";
import {rcsSubscriptionId} from "./rcsSubscriptions";

type Collection = SourceWork["source"]["collection"];
type Value = Record<string, unknown>;

export function readinessScope(collection: Collection, documentId: string,
  value: Value): ReadinessSourceScope | null {
  switch (collection) {
  case "eventAssistanceRcsSenders":
    return sender("catchEventRcs", documentId);
  case "eventAssistanceRcsBudgets":
    return sender("catchEventRcs", value.senderId);
  case "eventAssistanceRcsSubscriptions": {
    if (typeof value.agentId !== "string" ||
        typeof value.endpointHash !== "string") return null;
    const subscriptionId = rcsSubscriptionId(value.agentId, value.endpointHash);
    if (value.subscriptionId !== subscriptionId ||
        documentId !== subscriptionId) return null;
    return {kind: "rcsSubscription", subscriptionId};
  }
  case "eventAssistanceSmsSenders":
    return sender("catchEventSms", documentId);
  case "eventAssistanceSmsBudgets":
    return sender("catchEventSms", value.senderId);
  case "organizerSenderConnections":
    return value.channel === "whatsapp" ?
      sender("organizerEventWhatsapp", documentId) : null;
  case "eventAssistanceWhatsappPolicies":
    return sender("organizerEventWhatsapp", documentId);
  case "organizerMessageTemplates":
    return sender("organizerEventWhatsapp", value.connectionId);
  case "eventAssistanceWhatsappBudgets":
    return sender("organizerEventWhatsapp", value.senderId);
  case "organizerContactChannelStates":
    if (value.channel !== "whatsapp") return null;
    // Falls through to the same organizer/endpoint scope as provider STOP.
  case "organizerWhatsappEndpointStops":
    if (typeof value.organizerId !== "string" ||
        typeof value.endpointHash !== "string" ||
        !/^[a-f0-9]{64}$/.test(value.endpointHash)) return null;
    return {kind: "whatsappEndpoint", organizerId: value.organizerId,
      recipientEndpointId: "whatsapp:" + value.endpointHash};
  default: return null;
  }
}

function sender(routeId: Extract<ReadinessSourceScope,
  {kind: "sender"}>["routeId"],
senderId: unknown): ReadinessSourceScope | null {
  return typeof senderId === "string" ? {kind: "sender", routeId,
    senderId} : null;
}

/** Dispatch debits and inbox counters are not repair notifications. */
export function readinessFields(collection: Collection): string[] | null {
  switch (collection) {
  case "eventAssistanceRcsSubscriptions":
    return ["subscriptionId", "agentId", "endpointHash", "lastStop"];
  case "eventAssistanceRcsBudgets":
    return ["senderId", "agentId", "scope", "status", "approvalId", "currency",
      "limitMicros", "startsAt", "endsAt"];
  case "eventAssistanceSmsBudgets":
  case "eventAssistanceWhatsappBudgets":
    return ["senderId", "scope", "status", "approvalId", "currency",
      "limitMicros", "startsAt", "endsAt"];
  case "organizerContactChannelStates":
    return ["organizerId", "contactId", "channel", "endpointHash",
      "adminSuppressed", "suppressionStatus", "suppressionSource"];
  default: return null;
  }
}

export function spendingReleased(collection: Collection,
  before: Value | undefined, after: Value | undefined) {
  return (collection === "eventAssistanceSmsBudgets" ||
    collection === "eventAssistanceWhatsappBudgets" ||
    collection === "eventAssistanceRcsBudgets") &&
    typeof before?.chargedMicros === "number" &&
    typeof after?.chargedMicros === "number" &&
    after.chargedMicros < before.chargedMicros;
}
