import {type FormEvent, useEffect, useMemo, useState} from "react";
import {trackMarketingEvent} from "../../analytics";
import {trackOrganizerSearchAppearance} from "./analytics";
import {hostListings} from "./data";
import {
  compareListings,
  defaultOrganizerDirectoryFilters,
  hasAnyEventSignal,
  hasUpcomingCatchEvent,
  isUnclaimedListing,
  isVerifiedListing,
  organizerAppearanceContext,
  organizerDirectorySearchText,
  readOrganizerFiltersFromUrl,
  replaceOrganizerDirectoryUrl,
  type OrganizerDirectoryFilters,
  type OrganizerSort,
  type OrganizerStatusFilter,
} from "./selectors";
import type {HostListing} from "./types";

export function useOrganizerDirectoryController() {
  const cityOptions = useMemo(
    () => [...new Set(hostListings.map((listing) => listing.city))].sort(),
    []
  );
  const formatOptions = useMemo(
    () => [...new Set(hostListings.flatMap((listing) => listing.formats))].sort(),
    []
  );
  const initialFilters = useMemo(
    () => readOrganizerFiltersFromUrl(cityOptions, formatOptions),
    [cityOptions, formatOptions]
  );
  const [query, setQuery] = useState(initialFilters.query);
  const [statusFilter, setStatusFilter] =
    useState<OrganizerStatusFilter>(initialFilters.statusFilter);
  const [formatFilter, setFormatFilter] = useState(initialFilters.formatFilter);
  const [cityFilter, setCityFilter] = useState(initialFilters.cityFilter);
  const [upcomingOnly, setUpcomingOnly] = useState(initialFilters.upcomingOnly);
  const [minRating, setMinRating] = useState(initialFilters.minRating);
  const [sort, setSort] = useState<OrganizerSort>(initialFilters.sort);
  const normalizedQuery = query.trim().toLowerCase();
  const queryTerms = useMemo(
    () => normalizedQuery.split(/\s+/).filter(Boolean),
    [normalizedQuery]
  );
  const currentFilters: OrganizerDirectoryFilters = {
    query,
    statusFilter,
    formatFilter,
    cityFilter,
    upcomingOnly,
    minRating,
    sort,
  };
  const appearanceContext = organizerAppearanceContext(currentFilters);

  useEffect(() => {
    const syncFromUrl = () => {
      const next = readOrganizerFiltersFromUrl(cityOptions, formatOptions);
      setQuery(next.query);
      setStatusFilter(next.statusFilter);
      setFormatFilter(next.formatFilter);
      setCityFilter(next.cityFilter);
      setUpcomingOnly(next.upcomingOnly);
      setMinRating(next.minRating);
      setSort(next.sort);
    };
    window.addEventListener("popstate", syncFromUrl);
    return () => window.removeEventListener("popstate", syncFromUrl);
  }, [cityOptions, formatOptions]);

  useEffect(() => {
    replaceOrganizerDirectoryUrl(currentFilters);
  }, [cityFilter, formatFilter, minRating, query, sort, statusFilter, upcomingOnly]);

  const results = useMemo(() => {
    const filtered = hostListings.filter((listing) => {
      const haystack = organizerDirectorySearchText(listing);
      if (queryTerms.length && !queryTerms.every((term) => haystack.includes(term))) return false;
      if (statusFilter === "verified" && !isVerifiedListing(listing)) return false;
      if (statusFilter === "claimed" && listing.status !== "claimed") return false;
      if (statusFilter === "unclaimed" && !isUnclaimedListing(listing)) return false;
      if (formatFilter !== "all" && !listing.formats.includes(formatFilter)) return false;
      if (cityFilter !== "all" && listing.city !== cityFilter) return false;
      if (upcomingOnly && !hasUpcomingCatchEvent(listing)) return false;
      if (minRating > 0 && (listing.metrics?.rating ?? 0) < minRating) return false;
      return true;
    });
    return filtered.slice().sort((a, b) => compareListings(a, b, sort));
  }, [cityFilter, formatFilter, minRating, queryTerms, sort, statusFilter, upcomingOnly]);

  const summary = useMemo(() => {
    let verifiedCount = 0;
    let unclaimedCount = 0;
    let eventBackedCount = 0;
    const claimableListings: HostListing[] = [];
    for (const listing of hostListings) {
      if (isVerifiedListing(listing)) verifiedCount += 1;
      if (isUnclaimedListing(listing)) {
        unclaimedCount += 1;
        if (claimableListings.length < 3) claimableListings.push(listing);
      }
      if (hasAnyEventSignal(listing)) eventBackedCount += 1;
    }
    return {
      claimableListings,
      eventBackedCount,
      profileCount: hostListings.length,
      unclaimedCount,
      verifiedCount,
    };
  }, []);

  function handleSearch(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    replaceOrganizerDirectoryUrl(currentFilters);
    trackMarketingEvent("organizer_search_submitted", {
      query: normalizedQuery,
      result_count: results.length,
      city_filter: cityFilter,
      format_filter: formatFilter,
      status_filter: statusFilter,
      upcoming_only: upcomingOnly,
      min_rating: minRating,
      sort,
    });
    results.slice(0, 20).forEach((listing) =>
      trackOrganizerSearchAppearance(listing, appearanceContext)
    );
  }

  function clearFilters() {
    const next = defaultOrganizerDirectoryFilters();
    setQuery(next.query);
    setStatusFilter(next.statusFilter);
    setFormatFilter(next.formatFilter);
    setCityFilter(next.cityFilter);
    setUpcomingOnly(next.upcomingOnly);
    setMinRating(next.minRating);
    setSort(next.sort);
    replaceOrganizerDirectoryUrl(next);
    trackMarketingEvent("organizer_search_filters_cleared", {});
  }

  return {
    appearanceContext,
    cityFilter,
    cityOptions,
    clearFilters,
    currentFilters,
    formatFilter,
    formatOptions,
    handleSearch,
    minRating,
    normalizedQuery,
    query,
    queryTerms,
    results,
    setCityFilter,
    setFormatFilter,
    setMinRating,
    setQuery,
    setSort,
    setStatusFilter,
    setUpcomingOnly,
    sort,
    statusFilter,
    summary,
    upcomingOnly,
  };
}
