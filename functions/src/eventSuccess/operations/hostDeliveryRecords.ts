import type {DocumentSnapshot} from "firebase-admin/firestore";
import {operationContentHash} from "../../operations/durableActions";
import type {OrganizerDocument} from
  "../../shared/generated/firestoreAdminTypes";
import type {EventAssistanceDeliveriesCallableResponse as Response} from
  "../../shared/generated/eventAssistanceDeliveriesCallableResponse";
import {validateEventAttendeeDocument} from
  "../../shared/generated/validators/eventAttendeeDocument";
import {isOrganizerManager} from "../../shared/organizerHosts";
import {guestIdentity, guestSourceFactsFromSnapshots, parseGuest,
  messageWindowOpen, guestCanReceiveMessage} from "./guestRecords";
import {invalidSource} from "./groupProgressSource";
import {sameMessageContext} from "./messagingPolicy";
import {MessageRecord, parseMessageRecord} from "./messageOutbox";
import {assertDeliveryMessage, readDeliveryWorkRecords} from
  "./deliveryWorkRecords";

export type HostDeliveryView = Response["deliveries"][number];
export type DeliveryCoordination = ReturnType<typeof readDeliveryWorkRecords>;

export function parseHostDelivery(value: unknown, id: string,
  context: Response["context"], now: number): MessageRecord {
  const record = parseMessageRecord(value);
  if (record.messageId !== id || record.intent.context.mode !== "live" ||
      !sameMessageContext(record.intent.context, context) ||
      record.intent.eventId !== context.eventId || record.updatedAt > now) {
    throw invalidSource();
  }
  return record;
}

/** Pending submissions outrank failures on other routes. */
export function hostDeliveryStatus(message: MessageRecord):
  HostDeliveryView["deliveryStatus"] {
  if (message.deliveryConflict) return "conflictingEvidence";
  const states = message.attempts.map((a) => a.state.kind);
  for (const state of ["read", "delivered", "unknown", "accepted",
    "reserved"] as const) {
    if (states.includes(state)) return state;
  }
  return message.attempts.at(-1)?.state.kind ?? "notSubmitted";
}

/** A host review never exposes routes, recipient endpoints or bearer links. */
export function projectHostDelivery(message: MessageRecord,
  event: DocumentSnapshot, attendee: DocumentSnapshot,
  guestSnapshot: DocumentSnapshot, organizer: OrganizerDocument,
  work: DeliveryCoordination | null, now: number): HostDeliveryView {
  const intent = message.intent;
  if (intent.context.mode !== "live") throw invalidSource();
  if (work) assertDeliveryMessage(work.payload, message);
  const row = attendee.data();
  const source = row && row.eventId === intent.eventId &&
    row.organizerId === intent.context.organizerId ? (() => {
      if (!validateEventAttendeeDocument(row)) throw invalidSource();
      return guestSourceFactsFromSnapshots(intent.context, intent.attendeeId,
        event, attendee);
    })() : null;
  const rawGuest = guestSnapshot.data();
  const guest = rawGuest === undefined ? null : parseGuest(rawGuest);
  if (guest && (guest.guestId !== guestSnapshot.id ||
      guest.guestId !== guestIdentity(intent.context, intent.attendeeId) ||
      guest.updatedAt > now)) throw invalidSource();
  const current = !!source && !!guest &&
    guest.episodeId === intent.episodeId &&
    guest.attendeeGeneration === source.attendeeGeneration &&
    guest.sourceGeneration === source.sourceGeneration;
  const ownerCurrent = !!message.handoff &&
    isOrganizerManager(organizer, message.handoff.actorUid);
  const handling: HostDeliveryView["handling"] = message.handoff ?
    {kind: "manual", actorUid: message.handoff.actorUid,
      at: message.handoff.at, authority: ownerCurrent ? "current" : "revoked"} :
    {kind: "automatic"};
  const c = work?.payload.checkpoint;
  const coordination: HostDeliveryView["coordination"] = c ?
    {kind: "tracked", phase: c.phase, reason: c.reason, dueAt: c.dueAt} :
    {kind: "untracked"};
  const deliveryStatus = hostDeliveryStatus(message);
  const common = {messageId: message.messageId, revision: message.revision,
    reviewHash: operationContentHash([message, source, guest, work,
      ownerCurrent]), createdAt: message.createdAt,
    expiresAt: intent.expiresAt, lifecycle: message.lifecycle, deliveryStatus,
    purpose: intent.kind === "joiningUpdate" ?
      "joiningUpdate" as const : intent.noticeKind,
    attempts: message.attempts.map((a) => {
      if (a.mode !== "live") throw invalidSource();
      return {channel: a.binding.transport, state: a.state.kind,
        at: a.state.at};
    }), coordination, handling};
  if (!current) {
    return {...common, availability: "sourceChanged",
      attendeeId: null, actions: []};
  }
  const relevant = message.lifecycle === "active" &&
    now < intent.expiresAt && messageWindowOpen(intent, source, now) &&
    guestCanReceiveMessage(guest, source, intent) &&
    (intent.kind !== "joiningUpdate" ||
      (source.attendeeStatus !== "checkedIn" &&
        guest.intention.kind !== "notComing"));
  const resolved = message.response !== null ||
    message.attempts.some((a) =>
      a.state.kind === "read" || a.state.kind === "delivered");
  return {...common, availability: "current", attendeeId: intent.attendeeId,
    actions: relevant && !resolved && !ownerCurrent ? ["manualHandoff"] : []};
}
