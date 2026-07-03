import type {Meta, StoryObj} from "@storybook/react-vite";
import {
  initialOverviewHostAnalytics,
  initialOverviewSnapshot,
} from "../features/overview/api/overviewRepository";
import type {
  AccessReviewController,
  AccessReviewFormState,
} from "../features/access/controllers/useAccessReviewController";
import {AccessReviewWorkspace} from "../features/access/ui/AccessReviewScreen";
import {
  buildAdminRoleScopeContract,
  type AdminRoleAssignmentStatusFilter,
  type AdminRoleManagementController,
} from "../features/admin-roles/controllers/useAdminRoleManagementController";
import {AdminRoleManagementWorkspace} from "../features/admin-roles/ui/AdminRoleManagementScreen";
import type {
  DataQualityController,
  DataQualityRow,
  DataQualityStateFilter,
} from "../features/data-quality/controllers/useDataQualityController";
import {DataQualityWorkspace} from "../features/data-quality/ui/DataQualityScreen";
import {
  sampleEventDetails,
  sampleExternalEventRows,
  sampleClubDetails,
  sampleUserAnalyticsReport,
} from "../shared/api/sampleData";
import type {EventPublishingController} from "../features/events/controllers/useEventPublishingController";
import {
  buildExternalEventImportReview,
  formFromEventProfile,
} from "../features/events/controllers/eventPublishingHelpers";
import {EventPublishingWorkspace} from "../features/events/ui/EventPublishingScreen";
import eventIntakeBridgeFixture from "../generated/eventIntakeBridge.json";
import type {EventIntakeController} from "../features/intake/events/controllers/useEventIntakeController";
import {EventIntakePreviewWorkspace} from "../features/intake/events/ui/EventIntakeWorkspace";
import organizerIntakeBridgeFixture from "../features/intake/organizer/generated/organizerIntakeBridge.json";
import type {OrganizerIntakeController} from "../features/intake/organizer/controllers/useOrganizerIntakeController";
import {OrganizerIntakeWorkspace} from "../features/intake/organizer/ui/OrganizerIntakeScreen";
import {IntakeWorkspace} from "../features/intake/ui/IntakeWorkspaceScreen";
import {
  buildFinanceIssueReview,
  type FinanceIssueKind,
  type FinanceIssueRow,
  type FinanceOpsController,
} from "../features/finance/controllers/useFinanceOpsController";
import {FinanceOpsWorkspace} from "../features/finance/ui/FinanceOpsScreen";
import marketingOpsBridgeFixture from "../generated/marketingOpsBridge.json";
import type {MarketingOpsController} from "../features/marketing/controllers/useMarketingOpsController";
import {MarketingOpsWorkspace} from "../features/marketing/ui/MarketingOpsScreen";
import {
  filterOrganizerRows,
  type OrganizerPublishingController,
} from "../features/organizers/controllers/useOrganizerPublishingController";
import {
  diffOrganizerProfile,
  emptyPublishChecklist,
  formFromOrganizerProfile,
  validateOrganizerPublishingForm,
} from "../features/organizers/controllers/organizerPublishingHelpers";
import {OrganizerPublishingWorkspace} from "../features/organizers/ui/OrganizerPublishingScreen";
import type {
  GrowthKpiController,
  GrowthRangePreset,
  GrowthSignalRow,
  GrowthStage,
} from "../features/growth/controllers/useGrowthKpiController";
import {GrowthKpiWorkspace} from "../features/growth/ui/GrowthKpiScreen";
import {
  type OverviewAnalyticsGranularity,
  type OverviewAnalyticsRangePreset,
  OverviewScreen,
} from "../features/overview/ui/OverviewScreen";
import type {SafetyTriageController} from "../features/safety/controllers/useSafetyTriageController";
import {SafetyTriageWorkspace} from "../features/safety/ui/SafetyTriageScreen";
import {
  type AccessApplicationDecision,
  type AdminClubDetails,
  type AdminClubListRow,
  type AdminEventDetails,
  type AdminEventListRow,
  type AdminAccessApplicationDetails,
  type AdminExternalEventListRow,
  type AdminGetEventSupplyReadinessResponse,
  type AdminQueueItem,
  type EventIntakeBridge,
  type EventIntakeCandidate,
  type EventIntakeSourceProfile,
  type EventIntakeSourceResult,
  adminRoleClaimKeys,
  type AdminRoleAssignmentRow,
  type AdminRoleClaim,
  type AdminUserRoleRecord,
  type ExternalEventImportAction,
  type HostAnalyticsTrendPoint,
  type UserAnalyticsGranularity,
  type UserAnalyticsQueryPayload,
  type UserAnalyticsRangePreset,
} from "../shared/types/adminTypes";
import {
  buildUserLookupContract,
  type UserAnalyticsController,
} from "../features/users/controllers/useUserAnalyticsController";
import {UserAnalyticsWorkspace} from "../features/users/ui/UserAnalyticsScreen";
import {AdminWorkspace} from "../shared/ui/AdminPrimitives";

const overview = initialOverviewSnapshot();
const hostAnalytics = initialOverviewHostAnalytics();
const eventRows: AdminEventListRow[] =
  Object.values(sampleEventDetails).map(eventListRowFromDetails);
const externalEventRows = sampleExternalEventRows;
const selectedExternalEvent = externalEventRows[1] ?? externalEventRows[0] ?? null;
const eventSupplyReadiness = buildEventSupplyReadiness(
  selectedExternalEvent,
  "2026-07-03T09:58:00.000Z"
);
const eventController: EventPublishingController = {
  backToList: () => {
    noop();
  },
  diffRows: [],
  event: sampleEventDetails["mumbai-padel-mixer-1"] ?? null,
  eventId: "mumbai-padel-mixer-1",
  externalFilter: "reviewOpen",
  externalListGeneratedAt: "2026-07-03T09:58:00.000Z",
  externalQuery: "",
  externalRows: externalEventRows,
  filter: "launchCities",
  filteredExternalRows: externalEventRows,
  filteredRows: eventRows,
  form: sampleEventDetails["mumbai-padel-mixer-1"] ?
    formFromEventProfile(sampleEventDetails["mumbai-padel-mixer-1"]) :
    null,
  isDetailLoading: false,
  isExternalListLoading: false,
  isListLoading: false,
  isSaving: false,
  isSupplyReadinessLoading: false,
  listGeneratedAt: "2026-07-03T09:55:00.000Z",
  openExternalSupply: () => {
    noop();
  },
  publishExternalEvent: async (_request) => {
    noop();
    return false;
  },
  publishingExternalActionId: null,
  query: "",
  refreshExternalList: async () => {
    noop();
    return true;
  },
  refreshList: async () => {
    noop();
    return true;
  },
  refreshSupplyReadiness: async () => {
    noop();
    return true;
  },
  rows: eventRows,
  save: async () => {
    noop();
    return true;
  },
  selectEvent: (_eventId) => {
    noop();
  },
  selectExternalEvent: (_value) => {
    noop();
  },
  selectedExternalEvent,
  selectedExternalEventId: selectedExternalEvent?.eventId ?? null,
  selectedExternalImportReview: buildExternalEventImportReview(
    selectedExternalEvent,
    eventSupplyReadiness.importPlan,
    eventSupplyReadiness.executionPlan
  ),
  setEventId: (_value) => {
    noop();
  },
  setExternalFilter: (_value) => {
    noop();
  },
  setExternalQuery: (_value) => {
    noop();
  },
  setFilter: (_value) => {
    noop();
  },
  setForm: (_value) => {
    noop();
  },
  setQuery: (_value) => {
    noop();
  },
  supplyReadiness: eventSupplyReadiness,
  validationIssues: [],
  view: "list",
};
const eventIntakeBridge =
  eventIntakeBridgeFixture as unknown as EventIntakeBridge;
const eventIntakeController: EventIntakeController = {
  activeTab: "setup",
  bridge: eventIntakeBridge,
  inFlight: {},
  isLoading: false,
  loadBridge: async () => {
    noop();
    return true;
  },
  localDecisions: {},
  notes: {},
  setActiveTab: (_value) => {
    noop();
  },
  setNote: (_key: string, _value: string) => {
    noop();
  },
  sourceResultById: new Map(
    eventIntakeBridge.sourceResults.map((result) => [result.id, result])
  ),
  targetDecision: async (_input) => {
    noop();
  },
  updateCandidate: (
    _candidateId: string,
    _patch: Partial<EventIntakeCandidate>
  ) => {
    noop();
  },
  updateSource: (
    _sourceId: string,
    _patch: Partial<EventIntakeSourceProfile>
  ) => {
    noop();
  },
  updateSourceResult: (
    _resultId: string,
    _patch: Partial<EventIntakeSourceResult>
  ) => {
    noop();
  },
};
const organizerIntakeBridge =
  organizerIntakeBridgeFixture as unknown as OrganizerIntakeController["bridge"];
const organizerIntakeController: OrganizerIntakeController = {
  bridge: organizerIntakeBridge,
  curationForms: {},
  curationInFlight: {},
  decisionInFlight: {},
  decisionNotes: {},
  eventDecisionInFlight: {},
  eventDecisionNotes: {},
  handleAttachCandidate: async (_candidate) => {
    noop();
  },
  handleDecision: async (_item, _decision) => {
    noop();
  },
  handleEventDecision: async (_candidate, _decision) => {
    noop();
  },
  handleItemCuration: async (_item, _form) => {
    noop();
  },
  handleLocationResolution: async (_task) => {
    noop();
  },
  handlePendingInputDecision: async (_input, _decision) => {
    noop();
  },
  handlePolicyGapDecision: async (_gap, _decision) => {
    noop();
  },
  localCuration: {},
  localDecisions: {},
  localEventDecisions: {},
  localLocationResolutions: {},
  localPolicyDecisions: {},
  locationResolutionForms: {},
  locationResolutionInFlight: {},
  manualReportAcknowledgements: {},
  metrics: [
    {
      label: "Host entities",
      value: organizerIntakeBridge.summary.canonicalHostEntities ?? 0,
    },
    {
      label: "Review packets",
      value: organizerIntakeBridge.summary.publicationReviewPackets ?? 0,
    },
    {
      label: "Would publish",
      value: organizerIntakeBridge.summary.publicationImpactWouldPublish ?? 0,
    },
    {
      label: "Review items",
      value: organizerIntakeBridge.summary.reviewItems,
    },
    {
      label: "Policy gaps",
      value: organizerIntakeBridge.summary.policyGapsDecisionRequired ?? 0,
    },
    {
      label: "Event candidates",
      value: organizerIntakeBridge.summary.externalEventCandidates ?? 0,
    },
  ],
  policyDecisionInFlight: {},
  policyDecisionNotes: {},
  publicationPacketByEntity: new Map(
    organizerIntakeBridge.publicationReviewPackets.packets.map((packet) => [
      packet.entityId,
      packet,
    ])
  ),
  setCurationForms: (_value) => {
    noop();
  },
  setDecisionNotes: (_value) => {
    noop();
  },
  setEventDecisionNotes: (_value) => {
    noop();
  },
  setLocationResolutionForms: (_value) => {
    noop();
  },
  setManualReportAcknowledgements: (_value) => {
    noop();
  },
  setPolicyDecisionNotes: (_value) => {
    noop();
  },
};
const marketingOpsBridge =
  marketingOpsBridgeFixture as unknown as MarketingOpsController["bridge"];
const marketingOpsSelectedDraft =
  marketingOpsBridge?.contentDrafts[0] ?? null;
const marketingOpsController: MarketingOpsController = {
  activeTab: "posts",
  bridge: marketingOpsBridge,
  composerStep: 0,
  createDraft: async (_draftType) => {
    noop();
  },
  inFlight: {},
  isLoading: false,
  loadBridge: async () => {
    noop();
    return true;
  },
  localDecisions: {},
  notes: {},
  selectedDraft: marketingOpsSelectedDraft,
  selectedDraftId: marketingOpsSelectedDraft?.id ?? null,
  setActiveTab: (_value) => {
    noop();
  },
  setComposerStep: (_value) => {
    noop();
  },
  setNote: (_key: string, _value: string) => {
    noop();
  },
  setSelectedDraftId: (_value) => {
    noop();
  },
  setTypeFilter: (_value) => {
    noop();
  },
  targetDecision: async (_input) => {
    noop();
  },
  typeFilter: "all",
  updateDraft: (_draftId, _patch) => {
    noop();
  },
  updateDraftSlide: (_draftId, _slideId, _patch) => {
    noop();
  },
  updateRecommendationItem: (_setId, _itemId, _patch) => {
    noop();
  },
};
const organizerPublishingRows: AdminClubListRow[] =
  Object.values(sampleClubDetails).map(organizerListRowFromDetails);
const organizerPublishingClub = sampleClubDetails.afterfly ?? null;
const organizerPublishingForm = organizerPublishingClub ?
  formFromOrganizerProfile(organizerPublishingClub) :
  null;
const organizerPublishingDiffRows = diffOrganizerProfile(
  organizerPublishingClub,
  organizerPublishingForm
);
const organizerPublishingController: OrganizerPublishingController = {
  backToList: () => {
    noop();
  },
  checklist: emptyPublishChecklist,
  club: organizerPublishingClub,
  clubId: organizerPublishingClub?.clubId ?? "",
  completeChecklist: false,
  diffRows: organizerPublishingDiffRows,
  filter: "launchCities",
  filteredRows: filterOrganizerRows(organizerPublishingRows, "launchCities"),
  form: organizerPublishingForm,
  isDetailLoading: false,
  isListLoading: false,
  isPublishing: false,
  isSaving: false,
  listGeneratedAt: "2026-07-03T10:08:00.000Z",
  publishingIssues: validateOrganizerPublishingForm(
    organizerPublishingForm,
    {publishing: true, requireReviewNote: true}
  ),
  query: "",
  refreshList: async () => {
    noop();
  },
  rows: organizerPublishingRows,
  save: async () => {
    noop();
    return true;
  },
  saveAndPublish: async () => {
    noop();
  },
  selectOrganizer: (_clubId) => {
    noop();
  },
  setChecklist: (_value) => {
    noop();
  },
  setClubId: (_value) => {
    noop();
  },
  setFilter: (_value) => {
    noop();
  },
  setForm: (_value) => {
    noop();
  },
  setQuery: (_value) => {
    noop();
  },
  validationIssues: validateOrganizerPublishingForm(
    organizerPublishingForm,
    {requireReviewNote: organizerPublishingDiffRows.length > 0}
  ),
  view: "list",
};
const safetyRows: SafetyTriageController["rows"] = [
  ...overview.queues.safetyReports.map((row, index) => ({
    ...row,
    queueKind: "reports" as const,
    queueLabel: "User reports",
    priority: index === 0 ? "high" as const : "medium" as const,
    routeOwner: index === 0 ? "Trust and safety" : "Support review",
  })),
  ...overview.queues.moderationFlags.map((row, index) => ({
    ...row,
    queueKind: "moderation" as const,
    queueLabel: "Moderation flags",
    priority: index === 1 ? "high" as const : "medium" as const,
    routeOwner: "Moderation",
  })),
  ...overview.queues.eventSafetyReports.map((row) => ({
    ...row,
    queueKind: "event" as const,
    queueLabel: "Event reports",
    priority: "high" as const,
    routeOwner: "Event safety",
  })),
];
const safetySelected = safetyRows[0] ?? null;
const safetySelectedDetail: NonNullable<SafetyTriageController["selectedDetail"]> = {
  assignment: {
    assigneeUid: "safety-reviewer",
    ownerTeam: "Trust and safety",
    queue: "reports",
    severity: "high",
  },
  clubId: null,
  contextId: "sample/context",
  createdAt: safetySelected?.createdAt ?? null,
  eventId: null,
  evidence: [
    {
      label: "Report detail",
      sensitive: true,
      sourcePath: safetySelected?.targetPath ?? null,
      value: safetySelected?.detail ?? "target user_829 - chat",
    },
    {
      label: "Channel",
      sensitive: false,
      sourcePath: "chats/chat-829",
      value: "chat",
    },
  ],
  fields: [
    {label: "Queue item", value: safetySelected?.title ?? "harassment"},
    {label: "Target path", value: safetySelected?.targetPath ?? "reports/report-1"},
    {label: "Status", value: safetySelected?.status ?? "open"},
  ],
  kind: "report",
  nextActions: [
    "Open the source document before resolving.",
    "Confirm reporter, subject, event, and channel context.",
    "Use audited safety mutations only after the policy outcome is explicit.",
  ],
  outcomeGuidance: [
    {
      actionStatus: "manual",
      detail: "Escalation and restriction actions are intentionally outside this workspace until their audited callables exist.",
      id: "manual-escalation",
      label: "Escalate after policy review",
      severity: "warning",
    },
  ],
  primaryUserId: "user_829",
  priorHistory: [
    {
      count: 2,
      id: "prior-chat-reports",
      label: "Prior chat reports",
      sampleTargetPaths: ["reports/report-archive-1", "reports/report-archive-2"],
    },
  ],
  secondaryUserId: null,
  sla: {
    dueAt: "2026-06-01T11:44:00.000Z",
    policy: "High severity reports require same-day review.",
    state: "due_soon",
  },
  source: "chat",
  status: safetySelected?.status ?? "open",
  summary: safetySelected?.detail ?? "target user_829 - chat",
  targetPath: safetySelected?.targetPath ?? "reports/report-1",
  title: safetySelected?.title ?? "harassment",
  updatedAt: null,
};
const safetyController: SafetyTriageController = {
  assignmentForm: {
    assigneeUid: "safety-reviewer",
    note: "Assigning same-day high-severity report review.",
  },
  assignmentInFlight: false,
  assignmentValidationIssue: null,
  decisionForm: {
    note: "Reviewed evidence preview and confirmed this requires manual policy follow-up.",
  },
  decisionInFlight: null,
  decisionValidationIssue: null,
  filteredRows: safetyRows,
  generatedAt: overview.generatedAt,
  isDetailLoading: false,
  isLoading: false,
  metrics: {
    eventReports: overview.queues.eventSafetyReports.length,
    highPriority: safetyRows.filter((row) => row.priority === "high").length,
    moderation: overview.queues.moderationFlags.length,
    reports: overview.queues.safetyReports.length,
  },
  query: "",
  queueFilter: "all",
  recentAssignments: [
    {
      assignment: safetySelectedDetail.assignment,
      note: "Escalated to same-day safety queue.",
      targetPath: safetySelectedDetail.targetPath,
    },
  ],
  recentDecisions: [
    {
      decision: "review",
      note: "Confirmed enough evidence for reviewed status.",
      status: "reviewed",
      targetPath: "moderationFlags/flag-1",
    },
  ],
  rows: safetyRows,
  selected: safetySelected,
  selectedDetail: safetySelectedDetail,
  assign: async () => {
    noop();
    return true;
  },
  decide: async (_decision) => {
    noop();
    return true;
  },
  refresh: async () => {
    noop();
    return true;
  },
  select: (_row) => {
    noop();
  },
  setAssignmentForm: (_value) => {
    noop();
  },
  setDecisionForm: (_value) => {
    noop();
  },
  setQuery: (_value) => {
    noop();
  },
  setQueueFilter: (_value) => {
    noop();
  },
};
const accessRows: AdminQueueItem[] = [
  {
    id: "access-priya",
    title: "Priya Sharma",
    detail: "Indore founder · supper club host · referral overlap",
    status: "pending",
    createdAt: "2026-07-03T07:30:00.000Z",
    targetPath: "accessApplications/access-priya",
  },
  {
    id: "access-rahul",
    title: "Rahul Jain",
    detail: "Mumbai member application · invite code pending",
    status: "pending",
    createdAt: "2026-07-03T06:10:00.000Z",
    targetPath: "accessApplications/access-rahul",
  },
];
const accessSelected = accessRows[0] ?? null;
const accessForm: AccessReviewFormState = {
  cohortId: "indore-founders",
  note: "Verified launch-city host fit and checked deterministic overlap signals.",
};
const accessSelectedDetails: AdminAccessApplicationDetails = {
  availabilityWindows: ["thursday_evening", "weekend"],
  city: "Indore",
  cohortId: null,
  createdAt: "2026-07-03T07:25:00.000Z",
  duplicateSignals: [
    {
      count: 2,
      id: "instagram-handle-overlap",
      label: "Instagram handle overlap",
      sampleTargetPaths: [
        "accessApplications/access-priya-old",
        "users/user-priya",
      ],
      value: "@priya_hosts",
    },
  ],
  eventTypes: ["supper_club", "singles_mixer"],
  hostUserId: null,
  instagramHandle: "@priya_hosts",
  inviteCode: "INDOREFOUNDERS",
  referralSource: "Founding organizer referral",
  reviewedAt: null,
  reviewerUid: null,
  reviewNote: null,
  role: "Host",
  status: "pending",
  submissionCount: 2,
  submittedAt: "2026-07-03T07:30:00.000Z",
  targetPath: "accessApplications/access-priya",
  uid: "access-priya",
  updatedAt: "2026-07-03T07:30:00.000Z",
  wantsToHost: true,
  whyCatch: "Wants to host smaller, curated dinners for verified singles.",
};
const accessController: AccessReviewController = {
  decisionInFlight: null,
  filteredRows: accessRows,
  form: accessForm,
  isDetailLoading: false,
  isLoading: false,
  query: "",
  recentDecisions: [
    {
      applicationUid: "access-archive-1",
      decision: "deny",
      status: "notSelectedYet",
      title: "Incomplete duplicate application",
    },
  ],
  rows: accessRows,
  selected: accessSelected,
  selectedDetails: accessSelectedDetails,
  validationIssue: null,
  decide: async (_decision: AccessApplicationDecision) => {
    noop();
    return true;
  },
  refresh: async () => {
    noop();
  },
  select: (_row: AdminQueueItem) => {
    noop();
  },
  setForm: (_form: AccessReviewFormState) => {
    noop();
  },
  setQuery: (_query: string) => {
    noop();
  },
};
const adminRoleSelectedUser: AdminUserRoleRecord = {
  assignmentPath: "adminRoleAssignments/admin-owner",
  disabled: false,
  displayName: "Catch Admin Owner",
  email: "owner@catch.local",
  roles: ["adminOwner"],
  targetUid: "admin-owner",
};
const adminRoleAssignmentRows: AdminRoleAssignmentRow[] = [
  {
    ...adminRoleSelectedUser,
    status: "active",
    updatedAt: "2026-07-03T09:50:00.000Z",
    updatedByUid: "admin-owner",
  },
  {
    assignmentPath: "adminRoleAssignments/support-ops",
    disabled: false,
    displayName: "Support Ops",
    email: "support@catch.local",
    roles: ["support", "analyticsViewer"],
    status: "active",
    targetUid: "support-ops",
    updatedAt: "2026-07-03T08:15:00.000Z",
    updatedByUid: "admin-owner",
  },
];
const adminRoleController: AdminRoleManagementController = {
  assignmentFilter: "active",
  assignmentGeneratedAt: "2026-07-03T09:55:00.000Z",
  assignmentRows: adminRoleAssignmentRows,
  isAssignmentListLoading: false,
  isLoading: false,
  isSaving: false,
  note: "",
  recentChanges: [
    {
      afterRoles: ["support", "analyticsViewer"],
      beforeRoles: ["support"],
      targetUid: "support-ops",
    },
  ],
  refreshAssignments: async () => {
    noop();
  },
  roleOptions: adminRoleClaimKeys,
  selectedRoles: ["adminOwner"],
  selectedUser: adminRoleSelectedUser,
  scopeContract: buildAdminRoleScopeContract("admin-owner", "admin-owner"),
  targetUid: "admin-owner",
  validationIssue: "Change at least one admin role before saving.",
  load: async (_nextTargetUid?: string) => {
    noop();
    return true;
  },
  save: async () => {
    noop();
    return false;
  },
  selectAssignment: (_row: AdminRoleAssignmentRow) => {
    noop();
  },
  setAssignmentFilter: (_value: AdminRoleAssignmentStatusFilter) => {
    noop();
  },
  setNote: (_value: string) => {
    noop();
  },
  setTargetUid: (_value: string) => {
    noop();
  },
  toggleRole: (_role: AdminRoleClaim, _checked: boolean) => {
    noop();
  },
};
const dataQualityRows: DataQualityRow[] = [
  {
    id: "overview-club-claims",
    source: "Overview",
    label: "Organizer claim queue",
    state: "blocked",
    detail: "3 organizer claims need canonical owner validation before publication.",
    owner: "Admin ops",
    runbook: "admin > Organizers > Claim review",
    nextAction: "Resolve claim identity conflicts before enabling public claim CTAs.",
    updatedAt: "2026-07-03T08:30:00.000Z",
  },
  {
    id: "event-supply-readiness-preflight",
    source: "Event supply readiness",
    label: "External event import blockers",
    state: "partial",
    detail: "12 candidates, 8 write-ready, 4 blocked by location or schema checks.",
    owner: "Events intake",
    runbook: "admin > Events > External import readiness",
    nextAction: "Resolve review, location, schema, or projection blockers before publishing readiness again.",
    updatedAt: "2026-07-03T07:45:00.000Z",
  },
  {
    id: "host-analytics-booking-window",
    source: "Host analytics",
    label: "Booking attribution",
    state: "warning",
    detail: "Analytics range uses a generated sample bridge older than the current launch week.",
    owner: "Growth ops",
    runbook: "admin > Growth > Host analytics",
    nextAction: "Regenerate the host analytics bridge before launch reporting.",
    updatedAt: "2026-07-02T12:00:00.000Z",
  },
  {
    id: "generated-marketing-bridge",
    source: "Generated bridge",
    label: "Marketing ops bridge",
    state: "ok",
    detail: "Generated today for Indore launch week content packaging.",
    owner: "Marketing ops",
    runbook: "admin/src/generated/marketingOpsBridge.json",
    nextAction: "No action; generated bridge is fresh enough for the launch workspace.",
    updatedAt: "2026-07-03T09:15:00.000Z",
  },
];
const dataQualityController: DataQualityController = {
  filteredRows: dataQualityRows,
  generatedAt: "2026-07-03T09:30:00.000Z",
  isLoading: false,
  metrics: dataQualityMetrics(dataQualityRows),
  query: "",
  rows: dataQualityRows,
  selected: dataQualityRows[0] ?? null,
  stateFilter: "all",
  refresh: async () => {
    noop();
  },
  select: (_row: DataQualityRow) => {
    noop();
  },
  setQuery: (_value: string) => {
    noop();
  },
  setStateFilter: (_value: DataQualityStateFilter) => {
    noop();
  },
};
const growthRows: GrowthSignalRow[] = [
  {
    id: "signupsThisWeek",
    stage: "acquisition",
    label: "Signups this week",
    value: 142,
    unit: "count",
    status: "ready",
    source: "adminGetOverview",
    detail: "Launch demand created this week across Indore and Mumbai.",
  },
  {
    id: "pendingClubClaims",
    stage: "supply",
    label: "Pending club claims",
    value: 9,
    unit: "count",
    status: "partial",
    source: "adminGetOverview",
    detail: "Organizer claim demand waiting for review before publication.",
  },
  {
    id: "bookings",
    stage: "conversion",
    label: "Bookings",
    value: 74,
    unit: "count",
    status: "ready",
    source: "adminGetHostAnalytics",
    detail: "Bookings confirmed by host analytics summary cards.",
  },
  {
    id: "checkoutConversionRate",
    stage: "conversion",
    label: "Checkout conversion rate",
    value: 38,
    unit: "percent",
    status: "partial",
    source: "adminGetHostAnalytics",
    detail: "Conversion is usable for launch review but not yet channel-attributed.",
  },
  {
    id: "claimClicks",
    stage: "marketplace",
    label: "Claim clicks",
    value: 21,
    unit: "count",
    status: "ready",
    source: "adminGetHostAnalytics.discoverySummary",
    detail: "Organizer claim intent captured from public pages.",
  },
];
const growthTrend: HostAnalyticsTrendPoint[] = [
  {
    periodStart: "2026-06-20",
    periodEnd: "2026-06-26",
    metrics: {
      bookings: 25,
      checkedIn: 18,
      checkoutDropoff: 7,
      demand: 84,
      reviews: 12,
    },
  },
  {
    periodStart: "2026-06-27",
    periodEnd: "2026-07-03",
    metrics: {
      bookings: 49,
      checkedIn: 37,
      checkoutDropoff: 9,
      demand: 116,
      reviews: 19,
    },
  },
];
const growthController: GrowthKpiController = {
  filteredRows: growthRows,
  isLoading: false,
  loadedAt: "2026-07-03T09:40:00.000Z",
  metrics: growthMetrics(growthRows),
  query: "",
  rangePreset: "30d",
  rows: growthRows,
  selected: growthRows[1] ?? null,
  stageFilter: "all",
  trend: growthTrend,
  refresh: async () => {
    noop();
    return true;
  },
  select: (_row: GrowthSignalRow) => {
    noop();
  },
  setQuery: (_value: string) => {
    noop();
  },
  setRangePreset: (_value: GrowthRangePreset) => {
    noop();
  },
  setStageFilter: (_value: GrowthStage) => {
    noop();
  },
};
const financeRows: FinanceIssueRow[] = [
  {
    id: "payment-refundfailed-pune-1",
    kind: "payment",
    title: "Manual refund needed",
    detail: "Refund failed for a charged booking after event cancellation.",
    status: "refundFailed",
    targetPath: "payments/pay_manual_refund_1",
    createdAt: "2026-07-03T06:20:00.000Z",
    amountMinor: 250000,
    currency: "INR",
    severity: "high",
    nextAction: "Open the provider record before retry, refund, or manual follow-up.",
  },
  {
    id: "event-mumbai-padel-payments",
    kind: "event",
    title: "Mumbai padel mixer payments",
    detail: "2 failed, 1 refunded, 6 checkout drop-off.",
    status: "failed",
    targetPath: "events/mumbai-padel-mixer-1",
    createdAt: "2026-07-05T13:30:00.000Z",
    amountMinor: 1840000,
    currency: "INR",
    severity: "high",
    nextAction: "Use event and provider records to reconcile payment state before action.",
  },
  {
    id: "payout-restricted-hosts",
    kind: "payout",
    title: "Payout restricted hosts",
    detail: "3 host accounts need provider review.",
    status: "restricted",
    targetPath: "metrics/payoutRestrictedHosts",
    createdAt: "2026-07-03T09:45:00.000Z",
    amountMinor: null,
    currency: "INR",
    severity: "medium",
    nextAction: "Inspect provider authority before changing payout or settlement state.",
  },
];
const selectedFinanceRow = financeRows[0] ?? null;
const financeController: FinanceOpsController = {
  filteredRows: financeRows,
  isLoading: false,
  kindFilter: "all",
  loadedAt: "2026-07-03T09:45:00.000Z",
  metrics: {
    completedPayments: 418,
    failedPayments: 6,
    payoutRestrictedHosts: 3,
    revenueMinor: 9275000,
    signupFailedPayments: 2,
  },
  query: "",
  rows: financeRows,
  selected: selectedFinanceRow,
  selectedReview: selectedFinanceRow ?
    buildFinanceIssueReview(selectedFinanceRow) :
    null,
  refresh: async () => {
    noop();
    return true;
  },
  select: (_row: FinanceIssueRow) => {
    noop();
  },
  setKindFilter: (_value: FinanceIssueKind) => {
    noop();
  },
  setQuery: (_value: string) => {
    noop();
  },
};
const userAnalyticsPayload: UserAnalyticsQueryPayload = {
  endDate: null,
  granularity: "day",
  rangePreset: "30d",
  startDate: null,
  userId: "user-1",
};
const userAnalyticsController: UserAnalyticsController = {
  endDate: "2026-07-03",
  granularity: "day",
  isLoading: false,
  lookupContract: buildUserLookupContract("users/user-1"),
  payload: userAnalyticsPayload,
  rangePreset: "30d",
  report: sampleUserAnalyticsReport(userAnalyticsPayload),
  startDate: "2026-06-04",
  userId: "users/user-1",
  load: async (_nextUserId?: string) => {
    noop();
    return true;
  },
  setEndDate: (_value: string) => {
    noop();
  },
  setGranularity: (_value: UserAnalyticsGranularity) => {
    noop();
  },
  setRangePreset: (_value: UserAnalyticsRangePreset) => {
    noop();
  },
  setStartDate: (_value: string) => {
    noop();
  },
  setUserId: (_value: string) => {
    noop();
  },
};

const meta = {
  title: "Admin Dashboard/Routes",
  parameters: {
    catchComponentRegistry: {
      path: "design/admin/components.json",
    },
  },
} satisfies Meta;

export default meta;

type Story = StoryObj<typeof meta>;

const noop = () => {
  // Storybook preview only; route-state mutation is covered by app/controller tests.
};

const setGranularity = (_value: OverviewAnalyticsGranularity) => {
  noop();
};

const setRangePreset = (_value: OverviewAnalyticsRangePreset) => {
  noop();
};

function dataQualityMetrics(rows: DataQualityRow[]) {
  return {
    total: rows.length,
    blocking: rows.filter((row) =>
      row.state === "blocked" || row.state === "missing"
    ).length,
    watch: rows.filter((row) =>
      row.state === "warning" || row.state === "partial"
    ).length,
    ok: rows.filter((row) => row.state === "ok").length,
    sources: new Set(rows.map((row) => row.source)).size,
  };
}

function growthMetrics(rows: GrowthSignalRow[]) {
  const value = (id: string) => rows.find((row) => row.id === id)?.value ?? 0;
  return {
    signals: rows.length,
    watch: rows.filter((row) => row.status !== "ready").length,
    signupsThisWeek: value("signupsThisWeek"),
    bookings: value("bookings"),
  };
}

function eventListRowFromDetails(event: AdminEventDetails): AdminEventListRow {
  return {
    activityKind: event.eventFormat.activityKind,
    activityLabel: event.eventFormat.label,
    availability: event.discovery.availability,
    bookedCount: event.bookedCount,
    capacityLimit: event.capacityLimit,
    citySlug: event.discovery.citySlug,
    clubId: event.clubId,
    currency: event.currency,
    eventId: event.eventId,
    meetingPoint: event.meetingPoint,
    organizerName: event.organizerName,
    priceInPaise: event.priceInPaise,
    searchIndexStatus: event.searchIndexStatus,
    startTime: event.startTime,
    status: event.status,
    title: event.title,
  };
}

function organizerListRowFromDetails(club: AdminClubDetails): AdminClubListRow {
  return {
    appVisibility: club.appVisibility,
    canonicalPath: club.publicPage.canonicalPath,
    cityName: club.cityName ?? club.area,
    citySlug: club.location ?? club.publicPage.citySlug,
    claimState: club.claimState,
    clubId: club.clubId,
    countryCode: club.countryCode,
    displayCategory: club.displayCategory,
    indexStatus: club.publicPage.indexStatus,
    name: club.name,
    ownershipState: club.ownershipState,
    publishStatus: club.publicPage.publishStatus,
    regionName: club.regionName,
    robots: club.publicPage.robots,
    routeReservationStatus: club.publicPage.canonicalPath ? "reserved" : "missing",
    routeStatus: club.publicPage.canonicalPath ? "valid" : "missing",
    searchIndexStatus: club.publicPage.indexStatus === "indexed" ?
      "indexed" :
      "missing",
    sourceConfidence: club.provenance.sourceConfidence,
    verificationStatus: club.provenance.verificationStatus,
  };
}

function buildEventSupplyReadiness(
  row: AdminExternalEventListRow | null,
  generatedAt: string
): AdminGetEventSupplyReadinessResponse {
  const importAction = row ? buildExternalEventImportAction(row) : null;
  return {
    generatedAt,
    source: "sample",
    importPlan: {
      actions: importAction ? [importAction] : [],
      commands: {
        plan: "node tool/organizer_intake/publish_event_supply_readiness.mjs --dry-run",
        write: "node tool/organizer_intake/publish_event_supply_readiness.mjs --write",
      },
      generatedFrom: {
        batches: ["storybook-event-supply"],
        externalEventCandidateQueue: "externalEventCandidateQueue/current",
        reviewDecisionBatches: ["storybook-review-batch"],
        locationResolutionBatches: ["storybook-location-batch"],
      },
      guardrails: [
        "No writes to canonical events/{id}",
        "External supply remains outbound-link only",
      ],
      policy: {
        reason: "Storybook fixture keeps importer writes disabled.",
        status: "disabled",
        writeEnabled: false,
      },
      summary: {
        actionsByPlatform: row ? {[row.platform]: 1} : {},
        actionsByStatus: row ? {waiting_review: 1} : {},
        blocked: 0,
        candidates: row ? 1 : 0,
        duplicateEventKeys: row?.duplicateCandidateCount ?? 0,
        proposedCreates: 0,
        proposedReadOnlyEvents: row ? 1 : 0,
        rejected: 0,
        waitingReview: row ? 1 : 0,
        writeReady: 0,
      },
    },
    executionPlan: {
      actions: [],
      commands: {
        plan: "node tool/organizer_intake/verify_event_import_preflight.mjs --dry-run",
        write: "not enabled in Storybook fixture",
      },
      generatedFrom: {
        externalEventImportPlan: "externalEventImportPlan/storybook",
        importPlanGeneratedFrom: {
          source: "storybook",
        },
      },
      guardrails: [
        "Preflight must pass before adminPublishExternalEvent can write",
      ],
      policy: {
        authorityModel: "preflight",
        reason: "Storybook fixture is read-only.",
        status: "disabled",
        writeEnabled: false,
      },
      summary: {
        actionsByStatus: {},
        blocked: 0,
        createActions: 0,
        importActions: 0,
        payloadInvalid: 0,
        payloadValid: 0,
        projectionInvalid: 0,
        projectionInvalidCount: 0,
        projectionValid: 0,
        readOnlyActions: 0,
        schemaInvalid: 0,
        skipped: 0,
        wouldCreate: 0,
        wouldPublishReadOnly: 0,
      },
    },
  };
}

function buildExternalEventImportAction(
  row: AdminExternalEventListRow
): ExternalEventImportAction {
  return {
    action: "publish_read_only_external_event",
    actionId: `storybook:${row.candidateId}`,
    blockers: row.importPolicyAcknowledged && row.ownerSafeCopyReviewed ? [] : [
      "import_policy_acknowledgement_required",
      "owner_safe_copy_review_required",
    ],
    candidateId: row.candidateId,
    duplicateCandidateIds: [],
    entityId: row.eventId,
    importState: "waiting_review",
    normalizedEventKey: row.normalizedEventKey,
    platform: row.platform,
    proposedReadOnlyEventDraft: {
      activity: {
        activityKind: row.activityKind,
        interactionModel: row.interactionModel,
        source: row.activitySource,
        version: 1,
      },
      booking: {
        catchBookingEnabled: false,
        catchPaymentsEnabled: false,
        catchReservationsEnabled: false,
        catchWaitlistEnabled: false,
        externalLinks: [{
          candidateId: row.candidateId,
          linkType: "primary",
          platform: row.platform,
          primary: true,
          sourceEventKey: row.sourceEventKey,
          url: row.primaryExternalUrl ?? row.eventUrl ?? row.sourceUrl ?? "",
        }],
        mode: "external",
      },
      canonicalHostId: row.canonicalHostId,
      compatibilityClubId: row.compatibilityClubId,
      description: "Read-only external supply preview for Storybook.",
      endTime: row.endTime,
      eventId: row.eventId,
      locationDetails: null,
      meetingPoint: row.meetingPoint,
      photoUrl: null,
      price: {
        currency: row.currency,
        displayText: row.priceDisplayText,
        parsedPriceInPaise: row.parsedPriceInPaise,
      },
      startTime: row.startTime ?? "2026-07-08T13:30:00.000Z",
      timezone: row.timezone,
      title: row.title,
    },
    reviewStatus: "waiting_review",
    source: {
      batchId: row.reviewBatchId ?? "storybook-review-batch",
      eventUrl: row.eventUrl,
      sourceStatus: row.status,
      sourceUrl: row.sourceUrl,
      surfaceId: "storybook",
    },
    sourceEventKey: row.sourceEventKey,
    status: "waiting_review",
    targetPath: row.targetPath,
  };
}

const renderDataQualityWorkspace = () => (
  <AdminWorkspace>
    <DataQualityWorkspace controller={dataQualityController} />
  </AdminWorkspace>
);

const renderAccessReviewWorkspace = () => (
  <AdminWorkspace>
    <AccessReviewWorkspace controller={accessController} />
  </AdminWorkspace>
);

const renderEventPublishingWorkspace = () => (
  <AdminWorkspace>
    <EventPublishingWorkspace controller={eventController} />
  </AdminWorkspace>
);

const renderEventIntakeWorkspace = () => (
  <AdminWorkspace>
    <EventIntakePreviewWorkspace controller={eventIntakeController} />
  </AdminWorkspace>
);

const renderOrganizerIntakeWorkspace = () => (
  <AdminWorkspace>
    <OrganizerIntakeWorkspace controller={organizerIntakeController} />
  </AdminWorkspace>
);

const renderMarketingOpsWorkspace = () => (
  <AdminWorkspace>
    <MarketingOpsWorkspace controller={marketingOpsController} />
  </AdminWorkspace>
);

const renderOrganizerPublishingWorkspace = () => (
  <AdminWorkspace>
    <OrganizerPublishingWorkspace controller={organizerPublishingController} />
  </AdminWorkspace>
);

const renderIntakeWorkspace = () => (
  <AdminWorkspace>
    <IntakeWorkspace
      activeWorkspace="events"
      eventsContent={<EventIntakePreviewWorkspace controller={eventIntakeController} />}
      organizersContent={<OrganizerIntakeWorkspace controller={organizerIntakeController} />}
      onWorkspaceChange={noop}
    />
  </AdminWorkspace>
);

const renderGrowthWorkspace = () => (
  <AdminWorkspace>
    <GrowthKpiWorkspace controller={growthController} />
  </AdminWorkspace>
);

const renderFinanceWorkspace = () => (
  <AdminWorkspace>
    <FinanceOpsWorkspace controller={financeController} />
  </AdminWorkspace>
);

const renderUserAnalyticsWorkspace = () => (
  <AdminWorkspace>
    <UserAnalyticsWorkspace controller={userAnalyticsController} />
  </AdminWorkspace>
);

const renderAdminRoleWorkspace = () => (
  <AdminWorkspace>
    <AdminRoleManagementWorkspace controller={adminRoleController} />
  </AdminWorkspace>
);

const renderSafetyTriageWorkspace = () => (
  <AdminWorkspace>
    <SafetyTriageWorkspace controller={safetyController} />
  </AdminWorkspace>
);

export const SafetyTriageRouteStory: Story = {
  name: "Safety",
  parameters: {
    catchComponent: {
      id: "route_safety_triage",
      states: ["default", "queue-detail", "assignment-decision"],
    },
  },
  render: renderSafetyTriageWorkspace,
};

export const SafetyTriageWorkspaceStory: Story = {
  name: "Safety Workspace",
  parameters: {
    catchComponent: {
      id: "workspace_safety_triage",
      states: ["default", "queue-detail", "assignment-decision"],
    },
  },
  render: renderSafetyTriageWorkspace,
};

export const AccessReviewRouteStory: Story = {
  name: "Access",
  parameters: {
    catchComponent: {
      id: "route_access_review",
      states: ["default", "application-detail", "decision-controls"],
    },
  },
  render: renderAccessReviewWorkspace,
};

export const AccessReviewWorkspaceStory: Story = {
  name: "Access Workspace",
  parameters: {
    catchComponent: {
      id: "workspace_access_review",
      states: ["default", "application-detail", "decision-controls"],
    },
  },
  render: renderAccessReviewWorkspace,
};

export const DataQualityRouteStory: Story = {
  name: "Data Quality",
  parameters: {
    catchComponent: {
      id: "route_data_quality",
      states: ["default", "signals", "detail"],
    },
  },
  render: renderDataQualityWorkspace,
};

export const DataQualityWorkspaceStory: Story = {
  name: "Data Quality Workspace",
  parameters: {
    catchComponent: {
      id: "workspace_data_quality",
      states: ["default", "signals", "detail"],
    },
  },
  render: renderDataQualityWorkspace,
};

export const EventPublishingRouteStory: Story = {
  name: "Events",
  parameters: {
    catchComponent: {
      id: "route_event_publishing",
      states: ["default", "canonical-directory", "external-supply"],
    },
  },
  render: renderEventPublishingWorkspace,
};

export const EventPublishingWorkspaceStory: Story = {
  name: "Events Workspace",
  parameters: {
    catchComponent: {
      id: "workspace_event_publishing",
      states: ["default", "canonical-directory", "external-supply"],
    },
  },
  render: renderEventPublishingWorkspace,
};

export const IntakeWorkspaceRouteStory: Story = {
  name: "Intake",
  parameters: {
    catchComponent: {
      id: "route_intake_workspace",
      states: ["default", "event-intake", "run-plan"],
    },
  },
  render: renderIntakeWorkspace,
};

export const IntakeWorkspaceStory: Story = {
  name: "Intake Workspace Shell",
  parameters: {
    catchComponent: {
      id: "workspace_intake_workspace",
      states: ["default", "event-intake", "run-plan"],
    },
  },
  render: renderIntakeWorkspace,
};

export const EventIntakeWorkspaceStory: Story = {
  name: "Event Intake Workspace",
  parameters: {
    catchComponent: {
      id: "workspace_event_intake",
      states: ["default", "run-plan", "source-review"],
    },
  },
  render: renderEventIntakeWorkspace,
};

export const OrganizerIntakeRouteStory: Story = {
  name: "Organizer Intake",
  parameters: {
    catchComponent: {
      id: "route_organizer_intake",
      states: ["default", "workflow-readiness", "publication-packets"],
    },
  },
  render: renderOrganizerIntakeWorkspace,
};

export const OrganizerIntakeWorkspaceStory: Story = {
  name: "Organizer Intake Workspace",
  parameters: {
    catchComponent: {
      id: "workspace_organizer_intake",
      states: ["default", "workflow-readiness", "publication-packets"],
    },
  },
  render: renderOrganizerIntakeWorkspace,
};

export const MarketingOpsRouteStory: Story = {
  name: "Marketing Ops",
  parameters: {
    catchComponent: {
      id: "route_marketing_ops",
      states: ["default", "post-board", "action-boundary"],
    },
  },
  render: renderMarketingOpsWorkspace,
};

export const MarketingOpsWorkspaceStory: Story = {
  name: "Marketing Ops Workspace",
  parameters: {
    catchComponent: {
      id: "workspace_marketing_ops",
      states: ["default", "post-board", "action-boundary"],
    },
  },
  render: renderMarketingOpsWorkspace,
};

export const OrganizerPublishingRouteStory: Story = {
  name: "Organizer Publishing",
  parameters: {
    catchComponent: {
      id: "route_organizer_publishing",
      states: ["default", "canonical-directory", "publishing-contract"],
    },
  },
  render: renderOrganizerPublishingWorkspace,
};

export const OrganizerPublishingWorkspaceStory: Story = {
  name: "Organizer Publishing Workspace",
  parameters: {
    catchComponent: {
      id: "workspace_organizer_publishing",
      states: ["default", "canonical-directory", "publishing-contract"],
    },
  },
  render: renderOrganizerPublishingWorkspace,
};

export const GrowthRouteStory: Story = {
  name: "Growth",
  parameters: {
    catchComponent: {
      id: "route_growth_kpi",
      states: ["default", "signals", "trend"],
    },
  },
  render: renderGrowthWorkspace,
};

export const GrowthWorkspaceStory: Story = {
  name: "Growth Workspace",
  parameters: {
    catchComponent: {
      id: "workspace_growth_kpi",
      states: ["default", "signals", "trend"],
    },
  },
  render: renderGrowthWorkspace,
};

export const FinanceRouteStory: Story = {
  name: "Finance",
  parameters: {
    catchComponent: {
      id: "route_finance_ops",
      states: ["default", "issues", "reconciliation"],
    },
  },
  render: renderFinanceWorkspace,
};

export const FinanceWorkspaceStory: Story = {
  name: "Finance Workspace",
  parameters: {
    catchComponent: {
      id: "workspace_finance_ops",
      states: ["default", "issues", "reconciliation"],
    },
  },
  render: renderFinanceWorkspace,
};

export const UserAnalyticsRouteStory: Story = {
  name: "Users",
  parameters: {
    catchComponent: {
      id: "route_user_analytics",
      states: ["default", "lookup-contract", "report"],
    },
  },
  render: renderUserAnalyticsWorkspace,
};

export const UserAnalyticsWorkspaceStory: Story = {
  name: "Users Workspace",
  parameters: {
    catchComponent: {
      id: "workspace_user_analytics",
      states: ["default", "lookup-contract", "report"],
    },
  },
  render: renderUserAnalyticsWorkspace,
};

export const AdminRoleManagementRouteStory: Story = {
  name: "Admin Roles",
  parameters: {
    catchComponent: {
      id: "route_admin_role_management",
      states: ["default", "scope-contract", "assignment-register"],
    },
  },
  render: renderAdminRoleWorkspace,
};

export const AdminRoleManagementWorkspaceStory: Story = {
  name: "Admin Roles Workspace",
  parameters: {
    catchComponent: {
      id: "workspace_admin_role_management",
      states: ["default", "scope-contract", "assignment-register"],
    },
  },
  render: renderAdminRoleWorkspace,
};

export const OverviewRouteStory: Story = {
  name: "Overview",
  parameters: {
    catchComponent: {
      id: "route_overview",
      states: ["default", "analytics-controls", "queue-detail"],
    },
  },
  render: () => (
    <AdminWorkspace>
      <OverviewScreen
        analyticsClubId=""
        analyticsEndDate="2026-07-03"
        analyticsEventId=""
        analyticsGranularity="day"
        analyticsRangePreset="30d"
        analyticsStartDate="2026-06-04"
        hostAnalytics={hostAnalytics}
        overview={overview}
        onAnalyticsClubIdChange={noop}
        onAnalyticsEndDateChange={noop}
        onAnalyticsEventIdChange={noop}
        onAnalyticsGranularityChange={setGranularity}
        onAnalyticsRangePresetChange={setRangePreset}
        onAnalyticsStartDateChange={noop}
        onClearAnalyticsScope={noop}
      />
    </AdminWorkspace>
  ),
};
