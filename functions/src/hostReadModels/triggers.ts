import * as admin from "firebase-admin";
import {onDocumentWritten} from "firebase-functions/v2/firestore";
import {reconcileContactSummary} from "./contactStore";

const options = {retry: true, memory: "512MiB" as const};
export const onHostContactSummaryChanged = onDocumentWritten({
  ...options, document: "organizerContacts/{contactId}",
}, (event) => reconcileContactSummary(
  admin.firestore(), event.params.contactId));
export const onHostContactTraitsSummaryChanged = onDocumentWritten({
  ...options, document: "organizerContactTraits/{contactId}",
}, (event) => reconcileContactSummary(
  admin.firestore(), event.params.contactId));
export const onHostContactChannelSummaryChanged = onDocumentWritten({
  ...options, document: "organizerContactChannelStates/{stateId}",
}, async (event) => {
  const ids = new Set([event.data?.before.get("contactId"),
    event.data?.after.get("contactId")]);
  for (const id of ids) {
    if (typeof id === "string") {
      await reconcileContactSummary(
        admin.firestore(), id);
    }
  }
});

/** Vocabulary changes fan out in bounded pages, outside list reads. */
export const onHostContactVocabularySummaryChanged = onDocumentWritten({
  ...options, document: "organizerContactTagVocabularies/{organizerId}",
}, async (event) => {
  const db = admin.firestore();
  const organizerId = event.params.organizerId;
  let cursor: FirebaseFirestore.QueryDocumentSnapshot | undefined;
  do {
    let query = db.collection("organizerContacts")
      .where("organizerId", "==", organizerId)
      .orderBy(admin.firestore.FieldPath.documentId()).limit(100);
    if (cursor) query = query.startAfter(cursor);
    const page = await query.get();
    for (const doc of page.docs) await reconcileContactSummary(db, doc.id);
    cursor = page.size === 100 ? page.docs.at(-1) : undefined;
  } while (cursor);
  // Refresh choices even for an organizer with no contacts.
  await db.runTransaction(async (tx) => {
    const ref = db.collection("hostDirectorySummaries").doc(organizerId);
    const [summary, vocabulary] = await tx.getAll(ref,
      db.collection("organizerContactTagVocabularies").doc(organizerId));
    if (summary.exists) {
      tx.update(ref, {manualTagVocabulary:
      vocabulary.get("organizerId") === organizerId ?
        (vocabulary.get("tags") ?? []).map(
          ({tagId, label}: {tagId: string; label: string}) =>
            ({tagId, label})) :
        []});
    }
  });
});
