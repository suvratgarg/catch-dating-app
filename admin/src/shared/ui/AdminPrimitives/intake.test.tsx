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
    actionGate: "Approval is blocked until the source is verified.",
    actions: <button disabled type="button">Approve listing</button>,
    blockers: [{
      action: "Open the official source and confirm ownership.",
      id: "source",
      label: "Source evidence",
      tone: "warning",
    }],
    initials: "AF",
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
        id: "impact",
        kind: "impact",
        rows: [{id: "publish", label: "Publish", value: "Separate workflow"}],
        title: "Impact",
      },
      {
        content: <span>Decision note field</span>,
        id: "note",
        kind: "content",
        title: "Decision note",
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
  controls,
  onSelect = vi.fn(),
  selectedId = "afterfly",
  workbenchItems = items,
}: {
  bulkActions?: Parameters<typeof AdminIntakeReviewWorkbench>[0]["bulkActions"];
  controls?: Parameters<typeof AdminIntakeReviewWorkbench>[0]["controls"];
  onSelect?: (id: string) => void;
  selectedId?: string | null;
  workbenchItems?: AdminIntakeQueueItem[];
} = {}) {
  return render(
    <AdminIntakeReviewWorkbench
      bulkActions={bulkActions}
      controls={controls}
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
          {id: "incoming", label: "Incoming"},
          {id: "verify", label: "Verify"},
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

  it("replaces filters with a fixed selection action bar and restores them on clear", async () => {
    const user = userEvent.setup();
    renderWorkbench({
      bulkActions: [{
        eligibleIds: ["afterfly"],
        id: "hold",
        label: "Hold",
        onApply: vi.fn(),
      }],
      controls: <input aria-label="Domain search" />,
    });

    expect(screen.getByLabelText("Domain search")).toBeTruthy();
    await user.click(screen.getByRole("checkbox", {name: "Select AFTER FLY"}));

    expect(screen.queryByLabelText("Domain search")).toBeNull();
    expect(screen.getByLabelText("Selection actions")).toBeTruthy();
    expect(screen.getByText("1 selected")).toBeTruthy();
    expect(screen.getByRole("button", {name: "Hold"})).toBeTruthy();

    await user.click(screen.getByRole("button", {name: "Clear"}));
    expect(screen.getByLabelText("Domain search")).toBeTruthy();
  });

  it("shows partial eligibility and fully disabled gate reasons as visible text", async () => {
    const user = userEvent.setup();
    renderWorkbench({
      bulkActions: [
        {
          eligibleIds: ["courtside"],
          id: "approve",
          label: "Approve",
          onApply: vi.fn(),
        },
        {
          disabledReason: "Ownership review blocks attachment.",
          eligibleIds: [],
          id: "attach",
          label: "Attach",
          onApply: vi.fn(),
        },
      ],
    });

    await user.click(screen.getByRole("checkbox", {name: "Select all matching"}));
    expect(screen.getByText("1 eligible; 2 will be skipped.")).toBeTruthy();
    expect(screen.getByText("Ownership review blocks attachment.")).toBeTruthy();
    expect((screen.getByRole("button", {name: "Attach 0/3"}) as HTMLButtonElement).disabled)
      .toBe(true);
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

    await user.click(screen.getByRole("checkbox", {name: "Select AFTER FLY"}));
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

    await user.click(screen.getByRole("checkbox", {name: "Select AFTER FLY"}));
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

  it("preserves the table during a retryable refresh error", () => {
    const onRetry = vi.fn();
    render(
      <AdminIntakeReviewWorkbench
        detail={detail()}
        items={items}
        loadError="Refresh failed; showing the last reviewed snapshot."
        queueMeta="3 items"
        queueTitle="Queue"
        selectedId="afterfly"
        state="error"
        onRetry={onRetry}
        onSelect={vi.fn()}
      />
    );
    expect(screen.getByRole("table")).toBeTruthy();
    expect(screen.getByRole("alert").textContent).toContain(
      "Refresh failed; showing the last reviewed snapshot."
    );
    screen.getByRole("button", {name: "Try again"}).click();
    expect(onRetry).toHaveBeenCalledTimes(1);
  });

  it("publishes the complete keyboard map with accessible mouse equivalents", async () => {
    const user = userEvent.setup();
    const approve = vi.fn();
    const hold = vi.fn();
    const suppress = vi.fn();
    const onSelect = vi.fn();
    renderWorkbench({
      bulkActions: [
        {eligibleIds: items.map((item) => item.id), id: "approve", label: "Approve", onApply: approve},
        {eligibleIds: items.map((item) => item.id), id: "hold", label: "Hold", onApply: hold},
        {eligibleIds: items.map((item) => item.id), id: "suppress", label: "Suppress", onApply: suppress},
      ],
      controls: <input aria-label="Domain search" data-intake-search />,
      onSelect,
    });
    const workbench = screen.getByRole("region", {name: "Organizer intake queue"});

    fireEvent.keyDown(workbench, {key: "j"});
    fireEvent.keyDown(workbench, {key: "k"});
    expect(onSelect).toHaveBeenCalledWith("courtside");
    expect(onSelect).toHaveBeenCalledWith("meeple");

    fireEvent.keyDown(workbench, {key: "Enter"});
    expect(screen.getByRole("complementary", {name: "Candidate review inspector"}))
      .toBeTruthy();
    fireEvent.keyDown(workbench, {key: "Escape"});
    expect(screen.queryByRole("complementary", {name: "Candidate review inspector"}))
      .toBeNull();

    fireEvent.keyDown(workbench, {key: "/"});
    expect(document.activeElement).toBe(screen.getByLabelText("Domain search"));
    await user.click(workbench);
    fireEvent.keyDown(workbench, {key: "?"});
    expect(screen.getByRole("dialog", {name: "Intake keyboard shortcuts"}))
      .toBeTruthy();
    expect(screen.getByRole("button", {name: "Close shortcuts"})).toBeTruthy();

    fireEvent.keyDown(workbench, {key: "a"});
    fireEvent.keyDown(workbench, {key: "h"});
    fireEvent.keyDown(workbench, {key: "s"});
    expect(approve).toHaveBeenCalledWith(["afterfly"]);
    expect(hold).toHaveBeenCalledWith(["afterfly"]);
    expect(suppress).toHaveBeenCalledWith(["afterfly"]);

    expect(screen.getByRole("button", {name: "Review AFTER FLY"})).toBeTruthy();
    expect(screen.getByRole("button", {name: "Show intake keyboard shortcuts"}))
      .toBeTruthy();
  });

  it("keeps every active workbench font declaration at twelve pixels or larger", () => {
    const stylesheet = readFileSync(`${process.cwd()}/src/styles.css`, "utf8");
    const start = stylesheet.indexOf("/* Supply Intake batch workbench");
    const end = stylesheet.indexOf("@keyframes intake-skeleton", start);
    const activeWorkbenchCss = stylesheet.slice(start, end);
    expect(activeWorkbenchCss).not.toMatch(
      /font(?:-size)?:\s*(?:[0-9]|1[01])px/u
    );
  });

  it("lets the shell own workbench height without viewport arithmetic or caps", () => {
    const stylesheet = readFileSync(`${process.cwd()}/src/styles.css`, "utf8");
    const rootRule = stylesheet.match(
      /\.intake-review-workbench\.intake-batch-workbench\s*\{([^}]*)\}/u
    )?.[1] ?? "";
    expect(rootRule).not.toMatch(
      /(?:^|\n)\s*(?:min-|max-)?height\s*:/u
    );
    expect(rootRule).not.toContain("calc(");
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
