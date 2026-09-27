export type SalesResearchStatus =
  | "new"
  | "needs_research"
  | "ready_for_review"
  | "qualified"
  | "benchmark_only"
  | "no_fit"
  | "archived";
export type SalesTaskStatus = "open" | "completed" | "cancelled";
export type SalesTaskKind =
  | "research"
  | "reply"
  | "follow_up"
  | "demo"
  | "pilot"
  | "duplicate_review"
  | "opt_out"
  | "service_commitment";
export type SalesOpportunityStage =
  | "new_enquiry"
  | "ready_to_contact"
  | "contacted"
  | "in_conversation"
  | "demo_arranged"
  | "demo_completed"
  | "pilot_agreed"
  | "pilot_running"
  | "commercial_discussion"
  | "closed_won"
  | "closed_lost";

/** Resolved afresh by the caller; delegated clients have explicit scopes. */
export interface SalesPrincipal {
  uid: string;
  roles: readonly string[];
  clientId?: string;
  clientAuthUid?: string;
  delegationId?: string;
  organizerIds?: readonly string[];
  allowedActions?: readonly string[];
  fieldIds?: readonly string[];
  readEndpoints?: boolean;
}

export interface SalesAccount {
  schemaVersion: 1;
  classification: "sales_private";
  organizerId: string;
  revision: number;
  researchStatus: SalesResearchStatus;
  assignedOwnerUid: string | null;
  summary: string | null;
  nextAction: string | null;
  suppressionStatus: "clear" | "held" | "suppressed";
  suppressionReason?: string | null;
  suppressionAt?: string | null;
  suppressionBy?: string | null;
  duplicateReviewRequired: boolean;
  qualificationPolicy: {
    policyId: string;
    version: string;
    policyHash: string;
  } | null;
  name: string;
  city: string | null;
  market: string | null;
  marketLabel: string | null;
  eventTypes: string[];
  cohortIds: string[];
  searchTokens: string[];
  createdAt: string;
  updatedAt: string;
  updatedBy: string;
}

export interface SalesTask {
  schemaVersion: 1;
  classification: "sales_private";
  taskId: string;
  organizerId: string;
  contactId: string | null;
  revision: number;
  kind: SalesTaskKind;
  title: string;
  dueAt: string | null;
  ownerUid: string;
  status: SalesTaskStatus;
  createdAt: string;
  updatedAt: string;
  updatedBy: string;
}

export interface SalesOpportunity {
  schemaVersion: 1;
  classification: "sales_private";
  opportunityId: string;
  organizerId: string;
  revision: number;
  motion: string;
  stage: SalesOpportunityStage;
  ownerUid: string;
  nextStep: string | null;
  nextStepAt: string | null;
  stageEnteredAt: string;
  createdAt: string;
  updatedAt: string;
  updatedBy: string;
}

export interface SalesActivity {
  schemaVersion: 1;
  classification: "sales_private";
  activityId: string;
  organizerId: string;
  opportunityId: string | null;
  type:
    | "note"
    | "reply"
    | "call"
    | "demo"
    | "pilot"
    | "correction"
    | "outreach_sent_manual"
    | "claim_requested"
    | "claim_approved"
    | "claim_rejected";
  source?: {
    kind: "organizer_claim";
    claimRequestId: string;
    transitionId: string;
  };
  channel: "email" | "whatsapp" | "other" | null;
  outcome: "actor_attested_sent" | null;
  providerConfirmed: false;
  occurredAt: string;
  recordedAt: string;
  note: string;
  actorUid: string;
}

export interface SalesCustomField {
  schemaVersion: 1;
  classification: "sales_private";
  fieldId: string;
  label: string;
  normalizedLabel: string;
  type: "string" | "number" | "boolean" | "date" | "enum";
  recordType: "account";
  helpText: string | null;
  enumOptions: string[];
  revision: 1;
  createdAt: string;
  createdBy: string;
}

export type SalesReadAction =
  | "hosts.search"
  | "hosts.get"
  | "tasks.list"
  | "opportunities.list"
  | "fields.list"
  | "receipts.get"
  | "intents.list"
  | "imports.preview"
  | "contacts.list"
  | "evidence.list";
export type SalesMutationAction =
  | "hosts.create"
  | "hosts.update"
  | "tasks.upsert"
  | "opportunities.upsert"
  | "activities.log"
  | "fields.create"
  | "fields.setValue"
  | "intents.link"
  | "imports.apply"
  | "contacts.upsert"
  | "evidence.add"
  | "accounts.setSuppression"
  | "contacts.setContactability";

export interface SalesActionReceipt {
  schemaVersion: 1;
  classification: "sales_private";
  requestId: string;
  requestHash: string;
  action: SalesMutationAction;
  actorUid: string;
  clientId: string | null;
  clientAuthUid: string | null;
  delegationId: string | null;
  organizerId: string | null;
  createdAt: string;
  result: unknown;
}
