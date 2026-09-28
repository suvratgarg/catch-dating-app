import hostListingsJson from "../../generated/hostListings.json";
import type {HostListing} from "./types";

// Generated exports contain organizer/external evidence only. Also discard
// stale Catch rows when an older build input is accidentally supplied.
export const hostListings: HostListing[] = (hostListingsJson as HostListing[])
  .map((listing) => ({...listing, catchEvents: []}));
