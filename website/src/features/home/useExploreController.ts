import {useMemo, useState} from "react";
import {usePublicHostListings} from "../organizers/usePublicEventListingsController";
import {buildExploreDiscovery, exploreRouteStateForSearch, type ExploreFilters} from "./exploreDiscovery";
export function useExploreController(initial = exploreRouteStateForSearch(""), onFiltersChange?: (filters: ExploreFilters) => void) {
  const [localFilters, setFilters] = useState(initial);
  const filters = onFiltersChange ? initial : localFilters;
  const {listings, phase, readAt} = usePublicHostListings();
  const data = useMemo(() => buildExploreDiscovery(listings, filters, readAt ?? Date.now()), [listings, filters, readAt]);
  const update = (patch: Partial<ExploreFilters>) => {const next = {...filters,...patch}; setFilters(next); onFiltersChange?.(next);};
  const clear = () => update({category:"all", query:"", date:"any", experience:false});
  return {...data, filters, phase, update, clear};
}
