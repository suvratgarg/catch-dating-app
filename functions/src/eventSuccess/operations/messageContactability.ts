import type {Firestore, Transaction} from "firebase-admin/firestore";
import {operationContentHash} from "../../operations/durableActions";
import {validateOrganizerSenderConnectionDocument} from
  "../../shared/generated/validators/organizerSenderConnectionDocument";
import {readGuestSourceFacts, requireDocumentId} from "./guestRecords";
import type {MessageRecord} from "./messageOutbox";
import {smsCollections} from "./smsPermissionRecords";
import {parseSmsConfig} from "./smsProtocol";
import {whatsappConsentSender} from "./whatsappConsentSender";
import {WHATSAPP_POLICIES} from "./whatsappTemplate";
import {MessagePermissionScope, readSmsMessagePermission,
  readWhatsappMessagePermission} from "./messagePermissionReader";
import type {LateJoinAutomation} from "./messageProtocol";
import {parseRcsConfig} from "./rcsProtocol";
import {rcsConsentCollections, rcsStopHash} from "./rcsConsent";
import {readRcsMessagePermission} from "./rcsPermissionReader";

/** The trusted workflow chooses senders; consent never selects them. */
export type EventMessageRouteSelection = LateJoinAutomation["routes"][number];
type WireRoute = MessageRecord["intent"]["permittedRoutes"][number];
const completeRoutes: [
  Exclude<WireRoute, EventMessageRouteSelection["routeId"]>,
  Exclude<EventMessageRouteSelection["routeId"], WireRoute>,
] extends [never, never] ? true : false = true;
void completeRoutes;
export type MessagePurpose = "joiningUpdate" | Extract<
  MessageRecord["intent"], {kind: "operationalNotice"}>["noticeKind"];
type Scope = Omit<MessagePermissionScope, "senderId">;
export type Contactability = {route: EventMessageRouteSelection; state:
  | {kind: "canPrepare"; validUntil: number; evidenceHash: string}
  | {kind: "blocked"; reason: "notProvisioned" | "missingPermission" |
      "suppressed" | "templateUnavailable" | "eventClosed" |
      "notAdmitted"}};

/**
 * Pre-publication contactability, not dispatch authorization. Exact rendering,
 * credentials, budget and reservation/claim checks remain at the send boundary.
 * This internal reader does not read secrets or write grants/messages.
 */
export async function readEventMessageContactability(db: Firestore,
  tx: Transaction, scope: Scope,
  selections: readonly EventMessageRouteSelection[],
  purpose: MessagePurpose, now: number): Promise<Contactability[]> {
  if (!Number.isSafeInteger(now) || now < 0 || !selections.length ||
      selections.length > 3 ||
      new Set(selections.map((r) => r.routeId)).size !==
        selections.length) throw new Error("Invalid contactability scope");
  const source = await readGuestSourceFacts(db, tx, scope.context,
    scope.attendeeId);
  const serviceEnd = Math.floor(source.eventEnd) + 86_400_000;
  const results: Contactability[] = [];
  for (const route of selections) {
    const blocked = (reason: Extract<Contactability["state"],
      {kind: "blocked"}>["reason"]): Contactability =>
      ({route, state: {kind: "blocked", reason}});
    if (now >= serviceEnd) {
      results.push(blocked("eventClosed")); continue;
    }
    const admitted = ["registered", "checkedIn"]
      .includes(source.attendeeStatus);
    if (!admitted && !(purpose === "eventCancelled" &&
        source.eventStatus === "cancelled" &&
        source.attendeeStatus === "cancelled")) {
      results.push(blocked("notAdmitted")); continue;
    }
    switch (route.routeId) {
    case "catchEventRcs": {
      requireDocumentId(route.senderId);
      const snap = await tx.get(db.collection(rcsConsentCollections.senders)
        .doc(route.senderId));
      if (!snap.exists) {
        results.push(blocked("notProvisioned")); break;
      }
      const sender = parseRcsConfig(snap.data());
      if (sender.senderId !== route.senderId || sender.status !== "ready" ||
          sender.activation.approvedAt > now ||
          now >= Math.min(sender.activation.validUntil,
            sender.quote.validUntil)) {
        results.push(blocked("notProvisioned")); break;
      }
      if (!sender.allowedPurposes.includes(purpose)) {
        results.push(blocked("templateUnavailable")); break;
      }
      const consent = await readRcsMessagePermission(db, tx,
        {...scope, senderId: route.senderId}, sender, now);
      if (consent.kind === "blocked") {
        results.push(blocked(consent.reason)); break;
      }
      if (!sender.recipientPrefixes.some((prefix) =>
        consent.permission.phoneE164.startsWith(prefix))) {
        results.push(blocked("notProvisioned")); break;
      }
      results.push({route, state: {kind: "canPrepare",
        validUntil: Math.min(now + 30_000, serviceEnd,
          consent.permission.expiresAt, sender.activation.validUntil,
          sender.quote.validUntil), evidenceHash: operationContentHash([
          scope, purpose, sender, consent.permission,
          rcsStopHash(consent.subscription)])}});
      break;
    }
    case "catchEventSms": {
      requireDocumentId(route.senderId);
      const snap = await tx.get(db.collection(smsCollections.senders)
        .doc(route.senderId));
      if (!snap.exists) {
        results.push(blocked("notProvisioned")); break;
      }
      const sender = parseSmsConfig(snap.data());
      if (sender.senderId !== route.senderId || sender.status !== "ready" ||
          sender.activation.approvedAt > now ||
          now >= Math.min(sender.activation.validUntil,
            sender.quote.validUntil)) {
        results.push(blocked("notProvisioned")); break;
      }
      if (!sender.templates.some((t) =>
        t.status === "approved" && t.purpose === purpose)) {
        results.push(blocked("templateUnavailable")); break;
      }
      const consent = await readSmsMessagePermission(db, tx,
        {...scope, senderId: route.senderId}, now);
      if (consent.kind === "blocked") {
        results.push(blocked(consent.reason)); break;
      }
      results.push({route, state: {kind: "canPrepare",
        validUntil: Math.min(now + 30_000, serviceEnd,
          consent.permission.expiresAt, sender.activation.validUntil,
          sender.quote.validUntil), evidenceHash: operationContentHash([
          scope, purpose, sender, consent.permission])}});
      break;
    }
    case "organizerEventWhatsapp": {
      requireDocumentId(route.senderId);
      const [connectionSnap, policySnap] = await tx.getAll(
        db.collection("organizerSenderConnections").doc(route.senderId),
        db.collection(WHATSAPP_POLICIES).doc(route.senderId));
      const connection = connectionSnap.data();
      if (!validateOrganizerSenderConnectionDocument(connection)) {
        results.push(blocked("notProvisioned")); break;
      }
      const sender = whatsappConsentSender(route.senderId,
        scope.context.organizerId, connection, policySnap.data());
      const policy = sender?.policy;
      if (!sender?.connectionReady || !policy || policy.status !== "ready" ||
          policy.activation.approvedAt > now ||
          now >= Math.min(policy.activation.validUntil,
            policy.quote.validUntil)) {
        results.push(blocked("notProvisioned")); break;
      }
      if (!policy.templates.some((t) => t.purpose === purpose)) {
        results.push(blocked("templateUnavailable")); break;
      }
      const consent = await readWhatsappMessagePermission(db, tx,
        {...scope, senderId: route.senderId}, connection, now);
      if (consent.kind === "blocked") {
        results.push(blocked(consent.reason)); break;
      }
      if (!policy.quote.recipientPrefixes.some((prefix) =>
        consent.permission.phoneE164.startsWith(prefix))) {
        results.push(blocked("notProvisioned")); break;
      }
      results.push({route, state: {kind: "canPrepare",
        validUntil: Math.min(now + 30_000, serviceEnd,
          consent.permission.expiresAt, policy.activation.validUntil,
          policy.quote.validUntil), evidenceHash: operationContentHash([
          scope, purpose, connection, policy,
          consent.permission, consent.stop])}});
      break;
    }
    default: {
      const unhandled: never = route;
      void unhandled;
      throw new Error("Unknown event-service route");
    }
    }
  }
  return results;
}
