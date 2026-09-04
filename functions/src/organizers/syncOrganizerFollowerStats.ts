import {onDocumentWritten} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import type {
  OrganizerFollowDocument,
} from "../shared/generated/firestoreAdminTypes";

interface SyncOrganizerFollowerStatsDeps {
  firestore: () => FirebaseFirestore.Firestore;
}

const defaultDeps: SyncOrganizerFollowerStatsDeps = {
  firestore: () => admin.firestore(),
};

/** Recomputes the canonical follower count for one organizer. */
export async function refreshOrganizerFollowerStats(
  organizerId: string,
  deps: SyncOrganizerFollowerStatsDeps = defaultDeps
): Promise<void> {
  const db = deps.firestore();
  const organizerRef = db.collection("organizers").doc(organizerId);
  const organizerSnap = await organizerRef.get();
  if (!organizerSnap.exists) return;

  const followsSnap = await db
    .collection("organizerFollows")
    .where("organizerId", "==", organizerId)
    .where("status", "==", "active")
    .get();
  const followerCount = followsSnap.docs.length;
  await organizerRef.set({followerCount}, {merge: true});
}

/** Recomputes organizer follower counts affected by a follow-edge write. */
export async function syncOrganizerFollowerStatsHandler(
  before: OrganizerFollowDocument | undefined,
  after: OrganizerFollowDocument | undefined,
  deps: SyncOrganizerFollowerStatsDeps = defaultDeps
): Promise<void> {
  const organizerIds = new Set<string>();
  if (before?.organizerId) organizerIds.add(before.organizerId);
  if (after?.organizerId) organizerIds.add(after.organizerId);
  await Promise.all(
    Array.from(organizerIds).map((organizerId) =>
      refreshOrganizerFollowerStats(organizerId, deps)
    )
  );
}

export const syncOrganizerFollowerStats = onDocumentWritten(
  "organizerFollows/{followId}",
  async (event) => {
    const before = event.data?.before.data() as
      OrganizerFollowDocument | undefined;
    const after = event.data?.after.data() as
      OrganizerFollowDocument | undefined;
    await syncOrganizerFollowerStatsHandler(before, after);
  }
);
