import {act, cleanup, fireEvent, render, screen, waitFor} from "@testing-library/react";
import {afterEach, expect, it, vi} from "vitest";
import {createQueryHarness} from "../../../shared/test/queryHarness";
import type {DemoBlueprint, DemoManagementApi} from "../api/salesDemoManagement";
import type {OwnerDemoReview, SalesDemoPartnerReviewApi} from "../api/salesDemoPartnerReview";
import {SalesDemoWorkspace} from "./SalesDemoPanel";
const reviewApi = vi.hoisted(() => ({get: vi.fn<SalesDemoPartnerReviewApi["get"]>(),
  share: vi.fn<SalesDemoPartnerReviewApi["share"]>()}));
vi.mock("../api/salesDemoPartnerReview", () => ({salesDemoPartnerReviewApi: reviewApi}));
const fingerprint = "a".repeat(64);
const preview = {brandName: "Synthetic organizer", headline: "A clear sample", scenario: "Sample application review",
  steps: ["Review", "Prepare reply", "Admit sample"], retainedTools: ["Keep the existing form"],
  limitations: ["Synthetic only; no real messages or admissions."], cta: "Discuss a pilot"};
function currentOwner(): OwnerDemoReview {
  return {organizerId: "organizer-one", blueprintId: "blueprint-one", blueprintRevision: 7, partnerUid: "partner-one", assignmentRevision: 3,
    preview, previewHash: fingerprint, sharingRevision: 0, proposedWording: null, proposalRevision: 0, sharingState: "none",
    expiresAt: null, sharingCurrent: false, maximumExpiresAt: new Date(Date.now() + 3600_000).toISOString(), evaluatedAt: new Date().toISOString(),
    sendAuthority: false, capabilityApprovalAuthority: false, organizerControlAuthority: false};
}
const blueprint: DemoBlueprint = {blueprintId: "blueprint-one", revision: 7, state: "reviewed", organizerId: "organizer-one",
  candidateId: null, opportunityId: null, capabilityRevision: "revision-one", evidenceRevision: "evidence-one",
  formCapabilityReview: {questionTypes: "manual", branching: "manual", requiredFields: "manual", scoringApproval: "unsupported", uploads: "retained"},
  fieldMappings: [], preview, reviewedAt: "2026-09-28T10:00:00.000Z", updatedAt: "2026-09-28T10:00:00.000Z"};
function fixture() {
  reviewApi.get.mockResolvedValue(currentOwner());
  reviewApi.share.mockImplementation(async (input) => ({blueprintId: input.blueprintId, blueprintRevision: input.expectedBlueprintRevision,
    sharingRevision: input.expectedSharingRevision + 1, sharingState: input.decision === "share" ? "active" : "withdrawn",
    previewHash: input.expectedPreviewHash, expiresAt: input.expiresAt ?? new Date().toISOString(),
    sendAuthority: false, capabilityApprovalAuthority: false, organizerControlAuthority: false}));
  const api = {capability: vi.fn(async () => ({capability: "synthetic_forms_v1" as const, revision: "revision-one",
    evidenceRevision: "evidence-one", enabled: true, templateOptions: []})),
  listBlueprints: vi.fn(async () => ({rows: [blueprint], nextCursor: null})), getBlueprint: vi.fn(async () => blueprint),
  listInvitations: vi.fn(async () => ({rows: [], nextCursor: null})), getInvitation: vi.fn(), saveBlueprint: vi.fn(),
  reviewBlueprint: vi.fn(), withdrawBlueprint: vi.fn(), issueInvitation: vi.fn(), revokeInvitation: vi.fn()} satisfies DemoManagementApi;
  const view = (actorUid = "owner-one") => <SalesDemoWorkspace organizerId="organizer-one"
    organizerName="Synthetic organizer" currentUserUid={actorUid} isAdminOwner api={api} />;
  const rendered = render(view(), createQueryHarness());
  return {api, rendered, view};
}
async function openSharing() {
  fireEvent.click(await screen.findByRole("button", {name: "Open"}));
  return screen.findByRole("button", {name: "Share this preview"});
}
function expiryAndReview() {
  fireEvent.change(screen.getByLabelText("Share until (UTC)"), {target: {value: new Date(Date.now() + 1800_000).toISOString().slice(0, 16)}});
  fireEvent.click(screen.getByLabelText("I approve this exact synthetic preview for this assigned partner"));
}
afterEach(cleanup);
it("requires exact recipient confirmation, resets confirmation after expiry edits, and only shares on deliberate action", async () => {
  fixture(); const share = await openSharing(); expect(share).toHaveProperty("disabled", true);
  expect(reviewApi.share).not.toHaveBeenCalled(); expect(screen.getByText("partner-one")).toBeTruthy();
  const checkbox = screen.getByLabelText("I approve this exact synthetic preview for this assigned partner");
  fireEvent.click(checkbox);
  fireEvent.change(screen.getByLabelText("Share until (UTC)"), {target: {value: new Date(Date.now() + 1800_000).toISOString().slice(0, 16)}});
  expect(share).toHaveProperty("disabled", true); fireEvent.click(checkbox); fireEvent.click(share);
  await waitFor(() => expect(reviewApi.share).toHaveBeenCalledOnce()); expect(reviewApi.share.mock.calls[0][0].decision).toBe("share");
  expect(reviewApi.share.mock.calls[0][0].expectedPreviewHash).toBe(fingerprint);
  expect(reviewApi.share.mock.calls[0][0]).toMatchObject({partnerUid: "partner-one", expectedAssignmentRevision: 3,
    expectedBlueprintRevision: 7, expectedSharingRevision: 0});
});
it("hides sharing while parent access refreshes and restores the same review only after current source returns", async () => {
  const {api} = fixture(); await openSharing(); expiryAndReview();
  let resolve!: (value: DemoBlueprint) => void;
  api.getBlueprint.mockImplementationOnce(() => new Promise((done) => {resolve = done;}));
  fireEvent.click(screen.getByRole("button", {name: "Refresh example and access"}));
  await waitFor(() => expect(screen.queryByRole("button", {name: "Share this preview"})).toBeNull());
  expect(reviewApi.share).not.toHaveBeenCalled();
  await act(async () => {resolve(blueprint);});
  const share = await screen.findByRole("button", {name: "Share this preview"});
  expect(screen.getByLabelText("I approve this exact synthetic preview for this assigned partner")).toHaveProperty("checked", true);
  expect(share).toHaveProperty("disabled", false); expect(reviewApi.share).not.toHaveBeenCalled();
});
it("requires a fresh confirmation when sharing refresh changes the exact recipient fingerprint", async () => {
  fixture(); await openSharing(); expiryAndReview();
  reviewApi.get.mockResolvedValueOnce({...currentOwner(), previewHash: "b".repeat(64), partnerUid: "partner-two", assignmentRevision: 4});
  fireEvent.click(screen.getByRole("button", {name: "Refresh sharing scope"}));
  await screen.findByText("partner-two");
  expect(screen.getByLabelText("I approve this exact synthetic preview for this assigned partner")).toHaveProperty("checked", false);
  expect(screen.getByRole("button", {name: "Share this preview"})).toHaveProperty("disabled", true);
  expect(reviewApi.share).not.toHaveBeenCalled();
});
it("keeps uncertain sharing and parent actions locked, then discards the old retry on owner scope change", async () => {
  const {rendered, view} = fixture(); await openSharing(); expiryAndReview();
  reviewApi.share.mockRejectedValueOnce(new Error("network lost")); fireEvent.click(screen.getByRole("button", {name: "Share this preview"}));
  await screen.findByRole("button", {name: "Retry unchanged sharing action"});
  await waitFor(() => expect(screen.getByRole("button", {name: "New example"})).toHaveProperty("disabled", true));
  expect(screen.getByRole("button", {name: "Save draft"})).toHaveProperty("disabled", true);
  expect(screen.getByRole("button", {name: "Share this preview"})).toHaveProperty("disabled", true);
  rendered.rerender(view("owner-two"));
  await waitFor(() => expect(screen.getByRole("button", {name: "New example"})).toHaveProperty("disabled", false));
  expect(screen.queryByRole("button", {name: "Retry unchanged sharing action"})).toBeNull();
  expect(screen.queryByRole("button", {name: "Share this preview"})).toBeNull(); expect(reviewApi.share).toHaveBeenCalledOnce();
});
it("loads pending partner wording as dirty edits and hides sharing without approving or sending", async () => {
  const {api} = fixture(); reviewApi.get.mockResolvedValue({...currentOwner(), proposedWording: {
    headline: "Partner proposal", scenario: "An approachable synthetic scenario", cta: "Review together"}, proposalRevision: 1});
  await openSharing(); fireEvent.click(screen.getByRole("button", {name: "Load proposal into draft editor"}));
  expect(await screen.findByDisplayValue("Partner proposal")).toBeTruthy();
  expect(screen.queryByRole("button", {name: "Share this preview"})).toBeNull();
  expect(reviewApi.share).not.toHaveBeenCalled(); expect(api.saveBlueprint).not.toHaveBeenCalled(); expect(api.reviewBlueprint).not.toHaveBeenCalled();
});
