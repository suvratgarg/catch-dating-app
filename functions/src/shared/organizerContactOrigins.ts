import {createHash} from "crypto";
import {
  EventAttendeeDocument,
  OrganizerContactOriginDocument,
} from "./generated/firestoreAdminTypes";

/** Deterministic source identity keeps projection retries idempotent. */
export function organizerContactOriginId(params: {
  organizerId: string;
  sourceKind: OrganizerContactOriginDocument["sourceKind"];
  sourceEntityKind: OrganizerContactOriginDocument["sourceEntityKind"];
  sourceEntityId: string;
}): string {
  return `oco_${sha256([
    params.organizerId,
    params.sourceKind,
    params.sourceEntityKind,
    params.sourceEntityId,
  ].join("|")).slice(0, 48)}`;
}

/** Builds immutable provenance for a manager-created Customers record. */
export function manualOrganizerContactOrigin(params: {
  organizerId: string;
  contactId: string;
  actorUid: string;
  now: FirebaseFirestore.Timestamp;
}): OrganizerContactOriginDocument {
  return {
    organizerId: params.organizerId,
    currentContactId: params.contactId,
    originContactId: params.contactId,
    sourceKind: "hostManual",
    sourceEntityKind: "manualEntry",
    sourceEntityId: params.contactId,
    eventId: null,
    formId: null,
    responseId: null,
    actorClass: "organizerManager",
    actorUid: params.actorUid,
    observedAt: params.now,
    originVersion: 1,
    createdAt: params.now,
  };
}

/** Builds immutable provenance from the canonical operational attendee row. */
export function attendeeOrganizerContactOrigin(params: {
  attendeeId: string;
  attendee: EventAttendeeDocument;
  contactId: string;
  originContactId?: string;
  now: FirebaseFirestore.Timestamp;
}): OrganizerContactOriginDocument {
  const actorClass: OrganizerContactOriginDocument["actorClass"] =
    params.attendee.source === "webOtp" ? "participant" :
      params.attendee.source === "providerSync" ? "provider" :
        params.attendee.source === "hostImport" ||
        params.attendee.source === "hostManual" ? "organizerManager" :
          "system";
  return {
    organizerId: params.attendee.organizerId,
    currentContactId: params.contactId,
    originContactId: params.originContactId ?? params.contactId,
    sourceKind: params.attendee.source,
    sourceEntityKind: "eventAttendee",
    sourceEntityId: params.attendeeId,
    eventId: params.attendee.eventId,
    formId: null,
    responseId: null,
    actorClass,
    actorUid: params.attendee.source === "webOtp" ?
      params.attendee.linkedUid : null,
    observedAt: params.attendee.createdAt,
    originVersion: 1,
    createdAt: params.now,
  };
}

function sha256(value: string): string {
  return createHash("sha256").update(value).digest("hex");
}
