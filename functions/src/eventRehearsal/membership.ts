import {HttpsError} from "firebase-functions/v2/https";
import type {EventRehearsalDocument as Session,
  EventRehearsalActorDocument as Actor} from
  "../shared/generated/firestoreAdminTypes";
import type {ControlEventRehearsalCallablePayload} from
  "../shared/generated/controlEventRehearsalCallablePayload";
import type {EventRehearsalBootstrapCallableResponse as Bootstrap} from
  "../shared/generated/eventRehearsalBootstrapCallableResponse";
import {isOrganizerManager, organizerManagerUserIds} from
  "../shared/organizerHosts";
import {operationContentHash as hash} from "../operations/durableActions";
import {availableMembershipActions, membershipTransferState,
  prepareMembershipChange, membershipConflict, MembershipDecisionReview} from
  "../eventSuccess/operations/membershipDecisions";
import {timestampEvidence, invalidSource} from
  "../eventSuccess/operations/groupProgressSource";
import {practiceContext, practiceEpisode, practiceState} from
  "./assistanceRuntime";
import type {PracticeCaseAuthority} from "./assistanceCases";
import {validPracticeParticipation} from "./participation";

type Reviews = NonNullable<Bootstrap["membershipReviews"]>;
type Row = Reviews["rows"][number];
type Command = Extract<NonNullable<
  ControlEventRehearsalCallablePayload["assistance"]>, {kind: "transferGroup"}>;

/** Participation episodes survive first arrival, but never a leave/re-entry. */
export function practiceMembershipEpisode(session: Session, actor: Actor) {
  return "episode:" + hash([practiceEpisode(session, actor),
    timestampEvidence(actor.createdAt),
    actor.participation?.episodeRevision ?? null]);
}
function membershipFacts(session: Session, actor: Actor,
  authority: PracticeCaseAuthority) {
  if (!isOrganizerManager(authority.organizer, authority.actorUid)) {
    throw new HttpsError("permission-denied",
      "Current Host authority required.");
  }
  const context = practiceContext(session, actor);
  const route = session.setup.movementSimulation?.routePlan;
  const groups = route?.groupStrategy === "paceGroups" ?
    (route.paceGroups ?? []).map((g) => ({groupId: g.id, label: g.label,
      sourceHash: hash([context, route.groupStrategy, g])})) : [];
  if (new Set(groups.map((g) => g.groupId)).size !== groups.length ||
      groups.some((g) => g.groupId === "event:whole")) throw invalidSource();
  const now = session.virtualNow.toMillis();
  const start = session.virtualStartedAt.toMillis();
  const membership = actor.groupMembership ?? null;
  if (membership) {
    const t = membership.transfer;
    if (membership.clockId !== context.clockId ||
        membership.createdAt < start ||
        membership.createdAt > membership.updatedAt ||
        membership.updatedAt > now ||
        membership.accepted && (membership.accepted.acceptedAt < start ||
          membership.accepted.acceptedAt > membership.updatedAt) ||
        t && (t.requestedAt < start || t.requestedAt > membership.updatedAt ||
          t.expiresAt <= t.requestedAt || t.from === t.to ||
          (t.status === "pending" ? t.resolvedAt !== null ||
            t.resolvedBy !== null ||
            t.from !== (membership.accepted?.groupId ?? null) :
            t.resolvedAt === null || t.resolvedBy === null ||
            t.resolvedAt < t.requestedAt ||
            t.resolvedAt > membership.updatedAt))) throw invalidSource();
  }
  const valid = validPracticeParticipation(actor);
  const episodeId = valid ? practiceMembershipEpisode(session, actor) : null;
  const availability: Row["availability"] = groups.length === 0 ?
    "notApplicable" : !actor.participation ? "participationNotRecorded" :
      !valid ? "invalidSource" : "ready";
  const current = !!membership && valid &&
    membership.episodeId === episodeId && (!membership.accepted ||
      groups.some((g) => g.groupId === membership.accepted!.groupId &&
        g.sourceHash === membership.accepted!.groupSourceHash));
  const end = start + session.setup.durationMinutes * 60000;
  const ready = availability === "ready" &&
    actor.participation!.state === "active" &&
    practiceState(actor).intention.kind !== "notComing" &&
    ["running", "paused"].includes(session.status) && now < end;
  const facts: MembershipDecisionReview = {now, actorUid: authority.actorUid,
    manager: true, hasGuest: valid, current, ready, membership, groups,
    transferableGroupIds: groups.map((g) => g.groupId)};
  return {facts, context, episodeId, availability, end,
    membershipId: "practice-membership:" + hash([context, actor.actorId]),
    sourceHash: hash([context, actor.actorId,
      timestampEvidence(actor.createdAt), actor.participation ?? null,
      practiceState(actor).intention, groups, session.setup.durationMinutes]),
    writable: ["running", "paused", "complete"].includes(session.status) &&
      session.actionCount < 500 && session.runtimeRevision < 2147483647 &&
      (membership?.revision ?? 0) < Number.MAX_SAFE_INTEGER};
}

export function practiceMembershipView(session: Session, actor: Actor,
  authority: PracticeCaseAuthority): Row {
  const s = membershipFacts(session, actor, authority);
  return {attendeeId: actor.actorId, sourceHash: s.sourceHash,
    serverTime: s.facts.now, revision: actor.groupMembership?.revision ?? 0,
    episodeId: s.episodeId,
    participationRevision: s.episodeId === null ? 0 :
      actor.participation?.revision ?? 0,
    freshness: !actor.groupMembership ? "uninitialized" : s.facts.current ?
      "current" : "sourceChanged", ready: s.facts.ready,
    accepted: actor.groupMembership?.accepted ?? null,
    transfer: actor.groupMembership?.transfer ?? null,
    transferState: membershipTransferState(s.facts),
    groups: s.facts.groups.map(({groupId, label}) => ({groupId, label})),
    actions: s.availability === "ready" && s.writable ?
      availableMembershipActions(s.facts) : [], availability: s.availability};
}

/** Current managers practice the same atomic handover as live managers. */
export function transferPracticeMembership(session: Session, actor: Actor,
  command: Command, authority: PracticeCaseAuthority,
  operationId: string): Actor {
  const s = membershipFacts(session, actor, authority);
  const p = command.payload;
  if (command.actorId !== actor.actorId || p.attendeeId !== actor.actorId ||
      p.episodeId !== s.episodeId ||
      p.expectedParticipationRevision !== actor.participation?.revision ||
      p.expectedMembershipRevision !== (actor.groupMembership?.revision ?? 0) ||
      command.expectedSourceHash !== s.sourceHash) throw membershipConflict();
  if (!s.writable || s.availability !== "ready" || !operationId) {
    throw new HttpsError("failed-precondition",
      "This practice membership is unavailable.");
  }
  if (p.decision.kind === "propose" && !isOrganizerManager(
    authority.organizer, p.decision.receivingOperatorId)) {
    throw new HttpsError("permission-denied",
      "Choose a current rehearsal Host to receive the guest.");
  }
  const change = prepareMembershipChange(s.facts, {payload: p, operationId},
    {membershipId: s.membershipId, episodeId: s.episodeId!, eventEnd: s.end});
  return {...actor, groupMembership: {...change,
    clockId: s.context.clockId, episodeId: s.episodeId!,
    revision: (actor.groupMembership?.revision ?? 0) + 1,
    createdAt: actor.groupMembership?.createdAt ?? s.facts.now,
    updatedAt: s.facts.now}};
}

/** Complete, private Host coverage; no production roster or duty reads. */
export function practiceMembershipProjection(sessionId: string,
  session: Session, actors: readonly Actor[],
  authority: PracticeCaseAuthority): Reviews {
  if (actors.length !== session.actorCount || actors.length > 50 ||
      actors.some((a) => a.sessionId !== sessionId) ||
      new Set(actors.map((a) => a.actorId)).size !== actors.length) {
    throw new HttpsError("failed-precondition", "Practice roster changed.");
  }
  return {clockId: practiceContext(session, {sessionId}).clockId,
    actorUid: authority.actorUid, coverage: "boundedSession",
    receivingOperatorIds: organizerManagerUserIds(authority.organizer).sort(),
    rows: actors.map((a) => practiceMembershipView(session, a, authority))
      .sort((a, b) => a.attendeeId.localeCompare(b.attendeeId))};
}
