import {type FormEvent, useEffect, useMemo, useState} from "react";
import {trackMarketingEvent} from "../../analytics";
import {
  createPublicClubReview,
  listPublicClubReviews,
  publicReviewsFirebaseConfigured,
} from "../../firebase";
import type {FormStatus} from "../../shared/forms/types";
import {isPublicApiEnabled} from "../organizers/selectors";
import type {HostListing, HostListingReview} from "../organizers/types";
import {buildListingReviewSummary, mergeReviews} from "./reviewModel";

export function useListingReviewsController(listing: HostListing) {
  const seedReviews = useMemo(() => listing.reviews ?? [], [listing]);
  const publicApiEnabled = isPublicApiEnabled(listing);
  const [reviews, setReviews] = useState<HostListingReview[]>(() => seedReviews);
  const [rating, setRating] = useState(5);
  const [reviewerName, setReviewerName] = useState("");
  const [comment, setComment] = useState("");
  const [isAnonymous, setIsAnonymous] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [status, setStatus] = useState<FormStatus>({message: "", tone: ""});

  useEffect(() => {
    let cancelled = false;
    setReviews(seedReviews);

    if (!publicApiEnabled || !publicReviewsFirebaseConfigured) {
      return () => {
        cancelled = true;
      };
    }

    listPublicClubReviews({clubId: listing.id})
      .then((result) => {
        if (cancelled || !result.reviews.length) return;
        setReviews(mergeReviews(result.reviews, seedReviews));
      })
      .catch((error) => {
        if (cancelled) return;
        setStatus({
          message: readableError(error),
          tone: "is-error",
        });
      });

    return () => {
      cancelled = true;
    };
  }, [listing.id, publicApiEnabled, seedReviews]);

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
      setStatus({message: "Review text is required.", tone: "is-error"});
      return;
    }
    if (!isAnonymous && !trimmedName) {
      setStatus({
        message: "Add your name, or choose anonymous.",
        tone: "is-error",
      });
      return;
    }

    setIsSubmitting(true);
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
      if (publicReviewsFirebaseConfigured) {
        const result = await createPublicClubReview({
          clubId: listing.id,
          rating,
          comment: trimmedComment,
          reviewerName: trimmedName,
          isAnonymous,
          submittedFromPath: window.location.pathname,
        });
        setReviews((current) => mergeReviews([result.review], current));
        setStatus({
          message: "Review published as an unverified public review.",
          tone: "is-success",
        });
      } else {
        setReviews((current) => mergeReviews([localReview], current));
        setStatus({
          message:
            "Preview review added locally. Configure website App Check to write it to Firestore.",
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
    } finally {
      setIsSubmitting(false);
    }
  }

  return {
    comment,
    isAnonymous,
    isSubmitting,
    publicApiEnabled,
    rating,
    reviewFormId: `review-${listing.id}`,
    reviewerName,
    reviews,
    setComment,
    setIsAnonymous,
    setRating,
    setReviewerName,
    status,
    submitReview,
    summary,
  };
}

function readableError(error: unknown): string {
  return error instanceof Error ?
    error.message :
    "Something went wrong. Please try again.";
}
