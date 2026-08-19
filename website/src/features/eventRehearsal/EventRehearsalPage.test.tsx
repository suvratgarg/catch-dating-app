import {cleanup, fireEvent, render, screen} from "@testing-library/react";
import {MemoryRouter, Route, Routes} from "react-router";
import {afterEach, describe, expect, it, vi} from "vitest";

const rehearsalController = vi.hoisted(() => ({value: null as any}));

vi.mock("./useEventRehearsalController", () => ({
  useEventRehearsalController: () => rehearsalController.value,
}));

import type {EventRehearsalGuestBootstrap} from "../../firebase";
import {eventRehearsalCopy} from "../../content/eventRehearsal";
import {
  EventRehearsalPage,
  EventRehearsalPreview,
} from "./EventRehearsalPage";

const bootstrap: EventRehearsalGuestBootstrap = {
  slotToken: "slot_1234567890123456_token_12345678901234567890",
  practiceBanner: eventRehearsalCopy.practiceBanner,
  session: {
    title: "Courtyard practice",
    locationName: "Practice studio",
    status: "running",
    activeStepIndex: 1,
    virtualNowMillis: Date.parse("2026-08-19T18:00:00.000Z"),
    attendeePrompt: "Say hello to someone new",
    moduleIds: ["arrival", "firstHello"],
    runtimeRevision: 2,
    faultId: "none",
  },
  actor: {
    actorId: "actor-01",
    displayName: "Rhea",
    status: "expected",
    guestMoment: "checkIn",
    optedOut: false,
    helpRequested: false,
    promptCompleted: false,
  },
};

afterEach(cleanup);

describe("EventRehearsalPreview", () => {
  it("keeps practice identity visible and sends guest actions", () => {
    const onAction = vi.fn();
    render(
      <EventRehearsalPreview
        bootstrap={bootstrap}
        onAction={onAction}
        pending={false}
        status={{message: "", tone: ""}}
      />
    );

    expect(screen.getByText(eventRehearsalCopy.practiceBanner)).toBeTruthy();
    fireEvent.click(screen.getByRole("button", {
      name: eventRehearsalCopy.checkedIn,
    }));
    expect(onAction).toHaveBeenCalledWith("checkIn");
    expect(screen.queryByText(/otp/iu)).toBeNull();
  });

  it("shows fault guidance and removes actions when practice completes", () => {
    render(
      <EventRehearsalPreview
        bootstrap={{
          ...bootstrap,
          session: {
            ...bootstrap.session,
            status: "complete",
            faultId: "reducedMotion",
          },
          actor: {...bootstrap.actor, guestMoment: "complete"},
        }}
        onAction={vi.fn()}
        pending={false}
        status={{message: "", tone: ""}}
      />
    );

    expect(screen.getByRole("heading", {
      name: eventRehearsalCopy.completeTitle,
    })).toBeTruthy();
    expect(screen.getByText(eventRehearsalCopy.faultNotices.reducedMotion))
      .toBeTruthy();
    expect(screen.queryByRole("button")).toBeNull();
  });
});

describe("EventRehearsalPage", () => {
  it("renders a practice-specific loading state while redeeming a slot", () => {
    rehearsalController.value = {
      bootstrap: null,
      isLoading: true,
      isUnavailable: false,
      pending: false,
      refresh: vi.fn(),
      status: {message: "", tone: ""},
      submit: vi.fn(),
    };
    renderPage();

    expect(screen.getByRole("heading", {
      name: eventRehearsalCopy.loadingTitle,
    })).toBeTruthy();
    expect(screen.getByText(eventRehearsalCopy.practiceBanner)).toBeTruthy();
  });

  it("fails closed and offers retry for an unavailable practice link", () => {
    const refresh = vi.fn();
    rehearsalController.value = {
      bootstrap: null,
      isLoading: false,
      isUnavailable: true,
      pending: false,
      refresh,
      status: {message: "", tone: ""},
      submit: vi.fn(),
    };
    renderPage();

    fireEvent.click(screen.getByRole("button", {
      name: eventRehearsalCopy.retry,
    }));
    expect(refresh).toHaveBeenCalledWith();
    expect(screen.getByRole("heading", {
      name: eventRehearsalCopy.unavailableTitle,
    })).toBeTruthy();
  });
});

function renderPage() {
  return render(
    <MemoryRouter initialEntries={[
      "/rehearse/practice_12345678901234567890",
    ]}>
      <Routes>
        <Route
          path="/rehearse/:publicRehearsalId"
          element={<EventRehearsalPage />}
        />
      </Routes>
    </MemoryRouter>
  );
}
