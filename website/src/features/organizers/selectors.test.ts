import {beforeEach, describe, expect, it, vi} from "vitest";
import {hostListings} from "./data";
import type {HostListingCatchEvent} from "./types";
import {
  defaultOrganizerDirectoryFilters,
  nextFutureCatchEvent,
  organizerDirectorySearchParams,
  readOrganizerFiltersFromUrl,
} from "./selectors";

describe("organizer selectors", () => {
  beforeEach(() => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date("2026-01-01T00:00:00.000Z"));
  });

  it("round-trips supported URL filters and drops defaults", () => {
    const filters = readOrganizerFiltersFromUrl(
      ["delhi-ncr", "mumbai"],
      ["Dinner", "Social run"],
      "?q=run&city=mumbai&format=Social+run&status=verified&upcoming=true&rating=4.5&sort=reviews"
    );
    expect(organizerDirectorySearchParams(filters).toString()).toBe(
      "q=run&city=mumbai&format=Social+run&status=verified&upcoming=true&rating=4.5&sort=reviews"
    );
    expect(organizerDirectorySearchParams(defaultOrganizerDirectoryFilters()).toString()).toBe("");
  });

  it("selects the nearest future event signal", () => {
    const eventTitle = hostListings[0].name;
    const listing = {
      ...hostListings[0],
      catchEvents: [{
        id: "future-event",
        title: eventTitle,
        startTime: "2026-02-01T10:00:00.000Z",
      } as HostListingCatchEvent],
    };
    expect(nextFutureCatchEvent(listing)).toEqual({title: eventTitle});
  });
});
