import {act, cleanup, fireEvent, render, screen, waitFor} from
  "@testing-library/react";
import {afterEach, expect, it, vi} from "vitest";
import {renderSalesImportCompensation} from "./SalesImportCompensationPanel";
import type {SalesWorkspaceController} from
  "../controllers/useSalesWorkspaceController";
import type {SalesImportCompensationPreview} from "../api/salesTypes";

vi.mock("../../../shared/api/dataMode", () => ({dataMode: () => "live"}));
afterEach(cleanup);

const plan: SalesImportCompensationPreview = {
  importId: "import-1", organizerId: "org-1", mode: "remove_cohorts",
  blockers: [], accountRevision: 4, cohortIdsRemoved: ["cohort-a"],
  previewHash: "a".repeat(64), alreadyCompensated: false,
};
function controller(overrides: Record<string, unknown> = {}) {
  return {isSaving: false, compensationPreviewPending: false,
    previewCompensation: vi.fn(async () => plan),
    applyCompensation: vi.fn(async () => true),
    ...overrides} as unknown as SalesWorkspaceController;
}
function enterIdentity() {
  fireEvent.change(screen.getByLabelText("Applied import ID"),
    {target: {value: "import-1"}});
  fireEvent.change(screen.getByLabelText("Canonical organizer ID"),
    {target: {value: "org-1"}});
}

it("drops a late server plan when the organizer changes", async () => {
  let resolve!: (value: SalesImportCompensationPreview) => void;
  const pending = new Promise<SalesImportCompensationPreview>((done) => {
    resolve = done;
  });
  const api = controller({previewCompensation: vi.fn(() => pending)});
  render(renderSalesImportCompensation(api));
  enterIdentity();
  fireEvent.click(screen.getByRole("button", {name: "Preview current correction"}));
  await waitFor(() => expect(api.previewCompensation).toHaveBeenCalledOnce());
  fireEvent.change(screen.getByLabelText("Canonical organizer ID"),
    {target: {value: "org-2"}});
  await act(async () => resolve(plan));
  expect(screen.queryByText(/Review hash:/u)).toBeNull();
  expect(api.applyCompensation).not.toHaveBeenCalled();
});

it("requires exact plan review and typed reason before apply", async () => {
  const api = controller();
  render(renderSalesImportCompensation(api));
  enterIdentity();
  fireEvent.click(screen.getByRole("button", {name: "Preview current correction"}));
  await screen.findByText(/Review hash:/u);
  const apply = screen.getByRole("button", {
    name: "Apply reviewed correction"}) as HTMLButtonElement;
  expect(apply.disabled).toBe(true);
  fireEvent.change(screen.getByLabelText("Reason for correction"),
    {target: {value: "Reviewed source correction"}});
  fireEvent.change(screen.getByLabelText("Review decision"),
    {target: {value: "yes"}});
  expect(apply.disabled).toBe(false);
  fireEvent.change(screen.getByLabelText("Reason for correction"),
    {target: {value: "Updated source correction"}});
  expect(apply.disabled).toBe(true);
  fireEvent.change(screen.getByLabelText("Review decision"),
    {target: {value: "yes"}});
  fireEvent.click(apply);
  await waitFor(() => expect(api.applyCompensation).toHaveBeenCalledWith({
    importId: "import-1", organizerId: "org-1",
    previewHash: "a".repeat(64), reason: "Updated source correction",
  }));
  await waitFor(() => expect(screen.queryByText(/Review hash:/u)).toBeNull());
});

it("shows blockers without a mutation control", async () => {
  const api = controller({previewCompensation: vi.fn(async () => ({...plan,
    mode: "blocked", blockers: ["sibling_import_membership"]}))});
  render(renderSalesImportCompensation(api));
  enterIdentity();
  fireEvent.click(screen.getByRole("button", {name: "Preview current correction"}));
  await screen.findByText("sibling import membership");
  expect(screen.queryByRole("button", {name: "Apply reviewed correction"}))
    .toBeNull();
});
