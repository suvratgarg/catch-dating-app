import {HttpsError} from "firebase-functions/v2/https";
import type {EventRehearsalDocument as Session,
  EventRehearsalActorDocument as Actor} from
  "../shared/generated/firestoreAdminTypes";
import type {PracticePlan} from "./assistanceRuntime";
import type {PracticeDepartures} from "./movementGuidance";
import {practiceContext, practiceEpisode} from "./assistanceIdentity";
import {practiceMovementSource} from "./movementSource";
import {practiceMembershipSource} from "./membershipSource";
import {parsePracticeMovement} from "./movementRecords";
import {bindPolicyTemplate} from "../eventSuccess/operations/policySettings";
import {operationContentHash as hash} from "../operations/durableActions";
import {practiceSettingsGroup, practiceSettingsState, PracticeRuntime} from
  "./assistanceSettings";

export type ManagedPracticeRecipe =
  | {kind: "manual"}
  | {kind: "unavailable"}
  | {kind: "disabled"}
  | {kind: "ready"; plan: PracticePlan; paused: boolean;
      outcomes: PracticeRuntime["configuration"]["outcomes"]};

/** Rebind only event-enrolled recipes; a timetable cannot confirm departure. */
export function managedPracticeRecipe(session: Session, actor: Actor,
  departures: PracticeDepartures): ManagedPracticeRecipe {
  try {
    return resolveRecipe(session, actor, departures);
  } catch (error) {
    if (error instanceof HttpsError && error.code === "failed-precondition") {
      return {kind: "unavailable"};
    }
    throw error;
  }
}
function resolveRecipe(session: Session, actor: Actor,
  departures: PracticeDepartures): ManagedPracticeRecipe {
  if (!["running", "paused"].includes(session.status) ||
      session.virtualNow.toMillis() >= session.virtualStartedAt.toMillis() +
        session.setup.durationMinutes * 60000) return {kind: "manual"};
  if (actor.assistanceAutomation &&
      actor.assistanceAutomation.origin !== "eventSettings") {
    return {kind: "manual"};
  }
  const runtime = practiceSettingsState(actor.sessionId, session).runtime;
  if (!runtime) return {kind: "unavailable"};
  const membership = practiceMembershipSource(session, actor);
  const groupId = !membership.groups.length ? "event:whole" :
    membership.current && membership.ready ?
      membership.membership?.accepted?.groupId : null;
  if (!groupId) return {kind: "unavailable"};
  const group = practiceSettingsGroup(actor.sessionId, session, groupId);
  const source = practiceMovementSource(actor.sessionId, session, groupId);
  if (group.status === "disabled") return {kind: "disabled"};
  if (!source.eventOpen || !group.effective ||
      group.status !== "configured") return {kind: "unavailable"};
  const movement = departures.get(groupId);
  if (!movement) return {kind: "unavailable"};
  parsePracticeMovement(movement, source);
  const destination = source.destinations.find((d) =>
    hash(d.target) === hash(movement.departure.destination));
  if (!destination || movement.departure.sourceHash !== source.sourceHash) {
    return {kind: "unavailable"};
  }
  const policy = bindPolicyTemplate(group.effective,
    {kind: "guest", eventId: practiceContext(session, actor).virtualEventId,
      attendeeId: actor.actorId, episodeId: practiceEpisode(session, actor)},
    source.destinations.map((d) => d.target), destination.target);
  if (policy?.kind !== "lateJoin") return {kind: "unavailable"};
  const {configuration: config} = runtime;
  // Restrict the selected current venue; an override cannot relax entry rules.
  const target = destination.target.kind === "fixedPlace" &&
    policy.config.destination.kind === "fixedPlace" &&
    policy.config.destination.placeId === destination.target.placeId &&
    destination.target.lateEntry === "allowed" ?
    {...destination.target, lateEntry: policy.config.destination.lateEntry} :
    destination.target;
  const plan: PracticePlan = {policy: policy.config,
    setting: group.effective.setting,
    guidance: {revision: movement.progressRevision, destination: target,
      materialKey: hash([source.sourceHash, target]), text: destination.text,
      validUntil: source.endAt}, departureConfirmed: true,
    responseDeadline: config.responseDeadline, routes: config.routes,
    deliveryPolicy: config.deliveryPolicy,
    ...(config.laterChoices === undefined ? {} : {laterChoices:
      config.laterChoices.filter((c) => source.destinations.some((d) =>
        hash(d.target) === hash(c.target)))})};
  return {kind: "ready", plan, outcomes: config.outcomes,
    paused: runtime.status === "paused"};
}
