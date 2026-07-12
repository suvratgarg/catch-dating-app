import {hostListings} from "./data";
import {activeMarket} from "@content/markets";
import {
  buildPublicEventSummaries,
  buildPublicSearchSuggestions,
} from "./publicDiscovery";

export const publicEventSummaries = buildPublicEventSummaries(hostListings, {
  now: Date.now(),
  cities: activeMarket.cities,
});
export const publicSearchSuggestions = buildPublicSearchSuggestions(
  hostListings,
  publicEventSummaries
);
