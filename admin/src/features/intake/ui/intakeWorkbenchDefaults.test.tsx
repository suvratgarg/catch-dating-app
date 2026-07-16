import {cleanup, fireEvent, render, screen} from "@testing-library/react";
import {afterEach, describe, expect, it, vi} from "vitest";

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

afterEach(cleanup);

describe("Intake task-first defaults", () => {
  it("keeps organizer diagnostics behind the review queue", async () => {
    const {wrapper} = createQueryHarness();
    render(<OrganizerHarness />, {wrapper});

    expect(await screen.findByRole("navigation", {
      name: "Organizer intake stages",
    })).toBeTruthy();
    expect(screen.queryByRole("heading", {name: "Workflow readiness"})).toBeNull();

    fireEvent.click(screen.getByRole("button", {name: "Diagnostics"}));
    expect(await screen.findByRole("heading", {
      name: "Workflow readiness",
    })).toBeTruthy();
    fireEvent.click(screen.getByRole("button", {name: "Back to review queue"}));
    expect(screen.getByRole("navigation", {
      name: "Organizer intake stages",
    })).toBeTruthy();
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
    fireEvent.click(screen.getByRole("button", {name: "Back to review queue"}));
    expect(screen.getByRole("navigation", {
      name: "Event intake stages",
    })).toBeTruthy();
  });
});
