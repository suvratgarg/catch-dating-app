import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import {renderHook, waitFor} from "@testing-library/react";
import type {PropsWithChildren} from "react";
import {beforeEach, describe, expect, it, vi} from "vitest";
import {
  sampleEventDetails,
  sampleExternalEventRows,
} from "../../../shared/api/sampleData";
import type {AdminEventListRow} from "../../../shared/types/adminTypes";
import {
  buildEventListPayload,
  buildExternalEventListPayload,
  filterEventRows,
  filterExternalEventRows,
  useEventPublishingController,
} from "./useEventPublishingController";

const repository = vi.hoisted(() => ({
  listExternalEventProfiles: vi.fn(),
  listEventProfiles: vi.fn(),
  loadEventProfile: vi.fn(),
  loadEventSupplyReadiness: vi.fn(),
  publishExternalEventProfile: vi.fn(),
  saveEventProfile: vi.fn(),
}));

vi.mock("../api/eventPublishingRepository", () => repository);

function createWrapper() {
  const queryClient = new QueryClient({defaultOptions: {queries: {retry: false}}});
  return function Wrapper({children}: PropsWithChildren) {
    return <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>;
  };
}

describe("useEventPublishingController", () => {
  beforeEach(() => {
    Object.values(repository).forEach((mock) => mock.mockReset());
    repository.listEventProfiles.mockResolvedValue({generatedAt: null, rows: []});
    repository.listExternalEventProfiles.mockResolvedValue({generatedAt: null, rows: []});
    repository.loadEventSupplyReadiness.mockResolvedValue(null);
  });

  it("loads only the active directory boundary without eagerly loading detail", async () => {
    const {result} = renderHook(
      () => useEventPublishingController({onError: vi.fn(), onNotice: vi.fn()}),
      {wrapper: createWrapper()}
    );

    await waitFor(() => {
      expect(result.current.isListLoading).toBe(false);
    });
    expect(repository.listEventProfiles).toHaveBeenCalledWith(
      buildEventListPayload("launchCities", "")
    );
    expect(repository.listExternalEventProfiles).not.toHaveBeenCalled();
    expect(repository.loadEventSupplyReadiness).not.toHaveBeenCalled();
    expect(repository.loadEventProfile).not.toHaveBeenCalled();
    expect(result.current.view).toBe("list");
  });

  it("loads only the selected non-directory workspace", async () => {
    const external = renderHook(
      () => useEventPublishingController({
        activeWorkspace: "external",
        onError: vi.fn(),
        onNotice: vi.fn(),
      }),
      {wrapper: createWrapper()}
    );

    await waitFor(() => {
      expect(repository.listExternalEventProfiles).toHaveBeenCalled();
    });
    expect(repository.listEventProfiles).not.toHaveBeenCalled();
    expect(repository.loadEventSupplyReadiness).not.toHaveBeenCalled();
    expect(external.result.current.view).toBe("external");

    repository.listExternalEventProfiles.mockClear();
    const readiness = renderHook(
      () => useEventPublishingController({
        activeWorkspace: "readiness",
        onError: vi.fn(),
        onNotice: vi.fn(),
      }),
      {wrapper: createWrapper()}
    );
    await waitFor(() => {
      expect(repository.loadEventSupplyReadiness).toHaveBeenCalled();
    });
    expect(repository.listExternalEventProfiles).not.toHaveBeenCalled();
    expect(readiness.result.current.view).toBe("readiness");
  });

  it("loads a route-selected event even when the directory query is disabled", async () => {
    const event = sampleEventDetails["mumbai-padel-mixer-1"];
    const onError = vi.fn();
    repository.loadEventProfile.mockResolvedValue({event});
    const {result} = renderHook(
      () => useEventPublishingController({
        onError,
        onNotice: vi.fn(),
        selectedEventId: event.eventId,
      }),
      {wrapper: createWrapper()}
    );

    await waitFor(() => expect(result.current.event?.eventId).toBe(event.eventId));
    expect(repository.listEventProfiles).not.toHaveBeenCalled();
    expect(repository.loadEventProfile).toHaveBeenCalledWith({eventId: event.eventId});
    expect(result.current.view).toBe("detail");
  });

  it("normalizes query and filter payloads", () => {
    expect(buildEventListPayload("cancelled", "  mixer  ")).toMatchObject({
      limit: 100,
      query: "mixer",
      status: "cancelled",
    });
    expect(buildExternalEventListPayload("public", "  run  ")).toMatchObject({
      limit: 100,
      publicationStatus: "public",
      query: "run",
    });
  });

  it("applies time, capacity, launch-market, search, and review filters", () => {
    const base: AdminEventListRow = {
      eventId: "event-1",
      clubId: "club-1",
      organizerName: "Sunday Club",
      title: "Sunday Table",
      activityKind: "singlesMixer",
      activityLabel: "Singles mixer",
      startTime: "2026-07-02T18:00:00.000Z",
      citySlug: "in-mp-indore",
      meetingPoint: "Indore",
      status: "active",
      availability: "available",
      bookedCount: 8,
      capacityLimit: 8,
      priceInPaise: 120000,
      currency: "INR",
      searchIndexStatus: "indexed",
    };
    const rows = [
      base,
      {...base, eventId: "past", startTime: "2026-06-01T18:00:00.000Z"},
      {...base, eventId: "search", searchIndexStatus: "missing" as const},
    ];
    expect(filterEventRows(rows, "upcoming", "2026-07-01T00:00:00.000Z"))
      .toEqual([base, rows[2]]);
    expect(filterEventRows(rows, "full", "2026-07-01T00:00:00.000Z"))
      .toEqual([base, rows[2]]);
    expect(filterEventRows(rows, "searchIssues", "2026-07-01T00:00:00.000Z"))
      .toEqual([rows[2]]);

    expect(filterExternalEventRows(sampleExternalEventRows, "reviewOpen", "2026-06-01T00:00:00.000Z"))
      .toEqual(expect.arrayContaining([
        expect.objectContaining({publicationStatus: "draft"}),
      ]));
  });
});
