import {useMemo, useState} from "react";
import {usePublicHostListings} from "../organizers/usePublicEventListingsController";
import {buildHomeDiscovery, homeDiscoveryHref, type HomeCategory} from "./homeDiscovery";

export function useConsumerHomeController(initialCity = "mumbai", initialCategory: HomeCategory = "all") {
  const [city, setCity] = useState(initialCity);
  const [category, setCategory] = useState<HomeCategory>(initialCategory);
  const {listings, phase, readAt} = usePublicHostListings();
  const data = useMemo(() => buildHomeDiscovery(listings, city, category, readAt ?? Date.now()), [listings, city, category, readAt]);
  const selectCity = (value: string) => {setCity(value); setCategory("all");};
  return {...data, phase, category, selectCity, setCategory, discoveryHref: homeDiscoveryHref(data.city.slug, category)};
}
