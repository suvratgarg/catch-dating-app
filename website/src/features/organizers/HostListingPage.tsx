import {type CSSProperties, useEffect, useState} from "react";
import {trackMarketingEvent} from "../../analytics";
import {
  EventActionCard,
  OwnerResponsePrompt,
  ProcessStatusPanel,
  ReviewSignalLane,
  SectionHeader,
  SiteFooter,
  SiteHeader,
} from "../../components/site";
import {
  AuthStatusRow,
  Button,
  ButtonLink,
  CheckboxField,
  FormStatus,
  SelectField,
  TextAreaField,
  TextField,
} from "../../shared/ui/primitives";
import {claimRoleOptions} from "../claims/claimModel";
import {useListingClaimController} from "../claims/useListingClaimController";
import {AppDownloadCtas} from "../marketing/AppDownloadCtas";
import {claimUnlocks} from "../marketing/content";
import {trackCtaClick} from "../marketing/tracking";
import {trackOrganizerAnalytics} from "./analytics";
import {hostListings} from "./data";
import {ActivityMark, ProfileStrength, StatusBadge} from "./OrganizerIdentity";
import {OrganizerMiniCard} from "./OrganizerMiniCard";
import {
  absoluteListingUrl,
  activityForListing,
  eventActionCardForListing,
  externalEventActionCardForListing,
} from "./publicDiscovery";
import {claimHrefForListing} from "./routing";
import {readSavedOrganizer, writeSavedOrganizer} from "./savedOrganizerStorage";
import {isVerifiedListing, listingProfileStrength} from "./selectors";
import type {HostListing, HostListingEventSuccessSummary} from "./types";
import {useListingReviewsController} from "../reviews/useListingReviewsController";

export function HostListingPage({listing}: {listing: HostListing}) {
  const isAppCreated = listing.listingVariant === "appCreatedClub";
  const activity = activityForListing(listing);
  const claimHref = isAppCreated ? listing.claim.href : claimHrefForListing(listing);
  const hasEventSupply = Boolean(
    listing.catchEvents?.length || listing.externalEvents?.length
  );
  const [shareStatus, setShareStatus] = useState("");
  const [isSaved, setIsSaved] = useState(() => readSavedOrganizer(listing.id));
  const nav = [
    {href: "#profile", label: "Profile"},
    ...(hasEventSupply ? [{href: "#events", label: "Events"}] : []),
    {href: "#reviews", label: "Reviews"},
    {href: "#fit", label: isAppCreated ? "Format" : "Fit"},
    ...(!isAppCreated ? [{href: "#sources", label: "Sources"}] : []),
    {href: "/organizers/", label: "Search"},
    {href: "/host/", label: "For hosts"},
  ];

  useEffect(() => {
    trackOrganizerAnalytics(listing, "listingView", "listing_page");
  }, [listing]);

  function handleSaveListing() {
    const nextSaved = !isSaved;
    setIsSaved(nextSaved);
    writeSavedOrganizer(listing.id, nextSaved);
    if (nextSaved) {
      trackOrganizerAnalytics(listing, "organizerSave", "listing_hero");
    }
  }

  async function handleShareListing() {
    const shareUrl = absoluteListingUrl(listing);
    const shareData = {
      title: `${listing.name} on Catch`,
      text: listing.headline,
      url: shareUrl,
    };

    try {
      if ("share" in navigator && typeof navigator.share === "function") {
        await navigator.share(shareData);
        setShareStatus("Share sheet opened.");
        trackMarketingEvent("listing_share_completed", {
          club_id: listing.id,
          method: "native",
        });
        return;
      }
      if (navigator.clipboard?.writeText) {
        await navigator.clipboard.writeText(shareUrl);
        setShareStatus("Listing link copied.");
        trackMarketingEvent("listing_share_completed", {
          club_id: listing.id,
          method: "clipboard",
        });
        return;
      }
      setShareStatus(shareUrl);
      trackMarketingEvent("listing_share_completed", {
        club_id: listing.id,
        method: "manual",
      });
    } catch (error) {
      const aborted = error instanceof DOMException && error.name === "AbortError";
      setShareStatus(aborted ? "Share cancelled." : "Could not share. Copy the URL from the address bar.");
      trackMarketingEvent("listing_share_error", {
        club_id: listing.id,
        aborted,
      });
    }
  }

  return (
    <>
      <SiteHeader
        brandHref="/"
        nav={nav}
        ctaHref={claimHref}
        ctaLabel={isAppCreated ? listing.claim.label : "Claim listing"}
      />

      <main id="profile">
        <section className="listing-hero">
          <div className="listing-hero__inner">
            <div
              className="listing-hero__copy"
              data-reveal
              style={{"--activity": activity.token} as CSSProperties}
            >
              <div className="listing-hero__eyebrow">
                <StatusBadge listing={listing} />
                <span className="ui-label">{listing.category}</span>
              </div>
              <h1>{listing.headline}</h1>
              <p>{listing.description}</p>
              <div className="listing-badge-row" aria-label="Listing status">
                <span>{listing.status}</span>
                <span>{listing.sourceConfidence.replaceAll("_", " ")}</span>
                <span>Updated {listing.lastVerifiedAt}</span>
              </div>
              <div className="hero__actions">
                <ButtonLink
                  href={claimHref}
                  onClick={() => {
                    trackCtaClick("listing_claim", claimHref);
                    trackOrganizerAnalytics(listing, "claimClick", "hero");
                  }}
                >
                  {listing.claim.label}
                </ButtonLink>
                <ButtonLink
                  variant="ghost"
                  href={isAppCreated ? "/organizers/" : "/host/"}
                  onClick={() => trackCtaClick(
                    isAppCreated ? "listing_search_organizers" : "listing_host_tools",
                    isAppCreated ? "/organizers/" : "/host/"
                  )}
                >
                  {isAppCreated ? "Search organizers" : "See Catch for hosts"}
                </ButtonLink>
                <Button
                  variant="ghost"
                  type="button"
                  onClick={() => void handleShareListing()}
                >
                  Share listing
                </Button>
                <Button
                  variant="ghost"
                  type="button"
                  aria-pressed={isSaved}
                  onClick={handleSaveListing}
                >
                  {isSaved ? "Saved" : "Save"}
                </Button>
              </div>
              <p className="listing-share-status" role="status" aria-live="polite">
                {shareStatus}
              </p>
            </div>

            <aside
              className="listing-panel"
              aria-label={`${listing.name} profile`}
              data-reveal
              style={{"--activity": activity.token} as CSSProperties}
            >
              <ActivityMark listing={listing} size="lg" />
              <div>
                <span className="ui-label">
                  {isAppCreated ? "Catch organizer" : "Unclaimed profile"}
                </span>
                <h2>{listing.name}</h2>
                <p>
                  {listing.host ? `Hosted by ${listing.host.name}` : `${listing.city}, ${listing.region}`}
                </p>
              </div>
              {listing.metrics ? (
                <div className="listing-panel__metrics" aria-label="Organizer metrics">
                  <span><strong>{listing.metrics.memberCount ?? 0}</strong> members</span>
                  <span><strong>{listing.metrics.rating?.toFixed(1) ?? "0.0"}</strong> rating</span>
                  <span><strong>{listing.metrics.reviewCount ?? 0}</strong> reviews</span>
                </div>
              ) : null}
              <div className="listing-format-row">
                {listing.formats.map((format) => (
                  <span key={format}>{format}</span>
                ))}
              </div>
              <ListingDiagnosticsPanel listing={listing} />
            </aside>
          </div>
        </section>

        <section className="listing-section" aria-labelledby="listing-facts-title">
          <div className="section-heading" data-reveal>
            <span className="ui-label">
              {isAppCreated ? "Club profile" : "Known profile"}
            </span>
            <h2 id="listing-facts-title">
              {isAppCreated ?
                "A Catch-created club with real product context." :
                "A source-conservative seed listing."}
            </h2>
            <p>{listing.sourceSummary}</p>
          </div>
          <div className="listing-grid">
            {listing.facts.map((fact) => (
              <article className="listing-card" data-reveal key={fact.label}>
                <span>{fact.label}</span>
                <strong>{fact.value}</strong>
              </article>
            ))}
          </div>
        </section>

        {listing.catchEvents?.length ? (
          <ListingCatchEventsSection listing={listing} />
        ) : null}

        {listing.externalEvents?.length ? (
          <ListingExternalEventsSection
            anchorId={listing.catchEvents?.length ? "external-events" : "events"}
            listing={listing}
          />
        ) : null}

        {listing.eventEvidence?.length ? (
          <section className="listing-section listing-section--events" aria-labelledby="listing-events-title">
            <div className="section-heading" data-reveal>
              <span className="ui-label">Event evidence</span>
              <h2 id="listing-events-title">Public events tied to this host.</h2>
            </div>
            <div className="listing-event-stack">
              {listing.eventEvidence.map((event) => (
                <article className="listing-event-card" data-reveal key={event.title}>
                  <div>
                    <span className="ui-label">{event.date}</span>
                    <h3>{event.title}</h3>
                    <p>{event.summary}</p>
                  </div>
                  <dl className="listing-event-meta">
                    <div>
                      <dt>Location</dt>
                      <dd>{event.location}</dd>
                    </div>
                    <div>
                      <dt>Source</dt>
                      <dd>
                        <a
                          href={event.sourceHref}
                          target="_blank"
                          rel="noreferrer"
                          onClick={() => trackOrganizerAnalytics(
                            listing,
                            "outboundClick",
                            "event_evidence"
                          )}
                        >
                          {event.sourceLabel}
                        </a>
                      </dd>
                    </div>
                  </dl>
                  <ul className="listing-event-facts">
                    {event.facts.map((fact) => (
                      <li key={fact}>{fact}</li>
                    ))}
                  </ul>
                </article>
              ))}
            </div>
          </section>
        ) : null}

        <ListingReviewsSection listing={listing} />

        {listing.eventSuccessSummary ? (
          <ListingEventSuccessSection summary={listing.eventSuccessSummary} />
        ) : null}

        <section className="listing-section" id="fit" aria-labelledby="listing-fit-title">
          <div className="section-heading" data-reveal>
            <span className="ui-label">{isAppCreated ? "Page format" : "Catch fit"}</span>
            <h2 id="listing-fit-title">
              {isAppCreated ?
                "What the app-created profile needs to emphasize." :
                "Why this category belongs in the first test."}
            </h2>
          </div>
          <div className="listing-grid listing-grid--fit">
            {listing.fitNotes.map((note) => (
              <article className="listing-card" data-reveal key={note}>
                <p>{note}</p>
              </article>
            ))}
          </div>
        </section>

        {!isAppCreated ? (
          <>
            <ListingSourcesSection listing={listing} />
            <section className="claim-band" aria-labelledby="listing-missing-title">
              <div data-reveal>
                <span className="ui-label">Before public indexing</span>
                <h2 id="listing-missing-title">Missing evidence</h2>
                <p>
                  This is the pressure mechanic from the prototype: visitors can
                  see what is known, what is missing, and why a verified Catch
                  profile earns stronger placement.
                </p>
              </div>
              <div className="claim-band__grid">
                <ul className="missing-list" data-reveal>
                  {listing.missingEvidence.map((item) => (
                    <li key={item}>{item}</li>
                  ))}
                </ul>
                <div className="claim-band__rail">
                  <ClaimUnlocksCard listing={listing} />
                  <ClaimListingPanel listing={listing} />
                </div>
              </div>
            </section>
            <RecommendedOrganizersSection current={listing} />
          </>
        ) : null}
      </main>

      <SiteFooter
        brandHref="/"
        body="Claimable profiles for hosts who run social events people actually show up for."
        links={[
          {href: "/host/", label: "For hosts"},
          {href: "#profile", label: "Profile"},
          {href: "#sources", label: "Sources"},
          {href: claimHref, label: "Claim"},
        ]}
      />
    </>
  );
}

function ListingDiagnosticsPanel({listing}: {listing: HostListing}) {
  const verified = isVerifiedListing(listing);
  const strength = listingProfileStrength(listing);
  const diagnostics = verified
    ? [
        {ok: true, label: "Ownership and source model verified"},
        {ok: true, label: "Catch events attached to profile"},
        {ok: (listing.metrics?.reviewCount ?? 0) > 0, label: "Review signal visible"},
        {ok: Boolean(listing.eventSuccessSummary), label: "Aggregate host report available"},
      ]
    : [
        {ok: true, label: "Public facts collected from sources"},
        {ok: false, label: "Ownership not verified"},
        {ok: false, label: "No Catch events published"},
        {ok: false, label: "No verified attendee reviews"},
      ];

  return (
    <div className="listing-diagnostics">
      <div className="listing-diagnostics__head">
        <span className="ui-label">Profile strength</span>
        <strong>{strength}%</strong>
      </div>
      <ProfileStrength value={strength} />
      <ul>
        {diagnostics.map((item) => (
          <li className={item.ok ? "is-ok" : "is-missing"} key={item.label}>
            <span aria-hidden="true">{item.ok ? "✓" : "!"}</span>
            {item.label}
          </li>
        ))}
      </ul>
    </div>
  );
}

function ClaimUnlocksCard({listing}: {listing: HostListing}) {
  const claimHref = claimHrefForListing(listing);
  return (
    <aside className="claim-unlocks" data-reveal>
      <span className="ui-label">Claiming unlocks</span>
      <h3>What {listing.name} cannot show yet.</h3>
      <ul>
        {claimUnlocks.map((item) => (
          <li key={item}>{item}</li>
        ))}
      </ul>
      <ButtonLink
        href={claimHref}
        onClick={() => {
          trackCtaClick("claim_unlocks_panel", claimHref);
          trackOrganizerAnalytics(listing, "claimClick", "claim_unlocks_panel");
        }}
      >
        Claim this listing
      </ButtonLink>
    </aside>
  );
}

function RecommendedOrganizersSection({current}: {current: HostListing}) {
  const recommended = hostListings
    .filter((listing) => listing.id !== current.id && isVerifiedListing(listing))
    .slice(0, 3);
  if (!recommended.length) return null;

  return (
    <section className="listing-section recommended-organizers" aria-labelledby="recommended-organizers-title">
      <div className="section-heading" data-reveal>
        <span className="ui-label">While you are here</span>
        <h2 id="recommended-organizers-title">Verified organizers nearby in the product loop.</h2>
        <p>
          Unclaimed pages keep the source ledger visible, but verified profiles
          can show owner-managed activity, reviews, and event outcomes.
        </p>
      </div>
      <div className="featured-organizers__grid">
        {recommended.map((listing) => (
          <OrganizerMiniCard listing={listing} key={listing.id} />
        ))}
      </div>
    </section>
  );
}

function ListingCatchEventsSection({listing}: {listing: HostListing}) {
  const events = listing.catchEvents ?? [];
  const eventCards = events.map((event) => eventActionCardForListing(listing, event));
  return (
    <section
      className="listing-section listing-section--events"
      id="events"
      aria-labelledby="listing-catch-events-title"
    >
      <div className="section-heading" data-reveal>
        <span className="ui-label">Catch events</span>
        <h2 id="listing-catch-events-title">Events created inside Catch.</h2>
        <p>
          App-created clubs should show the actual event pipeline: what is
          coming up, what filled, and what happened after people showed up.
        </p>
      </div>
      <div className="listing-catch-event-grid">
        {eventCards.map((event) => (
          <EventActionCard event={event} key={event.id} />
        ))}
      </div>
      <div className="listing-event-download" data-reveal>
        <div>
          <span className="ui-label">Member app</span>
          <h3>Book, check in, and review from Catch.</h3>
          <p>
            Public pages expose the event record. The app handles booking,
            waitlist movement, attendance, catches, and verified reviews.
          </p>
        </div>
        <AppDownloadCtas
          placement={`listing-events-${listing.slug}`}
          className="app-download-ctas--compact"
        />
      </div>
    </section>
  );
}

function ListingExternalEventsSection({
  anchorId,
  listing,
}: {
  anchorId: string;
  listing: HostListing;
}) {
  const events = listing.externalEvents ?? [];
  const eventCards = events.map((event) =>
    externalEventActionCardForListing(listing, event)
  );
  return (
    <section
      className="listing-section listing-section--events"
      id={anchorId}
      aria-labelledby="listing-external-events-title"
    >
      <div className="section-heading" data-reveal>
        <span className="ui-label">External events</span>
        <h2 id="listing-external-events-title">Source-attributed events from public listings.</h2>
        <p>
          These events come from approved intake sources and remain read-only:
          Catch does not run booking, payment, reservations, waitlists, or
          attendance for them.
        </p>
      </div>
      <div className="listing-catch-event-grid">
        {eventCards.map((event) => (
          <EventActionCard event={event} key={event.id} />
        ))}
      </div>
    </section>
  );
}

function ListingEventSuccessSection({
  summary,
}: {
  summary: HostListingEventSuccessSummary;
}) {
  const metrics = [
    {label: "Booked", value: summary.bookedCount},
    {label: "Checked in", value: summary.checkedInCount},
    {label: "Catches sent", value: summary.catchSentCount},
    {label: "Mutual matches", value: summary.mutualMatchCount},
    {label: "Chats started", value: summary.chatStartedCount},
    {label: "Safety reports", value: summary.safetyIncidentCount},
  ];
  return (
    <section
      className="listing-section listing-section--success"
      id="event-success"
      aria-labelledby="event-success-title"
    >
      <div className="section-heading" data-reveal>
        <span className="ui-label">Event Success</span>
        <h2 id="event-success-title">The claimed profile can show what Catch actually operated.</h2>
        <p>
          These are aggregate, host-safe outcomes from a completed Catch event.
          This is the kind of proof an app-created club can show that a scraped
          unclaimed listing cannot.
        </p>
      </div>
      <div className="listing-success-grid" data-reveal>
        {metrics.map((metric) => (
          <div key={metric.label}>
            <strong>{metric.value}</strong>
            <span>{metric.label}</span>
          </div>
        ))}
      </div>
    </section>
  );
}

function ListingSourcesSection({listing}: {listing: HostListing}) {
  return (
    <section className="listing-section listing-section--split" id="sources">
      <div data-reveal>
        <span className="ui-label">Source ledger</span>
        <h2>Evidence before indexing.</h2>
        <p>
          Thin pages should stay out of search until identity, cadence, and
          owner-safe details are verified.
        </p>
      </div>

      <div className="listing-ledger" data-reveal>
        {listing.sources.map((source) => (
          <article key={`${source.type}-${source.label}`}>
            <div>
              <strong>{source.label}</strong>
              <span>{source.confidence} confidence</span>
            </div>
            <p>{source.detail}</p>
            {source.href ? (
              <a
                className="source-link"
                href={source.href}
                target="_blank"
                rel="noreferrer"
                onClick={() => trackOrganizerAnalytics(
                  listing,
                  source.type === "socialProfile" ? "contactClick" : "outboundClick",
                  `source_${source.type}`
                )}
              >
                Open source
              </a>
            ) : null}
          </article>
        ))}
      </div>
    </section>
  );
}

function ListingReviewsSection({listing}: {listing: HostListing}) {
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
    <section
      className="listing-section listing-section--reviews"
      id="reviews"
      aria-labelledby="listing-reviews-title"
    >
      <div className="section-heading" data-reveal>
        <span className="ui-label">Reviews</span>
        <h2 id="listing-reviews-title">Public reviews for {listing.name}.</h2>
        <p>
          Verified reviews come from logged-in Catch guests after attended
          events. Reviews submitted on this public page are unverified and can
          be anonymous.
        </p>
      </div>

      <div className="listing-review-summary" data-reveal>
        <div>
          <span className="ui-label">Rating</span>
          <strong>
            {displayReviewCount ? displayRating.toFixed(1) : "No reviews yet"}
          </strong>
        </div>
        <div>
          <span className="ui-label">Count</span>
          <strong>{displayReviewCount}</strong>
        </div>
        <div>
          <span className="ui-label">Verified</span>
          <strong>{verifiedCount}</strong>
        </div>
        <ButtonLink
          variant="ghost"
          href={`#${reviewFormId}`}
          onClick={() => trackCtaClick("listing_review_intent", `#${reviewFormId}`)}
        >
          Add review
        </ButtonLink>
      </div>

      <div className="listing-review-workspace">
        <div>
          {reviews.length ? (
            <div className="listing-review-lanes">
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
            </div>
          ) : (
            <div className="listing-review-empty" data-reveal>
              <div>
                <span className="ui-label">First review</span>
                <h3>No public reviews for {listing.name} yet.</h3>
                <p>
                  Add the first public review here. If the organizer claims this
                  page, they can respond from the verified host account.
                </p>
              </div>
            </div>
          )}
          <OwnerResponsePrompt
            title={isAppCreated ? "Owner replies stay attached to the source." : "Claiming unlocks owner replies."}
            body={isAppCreated ?
              "Catch separates attendee proof, public web feedback, and host replies so responses do not blur the review source." :
              "Public reviews can arrive before the organizer owns the page. Catch keeps them unverified until a claim is approved."}
            stats={ownerPromptStats}
            ctaHref={isAppCreated ? undefined : claimHrefForListing(listing)}
            ctaLabel={isAppCreated ? undefined : "Claim to respond"}
          />
        </div>

        <form
          className="listing-review-form"
          data-reveal
          id={reviewFormId}
          onSubmit={submitReview}
        >
          <div>
            <span className="ui-label">Add review</span>
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
          <CheckboxField
            className="listing-review-checkbox"
            checked={isAnonymous}
            onChange={(event) => setIsAnonymous(event.target.checked)}
          >
            Post anonymously
          </CheckboxField>
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
        </form>
      </div>
    </section>
  );
}

function ClaimListingPanel({listing}: {listing: HostListing}) {
  const {
    authReady,
    handleSignIn,
    handleSignOut,
    handleSubmit,
    isConfigured,
    isSigningIn,
    isSubmitting,
    notConfiguredReason,
    status,
    user,
  } = useListingClaimController(listing);

  if (!isConfigured) {
    return (
      <div className="claim-request-panel" id="claim" data-reveal>
        <div>
          <span className="ui-label">Claim this listing</span>
          <h3>Owner review is not enabled for this listing.</h3>
          <p>
            {notConfiguredReason} Use the host application while this public
            claim flow is being connected.
          </p>
        </div>
        <ButtonLink
          href="/host/#founding-hosts"
          onClick={() => trackCtaClick("listing_claim_fallback", "/host/#founding-hosts")}
        >
          Apply as host
        </ButtonLink>
      </div>
    );
  }

  return (
    <div className="claim-request-panel" id="claim" data-reveal>
      <div className="claim-request-panel__heading">
        <span className="ui-label">Claim this listing</span>
        <h3>Request ownership for {listing.name}</h3>
        <p>
          Approved claims attach this profile to a Catch host account before
          owner tools or responses are unlocked.
        </p>
      </div>

      <AuthStatusRow
        action={
          user ? (
            <Button
              variant="ghost"
              onClick={() => void handleSignOut()}
              type="button"
            >
              Sign out
            </Button>
          ) : (
            <Button
              disabled={!authReady || isSigningIn}
              onClick={() => void handleSignIn()}
              type="button"
            >
              {isSigningIn ? "Signing in..." : "Sign in"}
            </Button>
          )
        }
      >
        {user ?
          `Signed in as ${user.displayName || user.email || "Catch user"}` :
          authReady ?
            "Sign in to request ownership." :
            "Checking sign-in status."}
      </AuthStatusRow>

      <form className="claim-request-form" onSubmit={handleSubmit}>
        <TextField
          id={`claim-${listing.id}-requester-name`}
          label="Your name"
          name="requesterName"
          autoComplete="name"
          defaultValue={user?.displayName ?? ""}
          required
        />
        <SelectField
          id={`claim-${listing.id}-requester-role`}
          label="Role"
          name="requesterRole"
          defaultValue="owner"
          required
        >
          {claimRoleOptions.map((option) => (
            <option value={option.value} key={option.value}>
              {option.label}
            </option>
          ))}
        </SelectField>
        <TextField
          id={`claim-${listing.id}-business-email`}
          label="Business email"
          name="businessEmail"
          type="email"
          autoComplete="email"
          defaultValue={user?.email ?? ""}
        />
        <TextField
          id={`claim-${listing.id}-business-phone`}
          label="Business phone"
          name="businessPhone"
          type="tel"
          autoComplete="tel"
        />
        <TextAreaField
          id={`claim-${listing.id}-proof-urls`}
          label="Proof links"
          name="proofUrls"
          rows={3}
          placeholder="Official website, Instagram, Luma, Linktree, or event page"
          span
        />
        <TextAreaField
          id={`claim-${listing.id}-message`}
          label="Note for review"
          name="message"
          rows={3}
          maxLength={1000}
          placeholder="Anything Catch should know before approving ownership"
          span
        />
        <Button disabled={!user || isSubmitting} type="submit">
          {isSubmitting ? "Submitting..." : "Request claim"}
        </Button>
        <FormStatus status={status} />
      </form>
    </div>
  );
}
