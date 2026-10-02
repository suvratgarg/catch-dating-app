import {Timestamp} from "firebase-admin/firestore";
import type {OrganizerFormResponseDocument as Response,
  OrganizerFormVersionDocument as Version} from
  "../shared/generated/firestoreAdminTypes";
import {validateOrganizerFormResponseDocument} from
  "../shared/generated/validators/organizerFormResponseDocument";
import {validateOrganizerFormVersionDocument} from
  "../shared/generated/validators/organizerFormVersionDocument";

/** Internal source proof, not a callable DTO or an editable activity record. */
export interface ParticipantFormActivitySource {
  responseId: string;
  organizerId: string;
  formId: string;
  versionId: string;
  formTitle: string;
  purpose: Version["definition"]["purpose"];
  /** Configured form target only; not proof of event admission. */
  eventId: string | null;
  submittedAtMillis: number;
}

/**
 * Own submission metadata is independent of profile claims and Host grants.
 * This internal reader requires the future callable's Auth-derived uid.
 * A caller may share its existing transaction.
 */
export async function readParticipantFormActivitySource(params: {
  db: FirebaseFirestore.Firestore;
  tx?: FirebaseFirestore.Transaction;
  uid: string;
  responseId: string;
  nowMillis?: number;
}): Promise<ParticipantFormActivitySource | null> {
  const {db, uid, responseId} = params;
  const nowMillis = params.nowMillis ?? Date.now();
  if (!documentId(uid) || !documentId(responseId) ||
      !Number.isFinite(nowMillis) || nowMillis < 0) return null;
  const read = async (tx: FirebaseFirestore.Transaction) => {
    const [responseSnap, deleted, user] = await Promise.all([
      tx.get(db.collection("organizerFormResponses").doc(responseId)),
      tx.get(db.collection("deletedUsers").doc(uid)),
      tx.get(db.collection("users").doc(uid)),
    ]);
    if (deleted.exists || user.data()?.deleted === true) return null;
    const response = responseSnap.data() as Response | undefined;
    if (!validateOrganizerFormResponseDocument(response) || !response ||
        response.respondentUid !== uid || response.status !== "submitted" ||
        response.withdrawnAt !== null ||
        response.identityKind === "anonymous") {
      return null;
    }
    const version = (await tx.get(db.collection("organizerFormVersions")
      .doc(response.versionId))).data() as Version | undefined;
    if (!validateOrganizerFormVersionDocument(version) || !version ||
        version.organizerId !== response.organizerId ||
        version.formId !== response.formId ||
        version.definition.consent.consentVersion !== response.consentVersion ||
        !accountIdentityMatches(version.definition.identityPolicy,
          response.identityKind)) return null;
    const submittedAtMillis = timestampMillis(response.submittedAt);
    const publishedAtMillis = timestampMillis(version.publishedAt);
    if (submittedAtMillis === null || publishedAtMillis === null ||
        submittedAtMillis < publishedAtMillis ||
        submittedAtMillis > nowMillis || publishedAtMillis > nowMillis) {
      return null;
    }
    // No answers, endpoint snapshots, tokens, review notes or profile pointers.
    // The immutable version describes this submission, not today's live form.
    return {responseId, organizerId: response.organizerId,
      formId: response.formId, versionId: response.versionId,
      formTitle: version.definition.title, purpose: version.definition.purpose,
      eventId: version.definition.defaultTargetKind === "event" ?
        version.definition.defaultTargetId : null,
      submittedAtMillis};
  };
  return params.tx ? read(params.tx) : db.runTransaction(read);
}

function accountIdentityMatches(policy: Version["definition"]["identityPolicy"],
  kind: Response["identityKind"]): boolean {
  if (policy === "anonymous" || kind === "anonymous") return false;
  if (policy === "phoneVerified") return kind === "phoneVerified";
  if (policy === "emailVerified" || policy === "emailOrPhoneVerified") {
    // The actual writer chooses phone first for a dual-verified account.
    return kind === "phoneVerified" || kind === "emailVerified";
  }
  return policy === "catchAccount";
}

function documentId(value: string): boolean {
  return typeof value === "string" && value.length > 0 && value.length <= 180 &&
    value !== "." && value !== ".." && !value.includes("/") &&
    [...value].every((character) => character.charCodeAt(0) >= 32);
}

function timestampMillis(value: unknown): number | null {
  if (!(value instanceof Timestamp)) return null;
  const millis = value.toMillis();
  return Number.isFinite(millis) && millis >= 0 ? millis : null;
}
