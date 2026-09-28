import {cleanup, render, screen, waitFor} from "@testing-library/react";
import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import {afterEach, expect, it, vi} from "vitest";
import {renderSalesFitQueueWorkspace} from "./SalesFitQueueWorkspace";

const mocks = vi.hoisted(() => ({mode: "sample" as "sample" | "live",
  list: vi.fn(), refresh: vi.fn(), refreshBatch: vi.fn()}));
vi.mock("../../../shared/api/dataMode", () => ({dataMode: () => mocks.mode}));
vi.mock("../api/salesFitQueueRepository", () => ({salesFitQueueApi: {
  list: mocks.list, refresh: mocks.refresh, refreshBatch: mocks.refreshBatch,
}}));
afterEach(() => {cleanup(); vi.clearAllMocks(); mocks.mode = "sample";});

function view() {
  const client = new QueryClient({defaultOptions: {queries: {retry: false}}});
  return render(<QueryClientProvider client={client}>
    {renderSalesFitQueueWorkspace("employee", vi.fn())}
  </QueryClientProvider>);
}

it("does not present sample hosts as reviewed fit", () => {
  view();
  expect(screen.getByText(/Sample hosts do not carry reviewed scores/u)).toBeTruthy();
  expect(mocks.list).not.toHaveBeenCalled();
});

it("shows unknown scores and page-scoped expiry without outreach authority", async () => {
  mocks.mode = "live";
  mocks.list.mockResolvedValue({rows: [{organizerId: "org-a",
    policyId: "synthetic", policyRevision: 2, policyVersion: "v1",
    sourceHash: "a".repeat(64), accountRevision: 3,
    qualificationExpiresAt: null, qualificationPolicyHash: null, status: "needs_research", score: null,
    priority: "unranked", eligibleForOutreachReview: false,
    suppressionStatus: "clear", duplicateReviewRequired: false,
    researchStatus: "needs_research", name: "Sample Harbor",
    city: "City", assignedOwnerUid: null, expiresAt: null,
    evaluatedAt: "2026-09-28T10:00:00.000Z"}],
  nextCursor: null, generation: 4, policyRevision: 2,
  qualificationPolicyHash: null, omittedExpiredInPage: 2});
  view();
  await waitFor(() => expect(screen.getByText("Sample Harbor")).toBeTruthy());
  expect(screen.getByText(/Unknown · more reviewed evidence needed/u)).toBeTruthy();
  expect(screen.getByText(/2 expired ranking\(s\) were omitted/u)).toBeTruthy();
  expect(screen.getByText(/does not authorize contacting anyone/u)).toBeTruthy();
});
