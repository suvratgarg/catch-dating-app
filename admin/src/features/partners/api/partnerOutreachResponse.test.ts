import {describe, expect, it} from "vitest";
import {parsePartnerOutreachResponse} from "./partnerOutreachResponse";

function preparation() {
  return {organizerId: "synthetic", assignmentRevision: 1, researchStatus: "qualified",
    contacts: [{contactId: "contact", displayName: "Synthetic contact", role: "Founder"}],
    opportunities: [{opportunityId: "opportunity", stage: "ready_to_contact", motion: "Event pilot"}],
    clauses: [{clauseId: "observation", kind: "observation", text: "Public observation.", revision: 1,
      validUntil: "2026-12-01T00:00:00.000Z", evidence: [{evidenceId: "public-source",
        sourceRef: "https://public.example.test/events", observedAt: "2026-10-01T00:00:00.000Z",
        validThrough: null, excerpt: "Public page excerpt", confidence: "high"}]}],
    evaluatedAt: "2026-10-04T00:00:00.000Z", sendAuthority: false, capabilityApprovalAuthority: false};
}
describe("partner private response boundary", () => {
  it("accepts bounded preparation without granting send or capability authority", () => {
    const value = preparation(); expect(parsePartnerOutreachResponse("preparation", value)).toBe(value);
  });
  it("rejects staff notes, private endpoints and reviewer identity before retention", () => {
    for (const target of ["root", "contact", "opportunity", "clause", "citation"] as const) {
      const value = preparation();
      const row = {root: value, contact: value.contacts[0], opportunity: value.opportunities[0],
        clause: value.clauses[0], citation: value.clauses[0].evidence[0]}[target];
      Object.assign(row, {reviewerUid: "staff-private", endpoints: ["private@example.test"]});
      expect(() => parsePartnerOutreachResponse("preparation", value)).toThrow();
    }
  });
  it("rejects token-bearing, insecure and malformed public source URLs", () => {
    for (const sourceRef of ["http://public.example.test", "https://public.example.test/?signature=SECRET",
      "https://user:password@public.example.test/", "https://public.example.test/#SECRET", "https://host.local/"]) {
      const value = preparation(); value.clauses[0].evidence[0].sourceRef = sourceRef;
      expect(() => parsePartnerOutreachResponse("preparation", value)).toThrow();
    }
  });
  it("rejects unbounded preparation, invalid time and fabricated authority", () => {
    const values = [preparation(), preparation(), preparation(), preparation()];
    values[0].contacts = Array.from({length: 26}, () => preparation().contacts[0]);
    values[1].clauses[0].evidence[0].observedAt = "unknown";
    values[2].sendAuthority = true; values[3].capabilityApprovalAuthority = true;
    for (const value of values) expect(() => parsePartnerOutreachResponse("preparation", value)).toThrow();
  });
  it("rejects provider-confirmed delivery or employee fields on partner receipts", () => {
    const receipt = {organizerId: "synthetic", draftId: "draft-own", activityId: "manual-activity",
      exactContentHash: "a".repeat(64), occurredAt: "2026-10-04T00:00:00.000Z",
      outcome: "actor_attested_sent", providerConfirmed: false, sendAuthority: false};
    expect(parsePartnerOutreachResponse("record", receipt)).toBe(receipt);
    expect(() => parsePartnerOutreachResponse("record", {...receipt, providerConfirmed: true})).toThrow();
    expect(() => parsePartnerOutreachResponse("record", {...receipt, employeeUid: "staff"})).toThrow();
    expect(() => parsePartnerOutreachResponse("review", {draftId: "draft-own", exactContentHash: "a".repeat(64),
      compositionReviewed: true, capabilityApprovalAuthority: true, sendAuthority: false, providerConfirmed: false})).toThrow();
  });
});
