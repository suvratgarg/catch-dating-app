import {
  ActivityMark as SiteActivityMark,
  ProfileStrength as SiteProfileStrength,
  StatusBadge as SiteStatusBadge,
} from "../../components/site";
import {activityForListing} from "./publicDiscovery";
import {isVerifiedListing} from "./selectors";
import type {HostListing} from "./types";

export function ActivityMark({
  listing,
  size = "md",
}: {
  listing: HostListing;
  size?: "sm" | "md" | "lg";
}) {
  return <SiteActivityMark listing={listing} activity={activityForListing(listing)} size={size} />;
}

export function StatusBadge({
  listing,
  compact = false,
}: {
  listing: HostListing;
  compact?: boolean;
}) {
  return (
    <SiteStatusBadge
      status={listing.status}
      isVerified={isVerifiedListing(listing)}
      compact={compact}
    />
  );
}

export function ProfileStrength({value}: {value: number}) {
  return <SiteProfileStrength value={value} />;
}
