import {SectionHeader} from "../../../shared/site";
import {
  Button,
  ButtonLink,
  FormStatus,
  ListingReviewCheckbox,
  ListingReviewEmptyState,
  ListingReviewForm,
  ListingReviewLanes,
  ListingReviewSummary,
  ListingReviewWorkspace,
  ListingSection,
  OwnerResponsePrompt,
  ReviewSignalLane,
  SelectField,
  TextAreaField,
  TextField,
  UiLabel,
} from "../../../shared/ui/primitives";
import {trackCtaClick} from "../../marketing/tracking";
import {claimHrefForListing} from "../routing";
import type {HostListing} from "../types";
import {useListingReviewsController} from "../../reviews/useListingReviewsController";

export function ListingReviewsSection({listing}: {listing: HostListing}) {
  const {
    comment,
    isAnonymous,
    isSubmitting,
    rating,
    reviewFormId,
    reviewerName,
    reviews,
    setComment,
    setIsAnonymous,
    setRating,
    setReviewerName,
    status,
    submitReview,
    summary,
  } = useListingReviewsController(listing);
  const isAppCreated = listing.listingVariant === "appCreatedClub";
  const {
    displayRating,
    displayReviewCount,
    ownerPromptStats,
    publicReviews,
    verifiedCount,
    verifiedReviews,
  } = summary;

  return (
    <ListingSection
      variant="reviews"
      id="reviews"
      aria-labelledby="listing-reviews-title"
    >
      <SectionHeader
        eyebrow="Reviews"
        id="listing-reviews-title"
        title={<>Public reviews for {listing.name}.</>}
        body="Verified reviews come from logged-in Catch guests after attended events. Reviews submitted on this public page are unverified and can be anonymous." />
      <ListingReviewSummary>
        <div>
          <UiLabel>Rating</UiLabel>
          <strong>
            {displayReviewCount ? displayRating.toFixed(1) : "No reviews yet"}
          </strong>
        </div>
        <div>
          <UiLabel>Count</UiLabel>
          <strong>{displayReviewCount}</strong>
        </div>
        <div>
          <UiLabel>Verified</UiLabel>
          <strong>{verifiedCount}</strong>
        </div>
        <ButtonLink
          variant="ghost"
          href={`#${reviewFormId}`}
          onClick={() => trackCtaClick("listing_review_intent", `#${reviewFormId}`)}
        >
          Add review
        </ButtonLink>
      </ListingReviewSummary>
      <ListingReviewWorkspace>
        <div>
          {reviews.length ? (
            <ListingReviewLanes>
              <ReviewSignalLane
                title="Verified Catch attendee reviews"
                body="These reviews come from logged-in guests after attended Catch events and stay separate from public page feedback."
                reviews={verifiedReviews}
                emptyTitle="No verified attendee reviews are visible yet."
                emptyBody="Verified attendee reviews appear after Catch has operated the event and confirmed attendance."
              />
              <ReviewSignalLane
                title="Unverified public reviews"
                body="These reviews are submitted from the public web page. They are useful, but they are not treated as attended-event proof."
                reviews={publicReviews}
                emptyTitle="No public web reviews yet."
                emptyBody="Public reviews can be added here; Catch keeps them clearly labeled until they can be tied to a verified event."
              />
            </ListingReviewLanes>
          ) : (
            <ListingReviewEmptyState reveal>
              <div>
                <UiLabel>First review</UiLabel>
                <h3>No public reviews for {listing.name} yet.</h3>
                <p>
                  Add the first public review here. If the organizer claims this
                  page, they can respond from the verified host account.
                </p>
              </div>
            </ListingReviewEmptyState>
          )}
          <OwnerResponsePrompt
            title={isAppCreated ? "Owner replies stay attached to the source." : "Claiming unlocks owner replies."}
            body={isAppCreated ?
              "Catch separates attendee proof, public web feedback, and host replies so responses do not blur the review source." :
              "Public reviews can arrive before the organizer owns the page. Catch keeps them unverified until a claim is approved."}
            stats={ownerPromptStats}
            ctaHref={isAppCreated ? undefined : claimHrefForListing(listing)}
            ctaLabel={isAppCreated ? undefined : "Claim to respond"}
            onCtaClick={(href) => trackCtaClick("owner_response_prompt", href)}
          />
        </div>

        <ListingReviewForm
          id={reviewFormId}
          onSubmit={submitReview}
          reveal
        >
          <div>
            <UiLabel>Add review</UiLabel>
            <h3>Share feedback for {listing.name}.</h3>
          </div>
          <SelectField
            id={`${reviewFormId}-rating`}
            label="Rating"
            value={rating}
            onChange={(event) => setRating(Number(event.target.value))}
          >
            <option value={5}>5 stars</option>
            <option value={4}>4 stars</option>
            <option value={3}>3 stars</option>
            <option value={2}>2 stars</option>
            <option value={1}>1 star</option>
          </SelectField>
          <TextField
            id={`${reviewFormId}-reviewer`}
            label="Display name"
            value={reviewerName}
            disabled={isAnonymous}
            maxLength={120}
            onChange={(event) => setReviewerName(event.target.value)}
            placeholder={isAnonymous ? "Anonymous reviewer" : "Your name"}
          />
          <ListingReviewCheckbox
            checked={isAnonymous}
            onChange={(event) => setIsAnonymous(event.target.checked)}
          >
            Post anonymously
          </ListingReviewCheckbox>
          <TextAreaField
            id={`${reviewFormId}-comment`}
            label="Review"
            value={comment}
            maxLength={1000}
            rows={6}
            onChange={(event) => setComment(event.target.value)}
            placeholder="What should people know about this organizer?"
          />
          <Button type="submit" disabled={isSubmitting}>
            {isSubmitting ? "Publishing..." : "Publish review"}
          </Button>
          {status.message ? <FormStatus status={status} /> : null}
        </ListingReviewForm>
      </ListingReviewWorkspace>
    </ListingSection>
  );
}
