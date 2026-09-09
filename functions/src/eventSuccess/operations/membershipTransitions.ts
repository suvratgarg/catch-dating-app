import {availableMembershipActions, membershipTransferState,
  prepareMembershipChange, membershipDecisionDenied} from
  "./membershipDecisions";
import type {TransferEventAssistanceGroupCallablePayload as Input} from
  "../../shared/generated/transferEventAssistanceGroupCallablePayload";
import type {EventAssistanceMembershipCallableResponse as Response} from
  "../../shared/generated/eventAssistanceMembershipCallableResponse";
import {validateEventAssistanceMembershipCallableResponse} from
  "../../shared/generated/validators/eventAssistanceMembershipOutput";
import {invalidSource} from "./groupProgressSource";
import {Membership, MembershipState, currentMembership, membershipReady,
  memberAccess} from "./membershipReader";

type View = Response["view"];
function decisionReview(s: MembershipState) {
  return {now: s.now, actorUid: s.actorUid, manager: s.manager,
    hasGuest: !!s.guest, ready: membershipReady(s),
    current: currentMembership(s), membership: s.membership, groups: s.groups,
    transferableGroupIds: s.groups.filter((g) =>
      memberAccess(s, g.groupId, "transferGroup")).map((g) => g.groupId)};
}
export function transferState(s: MembershipState): View["transferState"] {
  return membershipTransferState(decisionReview(s));
}
export function membershipActions(s: MembershipState): View["actions"] {
  return availableMembershipActions(decisionReview(s));
}
export function membershipResponse(outcome: Response["outcome"],
  s: MembershipState, operationRevision: number | null = null): Response {
  const value: Response = {outcome, operationRevision, view: {
    ...s.scope, sourceHash: s.sourceHash, serverTime: s.now,
    revision: s.membership?.revision ?? 0,
    episodeId: s.guest?.episodeId ?? null,
    participationRevision: s.guest?.revision ?? 0,
    freshness: !s.membership ? "uninitialized" : currentMembership(s) ?
      "current" : "sourceChanged", ready: membershipReady(s),
    accepted: s.membership?.accepted ?? null,
    transfer: s.membership?.transfer ?? null, transferState: transferState(s),
    groups: s.groups.map(({groupId, label}) => ({groupId, label})),
    actions: membershipActions(s)}};
  if (!validateEventAssistanceMembershipCallableResponse(value)) {
    throw invalidSource();
  }
  return value;
}
/** Persistence keeps its live context; both modes share the decision rule. */
export function transitionMembership(s: MembershipState,
  input: Input): Membership {
  if (!s.guest) throw membershipDecisionDenied();
  const {accepted, transfer} = prepareMembershipChange(decisionReview(s),
    input.command, {membershipId: s.membershipId, episodeId: s.guest!.episodeId,
      eventEnd: s.source.eventEnd});
  return {schemaVersion: 1, membershipId: s.membershipId, ...s.scope,
    sourceGeneration: s.source.sourceGeneration,
    attendeeGeneration: s.source.attendeeGeneration,
    episodeId: s.guest!.episodeId, revision: (s.membership?.revision ?? 0) + 1,
    accepted, transfer, createdAt: s.membership?.createdAt ?? s.now,
    updatedAt: s.now};
}
export {membershipConflict} from "./membershipDecisions";
export type {Decision} from "./membershipDecisions";
