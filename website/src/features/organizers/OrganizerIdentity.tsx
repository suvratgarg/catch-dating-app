import {
  ActivityMark as SharedActivityMark,
  StatusBadge as SharedStatusBadge,
} from "../../shared/ui/primitives";
import {activityForListing} from "./publicDiscovery";
import {organizerPolicyForListing} from "./organizerPolicy";
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
  const {badge} = organizerPolicyForListing(listing);
  return (
    <SharedStatusBadge tone={badge.tone}>
      {compact ? badge.compactLabel : badge.label}
    </SharedStatusBadge>
  );
}
