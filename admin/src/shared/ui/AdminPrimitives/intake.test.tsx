import {cleanup, render, screen} from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import {afterEach, describe, expect, it, vi} from "vitest";

import {
  AdminIntakeReviewWorkbench,
  AdminIntakeStageRail,
} from "./intake";

afterEach(() => cleanup());

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
  it("keeps queue selection and decision readiness available without color", async () => {
    const user = userEvent.setup();
    const onSelect = vi.fn();
    render(
      <AdminIntakeReviewWorkbench
        detail={{
          checklistRows: [{id: "source", label: "Source reviewed", meta: "required", passed: false}],
          checklistTitle: "Checklist",
          footerActions: <button disabled type="button">Approve</button>,
          footerHint: "Approval is blocked.",
          impactRows: [{id: "publish", label: "Publish", value: "Separate workflow"}],
          impactTitle: "Impact",
          initials: "AF",
          note: <span>Decision note field</span>,
          noteTitle: "Decision note",
          primaryRows: [{
            id: "source",
            meta: "Primary identity",
            status: "Confirmed",
            statusTone: "success",
            title: "Instagram",
          }],
          primaryTitle: "Evidence",
          readiness: {blockers: 1, complete: 0, label: "Decision readiness", total: 1},
          status: "Needs evidence",
          statusTone: "warning",
          subtitle: "Organizer lead",
          title: "AFTER FLY",
        }}
        items={[
          {
            description: "Run club",
            id: "afterfly",
            initials: "AF",
            meta: "5 surfaces",
            status: "Needs evidence",
            statusTone: "warning",
            title: "AFTER FLY",
          },
          {
            description: "Run club",
            id: "bhag",
            initials: "BC",
            meta: "3 surfaces",
            status: "Ready",
            statusTone: "success",
            title: "Bhag Club",
          },
        ]}
        queueMeta="2 items"
        queueTitle="Needs verification"
        selectedId="afterfly"
        onSelect={onSelect}
      />
    );

    expect(screen.getByText("1 blocker")).toBeTruthy();
    expect(screen.getByText("Approval is blocked.")).toBeTruthy();
    const selected = screen.getByRole("button", {name: /AFTER FLY/u});
    expect(selected.getAttribute("aria-pressed")).toBe("true");

    await user.click(screen.getByRole("button", {name: /Bhag Club/u}));
    expect(onSelect).toHaveBeenCalledWith("bhag");
  });
});
