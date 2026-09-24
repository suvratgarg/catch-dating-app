import {createHash} from "node:crypto";
import type {EventDocument, EventPlanChangeDocument} from
  "../shared/generated/firestoreAdminTypes";

export const EVENT_PLAN_CHANGES = "eventPlanChanges";
export type EventPlanChangeField =
  EventPlanChangeDocument["changedFields"][number];

/** Stable identity for one immutable event plan revision. */
export function eventPlanChangeSourceId(eventId: string, revision: number) {
  const digest = createHash("sha256")
    .update(JSON.stringify([eventId, revision]))
    .digest("hex");
  return `plan-change:${digest}`;
}

/** Returns only attendee-relevant facts that actually changed. */
export function eventPlanChangeFields(
  before: EventDocument,
  after: EventDocument
): EventPlanChangeField[] {
  const changed: EventPlanChangeField[] = [];
  if ((before.name ?? null) !== (after.name ?? null)) changed.push("name");
  if (before.startTime.toMillis() !== after.startTime.toMillis() ||
      before.endTime?.toMillis() !== after.endTime?.toMillis()) {
    changed.push("schedule");
  }
  if (!same(before.meetingLocation, after.meetingLocation)) {
    changed.push("meetingLocation");
  }
  if (!same(before.itinerary ?? [], after.itinerary ?? [])) {
    changed.push("itinerary");
  }
  if (!same(before.eventFormat, after.eventFormat)) changed.push("format");
  return changed;
}

function same(left: unknown, right: unknown) {
  return JSON.stringify(left) === JSON.stringify(right);
}
