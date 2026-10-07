import {describe, expect, it} from "vitest";
import {parsePartnerWorkspace} from "./partnerWorkspaceResponse";

function workspace() {
  return {membership: {uid: "partner", displayName: "Partner",
    termsVersion: "referral-preview-v1", expiresAt: "2026-12-01T00:00:00.000Z"},
  leads: [{assignment: {organizerId: "synthetic", revision: 1, status: "accepted",
    nextAction: "Review sourced proposal", reviewAt: "2026-10-06T00:00:00.000Z",
    expiresAt: "2026-11-01T00:00:00.000Z", relationshipContext: null, channel: null},
  organizer: {organizerId: "synthetic", name: "Synthetic organizer", city: null,
    claimState: "unclaimed"}}], submissions: [], nextCursor: null, sendAuthority: false};
}

describe("private partner response boundary", () => {
  it("accepts the bounded projection without changing claim or send authority", () => {
    const value = workspace();
    expect(parsePartnerWorkspace(value)).toBe(value);
  });
  it("accepts a canonical empty city and requires truthful submission linkage", () => {
    const value = workspace();
    Object.assign(value.leads[0].organizer, {city: ""});
    expect(parsePartnerWorkspace(value)).toBe(value);
    for (const submission of [
      {intentId: "nomination", name: "Synthetic", status: "linked", organizerId: null},
      {intentId: "nomination", name: "Synthetic", status: "dismissed", organizerId: "synthetic"},
    ]) {
      expect(() => parsePartnerWorkspace({...workspace(), submissions: [submission]})).toThrow();
    }
  });
  it("rejects staff-only fields rather than retaining them in the cache", () => {
    const value = workspace();
    Object.assign(value.leads[0].assignment, {catchOwnerUid: "private-employee"});
    expect(() => parsePartnerWorkspace(value)).toThrow("response is invalid");
  });
  it("rejects mismatched and repeated canonical identities", () => {
    const value = workspace();
    value.leads[0].organizer.organizerId = "foreign";
    expect(() => parsePartnerWorkspace(value)).toThrow();
    const duplicate = workspace();
    duplicate.leads.push(duplicate.leads[0]);
    expect(() => parsePartnerWorkspace(duplicate)).toThrow();
  });
  it("rejects unbounded lists, malformed deadlines and sending authority", () => {
    const values = [workspace(), workspace(), workspace()];
    values[0].leads = Array.from({length: 26}, () => workspace().leads[0]);
    values[1].membership.expiresAt = "unknown";
    values[2].sendAuthority = true;
    for (const value of values) expect(() => parsePartnerWorkspace(value)).toThrow();
  });
});
