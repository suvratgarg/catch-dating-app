import {websiteCopy} from "@content/generated";
import {organizerListingCopy} from "@content/organizer";
import {useMutation, useQuery, useQueryClient} from "@tanstack/react-query";
import {type FormEvent, useEffect, useMemo, useState} from "react";
import {trackMarketingEvent} from "../../analytics";
import type {ListPublicOrganizerReviewsResponse} from "../../firebase";
import {publicReviewsFirebaseConfigured} from "../../firebaseConfig";
import type {FormStatus} from "../../shared/forms/types";
import {websiteQueryKeys} from "../../shared/query/queryKeys";
import {organizerPolicyForListing} from "../organizers/organizerPolicy";
import {listingReviewPresentationFor} from "../organizers/listingPresentation";
import type {HostListing, HostListingReview} from "../organizers/types";
import {buildListingReviewSummary, mergeReviews} from "./reviewModel";

export function useListingReviewsController(listing: HostListing) {
  const queryClient = useQueryClient();
  const policy = organizerPolicyForListing(listing);
  const presentation = listingReviewPresentationFor({
    canReadPublicReviews: policy.canReadPublicReviews,
    canWritePublicReview: policy.canWritePublicReview,
    isPubliclyReadable: policy.isPubliclyReadable,
    runtimeAvailable: publicReviewsFirebaseConfigured,
  });
  const seedReviews = useMemo(
    () => policy.canReadPublicReviews ? listing.reviews ?? [] : [],
    [listing, policy.canReadPublicReviews]
  );
  const publicReviewWriteEnabled = presentation.write === "form";
  const publicReviewReason = policy.canWritePublicReview && !publicReviewsFirebaseConfigured ?
    organizerListingCopy.reviews.runtimeUnavailable :
    policy.publicReviewReason;
  const reviewQueryKey = useMemo(
    () => websiteQueryKeys.reviews.listing(listing.id),
    [listing.id]
  );
  const [localReviews, setLocalReviews] = useState<HostListingReview[]>([]);
  const [rating, setRating] = useState(5);
  const [reviewerName, setReviewerName] = useState("");
  const [comment, setComment] = useState("");
  const [isAnonymous, setIsAnonymous] = useState(false);
  const [status, setStatus] = useState<FormStatus>({message: "", tone: ""});

  useEffect(() => {
    setLocalReviews([]);
    setStatus({message: "", tone: ""});
  }, [listing.id]);

  const reviewsQuery = useQuery({
    enabled: policy.canReadPublicReviews && publicReviewsFirebaseConfigured,
    queryFn: async () => {
      const {listPublicOrganizerReviews} = await import("../../firebase");
      return listPublicOrganizerReviews({organizerId: listing.id});
    },
    queryKey: reviewQueryKey,
  });

  const createReviewMutation = useMutation({
    mutationFn: async (payload: {
      comment: string;
      isAnonymous: boolean;
      localReview: HostListingReview;
      rating: number;
      reviewerName: string;
    }) => {
      if (!publicReviewsFirebaseConfigured) {
        throw new Error(organizerListingCopy.reviews.runtimeUnavailable);
      }
      const {createPublicOrganizerReview} = await import("../../firebase");
      const result = await createPublicOrganizerReview({
        organizerId: listing.id,
        rating: payload.rating,
        comment: payload.comment,
        reviewerName: payload.reviewerName,
        isAnonymous: payload.isAnonymous,
        submittedFromPath: listing.path,
      });
      const review = result.review as typeof result.review & {
        moderationStatus?: "published" | "pending";
      };
      return {
        moderationStatus: review.moderationStatus ?? "pending",
        review,
      };
    },
  });

  const remoteReviews = reviewsQuery.data?.reviews;
  const reviews = useMemo(() => policy.canReadPublicReviews ?
    mergeReviews(localReviews, mergeReviews(remoteReviews ?? [], seedReviews)) :
    [], [localReviews, policy.canReadPublicReviews, remoteReviews, seedReviews]);

  const summary = useMemo(
    () => buildListingReviewSummary(listing, reviews),
    [listing, reviews]
  );

  async function submitReview(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setStatus({message: "", tone: ""});

    if (!publicReviewWriteEnabled) {
      setStatus({
        message: publicReviewReason,
        tone: "is-error",
      });
      return;
    }

    const trimmedComment = comment.trim();
    const trimmedName = reviewerName.trim();
    if (!trimmedComment) {
      setStatus({message: websiteCopy["uselistingreviewscontroller_0505"], tone: "is-error"});
      return;
    }
    if (!isAnonymous && !trimmedName) {
      setStatus({
        message: websiteCopy["uselistingreviewscontroller_0502"],
        tone: "is-error",
      });
      return;
    }

    const localReview: HostListingReview = {
      id: `local-${Date.now()}`,
      reviewerName: isAnonymous ? "Anonymous reviewer" : trimmedName,
      rating,
      comment: trimmedComment,
      createdAt: new Date().toISOString(),
      verificationStatus: "unverified",
      source: "publicListing",
      isAnonymous,
      ownerResponse: null,
    };

    try {
      const result = await createReviewMutation.mutateAsync({
        comment: trimmedComment,
        isAnonymous,
        localReview,
        rating,
        reviewerName: trimmedName,
      });

      if (result.moderationStatus === "pending") {
        await queryClient.invalidateQueries({queryKey: reviewQueryKey});
        setStatus({
          message: organizerListingCopy.reviews.pendingAcknowledgement,
          tone: "is-success",
        });
        setComment("");
        if (isAnonymous) setReviewerName("");
        trackMarketingEvent("listing_public_review_submitted", {
          club_id: listing.id,
          anonymous: isAnonymous,
          configured: true,
          moderation_status: "pending",
        });
        return;
      }
      // Keep a published callable response visible while the eventually
      // consistent list query catches up. mergeReviews deduplicates it once
      // the backend read returns the same id.
      setLocalReviews((current) => mergeReviews([result.review], current));
      queryClient.setQueryData<ListPublicOrganizerReviewsResponse>(
        reviewQueryKey,
        (current) => {
          const seen = new Set<string>();
          const reviews = [result.review, ...(current?.reviews ?? [])].filter((review) => {
            if (seen.has(review.id)) return false;
            seen.add(review.id);
            return true;
          });
          return {reviews};
        }
      );
      await queryClient.invalidateQueries({queryKey: reviewQueryKey});
      setStatus({
        message: websiteCopy["uselistingreviewscontroller_0504"],
        tone: "is-success",
      });
      setComment("");
      if (isAnonymous) setReviewerName("");
      trackMarketingEvent("listing_public_review_submitted", {
        club_id: listing.id,
        anonymous: isAnonymous,
        configured: true,
        moderation_status: result.moderationStatus,
      });
    } catch (error) {
      setStatus({
        message: readableError(error),
        tone: "is-error",
      });
    }
  }

  const resolvedStatus: FormStatus = status.message || !reviewsQuery.isError ?
    status :
    {
      message: readableError(reviewsQuery.error),
      tone: "is-error" as const,
    };

  return {
    comment,
    isAnonymous,
    isSubmitting: createReviewMutation.isPending,
    publicApiEnabled: publicReviewWriteEnabled,
    presentation,
    publicReviewReadEnabled: presentation.read === "content",
    publicReviewReason,
    publicReviewWriteEnabled,
    rating,
    reviewFormId: `review-${listing.id}`,
    reviewerName,
    reviews,
    setComment,
    setIsAnonymous,
    setRating,
    setReviewerName,
    status: resolvedStatus,
    submitReview,
    summary,
  };
}

function readableError(error: unknown): string {
  return error instanceof Error ?
    error.message :
    "Something went wrong. Please try again.";
}
