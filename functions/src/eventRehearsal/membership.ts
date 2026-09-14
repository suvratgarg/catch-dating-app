import {requirePracticeHost, practiceIsManager, practiceGroupPermission,
  practiceStaffState} from "./groupStaff";
import {HttpsError} from "firebase-functions/v2/https";
import type {EventRehearsalDocument as Session,
  EventRehearsalActorDocument as Actor} from
  "../shared/generated/firestoreAdminTypes";
import type {ControlEventRehearsalCallablePayload} from
  "../shared/generated/controlEventRehearsalCallablePayload";
import type {EventRehearsalBootstrapCallableResponse as Bootstrap} from
  "../shared/generated/eventRehearsalBootstrapCallableResponse";
import {organizerManagerUserIds} from
  "../shared/organizerHosts";
import {operationContentHash as hash} from "../operations/durableActions";
import {availableMembershipActions, membershipTransferState,
  prepareMembershipChange, membershipConflict, MembershipDecisionReview} from
  "../eventSuccess/operations/membershipDecisions";
import {timestampEvidence} from
  "../eventSuccess/operations/groupProgressSource";
import {practiceContext, practiceState} from "./assistanceIdentity";
import {practiceMembershipSource} from "./membershipSource";
export {practiceMembershipEpisode} from "./membershipSource";
import type {PracticeCaseAuthority} from "./assistanceCases";

type Reviews = NonNullable<Bootstrap["membershipReviews"]>;
type Row = Reviews["rows"][number];
type Command = Extract<NonNullable<
  ControlEventRehearsalCallablePayload["assistance"]>, {kind: "transferGroup"}>;

function membershipFacts(session: Session, actor: Actor,
  authority: PracticeCaseAuthority) {
  requirePracticeHost(authority);
  const {context, groups, now, membership, valid, episodeId,
    availability, current, end, ready} = practiceMembershipSource(session,
    actor);
  const facts: MembershipDecisionReview = {now, actorUid: authority.actorUid,
    manager: practiceIsManager(authority), hasGuest: valid, current, ready,
    membership, groups, transferableGroupIds: groups.filter((g) =>
      practiceGroupPermission(actor.sessionId, session, authority, g.groupId,
        "transferGroup") !== null).map((g) => g.groupId)};
  return {facts, context, episodeId, availability, end,
    membershipId: "practice-membership:" + hash([context, actor.actorId]),
    sourceHash: hash([...(authority.practiceOperatorId ?
      [authority.practiceOperatorId] : []), context, actor.actorId,
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
  if (p.decision.kind === "propose" && practiceGroupPermission(actor.sessionId,
    session, authority, p.decision.to, "transferGroup",
    p.decision.receivingOperatorId) === null) {
    throw new HttpsError("permission-denied",
      "Choose a practice operator with a current receiving-group duty.");
  }
  const change = prepareMembershipChange(s.facts, {payload: p, operationId},
    {membershipId: s.membershipId, episodeId: s.episodeId!, eventEnd: s.end});
  const revision = (actor.groupMembership?.revision ?? 0) + 1;
  const assignmentRevision = ["place", "accept", "leave"].includes(
    p.decision.kind) ? revision : actor.groupMembership?.assignmentRevision;
  return {...actor, groupMembership: {...change,
    ...(assignmentRevision === undefined ? {} : {assignmentRevision}),
    clockId: s.context.clockId, episodeId: s.episodeId!,
    revision,
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
    receivingOperatorIds: [...organizerManagerUserIds(authority.organizer),
      ...practiceStaffState(sessionId, session).operators.filter((o) =>
        o.duties.some((d) => practiceGroupPermission(sessionId, session,
          authority, d.groupId, "transferGroup", o.operatorId) !== null))
        .map((o) => o.operatorId)].sort(),
    rows: actors.map((a) => practiceMembershipView(session, a, authority))
      .sort((a, b) => a.attendeeId.localeCompare(b.attendeeId))};
}
