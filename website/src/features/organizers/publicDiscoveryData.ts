import {useMemo} from "react";
import {usePublicHostListings} from "./usePublicEventListingsController";
import {activeMarket} from "@content/markets";
import {
  buildPublicEventSummaries,
  buildPublicSearchSuggestions,
} from "./publicDiscovery";

export function usePublicDiscoveryData() {
  const {listings} = usePublicHostListings();
  return useMemo(() => {
    const events = buildPublicEventSummaries([...listings], {
      now: Date.now(), cities: activeMarket.cities,
    });
    return {events, suggestions: buildPublicSearchSuggestions([...listings], events)};
  }, [listings]);
}
