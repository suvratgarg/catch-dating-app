import type {Firestore, Transaction} from "firebase-admin/firestore";
import {operationContentHash} from "../../operations/durableActions";
import {validateEventAssistanceCaseDocument} from
  "../../shared/generated/validators/eventAssistanceCaseDocument";
import {assertCommandContext, assertCommandRole} from "./commands";
import {EVENT_ASSISTANCE_MESSAGES} from "./firestoreMessageOutbox";
import {Guest, guestCollections, parseGuest} from "./guestRecords";
import {MessageRecord, parseMessageRecord} from "./messageOutbox";
import {
  GuestChoiceResult, GuestChoiceSubmission, ResolvedGuestScope,
  resolveGuestChoice,
} from "./messageProtocol";
import {DispatchGate, sameMessageContext} from "./messagingPolicy";

export type GuestActionResult =
  | {kind: "accepted" | "replayed"; guest: Guest; message: MessageRecord}
  | {kind: "rejected"; reason: Extract<GuestChoiceResult,
    {kind: "rejected"}>["reason"] | "guestStateChanged"};

/**
 * Shared domain writer for authenticated guest adapters. The caller resolves
 * scope and current source facts in this transaction, before staging writes.
 * No provider reply or webpage can invent an action from its display label.
 */
export function applyGuestChoice(db: Firestore, tx: Transaction, input: {
  guest: Guest;
  message: MessageRecord;
  scope: ResolvedGuestScope;
  submission: GuestChoiceSubmission;
  expectedGuestRevision: number;
  gate: DispatchGate;
  now: number;
}): GuestActionResult {
  const guest = parseGuest(input.guest);
  const message = parseMessageRecord(input.message);
  const {now, expectedGuestRevision} = input;
  if (!sameMessageContext(guest.context, message.intent.context) ||
      guest.attendeeId !== message.intent.attendeeId ||
      guest.episodeId !== message.intent.episodeId ||
      now < guest.updatedAt || now < message.updatedAt ||
      !Number.isSafeInteger(expectedGuestRevision) ||
      expectedGuestRevision < 0) {
    throw new Error("Guest action context or revision is invalid");
  }
  const choice = resolveGuestChoice({intent: message.intent,
    lifecycle: message.lifecycle, submission: input.submission,
    scope: input.scope, gate: input.gate, now,
    existingResponse: message.response});
  if (choice.kind === "rejected") return choice;
  if (choice.kind === "replayed") return {kind: "replayed", guest, message};
  const response = choice.response;
  if (response.value.kind === "joinIntent" &&
      guest.revision !== expectedGuestRevision) {
    return {kind: "rejected", reason: "guestStateChanged"};
  }
  let nextGuest = guest;
  switch (response.value.kind) {
  case "joinIntent": {
    const command = {kind: "setJoinIntent" as const,
      context: guest.context, eventId: guest.context.eventId,
      operationId: response.responseId,
      payload: {attendeeId: guest.attendeeId, episodeId: guest.episodeId,
        expectedParticipationRevision: expectedGuestRevision,
        intent: response.value.intention}};
    assertCommandContext(command, guest.context);
    assertCommandRole(command, ["guestSelf"]);
    nextGuest = parseGuest({...guest, intention: command.payload.intent,
      revision: guest.revision + 1, updatedAt: now});
    tx.set(db.collection(guestCollections.guests).doc(guest.guestId),
      nextGuest);
    break;
  }
  case "requestHelp": {
    const category = response.value.category;
    const request = {schemaVersion: 1,
      caseId: "case:" + operationContentHash(response.responseId),
      guestId: guest.guestId, context: guest.context,
      attendeeId: guest.attendeeId, episodeId: guest.episodeId,
      responseId: response.responseId, messageId: message.messageId,
      status: "open", category, receivedAt: now,
      owner: category === "comfortSafety" ?
        "authorizedSafetyOperator" : "eventLead"};
    if (!validateEventAssistanceCaseDocument(request)) {
      throw new Error("Guest request failed its ownership contract");
    }
    tx.create(db.collection(guestCollections.cases).doc(request.caseId),
      request);
    break;
  }
  case "acknowledge": break;
  default: {
    const unhandled: never = response.value;
    throw new Error("Unhandled guest response: " + unhandled);
  }
  }
  const nextMessage = parseMessageRecord({...message, response,
    lifecycle: "responded", revision: message.revision + 1, updatedAt: now});
  tx.set(db.collection(EVENT_ASSISTANCE_MESSAGES).doc(message.messageId),
    nextMessage);
  return {kind: "accepted", guest: nextGuest, message: nextMessage};
}
