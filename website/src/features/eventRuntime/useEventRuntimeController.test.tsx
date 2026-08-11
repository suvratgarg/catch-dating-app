import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import {renderHook, waitFor} from "@testing-library/react";
import type {PropsWithChildren} from "react";
import {beforeEach, describe, expect, it, vi} from "vitest";

const runtime = vi.hoisted(() => ({user: null as null | {uid: string}}));
const getEventRuntimeBootstrap = vi.hoisted(() => vi.fn());
const checkInEventRuntime = vi.hoisted(() => vi.fn());
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
  fetchEventRuntimeWingmanCandidates: vi.fn(),
  getEventRuntimeBootstrap,
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
      publicRuntimeId: "runtime_123456789012345678901234",
      title: "Courtyard Social",
      startTimeMillis: 1,
      endTimeMillis: 2,
      locationName: "The Courtyard",
      runtimeTermsVersion: "event-runtime-v1",
      moduleIds: [],
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
  });
});
