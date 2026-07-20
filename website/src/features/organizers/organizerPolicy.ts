import type {HostListing} from "./types";

export type OrganizerOwnershipState =
  | "programmatic"
  | "userCreated"
  | "claimed"
  | "transferred"
  | "unknown";

export type OrganizerClaimState =
  | "unclaimed"
  | "claimPending"
  | "claimed"
  | "verified"
  | "suppressed"
  | "unknown";

export type OrganizerVerificationStatus =
  | "unverified"
  | "sourceBacked"
  | "ownerVerified"
  | "unknown";

export interface OrganizerListingPolicy {
  badge: {
    compactLabel: string;
    label: string;
    tone: "claimed" | "unclaimed" | "verified";
  };
  canReadPublicReviews: boolean;
  canRequestClaim: boolean;
  canWritePublicReview: boolean;
  claimRequestReason: string;
  claimState: OrganizerClaimState;
  isCatchCreated: boolean;
  ownershipState: OrganizerOwnershipState;
  publicReviewReason: string;
  verificationStatus: OrganizerVerificationStatus;
}

interface PolicyAwareListing {
  authority?: {
    appVisibility?: string;
    claimState?: string;
    indexStatus?: string;
    ownershipState?: string;
    provenanceOrigin?: string;
    publishStatus?: string;
    sourceConfidence?: string;
    verificationStatus?: string;
  };
  capabilities?: {
    claimRequest?: {
      reason?: string;
      state?: string;
    };
    publicReviews?: {
      readState?: string;
      reason?: string;
      writeState?: string;
    };
  };
}

const ownershipStates = new Set<OrganizerOwnershipState>([
  "programmatic",
  "userCreated",
  "claimed",
  "transferred",
]);
const claimStates = new Set<OrganizerClaimState>([
  "unclaimed",
  "claimPending",
  "claimed",
  "verified",
  "suppressed",
]);
const verificationStatuses = new Set<OrganizerVerificationStatus>([
  "unverified",
  "sourceBacked",
  "ownerVerified",
]);

/**
 * Derives action and presentation policy from the canonical listing projection.
 * The compatibility branch is deliberately explicit so old generated fixtures
 * remain readable while authority/capability fields roll out.
 */
export function organizerPolicyForListing(listing: HostListing): OrganizerListingPolicy {
  const projected = listing as HostListing & PolicyAwareListing;
  const hasAuthorityProjection = projected.authority !== undefined;
  const hasCapabilityProjection = projected.capabilities !== undefined;
  const ownershipState = normalizedOwnershipState(
    projected.authority?.ownershipState,
    listing,
    !hasAuthorityProjection
  );
  const claimState = normalizedClaimState(
    projected.authority?.claimState,
    listing,
    !hasAuthorityProjection
  );
  const verificationStatus = normalizedVerificationStatus(
    projected.authority?.verificationStatus,
    listing,
    !hasAuthorityProjection
  );
  const isCatchCreated = ownershipState === "userCreated" ||
    listing.listingVariant === "appCreatedClub";
  const publicationBlocksActions = ["suppressed", "removed"].includes(
    projected.authority?.publishStatus ?? ""
  );
  const ownershipCanBeClaimed = ownershipState === "programmatic";
  const claimStateCanBeClaimed = claimState === "unclaimed";
  const claimCapability = projected.capabilities?.claimRequest;
  const legacyPublicApiEnabled = listing.publicApi.state === "enabled";
  const claimCapabilityEnabled = claimCapability ?
    capabilityEnabled(claimCapability.state) :
    !hasCapabilityProjection && legacyPublicApiEnabled;
  const canRequestClaim = !publicationBlocksActions &&
    ownershipCanBeClaimed &&
    claimStateCanBeClaimed &&
    claimCapabilityEnabled;
  const claimRequestReason = canRequestClaim ? "" : firstReason([
    publicationBlocksActions ? "This organizer listing is not publicly available." : "",
    claimStateReason(claimState),
    ownershipReason(ownershipState),
    claimCapability?.reason,
    listing.publicApi.reason,
    "Claiming is not available for this organizer.",
  ]);

  const publicReviews = projected.capabilities?.publicReviews;
  const canReadPublicReviews = !publicationBlocksActions && (publicReviews ?
    capabilityEnabled(publicReviews.readState) :
    !hasCapabilityProjection && legacyPublicApiEnabled);
  const canWritePublicReview = canReadPublicReviews && (publicReviews ?
    capabilityEnabled(publicReviews.writeState) :
    !hasCapabilityProjection && legacyPublicApiEnabled);
  const publicReviewReason = canWritePublicReview ? "" : firstReason([
    publicationBlocksActions ? "Reviews are unavailable for this organizer listing." : "",
    publicReviews?.reason,
    listing.publicApi.reason,
    "Public reviews are not available for this organizer.",
  ]);

  return {
    badge: badgeFor({
      claimState,
      isCatchCreated,
      ownershipState,
      verificationStatus,
    }),
    canReadPublicReviews,
    canRequestClaim,
    canWritePublicReview,
    claimRequestReason,
    claimState,
    isCatchCreated,
    ownershipState,
    publicReviewReason,
    verificationStatus,
  };
}

function normalizedOwnershipState(
  value: string | undefined,
  listing: HostListing,
  useLegacyFallback: boolean
): OrganizerOwnershipState {
  if (ownershipStates.has(value as OrganizerOwnershipState)) {
    return value as OrganizerOwnershipState;
  }
  if (!useLegacyFallback) return "unknown";
  if (listing.listingVariant === "appCreatedClub") return "userCreated";
  if (listing.status === "claimed" || listing.status === "verified") return "claimed";
  return listing.listingVariant === "unclaimedScraped" ? "programmatic" : "unknown";
}

function normalizedClaimState(
  value: string | undefined,
  listing: HostListing,
  useLegacyFallback: boolean
): OrganizerClaimState {
  if (claimStates.has(value as OrganizerClaimState)) {
    return value as OrganizerClaimState;
  }
  if (!useLegacyFallback) return "unknown";
  const legacyState = listing.status.trim();
  if (claimStates.has(legacyState as OrganizerClaimState)) {
    return legacyState as OrganizerClaimState;
  }
  return "unknown";
}

function normalizedVerificationStatus(
  value: string | undefined,
  listing: HostListing,
  useLegacyFallback: boolean
): OrganizerVerificationStatus {
  if (verificationStatuses.has(value as OrganizerVerificationStatus)) {
    return value as OrganizerVerificationStatus;
  }
  if (!useLegacyFallback) return "unknown";
  if (listing.listingVariant === "appCreatedClub" || listing.sourceConfidence === "first_party") {
    return "ownerVerified";
  }
  if (["high", "medium"].includes(listing.sourceConfidence)) return "sourceBacked";
  if (listing.sourceConfidence === "low") return "unverified";
  return "unknown";
}

function badgeFor({
  claimState,
  isCatchCreated,
  ownershipState,
  verificationStatus,
}: {
  claimState: OrganizerClaimState;
  isCatchCreated: boolean;
  ownershipState: OrganizerOwnershipState;
  verificationStatus: OrganizerVerificationStatus;
}): OrganizerListingPolicy["badge"] {
  if (claimState === "suppressed") {
    return {compactLabel: "Unavailable", label: "Listing unavailable", tone: "unclaimed"};
  }
  if (claimState === "claimPending") {
    return {compactLabel: "Pending", label: "Claim pending", tone: "claimed"};
  }
  if (isCatchCreated || claimState === "verified" || verificationStatus === "ownerVerified") {
    return {compactLabel: "Verified", label: "Verified on Catch", tone: "verified"};
  }
  if (["claimed", "transferred"].includes(ownershipState) || claimState === "claimed") {
    return {compactLabel: "Claimed", label: "Claimed", tone: "claimed"};
  }
  if (verificationStatus === "sourceBacked") {
    return {compactLabel: "Source-backed", label: "Source-backed listing", tone: "verified"};
  }
  if (claimState === "unclaimed") {
    return {compactLabel: "Unclaimed", label: "Unclaimed", tone: "unclaimed"};
  }
  return {compactLabel: "Unknown", label: "Status unavailable", tone: "unclaimed"};
}

function capabilityEnabled(value: string | undefined) {
  return value === "enabled" || value === "available" || value === "ready";
}

function claimStateReason(state: OrganizerClaimState) {
  switch (state) {
  case "claimPending": return "An organizer claim is already under review.";
  case "claimed":
  case "verified": return "This organizer listing already has an owner.";
  case "suppressed": return "This organizer listing is not available for claims.";
  case "unknown": return "This organizer listing does not have a recognized claim state.";
  case "unclaimed": return "";
  }
}

function ownershipReason(state: OrganizerOwnershipState) {
  switch (state) {
  case "claimed":
  case "transferred":
  case "userCreated": return "This organizer listing already has an owner.";
  case "programmatic":
    return "";
  case "unknown": return "This organizer listing does not have a recognized ownership state.";
  }
}

function firstReason(values: Array<string | undefined>) {
  return values.find((value): value is string => Boolean(value?.trim())) ?? "";
}
