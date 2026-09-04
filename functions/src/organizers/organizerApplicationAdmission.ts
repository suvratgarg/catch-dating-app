import {createHash} from "crypto";
import {HttpsError} from "firebase-functions/v2/https";
import type {
  OrganizerApplicationDocument,
  OrganizerContactDocument,
  OrganizerContactOriginDocument,
} from "../shared/generated/firestoreAdminTypes";
import {organizerContactOriginId} from "../shared/organizerContactOrigins";
import {OrganizerApplicationAccess} from "./organizerApplicationAccess";

/** Resolve a unique organizer contact without asserting verified identity. */
export async function applicationAdmissionContactId(params: {
  db: FirebaseFirestore.Firestore;
  transaction: FirebaseFirestore.Transaction;
  applicationId: string;
  application: OrganizerApplicationDocument;
  access: OrganizerApplicationAccess;
  phoneE164: string | null;
  email: string | null;
}): Promise<string> {
  const {db, transaction: tx, application, access} = params;
  const originId = organizerContactOriginId({
    organizerId: application.organizerId, sourceKind: "hostForm",
    sourceEntityKind: access.sourceResponseId ?
      "hostFormResponse" : "hostApplicationResponse",
    sourceEntityId: application.latestResponseId,
  });
  const origin = (await tx.get(db.collection("organizerContactOrigins")
    .doc(originId))).data() as OrganizerContactOriginDocument | undefined;
  const candidates = new Set<string>();
  if (origin?.organizerId === application.organizerId) {
    candidates.add(origin.currentContactId);
  } else if (application.contactId) candidates.add(application.contactId);
  const endpoints: Array<["phoneE164" | "email" | "linkedUid", string]> = [];
  if (params.phoneE164) endpoints.push(["phoneE164", params.phoneE164]);
  if (params.email) endpoints.push(["email", params.email.toLowerCase()]);
  if (application.linkedUid) {
    endpoints.push(["linkedUid",
      application.linkedUid]);
  }
  for (const [field, value] of endpoints) {
    const matches = await tx.get(db.collection("organizerContacts")
      .where("organizerId", "==", application.organizerId)
      .where(field, "==", value).limit(10));
    if (matches.size === 10) {
      throw new HttpsError("failed-precondition",
        "Review duplicate contacts before accepting this application.");
    }
    for (const doc of matches.docs) {
      const contact = doc.data() as OrganizerContactDocument;
      if (contact.deletedAt !== null || contact.hiddenAt !== null ||
          contact.mergedIntoContactId !== null) continue;
      if (contact.linkedUid && application.linkedUid &&
          contact.linkedUid !== application.linkedUid) {
        throw new HttpsError("failed-precondition",
          "The matching customer belongs to another account. " +
            "Review duplicates.");
      }
      candidates.add(doc.id);
    }
  }
  if (candidates.size > 1) {
    throw new HttpsError("failed-precondition",
      "The application matches conflicting contacts. Review duplicates first.");
  }
  const existingId = [...candidates][0];
  if (existingId) {
    const existing = (await tx.get(db.collection("organizerContacts")
      .doc(existingId))).data() as OrganizerContactDocument | undefined;
    if (!existing || existing.organizerId !== application.organizerId ||
        (existing.linkedUid && application.linkedUid &&
        existing.linkedUid !== application.linkedUid)) {
      throw new HttpsError("failed-precondition",
        "The linked customer is unavailable or belongs to another account.");
    }
    return existingId;
  }
  if (!params.phoneE164 && !params.email) {
    throw new HttpsError("failed-precondition",
      "A submitted phone number or email is needed to add this person.");
  }
  return "applicationcontact_" + createHash("sha256")
    .update(application.organizerId + "|" + params.applicationId)
    .digest("hex").slice(0, 32);
}
