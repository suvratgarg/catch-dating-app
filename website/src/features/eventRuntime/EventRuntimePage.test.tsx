import {cleanup, fireEvent, render, screen} from "@testing-library/react";
import {MemoryRouter, Route, Routes} from "react-router";
import {afterEach, beforeEach, describe, expect, it, vi} from "vitest";

const runtimeController = vi.hoisted(() => ({value: null as any}));

vi.mock("./useEventRuntimeController", () => ({
  useEventRuntimeController: () => runtimeController.value,
}));

vi.mock("@catch/web-ui", async (importOriginal) => {
  const actual = await importOriginal<typeof import("@catch/web-ui")>();
  return {
    ...actual,
    LottieAnimationControl: ({source}: {source: string}) => (
      <span data-lottie-source={source} />
    ),
  };
});

import {eventRuntimeCopy} from "../../content/eventRuntime";
import {EventRuntimePage} from "./EventRuntimePage";

function controller() {
  return new Proxy({
    attendeeInviteLink: null,
    attendeeInviteLinkLoading: false,
    bootstrap: {
      event: {
        endTimeMillis: Date.now() - 1_000,
        eventId: "event-1",
        checkedInCount: 18,
        locationName: "The Courtyard",
        moduleIds: [],
        startTimeMillis: Date.now() - 3_600_000,
        title: "Courtyard Social",
      },
      participant: {
        attendanceStatus: "checkedIn",
        eventId: "event-1",
      },
    },
    conversationGraph: {
      candidates: [
        {assigned: true, displayName: "Rhea", uid: "guest-2"},
        {assigned: false, displayName: "Mina", uid: "guest-3"},
      ],
      consentMode: "optIn",
      eventId: "event-1",
      prompt: "Who were your tablemates?",
      selectedUids: [],
      submissionStatus: "unsubmitted",
    },
    conversationGraphLoading: false,
    eventEnded: true,
    liveState: {
      assignments: [],
      compatibilityAnswerIds: [],
      feedback: null,
      lateArrival: null,
      mission: null,
      plan: null,
      standings: null,
      wingmanTargetUid: null,
    },
    pending: false,
    questionnaire: {questions: [], title: ""},
    selectedConversationUids: [],
    stage: "runtime",
    status: {message: "", tone: ""},
    submitConversationGraph: vi.fn(),
    toggleConversationUid: vi.fn(),
  }, {
    get: (target, key) => key in target ?
      target[key as keyof typeof target] : vi.fn(),
  });
}

describe("EventRuntimePage conversation graph", () => {
  beforeEach(() => {
    runtimeController.value = controller();
  });

  afterEach(() => {
    cleanup();
    vi.useRealTimers();
  });

  it("renders one private roster-chip mechanism with server-owned format copy", () => {
    render(
      <MemoryRouter initialEntries={["/join/runtime-1"]}>
        <Routes>
          <Route path="/join/:publicRuntimeId" element={<EventRuntimePage />} />
        </Routes>
      </MemoryRouter>
    );

    expect(screen.getByRole("heading", {
      name: "Who were your tablemates?",
    })).toBeTruthy();
    const assignedChip = screen.getByRole("button", {
      name: `Rhea · ${eventRuntimeCopy.conversationSuggested}`,
    });
    fireEvent.click(assignedChip);
    expect(runtimeController.value.toggleConversationUid)
      .toHaveBeenCalledWith("guest-2");

    fireEvent.click(screen.getByRole("button", {
      name: eventRuntimeCopy.conversationSave,
    }));
    expect(runtimeController.value.submitConversationGraph)
      .toHaveBeenCalledWith();
    expect(screen.getByText(eventRuntimeCopy.conversationPrivacy))
      .toBeTruthy();
  });

  it("renders the same server-clocked reveal midpoint and arrival count", () => {
    vi.useFakeTimers();
    vi.setSystemTime(1_786_703_405_000);
    runtimeController.value = controller();
    runtimeController.value.bootstrap.event.moduleIds = ["live_reveal"];
    runtimeController.value.liveState.plan = {
      attendeePrompt: null,
      activeRevealRoundIndex: 2,
      publishedRevealRoundIndex: -1,
      publishedRotationRoundIndex: -1,
      revealCountdownSeconds: 10,
      revealStartedAtMillis: 1_786_703_400_000,
      revealStatus: "countingDown",
      status: "live",
    };

    const {container} = render(
      <MemoryRouter initialEntries={["/join/runtime-1"]}>
        <Routes>
          <Route path="/join/:publicRuntimeId" element={<EventRuntimePage />} />
        </Routes>
      </MemoryRouter>
    );

    const cinematic = container.querySelector("[data-phase='anticipation']");
    expect(cinematic).toBeTruthy();
    expect(cinematic?.getAttribute("style")).toContain(
      "--marquee-phase-progress: 0.5"
    );
    expect(screen.getByLabelText(eventRuntimeCopy.checkedInCount(18)))
      .toBeTruthy();
  });
});
