import {HttpsError} from "firebase-functions/v2/https";
import type {EventRehearsalDocument as Session,
  EventRehearsalActorDocument as Actor} from
  "../shared/generated/firestoreAdminTypes";
import type {EventRehearsalMessageDocument as Message} from
  "../shared/generated/eventRehearsalMessageDocument";
import {operationContentHash as hash} from "../operations/durableActions";
import {timestampEvidence, invalidSource} from
  "../eventSuccess/operations/groupProgressSource";
import {practiceContext, practiceEpisode, practiceState} from
  "./assistanceIdentity";
import {validPracticeParticipation} from "./participation";

type Availability = "ready" | "notApplicable" | "participationNotRecorded" |
  "invalidSource";

/** Participation episodes survive first arrival, but never a leave/re-entry. */
export function practiceMembershipEpisode(session: Session, actor: Actor) {
  return "episode:" + hash([practiceEpisode(session, actor),
    timestampEvidence(actor.createdAt),
    actor.participation?.episodeRevision ?? null]);
}
export function practiceMembershipSource(session: Session, actor: Actor) {
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
    if (membership.assignmentRevision !== undefined &&
        (!Number.isSafeInteger(membership.assignmentRevision) ||
          membership.assignmentRevision < 1 ||
          membership.assignmentRevision > membership.revision) ||
        membership.clockId !== context.clockId ||
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
  const availability: Availability = groups.length === 0 ?
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
  return {context, groups, now, membership, valid, episodeId,
    availability, current, end, ready};
}

/** Proposals preserve this proof; changed acceptance retires it. */
export function practiceGuidanceBinding(session: Session, actor: Actor,
  target: Message["plan"]["guidance"]["destination"]):
  NonNullable<Message["membershipBinding"]> | null | undefined {
  if (target.kind !== "groupCheckpoint") return undefined;
  let s: ReturnType<typeof practiceMembershipSource>;
  try {
    s = practiceMembershipSource(session, actor);
  } catch (error) {
    if (error instanceof HttpsError && error.code === "failed-precondition") {
      return null;
    }
    throw error;
  }
  const accepted = s.membership?.accepted;
  if (!s.current || !s.valid || actor.participation?.state !== "active" ||
      !accepted || accepted.groupId !== target.groupId ||
      !s.membership?.assignmentRevision) return null;
  return {episodeId: s.episodeId!, groupId: accepted.groupId,
    groupSourceHash: accepted.groupSourceHash,
    assignmentRevision: s.membership.assignmentRevision};
}
