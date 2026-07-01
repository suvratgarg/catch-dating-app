import {type CSSProperties, useEffect} from "react";
import {
  Button,
  PlainLink,
  SelectField,
  TextActionButton,
  TextField,
  ToggleChipButton,
} from "../../../shared/ui/primitives";
import {trackOrganizerSearchAppearance} from "../analytics";
import {ActivityMark, ProfileStrength, StatusBadge} from "../OrganizerIdentity";
import {activityForListing, eventHighlightsForListing} from "../publicDiscovery";
import {claimHrefForListing} from "../routing";
import {
  listingProfileStrength,
  nextFutureCatchEvent,
  type OrganizerSort,
  type OrganizerStatusFilter,
} from "../selectors";
import type {HostListing} from "../types";
import type {OrganizerDirectoryController} from "../useOrganizerDirectoryController";

export function OrganizerSearchHeroSection({
  controller,
}: {
  controller: OrganizerDirectoryController;
}) {
  const {
    cityFilter,
    cityOptions,
    clearFilters,
    formatFilter,
    formatOptions,
    handleSearch,
    minRating,
    normalizedQuery,
    query,
    results,
    setCityFilter,
    setFormatFilter,
    setMinRating,
    setQuery,
    setSort,
    setStatusFilter,
    setUpcomingOnly,
    sort,
    statusFilter,
    summary,
    upcomingOnly,
  } = controller;

  return (
    <section className="organizer-search-hero" aria-labelledby="organizer-search-title">
      <div className="section-heading section-heading--wide" data-reveal>
        <span className="ui-label">Organizer search</span>
        <h1 id="organizer-search-title">Every club, host, and venue running real events.</h1>
        <p>
          Search source-backed seed listings and Catch-created clubs by name,
          city, format, reviews, upcoming events, and claim state.
        </p>
      </div>
      <div className="organizer-search-stats" data-reveal>
        <span><strong>{summary.profileCount}</strong> profiles tracked</span>
        <span><strong>{summary.verifiedCount}</strong> verified on Catch</span>
        <span><strong>{summary.unclaimedCount}</strong> claimable seed pages</span>
        <span><strong>{summary.eventBackedCount}</strong> event-backed pages</span>
      </div>
      <form className="organizer-search-form" onSubmit={handleSearch} data-reveal>
        <TextField
          id="organizer-search-query"
          label="Search organizers"
          name="q"
          value={query}
          onChange={(event) => setQuery(event.target.value)}
          placeholder="Try Sunday Table, Indore, run club, dinner"
        />
        <Button type="submit">Search</Button>
      </form>
      <div className="organizer-filter-rail" data-reveal>
        <SelectField
          id="organizer-status-filter"
          label="Status"
          name="status"
          value={statusFilter}
          onChange={(event) => setStatusFilter(event.target.value as OrganizerStatusFilter)}
        >
          <option value="all">Any status</option>
          <option value="verified">Verified on Catch</option>
          <option value="claimed">Claimed</option>
          <option value="unclaimed">Unclaimed</option>
        </SelectField>
        <SelectField
          id="organizer-city-filter"
          label="City"
          name="city"
          value={cityFilter}
          onChange={(event) => setCityFilter(event.target.value)}
        >
          <option value="all">Any city</option>
          {cityOptions.map((city) => <option key={city}>{city}</option>)}
        </SelectField>
        <SelectField
          id="organizer-format-filter"
          label="Format"
          name="format"
          value={formatFilter}
          onChange={(event) => setFormatFilter(event.target.value)}
        >
          <option value="all">Any format</option>
          {formatOptions.map((format) => <option key={format}>{format}</option>)}
        </SelectField>
        <SelectField
          id="organizer-rating-filter"
          label="Rating"
          name="rating"
          value={minRating}
          onChange={(event) => setMinRating(Number(event.target.value))}
        >
          <option value={0}>Any rating</option>
          <option value={4}>4.0+</option>
          <option value={4.5}>4.5+</option>
        </SelectField>
        <ToggleChipButton
          selected={upcomingOnly}
          onClick={() => setUpcomingOnly((current) => !current)}
        >
          Has upcoming events
        </ToggleChipButton>
        <SelectField
          id="organizer-sort"
          label="Sort"
          name="sort"
          value={sort}
          onChange={(event) => setSort(event.target.value as OrganizerSort)}
        >
          <option value="relevance">Relevance</option>
          <option value="reviews">Most reviewed</option>
          <option value="rating">Rating</option>
          <option value="upcoming">Upcoming first</option>
          <option value="confidence">Source confidence</option>
        </SelectField>
      </div>
      <div className="organizer-result-summary" data-reveal>
        <p>
          {results.length} {results.length === 1 ? "profile" : "profiles"}
          {normalizedQuery ? ` for "${query.trim()}"` : ""}
        </p>
        <TextActionButton onClick={clearFilters}>
          Clear filters
        </TextActionButton>
      </div>
    </section>
  );
}

export function DirectoryClaimPressureStrip({
  claimableListings,
  eventBackedCount,
  unclaimedCount,
}: {
  claimableListings: HostListing[];
  eventBackedCount: number;
  unclaimedCount: number;
}) {
  return (
    <section className="directory-claim-pressure" aria-labelledby="directory-claim-title">
      <div className="directory-claim-pressure__copy" data-reveal>
        <span className="ui-label">Claim pressure</span>
        <h2 id="directory-claim-title">Public pages work harder when the owner steps in.</h2>
        <p>
          Seed pages expose source evidence and proof gaps. Claimed pages can add
          official details, publish Catch events, separate verified attendee
          reviews, and respond as the host.
        </p>
        <div className="directory-claim-pressure__stats">
          <span><strong>{unclaimedCount}</strong> claimable pages</span>
          <span><strong>{eventBackedCount}</strong> event-backed pages</span>
        </div>
      </div>
      <div className="directory-claim-pressure__list" data-reveal>
        {claimableListings.map((listing) => (
          <PlainLink href={claimHrefForListing(listing)} key={listing.id}>
            <ActivityMark listing={listing} size="sm" />
            <span>
              <strong>{listing.name}</strong>
              <small>{listing.city} · {listing.missingEvidence.length} proof gaps</small>
            </span>
            <StatusBadge listing={listing} compact />
          </PlainLink>
        ))}
        <PlainLink className="directory-claim-pressure__cta" href="/claim/">
          Open claim flow
        </PlainLink>
      </div>
    </section>
  );
}

export function OrganizerResultsSection({
  appearanceContext,
  clearFilters,
  queryTerms,
  results,
}: {
  appearanceContext: string;
  clearFilters: () => void;
  queryTerms: string[];
  results: HostListing[];
}) {
  return (
    <section className="organizer-results" aria-label="Organizer results">
      {results.length ? (
        results.map((listing) => (
          <OrganizerResultCard
            appearanceContext={appearanceContext}
            listing={listing}
            key={listing.id}
            queryTerms={queryTerms}
          />
        ))
      ) : (
        <div className="empty-results" data-reveal>
          <h2>No organizer profiles match those filters.</h2>
          <p>Try a wider city, format, or status filter.</p>
          <Button variant="ghost" type="button" onClick={clearFilters}>
            Reset directory
          </Button>
        </div>
      )}
    </section>
  );
}

function OrganizerResultCard({
  appearanceContext,
  listing,
  queryTerms,
}: {
  appearanceContext: string;
  listing: HostListing;
  queryTerms: string[];
}) {
  const isAppCreated = listing.listingVariant === "appCreatedClub";
  const rating = listing.metrics?.rating;
  const reviewCount = listing.metrics?.reviewCount;
  const activity = activityForListing(listing);
  const eventHighlights = eventHighlightsForListing(listing, queryTerms);
  const nextEvent = nextFutureCatchEvent(listing);

  useEffect(() => {
    trackOrganizerSearchAppearance(listing, appearanceContext);
  }, [appearanceContext, listing]);

  return (
    <article
      className="organizer-result-card"
      style={{"--activity": activity.token} as CSSProperties}
    >
      <PlainLink href={listing.path}>
        <ActivityMark listing={listing} size="lg" />
        <div className="organizer-result-card__body">
          <div className="organizer-card-topline">
            <StatusBadge listing={listing} compact />
            <span>{listing.city}</span>
            <span>{activity.label}</span>
          </div>
          <h2>{listing.name}</h2>
          <p>{listing.description}</p>
          <div className="listing-badge-row">
            <span>{listing.category}</span>
            {rating ? <span>{rating.toFixed(1)} rating</span> : null}
            {reviewCount ? <span>{reviewCount} reviews</span> : null}
            {nextEvent ? (
              <span>{nextEvent.title}</span>
            ) : (
              <span>{isAppCreated ? "No future event" : "Cadence unverified"}</span>
            )}
          </div>
          {eventHighlights.length ? (
            <div className="organizer-event-highlights" aria-label={`${listing.name} event evidence`}>
              {eventHighlights.map((event) => (
                <span key={event.id} style={{"--activity": event.activityToken} as CSSProperties}>
                  <strong>{event.title}</strong>
                  <small>{event.kind} · {event.detail}</small>
                </span>
              ))}
            </div>
          ) : null}
          <div className="listing-format-row">
            {listing.formats.slice(0, 4).map((format) => (
              <span key={format}>{format}</span>
            ))}
          </div>
          <div className="organizer-result-card__footer">
            <ProfileStrength value={listingProfileStrength(listing)} />
            <span>{isAppCreated ? "Owner-managed profile" : `${listing.missingEvidence.length} proof gaps`}</span>
          </div>
        </div>
      </PlainLink>
    </article>
  );
}
