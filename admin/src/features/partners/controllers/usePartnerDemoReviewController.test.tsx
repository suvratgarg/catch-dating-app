import {act, cleanup, renderHook, waitFor} from "@testing-library/react";
import {afterEach, expect, it, vi} from "vitest";
import {createQueryHarness} from "../../../shared/test/queryHarness";
import {usePartnerDemoReviewController} from "./usePartnerDemoReviewController";
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
function fixture() {
  const api = {list: vi.fn(async () => partnerList()), propose: vi.fn().mockResolvedValue({})};
  const props = {actorUid: "partner-one", organizerId: "organizer-one", assignmentRevision: 3,
    accessExpiresAt: new Date(Date.now() + 3600_000).toISOString(), isCurrentSession: () => true, parentAccessCurrent: true, api};
  return {api, props};
}
afterEach(() => {cleanup(); vi.restoreAllMocks();});
it("retains exact interrupted wording through access refresh and blocks concurrent/revised proposals", async () => {
  const {api, props} = fixture(); api.propose.mockRejectedValueOnce(new Error("Interrupted"));
  const {result, rerender} = renderHook((p) => usePartnerDemoReviewController(p), {initialProps: props, ...createQueryHarness()});
  await waitFor(() => expect(result.current.data).not.toBeNull());
  const row = result.current.data!.rows[0]; const words = {headline: "Useful sample", scenario: "A sample flow", cta: "Talk"};
  await act(async () => {await result.current.propose(row, words);});
  expect(result.current.ticket).not.toBeNull();
  await act(async () => {await result.current.propose(row, {...words, cta: "Changed"});});
  expect(api.propose).toHaveBeenCalledOnce();
  rerender({...props, parentAccessCurrent: false}); expect(result.current.data).toBeNull();
  await act(async () => {expect(await result.current.retry()).toBe(false);});
  expect(api.propose).toHaveBeenCalledOnce();
  rerender(props); await waitFor(() => expect(result.current.data).not.toBeNull());
  await act(async () => {expect(await result.current.retry()).toBe(true);});
  expect(api.propose.mock.calls[1][0]).toEqual(api.propose.mock.calls[0][0]); expect(result.current.ticket).toBeNull();
});
it("hides cached previews on denied refresh and refuses expired or revoked actions", async () => {
  const {api, props} = fixture(); const {result} = renderHook(() => usePartnerDemoReviewController(props), createQueryHarness());
  await waitFor(() => expect(result.current.data).not.toBeNull()); const row = result.current.data!.rows[0];
  api.list.mockRejectedValue(new Error("Revoked"));
  await act(async () => {await result.current.refresh();});
  await waitFor(() => expect(result.current.query.isError).toBe(true)); expect(result.current.data).toBeNull();
  await act(async () => {expect(await result.current.propose(row, preview)).toBe(false);}); expect(api.propose).not.toHaveBeenCalled();
});
it("does not retain a late previous actor reply or recover their ticket", async () => {
  const {api, props} = fixture(); let finish!: (value: unknown) => void;
  api.propose.mockImplementationOnce(() => new Promise((resolve) => {finish = resolve;}));
  const {result, rerender} = renderHook((p) => usePartnerDemoReviewController(p), {initialProps: props, ...createQueryHarness()});
  await waitFor(() => expect(result.current.data).not.toBeNull()); let work!: Promise<boolean>;
  await act(async () => {work = result.current.propose(result.current.data!.rows[0], preview);});
  rerender({...props, actorUid: "partner-two"});
  await act(async () => {finish({}); await work;}); expect(result.current.notice).toBeNull(); expect(result.current.ticket).toBeNull();
});
