import {createHash} from "crypto";
import {
  OrganizerApplicationDocument,
  OrganizerApplicationResponseDocument,
  OrganizerFormResponseDocument,
  OrganizerFormVersionDocument,
  ParticipantOrganizerDataGrantDocument,
} from "../shared/generated/firestoreAdminTypes";
import {
  hostVisibleApplicationAnswers,
  participantOrganizerGrantId,
} from "./participantOrganizerApplications";

export function genericFormApplicationId(responseId: string): string {
  return "formapplication_" + createHash("sha256")
    .update(responseId).digest("hex").slice(0, 32);
}

export interface OrganizerApplicationAccess {
  answers: OrganizerApplicationResponseDocument["answers"];
  accessState: "organizerImported" | "activeParticipantGrant" |
    "submittedFormResponse" | "revokedParticipantGrant";
  sourceResponseId: string | null;
  identity?: {phoneE164: string | null; email: string | null};
}

/**
 * Generic forms retain their own submission authority; no grant is invented.
 */
export async function organizerApplicationAccess(params: {
  db: FirebaseFirestore.Firestore;
  applicationId: string;
  application: OrganizerApplicationDocument;
  transaction?: FirebaseFirestore.Transaction;
}): Promise<OrganizerApplicationAccess> {
  const {db, applicationId, application, transaction} = params;
  const read = (collection: string, id: string) => transaction ?
    transaction.get(db.collection(collection).doc(id)) :
    db.collection(collection).doc(id).get();
  const denied: OrganizerApplicationAccess = {
    answers: [], accessState: "revokedParticipantGrant", sourceResponseId: null,
  };
  const response = (await read("organizerApplicationResponses",
    application.latestResponseId)).data() as
    OrganizerApplicationResponseDocument | undefined;
  if (!response || response.applicationId !== applicationId ||
      response.organizerId !== application.organizerId ||
      response.formId !== application.formId ||
      response.formVersionId !== application.formVersionId ||
      response.linkedUid !== application.linkedUid ||
      response.source.kind !== application.source.kind) return denied;
  if (application.source.kind === "native" &&
      applicationId === genericFormApplicationId(
        application.latestResponseId)) {
    const [submittedSnap, versionSnap] = await Promise.all([
      read("organizerFormResponses", application.latestResponseId),
      read("organizerFormVersions", application.formVersionId),
    ]);
    const submitted = submittedSnap.data() as
      OrganizerFormResponseDocument | undefined;
    const version = versionSnap.data() as
      OrganizerFormVersionDocument | undefined;
    if (!submitted || !version || submitted.status !== "submitted" ||
        submitted.organizerId !== application.organizerId ||
        submitted.formId !== application.formId ||
        submitted.versionId !== application.formVersionId ||
        submitted.respondentUid !== application.linkedUid ||
        version.organizerId !== application.organizerId ||
        version.formId !== application.formId ||
        response.source.externalResponseId !== application.latestResponseId) {
      return denied;
    }
    return {
      answers: response.answers,
      accessState: "submittedFormResponse",
      sourceResponseId: application.latestResponseId,
      identity: submitted.identity,
    };
  }
  const grant = response.source.kind === "native" && response.grantId ?
    (await read("participantOrganizerDataGrants",
      participantOrganizerGrantId(applicationId))).data() as
      ParticipantOrganizerDataGrantDocument | undefined : undefined;
  return {...hostVisibleApplicationAnswers({
    response, responseId: application.latestResponseId, grant,
  }), sourceResponseId: null};
}
