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

function LiveOrganizerHarness() {
  const controller = useOrganizerIntakeController({
    onError: vi.fn(),
    onNotice: vi.fn(),
  });
  return (
    <OrganizerIntakeWorkspace
      controller={{...controller, source: "firestore"}}
    />
  );
}

function EventHarness() {
  const controller = useEventIntakeController({
    onError: vi.fn(),
    onNotice: vi.fn(),
  });
  return <EventIntakePreviewWorkspace controller={controller} />;
}

function OrphanEventHarness() {
  const controller = useEventIntakeController({
    onError: vi.fn(),
    onNotice: vi.fn(),
  });
  const first = controller.bridge?.eventCandidates[0];
  if (!controller.bridge || !first?.attribution) {
    return <EventIntakePreviewWorkspace controller={controller} />;
  }
  const orphan = {
    ...first,
    attribution: {
      ...first.attribution,
      state: "orphan" as const,
      match: {
        ...first.attribution.match,
        matchedEntityId: null,
      },
    },
    organizerCeiling: {
      appVisibility: "hidden" as const,
      canAppDiscover: false,
      organizerId: null,
      reason: "Organizer attribution is required before app discovery.",
    },
  };
  return (
    <EventIntakePreviewWorkspace
      controller={{
        ...controller,
        bridge: {
          ...controller.bridge,
          eventCandidates: [orphan, ...controller.bridge.eventCandidates.slice(1)],
        },
      }}
    />
  );
}

beforeEach(() => {
  window.localStorage.clear();
});
afterEach(() => {
  cleanup();
  window.localStorage.clear();
});

describe("Intake task-first defaults", () => {
  it("does not import Marketing primitives or retain a parallel tab UI", () => {
    const root = join(process.cwd(), "src/features/intake");
    const sourceFiles: string[] = [];
    const visit = (directory: string) => {
      for (const entry of readdirSync(directory)) {
        const path = join(directory, entry);
        if (statSync(path).isDirectory()) {
          visit(path);
        } else if (/\.[jt]sx?$/u.test(entry) && !entry.includes(".test.")) {
          sourceFiles.push(path);
        }
      }
    };
    visit(root);
    const source = sourceFiles.map((path) => readFileSync(path, "utf8")).join("\n");
    expect(source).not.toMatch(/\bAdminMarketing[A-Z]\w*/u);
    expect(source).not.toMatch(/\bsetActiveTab\b/u);
  });

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
    expect(stageNavigation.textContent).toBe("IncomingVerifyResolveReady");
    expect(screen.getByLabelText("Intake queue metrics")).toBeTruthy();
    expect(screen.getByText("2 items")).toBeTruthy();

    fireEvent.click(screen.getByRole("button", {name: "Review Small World"}));
    expect(screen.getByRole("link", {
      name: "Open source for Small World",
    })).toBeTruthy();
    expect(screen.getByText("Captured search context")).toBeTruthy();
    expect(screen.getByRole("button", {
      name: "Create organizer draft",
    })).toBeTruthy();
    expect((screen.getByLabelText("Organizer name") as HTMLInputElement).value)
      .toBe("Small World");
    expect((screen.getByLabelText("Public page slug") as HTMLInputElement).value)
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
    fireEvent.click(screen.getByRole("button", {name: "Review AFTER FLY"}));
    expect(screen.getByRole("button", {
      name: "Attach to existing organizer",
    }).hasAttribute("disabled")).toBe(false);
  });

  it("marks unavailable live publication stages instead of reporting zero", async () => {
    const {wrapper} = createQueryHarness();
    render(<LiveOrganizerHarness />, {wrapper});

    const stages = await screen.findByRole("navigation", {
      name: "Organizer intake stages",
    });
    expect(stages.textContent).toBe("IncomingVerifyResolveReady");

    fireEvent.click(screen.getByRole("button", {name: /Verify/u}));
    expect(screen.getByText("This projection is not available yet."))
      .toBeTruthy();
    expect(screen.getAllByText(
      /Organizer publication review is not available/
    ).length).toBeGreaterThan(0);
    expect(screen.getByText("Publication review unavailable")).toBeTruthy();
    expect(screen.getByRole("button", {name: "All —"})).toBeTruthy();
  });

  it("keeps event diagnostics collapsed inside the candidate inspector", async () => {
    const {wrapper} = createQueryHarness();
    render(<EventHarness />, {wrapper});

    expect(await screen.findByRole("navigation", {
      name: "Event intake stages",
    })).toBeTruthy();
    expect(screen.queryByRole("button", {name: "Diagnostics"})).toBeNull();
    fireEvent.click(screen.getByRole("button", {
      name: "Review Sample Mumbai social",
    }));
    expect(screen.getByText("Diagnostics")).toBeTruthy();
    expect(screen.getByText("Reviewed fields")).toBeTruthy();
    expect(screen.queryByText("Event intake contract")).toBeNull();
    expect(screen.queryByText("adminGetEventIntakeDashboard")).toBeNull();
    expect(screen.queryByText("adminRecordEventIntakeReviewDecision")).toBeNull();
    expect((screen.getByLabelText("App visibility ceiling") as HTMLSelectElement).disabled)
      .toBe(true);
    expect(screen.getByText("The attributed organizer is hidden in the app."))
      .toBeTruthy();
  });

  it("blocks unattributed events and opens their seeded organizer lead", async () => {
    window.localStorage.setItem(
      "catch-admin.event-intake-stage.v2",
      "resolve"
    );
    const {wrapper} = createQueryHarness();
    render(<OrphanEventHarness />, {wrapper});

    fireEvent.click(await screen.findByRole("button", {
      name: "Review Sample Mumbai social",
    }));
    expect(screen.getAllByText("Canonical organizer attributed").length)
      .toBeGreaterThan(0);
    expect(screen.getByRole("link", {
      name: "Open generated organizer discovery lead",
    })).toBeTruthy();
    expect((screen.getByRole("button", {
      name: "Approve intake",
    }) as HTMLButtonElement).disabled).toBe(true);
  });
});
import {readdirSync, readFileSync, statSync} from "node:fs";
import {join} from "node:path";
