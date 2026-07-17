import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import {act, renderHook, waitFor} from "@testing-library/react";
import type {PropsWithChildren} from "react";
import {beforeEach, describe, expect, it, vi} from "vitest";

const createMarketingEventId = vi.hoisted(() => vi.fn());
const trackMarketingEvent = vi.hoisted(() => vi.fn());
const waitlistAnalyticsPayload = vi.hoisted(() => vi.fn());

vi.mock("../../../analytics", () => ({
  createMarketingEventId,
  trackMarketingEvent,
  waitlistAnalyticsPayload,
}));

import {useHostApplicationController} from "./useHostApplicationController";

function wrapper() {
  const client = new QueryClient({defaultOptions: {mutations: {retry: false}}});
  return function Wrapper({children}: PropsWithChildren) {
    return <QueryClientProvider client={client}>{children}</QueryClientProvider>;
  };
}

describe("useHostApplicationController", () => {
  beforeEach(() => {
    createMarketingEventId.mockReturnValue("host_lead_event-1");
    waitlistAnalyticsPayload.mockReturnValue({attribution: null, analytics: {eventId: "host_lead_event-1"}});
  });

  it("blocks navigation until the current step is complete", () => {
    const {result} = renderHook(() => useHostApplicationController(), {wrapper: wrapper()});
    act(() => result.current.goNext());
    expect(result.current.step).toBe("profile");
    expect(result.current.status).toEqual({
      message: "Add your identity, organizer name, city, and public link.",
      tone: "is-error",
    });
  });

  it("submits a complete operating packet and reports success", async () => {
    const fetchMock = vi.fn().mockResolvedValue({ok: true, json: async () => ({alreadyJoined: false})});
    vi.stubGlobal("fetch", fetchMock);
    const {result} = renderHook(() => useHostApplicationController(), {wrapper: wrapper()});

    act(() => {
      result.current.updateDraft("fullName", "A Host");
      result.current.updateDraft("email", "host@example.com");
      result.current.updateDraft("organizationName", "Sunday Club");
      result.current.updateDraft("communityLink", "https://example.com");
      result.current.updateDraft("nextEventName", "Sunday Dinner");
      result.current.updateDraft("eventLocation", "Delhi");
      result.current.updateDraft("hostGoals", "Create thoughtful introductions");
    });

    await act(async () => result.current.handleSubmit({preventDefault: vi.fn()} as never));

    await waitFor(() => expect(result.current.submitted).toBe(true));
    expect(result.current.status.tone).toBe("is-success");
    expect(JSON.parse(fetchMock.mock.calls[0][1].body)).toMatchObject({
      fullName: "A Host",
      email: "host@example.com",
      role: "host",
      hostApplication: {
        organizationName: "Sunday Club",
        nextEventName: "Sunday Dinner",
      },
    });
  });
});
