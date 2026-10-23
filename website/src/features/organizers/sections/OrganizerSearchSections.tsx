import {CatchField} from "@catch/web-ui";
import {organiserDirectoryCopy as copy} from "@content/organiserDirectory";
import {interpolateContent as fill} from "@content/interpolate";
import {websiteCopy} from "@content/generated";
import {websiteTemplates} from "@content/templates";
import {useEffect} from "react";
import {ArrowRight, MapPin, Search, Users} from "lucide-react";
import {BadgeRow, Button, DirectoryClaimPressureCopy, DirectoryClaimPressureCta, DirectoryClaimPressureList, DirectoryClaimPressureStats, ListingFormatRow, OrganizerEventHighlights, OrganizerResultCardBody, OrganizerResultCardFooter, OrganizerResultCardShell, OrganizerResultCardTopline, OrganizerSearchSection, PlainLink, SearchFormShell, TextActionButton, ToggleChipButton, UiLabel} from "../../../shared/ui/primitives";
import {ConsumerEmpty} from "../../../shared/ui/primitives/consumerHome";
import {DirectoryIntro, DirectoryFilters, DirectoryMoreFilters, DirectoryResults, DirectoryResultsGrid, DirectoryResultsHeading, DirectoryTrust} from "../../../shared/ui/primitives/organiserDirectory";
import {trackOrganizerSearchAppearance} from "../analytics";
import {ActivityMark, StatusBadge} from "../OrganizerIdentity";
import {activityForListing, eventHighlightsForListing} from "../publicDiscovery";
import {organizerPolicyForListing} from "../organizerPolicy";
import {claimHrefForListing} from "../routing";
import {nextFutureCatchEvent, type OrganizerSort, type OrganizerStatusFilter} from "../selectors";
import type {HostListing} from "../types";
import type {OrganizerDirectoryController} from "../useOrganizerDirectoryController";

export function OrganizerSearchHeroSection({controller: c}: {controller: OrganizerDirectoryController}) {
  const filtered = c.query || c.cityFilter !== "all" || c.formatFilter !== "all" || c.upcomingOnly || c.statusFilter !== "all" || c.minRating || c.sort !== "relevance";
  return <DirectoryIntro aria-labelledby="organizer-search-title">
    <h1 id="organizer-search-title">{copy.title}</h1><p>{copy.body}</p>
    <SearchFormShell variant="organizer" role="search" onSubmit={c.handleSearch}>
      <CatchField
        recipe="input"
        id="organizer-search-query"
        title={copy.search}
        name="q"
        value={c.query}
        maxLength={120}
        onChanged={(value) => c.setQuery(value)}
        inputHint={copy.placeholder}
      />
      <Button type="submit"><Search size={18} aria-hidden="true" />{copy.searchAction}</Button>
    </SearchFormShell>
    <DirectoryFilters>
      <CatchField recipe="select" id="organizer-city-filter" title={copy.city} values={["all", ...c.cityOptions]}
        itemLabelBuilder={city => city === "all" ? copy.allCities : city} value={c.cityFilter}
        onChanged={city => c.setCityFilter(city ?? "all")} />
      <CatchField recipe="select" id="organizer-format-filter" title={copy.format} values={["all", ...c.formatOptions]}
        itemLabelBuilder={format => format === "all" ? copy.allFormats : format} value={c.formatFilter}
        onChanged={format => c.setFormatFilter(format ?? "all")} />
      <ToggleChipButton selected={c.upcomingOnly} onClick={() => c.setUpcomingOnly(value => !value)}>{copy.upcoming}</ToggleChipButton>
      {filtered ? <TextActionButton onClick={c.clearFilters}>{copy.clear}</TextActionButton> : null}
    </DirectoryFilters>
    <DirectoryMoreFilters open={c.statusFilter !== "all" || c.minRating > 0 || c.sort !== "relevance" || undefined}>
      <summary>{copy.more}</summary><DirectoryFilters>
        <CatchField recipe="select" id="organizer-status-filter" title={copy.status}
          values={["all", "verified", "claimed", "unclaimed"] satisfies OrganizerStatusFilter[]}
          itemLabelBuilder={status => ({all: copy.allStatuses, verified: copy.verified, claimed: copy.claimed,
            unclaimed: copy.unclaimed})[status]}
          value={c.statusFilter} onChanged={status => c.setStatusFilter(status ?? "all")} />
        <CatchField recipe="select" id="organizer-rating-filter" title={copy.rating} values={[0, 4, 4.5]}
          itemLabelBuilder={rating => rating === 0 ? copy.allRatings : `${rating.toFixed(1)}+`}
          value={c.minRating} onChanged={rating => c.setMinRating(rating ?? 0)} />
        <CatchField recipe="select" id="organizer-sort" title={copy.sort}
          values={["relevance", "reviews", "rating", "upcoming", "confidence"] satisfies OrganizerSort[]}
          itemLabelBuilder={sort => ({relevance: copy.recommended, reviews: copy.reviews, rating: copy.highestRating,
            upcoming: copy.upcomingSort, confidence: copy.confidence})[sort]}
          value={c.sort} onChanged={sort => c.setSort(sort ?? "relevance")} />
      </DirectoryFilters>
    </DirectoryMoreFilters>
  </DirectoryIntro>;
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

export function OrganizerResultsSection({appearanceContext, clearFilters, queryTerms, results, phase = "ready"}: {
  appearanceContext: string; clearFilters: () => void; queryTerms: string[]; results: HostListing[]; phase?: "ready" | "loading" | "unavailable";
}) {
  return <DirectoryResults aria-labelledby="directory-results-title">
    <DirectoryResultsHeading><h2 id="directory-results-title">{copy.results}</h2><p role="status" aria-live="polite">{phase === "ready" ? results.length === 1 ? copy.one : fill(copy.count,{count:results.length}) : phase === "loading" ? copy.loading : copy.unavailable}</p></DirectoryResultsHeading>
    {phase !== "ready" ? <ConsumerEmpty><Users size={32} aria-hidden="true" /><h3>{phase === "loading" ? copy.loading : copy.unavailable}</h3>{phase === "unavailable" ? <><p>{copy.unavailableBody}</p><Button onClick={() => window.location.reload()}>{copy.retry}</Button></> : null}</ConsumerEmpty> : results.length ? <DirectoryResultsGrid>{results.map(listing => <OrganizerResultCard appearanceContext={appearanceContext} listing={listing} key={listing.id} queryTerms={queryTerms} />)}</DirectoryResultsGrid> : <ConsumerEmpty><Users size={32} aria-hidden="true" /><h3>{copy.empty}</h3><p>{copy.emptyBody}</p><Button onClick={clearFilters}>{copy.reset}</Button></ConsumerEmpty>}
    <DirectoryTrust><p>{copy.trust}</p><p>{copy.experience}</p><PlainLink href="/explore/">{copy.events}<ArrowRight size={16} aria-hidden="true" /></PlainLink></DirectoryTrust>
  </DirectoryResults>;
}

function OrganizerResultCard({appearanceContext,listing,queryTerms}: {appearanceContext:string;listing:HostListing;queryTerms:string[]}) {
  const policy = organizerPolicyForListing(listing);
  const rating = policy.canReadPublicReviews ? listing.metrics?.rating : undefined;
  const reviewCount = policy.canReadPublicReviews ? listing.metrics?.reviewCount : undefined;
  const activity = activityForListing(listing);
  const eventHighlights = eventHighlightsForListing(listing,queryTerms);
  const nextEvent = nextFutureCatchEvent(listing);
  useEffect(() => {trackOrganizerSearchAppearance(listing,appearanceContext);},[appearanceContext,listing]);
  return <OrganizerResultCardShell activityToken={activity.token}>
    <PlainLink href={listing.path}>
      <ActivityMark listing={listing} size="lg" />
      <OrganizerResultCardBody>
        <OrganizerResultCardTopline><span><MapPin size={14} aria-hidden="true" />{listing.city}</span><StatusBadge listing={listing} compact /></OrganizerResultCardTopline>
        <h3>{listing.name}</h3><p>{listing.description}</p>
        <ListingFormatRow items={listing.formats.slice(0,4)} />
        {rating && reviewCount ? <BadgeRow items={[{label:websiteTemplates.ratingLabel(rating)},{label:websiteTemplates.reviewCountLabel(reviewCount)}]} /> : null}
        <p>{nextEvent ? <><strong>{copy.next}</strong><br />{nextEvent.title}</> : copy.noEvents}</p>
        {!nextEvent && eventHighlights.length ? <OrganizerEventHighlights ariaLabel={`${listing.name} event evidence`} items={eventHighlights.slice(0,2)} /> : null}
        <OrganizerResultCardFooter><span>{copy.profile}</span><ArrowRight size={18} aria-hidden="true" /></OrganizerResultCardFooter>
      </OrganizerResultCardBody>
    </PlainLink>
  </OrganizerResultCardShell>;
}
