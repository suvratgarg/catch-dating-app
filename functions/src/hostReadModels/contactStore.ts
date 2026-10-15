import {isDeepStrictEqual} from "node:util";
import type {
  HostDirectorySummaryDocument, HostContactSummaryDocument,
  OrganizerAudienceSummaryDocument, OrganizerContactDocument,
  OrganizerContactTraitDocument, OrganizerContactChannelStateDocument,
  OrganizerContactTagVocabularyDocument,
} from "../shared/generated/firestoreAdminTypes";
import {organizerContactChannelStateId} from
  "../organizers/organizerCampaignModel";
import {projectContactSummary} from "./contactSummary";

type Directory = HostDirectorySummaryDocument;
type View = HostContactSummaryDocument;

export function emptyDirectory(organizerId: string): Directory {
  return {organizerId, contactSummaryVersion: 0, segmentCounts: {},
    manualTagVocabulary: [], sourceCoverage: "partial", projectionVersion: 1,
    summary: {organizerId, contactCount: 0, pastAttendeeCount: 0,
      repeatAttendeeCount: 0, advocateCount: 0, highImpactAdvocateCount: 0,
      linkedAccountCount: 0, importedContactCount: 0, whatsappOptInCount: 0,
      smsOptInCount: 0, truncated: false, readiness: {
        inApp: "currentEventOnly", whatsapp: "providerSetupRequired",
        sms: "providerAndDltSetupRequired"}}};
}

/** Counts change only with the transaction's previous and next view. */
export function adjustDirectory(directory: Directory,
  previous: View | undefined, next: View | null): Directory {
  const result: Directory = JSON.parse(JSON.stringify(directory));
  for (const [view, delta] of [[previous, -1], [next, 1]] as const) {
    if (!view || view.organizerId !== directory.organizerId) continue;
    const summary = result.summary;
    summary.contactCount += delta;
    summary.linkedAccountCount += view.linkedAccount ? delta : 0;
    summary.importedContactCount += view.importedContact ? delta : 0;
    summary.whatsappOptInCount += view.row.whatsappStatus === "optedIn" ?
      delta : 0;
    summary.smsOptInCount += view.row.smsStatus === "optedIn" ? delta : 0;
    for (const segment of view.row.segmentIds) {
      result.segmentCounts[segment] =
        (result.segmentCounts[segment] ?? 0) + delta;
    }
  }
  const counts = result.segmentCounts;
  result.summary.pastAttendeeCount = counts.past_attendee ?? 0;
  result.summary.repeatAttendeeCount = counts.repeat_attendee ?? 0;
  result.summary.advocateCount = counts.advocate ?? 0;
  result.summary.highImpactAdvocateCount = counts.high_impact_advocate ?? 0;
  return result;
}

/** Current reads prevent delayed events from resurrecting removed PII. */
export async function reconcileContactSummary(
  db: FirebaseFirestore.Firestore, contactId: string
): Promise<void> {
  await db.runTransaction(async (tx) => {
    const viewRef = db.collection("hostContactSummaries").doc(contactId);
    const [contactSnap, traitsSnap, oldSnap] = await tx.getAll(
      db.collection("organizerContacts").doc(contactId),
      db.collection("organizerContactTraits").doc(contactId), viewRef);
    const contact = contactSnap.data() as OrganizerContactDocument | undefined;
    const traits = traitsSnap.data() as
      OrganizerContactTraitDocument | undefined;
    const old = oldSnap.data() as View | undefined;
    const organizerIds = [...new Set([contact?.organizerId, old?.organizerId]
      .filter((id): id is string => Boolean(id)))];
    if (!organizerIds.length) return;
    const sources = await Promise.all(organizerIds.map(async (organizerId) => {
      const [directory, vocabulary, authority, coverage] = await tx.getAll(
        db.collection("hostDirectorySummaries").doc(organizerId),
        db.collection("organizerContactTagVocabularies").doc(organizerId),
        db.collection("organizers").doc(organizerId),
        db.collection("organizerAudienceSummaries").doc(organizerId));
      return {organizerId, directory: directory.data() as Directory | undefined,
        vocabulary: vocabulary.data() as
          OrganizerContactTagVocabularyDocument | undefined,
        exists: authority.exists, coverage: coverage.data() as
          OrganizerAudienceSummaryDocument | undefined};
    }));
    const current = sources.find((item) =>
      item.organizerId === contact?.organizerId);
    const channel = contact ? (await tx.get(db
      .collection("organizerContactChannelStates")
      .doc(organizerContactChannelStateId(contact.organizerId, contactId))))
      .data() as OrganizerContactChannelStateDocument | undefined : undefined;
    const tags = current?.vocabulary?.organizerId === contact?.organizerId ?
      (current?.vocabulary?.tags ?? []).map(({tagId, label}) =>
        ({tagId, label})) : [];
    const next = current?.exists ? projectContactSummary({contactId,
      contact, traits, channel, tags: new Map(tags.map((tag) =>
        [tag.tagId, tag]))}) : null;
    if (isDeepStrictEqual(old ?? null, next)) return;
    for (const source of sources) {
      const directory = adjustDirectory(source.directory ??
        emptyDirectory(source.organizerId), old, next);
      if (source.vocabulary?.organizerId === source.organizerId) {
        directory.manualTagVocabulary = source.vocabulary.tags
          .map(({tagId, label}) => ({tagId, label}));
      }
      directory.sourceCoverage = source.coverage?.sourceCoverage === "exact" ?
        "exact" : "partial";
      directory.projectionVersion = source.coverage?.projectionVersion ?? 1;
      directory.summary.truncated = directory.sourceCoverage !== "exact";
      if (!isDeepStrictEqual(source.directory ?? null, directory)) {
        tx.set(db.collection("hostDirectorySummaries").doc(source.organizerId),
          directory);
      }
    }
    if (next) tx.set(viewRef, next);
    else if (old) tx.delete(viewRef);
  });
}
