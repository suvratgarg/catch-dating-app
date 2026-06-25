import type {CSSProperties} from "react";
import {trackCtaClick} from "../marketing/tracking";
import {activityForListing} from "./publicDiscovery";
import {listingProfileStrength} from "./selectors";
import type {HostListing} from "./types";
import {ActivityMark, ProfileStrength, StatusBadge} from "./OrganizerIdentity";

export function OrganizerMiniCard({listing}: {listing: HostListing}) {
  const activity = activityForListing(listing);
  return (
    <a
      className="organizer-mini-card"
      href={listing.path}
      data-reveal
      style={{"--activity": activity.token} as CSSProperties}
      onClick={() => trackCtaClick("featured_organizer", listing.path)}
    >
      <ActivityMark listing={listing} />
      <div>
        <StatusBadge listing={listing} compact />
        <h3>{listing.name}</h3>
        <p>{listing.category} · {listing.city}</p>
      </div>
      <ProfileStrength value={listingProfileStrength(listing)} />
    </a>
  );
}
