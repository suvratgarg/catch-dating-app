import {
  Activity,
  CheckCircle2,
  Clock3,
  Database,
  FileWarning,
  FolderSearch,
  LineChart,
  Lock,
  RefreshCw,
  Search,
  Settings2,
  UserCheck,
  Users,
} from "lucide-react";
import {EventIntakeWorkspace} from "../../events/ui/EventIntakeWorkspace";
import {
  AdminButton,
  AdminTag,
  AlertRow,
  CheckboxField,
  Panel,
  SegmentedControl,
  SelectField,
  StateRow,
  TextareaField,
  TextField,
} from "../../../../shared/ui/AdminPrimitives";
import {
  curationFormKey,
  decisionLabel,
  defaultCurationForm,
  eventDecisionLabel,
  intakeChecklistForDecision,
  locationResolutionFormFromTask,
  pendingInputDecisionLabel,
  pendingInputDecisionProgressLabel,
  pendingInputDecisionState,
  pendingInputInFlightDecision,
  pendingInputSubmittedDecision,
  policyGapDecisionLabel,
  publicationPacketReady,
} from "../controllers/organizerIntakeHelpers";
import {useOrganizerIntakeController} from "../controllers/useOrganizerIntakeController";
import type {
  AdminDecideOrganizerEventCandidateResponse,
  AdminDecideOrganizerIntakeResponse,
  AdminDecideOrganizerPolicyGapResponse,
  AdminRecordOrganizerCurationResponse,
  AdminResolveOrganizerEventLocationResponse,
  OrganizerCurationOperation,
  OrganizerEventCandidateDecision,
  OrganizerIntakeDecision,
  OrganizerPolicyGapDecision,
  OrganizerSurfaceDecision,
} from "../../../../shared/types/adminTypes";
import type * as Intake from "../types/organizerIntakeTypes";

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

export function OrganizerIntakeScreen({
  onError,
  onNotice,
}: {
  onError: (message: string | null) => void;
  onNotice: (message: string | null) => void;
}) {
  const {
    activeWorkspace,
    bridge,
    curationForms,
    curationInFlight,
    decisionInFlight,
    decisionNotes,
    eventDecisionInFlight,
    eventDecisionNotes,
    handleAttachCandidate,
    handleDecision,
    handleEventDecision,
    handleItemCuration,
    handleLocationResolution,
    handlePendingInputDecision,
    handlePolicyGapDecision,
    localCuration,
    localDecisions,
    localEventDecisions,
    localLocationResolutions,
    localPolicyDecisions,
    locationResolutionForms,
    locationResolutionInFlight,
    manualReportAcknowledgements,
    metrics,
    policyDecisionInFlight,
    policyDecisionNotes,
    publicationPacketByEntity,
    setActiveWorkspace,
    setCurationForms,
    setDecisionNotes,
    setEventDecisionNotes,
    setLocationResolutionForms,
    setManualReportAcknowledgements,
    setPolicyDecisionNotes,
  } = useOrganizerIntakeController({onError, onNotice});

  return (
    <>
      <section className="intake-workspace-header">
        <div>
          <div className="intake-eyebrow">Intake workspace</div>
          <h2>
            {activeWorkspace === "events" ?
              "Event intake" :
              "Organizer intake"}
          </h2>
          <p>
            {activeWorkspace === "events" ?
              "Search-source setup, raw lead review, candidate editing, and event-owned review decisions before external import planning or Marketing consume these records." :
              "Organizer discovery, evidence review, curation, publication readiness, and claim handoff."}
          </p>
        </div>
        <SegmentedControl
          ariaLabel="Intake workspace"
          className="intake-workspace-tabs"
          options={[
            {id: "events", label: "Event leads"},
            {id: "organizers", label: "Organizers"},
          ]}
          value={activeWorkspace}
          onChange={setActiveWorkspace}
        />
      </section>

      <IntakePublicationBoundaryPanel activeWorkspace={activeWorkspace} />

      {activeWorkspace === "events" ? (
        <EventIntakeWorkspace
          onError={onError}
          onNotice={onNotice}
        />
      ) : (
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
          title="Discovery search plan"
          action={`${bridge.discoverySearchPlan.summary.launchCityPlanned} launch queries`}
        >
          <OrganizerDiscoverySearchPlanView
            plan={bridge.discoverySearchPlan}
          />
        </Panel>

        <Panel
          className="span-2"
          icon={<FileWarning size={18} strokeWidth={1.9} />}
          title="Publishing contract anchors"
          action="app + website schemas"
        >
          <OrganizerPublishingContractsView
            contracts={bridge.publishingContracts}
          />
        </Panel>

        <Panel
          className="span-2"
          icon={<LineChart size={18} strokeWidth={1.9} />}
          title="Source mention resolution"
          action={`${bridge.sourceMentionResolution.resolutionClusters.summary.clusters} clusters`}
        >
          <OrganizerSourceMentionResolutionView
            resolution={bridge.sourceMentionResolution}
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
      )}
    </>
  );
}

function IntakePublicationBoundaryPanel({
  activeWorkspace,
}: {
  activeWorkspace: "events" | "organizers";
}) {
  const isEvents = activeWorkspace === "events";
  return (
    <Panel
      className="span-2"
      icon={<Lock size={18} strokeWidth={1.9} />}
      title="Intake publication boundary"
      action={isEvents ? "event review only" : "organizer review only"}
    >
      <AlertRow
        icon={<Lock size={16} strokeWidth={1.9} />}
        title={isEvents ? "Event candidates are not app events" : "Organizer approvals are not final publication"}
      >
        {isEvents ?
          "Event Intake reads eventIntakeDashboards/current and writes eventIntakeReviewDecisions. Canonical event creation, external event promotion, booking, payments, and waitlists stay outside this workspace." :
          "Organizer Intake records review, curation, policy, and location decisions. Canonical organizer publishing, public route indexing, and claim ownership still pass through promotion tooling and the Organizers workspace."}
      </AlertRow>
      <div className="quality-list">
        <StateRow
          label="Read model"
          value={isEvents ?
            "eventIntakeDashboards/current plus generated sample bridge" :
            "repo-owned organizer intake bridge JSON"}
        />
        <StateRow
          label="Writes here"
          value={isEvents ?
            "eventIntakeReviewDecisions/{decisionId}" :
            "organizer review, curation, policy, and location decision records"}
        />
        {isEvents ? (
          <StateRow
            label="Callable boundary"
            value="adminGetEventIntakeDashboard + adminRecordEventIntakeReviewDecision"
          />
        ) : null}
        <StateRow
          label="Not here"
          value={isEvents ?
            "events/{id}, externalEvents/{id}, bookings, payments, waitlists" :
            "unchecked canonical clubs/{id} publication, route indexing, claim ownership transfer"}
        />
      </div>
      <div className="intake-tags">
        {(isEvents ? [
          "source evidence",
          "dedupe",
          "location",
          "policy",
          "review note",
        ] : [
          "evidence",
          "surface curation",
          "policy gaps",
          "publication packet",
          "claim handoff",
        ]).map((label) => (
          <AdminTag key={label}>{label}</AdminTag>
        ))}
      </div>
    </Panel>
  );
}

function OrganizerWorkflowReadinessView({
  readiness,
}: {
  readiness: Intake.OrganizerWorkflowReadiness;
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
  queue: Intake.OrganizerOperatorActionQueue;
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
  health: Intake.OrganizerOperationalHealthReport;
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
  coverage: Intake.OrganizerPendingWorkCoverage;
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
    input: Intake.OrganizerPendingInputItem,
    decision: string
  ) => void;
  policyDecisions: Record<string, AdminDecideOrganizerPolicyGapResponse>;
  policyInFlight: Record<string, OrganizerPolicyGapDecision>;
  publicationDecisions: Record<string, AdminDecideOrganizerIntakeResponse>;
  publicationInFlight: Record<string, OrganizerIntakeDecision>;
  request: Intake.OrganizerPendingInputRequest;
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
                        <AdminButton
                          disabled={isDeciding || !payloadAvailable}
                          key={`${input.requestId}:decision:${decision}`}
                          onClick={() => onPendingDecision(input, decision)}
                        >
                          {inFlightDecision === decision ?
                            pendingInputDecisionProgressLabel(decision) :
                            pendingInputDecisionLabel(decision)}
                        </AdminButton>
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
  register: Intake.OrganizerReviewedDecisionAnswerPacketRegister;
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
  packet: Intake.OrganizerPromotionExecutionPacket;
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
    gap: Intake.OrganizerPolicyGap,
    decision: OrganizerPolicyGapDecision
  ) => void;
  onNoteChange: (gapId: string, note: string) => void;
  register: Intake.OrganizerPolicyGapRegister;
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
                    <AdminButton
                      disabled={isDeciding}
                      onClick={() => onDecision(gap, "accept")}
                      variant="primary"
                    >
                      {inFlightDecisions[gap.gapId] === "accept" ?
                        "Accepting" :
                        "Accept"}
                    </AdminButton>
                    <AdminButton
                      disabled={isDeciding}
                      onClick={() => onDecision(gap, "hold")}
                    >
                      {inFlightDecisions[gap.gapId] === "hold" ?
                        "Holding" :
                        "Hold"}
                    </AdminButton>
                    <AdminButton
                      disabled={isDeciding}
                      onClick={() => onDecision(gap, "reject")}
                    >
                      {inFlightDecisions[gap.gapId] === "reject" ?
                        "Rejecting" :
                        "Reject"}
                    </AdminButton>
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
  packets: Intake.OrganizerPolicyDecisionPackets;
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
  registry: Intake.OrganizerCanonicalHostEntityRegistry;
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
  index: Intake.OrganizerCanonicalEvidenceIndex;
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
  packets: Intake.OrganizerPublicationReviewPackets;
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
  record: Intake.OrganizerPublicationEvidenceReviewRecord
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
  preview: Intake.OrganizerPublicationDecisionImpactPreview;
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

function sourceResolutionTone(status: string) {
  if (status === "auto_attach" || status === "singleton") return "ready";
  if (status === "needs_human_review") return "blocked";
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
  preview: Intake.OrganizerClaimTargetSyncPreview;
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
  plan: Intake.OrganizerCrawlRunPlan;
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
  manifest: Intake.OrganizerRawArtifactStorageManifest;
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
  onAttachCandidate: (candidate: Intake.OrganizerSearchCandidate) => void;
  queue: Intake.OrganizerSearchCandidateQueue;
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

function OrganizerDiscoverySearchPlanView({
  plan,
}: {
  plan: Intake.OrganizerDiscoverySearchPlan;
}) {
  const launchEntries = plan.planned
    .filter((entry) => plan.summary.launchCities.includes(entry.citySlug))
    .slice(0, 18);
  const skippedEntries = plan.skippedFresh
    .filter((entry) => plan.summary.launchCities.includes(entry.citySlug))
    .slice(0, 6);
  const launchQueryTemplates = Array.from(new Map(
    launchEntries.map((entry) => [
      `${entry.queryTemplateId}:${entry.queryTemplate}`,
      entry,
    ])
  ).values()).slice(0, 12);
  const sourceRows = [
    ["Search plan", plan.generatedFrom.searchPlan],
    ["Search matrix", plan.generatedFrom.searchMatrix ?? "not configured"],
    ["Target categories", plan.generatedFrom.targetCategories ?? "not configured"],
    ["Query templates", plan.generatedFrom.queryTemplates ?? "not configured"],
    [
      "Candidate batches",
      plan.generatedFrom.batches.length > 0 ?
        plan.generatedFrom.batches.join(", ") :
        "none",
    ],
    [
      "Prior runs",
      plan.generatedFrom.runs.length > 0 ?
        `${plan.generatedFrom.runs.length} recorded run files` :
        "none",
    ],
  ] as const;

  return (
    <div className="search-candidate-panel">
      <div className="intake-state-grid">
        <StateRow label="Launch cities" value={plan.summary.launchCities.join(", ")} />
        <StateRow label="Planned launch queries" value={String(plan.summary.launchCityPlanned)} />
        <StateRow label="Fresh skipped" value={String(plan.summary.launchCitySkippedFresh)} />
        <StateRow label="Fresh for" value={plan.freshForDays ? `${plan.freshForDays} days` : "not configured"} />
        <StateRow label="As of" value={plan.asOf ?? "unknown"} />
        <StateRow label="Plan source" value={plan.generatedFrom.searchPlan} />
      </div>

      <div className="intake-tags">
        {plan.launchCities.map((city) => (
          <span
            className={`intake-tag ${city.missingCategoryIds.length > 0 ? "muted" : ""}`}
            key={city.citySlug}
          >
            {city.city}: {city.categoryIds.length} categories
          </span>
        ))}
      </div>

      <div className="quality-row warning">
        <Lock size={16} strokeWidth={1.9} />
        <div>
          <strong>Repo-owned search configuration</strong>
          <span>{plan.commands.configure}</span>
          <span>Change the files below, regenerate the plan, then capture and ingest provider results.</span>
        </div>
      </div>

      <div className="intake-section">
        <div className="intake-section-title">Configuration Sources</div>
        <div className="intake-state-grid">
          {sourceRows.map(([label, value]) => (
            <StateRow key={label} label={label} value={value} />
          ))}
        </div>
      </div>

      <div className="intake-section">
        <div className="intake-section-title">Launch Search Terms</div>
        <div className="intake-tags">
          {launchQueryTemplates.length === 0 ? (
            <span className="intake-tag muted">No launch search terms planned.</span>
          ) : (
            launchQueryTemplates.map((entry) => (
              <span
                className="intake-tag muted"
                key={`${entry.queryTemplateId}-${entry.queryTemplate}`}
              >
                {entry.queryTemplateId}: {entry.queryTemplate}
              </span>
            ))
          )}
        </div>
      </div>

      <div className="intake-section">
        <div className="intake-section-title">Operator Commands</div>
        <div className="command-stack">
          {Object.entries(plan.commands).map(([label, command]) => (
            <div className="command-row" key={label}>
              <span>{label}</span>
              <code>{command}</code>
            </div>
          ))}
        </div>
      </div>

      {plan.summary.missingLaunchCityCategories.length > 0 ? (
        <div className="intake-section">
          <div className="intake-section-title">Missing launch categories</div>
          <div className="intake-gate-list">
            {plan.summary.missingLaunchCityCategories.map((missing) => (
              <div
                className="intake-gate blocked"
                key={`${missing.citySlug}-${missing.categoryId}`}
              >
                <FileWarning size={15} strokeWidth={1.9} />
                <div>
                  <strong>{missing.city}</strong>
                  <span>{missing.categoryId}</span>
                </div>
              </div>
            ))}
          </div>
        </div>
      ) : null}

      <div className="search-candidate-list">
        {launchEntries.map((entry) => (
          <article className="search-candidate-card" key={entry.runKey}>
            <header className="search-candidate-header">
              <div>
                <div className="intake-eyebrow">
                  {entry.city} / {entry.categoryId.replaceAll("_", " ")}
                </div>
                <h3>{entry.renderedQuery}</h3>
              </div>
              <span className="intake-badge">
                {entry.planKind.replaceAll("_", " ")}
              </span>
            </header>
            <div className="intake-state-grid">
              <StateRow label="Template" value={entry.queryTemplateId} />
              <StateRow label="Template text" value={entry.queryTemplate} />
              <StateRow label="Source" value={entry.source} />
              <StateRow label="Run key" value={entry.runKey} />
              <StateRow label="Candidate" value={entry.candidateName ?? "generic city search"} />
              <StateRow label="Searched" value={entry.searchedAt ?? "not captured"} />
              <StateRow label="Existing run" value={entry.existingRunFile ?? "none"} />
              <StateRow label="Fingerprint" value={entry.resultFingerprint ?? "none"} />
            </div>
          </article>
        ))}
        {launchEntries.length === 0 ? (
          <div className="empty-row">
            <FileWarning size={16} strokeWidth={1.9} />
            <span>No planned launch-city discovery queries</span>
          </div>
        ) : null}
      </div>

      {skippedEntries.length > 0 ? (
        <div className="intake-section">
          <div className="intake-section-title">Fresh skipped queries</div>
          <div className="search-candidate-list">
            {skippedEntries.map((entry) => (
              <article className="search-candidate-card" key={entry.runKey}>
                <header className="search-candidate-header">
                  <div>
                    <div className="intake-eyebrow">
                      {entry.city} / {entry.categoryId.replaceAll("_", " ")}
                    </div>
                    <h3>{entry.renderedQuery}</h3>
                  </div>
                  <span className="intake-badge">fresh</span>
                </header>
                <div className="intake-state-grid">
                  <StateRow label="Run key" value={entry.runKey} />
                  <StateRow label="Searched" value={entry.searchedAt ?? "unknown"} />
                  <StateRow label="Existing run" value={entry.existingRunFile ?? "none"} />
                  <StateRow label="Fingerprint" value={entry.resultFingerprint ?? "none"} />
                </div>
              </article>
            ))}
          </div>
        </div>
      ) : null}
    </div>
  );
}

function OrganizerPublishingContractsView({
  contracts,
}: {
  contracts: Intake.OrganizerPublishingContracts;
}) {
  return (
    <div className="search-candidate-panel">
      <div className="search-candidate-list">
        {Object.entries(contracts).map(([key, contract]) => (
          <article className="search-candidate-card" key={key}>
            <header className="search-candidate-header">
              <div>
                <div className="intake-eyebrow">
                  {contract.intakeTarget} / {contract.writeCallable}
                </div>
                <h3>{contract.callablePayloadSchema}</h3>
              </div>
              <span className="intake-badge ready">schema source</span>
            </header>
            <div className="intake-state-grid">
              <StateRow label="Firestore" value={contract.firestoreSchema} />
              <StateRow label="Generated payload" value={contract.generatedCallablePayload} />
              <StateRow label="Callable" value={contract.writeCallable} />
            </div>
            <div className="intake-tags">
              {contract.projectionNotes.map((note: string) => (
                <span className="intake-tag muted" key={note}>
                  {note}
                </span>
              ))}
            </div>
          </article>
        ))}
      </div>
    </div>
  );
}

function OrganizerSourceMentionResolutionView({
  resolution,
}: {
  resolution: Intake.OrganizerSourceMentionResolution;
}) {
  const clusters = resolution.resolutionClusters.clusters.slice(0, 8);
  const reviewPackets = resolution.reviewPackets.packets.slice(0, 8);
  const llmQueue = resolution.resolutionClusters.llmReviewQueue.slice(0, 6);
  const promptQueue = resolution.llmPromptQueue.requests.slice(0, 6);
  const blockingKeys = resolution.policy.blockingKeys.slice(0, 10);
  const stableProviderPlatforms =
    resolution.policy.hardKeyPolicy?.stableProviderEventPlatforms ?? [];
  const thresholds = Object.entries(resolution.policy.thresholds);

  return (
    <div className="search-candidate-panel">
      <div className="intake-state-grid">
        <StateRow
          label="Source artifacts"
          value={String(resolution.sourceArtifacts.summary.artifacts)}
        />
        <StateRow
          label="Mentions"
          value={String(resolution.extractedMentions.summary.mentions)}
        />
        <StateRow
          label="Candidates"
          value={String(resolution.resolutionCandidates.summary.candidates)}
        />
        <StateRow
          label="Clusters"
          value={String(resolution.resolutionClusters.summary.clusters)}
        />
        <StateRow
          label="Human review"
          value={String(resolution.reviewPackets.summary.humanReviewRequired)}
        />
        <StateRow label="LLM status" value={resolution.policy.llm.status} />
        <StateRow
          label="Prompt payloads"
          value={String(resolution.llmPromptQueue.summary.requests)}
        />
      </div>

      <div className="quality-row warning">
        <Lock size={16} strokeWidth={1.9} />
        <div>
          <strong>Canonical write boundary</strong>
          <span>{resolution.policy.canonicalBoundary.generatedCandidates}</span>
          <span>{resolution.policy.canonicalBoundary.platformVerifiedMeaning}</span>
        </div>
      </div>

      <div className="intake-section">
        <div className="intake-section-title">Editable Resolution Policy</div>
        <div className="intake-tags">
          {thresholds.map(([key, value]) => (
            <span className="intake-tag muted" key={key}>
              {key}: {value}
            </span>
          ))}
          {blockingKeys.map((key) => (
            <span className="intake-tag muted" key={key.id}>
              {key.id} / {key.strength}
            </span>
          ))}
          {stableProviderPlatforms.length > 0 ? (
            <span className="intake-tag muted">
              provider hard keys: {stableProviderPlatforms.join(", ")}
            </span>
          ) : null}
        </div>
      </div>

      <div className="intake-section">
        <div className="intake-section-title">Resolution review packets</div>
        <div className="search-candidate-list">
          {reviewPackets.map((packet) => (
            <article className="search-candidate-card" key={packet.packetId}>
              <header className="search-candidate-header">
                <div>
                  <div className="intake-eyebrow">
                    {packet.entityType} / {packet.recommendedAction.replaceAll("_", " ")}
                  </div>
                  <h3>{packet.packetId}</h3>
                </div>
                <span
                  className={`intake-badge ${
                    packet.humanReviewRequired ? "blocked" : "ready"
                  }`}
                >
                  {packet.resolutionState.replaceAll("_", " ")}
                </span>
              </header>
              <div className="intake-state-grid">
                <StateRow label="Score" value={String(packet.score)} />
                <StateRow label="Candidates" value={String(packet.candidateIds.length)} />
                <StateRow label="Mentions" value={String(packet.mentionIds.length)} />
                <StateRow
                  label="LLM"
                  value={packet.llmReview.status.replaceAll("_", " ")}
                />
              </div>
              <div className="intake-tags">
                {Object.entries(packet.checklist).map(([key, value]) => (
                  <span className="intake-tag muted" key={key}>
                    {key}: {String(value)}
                  </span>
                ))}
                {packet.topSignals.slice(0, 5).map((signal) => (
                  <span className="intake-tag" key={signal}>
                    {signal.replaceAll("_", " ")}
                  </span>
                ))}
                {packet.conflicts.map((conflict) => (
                  <span className="intake-tag muted" key={conflict}>
                    conflict: {conflict.replaceAll("_", " ")}
                  </span>
                ))}
              </div>
            </article>
          ))}
          {reviewPackets.length === 0 ? (
            <div className="empty-row">
              <FileWarning size={16} strokeWidth={1.9} />
              <span>No source resolution review packets have been generated yet.</span>
            </div>
          ) : null}
        </div>
      </div>

      <div className="search-candidate-list">
        {clusters.map((cluster) => (
          <article className="search-candidate-card" key={cluster.clusterId}>
            <header className="search-candidate-header">
              <div>
                <div className="intake-eyebrow">
                  {cluster.entityType} / {cluster.scoreBand.replaceAll("_", " ")}
                </div>
                <h3>{cluster.displayNames.slice(0, 3).join(" / ") || cluster.clusterId}</h3>
              </div>
              <span className={`intake-badge ${sourceResolutionTone(cluster.resolutionState)}`}>
                {cluster.resolutionState.replaceAll("_", " ")}
              </span>
            </header>
            <div className="intake-state-grid">
              <StateRow label="Score" value={String(cluster.score)} />
              <StateRow label="Mentions" value={String(cluster.mentionIds.length)} />
              <StateRow label="Cities" value={cluster.cities.join(", ") || "unknown"} />
              <StateRow label="Dates" value={cluster.dates.join(", ") || "unknown"} />
              <StateRow label="LLM" value={cluster.llmReview.status.replaceAll("_", " ")} />
            </div>
            <div className="intake-tags">
              {cluster.hardSignals.map((signal) => (
                <span className="intake-tag" key={signal}>
                  {signal}
                </span>
              ))}
              {cluster.matchingSignals.slice(0, 6).map((signal) => (
                <span className="intake-tag muted" key={signal}>
                  {signal.replaceAll("_", " ")}
                </span>
              ))}
              {cluster.conflictingSignals.map((signal) => (
                <span className="intake-tag muted" key={signal}>
                  conflict: {signal.replaceAll("_", " ")}
                </span>
              ))}
            </div>
            {cluster.publishBoundary ? (
              <div className="quality-row">
                <FileWarning size={16} strokeWidth={1.9} />
                <div>
                  <strong>Projection boundary</strong>
                  <span>{cluster.publishBoundary}</span>
                </div>
              </div>
            ) : null}
          </article>
        ))}
        {clusters.length === 0 ? (
          <div className="empty-row">
            <FileWarning size={16} strokeWidth={1.9} />
            <span>No source mentions have been captured for resolution yet.</span>
          </div>
        ) : null}
      </div>

      {llmQueue.length > 0 ? (
        <div className="intake-section">
          <div className="intake-section-title">LLM Review Queue</div>
          <div className="intake-tags">
            {llmQueue.map((request) => (
              <span className="intake-tag muted" key={request.clusterId}>
                {request.clusterId}: {request.status} / {request.promptVersion}
              </span>
            ))}
          </div>
        </div>
      ) : null}

      <div className="intake-section">
        <div className="intake-section-title">LLM Prompt Queue</div>
        <div className="quality-row warning">
          <Lock size={16} strokeWidth={1.9} />
          <div>
            <strong>{resolution.llmPromptQueue.policy.status.replaceAll("_", " ")}</strong>
            <span>{resolution.llmPromptQueue.policy.note}</span>
          </div>
        </div>
        <div className="intake-tags">
          {promptQueue.map((request) => (
            <span className="intake-tag muted" key={request.requestId}>
              {request.clusterId}: {request.status} / {request.promptVersion}
            </span>
          ))}
          {promptQueue.length === 0 ? (
            <span className="intake-tag muted">No prompt payloads queued.</span>
          ) : null}
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
  candidate: Intake.OrganizerSearchCandidate;
  commands: Intake.OrganizerSearchCandidateCommands;
  inFlight: boolean;
  localCuration?: AdminRecordOrganizerCurationResponse;
  onAttachCandidate: (candidate: Intake.OrganizerSearchCandidate) => void;
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
            <AdminButton
              disabled={!canAttach || inFlight}
              onClick={() => onAttachCandidate(candidate)}
            >
              {inFlight ? "Recording" : "Attach surface"}
            </AdminButton>
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
    candidate: Intake.OrganizerExternalEventCandidate,
    decision: OrganizerEventCandidateDecision
  ) => void;
  onNoteChange: (candidateId: string, note: string) => void;
  queue: Intake.OrganizerExternalEventCandidateQueue;
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
  plan: Intake.OrganizerExternalEventImportPlan;
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
  forms: Record<string, Intake.OrganizerLocationResolutionFormState>;
  inFlight: Record<string, boolean>;
  localResolutions: Record<string, AdminResolveOrganizerEventLocationResponse>;
  onFormChange: (
    taskId: string,
    form: Intake.OrganizerLocationResolutionFormState
  ) => void;
  onResolve: (task: Intake.OrganizerExternalEventLocationResolutionTask) => void;
  queue: Intake.OrganizerExternalEventLocationResolutionQueue;
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
                <TextField
                  label="Name"
                  onChange={(name) =>
                    onFormChange(task.taskId, {...form, name})}
                  value={form.name}
                />
                <TextField
                  label="Address"
                  onChange={(address) =>
                    onFormChange(task.taskId, {...form, address})}
                  value={form.address}
                />
                <TextField
                  label="Place ID"
                  onChange={(placeId) =>
                    onFormChange(task.taskId, {...form, placeId})}
                  value={form.placeId}
                />
                <TextField
                  inputMode="decimal"
                  label="Latitude"
                  onChange={(latitude) =>
                    onFormChange(task.taskId, {...form, latitude})}
                  value={form.latitude}
                />
                <TextField
                  inputMode="decimal"
                  label="Longitude"
                  onChange={(longitude) =>
                    onFormChange(task.taskId, {...form, longitude})}
                  value={form.longitude}
                />
                <TextField
                  className="field-control span-2"
                  label="Resolution notes"
                  onChange={(notes) =>
                    onFormChange(task.taskId, {...form, notes})}
                  value={form.notes}
                />
                <TextareaField
                  className="field-control span-2"
                  label="Review note"
                  onChange={(note) =>
                    onFormChange(task.taskId, {...form, note})}
                  rows={2}
                  value={form.note}
                />
              </div>

              <div className="search-candidate-actions">
                <AdminButton
                  disabled={
                    inFlight[task.taskId] === true ||
                    localResolution?.resolutionStatus === "resolved"
                  }
                  onClick={() => onResolve(task)}
                >
                  {localResolution?.resolutionStatus === "resolved" ?
                    "Resolved" :
                    inFlight[task.taskId] ? "Saving..." : "Resolve location"}
                </AdminButton>
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
  plan: Intake.OrganizerExternalEventImportExecutionPlan;
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
  candidate: Intake.OrganizerExternalEventCandidate;
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
            <AdminButton
              disabled={isDeciding}
              onClick={() => onDecision("approve_for_import")}
              variant="primary"
            >
              {inFlightDecision === "approve_for_import" ?
                "Approving" :
                "Approve future import"}
            </AdminButton>
            <AdminButton
              disabled={isDeciding}
              onClick={() => onDecision("hold")}
            >
              {inFlightDecision === "hold" ? "Holding" : "Hold"}
            </AdminButton>
            <AdminButton
              disabled={isDeciding}
              onClick={() => onDecision("reject")}
            >
              {inFlightDecision === "reject" ? "Rejecting" : "Reject"}
            </AdminButton>
          </div>
        </div>
      )}
    </article>
  );
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
  curationForm: Intake.OrganizerCurationFormState;
  curationInFlight: boolean;
  curationResult?: AdminRecordOrganizerCurationResponse;
  entityOptions: Intake.OrganizerIntakeItem[];
  inFlightDecision?: OrganizerIntakeDecision;
  item: Intake.OrganizerIntakeItem;
  localDecision?: AdminDecideOrganizerIntakeResponse;
  manualReportsAcknowledged: boolean;
  note: string;
  onCurationFormChange: (form: Intake.OrganizerCurationFormState) => void;
  onCurationSubmit: (form: Intake.OrganizerCurationFormState) => void;
  onDecision: (decision: OrganizerIntakeDecision) => void;
  onManualReportsAcknowledgedChange: (checked: boolean) => void;
  onNoteChange: (note: string) => void;
  publicationPacket?: Intake.OrganizerPublicationReviewPacket;
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
              <CheckboxField
                checked={manualReportsAcknowledged}
                className="intake-checkbox-row"
                disabled={isDeciding}
                label="Manual reports reviewed as prompts, not identity proof."
                onChange={onManualReportsAcknowledgedChange}
              />
            ) : null}
            <div className="intake-decision-actions">
              <AdminButton
                disabled={
                  !approvalReady ||
                  isDeciding ||
                  (manualReportCount > 0 && !manualReportsAcknowledged)
                }
                onClick={() => onDecision("approve_public")}
                variant="primary"
              >
                {inFlightDecision === "approve_public" ?
                  "Approving" :
                  "Approve public"}
              </AdminButton>
              <AdminButton
                disabled={isDeciding}
                onClick={() => onDecision("hold")}
              >
                {inFlightDecision === "hold" ? "Holding" : "Hold"}
              </AdminButton>
              <AdminButton
                disabled={isDeciding}
                onClick={() => onDecision("suppress")}
              >
                {inFlightDecision === "suppress" ? "Suppressing" : "Suppress"}
              </AdminButton>
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
  form: Intake.OrganizerCurationFormState;
  inFlight: boolean;
  item: Intake.OrganizerIntakeItem;
  localCuration?: AdminRecordOrganizerCurationResponse;
  onChange: (form: Intake.OrganizerCurationFormState) => void;
  onSubmit: (form: Intake.OrganizerCurationFormState) => void;
  targetOptions: Intake.OrganizerIntakeItem[];
}) {
  const surfaceOptions = item.surfaces.length > 0 ?
    item.surfaces.map((surface) => surface.surfaceId) :
    [""];
  const targetEntityOptions = targetOptions
    .map((option) => option.entityId)
    .filter((entityId) => entityId !== item.entityId);
  const update = <K extends keyof Intake.OrganizerCurationFormState>(
    key: K,
    value: Intake.OrganizerCurationFormState[K]
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
        <AdminButton
          disabled={inFlight}
          onClick={() => onSubmit(form)}
          variant="primary"
        >
          {inFlight ? "Recording" : "Record curation"}
        </AdminButton>
      </div>
    </div>
  );
}

function eventCandidateLocation(candidate: Intake.OrganizerExternalEventCandidate) {
  return [
    candidate.location.name,
    candidate.location.address,
    candidate.location.citySlug,
    candidate.location.countryCode,
  ].filter(Boolean).join(" / ") || "unknown";
}
