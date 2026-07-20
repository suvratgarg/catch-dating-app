import {websiteCopy} from "@content/generated";
import {useMutation, useQuery, useQueryClient} from "@tanstack/react-query";
import {type FormEvent, useEffect, useMemo, useState} from "react";
import {trackMarketingEvent} from "../../analytics";
import type {ListPublicOrganizerReviewsResponse} from "../../firebase";
import {publicReviewsFirebaseConfigured} from "../../firebaseConfig";
import type {FormStatus} from "../../shared/forms/types";
import {websiteQueryKeys} from "../../shared/query/queryKeys";
import {isPublicApiEnabled} from "../organizers/selectors";
import type {HostListing, HostListingReview} from "../organizers/types";
import {buildListingReviewSummary, mergeReviews} from "./reviewModel";

export function useListingReviewsController(listing: HostListing) {
  const queryClient = useQueryClient();
  const seedReviews = useMemo(() => listing.reviews ?? [], [listing]);
  const publicApiEnabled = isPublicApiEnabled(listing);
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
    enabled: publicApiEnabled && publicReviewsFirebaseConfigured,
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
        return {
          mode: "local" as const,
          review: payload.localReview,
        };
      }
      const {createPublicOrganizerReview} = await import("../../firebase");
      const result = await createPublicOrganizerReview({
        organizerId: listing.id,
        rating: payload.rating,
        comment: payload.comment,
        reviewerName: payload.reviewerName,
        isAnonymous: payload.isAnonymous,
        submittedFromPath: window.location.pathname,
      });
      return {
        mode: "remote" as const,
        review: result.review,
      };
    },
  });

  const remoteReviews = reviewsQuery.data?.reviews;
  const reviews = useMemo(
    () => mergeReviews(localReviews, mergeReviews(remoteReviews ?? [], seedReviews)),
    [localReviews, remoteReviews, seedReviews]
  );

  const summary = useMemo(
    () => buildListingReviewSummary(listing, reviews),
    [listing, reviews]
  );

  async function submitReview(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setStatus({message: "", tone: ""});

    if (!publicApiEnabled) {
      setStatus({
        message: listing.publicApi.reason,
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

      if (result.mode === "remote") {
        // Keep the callable's accepted review visible while the eventually
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
      } else {
        setLocalReviews((current) => mergeReviews([result.review], current));
        setStatus({
          message:
            websiteCopy["uselistingreviewscontroller_0503"],
          tone: "is-success",
        });
      }
      setComment("");
      if (isAnonymous) setReviewerName("");
      trackMarketingEvent("listing_public_review_submitted", {
        club_id: listing.id,
        anonymous: isAnonymous,
        configured: publicReviewsFirebaseConfigured,
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
    publicApiEnabled,
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
