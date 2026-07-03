import {
  ActivityMark as SharedActivityMark,
  ProfileStrength as SharedProfileStrength,
  StatusBadge as SharedStatusBadge,
} from "../../shared/ui/primitives";
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
  return <SharedActivityMark listing={listing} activity={activityForListing(listing)} size={size} />;
}

export function StatusBadge({
  listing,
  compact = false,
}: {
  listing: HostListing;
  compact?: boolean;
}) {
  const isVerified = isVerifiedListing(listing);
  const isUnclaimed = listing.status.toLowerCase() === "unclaimed";
  const label = isVerified
    ? compact ? "Verified" : "Verified on Catch"
    : isUnclaimed
      ? "Unclaimed"
      : "Claimed";
  const tone = isVerified ? "verified" : isUnclaimed ? "unclaimed" : "claimed";
  return (
    <SharedStatusBadge tone={tone}>
      {label}
    </SharedStatusBadge>
  );
}

export function ProfileStrength({value}: {value: number}) {
  return <SharedProfileStrength value={value} />;
}
