import {HttpsError} from "firebase-functions/v2/https";
import type {
  OrganizerApplicationDocument,
  OrganizerFormResponseDocument,
  OrganizerFormVersionDocument,
} from "../shared/generated/firestoreAdminTypes";
import {validateOrganizerApplicationDocument} from
  "../shared/generated/validators/organizerApplicationDocument";
import {validateOrganizerFormResponseDocument} from
  "../shared/generated/validators/organizerFormResponseDocument";
import {validateOrganizerFormVersionDocument} from
  "../shared/generated/validators/organizerFormVersionDocument";
import {
  genericFormApplicationId,
  organizerApplicationAccess,
} from "../organizers/organizerApplicationAccess";
import type {OrganizerCommunityMembershipDocument} from
  "../shared/generated/organizerCommunityMembershipDocument";

/**
 * Resolve UID-backed submission evidence, without needing a Consumer
 * profile.
 */
export async function readApprovedCommunityApplication(params: {
  db: FirebaseFirestore.Firestore;
  tx: FirebaseFirestore.Transaction;
  organizerId: string;
  applicationId: string;
  expectedApplicationRevision: number;
  uid: string;
  nowMillis: number;
}): Promise<OrganizerCommunityMembershipDocument["source"]> {
  const {db, tx, applicationId, organizerId} = params;
  const raw = (
    await tx.get(db.collection("organizerApplications").doc(applicationId))
  ).data();
  const app = raw as OrganizerApplicationDocument | undefined;
  const fail = (): never => {
    throw new HttpsError(
      "failed-precondition",
      "A current approved community application is required."
    );
  };
  if (
    !validateOrganizerApplicationDocument(raw) ||
    !app ||
    app.organizerId !== organizerId ||
    app.targetKind !== "organizer" ||
    app.targetId !== null ||
    app.source.kind !== "native" ||
    app.source.externalResponseId !== app.latestResponseId ||
    app.source.providerId !== null || app.source.externalFormId !== null ||
    app.source.importReceiptId !== null ||
    app.reviewStatus !== "approved" ||
    app.revision !== params.expectedApplicationRevision ||
    applicationId !== genericFormApplicationId(app.latestResponseId) ||
    !app.reviewedAt ||
    app.reviewedAt.toMillis() <= 0 ||
    app.reviewedAt.toMillis() > params.nowMillis
  ) {
    return fail();
  }
  const access = await organizerApplicationAccess({
    db,
    transaction: tx,
    applicationId,
    application: app,
  });
  if (
    access.accessState !== "submittedFormResponse" ||
    access.sourceResponseId !== app.latestResponseId
  ) {
    return fail();
  }
  const [responseSnap, versionSnap] = await Promise.all([
    tx.get(db.collection("organizerFormResponses").doc(app.latestResponseId)),
    tx.get(db.collection("organizerFormVersions").doc(app.formVersionId)),
  ]);
  const response = responseSnap.data() as
    | OrganizerFormResponseDocument
    | undefined;
  const version = versionSnap.data() as
    | OrganizerFormVersionDocument
    | undefined;
  if (
    !validateOrganizerFormResponseDocument(response) ||
    !validateOrganizerFormVersionDocument(version) ||
    !response ||
    !version ||
    response.status !== "submitted" ||
    response.withdrawnAt !== null ||
    app.reviewedAt.toMillis() < response.submittedAt.toMillis() ||
    !["phoneVerified", "emailVerified", "catchAccount"].includes(
      response.identityKind
    ) ||
    response.respondentUid !== params.uid ||
    app.linkedUid !== params.uid ||
    response.organizerId !== organizerId ||
    response.formId !== app.formId ||
    response.versionId !== app.formVersionId ||
    version.organizerId !== organizerId ||
    version.formId !== app.formId ||
    !supportsUidEvidence(
      version.definition.identityPolicy,
      response.identityKind
    ) ||
    version.definition.purpose !== "application" ||
    version.definition.defaultTargetKind !== "organizer" ||
    version.definition.defaultTargetId !== null
  ) {
    return fail();
  }
  return {
    applicationId,
    responseId: app.latestResponseId,
    formVersionId: app.formVersionId,
    applicationRevision: app.revision,
  };
}

/**
 * Match actual requireResponseIdentity outputs, including dual-verified
 * users.
 */
function supportsUidEvidence(policy: string, kind: string): boolean {
  if (policy === "anonymous") return false;
  if (policy === "phoneVerified") return kind === "phoneVerified";
  if (policy === "emailVerified" || policy === "emailOrPhoneVerified") {
    return kind === "phoneVerified" || kind === "emailVerified";
  }
  return (
    policy === "catchAccount" &&
    ["phoneVerified", "emailVerified", "catchAccount"].includes(kind)
  );
}
