import {HttpsError} from "firebase-functions/v2/https";
import {operationContentHash} from "../../operations/durableActions";
import type {EventAssistanceCheckpointDocument as Report} from
  "../../shared/generated/eventAssistanceCheckpointDocument";
import type {EventAssistanceDepartureRosterDocument as Roster} from
  "../../shared/generated/eventAssistanceDepartureRosterDocument";
import type {GetEventAssistanceCheckpointCallablePayload as Scope} from
  "../../shared/generated/getEventAssistanceCheckpointCallablePayload";
import type {EventAssistanceCheckpointCallableResponse as Response} from
  "../../shared/generated/eventAssistanceCheckpointCallableResponse";
import {validateEventAssistanceCheckpointDocument} from
  "../../shared/generated/validators/eventAssistanceCheckpointDocument";
import {validateEventAssistanceDepartureRosterDocument} from
  "../../shared/generated/validators/eventAssistanceDepartureRosterDocument";
import {validateEventAssistanceCheckpointCallableResponse} from
  "../../shared/generated/validators/eventAssistanceCheckpointOutput";
import type {readGroupProgressState} from "./groupProgressReader";
import {progressIdentity, invalidSource} from "./groupProgressSource";
import {departureRosterIdentity} from "./departureRosterSource";
import {assertSavedCheckpointRequest} from "./checkpointRequest";

export type {Scope, Report, Roster, Response};
export const CHECKPOINTS = "eventAssistanceCheckpoints";
export const CHECKPOINT_RECEIPTS = "eventAssistanceCheckpointReceipts";
export type ProgressState = Awaited<ReturnType<typeof readGroupProgressState>>;
type Ready = Extract<Response["view"]["availability"], {kind: "ready"}>;
export type Visit = Ready["members"][number]["visit"];
export interface CheckpointState {
  scope: Scope;
  progress: ProgressState;
  roster: Roster | null;
  report: Report | null;
  visits: {attendeeId: string; visit: Visit}[];
  ownerValidUntil: number;
  now: number;
}
export function checkpointIdentity(scope: Scope) {
  return "checkpoint:" + operationContentHash([scope.context, scope.groupId,
    scope.progressRevision, scope.checkpointId]);
}

export function parseDepartureRoster(value: unknown, scope: Scope,
  now: number): Roster | null {
  if (value === undefined) return null;
  if (!validateEventAssistanceDepartureRosterDocument(value) ||
      value.rosterId !== departureRosterIdentity(scope.context, scope.groupId,
        scope.progressRevision) ||
      value.rosterId !== departureRosterIdentity(value.context, value.groupId,
        value.progressRevision) ||
      value.progressId !== progressIdentity(scope.context, scope.groupId) ||
      value.confirmedAt > now || !canonicalIds(value.members.map((m) =>
    m.attendeeId)) || value.members.some((m) =>
    scope.groupId === "event:whole" ? m.membershipHash !== null :
      m.membershipHash === null || m.episodeId === null)) throw invalidSource();
  assertSavedCheckpointRequest(value);
  return value;
}

export function parseCheckpointReport(value: unknown, scope: Scope,
  roster: Roster | null, now: number): Report | null {
  if (value === undefined) return null;
  if (!validateEventAssistanceCheckpointDocument(value) || !roster ||
      value.reportId !== checkpointIdentity(scope) ||
      value.reportId !== checkpointIdentity(value) ||
      value.rosterId !== roster.rosterId ||
      value.rosterHash !== operationContentHash(roster) ||
      value.createdAt < roster.confirmedAt ||
      value.createdAt > value.reportedAt || value.reportedAt > now ||
      !canonicalIds(value.accountedFor) ||
      value.accountedFor.some((id) =>
        !roster.members.some((m) => m.attendeeId === id))) {
    throw invalidSource();
  }
  return value;
}

function canonicalIds(ids: string[]) {
  return ids.every((id, i) => i === 0 || ids[i - 1] < id);
}

export function checkpointAvailability(s: CheckpointState):
  Response["view"]["availability"] {
  const {roster} = s;
  const unavailable = (reason: Extract<Response["view"]["availability"],
    {kind: "unavailable"}>["reason"]) =>
    ({kind: "unavailable" as const, reason});
  if (!roster) return unavailable("rosterNotRecorded");
  if (roster.sourceHash !== s.progress.source.sourceHash) {
    return unavailable("setupChanged");
  }
  const target = roster.destination;
  if (!target) return unavailable("destinationNotRecorded");
  if (target.kind !== "itineraryStop" && target.kind !== "groupCheckpoint") {
    return unavailable("notCheckpoint");
  }
  const id = target.kind === "itineraryStop" ? target.stopId :
    target.checkpointId;
  if (id !== s.scope.checkpointId) return unavailable("differentCheckpoint");
  const destination = s.progress.source.destinations.find((d) =>
    operationContentHash(d.target) === operationContentHash(target));
  if (!destination) return unavailable("setupChanged");
  const accounted = new Set(s.report?.accountedFor ?? []);
  return {kind: "ready", rosterId: roster.rosterId, label: destination.label,
    reportStatus: !s.report ? "unreported" :
      accounted.size === roster.members.length ? "complete" : "partial",
    members: s.visits.map(({attendeeId, visit}) => ({attendeeId, visit,
      observation: accounted.has(attendeeId) ?
        "accountedFor" : "unconfirmed"}))};
}

export function checkpointSourceHash(s: CheckpointState) {
  return operationContentHash([s.scope, s.progress.source.sourceHash,
    s.roster, s.report, s.visits]);
}
function checkpointRequestView(s: CheckpointState):
  Response["view"]["request"] {
  const request = s.roster?.checkpointRequest;
  const destination = s.roster?.destination;
  const checkpointId = destination?.kind === "itineraryStop" ?
    destination.stopId : destination?.kind === "groupCheckpoint" ?
      destination.checkpointId : null;
  if (!request || checkpointId !== s.scope.checkpointId) return null;
  const complete = s.report !== null &&
    s.report.accountedFor.length === s.roster!.members.length;
  if (complete) {
    return {...request, state: "complete", ownerAvailability: "notRequired"};
  }
  return {...request, state:
    checkpointAvailability(s).kind !== "ready" ? "sourceUnavailable" :
      s.report ? "discrepancy" : s.now >= request.dueAt ?
        "overdue" : "awaitingReport",
  ownerAvailability: s.ownerValidUntil > Math.max(s.now, request.dueAt) ?
    "current" : "needsReassignment"};
}
export function checkpointResponse(outcome: Response["outcome"],
  s: CheckpointState, operationRevision: number | null = null): Response {
  const value: Response = {outcome, operationRevision, view: {...s.scope,
    serverTime: s.now, sourceHash: checkpointSourceHash(s),
    revision: s.report?.revision ?? 0, report: s.report,
    request: checkpointRequestView(s),
    availability: checkpointAvailability(s)}};
  if (!validateEventAssistanceCheckpointCallableResponse(value)) {
    throw invalidSource();
  }
  return value;
}
export function checkpointConflict() {
  return new HttpsError("aborted",
    "Checkpoint report changed. Refresh and retry.");
}
