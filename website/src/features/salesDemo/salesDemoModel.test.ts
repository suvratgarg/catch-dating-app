import {describe, expect, it, vi} from "vitest";
import {grantFromSalesDemoFragment, salesDemoApiFromCallable} from
  "./salesDemoModel";

describe("private demo link contract", () => {
  it("accepts only a grant in the URL fragment", () => {
    const grant = "A".repeat(43);
    expect(grantFromSalesDemoFragment(`#grant=${grant}`)).toBe(grant);
    expect(grantFromSalesDemoFragment(`#grant=${grant.slice(1)}`)).toBeNull();
    expect(grantFromSalesDemoFragment(`?grant=${grant}`)).toBeNull();
    expect(grantFromSalesDemoFragment("#preview=true")).toBeNull();
  });

  it("routes each operation to the exact callable without adding link data", async () => {
    const invoke = vi.fn().mockResolvedValue({});
    const api = salesDemoApiFromCallable(invoke);
    await api.preview({invitationId: "invite-1"});
    await api.start({invitationId: "invite-1", grantToken: "A".repeat(43),
      requestId: "request-1"});
    await api.getSession({sessionId: "session-1", grantToken: "A".repeat(43)});
    await api.advance({sessionId: "session-1", grantToken: "A".repeat(43),
      requestId: "request-2", expectedRevision: 1,
      action: "reviewApplication", choice: "approve"});
    expect(invoke.mock.calls.map(([name]) => name)).toEqual([
      "getSalesDemoPreview", "startSalesDemo", "getSalesDemoSession",
      "advanceSalesDemo",
    ]);
    expect(invoke.mock.calls[0][1]).toEqual({invitationId: "invite-1"});
  });
});
