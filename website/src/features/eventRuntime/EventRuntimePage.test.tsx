import {fireEvent, render, screen} from "@testing-library/react";
import {MemoryRouter, Route, Routes} from "react-router";
import {beforeEach, describe, expect, it, vi} from "vitest";

const runtimeController = vi.hoisted(() => ({value: null as any}));

vi.mock("./useEventRuntimeController", () => ({
  useEventRuntimeController: () => runtimeController.value,
}));

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
});
