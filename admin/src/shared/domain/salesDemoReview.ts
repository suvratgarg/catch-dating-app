/** Minimal synthetic composition, independent of private blueprint and invitation records. */
export interface DemoReviewPreview {
  brandName: string; headline: string; scenario: string; steps: string[];
  retainedTools: string[]; limitations: string[]; cta: string;
}
export type DemoReviewWording = Pick<DemoReviewPreview, "headline" | "scenario" | "cta">;
export interface PartnerDemoReviewRow {
  organizerId: string; assignmentRevision: number; blueprintId: string; blueprintRevision: number;
  preview: DemoReviewPreview; previewHash: string; validUntil: string; evaluatedAt: string;
  synthetic: true; interactiveAvailable: false; sendAuthority: false;
  capabilityApprovalAuthority: false; organizerControlAuthority: false;
  proposalRevision: number; proposedWording: DemoReviewWording | null;
}
