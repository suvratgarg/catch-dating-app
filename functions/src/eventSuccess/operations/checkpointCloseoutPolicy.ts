import {currentCheckpointCloseout, checkpointCloseoutDecisionState,
  checkpointCloseoutEligibility} from "./checkpointManagementDecisions";
import {operationContentHash} from "../../operations/durableActions";
import type {EventAssistanceCheckpointWork} from
  "../../shared/generated/eventAssistanceCheckpointWork";
import {invalidSource} from "./groupProgressSource";
import {checkpointAvailability, checkpointSourceHash, checkpointIdentity,
  parseCheckpointReport, CheckpointState, Response} from "./checkpointRecords";

export type CloseoutChange = NonNullable<
  EventAssistanceCheckpointWork["closeout"]>;
type View = NonNullable<Response["view"]["closeout"]>;
type Closed = Extract<CloseoutChange["decision"], {kind: "close"}>;

/** Validate saved historical evidence against its immutable departure. */
export function assertCloseoutRoster(s: CheckpointState) {
  const c = s.requestWork?.payload.closeout;
  if (!c || c.decision.kind !== "close") return;
  const {report, dispositions} = c.decision;
  parseCheckpointReport(report, s.scope, s.roster, c.changedAt);
  const ids = [...report.accountedFor,
    ...dispositions.map((d) => d.attendeeId)].sort();
  if (operationContentHash(ids) !== operationContentHash(
    s.roster!.members.map((m) => m.attendeeId))) throw invalidSource();
}

function evidence(s: CheckpointState) {
  return {availability: checkpointAvailability(s), report: s.report,
    rosterIds: s.roster?.members.map((m) => m.attendeeId) ?? []};
}

export function currentCloseoutDecision(s: CheckpointState): Closed | null {
  return currentCheckpointCloseout(evidence(s));
}

export function checkpointCloseoutState(s: CheckpointState): View["state"] {
  return checkpointCloseoutDecisionState(evidence(s),
    s.requestWork?.payload.closeout?.decision ?? null);
}

export function checkpointCloseoutView(s: CheckpointState): View | null {
  if (!s.requestWork) return null;
  const change = s.requestWork.payload.closeout ?? null;
  const state = checkpointCloseoutState(s);
  return {revision: change?.revision ?? 0, change, state,
    eligibility: checkpointCloseoutEligibility(evidence(s), state),
    sourceHash: operationContentHash([checkpointSourceHash(s),
      s.dispositions ?? null, s.requestWork.payload.request,
      s.requestWork.payload.reassignment ?? null, change])};
}

/** Shape validation is supplied by the work schema before this check. */
export function assertCloseoutChange(c: CloseoutChange,
  work: EventAssistanceCheckpointWork) {
  if (c.previousRevision !== c.revision - 1 ||
      c.changedAt < work.requestedAt ||
      work.checkpoint.evaluatedAt === null ||
      c.changedAt > work.checkpoint.evaluatedAt ||
      c.reason !== c.reason.trim() ||
      c.decision.kind === "reopen" && c.previousRevision === 0) {
    throw invalidSource();
  }
  if (c.decision.kind !== "close") return;
  const {report, dispositions} = c.decision;
  const accounted = new Set(report.accountedFor);
  if (report.reportId !== checkpointIdentity(work.scope) ||
      checkpointIdentity(report) !== report.reportId ||
      report.rosterId !== work.rosterId ||
      report.rosterHash !== work.rosterHash ||
      report.createdAt < work.requestedAt ||
      report.createdAt > report.reportedAt || report.reportedAt > c.changedAt ||
      dispositions.length === 0 ||
      dispositions.some((d, i) => accounted.has(d.attendeeId) ||
        i > 0 && dispositions[i - 1].attendeeId >= d.attendeeId ||
        d.resolvedAt < work.requestedAt || d.resolvedAt > c.changedAt)) {
    throw invalidSource();
  }
}
