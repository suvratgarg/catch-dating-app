import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import {act, renderHook, waitFor} from "@testing-library/react";
import type {PropsWithChildren} from "react";
import {beforeEach, describe, expect, it, vi} from "vitest";

const createMarketingEventId = vi.hoisted(() => vi.fn());
const trackMarketingEvent = vi.hoisted(() => vi.fn());
const waitlistAnalyticsPayload = vi.hoisted(() => vi.fn());

vi.mock("../../analytics", () => ({
  createMarketingEventId,
  trackMarketingEvent,
  waitlistAnalyticsPayload,
}));

import {useWaitlistFormController} from "./useWaitlistFormController";

function wrapper() {
  const client = new QueryClient({defaultOptions: {mutations: {retry: false}}});
  return function Wrapper({children}: PropsWithChildren) {
    return <QueryClientProvider client={client}>{children}</QueryClientProvider>;
  };
}

function form(values: Record<string, string>) {
  const element = document.createElement("form");
  for (const [name, value] of Object.entries(values)) {
    const input = document.createElement("input");
    input.name = name;
    input.value = value;
    element.appendChild(input);
  }
  return element;
}

describe("useWaitlistFormController", () => {
  beforeEach(() => {
    createMarketingEventId.mockReturnValue("waitlist_event-1");
    waitlistAnalyticsPayload.mockReturnValue({attribution: null, analytics: {eventId: "waitlist_event-1"}});
  });

  it("shows required-field validation before a network request", async () => {
    const fetchMock = vi.fn();
    vi.stubGlobal("fetch", fetchMock);
    const {result} = renderHook(() => useWaitlistFormController("member"), {wrapper: wrapper()});

    await act(async () => result.current.handleSubmit({
      preventDefault: vi.fn(),
      currentTarget: form({fullName: "", email: "", city: "", role: ""}),
    } as never));

    expect(result.current.status).toEqual({
      message: "Please fill out your name, email, city, and role.",
      tone: "is-error",
    });
    expect(fetchMock).not.toHaveBeenCalled();
  });

  it("submits the normalized payload and reports success", async () => {
    const fetchMock = vi.fn().mockResolvedValue({ok: true, json: async () => ({alreadyJoined: false})});
    vi.stubGlobal("fetch", fetchMock);
    const {result} = renderHook(() => useWaitlistFormController("member"), {wrapper: wrapper()});
    const element = form({
      fullName: "  Member Name  ",
      email: " member@example.com ",
      city: "Delhi",
      role: "member",
      instagram: "",
      website: "",
    });

    await act(async () => result.current.handleSubmit({preventDefault: vi.fn(), currentTarget: element} as never));

    await waitFor(() => expect(result.current.status.tone).toBe("is-success"));
    const request = fetchMock.mock.calls[0][1];
    expect(JSON.parse(request.body)).toMatchObject({
      fullName: "Member Name",
      email: "member@example.com",
      city: "Delhi",
      role: "member",
    });
    expect(trackMarketingEvent).toHaveBeenCalledWith("waitlist_submitted", expect.objectContaining({
      event_id: "waitlist_event-1",
    }));
  });
});
