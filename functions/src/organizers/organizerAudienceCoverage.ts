import {
  OrganizerAudienceSummaryDocument,
} from "../shared/generated/firestoreAdminTypes";

export type OrganizerAudienceSourceCoverage =
  OrganizerAudienceSummaryDocument["sourceCoverage"];

/**
 * Missing projection state is complete only when there is no canonical roster
 * history to migrate. This keeps new and manual-only organizers out of a
 * permanent migration warning without hiding genuinely unprojected history.
 */
export function effectiveOrganizerAudienceCoverage(
  storedCoverage: OrganizerAudienceSourceCoverage | null | undefined,
  hasCanonicalAttendeeHistory: boolean,
): OrganizerAudienceSourceCoverage {
  if (storedCoverage === "exact") return "exact";
  return hasCanonicalAttendeeHistory ? "partial" : "exact";
}

/** Resolves coverage with the smallest possible canonical-history read. */
export async function resolveOrganizerAudienceCoverage(params: {
  db: FirebaseFirestore.Firestore;
  organizerId: string;
  storedCoverage: OrganizerAudienceSourceCoverage | null | undefined;
}): Promise<OrganizerAudienceSourceCoverage> {
  if (params.storedCoverage === "exact") return "exact";
  const attendeeSnap = await params.db.collection("eventAttendees")
    .where("organizerId", "==", params.organizerId)
    .limit(1)
    .get();
  return effectiveOrganizerAudienceCoverage(
    params.storedCoverage,
    attendeeSnap.size > 0,
  );
}
