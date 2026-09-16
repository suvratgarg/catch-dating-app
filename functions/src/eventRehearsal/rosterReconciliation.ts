import {HttpsError} from "firebase-functions/v2/https";
import type {
  EventRehearsalActorDocument as Actor,
  EventRehearsalDocument as Session,
} from "../shared/generated/firestoreAdminTypes";
import type {ControlEventRehearsalCallablePayload as Control} from
  "../shared/generated/controlEventRehearsalCallablePayload";
import type {EventRehearsalBootstrapCallableResponse as Bootstrap} from
  "../shared/generated/eventRehearsalBootstrapCallableResponse";
import {operationContentHash as hash} from "../operations/durableActions";

type State = NonNullable<Session["rosterReconciliation"]>;
type Command = NonNullable<Control["roster"]>;
type Row = State["rows"][number];
export type PracticeRosterReview = NonNullable<
  Bootstrap["rosterReview"]
>;

export interface PracticeRosterResult {
  state: State;
  replayed: boolean;
}

/** Builds one committed synthetic roster source for a setup generation. */
export function buildPracticeRosterSource(
  sessionId: string,
  sourceRevision: number,
  scenarioId: Session["scenarioId"],
  actors: readonly Actor[]
): State {
  validateRoster(sessionId, actors);
  const sourceId = "practice-roster:" + hash(sessionId);
  const rows: Row[] = [...actors]
    .sort((left, right) => left.actorId.localeCompare(right.actorId))
    .map((actor) => ({
      rowId: "source-row:" + actor.actorId,
      outcome: "imported" as const,
      actorId: actor.actorId,
    }));
  if (scenarioId === "rosterAndCapacity") {
    rows.push({rowId: "source-row:duplicate", outcome: "duplicate",
      actorId: actors[0]!.actorId});
    rows.push({rowId: "source-row:failed", outcome: "failed",
      actorId: null});
  } else if (scenarioId === "walkInAndAmbiguousClaim" ||
      scenarioId === "externalProfiles") {
    rows.push({rowId: "source-row:ambiguous", outcome: "ambiguous",
      actorId: null});
  }
  return {sourceId, sourceRevision, rows, status: "pending",
    reconciliationRevision: 0, lastOperationId: null, reconciledBy: null,
    reconciledAt: null};
}

/** Projects every synthetic source row so unresolved input is accounted for. */
export function practiceRosterReview(session: Session): PracticeRosterReview {
  const state = requireSource(session);
  return {
    sourceId: state.sourceId,
    sourceRevision: state.sourceRevision,
    status: state.status,
    reconciliationRevision: state.reconciliationRevision,
    reconciledAt: state.reconciledAt?.toMillis() ?? null,
    importedCount: count(state.rows, "imported"),
    duplicateCount: count(state.rows, "duplicate"),
    ambiguousCount: count(state.rows, "ambiguous"),
    failedCount: count(state.rows, "failed"),
    rows: state.rows.map((row) => ({...row})),
  };
}

/** Reconciles one exact committed source without inventing resolved rows. */
export function preparePracticeRosterReconciliation(
  session: Session,
  command: Command,
  actorUid: string,
  operationId: string
): PracticeRosterResult {
  if (!["draft", "ready", "running", "paused"].includes(session.status)) {
    throw new HttpsError("failed-precondition",
      "Practice roster reconciliation is unavailable after completion.");
  }
  const state = requireSource(session);
  if (command.sourceId !== state.sourceId ||
      command.sourceRevision !== state.sourceRevision) {
    throw new HttpsError("aborted",
      "The practice roster source changed. Review it again.");
  }
  if (state.status === "reconciled") {
    return {state, replayed: true};
  }
  if (state.reconciliationRevision >= 2147483647) {
    throw new HttpsError("resource-exhausted",
      "The practice roster reconciliation limit has been reached.");
  }
  return {replayed: false, state: {...state, status: "reconciled",
    reconciliationRevision: state.reconciliationRevision + 1,
    lastOperationId: operationId, reconciledBy: actorUid,
    reconciledAt: session.virtualNow}};
}

function requireSource(session: Session): State {
  if (!session.rosterReconciliation) {
    throw new HttpsError("failed-precondition",
      "This legacy rehearsal has no committed roster source. Reset it first.");
  }
  return session.rosterReconciliation;
}

function validateRoster(sessionId: string, actors: readonly Actor[]): void {
  if (actors.length < 2 || actors.length > 50 ||
      new Set(actors.map((actor) => actor.actorId)).size !== actors.length ||
      actors.some((actor) => actor.sessionId !== sessionId)) {
    throw new HttpsError("failed-precondition",
      "Practice roster source is invalid.");
  }
}

function count(rows: readonly Row[], outcome: Row["outcome"]): number {
  return rows.filter((row) => row.outcome === outcome).length;
}
