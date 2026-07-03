import {SectionHeader} from "../../../shared/site";
import {useEffect} from "react";
import {
  BadgeRow,
  Button,
  DirectoryClaimPressureCopy,
  DirectoryClaimPressureCta,
  DirectoryClaimPressureList,
  DirectoryClaimPressureStats,
  EmptyState,
  FilterRail,
  ListingFormatRow,
  OrganizerEventHighlights,
  OrganizerResultSummary,
  OrganizerResultCardBody,
  OrganizerResultCardFooter,
  OrganizerResultCardShell,
  OrganizerResultCardTopline,
  OrganizerSearchSection,
  OrganizerSearchStats,
  PlainLink,
  SearchFormShell,
  SelectField,
  TextActionButton,
  TextField,
  ToggleChipButton,
  UiLabel,
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
    <OrganizerSearchSection variant="hero" aria-labelledby="organizer-search-title">
      <SectionHeader
        eyebrow="Organizer search"
        headingLevel="h1"
        id="organizer-search-title"
        title="Every club, host, and venue running real events."
        body="Search source-backed seed listings and Catch-created clubs by name, city, format, reviews, upcoming events, and claim state."
        wide />
      <OrganizerSearchStats
        reveal
        items={[
          {label: " profiles tracked", value: summary.profileCount},
          {label: " verified on Catch", value: summary.verifiedCount},
          {label: " claimable seed pages", value: summary.unclaimedCount},
          {label: " event-backed pages", value: summary.eventBackedCount},
        ]}
      />
      <SearchFormShell variant="organizer" onSubmit={handleSearch} reveal>
        <TextField
          id="organizer-search-query"
          label="Search organizers"
          name="q"
          value={query}
          onChange={(event) => setQuery(event.target.value)}
          placeholder="Try Sunday Table, Indore, run club, dinner"
        />
        <Button type="submit">Search</Button>
      </SearchFormShell>
      <FilterRail reveal>
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
      </FilterRail>
      <OrganizerResultSummary>
        <p>
          {results.length} {results.length === 1 ? "profile" : "profiles"}
          {normalizedQuery ? ` for "${query.trim()}"` : ""}
        </p>
        <TextActionButton onClick={clearFilters}>
          Clear filters
        </TextActionButton>
      </OrganizerResultSummary>
    </OrganizerSearchSection>
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
    <OrganizerSearchSection variant="claim-pressure" aria-labelledby="directory-claim-title">
      <DirectoryClaimPressureCopy>
        <UiLabel>Claim pressure</UiLabel>
        <h2 id="directory-claim-title">Public pages work harder when the owner steps in.</h2>
        <p>
          Seed pages expose source evidence and proof gaps. Claimed pages can add
          official details, publish Catch events, separate verified attendee
          reviews, and respond as the host.
        </p>
        <DirectoryClaimPressureStats
          items={[
            {label: " claimable pages", value: unclaimedCount},
            {label: " event-backed pages", value: eventBackedCount},
          ]}
        />
      </DirectoryClaimPressureCopy>
      <DirectoryClaimPressureList>
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
        <DirectoryClaimPressureCta href="/claim/">
          Open claim flow
        </DirectoryClaimPressureCta>
      </DirectoryClaimPressureList>
    </OrganizerSearchSection>
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
    <OrganizerSearchSection variant="results" aria-label="Organizer results">
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
        <EmptyState variant="organizer-results" reveal>
          <h2>No organizer profiles match those filters.</h2>
          <p>Try a wider city, format, or status filter.</p>
          <Button variant="ghost" type="button" onClick={clearFilters}>
            Reset directory
          </Button>
        </EmptyState>
      )}
    </OrganizerSearchSection>
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
    <OrganizerResultCardShell activityToken={activity.token}>
      <PlainLink href={listing.path}>
        <ActivityMark listing={listing} size="lg" />
        <OrganizerResultCardBody>
          <OrganizerResultCardTopline>
            <StatusBadge listing={listing} compact />
            <span>{listing.city}</span>
            <span>{activity.label}</span>
          </OrganizerResultCardTopline>
          <h2>{listing.name}</h2>
          <p>{listing.description}</p>
          <BadgeRow
            items={[
              {label: listing.category},
              ...(rating ? [{label: `${rating.toFixed(1)} rating`}] : []),
              ...(reviewCount ? [{label: `${reviewCount} reviews`}] : []),
              {
                label: nextEvent ?
                  nextEvent.title :
                  isAppCreated ? "No future event" : "Cadence unverified",
              },
            ]}
          />
          {eventHighlights.length ? (
            <OrganizerEventHighlights
              ariaLabel={`${listing.name} event evidence`}
              items={eventHighlights}
            />
          ) : null}
          <ListingFormatRow items={listing.formats.slice(0, 4)} />
          <OrganizerResultCardFooter>
            <ProfileStrength value={listingProfileStrength(listing)} />
            <span>{isAppCreated ? "Owner-managed profile" : `${listing.missingEvidence.length} proof gaps`}</span>
          </OrganizerResultCardFooter>
        </OrganizerResultCardBody>
      </PlainLink>
    </OrganizerResultCardShell>
  );
}
