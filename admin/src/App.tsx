import {useCallback, useEffect, useMemo, useState} from "react";
import type {ReactNode} from "react";
import {
  Activity,
  AlertTriangle,
  BarChart3,
  CheckCircle2,
  CircleDollarSign,
  Clock3,
  Database,
  FileWarning,
  FolderSearch,
  LineChart,
  Lock,
  RefreshCw,
  Save,
  Search,
  Settings2,
  ShieldAlert,
  Sparkles,
  UserCheck,
  Users,
} from "lucide-react";
import {onAuthStateChanged, User} from "firebase/auth";
import {auth, signInWithGoogle, signOutAdmin} from "./firebase";
import {
  dataMode,
  decideAccessApplication,
  decideClubClaim,
  decideOrganizerEventCandidate,
  decideOrganizerIntake,
  decideOrganizerPolicyGap,
  loadHostAnalytics,
  loadClubDetails,
  loadOverview,
  recordOrganizerCuration,
  resolveOrganizerEventLocation,
  saveClubDetails,
  setClubIndexStatus,
} from "./adminApi";
import {
  sampleHostAnalytics,
  sampleOverview,
} from "./sampleData";
import organizerIntakeBridgeJson from "./generated/organizerIntakeBridge.json";
import {
  AccessApplicationDecision,
  AdminClubDetails,
  AdminDecideOrganizerEventCandidateResponse,
  AdminDecideOrganizerIntakePayload,
  AdminDecideOrganizerIntakeResponse,
  AdminDecideOrganizerPolicyGapPayload,
  AdminDecideOrganizerPolicyGapResponse,
  AdminOverviewMetric,
  AdminOverviewResponse,
  AdminRecordOrganizerCurationPayload,
  AdminRecordOrganizerCurationResponse,
  AdminResolveOrganizerEventLocationResponse,
  AdminQueueItem,
  AdminUpdateClubDetailsPayload,
  ClubClaimDecision,
  ClubIndexDecision,
  HostAnalyticsQueryPayload,
  HostAnalyticsEventRow,
  HostAnalyticsResponse,
  OrganizerAppVisibility,
  OrganizerCurationOperation,
  OrganizerEntityKind,
  OrganizerEventCandidateDecision,
  OrganizerCurationSurface,
  OrganizerIntakeDecision,
  OrganizerPolicyGapDecision,
  OrganizerPublishStatus,
  OrganizerSourceConfidence,
  OrganizerSurfaceDecision,
  OrganizerVerificationStatus,
} from "./types";

type AnalyticsRangePreset = NonNullable<
  HostAnalyticsQueryPayload["rangePreset"]
>;
type AnalyticsGranularity = NonNullable<
  HostAnalyticsQueryPayload["granularity"]
>;

const navigation = [
  {id: "overview", label: "Overview", icon: Activity},
  {id: "safety", label: "Safety", icon: ShieldAlert},
  {id: "access", label: "Access", icon: UserCheck},
  {id: "growth", label: "Growth", icon: LineChart},
  {id: "organizer-intake", label: "Intake", icon: FolderSearch},
  {id: "hosts", label: "Hosts", icon: Users},
  {id: "events", label: "Events", icon: BarChart3},
  {id: "users", label: "Users", icon: Sparkles},
  {id: "finance", label: "Finance", icon: CircleDollarSign},
  {id: "quality", label: "Data quality", icon: Database},
];

const priorityMetricIds = [
  "signupsToday",
  "signupsThisWeek",
  "openReports",
  "pendingApplications",
  "pendingClubClaims",
  "indexReviewPages",
  "activeHosts",
  "failedPayments",
];

const organizerIntakeBridge =
  organizerIntakeBridgeJson as unknown as OrganizerIntakeBridge;

const organizerCurationOperations: OrganizerCurationOperation[] = [
  "surface_decision",
  "split_surface",
  "merge_entity",
  "suppress_entity",
];

const organizerSurfaceDecisions: OrganizerSurfaceDecision[] = [
  "reject_wrong_entity",
  "accept_primary",
  "accept_secondary",
  "mark_ambiguous",
  "mark_historical",
];

interface OrganizerIntakeBridge {
  schemaVersion: number;
  generatedFrom: Record<string, string>;
  summary: OrganizerIntakeSummary;
  guardrails: string[];
  workflowReadiness: OrganizerWorkflowReadiness;
  policyGaps: OrganizerPolicyGapRegister;
  policyDecisionPackets: OrganizerPolicyDecisionPackets;
  canonicalHostEntities: OrganizerCanonicalHostEntityRegistry;
  canonicalEvidenceIndex: OrganizerCanonicalEvidenceIndex;
  publicationReviewPackets: OrganizerPublicationReviewPackets;
  publicationDecisionImpactPreview: OrganizerPublicationDecisionImpactPreview;
  operatorActionQueue: OrganizerOperatorActionQueue;
  operationalHealth: OrganizerOperationalHealthReport;
  pendingInputRequest: OrganizerPendingInputRequest;
  pendingWorkCoverage: OrganizerPendingWorkCoverage;
  reviewedDecisionAnswerPackets: OrganizerReviewedDecisionAnswerPacketRegister;
  promotionExecutionPacket: OrganizerPromotionExecutionPacket;
  claimTargetSyncPreview: OrganizerClaimTargetSyncPreview;
  crawlPlan: OrganizerCrawlPlan;
  crawlRunPlan: OrganizerCrawlRunPlan;
  rawArtifactStorage: OrganizerRawArtifactStorageManifest;
  searchCandidates: OrganizerSearchCandidateQueue;
  externalEventCandidates: OrganizerExternalEventCandidateQueue;
  externalEventLocationResolution: OrganizerExternalEventLocationResolutionQueue;
  externalEventImportPlan: OrganizerExternalEventImportPlan;
  externalEventImportExecutionPlan: OrganizerExternalEventImportExecutionPlan;
  curation: OrganizerCurationState;
  items: OrganizerIntakeItem[];
}

interface OrganizerIntakeSummary {
  reviewItems: number;
  evidenceReview: number;
  promotionReview: number;
  blocked: number;
  approvedPublic: number;
  appDiscoverable: number;
  claimTargets?: number;
  claimTargetSyncPreviewWrites?: number;
  claimTargetSyncPreviewCreates?: number;
  claimTargetSyncPreviewRefreshes?: number;
  claimTargetSyncPreviewSkippedOwnerBound?: number;
  canonicalHostEntities?: number;
  canonicalHostPublicPublished?: number;
  canonicalHostIndexed?: number;
  canonicalHostClaimTargets?: number;
  canonicalHostSurfaces?: number;
  canonicalHostCrawlCapableSurfaces?: number;
  canonicalEvidenceRecords?: number;
  canonicalEvidenceResolvedRefs?: number;
  canonicalEvidenceSurfacesWithoutEvidence?: number;
  canonicalEvidenceManualReportsWithoutArtifacts?: number;
  canonicalEvidenceRawProviderArtifacts?: number;
  publicationReviewPackets?: number;
  publicationReviewReady?: number;
  publicationReviewBlockedByData?: number;
  publicationImpacts?: number;
  publicationImpactWouldPublish?: number;
  publicationImpactWouldIndex?: number;
  publicationImpactClaimTargets?: number;
  publicationImpactAppDiscoverable?: number;
  operatorActions?: number;
  operatorAdminDecisionsRequired?: number;
  operatorPolicyInputsRequired?: number;
  operatorWaitingActions?: number;
  operationalHealthStatus?: string;
  operationalHealthWorkstreams?: number;
  operationalHealthActionRequired?: number;
  operationalHealthPolicyBlocked?: number;
  operationalHealthWaiting?: number;
  pendingInputRequests?: number;
  pendingAdminPublicationInputs?: number;
  pendingPolicyDecisionInputs?: number;
  pendingRequiredPolicyQuestions?: number;
  pendingWorkCoverageStatus?: string;
  pendingWorkCovered?: number;
  pendingWorkUntriaged?: number;
  reviewedAnswerPacketStatus?: string;
  reviewedAnswerPackets?: number;
  reviewedAnswerPacketsReady?: number;
  reviewedAnswerPacketsAwaitingAnswers?: number;
  reviewedAnswerPacketsInvalid?: number;
  reviewedAnswerPacketsStale?: number;
  promotionExecutionStatus?: string;
  promotionExecutionPhases?: number;
  promotionExecutionBlockedPhases?: number;
  promotionCanRunLocalPreview?: boolean;
  promotionCanDeployNewPublicPages?: boolean;
  promotionCanWriteClaimTargets?: boolean;
  curationOperations?: number;
  attachedSurfaces?: number;
  mergedSources?: number;
  splitSurfaces?: number;
  searchResultCandidates?: number;
  matchedSearchResultCandidates?: number;
  duplicateSearchResultKeys?: number;
  externalEventCandidates?: number;
  externalEventCandidatesBlocked?: number;
  externalEventCandidatesReviewed?: number;
  externalEventCandidatesApproved?: number;
  externalEventCandidatesHeld?: number;
  externalEventCandidatesRejected?: number;
  externalEventLocationTasks?: number;
  externalEventLocationMissingCoordinates?: number;
  externalEventLocationProviderDisabled?: number;
  externalEventImportProposedCreates?: number;
  externalEventImportProposedReadOnlyEvents?: number;
  externalEventImportBlocked?: number;
  externalEventImportWriteReady?: number;
  externalEventImportExecutionWouldCreate?: number;
  externalEventImportExecutionWouldPublishReadOnly?: number;
  externalEventImportExecutionBlocked?: number;
  externalEventImportExecutionSchemaInvalid?: number;
  externalEventImportExecutionProjectionInvalid?: number;
  externalEventImportExecutionPayloadInvalid?: number;
  externalEventImportExecutionProjectionInvalidCount?: number;
  crawlCapableSurfaces?: number;
  crawlApprovedSurfaces?: number;
  crawlBlockedSurfaces?: number;
  crawlRunIntents?: number;
  crawlRunWouldFetch?: number;
  crawlRunBlocked?: number;
  readinessBlocked?: number;
  readinessPolicyNeeded?: number;
  readinessReviewNeeded?: number;
  policyGaps?: number;
  policyGapsDecisionRequired?: number;
  policyGapReviewDecisions?: number;
  policyGapReviewAccepted?: number;
  policyGapReviewHeld?: number;
  policyGapReviewRejected?: number;
  policyGapReviewInvalid?: number;
  policyDecisionPackets?: number;
  policyDecisionQuestions?: number;
  policyDecisionUnanswered?: number;
  rawArtifacts?: number;
  rawProviderPayloads?: number;
  rawArtifactStorageBlocked?: number;
  rawArtifactBytes?: number;
}

interface OrganizerWorkflowReadiness {
  status: string;
  summary: {
    blocked: number;
    claimSyncReady: boolean;
    gates: number;
    localPromotionPipelineReady: boolean;
    canonicalEvidenceRecords?: number;
    canonicalEvidenceResolvedRefs?: number;
    canonicalEvidenceSurfacesWithoutEvidence?: number;
    canonicalEvidenceManualReportsWithoutArtifacts?: number;
    publicationReviewPackets?: number;
    publicationReviewReady?: number;
    publicationReviewBlockedByData?: number;
    canonicalHostEntities?: number;
    canonicalHostPublicPublished?: number;
    canonicalHostClaimTargets?: number;
    policyNeeded: number;
    publicProjectionReady: boolean;
    ready: number;
    recurringCrawlEnabled: boolean;
    crawlRunIntents?: number;
    rawArtifacts?: number;
    rawProviderPayloads?: number;
    rawArtifactStorageBlocked?: number;
    reviewNeeded: number;
    waiting: number;
  };
  gates: OrganizerWorkflowReadinessGate[];
  commands: Record<string, string>;
}

interface OrganizerWorkflowReadinessGate {
  id: string;
  label: string;
  status: string;
  detail: string;
  nextAction: string;
}

interface OrganizerOperatorActionQueue {
  schemaVersion: number;
  summary: {
    actions: number;
    publicationReviewActions: number;
    policyDecisionActions: number;
    workflowGateActions: number;
    adminDecisionsRequired: number;
    policyInputsRequired: number;
    waitingActions: number;
    actionsByPriority: Record<string, number>;
    actionsByStatus: Record<string, number>;
    actionsByType: Record<string, number>;
    highestPriority: string | null;
  };
  guardrails: string[];
  actions: OrganizerOperatorAction[];
}

interface OrganizerOperatorAction {
  actionId: string;
  actionType: string;
  blockers: string[];
  commands: string[];
  decisionOptions: string[];
  detail: string;
  impact?: {
    appVisibility: string | null;
    claimTargetPath: string | null;
    sitemapEligible: boolean;
    wouldCreateClaimTarget: boolean;
    wouldIndex: boolean;
    wouldPublish: boolean;
  } | null;
  nextAction: string;
  priority: string;
  requiredAcknowledgements?: {
    manualReportsReviewed?: boolean;
    publicationChecklist?: string[];
  };
  requiredInputs?: string[];
  safeDefaultAction?: string;
  sourceArtifacts: string[];
  status: string;
  subjectId: string;
  subjectName: string;
  taskType: string;
}

interface OrganizerOperationalHealthReport {
  schemaVersion: number;
  summary: {
    healthStatus: string;
    workstreams: number;
    readyWorkstreams: number;
    actionRequiredWorkstreams: number;
    policyBlockedWorkstreams: number;
    blockedWorkstreams: number;
    waitingWorkstreams: number;
    idleWorkstreams: number;
    highestPriority: string | null;
    operatorActions: number;
    adminDecisionsRequired: number;
    policyInputsRequired: number;
    waitingActions: number;
    workflowReady: number;
    workflowWaiting: number;
    workflowBlocked: number;
    workflowPolicyNeeded: number;
    workstreamsByStatus: Record<string, number>;
    workstreamsByPriority: Record<string, number>;
  };
  guardrails: string[];
  workstreams: OrganizerOperationalHealthWorkstream[];
}

interface OrganizerOperationalHealthWorkstream {
  id: string;
  label: string;
  status: string;
  priority: string;
  metrics: Record<string, string | number | boolean | null>;
  blockers: string[];
  nextActions: string[];
  commands: string[];
  sourceArtifacts: string[];
}

interface OrganizerPendingInputRequest {
  schemaVersion: number;
  generatedFrom: Record<string, string>;
  summary: {
    requests: number;
    adminPublicationRequests: number;
    policyDecisionRequests: number;
    requiredPolicyQuestions: number;
    manualPublicationAcknowledgements: number;
    workflowFollowUps: number;
    highestPriority: string | null;
    requestsByOwner: Record<string, number>;
    requestsByPriority: Record<string, number>;
    requestsByType: Record<string, number>;
    followUpsByStatus: Record<string, number>;
  };
  guardrails: string[];
  requests: OrganizerPendingInputItem[];
  followUps: OrganizerPendingInputFollowUp[];
}

interface OrganizerPendingInputItem {
  requestId: string;
  requestType: "admin_publication_decision" | "policy_decision" | string;
  priority: string;
  owner: string;
  subjectId: string;
  subjectName: string;
  prompt: string;
  decisionOptions: string[];
  safeDefaultAction: string;
  requiredAcknowledgements?: {
    manualReportsReviewed?: boolean;
    publicationChecklist?: string[];
  };
  requiredInputs?: OrganizerPendingInputRequiredInput[];
  currentState?: Record<string, unknown>;
  impact?: {
    appVisibility?: string | null;
    claimTargetPath?: string | null;
    sitemapEligible?: boolean;
    wouldCreateClaimTarget?: boolean;
    wouldIndex?: boolean;
    wouldPublish?: boolean;
  } | null;
  nextAction?: string;
  commands: string[];
  callableSubmission?: OrganizerPendingInputCallableSubmission;
  sourceArtifacts: string[];
}

interface OrganizerPendingInputCallableSubmission {
  callableName: string;
  adminApiWrapper: string;
  payloadType: string;
  firestoreCollection: string;
  payloadsByDecision: Record<string, Record<string, unknown>>;
  safeDefaultPayload: Record<string, unknown> | null;
}

interface OrganizerPendingInputRequiredInput {
  questionId?: string;
  input?: string;
  prompt: string;
  currentDefault?: string;
  recommendedSafeDefault: string;
  requiredForAcceptance: boolean;
}

interface OrganizerPendingInputFollowUp {
  followUpId: string;
  workstreamId: string;
  label: string;
  status: string;
  priority: string;
  blockers: string[];
  nextActions: string[];
  commands: string[];
}

interface OrganizerPendingWorkCoverage {
  schemaVersion: number;
  generatedFrom: Record<string, string>;
  summary: {
    status: string;
    unresolvedWorkstreams: number;
    coveredWorkstreams: number;
    coveredByInputRequest: number;
    coveredByFollowUp: number;
    untriagedWorkstreams: number;
    highestPriority: string | null;
    coverageByStatus: Record<string, number>;
    workstreamsByStatus: Record<string, number>;
    workstreamsByPriority: Record<string, number>;
  };
  guardrails: string[];
  entries: OrganizerPendingWorkCoverageEntry[];
}

interface OrganizerPendingWorkCoverageEntry {
  coverageId: string;
  workstreamId: string;
  label: string;
  status: string;
  priority: string;
  coverageStatus: string;
  blockerClass: string;
  pendingRequestIds: string[];
  followUpIds: string[];
  blockers: string[];
  nextActions: string[];
  commands: string[];
}

interface OrganizerReviewedDecisionAnswerPacketRegister {
  schemaVersion: number;
  generatedFrom: {
    answerPacketsRoot: string;
    generatedAnswerPacket: string;
  };
  summary: {
    status: string;
    packets: number;
    readyToApply: number;
    awaitingAnswers: number;
    invalid: number;
    stale: number;
    sourceFresh: number;
  };
  guardrails: string[];
  entries: OrganizerReviewedDecisionAnswerPacketEntry[];
}

interface OrganizerReviewedDecisionAnswerPacketEntry {
  path: string;
  reviewer: string | null;
  decidedAt: string | null;
  reviewDraft: Record<string, unknown> | null;
  status: string;
  answerSlots: number;
  plannedActions: number;
  pendingAnswers: number;
  readyToApply: boolean;
  awaitingAnswers: boolean;
  invalid: boolean;
  stale: boolean;
  sourceFresh: boolean;
  sourceFreshness: string;
  errors: string[];
  warnings: string[];
}

interface OrganizerPromotionExecutionPacket {
  schemaVersion: number;
  generatedFrom: Record<string, string>;
  summary: {
    status: string;
    localPromotionPipelineReady: boolean;
    publicProjectionReady: boolean;
    claimSyncReady: boolean;
    pendingAdminDecisions: number;
    pendingPolicyDecisions: number;
    pendingAnswerSlots: number;
    reviewedAnswerPacketStatus: string;
    reviewedAnswerPackets: number;
    reviewedAnswerPacketsReady: number;
    reviewedAnswerPacketsAwaitingAnswers: number;
    reviewedAnswerPacketsInvalid: number;
    reviewedAnswerPacketsStale: number;
    pendingWorkUntriaged: number;
    approvedPublicProjections: number;
    publicationImpacts: number;
    publicationImpactWouldPublish: number;
    claimTargetPreviewTargets: number;
    claimTargetPreviewWrites: number;
    canRunLocalPreview: boolean;
    canDeployNewPublicPages: boolean;
    canWriteClaimTargets: boolean;
    policyInputRequiredBeforeCrawlStorageOrImport: boolean;
    phases: number;
    phasesByStatus: Record<string, number>;
    blockedPhases: number;
    guardedRemoteReadPhases: number;
    guardedRemoteWritePhases: number;
  };
  guardrails: string[];
  phases: OrganizerPromotionExecutionPhase[];
}

interface OrganizerPromotionExecutionPhase {
  phaseId: string;
  label: string;
  status: string;
  executionMode: string;
  command: string;
  blockers: string[];
  outputs: string[];
}

interface OrganizerPolicyGapRegister {
  schemaVersion: number;
  summary: {
    gaps: number;
    decisionRequired: number;
    ready: number;
    blockedByPolicy: number;
    gapsByArea: Record<string, number>;
    gapsBySeverity: Record<string, number>;
    gapsByStatus: Record<string, number>;
    reviewDecisions: number;
    reviewAccepted: number;
    reviewHeld: number;
    reviewRejected: number;
    reviewInvalid: number;
    reviewNotReviewed: number;
    gapsByDecisionStatus: Record<string, number>;
  };
  guardrails: string[];
  errors?: string[];
  gaps: OrganizerPolicyGap[];
}

interface OrganizerPolicyGapReviewDecision {
  policyGapDecisionBatchId: string;
  decidedAt: string;
  reviewer: string;
  decision: "accept" | "hold" | "reject";
  note: string;
  requiredInputsReviewed: string[];
  missingRequiredInputs: string[];
  unknownRequiredInputs: string[];
}

interface OrganizerPolicyGap {
  gapId: string;
  area: string;
  severity: "critical" | "high" | "medium" | "low";
  status: "decision_required" | "ready";
  decisionStatus: "not_reviewed" | "accepted" | "held" | "rejected" | "invalid";
  reviewDecision: OrganizerPolicyGapReviewDecision | null;
  defaultPosition: string;
  decisionOwner: string;
  currentState: string;
  requiredInputs: string[];
  unblockCriteria: string[];
  blockedArtifacts: string[];
  nextAction: string;
  evidence: Record<string, unknown>;
}

interface OrganizerPolicyDecisionPackets {
  schemaVersion: number;
  summary: {
    packets: number;
    decisionRequired: number;
    ready: number;
    notReviewed: number;
    accepted: number;
    held: number;
    rejected: number;
    invalid: number;
    questions: number;
    unansweredQuestions: number;
    requiredQuestions: number;
    questionsByArea: Record<string, number>;
    questionsByAnswerState: Record<string, number>;
  };
  guardrails: string[];
  packets: OrganizerPolicyDecisionPacket[];
}

interface OrganizerPolicyDecisionPacket {
  packetId: string;
  gapId: string;
  area: string;
  severity: "critical" | "high" | "medium" | "low";
  status: string;
  decisionStatus: string;
  decisionOwner: string;
  decisionPrompt: string;
  currentState: string;
  safeDefaultAction: string;
  implementationGate: string;
  blockedArtifacts: string[];
  unblockCriteria: string[];
  nextAction: string;
  reviewDecision: OrganizerPolicyGapReviewDecision | null;
  questions: OrganizerPolicyDecisionQuestion[];
}

interface OrganizerPolicyDecisionQuestion {
  questionId: string;
  input: string;
  prompt: string;
  currentDefault: string;
  recommendedSafeDefault: string;
  requiredForAcceptance: boolean;
  answerState: "reviewed" | "needs_input";
}

interface OrganizerCanonicalHostEntityRegistry {
  schemaVersion: number;
  naming: {
    publicEntityLabel: string;
    canonicalDataModel: string;
    operatorAccountLabel: string;
    legacyCompatibilityModel: string;
    note: string;
  };
  summary: {
    entities: number;
    publicPublished: number;
    indexed: number;
    appDiscoverable: number;
    claimTargets: number;
    unclaimed: number;
    claimed: number;
    internalOnly: number;
    cityScoped: number;
    multiCityScoped: number;
    nationalScoped: number;
    globalScoped: number;
    remoteScoped: number;
    surfaces: number;
    activeSurfaces: number;
    ambiguousSurfaces: number;
    rejectedSurfaces: number;
    crawlCapableSurfaces: number;
    eventSourceSurfaces: number;
    socialProfileSurfaces: number;
    legacyClubProjected: number;
    pendingManualReview: number;
    byEntityKind: Record<string, number>;
    byScopeKind: Record<string, number>;
  };
  guardrails: string[];
  entries: OrganizerCanonicalHostEntity[];
}

interface OrganizerCanonicalHostEntity {
  canonicalHostId: string;
  entityId: string;
  displayName: string;
  canonicalSlug: string;
  aliases: string[];
  entityKind: string;
  entitySubtypes: string[];
  priority: string;
  activity: {
    primaryActivityKind: string | null;
    supportedActivityKinds: string[];
    confidence: string;
    derivedFromSurfaceIds: string[];
  };
  geography: {
    scopeKind: string | null;
    primaryMarketSlug: string | null;
    markets: OrganizerIntakeMarket[];
    countryCodes: string[];
  };
  publicPresence: {
    reviewStatus: string;
    projectionStatus: string;
    publishStatus: string;
    indexStatus: string;
    appVisibility: string;
    canonicalPath: string | null;
    legacyPaths: string[];
    pageMode: string;
    publicListingId: string | null;
    publicListingStatus: string | null;
    blockedBy: string[];
  };
  claim: {
    relationshipToCatch: string;
    claimState: string;
    claimTargetPath: string | null;
    appVisibility: string;
    ownerAccountRequired: boolean;
    writeMode: string | null;
  };
  legacyClubCompatibility: {
    collection: string;
    documentId: string;
    status: string;
    writeMode: string | null;
    sourceHash: string | null;
    note: string;
  };
  surfaceInventory: {
    surfaces: number;
    active: number;
    ambiguous: number;
    rejected: number;
    historical: number;
    primarySurfaceIds: string[];
    eventSourceSurfaceIds: string[];
    socialProfileSurfaceIds: string[];
    platforms: Record<string, number>;
    normalizedKeys: string[];
  };
  dedupe: {
    keys: number;
    strongKeys: number;
    mediumKeys: number;
    weakKeys: number;
    conflicts: number;
    keyTypes: Record<string, number>;
  };
  nextActions: string[];
}

interface OrganizerCanonicalEvidenceIndex {
  schemaVersion: number;
  summary: {
    records: number;
    hosts: number;
    surfaces: number;
    surfacesWithoutEvidence: number;
    resolvedArtifactRefs: number;
    unresolvedLocalRefs: number;
    manualReportsWithoutArtifacts: number;
    externalUrlRefs: number;
    rawProviderArtifacts: number;
    rawProviderArtifactsReferenced: number;
    rawPayloadBytes: number;
    firestoreForbiddenArtifactRefs: number;
    remoteUploadBlockedArtifactRefs: number;
    evidenceByStatus: Record<string, number>;
    evidenceByType: Record<string, number>;
    surfaceStatuses: Record<string, number>;
    publishStatuses: Record<string, number>;
    artifactKinds: Record<string, number>;
  };
  guardrails: string[];
  records: OrganizerCanonicalEvidenceRecord[];
  artifactCoverage: OrganizerCanonicalEvidenceArtifact[];
}

interface OrganizerCanonicalEvidenceRecord {
  evidenceId: string;
  canonicalHostId: string;
  entityId: string;
  displayName: string;
  surface: {
    surfaceId: string;
    platform: string;
    surfaceKind: string;
    url: string | null;
    normalizedKey: string | null;
    role: string;
    status: string;
    supportsEventExtraction: boolean;
  };
  evidence: {
    type: string;
    ref: string | null;
    description: string | null;
    status: string;
  };
  artifact: OrganizerCanonicalEvidenceArtifact | null;
  reviewState: {
    entityReviewStatus: string | null;
    publishStatus: string | null;
    indexStatus: string | null;
    claimState: string | null;
    appVisibility: string | null;
    reviewTaskType: string | null;
    reviewBlockers: string[];
    curation: Record<string, unknown> | null;
  };
  correlatedCandidates: {
    searchCandidateIds: string[];
    externalEventCandidateIds: string[];
  };
  riskFlags: string[];
  nextAction: string;
}

interface OrganizerCanonicalEvidenceArtifact {
  artifactId: string;
  path: string;
  artifactKind: string;
  storageClass: string;
  sizeBytes: number;
  sha256: string;
  source?: string;
  containsRawProviderPayload: boolean;
  firestoreMode: string;
  retentionStatus: string | null;
  storageAction: string | null;
  remoteObjectKey: string | null;
  referencedByEvidenceIds?: string[];
}

interface OrganizerPublicationReviewPackets {
  schemaVersion: number;
  summary: {
    packets: number;
    readyForManualPublicationReview: number;
    blockedByData: number;
    published: number;
    suppressed: number;
    held: number;
    evidenceRecords: number;
    manualReportsWithoutArtifacts: number;
    unresolvedEvidenceRefs: number;
    missingSurfaceEvidence: number;
    packetsByStatus: Record<string, number>;
    packetsByTaskType: Record<string, number>;
  };
  guardrails: string[];
  packets: OrganizerPublicationReviewPacket[];
}

interface OrganizerPublicationReviewPacket {
  packetId: string;
  canonicalHostId: string;
  entityId: string;
  displayName: string;
  priority: string;
  taskType: string;
  status: string;
  recommendedAction: string;
  identity: {
    entityKind: string;
    aliases: string[];
    activity: OrganizerCanonicalHostEntity["activity"];
    geography: OrganizerCanonicalHostEntity["geography"];
  };
  publicPresence: {
    canonicalPath: string | null;
    legacyPaths: string[];
    projectionStatus: string;
    publishStatus: string;
    indexStatus: string;
    appVisibility: string;
    claimTargetPath: string | null;
  };
  publicDraft: {
    headline: string | null;
    summary: string | null;
    sourceSummary: string | null;
    formats: string[];
    missingEvidence: string[];
  };
  surfaceSummary: OrganizerCanonicalHostEntity["surfaceInventory"];
  evidenceSummary: {
    records: number;
    resolvedArtifactRefs: number;
    manualReportsWithoutArtifacts: number;
    unresolvedLocalRefs: number;
    missingSurfaceEvidence: number;
    rawProviderArtifactRefs: number;
    firestoreForbiddenArtifactRefs: number;
    riskFlags: string[];
    byStatus: Record<string, number>;
    byType: Record<string, number>;
  };
  evidenceReview: {
    totalRecords: number;
    shownRecords: number;
    truncated: boolean;
    artifactBackedRecords: number;
    manualReportsWithoutArtifacts: number;
    unresolvedLocalRefs: number;
    missingSurfaceEvidence: number;
    externalUrlRefs: number;
    rawProviderArtifactRefs: number;
    records: OrganizerPublicationEvidenceReviewRecord[];
  };
  evidenceRecordIds: string[];
  gates: OrganizerIntakeGate[];
  blockers: string[];
  dataBlockers: string[];
  evidenceBlockers: string[];
  approvalChecklist: Record<string, boolean>;
  adminDecision: {
    currentDecision: OrganizerReviewDecision | null;
    allowedDecisions: OrganizerIntakeDecision[];
    defaultAppVisibility: string;
    command: string;
  };
  nextActions: string[];
}

interface OrganizerPublicationEvidenceReviewRecord {
  evidenceId: string;
  surface: {
    surfaceId: string | null;
    platform: string;
    surfaceKind: string;
    role: string;
    status: string;
    url: string | null;
    normalizedKey: string | null;
    supportsEventExtraction: boolean;
  };
  evidence: {
    type: string;
    status: string;
    ref: string | null;
    description: string | null;
  };
  artifact: {
    artifactId: string;
    path: string;
    artifactKind: string;
    storageClass: string;
    sizeBytes: number;
    sha256: string;
    containsRawProviderPayload: boolean;
    firestoreMode: string;
    retentionStatus: string | null;
    storageAction: string | null;
  } | null;
  correlatedCandidates: {
    searchCandidateIds: string[];
    externalEventCandidateIds: string[];
  };
  riskFlags: string[];
  nextAction: string;
  reviewerUse: {
    artifactAvailable: boolean;
    manualReportWithoutArtifact: boolean;
    missingSurfaceEvidence: boolean;
    unresolvedLocalReference: boolean;
    sourceUrlAvailable: boolean;
  };
}

interface OrganizerPublicationDecisionImpactPreview {
  schemaVersion: number;
  summary: {
    impacts: number;
    wouldPublish: number;
    wouldIndex: number;
    wouldCreateClaimTargets: number;
    wouldBeAppDiscoverable: number;
    blocked: number;
    reviewerAcknowledgementsRequired: number;
    byStatus: Record<string, number>;
  };
  guardrails: string[];
  entries: OrganizerPublicationDecisionImpact[];
}

interface OrganizerPublicationDecisionImpact {
  impactId: string;
  packetId: string;
  entityId: string;
  displayName: string;
  status: string;
  decisionRequired: {
    decision: OrganizerIntakeDecision;
    appVisibility: string;
    checklist: Record<string, boolean>;
    command: string;
  };
  preconditions: {
    packetStatus: string;
    dataBlockers: string[];
    evidenceBlockers: string[];
    manualReportsWithoutArtifacts: number;
    reviewerAcknowledgementRequired: boolean;
    blockers?: string[];
  };
  publicProjection: {
    wouldPublish: boolean;
    wouldIndex: boolean;
    projectionStatus: string;
    publishStatus: string;
    indexStatus: string;
    canonicalPath: string | null;
    legacyPaths: string[];
    pageMode: string | null;
    listingId: string | null;
    listingName: string | null;
    listingVariant: string | null;
    dataOrigin: string | null;
    indexing: string;
    sourceCount: number;
    missingEvidence: string[];
  };
  claimTarget: {
    wouldCreateOrRefresh: boolean;
    path: string | null;
    writeMode: string | null;
    appVisibility: string;
    claimState: string;
    sourceHash: string | null;
  };
  app: {
    appVisibility: string;
    wouldBeDiscoverable: boolean;
  };
  remoteEffects: {
    writesDuringPreview: number;
    writesDuringDecisionExport: number;
    claimSyncRequired: boolean;
    claimSyncTargetPath: string | null;
    websiteGenerationRequired: boolean;
    sitemapEligible: boolean;
  };
  commands: string[];
}

interface OrganizerClaimTargetSyncPreview {
  schemaVersion: number;
  generatedFrom: {
    claimTargetPlan: string;
    existingDocsSource: string;
  };
  summary: {
    targets: number;
    creates: number;
    refreshes: number;
    skippedOwnerBound: number;
    writesNeeded: number;
  };
  mode: {
    previewOnly: boolean;
    existingDocsSource: string;
    remoteReads: number;
    remoteWrites: number;
    assumesMissingWhenNotInFixture: boolean;
  };
  guardrails: string[];
  commands: Record<string, string>;
  actions: OrganizerClaimTargetSyncPreviewAction[];
}

interface OrganizerClaimTargetSyncPreviewAction {
  entityId: string;
  path: string;
  status: "create" | "refresh" | "skip_owner_bound";
  merge: boolean;
  reason: string;
  writeFields: string[];
  writeFieldCount: number;
  writesRemoteData: boolean;
  requiresFirestoreDryRun: boolean;
}

interface OrganizerCrawlPlan {
  summary: OrganizerCrawlPlanSummary;
  policy: OrganizerCrawlPlanPolicy;
  guardrails: string[];
}

interface OrganizerCrawlPlanSummary {
  entities: number;
  crawlCapableSurfaces: number;
  approvedSurfaces: number;
  blockedSurfaces: number;
  platforms: Record<string, number>;
  blockers: Record<string, number>;
}

interface OrganizerCrawlPlanPolicy {
  status: string;
  schedulerEnabled: boolean;
  defaultSurfacePolicy: string;
  reason: string;
}

interface OrganizerCrawlRunPlan {
  summary: {
    candidateSurfaces: number;
    wouldFetch: number;
    blocked: number;
    networkRequests: number;
    firestoreWrites: number;
    platforms: Record<string, number>;
    blockers: Record<string, number>;
  };
  policy: {
    status: string;
    schedulerEnabled: boolean;
    networkEnabled: boolean;
    firestoreWritesEnabled: boolean;
    platformAllowlist: string[];
    maxRequestsPerRun: number;
    reason: string;
  };
  guardrails: string[];
  runIntents: OrganizerCrawlRunIntent[];
}

interface OrganizerCrawlRunIntent {
  crawlRunId: string;
  entityId: string;
  displayName: string;
  surfaceId: string;
  platform: string;
  surfaceKind: string;
  url: string | null;
  normalizedKey: string | null;
  action: "blocked" | "would_fetch";
  blockedBy: string[];
  expectedOutput: string;
  nextGate: string;
}

interface OrganizerRawArtifactStorageManifest {
  summary: {
    artifacts: number;
    rawProviderPayloads: number;
    reviewedSourceBatches: number;
    decisionBatches: number;
    fixtureSupportFiles: number;
    seedIntakeBatches: number;
    totalBytes: number;
    remoteUploadReady: number;
    remoteUploadBlocked: number;
    firestoreRawStorageAllowed: boolean;
    retentionDecisionRequired: number;
    blockers: Record<string, number>;
    storageClasses: Record<string, number>;
  };
  policy: {
    status: string;
    remoteObjectStorageEnabled: boolean;
    firestoreRawPayloadStorageEnabled: boolean;
    provider: string;
    bucket: string | null;
    rawPayloadRetentionDays: number | null;
    retentionPolicyApproved: boolean;
    reason: string;
  };
  guardrails: string[];
  artifacts: OrganizerRawArtifactRecord[];
}

interface OrganizerRawArtifactRecord {
  artifactId: string;
  path: string;
  artifactKind: string;
  storageClass: string;
  sizeBytes: number;
  sha256: string;
  containsRawProviderPayload: boolean;
  firestoreMode: string;
  retention: {
    status: string;
    retentionDays: number | null;
    deletionMode: string;
  };
  storagePlan: {
    action: "blocked" | "not_required" | "would_upload";
    remoteObjectKey: string;
    blockedBy: string[];
    reason: string;
  };
}

interface OrganizerIntakeItem {
  entityId: string;
  displayName: string;
  priority: string;
  taskType: string;
  reviewStatus: string;
  relationshipToCatch: string;
  canonicalPath: string | null;
  legacyPaths: string[];
  markets: OrganizerIntakeMarket[];
  blockers: string[];
  gates: OrganizerIntakeGate[];
  surfaceSummary: OrganizerSurfaceSummary;
  surfaces: OrganizerItemSurface[];
  promotionPolicy: OrganizerPromotionPolicy;
  reviewDecision: OrganizerReviewDecision | null;
  projectionStatus: string;
  publishStatus: string;
  indexStatus: string;
  appVisibility: string;
  claimTargetPath?: string | null;
  curation: OrganizerItemCuration | null;
  decisionCommands: OrganizerDecisionCommands;
}

interface OrganizerCurationState {
  summary: OrganizerCurationSummary;
  commands: OrganizerCurationCommands;
  attachedSurfaces: OrganizerCurationStateOperation[];
  mergedEntities: OrganizerCurationStateOperation[];
  suppressedEntities: OrganizerCurationStateOperation[];
  surfaceDecisions: OrganizerCurationStateOperation[];
  splitSurfaces: OrganizerCurationStateOperation[];
}

interface OrganizerCurationSummary {
  entities: number;
  operations: number;
  attachedSurfaces: number;
  merges: number;
  suppressions: number;
  surfaceDecisions: number;
  splitSurfaces: number;
  mergeTargets: number;
  mergedSources: number;
}

interface OrganizerCurationCommands {
  attachSurface: string;
  mergeEntity: string;
  splitSurface: string;
  suppressEntity: string;
  surfaceDecision: string;
}

interface OrganizerCurationStateOperation {
  operationId: string;
  reason: string;
  [key: string]: unknown;
}

interface OrganizerItemCuration {
  attachedSurfaces: Array<{
    surfaceId: string;
    sourceCandidateId: string;
    reason: string;
  }>;
  mergedFrom: string[];
  mergedInto: string | null;
  suppressed: string | null;
  surfaceDecisions: Array<{
    surfaceId: string;
    decision: string;
    reason: string;
  }>;
  splitSurfaces: Array<{
    surfaceId: string;
    newEntityId: string;
    reason: string;
  }>;
}

interface OrganizerSearchCandidateQueue {
  summary: OrganizerSearchCandidateSummary;
  generatedFrom: {
    batches: string[];
    dedupeIndexGeneratedAt: string | null;
  };
  candidates: OrganizerSearchCandidate[];
  duplicateKeys: Array<{
    normalizedKey: string;
    candidateIds: string[];
  }>;
  warnings: string[];
  errors: string[];
  commands: OrganizerSearchCandidateCommands;
}

interface OrganizerSearchCandidateSummary {
  batches: number;
  results: number;
  candidates: number;
  matchedExistingEntities: number;
  duplicateNormalizedKeys: number;
  platforms: Record<string, number>;
}

interface OrganizerSearchCandidateCommands {
  capture: string;
  curateSurface: string;
  ingest: string;
  normalize: string;
}

interface OrganizerSearchCandidate {
  candidateId: string;
  batchId: string;
  resultId: string;
  rank: number;
  query: string;
  queryIntent: {
    activityKind: string | null;
    entityHint: string | null;
    marketSlug: string | null;
  };
  observedAt: string;
  title: string;
  snippet: string | null;
  url: string;
  canonicalUrl: string;
  platform: string;
  surfaceKind: string;
  normalizedKey: string | null;
  suggestedSurface: OrganizerSuggestedSurface;
  existingEntityMatches: OrganizerExistingEntityMatch[];
  reviewAction: string;
  diagnostics: string[];
}

type OrganizerSuggestedSurface = OrganizerCurationSurface;

interface OrganizerExistingEntityMatch {
  entityId: string;
  strength: string;
  reason: string;
}

interface OrganizerExternalEventCandidateQueue {
  summary: {
    batches: number;
    events: number;
    candidates: number;
    platforms: Record<string, number>;
    duplicateEventKeys: number;
    blocked: number;
    reviewed: number;
    approvedForImport: number;
    held: number;
    rejected: number;
    locationResolved?: number;
  };
  policy: {
    status: string;
    reason: string;
    importWritesEnabled: boolean;
  };
  generatedFrom: {
    batches: string[];
    reviewDecisionBatches: string[];
    locationResolutionBatches?: string[];
  };
  candidates: OrganizerExternalEventCandidate[];
  duplicateEventKeys: Array<{
    normalizedEventKey: string;
    candidateIds: string[];
  }>;
  warnings: string[];
  errors: string[];
  commands: Record<string, string>;
}

interface OrganizerExternalEventCandidate {
  candidateId: string;
  entityId: string;
  surfaceId: string;
  platform: string;
  title: string;
  startAt: string;
  endAt: string | null;
  timezone: string | null;
  reviewStatus: string;
  reviewDecision: OrganizerExternalEventReviewDecision | null;
  importReadiness: string;
  importState: string;
  blockers: string[];
  eventUrl: string | null;
  location: {
    name: string | null;
    address?: string | null;
    citySlug: string | null;
    countryCode: string | null;
    latitude?: number | null;
    longitude?: number | null;
    placeId?: string | null;
    notes?: string | null;
  };
  locationResolution: OrganizerExternalEventLocationResolutionDecision | null;
  diagnostics: string[];
}

interface OrganizerExternalEventReviewDecision {
  checklist: {
    identityReviewed: boolean;
    sourceEventReviewed: boolean;
    timeReviewed: boolean;
    locationReviewed: boolean;
    dedupeReviewed: boolean;
    ownerSafeCopyReviewed: boolean;
    importPolicyAcknowledged: boolean;
  };
  decidedAt: string;
  decision: OrganizerEventCandidateDecision;
  eventReviewBatchId: string;
  note: string;
  reviewer: string;
}

interface OrganizerExternalEventLocationResolutionQueue {
  summary: {
    candidates: number;
    tasks: number;
    missingExactCoordinates: number;
    missingLocationText: number;
    providerDisabled: number;
    tasksByPlatform: Record<string, number>;
    tasksByCountry: Record<string, number>;
  };
  policy: {
    status: string;
    providerLookupEnabled: boolean;
    provider: string;
    reason: string;
  };
  generatedFrom: {
    externalEventCandidateQueue: string;
    batches: string[];
    reviewDecisionBatches: string[];
    locationResolutionBatches?: string[];
  };
  guardrails: string[];
  tasks: OrganizerExternalEventLocationResolutionTask[];
  commands: Record<string, string>;
}

interface OrganizerExternalEventLocationResolutionTask {
  taskId: string;
  candidateId: string;
  entityId: string;
  platform: string;
  sourceEventKey: string;
  eventUrl: string | null;
  sourceUrl: string | null;
  title: string;
  startAt: string;
  citySlug: string | null;
  countryCode: string;
  sourceLocation: {
    name: string | null;
    address: string | null;
    latitude: number | null;
    longitude: number | null;
    placeId?: string | null;
  };
  locationResolution: OrganizerExternalEventLocationResolutionDecision | null;
  resolutionQuery: string;
  resolutionState: string;
  blockers: string[];
  expectedOutput: Record<string, string>;
}

interface OrganizerExternalEventLocationResolutionDecision {
  checklist: {
    sourceLocationReviewed: boolean;
    coordinatesReviewed: boolean;
    placeIdentityReviewed: boolean;
    importSafetyReviewed: boolean;
  };
  locationResolutionBatchId: string;
  note: string;
  resolvedAt: string;
  reviewer: string;
}

interface OrganizerExternalEventImportPlan {
  summary: {
    candidates: number;
    proposedReadOnlyEvents?: number;
    proposedCreates: number;
    mergedSourceLinks?: number;
    writeReady: number;
    blocked: number;
    waitingReview: number;
    rejected: number;
    duplicateEventKeys: number;
    actionsByStatus: Record<string, number>;
    actionsByPlatform: Record<string, number>;
  };
  policy: {
    status: string;
    writeEnabled: boolean;
    reason: string;
  };
  generatedFrom: {
    externalEventCandidateQueue: string;
    batches: string[];
    reviewDecisionBatches: string[];
    locationResolutionBatches?: string[];
  };
  guardrails: string[];
  actions: OrganizerExternalEventImportAction[];
  commands: Record<string, string>;
}

interface OrganizerExternalEventImportAction {
  actionId: string;
  action:
    | "publish_read_only_external_event"
    | "merge_duplicate_source_link"
    | "create_event"
    | "skip";
  status:
    | "blocked"
    | "merged_duplicate"
    | "waiting_review"
    | "rejected"
    | "write_ready";
  candidateId: string;
  entityId: string;
  platform: string;
  sourceEventKey: string;
  normalizedEventKey: string;
  targetPath: string;
  reviewStatus: string;
  importState: string;
  blockers: string[];
  duplicateRole?: string;
  canonicalCandidateId?: string;
  duplicateCandidateIds: string[];
  source: {
    eventUrl: string | null;
    sourceUrl: string | null;
    sourceStatus: string;
    batchId: string;
    surfaceId: string;
  };
  proposedReadOnlyEventDraft: {
    eventId: string;
    canonicalHostId: string;
    compatibilityClubId?: string;
    title: string;
    description: string;
    startTime: string;
    endTime: string | null;
    timezone?: string | null;
    meetingPoint: string;
    meetingLocation?: {
      name: string;
      latitude: number | null;
      longitude: number | null;
      placeId: string | null;
      address: string | null;
      notes: string | null;
    };
    startingPointLat?: number | null;
    startingPointLng?: number | null;
    locationDetails: string | null;
    photoUrl: string | null;
    activity: {
      version: number;
      activityKind: string;
      interactionModel: string;
      source?: string;
    };
    price: {
      displayText: string | null;
      parsedPriceInPaise: number | null;
      currency: string;
    };
    booking: {
      mode: string;
      catchBookingEnabled: boolean;
      catchPaymentsEnabled: boolean;
      catchReservationsEnabled: boolean;
      catchWaitlistEnabled: boolean;
      externalLinks: Array<{
        platform: string;
        url: string;
        linkType: string;
        sourceEventKey: string;
        candidateId: string;
        primary: boolean;
      }>;
    };
  };
}

interface OrganizerExternalEventImportExecutionPlan {
  summary: {
    importActions: number;
    createActions: number;
    readOnlyActions?: number;
    skipped: number;
    blocked: number;
    projectionInvalid?: number;
    schemaInvalid: number;
    wouldPublishReadOnly?: number;
    wouldCreate: number;
    projectionValid?: number;
    projectionInvalidCount?: number;
    payloadValid: number;
    payloadInvalid: number;
    actionsByStatus: Record<string, number>;
  };
  policy: {
    status: string;
    writeEnabled: boolean;
    authorityModel: string;
    reason: string;
  };
  generatedFrom: {
    externalEventImportPlan: string;
    importPlanGeneratedFrom: Record<string, unknown>;
  };
  guardrails: string[];
  actions: OrganizerExternalEventImportExecutionAction[];
  commands: Record<string, string>;
}

interface OrganizerExternalEventImportExecutionAction {
  actionId: string;
  sourceActionId: string;
  sourceAction: string;
  status:
    | "blocked"
    | "projection_invalid"
    | "schema_invalid"
    | "skipped"
    | "would_create"
    | "would_publish_read_only";
  candidateId: string;
  entityId: string;
  targetCallable: string | null;
  targetWriter?: string;
  targetPath: string;
  sourceStatus: string;
  sourceReviewStatus: string;
  blockers: string[];
  payloadValidation: {
    valid: boolean;
    errors: Array<{
      path: string;
      message: string;
      keyword: string;
    }>;
  };
  projectionValidation?: {
    valid: boolean;
    errors: Array<{
      path: string;
      message: string;
      keyword: string;
    }>;
  };
  readOnlyEventProjection?: OrganizerExternalEventImportAction["proposedReadOnlyEventDraft"];
  createEventPayload?: {
    eventId?: string;
    clubId?: string;
    startTimeMillis?: number | null;
    endTimeMillis?: number | null;
    meetingPoint?: string;
    capacityLimit?: number | null;
    pace?: string | null;
    distanceKm?: number | null;
    [key: string]: unknown;
  };
}

interface OrganizerIntakeMarket {
  marketSlug: string;
  displayName: string;
  countryCode: string;
  eventFilter: {
    mode: string;
    citySlug: string;
  };
}

interface OrganizerIntakeGate {
  id: string;
  passed: boolean;
  description: string;
}

interface OrganizerSurfaceSummary {
  total: number;
  active: number;
  ambiguous: number;
  candidate: number;
  rejected: number;
  platforms: Record<string, number>;
}

interface OrganizerItemSurface {
  surfaceId: string;
  platform: string;
  surfaceKind: string;
  url: string | null;
  normalizedKey: string | null;
  role: string;
  status: string;
  crawl: {
    eventDiscoveryStatus: string;
    policy: string;
    supportsEventExtraction: boolean;
  };
  notes: string;
}

interface OrganizerCurationFormState {
  operationType: OrganizerCurationOperation;
  targetEntityId: string;
  surfaceId: string;
  newEntityId: string;
  decision: OrganizerSurfaceDecision;
  reason: string;
}

interface OrganizerLocationResolutionFormState {
  name: string;
  address: string;
  placeId: string;
  latitude: string;
  longitude: string;
  notes: string;
  note: string;
}

interface OrganizerPromotionPolicy {
  adminApprovalIndexesWebsite: boolean;
  adminApprovalPublishesWebsite: boolean;
  appVisibilityAfterPublicApproval: string;
}

interface OrganizerReviewDecision {
  decision: string;
  appVisibility: string;
  decidedAt: string;
  reviewer: string;
  decisionBatchId: string;
  sourceFile: string;
}

interface OrganizerDecisionCommands {
  approvePublic: string;
  hold: string;
  suppress: string;
}

interface OrganizerDetailsFormState {
  clubId: string;
  name: string;
  description: string;
  location: string;
  area: string;
  tagsText: string;
  instagramHandle: string;
  phoneNumber: string;
  email: string;
  imageUrl: string;
  profileImageUrl: string;
  entityKind: OrganizerEntityKind;
  entitySubtypesText: string;
  displayCategory: string;
  cityName: string;
  regionName: string;
  countryCode: string;
  countryName: string;
  appVisibility: OrganizerAppVisibility;
  publicPageSlug: string;
  publicPageCitySlug: string;
  canonicalPath: string;
  publishStatus: OrganizerPublishStatus;
  seoTitle: string;
  seoDescription: string;
  sourceConfidence: OrganizerSourceConfidence;
  verificationStatus: OrganizerVerificationStatus;
  headline: string;
  summary: string;
  sourceSummary: string;
  formatsText: string;
  fitNotesText: string;
  missingEvidenceText: string;
  reviewNote: string;
}

export function App() {
  const mode = dataMode();
  const [activeNav, setActiveNav] = useState("overview");
  const [analyticsRangePreset, setAnalyticsRangePreset] =
    useState<AnalyticsRangePreset>("30d");
  const [analyticsGranularity, setAnalyticsGranularity] =
    useState<AnalyticsGranularity>("day");
  const [analyticsStartDate, setAnalyticsStartDate] =
    useState(defaultAnalyticsDate(29));
  const [analyticsEndDate, setAnalyticsEndDate] =
    useState(defaultAnalyticsDate(0));
  const [analyticsClubId, setAnalyticsClubId] = useState("");
  const [analyticsEventId, setAnalyticsEventId] = useState("");
  const [overview, setOverview] =
    useState<AdminOverviewResponse>(sampleOverview);
  const [hostAnalytics, setHostAnalytics] =
    useState<HostAnalyticsResponse>(sampleHostAnalytics);
  const [isLoading, setIsLoading] = useState(false);
  const [decisionInFlight, setDecisionInFlight] =
    useState<Record<string, AccessApplicationDecision>>({});
  const [claimDecisionInFlight, setClaimDecisionInFlight] =
    useState<Record<string, ClubClaimDecision>>({});
  const [indexDecisionInFlight, setIndexDecisionInFlight] =
    useState<Record<string, ClubIndexDecision>>({});
  const [clubDetailsId, setClubDetailsId] =
    useState("afterfly-run-club-indore");
  const [clubDetails, setClubDetails] =
    useState<AdminClubDetails | null>(null);
  const [clubDetailsForm, setClubDetailsForm] =
    useState<OrganizerDetailsFormState | null>(null);
  const [isClubDetailsLoading, setIsClubDetailsLoading] = useState(false);
  const [isClubDetailsSaving, setIsClubDetailsSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [notice, setNotice] = useState<string | null>(null);
  const [user, setUser] = useState<User | null>(null);

  useEffect(() => {
    if (mode === "sample") return undefined;
    return onAuthStateChanged(auth, setUser);
  }, [mode]);

  const analyticsPayload = useMemo(
    () => buildHostAnalyticsPayload({
      clubId: analyticsClubId,
      eventId: analyticsEventId,
      granularity: analyticsGranularity,
      rangePreset: analyticsRangePreset,
      startDate: analyticsStartDate,
      endDate: analyticsEndDate,
    }),
    [
      analyticsClubId,
      analyticsEndDate,
      analyticsEventId,
      analyticsGranularity,
      analyticsRangePreset,
      analyticsStartDate,
    ]
  );

  const refresh = useCallback(async () => {
    setIsLoading(true);
    setError(null);
    try {
      const [nextOverview, nextHostAnalytics] = await Promise.all([
        loadOverview(),
        loadHostAnalytics(analyticsPayload),
      ]);
      setOverview(nextOverview);
      setHostAnalytics(nextHostAnalytics);
    } catch (loadError) {
      setError(
        loadError instanceof Error ?
          loadError.message :
          "Unable to load admin overview."
      );
    } finally {
      setIsLoading(false);
    }
  }, [analyticsPayload]);

  useEffect(() => {
    if (mode === "live" && !user) return;
    void refresh();
  }, [mode, refresh, user]);

  const handleLoadClubDetails = useCallback(async (clubId: string) => {
    const normalizedClubId = clubId.trim();
    if (!normalizedClubId) {
      setError("Enter an organizer document id.");
      return;
    }
    setIsClubDetailsLoading(true);
    setError(null);
    setNotice(null);
    try {
      const response = await loadClubDetails({clubId: normalizedClubId});
      setClubDetails(response.club);
      setClubDetailsForm(formFromClubDetails(response.club));
      setClubDetailsId(response.club.clubId);
    } catch (loadError) {
      setError(
        loadError instanceof Error ?
          loadError.message :
          "Unable to load organizer details."
      );
    } finally {
      setIsClubDetailsLoading(false);
    }
  }, []);

  useEffect(() => {
    if (mode === "live" && !user) return;
    if (activeNav !== "hosts" || clubDetailsForm) return;
    void handleLoadClubDetails(clubDetailsId);
  }, [
    activeNav,
    clubDetailsForm,
    clubDetailsId,
    handleLoadClubDetails,
    mode,
    user,
  ]);

  const handleSaveClubDetails = useCallback(async () => {
    if (!clubDetailsForm) {
      setError("Load an organizer before saving.");
      return;
    }
    setIsClubDetailsSaving(true);
    setError(null);
    setNotice(null);
    try {
      const payload = payloadFromOrganizerDetailsForm(clubDetailsForm);
      const result = await saveClubDetails(payload);
      const refreshed = await loadClubDetails({clubId: result.clubId});
      setClubDetails(refreshed.club);
      setClubDetailsForm(formFromClubDetails(refreshed.club));
      setNotice(
        `Saved ${result.updatedFieldCount} organizer detail fields.`
      );
      if (mode === "live") void refresh();
    } catch (saveError) {
      setError(
        saveError instanceof Error ?
          saveError.message :
          "Unable to save organizer details."
      );
    } finally {
      setIsClubDetailsSaving(false);
    }
  }, [clubDetailsForm, mode, refresh]);

  const primaryMetrics = useMemo(
    () => priorityMetricIds
      .map((id) => overview.metrics.find((metric) => metric.id === id))
      .filter((metric): metric is AdminOverviewMetric => Boolean(metric)),
    [overview.metrics]
  );

  const handleAccessDecision = useCallback(async (
    item: AdminQueueItem,
    decision: AccessApplicationDecision
  ) => {
    const applicationUid = applicationUidFromTargetPath(item.targetPath);
    if (!applicationUid) {
      setError("Cannot decide an access application without a valid target.");
      return;
    }

    setDecisionInFlight((current) => ({
      ...current,
      [item.targetPath]: decision,
    }));
    setError(null);
    setNotice(null);

    try {
      await decideAccessApplication({applicationUid, decision});
      setOverview((current) =>
        removeAccessApplication(current, item.targetPath)
      );
      setNotice(
        `${decision === "approve" ? "Approved" : "Denied"} ${item.title}.`
      );
      if (mode === "live") void refresh();
    } catch (decisionError) {
      setError(
        decisionError instanceof Error ?
          decisionError.message :
          "Unable to review access application."
      );
    } finally {
      setDecisionInFlight((current) => {
        const next = {...current};
        delete next[item.targetPath];
        return next;
      });
    }
  }, [mode, refresh]);

  const handleClubClaimDecision = useCallback(async (
    item: AdminQueueItem,
    decision: ClubClaimDecision
  ) => {
    const requestId = clubClaimRequestIdFromTargetPath(item.targetPath);
    if (!requestId) {
      setError("Cannot decide an organizer claim without a valid request.");
      return;
    }

    setClaimDecisionInFlight((current) => ({
      ...current,
      [item.targetPath]: decision,
    }));
    setError(null);
    setNotice(null);

    try {
      await decideClubClaim({requestId, decision});
      setOverview((current) =>
        removeClubClaimRequest(current, item.targetPath)
      );
      setNotice(
        `${decision === "approve" ? "Approved" : "Rejected"} ${item.title}.`
      );
      if (mode === "live") void refresh();
    } catch (decisionError) {
      setError(
        decisionError instanceof Error ?
          decisionError.message :
          "Unable to review organizer claim."
      );
    } finally {
      setClaimDecisionInFlight((current) => {
        const next = {...current};
        delete next[item.targetPath];
        return next;
      });
    }
  }, [mode, refresh]);

  const handleClubIndexDecision = useCallback(async (
    item: AdminQueueItem,
    decision: ClubIndexDecision
  ) => {
    const clubId = clubIdFromTargetPath(item.targetPath);
    if (!clubId) {
      setError("Cannot review indexing without a valid organizer profile.");
      return;
    }

    setIndexDecisionInFlight((current) => ({
      ...current,
      [item.targetPath]: decision,
    }));
    setError(null);
    setNotice(null);

    try {
      await setClubIndexStatus({
        clubId,
        indexStatus: decision,
        checklist: decision === "indexReady" ?
          completeIndexChecklist() :
          emptyIndexChecklist(),
        reviewNote: decision === "indexReady" ?
          "Admin marked source evidence, media rights, cadence, and owner/contact checks complete." :
          "Admin kept this organizer page noindex from the overview queue.",
      });
      setOverview((current) =>
        removeClubIndexReview(current, item.targetPath)
      );
      setNotice(
        `${decision === "indexReady" ? "Marked index-ready" : "Kept noindex"} ${item.title}.`
      );
      if (mode === "live") void refresh();
    } catch (decisionError) {
      setError(
        decisionError instanceof Error ?
          decisionError.message :
          "Unable to review organizer indexing."
      );
    } finally {
      setIndexDecisionInFlight((current) => {
        const next = {...current};
        delete next[item.targetPath];
        return next;
      });
    }
  }, [mode, refresh]);

  if (mode === "live" && !user) {
    return <SignInScreen onSignIn={() => void signInWithGoogle()} />;
  }

  const topbarCopy = copyForAdminSection(activeNav);

  return (
    <div className="app-shell">
      <aside className="sidebar" aria-label="Admin sections">
        <div className="brand-block">
          <div className="brand-mark">C</div>
          <div>
            <div className="brand-title">Catch Ops</div>
            <div className="brand-subtitle">{mode} console</div>
          </div>
        </div>
        <nav className="nav-list">
          {navigation.map((item) => {
            const Icon = item.icon;
            const selected = activeNav === item.id;
            return (
              <button
                className={`nav-item ${selected ? "selected" : ""}`}
                key={item.id}
                onClick={() => setActiveNav(item.id)}
                type="button"
              >
                <Icon aria-hidden="true" size={17} strokeWidth={1.8} />
                <span>{item.label}</span>
              </button>
            );
          })}
        </nav>
        <div className="sidebar-footer">
          <Lock size={15} strokeWidth={1.8} />
          <span>Admin claim required</span>
        </div>
      </aside>

      <main className="workspace">
        <header className="topbar">
          <div>
            <h1>{topbarCopy.title}</h1>
            <p>{topbarCopy.subtitle}</p>
          </div>
          <div className="topbar-actions">
            <div className="search-control">
              <Search size={16} strokeWidth={1.8} />
              <input aria-label="Search users or events" placeholder="Search user, host, event" />
            </div>
            <select aria-label="Environment" defaultValue="dev">
              <option value="dev">Dev</option>
              <option value="staging">Staging</option>
              <option value="prod">Prod</option>
            </select>
            <div className="segmented" aria-label="Time range">
              {(["7d", "30d", "90d", "month"] as AnalyticsRangePreset[]).map((range) => (
                <button
                  className={analyticsRangePreset === range ? "selected" : ""}
                  key={range}
                  onClick={() => setAnalyticsRangePreset(range)}
                  type="button"
                >
                  {range === "month" ? "month" : range}
                </button>
              ))}
            </div>
            <button
              className="icon-button"
              disabled={isLoading}
              onClick={() => void refresh()}
              title="Refresh"
              type="button"
            >
              <RefreshCw
                className={isLoading ? "spin" : ""}
                size={17}
                strokeWidth={1.9}
              />
            </button>
            {mode === "live" && (
              <button className="ghost-button" onClick={() => void signOutAdmin()} type="button">
                Sign out
              </button>
            )}
          </div>
        </header>

        {error && (
          <div className="error-banner" role="alert">
            <AlertTriangle size={17} strokeWidth={1.9} />
            <span>{error}</span>
          </div>
        )}
        {notice && (
          <div className="success-banner" role="status">
            <CheckCircle2 size={17} strokeWidth={1.9} />
            <span>{notice}</span>
          </div>
        )}

        {activeNav === "organizer-intake" ? (
          <OrganizerIntakeScreen
            bridge={organizerIntakeBridge}
            onError={setError}
            onNotice={setNotice}
          />
        ) : activeNav === "hosts" ? (
          <OrganizerDetailsScreen
            club={clubDetails}
            clubId={clubDetailsId}
            form={clubDetailsForm}
            isLoading={isClubDetailsLoading}
            isSaving={isClubDetailsSaving}
            onClubIdChange={setClubDetailsId}
            onFormChange={setClubDetailsForm}
            onLoad={() => void handleLoadClubDetails(clubDetailsId)}
            onSave={() => void handleSaveClubDetails()}
          />
        ) : (
          <>
            <AnalyticsControls
              clubId={analyticsClubId}
              endDate={analyticsEndDate}
              eventId={analyticsEventId}
              granularity={analyticsGranularity}
              rangePreset={analyticsRangePreset}
              startDate={analyticsStartDate}
              onClearScope={() => {
                setAnalyticsClubId("");
                setAnalyticsEventId("");
              }}
              onClubIdChange={setAnalyticsClubId}
              onEndDateChange={setAnalyticsEndDate}
              onEventIdChange={setAnalyticsEventId}
              onGranularityChange={setAnalyticsGranularity}
              onRangePresetChange={setAnalyticsRangePreset}
              onStartDateChange={setAnalyticsStartDate}
            />
            <section className="metric-grid" aria-label="Key metrics">
              {primaryMetrics.map((metric) => (
                <MetricTile key={metric.id} metric={metric} />
              ))}
            </section>

            <section className="main-grid">
              <Panel
                className="span-2"
                icon={<ShieldAlert size={18} strokeWidth={1.9} />}
                title="Live queues"
                action={`${queueCount(overview)} open`}
              >
                <div className="queue-columns">
                  <QueueList
                    intent="danger"
                    items={[
                      ...overview.queues.safetyReports,
                      ...overview.queues.eventSafetyReports,
                    ]}
                    title="Safety reports"
                  />
                  <QueueList
                    decisionInFlight={decisionInFlight}
                    intent="warning"
                    items={overview.queues.accessApplications}
                    onAccessDecision={handleAccessDecision}
                    title="Access applications"
                  />
                  <QueueList
                    claimDecisionInFlight={claimDecisionInFlight}
                    intent="neutral"
                    items={overview.queues.clubClaimRequests}
                    onClubClaimDecision={handleClubClaimDecision}
                    title="Organizer claims"
                  />
                  <QueueList
                    indexDecisionInFlight={indexDecisionInFlight}
                    intent="neutral"
                    items={overview.queues.clubIndexReviews}
                    onClubIndexDecision={handleClubIndexDecision}
                    title="Index reviews"
                  />
                  <QueueList
                    intent="neutral"
                    items={[
                      ...overview.queues.moderationFlags,
                      ...overview.queues.paymentIssues,
                    ]}
                    title="Moderation and payments"
                  />
                </div>
              </Panel>

              <Panel
                icon={<LineChart size={18} strokeWidth={1.9} />}
                title="Attendance trend"
                action={analyticsMetricAction(hostAnalytics, "attendanceRate")}
              >
                <LineMiniChart points={analyticsRatePoints(hostAnalytics)} />
              </Panel>

              <Panel
                icon={<Users size={18} strokeWidth={1.9} />}
                title="Booking demand"
                action={analyticsMetricAction(hostAnalytics, "bookings")}
              >
                <BarMiniChart points={analyticsTrendPoints(
                  hostAnalytics,
                  "bookings"
                )} />
              </Panel>

              <Panel
                className="span-2"
                icon={<BarChart3 size={18} strokeWidth={1.9} />}
                title="Event performance"
                action={`${hostAnalytics.topEvents.length} ranked`}
              >
                <EventPerformanceTable
                  events={hostAnalytics.topEvents}
                  onFocusEvent={setAnalyticsEventId}
                />
              </Panel>

              <Panel
                icon={<Sparkles size={18} strokeWidth={1.9} />}
                title="User value signals"
                action="Draft model"
              >
                <ValueSignals />
              </Panel>

              <Panel
                icon={<Database size={18} strokeWidth={1.9} />}
                title="Data quality"
                action={overview.timezone}
              >
                <DataQualityRows
                  hostAnalytics={hostAnalytics}
                  overview={overview}
                />
              </Panel>
            </section>
          </>
        )}
      </main>
    </div>
  );
}

function copyForAdminSection(activeNav: string) {
  if (activeNav === "organizer-intake") {
    return {
      title: "Organizer intake",
      subtitle:
        "Review private scraped candidates before public listing projection, indexing, or claim handoff.",
    };
  }
  if (activeNav === "hosts") {
    return {
      title: "Organizer details",
      subtitle:
        "Review and clean up canonical organizer fields before publishing, indexing, or claim handoff.",
    };
  }
  return {
    title: "Overview",
    subtitle: "Live operations, cohort health, finance risk, and marketplace signals.",
  };
}

function AnalyticsControls({
  clubId,
  endDate,
  eventId,
  granularity,
  rangePreset,
  startDate,
  onClearScope,
  onClubIdChange,
  onEndDateChange,
  onEventIdChange,
  onGranularityChange,
  onRangePresetChange,
  onStartDateChange,
}: {
  clubId: string;
  endDate: string;
  eventId: string;
  granularity: AnalyticsGranularity;
  rangePreset: AnalyticsRangePreset;
  startDate: string;
  onClearScope: () => void;
  onClubIdChange: (value: string) => void;
  onEndDateChange: (value: string) => void;
  onEventIdChange: (value: string) => void;
  onGranularityChange: (value: AnalyticsGranularity) => void;
  onRangePresetChange: (value: AnalyticsRangePreset) => void;
  onStartDateChange: (value: string) => void;
}) {
  const hasScope = clubId.trim() || eventId.trim();
  return (
    <section className="analytics-controls" aria-label="Host analytics filters">
      <label className="field-control">
        <span>Range</span>
        <select
          value={rangePreset}
          onChange={(event) =>
            onRangePresetChange(event.target.value as AnalyticsRangePreset)
          }
        >
          <option value="7d">Last 7 days</option>
          <option value="30d">Last 30 days</option>
          <option value="90d">Last 90 days</option>
          <option value="month">This month</option>
          <option value="custom">Custom</option>
        </select>
      </label>
      <label className="field-control">
        <span>Group by</span>
        <select
          value={granularity}
          onChange={(event) =>
            onGranularityChange(event.target.value as AnalyticsGranularity)
          }
        >
          <option value="day">Day</option>
          <option value="week">Week</option>
          <option value="month">Month</option>
        </select>
      </label>
      {rangePreset === "custom" && (
        <>
          <label className="field-control">
            <span>Start date</span>
            <input
              type="date"
              value={startDate}
              onChange={(event) => onStartDateChange(event.target.value)}
            />
          </label>
          <label className="field-control">
            <span>End date</span>
            <input
              type="date"
              value={endDate}
              onChange={(event) => onEndDateChange(event.target.value)}
            />
          </label>
        </>
      )}
      <label className="field-control">
        <span>Organizer id</span>
        <input
          value={clubId}
          onChange={(event) => onClubIdChange(event.target.value)}
          placeholder="all organizers"
        />
      </label>
      <label className="field-control">
        <span>Event id</span>
        <input
          value={eventId}
          onChange={(event) => onEventIdChange(event.target.value)}
          placeholder="all events"
        />
      </label>
      <button
        className="ghost-button analytics-clear"
        disabled={!hasScope}
        onClick={onClearScope}
        type="button"
      >
        Clear scope
      </button>
    </section>
  );
}

function buildHostAnalyticsPayload({
  clubId,
  endDate,
  eventId,
  granularity,
  rangePreset,
  startDate,
}: {
  clubId: string;
  endDate: string;
  eventId: string;
  granularity: AnalyticsGranularity;
  rangePreset: AnalyticsRangePreset;
  startDate: string;
}): HostAnalyticsQueryPayload {
  const isCustom = rangePreset === "custom";
  return {
    clubId: clubId.trim() || null,
    eventId: eventId.trim() || null,
    rangePreset,
    startDate: isCustom ? startDate : null,
    endDate: isCustom ? endDate : null,
    granularity,
  };
}

function defaultAnalyticsDate(daysAgo: number): string {
  const date = new Date();
  date.setUTCDate(date.getUTCDate() - daysAgo);
  return date.toISOString().slice(0, 10);
}

function SignInScreen({onSignIn}: {onSignIn: () => void}) {
  return (
    <main className="signin-screen">
      <section className="signin-panel">
        <div className="brand-mark large">C</div>
        <h1>Catch Ops</h1>
        <p>Internal admin access requires Firebase Auth and an admin claim.</p>
        <button className="primary-button" onClick={onSignIn} type="button">
          Sign in with Google
        </button>
      </section>
    </main>
  );
}

function OrganizerIntakeScreen({
  bridge,
  onError,
  onNotice,
}: {
  bridge: OrganizerIntakeBridge;
  onError: (message: string | null) => void;
  onNotice: (message: string | null) => void;
}) {
  const [decisionNotes, setDecisionNotes] = useState<Record<string, string>>(
    {}
  );
  const [decisionInFlight, setDecisionInFlight] =
    useState<Record<string, OrganizerIntakeDecision>>({});
  const [localDecisions, setLocalDecisions] =
    useState<Record<string, AdminDecideOrganizerIntakeResponse>>({});
  const [curationInFlight, setCurationInFlight] =
    useState<Record<string, boolean>>({});
  const [localCuration, setLocalCuration] =
    useState<Record<string, AdminRecordOrganizerCurationResponse>>({});
  const [curationForms, setCurationForms] =
    useState<Record<string, OrganizerCurationFormState>>({});
  const [eventDecisionNotes, setEventDecisionNotes] =
    useState<Record<string, string>>({});
  const [eventDecisionInFlight, setEventDecisionInFlight] =
    useState<Record<string, OrganizerEventCandidateDecision>>({});
  const [localEventDecisions, setLocalEventDecisions] =
    useState<Record<string, AdminDecideOrganizerEventCandidateResponse>>({});
  const [locationResolutionForms, setLocationResolutionForms] =
    useState<Record<string, OrganizerLocationResolutionFormState>>({});
  const [locationResolutionInFlight, setLocationResolutionInFlight] =
    useState<Record<string, boolean>>({});
  const [localLocationResolutions, setLocalLocationResolutions] =
    useState<Record<string, AdminResolveOrganizerEventLocationResponse>>({});
  const [policyDecisionNotes, setPolicyDecisionNotes] =
    useState<Record<string, string>>({});
  const [policyDecisionInFlight, setPolicyDecisionInFlight] =
    useState<Record<string, OrganizerPolicyGapDecision>>({});
  const [localPolicyDecisions, setLocalPolicyDecisions] =
    useState<Record<string, AdminDecideOrganizerPolicyGapResponse>>({});
  const [manualReportAcknowledgements, setManualReportAcknowledgements] =
    useState<Record<string, boolean>>({});
  const publicationPacketByEntity = useMemo(() =>
    new Map(
      bridge.publicationReviewPackets.packets.map((packet) => [
        packet.entityId,
        packet,
      ])
    ), [bridge.publicationReviewPackets.packets]);
  const metrics = [
    {label: "Host entities", value: bridge.summary.canonicalHostEntities ?? 0},
    {label: "Evidence refs", value: bridge.summary.canonicalEvidenceRecords ?? 0},
    {label: "Review packets", value: bridge.summary.publicationReviewPackets ?? 0},
    {label: "Would publish", value: bridge.summary.publicationImpactWouldPublish ?? 0},
    {label: "Would index", value: bridge.summary.publicationImpactWouldIndex ?? 0},
    {label: "Review items", value: bridge.summary.reviewItems},
    {label: "Promotion", value: bridge.summary.promotionReview},
    {label: "Evidence", value: bridge.summary.evidenceReview},
    {label: "Blocked", value: bridge.summary.blocked},
    {label: "Public", value: bridge.summary.approvedPublic},
    {label: "App visible", value: bridge.summary.appDiscoverable},
    {label: "Claim writes", value: bridge.summary.claimTargetSyncPreviewWrites ?? 0},
    {label: "Search surfaces", value: bridge.summary.searchResultCandidates ?? 0},
    {label: "Event candidates", value: bridge.summary.externalEventCandidates ?? 0},
    {label: "Location tasks", value: bridge.summary.externalEventLocationTasks ?? 0},
    {
      label: "Read-only events",
      value: bridge.summary.externalEventImportProposedReadOnlyEvents ??
        bridge.summary.externalEventImportProposedCreates ??
        0,
    },
    {
      label: "Projection errors",
      value: bridge.summary.externalEventImportExecutionProjectionInvalidCount ??
        bridge.summary.externalEventImportExecutionPayloadInvalid ??
        0,
    },
    {label: "Crawl surfaces", value: bridge.summary.crawlCapableSurfaces ?? 0},
    {label: "Crawl runs", value: bridge.summary.crawlRunIntents ?? 0},
    {label: "Raw payloads", value: bridge.summary.rawProviderPayloads ?? 0},
    {label: "Curation", value: bridge.summary.curationOperations ?? 0},
    {label: "Policy gates", value: bridge.summary.readinessPolicyNeeded ?? 0},
    {label: "Policy gaps", value: bridge.summary.policyGapsDecisionRequired ?? 0},
    {label: "Policy inputs", value: bridge.summary.policyDecisionUnanswered ?? 0},
    {label: "Pending inputs", value: bridge.summary.pendingInputRequests ?? 0},
    {label: "Admin inputs", value: bridge.summary.pendingAdminPublicationInputs ?? 0},
    {label: "Answer packets", value: bridge.summary.reviewedAnswerPackets ?? 0},
    {label: "Ready packets", value: bridge.summary.reviewedAnswerPacketsReady ?? 0},
    {label: "Work covered", value: bridge.summary.pendingWorkCovered ?? 0},
    {label: "Untriaged work", value: bridge.summary.pendingWorkUntriaged ?? 0},
  ];
  const handleDecision = useCallback(async (
    item: OrganizerIntakeItem,
    decision: OrganizerIntakeDecision
  ) => {
    const publicationPacket = publicationPacketByEntity.get(item.entityId);
    if (decision === "approve_public" &&
      !publicationPacketReady(publicationPacket)) {
      onError(
        publicationPacket ?
          "Resolve publication packet blockers before approving this organizer." :
          "Generate a publication review packet before approving this organizer."
      );
      return;
    }
    const manualReportCount =
      publicationPacket?.evidenceSummary.manualReportsWithoutArtifacts ?? 0;
    if (decision === "approve_public" &&
      manualReportCount > 0 &&
      manualReportAcknowledgements[item.entityId] !== true) {
      onError(
        "Acknowledge manual reports before approving this organizer."
      );
      return;
    }
    const checklist = {
      ...intakeChecklistForDecision(item, decision),
      ...(decision === "approve_public" && manualReportCount > 0 ?
        {manualReportsReviewed: true} :
        {}),
    };
    if (decision === "approve_public" &&
      !Object.values(checklist).every(Boolean)) {
      onError("Resolve review gates before approving this organizer.");
      return;
    }
    const note = decisionNotes[item.entityId]?.trim() ||
      defaultIntakeDecisionNote(item, decision);
    setDecisionInFlight((current) => ({
      ...current,
      [item.entityId]: decision,
    }));
    onError(null);
    onNotice(null);
    try {
      const response = await decideOrganizerIntake({
        entityId: item.entityId,
        decision,
        appVisibility: "hidden",
        checklist,
        note,
      });
      setLocalDecisions((current) => ({
        ...current,
        [item.entityId]: response,
      }));
      onNotice(
        `Recorded ${decisionLabel(decision)} for ${item.displayName}.`
      );
    } catch (decisionError) {
      onError(
        decisionError instanceof Error ?
          decisionError.message :
          "Unable to record organizer intake decision."
      );
    } finally {
      setDecisionInFlight((current) => {
        const next = {...current};
        delete next[item.entityId];
        return next;
      });
    }
  }, [
    decisionNotes,
    manualReportAcknowledgements,
    onError,
    onNotice,
    publicationPacketByEntity,
  ]);
  const handleAttachCandidate = useCallback(async (
    candidate: OrganizerSearchCandidate
  ) => {
    const entityId = candidate.existingEntityMatches[0]?.entityId;
    if (!entityId) {
      onError("Choose a matched organizer before attaching this surface.");
      return;
    }
    setCurationInFlight((current) => ({
      ...current,
      [candidate.candidateId]: true,
    }));
    onError(null);
    onNotice(null);
    try {
      const response = await recordOrganizerCuration({
        operationType: "attach_surface",
        entityId,
        sourceCandidateId: candidate.candidateId,
        surface: surfaceForCandidateCuration(candidate),
        reason: `Search candidate ${candidate.candidateId} belongs to ${entityId}.`,
      });
      setLocalCuration((current) => ({
        ...current,
        [candidate.candidateId]: response,
      }));
      onNotice(
        `Recorded curation attach for ${candidate.title}.`
      );
    } catch (curationError) {
      onError(
        curationError instanceof Error ?
          curationError.message :
          "Unable to record organizer curation operation."
      );
    } finally {
      setCurationInFlight((current) => {
        const next = {...current};
        delete next[candidate.candidateId];
        return next;
      });
    }
  }, [onError, onNotice]);
  const handleItemCuration = useCallback(async (
    item: OrganizerIntakeItem,
    form: OrganizerCurationFormState
  ) => {
    const payload = curationPayloadForItem(item, form);
    if (!payload.ok) {
      onError(payload.message);
      return;
    }
    const operationKey = curationFormKey(item, form);
    setCurationInFlight((current) => ({
      ...current,
      [operationKey]: true,
    }));
    onError(null);
    onNotice(null);
    try {
      const response = await recordOrganizerCuration(payload.value);
      setLocalCuration((current) => ({
        ...current,
        [operationKey]: response,
      }));
      onNotice(
        `Recorded ${form.operationType.replaceAll("_", " ")} for ${item.displayName}.`
      );
    } catch (curationError) {
      onError(
        curationError instanceof Error ?
          curationError.message :
          "Unable to record organizer curation operation."
      );
    } finally {
      setCurationInFlight((current) => {
        const next = {...current};
        delete next[operationKey];
        return next;
      });
    }
  }, [onError, onNotice]);
  const handleEventDecision = useCallback(async (
    candidate: OrganizerExternalEventCandidate,
    decision: OrganizerEventCandidateDecision
  ) => {
    const checklist = eventCandidateChecklistForDecision(candidate, decision);
    if (decision === "approve_for_import" &&
      !Object.values(checklist).every(Boolean)) {
      onError("Resolve event candidate review gates before import approval.");
      return;
    }
    const note = eventDecisionNotes[candidate.candidateId]?.trim() ||
      defaultEventCandidateDecisionNote(candidate, decision);
    setEventDecisionInFlight((current) => ({
      ...current,
      [candidate.candidateId]: decision,
    }));
    onError(null);
    onNotice(null);
    try {
      const response = await decideOrganizerEventCandidate({
        candidateId: candidate.candidateId,
        decision,
        checklist,
        note,
      });
      setLocalEventDecisions((current) => ({
        ...current,
        [candidate.candidateId]: response,
      }));
      onNotice(
        `Recorded ${eventDecisionLabel(decision)} for ${candidate.title}.`
      );
    } catch (decisionError) {
      onError(
        decisionError instanceof Error ?
          decisionError.message :
          "Unable to record event candidate decision."
      );
    } finally {
      setEventDecisionInFlight((current) => {
        const next = {...current};
        delete next[candidate.candidateId];
        return next;
      });
    }
  }, [eventDecisionNotes, onError, onNotice]);
  const handlePolicyGapDecision = useCallback(async (
    gap: OrganizerPolicyGap,
    decision: OrganizerPolicyGapDecision
  ) => {
    const checklist = policyGapChecklistForDecision(decision);
    const requiredInputsReviewed = decision === "accept" ?
      gap.requiredInputs :
      [];
    if (decision === "accept" &&
      (!Object.values(checklist).every(Boolean) ||
        requiredInputsReviewed.length === 0)) {
      onError("Review all policy inputs before accepting this policy gap.");
      return;
    }
    const note = policyDecisionNotes[gap.gapId]?.trim() ||
      defaultPolicyGapDecisionNote(gap, decision);
    setPolicyDecisionInFlight((current) => ({
      ...current,
      [gap.gapId]: decision,
    }));
    onError(null);
    onNotice(null);
    try {
      const response = await decideOrganizerPolicyGap({
        gapId: gap.gapId,
        decision,
        requiredInputsReviewed,
        checklist,
        note,
      });
      setLocalPolicyDecisions((current) => ({
        ...current,
        [gap.gapId]: response,
      }));
      onNotice(
        `Recorded ${policyGapDecisionLabel(decision)} for ${gap.gapId}.`
      );
    } catch (decisionError) {
      onError(
        decisionError instanceof Error ?
          decisionError.message :
          "Unable to record policy gap decision."
      );
    } finally {
      setPolicyDecisionInFlight((current) => {
        const next = {...current};
        delete next[gap.gapId];
        return next;
      });
    }
  }, [policyDecisionNotes, onError, onNotice]);
  const handlePendingInputDecision = useCallback(async (
    input: OrganizerPendingInputItem,
    decision: string
  ) => {
    const payload = input.callableSubmission?.payloadsByDecision[decision];
    if (!payload) {
      onError("Generated pending-input payload is missing for this decision.");
      return;
    }
    onError(null);
    onNotice(null);
    if (input.requestType === "admin_publication_decision") {
      const intakeDecision = organizerIntakeDecisionFromString(decision);
      if (!intakeDecision) {
        onError("Pending input decision is not a publication decision.");
        return;
      }
      setDecisionInFlight((current) => ({
        ...current,
        [input.subjectId]: intakeDecision,
      }));
      try {
        const response = await decideOrganizerIntake(
          payload as unknown as AdminDecideOrganizerIntakePayload
        );
        setLocalDecisions((current) => ({
          ...current,
          [response.entityId]: response,
        }));
        onNotice(
          `Recorded ${decisionLabel(response.decision)} for ${input.subjectName}.`
        );
      } catch (decisionError) {
        onError(
          decisionError instanceof Error ?
            decisionError.message :
            "Unable to record organizer intake decision."
        );
      } finally {
        setDecisionInFlight((current) => {
          const next = {...current};
          delete next[input.subjectId];
          return next;
        });
      }
      return;
    }
    if (input.requestType === "policy_decision") {
      const policyDecision = organizerPolicyGapDecisionFromString(decision);
      if (!policyDecision) {
        onError("Pending input decision is not a policy decision.");
        return;
      }
      setPolicyDecisionInFlight((current) => ({
        ...current,
        [input.subjectId]: policyDecision,
      }));
      try {
        const response = await decideOrganizerPolicyGap(
          payload as unknown as AdminDecideOrganizerPolicyGapPayload
        );
        setLocalPolicyDecisions((current) => ({
          ...current,
          [response.gapId]: response,
        }));
        onNotice(
          `Recorded ${policyGapDecisionLabel(response.decision)} for ${input.subjectName}.`
        );
      } catch (decisionError) {
        onError(
          decisionError instanceof Error ?
            decisionError.message :
            "Unable to record policy gap decision."
        );
      } finally {
        setPolicyDecisionInFlight((current) => {
          const next = {...current};
          delete next[input.subjectId];
          return next;
        });
      }
      return;
    }
    onError("Pending input request type is not wired for admin action.");
  }, [onError, onNotice]);
  const handleLocationResolution = useCallback(async (
    task: OrganizerExternalEventLocationResolutionTask
  ) => {
    const form = locationResolutionForms[task.taskId] ??
      locationResolutionFormFromTask(task);
    const latitude = Number(form.latitude);
    const longitude = Number(form.longitude);
    const name = form.name.trim() ||
      task.sourceLocation.name?.trim() ||
      task.resolutionQuery.trim();
    if (!name) {
      onError("Enter a reviewed location name before resolving coordinates.");
      return;
    }
    if (!Number.isFinite(latitude) || latitude < -90 || latitude > 90 ||
      !Number.isFinite(longitude) || longitude < -180 || longitude > 180) {
      onError("Enter reviewed latitude and longitude values.");
      return;
    }
    const note = form.note.trim() ||
      `Manual location QA complete for ${task.title}.`;
    setLocationResolutionInFlight((current) => ({
      ...current,
      [task.taskId]: true,
    }));
    onError(null);
    onNotice(null);
    try {
      const response = await resolveOrganizerEventLocation({
        candidateId: task.candidateId,
        location: {
          name,
          address: nullableInput(form.address),
          placeId: nullableInput(form.placeId),
          latitude,
          longitude,
          notes: nullableInput(form.notes),
        },
        checklist: {
          sourceLocationReviewed: true,
          coordinatesReviewed: true,
          placeIdentityReviewed: true,
          importSafetyReviewed: true,
        },
        note,
      });
      setLocalLocationResolutions((current) => ({
        ...current,
        [task.candidateId]: response,
      }));
      onNotice(`Resolved event location for ${task.title}.`);
    } catch (resolutionError) {
      onError(
        resolutionError instanceof Error ?
          resolutionError.message :
          "Unable to record event location resolution."
      );
    } finally {
      setLocationResolutionInFlight((current) => {
        const next = {...current};
        delete next[task.taskId];
        return next;
      });
    }
  }, [locationResolutionForms, onError, onNotice]);

  return (
    <>
      <section className="metric-grid" aria-label="Organizer intake metrics">
        {metrics.map((metric) => (
          <article
            className={`metric-tile ${metric.label === "Blocked" ? "attention" : ""}`}
            key={metric.label}
          >
            <div className="metric-label">{metric.label}</div>
            <div className="metric-value">{metric.value.toLocaleString()}</div>
          </article>
        ))}
      </section>

      <section className="main-grid intake-layout">
        <Panel
          className="span-2"
          icon={<Settings2 size={18} strokeWidth={1.9} />}
          title="Workflow readiness"
          action={bridge.workflowReadiness.status.replaceAll("_", " ")}
        >
          <OrganizerWorkflowReadinessView readiness={bridge.workflowReadiness} />
        </Panel>

        <Panel
          className="span-2"
          icon={<FileWarning size={18} strokeWidth={1.9} />}
          title="Operator action queue"
          action={`${bridge.operatorActionQueue.summary.actions} actions`}
        >
          <OrganizerOperatorActionQueueView queue={bridge.operatorActionQueue} />
        </Panel>

        <Panel
          className="span-2"
          icon={<Activity size={18} strokeWidth={1.9} />}
          title="Operational health"
          action={bridge.operationalHealth.summary.healthStatus.replaceAll("_", " ")}
        >
          <OrganizerOperationalHealthView health={bridge.operationalHealth} />
        </Panel>

        <Panel
          className="span-2"
          icon={<CheckCircle2 size={18} strokeWidth={1.9} />}
          title="Pending work coverage"
          action={bridge.pendingWorkCoverage.summary.status.replaceAll("_", " ")}
        >
          <OrganizerPendingWorkCoverageView
            coverage={bridge.pendingWorkCoverage}
          />
        </Panel>

        <Panel
          className="span-2"
          icon={<UserCheck size={18} strokeWidth={1.9} />}
          title="Pending admin/product inputs"
          action={`${bridge.pendingInputRequest.summary.requests} inputs`}
        >
          <OrganizerPendingInputRequestView
            onPendingDecision={handlePendingInputDecision}
            policyDecisions={localPolicyDecisions}
            policyInFlight={policyDecisionInFlight}
            publicationDecisions={localDecisions}
            publicationInFlight={decisionInFlight}
            request={bridge.pendingInputRequest}
          />
        </Panel>

        <Panel
          className="span-2"
          icon={<FileWarning size={18} strokeWidth={1.9} />}
          title="Reviewed answer packets"
          action={bridge.reviewedDecisionAnswerPackets.summary.status.replaceAll("_", " ")}
        >
          <OrganizerReviewedDecisionAnswerPacketsView
            register={bridge.reviewedDecisionAnswerPackets}
          />
        </Panel>

        <Panel
          className="span-2"
          icon={<RefreshCw size={18} strokeWidth={1.9} />}
          title="Promotion execution"
          action={bridge.promotionExecutionPacket.summary.status.replaceAll("_", " ")}
        >
          <OrganizerPromotionExecutionView
            packet={bridge.promotionExecutionPacket}
          />
        </Panel>

        <Panel
          className="span-2"
          icon={<Users size={18} strokeWidth={1.9} />}
          title="Canonical host registry"
          action={`${bridge.canonicalHostEntities.summary.entities} entities`}
        >
          <OrganizerCanonicalHostRegistryView
            registry={bridge.canonicalHostEntities}
          />
        </Panel>

        <Panel
          className="span-2"
          icon={<Database size={18} strokeWidth={1.9} />}
          title="Canonical evidence index"
          action={`${bridge.canonicalEvidenceIndex.summary.resolvedArtifactRefs} resolved`}
        >
          <OrganizerCanonicalEvidenceIndexView
            index={bridge.canonicalEvidenceIndex}
          />
        </Panel>

        <Panel
          className="span-2"
          icon={<CheckCircle2 size={18} strokeWidth={1.9} />}
          title="Publication review packets"
          action={`${bridge.publicationReviewPackets.summary.readyForManualPublicationReview} ready`}
        >
          <OrganizerPublicationReviewPacketsView
            packets={bridge.publicationReviewPackets}
          />
        </Panel>

        <Panel
          className="span-2"
          icon={<LineChart size={18} strokeWidth={1.9} />}
          title="Publication impact preview"
          action={`${bridge.publicationDecisionImpactPreview.summary.wouldPublish} would publish`}
        >
          <OrganizerPublicationImpactPreviewView
            preview={bridge.publicationDecisionImpactPreview}
          />
        </Panel>

        <Panel
          className="span-2"
          icon={<Database size={18} strokeWidth={1.9} />}
          title="Claim-target sync preview"
          action={`${bridge.claimTargetSyncPreview.summary.writesNeeded} writes`}
        >
          <OrganizerClaimTargetSyncPreviewView
            preview={bridge.claimTargetSyncPreview}
          />
        </Panel>

        <Panel
          className="span-2"
          icon={<FileWarning size={18} strokeWidth={1.9} />}
          title="Policy gap register"
          action={`${bridge.policyGaps.summary.reviewDecisions} reviewed`}
        >
          <OrganizerPolicyGapRegisterView
            inFlightDecisions={policyDecisionInFlight}
            localDecisions={localPolicyDecisions}
            notes={policyDecisionNotes}
            onDecision={(gap, decision) =>
              void handlePolicyGapDecision(gap, decision)}
            onNoteChange={(gapId, note) =>
              setPolicyDecisionNotes((current) => ({
                ...current,
                [gapId]: note,
              }))}
            register={bridge.policyGaps}
          />
        </Panel>

        <Panel
          className="span-2"
          icon={<FileWarning size={18} strokeWidth={1.9} />}
          title="Policy decision packets"
          action={`${bridge.policyDecisionPackets.summary.unansweredQuestions} inputs`}
        >
          <OrganizerPolicyDecisionPacketsView
            packets={bridge.policyDecisionPackets}
          />
        </Panel>

        <Panel
          className="span-2"
          icon={<Clock3 size={18} strokeWidth={1.9} />}
          title="Event crawl run plan"
          action={`${bridge.crawlRunPlan.summary.blocked} blocked`}
        >
          <OrganizerCrawlRunPlanView plan={bridge.crawlRunPlan} />
        </Panel>

        <Panel
          className="span-2"
          icon={<Database size={18} strokeWidth={1.9} />}
          title="Raw artifact storage"
          action={`${bridge.rawArtifactStorage.summary.remoteUploadBlocked} blocked`}
        >
          <OrganizerRawArtifactStorageView
            manifest={bridge.rawArtifactStorage}
          />
        </Panel>

        <Panel
          className="span-2"
          icon={<FolderSearch size={18} strokeWidth={1.9} />}
          title="Search surface candidates"
          action={`${bridge.searchCandidates.summary.candidates} surfaces`}
        >
          <OrganizerSearchCandidateQueueView
            curationInFlight={curationInFlight}
            localCuration={localCuration}
            onAttachCandidate={(candidate) => void handleAttachCandidate(candidate)}
            queue={bridge.searchCandidates}
          />
        </Panel>

        <Panel
          className="span-2"
          icon={<Activity size={18} strokeWidth={1.9} />}
          title="External event candidates"
          action={bridge.externalEventCandidates.policy.status}
        >
          <OrganizerExternalEventCandidateQueueView
            decisionInFlight={eventDecisionInFlight}
            localDecisions={localEventDecisions}
            notes={eventDecisionNotes}
            onDecision={(candidate, decision) =>
              void handleEventDecision(candidate, decision)}
            onNoteChange={(candidateId, note) =>
              setEventDecisionNotes((current) => ({
                ...current,
                [candidateId]: note,
              }))}
            queue={bridge.externalEventCandidates}
          />
        </Panel>

        <Panel
          className="span-2"
          icon={<FolderSearch size={18} strokeWidth={1.9} />}
          title="External event location resolution"
          action={`${bridge.externalEventLocationResolution.summary.tasks} tasks`}
        >
          <OrganizerExternalEventLocationResolutionView
            forms={locationResolutionForms}
            inFlight={locationResolutionInFlight}
            localResolutions={localLocationResolutions}
            onFormChange={(taskId, form) =>
              setLocationResolutionForms((current) => ({
                ...current,
                [taskId]: form,
              }))}
            onResolve={(task) => void handleLocationResolution(task)}
            queue={bridge.externalEventLocationResolution}
          />
        </Panel>

        <Panel
          className="span-2"
          icon={<Database size={18} strokeWidth={1.9} />}
          title="External event import plan"
          action={bridge.externalEventImportPlan.policy.status}
        >
          <OrganizerExternalEventImportPlanView
            plan={bridge.externalEventImportPlan}
          />
        </Panel>

        <Panel
          className="span-2"
          icon={<Settings2 size={18} strokeWidth={1.9} />}
          title="External event import preflight"
          action={bridge.externalEventImportExecutionPlan.policy.status}
        >
          <OrganizerExternalEventImportExecutionPlanView
            plan={bridge.externalEventImportExecutionPlan}
          />
        </Panel>

        <Panel
          icon={<Database size={18} strokeWidth={1.9} />}
          title="Bridge guardrails"
          action={`Schema v${bridge.schemaVersion}`}
        >
          <div className="guardrail-list">
            {bridge.guardrails.map((guardrail) => (
              <div className="quality-row warning" key={guardrail}>
                <FileWarning size={16} strokeWidth={1.9} />
                <div>
                  <strong>{guardrail}</strong>
                </div>
              </div>
            ))}
          </div>
          <div className="intake-source-list">
            {Object.entries(bridge.generatedFrom).map(([label, source]) => (
              <StateRow key={label} label={label} value={source} />
            ))}
          </div>
          <div className="intake-section curation-panel">
            <div className="intake-section-title">Dedupe curation</div>
            <div className="intake-state-grid">
              <StateRow label="Operations" value={String(bridge.curation.summary.operations)} />
              <StateRow label="Attached" value={String(bridge.curation.summary.attachedSurfaces ?? 0)} />
              <StateRow label="Merges" value={String(bridge.curation.summary.merges)} />
              <StateRow label="Surface decisions" value={String(bridge.curation.summary.surfaceDecisions)} />
              <StateRow label="Splits" value={String(bridge.curation.summary.splitSurfaces)} />
            </div>
            <div className="command-stack">
              {Object.entries(bridge.curation.commands).map(([label, command]) => (
                <div className="command-row" key={label}>
                  <span>{label}</span>
                  <code>{command}</code>
                </div>
              ))}
            </div>
          </div>
        </Panel>

        <Panel
          icon={<Activity size={18} strokeWidth={1.9} />}
          title="Event crawl readiness"
          action={bridge.crawlPlan.policy.status}
        >
          <div className="intake-state-grid">
            <StateRow label="Scheduler" value={bridge.crawlPlan.policy.schedulerEnabled ? "enabled" : "disabled"} />
            <StateRow label="Default policy" value={bridge.crawlPlan.policy.defaultSurfacePolicy} />
            <StateRow label="Capable" value={String(bridge.crawlPlan.summary.crawlCapableSurfaces)} />
            <StateRow label="Blocked" value={String(bridge.crawlPlan.summary.blockedSurfaces)} />
          </div>

          <div className="intake-tags">
            {Object.entries(bridge.crawlPlan.summary.platforms)
              .sort(([left], [right]) => left.localeCompare(right))
              .map(([platform, count]) => (
                <span className="intake-tag" key={platform}>
                  {platform} x{count}
                </span>
              ))}
          </div>

          <div className="guardrail-list">
            {bridge.crawlPlan.guardrails.map((guardrail) => (
              <div className="quality-row warning" key={guardrail}>
                <Clock3 size={16} strokeWidth={1.9} />
                <div>
                  <strong>{guardrail}</strong>
                </div>
              </div>
            ))}
          </div>

          <div className="intake-section">
            <div className="intake-section-title">Blockers</div>
            <div className="intake-tags">
              {Object.entries(bridge.crawlPlan.summary.blockers)
                .sort(([left], [right]) => left.localeCompare(right))
                .map(([blocker, count]) => (
                  <span className="intake-tag muted" key={blocker}>
                    {blocker} x{count}
                  </span>
                ))}
            </div>
          </div>
        </Panel>

        <Panel
          className="span-2"
          icon={<FolderSearch size={18} strokeWidth={1.9} />}
          title="Private entity queue"
          action={`${bridge.items.length} entities`}
        >
          <div className="intake-list">
            {bridge.items.length === 0 ? (
              <div className="empty-row">
                <CheckCircle2 size={16} strokeWidth={1.9} />
                <span>Clear</span>
              </div>
            ) : (
              bridge.items.map((item) => (
                <OrganizerIntakeCard
                  inFlightDecision={decisionInFlight[item.entityId]}
                  item={item}
                  curationForm={
                    curationForms[item.entityId] ?? defaultCurationForm(item)
                  }
                  curationInFlight={curationInFlight[
                    curationFormKey(
                      item,
                      curationForms[item.entityId] ?? defaultCurationForm(item)
                    )
                  ] === true}
                  curationResult={localCuration[
                    curationFormKey(
                      item,
                      curationForms[item.entityId] ?? defaultCurationForm(item)
                    )
                  ]}
                  entityOptions={bridge.items}
                  key={item.entityId}
                  localDecision={localDecisions[item.entityId]}
                  manualReportsAcknowledged={
                    manualReportAcknowledgements[item.entityId] === true
                  }
                  note={decisionNotes[item.entityId] ?? ""}
                  publicationPacket={publicationPacketByEntity.get(item.entityId)}
                  onManualReportsAcknowledgedChange={(checked) =>
                    setManualReportAcknowledgements((current) => ({
                      ...current,
                      [item.entityId]: checked,
                    }))}
                  onCurationFormChange={(form) =>
                    setCurationForms((current) => ({
                      ...current,
                      [item.entityId]: form,
                    }))}
                  onCurationSubmit={(form) =>
                    void handleItemCuration(item, form)}
                  onDecision={(decision) => void handleDecision(item, decision)}
                  onNoteChange={(note) => setDecisionNotes((current) => ({
                    ...current,
                    [item.entityId]: note,
                  }))}
                />
              ))
            )}
          </div>
        </Panel>
      </section>
    </>
  );
}

function OrganizerWorkflowReadinessView({
  readiness,
}: {
  readiness: OrganizerWorkflowReadiness;
}) {
  return (
    <div className="search-candidate-panel">
      <div className="intake-state-grid">
        <StateRow label="Ready" value={String(readiness.summary.ready)} />
        <StateRow label="Review" value={String(readiness.summary.reviewNeeded)} />
        <StateRow label="Waiting" value={String(readiness.summary.waiting)} />
        <StateRow label="Policy" value={String(readiness.summary.policyNeeded)} />
      </div>

      <div className="intake-tags">
        <span className={`intake-tag ${readiness.summary.localPromotionPipelineReady ? "" : "muted"}`}>
          local pipeline {readiness.summary.localPromotionPipelineReady ? "ready" : "blocked"}
        </span>
        <span className={`intake-tag ${readiness.summary.publicProjectionReady ? "" : "muted"}`}>
          public projection {readiness.summary.publicProjectionReady ? "ready" : "waiting"}
        </span>
        <span className={`intake-tag ${readiness.summary.claimSyncReady ? "" : "muted"}`}>
          claim sync {readiness.summary.claimSyncReady ? "ready" : "waiting"}
        </span>
        <span className={`intake-tag ${readiness.summary.recurringCrawlEnabled ? "" : "muted"}`}>
          crawl {readiness.summary.recurringCrawlEnabled ? "enabled" : "disabled"}
        </span>
      </div>

      <div className="intake-gate-list">
        {readiness.gates.map((gate) => (
          <div
            className={`intake-gate ${readinessGateTone(gate.status)}`}
            key={gate.id}
          >
            {gate.status === "ready" ? (
              <CheckCircle2 size={15} strokeWidth={1.9} />
            ) : gate.status === "policy_needed" ? (
              <Clock3 size={15} strokeWidth={1.9} />
            ) : (
              <FileWarning size={15} strokeWidth={1.9} />
            )}
            <div>
              <strong>{gate.label}</strong>
              <span>{gate.detail}</span>
              <span>{gate.nextAction}</span>
            </div>
          </div>
        ))}
      </div>

      <div className="intake-section">
        <div className="intake-section-title">Commands</div>
        <div className="command-stack">
          {Object.entries(readiness.commands).map(([label, command]) => (
            <div className="command-row" key={label}>
              <span>{label}</span>
              <code>{command}</code>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

function OrganizerOperatorActionQueueView({
  queue,
}: {
  queue: OrganizerOperatorActionQueue;
}) {
  const visibleActions = queue.actions.slice(0, 8);

  return (
    <div className="search-candidate-panel">
      <div className="intake-state-grid">
        <StateRow label="Actions" value={String(queue.summary.actions)} />
        <StateRow label="Admin" value={String(queue.summary.adminDecisionsRequired)} />
        <StateRow label="Policy" value={String(queue.summary.policyInputsRequired)} />
        <StateRow label="Waiting" value={String(queue.summary.waitingActions)} />
      </div>

      <div className="intake-tags">
        {Object.entries(queue.summary.actionsByPriority).map(([priority, count]) => (
          <span className="intake-tag muted" key={priority}>
            {priority} x{count}
          </span>
        ))}
        {Object.entries(queue.summary.actionsByType).map(([type, count]) => (
          <span className="intake-tag muted" key={type}>
            {type.replaceAll("_", " ")} x{count}
          </span>
        ))}
      </div>

      <div className="quality-row warning">
        <Lock size={16} strokeWidth={1.9} />
        <div>
          <strong>{queue.guardrails[0]}</strong>
          <span>{queue.guardrails[1]}</span>
        </div>
      </div>

      <div className="search-candidate-list">
        {visibleActions.map((action) => (
          <article className="search-candidate-card" key={action.actionId}>
            <header className="search-candidate-header">
              <div>
                <div className="intake-eyebrow">
                  {action.actionType.replaceAll("_", " ")} / {action.priority}
                </div>
                <h3>{action.subjectName}</h3>
              </div>
              <span className={`intake-badge ${action.status === "requires_admin_decision" ? "ready" : ""}`}>
                {action.status.replaceAll("_", " ")}
              </span>
            </header>

            <div className="intake-state-grid">
              <StateRow label="Subject" value={action.subjectId} />
              <StateRow label="Task" value={action.taskType.replaceAll("_", " ")} />
              <StateRow label="Options" value={String(action.decisionOptions.length)} />
              <StateRow label="Blockers" value={String(action.blockers.length)} />
            </div>

            <div className="quality-row">
              <FileWarning size={16} strokeWidth={1.9} />
              <div>
                <strong>{action.nextAction}</strong>
                <span>{action.detail}</span>
              </div>
            </div>

            <div className="intake-tags">
              {action.decisionOptions.map((option) => (
                <span className="intake-tag" key={option}>
                  {option.replaceAll("_", " ")}
                </span>
              ))}
              {action.requiredAcknowledgements?.manualReportsReviewed ? (
                <span className="intake-tag muted">manual reports</span>
              ) : null}
              {(action.requiredInputs ?? []).slice(0, 6).map((input) => (
                <span className="intake-tag muted" key={input}>
                  {input.replaceAll("_", " ")}
                </span>
              ))}
              {action.impact?.wouldIndex ? (
                <span className="intake-tag">indexable</span>
              ) : null}
              {action.impact?.wouldCreateClaimTarget ? (
                <span className="intake-tag">claim target</span>
              ) : null}
            </div>

            <div className="command-stack">
              {action.commands.slice(0, 3).map((command, index) => (
                <div className="command-row" key={`${action.actionId}:${index}`}>
                  <span>{index === 0 ? "command" : "then"}</span>
                  <code>{command}</code>
                </div>
              ))}
            </div>
          </article>
        ))}
      </div>
    </div>
  );
}

function OrganizerOperationalHealthView({
  health,
}: {
  health: OrganizerOperationalHealthReport;
}) {
  const visibleWorkstreams = health.workstreams.slice(0, 6);

  return (
    <div className="search-candidate-panel">
      <div className="intake-state-grid">
        <StateRow label="Status" value={health.summary.healthStatus.replaceAll("_", " ")} />
        <StateRow label="Workstreams" value={String(health.summary.workstreams)} />
        <StateRow label="Action" value={String(health.summary.actionRequiredWorkstreams)} />
        <StateRow label="Policy" value={String(health.summary.policyBlockedWorkstreams)} />
        <StateRow label="Waiting" value={String(health.summary.waitingWorkstreams)} />
        <StateRow label="Ready" value={String(health.summary.readyWorkstreams)} />
      </div>

      <div className="intake-tags">
        {Object.entries(health.summary.workstreamsByPriority).map(([priority, count]) => (
          <span className="intake-tag muted" key={priority}>
            {priority} x{count}
          </span>
        ))}
        {Object.entries(health.summary.workstreamsByStatus).map(([status, count]) => (
          <span className="intake-tag muted" key={status}>
            {status.replaceAll("_", " ")} x{count}
          </span>
        ))}
      </div>

      <div className="quality-row warning">
        <Lock size={16} strokeWidth={1.9} />
        <div>
          <strong>{health.guardrails[0]}</strong>
          <span>{health.guardrails[1]}</span>
        </div>
      </div>

      <div className="search-candidate-list">
        {visibleWorkstreams.map((stream) => (
          <article className="search-candidate-card" key={stream.id}>
            <header className="search-candidate-header">
              <div>
                <div className="intake-eyebrow">
                  {stream.priority} / {stream.id.replaceAll("_", " ")}
                </div>
                <h3>{stream.label}</h3>
              </div>
              <span className={`intake-badge ${healthStatusTone(stream.status)}`}>
                {stream.status.replaceAll("_", " ")}
              </span>
            </header>

            <div className="intake-state-grid">
              {Object.entries(stream.metrics).slice(0, 6).map(([metric, value]) => (
                <StateRow
                  key={metric}
                  label={metric.replaceAll("_", " ")}
                  value={formatHealthMetric(value)}
                />
              ))}
            </div>

            {stream.nextActions.length > 0 ? (
              <div className="quality-row">
                <FileWarning size={16} strokeWidth={1.9} />
                <div>
                  <strong>{stream.nextActions[0]}</strong>
                  {stream.nextActions.slice(1, 3).map((action) => (
                    <span key={action}>{action}</span>
                  ))}
                </div>
              </div>
            ) : null}

            <div className="intake-tags">
              {stream.blockers.slice(0, 6).map((blocker) => (
                <span className="intake-tag muted" key={blocker}>
                  {blocker.replaceAll("_", " ")}
                </span>
              ))}
            </div>

            <div className="command-stack">
              {stream.commands.slice(0, 2).map((command, index) => (
                <div className="command-row" key={`${stream.id}:${index}`}>
                  <span>{index === 0 ? "command" : "then"}</span>
                  <code>{command}</code>
                </div>
              ))}
            </div>
          </article>
        ))}
      </div>
    </div>
  );
}

function OrganizerPendingWorkCoverageView({
  coverage,
}: {
  coverage: OrganizerPendingWorkCoverage;
}) {
  const visibleEntries = coverage.entries.slice(0, 8);

  return (
    <div className="search-candidate-panel">
      <div className="intake-state-grid">
        <StateRow
          label="Status"
          value={coverage.summary.status.replaceAll("_", " ")}
        />
        <StateRow
          label="Unresolved"
          value={String(coverage.summary.unresolvedWorkstreams)}
        />
        <StateRow
          label="Covered"
          value={String(coverage.summary.coveredWorkstreams)}
        />
        <StateRow
          label="Input-covered"
          value={String(coverage.summary.coveredByInputRequest)}
        />
        <StateRow
          label="Follow-up"
          value={String(coverage.summary.coveredByFollowUp)}
        />
        <StateRow
          label="Untriaged"
          value={String(coverage.summary.untriagedWorkstreams)}
        />
      </div>

      <div className="intake-tags">
        {coverage.summary.highestPriority ? (
          <span className="intake-tag">
            highest {coverage.summary.highestPriority}
          </span>
        ) : null}
        {Object.entries(coverage.summary.coverageByStatus).map(([status, count]) => (
          <span className="intake-tag muted" key={status}>
            {status.replaceAll("_", " ")} x{count}
          </span>
        ))}
        {Object.entries(coverage.summary.workstreamsByPriority).map(([priority, count]) => (
          <span className="intake-tag muted" key={priority}>
            {priority} x{count}
          </span>
        ))}
      </div>

      <div className="quality-row warning">
        <Lock size={16} strokeWidth={1.9} />
        <div>
          <strong>{coverage.guardrails[0]}</strong>
          <span>{coverage.guardrails[1]}</span>
        </div>
      </div>

      <div className="search-candidate-list">
        {visibleEntries.map((entry) => (
          <article className="search-candidate-card" key={entry.coverageId}>
            <header className="search-candidate-header">
              <div>
                <div className="intake-eyebrow">
                  {entry.priority} / {entry.workstreamId.replaceAll("_", " ")}
                </div>
                <h3>{entry.label}</h3>
              </div>
              <span className={`intake-badge ${coverageStatusTone(entry.coverageStatus)}`}>
                {entry.coverageStatus.replaceAll("_", " ")}
              </span>
            </header>

            <div className="intake-state-grid">
              <StateRow label="Status" value={entry.status.replaceAll("_", " ")} />
              <StateRow
                label="Blocker"
                value={entry.blockerClass.replaceAll("_", " ")}
              />
              <StateRow
                label="Requests"
                value={String(entry.pendingRequestIds.length)}
              />
              <StateRow
                label="Follow-ups"
                value={String(entry.followUpIds.length)}
              />
            </div>

            {entry.nextActions.length > 0 ? (
              <div className="quality-row">
                <FileWarning size={16} strokeWidth={1.9} />
                <div>
                  <strong>{entry.nextActions[0]}</strong>
                  {entry.nextActions.slice(1, 3).map((action) => (
                    <span key={action}>{action}</span>
                  ))}
                </div>
              </div>
            ) : null}

            <div className="intake-tags">
              {entry.pendingRequestIds.slice(0, 6).map((requestId) => (
                <span className="intake-tag" key={requestId}>
                  {requestId.replaceAll("_", " ")}
                </span>
              ))}
              {entry.followUpIds.slice(0, 6).map((followUpId) => (
                <span className="intake-tag muted" key={followUpId}>
                  {followUpId.replaceAll("_", " ")}
                </span>
              ))}
              {entry.blockers.slice(0, 6).map((blocker) => (
                <span className="intake-tag muted" key={blocker}>
                  {blocker}
                </span>
              ))}
            </div>

            <div className="command-stack">
              {entry.commands.slice(0, 3).map((command, index) => (
                <div className="command-row" key={`${entry.coverageId}:${index}`}>
                  <span>{index === 0 ? "command" : "then"}</span>
                  <code>{command}</code>
                </div>
              ))}
            </div>
          </article>
        ))}
      </div>
    </div>
  );
}

function OrganizerPendingInputRequestView({
  onPendingDecision,
  policyDecisions,
  policyInFlight,
  publicationDecisions,
  publicationInFlight,
  request,
}: {
  onPendingDecision: (
    input: OrganizerPendingInputItem,
    decision: string
  ) => void;
  policyDecisions: Record<string, AdminDecideOrganizerPolicyGapResponse>;
  policyInFlight: Record<string, OrganizerPolicyGapDecision>;
  publicationDecisions: Record<string, AdminDecideOrganizerIntakeResponse>;
  publicationInFlight: Record<string, OrganizerIntakeDecision>;
  request: OrganizerPendingInputRequest;
}) {
  const visibleRequests = request.requests.slice(0, 8);
  const visibleFollowUps = request.followUps.slice(0, 6);

  return (
    <div className="search-candidate-panel">
      <div className="intake-state-grid">
        <StateRow label="Inputs" value={String(request.summary.requests)} />
        <StateRow label="Admin" value={String(request.summary.adminPublicationRequests)} />
        <StateRow label="Policy" value={String(request.summary.policyDecisionRequests)} />
        <StateRow label="Questions" value={String(request.summary.requiredPolicyQuestions)} />
        <StateRow label="Manual acks" value={String(request.summary.manualPublicationAcknowledgements)} />
        <StateRow label="Follow-ups" value={String(request.summary.workflowFollowUps)} />
      </div>

      <div className="intake-tags">
        {request.summary.highestPriority ? (
          <span className="intake-tag">
            highest {request.summary.highestPriority}
          </span>
        ) : null}
        {Object.entries(request.summary.requestsByOwner).map(([owner, count]) => (
          <span className="intake-tag muted" key={owner}>
            {owner.replaceAll("_", " ")} x{count}
          </span>
        ))}
        {Object.entries(request.summary.requestsByType).map(([type, count]) => (
          <span className="intake-tag muted" key={type}>
            {type.replaceAll("_", " ")} x{count}
          </span>
        ))}
      </div>

      <div className="quality-row warning">
        <Lock size={16} strokeWidth={1.9} />
        <div>
          <strong>{request.guardrails[0]}</strong>
          <span>{request.guardrails[1]}</span>
        </div>
      </div>

      <div className="search-candidate-list">
        {visibleRequests.map((input) => {
          const submittedDecision =
            pendingInputSubmittedDecision({
              input,
              policyDecisions,
              publicationDecisions,
            });
          const inFlightDecision =
            pendingInputInFlightDecision({
              input,
              policyInFlight,
              publicationInFlight,
            });
          const isDeciding = Boolean(inFlightDecision);

          return (
          <article className="search-candidate-card" key={input.requestId}>
            <header className="search-candidate-header">
              <div>
                <div className="intake-eyebrow">
                  {input.requestType.replaceAll("_", " ")} / {input.priority}
                </div>
                <h3>{input.subjectName}</h3>
              </div>
              <span className={`intake-badge ${input.priority === "p0" ? "ready" : ""}`}>
                {input.owner.replaceAll("_", " ")}
              </span>
            </header>

            <div className="quality-row">
              <FileWarning size={16} strokeWidth={1.9} />
              <div>
                <strong>{input.prompt}</strong>
                <span>Safe default: {input.safeDefaultAction.replaceAll("_", " ")}</span>
              </div>
            </div>

            <div className="intake-state-grid">
              <StateRow label="Subject" value={input.subjectId} />
              <StateRow label="Options" value={input.decisionOptions.join(", ")} />
              <StateRow
                label="Required inputs"
                value={String(input.requiredInputs?.length ?? 0)}
              />
              <StateRow
                label="Manual ack"
                value={input.requiredAcknowledgements?.manualReportsReviewed ? "required" : "not required"}
              />
              <StateRow
                label="Would publish"
                value={input.impact?.wouldPublish ? "yes" : "no"}
              />
              <StateRow
                label="Claim target"
                value={input.impact?.claimTargetPath ?? "none"}
              />
            </div>

            <div className="intake-tags">
              {input.decisionOptions.map((option) => (
                <span className="intake-tag" key={option}>
                  {option.replaceAll("_", " ")}
                </span>
              ))}
              {input.requiredAcknowledgements?.manualReportsReviewed ? (
                <span className="intake-tag muted">manual reports reviewed</span>
              ) : null}
              {(input.requiredAcknowledgements?.publicationChecklist ?? [])
                .slice(0, 8)
                .map((acknowledgement) => (
                  <span className="intake-tag muted" key={acknowledgement}>
                    {acknowledgement.replaceAll("_", " ")}
                  </span>
                ))}
              {(input.currentState?.riskFlags as string[] | undefined)
                ?.slice(0, 8)
                .map((flag) => (
                  <span className="intake-tag muted" key={flag}>
                    {flag.replaceAll("_", " ")}
                  </span>
                ))}
            </div>

            {input.requiredInputs && input.requiredInputs.length > 0 ? (
              <div className="intake-section">
                <div className="intake-section-title">Required Policy Inputs</div>
                <div className="command-stack">
                  {input.requiredInputs.slice(0, 6).map((requiredInput) => (
                    <div
                      className="command-row"
                      key={requiredInput.questionId ?? requiredInput.prompt}
                    >
                      <span>{requiredInput.input ?? "input"}</span>
                      <code>
                        {requiredInput.prompt} Default: {requiredInput.recommendedSafeDefault}
                      </code>
                    </div>
                  ))}
                </div>
              </div>
            ) : null}

            {input.callableSubmission ? (
              <div className="intake-section">
                <div className="intake-section-title">Callable Payloads</div>
                <div className="intake-state-grid">
                  <StateRow
                    label="Callable"
                    value={input.callableSubmission.callableName}
                  />
                  <StateRow
                    label="Wrapper"
                    value={input.callableSubmission.adminApiWrapper}
                  />
                  <StateRow
                    label="Payload"
                    value={input.callableSubmission.payloadType}
                  />
                  <StateRow
                    label="Collection"
                    value={input.callableSubmission.firestoreCollection}
                  />
                </div>
                <div className="command-stack">
                  {Object.entries(input.callableSubmission.payloadsByDecision)
                    .slice(0, 4)
                    .map(([decision, payload]) => (
                      <div
                        className="command-row"
                        key={`${input.requestId}:payload:${decision}`}
                      >
                        <span>{decision.replaceAll("_", " ")}</span>
                        <code>{JSON.stringify(payload)}</code>
                      </div>
                    ))}
                </div>
                {submittedDecision ? (
                  <div className="quality-row success">
                    <CheckCircle2 size={16} strokeWidth={1.9} />
                    <div>
                      <strong>
                        {pendingInputDecisionLabel(submittedDecision.decision)}
                      </strong>
                      <span>
                        {submittedDecision.decisionPath} / {pendingInputDecisionState(submittedDecision)}
                      </span>
                    </div>
                  </div>
                ) : (
                  <div className="intake-decision-actions">
                    {input.decisionOptions.map((decision) => {
                      const payloadAvailable = Boolean(
                        input.callableSubmission?.payloadsByDecision[decision]
                      );
                      return (
                        <button
                          disabled={isDeciding || !payloadAvailable}
                          key={`${input.requestId}:decision:${decision}`}
                          onClick={() => onPendingDecision(input, decision)}
                          type="button"
                        >
                          {inFlightDecision === decision ?
                            pendingInputDecisionProgressLabel(decision) :
                            pendingInputDecisionLabel(decision)}
                        </button>
                      );
                    })}
                  </div>
                )}
              </div>
            ) : null}

            <div className="command-stack">
              {input.commands.slice(0, 4).map((command, index) => (
                <div className="command-row" key={`${input.requestId}:${index}`}>
                  <span>{index === 0 ? "command" : "then"}</span>
                  <code>{command}</code>
                </div>
              ))}
            </div>
          </article>
          );
        })}
      </div>

      <div className="intake-section">
        <div className="intake-section-title">Workflow Follow-ups</div>
        <div className="search-candidate-list">
          {visibleFollowUps.length === 0 ? (
            <div className="empty-row">
              <CheckCircle2 size={16} strokeWidth={1.9} />
              <span>No follow-ups are pending.</span>
            </div>
          ) : (
            visibleFollowUps.map((followUp) => (
              <article className="search-candidate-card" key={followUp.followUpId}>
                <header className="search-candidate-header">
                  <div>
                    <div className="intake-eyebrow">
                      {followUp.priority} / {followUp.workstreamId.replaceAll("_", " ")}
                    </div>
                    <h3>{followUp.label}</h3>
                  </div>
                  <span className={`intake-badge ${healthStatusTone(followUp.status)}`}>
                    {followUp.status.replaceAll("_", " ")}
                  </span>
                </header>
                <div className="quality-row">
                  <FileWarning size={16} strokeWidth={1.9} />
                  <div>
                    <strong>{followUp.nextActions[0] ?? "Review workflow state."}</strong>
                    {followUp.nextActions.slice(1, 3).map((action) => (
                      <span key={action}>{action}</span>
                    ))}
                  </div>
                </div>
                <div className="intake-tags">
                  {followUp.blockers.slice(0, 8).map((blocker) => (
                    <span className="intake-tag muted" key={blocker}>
                      {blocker.replaceAll("_", " ")}
                    </span>
                  ))}
                </div>
                <div className="command-stack">
                  {followUp.commands.slice(0, 2).map((command, index) => (
                    <div className="command-row" key={`${followUp.followUpId}:${index}`}>
                      <span>{index === 0 ? "command" : "then"}</span>
                      <code>{command}</code>
                    </div>
                  ))}
                </div>
              </article>
            ))
          )}
        </div>
      </div>
    </div>
  );
}

function OrganizerReviewedDecisionAnswerPacketsView({
  register,
}: {
  register: OrganizerReviewedDecisionAnswerPacketRegister;
}) {
  const visibleEntries = register.entries.slice(0, 8);

  return (
    <div className="search-candidate-panel">
      <div className="intake-state-grid">
        <StateRow
          label="Status"
          value={register.summary.status.replaceAll("_", " ")}
        />
        <StateRow label="Packets" value={String(register.summary.packets)} />
        <StateRow label="Ready" value={String(register.summary.readyToApply)} />
        <StateRow
          label="Awaiting"
          value={String(register.summary.awaitingAnswers)}
        />
        <StateRow label="Stale" value={String(register.summary.stale)} />
        <StateRow label="Invalid" value={String(register.summary.invalid)} />
      </div>

      <div className="intake-tags">
        <span className="intake-tag muted">
          root {register.generatedFrom.answerPacketsRoot}
        </span>
        <span className="intake-tag muted">
          source {register.generatedFrom.generatedAnswerPacket}
        </span>
        <span className="intake-tag">
          fresh x{register.summary.sourceFresh}
        </span>
      </div>

      <div className="quality-row warning">
        <Lock size={16} strokeWidth={1.9} />
        <div>
          <strong>{register.guardrails[0]}</strong>
          <span>{register.guardrails[1]}</span>
        </div>
      </div>

      <div className="search-candidate-list">
        {visibleEntries.length === 0 ? (
          <div className="empty-row">
            <Clock3 size={16} strokeWidth={1.9} />
            <span>No reviewed answer packets exist yet.</span>
          </div>
        ) : (
          visibleEntries.map((entry) => (
            <article className="search-candidate-card" key={entry.path}>
              <header className="search-candidate-header">
                <div>
                  <div className="intake-eyebrow">
                    {entry.sourceFreshness.replaceAll("_", " ")}
                  </div>
                  <h3>{entry.path}</h3>
                </div>
                <span
                  className={`intake-badge ${entry.readyToApply ? "ready" : ""}`}
                >
                  {entry.status.replaceAll("_", " ")}
                </span>
              </header>

              <div className="intake-state-grid">
                <StateRow label="Reviewer" value={entry.reviewer ?? "unknown"} />
                <StateRow label="Date" value={entry.decidedAt ?? "unknown"} />
                <StateRow label="Slots" value={String(entry.answerSlots)} />
                <StateRow
                  label="Planned actions"
                  value={String(entry.plannedActions)}
                />
                <StateRow
                  label="Pending answers"
                  value={String(entry.pendingAnswers)}
                />
                <StateRow
                  label="Source"
                  value={entry.sourceFresh ? "fresh" : entry.sourceFreshness}
                />
              </div>

              {(entry.errors.length > 0 || entry.warnings.length > 0) ? (
                <div className="quality-row warning">
                  <FileWarning size={16} strokeWidth={1.9} />
                  <div>
                    <strong>
                      {entry.errors[0] ?? entry.warnings[0]}
                    </strong>
                    {[...entry.errors.slice(1, 3), ...entry.warnings.slice(1, 3)]
                      .slice(0, 3)
                      .map((message) => (
                        <span key={message}>{message}</span>
                      ))}
                  </div>
                </div>
              ) : null}

              <div className="intake-tags">
                {entry.readyToApply ? (
                  <span className="intake-tag">ready to apply</span>
                ) : null}
                {entry.awaitingAnswers ? (
                  <span className="intake-tag muted">awaiting answers</span>
                ) : null}
                {entry.stale ? (
                  <span className="intake-tag muted">stale source</span>
                ) : null}
                {entry.invalid ? (
                  <span className="intake-tag muted">invalid packet</span>
                ) : null}
              </div>
            </article>
          ))
        )}
      </div>
    </div>
  );
}

function OrganizerPromotionExecutionView({
  packet,
}: {
  packet: OrganizerPromotionExecutionPacket;
}) {
  const visiblePhases = packet.phases.slice(0, 8);

  return (
    <div className="search-candidate-panel">
      <div className="intake-state-grid">
        <StateRow
          label="Status"
          value={packet.summary.status.replaceAll("_", " ")}
        />
        <StateRow label="Phases" value={String(packet.summary.phases)} />
        <StateRow
          label="Blocked"
          value={String(packet.summary.blockedPhases)}
        />
        <StateRow
          label="Local preview"
          value={packet.summary.canRunLocalPreview ? "ready" : "blocked"}
        />
        <StateRow
          label="Public deploy"
          value={packet.summary.canDeployNewPublicPages ? "ready" : "blocked"}
        />
        <StateRow
          label="Claim writes"
          value={packet.summary.canWriteClaimTargets ? "ready" : "blocked"}
        />
        <StateRow
          label="Answer packets"
          value={packet.summary.reviewedAnswerPacketStatus.replaceAll("_", " ")}
        />
      </div>

      <div className="intake-tags">
        <span className="intake-tag">
          admin pending x{packet.summary.pendingAdminDecisions}
        </span>
        <span className="intake-tag muted">
          policy pending x{packet.summary.pendingPolicyDecisions}
        </span>
        <span className="intake-tag muted">
          answer slots x{packet.summary.pendingAnswerSlots}
        </span>
        <span className={packet.summary.reviewedAnswerPacketsReady > 0 ? "intake-tag" : "intake-tag muted"}>
          ready packets x{packet.summary.reviewedAnswerPacketsReady}
        </span>
        <span className="intake-tag muted">
          reviewed packets x{packet.summary.reviewedAnswerPackets}
        </span>
        {packet.summary.reviewedAnswerPacketsStale > 0 ? (
          <span className="intake-tag muted">
            stale packets x{packet.summary.reviewedAnswerPacketsStale}
          </span>
        ) : null}
        {packet.summary.reviewedAnswerPacketsInvalid > 0 ? (
          <span className="intake-tag muted">
            invalid packets x{packet.summary.reviewedAnswerPacketsInvalid}
          </span>
        ) : null}
        <span className="intake-tag muted">
          guarded reads x{packet.summary.guardedRemoteReadPhases}
        </span>
        <span className="intake-tag muted">
          guarded writes x{packet.summary.guardedRemoteWritePhases}
        </span>
        {Object.entries(packet.summary.phasesByStatus).map(([status, count]) => (
          <span className="intake-tag muted" key={status}>
            {status.replaceAll("_", " ")} x{count}
          </span>
        ))}
      </div>

      <div className="quality-row warning">
        <Lock size={16} strokeWidth={1.9} />
        <div>
          <strong>{packet.guardrails[0]}</strong>
          <span>{packet.guardrails[1]}</span>
        </div>
      </div>

      <div className="search-candidate-list">
        {visiblePhases.map((phase) => (
          <article className="search-candidate-card" key={phase.phaseId}>
            <header className="search-candidate-header">
              <div>
                <div className="intake-eyebrow">
                  {phase.executionMode.replaceAll("_", " ")}
                </div>
                <h3>{phase.label}</h3>
              </div>
              <span className={`intake-badge ${promotionPhaseTone(phase.status)}`}>
                {phase.status.replaceAll("_", " ")}
              </span>
            </header>

            <div className="intake-state-grid">
              <StateRow label="Mode" value={phase.executionMode.replaceAll("_", " ")} />
              <StateRow label="Blockers" value={String(phase.blockers.length)} />
              <StateRow label="Outputs" value={String(phase.outputs.length)} />
              <StateRow label="Phase" value={phase.phaseId.replaceAll("_", " ")} />
            </div>

            {phase.blockers.length > 0 ? (
              <div className="quality-row warning">
                <FileWarning size={16} strokeWidth={1.9} />
                <div>
                  <strong>{phase.blockers[0]}</strong>
                  {phase.blockers.slice(1, 4).map((blocker) => (
                    <span key={blocker}>{blocker}</span>
                  ))}
                </div>
              </div>
            ) : (
              <div className="quality-row success">
                <CheckCircle2 size={16} strokeWidth={1.9} />
                <div>
                  <strong>Phase ready</strong>
                  <span>Run only in the documented order.</span>
                </div>
              </div>
            )}

            <div className="intake-tags">
              {phase.outputs.slice(0, 8).map((output) => (
                <span className="intake-tag muted" key={output}>
                  {output}
                </span>
              ))}
            </div>

            <div className="command-stack">
              <div className="command-row">
                <span>command</span>
                <code>{phase.command}</code>
              </div>
            </div>
          </article>
        ))}
      </div>
    </div>
  );
}

type OrganizerPendingInputSubmittedDecision =
  | AdminDecideOrganizerIntakeResponse
  | AdminDecideOrganizerPolicyGapResponse;

function pendingInputSubmittedDecision({
  input,
  policyDecisions,
  publicationDecisions,
}: {
  input: OrganizerPendingInputItem;
  policyDecisions: Record<string, AdminDecideOrganizerPolicyGapResponse>;
  publicationDecisions: Record<string, AdminDecideOrganizerIntakeResponse>;
}): OrganizerPendingInputSubmittedDecision | null {
  if (input.requestType === "admin_publication_decision") {
    return publicationDecisions[input.subjectId] ?? null;
  }
  if (input.requestType === "policy_decision") {
    return policyDecisions[input.subjectId] ?? null;
  }
  return null;
}

function pendingInputInFlightDecision({
  input,
  policyInFlight,
  publicationInFlight,
}: {
  input: OrganizerPendingInputItem;
  policyInFlight: Record<string, OrganizerPolicyGapDecision>;
  publicationInFlight: Record<string, OrganizerIntakeDecision>;
}): string | undefined {
  if (input.requestType === "admin_publication_decision") {
    return publicationInFlight[input.subjectId];
  }
  if (input.requestType === "policy_decision") {
    return policyInFlight[input.subjectId];
  }
  return undefined;
}

function pendingInputDecisionState(
  decision: OrganizerPendingInputSubmittedDecision
) {
  return "projectionState" in decision ?
    decision.projectionState :
    decision.operationalState;
}

function pendingInputDecisionLabel(decision: string) {
  if (decision === "approve_public") return "Approve public";
  if (decision === "accept") return "Accept";
  return decision.charAt(0).toUpperCase() +
    decision.slice(1).replaceAll("_", " ");
}

function pendingInputDecisionProgressLabel(decision: string) {
  if (decision === "approve_public") return "Approving";
  if (decision === "accept") return "Accepting";
  if (decision === "hold") return "Holding";
  if (decision === "suppress") return "Suppressing";
  if (decision === "reject") return "Rejecting";
  return "Recording";
}

function organizerIntakeDecisionFromString(
  decision: string
): OrganizerIntakeDecision | null {
  if (
    decision === "approve_public" ||
    decision === "hold" ||
    decision === "suppress"
  ) {
    return decision;
  }
  return null;
}

function organizerPolicyGapDecisionFromString(
  decision: string
): OrganizerPolicyGapDecision | null {
  if (decision === "accept" || decision === "hold" || decision === "reject") {
    return decision;
  }
  return null;
}

function OrganizerPolicyGapRegisterView({
  inFlightDecisions,
  localDecisions,
  notes,
  onDecision,
  onNoteChange,
  register,
}: {
  inFlightDecisions: Record<string, OrganizerPolicyGapDecision>;
  localDecisions: Record<string, AdminDecideOrganizerPolicyGapResponse>;
  notes: Record<string, string>;
  onDecision: (
    gap: OrganizerPolicyGap,
    decision: OrganizerPolicyGapDecision
  ) => void;
  onNoteChange: (gapId: string, note: string) => void;
  register: OrganizerPolicyGapRegister;
}) {
  const visibleGaps = register.gaps.slice(0, 8);

  return (
    <div className="search-candidate-panel">
      <div className="intake-state-grid">
        <StateRow label="Gaps" value={String(register.summary.gaps)} />
        <StateRow label="Operational blockers" value={String(register.summary.decisionRequired)} />
        <StateRow label="Reviewed" value={String(register.summary.reviewDecisions)} />
        <StateRow label="Accepted" value={String(register.summary.reviewAccepted)} />
        <StateRow label="Held" value={String(register.summary.reviewHeld)} />
        <StateRow label="Rejected" value={String(register.summary.reviewRejected)} />
        <StateRow label="Invalid" value={String(register.summary.reviewInvalid)} />
        <StateRow label="Ready" value={String(register.summary.ready)} />
        <StateRow label="Disabled" value={String(register.summary.blockedByPolicy)} />
      </div>

      <div className="intake-tags">
        {Object.entries(register.summary.gapsByArea).map(([area, count]) => (
          <span className="intake-tag muted" key={area}>
            {area} x{count}
          </span>
        ))}
        {Object.entries(register.summary.gapsByDecisionStatus).map(([status, count]) => (
          <span className="intake-tag muted" key={status}>
            {status.replaceAll("_", " ")} x{count}
          </span>
        ))}
        {register.guardrails.map((guardrail) => (
          <span className="intake-tag muted" key={guardrail}>
            {guardrail}
          </span>
        ))}
      </div>

      {register.errors && register.errors.length > 0 ? (
        <div className="guardrail-list">
          {register.errors.map((error) => (
            <div className="quality-row warning" key={error}>
              <FileWarning size={16} strokeWidth={1.9} />
              <div>
                <strong>{error}</strong>
              </div>
            </div>
          ))}
        </div>
      ) : null}

      <div className="search-candidate-list">
        {visibleGaps.map((gap) => {
          const localDecision = localDecisions[gap.gapId];
          const submittedDecision = localDecision?.decision ??
            gap.reviewDecision?.decision;
          const isDeciding = Boolean(inFlightDecisions[gap.gapId]);

          return (
            <article className="search-candidate-card" key={gap.gapId}>
              <header className="search-candidate-header">
                <div>
                  <div className="intake-eyebrow">
                    {gap.area} / {gap.decisionOwner}
                  </div>
                  <h3>{gap.gapId.replaceAll("_", " ")}</h3>
                </div>
                <span className={`intake-badge ${gap.status === "ready" ? "ready" : ""}`}>
                  {gap.severity}
                </span>
              </header>

              <div className="intake-state-grid">
                <StateRow label="Status" value={gap.status.replaceAll("_", " ")} />
                <StateRow label="Decision" value={gap.decisionStatus.replaceAll("_", " ")} />
                <StateRow label="Default" value={gap.defaultPosition.replaceAll("_", " ")} />
                <StateRow label="State" value={gap.currentState} />
                <StateRow label="Next" value={gap.nextAction} />
              </div>

              {submittedDecision ? (
                <div className="intake-decision-state">
                  <CheckCircle2 size={16} strokeWidth={1.9} />
                  <div>
                    <strong>{policyGapDecisionLabel(submittedDecision)}</strong>
                    <span>
                      {localDecision ?
                        `${localDecision.decisionPath} / ${localDecision.operationalState}` :
                        `Decision present in ${gap.reviewDecision?.policyGapDecisionBatchId}`}
                    </span>
                  </div>
                </div>
              ) : (
                <div className="intake-decision-box">
                  <TextareaField
                    label="Policy review note"
                    onChange={(note) => onNoteChange(gap.gapId, note)}
                    rows={3}
                    value={notes[gap.gapId] ?? ""}
                  />
                  <div className="intake-decision-actions">
                    <button
                      disabled={isDeciding}
                      onClick={() => onDecision(gap, "accept")}
                      type="button"
                    >
                      {inFlightDecisions[gap.gapId] === "accept" ?
                        "Accepting" :
                        "Accept"}
                    </button>
                    <button
                      disabled={isDeciding}
                      onClick={() => onDecision(gap, "hold")}
                      type="button"
                    >
                      {inFlightDecisions[gap.gapId] === "hold" ?
                        "Holding" :
                        "Hold"}
                    </button>
                    <button
                      disabled={isDeciding}
                      onClick={() => onDecision(gap, "reject")}
                      type="button"
                    >
                      {inFlightDecisions[gap.gapId] === "reject" ?
                        "Rejecting" :
                        "Reject"}
                    </button>
                  </div>
                </div>
              )}

              {gap.reviewDecision ? (
                <div className="intake-section">
                  <div className="intake-section-title">Reviewed Decision</div>
                  <div className="intake-state-grid">
                    <StateRow label="Decision" value={gap.reviewDecision.decision} />
                    <StateRow label="Reviewer" value={gap.reviewDecision.reviewer} />
                    <StateRow label="Date" value={gap.reviewDecision.decidedAt} />
                    <StateRow label="Note" value={gap.reviewDecision.note} />
                    <StateRow
                      label="Missing inputs"
                      value={String(gap.reviewDecision.missingRequiredInputs.length)}
                    />
                    <StateRow
                      label="Batch"
                      value={gap.reviewDecision.policyGapDecisionBatchId}
                    />
                  </div>
                </div>
              ) : null}

              <div className="policy-gap-columns">
                <div>
                  <div className="intake-section-title">Required Inputs</div>
                  <div className="intake-tags">
                    {gap.requiredInputs.map((input) => (
                      <span className="intake-tag" key={input}>
                        {input}
                      </span>
                    ))}
                  </div>
                </div>
                <div>
                  <div className="intake-section-title">Unblock Criteria</div>
                  <div className="intake-tags">
                    {gap.unblockCriteria.map((criterion) => (
                      <span className="intake-tag muted" key={criterion}>
                        {criterion}
                      </span>
                    ))}
                  </div>
                </div>
              </div>

              <div className="command-stack">
                {gap.blockedArtifacts.map((artifact) => (
                  <div className="command-row" key={artifact}>
                    <span>artifact</span>
                    <code>{artifact}</code>
                  </div>
                ))}
              </div>
            </article>
          );
        })}
      </div>
    </div>
  );
}

function OrganizerPolicyDecisionPacketsView({
  packets,
}: {
  packets: OrganizerPolicyDecisionPackets;
}) {
  const visiblePackets = packets.packets.slice(0, 8);

  return (
    <div className="search-candidate-panel">
      <div className="intake-state-grid">
        <StateRow label="Packets" value={String(packets.summary.packets)} />
        <StateRow label="Need decision" value={String(packets.summary.decisionRequired)} />
        <StateRow label="Questions" value={String(packets.summary.questions)} />
        <StateRow label="Unanswered" value={String(packets.summary.unansweredQuestions)} />
        <StateRow label="Accepted" value={String(packets.summary.accepted)} />
        <StateRow label="Held" value={String(packets.summary.held)} />
      </div>

      <div className="intake-tags">
        {Object.entries(packets.summary.questionsByArea).map(([area, count]) => (
          <span className="intake-tag muted" key={area}>
            {area} x{count}
          </span>
        ))}
        {Object.entries(packets.summary.questionsByAnswerState).map(([state, count]) => (
          <span className="intake-tag muted" key={state}>
            {state.replaceAll("_", " ")} x{count}
          </span>
        ))}
        {packets.guardrails.map((guardrail) => (
          <span className="intake-tag muted" key={guardrail}>
            {guardrail}
          </span>
        ))}
      </div>

      <div className="search-candidate-list">
        {visiblePackets.map((packet) => (
          <article className="search-candidate-card" key={packet.packetId}>
            <header className="search-candidate-header">
              <div>
                <div className="intake-eyebrow">
                  {packet.area} / {packet.decisionOwner}
                </div>
                <h3>{packet.decisionPrompt}</h3>
              </div>
              <span className={`intake-badge ${packet.status === "ready" ? "ready" : ""}`}>
                {packet.severity}
              </span>
            </header>

            <div className="intake-state-grid">
              <StateRow label="Gap" value={packet.gapId} />
              <StateRow label="Decision" value={packet.decisionStatus.replaceAll("_", " ")} />
              <StateRow label="Safe default" value={packet.safeDefaultAction.replaceAll("_", " ")} />
              <StateRow label="Gate" value={packet.implementationGate} />
            </div>

            <div className="quality-row warning">
              <Lock size={16} strokeWidth={1.9} />
              <div>
                <strong>{packet.currentState}</strong>
                <span>{packet.nextAction}</span>
              </div>
            </div>

            <div className="intake-section">
              <div className="intake-section-title">Required Inputs</div>
              <div className="intake-tags">
                {packet.questions.map((question) => (
                  <span
                    className={`intake-tag ${question.answerState === "reviewed" ? "" : "muted"}`}
                    key={question.questionId}
                  >
                    {question.input}
                  </span>
                ))}
              </div>
            </div>

            <div className="command-stack">
              {packet.blockedArtifacts.map((artifact) => (
                <div className="command-row" key={artifact}>
                  <span>blocked</span>
                  <code>{artifact}</code>
                </div>
              ))}
            </div>
          </article>
        ))}
      </div>
    </div>
  );
}

function OrganizerCanonicalHostRegistryView({
  registry,
}: {
  registry: OrganizerCanonicalHostEntityRegistry;
}) {
  const visibleEntries = registry.entries.slice(0, 8);

  return (
    <div className="search-candidate-panel">
      <div className="intake-state-grid">
        <StateRow label="Entities" value={String(registry.summary.entities)} />
        <StateRow label="Public" value={String(registry.summary.publicPublished)} />
        <StateRow label="Indexed" value={String(registry.summary.indexed)} />
        <StateRow label="Claim targets" value={String(registry.summary.claimTargets)} />
        <StateRow label="Surfaces" value={String(registry.summary.surfaces)} />
        <StateRow label="Crawl-capable" value={String(registry.summary.crawlCapableSurfaces)} />
      </div>

      <div className="intake-tags">
        <span className="intake-tag">{registry.naming.publicEntityLabel}</span>
        <span className="intake-tag muted">
          {registry.naming.canonicalDataModel}
        </span>
        <span className="intake-tag muted">
          {registry.naming.legacyCompatibilityModel}
        </span>
        {Object.entries(registry.summary.byEntityKind).map(([kind, count]) => (
          <span className="intake-tag muted" key={kind}>
            {kind} x{count}
          </span>
        ))}
        {Object.entries(registry.summary.byScopeKind).map(([scope, count]) => (
          <span className="intake-tag muted" key={scope}>
            {scope} x{count}
          </span>
        ))}
      </div>

      <div className="quality-row warning">
        <Lock size={16} strokeWidth={1.9} />
        <div>
          <strong>{registry.naming.note}</strong>
          <span>{registry.guardrails[0]}</span>
        </div>
      </div>

      <div className="search-candidate-list">
        {visibleEntries.map((entry) => (
          <article className="search-candidate-card" key={entry.canonicalHostId}>
            <header className="search-candidate-header">
              <div>
                <div className="intake-eyebrow">
                  {entry.entityKind} / {entry.geography.scopeKind ?? "unknown"}
                </div>
                <h3>{entry.displayName}</h3>
              </div>
              <span className={`intake-badge ${entry.publicPresence.publishStatus === "published" ? "ready" : ""}`}>
                {entry.publicPresence.publishStatus}
              </span>
            </header>

            <div className="intake-state-grid">
              <StateRow label="Host id" value={entry.canonicalHostId} />
              <StateRow label="Path" value={entry.publicPresence.canonicalPath ?? "none"} />
              <StateRow label="Index" value={entry.publicPresence.indexStatus} />
              <StateRow label="App" value={entry.publicPresence.appVisibility} />
              <StateRow label="Claim" value={entry.claim.claimState} />
              <StateRow label="Club doc" value={entry.legacyClubCompatibility.documentId} />
            </div>

            <div className="intake-tags">
              {entry.geography.markets.map((market) => (
                <span className="intake-tag" key={market.marketSlug}>
                  {market.displayName}
                </span>
              ))}
              <span className="intake-tag muted">
                {entry.surfaceInventory.active} active
              </span>
              <span className="intake-tag muted">
                {entry.surfaceInventory.ambiguous} ambiguous
              </span>
              <span className="intake-tag muted">
                {entry.surfaceInventory.rejected} rejected
              </span>
              <span className="intake-tag muted">
                {entry.dedupe.strongKeys} strong keys
              </span>
            </div>

            <div className="command-stack">
              {entry.nextActions.map((action) => (
                <div className="command-row" key={action}>
                  <span>next</span>
                  <code>{action}</code>
                </div>
              ))}
            </div>
          </article>
        ))}
      </div>
    </div>
  );
}

function OrganizerCanonicalEvidenceIndexView({
  index,
}: {
  index: OrganizerCanonicalEvidenceIndex;
}) {
  const visibleRecords = index.records.slice(0, 8);

  return (
    <div className="search-candidate-panel">
      <div className="intake-state-grid">
        <StateRow label="Records" value={String(index.summary.records)} />
        <StateRow label="Resolved" value={String(index.summary.resolvedArtifactRefs)} />
        <StateRow label="Missing" value={String(index.summary.surfacesWithoutEvidence)} />
        <StateRow label="Manual" value={String(index.summary.manualReportsWithoutArtifacts)} />
        <StateRow label="Raw payloads" value={String(index.summary.rawProviderArtifacts)} />
        <StateRow label="Raw bytes" value={index.summary.rawPayloadBytes.toLocaleString()} />
      </div>

      <div className="intake-tags">
        {Object.entries(index.summary.evidenceByStatus).map(([status, count]) => (
          <span className="intake-tag muted" key={status}>
            {status.replaceAll("_", " ")} x{count}
          </span>
        ))}
        {Object.entries(index.summary.evidenceByType).map(([type, count]) => (
          <span className="intake-tag muted" key={type}>
            {type} x{count}
          </span>
        ))}
      </div>

      <div className="quality-row warning">
        <Lock size={16} strokeWidth={1.9} />
        <div>
          <strong>{index.guardrails[0]}</strong>
          <span>{index.guardrails[1]}</span>
        </div>
      </div>

      <div className="search-candidate-list">
        {visibleRecords.map((record) => (
          <article className="search-candidate-card" key={record.evidenceId}>
            <header className="search-candidate-header">
              <div>
                <div className="intake-eyebrow">
                  {record.surface.platform} / {record.surface.status}
                </div>
                <h3>{record.displayName}</h3>
              </div>
              <span className={`intake-badge ${record.evidence.status === "resolved_artifact" ? "ready" : ""}`}>
                {record.evidence.status.replaceAll("_", " ")}
              </span>
            </header>

            <div className="intake-state-grid">
              <StateRow label="Surface" value={record.surface.surfaceId} />
              <StateRow label="Type" value={record.evidence.type} />
              <StateRow label="Publish" value={record.reviewState.publishStatus ?? "unknown"} />
              <StateRow label="Claim" value={record.reviewState.claimState ?? "unknown"} />
              <StateRow
                label="Artifact"
                value={record.artifact ? record.artifact.artifactKind : "none"}
              />
              <StateRow
                label="SHA"
                value={record.artifact ? record.artifact.sha256.slice(0, 12) : "none"}
              />
            </div>

            <div className="intake-tags">
              {record.riskFlags.length === 0 ? (
                <span className="intake-tag">no flags</span>
              ) : (
                record.riskFlags.map((flag) => (
                  <span className="intake-tag muted" key={flag}>
                    {flag.replaceAll("_", " ")}
                  </span>
                ))
              )}
            </div>

            <div className="command-stack">
              <div className="command-row">
                <span>ref</span>
                <code>{record.evidence.ref ?? "none"}</code>
              </div>
              <div className="command-row">
                <span>next</span>
                <code>{record.nextAction}</code>
              </div>
            </div>
          </article>
        ))}
      </div>
    </div>
  );
}

function OrganizerPublicationReviewPacketsView({
  packets,
}: {
  packets: OrganizerPublicationReviewPackets;
}) {
  const visiblePackets = packets.packets.slice(0, 8);

  return (
    <div className="search-candidate-panel">
      <div className="intake-state-grid">
        <StateRow label="Packets" value={String(packets.summary.packets)} />
        <StateRow label="Ready" value={String(packets.summary.readyForManualPublicationReview)} />
        <StateRow label="Blocked" value={String(packets.summary.blockedByData)} />
        <StateRow label="Published" value={String(packets.summary.published)} />
        <StateRow label="Evidence" value={String(packets.summary.evidenceRecords)} />
        <StateRow label="Manual refs" value={String(packets.summary.manualReportsWithoutArtifacts)} />
      </div>

      <div className="intake-tags">
        {Object.entries(packets.summary.packetsByStatus).map(([status, count]) => (
          <span className="intake-tag muted" key={status}>
            {status.replaceAll("_", " ")} x{count}
          </span>
        ))}
        {Object.entries(packets.summary.packetsByTaskType).map(([type, count]) => (
          <span className="intake-tag muted" key={type}>
            {type.replaceAll("_", " ")} x{count}
          </span>
        ))}
      </div>

      <div className="quality-row warning">
        <Lock size={16} strokeWidth={1.9} />
        <div>
          <strong>{packets.guardrails[0]}</strong>
          <span>{packets.guardrails[1]}</span>
        </div>
      </div>

      <div className="search-candidate-list">
        {visiblePackets.map((packet) => (
          <article className="search-candidate-card" key={packet.packetId}>
            <header className="search-candidate-header">
              <div>
                <div className="intake-eyebrow">
                  {packet.taskType.replaceAll("_", " ")} / {packet.priority}
                </div>
                <h3>{packet.displayName}</h3>
              </div>
              <span className={`intake-badge ${packet.status === "ready_for_manual_publication_review" ? "ready" : ""}`}>
                {packet.status.replaceAll("_", " ")}
              </span>
            </header>

            <div className="intake-state-grid">
              <StateRow label="Path" value={packet.publicPresence.canonicalPath ?? "none"} />
              <StateRow label="Index" value={packet.publicPresence.indexStatus} />
              <StateRow label="App" value={packet.publicPresence.appVisibility} />
              <StateRow label="Evidence" value={String(packet.evidenceSummary.records)} />
              <StateRow label="Data blockers" value={String(packet.dataBlockers.length)} />
              <StateRow label="Evidence blockers" value={String(packet.evidenceBlockers.length)} />
            </div>

            <div className="quality-row">
              <CheckCircle2 size={16} strokeWidth={1.9} />
              <div>
                <strong>{packet.recommendedAction}</strong>
                <span>{packet.publicDraft.headline ?? packet.entityId}</span>
              </div>
            </div>

            <div className="intake-section">
              <div className="intake-section-title">Evidence review</div>
              <div className="intake-state-grid">
                <StateRow label="Shown" value={`${packet.evidenceReview.shownRecords}/${packet.evidenceReview.totalRecords}`} />
                <StateRow label="Artifacts" value={String(packet.evidenceReview.artifactBackedRecords)} />
                <StateRow label="Manual" value={String(packet.evidenceReview.manualReportsWithoutArtifacts)} />
                <StateRow label="Unresolved" value={String(packet.evidenceReview.unresolvedLocalRefs)} />
              </div>
              <div className="command-stack">
                {packet.evidenceReview.records.slice(0, 6).map((record) => (
                  <div className="command-row" key={record.evidenceId}>
                    <span>
                      {record.surface.platform} / {record.evidence.status.replaceAll("_", " ")}
                    </span>
                    <code>{publicationEvidenceReviewLine(record)}</code>
                    <div className="intake-tags">
                      <span className={record.reviewerUse.artifactAvailable ? "intake-tag" : "intake-tag muted"}>
                        {record.reviewerUse.artifactAvailable ? "artifact" : "no artifact"}
                      </span>
                      <span className="intake-tag muted">
                        {record.surface.status.replaceAll("_", " ")}
                      </span>
                      {record.riskFlags.slice(0, 4).map((flag) => (
                        <span className="intake-tag muted" key={flag}>
                          {flag.replaceAll("_", " ")}
                        </span>
                      ))}
                    </div>
                  </div>
                ))}
                {packet.evidenceReview.truncated ? (
                  <div className="command-row">
                    <span>more</span>
                    <code>{packet.evidenceReview.totalRecords - packet.evidenceReview.shownRecords} additional evidence records</code>
                  </div>
                ) : null}
              </div>
            </div>

            <div className="intake-tags">
              {packet.publicDraft.formats.map((format) => (
                <span className="intake-tag" key={format}>
                  {format}
                </span>
              ))}
              {packet.evidenceSummary.riskFlags.map((flag) => (
                <span className="intake-tag muted" key={flag}>
                  {flag.replaceAll("_", " ")}
                </span>
              ))}
            </div>

            <div className="command-stack">
              <div className="command-row">
                <span>decision</span>
                <code>{packet.adminDecision.command}</code>
              </div>
              {packet.nextActions.map((action) => (
                <div className="command-row" key={action}>
                  <span>next</span>
                  <code>{action}</code>
                </div>
              ))}
            </div>
          </article>
        ))}
      </div>
    </div>
  );
}

function publicationEvidenceReviewLine(
  record: OrganizerPublicationEvidenceReviewRecord
) {
  const surface = record.surface.surfaceId ?? "unknown surface";
  const ref = record.evidence.ref ?? record.surface.url ?? "manual report";
  const artifact = record.artifact ?
    `${record.artifact.artifactKind} ${record.artifact.sha256.slice(0, 12)}` :
    "no artifact";
  const candidates = [
    ...record.correlatedCandidates.searchCandidateIds,
    ...record.correlatedCandidates.externalEventCandidateIds,
  ];
  const candidateText = candidates.length > 0 ?
    ` / candidates ${candidates.slice(0, 3).join(", ")}` :
    "";
  return `${surface} / ${record.evidence.type} / ${ref} / ${artifact} / next ${record.nextAction}${candidateText}`;
}

function OrganizerPublicationImpactPreviewView({
  preview,
}: {
  preview: OrganizerPublicationDecisionImpactPreview;
}) {
  const visibleEntries = preview.entries.slice(0, 8);

  return (
    <div className="search-candidate-panel">
      <div className="intake-state-grid">
        <StateRow label="Impacts" value={String(preview.summary.impacts)} />
        <StateRow label="Would publish" value={String(preview.summary.wouldPublish)} />
        <StateRow label="Would index" value={String(preview.summary.wouldIndex)} />
        <StateRow label="Claim targets" value={String(preview.summary.wouldCreateClaimTargets)} />
        <StateRow label="App visible" value={String(preview.summary.wouldBeAppDiscoverable)} />
        <StateRow label="Manual acks" value={String(preview.summary.reviewerAcknowledgementsRequired)} />
      </div>

      <div className="intake-tags">
        {Object.entries(preview.summary.byStatus).map(([status, count]) => (
          <span className="intake-tag muted" key={status}>
            {status.replaceAll("_", " ")} x{count}
          </span>
        ))}
      </div>

      <div className="quality-row warning">
        <Lock size={16} strokeWidth={1.9} />
        <div>
          <strong>{preview.guardrails[0]}</strong>
          <span>{preview.guardrails[1]}</span>
        </div>
      </div>

      <div className="search-candidate-list">
        {visibleEntries.map((entry) => (
          <article className="search-candidate-card" key={entry.impactId}>
            <header className="search-candidate-header">
              <div>
                <div className="intake-eyebrow">
                  {entry.entityId} / {entry.decisionRequired.decision}
                </div>
                <h3>{entry.displayName}</h3>
              </div>
              <span className={`intake-badge ${entry.status.includes("would_publish") ? "ready" : ""}`}>
                {entry.status.replaceAll("_", " ")}
              </span>
            </header>

            <div className="intake-state-grid">
              <StateRow label="Path" value={entry.publicProjection.canonicalPath ?? "none"} />
              <StateRow label="Publish" value={entry.publicProjection.publishStatus} />
              <StateRow label="Index" value={entry.publicProjection.indexing} />
              <StateRow label="Claim" value={entry.claimTarget.path ?? "none"} />
              <StateRow label="App" value={entry.app.appVisibility} />
              <StateRow label="Sitemap" value={entry.remoteEffects.sitemapEligible ? "eligible" : "excluded"} />
            </div>

            <div className="intake-tags">
              {entry.preconditions.reviewerAcknowledgementRequired ? (
                <span className="intake-tag muted">
                  manual reports require acknowledgement
                </span>
              ) : (
                <span className="intake-tag">packet ready</span>
              )}
              {entry.publicProjection.legacyPaths.map((legacyPath) => (
                <span className="intake-tag muted" key={legacyPath}>
                  legacy {legacyPath}
                </span>
              ))}
              {entry.preconditions.blockers?.map((blocker) => (
                <span className="intake-tag muted" key={blocker}>
                  {blocker.replaceAll("_", " ")}
                </span>
              ))}
            </div>

            <div className="command-stack">
              {entry.commands.map((command) => (
                <div className="command-row" key={command}>
                  <span>next</span>
                  <code>{command}</code>
                </div>
              ))}
            </div>
          </article>
        ))}
      </div>
    </div>
  );
}

function readinessGateTone(status: string) {
  if (status === "ready") return "passed";
  return "blocked";
}

function healthStatusTone(status: string) {
  if (status === "ready" || status === "clear" || status === "idle") {
    return "ready";
  }
  return "";
}

function coverageStatusTone(status: string) {
  if (
    status === "covered_by_input_request" ||
    status === "covered_by_follow_up"
  ) {
    return "ready";
  }
  return "";
}

function promotionPhaseTone(status: string) {
  if (
    status === "ready" ||
    status === "ready_for_firestore_dry_run" ||
    status === "ready_after_reviewed_firestore_dry_run"
  ) {
    return "ready";
  }
  if (
    status.startsWith("blocked") ||
    status.startsWith("disabled") ||
    status.startsWith("waiting")
  ) {
    return "blocked";
  }
  return "";
}

function formatHealthMetric(value: string | number | boolean | null) {
  if (typeof value === "number") return value.toLocaleString();
  if (typeof value === "boolean") return value ? "yes" : "no";
  return value ?? "none";
}

function OrganizerClaimTargetSyncPreviewView({
  preview,
}: {
  preview: OrganizerClaimTargetSyncPreview;
}) {
  const visibleActions = preview.actions.slice(0, 8);

  return (
    <div className="search-candidate-panel">
      <div className="intake-state-grid">
        <StateRow label="Targets" value={String(preview.summary.targets)} />
        <StateRow label="Creates" value={String(preview.summary.creates)} />
        <StateRow label="Refreshes" value={String(preview.summary.refreshes)} />
        <StateRow label="Owner-bound" value={String(preview.summary.skippedOwnerBound)} />
        <StateRow label="Writes" value={String(preview.summary.writesNeeded)} />
        <StateRow label="Remote writes" value={String(preview.mode.remoteWrites)} />
      </div>

      <div className="quality-row warning">
        <Lock size={16} strokeWidth={1.9} />
        <div>
          <strong>{preview.guardrails[0]}</strong>
          <span>{preview.guardrails[1]}</span>
        </div>
      </div>

      <div className="intake-tags">
        <span className="intake-tag muted">
          source {preview.mode.existingDocsSource}
        </span>
        {preview.mode.assumesMissingWhenNotInFixture ? (
          <span className="intake-tag muted">missing docs assumed absent</span>
        ) : null}
      </div>

      <div className="search-candidate-list">
        {visibleActions.length === 0 ? (
          <div className="empty-row">
            <CheckCircle2 size={16} strokeWidth={1.9} />
            <span>No claim-target sync actions until a public approval exists.</span>
          </div>
        ) : (
          visibleActions.map((action) => (
            <article className="search-candidate-card" key={`${action.path}-${action.status}`}>
              <header className="search-candidate-header">
                <div>
                  <div className="intake-eyebrow">
                    {action.entityId} / {action.reason.replaceAll("_", " ")}
                  </div>
                  <h3>{action.path}</h3>
                </div>
                <span className={`intake-badge ${action.writesRemoteData ? "ready" : ""}`}>
                  {action.status.replaceAll("_", " ")}
                </span>
              </header>

              <div className="intake-state-grid">
                <StateRow label="Merge" value={action.merge ? "merge" : "set"} />
                <StateRow label="Fields" value={String(action.writeFieldCount)} />
                <StateRow label="Dry run" value={action.requiresFirestoreDryRun ? "required" : "not required"} />
              </div>

              <div className="intake-tags">
                {action.writeFields.slice(0, 12).map((field) => (
                  <span className="intake-tag muted" key={field}>
                    {field}
                  </span>
                ))}
              </div>
            </article>
          ))
        )}
      </div>

      <div className="command-stack">
        {Object.entries(preview.commands).map(([label, command]) => (
          <div className="command-row" key={label}>
            <span>{label}</span>
            <code>{command}</code>
          </div>
        ))}
      </div>
    </div>
  );
}

function OrganizerCrawlRunPlanView({
  plan,
}: {
  plan: OrganizerCrawlRunPlan;
}) {
  const visibleIntents = plan.runIntents.slice(0, 8);

  return (
    <div className="search-candidate-panel">
      <div className="intake-state-grid">
        <StateRow label="Scheduler" value={plan.policy.schedulerEnabled ? "enabled" : "disabled"} />
        <StateRow label="Network" value={plan.policy.networkEnabled ? "enabled" : "disabled"} />
        <StateRow label="Request cap" value={String(plan.policy.maxRequestsPerRun)} />
        <StateRow label="Would fetch" value={String(plan.summary.wouldFetch)} />
        <StateRow label="Blocked" value={String(plan.summary.blocked)} />
        <StateRow label="Writes" value={String(plan.summary.firestoreWrites)} />
      </div>

      <div className="intake-tags">
        {plan.policy.platformAllowlist.length === 0 ? (
          <span className="intake-tag muted">No platform allowlist</span>
        ) : (
          plan.policy.platformAllowlist.map((platform) => (
            <span className="intake-tag" key={platform}>{platform}</span>
          ))
        )}
        {plan.guardrails.map((guardrail) => (
          <span className="intake-tag muted" key={guardrail}>
            {guardrail}
          </span>
        ))}
      </div>

      <div className="intake-section">
        <div className="intake-section-title">Run blockers</div>
        <div className="intake-tags">
          {Object.entries(plan.summary.blockers)
            .sort(([left], [right]) => left.localeCompare(right))
            .map(([blocker, count]) => (
              <span className="intake-tag muted" key={blocker}>
                {blocker} x{count}
              </span>
            ))}
        </div>
      </div>

      <div className="search-candidate-list">
        {visibleIntents.map((intent) => (
          <article className="search-candidate-card" key={intent.crawlRunId}>
            <header className="search-candidate-header">
              <div>
                <div className="intake-eyebrow">
                  {intent.platform} / {intent.surfaceKind}
                </div>
                <h3>{intent.displayName}</h3>
              </div>
              <span className={`intake-badge ${intent.action === "would_fetch" ? "ready" : ""}`}>
                {intent.action.replaceAll("_", " ")}
              </span>
            </header>
            <div className="intake-state-grid">
              <StateRow label="Run" value={intent.crawlRunId} />
              <StateRow label="Surface" value={intent.surfaceId} />
              <StateRow label="Next" value={intent.nextGate.replaceAll("_", " ")} />
              <StateRow label="Output" value={intent.expectedOutput} />
            </div>
            <div className="intake-tags">
              {intent.blockedBy.length === 0 ? (
                <span className="intake-tag">ready for reviewed capture</span>
              ) : (
                intent.blockedBy.map((blocker) => (
                  <span className="intake-tag muted" key={blocker}>
                    {blocker}
                  </span>
                ))
              )}
            </div>
          </article>
        ))}
      </div>
    </div>
  );
}

function OrganizerRawArtifactStorageView({
  manifest,
}: {
  manifest: OrganizerRawArtifactStorageManifest;
}) {
  const visibleArtifacts = manifest.artifacts.slice(0, 8);

  return (
    <div className="search-candidate-panel">
      <div className="intake-state-grid">
        <StateRow label="Policy" value={manifest.policy.status.replaceAll("_", " ")} />
        <StateRow label="Object storage" value={manifest.policy.remoteObjectStorageEnabled ? "enabled" : "disabled"} />
        <StateRow label="Firestore raw" value={manifest.summary.firestoreRawStorageAllowed ? "allowed" : "forbidden"} />
        <StateRow label="Raw payloads" value={String(manifest.summary.rawProviderPayloads)} />
        <StateRow label="Upload blocked" value={String(manifest.summary.remoteUploadBlocked)} />
        <StateRow label="Bytes" value={manifest.summary.totalBytes.toLocaleString()} />
      </div>

      <div className="intake-tags">
        <span className="intake-tag muted">provider: {manifest.policy.provider}</span>
        <span className="intake-tag muted">
          bucket: {manifest.policy.bucket ?? "not configured"}
        </span>
        <span className="intake-tag muted">
          retention: {manifest.policy.rawPayloadRetentionDays ?? "not configured"}
        </span>
        {manifest.guardrails.map((guardrail) => (
          <span className="intake-tag muted" key={guardrail}>
            {guardrail}
          </span>
        ))}
      </div>

      <div className="intake-section">
        <div className="intake-section-title">Storage blockers</div>
        <div className="intake-tags">
          {Object.entries(manifest.summary.blockers).length === 0 ? (
            <span className="intake-tag">No upload blockers</span>
          ) : (
            Object.entries(manifest.summary.blockers)
              .sort(([left], [right]) => left.localeCompare(right))
              .map(([blocker, count]) => (
                <span className="intake-tag muted" key={blocker}>
                  {blocker} x{count}
                </span>
              ))
          )}
        </div>
      </div>

      <div className="search-candidate-list">
        {visibleArtifacts.map((artifact) => (
          <article className="search-candidate-card" key={artifact.artifactId}>
            <header className="search-candidate-header">
              <div>
                <div className="intake-eyebrow">
                  {artifact.storageClass} / {artifact.artifactKind}
                </div>
                <h3>{artifact.path}</h3>
              </div>
              <span className={`intake-badge ${artifact.storagePlan.action === "would_upload" ? "ready" : ""}`}>
                {artifact.storagePlan.action.replaceAll("_", " ")}
              </span>
            </header>
            <div className="intake-state-grid">
              <StateRow label="Firestore" value={artifact.firestoreMode.replaceAll("_", " ")} />
              <StateRow label="Retention" value={artifact.retention.status.replaceAll("_", " ")} />
              <StateRow label="Bytes" value={artifact.sizeBytes.toLocaleString()} />
              <StateRow label="Object key" value={artifact.storagePlan.remoteObjectKey} />
            </div>
            <div className="intake-tags">
              {artifact.storagePlan.blockedBy.length === 0 ? (
                <span className="intake-tag">storage policy satisfied</span>
              ) : (
                artifact.storagePlan.blockedBy.map((blocker) => (
                  <span className="intake-tag muted" key={blocker}>
                    {blocker}
                  </span>
                ))
              )}
            </div>
          </article>
        ))}
      </div>
    </div>
  );
}

function OrganizerSearchCandidateQueueView({
  curationInFlight,
  localCuration,
  onAttachCandidate,
  queue,
}: {
  curationInFlight: Record<string, boolean>;
  localCuration: Record<string, AdminRecordOrganizerCurationResponse>;
  onAttachCandidate: (candidate: OrganizerSearchCandidate) => void;
  queue: OrganizerSearchCandidateQueue;
}) {
  const platformEntries = Object.entries(queue.summary.platforms)
    .sort(([left], [right]) => left.localeCompare(right));
  const visibleCandidates = queue.candidates.slice(0, 12);

  return (
    <div className="search-candidate-panel">
      <div className="intake-state-grid">
        <StateRow label="Batches" value={String(queue.summary.batches)} />
        <StateRow label="Results" value={String(queue.summary.results)} />
        <StateRow label="Matched" value={String(queue.summary.matchedExistingEntities)} />
        <StateRow label="Duplicate keys" value={String(queue.summary.duplicateNormalizedKeys)} />
      </div>

      <div className="intake-tags">
        {platformEntries.length === 0 ? (
          <span className="intake-tag muted">No captured surfaces</span>
        ) : (
          platformEntries.map(([platform, count]) => (
            <span className="intake-tag" key={platform}>
              {platform} x{count}
            </span>
          ))
        )}
      </div>

      {queue.errors.length > 0 || queue.warnings.length > 0 ? (
        <div className="intake-section">
          <div className="intake-section-title">Queue Diagnostics</div>
          <div className="intake-gate-list">
            {[...queue.errors, ...queue.warnings].map((message) => (
              <div className="intake-gate blocked" key={message}>
                <FileWarning size={15} strokeWidth={1.9} />
                <div>
                  <strong>{message}</strong>
                </div>
              </div>
            ))}
          </div>
        </div>
      ) : null}

      <div className="search-candidate-list">
        {visibleCandidates.length === 0 ? (
          <div className="empty-row">
            <CheckCircle2 size={16} strokeWidth={1.9} />
            <span>No captured search surfaces</span>
          </div>
        ) : (
          visibleCandidates.map((candidate) => (
            <OrganizerSearchCandidateCard
              candidate={candidate}
              commands={queue.commands}
              inFlight={curationInFlight[candidate.candidateId] === true}
              key={candidate.candidateId}
              localCuration={localCuration[candidate.candidateId]}
              onAttachCandidate={onAttachCandidate}
            />
          ))
        )}
      </div>

      <div className="intake-section">
        <div className="intake-section-title">Queue Commands</div>
        <div className="command-stack">
          {Object.entries(queue.commands).map(([label, command]) => (
            <div className="command-row" key={label}>
              <span>{label}</span>
              <code>{command}</code>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

function OrganizerSearchCandidateCard({
  candidate,
  commands,
  inFlight,
  localCuration,
  onAttachCandidate,
}: {
  candidate: OrganizerSearchCandidate;
  commands: OrganizerSearchCandidateCommands;
  inFlight: boolean;
  localCuration?: AdminRecordOrganizerCurationResponse;
  onAttachCandidate: (candidate: OrganizerSearchCandidate) => void;
}) {
  const matchedEntityIds = candidate.existingEntityMatches.map((match) => match.entityId);
  const entityTarget = matchedEntityIds[0] ?? "ENTITY";
  const attachCommand = commands.curateSurface
    .replace("ENTITY", entityTarget)
    .replace("CANDIDATE_ID", candidate.candidateId);
  const canAttach =
    candidate.reviewAction !== "supporting_evidence_only" &&
    matchedEntityIds.length > 0 &&
    !localCuration;

  return (
    <article className="search-candidate-card">
      <header className="search-candidate-header">
        <div>
          <div className="intake-eyebrow">
            #{candidate.rank} / {candidate.platform} / {candidate.surfaceKind}
          </div>
          <h3>{candidate.title}</h3>
        </div>
        <span className={`intake-badge ${candidate.reviewAction.includes("attach") ? "ready" : ""}`}>
          {candidate.reviewAction.replaceAll("_", " ")}
        </span>
      </header>

      <div className="intake-state-grid">
        <StateRow label="Candidate" value={candidate.candidateId} />
        <StateRow label="Observed" value={candidate.observedAt} />
        <StateRow label="Normalized" value={candidate.normalizedKey ?? "none"} />
        <StateRow label="Canonical URL" value={candidate.canonicalUrl} />
      </div>

      {candidate.snippet ? (
        <p className="search-candidate-snippet">{candidate.snippet}</p>
      ) : null}

      <div className="intake-tags">
        {matchedEntityIds.length > 0 ? (
          matchedEntityIds.map((entityId) => (
            <span className="intake-tag" key={entityId}>
              matches {entityId}
            </span>
          ))
        ) : (
          <span className="intake-tag muted">no surface match</span>
        )}
        {candidate.queryIntent.marketSlug ? (
          <span className="intake-tag muted">{candidate.queryIntent.marketSlug}</span>
        ) : null}
        {candidate.queryIntent.entityHint ? (
          <span className="intake-tag muted">{candidate.queryIntent.entityHint}</span>
        ) : null}
        {candidate.diagnostics.map((diagnostic) => (
          <span className="intake-tag muted" key={diagnostic}>{diagnostic}</span>
        ))}
      </div>

      {candidate.reviewAction !== "supporting_evidence_only" ? (
        <div className="search-candidate-actions">
          {localCuration ? (
            <div className="intake-decision-state">
              <CheckCircle2 size={16} strokeWidth={1.9} />
              <div>
                <strong>Attach recorded</strong>
                <span>{localCuration.decisionPath}</span>
              </div>
            </div>
          ) : (
            <button
              disabled={!canAttach || inFlight}
              onClick={() => onAttachCandidate(candidate)}
              type="button"
            >
              {inFlight ? "Recording" : "Attach surface"}
            </button>
          )}
          <div className="command-row">
            <span>attach</span>
            <code>{attachCommand}</code>
          </div>
        </div>
      ) : null}
    </article>
  );
}

function OrganizerExternalEventCandidateQueueView({
  decisionInFlight,
  localDecisions,
  notes,
  onDecision,
  onNoteChange,
  queue,
}: {
  decisionInFlight: Record<string, OrganizerEventCandidateDecision>;
  localDecisions: Record<string, AdminDecideOrganizerEventCandidateResponse>;
  notes: Record<string, string>;
  onDecision: (
    candidate: OrganizerExternalEventCandidate,
    decision: OrganizerEventCandidateDecision
  ) => void;
  onNoteChange: (candidateId: string, note: string) => void;
  queue: OrganizerExternalEventCandidateQueue;
}) {
  const visibleCandidates = queue.candidates.slice(0, 8);
  return (
    <div className="search-candidate-panel">
      <div className="intake-state-grid">
        <StateRow label="Batches" value={String(queue.summary.batches)} />
        <StateRow label="Events" value={String(queue.summary.events)} />
        <StateRow label="Candidates" value={String(queue.summary.candidates)} />
        <StateRow label="Blocked" value={String(queue.summary.blocked)} />
        <StateRow label="Reviewed" value={String(queue.summary.reviewed ?? 0)} />
        <StateRow
          label="Approved"
          value={String(queue.summary.approvedForImport ?? 0)}
        />
        <StateRow label="Held" value={String(queue.summary.held ?? 0)} />
        <StateRow label="Rejected" value={String(queue.summary.rejected ?? 0)} />
      </div>

      <div className="quality-row warning">
        <Clock3 size={16} strokeWidth={1.9} />
        <div>
          <strong>{queue.policy.importWritesEnabled ? "Import writes enabled" : "Import writes disabled"}</strong>
          <span>{queue.policy.reason}</span>
        </div>
      </div>

      <div className="intake-tags">
        {Object.entries(queue.summary.platforms).length === 0 ? (
          <span className="intake-tag muted">no provider batches</span>
        ) : (
          Object.entries(queue.summary.platforms)
            .sort(([left], [right]) => left.localeCompare(right))
            .map(([platform, count]) => (
              <span className="intake-tag" key={platform}>
                {platform} x{count}
              </span>
            ))
        )}
      </div>

      {queue.errors.length > 0 || queue.warnings.length > 0 ? (
        <div className="intake-section">
          <div className="intake-section-title">Event Diagnostics</div>
          <div className="intake-gate-list">
            {[...queue.errors, ...queue.warnings].map((message) => (
              <div className="intake-gate blocked" key={message}>
                <FileWarning size={15} strokeWidth={1.9} />
                <div>
                  <strong>{message}</strong>
                </div>
              </div>
            ))}
          </div>
        </div>
      ) : null}

      <div className="search-candidate-list">
        {visibleCandidates.length === 0 ? (
          <div className="empty-row">
            <CheckCircle2 size={16} strokeWidth={1.9} />
            <span>No external event candidates</span>
          </div>
        ) : (
          visibleCandidates.map((candidate) => (
            <OrganizerExternalEventCandidateCard
              candidate={candidate}
              inFlightDecision={decisionInFlight[candidate.candidateId]}
              key={candidate.candidateId}
              localDecision={localDecisions[candidate.candidateId]}
              note={notes[candidate.candidateId] ?? ""}
              onDecision={(decision) => onDecision(candidate, decision)}
              onNoteChange={(note) => onNoteChange(candidate.candidateId, note)}
            />
          ))
        )}
      </div>

      <div className="intake-section">
        <div className="intake-section-title">Event Commands</div>
        <div className="command-stack">
          {Object.entries(queue.commands).map(([label, command]) => (
            <div className="command-row" key={label}>
              <span>{label}</span>
              <code>{command}</code>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

function OrganizerExternalEventImportPlanView({
  plan,
}: {
  plan: OrganizerExternalEventImportPlan;
}) {
  const visibleActions = plan.actions.slice(0, 8);

  return (
    <div className="search-candidate-panel">
      <div className="intake-state-grid">
        <StateRow label="Candidates" value={String(plan.summary.candidates)} />
        <StateRow
          label="Read-only events"
          value={String(plan.summary.proposedReadOnlyEvents ?? plan.summary.proposedCreates)}
        />
        <StateRow label="Merged links" value={String(plan.summary.mergedSourceLinks ?? 0)} />
        <StateRow label="Write-ready" value={String(plan.summary.writeReady)} />
        <StateRow label="Blocked" value={String(plan.summary.blocked)} />
        <StateRow label="Waiting" value={String(plan.summary.waitingReview)} />
        <StateRow label="Rejected" value={String(plan.summary.rejected)} />
      </div>

      <div className="quality-row warning">
        <Lock size={16} strokeWidth={1.9} />
        <div>
          <strong>{plan.policy.writeEnabled ? "Writes enabled" : "Writes disabled"}</strong>
          <span>{plan.policy.reason}</span>
        </div>
      </div>

      <div className="intake-tags">
        {plan.guardrails.map((guardrail) => (
          <span className="intake-tag muted" key={guardrail}>
            {guardrail}
          </span>
        ))}
      </div>

      <div className="search-candidate-list">
        {visibleActions.length === 0 ? (
          <div className="empty-row">
            <CheckCircle2 size={16} strokeWidth={1.9} />
            <span>No event import actions</span>
          </div>
        ) : (
          visibleActions.map((action) => (
            <article className="search-candidate-card" key={action.actionId}>
              <header className="search-candidate-header">
                <div>
                  <div className="intake-eyebrow">
                    {action.platform} / {action.status}
                  </div>
                  <h3>{action.proposedReadOnlyEventDraft.eventId}</h3>
                </div>
                <span className={`intake-badge ${action.status === "write_ready" ? "ready" : ""}`}>
                  {action.action.replaceAll("_", " ")}
                </span>
              </header>

              <div className="intake-state-grid">
                <StateRow label="Candidate" value={action.candidateId} />
                <StateRow label="Target" value={action.targetPath} />
                <StateRow
                  label="Organizer"
                  value={action.proposedReadOnlyEventDraft.canonicalHostId}
                />
                <StateRow label="Starts" value={action.proposedReadOnlyEventDraft.startTime} />
                <StateRow label="Ends" value={action.proposedReadOnlyEventDraft.endTime ?? "unknown"} />
                <StateRow label="Activity" value={action.proposedReadOnlyEventDraft.activity.activityKind} />
                <StateRow
                  label="Outbound links"
                  value={String(action.proposedReadOnlyEventDraft.booking.externalLinks.length)}
                />
                <StateRow
                  label="Catch booking"
                  value={action.proposedReadOnlyEventDraft.booking.catchBookingEnabled ? "enabled" : "disabled"}
                />
              </div>

              <div className="intake-tags">
                {action.proposedReadOnlyEventDraft.booking.externalLinks.map((link) => (
                  <span className="intake-tag ready" key={`${link.platform}-${link.url}`}>
                    {link.platform} outbound
                  </span>
                ))}
                {action.blockers.map((blocker) => (
                  <span className="intake-tag muted" key={blocker}>
                    {blocker}
                  </span>
                ))}
                {action.duplicateCandidateIds.map((candidateId) => (
                  <span className="intake-tag muted" key={candidateId}>
                    duplicate {candidateId}
                  </span>
                ))}
              </div>
            </article>
          ))
        )}
      </div>

      <div className="intake-section">
        <div className="intake-section-title">Import Commands</div>
        <div className="command-stack">
          {Object.entries(plan.commands).map(([label, command]) => (
            <div className="command-row" key={label}>
              <span>{label}</span>
              <code>{command}</code>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

function OrganizerExternalEventLocationResolutionView({
  forms,
  inFlight,
  localResolutions,
  onFormChange,
  onResolve,
  queue,
}: {
  forms: Record<string, OrganizerLocationResolutionFormState>;
  inFlight: Record<string, boolean>;
  localResolutions: Record<string, AdminResolveOrganizerEventLocationResponse>;
  onFormChange: (
    taskId: string,
    form: OrganizerLocationResolutionFormState
  ) => void;
  onResolve: (task: OrganizerExternalEventLocationResolutionTask) => void;
  queue: OrganizerExternalEventLocationResolutionQueue;
}) {
  const visibleTasks = queue.tasks.slice(0, 8);

  return (
    <div className="search-candidate-panel">
      <div className="intake-state-grid">
        <StateRow label="Candidates" value={String(queue.summary.candidates)} />
        <StateRow label="Tasks" value={String(queue.summary.tasks)} />
        <StateRow label="Missing coords" value={String(queue.summary.missingExactCoordinates)} />
        <StateRow label="Missing text" value={String(queue.summary.missingLocationText)} />
        <StateRow label="Provider disabled" value={String(queue.summary.providerDisabled)} />
        <StateRow label="Provider" value={queue.policy.provider} />
      </div>

      <div className="quality-row warning">
        <Lock size={16} strokeWidth={1.9} />
        <div>
          <strong>
            {queue.policy.providerLookupEnabled ? "Provider lookup enabled" : "Provider lookup disabled"}
          </strong>
          <span>{queue.policy.reason}</span>
        </div>
      </div>

      <div className="intake-tags">
        {queue.guardrails.map((guardrail) => (
          <span className="intake-tag muted" key={guardrail}>
            {guardrail}
          </span>
        ))}
      </div>

      <div className="search-candidate-list">
        {visibleTasks.length === 0 ? (
          <div className="empty-row">
            <CheckCircle2 size={16} strokeWidth={1.9} />
            <span>No event location resolution tasks</span>
          </div>
        ) : (
          visibleTasks.map((task) => {
            const form = forms[task.taskId] ??
              locationResolutionFormFromTask(task);
            const localResolution = localResolutions[task.candidateId];
            return (
              <article className="search-candidate-card" key={task.taskId}>
              <header className="search-candidate-header">
                <div>
                  <div className="intake-eyebrow">
                    {task.platform} / {task.resolutionState}
                  </div>
                  <h3>{task.title}</h3>
                </div>
                <span className="intake-badge">
                  {task.countryCode}
                </span>
              </header>

              <div className="intake-state-grid">
                <StateRow label="Candidate" value={task.candidateId} />
                <StateRow label="Entity" value={task.entityId} />
                <StateRow label="Starts" value={task.startAt} />
                <StateRow label="Query" value={task.resolutionQuery || "missing"} />
                <StateRow label="Name" value={task.sourceLocation.name ?? "missing"} />
                <StateRow label="Address" value={task.sourceLocation.address ?? "missing"} />
                <StateRow
                  label="Local decision"
                  value={localResolution?.resolutionStatus ?? "not recorded"}
                />
              </div>

              <div className="intake-tags">
                {task.blockers.map((blocker) => (
                  <span className="intake-tag muted" key={blocker}>
                    {blocker}
                  </span>
                ))}
              </div>

              <div className="location-resolution-form">
                <label>
                  <span>Name</span>
                  <input
                    value={form.name}
                    onChange={(event) =>
                      onFormChange(task.taskId, {
                        ...form,
                        name: event.target.value,
                      })}
                  />
                </label>
                <label>
                  <span>Address</span>
                  <input
                    value={form.address}
                    onChange={(event) =>
                      onFormChange(task.taskId, {
                        ...form,
                        address: event.target.value,
                      })}
                  />
                </label>
                <label>
                  <span>Place ID</span>
                  <input
                    value={form.placeId}
                    onChange={(event) =>
                      onFormChange(task.taskId, {
                        ...form,
                        placeId: event.target.value,
                      })}
                  />
                </label>
                <label>
                  <span>Latitude</span>
                  <input
                    inputMode="decimal"
                    value={form.latitude}
                    onChange={(event) =>
                      onFormChange(task.taskId, {
                        ...form,
                        latitude: event.target.value,
                      })}
                  />
                </label>
                <label>
                  <span>Longitude</span>
                  <input
                    inputMode="decimal"
                    value={form.longitude}
                    onChange={(event) =>
                      onFormChange(task.taskId, {
                        ...form,
                        longitude: event.target.value,
                      })}
                  />
                </label>
                <label className="span-2">
                  <span>Resolution notes</span>
                  <input
                    value={form.notes}
                    onChange={(event) =>
                      onFormChange(task.taskId, {
                        ...form,
                        notes: event.target.value,
                      })}
                  />
                </label>
                <label className="span-2">
                  <span>Review note</span>
                  <textarea
                    rows={2}
                    value={form.note}
                    onChange={(event) =>
                      onFormChange(task.taskId, {
                        ...form,
                        note: event.target.value,
                      })}
                  />
                </label>
              </div>

              <div className="search-candidate-actions">
                <button
                  disabled={
                    inFlight[task.taskId] === true ||
                    localResolution?.resolutionStatus === "resolved"
                  }
                  onClick={() => onResolve(task)}
                  type="button"
                >
                  {localResolution?.resolutionStatus === "resolved" ?
                    "Resolved" :
                    inFlight[task.taskId] ? "Saving..." : "Resolve location"}
                </button>
              </div>
            </article>
            );
          })
        )}
      </div>

      <div className="intake-section">
        <div className="intake-section-title">Location Commands</div>
        <div className="command-stack">
          {Object.entries(queue.commands).map(([label, command]) => (
            <div className="command-row" key={label}>
              <span>{label}</span>
              <code>{command}</code>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

function OrganizerExternalEventImportExecutionPlanView({
  plan,
}: {
  plan: OrganizerExternalEventImportExecutionPlan;
}) {
  const visibleActions = plan.actions.slice(0, 8);

  return (
    <div className="search-candidate-panel">
      <div className="intake-state-grid">
        <StateRow label="Import actions" value={String(plan.summary.importActions)} />
        <StateRow
          label="Read-only actions"
          value={String(plan.summary.readOnlyActions ?? plan.summary.createActions)}
        />
        <StateRow
          label="Would publish"
          value={String(plan.summary.wouldPublishReadOnly ?? plan.summary.wouldCreate)}
        />
        <StateRow label="Blocked" value={String(plan.summary.blocked)} />
        <StateRow
          label="Projection invalid"
          value={String(plan.summary.projectionInvalid ?? plan.summary.schemaInvalid)}
        />
        <StateRow
          label="Projection errors"
          value={String(plan.summary.projectionInvalidCount ?? plan.summary.payloadInvalid)}
        />
      </div>

      <div className="quality-row warning">
        <Lock size={16} strokeWidth={1.9} />
        <div>
          <strong>
            {plan.policy.writeEnabled ? "Execution writes enabled" : "Execution writes disabled"}
          </strong>
          <span>
            {plan.policy.authorityModel} / {plan.policy.reason}
          </span>
        </div>
      </div>

      <div className="intake-tags">
        {plan.guardrails.map((guardrail) => (
          <span className="intake-tag muted" key={guardrail}>
            {guardrail}
          </span>
        ))}
      </div>

      <div className="search-candidate-list">
        {visibleActions.length === 0 ? (
          <div className="empty-row">
            <CheckCircle2 size={16} strokeWidth={1.9} />
            <span>No event import execution actions</span>
          </div>
        ) : (
          visibleActions.map((action) => (
            <article className="search-candidate-card" key={action.actionId}>
              <header className="search-candidate-header">
                <div>
                  <div className="intake-eyebrow">
                    {(action.targetWriter ?? action.targetCallable ?? "read-only projection")} / {action.status}
                  </div>
                  <h3>{action.readOnlyEventProjection?.eventId ?? action.createEventPayload?.eventId ?? action.sourceActionId}</h3>
                </div>
                <span className={`intake-badge ${action.status === "would_publish_read_only" ? "ready" : ""}`}>
                  {action.sourceAction.replaceAll("_", " ")}
                </span>
              </header>

              <div className="intake-state-grid">
                <StateRow label="Candidate" value={action.candidateId} />
                <StateRow label="Target" value={action.targetPath} />
                <StateRow
                  label="Organizer"
                  value={action.readOnlyEventProjection?.canonicalHostId ?? action.createEventPayload?.clubId ?? action.entityId}
                />
                <StateRow
                  label="Starts"
                  value={action.readOnlyEventProjection?.startTime ?? String(action.createEventPayload?.startTimeMillis ?? "invalid")}
                />
                <StateRow
                  label="Outbound links"
                  value={String(action.readOnlyEventProjection?.booking.externalLinks.length ?? 0)}
                />
                <StateRow
                  label="Projection"
                  value={(action.projectionValidation ?? action.payloadValidation).valid ? "valid" : "invalid"}
                />
              </div>

              <div className="intake-tags">
                {action.blockers.map((blocker) => (
                  <span className="intake-tag muted" key={blocker}>
                    {blocker}
                  </span>
                ))}
              </div>

              {(action.projectionValidation?.errors ?? action.payloadValidation.errors).length > 0 ? (
                <div className="intake-section">
                  <div className="intake-section-title">Projection errors</div>
                  <div className="guardrail-list">
                    {(action.projectionValidation?.errors ?? action.payloadValidation.errors).map((error, index) => (
                      <div
                        className="quality-row warning"
                        key={`${error.path}-${error.keyword}-${index}`}
                      >
                        <FileWarning size={16} strokeWidth={1.9} />
                        <div>
                          <strong>{error.path}</strong>
                          <span>{error.message}</span>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              ) : null}
            </article>
          ))
        )}
      </div>

      <div className="intake-section">
        <div className="intake-section-title">Preflight Commands</div>
        <div className="command-stack">
          {Object.entries(plan.commands).map(([label, command]) => (
            <div className="command-row" key={label}>
              <span>{label}</span>
              <code>{command}</code>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

function OrganizerExternalEventCandidateCard({
  candidate,
  inFlightDecision,
  localDecision,
  note,
  onDecision,
  onNoteChange,
}: {
  candidate: OrganizerExternalEventCandidate;
  inFlightDecision?: OrganizerEventCandidateDecision;
  localDecision?: AdminDecideOrganizerEventCandidateResponse;
  note: string;
  onDecision: (decision: OrganizerEventCandidateDecision) => void;
  onNoteChange: (note: string) => void;
}) {
  const generatedDecision = candidate.reviewDecision?.decision ?? null;
  const submittedDecision = localDecision?.decision ?? generatedDecision;
  const isDeciding = Boolean(inFlightDecision);

  return (
    <article className="search-candidate-card">
      <header className="search-candidate-header">
        <div>
          <div className="intake-eyebrow">
            {candidate.platform} / {candidate.reviewStatus}
          </div>
          <h3>{candidate.title}</h3>
        </div>
        <span className={`intake-badge ${candidate.reviewStatus === "approved_for_import" ? "ready" : ""}`}>
          {candidate.entityId}
        </span>
      </header>

      <div className="intake-state-grid">
        <StateRow label="Candidate" value={candidate.candidateId} />
        <StateRow label="Surface" value={candidate.surfaceId} />
        <StateRow label="Starts" value={candidate.startAt} />
        <StateRow label="Ends" value={candidate.endAt ?? "unknown"} />
        <StateRow label="Location" value={eventCandidateLocation(candidate)} />
        <StateRow label="Import" value={`${candidate.importReadiness} / ${candidate.importState}`} />
      </div>

      <div className="intake-tags">
        {candidate.blockers.map((blocker) => (
          <span className="intake-tag muted" key={blocker}>{blocker}</span>
        ))}
        {candidate.diagnostics.map((diagnostic) => (
          <span className="intake-tag muted" key={diagnostic}>{diagnostic}</span>
        ))}
      </div>

      {submittedDecision ? (
        <div className="intake-decision-state">
          <CheckCircle2 size={16} strokeWidth={1.9} />
          <div>
            <strong>{eventDecisionLabel(submittedDecision)}</strong>
            <span>
              {localDecision ?
                `${localDecision.decisionPath} / ${localDecision.importState}` :
                `Decision present in ${candidate.reviewDecision?.eventReviewBatchId}`}
            </span>
          </div>
        </div>
      ) : (
        <div className="intake-decision-box">
          <TextareaField
            label="Event review note"
            onChange={onNoteChange}
            rows={3}
            value={note}
          />
          <div className="intake-decision-actions">
            <button
              disabled={isDeciding}
              onClick={() => onDecision("approve_for_import")}
              type="button"
            >
              {inFlightDecision === "approve_for_import" ?
                "Approving" :
                "Approve future import"}
            </button>
            <button
              disabled={isDeciding}
              onClick={() => onDecision("hold")}
              type="button"
            >
              {inFlightDecision === "hold" ? "Holding" : "Hold"}
            </button>
            <button
              disabled={isDeciding}
              onClick={() => onDecision("reject")}
              type="button"
            >
              {inFlightDecision === "reject" ? "Rejecting" : "Reject"}
            </button>
          </div>
        </div>
      )}
    </article>
  );
}

function surfaceForCandidateCuration(
  candidate: OrganizerSearchCandidate
): OrganizerCurationSurface {
  return {
    ...candidate.suggestedSurface,
    evidenceRefs: [
      ...candidate.suggestedSurface.evidenceRefs,
      {
        type: "manualNote",
        ref: "admin/src/generated/organizerIntakeBridge.json",
        description:
          `Search candidate ${candidate.candidateId} observed ${candidate.observedAt}.`,
      },
    ],
    notes: appendSentence(
      candidate.suggestedSurface.notes,
      `Candidate title: ${candidate.title}`
    ),
  };
}

function appendSentence(value: string, sentence: string) {
  const base = value.trim();
  const next = sentence.trim();
  if (!base) return next;
  if (!next) return base;
  return `${base} ${next}`;
}

function OrganizerIntakeCard({
  curationForm,
  curationInFlight,
  curationResult,
  entityOptions,
  inFlightDecision,
  item,
  localDecision,
  manualReportsAcknowledged,
  note,
  onCurationFormChange,
  onCurationSubmit,
  onDecision,
  onManualReportsAcknowledgedChange,
  onNoteChange,
  publicationPacket,
}: {
  curationForm: OrganizerCurationFormState;
  curationInFlight: boolean;
  curationResult?: AdminRecordOrganizerCurationResponse;
  entityOptions: OrganizerIntakeItem[];
  inFlightDecision?: OrganizerIntakeDecision;
  item: OrganizerIntakeItem;
  localDecision?: AdminDecideOrganizerIntakeResponse;
  manualReportsAcknowledged: boolean;
  note: string;
  onCurationFormChange: (form: OrganizerCurationFormState) => void;
  onCurationSubmit: (form: OrganizerCurationFormState) => void;
  onDecision: (decision: OrganizerIntakeDecision) => void;
  onManualReportsAcknowledgedChange: (checked: boolean) => void;
  onNoteChange: (note: string) => void;
  publicationPacket?: OrganizerPublicationReviewPacket;
}) {
  const platformEntries = Object.entries(item.surfaceSummary.platforms)
    .sort(([left], [right]) => left.localeCompare(right));
  const commandEntries = [
    [
      "Approve public",
      publicationPacket?.adminDecision.command ?? item.decisionCommands.approvePublic,
    ],
    ["Hold", item.decisionCommands.hold],
    ["Suppress", item.decisionCommands.suppress],
  ];
  const generatedDecision = item.reviewDecision?.decision ?? null;
  const submittedDecision = localDecision?.decision ?? generatedDecision;
  const approvalReady = Object.values(
    intakeChecklistForDecision(item, "approve_public")
  ).every(Boolean) && publicationPacketReady(publicationPacket);
  const manualReportCount =
    publicationPacket?.evidenceSummary.manualReportsWithoutArtifacts ?? 0;
  const isDeciding = Boolean(inFlightDecision);

  return (
    <article className="intake-card">
      <header className="intake-card-header">
        <div>
          <div className="intake-eyebrow">
            {item.priority} / {item.taskType.replaceAll("_", " ")}
          </div>
          <h3>{item.displayName}</h3>
        </div>
        <div className="intake-badges">
          <span className={`intake-badge ${item.projectionStatus}`}>
            {item.projectionStatus}
          </span>
          <span className="intake-badge">{item.relationshipToCatch}</span>
        </div>
      </header>

      <div className="intake-state-grid">
        <StateRow label="Entity ID" value={item.entityId} />
        <StateRow label="Canonical" value={item.canonicalPath} />
        <StateRow label="Website" value={`${item.publishStatus} / ${item.indexStatus}`} />
        <StateRow label="App" value={item.appVisibility} />
      </div>

      {item.curation ? (
        <div className="intake-section curation-panel">
          <div className="intake-section-title">Curation</div>
          <div className="intake-tags">
            {item.curation.attachedSurfaces.map((surface) => (
              <span className="intake-tag" key={`attached-${surface.surfaceId}`}>
                attached {surface.surfaceId}
              </span>
            ))}
            {item.curation.mergedFrom.map((entityId) => (
              <span className="intake-tag" key={`merged-${entityId}`}>
                merged {entityId}
              </span>
            ))}
            {item.curation.mergedInto ? (
              <span className="intake-tag muted">
                merged into {item.curation.mergedInto}
              </span>
            ) : null}
            {item.curation.suppressed ? (
              <span className="intake-tag muted">
                suppressed
              </span>
            ) : null}
            {item.curation.surfaceDecisions.map((decision) => (
              <span className="intake-tag" key={`${decision.surfaceId}-${decision.decision}`}>
                {decision.surfaceId}: {decision.decision}
              </span>
            ))}
            {item.curation.splitSurfaces.map((split) => (
              <span className="intake-tag muted" key={`${split.surfaceId}-${split.newEntityId}`}>
                split {split.surfaceId} to {split.newEntityId}
              </span>
            ))}
          </div>
        </div>
      ) : null}

      <div className="intake-section">
        <div className="intake-section-title">Markets</div>
        <div className="intake-tags">
          {item.markets.map((market) => (
            <span className="intake-tag" key={market.marketSlug}>
              {market.displayName} / {market.eventFilter.citySlug}
            </span>
          ))}
          {item.legacyPaths.map((path) => (
            <span className="intake-tag muted" key={path}>{path}</span>
          ))}
        </div>
      </div>

      <div className="intake-section">
        <div className="intake-section-title">Surface Inventory</div>
        <div className="intake-surface-grid">
          <StateRow label="Active" value={String(item.surfaceSummary.active)} />
          <StateRow label="Candidate" value={String(item.surfaceSummary.candidate)} />
          <StateRow label="Ambiguous" value={String(item.surfaceSummary.ambiguous)} />
          <StateRow label="Rejected" value={String(item.surfaceSummary.rejected)} />
        </div>
        <div className="intake-tags">
          {platformEntries.map(([platform, count]) => (
            <span className="intake-tag" key={platform}>
              {platform} x{count}
            </span>
          ))}
        </div>
        <div className="surface-list">
          {item.surfaces.map((surface) => (
            <div className="surface-row" key={surface.surfaceId}>
              <div>
                <strong>{surface.surfaceId}</strong>
                <span>
                  {surface.platform} / {surface.surfaceKind} / {surface.status}
                </span>
              </div>
              <span>{surface.role}</span>
            </div>
          ))}
        </div>
      </div>

      <div className="intake-section">
        <div className="intake-section-title">Review Gates</div>
        <div className="intake-gate-list">
          {item.gates.map((gate) => (
            <div
              className={`intake-gate ${gate.passed ? "passed" : "blocked"}`}
              key={gate.id}
            >
              {gate.passed ? (
                <CheckCircle2 size={15} strokeWidth={1.9} />
              ) : (
                <FileWarning size={15} strokeWidth={1.9} />
              )}
              <div>
                <strong>{gate.id}</strong>
                <span>{gate.description}</span>
              </div>
            </div>
          ))}
        </div>
      </div>

      <OrganizerCurationControl
        form={curationForm}
        inFlight={curationInFlight}
        item={item}
        localCuration={curationResult}
        onChange={onCurationFormChange}
        onSubmit={onCurationSubmit}
        targetOptions={entityOptions}
      />

      <div className="intake-section">
        <div className="intake-section-title">Admin Decision</div>
        {publicationPacket ? (
          <div className={
            `quality-row ${publicationPacketReady(publicationPacket) ? "" : "warning"}`
          }>
            {publicationPacketReady(publicationPacket) ? (
              <CheckCircle2 size={16} strokeWidth={1.9} />
            ) : (
              <FileWarning size={16} strokeWidth={1.9} />
            )}
            <div>
              <strong>{publicationPacket.status.replaceAll("_", " ")}</strong>
              <span>
                {manualReportCount > 0 ?
                  `${manualReportCount} manual report(s) require reviewer acknowledgement.` :
                  publicationPacket.recommendedAction}
              </span>
            </div>
          </div>
        ) : (
          <div className="quality-row warning">
            <FileWarning size={16} strokeWidth={1.9} />
            <div>
              <strong>Publication packet missing</strong>
              <span>Regenerate organizer intake before public approval.</span>
            </div>
          </div>
        )}
        {submittedDecision ? (
          <div className="intake-decision-state">
            <CheckCircle2 size={16} strokeWidth={1.9} />
            <div>
              <strong>{decisionLabel(submittedDecision)}</strong>
              <span>
                {localDecision ?
                  `${localDecision.decisionPath} / ${localDecision.projectionState}` :
                  "Decision present in generated review state"}
              </span>
            </div>
          </div>
        ) : (
          <div className="intake-decision-box">
            <TextareaField
              label="Review note"
              onChange={onNoteChange}
              rows={3}
              value={note}
            />
            {manualReportCount > 0 ? (
              <label className="intake-checkbox-row">
                <input
                  checked={manualReportsAcknowledged}
                  disabled={isDeciding}
                  onChange={(event) =>
                    onManualReportsAcknowledgedChange(event.currentTarget.checked)}
                  type="checkbox"
                />
                <span>
                  Manual reports reviewed as prompts, not identity proof.
                </span>
              </label>
            ) : null}
            <div className="intake-decision-actions">
              <button
                disabled={
                  !approvalReady ||
                  isDeciding ||
                  (manualReportCount > 0 && !manualReportsAcknowledged)
                }
                onClick={() => onDecision("approve_public")}
                type="button"
              >
                {inFlightDecision === "approve_public" ?
                  "Approving" :
                  "Approve public"}
              </button>
              <button
                disabled={isDeciding}
                onClick={() => onDecision("hold")}
                type="button"
              >
                {inFlightDecision === "hold" ? "Holding" : "Hold"}
              </button>
              <button
                disabled={isDeciding}
                onClick={() => onDecision("suppress")}
                type="button"
              >
                {inFlightDecision === "suppress" ? "Suppressing" : "Suppress"}
              </button>
            </div>
          </div>
        )}
      </div>

      <div className="intake-section">
        <div className="intake-section-title">Decision Commands</div>
        <div className="command-stack">
          {commandEntries.map(([label, command]) => (
            <div className="command-row" key={label}>
              <span>{label}</span>
              <code>{command}</code>
            </div>
          ))}
        </div>
      </div>
    </article>
  );
}

function OrganizerCurationControl({
  form,
  inFlight,
  item,
  localCuration,
  onChange,
  onSubmit,
  targetOptions,
}: {
  form: OrganizerCurationFormState;
  inFlight: boolean;
  item: OrganizerIntakeItem;
  localCuration?: AdminRecordOrganizerCurationResponse;
  onChange: (form: OrganizerCurationFormState) => void;
  onSubmit: (form: OrganizerCurationFormState) => void;
  targetOptions: OrganizerIntakeItem[];
}) {
  const surfaceOptions = item.surfaces.length > 0 ?
    item.surfaces.map((surface) => surface.surfaceId) :
    [""];
  const targetEntityOptions = targetOptions
    .map((option) => option.entityId)
    .filter((entityId) => entityId !== item.entityId);
  const update = <K extends keyof OrganizerCurationFormState>(
    key: K,
    value: OrganizerCurationFormState[K]
  ) => {
    onChange({...form, [key]: value});
  };
  const selectedSurface = item.surfaces.find(
    (surface) => surface.surfaceId === form.surfaceId
  );
  const usesSurface = form.operationType === "surface_decision" ||
    form.operationType === "split_surface";

  return (
    <div className="intake-section curation-control">
      <div className="intake-section-title">Curation Operation</div>
      <div className="curation-control-grid">
        <SelectField
          label="Operation"
          onChange={(value) => update(
            "operationType",
            value as OrganizerCurationOperation
          )}
          options={organizerCurationOperations}
          value={form.operationType}
        />

        {form.operationType === "merge_entity" ? (
          <SelectField
            label="Merge into"
            onChange={(value) => update("targetEntityId", value)}
            options={["", ...targetEntityOptions]}
            value={form.targetEntityId}
          />
        ) : null}

        {usesSurface ? (
            <SelectField
              label="Surface"
              onChange={(value) => update("surfaceId", value)}
              options={surfaceOptions}
              value={form.surfaceId}
            />
          ) : null}

        {form.operationType === "surface_decision" ? (
          <SelectField
            label="Decision"
            onChange={(value) => update(
              "decision",
              value as OrganizerSurfaceDecision
            )}
            options={organizerSurfaceDecisions}
            value={form.decision}
          />
        ) : null}

        {form.operationType === "split_surface" ? (
          <TextField
            label="New entity id"
            onChange={(value) => update("newEntityId", value)}
            value={form.newEntityId}
          />
        ) : null}
      </div>

      {usesSurface && selectedSurface ? (
        <div className="surface-preview">
          <strong>{selectedSurface.platform} / {selectedSurface.surfaceKind}</strong>
          <span>{selectedSurface.url ?? "no URL captured"}</span>
          <span>{selectedSurface.notes}</span>
        </div>
      ) : null}

      <TextareaField
        label="Curation reason"
        onChange={(value) => update("reason", value)}
        rows={2}
        value={form.reason}
      />

      {localCuration ? (
        <div className="intake-decision-state">
          <CheckCircle2 size={16} strokeWidth={1.9} />
          <div>
            <strong>{localCuration.operationType.replaceAll("_", " ")}</strong>
            <span>{localCuration.decisionPath}</span>
          </div>
        </div>
      ) : null}

      <div className="intake-decision-actions">
        <button
          disabled={inFlight}
          onClick={() => onSubmit(form)}
          type="button"
        >
          {inFlight ? "Recording" : "Record curation"}
        </button>
      </div>
    </div>
  );
}

function defaultCurationForm(
  item: OrganizerIntakeItem
): OrganizerCurationFormState {
  return {
    operationType: item.surfaces.length > 0 ?
      "surface_decision" :
      "suppress_entity",
    targetEntityId: "",
    surfaceId: item.surfaces[0]?.surfaceId ?? "",
    newEntityId: "",
    decision: "reject_wrong_entity",
    reason: "",
  };
}

function curationFormKey(
  item: OrganizerIntakeItem,
  form: OrganizerCurationFormState
) {
  return [
    item.entityId,
    form.operationType,
    form.targetEntityId,
    form.surfaceId,
    form.decision,
    form.newEntityId,
  ].filter(Boolean).join(":");
}

function curationPayloadForItem(
  item: OrganizerIntakeItem,
  form: OrganizerCurationFormState
): {ok: true; value: AdminRecordOrganizerCurationPayload} |
  {ok: false; message: string} {
  const reason = form.reason.trim() || defaultCurationReason(item, form);
  if (form.operationType === "suppress_entity") {
    return {
      ok: true,
      value: {
        operationType: "suppress_entity",
        entityId: item.entityId,
        reason,
      },
    };
  }
  if (form.operationType === "merge_entity") {
    if (!form.targetEntityId) {
      return {ok: false, message: "Choose a target entity for merge."};
    }
    if (form.targetEntityId === item.entityId) {
      return {ok: false, message: "Choose a different merge target."};
    }
    return {
      ok: true,
      value: {
        operationType: "merge_entity",
        sourceEntityId: item.entityId,
        targetEntityId: form.targetEntityId,
        reason,
      },
    };
  }
  if (form.operationType === "surface_decision") {
    if (!form.surfaceId) {
      return {ok: false, message: "Choose a surface for this decision."};
    }
    return {
      ok: true,
      value: {
        operationType: "surface_decision",
        entityId: item.entityId,
        surfaceId: form.surfaceId,
        decision: form.decision,
        reason,
      },
    };
  }
  if (!form.surfaceId) {
    return {ok: false, message: "Choose a surface to split."};
  }
  if (!form.newEntityId.trim()) {
    return {ok: false, message: "Enter the new entity id for the split."};
  }
  return {
    ok: true,
    value: {
      operationType: "split_surface",
      entityId: item.entityId,
      surfaceId: form.surfaceId,
      newEntityId: form.newEntityId.trim(),
      reason,
    },
  };
}

function defaultCurationReason(
  item: OrganizerIntakeItem,
  form: OrganizerCurationFormState
) {
  if (form.operationType === "suppress_entity") {
    return `${item.displayName} is a false-positive organizer candidate.`;
  }
  if (form.operationType === "merge_entity") {
    return `${item.entityId} is the same organizer as ${form.targetEntityId}.`;
  }
  if (form.operationType === "surface_decision") {
    return `${form.surfaceId} is ${form.decision.replaceAll("_", " ")}.`;
  }
  return `${form.surfaceId} belongs to ${form.newEntityId}.`;
}

function intakeChecklistForDecision(
  item: OrganizerIntakeItem,
  decision: OrganizerIntakeDecision
) {
  const gatePassed = (id: string) =>
    item.gates.find((gate) => gate.id === id)?.passed === true;
  return {
    identityReviewed: gatePassed("identity_surface_present"),
    surfaceInventoryReviewed: gatePassed("surface_inventory_reviewable"),
    ownerSafeCopyReviewed: gatePassed("owner_safe_public_draft"),
    marketScopeReviewed: gatePassed("market_model_present"),
    mediaRightsReviewed: decision === "approve_public",
    crawlDisabledReviewed: gatePassed("crawl_disabled_by_default"),
  };
}

function publicationPacketReady(packet?: OrganizerPublicationReviewPacket) {
  if (!packet) return false;
  return packet.status === "ready_for_manual_publication_review" &&
    packet.dataBlockers.length === 0 &&
    packet.evidenceBlockers.length === 0 &&
    Object.values(packet.approvalChecklist).every(Boolean);
}

function defaultIntakeDecisionNote(
  item: OrganizerIntakeItem,
  decision: OrganizerIntakeDecision
) {
  if (decision === "approve_public") {
    return `Manual QA approved ${item.displayName} for public website projection.`;
  }
  if (decision === "hold") {
    return `Manual QA held ${item.displayName} for additional evidence.`;
  }
  return `Manual QA suppressed ${item.displayName} from public projection.`;
}

function eventCandidateChecklistForDecision(
  candidate: OrganizerExternalEventCandidate,
  decision: OrganizerEventCandidateDecision
) {
  if (decision === "approve_for_import") {
    return {
      identityReviewed: true,
      sourceEventReviewed: true,
      timeReviewed: true,
      locationReviewed: true,
      dedupeReviewed: true,
      ownerSafeCopyReviewed: true,
      importPolicyAcknowledged: true,
    };
  }
  return {
    identityReviewed: Boolean(candidate.entityId && candidate.surfaceId),
    sourceEventReviewed: Boolean(candidate.eventUrl),
    timeReviewed: Boolean(candidate.startAt),
    locationReviewed: Boolean(
      candidate.location.name ||
        candidate.location.address ||
        candidate.location.citySlug
    ),
    dedupeReviewed: false,
    ownerSafeCopyReviewed: false,
    importPolicyAcknowledged: true,
  };
}

function defaultEventCandidateDecisionNote(
  candidate: OrganizerExternalEventCandidate,
  decision: OrganizerEventCandidateDecision
) {
  if (decision === "approve_for_import") {
    return `Manual QA approved ${candidate.title} for future event import. Import writes remain disabled by policy.`;
  }
  if (decision === "hold") {
    return `Manual QA held ${candidate.title} for additional event evidence.`;
  }
  return `Manual QA rejected ${candidate.title} from external event import.`;
}

function policyGapChecklistForDecision(decision: OrganizerPolicyGapDecision) {
  if (decision === "accept") {
    return {
      requiredInputsReviewed: true,
      costAndSafetyReviewed: true,
      implementationOwnerReviewed: true,
      behaviorStillDisabledAcknowledged: true,
    };
  }
  return {
    requiredInputsReviewed: false,
    costAndSafetyReviewed: false,
    implementationOwnerReviewed: true,
    behaviorStillDisabledAcknowledged: true,
  };
}

function defaultPolicyGapDecisionNote(
  gap: OrganizerPolicyGap,
  decision: OrganizerPolicyGapDecision
) {
  if (decision === "accept") {
    return `Product policy accepted for ${gap.gapId}; behavior remains disabled until encoded in repo-backed policy.`;
  }
  if (decision === "hold") {
    return `Product policy held for ${gap.gapId}; required inputs remain unresolved.`;
  }
  return `Product policy rejected for ${gap.gapId}.`;
}

function locationResolutionFormFromTask(
  task: OrganizerExternalEventLocationResolutionTask
): OrganizerLocationResolutionFormState {
  return {
    name: task.sourceLocation.name ?? "",
    address: task.sourceLocation.address ?? "",
    placeId: task.sourceLocation.placeId ?? "",
    latitude: task.sourceLocation.latitude == null ?
      "" :
      String(task.sourceLocation.latitude),
    longitude: task.sourceLocation.longitude == null ?
      "" :
      String(task.sourceLocation.longitude),
    notes: "",
    note: `Manual location QA complete for ${task.title}.`,
  };
}

function nullableInput(value: string): string | null {
  const trimmed = value.trim();
  return trimmed ? trimmed : null;
}

function decisionLabel(decision: string) {
  if (decision === "approve_public") return "Approve public";
  return decision.charAt(0).toUpperCase() + decision.slice(1);
}

function eventDecisionLabel(decision: string) {
  if (decision === "approve_for_import") return "Approve future import";
  return decision.charAt(0).toUpperCase() + decision.slice(1);
}

function policyGapDecisionLabel(decision: string) {
  if (decision === "accept") return "Accepted policy";
  if (decision === "hold") return "Held policy";
  if (decision === "reject") return "Rejected policy";
  return decision.charAt(0).toUpperCase() + decision.slice(1);
}

function eventCandidateLocation(candidate: OrganizerExternalEventCandidate) {
  return [
    candidate.location.name,
    candidate.location.address,
    candidate.location.citySlug,
    candidate.location.countryCode,
  ].filter(Boolean).join(" / ") || "unknown";
}

function MetricTile({metric}: {metric: AdminOverviewMetric}) {
  const tone = metric.id.includes("failed") ||
    metric.id.includes("Reports") ||
    metric.id.includes("Applications") ?
    "attention" :
    "normal";
  return (
    <article className={`metric-tile ${tone}`}>
      <div className="metric-label">{metric.label}</div>
      <div className="metric-value">
        {metric.value.toLocaleString()}
        {metric.unit && <span>{metric.unit}</span>}
      </div>
    </article>
  );
}

function Panel({
  action,
  children,
  className = "",
  icon,
  title,
}: {
  action: string;
  children: ReactNode;
  className?: string;
  icon: ReactNode;
  title: string;
}) {
  return (
    <section className={`panel ${className}`}>
      <header className="panel-header">
        <div className="panel-title">
          {icon}
          <h2>{title}</h2>
        </div>
        <span>{action}</span>
      </header>
      {children}
    </section>
  );
}

function OrganizerDetailsScreen({
  club,
  clubId,
  form,
  isLoading,
  isSaving,
  onClubIdChange,
  onFormChange,
  onLoad,
  onSave,
}: {
  club: AdminClubDetails | null;
  clubId: string;
  form: OrganizerDetailsFormState | null;
  isLoading: boolean;
  isSaving: boolean;
  onClubIdChange: (clubId: string) => void;
  onFormChange: (form: OrganizerDetailsFormState | null) => void;
  onLoad: () => void;
  onSave: () => void;
}) {
  const update = <K extends keyof OrganizerDetailsFormState>(
    key: K,
    value: OrganizerDetailsFormState[K]
  ) => {
    if (!form) return;
    onFormChange({...form, [key]: value});
  };

  return (
    <section className="organizer-editor-grid">
      <Panel
        className="span-2 organizer-editor-panel"
        icon={<Settings2 size={18} strokeWidth={1.9} />}
        title="Organizer editor"
        action={club?.clubId ?? "No organizer loaded"}
      >
        <div className="organizer-loadbar">
          <label>
            <span>Document ID</span>
            <input
              aria-label="Organizer document id"
              onChange={(event) => onClubIdChange(event.target.value)}
              value={clubId}
            />
          </label>
          <button
            className="ghost-button"
            disabled={isLoading}
            onClick={onLoad}
            type="button"
          >
            <FolderSearch size={15} strokeWidth={1.9} />
            {isLoading ? "Loading" : "Load"}
          </button>
          <button
            className="primary-button"
            disabled={!form || isSaving}
            onClick={onSave}
            type="button"
          >
            <Save size={15} strokeWidth={1.9} />
            {isSaving ? "Saving" : "Save"}
          </button>
        </div>

        {form ? (
          <form className="organizer-form">
            <fieldset className="editor-section">
              <legend>Identity</legend>
              <div className="form-grid two">
                <TextField
                  label="Name"
                  onChange={(value) => update("name", value)}
                  value={form.name}
                />
                <SelectField
                  label="Entity"
                  onChange={(value) =>
                    update("entityKind", value as OrganizerEntityKind)}
                  options={[
                    "club",
                    "venue",
                    "eventOrganizer",
                    "creatorCommunity",
                    "brand",
                  ]}
                  value={form.entityKind}
                />
                <TextField
                  label="Display category"
                  onChange={(value) => update("displayCategory", value)}
                  value={form.displayCategory}
                />
                <TextField
                  label="Area"
                  onChange={(value) => update("area", value)}
                  value={form.area}
                />
              </div>
              <TextareaField
                label="Description"
                onChange={(value) => update("description", value)}
                rows={4}
                value={form.description}
              />
              <div className="form-grid two">
                <TextareaField
                  label="Tags"
                  onChange={(value) => update("tagsText", value)}
                  rows={4}
                  value={form.tagsText}
                />
                <TextareaField
                  label="Subtypes"
                  onChange={(value) => update("entitySubtypesText", value)}
                  rows={4}
                  value={form.entitySubtypesText}
                />
              </div>
            </fieldset>

            <fieldset className="editor-section">
              <legend>Location And Contact</legend>
              <div className="form-grid three">
                <TextField
                  label="Location slug"
                  onChange={(value) => update("location", value)}
                  value={form.location}
                />
                <TextField
                  label="City"
                  onChange={(value) => update("cityName", value)}
                  value={form.cityName}
                />
                <TextField
                  label="Region"
                  onChange={(value) => update("regionName", value)}
                  value={form.regionName}
                />
                <TextField
                  label="Country code"
                  onChange={(value) => update("countryCode", value)}
                  value={form.countryCode}
                />
                <TextField
                  label="Country"
                  onChange={(value) => update("countryName", value)}
                  value={form.countryName}
                />
                <SelectField
                  label="App visibility"
                  onChange={(value) =>
                    update("appVisibility", value as OrganizerAppVisibility)}
                  options={["hidden", "discoverable"]}
                  value={form.appVisibility}
                />
                <TextField
                  label="Instagram"
                  onChange={(value) => update("instagramHandle", value)}
                  value={form.instagramHandle}
                />
                <TextField
                  label="Email"
                  onChange={(value) => update("email", value)}
                  value={form.email}
                />
                <TextField
                  label="Phone"
                  onChange={(value) => update("phoneNumber", value)}
                  value={form.phoneNumber}
                />
              </div>
            </fieldset>

            <fieldset className="editor-section">
              <legend>Public Page</legend>
              <div className="form-grid two">
                <TextField
                  label="Slug"
                  onChange={(value) => update("publicPageSlug", value)}
                  value={form.publicPageSlug}
                />
                <TextField
                  label="Page city slug"
                  onChange={(value) => update("publicPageCitySlug", value)}
                  value={form.publicPageCitySlug}
                />
                <TextField
                  label="Canonical path"
                  onChange={(value) => update("canonicalPath", value)}
                  value={form.canonicalPath}
                />
                <SelectField
                  label="Publish status"
                  onChange={(value) =>
                    update("publishStatus", value as OrganizerPublishStatus)}
                  options={["draft", "qa", "published", "suppressed", "removed"]}
                  value={form.publishStatus}
                />
                <TextField
                  label="Image URL"
                  onChange={(value) => update("imageUrl", value)}
                  value={form.imageUrl}
                />
                <TextField
                  label="Logo URL"
                  onChange={(value) => update("profileImageUrl", value)}
                  value={form.profileImageUrl}
                />
                <TextField
                  label="SEO title"
                  onChange={(value) => update("seoTitle", value)}
                  value={form.seoTitle}
                />
                <TextField
                  label="SEO description"
                  onChange={(value) => update("seoDescription", value)}
                  value={form.seoDescription}
                />
              </div>
            </fieldset>

            <fieldset className="editor-section">
              <legend>Listing Copy</legend>
              <TextField
                label="Headline"
                onChange={(value) => update("headline", value)}
                value={form.headline}
              />
              <TextareaField
                label="Summary"
                onChange={(value) => update("summary", value)}
                rows={5}
                value={form.summary}
              />
              <TextareaField
                label="Source summary"
                onChange={(value) => update("sourceSummary", value)}
                rows={4}
                value={form.sourceSummary}
              />
              <div className="form-grid three">
                <TextareaField
                  label="Formats"
                  onChange={(value) => update("formatsText", value)}
                  rows={5}
                  value={form.formatsText}
                />
                <TextareaField
                  label="Fit notes"
                  onChange={(value) => update("fitNotesText", value)}
                  rows={5}
                  value={form.fitNotesText}
                />
                <TextareaField
                  label="Missing evidence"
                  onChange={(value) => update("missingEvidenceText", value)}
                  rows={5}
                  value={form.missingEvidenceText}
                />
              </div>
            </fieldset>

            <fieldset className="editor-section">
              <legend>Review State</legend>
              <div className="form-grid three">
                <SelectField
                  label="Source confidence"
                  onChange={(value) =>
                    update(
                      "sourceConfidence",
                      value as OrganizerSourceConfidence
                    )}
                  options={["seedOnly", "low", "medium", "high", "ownerVerified"]}
                  value={form.sourceConfidence}
                />
                <SelectField
                  label="Verification"
                  onChange={(value) =>
                    update(
                      "verificationStatus",
                      value as OrganizerVerificationStatus
                    )}
                  options={["unverified", "sourceBacked", "ownerVerified"]}
                  value={form.verificationStatus}
                />
                <TextField
                  label="Review note"
                  onChange={(value) => update("reviewNote", value)}
                  value={form.reviewNote}
                />
              </div>
            </fieldset>
          </form>
        ) : (
          <div className="empty-editor">
            <FolderSearch size={18} strokeWidth={1.9} />
            <span>Load an organizer document to review details.</span>
          </div>
        )}
      </Panel>

      <Panel
        icon={<Database size={18} strokeWidth={1.9} />}
        title="Current state"
        action={club?.publicPage.indexStatus ?? "No page"}
      >
        {club ? (
          <div className="organizer-state-list">
            <StateRow label="Claim" value={club.claimState} />
            <StateRow label="Ownership" value={club.ownershipState} />
            <StateRow label="Origin" value={club.provenance.origin} />
            <StateRow label="Index" value={club.publicPage.indexStatus} />
            <StateRow label="Robots" value={club.publicPage.robots} />
            <StateRow label="Canonical" value={club.publicPage.canonicalPath} />
          </div>
        ) : (
          <div className="empty-row">
            <Clock3 size={16} strokeWidth={1.9} />
            <span>No organizer loaded</span>
          </div>
        )}
      </Panel>
    </section>
  );
}

function TextField({
  label,
  onChange,
  value,
}: {
  label: string;
  onChange: (value: string) => void;
  value: string;
}) {
  return (
    <label className="field-control">
      <span>{label}</span>
      <input onChange={(event) => onChange(event.target.value)} value={value} />
    </label>
  );
}

function TextareaField({
  label,
  onChange,
  rows,
  value,
}: {
  label: string;
  onChange: (value: string) => void;
  rows: number;
  value: string;
}) {
  return (
    <label className="field-control">
      <span>{label}</span>
      <textarea
        onChange={(event) => onChange(event.target.value)}
        rows={rows}
        value={value}
      />
    </label>
  );
}

function SelectField({
  label,
  onChange,
  options,
  value,
}: {
  label: string;
  onChange: (value: string) => void;
  options: string[];
  value: string;
}) {
  return (
    <label className="field-control">
      <span>{label}</span>
      <select onChange={(event) => onChange(event.target.value)} value={value}>
        {options.map((option) => (
          <option key={option} value={option}>{option}</option>
        ))}
      </select>
    </label>
  );
}

function StateRow({
  label,
  value,
}: {
  label: string;
  value: string | null;
}) {
  return (
    <div className="state-row">
      <span>{label}</span>
      <strong>{value ?? "none"}</strong>
    </div>
  );
}

function QueueList({
  claimDecisionInFlight = {},
  decisionInFlight = {},
  indexDecisionInFlight = {},
  intent,
  items,
  onAccessDecision,
  onClubClaimDecision,
  onClubIndexDecision,
  title,
}: {
  claimDecisionInFlight?: Record<string, ClubClaimDecision>;
  decisionInFlight?: Record<string, AccessApplicationDecision>;
  indexDecisionInFlight?: Record<string, ClubIndexDecision>;
  intent: "danger" | "warning" | "neutral";
  items: AdminQueueItem[];
  onAccessDecision?: (
    item: AdminQueueItem,
    decision: AccessApplicationDecision
  ) => void;
  onClubClaimDecision?: (
    item: AdminQueueItem,
    decision: ClubClaimDecision
  ) => void;
  onClubIndexDecision?: (
    item: AdminQueueItem,
    decision: ClubIndexDecision
  ) => void;
  title: string;
}) {
  return (
    <div className="queue-list">
      <div className="queue-heading">
        <span>{title}</span>
        <strong>{items.length}</strong>
      </div>
      <div className="queue-items">
        {items.length === 0 ? (
          <div className="empty-row">
            <CheckCircle2 size={16} strokeWidth={1.9} />
            <span>Clear</span>
          </div>
        ) : (
          items.slice(0, 3).map((item) => (
            <QueueRow
              claimDecisionInFlight={claimDecisionInFlight[item.targetPath]}
              decisionInFlight={decisionInFlight[item.targetPath]}
              indexDecisionInFlight={indexDecisionInFlight[item.targetPath]}
              intent={intent}
              item={item}
              key={item.id}
              onAccessDecision={onAccessDecision}
              onClubClaimDecision={onClubClaimDecision}
              onClubIndexDecision={onClubIndexDecision}
            />
          ))
        )}
      </div>
    </div>
  );
}

function QueueRow({
  claimDecisionInFlight,
  decisionInFlight,
  indexDecisionInFlight,
  intent,
  item,
  onAccessDecision,
  onClubClaimDecision,
  onClubIndexDecision,
}: {
  claimDecisionInFlight?: ClubClaimDecision;
  decisionInFlight?: AccessApplicationDecision;
  indexDecisionInFlight?: ClubIndexDecision;
  intent: "danger" | "warning" | "neutral";
  item: AdminQueueItem;
  onAccessDecision?: (
    item: AdminQueueItem,
    decision: AccessApplicationDecision
  ) => void;
  onClubClaimDecision?: (
    item: AdminQueueItem,
    decision: ClubClaimDecision
  ) => void;
  onClubIndexDecision?: (
    item: AdminQueueItem,
    decision: ClubIndexDecision
  ) => void;
}) {
  const isDeciding = Boolean(
    decisionInFlight ||
    claimDecisionInFlight ||
    indexDecisionInFlight
  );
  return (
    <article className={`queue-row ${intent}`}>
      <div>
        <h3>{item.title}</h3>
        <p>{item.detail}</p>
      </div>
      <div className="queue-row-actions">
        <span>{relativeTime(item.createdAt)}</span>
        {intent === "warning" && onAccessDecision && (
          <div className="decision-actions">
            <button
              disabled={isDeciding}
              onClick={() => onAccessDecision(item, "approve")}
              type="button"
            >
              {decisionInFlight === "approve" ? "Approving" : "Approve"}
            </button>
            <button
              disabled={isDeciding}
              onClick={() => onAccessDecision(item, "deny")}
              type="button"
            >
              {decisionInFlight === "deny" ? "Denying" : "Deny"}
            </button>
          </div>
        )}
        {onClubClaimDecision && (
          <div className="decision-actions">
            <button
              disabled={isDeciding}
              onClick={() => onClubClaimDecision(item, "approve")}
              type="button"
            >
              {claimDecisionInFlight === "approve" ? "Approving" : "Approve"}
            </button>
            <button
              disabled={isDeciding}
              onClick={() => onClubClaimDecision(item, "reject")}
              type="button"
            >
              {claimDecisionInFlight === "reject" ? "Rejecting" : "Reject"}
            </button>
          </div>
        )}
        {onClubIndexDecision && (
          <div className="decision-actions">
            <button
              disabled={isDeciding}
              onClick={() => onClubIndexDecision(item, "indexReady")}
              type="button"
            >
              {indexDecisionInFlight === "indexReady" ?
                "Marking" :
                "Index ready"}
            </button>
            <button
              disabled={isDeciding}
              onClick={() => onClubIndexDecision(item, "noindex")}
              type="button"
            >
              {indexDecisionInFlight === "noindex" ?
                "Keeping" :
                "Keep noindex"}
            </button>
          </div>
        )}
      </div>
    </article>
  );
}

function LineMiniChart({points}: {points: Array<{label: string; value: number}>}) {
  if (points.length === 0) {
    return <div className="empty-panel">No trend data yet.</div>;
  }
  const path = points.map((point, index) => {
    const x = points.length === 1 ? 50 : (index / (points.length - 1)) * 100;
    const y = 100 - point.value;
    return `${index === 0 ? "M" : "L"} ${x.toFixed(2)} ${y.toFixed(2)}`;
  }).join(" ");
  return (
    <div className="line-chart">
      <svg viewBox="0 0 100 100" preserveAspectRatio="none" aria-hidden="true">
        <path className="line-area" d={`${path} L 100 100 L 0 100 Z`} />
        <path className="line-stroke" d={path} />
      </svg>
      <div className="chart-labels">
        {points.map((point) => (
          <span key={point.label}>{point.label}</span>
        ))}
      </div>
    </div>
  );
}

function BarMiniChart({points}: {points: Array<{label: string; value: number}>}) {
  if (points.length === 0) {
    return <div className="empty-panel">No trend data yet.</div>;
  }
  const max = Math.max(1, ...points.map((point) => point.value));
  return (
    <div className="bar-chart">
      {points.map((point) => (
        <div className="bar-column" key={point.label}>
          <div
            className="bar"
            style={{height: `${Math.max(8, (point.value / max) * 100)}%`}}
          />
          <span>{point.label}</span>
        </div>
      ))}
    </div>
  );
}

function analyticsRangePreset(
  activeRange: string
): "7d" | "30d" | "90d" | "month" {
  if (activeRange === "30d") return "30d";
  return "7d";
}

function analyticsTrendPoints(
  analytics: HostAnalyticsResponse,
  metric: string
): Array<{label: string; value: number}> {
  return analytics.trend.map((point) => ({
    label: shortPeriodLabel(point.periodStart),
    value: Math.round(point.metrics[metric] ?? 0),
  }));
}

function analyticsRatePoints(
  analytics: HostAnalyticsResponse
): Array<{label: string; value: number}> {
  return analytics.trend.map((point) => {
    const bookings = point.metrics.bookings ?? 0;
    const checkedIn = point.metrics.checkedIn ?? 0;
    return {
      label: shortPeriodLabel(point.periodStart),
      value: bookings <= 0 ? 0 : Math.round((checkedIn / bookings) * 100),
    };
  });
}

function analyticsMetricAction(
  analytics: HostAnalyticsResponse,
  metricId: string
): string {
  const metric = analytics.summaryCards.find((card) => card.id === metricId);
  if (!metric) return "n/a";
  if (metric.unit === "percent") return `${Math.round(metric.value)}%`;
  if (metric.unit === "money_minor") {
    return formatMinorCurrency(metric.value, "INR");
  }
  return String(Math.round(metric.value));
}

function shortPeriodLabel(value: string): string {
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return "n/a";
  return date.toLocaleDateString(undefined, {
    month: "short",
    day: "numeric",
  });
}

function formatMinorCurrency(value: number, currency: string): string {
  return new Intl.NumberFormat(undefined, {
    style: "currency",
    currency,
    maximumFractionDigits: 0,
  }).format(value / 100);
}

function eventRisk(row: HostAnalyticsEventRow): "low" | "medium" | "high" {
  if (
    row.paymentFailedCount > 2 ||
    row.checkoutDropoffCount > 5 ||
    row.checkInRate < 55
  ) return "high";
  if (
    row.paymentFailedCount > 0 ||
    row.checkoutDropoffCount > 0 ||
    row.checkInRate < 70
  ) return "medium";
  return "low";
}

function EventPerformanceTable({
  events,
  onFocusEvent,
}: {
  events: HostAnalyticsEventRow[];
  onFocusEvent: (eventId: string) => void;
}) {
  return (
    <div className="table-wrap">
      <table>
        <thead>
          <tr>
            <th>Event</th>
            <th>Club</th>
            <th>Fill</th>
            <th>Check-in</th>
            <th>Rating</th>
            <th>Checkout</th>
            <th>GMV</th>
            <th>Risk</th>
            <th>Scope</th>
          </tr>
        </thead>
        <tbody>
          {events.map((row) => (
            <tr key={row.eventId}>
              <td>{row.title}</td>
              <td>{row.clubId}</td>
              <td>{Math.round(row.fillRate)}%</td>
              <td>{Math.round(row.checkInRate)}%</td>
              <td>{row.averageRating > 0 ? row.averageRating.toFixed(1) : "n/a"}</td>
              <td>
                {row.checkoutStartedCount
                  ? `${row.checkoutDropoffCount}/${row.checkoutStartedCount} drop`
                  : "n/a"}
              </td>
              <td>{formatMinorCurrency(row.grossRevenueMinor, row.currency)}</td>
              <td>
                <span className={`risk ${eventRisk(row)}`}>
                  {eventRisk(row)}
                </span>
              </td>
              <td>
                <button
                  className="table-action"
                  onClick={() => onFocusEvent(row.eventId)}
                  type="button"
                >
                  Focus
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

function ValueSignals() {
  const signals = [
    {label: "Spend", value: 72, color: "green"},
    {label: "Referrals", value: 46, color: "teal"},
    {label: "Attendance", value: 64, color: "orange"},
    {label: "Match quality", value: 58, color: "red"},
  ];
  return (
    <div className="signals">
      {signals.map((signal) => (
        <div className="signal-row" key={signal.label}>
          <div>
            <span>{signal.label}</span>
            <strong>{signal.value}</strong>
          </div>
          <div className="signal-track">
            <div
              className={`signal-fill ${signal.color}`}
              style={{width: `${signal.value}%`}}
            />
          </div>
        </div>
      ))}
    </div>
  );
}

function DataQualityRows({
  hostAnalytics,
  overview,
}: {
  hostAnalytics: HostAnalyticsResponse;
  overview: AdminOverviewResponse;
}) {
  return (
    <div className="quality-list">
      {overview.dataQuality.map((item) => (
        <div className={`quality-row ${item.state}`} key={item.id}>
          {item.state === "blocked" ? (
            <FileWarning size={16} strokeWidth={1.9} />
          ) : (
            <Clock3 size={16} strokeWidth={1.9} />
          )}
          <div>
            <strong>{item.label}</strong>
            <span>{item.detail}</span>
          </div>
        </div>
      ))}
      {hostAnalytics.dataQuality.map((item) => (
        <div className={`quality-row ${item.state}`} key={`analytics-${item.id}`}>
          {item.state === "missing" ? (
            <FileWarning size={16} strokeWidth={1.9} />
          ) : (
            <Clock3 size={16} strokeWidth={1.9} />
          )}
          <div>
            <strong>Analytics · {item.id}</strong>
            <span>{item.detail}</span>
          </div>
        </div>
      ))}
    </div>
  );
}

function queueCount(overview: AdminOverviewResponse) {
  return Object.values(overview.queues)
    .reduce((sum, items) => sum + items.length, 0);
}

function applicationUidFromTargetPath(targetPath: string): string | null {
  const [collection, uid, extra] = targetPath.split("/");
  if (collection !== "accessApplications" || !uid || extra) return null;
  return uid;
}

function clubClaimRequestIdFromTargetPath(targetPath: string): string | null {
  const [collection, requestId, extra] = targetPath.split("/");
  if (collection !== "clubClaimRequests" || !requestId || extra) return null;
  return requestId;
}

function clubIdFromTargetPath(targetPath: string): string | null {
  const [collection, clubId, extra] = targetPath.split("/");
  if (collection !== "clubs" || !clubId || extra) return null;
  return clubId;
}

function completeIndexChecklist() {
  return {
    sourceEvidenceVerified: true,
    mediaRightsVerified: true,
    cadenceVerified: true,
    ownerContactVerified: true,
  };
}

function emptyIndexChecklist() {
  return {
    sourceEvidenceVerified: false,
    mediaRightsVerified: false,
    cadenceVerified: false,
    ownerContactVerified: false,
  };
}

function removeAccessApplication(
  overview: AdminOverviewResponse,
  targetPath: string
): AdminOverviewResponse {
  const applications = overview.queues.accessApplications.filter(
    (item) => item.targetPath !== targetPath
  );
  const removed = applications.length !==
    overview.queues.accessApplications.length;
  return {
    ...overview,
    metrics: overview.metrics.map((metric) => {
      if (metric.id !== "pendingApplications" || !removed) return metric;
      return {...metric, value: Math.max(0, metric.value - 1)};
    }),
    queues: {
      ...overview.queues,
      accessApplications: applications,
    },
  };
}

function removeClubClaimRequest(
  overview: AdminOverviewResponse,
  targetPath: string
): AdminOverviewResponse {
  const claimRequests = overview.queues.clubClaimRequests.filter(
    (item) => item.targetPath !== targetPath
  );
  const removed = claimRequests.length !==
    overview.queues.clubClaimRequests.length;
  return {
    ...overview,
    metrics: overview.metrics.map((metric) => {
      if (metric.id !== "pendingClubClaims" || !removed) return metric;
      return {...metric, value: Math.max(0, metric.value - 1)};
    }),
    queues: {
      ...overview.queues,
      clubClaimRequests: claimRequests,
    },
  };
}

function removeClubIndexReview(
  overview: AdminOverviewResponse,
  targetPath: string
): AdminOverviewResponse {
  const indexReviews = overview.queues.clubIndexReviews.filter(
    (item) => item.targetPath !== targetPath
  );
  const removed = indexReviews.length !== overview.queues.clubIndexReviews.length;
  return {
    ...overview,
    metrics: overview.metrics.map((metric) => {
      if (metric.id !== "indexReviewPages" || !removed) return metric;
      return {...metric, value: Math.max(0, metric.value - 1)};
    }),
    queues: {
      ...overview.queues,
      clubIndexReviews: indexReviews,
    },
  };
}

function formFromClubDetails(
  club: AdminClubDetails
): OrganizerDetailsFormState {
  return {
    clubId: club.clubId,
    name: club.name,
    description: club.description,
    location: club.location ?? "",
    area: club.area,
    tagsText: listToText(club.tags),
    instagramHandle: club.instagramHandle ?? "",
    phoneNumber: club.phoneNumber ?? "",
    email: club.email ?? "",
    imageUrl: club.imageUrl ?? "",
    profileImageUrl: club.profileImageUrl ?? "",
    entityKind: club.entityKind ?? "club",
    entitySubtypesText: listToText(club.entitySubtypes),
    displayCategory: club.displayCategory ?? "",
    cityName: club.cityName ?? "",
    regionName: club.regionName ?? "",
    countryCode: club.countryCode ?? "",
    countryName: club.countryName ?? "",
    appVisibility: club.appVisibility ?? "hidden",
    publicPageSlug: club.publicPage.slug ?? "",
    publicPageCitySlug: club.publicPage.citySlug ?? "",
    canonicalPath: club.publicPage.canonicalPath ?? "",
    publishStatus: club.publicPage.publishStatus ?? "qa",
    seoTitle: club.publicPage.seoTitle ?? "",
    seoDescription: club.publicPage.seoDescription ?? "",
    sourceConfidence: club.provenance.sourceConfidence ?? "seedOnly",
    verificationStatus: club.provenance.verificationStatus ?? "unverified",
    headline: club.publicProfile.headline ?? "",
    summary: club.publicProfile.summary ?? "",
    sourceSummary: club.publicProfile.sourceSummary ?? "",
    formatsText: listToText(club.publicProfile.formats),
    fitNotesText: listToText(club.publicProfile.fitNotes),
    missingEvidenceText: listToText(club.publicProfile.missingEvidence),
    reviewNote: "",
  };
}

function payloadFromOrganizerDetailsForm(
  form: OrganizerDetailsFormState
): AdminUpdateClubDetailsPayload {
  return {
    clubId: form.clubId.trim(),
    reviewNote: nullableText(form.reviewNote),
    fields: {
      name: form.name,
      description: form.description,
      location: nullableText(form.location),
      area: form.area,
      tags: textToList(form.tagsText),
      instagramHandle: nullableText(form.instagramHandle),
      phoneNumber: nullableText(form.phoneNumber),
      email: nullableText(form.email),
      imageUrl: nullableText(form.imageUrl),
      profileImageUrl: nullableText(form.profileImageUrl),
      entityKind: form.entityKind,
      entitySubtypes: textToList(form.entitySubtypesText),
      displayCategory: nullableText(form.displayCategory),
      cityName: nullableText(form.cityName),
      regionName: nullableText(form.regionName),
      countryCode: nullableText(form.countryCode),
      countryName: nullableText(form.countryName),
      appVisibility: form.appVisibility,
      publicPage: {
        slug: form.publicPageSlug,
        citySlug: nullableText(form.publicPageCitySlug),
        canonicalPath: form.canonicalPath,
        publishStatus: form.publishStatus,
        seoTitle: nullableText(form.seoTitle),
        seoDescription: nullableText(form.seoDescription),
      },
      provenance: {
        sourceConfidence: form.sourceConfidence,
        verificationStatus: form.verificationStatus,
      },
      publicProfile: {
        headline: nullableText(form.headline),
        summary: nullableText(form.summary),
        sourceSummary: nullableText(form.sourceSummary),
        formats: textToList(form.formatsText),
        fitNotes: textToList(form.fitNotesText),
        missingEvidence: textToList(form.missingEvidenceText),
      },
    },
  };
}

function listToText(items: string[]): string {
  return items.join("\n");
}

function textToList(value: string): string[] {
  return Array.from(new Set(
    value
      .split("\n")
      .map((item) => item.trim())
      .filter((item) => item.length > 0)
  ));
}

function nullableText(value: string): string | null {
  const trimmed = value.trim();
  return trimmed.length === 0 ? null : trimmed;
}

function relativeTime(value: string | null) {
  if (!value) return "queued";
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return "queued";
  const diffMinutes = Math.max(
    1,
    Math.round((Date.now() - date.getTime()) / 60000)
  );
  if (diffMinutes < 60) return `${diffMinutes}m`;
  const diffHours = Math.round(diffMinutes / 60);
  if (diffHours < 24) return `${diffHours}h`;
  return `${Math.round(diffHours / 24)}d`;
}
