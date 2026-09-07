import {HttpsError} from "firebase-functions/v2/https";
import type {Firestore, Transaction} from "firebase-admin/firestore";
import {operationContentHash} from "../../operations/durableActions";
import {isOrganizerManager} from "../../shared/organizerHosts";
import {eventStaffGrantId, staffTimestampMillis} from
  "../../shared/eventOperatorAuthority";
import type {OrganizerDocument, EventStaffGrantDocument as Staff} from
  "../../shared/generated/firestoreAdminTypes";
import type {EventDocument} from "../../shared/generated/eventDocument";
import {validateEventDocument} from
  "../../shared/generated/validators/eventDocument";
import {validateOrganizerDocument} from
  "../../shared/generated/validators/organizerDocument";
import {validateEventStaffGrantDocument} from
  "../../shared/generated/validators/eventStaffGrantDocument";
import {ProgressContext, invalidSource, timestampEvidence} from
  "./groupProgressSource";
import {requireDocumentId} from "./guestRecords";

export type GroupDuty = NonNullable<Staff["groupDuties"]>[number];
export type GroupPermission = "readProgress" | "confirmDeparture" |
  "transferGroup" | "recordCheckpoint" | "resolveAccountability";
export const GROUP_DUTY_PERMISSIONS = {
  lead: ["readProgress", "confirmDeparture", "transferGroup",
    "recordCheckpoint", "resolveAccountability"],
  pacer: ["readProgress", "confirmDeparture", "transferGroup",
    "recordCheckpoint", "resolveAccountability"],
  sweep: ["readProgress", "recordCheckpoint", "resolveAccountability"],
} as const satisfies Record<GroupDuty["duty"], readonly GroupPermission[]>;

/** Routine attendance, progress and schedule changes preserve a duty. */
export function groupDutySource(context: ProgressContext, groupId: string,
  event: EventDocument, generation: unknown) {
  requireDocumentId(context.eventId);
  requireDocumentId(context.organizerId);
  requireDocumentId(groupId);
  const route = event.eventFormat.activityDetails?.routePlan;
  const groups = route?.paceGroups ?? [];
  if (new Set(groups.map((g) => g.id)).size !== groups.length) {
    throw invalidSource();
  }
  const group = groupId === "event:whole" ? {kind: "wholeEvent"} :
    route?.groupStrategy === "paceGroups" ?
      groups.find((g) => g.id === groupId) ?? null : null;
  return {configured: group !== null,
    paceGroup: group !== null && groupId !== "event:whole",
    hash: operationContentHash([
      context, groupId, timestampEvidence(generation),
      event.eventFormat.activityKind, route?.groupStrategy ?? null, group])};
}

export function parseStaff(value: unknown, context: ProgressContext,
  uid: string, now: number): Staff | null {
  if (value === undefined) return null;
  if (!validateEventStaffGrantDocument(value) || value.uid !== uid ||
      value.eventId !== context.eventId ||
      value.organizerId !== context.organizerId ||
      staffTimestampMillis(value.createdAt) >
        staffTimestampMillis(value.updatedAt) ||
      staffTimestampMillis(value.updatedAt) > now ||
      new Set((value.groupDuties ?? []).map((d) => d.groupId)).size !==
        (value.groupDuties ?? []).length ||
      (value.groupDuties ?? []).some((d) => d.grantedAtMillis > now ||
        d.expiresAtMillis <= d.grantedAtMillis)) throw invalidSource();
  return value as unknown as Staff;
}

export async function readGroupDutySource(db: Firestore, tx: Transaction,
  context: ProgressContext, groupId: string, clock: () => number) {
  requireDocumentId(context.eventId);
  requireDocumentId(context.organizerId);
  requireDocumentId(groupId);
  const [eventSnap, organizerSnap] = await tx.getAll(
    db.collection("events").doc(context.eventId),
    db.collection("organizers").doc(context.organizerId));
  const event = eventSnap.data();
  const organizer = organizerSnap.data();
  if (!validateEventDocument(event) ||
      event.organizerId !== context.organizerId ||
      !validateOrganizerDocument(organizer)) throw invalidSource();
  const now = clock();
  if (!Number.isSafeInteger(now) || now < 0) throw invalidSource();
  return {event, organizer: organizer as unknown as OrganizerDocument,
    source: groupDutySource(context, groupId, event, eventSnap.createTime),
    now};
}

/** Scoped duties do not inherit the legacy event-wide operator permissions. */
export async function requireGroupPermission(db: Firestore, tx: Transaction,
  context: ProgressContext, groupId: string, actorUid: string,
  permission: GroupPermission, clock: () => number) {
  const state = await readGroupDutySource(db, tx, context, groupId, clock);
  if (!state.source.configured) throw denied();
  if (isOrganizerManager(state.organizer, actorUid)) {
    return {role: "eventLead" as const, validUntil: Number.MAX_SAFE_INTEGER};
  }
  const snap = await tx.get(db.collection("eventStaffGrants")
    .doc(eventStaffGrantId(context.eventId, actorUid)));
  const now = clock();
  if (!Number.isSafeInteger(now) || now < state.now) throw invalidSource();
  const staff = parseStaff(snap.data(), context, actorUid, now);
  const duty = staff?.groupDuties?.find((d) => d.groupId === groupId);
  const permissions: readonly GroupPermission[] = duty ?
    GROUP_DUTY_PERMISSIONS[duty.duty] : [];
  const validUntil = staff && duty ? Math.min(duty.expiresAtMillis,
    staffTimestampMillis(staff.expiresAt)) : 0;
  if (!staff || !duty || staff.status !== "active" || now >= validUntil ||
      duty.sourceHash !== state.source.hash ||
      !permissions.includes(permission)) throw denied();
  return {role: "groupLead" as const, validUntil};
}

export function denied(): HttpsError {
  return new HttpsError("permission-denied",
    "This account has no current duty for this group action.");
}
