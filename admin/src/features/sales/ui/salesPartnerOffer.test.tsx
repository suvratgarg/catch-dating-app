import {cleanup, fireEvent, render, screen} from "@testing-library/react";
import {afterEach, beforeEach, expect, it, vi} from "vitest";
import {createQueryHarness} from "../../../shared/test/queryHarness";
import {renderSalesPartnerOffer} from "./salesPartnerOffer";
const state = vi.hoisted(() => ({offer: vi.fn(), retry: vi.fn(), ticket: null as object | null,
  error: null, offeredTo: null as string | null, busy: false}));
vi.mock("../controllers/useSalesPartnerOfferController", () => ({useSalesPartnerOfferController: () => state}));
afterEach(cleanup);
beforeEach(() => {state.offer.mockReset(); state.ticket = null; state.offeredTo = null;});
function show() {const {wrapper} = createQueryHarness(); return render(renderSalesPartnerOffer("admin", "host", "Example host"), {wrapper});}
it("requires exact recipient review and clears that review when the offer changes", () => {
  show();
  const fill = (label: string, value: string) => fireEvent.change(screen.getByLabelText(label), {target: {value}});
  fill("Verified partner account UID", "partner"); fill("Next action for the partner", "Verify buyer");
  fill("Reason for this assignment", "Reviewed identity");
  fill("Review at (your local time)", "2026-10-20T18:00");
  fill("Assignment expires (your local time)", "2026-10-25T18:00");
  const button = screen.getByRole("button", {name: "Offer lead"});
  expect(button).toHaveProperty("disabled", true);
  fireEvent.click(screen.getByRole("checkbox"));
  expect(button).toHaveProperty("disabled", false);
  fill("Verified partner account UID", "another-partner");
  expect(button).toHaveProperty("disabled", true);
  fireEvent.click(screen.getByRole("checkbox")); fireEvent.click(button);
  expect(state.offer).toHaveBeenCalledWith(expect.objectContaining({partnerUid: "another-partner", nextAction: "Verify buyer"}));
});
it("locks edits during uncertain completion and exposes exact retry", () => {
  state.ticket = {}; show();
  expect(screen.getByLabelText("Verified partner account UID")).toHaveProperty("disabled", true);
  fireEvent.click(screen.getByRole("button", {name: "Retry unchanged offer"}));
  expect(state.retry).toHaveBeenCalled();
});
it("shows the exact confirmed recipient and removes the submission form", () => {
  state.offeredTo = "partner"; show();
  expect(screen.getByRole("status").textContent).toContain("partner");
  expect(screen.queryByRole("button", {name: "Offer lead"})).toBeNull();
});
