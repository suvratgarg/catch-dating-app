import type {HostListing} from "./types";
import {organizerListingCopy} from "../../content/organizer";

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

export type OrganizerTrustState =
  | "crawledUnclaimed"
  | "sourceBacked"
  | "claimPending"
  | "claimedUnverified"
  | "firstParty"
  | "ownerVerified"
  | "suppressed"
  | "unknown";

export interface OrganizerListingPolicy {
  badge: {
    compactLabel: string;
    label: string;
    tone: "claimed" | "unclaimed" | "verified";
  };
  canReadPublicReviews: boolean;
  canBook: boolean;
  canContactHost: boolean;
  canJoinWaitlist: boolean;
  isPubliclyReadable: boolean;
  canRequestClaim: boolean;
  canWritePublicReview: boolean;
  claimRequestReason: string;
  claimState: OrganizerClaimState;
  isCatchCreated: boolean;
  ownershipState: OrganizerOwnershipState;
  publicReviewReason: string;
  reviewPolicy: "after_event_end" | "attended_event_only" | "unavailable";
  trustState: OrganizerTrustState;
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
      targetState?: string;
      writeState?: string;
    };
    supply?: {
      mode?: string;
      bookable?: boolean;
      paymentsEnabled?: boolean;
      waitlistEnabled?: boolean;
      hostContactEnabled?: boolean;
      claimable?: boolean;
      reviewPolicy?: string;
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

/** Derives fail-closed policy from the canonical listing projection. */
export function organizerPolicyForListing(listing: HostListing): OrganizerListingPolicy {
  const projected = listing as HostListing & PolicyAwareListing;
  const hasAuthorityProjection = projected.authority !== undefined;
  const ownershipState = normalizedOwnershipState(
    projected.authority?.ownershipState
  );
  const claimState = normalizedClaimState(
    projected.authority?.claimState
  );
  const verificationStatus = normalizedVerificationStatus(
    projected.authority?.verificationStatus
  );
  const isCatchCreated = ownershipState === "userCreated";
  const publishStatus = projected.authority?.publishStatus;
  const isPubliclyReadable = hasAuthorityProjection &&
    publishStatus === "published" && claimState !== "suppressed";
  const trustState = trustStateFor({
    claimState,
    isCatchCreated,
    ownershipState,
    publishStatus,
    verificationStatus,
  });
  const ownershipCanBeClaimed = ownershipState === "programmatic";
  const claimStateCanBeClaimed = claimState === "unclaimed";
  const claimCapability = projected.capabilities?.claimRequest;
  const supply = projected.capabilities?.supply;
  const claimCapabilityEnabled = capabilityEnabled(claimCapability?.state);
  const canRequestClaim = isPubliclyReadable &&
    ownershipCanBeClaimed &&
    claimStateCanBeClaimed &&
    claimCapabilityEnabled &&
    supply?.claimable === true;
  const claimRequestReason = canRequestClaim ? "" : firstReason([
    !isPubliclyReadable ? "This organizer listing is not publicly available." : "",
    claimStateReason(claimState),
    ownershipReason(ownershipState),
    claimCapability?.reason,
    listing.publicApi.reason,
    "Claiming is not available for this organizer.",
  ]);

  const publicReviews = projected.capabilities?.publicReviews;
  const publicReviewTargetEnabled = capabilityEnabled(publicReviews?.targetState);
  const canReadPublicReviews = isPubliclyReadable &&
    publicReviewTargetEnabled &&
    capabilityEnabled(publicReviews?.readState);
  const reviewPolicy = normalizedReviewPolicy(supply?.reviewPolicy);
  const canWritePublicReview = canReadPublicReviews &&
    reviewPolicy !== "after_event_end" &&
    capabilityEnabled(publicReviews?.writeState);
  const publicReviewReason = canWritePublicReview ? "" : firstReason([
    !isPubliclyReadable ? "Reviews are unavailable for this organizer listing." : "",
    !publicReviewTargetEnabled ?
      "Reviews are unavailable until the canonical organizer target is ready." : "",
    publicReviews?.reason,
    listing.publicApi.reason,
    "Public reviews are not available for this organizer.",
  ]);

  return {
    badge: badgeFor(trustState),
    canReadPublicReviews,
    canBook: supply?.bookable === true,
    canContactHost: supply?.hostContactEnabled === true,
    canJoinWaitlist: supply?.waitlistEnabled === true,
    canRequestClaim,
    canWritePublicReview,
    claimRequestReason,
    claimState,
    isCatchCreated,
    isPubliclyReadable,
    ownershipState,
    publicReviewReason,
    reviewPolicy,
    trustState,
    verificationStatus,
  };
}

function normalizedReviewPolicy(
  value: string | undefined
): OrganizerListingPolicy["reviewPolicy"] {
  if (value === "after_event_end" || value === "attended_event_only") {
    return value;
  }
  return "unavailable";
}

function normalizedOwnershipState(
  value: string | undefined
): OrganizerOwnershipState {
  if (ownershipStates.has(value as OrganizerOwnershipState)) {
    return value as OrganizerOwnershipState;
  }
  return "unknown";
}

function normalizedClaimState(
  value: string | undefined
): OrganizerClaimState {
  if (claimStates.has(value as OrganizerClaimState)) {
    return value as OrganizerClaimState;
  }
  return "unknown";
}

function normalizedVerificationStatus(
  value: string | undefined
): OrganizerVerificationStatus {
  if (verificationStatuses.has(value as OrganizerVerificationStatus)) {
    return value as OrganizerVerificationStatus;
  }
  return "unknown";
}

function trustStateFor({
  claimState,
  isCatchCreated,
  ownershipState,
  publishStatus,
  verificationStatus,
}: {
  claimState: OrganizerClaimState;
  isCatchCreated: boolean;
  ownershipState: OrganizerOwnershipState;
  publishStatus: string | undefined;
  verificationStatus: OrganizerVerificationStatus;
}): OrganizerTrustState {
  if (claimState === "suppressed" || ["suppressed", "removed"].includes(publishStatus ?? "")) {
    return "suppressed";
  }
  if (isCatchCreated) return "firstParty";
  if (claimState === "verified" || verificationStatus === "ownerVerified") {
    return "ownerVerified";
  }
  if (claimState === "claimPending") return "claimPending";
  if (["claimed", "transferred"].includes(ownershipState) || claimState === "claimed") {
    return "claimedUnverified";
  }
  if (verificationStatus === "sourceBacked") return "sourceBacked";
  if (claimState === "unclaimed") return "crawledUnclaimed";
  return "unknown";
}

function badgeFor(state: OrganizerTrustState): OrganizerListingPolicy["badge"] {
  const copy = organizerListingCopy.badges[state];
  return {
    compactLabel: copy.compact,
    label: copy.label,
    tone: state === "ownerVerified" ?
      "verified" :
      state === "crawledUnclaimed" || state === "suppressed" || state === "unknown" ?
        "unclaimed" :
        "claimed",
  };
}

function capabilityEnabled(value: string | undefined) {
  return value === "enabled";
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
