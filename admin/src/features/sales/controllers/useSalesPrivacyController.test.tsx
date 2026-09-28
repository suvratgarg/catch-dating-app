import {act, renderHook, waitFor} from "@testing-library/react";
import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import {expect, it, vi} from "vitest";
import type {ReactNode} from "react";
import {AdminPendingOperationProvider} from
  "../../../shared/pendingOperation";
import type {PrivacyApi, PrivacyCase, PrivacyPreview} from
  "../api/salesPrivacyTypes";
import {useSalesPrivacyController} from "./useSalesPrivacyController";

const hash = "a".repeat(64);
const caseData: PrivacyCase = {organizerId: "org-a", restricted: true,
  restriction: {status: "restricted", revision: 2,
    restrictedAt: "2026-09-28T10:00:00.000Z", reason: "Owner review"},
  plan: {planId: "privacy-" + "b".repeat(40), organizerId: "org-a",
    policyHash: hash, inventoryHash: hash, cursor: 0, itemCount: 3,
    retainedCount: 1, unresolvedCount: 1, blockers: [], status: "reviewed"},
  policy: {revision: 1, policyHash: hash,
    sourceReference: "Reviewed file", reviewedAt: "2026-09-28T10:00:00.000Z",
    financeDisposition: "retain_pending_finance_review",
    auditDisposition: "retain_pending_audit_review",
    financeReason: "Reconciliation", auditReason: "Audit"},
  completeDeletion: false};
const preview: PrivacyPreview = {organizerId: "org-a",
  restrictionRevision: 2, activePlanId: caseData.plan!.planId,
  policyHash: hash, inventoryHash: "c".repeat(64),
  counts: {deletable: 2, retained: 1, unresolved: 1},
  blockers: [], overflow: false, effectsApplied: false};
function fixture() {
  const api: PrivacyApi = {
    getCase: vi.fn().mockResolvedValue(caseData),
    reviewPolicy: vi.fn().mockResolvedValue({policy: caseData.policy}),
    restrict: vi.fn().mockResolvedValue({restriction: caseData.restriction}),
    preview: vi.fn().mockResolvedValue(preview),
    reviewPlan: vi.fn().mockResolvedValue({plan: caseData.plan}),
    applyBatch: vi.fn().mockResolvedValue({batch: {organizerId: "org-a",
      planId: caseData.plan!.planId, previousCursor: 0, nextCursor: 3,
      itemCount: 3, deletedCount: 2, retainedCount: 1,
      unresolvedCount: 1, status: "internal_processed_with_unresolved",
      completeDeletion: false, receiptId: "privacy-batch-" + "d".repeat(40)}}),
  };
  const client = new QueryClient({defaultOptions: {queries: {retry: false}}});
  const wrapper = ({children}: {children: ReactNode}) =>
    <QueryClientProvider client={client}>
      <AdminPendingOperationProvider>{children}</AdminPendingOperationProvider>
    </QueryClientProvider>;
  const hook = renderHook(() => useSalesPrivacyController({
    actorUid: "owner-a", organizerId: "org-a", api}), {wrapper});
  return {api, hook};
}

it("reviews the exact preview including active plan for safe replacement", async () => {
  const {api, hook} = fixture();
  await waitFor(() => expect(hook.result.current.caseQuery.isSuccess).toBe(true));
  await act(async () => {await hook.result.current.loadPreview();});
  await act(async () => {await hook.result.current.reviewPlan();});
  expect(api.reviewPlan).toHaveBeenCalledWith(expect.objectContaining({
    organizerId: "org-a", restrictionRevision: 2,
    expectedActivePlanId: caseData.plan!.planId,
    policyHash: hash, inventoryHash: preview.inventoryHash}));
});

it("retains the same request ID after an uncertain batch outcome", async () => {
  const {api, hook} = fixture();
  await waitFor(() => expect(hook.result.current.caseQuery.isSuccess).toBe(true));
  vi.mocked(api.applyBatch).mockRejectedValueOnce(new Error("network lost"));
  await act(async () => {await hook.result.current.applyBatch();});
  expect(hook.result.current.pending?.kind).toBe("batch");
  await act(async () => {await hook.result.current.retryPending();});
  const calls = vi.mocked(api.applyBatch).mock.calls;
  expect(calls).toHaveLength(2);
  expect(calls[1][0]).toEqual(calls[0][0]);
  expect(hook.result.current.pending).toBeNull();
});

it("clears stale preview after a definitive revision conflict", async () => {
  const {api, hook} = fixture();
  await waitFor(() => expect(hook.result.current.caseQuery.isSuccess).toBe(true));
  await act(async () => {await hook.result.current.loadPreview();});
  vi.mocked(api.reviewPlan).mockRejectedValueOnce(Object.assign(
    new Error("Plan changed; preview again"), {code: "functions/aborted"}));
  await act(async () => {await hook.result.current.reviewPlan();});
  expect(hook.result.current.preview).toBeNull();
  expect(hook.result.current.pending).toBeNull();
  expect(hook.result.current.error).toMatch(/preview again/u);
});
