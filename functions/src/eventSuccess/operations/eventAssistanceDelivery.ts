import type {EventAssistanceMessageIntent as MessageIntent} from
  "../../shared/generated/eventAssistanceMessageIntent";
import type {EventAssistanceDeliveryAttempt as DeliveryAttempt} from
  "../../shared/generated/eventAssistanceDeliveryAttempt";
import type {DeliveryDispatchCandidate, DeliverySourceAdapter} from
  "../../delivery/deliveryCore";
import {
  parseDeliveryAttempt, parseMessageIntent,
} from "./messageProtocol";
import {
  assistanceMessageId, MessageRecord, parseMessageRecord,
} from "./messageOutbox";
import type {LiveSenderBinding} from "./messagingPolicy";
import {sameMessageContext} from "./messagingPolicy";

type MessageContext = MessageIntent["context"];

/**
 * Event Assistance's binding to the shared delivery core. The core owns the
 * generic outbox lifecycle; this adapter owns EA's generated contracts,
 * identity (`outbox:` hash of context/intent/revision), the
 * guidance/instruction revision rule, and the handoff stop evidence.
 */
export const eventAssistanceDeliveryAdapter: DeliverySourceAdapter<
  MessageContext, LiveSenderBinding, MessageIntent, DeliveryAttempt,
  MessageRecord
> = {
  collection: "eventAssistanceMessages",
  messageId: (intent) => assistanceMessageId(intent),
  parseIntent: (value) => parseMessageIntent(value),
  parseAttempt: (value) => parseDeliveryAttempt(value),
  parseRecord: (value) => parseMessageRecord(value),
  newRecord: (intent, now) => parseMessageRecord({schemaVersion: 1,
    messageId: assistanceMessageId(intent), revision: 0, intent,
    lifecycle: "active", response: null, attempts: [],
    deliveryConflict: false, createdAt: now, updatedAt: now}),
  instructionRevisionOf: (intent) => intent.kind === "joiningUpdate" ?
    intent.guidance.revision : intent.instructionRevision,
  sameContext: (left, right) => sameMessageContext(left, right),
  recordStopReason: (record) => record.handoff ? "hostStopped" : null,
  routeIdOf: (attempt) => attempt.mode === "live" ?
    attempt.binding.routeId : attempt.routeId,
  // The candidate-shape check `planMessageDelivery` runs per eligible route.
  assertDispatchCandidate: (
    candidate: DeliveryDispatchCandidate<LiveSenderBinding>,
    intent: MessageIntent, now: number
  ) => {
    parseDeliveryAttempt({
      schemaVersion: 1, attemptId: "binding-validation",
      intentId: intent.intentId, intentRevision: intent.revision,
      ordinal: 1, createdAt: now,
      state: {kind: "reserved", at: now, reconcileAfter: now},
      authorization: {permissionRevision: "binding-validation",
        checkedAt: now, validUntil: now + 1, instructionRevision: 0},
      mode: candidate.mode, context: intent.context,
      ...(candidate.mode === "live" ? {binding: candidate.binding} :
        {routeId: candidate.routeId}),
    });
  },
  withAttempts: (record, attempts) => ({...record, attempts}),
  withLifecycle: (record, lifecycle) => ({...record, lifecycle}),
  withDeliveryConflict: (record, deliveryConflict) =>
    ({...record, deliveryConflict}),
};
