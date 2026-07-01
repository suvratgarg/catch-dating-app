import type {CSSProperties} from "react";
import {
  ActivityMark,
  ProfileStrength,
  StatusBadge,
} from "../OrganizerIdentity";
import {activityForListing} from "../publicDiscovery";
import {isVerifiedListing, listingProfileStrength} from "../selectors";
import type {HostListing} from "../types";
import {Button, ButtonLink} from "../../../shared/ui/primitives";
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
