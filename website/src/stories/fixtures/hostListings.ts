import hostListingsJson from "../../generated/hostListings.demo.json";
import type {HostListing} from "../../features/organizers/types";

export const hostListings = hostListingsJson as HostListing[];
