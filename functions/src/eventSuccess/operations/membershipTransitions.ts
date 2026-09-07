import {HttpsError} from "firebase-functions/v2/https";
import type {TransferEventAssistanceGroupCallablePayload as Input} from
  "../../shared/generated/transferEventAssistanceGroupCallablePayload";
import type {EventAssistanceMembershipCallableResponse as Response} from
  "../../shared/generated/eventAssistanceMembershipCallableResponse";
import {validateEventAssistanceMembershipCallableResponse} from
  "../../shared/generated/validators/eventAssistanceMembershipOutput";
import {operationContentHash} from "../../operations/durableActions";
import {invalidSource} from "./groupProgressSource";
import {Membership, MembershipState, currentMembership, membershipReady,
  memberAccess, membershipDenied} from "./membershipReader";

type View = Response["view"];
type Decision = Input["command"]["payload"]["decision"];
export function transferState(s: MembershipState): View["transferState"] {
  const t = s.membership?.transfer;
  if (!t) return "none";
  if (t.status !== "pending") return t.status;
  if (!currentMembership(s) || !s.groups.some((g) =>
    g.groupId === t.to && g.sourceHash === t.targetSourceHash)) {
    return "sourceChanged";
  }
  return s.now >= t.expiresAt ? "expired" : "pending";
}
export function membershipActions(s: MembershipState): View["actions"] {
  const result: View["actions"] = [];
  if (!s.guest) return result;
  const current = currentMembership(s);
  const accepted = current ? s.membership!.accepted : null;
  const t = s.membership?.transfer;
  const sourceAccess = s.manager || !!accepted &&
    memberAccess(s, accepted.groupId, "transferGroup");
  const pending = transferState(s) === "pending";
  if (membershipReady(s) && sourceAccess && !pending) {
    if (!accepted && s.manager) result.push("place");
    result.push("propose");
  }
  if (pending && t?.receivingOperatorId === s.actorUid &&
      memberAccess(s, t.to, "transferGroup")) {
    if (membershipReady(s)) result.push("accept");
    result.push("reject");
  }
  if (t?.status === "pending" && sourceAccess) result.push("cancel");
  if (s.membership?.accepted && sourceAccess) result.push("leave");
  return result;
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
/** Pure transition; the store supplies freshly authorized source facts. */
export function transitionMembership(s: MembershipState,
  input: Input): Membership {
  const {decision} = input.command.payload;
  if (!membershipActions(s).includes(decision.kind)) throw membershipDenied();
  const current = currentMembership(s);
  let accepted = current ? s.membership!.accepted : null;
  let transfer = current ? s.membership!.transfer : null;
  const group = (id: string) => {
    const value = s.groups.find((g) => g.groupId === id);
    if (!value) throw invalidSource();
    return value;
  };
  const resolve = (status: "accepted" | "rejected" | "cancelled") => {
    const old = s.membership?.transfer;
    if (!old || !("transferId" in decision) ||
        decision.transferId !== old.transferId || old.status !== "pending") {
      throw membershipConflict();
    }
    return {...old, status, resolvedAt: s.now, resolvedBy: s.actorUid};
  };
  switch (decision.kind) {
  case "place":
    accepted = {groupId: decision.groupId,
      groupSourceHash: group(decision.groupId).sourceHash,
      responsibleOperatorId: s.actorUid, acceptedAt: s.now};
    transfer = null;
    break;
  case "propose": {
    if (decision.from !== (accepted?.groupId ?? null) ||
        decision.to === decision.from) throw membershipConflict();
    if (decision.expiresAtMillis <= s.now ||
        decision.expiresAtMillis > Math.min(s.now + 1_800_000,
          s.source.eventEnd)) {
      throw new HttpsError("failed-precondition",
        "Choose a handover deadline within 30 minutes and this event.");
    }
    transfer = {transferId: "transfer:" + operationContentHash([
      s.membershipId, s.guest!.episodeId, input.command.operationId,
      input.command.payload.expectedMembershipRevision]),
    from: decision.from, to: decision.to,
    targetSourceHash: group(decision.to).sourceHash,
    receivingOperatorId: decision.receivingOperatorId,
    requestedBy: s.actorUid, requestedAt: s.now,
    expiresAt: decision.expiresAtMillis, status: "pending",
    resolvedAt: null, resolvedBy: null};
    break;
  }
  case "accept":
    transfer = resolve("accepted");
    accepted = {groupId: transfer.to,
      groupSourceHash: group(transfer.to).sourceHash,
      responsibleOperatorId: s.actorUid, acceptedAt: s.now};
    break;
  case "reject": transfer = resolve("rejected"); break;
  case "cancel": transfer = resolve("cancelled"); break;
  case "leave":
    accepted = null;
    if (transfer?.status === "pending") {
      transfer = {...transfer,
        status: "cancelled", resolvedAt: s.now, resolvedBy: s.actorUid};
    }
    break;
  default: {
    const exhaustive: never = decision;
    throw new Error("Unknown membership transition: " + exhaustive);
  }
  }
  return {schemaVersion: 1, membershipId: s.membershipId, ...s.scope,
    sourceGeneration: s.source.sourceGeneration,
    attendeeGeneration: s.source.attendeeGeneration,
    episodeId: s.guest!.episodeId, revision: (s.membership?.revision ?? 0) + 1,
    accepted, transfer, createdAt: s.membership?.createdAt ?? s.now,
    updatedAt: s.now};
}
export function membershipConflict() {
  return new HttpsError("aborted",
    "Group membership changed. Refresh and retry.");
}
export type {Decision};
