import {readFileSync} from "node:fs";

import {cleanup, fireEvent, render, screen, within} from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import {afterEach, describe, expect, it, vi} from "vitest";

import type {
  AdminIntakeQueueItem,
  AdminIntakeWorkbenchDetail,
} from "./intake";
import {
  AdminIntakeReviewWorkbench,
  AdminIntakeStageRail,
} from "./intake";
import {
  eligibleBulkSelection,
  mergeStableIntakeItems,
  nextSelectionAfterDisposition,
  toggleIntakeRangeSelection,
} from "./intakeWorkbench";

afterEach(() => cleanup());

const items: AdminIntakeQueueItem[] = [
  {
    age: "2d",
    ageDays: 2,
    blocker: "Source evidence",
    blockerKey: "source",
    description: "Run club",
    id: "afterfly",
    initials: "AF",
    kind: "Organizer",
    market: "Indore",
    meta: "5 surfaces",
    source: "Official website",
    status: "Needs evidence",
    statusTone: "warning",
    title: "AFTER FLY",
  },
  {
    age: "1d",
    ageDays: 1,
    blocker: "—",
    blockerKey: null,
    description: "Social club",
    id: "courtside",
    initials: "CS",
    kind: "Candidate",
    market: "Mumbai",
    meta: "3 surfaces",
    source: "Instagram",
    status: "Ready",
    statusTone: "success",
    title: "Courtside",
  },
  {
    age: "Today",
    ageDays: 0,
    blocker: "Duplicate identity",
    blockerKey: "identity",
    description: "Board games",
    id: "meeple",
    initials: "MP",
    kind: "Candidate",
    market: "Mumbai",
    meta: "2 surfaces",
    source: "Official website",
    status: "Blocked",
    statusTone: "danger",
    title: "Meeple Club",
  },
];

function detail(): AdminIntakeWorkbenchDetail {
  return {
    blockers: [{
      action: "Open the official source and confirm ownership.",
      id: "source",
      label: "Source evidence",
      tone: "warning",
    }],
    checklistRows: [
      {id: "source", label: "Source reviewed", meta: "required", passed: false},
    ],
    checklistTitle: "Checklist",
    footerActions: <button disabled type="button">Approve listing</button>,
    footerHint: "Approval is blocked until the source is verified.",
    impactRows: [{id: "publish", label: "Publish", value: "Separate workflow"}],
    impactTitle: "Impact",
    initials: "AF",
    note: <span>Decision note field</span>,
    noteTitle: "Decision note",
    primaryRows: [{
      id: "website",
      meta: "Primary identity",
      status: "Current",
      statusTone: "success",
      title: "Official website",
    }],
    primaryTitle: "Evidence",
    readiness: {blockers: 1, complete: 0, label: "Decision readiness", total: 1},
    sections: [
      {
        id: "evidence",
        kind: "evidence",
        rows: [{
          id: "website",
          meta: "Primary identity",
          status: "Current",
          statusTone: "success",
          title: "Official website",
        }],
        title: "Evidence",
      },
      {
        content: "Run run-123 · revision 2",
        id: "diagnostics",
        kind: "diagnostics",
        title: "Run diagnostics",
      },
    ],
    status: "Needs evidence",
    statusTone: "warning",
    subtitle: "Organizer lead",
    title: "AFTER FLY",
  };
}

function renderWorkbench({
  bulkActions = [],
  onSelect = vi.fn(),
  selectedId = "afterfly",
  workbenchItems = items,
}: {
  bulkActions?: Parameters<typeof AdminIntakeReviewWorkbench>[0]["bulkActions"];
  onSelect?: (id: string) => void;
  selectedId?: string | null;
  workbenchItems?: AdminIntakeQueueItem[];
} = {}) {
  return render(
    <AdminIntakeReviewWorkbench
      bulkActions={bulkActions}
      detail={selectedId ? detail() : null}
      items={workbenchItems}
      queueMeta={`${workbenchItems.length} items`}
      queueTitle="Organizer intake queue"
      selectedId={selectedId}
      onSelect={onSelect}
    />
  );
}

describe("AdminIntakeStageRail", () => {
  it("exposes the selected step and reports stage changes", async () => {
    const user = userEvent.setup();
    const onChange = vi.fn();
    render(
      <AdminIntakeStageRail
        ariaLabel="Intake stages"
        options={[
          {id: "incoming", label: "Incoming", meta: "2 leads"},
          {id: "verify", label: "Verify", meta: "1 review"},
        ]}
        value="verify"
        onChange={onChange}
      />
    );

    expect(screen.getByRole("button", {name: /Verify/u}).getAttribute("aria-current"))
      .toBe("step");
    await user.click(screen.getByRole("button", {name: /Incoming/u}));
    expect(onChange).toHaveBeenCalledWith("incoming");
  });
});

describe("AdminIntakeReviewWorkbench", () => {
  it("supports mouse and keyboard navigation with an explicit inspector", async () => {
    const user = userEvent.setup();
    const onSelect = vi.fn();
    renderWorkbench({onSelect});
    const workbench = screen.getByRole("region", {name: "Organizer intake queue"});

    fireEvent.keyDown(workbench, {key: "j"});
    expect(onSelect).toHaveBeenCalledWith("courtside");

    await user.click(screen.getByRole("button", {name: /^CourtsideSocial club$/u}));
    expect(onSelect).toHaveBeenLastCalledWith("courtside");
    expect(screen.getByRole("complementary", {name: "Candidate review inspector"}))
      .toBeTruthy();
    expect(screen.getByText("Source evidence", {selector: ".intake-inspector-blockers strong"}))
      .toBeTruthy();
    expect(screen.getByText("Run diagnostics").closest("details")?.open).toBe(false);
    expect(
      (screen.getByRole("button", {name: "Approve listing"}) as HTMLButtonElement)
        .disabled
    ).toBe(true);
  });

  it("supports multi-selection and select-all matching", async () => {
    const user = userEvent.setup();
    renderWorkbench();
    const first = screen.getByRole("checkbox", {name: "Select AFTER FLY"});
    const third = screen.getByRole("checkbox", {name: "Select Meeple Club"});

    await user.click(first);
    await user.click(third);
    expect([
      screen.getByRole("checkbox", {name: "Select AFTER FLY"}),
      screen.getByRole("checkbox", {name: "Select Courtside"}),
      screen.getByRole("checkbox", {name: "Select Meeple Club"}),
    ].map((checkbox) => (checkbox as HTMLInputElement).checked)).toEqual([
      true,
      false,
      true,
    ]);

    await user.click(screen.getByRole("checkbox", {name: "Select all matching"}));
    expect((first as HTMLInputElement).checked).toBe(true);
    expect((third as HTMLInputElement).checked).toBe(true);
  });

  it("applies a partial-safe bulk action and explains skipped records", async () => {
    const user = userEvent.setup();
    const onApply = vi.fn().mockResolvedValue({appliedIds: ["courtside"]});
    renderWorkbench({
      bulkActions: [{
        eligibleIds: ["courtside"],
        id: "approve",
        label: "Approve",
        onApply,
        tone: "success",
      }],
    });
    await user.click(screen.getByRole("checkbox", {name: "Select all matching"}));
    await user.click(screen.getByRole("button", {name: /^Approve/u}));

    expect(onApply).toHaveBeenCalledWith(["courtside"]);
    expect(await screen.findByText(/1 approve · 2 skipped/u)).toBeTruthy();
  });

  it("keeps disposed rows visible, marks them resolved, and advances selection", async () => {
    const user = userEvent.setup();
    const onSelect = vi.fn();
    renderWorkbench({
      bulkActions: [{
        eligibleIds: ["afterfly"],
        id: "hold",
        label: "Hold",
        onApply: vi.fn().mockResolvedValue({appliedIds: ["afterfly"]}),
      }],
      onSelect,
    });

    await user.click(screen.getByRole("button", {name: "Hold"}));
    expect(onSelect).toHaveBeenCalledWith("courtside");
    expect(within(screen.getByRole("row", {name: /AFTER FLY/u})).getByText("Hold"))
      .toBeTruthy();
  });

  it("offers a ten-second undo when the decision supports supersession", async () => {
    const user = userEvent.setup();
    const onUndo = vi.fn();
    renderWorkbench({
      bulkActions: [{
        eligibleIds: ["afterfly"],
        id: "hold",
        label: "Hold",
        onApply: vi.fn().mockResolvedValue({appliedIds: ["afterfly"]}),
        onUndo,
      }],
    });

    await user.click(screen.getByRole("button", {name: "Hold"}));
    await user.click(await screen.findByRole("button", {name: /Undo/u}));
    expect(onUndo).toHaveBeenCalledWith(["afterfly"]);
  });

  it("renders loading, unavailable, filter-empty, and stage-empty as distinct states", () => {
    const common = {
      detail: null,
      items: [],
      onSelect: vi.fn(),
      queueMeta: "0 items",
      queueTitle: "Queue",
      selectedId: null,
    };
    const {rerender} = render(<AdminIntakeReviewWorkbench {...common} state="loading" />);
    expect(screen.getByRole("status", {name: "Loading intake candidates"})).toBeTruthy();

    rerender(<AdminIntakeReviewWorkbench {...common} state="unavailable" />);
    expect(screen.getByText("This projection is not available yet.")).toBeTruthy();

    rerender(<AdminIntakeReviewWorkbench {...common} emptyKind="filter" />);
    expect(screen.getByText("No candidates match these filters.")).toBeTruthy();

    rerender(<AdminIntakeReviewWorkbench {...common} emptyKind="stage" />);
    expect(screen.getByText("This stage is clear.")).toBeTruthy();
  });

  it("keeps every active workbench font declaration at twelve pixels or larger", () => {
    const stylesheet = readFileSync(`${process.cwd()}/src/styles.css`, "utf8");
    const start = stylesheet.indexOf("/* Supply Intake batch workbench");
    const end = stylesheet.indexOf("@keyframes intake-skeleton", start);
    const activeWorkbenchCss = stylesheet.slice(start, end);
    expect(activeWorkbenchCss).not.toMatch(/font(?:-size)?:\s*(?:[0-9]|1[01])px/u);
  });
});

describe("intake batch helpers", () => {
  it("splits eligible and skipped selections deterministically", () => {
    expect(eligibleBulkSelection(
      new Set(["afterfly", "courtside"]),
      {eligibleIds: ["courtside"]}
    )).toEqual({
      appliedIds: ["courtside"],
      skippedIds: ["afterfly"],
    });
  });

  it("advances to the next unresolved row", () => {
    expect(nextSelectionAfterDisposition(
      items,
      new Set(["afterfly"]),
      "afterfly"
    )).toBe("courtside");
  });

  it("updates incoming rows without dropping resolved rows before refresh", () => {
    const merged = mergeStableIntakeItems(items, [items[1]]);
    expect(merged.map((item) => item.id)).toEqual([
      "afterfly",
      "courtside",
      "meeple",
    ]);
  });

  it("selects an anchored shift range", () => {
    expect([...toggleIntakeRangeSelection(
      new Set(["afterfly"]),
      items,
      2,
      0,
      true
    )]).toEqual(["afterfly", "courtside", "meeple"]);
  });
});
