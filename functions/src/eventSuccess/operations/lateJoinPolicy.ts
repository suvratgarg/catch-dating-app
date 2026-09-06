import type {
  EventAssistanceLateJoinInput as LateJoinInput,
} from "../../shared/generated/eventAssistanceLateJoinInput";
import type {
  EventAssistanceLateJoinDecision as LateJoinDecision,
} from "../../shared/generated/eventAssistanceLateJoinDecision";

type JoinDestination = LateJoinInput["policy"]["destination"];
type JoiningTarget = Extract<
  LateJoinInput["guidance"],
  {kind: "known"}
>["value"]["destination"];

/** Check relationships after the wire schema has validated the input. */
export function assertLateJoinContext(value: LateJoinInput): void {
  const eventId =
    value.context.mode === "live" ?
      value.context.eventId :
      value.context.virtualEventId;
  if (eventId !== value.eventId) throw new Error("Event context mismatch");
  if (value.lastMessage && value.lastMessage.at > value.now) {
    throw new Error("Message receipt is from the future");
  }
}

/**
 * Shared live/rehearsal policy: no provider, clock, persistence or UI
 * dependency.
 */
export function evaluateLateJoinPolicy(input: LateJoinInput): LateJoinDecision {
  assertLateJoinContext(input);
  const {guest, policy, now} = input;
  if (!input.eventOpen) return {kind: "cancelled", reason: "eventClosed"};
  if (input.setting.kind === "disabled") {
    return {kind: "cancelled", reason: "policyDisabled"};
  }
  if (guest.admission !== "admitted") {
    return {kind: "cancelled", reason: "notAdmitted"};
  }
  if (guest.attendance.kind === "known" && guest.attendance.value.checkedIn) {
    return {kind: "resolved", reason: "joined"};
  }
  if (guest.intention.kind === "notComing") {
    return {kind: "resolved", reason: "declined"};
  }
  if (policy.cutoff.kind === "time" && now >= policy.cutoff.at) {
    return {kind: "expired", reason: "cutoff"};
  }
  if (guest.attendance.kind !== "known") {
    return {kind: "wait", reason: "attendanceUnknown"};
  }
  if (!input.departureConfirmed) {
    return {kind: "wait", reason: "departureUnconfirmed"};
  }
  if (
    input.guidance.kind !== "known" ||
    input.guidance.value.validUntil <= now
  ) {
    return {kind: "wait", reason: "guidanceUnavailable"};
  }
  const guidance = input.guidance.value;
  if (!destinationAllowed(policy.destination, guidance.destination)) {
    return {kind: "hostDecision", reason: "missingInformation", guidance: null};
  }
  if (guest.intention.kind === "joinLater") {
    if (!destinationAllowed(policy.destination, guest.intention.target)) {
      return {kind: "hostDecision", reason: "entryDecision", guidance: null};
    }
    if (!sameTarget(guest.intention.target, guidance.destination)) {
      return {kind: "wait", reason: "guidanceUnavailable"};
    }
  }
  if (
    guidance.destination.kind === "fixedPlace" &&
    guidance.destination.lateEntry === "closed"
  ) {
    return {kind: "expired", reason: "lateEntryClosed"};
  }
  if (
    guidance.destination.kind === "fixedPlace" &&
    guidance.destination.lateEntry === "hostDecision"
  ) {
    return {kind: "hostDecision", reason: "entryDecision", guidance};
  }
  if (
    policy.unanswered === "hostReviewAtDeadline" &&
    input.responseDeadline !== undefined &&
    now >= input.responseDeadline &&
    guest.intention.kind === "unknown"
  ) {
    return {kind: "hostDecision", reason: "missingInformation", guidance};
  }
  if (guest.deliveryEligibility !== "eligible") {
    return {kind: "hostDecision", reason: "unreachable", guidance};
  }
  const unchanged = input.lastMessage?.materialKey === guidance.materialKey;
  const capped = input.messagesThisEpisode >= policy.maxMessagesPerEpisode;
  const throttled =
    input.lastMessage !== null &&
    now - input.lastMessage.at < policy.minimumMinutesBetweenMessages * 60_000;
  const contextKey = input.context.mode === "live" ?
    ["live", input.context.organizerId, input.context.eventId] :
    ["rehearsal", input.context.rehearsalId,
      input.context.virtualEventId, input.context.clockId];
  const messageKey = JSON.stringify([
    contextKey,
    input.eventId,
    "lateJoin",
    guest.attendeeId,
    guest.episodeId,
    guidance.materialKey,
  ]);
  // Joining page can update immediately even when a message must wait or is
  // capped.
  const executable = input.setting.authority === "executeWithinPolicy";
  const retryAt = input.lastMessage ?
    input.lastMessage.at + policy.minimumMinutesBetweenMessages * 60_000 :
    null;
  const cutoffAt =
    policy.cutoff.kind === "time" ? policy.cutoff.at : guidance.validUntil;
  const nextEvaluationAt =
    executable &&
    !unchanged &&
    !capped &&
    throttled &&
    retryAt !== null &&
    retryAt < Math.min(cutoffAt, guidance.validUntil) ?
      retryAt :
      null;
  return {
    kind: "update",
    guidance,
    messageKey,
    shouldSend: executable && !unchanged && !capped && !throttled,
    nextEvaluationAt,
  };
}
export function assertNever(value: never): never {
  throw new Error("Unhandled variant: " + String(value));
}

export function destinationAllowed(
  policy: JoinDestination,
  candidate: JoiningTarget
): boolean {
  switch (policy.kind) {
  case "fixedPlace":
    return (
      candidate.kind === "fixedPlace" &&
        candidate.placeId === policy.placeId &&
        candidate.lateEntry === policy.lateEntry
    );
  case "itineraryStop":
    return (
      candidate.kind === "itineraryStop" &&
        candidate.itineraryId === policy.itineraryId &&
        policy.permittedStopIds.includes(candidate.stopId)
    );
  case "groupCheckpoint":
    return (
      candidate.kind === "groupCheckpoint" &&
        candidate.routeId === policy.routeId &&
        candidate.groupId === policy.groupId &&
        policy.permittedCheckpointIds.includes(candidate.checkpointId)
    );
  default:
    return assertNever(policy);
  }
}

function sameTarget(a: JoiningTarget, b: JoiningTarget): boolean {
  switch (a.kind) {
  case "fixedPlace":
    return b.kind === "fixedPlace" && a.placeId === b.placeId;
  case "itineraryStop":
    return (
      b.kind === "itineraryStop" &&
        a.itineraryId === b.itineraryId &&
        a.stopId === b.stopId
    );
  case "groupCheckpoint":
    return (
      b.kind === "groupCheckpoint" &&
        a.routeId === b.routeId &&
        a.groupId === b.groupId &&
        a.checkpointId === b.checkpointId
    );
  default:
    return assertNever(a);
  }
}
