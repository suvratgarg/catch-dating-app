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

/** No source snapshot is inferred from a guest's intention or location. */
export function currentCloseoutDecision(s: CheckpointState): Closed | null {
  const available = checkpointAvailability(s);
  if (available.kind !== "ready" || !s.report ||
      available.reportStatus === "complete") return null;
  const accounted = new Set(s.report.accountedFor);
  const dispositions: Closed["dispositions"] = [];
  for (const member of s.roster!.members) {
    if (accounted.has(member.attendeeId)) continue;
    const row = available.members.find((m) =>
      m.attendeeId === member.attendeeId);
    if (row?.visit.kind !== "current" ||
        row.disposition?.kind !== "resolved") return null;
    dispositions.push({attendeeId: member.attendeeId, ...row.disposition});
  }
  return {kind: "close", report: s.report, dispositions};
}

export function checkpointCloseoutState(s: CheckpointState): View["state"] {
  const c = s.requestWork?.payload.closeout;
  if (!c) return {kind: "open"};
  if (s.report && s.report.accountedFor.length === s.roster!.members.length) {
    return {kind: "superseded"};
  }
  if (c.decision.kind === "reopen") return {kind: "reopened"};
  if (checkpointAvailability(s).kind !== "ready") {
    return {kind: "needsReview", reason: "sourceUnavailable"};
  }
  if (operationContentHash(s.report) !==
      operationContentHash(c.decision.report)) {
    return {kind: "needsReview", reason: "reportChanged"};
  }
  const current = currentCloseoutDecision(s);
  return current && operationContentHash(current) ===
    operationContentHash(c.decision) ? {kind: "closedOut"} :
    {kind: "needsReview", reason: "dispositionChanged"};
}

export function checkpointCloseoutView(s: CheckpointState): View | null {
  if (!s.requestWork) return null;
  const change = s.requestWork.payload.closeout ?? null;
  const state = checkpointCloseoutState(s);
  const availability = checkpointAvailability(s);
  let eligibility: View["eligibility"];
  const reason = availability.kind !== "ready" ? "sourceUnavailable" :
    !s.report ? "reportMissing" : availability.reportStatus === "complete" ?
      "reportComplete" : state.kind === "closedOut" ? "alreadyClosed" : null;
  if (reason) {
    eligibility = {kind: "unavailable", reason, attendeeIds: []};
  } else if (currentCloseoutDecision(s)) {
    eligibility = {kind: "ready"};
  } else {
    const accounted = new Set(s.report!.accountedFor);
    const members = availability.kind === "ready" ? availability.members : [];
    eligibility = {kind: "unavailable", reason: "unresolvedMembers",
      attendeeIds: s.roster!.members.filter((m) =>
        !accounted.has(m.attendeeId) &&
        !members.some((d) => d.attendeeId === m.attendeeId &&
          d.visit.kind === "current" && d.disposition?.kind === "resolved"))
        .map((m) => m.attendeeId)};
  }
  return {revision: change?.revision ?? 0, change, state, eligibility,
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
