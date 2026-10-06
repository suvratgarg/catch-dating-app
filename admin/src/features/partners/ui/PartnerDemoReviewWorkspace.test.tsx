import {act, cleanup, fireEvent, render, screen, waitFor} from "@testing-library/react";
import {afterEach, expect, it, vi} from "vitest";
import {createQueryHarness} from "../../../shared/test/queryHarness";
import {PartnerDemoReviewWorkspace} from "./PartnerDemoReviewWorkspace";
const fingerprint = "a".repeat(64);
const preview = {brandName: "Synthetic organizer", headline: "A clear sample", scenario: "Sample application review",
  steps: ["Review", "Prepare reply", "Admit sample"], retainedTools: ["Keep the existing form"],
  limitations: ["Synthetic only; no real messages or admissions."], cta: "Discuss a pilot"};
function currentRow() {
  return {organizerId: "organizer-one", assignmentRevision: 3, blueprintId: "blueprint-one", blueprintRevision: 7,
    preview, previewHash: fingerprint, validUntil: new Date(Date.now() + 3600_000).toISOString(), evaluatedAt: new Date().toISOString(),
    synthetic: true as const, interactiveAvailable: false as const, sendAuthority: false as const,
    capabilityApprovalAuthority: false as const, organizerControlAuthority: false as const, proposalRevision: 0, proposedWording: null};
}
function partnerList() {
  const row = currentRow(); return {organizerId: row.organizerId, assignmentRevision: 3, rows: [row], evaluatedAt: row.evaluatedAt,
    sendAuthority: false as const, capabilityApprovalAuthority: false as const, organizerControlAuthority: false as const};
}
afterEach(cleanup);
it("requires deliberate truthful wording review and sends only a pending wording proposal", async () => {
  const api = {list: vi.fn(async () => partnerList()), propose: vi.fn().mockResolvedValue({})};
  render(<PartnerDemoReviewWorkspace actorUid="partner-one" organizerId="organizer-one" assignmentRevision={3}
    accessExpiresAt={new Date(Date.now() + 3600_000).toISOString()} isCurrentSession={() => true} api={api} />, createQueryHarness());
  const send = await screen.findByRole("button", {name: "Propose wording for Owner review"}); expect(send).toHaveProperty("disabled", true);
  expect(screen.getByText("Synthetic only; no real messages or admissions.")).toBeTruthy();
  fireEvent.click(screen.getByLabelText("I reviewed the wording and kept the simulation limitations truthful"));
  fireEvent.change(screen.getByLabelText("Proposed headline"), {target: {value: "Useful future flow"}});
  expect(send).toHaveProperty("disabled", true);
  fireEvent.click(screen.getByLabelText("I reviewed the wording and kept the simulation limitations truthful"));
  expect(send).toHaveProperty("disabled", false); fireEvent.click(send);
  await waitFor(() => expect(api.propose).toHaveBeenCalledOnce());
  expect(api.propose.mock.calls[0][0].wording).toEqual({headline: "Useful future flow", scenario: preview.scenario, cta: preview.cta});
  expect(screen.queryByRole("button", {name: /Send|Invite|Claim/u})).toBeNull();
});

it("preserves unsaved wording and exact review through deferred same-source read refresh and parent hiding", async () => {
  const api = {list: vi.fn(async () => partnerList()), propose: vi.fn().mockResolvedValue({})}; const harness = createQueryHarness();
  const props = {actorUid: "partner-one", organizerId: "organizer-one", assignmentRevision: 3,
    accessExpiresAt: new Date(Date.now() + 3600_000).toISOString(), isCurrentSession: () => true, api};
  const {rerender} = render(<PartnerDemoReviewWorkspace {...props} />, harness);
  fireEvent.change(await screen.findByLabelText("Proposed headline"), {target: {value: "Unsaved useful wording"}});
  fireEvent.click(screen.getByLabelText("I reviewed the wording and kept the simulation limitations truthful"));
  let finish!: (value: ReturnType<typeof partnerList>) => void;
  api.list.mockImplementationOnce(() => new Promise((resolve) => {finish = resolve;})); let refresh!: Promise<void>;
  await act(async () => {refresh = harness.client.invalidateQueries({queryKey: ["partner-demo-review"]});});
  await waitFor(() => expect(screen.queryByLabelText("Proposed headline")).toBeNull());
  await act(async () => {finish(partnerList()); await refresh;});
  expect(await screen.findByLabelText("Proposed headline")).toHaveProperty("value", "Unsaved useful wording");
  expect(screen.getByLabelText("I reviewed the wording and kept the simulation limitations truthful")).toHaveProperty("checked", true);
  rerender(<PartnerDemoReviewWorkspace {...props} parentAccessCurrent={false} />);
  expect(screen.queryByLabelText("Proposed headline")).toBeNull();
  rerender(<PartnerDemoReviewWorkspace {...props} parentAccessCurrent />);
  expect(await screen.findByLabelText("Proposed headline")).toHaveProperty("value", "Unsaved useful wording");
  expect(api.propose).not.toHaveBeenCalled();
});
