import {HttpsError} from "firebase-functions/v2/https";
import type {EventRehearsalDocument as Session,
  EventRehearsalActorDocument as Actor, OrganizerDocument} from
  "../shared/generated/firestoreAdminTypes";
import type {EventRehearsalBootstrapCallableResponse as Bootstrap} from
  "../shared/generated/eventRehearsalBootstrapCallableResponse";
import type {ControlEventRehearsalCallablePayload as Control} from
  "../shared/generated/controlEventRehearsalCallablePayload";
import {operationContentHash as hash} from "../operations/durableActions";
import {isOrganizerManager} from "../shared/organizerHosts";
import {hostDeliveryStatus, manualDeliveryActions} from
  "../eventSuccess/operations/deliveryReviewPolicy";
import {parseMessageRecord} from "../eventSuccess/operations/messageOutbox";
import {practiceContext, practiceState, readPracticeMessage,
  PracticeMessage} from "./assistanceRuntime";

type Reviews = NonNullable<Bootstrap["deliveryReviews"]>;
type Review = Reviews["deliveries"][number];
type Repair = Extract<NonNullable<Control["assistance"]>,
  {kind: "repairDelivery"}>;

/** Shared evidence and handling shapes, without an Operations run. */
export function practiceDeliveryReview(session: Session, actor: Actor,
  message: PracticeMessage, organizer: OrganizerDocument): Review {
  readPracticeMessage(message, session, actor);
  const {record, handoff} = message;
  const now = session.virtualNow.toMillis();
  const end = session.virtualStartedAt.toMillis() +
    session.setup.durationMinutes * 60000;
  const ownerCurrent = !!handoff &&
    isOrganizerManager(organizer, handoff.actorUid);
  const relevant = record.lifecycle === "active" &&
    practiceState(actor).latestMessageId === record.messageId &&
    ["running", "paused"].includes(session.status) &&
    now < record.intent.expiresAt && now < end &&
    ["expected", "disconnected"].includes(actor.status) &&
    practiceState(actor).intention.kind !== "notComing";
  return {messageId: record.messageId, revision: record.revision,
    reviewHash: hash([message, {actorId: actor.actorId, status: actor.status,
      state: practiceState(actor),
      automation: actor.assistanceAutomation ?? null,
      createdAt: [actor.createdAt.seconds, actor.createdAt.nanoseconds],
      updatedAt: [actor.updatedAt.seconds, actor.updatedAt.nanoseconds]},
    practiceContext(session, actor),
    session.status, session.runtimeRevision, session.setup.durationMinutes,
    now, ownerCurrent]),
    createdAt: record.createdAt, expiresAt: record.intent.expiresAt,
    lifecycle: record.lifecycle, purpose: "joiningUpdate",
    deliveryStatus: hostDeliveryStatus(record),
    attempts: record.attempts.map((a) => {
      if (a.mode !== "rehearsal") throw invalid();
      const channels = {catchEventSms: "sms", catchEventRcs: "rcs",
        organizerEventWhatsapp: "whatsapp"} as const;
      return {channel: channels[a.routeId],
        state: a.state.kind, at: a.state.at};
    }), coordination: {kind: "untracked"}, handling: handoff ?
      {kind: "manual", actorUid: handoff.actorUid, at: handoff.at,
        authority: ownerCurrent ? "current" : "revoked"} : {kind: "automatic"},
    availability: "current", attendeeId: actor.actorId,
    actions: manualDeliveryActions(record, relevant, ownerCurrent)};
}

/** Current actor messages only; historical delivery totals are not inferred. */
export function practiceDeliveryReviews(sessionId: string, session: Session,
  actors: readonly Actor[], messages: readonly PracticeMessage[],
  organizer: OrganizerDocument, actorUid: string): Reviews {
  if (!isOrganizerManager(organizer, actorUid)) {
    throw new HttpsError("permission-denied", "Host authority changed.");
  }
  if (actors.length > 50 || new Set(actors.map((a) => a.actorId)).size !==
      actors.length || actors.some((a) => a.sessionId !== sessionId) ||
      messages.length > 50 || new Set(messages.map((m) => m.actorId)).size !==
      messages.length) throw invalid();
  const deliveries = actors.flatMap((actor) => {
    const id = practiceState(actor).latestMessageId;
    const message = messages.find((m) => m.actorId === actor.actorId);
    if (!id && !message) return [];
    if (!message || message.record.messageId !== id) throw invalid();
    return [practiceDeliveryReview(session, actor, message, organizer)];
  }).sort((a, b) => a.messageId.localeCompare(b.messageId));
  if (deliveries.length !== messages.length) throw invalid();
  return {context: practiceContext(session, {sessionId}),
    coverage: "currentActorMessages", deliveries};
}

/** Parent receipts fence exact retries, authorization and reset. */
export function repairPracticeDelivery(session: Session, actor: Actor,
  message: PracticeMessage, command: Repair, organizer: OrganizerDocument,
  actorUid: string, operationId: string): PracticeMessage {
  if (!isOrganizerManager(organizer, actorUid)) {
    throw new HttpsError("permission-denied", "Host authority changed.");
  }
  if (command.actorId !== actor.actorId ||
      command.payload.deliveryId !== message.record.messageId) throw invalid();
  if (command.payload.action !== "manualHandoff") {
    throw new HttpsError("failed-precondition",
      "Provider lookup and verified retry are not available here.");
  }
  const view = practiceDeliveryReview(session, actor, message, organizer);
  if (view.revision !== command.expectedMessageRevision ||
      view.reviewHash !== command.expectedReviewHash) {
    throw new HttpsError("aborted", "This delivery changed. Review it again.");
  }
  if (!view.actions.includes("manualHandoff")) {
    throw new HttpsError("failed-precondition",
      "This message no longer needs a manual handoff.");
  }
  const at = session.virtualNow.toMillis();
  return readPracticeMessage({...message, handoff: {actorUid, at, operationId},
    record: parseMessageRecord({...message.record,
      revision: message.record.revision + 1, updatedAt: at})}, session, actor);
}

function invalid() {
  return new HttpsError("failed-precondition",
    "Practice delivery history needs review.");
}
