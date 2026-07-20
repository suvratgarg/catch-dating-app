import {websiteCopy} from "@content/generated";
import {websiteTemplates} from "@content/templates";
import type {CSSProperties} from "react";
import {
  ActivityMark,
  StatusBadge,
} from "../OrganizerIdentity";
import {activityForListing} from "../publicDiscovery";
import {isVerifiedListing} from "../selectors";
import {organizerPolicyForListing} from "../organizerPolicy";
import type {HostListing} from "../types";
import {
  ActionGroup,
  BadgeRow,
  Button,
  ButtonLink,
  ListingDiagnosticList,
  ListingDiagnostics,
  ListingFormatRow,
  ListingHeroCopy,
  ListingHeroEyebrow,
  ListingHeroInner,
  ListingHeroMetrics,
  ListingHeroShareStatus,
  ListingHeroShell,
  PanelShell,
  UiLabel,
} from "../../../shared/ui/primitives";
import {trackOrganizerAnalytics} from "../analytics";
import {trackCtaClick} from "../../marketing/tracking";

export function ListingHeroSection({
  canRequestClaim,
  claimHref,
  isAppCreated,
  isSaved,
  listing,
  onSaveListing,
  onShareListing,
  shareStatus,
}: {
  canRequestClaim?: boolean;
  claimHref: string;
  isAppCreated: boolean;
  isSaved: boolean;
  listing: HostListing;
  onSaveListing: () => void;
  onShareListing: () => void;
  shareStatus: string;
}) {
  const activity = activityForListing(listing);
  const resolvedCanRequestClaim = canRequestClaim ??
    organizerPolicyForListing(listing).canRequestClaim;

  return (
    <ListingHeroShell>
      <ListingHeroInner>
        <ListingHeroCopy
          style={{"--activity": activity.token} as CSSProperties}
        >
          <ListingHeroEyebrow>
            <StatusBadge listing={listing} />
            <UiLabel>{listing.category}</UiLabel>
          </ListingHeroEyebrow>
          <h1>{listing.headline}</h1>
          <p>{listing.description}</p>
          <BadgeRow
            aria-label={websiteCopy["listingherosection_0407"]}
            items={[
              {label: listing.status},
              {label: listing.sourceConfidence.replaceAll("_", " ")},
              {label: websiteTemplates.updatedLabel(listing.lastVerifiedAt)},
            ]}
          />
          <ActionGroup variant="hero">
            {resolvedCanRequestClaim ? (
              <ButtonLink
                href={claimHref}
                onClick={() => {
                  trackCtaClick("listing_claim", claimHref);
                  trackOrganizerAnalytics(listing, "claimClick", "hero");
                }}
              >
                {listing.claim.label}
              </ButtonLink>
            ) : isAppCreated ? (
              <ButtonLink
                href={claimHref}
                onClick={() => trackCtaClick("listing_events", claimHref)}
              >
                {listing.claim.label}
              </ButtonLink>
            ) : null}
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
              onClick={onShareListing}
            >{websiteCopy["listingherosection_0418"]}</Button>
            <Button
              variant="ghost"
              type="button"
              aria-pressed={isSaved}
              onClick={onSaveListing}
            >
              {isSaved ? "Saved" : "Save"}
            </Button>
          </ActionGroup>
          <ListingHeroShareStatus>
            {shareStatus}
          </ListingHeroShareStatus>
        </ListingHeroCopy>

        <PanelShell
          variant="listing"
          as="aside"
          aria-label={websiteTemplates.listingProfileLabel(listing.name)}
          reveal
          style={{"--activity": activity.token} as CSSProperties}
        >
          <ActivityMark listing={listing} size="lg" />
          <div>
            <UiLabel>
              {isAppCreated ? "Catch organizer" : "Unclaimed profile"}
            </UiLabel>
            <h2>{listing.name}</h2>
            <p>
              {listing.host ? `Hosted by ${listing.host.name}` : `${listing.city}, ${listing.region}`}
            </p>
          </div>
          {listing.metrics ? (
            <ListingHeroMetrics
              aria-label={websiteCopy["listingherosection_0411"]}
              items={[
                {label: websiteCopy["listingherosection_0408"], value: listing.metrics.memberCount ?? 0},
                {label: websiteCopy["listingherosection_0415"], value: listing.metrics.rating?.toFixed(1) ?? "0.0"},
                {label: websiteCopy["listingherosection_0417"], value: listing.metrics.reviewCount ?? 0},
              ]}
            />
          ) : null}
          <ListingFormatRow items={listing.formats} />
          <ListingDiagnosticsPanel listing={listing} />
        </PanelShell>
      </ListingHeroInner>
    </ListingHeroShell>
  );
}

function ListingDiagnosticsPanel({listing}: {listing: HostListing}) {
  const verified = isVerifiedListing(listing);
  const diagnostics = verified
    ? [
        {ok: true, label: websiteCopy["listingherosection_0412"]},
        {ok: true, label: websiteCopy["listingherosection_0406"]},
        {ok: (listing.metrics?.reviewCount ?? 0) > 0, label: websiteCopy["listingherosection_0416"]},
        {ok: Boolean(listing.eventSuccessSummary), label: websiteCopy["listingherosection_0405"]},
      ]
    : [
        {ok: true, label: websiteCopy["listingherosection_0414"]},
        {ok: false, label: websiteCopy["listingherosection_0413"]},
        {ok: false, label: websiteCopy["listingherosection_0409"]},
        {ok: false, label: websiteCopy["listingherosection_0410"]},
      ];

  return (
    <ListingDiagnostics>
      <ListingDiagnosticList items={diagnostics} />
    </ListingDiagnostics>
  );
}
