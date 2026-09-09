import {HttpsError} from "firebase-functions/v2/https";
import type {EventAssistanceCommand} from
  "../../shared/generated/eventAssistanceCommand";
import type {EventAssistanceGroupProgressCallableResponse as Progress} from
  "../../shared/generated/eventAssistanceGroupProgressCallableResponse";
import type {EventAssistanceCheckpointCallableResponse as Checkpoint} from
  "../../shared/generated/eventAssistanceCheckpointCallableResponse";
import {operationContentHash} from "../../operations/durableActions";

export type DeparturePayload = Extract<EventAssistanceCommand,
  {kind: "confirmDeparture"}>["payload"];
export type CheckpointPayload = Extract<EventAssistanceCommand,
  {kind: "recordCheckpoint"}>["payload"];
export type DepartureReview = Pick<Progress["view"],
  "revision" | "sourceHash" | "eventOpen" | "runtimeLive"> & {
    readonly destinations: readonly Pick<
      Progress["view"]["destinations"][number],
      "target">[];
  };
export type CheckpointObservationReview = Pick<Checkpoint["view"],
  "revision" | "sourceHash" | "availability"> & {
    readonly previouslyAccountedFor: readonly string[];
  };

/** Pure decision rules shared by live and synthetic execution adapters.
 * Callers validate the typed command, authenticate the scope, and read current
 * source/visit facts before calling; this layer grants no authority or effects.
 */
export function prepareDepartureDecision(review: DepartureReview,
  payload: DeparturePayload, expectedSourceHash: string) {
  if (payload.expectedProgressRevision !== review.revision ||
      expectedSourceHash !== review.sourceHash) throw departureConflict();
  if (!review.eventOpen || !review.runtimeLive) {
    throw new HttpsError("failed-precondition",
      "Start the event before confirming departure.");
  }
  const target = review.destinations.find((d) =>
    operationContentHash(d.target) ===
      operationContentHash(payload.destination));
  if (!target) {
    throw new HttpsError("failed-precondition",
      "Choose a destination from the current event setup.");
  }
  if (payload.checkpointRequest && (!payload.departureRoster ||
      (target.target.kind !== "itineraryStop" &&
        target.target.kind !== "groupCheckpoint"))) {
    throw new HttpsError("failed-precondition",
      "A checkpoint request needs a selected departure roster and stop.");
  }
  return {target, selection: payload.departureRoster,
    checkpointRequest: payload.checkpointRequest};
}

/** Complete observations can retain earlier proof after a new visit.
 * Removing earlier observations requires a correction. A return-sweep result
 * never establishes arrival at this checkpoint.
 */
export function prepareCheckpointObservation(
  review: CheckpointObservationReview, payload: CheckpointPayload,
  expectedSourceHash: string
) {
  if (expectedSourceHash !== review.sourceHash ||
      payload.expectedCheckpointRevision !== review.revision) {
    throw checkpointObservationConflict();
  }
  const availability = review.availability;
  if (availability.kind !== "ready") {
    throw new HttpsError("failed-precondition",
      "This departure has no current checkpoint roster.");
  }
  const accountedFor = [...payload.accountedFor].sort();
  const prior = new Set(review.previouslyAccountedFor);
  for (const id of accountedFor) {
    const member = availability.members.find((m) => m.attendeeId === id);
    if (!member || !prior.has(id) && member.visit.kind !== "current") {
      throw new HttpsError("failed-precondition",
        "New observations must match a guest's original departure visit.");
    }
  }
  const correctionReason = payload.correctionReason?.trim() ?? null;
  if ([...prior].some((id) => !accountedFor.includes(id)) &&
      !correctionReason) {
    throw new HttpsError("failed-precondition",
      "Explain why a previously recorded guest is being removed.");
  }
  return {accountedFor, correctionReason};
}

export function departureConflict() {
  return new HttpsError("aborted",
    "Group progress changed. Refresh and retry.");
}

export function checkpointObservationConflict() {
  return new HttpsError("aborted",
    "Checkpoint report changed. Refresh and retry.");
}
