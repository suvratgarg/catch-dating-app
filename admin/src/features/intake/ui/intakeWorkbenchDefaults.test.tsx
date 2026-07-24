import {cleanup, fireEvent, render, screen} from "@testing-library/react";
import {afterEach, beforeEach, describe, expect, it, vi} from "vitest";

import {createQueryHarness} from "../../../shared/test/queryHarness";
import {useEventIntakeController} from
  "../events/controllers/useEventIntakeController";
import {EventIntakePreviewWorkspace} from
  "../events/ui/EventIntakeWorkspace";
import {useOrganizerIntakeController} from
  "../organizer/controllers/useOrganizerIntakeController";
import {OrganizerIntakeWorkspace} from
  "../organizer/ui/OrganizerIntakeScreen";

function OrganizerHarness() {
  const controller = useOrganizerIntakeController({
    onError: vi.fn(),
    onNotice: vi.fn(),
  });
  return <OrganizerIntakeWorkspace controller={controller} />;
}

function EventHarness() {
  const controller = useEventIntakeController({
    onError: vi.fn(),
    onNotice: vi.fn(),
  });
  return <EventIntakePreviewWorkspace controller={controller} />;
}

beforeEach(() => {
  window.localStorage.clear();
});
afterEach(() => {
  cleanup();
  window.localStorage.clear();
});

describe("Intake task-first defaults", () => {
  it("does not offer obsolete local organizer diagnostics", async () => {
    const {wrapper} = createQueryHarness();
    render(<OrganizerHarness />, {wrapper});

    expect(await screen.findByRole("navigation", {
      name: "Organizer intake stages",
    })).toBeTruthy();
    expect(screen.queryByRole("heading", {name: "Workflow readiness"})).toBeNull();

    expect(screen.queryByRole("button", {name: "Diagnostics"})).toBeNull();
  });

  it("opens captured organizer search candidates in the Incoming review stage", async () => {
    window.localStorage.setItem(
      "catch-admin.organizer-intake-stage.v1",
      "verify"
    );
    const {wrapper} = createQueryHarness();
    render(<OrganizerHarness />, {wrapper});

    const stageNavigation = await screen.findByRole("navigation", {
      name: "Organizer intake stages",
    });
    expect(stageNavigation.querySelector("[aria-current='step']")?.textContent)
      .toContain("Incoming");
    expect(screen.getByText("2 new leads")).toBeTruthy();
    expect(screen.getByText("2 items")).toBeTruthy();

    fireEvent.click(screen.getByRole("button", {name: /Small World/u}));
    expect(screen.getByRole("link", {
      name: "Open source for Small World",
    })).toBeTruthy();
    expect(screen.getByText("Captured search context")).toBeTruthy();
    expect(screen.getByRole("button", {
      name: "Create organizer draft",
    })).toBeTruthy();
    expect((screen.getByLabelText("Organizer name") as HTMLInputElement).value)
      .toBe("Small World");
    expect((screen.getByLabelText("Draft slug") as HTMLInputElement).value)
      .toBe("small-world");
    expect(screen.getByText(
      /Publication, indexing, app visibility, crawling, and ownership remain disabled/u
    )).toBeTruthy();

    fireEvent.change(screen.getByLabelText("City"), {
      target: {value: "Mumbai"},
    });
    expect(screen.getByText("1 item")).toBeTruthy();
    expect(screen.queryByRole("button", {
      name: /Academy of Indore Marathoners/u,
    })).toBeNull();

    fireEvent.change(screen.getByLabelText("City"), {
      target: {value: "Indore"},
    });
    fireEvent.click(screen.getByRole("button", {name: /AFTER FLY/u}));
    expect(screen.getByRole("button", {
      name: "Attach to existing organizer",
    }).hasAttribute("disabled")).toBe(false);
  });

  it("keeps event diagnostics behind the candidate review queue", async () => {
    const {wrapper} = createQueryHarness();
    render(<EventHarness />, {wrapper});

    expect(await screen.findByRole("navigation", {
      name: "Event intake stages",
    })).toBeTruthy();
    expect(screen.queryByRole("heading", {name: "Event candidate queue"})).toBeNull();

    fireEvent.click(screen.getByRole("button", {name: "Diagnostics"}));
    expect(screen.getByRole("heading", {name: "Event candidate queue"})).toBeTruthy();
    fireEvent.click(screen.getByRole("button", {name: "Crawl setup"}));
    expect(screen.getByRole("heading", {name: "Review boundary"})).toBeTruthy();
    expect(screen.queryByText("Event intake contract")).toBeNull();
    expect(screen.queryByText("adminGetEventIntakeDashboard")).toBeNull();
    expect(screen.queryByText("adminRecordEventIntakeReviewDecision")).toBeNull();
    fireEvent.click(screen.getByRole("button", {name: "Back to review queue"}));
    expect(screen.getByRole("navigation", {
      name: "Event intake stages",
    })).toBeTruthy();
  });
});
