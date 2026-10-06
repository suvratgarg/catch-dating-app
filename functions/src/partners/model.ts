import {fail, hash, id, iso, object, requestId, revision, text} from
  "../admin/salesIntelligence/model";
export {fail, hash, id, iso, object, requestId, revision, text};

export const PARTNER_TERMS_VERSION = "referral-preview-v1";
export const MEMBERSHIPS = "salesPartnerMemberships";
export const ASSIGNMENTS = "salesPartnerAssignments";
export interface PartnerMarketingGrant {
  schemaVersion: 1; grantId: string; revision: number;
  status: "active" | "revoked"; organizerId: string; campaignId: string;
  channel: "email" | "whatsapp" | "other"; assetIds: string[];
  approvalReceiptId: string; approvedMembershipRevision: number;
  assignmentRevision: number; sourceHash: string; expiresAt: string;
  reviewedAt: string; reviewedBy: string; reason: string;
  purpose: "manual_partner_outreach";
}
export interface PartnerMembership {
  schemaVersion: 1; classification: "sales_private"; uid: string;
  revision: number; status: "active" | "revoked";
  termsVersion: string; acceptedAt: string; expiresAt: string;
  displayName: string; createdAt: string; updatedAt: string;
  marketingGrants: PartnerMarketingGrant[];
}
export interface PartnerAssignment {
  schemaVersion: 1; classification: "sales_private";
  organizerId: string; partnerUid: string; revision: number;
  status: "offered" | "accepted" | "declined" | "revoked";
  originatorUid: string | null; introducingSenderUid: string | null;
  catchOwnerUid: string; activationOwnerUid: string | null;
  relationshipContext: string | null;
  relationshipConfirmedAt: string | null; channel: "email" | "whatsapp" | "other" | null;
  nextAction: string; reviewAt: string; expiresAt: string;
  assignedAt: string; updatedAt: string; reason: string;
}
export interface PartnerActor {uid: string; roles: readonly string[]}
export interface PartnerDeps {
  db: FirebaseFirestore.Firestore; now: () => Date;
  // Required at every boundary and inside every retry. Never infer fresh Auth
  // authority from a membership or an old custom-claim token.
  checkAuth: (actor: PartnerActor, employee: boolean) => Promise<void>;
}
export function employee(actor: PartnerActor): void {
  if (!actor.uid || !actor.roles.some((r) => r === "admin" || r === "adminOwner")) {
    fail("permission-denied", "Current Sales employee review is required.");
  }
}
export function expectRevision(actual: unknown, expected: number): void {
  if (actual !== expected) fail("aborted", "Record changed; refresh before reviewing.");
}
export function future(value: unknown, now: Date, maxDays = 90): string {
  const result = iso(value);
  const span = Date.parse(result) - now.getTime();
  if (span <= 0 || span > maxDays * 86400000) {
    fail("invalid-argument", "Choose a future review within the permitted window.");
  }
  return result;
}
export function officialUrl(value: unknown): string {
  const result = text(value, 512);
  try {
    const url = new URL(result);
    if (url.protocol !== "https:" || url.username || url.password ||
        !url.hostname.includes(".") || url.hash) throw new Error();
    return url.href;
  } catch { return fail("invalid-argument", "An HTTPS organizer or event URL is required."); }
}
