import {organizerDirectorySearchText} from "./selectors";
import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import {act, cleanup, renderHook, waitFor} from "@testing-library/react";
import {StrictMode, type PropsWithChildren} from "react";
import {afterEach, beforeEach, expect, it, vi} from "vitest";
const api = vi.hoisted(() => ({subscribe: vi.fn()}));
vi.mock("../../firebase", () => ({subscribePublicCatchEvents: api.subscribe}));
import {mergePublicCatchEvents, usePublicEventListingsController} from "./usePublicEventListingsController";
import {hostListings} from "./data";
import type {LivePublicCatchEvent, projectPublicCatchEventSnapshot} from "./publicCatchEventProjection";
let client: QueryClient;
type Snapshot = Parameters<typeof projectPublicCatchEventSnapshot>[0];
const listeners: {rows: (rows: Snapshot) => void; error: () => void; stop: ReturnType<typeof vi.fn>}[] = [];
const row: LivePublicCatchEvent = {organizerId: hostListings[0].id, event: {id: "live-event", role: "Hosted event", title: "Live event", summary: "", activityKind: "socialRun", timeline: "upcoming", startTime: "2090-01-01", endTime: "2090-01-02", date: "Tomorrow", location: "Park", capacityLimit: 20, bookedCount: 1, checkedInCount: 0, waitlistedCount: 0, priceLabel: "Free"}};
function wrapper({children}: PropsWithChildren) {
  return <StrictMode><QueryClientProvider client={client}>{children}</QueryClientProvider></StrictMode>;
}
beforeEach(() => {
  client = new QueryClient(); listeners.length = 0;
  api.subscribe.mockImplementation(async (rows, error) => {
    const stop = vi.fn(); listeners.push({rows, error, stop}); return stop;
  });
});
afterEach(() => {cleanup(); client.clear();});
it("removes unpublished and unavailable rows from every merged listing", async () => {
  const {result} = renderHook(() => usePublicEventListingsController(true), {wrapper});
  await waitFor(() => expect(listeners).toHaveLength(1));
  act(() => listeners.at(-1)!.rows(snapshot([row])));
  await waitFor(() => expect(result.current.listings[0].catchEvents).toHaveLength(1));
  act(() => listeners.at(-1)!.rows(snapshot([])));
  await waitFor(() => expect(result.current.listings[0].catchEvents).toEqual([]));
  act(() => listeners.at(-1)!.rows(snapshot([row])));
  await waitFor(() => expect(result.current.listings[0].catchEvents).toHaveLength(1));
  act(() => listeners.at(-1)!.error());
  await waitFor(() => expect(result.current.phase).toBe("unavailable"));
  expect(result.current.listings[0].catchEvents).toEqual([]);
});
it("ignores a retired callback and stops subscription when late setup resolves", async () => {
  let resolve!: (stop: () => void) => void;
  let oldCallback!: (rows: Snapshot) => void;
  const stop = vi.fn();
  api.subscribe.mockImplementationOnce((rows) => {
    oldCallback = rows;
    return new Promise<() => void>((done) => {resolve = done;});
  });
  const first = renderHook(() => usePublicEventListingsController(true), {wrapper});
  first.unmount();
  const next = renderHook(() => usePublicEventListingsController(true), {wrapper});
  await act(async () => {resolve(stop);});
  expect(stop).toHaveBeenCalledOnce();
  act(() => oldCallback(snapshot([row])));
  expect(next.result.current.listings[0].catchEvents).toEqual([]);
  next.unmount();
  expect(listeners[0].stop).toHaveBeenCalledOnce();
});
it("clears on leaving discovery and waits for fresh data on return", async () => {
  const {result, rerender} = renderHook(({enabled}) => usePublicEventListingsController(enabled), {wrapper, initialProps: {enabled: true}});
  await waitFor(() => expect(listeners).toHaveLength(1));
  act(() => listeners[0].rows(snapshot([row])));
  await waitFor(() => expect(result.current.phase).toBe("ready"));
  rerender({enabled: false});
  expect(result.current.listings[0].catchEvents).toEqual([]);
  rerender({enabled: true});
  expect(result.current.listings[0].catchEvents).toEqual([]);
  expect(result.current.phase).toBe("loading");
});
it("preserves external provenance and replaces stale Catch snapshots", () => {
  const source = {...hostListings[0], catchEvents: [row.event]};
  const merged = mergePublicCatchEvents([source], []);
  expect(merged[0].catchEvents).toEqual([]);
  expect(merged[0].externalEvents).toBe(source.externalEvents);
  expect(source.catchEvents).toHaveLength(1);
});

function snapshot(rows: LivePublicCatchEvent[]): Snapshot {
  return {metadata: {fromCache: false, hasPendingWrites: false}, size: rows.length,
    docs: rows.map((row) => ({id: row.event.id, data: () => ({
      organizerId: row.organizerId, name: row.event.title,
      publicationState: "published", status: "active", currency: "INR",
      startTime: {toMillis: () => 9e12}, endTime: {toMillis: () => 9e12 + 3600000},
      meetingLocation: {name: "Park"}, eventFormat: {activityKind: "socialRun"},
      capacityLimit: 20, bookedCount: 0, priceInPaise: 0,
    })}))};
}

it("invalidates search text when the same organizer loses an event", () => {
  const before = {...hostListings[0], catchEvents: [{...row.event, title: "Retired event"}]};
  expect(organizerDirectorySearchText(before)).toContain("retired event");
  expect(organizerDirectorySearchText({...before, catchEvents: []})).not.toContain("retired event");
});
