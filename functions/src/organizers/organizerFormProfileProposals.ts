import {HttpsError} from "firebase-functions/v2/https";
import type {
  OrganizerFormResponseDraftDocument as Draft,
  OrganizerFormVersionDocument as Version,
  OrganizerFormResponseDocument as Response,
  ParticipantFormProfileProposalDocument as Proposal,
} from "../shared/generated/firestoreAdminTypes";
import {requireDoc} from "../shared/validation";
import {formAnswerDestination, validateFormCapabilities} from
  "./organizerFormCapabilities";

/**
 * Submission only queues exact private answer pointers for later review.
 * It never changes users, publicProfiles, portable intake or room membership.
 * Values stay in the immutable response and private upload store; claim reads
 * must recheck response ownership/status before dereferencing these pointers.
 */
export async function prepareFormProfileProposal(params: {
  tx: FirebaseFirestore.Transaction; db: FirebaseFirestore.Firestore;
  draft: Draft; definition: Version["definition"];
  answers: Draft["answers"]; responseId: string;
  now: FirebaseFirestore.Timestamp;
}): Promise<() => void> {
  const {tx, db, draft, definition, answers, responseId, now} = params;
  const fields: Proposal["fields"] = [];
  for (const section of definition.sections) {
    for (const question of section.questions) {
      const destination = formAnswerDestination(question);
      if (destination === "organizerOnly") continue;
      // Only visible, submitted, nonempty answers prepare a profile. A hidden
      // field's stale draft value must never enter the claim experience.
      const value = answers[question.questionId];
      if (value === undefined || value === null || value === "" ||
          (Array.isArray(value) && value.length === 0)) continue;
      fields.push({questionId: question.questionId, destination,
        canonicalFieldId: destination === "catchProfile" ?
          question.canonicalFieldId : null});
    }
  }
  if (fields.length === 0) return () => undefined;
  const uid = draft.respondentUid;
  if (!uid || draft.identityKind !== "phoneVerified" ||
      !draft.consentAccepted ||
      draft.consentVersion !== definition.consent.consentVersion) {
    throw new HttpsError("failed-precondition",
      "Review the form disclosure with your verified phone first.");
  }
  // Fail closed for an invalid version rather than promote an ambiguous field.
  validateFormCapabilities(definition, (_code, _path, message) => {
    throw new HttpsError("failed-precondition", message);
  });
  const deleted = await tx.get(db.collection("deletedUsers").doc(uid));
  if (deleted.exists) return () => undefined;
  const proposal: Proposal = {uid, organizerId: draft.organizerId,
    formId: draft.formId, versionId: draft.versionId, responseId, fields,
    createdAt: now};
  return () => tx.create(db.collection("participantFormProfileProposals")
    .doc(responseId), proposal);
}

/** One owner-only projection for claim and organizer-card review callers. */
export async function readParticipantFormProfileProposal(params: {
  db: FirebaseFirestore.Firestore; uid: string; responseId: string;
}) {
  const {db, uid, responseId} = params;
  // Take one consistent snapshot so withdrawal/deletion cannot combine with
  // an earlier source read to yield a new authorized projection.
  return db.runTransaction(async (tx) => {
    const [proposalSnap, responseSnap, deleted] = await Promise.all([
      tx.get(db.collection("participantFormProfileProposals").doc(responseId)),
      tx.get(db.collection("organizerFormResponses").doc(responseId)),
      tx.get(db.collection("deletedUsers").doc(uid)),
    ]);
    const unavailable = () => new HttpsError("not-found",
      "This private form profile is unavailable.");
    if (!proposalSnap.exists || !responseSnap.exists || deleted.exists) {
      throw unavailable();
    }
    const proposal = requireDoc<Proposal>(proposalSnap,
      "ParticipantFormProfileProposalDocument");
    const response = requireDoc<Response>(responseSnap,
      "OrganizerFormResponseDocument");
    if (proposal.uid !== uid || response.respondentUid !== uid ||
        proposal.responseId !== responseId || response.status !== "submitted" ||
        response.withdrawnAt !== null ||
        response.identityKind !== "phoneVerified" ||
        response.organizerId !== proposal.organizerId ||
        response.formId !== proposal.formId ||
        response.versionId !== proposal.versionId) throw unavailable();
    const versionSnap = await tx.get(db.collection("organizerFormVersions")
      .doc(proposal.versionId));
    if (!versionSnap.exists) throw unavailable();
    const version = requireDoc<Version>(versionSnap,
      "OrganizerFormVersionDocument");
    if (version.organizerId !== proposal.organizerId ||
        version.formId !== proposal.formId ||
        version.definition.identityPolicy !== "phoneVerified" ||
        version.definition.consent.consentVersion !== response.consentVersion) {
      throw unavailable();
    }
    const questions = new Map(version.definition.sections.flatMap((section) =>
      section.questions.map((question) => [question.questionId, question])));
    const fields = proposal.fields.map((field) => {
      const question = questions.get(field.questionId);
      const value = response.answers[field.questionId];
      if (!question || formAnswerDestination(question) !== field.destination ||
          (field.destination === "catchProfile" &&
            field.canonicalFieldId !== question.canonicalFieldId) ||
          (field.destination === "organizerCard" &&
            field.canonicalFieldId !== null) || value === undefined) {
        throw unavailable();
      }
      return {...field, label: question.label, kind: question.kind, value,
        options: question.options};
    });
    // Deliberately exclude the complete response, identity contact snapshot,
    // draft token, review notes and all organizer-only answers.
    return {responseId, organizerId: proposal.organizerId,
      formId: proposal.formId, formTitle: version.definition.title,
      submittedAtMillis: response.submittedAt.toMillis(), fields};
  });
}
