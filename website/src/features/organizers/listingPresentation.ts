export type ListingClaimPanelState = "hidden" | "form" | "runtimeFallback";

export interface ListingClaimPresentation {
  panel: ListingClaimPanelState;
}

export function listingClaimPresentationFor({
  canRequestClaim,
  isPubliclyReadable,
  runtimeAvailable,
}: {
  canRequestClaim: boolean;
  isPubliclyReadable: boolean;
  runtimeAvailable: boolean;
}): ListingClaimPresentation {
  if (!isPubliclyReadable || !canRequestClaim) {
    return {panel: "hidden"};
  }
  return {panel: runtimeAvailable ? "form" : "runtimeFallback"};
}

export type ListingReviewReadState = "hidden" | "content" | "unavailable";
export type ListingReviewWriteState = "hidden" | "form" | "unavailable";

export interface ListingReviewPresentation {
  read: ListingReviewReadState;
  write: ListingReviewWriteState;
}

export function listingReviewPresentationFor({
  canReadPublicReviews,
  canWritePublicReview,
  isPubliclyReadable,
  runtimeAvailable,
}: {
  canReadPublicReviews: boolean;
  canWritePublicReview: boolean;
  isPubliclyReadable: boolean;
  runtimeAvailable: boolean;
}): ListingReviewPresentation {
  if (!isPubliclyReadable) {
    return {read: "hidden", write: "hidden"};
  }
  if (!canReadPublicReviews) {
    return {read: "unavailable", write: "hidden"};
  }
  return {
    read: "content",
    write: canWritePublicReview && runtimeAvailable ? "form" : "unavailable",
  };
}
