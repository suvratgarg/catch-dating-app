import {act, cleanup, renderHook, waitFor} from "@testing-library/react";
import {afterEach, expect, it, vi} from "vitest";
import {createQueryHarness} from "../../../shared/test/queryHarness";
import {useSalesDemoPartnerReviewController} from "./useSalesDemoPartnerReviewController";
const fingerprint = "a".repeat(64);
const preview = {brandName: "Synthetic organizer", headline: "A clear sample", scenario: "Sample application review",
  steps: ["Review", "Prepare reply", "Admit sample"], retainedTools: ["Keep the existing form"],
  limitations: ["Synthetic only; no real messages or admissions."], cta: "Discuss a pilot"};
function currentOwner() {
  return {organizerId: "organizer-one", blueprintId: "blueprint-one", blueprintRevision: 7, partnerUid: "partner-one", assignmentRevision: 3,
    preview, previewHash: fingerprint, sharingRevision: 0, proposedWording: null, proposalRevision: 0, sharingState: "none" as const,
    expiresAt: null, sharingCurrent: false, maximumExpiresAt: new Date(Date.now() + 3600_000).toISOString(), evaluatedAt: new Date().toISOString(),
    sendAuthority: false as const, capabilityApprovalAuthority: false as const, organizerControlAuthority: false as const};
}
function fixture() {
  const api = {get: vi.fn(async () => currentOwner()), share: vi.fn().mockResolvedValue({})};
  const props = {actorUid: "owner-one", organizerId: "organizer-one", blueprintId: "blueprint-one", blueprintRevision: 7, parentAccessCurrent: true, api};
  return {api, props};
}
afterEach(() => {cleanup(); vi.restoreAllMocks();});
it("freezes recipient, independent sharing revision, expiry and request id for an uncertain action", async () => {
  const {api, props} = fixture(); api.share.mockRejectedValueOnce(new Error("Interrupted"));
  const {result, rerender} = renderHook((p) => useSalesDemoPartnerReviewController(p), {initialProps: props, ...createQueryHarness()});
  await waitFor(() => expect(result.current.data).not.toBeNull());
  const expiry = new Date(Date.now() + 1800_000).toISOString();
  await act(async () => {await result.current.share("share", expiry);});
  await act(async () => {await result.current.share("withdraw", null);}); expect(api.share).toHaveBeenCalledOnce();
  rerender({...props, parentAccessCurrent: false}); expect(result.current.data).toBeNull();
  await act(async () => {expect(await result.current.retry()).toBe(false);});
  rerender(props); await waitFor(() => expect(result.current.data).not.toBeNull());
  await act(async () => {expect(await result.current.retry()).toBe(true);});
  expect(api.share.mock.calls[1][0]).toEqual(api.share.mock.calls[0][0]);
  expect(api.share.mock.calls[0][0]).toEqual(expect.objectContaining({partnerUid: "partner-one", expectedAssignmentRevision: 3,
    expectedSharingRevision: 0, expectedBlueprintRevision: 7, expectedPreviewHash: fingerprint, expiresAt: expiry}));
});
it("hides stale blueprint/access, rejects expired UI authority and releases definitively rejected work", async () => {
  const {api, props} = fixture(); api.share.mockRejectedValueOnce(Object.assign(new Error("Stale"), {code: "functions/failed-precondition"}));
  const {result, rerender} = renderHook((p) => useSalesDemoPartnerReviewController(p), {initialProps: props, ...createQueryHarness()});
  await waitFor(() => expect(result.current.data).not.toBeNull());
  await act(async () => {await result.current.share("share", new Date(Date.now() + 1800_000).toISOString());});
  expect(result.current.ticket).toBeNull();
  rerender({...props, blueprintRevision: 8}); expect(result.current.data).toBeNull();
  await act(async () => {expect(await result.current.share("withdraw", null)).toBe(false);}); expect(api.share).toHaveBeenCalledOnce();
});
