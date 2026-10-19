import {organiserDirectoryCopy as copy} from "@content/organiserDirectory";
import {interpolateContent as fill} from "@content/interpolate";
import {websiteCopy} from "@content/generated";
import {websiteTemplates} from "@content/templates";
import {useEffect} from "react";
import {ArrowRight, MapPin, Search, Users} from "lucide-react";
import {BadgeRow, Button, DirectoryClaimPressureCopy, DirectoryClaimPressureCta, DirectoryClaimPressureList, DirectoryClaimPressureStats, ListingFormatRow, OrganizerEventHighlights, OrganizerResultCardBody, OrganizerResultCardFooter, OrganizerResultCardShell, OrganizerResultCardTopline, OrganizerSearchSection, PlainLink, SearchFormShell, SelectField, TextActionButton, TextField, ToggleChipButton, UiLabel} from "../../../shared/ui/primitives";
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
      <TextField id="organizer-search-query" label={copy.search} name="q" value={c.query} maxLength={120} onChange={event => c.setQuery(event.target.value)} placeholder={copy.placeholder} />
      <Button type="submit"><Search size={18} aria-hidden="true" />{copy.searchAction}</Button>
    </SearchFormShell>
    <DirectoryFilters>
      <SelectField id="organizer-city-filter" label={copy.city} value={c.cityFilter} onChange={event => c.setCityFilter(event.target.value)}><option value="all">{copy.allCities}</option>{c.cityOptions.map(city => <option key={city}>{city}</option>)}</SelectField>
      <SelectField id="organizer-format-filter" label={copy.format} value={c.formatFilter} onChange={event => c.setFormatFilter(event.target.value)}><option value="all">{copy.allFormats}</option>{c.formatOptions.map(format => <option key={format}>{format}</option>)}</SelectField>
      <ToggleChipButton selected={c.upcomingOnly} onClick={() => c.setUpcomingOnly(value => !value)}>{copy.upcoming}</ToggleChipButton>
      {filtered ? <TextActionButton onClick={c.clearFilters}>{copy.clear}</TextActionButton> : null}
    </DirectoryFilters>
    <DirectoryMoreFilters open={c.statusFilter !== "all" || c.minRating > 0 || c.sort !== "relevance" || undefined}>
      <summary>{copy.more}</summary><DirectoryFilters>
        <SelectField id="organizer-status-filter" label={copy.status} value={c.statusFilter} onChange={event => c.setStatusFilter(event.target.value as OrganizerStatusFilter)}>
          <option value="all">{copy.allStatuses}</option><option value="verified">{copy.verified}</option><option value="claimed">{copy.claimed}</option><option value="unclaimed">{copy.unclaimed}</option>
        </SelectField>
        <SelectField id="organizer-rating-filter" label={copy.rating} value={c.minRating} onChange={event => c.setMinRating(Number(event.target.value))}><option value={0}>{copy.allRatings}</option><option value={4}>4.0+</option><option value={4.5}>4.5+</option></SelectField>
        <SelectField id="organizer-sort" label={copy.sort} value={c.sort} onChange={event => c.setSort(event.target.value as OrganizerSort)}><option value="relevance">{copy.recommended}</option><option value="reviews">{copy.reviews}</option><option value="rating">{copy.highestRating}</option><option value="upcoming">{copy.upcomingSort}</option><option value="confidence">{copy.confidence}</option></SelectField>
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
