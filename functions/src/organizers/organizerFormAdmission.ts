import {createHash} from "crypto";
import {HttpsError} from "firebase-functions/v2/https";
import type {
  EventAttendeeDocument, EventDocument, OrganizerContactDocument,
  OrganizerContactEventEdgeDocument, OrganizerContactOriginDocument,
  OrganizerFormConversionReceiptDocument, OrganizerFormDocument,
  OrganizerFormResponseDocument, OrganizerFormVersionDocument,
  OrganizerDocument,
} from "../shared/generated/firestoreAdminTypes";
import {isOrganizerManager} from "../shared/organizerHosts";
import {organizerContactOriginId} from
  "../shared/organizerContactOrigins";
import {eventAttendeeId, normalizeRosterPhone} from
  "../events/eventAttendees";
import {formConversionReceiptId} from
  "./organizerFormAdmissionIdentity";

type Blocker =
  "sourceUnavailable" | "responseWithdrawn" | "wrongPurpose" |
  "wrongTarget" | "crmConversionIncomplete" | "originChanged" |
  "contactUnavailable" | "eventUnavailable" | "eventClosed" |
  "rosterConflict" | "receiptConflict" |
  "capacityAuthorityMissing" | "paymentPolicyMissing";

interface OfferReview {
  organizerId?: string;
  eventId?: string;
  contactId?: string;
  status?: string;
  expiresAtMillis?: number;
  manualPayment?: {
    status?: string;
    bankReceiptChecked?: boolean;
    reviewNote?: string | null;
    evidenceRecordedAtMillis?: number | null;
  };
}

/** Read-only transaction review; it never grants admission or payment truth. */
export interface FormAdmissionReview {
  organizerId: string;
  eventId: string;
  responseId: string;
  contactId: string | null;
  attendeeId: string | null;
  sourceReady: boolean;
  historicallyAdmitted: boolean;
  /** Always false until the shared capacity/payment contract is integrated. */
  canCommit: false;
  blockers: Blocker[];
  offer: {
    current: boolean;
    manualPaymentAttested: boolean;
  };
}

/**
 * Reads every existing source in one Firestore transaction. This is a
 * transaction-bound planner, not a callable or an attendee write: current
 * imports do not reserve authoritative capacity, and the offer model lacks
 * event payment amount/currency/revision. Neither may be inferred here.
 */
export async function reviewOrganizerFormAdmission(params: {
  db: FirebaseFirestore.Firestore;
  actorUid: string;
  organizerId: string;
  responseId: string;
  eventId: string;
  nowMillis: () => number;
}): Promise<FormAdmissionReview> {
  const {db, actorUid, organizerId, responseId, eventId} = params;
  for (const id of [actorUid, organizerId, responseId, eventId]) {
    if (!validId(id)) {
      throw new HttpsError("invalid-argument", "Invalid admission identity.");
    }
  }
  const ref = (collection: string, id: string) => db.collection(collection)
    .doc(id);
  return db.runTransaction(async (tx) => {
    const [organizerSnap, responseSnap, eventSnap,
      crmReceiptSnap, admissionReceiptSnap] = await Promise.all([
      tx.get(ref("organizers", organizerId)),
      tx.get(ref("organizerFormResponses", responseId)),
      tx.get(ref("events", eventId)),
      tx.get(ref("organizerFormConversionReceipts",
        formConversionReceiptId(responseId, "crmContact"))),
      tx.get(ref("organizerFormConversionReceipts",
        formConversionReceiptId(responseId, "eventAttendeeProposal", eventId))),
    ]);
    const organizer = organizerSnap.data() as OrganizerDocument | undefined;
    if (!organizer || !isOrganizerManager(organizer, actorUid) ||
        organizer.archived || organizer.status !== "active") {
      throw new HttpsError("permission-denied",
        "Current organizer manager authority is required.");
    }
    const nowMillis = params.nowMillis();
    if (!Number.isSafeInteger(nowMillis) || nowMillis < 0) {
      throw new HttpsError("internal", "Invalid server clock.");
    }
    const blockers = new Set<Blocker>();
    const response = responseSnap.data() as
      OrganizerFormResponseDocument | undefined;
    const event = eventSnap.data() as EventDocument | undefined;
    const crm = crmReceiptSnap.data() as
      OrganizerFormConversionReceiptDocument | undefined;
    const admission = admissionReceiptSnap.data() as
      OrganizerFormConversionReceiptDocument | undefined;
    if (!response || response.organizerId !== organizerId) {
      blockers.add("sourceUnavailable");
    } else if (response.status !== "submitted" ||
        response.withdrawnAt !== null) {
      blockers.add("responseWithdrawn");
    }
    if (!event || (event.organizerId ?? event.clubId) !== organizerId) {
      blockers.add("eventUnavailable");
    } else if (event.status !== "active" ||
        !event.startTime || event.startTime.toMillis() <= nowMillis) {
      blockers.add("eventClosed");
    }
    let form: OrganizerFormDocument | undefined;
    let version: OrganizerFormVersionDocument | undefined;
    if (response?.organizerId === organizerId) {
      const [formSnap, versionSnap] = await Promise.all([
        tx.get(ref("organizerForms", response.formId)),
        tx.get(ref("organizerFormVersions", response.versionId)),
      ]);
      form = formSnap.data() as OrganizerFormDocument | undefined;
      version = versionSnap.data() as OrganizerFormVersionDocument | undefined;
      if (!form || !version || form.organizerId !== organizerId ||
          version.organizerId !== organizerId ||
          version.formId !== response.formId) {
        blockers.add("sourceUnavailable");
      } else {
        if (!["registration", "intake"].includes(
          version.definition.purpose)) blockers.add("wrongPurpose");
        const target = version.definition;
        if (target.defaultTargetKind === "campaign" ||
            target.defaultTargetKind === "event" &&
              target.defaultTargetId !== eventId ||
            target.defaultTargetKind === "organizer" &&
              target.defaultTargetId !== null) {
          blockers.add("wrongTarget");
        }
      }
    }
    if (!crm || !response || crm.status !== "completed" ||
        crm.kind !== "crmContact" || crm.resultId === null ||
        crm.organizerId !== organizerId ||
        crm.responseId !== responseId ||
        crm.formId !== response.formId) {
      blockers.add("crmConversionIncomplete");
    }
    let contactId: string | null = null;
    let attendeeId: string | null = null;
    let historicallyAdmitted = false;
    let offer: OfferReview | undefined;
    if (response && crm?.status === "completed" && crm.resultId &&
        crm.organizerId === organizerId) {
      const originId = organizerContactOriginId({organizerId,
        sourceKind: "hostForm", sourceEntityKind: "hostFormResponse",
        sourceEntityId: responseId});
      const originSnap = await tx.get(ref("organizerContactOrigins",
        originId));
      const origin = originSnap.data() as
        OrganizerContactOriginDocument | undefined;
      if (!origin || origin.organizerId !== organizerId ||
          origin.sourceKind !== "hostForm" ||
          origin.sourceEntityKind !== "hostFormResponse" ||
          origin.sourceEntityId !== responseId ||
          origin.formId !== response.formId ||
          origin.responseId !== responseId ||
          origin.originContactId !== crm.resultId ||
          !validId(origin.currentContactId)) {
        blockers.add("originChanged");
      } else {
        contactId = origin.currentContactId;
        const contactSnap = await tx.get(ref("organizerContacts", contactId));
        const contact = contactSnap.data() as
          OrganizerContactDocument | undefined;
        if (!contact || contact.organizerId !== organizerId ||
            contact.deletedAt !== null || contact.hiddenAt != null ||
            contact.mergedIntoContactId !== null ||
            contact.identityState === "ambiguous" ||
            contact.ambiguousCandidateContactIds.length > 0) {
          blockers.add("contactUnavailable");
        }
        const stableKey = responseStableKey(responseId, crm);
        attendeeId = eventAttendeeId(eventId, stableKey);
        const offerId = responseOfferId(organizerId, eventId, contactId);
        const [attendeeSnap, edgeSnap, offerSnap] = await Promise.all([
          tx.get(ref("eventAttendees", attendeeId)),
          tx.get(ref("organizerContactEventEdges", attendeeId)),
          tx.get(ref("organizerEventOffers", offerId)),
        ]);
        const attendee = attendeeSnap.data() as
          EventAttendeeDocument | undefined;
        const edge = edgeSnap.data() as
          OrganizerContactEventEdgeDocument | undefined;
        offer = offerSnap.data() as OfferReview | undefined;
        if (attendee && (attendee.eventId !== eventId ||
            attendee.organizerId !== organizerId ||
            attendee.externalReference !== responseId ||
            attendee.sourceRowId !== responseId.slice(0, 120) ||
            attendee.status === "cancelled" ||
            attendee.source !== "hostManual" ||
            stableKey.startsWith("phone:") &&
              attendee.phoneE164 !== stableKey.slice(6) ||
            stableKey.startsWith("email:") &&
              attendee.email !== stableKey.slice(6))) {
          blockers.add("rosterConflict");
        }
        if (edge && (edge.organizerId !== organizerId ||
            edge.eventId !== eventId || edge.contactId !== contactId)) {
          blockers.add("rosterConflict");
        }
        if (admission?.status === "completed" &&
            admission.organizerId === organizerId &&
            admission.formId === response.formId &&
            admission.responseId === responseId &&
            admission.kind === "eventAttendeeProposal" &&
            admission.resultId === attendeeId && attendee &&
            Array.isArray(admission.fields) &&
            admission.fields.some((field) =>
              field.destinationField === "eventId" &&
                field.value === eventId) &&
            !blockers.has("rosterConflict")) {
          historicallyAdmitted = true;
        } else if (admission) {
          blockers.add("receiptConflict");
        }
      }
    }
    const offerCurrent = offer?.organizerId === organizerId &&
      offer.eventId === eventId && offer.contactId === contactId &&
      offer.status === "offered" &&
      Number.isSafeInteger(offer.expiresAtMillis) &&
      (offer.expiresAtMillis as number) > nowMillis;
    const manualPaymentAttested = offerCurrent &&
      offer?.manualPayment?.status === "hostAttestedReceived" &&
      offer.manualPayment.bankReceiptChecked === true &&
      !!offer.manualPayment.reviewNote?.trim() &&
      Number.isSafeInteger(offer.manualPayment.evidenceRecordedAtMillis);
    // This is not an inferred free event or a reservation. The final write
    // needs a shared authoritative capacity and event payment-policy source.
    blockers.add("capacityAuthorityMissing");
    blockers.add("paymentPolicyMissing");
    return {organizerId, eventId, responseId, contactId, attendeeId,
      sourceReady: [...blockers].every((item) => [
        "capacityAuthorityMissing", "paymentPolicyMissing",
      ].includes(item)),
      historicallyAdmitted, canCommit: false as const,
      blockers: [...blockers],
      offer: {current: offerCurrent, manualPaymentAttested}};
  });
}

function responseStableKey(responseId: string,
  crm: OrganizerFormConversionReceiptDocument): string {
  const field = (name: string) => crm.fields.find((entry) =>
    entry.destinationField === name)?.value;
  const rawPhone = field("phoneNumber");
  const phone = normalizeRosterPhone(
    typeof rawPhone === "string" ? rawPhone : null);
  if (phone.issue) {
    throw new HttpsError("failed-precondition", phone.issue);
  }
  const rawEmail = field("email");
  const email = typeof rawEmail === "string" ?
    rawEmail.trim().toLowerCase() : null;
  return phone.value ? `phone:${phone.value}` : email ?
    `email:${email}` : `external:${responseId.toLowerCase()}`;
}

function responseOfferId(organizerId: string, eventId: string,
  contactId: string): string {
  return "applicationoffer_" + createHash("sha256")
    .update([organizerId, eventId, contactId].join("\u001f"))
    .digest("hex").slice(0, 40);
}

function validId(value: string): boolean {
  return typeof value === "string" && value.length > 0 &&
    value.length <= 180 && value !== "." && value !== ".." &&
    !value.includes("/");
}
