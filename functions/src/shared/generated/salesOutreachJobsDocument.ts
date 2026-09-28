/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import type {OutreachDraftingInput} from "./outreachDraftingInput";
import type {AdminBuildSalesOutreachInputPayload} from "./adminSalesIntelligenceDraftCallablePayload";

/**
 * Private frozen zero-model draft request, attempt lease and completion pointer. Firestore is authoritative; local Operations files are temporary scratch only.
 */
export interface SalesOutreachJobsDocument {
  schemaVersion: 1;
  classification: "sales_private";
  jobId: string;
  actorUid: string;
  requestId: string;
  materialHash: string;
  sourceHash: string;
  sourceRequest: AdminBuildSalesOutreachInputPayload;
  frozenBundle: OutreachDraftingInput;
  status: "running" | "completed" | "failed";
  attemptCount: number;
  leaseOwner: string | null;
  leaseUntil: string | null;
  expiresAt: string;
  createdAt: string;
  updatedAt: string;
  result: {
    draftId: string;
    contentHash: string;
  } | null;
  failure: string | null;
}
