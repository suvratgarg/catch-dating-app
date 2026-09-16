import {Timestamp} from "firebase-admin/firestore";
import type {Firestore, Transaction} from "firebase-admin/firestore";
import type {EventAssistanceMembershipCallableResponse as Response} from
  "../../shared/generated/eventAssistanceMembershipCallableResponse";
import {organizerHostProfiles, organizerManagerUserIds} from
  "../../shared/organizerHosts";
import {eventStaffGrantId, staffTimestampMillis} from
  "../../shared/eventOperatorAuthority";
import {GROUP_DUTY_PERMISSIONS, parseStaff} from "./groupStaffAuthority";
import {invalidSource} from "./groupProgressSource";
import {canReadMembership, membershipDenied, MembershipState} from
  "./membershipReader";
import {membershipActions} from "./membershipTransitions";

type Review = NonNullable<Response["view"]["handoverReview"]>;

/** Names and eligible groups only; no phone or private grant details. */
export async function readMembershipReceivers(db: Firestore, tx: Transaction,
  state: MembershipState, clock: () => number): Promise<Review | undefined> {
  if (!canReadMembership(state)) throw membershipDenied();
  if (!membershipActions(state).includes("propose")) return undefined;
  // The staff writer caps active grants at 50. Read one overflow witness rather
  // than silently presenting a truncated list as complete.
  const grants = await tx.get(db.collection("eventStaffGrants")
    .where("eventId", "==", state.scope.context.eventId)
    .where("status", "==", "active")
    .where("expiresAt", ">", Timestamp.fromMillis(state.now)).limit(51));
  const now = clock();
  if (!Number.isSafeInteger(now) || now < state.now || grants.size > 50) {
    throw invalidSource();
  }
  state.now = now;
  if (!canReadMembership(state)) throw membershipDenied();
  if (!membershipActions(state).includes("propose")) return undefined;
  const expiresAt = Math.min(state.source.eventEnd, now + 1_800_000);
  const managers = organizerManagerUserIds(state.organizer);
  const profiles = organizerHostProfiles(state.organizer);
  const receivers: Review["receivers"] = managers.map((operatorId) => ({
    operatorId,
    displayName: profiles.find((p) => p.uid === operatorId)?.displayName ??
      null,
    groups: state.groups.map((g) => ({groupId: g.groupId,
      validUntil: expiresAt})),
  }));
  for (const snapshot of grants.docs) {
    const raw = snapshot.data();
    const uid = raw?.uid;
    if (typeof uid !== "string" || snapshot.id !==
        eventStaffGrantId(state.scope.context.eventId, uid)) {
      throw invalidSource();
    }
    const staff = parseStaff(raw, state.scope.context, uid, now);
    if (!staff || staff.status !== "active" || managers.includes(uid)) {
      continue;
    }
    const groups = (staff.groupDuties ?? []).flatMap((duty) => {
      const allowed: readonly string[] = GROUP_DUTY_PERMISSIONS[duty.duty];
      const validUntil = Math.min(expiresAt, duty.expiresAtMillis,
        staffTimestampMillis(staff.expiresAt));
      return validUntil > now && allowed.includes("transferGroup") &&
        state.groups.some((g) => g.groupId === duty.groupId &&
          g.sourceHash === duty.sourceHash) ?
        [{groupId: duty.groupId, validUntil}] : [];
    });
    if (groups.length) {
      receivers.push({operatorId: uid, displayName: staff.displayName, groups});
    }
  }
  receivers.sort((a, b) => a.operatorId.localeCompare(b.operatorId));
  return {expiresAt, receivers};
}
