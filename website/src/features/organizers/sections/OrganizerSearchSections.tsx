import {websiteCopy} from "@content/generated";
import {websiteTemplates} from "@content/templates";
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
import {ActivityMark, StatusBadge} from "../OrganizerIdentity";
import {activityForListing, eventHighlightsForListing} from "../publicDiscovery";
import {claimHrefForListing} from "../routing";
import {
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
        eyebrow={websiteCopy["organizersearchsections_0469"]}
        headingLevel="h1"
        id="organizer-search-title"
        title={websiteCopy["organizersearchsections_0462"]}
        body={websiteCopy["organizersearchsections_0478"]}
        wide />
      <OrganizerSearchStats
        reveal
        items={[
          {label: websiteCopy["organizersearchsections_0470"], value: summary.profileCount},
          {label: websiteCopy["organizersearchsections_0487"], value: summary.verifiedCount},
          {label: websiteCopy["organizersearchsections_0458"], value: summary.unclaimedCount},
          {label: websiteCopy["organizersearchsections_0461"], value: summary.eventBackedCount},
        ]}
      />
      <SearchFormShell variant="organizer" onSubmit={handleSearch} reveal>
        <TextField
          id="organizer-search-query"
          label={websiteCopy["organizersearchsections_0477"]}
          name="q"
          value={query}
          onChange={(event) => setQuery(event.target.value)}
          placeholder={websiteCopy["organizersearchsections_0484"]}
        />
        <Button type="submit">{websiteCopy["organizersearchsections_0476"]}</Button>
      </SearchFormShell>
      <FilterRail reveal>
        <SelectField
          id="organizer-status-filter"
          label={websiteCopy["organizersearchsections_0482"]}
          name="status"
          value={statusFilter}
          onChange={(event) => setStatusFilter(event.target.value as OrganizerStatusFilter)}
        >
          <option value="all">{websiteCopy["organizersearchsections_0454"]}</option>
          <option value="verified">{websiteCopy["organizersearchsections_0488"]}</option>
          <option value="claimed">{websiteCopy["organizersearchsections_0459"]}</option>
          <option value="unclaimed">{websiteCopy["organizersearchsections_0485"]}</option>
        </SelectField>
        <SelectField
          id="organizer-city-filter"
          label={websiteCopy["organizersearchsections_0455"]}
          name="city"
          value={cityFilter}
          onChange={(event) => setCityFilter(event.target.value)}
        >
          <option value="all">{websiteCopy["organizersearchsections_0451"]}</option>
          {cityOptions.map((city) => <option key={city}>{city}</option>)}
        </SelectField>
        <SelectField
          id="organizer-format-filter"
          label={websiteCopy["organizersearchsections_0463"]}
          name="format"
          value={formatFilter}
          onChange={(event) => setFormatFilter(event.target.value)}
        >
          <option value="all">{websiteCopy["organizersearchsections_0452"]}</option>
          {formatOptions.map((format) => <option key={format}>{format}</option>)}
        </SelectField>
        <SelectField
          id="organizer-rating-filter"
          label={websiteCopy["organizersearchsections_0473"]}
          name="rating"
          value={minRating}
          onChange={(event) => setMinRating(Number(event.target.value))}
        >
          <option value={0}>{websiteCopy["organizersearchsections_0453"]}</option>
          <option value={4}>4.0+</option>
          <option value={4.5}>4.5+</option>
        </SelectField>
        <ToggleChipButton
          selected={upcomingOnly}
          onClick={() => setUpcomingOnly((current) => !current)}
        >{websiteCopy["organizersearchsections_0464"]}</ToggleChipButton>
        <SelectField
          id="organizer-sort"
          label={websiteCopy["organizersearchsections_0480"]}
          name="sort"
          value={sort}
          onChange={(event) => setSort(event.target.value as OrganizerSort)}
        >
          <option value="relevance">{websiteCopy["organizersearchsections_0474"]}</option>
          <option value="reviews">{websiteCopy["organizersearchsections_0465"]}</option>
          <option value="rating">{websiteCopy["organizersearchsections_0473"]}</option>
          <option value="upcoming">{websiteCopy["organizersearchsections_0486"]}</option>
          <option value="confidence">{websiteCopy["organizersearchsections_0481"]}</option>
        </SelectField>
      </FilterRail>
      <OrganizerResultSummary>
        <p>
          {results.length} {results.length === 1 ? "profile" : "profiles"}
          {normalizedQuery ? ` for "${query.trim()}"` : ""}
        </p>
        <TextActionButton onClick={clearFilters}>{websiteCopy["organizersearchsections_0460"]}</TextActionButton>
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
        <UiLabel>{websiteCopy["organizersearchsections_0456"]}</UiLabel>
        <h2 id="directory-claim-title">{websiteCopy["organizersearchsections_0472"]}</h2>
        <p>{websiteCopy["organizersearchsections_0479"]}</p>
        <DirectoryClaimPressureStats
          items={[
            {label: websiteCopy["organizersearchsections_0457"], value: unclaimedCount},
            {label: websiteCopy["organizersearchsections_0461"], value: eventBackedCount},
          ]}
        />
      </DirectoryClaimPressureCopy>
      <DirectoryClaimPressureList>
        {claimableListings.map((listing) => (
          <PlainLink href={claimHrefForListing(listing)} key={listing.id}>
            <ActivityMark listing={listing} size="sm" />
            <span>
              <strong>{listing.name}</strong>
              <small>
                {listing.city} · {listing.missingEvidence.length}{" "}
                {websiteCopy["organizersearchsections_0471"]}
              </small>
            </span>
            <StatusBadge listing={listing} compact />
          </PlainLink>
        ))}
        <DirectoryClaimPressureCta href="/claim/">{websiteCopy["organizersearchsections_0467"]}</DirectoryClaimPressureCta>
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
    <OrganizerSearchSection variant="results" aria-label={websiteCopy["organizersearchsections_0468"]}>
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
          <h2>{websiteCopy["organizersearchsections_0466"]}</h2>
          <p>{websiteCopy["organizersearchsections_0483"]}</p>
          <Button variant="ghost" type="button" onClick={clearFilters}>{websiteCopy["organizersearchsections_0475"]}</Button>
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
              ...(rating ? [{label: websiteTemplates.ratingLabel(rating)}] : []),
              ...(reviewCount ? [{label: websiteTemplates.reviewCountLabel(reviewCount)}] : []),
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
            <span>{isAppCreated ? "Owner-managed profile" : `${listing.missingEvidence.length} proof gaps`}</span>
          </OrganizerResultCardFooter>
        </OrganizerResultCardBody>
      </PlainLink>
    </OrganizerResultCardShell>
  );
}
