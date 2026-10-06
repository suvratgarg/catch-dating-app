import {createHash} from "crypto";
import {eventAttendeeId} from "../events/eventAttendees";
import {organizerContactOriginId} from "../shared/organizerContactOrigins";
import type {EventAttendeeDocument, OrganizerContactDocument,
  OrganizerContactOriginDocument, OrganizerFormConversionReceiptDocument} from
  "../shared/generated/firestoreAdminTypes";

type Kind = OrganizerFormConversionReceiptDocument["kind"];

/** Event admissions are independently replayable for each selected event. */
export function formConversionReceiptId(responseId: string, kind: Kind,
  eventId: string | null = null): string {
  const parts = [responseId, kind];
  if (kind === "eventAttendeeProposal" && eventId) parts.push(eventId);
  return "formconversion_" + createHash("sha256")
    .update(parts.join("\u001f")).digest("hex").slice(0, 32);
}

/** Follows reviewed admission provenance, never endpoint similarity. */
export async function formAdmissionContactId(params: {
  db: FirebaseFirestore.Firestore;
  attendeeId: string;
  attendee: EventAttendeeDocument;
}): Promise<string | null> {
  const {db, attendee, attendeeId} = params;
  const responseId = attendee.externalReference;
  if (attendee.source !== "hostManual" || !responseId ||
      attendee.sourceRowId !== responseId.slice(0, 120)) return null;
  const receipt = (await db.collection("organizerFormConversionReceipts")
    .doc(formConversionReceiptId(responseId, "eventAttendeeProposal",
      attendee.eventId)).get()).data() as
    OrganizerFormConversionReceiptDocument | undefined;
  if (!receipt || receipt.organizerId !== attendee.organizerId ||
      receipt.responseId !== responseId ||
      receipt.kind !== "eventAttendeeProposal" || receipt.status === "failed") {
    return null;
  }
  const eventField = receipt.fields.find((entry) =>
    entry.destinationField === "eventId")?.value;
  if (eventField !== attendee.eventId) return null;
  const currentAttendeeId = eventAttendeeId(attendee.eventId,
    `external:${responseId.toLowerCase()}`);
  const pendingCurrentReceipt = receipt.status === "pending" &&
    receipt.resultId === null;
  const expectedAttendeeId = receipt.status === "completed" ?
    receipt.resultId : pendingCurrentReceipt ? currentAttendeeId : null;
  // A completed immutable receipt may point at the legacy phone/email key.
  // Pending writes must use the current attendee-level reference identity.
  if (!expectedAttendeeId || expectedAttendeeId !== attendeeId) return null;
  const origin = (await db.collection("organizerContactOrigins")
    .doc(organizerContactOriginId({organizerId: attendee.organizerId,
      sourceKind: "hostForm", sourceEntityKind: "hostFormResponse",
      sourceEntityId: responseId})).get()).data() as
    OrganizerContactOriginDocument | undefined;
  if (!origin || origin.organizerId !== attendee.organizerId ||
      origin.sourceEntityId !== responseId ||
      origin.formId !== receipt.formId) {
    return null;
  }
  const contact = (await db.collection("organizerContacts")
    .doc(origin.currentContactId).get()).data() as
    OrganizerContactDocument | undefined;
  if (!contact || contact.organizerId !== attendee.organizerId ||
      contact.deletedAt || contact.hiddenAt || contact.mergedIntoContactId) {
    return null;
  }
  return origin.currentContactId;
}
