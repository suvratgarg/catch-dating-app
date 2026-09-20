import {HttpsError} from "firebase-functions/v2/https";
import type {EventAssistanceCommand} from
  "../../shared/generated/eventAssistanceCommand";
import type {EventAssistanceMembershipDocument as Membership} from
  "../../shared/generated/eventAssistanceMembershipDocument";
import type {EventAssistanceMembershipCallableResponse as Response} from
  "../../shared/generated/eventAssistanceMembershipCallableResponse";
import {operationContentHash} from "../../operations/durableActions";
import {invalidSource} from "./groupProgressSource";

export type TransferPayload = Extract<EventAssistanceCommand,
  {kind: "transferGroup"}>["payload"];
export type Decision = TransferPayload["decision"];
type View = Response["view"];
export interface MembershipDecisionReview {
  now: number;
  actorUid: string;
  manager: boolean;
  hasGuest: boolean;
  ready: boolean;
  current: boolean;
  membership: Pick<Membership, "accepted" | "transfer"> | null;
  groups: readonly {groupId: string; label: string; sourceHash: string}[];
  transferableGroupIds: readonly string[];
}

export function membershipTransferState(s: MembershipDecisionReview):
  View["transferState"] {
  const t = s.membership?.transfer;
  if (!t) return "none";
  if (t.status !== "pending") return t.status;
  if (!s.current || !s.groups.some((g) =>
    g.groupId === t.to && g.sourceHash === t.targetSourceHash)) {
    return "sourceChanged";
  }
  return s.now >= t.expiresAt ? "expired" : "pending";
}
export function availableMembershipActions(s: MembershipDecisionReview):
  View["actions"] {
  const result: View["actions"] = [];
  if (!s.hasGuest) return result;
  const current = s.current;
  const accepted = current ? s.membership!.accepted : null;
  const t = s.membership?.transfer;
  const sourceAccess = s.manager || !!accepted &&
    s.transferableGroupIds.includes(accepted.groupId);
  const pending = membershipTransferState(s) === "pending";
  if (s.ready && sourceAccess && !pending) {
    if (!accepted && s.manager) result.push("place");
    result.push("propose");
  }
  if (pending && t?.receivingOperatorId === s.actorUid &&
      s.transferableGroupIds.includes(t.to)) {
    if (s.ready) result.push("accept");
    result.push("reject");
  }
  if (t?.status === "pending" && sourceAccess) result.push("cancel");
  if (s.membership?.accepted && sourceAccess) result.push("leave");
  return result;
}
/** Both execution modes supply current facts; this rule performs no I/O. */
export function prepareMembershipChange(s: MembershipDecisionReview,
  input: {payload: TransferPayload; operationId: string},
  identity: {membershipId: string; episodeId: string; eventEnd: number}) {
  const {decision} = input.payload;
  if (!availableMembershipActions(s).includes(decision.kind)) {
    throw membershipDecisionDenied();
  }
  const current = s.current;
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
          identity.eventEnd)) {
      throw new HttpsError("failed-precondition",
        "Choose a handover deadline within 30 minutes and this event.");
    }
    transfer = {transferId: "transfer:" + operationContentHash([
      identity.membershipId, identity.episodeId, input.operationId,
      input.payload.expectedMembershipRevision]),
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
  return {accepted, transfer};
}
export function membershipConflict() {
  return new HttpsError("aborted",
    "Group membership changed. Refresh and retry.");
}
export function membershipDecisionDenied() {
  return new HttpsError("permission-denied",
    "This account cannot manage this guest's group membership.");
}
