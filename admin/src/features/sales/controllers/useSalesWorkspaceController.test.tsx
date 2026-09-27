import {act, renderHook, waitFor} from "@testing-library/react";
import {beforeEach, describe, expect, it, vi} from "vitest";
import {createQueryHarness} from "../../../shared/test/queryHarness";
import {salesErrorMessage, toLocalDateTimeInput,
  useSalesWorkspaceController} from
  "./useSalesWorkspaceController";

const repository = vi.hoisted(() => ({
  getSalesAccount: vi.fn(),
  createSalesAccount: vi.fn(),
  listSalesAccounts: vi.fn(),
  listSalesTasks: vi.fn(),
  listSalesOpportunities: vi.fn(),
  listSalesInboundIntents: vi.fn(),
  linkSalesInboundIntent: vi.fn(),
  listSalesCustomFields: vi.fn(),
  createSalesCustomField: vi.fn(),
  setSalesCustomFieldValue: vi.fn(),
  searchCanonicalOrganizers: vi.fn(),
  recordSalesActivity: vi.fn(),
  updateSalesAccount: vi.fn(),
  upsertSalesTask: vi.fn(),
  upsertSalesOpportunity: vi.fn(),
}));
vi.mock("../api/salesRepository", () => repository);

const firstPage = {
  rows: [{organizerId: "host-one", name: "Sample Host", city: "Mumbai",
    market: "India", eventTypes: ["social"], researchStatus: "needs_research",
    fitLabel: null, stage: null, assignedOwnerUid: null, nextAction: null}],
  nextCursor: "opaque-page-two",
};

describe("useSalesWorkspaceController", () => {
  beforeEach(() => {
    Object.values(repository).forEach((mock) => mock.mockReset());
    repository.listSalesAccounts.mockResolvedValue(firstPage);
    repository.listSalesTasks.mockResolvedValue({rows: [], nextCursor: null});
    repository.listSalesOpportunities.mockResolvedValue({rows: [], nextCursor: null});
    repository.listSalesInboundIntents.mockResolvedValue({rows: [], nextCursor: null});
    repository.listSalesCustomFields.mockResolvedValue({rows: []});
    repository.searchCanonicalOrganizers.mockResolvedValue([]);
  });

  it("passes filters and the opaque cursor to the bounded server query", async () => {
    const {wrapper} = createQueryHarness();
    const {result} = renderHook(() => useSalesWorkspaceController({
      area: "hosts", selectedOrganizerId: null,
      onError: vi.fn(), onNotice: vi.fn(),
    }), {wrapper});
    await waitFor(() => expect(result.current.accounts.data?.rows).toHaveLength(1));
    act(() => result.current.setAccountFilters({researchStatus: "needs_research"}));
    await waitFor(() => expect(repository.listSalesAccounts).toHaveBeenCalledWith({
      limit: 25, cursor: undefined, query: undefined, ownerUid: undefined,
      researchStatus: "needs_research",
    }));
    await waitFor(() => expect(result.current.accounts.data?.nextCursor)
      .toBe("opaque-page-two"));
    act(() => result.current.nextPage());
    await waitFor(() => expect(repository.listSalesAccounts).toHaveBeenCalledWith({
      limit: 25, cursor: "opaque-page-two", query: undefined,
      ownerUid: undefined, researchStatus: "needs_research",
    }));
  });

  it("reuses the request ID after an uncertain failure and reports no success", async () => {
    const {wrapper} = createQueryHarness();
    const onError = vi.fn();
    const onNotice = vi.fn();
    repository.updateSalesAccount.mockRejectedValueOnce(new Error("network unavailable"))
      .mockResolvedValueOnce({account: {}, receipt: {requestId: "saved", revision: 2}});
    const {result} = renderHook(() => useSalesWorkspaceController({
      area: "hosts", selectedOrganizerId: null, onError, onNotice,
    }), {wrapper});
    const input = {organizerId: "host-one", expectedRevision: 1,
      patch: {nextAction: "Follow up"}};
    let first = true;
    await act(async () => { first = await result.current.saveAccount(input); });
    expect(first).toBe(false);
    expect(onNotice).not.toHaveBeenCalledWith("Host research saved.");
    expect(onError).toHaveBeenCalledWith("network unavailable");
    let second = false;
    await act(async () => { second = await result.current.saveAccount(input); });
    expect(second).toBe(true);
    const firstRequest = repository.updateSalesAccount.mock.calls[0][0].requestId;
    const secondRequest = repository.updateSalesAccount.mock.calls[1][0].requestId;
    expect(secondRequest).toBe(firstRequest);
    expect(onNotice).toHaveBeenCalledWith("Host research saved.");
  });

  it("explains revision conflicts without losing the operator's edit", () => {
    expect(salesErrorMessage(new Error("ABORTED: revision mismatch")))
      .toContain("Compare the latest details");
    expect(salesErrorMessage(new Error("failed-precondition: Suppressed host")))
      .toContain("Suppressed host");
  });

  it("formats activity time in the employee's local timezone", () => {
    const originalTimezone = process.env.TZ;
    try {
      process.env.TZ = "Asia/Kolkata";
      expect(toLocalDateTimeInput(new Date("2026-09-28T00:00:00.000Z")))
        .toBe("2026-09-28T05:30");
    } finally {
      process.env.TZ = originalTimezone;
    }
  });
});
