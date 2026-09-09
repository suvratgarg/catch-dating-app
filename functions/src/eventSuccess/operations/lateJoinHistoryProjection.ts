import {operationContentHash} from "../../operations/durableActions";
import {requireDocumentId} from "./guestRecords";
import {MessageRecord, parseMessageRecord} from "./messageOutbox";
import {sameMessageContext} from "./messagingPolicy";

// Complete history is bounded independently of provider retry count.
export const MAX_LATE_JOIN_HISTORY = 200;
export type MessageHistoryScope = {
  context: MessageRecord["intent"]["context"];
  attendeeId: string; episodeId: string;
};
export type LateJoinMessageHistory =
  | {kind: "unavailable"; reason: "historyLimit" | "deliveryConflict" |
      "ambiguousHistory"}
  | {kind: "ready"; facts: {
      lastMessage: {materialKey: string; at: number} | null;
      messagesThisEpisode: number}; evidenceHash: string};

/** Reduce a proven complete bounded snapshot, never a partial page. */
export function projectLateJoinMessageHistory(scope: MessageHistoryScope,
  records: readonly MessageRecord[], now: number,
  currentIntent?: MessageRecord["intent"]): LateJoinMessageHistory {
  requireDocumentId(scope.attendeeId);
  if (scope.context.mode !== "live" && scope.context.mode !== "rehearsal") {
    throw new Error("Invalid late-join history context");
  }
  const eventId = scope.context.mode === "live" ? scope.context.eventId :
    scope.context.virtualEventId;
  requireDocumentId(eventId);
  if (scope.context.mode === "live") {
    requireDocumentId(scope.context.organizerId);
  } else {
    requireDocumentId(scope.context.rehearsalId);
    requireDocumentId(scope.context.clockId);
  }
  requireDocumentId(scope.episodeId);
  if (!Number.isSafeInteger(now) || now < 0) {
    throw new Error("Invalid late-join history clock");
  }
  if (records.length > MAX_LATE_JOIN_HISTORY) {
    return {kind: "unavailable", reason: "historyLimit"};
  }
  const ids = new Set<string>();
  const counted: Array<{materialKey: string; createdAt: number;
    at: number}> = [];
  let conflict = false;
  let currentFound = false;
  for (const value of records) {
    const record = parseMessageRecord(value);
    const intent = record.intent;
    if (!sameMessageContext(intent.context, scope.context) ||
        intent.eventId !== eventId ||
        intent.attendeeId !== scope.attendeeId ||
        intent.episodeId !== scope.episodeId ||
        intent.workflow.kind !== "lateJoin" ||
        intent.kind !== "joiningUpdate" ||
        record.updatedAt > now || ids.has(record.messageId)) {
      throw new Error("Late-join history is outside the guest episode");
    }
    ids.add(record.messageId);
    conflict ||= record.deliveryConflict;
    if (currentIntent && intent.intentId === currentIntent.intentId &&
        intent.revision === currentIntent.revision) {
      if (operationContentHash(intent) !==
          operationContentHash(currentIntent)) {
        throw new Error("Dispatch intent does not match complete history");
      }
      currentFound = true;
      // The outbox owns this logical intent's bounded retries. Its reservation
      // must not consume the same episode slot twice at the final send claim.
      continue;
    }
    const attempts = record.attempts.filter((a) =>
      countsTowardOutreach(a.state));
    if (attempts.length) {
      counted.push({materialKey: intent.guidance.materialKey,
        createdAt: intent.createdAt,
        // A late receipt can extend cooldown, but must never make it shorter.
        at: Math.max(...attempts.map((a) => a.state.at))});
    }
  }
  if (currentIntent && !currentFound) {
    throw new Error("Dispatch intent is absent from complete history");
  }
  if (conflict) return {kind: "unavailable", reason: "deliveryConflict"};
  const latestCreatedAt = Math.max(...counted.map((m) => m.createdAt));
  const latest = counted.filter((m) => m.createdAt === latestCreatedAt);
  if (new Set(latest.map((m) => m.materialKey)).size > 1) {
    return {kind: "unavailable", reason: "ambiguousHistory"};
  }
  const lastMessage = latest.length ? {materialKey: latest[0].materialKey,
    at: Math.max(...counted.map((m) => m.at))} : null;
  return {kind: "ready", facts: {lastMessage,
    messagesThisEpisode: counted.length}, evidenceHash: operationContentHash([
    scope, now, currentIntent ?? null, [...records].sort((a, b) =>
      a.messageId.localeCompare(b.messageId))])};
}

/** Uncertain submissions and reservations consume the episode allowance. */
function countsTowardOutreach(
  state: MessageRecord["attempts"][number]["state"]):
  boolean {
  switch (state.kind) {
  case "notDispatched": return false;
  case "reserved":
  case "unknown":
  case "accepted":
  case "delivered":
  case "read":
  case "failed":
  case "revoked": return true;
  default: {
    const unhandled: never = state;
    void unhandled;
    throw new Error("Unknown outreach attempt state");
  }
  }
}
