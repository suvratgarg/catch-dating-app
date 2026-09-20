import {createHash} from "crypto";
import {eventAttendeeId, normalizeRosterPhone} from "../events/eventAttendees";
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
  const field = (name: string) => receipt.fields.find((entry) =>
    entry.destinationField === name)?.value;
  if (field("eventId") !== attendee.eventId) return null;
  const phoneValue = field("phoneNumber");
  const phone = normalizeRosterPhone(
    typeof phoneValue === "string" ? phoneValue : null).value;
  const email = typeof field("email") === "string" ?
    String(field("email")).trim().toLowerCase() : null;
  const key = phone ? `phone:${phone}` : email ? `email:${email}` :
    `external:${responseId.toLowerCase()}`;
  if (eventAttendeeId(attendee.eventId, key) !== attendeeId) return null;
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
