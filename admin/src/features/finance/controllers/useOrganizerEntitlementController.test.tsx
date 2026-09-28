import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import {act, renderHook, waitFor} from "@testing-library/react";
import type {PropsWithChildren} from "react";
import {beforeEach, describe, expect, it, vi} from "vitest";
import type {OrganizerEntitlementCallableResponse} from
  "../../../generated/contracts/organizerEntitlementCallableResponse";
import {
  parseCountValue,
  useOrganizerEntitlementController,
} from "./useOrganizerEntitlementController";

const mocks = vi.hoisted(() => ({
  loadOrganizerEntitlement: vi.fn(),
  grantOrganizerEntitlement: vi.fn(),
  revokeOrganizerEntitlementGrant: vi.fn(),
}));

vi.mock("../api/financeOpsRepository", () => mocks);

function createWrapper() {
  const queryClient = new QueryClient({
    defaultOptions: {mutations: {retry: false}},
  });
  return function Wrapper({children}: PropsWithChildren) {
    return <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>;
  };
}

const baseEntitlement: OrganizerEntitlementCallableResponse = {
  schemaVersion: 1,
  organizerId: "organizer-1",
  catalogVersion: 1,
  revision: 2,
  grants: [
    {
      grantId: "grant_existing-1",
      sku: "wedding_pro",
      skuLabel: "Wedding Pro",
      unit: "program",
      quantityTotal: 1,
      quantityConsumed: 0,
      quantityRemaining: 1,
      validFromMillis: 1_800_000_000_000,
      validUntilMillis: null,
      source: "manualInvoice",
      active: true,
      revoked: false,
    },
  ],
  meters: {flightDaysUsed: 0, waConversationsUsed: 0},
  skuCatalog: {
    wedding_pro: {
      label: "Wedding Pro",
      unit: "program",
      priceMinor: 5999900,
      currency: "INR",
      limits: {
        guests: 400,
        functions: 10,
        staffAssignments: 30,
        momentsPerFunction: null,
      },
      capabilitiesAllowed: [
        "arrivalsTransport",
        "accommodation",
        "forms",
        "messaging",
      ],
      includedFlightDays: 0,
      includedWaConversations: 0,
      stakeholderSeats: 6,
    },
    planner_annual: {
      label: "Planner annual (quote)",
      unit: "organizerYear",
      priceMinor: null,
      currency: "INR",
      limits: {
        guests: null,
        functions: null,
        staffAssignments: null,
        momentsPerFunction: null,
      },
      capabilitiesAllowed: [
        "arrivalsTransport",
        "accommodation",
        "forms",
        "messaging",
      ],
      includedFlightDays: 0,
      includedWaConversations: 0,
      stakeholderSeats: null,
    },
  },
};

describe("useOrganizerEntitlementController", () => {
  beforeEach(() => {
    window.sessionStorage.clear();
    Object.values(mocks).forEach((mock) => mock.mockReset());
    mocks.loadOrganizerEntitlement.mockResolvedValue(baseEntitlement);
  });

  it("loads the trimmed organizer scope and grants with a reused operation id", async () => {
    mocks.grantOrganizerEntitlement
      .mockRejectedValueOnce(new Error("temporary failure"))
      .mockResolvedValueOnce({
        schemaVersion: 1,
        organizerId: "organizer-1",
        revision: 3,
        grantId: "grant_entitlement-grant-reused",
        replayed: false,
      });
    mocks.loadOrganizerEntitlement
      .mockResolvedValueOnce(baseEntitlement)
      .mockResolvedValue({...baseEntitlement, revision: 3});
    const {result} = renderHook(() => useOrganizerEntitlementController({
      onError: vi.fn(),
      onNotice: vi.fn(),
    }), {wrapper: createWrapper()});

    act(() => result.current.setOrganizerId(" organizer-1 "));
    await act(async () => expect(await result.current.load()).toBe(true));
    expect(mocks.loadOrganizerEntitlement.mock.calls[0][0]).toEqual({
      organizerId: "organizer-1",
    });
    expect(result.current.entitlement?.revision).toBe(2);

    act(() => {
      result.current.setGrantField("sku", "planner_annual");
      result.current.setGrantField("quantity", "2");
      result.current.setGrantField("receiptRef", "INV-2026-0042");
      result.current.setGrantField("note", "Manual invoice reconciled.");
    });
    expect(result.current.grantForm.unit).toBe("organizerYear");

    await act(async () => expect(await result.current.grant()).toBe(false));
    await act(async () => expect(await result.current.grant()).toBe(true));

    const firstPayload = mocks.grantOrganizerEntitlement.mock.calls[0][0];
    const retryPayload = mocks.grantOrganizerEntitlement.mock.calls[1][0];
    expect(retryPayload.operationId).toBe(firstPayload.operationId);
    expect(retryPayload).toMatchObject({
      organizerId: "organizer-1",
      sku: "planner_annual",
      unit: "organizerYear",
      quantityTotal: 2,
      source: "manualInvoice",
      receiptRef: "INV-2026-0042",
      note: "Manual invoice reconciled.",
    });
    expect(firstPayload.operationId).toMatch(/^[A-Za-z0-9_-]{16,120}$/u);
    await waitFor(() => expect(result.current.entitlement?.revision).toBe(3));
  });

  it("revokes a loaded grant with a reason and refreshes the ledger", async () => {
    mocks.revokeOrganizerEntitlementGrant.mockResolvedValue({
      schemaVersion: 1,
      organizerId: "organizer-1",
      revision: 3,
      grantId: "grant_existing-1",
      replayed: false,
    });
    const {result} = renderHook(() => useOrganizerEntitlementController({
      onError: vi.fn(),
      onNotice: vi.fn(),
    }), {wrapper: createWrapper()});

    expect(result.current.revokeDisabledReason).toBe(
      "Load the current entitlement ledger first."
    );
    act(() => result.current.setOrganizerId("organizer-1"));
    await act(async () => void await result.current.load());

    act(() => result.current.setRevokeTargetGrantId("grant_existing-1"));
    expect(result.current.revokeDisabledReason).toBe("Add a revoke reason.");
    act(() => result.current.setRevokeReason("Invoice reversed."));
    await act(async () => expect(await result.current.revoke()).toBe(true));

    expect(mocks.revokeOrganizerEntitlementGrant.mock.calls[0][0]).toEqual(
      expect.objectContaining({
        organizerId: "organizer-1",
        grantId: "grant_existing-1",
        reason: "Invoice reversed.",
      })
    );
    expect(result.current.revokeTargetGrantId).toBeNull();
  });

  it("retries the frozen grant after edits and a page reload", async () => {
    mocks.grantOrganizerEntitlement
      .mockRejectedValueOnce(new Error("response lost"))
      .mockResolvedValueOnce({revision: 3, replayed: true});
    const first = renderHook(() => useOrganizerEntitlementController({
      onError: vi.fn(), onNotice: vi.fn(),
    }), {wrapper: createWrapper()});
    act(() => {
      first.result.current.setOrganizerId("organizer-1");
      first.result.current.setGrantField("receiptRef", "INV-ONE");
    });
    await act(async () => expect(await first.result.current.grant()).toBe(false));
    const frozen = mocks.grantOrganizerEntitlement.mock.calls[0][0];
    expect(first.result.current.pendingGrant).toEqual(frozen);
    act(() => {
      first.result.current.setOrganizerId("organizer-2");
      first.result.current.setGrantField("quantity", "9");
      first.result.current.setGrantField("receiptRef", "INV-TWO");
    });
    expect(first.result.current.pendingGrant).toEqual(frozen);
    first.unmount();

    const resumed = renderHook(() => useOrganizerEntitlementController({
      onError: vi.fn(), onNotice: vi.fn(),
    }), {wrapper: createWrapper()});
    expect(resumed.result.current.pendingGrant).toEqual(frozen);
    expect(resumed.result.current.grantDisabledReason).toBeNull();
    await act(async () => expect(await resumed.result.current.grant()).toBe(true));
    expect(mocks.grantOrganizerEntitlement.mock.calls[1][0]).toEqual(frozen);
    expect(resumed.result.current.pendingGrant).toBeNull();
    expect(resumed.result.current.organizerId).toBe("organizer-1");
    resumed.unmount();
  });

  it("clears a pending grant only after the ledger confirms its identity",
    async () => {
      mocks.grantOrganizerEntitlement.mockRejectedValueOnce(
        new Error("response lost"));
      const h = renderHook(() => useOrganizerEntitlementController({
        onError: vi.fn(), onNotice: vi.fn(),
      }), {wrapper: createWrapper()});
      act(() => {
        h.result.current.setOrganizerId("organizer-1");
        h.result.current.setGrantField("receiptRef", "INV-ONE");
      });
      await act(async () => expect(await h.result.current.grant()).toBe(false));
      const operationId = h.result.current.pendingGrant!.operationId;
      await act(async () => expect(await h.result.current.load()).toBe(true));
      expect(h.result.current.pendingGrant).not.toBeNull();
      mocks.loadOrganizerEntitlement.mockResolvedValue({
        ...baseEntitlement,
        grants: [...baseEntitlement.grants, {
          ...baseEntitlement.grants[0], grantId: `grant_${operationId}`,
        }],
      });
      await act(async () => expect(await h.result.current.load()).toBe(true));
      expect(h.result.current.pendingGrant).toBeNull();
      expect(mocks.grantOrganizerEntitlement).toHaveBeenCalledTimes(1);
      h.unmount();
    });

  it("retries the frozen revocation after editing and reload", async () => {
    mocks.revokeOrganizerEntitlementGrant
      .mockRejectedValueOnce(new Error("response lost"))
      .mockResolvedValueOnce({revision: 3, replayed: true});
    const first = renderHook(() => useOrganizerEntitlementController({
      onError: vi.fn(), onNotice: vi.fn(),
    }), {wrapper: createWrapper()});
    act(() => first.result.current.setOrganizerId("organizer-1"));
    await act(async () => expect(await first.result.current.load()).toBe(true));
    act(() => {
      first.result.current.setRevokeTargetGrantId("grant_existing-1");
      first.result.current.setRevokeReason("Invoice reversed");
    });
    await act(async () => expect(await first.result.current.revoke()).toBe(false));
    const frozen = mocks.revokeOrganizerEntitlementGrant.mock.calls[0][0];
    act(() => {
      first.result.current.setRevokeReason("Different reason");
      first.result.current.setRevokeTargetGrantId(null);
    });
    first.unmount();
    const resumed = renderHook(() => useOrganizerEntitlementController({
      onError: vi.fn(), onNotice: vi.fn(),
    }), {wrapper: createWrapper()});
    expect(resumed.result.current.pendingRevoke).toEqual(frozen);
    await act(async () => expect(await resumed.result.current.revoke()).toBe(true));
    expect(mocks.revokeOrganizerEntitlementGrant.mock.calls[1][0])
      .toEqual(frozen);
    expect(resumed.result.current.pendingRevoke).toBeNull();
    resumed.unmount();
  });
});

describe("parseCountValue", () => {
  it("accepts positive whole quantities and rejects the rest", () => {
    expect(parseCountValue("1")).toBe(1);
    expect(parseCountValue(" 40 ")).toBe(40);
    expect(parseCountValue("0")).toBeNull();
    expect(parseCountValue("1.5")).toBeNull();
    expect(parseCountValue("")).toBeNull();
  });
});
