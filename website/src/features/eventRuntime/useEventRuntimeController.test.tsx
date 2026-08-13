import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import {act, renderHook, waitFor} from "@testing-library/react";
import type {PropsWithChildren} from "react";
import {beforeEach, describe, expect, it, vi} from "vitest";

const runtime = vi.hoisted(() => ({user: null as null | {uid: string}}));
const getEventRuntimeBootstrap = vi.hoisted(() => vi.fn());
const checkInEventRuntime = vi.hoisted(() => vi.fn());
const heartbeatEventRuntimePresence = vi.hoisted(() => vi.fn());
const createEventRuntimeAttendeeInviteLink = vi.hoisted(() => vi.fn());
const recordEventRuntimeShareIntent = vi.hoisted(() => vi.fn());
const watchEventRuntimeAuthState = vi.hoisted(() => vi.fn(
  (callback: (user: typeof runtime.user) => void) => {
    callback(runtime.user);
    return vi.fn();
  }
));
const watchEventRuntimeLiveState = vi.hoisted(() => vi.fn(async () => vi.fn()));

vi.mock("../../firebase", () => ({
  beginPublicEventPhoneVerification: vi.fn(),
  checkInEventRuntime,
  claimEventRuntimeAccess: vi.fn(),
  completeEventRuntimeFirstHello: vi.fn(),
  createEventRuntimeAttendeeInviteLink,
  fetchEventRuntimeWingmanCandidates: vi.fn(),
  getEventRuntimeBootstrap,
  heartbeatEventRuntimePresence,
  recordEventInviteLinkOpen: vi.fn(),
  recordEventRuntimeShareIntent,
  saveEventRuntimeCompatibilityAnswers: vi.fn(),
  saveEventRuntimeFeedback: vi.fn(),
  startEventRuntimeFirstHello: vi.fn(),
  submitEventRuntimeProfile: vi.fn(),
  submitEventRuntimeWingmanRequest: vi.fn(),
  watchEventRuntimeAuthState,
  watchEventRuntimeLiveState,
  withdrawEventRuntimeWingmanRequest: vi.fn(),
}));

import {useEventRuntimeController} from "./useEventRuntimeController";

function wrapper() {
  const client = new QueryClient({defaultOptions: {mutations: {retry: false}}});
  return function Wrapper({children}: PropsWithChildren) {
    return <QueryClientProvider client={client}>{children}</QueryClientProvider>;
  };
}

function bootstrap(participant: unknown = null) {
  return {
    event: {
      eventId: "event-1",
      publicRuntimeId: "runtime_123456789012345678901234",
      title: "Courtyard Social",
      startTimeMillis: 1,
      endTimeMillis: Date.now() + 3_600_000,
      locationName: "The Courtyard",
      runtimeTermsVersion: "event-runtime-v1",
      moduleIds: [],
      requiredFieldIds: ["displayName"],
      optionalFieldIds: [],
      questionnaireConfig: null,
    },
    participant,
  };
}

describe("useEventRuntimeController", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    runtime.user = null;
    getEventRuntimeBootstrap.mockResolvedValue(bootstrap());
    createEventRuntimeAttendeeInviteLink.mockResolvedValue({
      eventId: "event-1",
      inviteLinkId: "invite-1",
      inviteToken: "v2_invite-1_secret",
      label: "Attendee share",
      source: "runtime_web",
    });
    recordEventRuntimeShareIntent.mockResolvedValue({recorded: true});
    heartbeatEventRuntimePresence.mockResolvedValue({
      presenceState: "present",
      serverTimeMillis: 1,
      heartbeatIntervalSeconds: 30,
      presentWindowSeconds: 90,
      likelyDepartedAfterSeconds: 300,
    });
  });

  it("opens phone verification for an anonymous guest", async () => {
    const {result} = renderHook(
      () => useEventRuntimeController("runtime_123456789012345678901234"),
      {wrapper: wrapper()}
    );
    await waitFor(() => expect(result.current.stage).toBe("phone"));
    expect(result.current.bootstrap?.event.title).toBe("Courtyard Social");
  });

  it("opens live tools for a ready checked-in runtime identity", async () => {
    runtime.user = {uid: "guest-1"};
    getEventRuntimeBootstrap.mockResolvedValue(bootstrap({
      accessStatus: "ready",
      attendanceStatus: "checkedIn",
      eventId: "event-1",
      clubId: "club-1",
      organizerId: "club-1",
      requiredFieldIds: ["displayName"],
      completedFieldIds: ["displayName"],
      runtimeProfile: {
        displayName: "Ari",
        gender: null,
        interestedInGenders: [],
        relationshipGoal: null,
        dateOfBirthMillis: null,
      },
    }));
    const {result} = renderHook(
      () => useEventRuntimeController("runtime_123456789012345678901234"),
      {wrapper: wrapper()}
    );
    await waitFor(() => expect(result.current.stage).toBe("runtime"));
    expect(checkInEventRuntime).not.toHaveBeenCalled();
    expect(watchEventRuntimeLiveState).toHaveBeenCalled();
    await waitFor(() => expect(heartbeatEventRuntimePresence)
      .toHaveBeenCalledWith("event-1"));
  });

  it("shares a stable attendee link and records only the Catch share action", async () => {
    runtime.user = {uid: "guest-1"};
    getEventRuntimeBootstrap.mockResolvedValue(bootstrap({
      accessStatus: "ready",
      attendanceStatus: "checkedIn",
      eventId: "event-1",
      clubId: "club-1",
      organizerId: "club-1",
      requiredFieldIds: ["displayName"],
      completedFieldIds: ["displayName"],
      runtimeProfile: {
        displayName: "Ari",
        gender: null,
        interestedInGenders: [],
        relationshipGoal: null,
        dateOfBirthMillis: null,
      },
    }));
    const share = vi.fn().mockResolvedValue(undefined);
    Object.defineProperty(navigator, "share", {
      configurable: true,
      value: share,
    });
    const {result} = renderHook(
      () => useEventRuntimeController("runtime_123456789012345678901234"),
      {wrapper: wrapper()}
    );
    await waitFor(() => expect(result.current.stage).toBe("runtime"));
    await waitFor(() => expect(result.current.attendeeInviteLink).not.toBeNull());

    await act(async () => result.current.shareEvent());

    expect(createEventRuntimeAttendeeInviteLink).toHaveBeenCalledWith(
      "event-1",
      "Attendee share"
    );
    expect(share).toHaveBeenCalledWith(expect.objectContaining({
      title: "Courtyard Social",
      url: expect.stringMatching(/\/invite\/v2_invite-1_secret$/u),
    }));
    expect(recordEventRuntimeShareIntent).toHaveBeenCalledWith({
      eventId: "event-1",
      inviteLinkId: "invite-1",
      channelHint: "systemShare",
    });
  });
});
