import {describe, expect, it} from "vitest";
import {parsePartnerDemoReviews} from "./partnerDemoReview";
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
const scope = {organizerId: "organizer-one", expectedAssignmentRevision: 3};
describe("strict private preview boundary", () => {
  it("accepts ordinary wording while withholding private metadata", () => {
    const value = partnerList(); Object.assign(value.rows[0], {proposedWording: {headline: "Useful future flow", scenario: "Review form answers", cta: "Discuss a pilot"}});
    expect(parsePartnerDemoReviews(value, scope)).toBe(value);
    for (const extra of [{partnerUid: "other-private"}, {fieldMappings: []}, {grantToken: "SECRET"}]) {
      const changed = partnerList(); Object.assign(changed.rows[0], extra);
      expect(() => parsePartnerDemoReviews(changed, scope)).toThrow();
    }
  });
  it("rejects control characters, foreign/repeated scope and fake authority", () => {
    for (const patch of [{organizerId: "foreign"}, {assignmentRevision: 4}, {sendAuthority: true}, {interactiveAvailable: true},
      {proposedWording: {headline: "a\u0001b", scenario: "A sample", cta: "Talk"}}]) {
      const value = partnerList(); Object.assign(value.rows[0], patch); expect(() => parsePartnerDemoReviews(value, scope)).toThrow();
    }
    const repeated = partnerList(); repeated.rows.push(repeated.rows[0]); expect(() => parsePartnerDemoReviews(repeated, scope)).toThrow();
  });
});
