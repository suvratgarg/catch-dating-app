import {emptyDirectory, adjustDirectory, reconcileContactSummary} from
  "./contactStore";
import {projectContactSummary} from "./contactSummary";
import type {HostContactSummaryDocument, HostDirectorySummaryDocument,
  OrganizerContactDocument, OrganizerContactTraitDocument,
  OrganizerContactChannelStateDocument, OrganizerContactTagVocabularyDocument,
  OrganizerAudienceSummaryDocument} from
  "../shared/generated/firestoreAdminTypes";
import {FieldPath} from "firebase-admin/firestore";

/** Explicit organizer scope. Applying does not itself authorize SDK cutover. */
export async function backfillContactSummaries(db: FirebaseFirestore.Firestore,
  organizerId: string, apply: boolean): Promise<number> {
  let cursor: FirebaseFirestore.QueryDocumentSnapshot | undefined;
  let count = 0;
  do {
    let query = db.collection("organizerContacts")
      .where("organizerId", "==", organizerId)
      .orderBy(FieldPath.documentId()).limit(100);
    if (cursor) query = query.startAfter(cursor);
    const page = await query.get();
    for (const doc of page.docs) {
      count++;
      if (apply) await reconcileContactSummary(db, doc.id);
    }
    cursor = page.size === 100 ? page.docs.at(-1) : undefined;
  } while (cursor);
  // Canonical deletions may predate trigger deployment. Purge orphan rows.
  let viewCursor: FirebaseFirestore.QueryDocumentSnapshot | undefined;
  if (apply) {
    do {
      let query = db.collection("hostContactSummaries")
        .where("organizerId", "==", organizerId)
        .orderBy(FieldPath.documentId()).limit(100);
      if (viewCursor) query = query.startAfter(viewCursor);
      const page = await query.get();
      for (const doc of page.docs) await reconcileContactSummary(db, doc.id);
      viewCursor = page.size === 100 ? page.docs.at(-1) : undefined;
    } while (viewCursor);
  }
  return count;
}

/** One consistent source/view snapshot gates migration, including empty scopes.
 * A changing source retries the transaction. Oversized scopes fail rather than
 * publishing an unchecked marker; the release owner can split/shard that case.
 */
export async function activateContactSummaries(db: FirebaseFirestore.Firestore,
  organizerId: string): Promise<number> {
  return db.runTransaction(async (tx) => {
    const scoped = (collection: string) => db.collection(collection)
      .where("organizerId", "==", organizerId);
    const directoryRef = db.collection("hostDirectorySummaries")
      .doc(organizerId);
    const [contacts, traits, channels, views, vocabulary, coverage, authority,
      oldDirectory] = await Promise.all([
      tx.get(scoped("organizerContacts")),
      tx.get(scoped("organizerContactTraits")),
      tx.get(scoped("organizerContactChannelStates")),
      tx.get(scoped("hostContactSummaries")),
      tx.get(db.collection("organizerContactTagVocabularies").doc(organizerId)),
      tx.get(db.collection("organizerAudienceSummaries").doc(organizerId)),
      tx.get(db.collection("organizers").doc(organizerId)),
      tx.get(directoryRef),
    ]);
    if (!authority.exists) throw new Error("Organizer does not exist.");
    const traitMap = new Map(traits.docs.map((doc) => [doc.id,
      doc.data() as OrganizerContactTraitDocument]));
    const channelMap = new Map(channels.docs.map((doc) => {
      const value = doc.data() as OrganizerContactChannelStateDocument;
      return [value.contactId, value] as const;
    }));
    const vocab = vocabulary.data() as
      OrganizerContactTagVocabularyDocument | undefined;
    const tags = vocab?.organizerId === organizerId ?
      vocab.tags.map(({tagId, label}) => ({tagId, label})) : [];
    const tagMap = new Map(tags.map((tag) => [tag.tagId, tag]));
    const expected = new Map<string, HostContactSummaryDocument>();
    for (const doc of contacts.docs) {
      const contact = doc.data() as OrganizerContactDocument;
      if (contact.deletedAt === null && contact.hiddenAt == null &&
          contact.identityState !== "merged" && !traitMap.has(doc.id)) {
        throw new Error(`Missing traits for contact ${doc.id}.`);
      }
      const view = projectContactSummary({contactId: doc.id, contact,
        traits: traitMap.get(doc.id), channel: channelMap.get(doc.id),
        tags: tagMap});
      if (view) expected.set(doc.id, view);
    }
    if (expected.size !== views.size || views.docs.some((doc) =>
      JSON.stringify(doc.data()) !== JSON.stringify(expected.get(doc.id)))) {
      // Firestore's map field order is not guaranteed; compare canonical keys.
      if (expected.size !== views.size || views.docs.some((doc) =>
        stable(doc.data()) !== stable(expected.get(doc.id)))) {
        throw new Error("Contact summary parity failed; rerun backfill.");
      }
    }
    let directory = emptyDirectory(organizerId);
    for (const view of expected.values()) {
      directory = adjustDirectory(directory, undefined, view);
    }
    const source = coverage.data() as
      OrganizerAudienceSummaryDocument | undefined;
    directory.manualTagVocabulary = tags;
    directory.sourceCoverage = source?.sourceCoverage === "exact" ?
      "exact" : "partial";
    directory.summary.truncated = directory.sourceCoverage !== "exact";
    directory.projectionVersion = source?.projectionVersion ?? 1;
    directory.contactSummaryVersion = 1;
    // Preserve other independently verified read-model markers.
    const previous = oldDirectory.data() as
      HostDirectorySummaryDocument | undefined;
    tx.set(directoryRef, {...previous, ...directory});
    return expected.size;
  });
}

function stable(value: unknown): string {
  if (Array.isArray(value)) return `[${value.map(stable).join(",")}]`;
  if (value && typeof value === "object") {
    return "{" + Object.entries(value).sort(([a], [b]) => a.localeCompare(b))
      .map(([key, item]) => `${JSON.stringify(key)}:${stable(item)}`)
      .join(",") +
      "}";
  }
  return JSON.stringify(value);
}
