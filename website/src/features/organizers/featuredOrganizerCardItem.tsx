import type {FeaturedOrganizerCardItem} from "../../shared/ui/primitives";
import {trackCtaClick} from "../marketing/tracking";
import {activityForListing} from "./publicDiscovery";
import {listingProfileStrength} from "./selectors";
import type {HostListing} from "./types";
import {ActivityMark, ProfileStrength, StatusBadge} from "./OrganizerIdentity";

export function featuredOrganizerCardItemForListing(
  listing: HostListing
): FeaturedOrganizerCardItem {
  const activity = activityForListing(listing);
  return {
    activity: <ActivityMark listing={listing} />,
    activityColor: activity.token,
    detail: `${listing.category} · ${listing.city}`,
    href: listing.path,
    key: listing.id,
    name: listing.name,
    onClick: () => trackCtaClick("featured_organizer", listing.path),
    status: <StatusBadge listing={listing} compact />,
    strength: <ProfileStrength value={listingProfileStrength(listing)} />,
  };
}
