import type {CSSProperties} from "react";
import {
  ActivityMark,
  StatusBadge,
} from "../OrganizerIdentity";
import {activityForListing} from "../publicDiscovery";
import {isVerifiedListing} from "../selectors";
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
  claimHref,
  isAppCreated,
  isSaved,
  listing,
  onSaveListing,
  onShareListing,
  shareStatus,
}: {
  claimHref: string;
  isAppCreated: boolean;
  isSaved: boolean;
  listing: HostListing;
  onSaveListing: () => void;
  onShareListing: () => void;
  shareStatus: string;
}) {
  const activity = activityForListing(listing);

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
            aria-label="Listing status"
            items={[
              {label: listing.status},
              {label: listing.sourceConfidence.replaceAll("_", " ")},
              {label: `Updated ${listing.lastVerifiedAt}`},
            ]}
          />
          <ActionGroup variant="hero">
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
              onClick={onShareListing}
            >
              Share listing
            </Button>
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
          aria-label={`${listing.name} profile`}
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
              aria-label="Organizer metrics"
              items={[
                {label: " members", value: listing.metrics.memberCount ?? 0},
                {label: " rating", value: listing.metrics.rating?.toFixed(1) ?? "0.0"},
                {label: " reviews", value: listing.metrics.reviewCount ?? 0},
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
    <ListingDiagnostics>
      <ListingDiagnosticList items={diagnostics} />
    </ListingDiagnostics>
  );
}
