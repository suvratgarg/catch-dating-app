import {HttpsError} from "firebase-functions/v2/https";
import type {
  EventRehearsalActorDocument as Actor,
  EventRehearsalDocument as Session,
} from "../shared/generated/firestoreAdminTypes";
import type {EventRehearsalBootstrapCallableResponse as Bootstrap} from
  "../shared/generated/eventRehearsalBootstrapCallableResponse";
import type {EventAssistanceCommand} from
  "../shared/generated/eventAssistanceCommand";
import {operationContentHash as hash} from "../operations/durableActions";
import {practiceContext} from "./assistanceRuntime";

type State = NonNullable<Session["allocationState"]>;
type Proposal = State["proposals"][number];
type ProposePayload = Extract<EventAssistanceCommand,
  {kind: "proposeAllocation"}>["payload"];
type PublishPayload = Extract<EventAssistanceCommand,
  {kind: "publishAllocation"}>["payload"];
export type PracticeAllocationCommand =
  ({kind: "propose"} & ProposePayload) |
  ({kind: "publish"} & PublishPayload);
export type PracticeAllocationReview = NonNullable<
  Bootstrap["allocationReview"]
>;

export interface PracticeAllocationResult {
  state: State;
  actors: Actor[];
  replayed: boolean;
}

const maxProposals = 100;
const syntheticUnitCapacity = 4;

/** Projects current synthetic assignments plus bounded Host proposals. */
export function practiceAllocationReview(
  session: Session,
  actors: readonly Actor[]
): PracticeAllocationReview {
  const state = allocationState(session);
  return {
    revision: state.revision,
    unitIds: currentUnitIds(actors),
    assignments: [...actors]
      .sort((left, right) => left.actorId.localeCompare(right.actorId))
      .map((actor) => ({
        attendeeId: actor.actorId,
        unitId: actor.layoutUnitId,
      })),
    proposals: [...state.proposals]
      .sort((left, right) =>
        left.proposedAt.toMillis() - right.proposedAt.toMillis() ||
        left.proposalId.localeCompare(right.proposalId))
      .map((proposal) => ({
        proposalId: proposal.proposalId,
        attendeeIds: proposal.attendeeIds,
        targetUnitId: proposal.targetUnitId,
        baseRevision: proposal.baseRevision,
        status: proposal.status,
        decisionId: proposal.decisionId,
        publishedRevision: proposal.publishedRevision,
        proposedAt: proposal.proposedAt.toMillis(),
        publishedAt: proposal.publishedAt?.toMillis() ?? null,
      })),
  };
}

/** Prepares or publishes one proposal without touching a live assignment. */
export function preparePracticeAllocation(
  sessionId: string,
  session: Session,
  actors: readonly Actor[],
  command: PracticeAllocationCommand,
  actorUid: string,
  operationId: string,
  now: FirebaseFirestore.Timestamp
): PracticeAllocationResult {
  if (!["running", "paused"].includes(session.status)) {
    throw new HttpsError("failed-precondition",
      "Practice allocations are available only while rehearsal is active.");
  }
  validateRoster(sessionId, session, actors);
  const state = allocationState(session);
  if (command.kind === "propose") {
    if (command.expectedAllocationRevision !== state.revision) {
      throw new HttpsError("aborted",
        "Practice assignments changed. Review them again.");
    }
    if (state.proposals.length >= maxProposals) {
      throw new HttpsError("resource-exhausted",
        "This rehearsal reached its allocation-proposal limit.");
    }
    validatePlacement(actors, command.attendeeIds, command.targetUnitId);
    const proposalId = "practice-allocation:" + hash([
      practiceContext(session, {sessionId}),
      operationId,
      command.attendeeIds,
      command.targetUnitId,
      state.revision,
    ]);
    const proposal: Proposal = {
      proposalId,
      attendeeIds: [...command.attendeeIds].sort(),
      targetUnitId: command.targetUnitId,
      baseRevision: state.revision,
      status: "pending",
      decisionId: null,
      publishedRevision: null,
      proposedBy: actorUid,
      operationId,
      proposedAt: session.virtualNow,
      publishedAt: null,
    };
    return {state: {...state, proposals: [...state.proposals, proposal]},
      actors: [], replayed: false};
  }

  const proposalIndex = state.proposals.findIndex((proposal) =>
    proposal.proposalId === command.proposalId);
  if (proposalIndex < 0) {
    throw new HttpsError("not-found",
      "Practice allocation proposal not found.");
  }
  const proposal = state.proposals[proposalIndex];
  const priorDecision = state.proposals.find((candidate) =>
    candidate.decisionId === command.decisionId);
  if (priorDecision) {
    if (priorDecision.proposalId !== proposal.proposalId ||
        proposal.status !== "published") {
      throw new HttpsError("aborted",
        "This allocation decision id already belongs to another proposal.");
    }
    return {state, actors: [], replayed: true};
  }
  if (proposal.status !== "pending") {
    throw new HttpsError("failed-precondition",
      "This practice allocation proposal is no longer current.");
  }
  if (proposal.baseRevision !== state.revision) {
    throw new HttpsError("aborted",
      "Practice assignments changed after this proposal was prepared.");
  }
  if (state.revision >= 2147483647) {
    throw new HttpsError("resource-exhausted",
      "The practice allocation revision limit has been reached.");
  }
  validatePlacement(actors, proposal.attendeeIds, proposal.targetUnitId);
  const nextRevision = state.revision + 1;
  const selected = new Set(proposal.attendeeIds);
  const nextActors = actors.filter((actor) => selected.has(actor.actorId))
    .map((actor) => ({
      ...actor,
      layoutUnitId: proposal.targetUnitId,
      confirmedLayoutUnitId: null,
      guestMoment: "assignment" as const,
      lastActionAt: now,
      updatedAt: now,
    }));
  const proposals = state.proposals.map((candidate, index): Proposal => {
    if (index === proposalIndex) {
      return {...candidate, status: "published",
        decisionId: command.decisionId, publishedRevision: nextRevision,
        publishedAt: session.virtualNow};
    }
    return candidate.status === "pending" &&
      candidate.baseRevision === state.revision ?
      {...candidate, status: "stale"} : candidate;
  });
  return {state: {revision: nextRevision, proposals},
    actors: nextActors, replayed: false};
}

function allocationState(session: Session): State {
  return session.allocationState ?? {revision: 0, proposals: []};
}

function validateRoster(
  sessionId: string,
  session: Session,
  actors: readonly Actor[]
): void {
  if (actors.length !== session.actorCount || actors.length > 50 ||
      new Set(actors.map((actor) => actor.actorId)).size !== actors.length ||
      actors.some((actor) => actor.sessionId !== sessionId)) {
    throw new HttpsError("failed-precondition", "Practice roster changed.");
  }
}

function validatePlacement(
  actors: readonly Actor[],
  attendeeIds: readonly string[],
  targetUnitId: string
): void {
  const units = new Set(currentUnitIds(actors));
  if (!units.has(targetUnitId)) {
    throw new HttpsError("not-found", "Practice target unit not found.");
  }
  if (new Set(attendeeIds).size !== attendeeIds.length) {
    throw new HttpsError("invalid-argument",
      "Choose each practice guest only once.");
  }
  const byId = new Map(actors.map((actor) => [actor.actorId, actor]));
  const selected = attendeeIds.map((id) => byId.get(id));
  if (selected.some((actor) => !actor)) {
    throw new HttpsError("not-found", "Practice guest not found.");
  }
  const guests = selected as Actor[];
  if (guests.every((actor) => actor.layoutUnitId === targetUnitId)) {
    throw new HttpsError("failed-precondition",
      "These practice guests are already in that unit.");
  }
  if (guests.some((actor) => actor.optedOut ||
      ["noShow", "departed", "ambiguousClaim"].includes(actor.status))) {
    throw new HttpsError("failed-precondition",
      "Only eligible practice guests can be allocated.");
  }
  const selectedIds = new Set(attendeeIds);
  const targetActors = actors.filter((actor) =>
    selectedIds.has(actor.actorId) ||
    (!selectedIds.has(actor.actorId) && actor.layoutUnitId === targetUnitId));
  if (targetActors.length > syntheticUnitCapacity) {
    throw new HttpsError("failed-precondition",
      "This practice unit has room for four guests.");
  }
  for (const actor of targetActors) {
    if (targetActors.some((other) => other.actorId !== actor.actorId &&
      (actor.keepApartActorIds.includes(other.actorId) ||
       other.keepApartActorIds.includes(actor.actorId)))) {
      throw new HttpsError("failed-precondition",
        "This proposal conflicts with a practice keep-apart rule.");
    }
  }
}

function currentUnitIds(actors: readonly Actor[]): string[] {
  return [...new Set(actors.map((actor) => actor.layoutUnitId)
    .filter((unitId): unitId is string => Boolean(unitId)))]
    .sort();
}
