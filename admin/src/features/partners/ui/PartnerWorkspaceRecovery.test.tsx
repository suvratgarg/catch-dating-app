vi.mock("./PartnerDemoReviewWorkspace", () => ({PartnerDemoReviewWorkspace: () => null}));
import {act, cleanup, fireEvent, render, screen, waitFor} from "@testing-library/react";
import {afterEach, beforeEach, expect, it, vi} from "vitest";
import {createQueryHarness} from "../../../shared/test/queryHarness";
import type {PropsWithChildren} from "react";
import {AdminPendingOperationProvider} from "../../../shared/pendingOperation";
import {PartnerWorkspaceScreen} from "./PartnerWorkspaceScreen";
const transport = vi.hoisted(() => ({readPartnerWorkspace: vi.fn(), writePartner: vi.fn()}));
const outreach = vi.hoisted(() => ({preparation: vi.fn(), generate: vi.fn(), job: vi.fn(),
  draft: vi.fn(), review: vi.fn(), copy: vi.fn(), record: vi.fn()}));
vi.mock("../api/partnerRepository", () => transport);
vi.mock("../api/partnerOutreachRepository", () => ({partnerOutreachApi: outreach}));
const hash = "a".repeat(64);
function recoveryHarness() {
  const harness = createQueryHarness(); const QueryHarness = harness.wrapper;
  return {...harness, wrapper: ({children}: PropsWithChildren) => <QueryHarness>
    <AdminPendingOperationProvider>{children}</AdminPendingOperationProvider>
  </QueryHarness>};
}
function workspace() {
  const expiresAt = new Date(Date.now() + 3600_000).toISOString();
  return {membership: {uid: "partner", displayName: "Synthetic partner", expiresAt}, submissions: [],
    nextCursor: null, sendAuthority: false, leads: [{organizer: {organizerId: "synthetic",
      name: "Private synthetic organizer", city: "Mumbai", claimState: "unclaimed"},
      assignment: {organizerId: "synthetic", revision: 1, status: "accepted", expiresAt,
        nextAction: "Private next step", reviewAt: expiresAt, channel: "whatsapp", relationshipContext: null}}]};
}
beforeEach(() => {
  transport.readPartnerWorkspace.mockImplementation(async () => workspace());
  outreach.preparation.mockImplementation(async () => ({organizerId: "synthetic", assignmentRevision: 1,
    researchStatus: "qualified", evaluatedAt: new Date().toISOString(), sendAuthority: false,
    capabilityApprovalAuthority: false, contacts: [{contactId: "contact", displayName: "Synthetic contact", role: "Founder"}],
    opportunities: [{opportunityId: "opportunity", stage: "ready_to_contact", motion: "Pilot"}],
    clauses: ["observation", "capability", "cta"].map((kind) => ({clauseId: kind, kind,
      text: `${kind} wording.`, revision: 1, validUntil: new Date(Date.now() + 3600_000).toISOString(), evidence: []}))}));
  outreach.generate.mockRejectedValueOnce(new Error("Connection interrupted"));
  outreach.generate.mockResolvedValue({status: "completed", result: {draftId: "draft-own", contentHash: hash}, idempotentReplay: true});
  outreach.job.mockRejectedValue(Object.assign(new Error("Not yet confirmed"), {code: "functions/not-found"}));
  outreach.draft.mockResolvedValue({draftId: "draft-own", status: "pending_review", reviewedAt: null,
    sendAuthority: false, draft: {draftId: "draft-own", organizerId: "synthetic", contentHash: hash,
      text: "Synthetic reviewed text", subject: null}});
});
afterEach(() => {cleanup(); vi.resetAllMocks();});
async function interrupted(view: ReturnType<typeof recoveryHarness>) {
  render(<PartnerWorkspaceScreen actorUid="partner" isCurrentSession={() => true} onSignOut={() => {}} />, view);
  await screen.findByLabelText("Current contact");
  fireEvent.change(screen.getByLabelText("Next action"), {target: {value: "Unsaved private next step"}});
  fireEvent.change(screen.getByLabelText("Current contact"), {target: {value: "contact"}});
  fireEvent.change(screen.getByLabelText("Opportunity"), {target: {value: "opportunity"}});
  for (const kind of ["observation", "capability", "cta"]) fireEvent.click(screen.getByLabelText(`${kind}: ${kind} wording.`));
  fireEvent.click(screen.getByRole("button", {name: "Prepare draft from selected wording"}));
  await screen.findByRole("button", {name: "Retry unchanged outreach action"});
  await waitFor(() => expect(screen.getByRole("button", {name: "Retry unchanged outreach action"})).toHaveProperty("disabled", false));
  return outreach.generate.mock.calls[0][0];
}
it("keeps exact interrupted child work and unsaved lead edits through successful same-revision parent refresh", async () => {
  const view = recoveryHarness(); const original = await interrupted(view);
  let finish!: (value: unknown) => void;
  transport.readPartnerWorkspace.mockImplementationOnce(() => new Promise((resolve) => {finish = resolve;}));
  let refresh!: Promise<void>;
  await act(async () => {refresh = view.client.invalidateQueries({queryKey: ["partner-workspace"]});});
  await waitFor(() => expect(screen.queryByText("Private synthetic organizer")).toBeNull());
  expect(screen.queryByLabelText("Current contact")).toBeNull();
  expect(screen.queryByRole("button", {name: "Retry unchanged outreach action"})).toBeNull();
  await act(async () => {finish(workspace()); await refresh;});
  await waitFor(() => expect(screen.getByRole("button", {name: "Retry unchanged outreach action"})).toHaveProperty("disabled", false));
  expect(screen.getByLabelText("Next action")).toHaveProperty("value", "Unsaved private next step");
  fireEvent.click(screen.getByRole("button", {name: "Retry unchanged outreach action"}));
  await waitFor(() => expect(outreach.generate).toHaveBeenCalledTimes(2));
  expect(outreach.generate.mock.calls[1][0]).toEqual(original);
});
it("hides and blocks retained child work when parent refresh denies access", async () => {
  const view = recoveryHarness(); await interrupted(view);
  transport.readPartnerWorkspace.mockRejectedValue(Object.assign(new Error("Revoked"), {code: "functions/permission-denied"}));
  await act(async () => {await view.client.invalidateQueries({queryKey: ["partner-workspace"]});});
  await waitFor(() => expect(screen.queryByText("Private synthetic organizer")).toBeNull());
  expect(screen.queryByLabelText("Next action")).toBeNull();
  expect(screen.queryByLabelText("Current contact")).toBeNull();
  expect(screen.queryByRole("button", {name: "Retry unchanged outreach action"})).toBeNull();
  expect(outreach.generate).toHaveBeenCalledTimes(1);
  expect(outreach.review).not.toHaveBeenCalled(); expect(outreach.record).not.toHaveBeenCalled();
  transport.readPartnerWorkspace.mockImplementation(async () => workspace());
  fireEvent.click(screen.getByRole("button", {name: "Refresh partner access"}));
  await waitFor(() => expect(screen.getByRole("button", {name: "Retry unchanged outreach action"})).toHaveProperty("disabled", false));
  const original = outreach.generate.mock.calls[0][0];
  fireEvent.click(screen.getByRole("button", {name: "Retry unchanged outreach action"}));
  await waitFor(() => expect(outreach.generate).toHaveBeenCalledTimes(2));
  expect(outreach.generate.mock.calls[1][0]).toEqual(original);
});
it("allows an explicit exit after denied access without retrying the retained action", async () => {
  const view = recoveryHarness(); const onSignOut = vi.fn();
  render(<PartnerWorkspaceScreen actorUid="partner" isCurrentSession={() => true} onSignOut={onSignOut} />, view);
  await screen.findByLabelText("Current contact");
  fireEvent.change(screen.getByLabelText("Current contact"), {target: {value: "contact"}});
  fireEvent.change(screen.getByLabelText("Opportunity"), {target: {value: "opportunity"}});
  for (const kind of ["observation", "capability", "cta"]) fireEvent.click(screen.getByLabelText(`${kind}: ${kind} wording.`));
  fireEvent.click(screen.getByRole("button", {name: "Prepare draft from selected wording"}));
  await screen.findByRole("button", {name: "Retry unchanged outreach action"});
  await waitFor(() => expect(screen.getByRole("button", {name: "Retry unchanged outreach action"})).toHaveProperty("disabled", false));
  transport.readPartnerWorkspace.mockRejectedValue(Object.assign(new Error("Revoked"), {code: "functions/permission-denied"}));
  await act(async () => {await view.client.invalidateQueries({queryKey: ["partner-workspace"]});});
  await waitFor(() => expect(screen.queryByLabelText("Current contact")).toBeNull());
  const exit = screen.getByRole("button", {name: "Sign out"});
  expect(exit).toHaveProperty("disabled", false); fireEvent.click(exit);
  expect(onSignOut).toHaveBeenCalledOnce(); expect(outreach.generate).toHaveBeenCalledTimes(1);
});
