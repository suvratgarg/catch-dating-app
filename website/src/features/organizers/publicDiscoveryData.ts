import {hostListings} from "./data";
import {
  buildPublicEventSummaries,
  buildPublicSearchSuggestions,
} from "./publicDiscovery";

export const publicEventSummaries = buildPublicEventSummaries(hostListings);
export const publicSearchSuggestions = buildPublicSearchSuggestions(
  hostListings,
  publicEventSummaries
);
