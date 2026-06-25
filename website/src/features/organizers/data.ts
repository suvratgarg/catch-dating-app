import hostListingsJson from "../../generated/hostListings.json";
import type {HostListing} from "./types";

export const hostListings = hostListingsJson as HostListing[];
