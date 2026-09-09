import {HttpsError} from "firebase-functions/v2/https";
import {operationContentHash as hash} from "../../operations/durableActions";
import type {EventAssistanceCommand} from
  "../../shared/generated/eventAssistanceCommand";
import type {EventAssistanceCheckpointCallableResponse as Response} from
  "../../shared/generated/eventAssistanceCheckpointCallableResponse";
import {checkpointObservationConflict} from "./movementDecisions";

type View = Response["view"];
type Closeout = NonNullable<View["closeout"]>;
type SavedDecision = NonNullable<Closeout["change"]>["decision"];
type ClosedDecision = Extract<SavedDecision, {kind: "close"}>;
type Disposition = ClosedDecision["dispositions"][number];
type Report = {readonly accountedFor: readonly string[]};
export type CheckpointCloseoutDecision<R extends Report> =
  {kind: "close"; report: R; dispositions: Disposition[]} | {kind: "reopen"};
export interface CheckpointCloseoutEvidence<R extends Report> {
  readonly report: R | null;
  readonly rosterIds: readonly string[];
  readonly availability: View["availability"];
}

/** Both execution modes supply validated, original-roster visit evidence.
 * These rules grant no authority, write no receipts and infer no arrivals.
 */
export function currentCheckpointCloseout<R extends Report>(
  e: CheckpointCloseoutEvidence<R>
): Extract<CheckpointCloseoutDecision<R>, {kind: "close"}> | null {
  if (e.availability.kind !== "ready" || !e.report ||
      e.availability.reportStatus === "complete") return null;
  const accounted = new Set(e.report.accountedFor);
  const dispositions: Disposition[] = [];
  for (const attendeeId of e.rosterIds) {
    if (accounted.has(attendeeId)) continue;
    const row = e.availability.members.find((m) =>
      m.attendeeId === attendeeId);
    if (row?.visit.kind !== "current" ||
        row.disposition?.kind !== "resolved") return null;
    dispositions.push({attendeeId, ...row.disposition});
  }
  return {kind: "close", report: e.report, dispositions};
}

export function checkpointCloseoutDecisionState<R extends Report>(
  e: CheckpointCloseoutEvidence<R>,
  decision: CheckpointCloseoutDecision<R> | null
): Closeout["state"] {
  if (!decision) return {kind: "open"};
  if (e.report && e.report.accountedFor.length === e.rosterIds.length) {
    return {kind: "superseded"};
  }
  if (decision.kind === "reopen") return {kind: "reopened"};
  if (e.availability.kind !== "ready") {
    return {kind: "needsReview", reason: "sourceUnavailable"};
  }
  if (hash(e.report) !== hash(decision.report)) {
    return {kind: "needsReview", reason: "reportChanged"};
  }
  const current = currentCheckpointCloseout(e);
  return current && hash(current) === hash(decision) ? {kind: "closedOut"} :
    {kind: "needsReview", reason: "dispositionChanged"};
}

export function checkpointCloseoutEligibility<R extends Report>(
  e: CheckpointCloseoutEvidence<R>, state: Closeout["state"]
): Closeout["eligibility"] {
  const reason = e.availability.kind !== "ready" ? "sourceUnavailable" :
    !e.report ? "reportMissing" :
      e.availability.reportStatus === "complete" ? "reportComplete" :
        state.kind === "closedOut" ? "alreadyClosed" : null;
  if (reason) return {kind: "unavailable", reason, attendeeIds: []};
  if (currentCheckpointCloseout(e)) return {kind: "ready"};
  const accounted = new Set(e.report!.accountedFor);
  const members = e.availability.kind === "ready" ? e.availability.members : [];
  return {kind: "unavailable", reason: "unresolvedMembers",
    attendeeIds: e.rosterIds.filter((id) => !accounted.has(id) &&
      !members.some((m) => m.attendeeId === id &&
        m.visit.kind === "current" && m.disposition?.kind === "resolved"))};
}

export function prepareCheckpointReassignment(
  review: Pick<View, "availability" | "request"> & {
    assignment: Pick<NonNullable<View["assignment"]>,
      "revision" | "sourceHash">;
  }, payload: Extract<EventAssistanceCommand,
    {kind: "reassignCheckpointReporter"}>["payload"], expectedSourceHash: string
) {
  if (review.assignment.sourceHash !== expectedSourceHash ||
      review.assignment.revision !== payload.expectedAssignmentRevision) {
    throw checkpointObservationConflict();
  }
  if (!review.request || review.availability.kind !== "ready" ||
      ["complete", "closedOut"].includes(review.request.state)) {
    throw new HttpsError("failed-precondition",
      "Only an outstanding report with current sources can be reassigned.");
  }
  if (review.request.responsibleOperatorId === payload.responsibleOperatorId) {
    throw new HttpsError("failed-precondition", "Choose a different reporter.");
  }
}

export function prepareCheckpointCloseout(
  review: {request: View["request"]; closeout: Pick<Closeout,
    "revision" | "sourceHash" | "eligibility"> & {
      change: {decision: {kind: "close" | "reopen"}} | null;
    }}, payload: Extract<EventAssistanceCommand,
    {kind: "setCheckpointCloseout"}>["payload"], expectedSourceHash: string
) {
  const view = review.closeout;
  if (view.sourceHash !== expectedSourceHash ||
      view.revision !== payload.expectedCloseoutRevision) {
    throw checkpointObservationConflict();
  }
  if (!review.request || (payload.decision === "close" ?
    view.eligibility.kind !== "ready" :
    view.change?.decision.kind !== "close" ||
      review.request.state === "complete")) {
    throw new HttpsError("failed-precondition", payload.decision === "close" ?
      "Review a disposition for every unconfirmed guest first." :
      "Only a recorded, unsuperseded closeout can be reopened.");
  }
}
