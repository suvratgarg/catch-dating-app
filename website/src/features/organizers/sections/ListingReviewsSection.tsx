import {websiteCopy} from "@content/generated";
import {organizerListingCopy} from "@content/organizer";
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
import {organizerPolicyForListing} from "../organizerPolicy";
import type {HostListing} from "../types";
import {useListingReviewsController} from "../../reviews/useListingReviewsController";

export function ListingReviewsSection({listing}: {listing: HostListing}) {
  const {
    comment,
    isAnonymous,
    isSubmitting,
    rating,
    publicReviewReason,
    presentation,
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
  const listingPolicy = organizerPolicyForListing(listing);
  const {
    displayRating,
    displayReviewCount,
    ownerPromptStats,
    publicReviews,
    verifiedCount,
    verifiedReviews,
  } = summary;

  if (presentation.read === "hidden") {
    return null;
  }

  if (presentation.read === "unavailable") {
    return (
      <ListingSection
        variant="reviews"
        id="reviews"
        aria-labelledby="listing-reviews-title"
      >
        <SectionHeader
          eyebrow={websiteCopy["listingreviewssection_0437"]}
          id="listing-reviews-title"
          title={<>{websiteCopy["listingreviewssection_0434"]} {listing.name}.</>}
          body={websiteCopy["listingreviewssection_0445"]} />
        <ListingReviewEmptyState reveal>
          <div>
            <UiLabel>{organizerListingCopy.reviews.unavailableLabel}</UiLabel>
            <h3>{organizerListingCopy.reviews.unavailableTitle}</h3>
            <p>{publicReviewReason}</p>
          </div>
        </ListingReviewEmptyState>
      </ListingSection>
    );
  }

  return (
    <ListingSection
      variant="reviews"
      id="reviews"
      aria-labelledby="listing-reviews-title"
    >
      <SectionHeader
        eyebrow={websiteCopy["listingreviewssection_0437"]}
        id="listing-reviews-title"
        title={<>{websiteCopy["listingreviewssection_0434"]} {listing.name}.</>}
        body={websiteCopy["listingreviewssection_0445"]} />
      <ListingReviewSummary>
        <div>
          <UiLabel>{websiteCopy["listingreviewssection_0435"]}</UiLabel>
          <strong>
            {verifiedCount ? displayRating.toFixed(1) : "No verified rating"}
          </strong>
        </div>
        <div>
          <UiLabel>{websiteCopy["listingreviewssection_0426"]}</UiLabel>
          <strong>{displayReviewCount}</strong>
        </div>
        <div>
          <UiLabel>{websiteCopy["listingreviewssection_0442"]}</UiLabel>
          <strong>{verifiedCount}</strong>
        </div>
        {presentation.write === "form" ? (
          <ButtonLink
            variant="ghost"
            href={`#${reviewFormId}`}
            onClick={() => trackCtaClick("listing_review_intent", `#${reviewFormId}`)}
          >{websiteCopy["listingreviewssection_0424"]}</ButtonLink>
        ) : null}
      </ListingReviewSummary>
      <ListingReviewWorkspace>
        <div>
          {reviews.length ? (
            <ListingReviewLanes>
              <ReviewSignalLane
                title={websiteCopy["listingreviewssection_0444"]}
                body={websiteCopy["listingreviewssection_0440"]}
                reviews={verifiedReviews}
                emptyTitle={websiteCopy["listingreviewssection_0431"]}
                emptyBody={websiteCopy["listingreviewssection_0443"]}
              />
              <ReviewSignalLane
                title={websiteCopy["listingreviewssection_0441"]}
                body={websiteCopy["listingreviewssection_0439"]}
                reviews={publicReviews}
                emptyTitle={websiteCopy["listingreviewssection_0430"]}
                emptyBody={websiteCopy["listingreviewssection_0433"]}
              />
            </ListingReviewLanes>
          ) : (
            <ListingReviewEmptyState reveal>
              <div>
                <UiLabel>{websiteCopy["listingreviewssection_0428"]}</UiLabel>
                <h3>
                  {websiteCopy["listingreviewssection_0429"]} {listing.name}{" "}
                  {websiteCopy["listingreviewssection_0447"]}
                </h3>
                <p>{websiteCopy["listingreviewssection_0425"]}</p>
              </div>
            </ListingReviewEmptyState>
          )}
          <OwnerResponsePrompt
            title={listingPolicy.canRequestClaim ?
              "Claiming unlocks owner replies." :
              "Owner replies stay attached to the source."}
            body={!listingPolicy.canRequestClaim ?
              "Catch separates attendee proof, public web feedback, and host replies so responses do not blur the review source." :
              "Public reviews can arrive before the organizer owns the page. Catch keeps them unverified until a claim is approved."}
            stats={ownerPromptStats}
            ctaHref={listingPolicy.canRequestClaim ? claimHrefForListing(listing) : undefined}
            ctaLabel={listingPolicy.canRequestClaim ? "Claim to respond" : undefined}
            onCtaClick={(href) => trackCtaClick("owner_response_prompt", href)}
          />
        </div>

        {presentation.write === "form" ? (
          <ListingReviewForm
            id={reviewFormId}
            onSubmit={submitReview}
            reveal
          >
            <div>
              <UiLabel>{websiteCopy["listingreviewssection_0424"]}</UiLabel>
              <h3>{websiteCopy["listingreviewssection_0438"]} {listing.name}.</h3>
            </div>
            <SelectField
              id={`${reviewFormId}-rating`}
              label={websiteCopy["listingreviewssection_0435"]}
              value={rating}
              onChange={(event) => setRating(Number(event.target.value))}
            >
              <option value={5}>{websiteCopy["listingreviewssection_0423"]}</option>
              <option value={4}>{websiteCopy["listingreviewssection_0422"]}</option>
              <option value={3}>{websiteCopy["listingreviewssection_0421"]}</option>
              <option value={2}>{websiteCopy["listingreviewssection_0420"]}</option>
              <option value={1}>{websiteCopy["listingreviewssection_0419"]}</option>
            </SelectField>
            <TextField
              id={`${reviewFormId}-reviewer`}
              label={websiteCopy["listingreviewssection_0427"]}
              value={reviewerName}
              disabled={isAnonymous}
              maxLength={120}
              onChange={(event) => setReviewerName(event.target.value)}
              placeholder={isAnonymous ? "Anonymous reviewer" : "Your name"}
            />
            <ListingReviewCheckbox
              checked={isAnonymous}
              onChange={(event) => setIsAnonymous(event.target.checked)}
            >{websiteCopy["listingreviewssection_0432"]}</ListingReviewCheckbox>
            <TextAreaField
              id={`${reviewFormId}-comment`}
              label={websiteCopy["listingreviewssection_0436"]}
              value={comment}
              maxLength={1000}
              rows={6}
              onChange={(event) => setComment(event.target.value)}
              placeholder={websiteCopy["listingreviewssection_0446"]}
            />
            <Button type="submit" disabled={isSubmitting}>
              {isSubmitting ? "Submitting..." : "Submit review"}
            </Button>
            {status.message ? <FormStatus status={status} /> : null}
          </ListingReviewForm>
        ) : (
          <ListingReviewEmptyState reveal>
            <div>
              <UiLabel>{organizerListingCopy.reviews.unavailableLabel}</UiLabel>
              <h3>{organizerListingCopy.reviews.unavailableTitle}</h3>
              <p>{publicReviewReason}</p>
            </div>
          </ListingReviewEmptyState>
        )}
      </ListingReviewWorkspace>
    </ListingSection>
  );
}
