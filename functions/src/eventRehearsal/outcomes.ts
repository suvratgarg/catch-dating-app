import {HttpsError} from "firebase-functions/v2/https";
import type {
  EventRehearsalActorDocument as Actor,
  EventRehearsalDocument as Session,
} from "../shared/generated/firestoreAdminTypes";
import type {ControlEventRehearsalCallablePayload as Control} from
  "../shared/generated/controlEventRehearsalCallablePayload";
import type {EventRehearsalBootstrapCallableResponse as Bootstrap} from
  "../shared/generated/eventRehearsalBootstrapCallableResponse";

type State = NonNullable<Session["unitOutcomes"]>;
type Command = NonNullable<Control["outcome"]>;
export type PracticeOutcomeReview = NonNullable<Bootstrap["outcomeReview"]>;
type UnitOutcome = State["unitOutcome"] | "none";

/** Projects synthetic unit outcomes without reading or changing live scores. */
export function practiceOutcomeReview(
  session: Session,
  actors: readonly Actor[]
): PracticeOutcomeReview {
  const unitIds = currentUnitIds(actors);
  const state = session.unitOutcomes;
  return {
    unitOutcome: practiceUnitOutcome(session),
    revision: state?.revision ?? 0,
    unitIds,
    records: [...(state?.records ?? [])]
      .sort(compareRecords)
      .map((record) => ({
        unitId: record.unitId,
        round: record.round,
        outcome: record.outcome,
        stateRevision: record.stateRevision,
        recordedAt: record.recordedAt.toMillis(),
      })),
  };
}

/** Applies one revision-fenced practice outcome to rehearsal-only state. */
export function preparePracticeOutcome(
  session: Session,
  actors: readonly Actor[],
  command: Command,
  actorUid: string,
  operationId: string
): State {
  if (!["running", "paused", "complete"].includes(session.status)) {
    throw new HttpsError("failed-precondition",
      "Practice outcomes are available after rehearsal starts.");
  }
  const unitOutcome = practiceUnitOutcome(session);
  if (unitOutcome === "none") {
    throw new HttpsError("failed-precondition",
      "This practice event format does not record unit outcomes.");
  }
  const current = session.unitOutcomes;
  if (current && current.unitOutcome !== unitOutcome) {
    throw new HttpsError("failed-precondition",
      "Saved practice outcomes do not match the current setup.");
  }
  const revision = current?.revision ?? 0;
  if (command.expectedOutcomeRevision !== revision) {
    throw new HttpsError("aborted",
      "Practice outcomes changed. Review them again.");
  }
  if (revision >= 2147483647) {
    throw new HttpsError("resource-exhausted",
      "The practice outcome revision limit has been reached.");
  }
  const unitIds = currentUnitIds(actors);
  if (!unitIds.includes(command.unitId)) {
    throw new HttpsError("not-found", "Practice unit not found.");
  }
  validateOutcome(unitOutcome, command.outcome, unitIds.length);

  const records = [...(current?.records ?? [])];
  const existingIndex = records.findIndex((record) =>
    record.unitId === command.unitId && record.round === command.round);
  const existingRounds = new Set(records.map((record) => record.round));
  if (!existingRounds.has(command.round)) {
    const nextRound = records.length === 0 ? 0 :
      Math.max(...records.map((record) => record.round)) + 1;
    if (command.round !== nextRound) {
      throw new HttpsError("failed-precondition",
        `Record practice round ${nextRound} next.`);
    }
    if (nextRound > 0) {
      const previousUnits = new Set(records
        .filter((record) => record.round === nextRound - 1)
        .map((record) => record.unitId));
      if (unitIds.some((unitId) => !previousUnits.has(unitId))) {
        throw new HttpsError("failed-precondition",
          "Complete the previous practice round first.");
      }
    }
  }
  if (command.outcome.kind === "rank") {
    const rank = command.outcome.rank;
    const duplicate = records.some((record, index) =>
      index !== existingIndex && record.round === command.round &&
      record.outcome.kind === "rank" &&
      record.outcome.rank === rank);
    if (duplicate) {
      throw new HttpsError("invalid-argument",
        "Each practice unit needs a unique rank in its round.");
    }
  }
  if (existingIndex < 0 && records.length >= 500) {
    throw new HttpsError("resource-exhausted",
      "This rehearsal reached its practice outcome limit.");
  }
  const nextRevision = revision + 1;
  const record: State["records"][number] = {
    unitId: command.unitId,
    round: command.round,
    outcome: command.outcome,
    stateRevision: nextRevision,
    operationId,
    recordedBy: actorUid,
    recordedAt: session.virtualNow,
  };
  if (existingIndex >= 0) records[existingIndex] = record;
  else records.push(record);
  return {unitOutcome, revision: nextRevision,
    records: records.sort(compareRecords)};
}

/** Resolves the frozen setup primitive, including legacy rehearsal sessions. */
export function practiceUnitOutcome(session: Session): UnitOutcome {
  if (session.setup.unitOutcome) return session.setup.unitOutcome;
  return session.setup.moduleIds.some((moduleId) =>
    moduleId === "pods" || moduleId === "rotations") ? "completion" : "none";
}

function currentUnitIds(actors: readonly Actor[]): string[] {
  return [...new Set(actors.map((actor) => (actor.layoutUnitId ?? "").trim())
    .filter(Boolean))].sort();
}

function validateOutcome(
  unitOutcome: Exclude<UnitOutcome, "none">,
  outcome: Command["outcome"],
  unitCount: number
): void {
  if (outcome.kind !== unitOutcome) {
    throw new HttpsError("invalid-argument",
      `Practice outcomes must use ${unitOutcome} values.`);
  }
  if (outcome.kind === "score" && !Number.isFinite(outcome.score)) {
    throw new HttpsError("invalid-argument",
      "Practice scores must be finite numbers.");
  }
  if (outcome.kind === "rank" &&
      (!Number.isInteger(outcome.rank) || outcome.rank < 1 ||
       outcome.rank > unitCount)) {
    throw new HttpsError("invalid-argument",
      "Practice ranks must be whole numbers within the current unit count.");
  }
}

function compareRecords(
  left: State["records"][number],
  right: State["records"][number]
): number {
  return left.round - right.round || left.unitId.localeCompare(right.unitId);
}
