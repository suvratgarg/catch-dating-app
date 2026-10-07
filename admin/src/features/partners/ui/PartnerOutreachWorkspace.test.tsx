import {cleanup, fireEvent, render, screen} from "@testing-library/react";
import {afterEach, beforeEach, expect, it, vi} from "vitest";
import {PartnerOutreachWorkspace} from "./PartnerOutreachWorkspace";
const state = vi.hoisted(() => ({controller: {} as Record<string, unknown>}));
vi.mock("../controllers/usePartnerOutreachController", () => ({usePartnerOutreachController: () => state.controller}));
const props = {actorUid: "partner", organizerId: "synthetic", assignmentRevision: 1,
  accessExpiresAt: "2026-12-01T00:00:00.000Z", channel: "whatsapp", isCurrentSession: () => true};
const hash = "a".repeat(64);
function draft(status = "pending_review", draftId = "draft-one") {
  return {draftId, status, reviewedAt: status === "approved" ? "2026-10-04T00:00:00.000Z" : null,
    sendAuthority: false, draft: {draftId, contentHash: hash, subject: null, text: "Synthetic reviewed wording."}};
}
beforeEach(() => {
  state.controller = {prepared: {researchStatus: "qualified",
    contacts: [{contactId: "contact", displayName: "Synthetic contact", role: "Founder"}],
    opportunities: [{opportunityId: "opportunity", stage: "ready_to_contact", motion: "Pilot"}],
    clauses: ["observation", "capability", "cta"].map((kind) => ({clauseId: kind, kind,
      text: `${kind} wording.`, revision: 1, evidence: []}))}, currentDraft: null,
    ticket: null, busy: false, error: null, notice: null,
    generate: vi.fn(), review: vi.fn(), copy: vi.fn(), record: vi.fn(), refresh: vi.fn(), retry: vi.fn()};
});
afterEach(() => {cleanup(); vi.clearAllMocks();});
it("requires explicit current source selections before drafting and never sends automatically", () => {
  render(<PartnerOutreachWorkspace {...props} />);
  const generate = screen.getByRole("button", {name: "Prepare draft from selected wording"});
  expect(generate).toHaveProperty("disabled", true);
  fireEvent.change(screen.getByLabelText("Current contact"), {target: {value: "contact"}});
  fireEvent.change(screen.getByLabelText("Opportunity"), {target: {value: "opportunity"}});
  for (const kind of ["observation", "capability", "cta"]) fireEvent.click(screen.getByLabelText(`${kind}: ${kind} wording.`));
  fireEvent.click(generate);
  expect(state.controller.generate).toHaveBeenCalledWith({organizerId: "synthetic", contactId: "contact",
    opportunityId: "opportunity", observationIds: ["observation"], capabilityIds: ["capability"],
    referenceIds: [], ctaIds: ["cta"], channel: "message", purpose: "first_message"});
  expect(state.controller.record).not.toHaveBeenCalled(); expect(state.controller.copy).not.toHaveBeenCalled();
});
it("requires a new composition confirmation when a new draft has the same wording hash", () => {
  state.controller.currentDraft = draft();
  const view = render(<PartnerOutreachWorkspace {...props} />);
  const review = screen.getByRole("button", {name: "Confirm exact composition review"});
  expect(review).toHaveProperty("disabled", true);
  fireEvent.click(screen.getByLabelText("I verified these facts, the tone and my established contact channel."));
  expect(review).toHaveProperty("disabled", false);
  state.controller.currentDraft = draft("pending_review", "draft-two");
  view.rerender(<PartnerOutreachWorkspace {...props} />);
  expect(screen.getByRole("button", {name: "Confirm exact composition review"})).toHaveProperty("disabled", true);
  expect(state.controller.review).not.toHaveBeenCalled();
});
it("requires a separate sending attestation and records the user's UTC time", () => {
  state.controller.currentDraft = draft("approved");
  render(<PartnerOutreachWorkspace {...props} />);
  expect(state.controller.record).not.toHaveBeenCalled();
  fireEvent.change(screen.getByLabelText("When you manually sent it (UTC)"), {target: {value: "2026-10-04T12:30"}});
  fireEvent.click(screen.getByLabelText("I manually sent this exact reviewed draft."));
  fireEvent.click(screen.getByRole("button", {name: "Record my manual-send attestation"}));
  expect(state.controller.record).toHaveBeenCalledWith("whatsapp", "2026-10-04T12:30:00.000Z");
  expect(state.controller.copy).not.toHaveBeenCalled();
});
it("withdraws private wording and all outreach controls when the current preparation is withheld", () => {
  state.controller.currentDraft = draft("approved");
  const view = render(<PartnerOutreachWorkspace {...props} />);
  expect(screen.getByLabelText("Exact draft wording")).toHaveProperty("value", "Synthetic reviewed wording.");
  state.controller.prepared = null; state.controller.currentDraft = null;
  view.rerender(<PartnerOutreachWorkspace {...props} />);
  expect(screen.queryByLabelText("Exact draft wording")).toBeNull();
  expect(screen.queryByRole("button", {name: "Record my manual-send attestation"})).toBeNull();
});
