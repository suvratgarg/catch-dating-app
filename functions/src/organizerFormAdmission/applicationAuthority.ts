import type {OrganizerApplicationDocument,
  OrganizerContactOriginDocument, OrganizerFormResponseDocument,
  OrganizerFormVersionDocument} from
  "../shared/generated/firestoreAdminTypes";
import {validateOrganizerApplicationDocument} from
  "../shared/generated/validators/organizerApplicationDocument";
import {genericFormApplicationId, organizerApplicationAccess} from
  "../organizers/organizerApplicationAccess";
import type {EventOffer} from "../organizerEventOffers/eventOfferDomain";
import {AdmissionPolicyError} from "./admissionPolicy";

export interface ApplicationAdmissionApproval {
  applicationId: string;
  revision: number;
  contactId: string;
  reviewedAtMillis: number;
}

/** Read current approval in the same transaction that reserves the seat. */
export async function readApplicationAdmissionApproval(params: {
  db: FirebaseFirestore.Firestore;
  tx: FirebaseFirestore.Transaction;
  response: OrganizerFormResponseDocument;
  responseId: string;
  version: OrganizerFormVersionDocument;
  origin: OrganizerContactOriginDocument;
  offer: EventOffer;
  nowMillis: number;
}): Promise<ApplicationAdmissionApproval> {
  const {db, tx, response, responseId, version, origin, offer} = params;
  const applicationId = genericFormApplicationId(responseId);
  const raw = (await tx.get(db.collection("organizerApplications")
    .doc(applicationId))).data();
  const application = raw as OrganizerApplicationDocument | undefined;
  const fail = (): never => {
    throw new AdmissionPolicyError("unavailable",
      "Current approved application authority is unavailable.");
  };
  if (!application || !validateOrganizerApplicationDocument(raw) ||
      (offer.sourceKind ?? "application") !== "application" ||
      offer.applicationId !== applicationId ||
      version.definition.purpose !== "application" ||
      application.organizerId !== response.organizerId ||
      application.formId !== response.formId ||
      application.formVersionId !== response.versionId ||
      application.latestResponseId !== responseId ||
      application.linkedUid !== response.respondentUid ||
      application.source.kind !== "native" ||
      application.reviewStatus !== "approved" ||
      application.targetKind !== version.definition.defaultTargetKind ||
      application.targetId !== version.definition.defaultTargetId ||
      !application.contactId ||
      ![origin.originContactId, origin.currentContactId]
        .includes(application.contactId) ||
      !application.reviewedAt ||
      application.reviewedAt.toMillis() <= 0 ||
      application.reviewedAt.toMillis() > params.nowMillis) return fail();
  const access = await organizerApplicationAccess({db, transaction: tx,
    applicationId, application});
  if (access.accessState !== "submittedFormResponse" ||
      access.sourceResponseId !== responseId) return fail();
  return {applicationId, revision: application.revision,
    contactId: application.contactId,
    reviewedAtMillis: application.reviewedAt.toMillis()};
}
