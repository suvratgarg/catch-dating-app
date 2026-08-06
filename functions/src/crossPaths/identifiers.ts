import {createHash} from "node:crypto";

export function crossPathsInvitationId(
  eventId: string,
  senderUid: string
): string {
  return `cp_${sha256(`${eventId}\u0000${senderUid}`).slice(0, 48)}`;
}

export function crossPathsEventPlanId(
  eventId: string,
  userA: string,
  userB: string
): string {
  const pair = [userA, userB].sort().join("\u0000");
  return `cpp_${sha256(`${eventId}\u0000${pair}`).slice(0, 48)}`;
}

export function crossPathsPairHoldId(invitationId: string): string {
  return `cph_${sha256(invitationId).slice(0, 48)}`;
}

function sha256(value: string): string {
  return createHash("sha256").update(value).digest("hex");
}
