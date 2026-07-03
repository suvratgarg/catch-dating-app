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
import {
  AdminButton,
  AdminMetricCard,
  AdminMetricGrid,
  AdminTag,
  AlertRow,
  EmptyState,
  Panel,
  QualityList,
  QualityRow,
  SelectField,
  StateRow,
  StatusChip,
  TextareaField,
  TextField,
  AdminCommandRow,
  AdminCommandStack,
  AdminEyebrow,
  AdminGuardrailList,
  AdminIntakeGate,
  AdminIntakeGateList,
  AdminIntakeDecisionActions,
  AdminIntakeDecisionBox,
  AdminIntakeDecisionState,
  AdminIntakeLayout,
  AdminIntakeSourceList,
  AdminTagList,
  AdminIntakeSection,
  AdminIntakeSectionTitle,
  AdminOrganizerCurationControlGrid,
  AdminOrganizerCurationControlSection,
  AdminOrganizerIntakeBadges,
  AdminOrganizerIntakeCard,
  AdminOrganizerIntakeCardHeader,
  AdminOrganizerIntakeCheckboxField,
  AdminOrganizerIntakeCurationPanel,
  AdminOrganizerIntakeList,
  AdminOrganizerIntakeSurfaceGrid,
  AdminOrganizerLocationResolutionForm,
  AdminOrganizerPolicyGapColumns,
  AdminOrganizerSurfaceList,
  AdminOrganizerSurfaceRow,
  AdminSearchCandidateActions,
  AdminSearchCandidateCard,
  AdminSearchCandidateHeader,
  AdminSearchCandidateList,
  AdminSearchCandidatePanel,
  AdminSearchCandidateSnippet,
  AdminSurfacePreview,
  AdminIntakeStateGrid,
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
import {
  type OrganizerIntakeController,
  useOrganizerIntakeController,
} from "../controllers/useOrganizerIntakeController";
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
import {useAdminFeedback} from "../../../../shared/feedback/AdminFeedbackContext";

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

export function OrganizerIntakeScreen() {
  const {setError: onError, setNotice: onNotice} = useAdminFeedback();
  const controller = useOrganizerIntakeController({onError, onNotice});

  return <OrganizerIntakeWorkspace controller={controller} />;
}

export function OrganizerIntakeWorkspace({
  controller,
}: {
  controller: OrganizerIntakeController;
}) {
  const {
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
    setCurationForms,
    setDecisionNotes,
    setEventDecisionNotes,
    setLocationResolutionForms,
    setManualReportAcknowledgements,
    setPolicyDecisionNotes,
  } = controller;

  return (
    <>
      <AdminMetricGrid ariaLabel="Organizer intake metrics">
        {metrics.map((metric) => (
          <AdminMetricCard
            key={metric.label}
            label={metric.label}
            tone={metric.label === "Blocked" ? "attention" : "normal"}
            value={metric.value.toLocaleString()}
            variant="tile"
          />
        ))}
      </AdminMetricGrid>

      <AdminIntakeLayout>
        <Panel
          span={2}
          icon={<Settings2 size={18} strokeWidth={1.9} />}
          title="Workflow readiness"
          action={bridge.workflowReadiness.status.replaceAll("_", " ")}
        >
          <OrganizerWorkflowReadinessView readiness={bridge.workflowReadiness} />
        </Panel>

        <Panel
          span={2}
          icon={<FileWarning size={18} strokeWidth={1.9} />}
          title="Operator action queue"
          action={`${bridge.operatorActionQueue.summary.actions} actions`}
        >
          <OrganizerOperatorActionQueueView queue={bridge.operatorActionQueue} />
        </Panel>

        <Panel
          span={2}
          icon={<Activity size={18} strokeWidth={1.9} />}
          title="Operational health"
          action={bridge.operationalHealth.summary.healthStatus.replaceAll("_", " ")}
        >
          <OrganizerOperationalHealthView health={bridge.operationalHealth} />
        </Panel>

        <Panel
          span={2}
          icon={<CheckCircle2 size={18} strokeWidth={1.9} />}
          title="Pending work coverage"
          action={bridge.pendingWorkCoverage.summary.status.replaceAll("_", " ")}
        >
          <OrganizerPendingWorkCoverageView
            coverage={bridge.pendingWorkCoverage}
          />
        </Panel>

        <Panel
          span={2}
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
          span={2}
          icon={<FileWarning size={18} strokeWidth={1.9} />}
          title="Reviewed answer packets"
          action={bridge.reviewedDecisionAnswerPackets.summary.status.replaceAll("_", " ")}
        >
          <OrganizerReviewedDecisionAnswerPacketsView
            register={bridge.reviewedDecisionAnswerPackets}
          />
        </Panel>

        <Panel
          span={2}
          icon={<RefreshCw size={18} strokeWidth={1.9} />}
          title="Promotion execution"
          action={bridge.promotionExecutionPacket.summary.status.replaceAll("_", " ")}
        >
          <OrganizerPromotionExecutionView
            packet={bridge.promotionExecutionPacket}
          />
        </Panel>

        <Panel
          span={2}
          icon={<Users size={18} strokeWidth={1.9} />}
          title="Canonical host registry"
          action={`${bridge.canonicalHostEntities.summary.entities} entities`}
        >
          <OrganizerCanonicalHostRegistryView
            registry={bridge.canonicalHostEntities}
          />
        </Panel>

        <Panel
          span={2}
          icon={<Database size={18} strokeWidth={1.9} />}
          title="Canonical evidence index"
          action={`${bridge.canonicalEvidenceIndex.summary.resolvedArtifactRefs} resolved`}
        >
          <OrganizerCanonicalEvidenceIndexView
            index={bridge.canonicalEvidenceIndex}
          />
        </Panel>

        <Panel
          span={2}
          icon={<CheckCircle2 size={18} strokeWidth={1.9} />}
          title="Publication review packets"
          action={`${bridge.publicationReviewPackets.summary.readyForManualPublicationReview} ready`}
        >
          <OrganizerPublicationReviewPacketsView
            packets={bridge.publicationReviewPackets}
          />
        </Panel>

        <Panel
          span={2}
          icon={<LineChart size={18} strokeWidth={1.9} />}
          title="Publication impact preview"
          action={`${bridge.publicationDecisionImpactPreview.summary.wouldPublish} would publish`}
        >
          <OrganizerPublicationImpactPreviewView
            preview={bridge.publicationDecisionImpactPreview}
          />
        </Panel>

        <Panel
          span={2}
          icon={<Database size={18} strokeWidth={1.9} />}
          title="Claim-target sync preview"
          action={`${bridge.claimTargetSyncPreview.summary.writesNeeded} writes`}
        >
          <OrganizerClaimTargetSyncPreviewView
            preview={bridge.claimTargetSyncPreview}
          />
        </Panel>

        <Panel
          span={2}
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
          span={2}
          icon={<FileWarning size={18} strokeWidth={1.9} />}
          title="Policy decision packets"
          action={`${bridge.policyDecisionPackets.summary.unansweredQuestions} inputs`}
        >
          <OrganizerPolicyDecisionPacketsView
            packets={bridge.policyDecisionPackets}
          />
        </Panel>

        <Panel
          span={2}
          icon={<Clock3 size={18} strokeWidth={1.9} />}
          title="Event crawl run plan"
          action={`${bridge.crawlRunPlan.summary.blocked} blocked`}
        >
          <OrganizerCrawlRunPlanView plan={bridge.crawlRunPlan} />
        </Panel>

        <Panel
          span={2}
          icon={<Database size={18} strokeWidth={1.9} />}
          title="Raw artifact storage"
          action={`${bridge.rawArtifactStorage.summary.remoteUploadBlocked} blocked`}
        >
          <OrganizerRawArtifactStorageView
            manifest={bridge.rawArtifactStorage}
          />
        </Panel>

        <Panel
          span={2}
          icon={<FolderSearch size={18} strokeWidth={1.9} />}
          title="Discovery search plan"
          action={`${bridge.discoverySearchPlan.summary.launchCityPlanned} launch queries`}
        >
          <OrganizerDiscoverySearchPlanView
            plan={bridge.discoverySearchPlan}
          />
        </Panel>

        <Panel
          span={2}
          icon={<FileWarning size={18} strokeWidth={1.9} />}
          title="Publishing contract anchors"
          action="app + website schemas"
        >
          <OrganizerPublishingContractsView
            contracts={bridge.publishingContracts}
          />
        </Panel>

        <Panel
          span={2}
          icon={<LineChart size={18} strokeWidth={1.9} />}
          title="Source mention resolution"
          action={`${bridge.sourceMentionResolution.resolutionClusters.summary.clusters} clusters`}
        >
          <OrganizerSourceMentionResolutionView
            resolution={bridge.sourceMentionResolution}
          />
        </Panel>

        <Panel
          span={2}
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
          span={2}
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
          span={2}
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
          span={2}
          icon={<Database size={18} strokeWidth={1.9} />}
          title="External event import plan"
          action={bridge.externalEventImportPlan.policy.status}
        >
          <OrganizerExternalEventImportPlanView
            plan={bridge.externalEventImportPlan}
          />
        </Panel>

        <Panel
          span={2}
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
          <AdminGuardrailList>
            {bridge.guardrails.map((guardrail) => (
              <QualityRow
                key={guardrail}
                tone="warning"
                icon={<FileWarning size={16} strokeWidth={1.9} />}>
                <strong>{guardrail}</strong>
              </QualityRow>
            ))}
          </AdminGuardrailList>
          <AdminIntakeSourceList>
            {Object.entries(bridge.generatedFrom).map(([label, source]) => (
              <StateRow key={label} label={label} value={source} />
            ))}
          </AdminIntakeSourceList>
          <AdminOrganizerIntakeCurationPanel>
            <AdminIntakeSectionTitle>Dedupe curation</AdminIntakeSectionTitle>
            <AdminIntakeStateGrid>
              <StateRow label="Operations" value={String(bridge.curation.summary.operations)} />
              <StateRow label="Attached" value={String(bridge.curation.summary.attachedSurfaces ?? 0)} />
              <StateRow label="Merges" value={String(bridge.curation.summary.merges)} />
              <StateRow label="Surface decisions" value={String(bridge.curation.summary.surfaceDecisions)} />
              <StateRow label="Splits" value={String(bridge.curation.summary.splitSurfaces)} />
            </AdminIntakeStateGrid>
            <AdminCommandStack>
              {Object.entries(bridge.curation.commands).map(([label, command]) => (
                <AdminCommandRow key={label}>
                  <span>{label}</span>
                  <code>{command}</code>
                </AdminCommandRow>
              ))}
            </AdminCommandStack>
          </AdminOrganizerIntakeCurationPanel>
        </Panel>

        <Panel
          icon={<Activity size={18} strokeWidth={1.9} />}
          title="Event crawl readiness"
          action={bridge.crawlPlan.policy.status}
        >
          <AdminIntakeStateGrid>
            <StateRow label="Scheduler" value={bridge.crawlPlan.policy.schedulerEnabled ? "enabled" : "disabled"} />
            <StateRow label="Default policy" value={bridge.crawlPlan.policy.defaultSurfacePolicy} />
            <StateRow label="Capable" value={String(bridge.crawlPlan.summary.crawlCapableSurfaces)} />
            <StateRow label="Blocked" value={String(bridge.crawlPlan.summary.blockedSurfaces)} />
          </AdminIntakeStateGrid>

          <AdminTagList>
            {Object.entries(bridge.crawlPlan.summary.platforms)
              .sort(([left], [right]) => left.localeCompare(right))
              .map(([platform, count]) => (
                <AdminTag key={platform}>
                  {platform} x{count}
                </AdminTag>
              ))}
          </AdminTagList>

          <AdminGuardrailList>
            {bridge.crawlPlan.guardrails.map((guardrail) => (
              <QualityRow
                key={guardrail}
                tone="warning"
                icon={<Clock3 size={16} strokeWidth={1.9} />}>
                <strong>{guardrail}</strong>
              </QualityRow>
            ))}
          </AdminGuardrailList>

          <AdminIntakeSection>
            <AdminIntakeSectionTitle>Blockers</AdminIntakeSectionTitle>
            <AdminTagList>
              {Object.entries(bridge.crawlPlan.summary.blockers)
                .sort(([left], [right]) => left.localeCompare(right))
                .map(([blocker, count]) => (
                  <AdminTag key={blocker} tone="muted">
                    {blocker} x{count}
                  </AdminTag>
                ))}
            </AdminTagList>
          </AdminIntakeSection>
        </Panel>

        <Panel
          span={2}
          icon={<FolderSearch size={18} strokeWidth={1.9} />}
          title="Private entity queue"
          action={`${bridge.items.length} entities`}
        >
          <AdminOrganizerIntakeList>
            {bridge.items.length === 0 ? (
              <EmptyState icon={<CheckCircle2 size={16} strokeWidth={1.9} />}>
                Clear
              </EmptyState>
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
          </AdminOrganizerIntakeList>
        </Panel>
      </AdminIntakeLayout>
    </>
  );
}

function OrganizerWorkflowReadinessView({
  readiness,
}: {
  readiness: Intake.OrganizerWorkflowReadiness;
}) {
  return (
    <AdminSearchCandidatePanel>
      <AdminIntakeStateGrid>
        <StateRow label="Ready" value={String(readiness.summary.ready)} />
        <StateRow label="Review" value={String(readiness.summary.reviewNeeded)} />
        <StateRow label="Waiting" value={String(readiness.summary.waiting)} />
        <StateRow label="Policy" value={String(readiness.summary.policyNeeded)} />
      </AdminIntakeStateGrid>
      <AdminTagList>
        <AdminTag tone={readiness.summary.localPromotionPipelineReady ? "neutral" : "muted"}>
          local pipeline {readiness.summary.localPromotionPipelineReady ? "ready" : "blocked"}
        </AdminTag>
        <AdminTag tone={readiness.summary.publicProjectionReady ? "neutral" : "muted"}>
          public projection {readiness.summary.publicProjectionReady ? "ready" : "waiting"}
        </AdminTag>
        <AdminTag tone={readiness.summary.claimSyncReady ? "neutral" : "muted"}>
          claim sync {readiness.summary.claimSyncReady ? "ready" : "waiting"}
        </AdminTag>
        <AdminTag tone={readiness.summary.recurringCrawlEnabled ? "neutral" : "muted"}>
          crawl {readiness.summary.recurringCrawlEnabled ? "enabled" : "disabled"}
        </AdminTag>
      </AdminTagList>
      <AdminIntakeGateList>
        {readiness.gates.map((gate) => (
          <AdminIntakeGate
            tone={readinessGateTone(gate.status)}
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
          </AdminIntakeGate>
        ))}
      </AdminIntakeGateList>
      <AdminIntakeSection>
        <AdminIntakeSectionTitle>Commands</AdminIntakeSectionTitle>
        <AdminCommandStack>
          {Object.entries(readiness.commands).map(([label, command]) => (
            <AdminCommandRow key={label}>
              <span>{label}</span>
              <code>{command}</code>
            </AdminCommandRow>
          ))}
        </AdminCommandStack>
      </AdminIntakeSection>
    </AdminSearchCandidatePanel>
  );
}

function OrganizerOperatorActionQueueView({
  queue,
}: {
  queue: Intake.OrganizerOperatorActionQueue;
}) {
  const visibleActions = queue.actions.slice(0, 8);

  return (
    <AdminSearchCandidatePanel>
      <AdminIntakeStateGrid>
        <StateRow label="Actions" value={String(queue.summary.actions)} />
        <StateRow label="Admin" value={String(queue.summary.adminDecisionsRequired)} />
        <StateRow label="Policy" value={String(queue.summary.policyInputsRequired)} />
        <StateRow label="Waiting" value={String(queue.summary.waitingActions)} />
      </AdminIntakeStateGrid>
      <AdminTagList>
        {Object.entries(queue.summary.actionsByPriority).map(([priority, count]) => (
          <AdminTag key={priority} tone="muted">
            {priority} x{count}
          </AdminTag>
        ))}
        {Object.entries(queue.summary.actionsByType).map(([type, count]) => (
          <AdminTag key={type} tone="muted">
            {type.replaceAll("_", " ")} x{count}
          </AdminTag>
        ))}
      </AdminTagList>
      <QualityRow tone="warning" icon={<Lock size={16} strokeWidth={1.9} />}>
        <strong>{queue.guardrails[0]}</strong>
        <span>{queue.guardrails[1]}</span>
      </QualityRow>
      <AdminSearchCandidateList>
        {visibleActions.map((action) => (
          <AdminSearchCandidateCard key={action.actionId}>
            <AdminSearchCandidateHeader>
              <div>
                <AdminEyebrow>
                  {action.actionType.replaceAll("_", " ")} / {action.priority}
                </AdminEyebrow>
                <h3>{action.subjectName}</h3>
              </div>
              <StatusChip tone={action.status === "requires_admin_decision" ? "ready" : ""}>
                {action.status.replaceAll("_", " ")}
              </StatusChip>
            </AdminSearchCandidateHeader>

            <AdminIntakeStateGrid>
              <StateRow label="Subject" value={action.subjectId} />
              <StateRow label="Task" value={action.taskType.replaceAll("_", " ")} />
              <StateRow label="Options" value={String(action.decisionOptions.length)} />
              <StateRow label="Blockers" value={String(action.blockers.length)} />
            </AdminIntakeStateGrid>

            <QualityRow icon={<FileWarning size={16} strokeWidth={1.9} />}>
              <strong>{action.nextAction}</strong>
              <span>{action.detail}</span>
            </QualityRow>

            <AdminTagList>
              {action.decisionOptions.map((option) => (
                <AdminTag key={option}>
                  {option.replaceAll("_", " ")}
                </AdminTag>
              ))}
              {action.requiredAcknowledgements?.manualReportsReviewed ? (
                <AdminTag tone="muted">manual reports</AdminTag>
              ) : null}
              {(action.requiredInputs ?? []).slice(0, 6).map((input) => (
                <AdminTag key={input} tone="muted">
                  {input.replaceAll("_", " ")}
                </AdminTag>
              ))}
              {action.impact?.wouldIndex ? (
                <AdminTag>indexable</AdminTag>
              ) : null}
              {action.impact?.wouldCreateClaimTarget ? (
                <AdminTag>claim target</AdminTag>
              ) : null}
            </AdminTagList>

            <AdminCommandStack>
              {action.commands.slice(0, 3).map((command, index) => (
                <AdminCommandRow key={`${action.actionId}:${index}`}>
                  <span>{index === 0 ? "command" : "then"}</span>
                  <code>{command}</code>
                </AdminCommandRow>
              ))}
            </AdminCommandStack>
          </AdminSearchCandidateCard>
        ))}
      </AdminSearchCandidateList>
    </AdminSearchCandidatePanel>
  );
}

function OrganizerOperationalHealthView({
  health,
}: {
  health: Intake.OrganizerOperationalHealthReport;
}) {
  const visibleWorkstreams = health.workstreams.slice(0, 6);

  return (
    <AdminSearchCandidatePanel>
      <AdminIntakeStateGrid>
        <StateRow label="Status" value={health.summary.healthStatus.replaceAll("_", " ")} />
        <StateRow label="Workstreams" value={String(health.summary.workstreams)} />
        <StateRow label="Action" value={String(health.summary.actionRequiredWorkstreams)} />
        <StateRow label="Policy" value={String(health.summary.policyBlockedWorkstreams)} />
        <StateRow label="Waiting" value={String(health.summary.waitingWorkstreams)} />
        <StateRow label="Ready" value={String(health.summary.readyWorkstreams)} />
      </AdminIntakeStateGrid>
      <AdminTagList>
        {Object.entries(health.summary.workstreamsByPriority).map(([priority, count]) => (
          <AdminTag key={priority} tone="muted">
            {priority} x{count}
          </AdminTag>
        ))}
        {Object.entries(health.summary.workstreamsByStatus).map(([status, count]) => (
          <AdminTag key={status} tone="muted">
            {status.replaceAll("_", " ")} x{count}
          </AdminTag>
        ))}
      </AdminTagList>
      <QualityRow tone="warning" icon={<Lock size={16} strokeWidth={1.9} />}>
        <strong>{health.guardrails[0]}</strong>
        <span>{health.guardrails[1]}</span>
      </QualityRow>
      <AdminSearchCandidateList>
        {visibleWorkstreams.map((stream) => (
          <AdminSearchCandidateCard key={stream.id}>
            <AdminSearchCandidateHeader>
              <div>
                <AdminEyebrow>
                  {stream.priority} / {stream.id.replaceAll("_", " ")}
                </AdminEyebrow>
                <h3>{stream.label}</h3>
              </div>
              <StatusChip tone={healthStatusTone(stream.status)}>
                {stream.status.replaceAll("_", " ")}
              </StatusChip>
            </AdminSearchCandidateHeader>

            <AdminIntakeStateGrid>
              {Object.entries(stream.metrics).slice(0, 6).map(([metric, value]) => (
                <StateRow
                  key={metric}
                  label={metric.replaceAll("_", " ")}
                  value={formatHealthMetric(value)}
                />
              ))}
            </AdminIntakeStateGrid>

            {stream.nextActions.length > 0 ? (
              <QualityRow icon={<FileWarning size={16} strokeWidth={1.9} />}>
                <strong>{stream.nextActions[0]}</strong>
                {stream.nextActions.slice(1, 3).map((action) => (
                  <span key={action}>{action}</span>
                ))}
              </QualityRow>
            ) : null}

            <AdminTagList>
              {stream.blockers.slice(0, 6).map((blocker) => (
                <AdminTag key={blocker} tone="muted">
                  {blocker.replaceAll("_", " ")}
                </AdminTag>
              ))}
            </AdminTagList>

            <AdminCommandStack>
              {stream.commands.slice(0, 2).map((command, index) => (
                <AdminCommandRow key={`${stream.id}:${index}`}>
                  <span>{index === 0 ? "command" : "then"}</span>
                  <code>{command}</code>
                </AdminCommandRow>
              ))}
            </AdminCommandStack>
          </AdminSearchCandidateCard>
        ))}
      </AdminSearchCandidateList>
    </AdminSearchCandidatePanel>
  );
}

function OrganizerPendingWorkCoverageView({
  coverage,
}: {
  coverage: Intake.OrganizerPendingWorkCoverage;
}) {
  const visibleEntries = coverage.entries.slice(0, 8);

  return (
    <AdminSearchCandidatePanel>
      <AdminIntakeStateGrid>
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
      </AdminIntakeStateGrid>
      <AdminTagList>
        {coverage.summary.highestPriority ? (
          <AdminTag>
            highest {coverage.summary.highestPriority}
          </AdminTag>
        ) : null}
        {Object.entries(coverage.summary.coverageByStatus).map(([status, count]) => (
          <AdminTag key={status} tone="muted">
            {status.replaceAll("_", " ")} x{count}
          </AdminTag>
        ))}
        {Object.entries(coverage.summary.workstreamsByPriority).map(([priority, count]) => (
          <AdminTag key={priority} tone="muted">
            {priority} x{count}
          </AdminTag>
        ))}
      </AdminTagList>
      <QualityRow tone="warning" icon={<Lock size={16} strokeWidth={1.9} />}>
        <strong>{coverage.guardrails[0]}</strong>
        <span>{coverage.guardrails[1]}</span>
      </QualityRow>
      <AdminSearchCandidateList>
        {visibleEntries.map((entry) => (
          <AdminSearchCandidateCard key={entry.coverageId}>
            <AdminSearchCandidateHeader>
              <div>
                <AdminEyebrow>
                  {entry.priority} / {entry.workstreamId.replaceAll("_", " ")}
                </AdminEyebrow>
                <h3>{entry.label}</h3>
              </div>
              <StatusChip tone={coverageStatusTone(entry.coverageStatus)}>
                {entry.coverageStatus.replaceAll("_", " ")}
              </StatusChip>
            </AdminSearchCandidateHeader>

            <AdminIntakeStateGrid>
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
            </AdminIntakeStateGrid>

            {entry.nextActions.length > 0 ? (
              <QualityRow icon={<FileWarning size={16} strokeWidth={1.9} />}>
                <strong>{entry.nextActions[0]}</strong>
                {entry.nextActions.slice(1, 3).map((action) => (
                  <span key={action}>{action}</span>
                ))}
              </QualityRow>
            ) : null}

            <AdminTagList>
              {entry.pendingRequestIds.slice(0, 6).map((requestId) => (
                <AdminTag key={requestId}>
                  {requestId.replaceAll("_", " ")}
                </AdminTag>
              ))}
              {entry.followUpIds.slice(0, 6).map((followUpId) => (
                <AdminTag key={followUpId} tone="muted">
                  {followUpId.replaceAll("_", " ")}
                </AdminTag>
              ))}
              {entry.blockers.slice(0, 6).map((blocker) => (
                <AdminTag key={blocker} tone="muted">
                  {blocker}
                </AdminTag>
              ))}
            </AdminTagList>

            <AdminCommandStack>
              {entry.commands.slice(0, 3).map((command, index) => (
                <AdminCommandRow key={`${entry.coverageId}:${index}`}>
                  <span>{index === 0 ? "command" : "then"}</span>
                  <code>{command}</code>
                </AdminCommandRow>
              ))}
            </AdminCommandStack>
          </AdminSearchCandidateCard>
        ))}
      </AdminSearchCandidateList>
    </AdminSearchCandidatePanel>
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
    <AdminSearchCandidatePanel>
      <AdminIntakeStateGrid>
        <StateRow label="Inputs" value={String(request.summary.requests)} />
        <StateRow label="Admin" value={String(request.summary.adminPublicationRequests)} />
        <StateRow label="Policy" value={String(request.summary.policyDecisionRequests)} />
        <StateRow label="Questions" value={String(request.summary.requiredPolicyQuestions)} />
        <StateRow label="Manual acks" value={String(request.summary.manualPublicationAcknowledgements)} />
        <StateRow label="Follow-ups" value={String(request.summary.workflowFollowUps)} />
      </AdminIntakeStateGrid>
      <AdminTagList>
        {request.summary.highestPriority ? (
          <AdminTag>
            highest {request.summary.highestPriority}
          </AdminTag>
        ) : null}
        {Object.entries(request.summary.requestsByOwner).map(([owner, count]) => (
          <AdminTag key={owner} tone="muted">
            {owner.replaceAll("_", " ")} x{count}
          </AdminTag>
        ))}
        {Object.entries(request.summary.requestsByType).map(([type, count]) => (
          <AdminTag key={type} tone="muted">
            {type.replaceAll("_", " ")} x{count}
          </AdminTag>
        ))}
      </AdminTagList>
      <QualityRow tone="warning" icon={<Lock size={16} strokeWidth={1.9} />}>
        <strong>{request.guardrails[0]}</strong>
        <span>{request.guardrails[1]}</span>
      </QualityRow>
      <AdminSearchCandidateList>
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
            <AdminSearchCandidateCard key={input.requestId}>
              <AdminSearchCandidateHeader>
                <div>
                  <AdminEyebrow>
                    {input.requestType.replaceAll("_", " ")} / {input.priority}
                  </AdminEyebrow>
                  <h3>{input.subjectName}</h3>
                </div>
                <StatusChip tone={input.priority === "p0" ? "ready" : ""}>
                  {input.owner.replaceAll("_", " ")}
                </StatusChip>
              </AdminSearchCandidateHeader>
              <QualityRow icon={<FileWarning size={16} strokeWidth={1.9} />}>
                <strong>{input.prompt}</strong>
                <span>Safe default: {input.safeDefaultAction.replaceAll("_", " ")}</span>
              </QualityRow>
              <AdminIntakeStateGrid>
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
              </AdminIntakeStateGrid>
              <AdminTagList>
                {input.decisionOptions.map((option) => (
                  <AdminTag key={option}>
                    {option.replaceAll("_", " ")}
                  </AdminTag>
                ))}
                {input.requiredAcknowledgements?.manualReportsReviewed ? (
                  <AdminTag tone="muted">manual reports reviewed</AdminTag>
                ) : null}
                {(input.requiredAcknowledgements?.publicationChecklist ?? [])
                  .slice(0, 8)
                  .map((acknowledgement) => (
                    <AdminTag key={acknowledgement} tone="muted">
                      {acknowledgement.replaceAll("_", " ")}
                    </AdminTag>
                  ))}
                {(input.currentState?.riskFlags as string[] | undefined)
                  ?.slice(0, 8)
                  .map((flag) => (
                    <AdminTag key={flag} tone="muted">
                      {flag.replaceAll("_", " ")}
                    </AdminTag>
                  ))}
              </AdminTagList>
              {input.requiredInputs && input.requiredInputs.length > 0 ? (
                <AdminIntakeSection>
                  <AdminIntakeSectionTitle>Required Policy Inputs</AdminIntakeSectionTitle>
                  <AdminCommandStack>
                    {input.requiredInputs.slice(0, 6).map((requiredInput) => (
                      <AdminCommandRow key={requiredInput.questionId ?? requiredInput.prompt}>
                        <span>{requiredInput.input ?? "input"}</span>
                        <code>
                          {requiredInput.prompt} Default: {requiredInput.recommendedSafeDefault}
                        </code>
                      </AdminCommandRow>
                    ))}
                  </AdminCommandStack>
                </AdminIntakeSection>
              ) : null}
              {input.callableSubmission ? (
                <AdminIntakeSection>
                  <AdminIntakeSectionTitle>Callable Payloads</AdminIntakeSectionTitle>
                  <AdminIntakeStateGrid>
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
                  </AdminIntakeStateGrid>
                  <AdminCommandStack>
                    {Object.entries(input.callableSubmission.payloadsByDecision)
                      .slice(0, 4)
                      .map(([decision, payload]) => (
                        <AdminCommandRow key={`${input.requestId}:payload:${decision}`}>
                          <span>{decision.replaceAll("_", " ")}</span>
                          <code>{JSON.stringify(payload)}</code>
                        </AdminCommandRow>
                      ))}
                  </AdminCommandStack>
                  {submittedDecision ? (
                    <QualityRow tone="success" icon={<CheckCircle2 size={16} strokeWidth={1.9} />}>
                      <strong>
                        {pendingInputDecisionLabel(submittedDecision.decision)}
                      </strong>
                      <span>
                        {submittedDecision.decisionPath} / {pendingInputDecisionState(submittedDecision)}
                      </span>
                    </QualityRow>
                  ) : (
                    <AdminIntakeDecisionActions>
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
                    </AdminIntakeDecisionActions>
                  )}
                </AdminIntakeSection>
              ) : null}
              <AdminCommandStack>
                {input.commands.slice(0, 4).map((command, index) => (
                  <AdminCommandRow key={`${input.requestId}:${index}`}>
                    <span>{index === 0 ? "command" : "then"}</span>
                    <code>{command}</code>
                  </AdminCommandRow>
                ))}
              </AdminCommandStack>
            </AdminSearchCandidateCard>
          );
        })}
      </AdminSearchCandidateList>
      <AdminIntakeSection>
        <AdminIntakeSectionTitle>Workflow Follow-ups</AdminIntakeSectionTitle>
        <AdminSearchCandidateList>
          {visibleFollowUps.length === 0 ? (
            <EmptyState icon={<CheckCircle2 size={16} strokeWidth={1.9} />}>
              No follow-ups are pending.
            </EmptyState>
          ) : (
            visibleFollowUps.map((followUp) => (
              <AdminSearchCandidateCard key={followUp.followUpId}>
                <AdminSearchCandidateHeader>
                  <div>
                    <AdminEyebrow>
                      {followUp.priority} / {followUp.workstreamId.replaceAll("_", " ")}
                    </AdminEyebrow>
                    <h3>{followUp.label}</h3>
                  </div>
                  <StatusChip tone={healthStatusTone(followUp.status)}>
                    {followUp.status.replaceAll("_", " ")}
                  </StatusChip>
                </AdminSearchCandidateHeader>
                <QualityRow icon={<FileWarning size={16} strokeWidth={1.9} />}>
                  <strong>{followUp.nextActions[0] ?? "Review workflow state."}</strong>
                  {followUp.nextActions.slice(1, 3).map((action) => (
                    <span key={action}>{action}</span>
                  ))}
                </QualityRow>
                <AdminTagList>
                  {followUp.blockers.slice(0, 8).map((blocker) => (
                    <AdminTag key={blocker} tone="muted">
                      {blocker.replaceAll("_", " ")}
                    </AdminTag>
                  ))}
                </AdminTagList>
                <AdminCommandStack>
                  {followUp.commands.slice(0, 2).map((command, index) => (
                    <AdminCommandRow key={`${followUp.followUpId}:${index}`}>
                      <span>{index === 0 ? "command" : "then"}</span>
                      <code>{command}</code>
                    </AdminCommandRow>
                  ))}
                </AdminCommandStack>
              </AdminSearchCandidateCard>
            ))
          )}
        </AdminSearchCandidateList>
      </AdminIntakeSection>
    </AdminSearchCandidatePanel>
  );
}

function OrganizerReviewedDecisionAnswerPacketsView({
  register,
}: {
  register: Intake.OrganizerReviewedDecisionAnswerPacketRegister;
}) {
  const visibleEntries = register.entries.slice(0, 8);

  return (
    <AdminSearchCandidatePanel>
      <AdminIntakeStateGrid>
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
      </AdminIntakeStateGrid>
      <AdminTagList>
        <AdminTag tone="muted">
          root {register.generatedFrom.answerPacketsRoot}
        </AdminTag>
        <AdminTag tone="muted">
          source {register.generatedFrom.generatedAnswerPacket}
        </AdminTag>
        <AdminTag>
          fresh x{register.summary.sourceFresh}
        </AdminTag>
      </AdminTagList>
      <QualityRow tone="warning" icon={<Lock size={16} strokeWidth={1.9} />}>
        <strong>{register.guardrails[0]}</strong>
        <span>{register.guardrails[1]}</span>
      </QualityRow>
      <AdminSearchCandidateList>
        {visibleEntries.length === 0 ? (
          <EmptyState icon={<Clock3 size={16} strokeWidth={1.9} />}>
            No reviewed answer packets exist yet.
          </EmptyState>
        ) : (
          visibleEntries.map((entry) => (
            <AdminSearchCandidateCard key={entry.path}>
              <AdminSearchCandidateHeader>
                <div>
                  <AdminEyebrow>
                    {entry.sourceFreshness.replaceAll("_", " ")}
                  </AdminEyebrow>
                  <h3>{entry.path}</h3>
                </div>
                <StatusChip tone={entry.readyToApply ? "ready" : ""}>
                  {entry.status.replaceAll("_", " ")}
                </StatusChip>
              </AdminSearchCandidateHeader>

              <AdminIntakeStateGrid>
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
              </AdminIntakeStateGrid>

              {(entry.errors.length > 0 || entry.warnings.length > 0) ? (
                <QualityRow tone="warning" icon={<FileWarning size={16} strokeWidth={1.9} />}>
                  <strong>
                    {entry.errors[0] ?? entry.warnings[0]}
                  </strong>
                  {[...entry.errors.slice(1, 3), ...entry.warnings.slice(1, 3)]
                    .slice(0, 3)
                    .map((message) => (
                      <span key={message}>{message}</span>
                    ))}
                </QualityRow>
              ) : null}

              <AdminTagList>
                {entry.readyToApply ? (
                  <AdminTag>ready to apply</AdminTag>
                ) : null}
                {entry.awaitingAnswers ? (
                  <AdminTag tone="muted">awaiting answers</AdminTag>
                ) : null}
                {entry.stale ? (
                  <AdminTag tone="muted">stale source</AdminTag>
                ) : null}
                {entry.invalid ? (
                  <AdminTag tone="muted">invalid packet</AdminTag>
                ) : null}
              </AdminTagList>
            </AdminSearchCandidateCard>
          ))
        )}
      </AdminSearchCandidateList>
    </AdminSearchCandidatePanel>
  );
}

function OrganizerPromotionExecutionView({
  packet,
}: {
  packet: Intake.OrganizerPromotionExecutionPacket;
}) {
  const visiblePhases = packet.phases.slice(0, 8);

  return (
    <AdminSearchCandidatePanel>
      <AdminIntakeStateGrid>
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
      </AdminIntakeStateGrid>
      <AdminTagList>
        <AdminTag>
          admin pending x{packet.summary.pendingAdminDecisions}
        </AdminTag>
        <AdminTag tone="muted">
          policy pending x{packet.summary.pendingPolicyDecisions}
        </AdminTag>
        <AdminTag tone="muted">
          answer slots x{packet.summary.pendingAnswerSlots}
        </AdminTag>
        <AdminTag tone={packet.summary.reviewedAnswerPacketsReady > 0 ? "neutral" : "muted"}>
          ready packets x{packet.summary.reviewedAnswerPacketsReady}
        </AdminTag>
        <AdminTag tone="muted">
          reviewed packets x{packet.summary.reviewedAnswerPackets}
        </AdminTag>
        {packet.summary.reviewedAnswerPacketsStale > 0 ? (
          <AdminTag tone="muted">
            stale packets x{packet.summary.reviewedAnswerPacketsStale}
          </AdminTag>
        ) : null}
        {packet.summary.reviewedAnswerPacketsInvalid > 0 ? (
          <AdminTag tone="muted">
            invalid packets x{packet.summary.reviewedAnswerPacketsInvalid}
          </AdminTag>
        ) : null}
        <AdminTag tone="muted">
          guarded reads x{packet.summary.guardedRemoteReadPhases}
        </AdminTag>
        <AdminTag tone="muted">
          guarded writes x{packet.summary.guardedRemoteWritePhases}
        </AdminTag>
        {Object.entries(packet.summary.phasesByStatus).map(([status, count]) => (
          <AdminTag key={status} tone="muted">
            {status.replaceAll("_", " ")} x{count}
          </AdminTag>
        ))}
      </AdminTagList>
      <QualityRow tone="warning" icon={<Lock size={16} strokeWidth={1.9} />}>
        <strong>{packet.guardrails[0]}</strong>
        <span>{packet.guardrails[1]}</span>
      </QualityRow>
      <AdminSearchCandidateList>
        {visiblePhases.map((phase) => (
          <AdminSearchCandidateCard key={phase.phaseId}>
            <AdminSearchCandidateHeader>
              <div>
                <AdminEyebrow>
                  {phase.executionMode.replaceAll("_", " ")}
                </AdminEyebrow>
                <h3>{phase.label}</h3>
              </div>
              <StatusChip tone={promotionPhaseTone(phase.status)}>
                {phase.status.replaceAll("_", " ")}
              </StatusChip>
            </AdminSearchCandidateHeader>

            <AdminIntakeStateGrid>
              <StateRow label="Mode" value={phase.executionMode.replaceAll("_", " ")} />
              <StateRow label="Blockers" value={String(phase.blockers.length)} />
              <StateRow label="Outputs" value={String(phase.outputs.length)} />
              <StateRow label="Phase" value={phase.phaseId.replaceAll("_", " ")} />
            </AdminIntakeStateGrid>

            {phase.blockers.length > 0 ? (
              <QualityRow tone="warning" icon={<FileWarning size={16} strokeWidth={1.9} />}>
                <strong>{phase.blockers[0]}</strong>
                {phase.blockers.slice(1, 4).map((blocker) => (
                  <span key={blocker}>{blocker}</span>
                ))}
              </QualityRow>
            ) : (
              <QualityRow tone="success" icon={<CheckCircle2 size={16} strokeWidth={1.9} />}>
                <strong>Phase ready</strong>
                <span>Run only in the documented order.</span>
              </QualityRow>
            )}

            <AdminTagList>
              {phase.outputs.slice(0, 8).map((output) => (
                <AdminTag key={output} tone="muted">
                  {output}
                </AdminTag>
              ))}
            </AdminTagList>

            <AdminCommandStack>
              <AdminCommandRow>
                <span>command</span>
                <code>{phase.command}</code>
              </AdminCommandRow>
            </AdminCommandStack>
          </AdminSearchCandidateCard>
        ))}
      </AdminSearchCandidateList>
    </AdminSearchCandidatePanel>
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
    <AdminSearchCandidatePanel>
      <AdminIntakeStateGrid>
        <StateRow label="Gaps" value={String(register.summary.gaps)} />
        <StateRow label="Operational blockers" value={String(register.summary.decisionRequired)} />
        <StateRow label="Reviewed" value={String(register.summary.reviewDecisions)} />
        <StateRow label="Accepted" value={String(register.summary.reviewAccepted)} />
        <StateRow label="Held" value={String(register.summary.reviewHeld)} />
        <StateRow label="Rejected" value={String(register.summary.reviewRejected)} />
        <StateRow label="Invalid" value={String(register.summary.reviewInvalid)} />
        <StateRow label="Ready" value={String(register.summary.ready)} />
        <StateRow label="Disabled" value={String(register.summary.blockedByPolicy)} />
      </AdminIntakeStateGrid>
      <AdminTagList>
        {Object.entries(register.summary.gapsByArea).map(([area, count]) => (
          <AdminTag key={area} tone="muted">
            {area} x{count}
          </AdminTag>
        ))}
        {Object.entries(register.summary.gapsByDecisionStatus).map(([status, count]) => (
          <AdminTag key={status} tone="muted">
            {status.replaceAll("_", " ")} x{count}
          </AdminTag>
        ))}
        {register.guardrails.map((guardrail) => (
          <AdminTag key={guardrail} tone="muted">
            {guardrail}
          </AdminTag>
        ))}
      </AdminTagList>
      {register.errors && register.errors.length > 0 ? (
        <AdminGuardrailList>
          {register.errors.map((error) => (
            <QualityRow
              key={error}
              tone="warning"
              icon={<FileWarning size={16} strokeWidth={1.9} />}>
              <strong>{error}</strong>
            </QualityRow>
          ))}
        </AdminGuardrailList>
      ) : null}
      <AdminSearchCandidateList>
        {visibleGaps.map((gap) => {
          const localDecision = localDecisions[gap.gapId];
          const submittedDecision = localDecision?.decision ??
            gap.reviewDecision?.decision;
          const isDeciding = Boolean(inFlightDecisions[gap.gapId]);

          return (
            <AdminSearchCandidateCard key={gap.gapId}>
              <AdminSearchCandidateHeader>
                <div>
                  <AdminEyebrow>
                    {gap.area} / {gap.decisionOwner}
                  </AdminEyebrow>
                  <h3>{gap.gapId.replaceAll("_", " ")}</h3>
                </div>
                <StatusChip tone={gap.status === "ready" ? "ready" : ""}>
                  {gap.severity}
                </StatusChip>
              </AdminSearchCandidateHeader>
              <AdminIntakeStateGrid>
                <StateRow label="Status" value={gap.status.replaceAll("_", " ")} />
                <StateRow label="Decision" value={gap.decisionStatus.replaceAll("_", " ")} />
                <StateRow label="Default" value={gap.defaultPosition.replaceAll("_", " ")} />
                <StateRow label="State" value={gap.currentState} />
                <StateRow label="Next" value={gap.nextAction} />
              </AdminIntakeStateGrid>
              {submittedDecision ? (
                <AdminIntakeDecisionState>
                  <CheckCircle2 size={16} strokeWidth={1.9} />
                  <div>
                    <strong>{policyGapDecisionLabel(submittedDecision)}</strong>
                    <span>
                      {localDecision ?
                        `${localDecision.decisionPath} / ${localDecision.operationalState}` :
                        `Decision present in ${gap.reviewDecision?.policyGapDecisionBatchId}`}
                    </span>
                  </div>
                </AdminIntakeDecisionState>
              ) : (
                <AdminIntakeDecisionBox>
                  <TextareaField
                    label="Policy review note"
                    onChange={(note) => onNoteChange(gap.gapId, note)}
                    rows={3}
                    value={notes[gap.gapId] ?? ""}
                  />
                  <AdminIntakeDecisionActions>
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
                  </AdminIntakeDecisionActions>
                </AdminIntakeDecisionBox>
              )}
              {gap.reviewDecision ? (
                <AdminIntakeSection>
                  <AdminIntakeSectionTitle>Reviewed Decision</AdminIntakeSectionTitle>
                  <AdminIntakeStateGrid>
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
                  </AdminIntakeStateGrid>
                </AdminIntakeSection>
              ) : null}
              <AdminOrganizerPolicyGapColumns>
                <div>
                  <AdminIntakeSectionTitle>Required Inputs</AdminIntakeSectionTitle>
                  <AdminTagList>
                    {gap.requiredInputs.map((input) => (
                      <AdminTag key={input}>
                        {input}
                      </AdminTag>
                    ))}
                  </AdminTagList>
                </div>
                <div>
                  <AdminIntakeSectionTitle>Unblock Criteria</AdminIntakeSectionTitle>
                  <AdminTagList>
                    {gap.unblockCriteria.map((criterion) => (
                      <AdminTag key={criterion} tone="muted">
                        {criterion}
                      </AdminTag>
                    ))}
                  </AdminTagList>
                </div>
              </AdminOrganizerPolicyGapColumns>
              <AdminCommandStack>
                {gap.blockedArtifacts.map((artifact) => (
                  <AdminCommandRow key={artifact}>
                    <span>artifact</span>
                    <code>{artifact}</code>
                  </AdminCommandRow>
                ))}
              </AdminCommandStack>
            </AdminSearchCandidateCard>
          );
        })}
      </AdminSearchCandidateList>
    </AdminSearchCandidatePanel>
  );
}

function OrganizerPolicyDecisionPacketsView({
  packets,
}: {
  packets: Intake.OrganizerPolicyDecisionPackets;
}) {
  const visiblePackets = packets.packets.slice(0, 8);

  return (
    <AdminSearchCandidatePanel>
      <AdminIntakeStateGrid>
        <StateRow label="Packets" value={String(packets.summary.packets)} />
        <StateRow label="Need decision" value={String(packets.summary.decisionRequired)} />
        <StateRow label="Questions" value={String(packets.summary.questions)} />
        <StateRow label="Unanswered" value={String(packets.summary.unansweredQuestions)} />
        <StateRow label="Accepted" value={String(packets.summary.accepted)} />
        <StateRow label="Held" value={String(packets.summary.held)} />
      </AdminIntakeStateGrid>
      <AdminTagList>
        {Object.entries(packets.summary.questionsByArea).map(([area, count]) => (
          <AdminTag key={area} tone="muted">
            {area} x{count}
          </AdminTag>
        ))}
        {Object.entries(packets.summary.questionsByAnswerState).map(([state, count]) => (
          <AdminTag key={state} tone="muted">
            {state.replaceAll("_", " ")} x{count}
          </AdminTag>
        ))}
        {packets.guardrails.map((guardrail) => (
          <AdminTag key={guardrail} tone="muted">
            {guardrail}
          </AdminTag>
        ))}
      </AdminTagList>
      <AdminSearchCandidateList>
        {visiblePackets.map((packet) => (
          <AdminSearchCandidateCard key={packet.packetId}>
            <AdminSearchCandidateHeader>
              <div>
                <AdminEyebrow>
                  {packet.area} / {packet.decisionOwner}
                </AdminEyebrow>
                <h3>{packet.decisionPrompt}</h3>
              </div>
              <StatusChip tone={packet.status === "ready" ? "ready" : ""}>
                {packet.severity}
              </StatusChip>
            </AdminSearchCandidateHeader>

            <AdminIntakeStateGrid>
              <StateRow label="Gap" value={packet.gapId} />
              <StateRow label="Decision" value={packet.decisionStatus.replaceAll("_", " ")} />
              <StateRow label="Safe default" value={packet.safeDefaultAction.replaceAll("_", " ")} />
              <StateRow label="Gate" value={packet.implementationGate} />
            </AdminIntakeStateGrid>

            <QualityRow tone="warning" icon={<Lock size={16} strokeWidth={1.9} />}>
              <strong>{packet.currentState}</strong>
              <span>{packet.nextAction}</span>
            </QualityRow>

            <AdminIntakeSection>
              <AdminIntakeSectionTitle>Required Inputs</AdminIntakeSectionTitle>
              <AdminTagList>
                {packet.questions.map((question) => (
                  <AdminTag
                    key={question.questionId}
                    tone={question.answerState === "reviewed" ? "neutral" : "muted"}
                  >
                    {question.input}
                  </AdminTag>
                ))}
              </AdminTagList>
            </AdminIntakeSection>

            <AdminCommandStack>
              {packet.blockedArtifacts.map((artifact) => (
                <AdminCommandRow key={artifact}>
                  <span>blocked</span>
                  <code>{artifact}</code>
                </AdminCommandRow>
              ))}
            </AdminCommandStack>
          </AdminSearchCandidateCard>
        ))}
      </AdminSearchCandidateList>
    </AdminSearchCandidatePanel>
  );
}

function OrganizerCanonicalHostRegistryView({
  registry,
}: {
  registry: Intake.OrganizerCanonicalHostEntityRegistry;
}) {
  const visibleEntries = registry.entries.slice(0, 8);

  return (
    <AdminSearchCandidatePanel>
      <AdminIntakeStateGrid>
        <StateRow label="Entities" value={String(registry.summary.entities)} />
        <StateRow label="Public" value={String(registry.summary.publicPublished)} />
        <StateRow label="Indexed" value={String(registry.summary.indexed)} />
        <StateRow label="Claim targets" value={String(registry.summary.claimTargets)} />
        <StateRow label="Surfaces" value={String(registry.summary.surfaces)} />
        <StateRow label="Crawl-capable" value={String(registry.summary.crawlCapableSurfaces)} />
      </AdminIntakeStateGrid>
      <AdminTagList>
        <AdminTag>{registry.naming.publicEntityLabel}</AdminTag>
        <AdminTag tone="muted">
          {registry.naming.canonicalDataModel}
        </AdminTag>
        <AdminTag tone="muted">
          {registry.naming.legacyCompatibilityModel}
        </AdminTag>
        {Object.entries(registry.summary.byEntityKind).map(([kind, count]) => (
          <AdminTag key={kind} tone="muted">
            {kind} x{count}
          </AdminTag>
        ))}
        {Object.entries(registry.summary.byScopeKind).map(([scope, count]) => (
          <AdminTag key={scope} tone="muted">
            {scope} x{count}
          </AdminTag>
        ))}
      </AdminTagList>
      <QualityRow tone="warning" icon={<Lock size={16} strokeWidth={1.9} />}>
        <strong>{registry.naming.note}</strong>
        <span>{registry.guardrails[0]}</span>
      </QualityRow>
      <AdminSearchCandidateList>
        {visibleEntries.map((entry) => (
          <AdminSearchCandidateCard key={entry.canonicalHostId}>
            <AdminSearchCandidateHeader>
              <div>
                <AdminEyebrow>
                  {entry.entityKind} / {entry.geography.scopeKind ?? "unknown"}
                </AdminEyebrow>
                <h3>{entry.displayName}</h3>
              </div>
              <StatusChip tone={entry.publicPresence.publishStatus === "published" ? "ready" : ""}>
                {entry.publicPresence.publishStatus}
              </StatusChip>
            </AdminSearchCandidateHeader>

            <AdminIntakeStateGrid>
              <StateRow label="Host id" value={entry.canonicalHostId} />
              <StateRow label="Path" value={entry.publicPresence.canonicalPath ?? "none"} />
              <StateRow label="Index" value={entry.publicPresence.indexStatus} />
              <StateRow label="App" value={entry.publicPresence.appVisibility} />
              <StateRow label="Claim" value={entry.claim.claimState} />
              <StateRow label="Club doc" value={entry.legacyClubCompatibility.documentId} />
            </AdminIntakeStateGrid>

            <AdminTagList>
              {entry.geography.markets.map((market) => (
                <AdminTag key={market.marketSlug}>
                  {market.displayName}
                </AdminTag>
              ))}
              <AdminTag tone="muted">
                {entry.surfaceInventory.active} active
              </AdminTag>
              <AdminTag tone="muted">
                {entry.surfaceInventory.ambiguous} ambiguous
              </AdminTag>
              <AdminTag tone="muted">
                {entry.surfaceInventory.rejected} rejected
              </AdminTag>
              <AdminTag tone="muted">
                {entry.dedupe.strongKeys} strong keys
              </AdminTag>
            </AdminTagList>

            <AdminCommandStack>
              {entry.nextActions.map((action) => (
                <AdminCommandRow key={action}>
                  <span>next</span>
                  <code>{action}</code>
                </AdminCommandRow>
              ))}
            </AdminCommandStack>
          </AdminSearchCandidateCard>
        ))}
      </AdminSearchCandidateList>
    </AdminSearchCandidatePanel>
  );
}

function OrganizerCanonicalEvidenceIndexView({
  index,
}: {
  index: Intake.OrganizerCanonicalEvidenceIndex;
}) {
  const visibleRecords = index.records.slice(0, 8);

  return (
    <AdminSearchCandidatePanel>
      <AdminIntakeStateGrid>
        <StateRow label="Records" value={String(index.summary.records)} />
        <StateRow label="Resolved" value={String(index.summary.resolvedArtifactRefs)} />
        <StateRow label="Missing" value={String(index.summary.surfacesWithoutEvidence)} />
        <StateRow label="Manual" value={String(index.summary.manualReportsWithoutArtifacts)} />
        <StateRow label="Raw payloads" value={String(index.summary.rawProviderArtifacts)} />
        <StateRow label="Raw bytes" value={index.summary.rawPayloadBytes.toLocaleString()} />
      </AdminIntakeStateGrid>
      <AdminTagList>
        {Object.entries(index.summary.evidenceByStatus).map(([status, count]) => (
          <AdminTag key={status} tone="muted">
            {status.replaceAll("_", " ")} x{count}
          </AdminTag>
        ))}
        {Object.entries(index.summary.evidenceByType).map(([type, count]) => (
          <AdminTag key={type} tone="muted">
            {type} x{count}
          </AdminTag>
        ))}
      </AdminTagList>
      <QualityRow tone="warning" icon={<Lock size={16} strokeWidth={1.9} />}>
        <strong>{index.guardrails[0]}</strong>
        <span>{index.guardrails[1]}</span>
      </QualityRow>
      <AdminSearchCandidateList>
        {visibleRecords.map((record) => (
          <AdminSearchCandidateCard key={record.evidenceId}>
            <AdminSearchCandidateHeader>
              <div>
                <AdminEyebrow>
                  {record.surface.platform} / {record.surface.status}
                </AdminEyebrow>
                <h3>{record.displayName}</h3>
              </div>
              <StatusChip tone={record.evidence.status === "resolved_artifact" ? "ready" : ""}>
                {record.evidence.status.replaceAll("_", " ")}
              </StatusChip>
            </AdminSearchCandidateHeader>

            <AdminIntakeStateGrid>
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
            </AdminIntakeStateGrid>

            <AdminTagList>
              {record.riskFlags.length === 0 ? (
                <AdminTag>no flags</AdminTag>
              ) : (
                record.riskFlags.map((flag) => (
                  <AdminTag key={flag} tone="muted">
                    {flag.replaceAll("_", " ")}
                  </AdminTag>
                ))
              )}
            </AdminTagList>

            <AdminCommandStack>
              <AdminCommandRow>
                <span>ref</span>
                <code>{record.evidence.ref ?? "none"}</code>
              </AdminCommandRow>
              <AdminCommandRow>
                <span>next</span>
                <code>{record.nextAction}</code>
              </AdminCommandRow>
            </AdminCommandStack>
          </AdminSearchCandidateCard>
        ))}
      </AdminSearchCandidateList>
    </AdminSearchCandidatePanel>
  );
}

function OrganizerPublicationReviewPacketsView({
  packets,
}: {
  packets: Intake.OrganizerPublicationReviewPackets;
}) {
  const visiblePackets = packets.packets.slice(0, 8);

  return (
    <AdminSearchCandidatePanel>
      <AdminIntakeStateGrid>
        <StateRow label="Packets" value={String(packets.summary.packets)} />
        <StateRow label="Ready" value={String(packets.summary.readyForManualPublicationReview)} />
        <StateRow label="Blocked" value={String(packets.summary.blockedByData)} />
        <StateRow label="Published" value={String(packets.summary.published)} />
        <StateRow label="Evidence" value={String(packets.summary.evidenceRecords)} />
        <StateRow label="Manual refs" value={String(packets.summary.manualReportsWithoutArtifacts)} />
      </AdminIntakeStateGrid>
      <AdminTagList>
        {Object.entries(packets.summary.packetsByStatus).map(([status, count]) => (
          <AdminTag key={status} tone="muted">
            {status.replaceAll("_", " ")} x{count}
          </AdminTag>
        ))}
        {Object.entries(packets.summary.packetsByTaskType).map(([type, count]) => (
          <AdminTag key={type} tone="muted">
            {type.replaceAll("_", " ")} x{count}
          </AdminTag>
        ))}
      </AdminTagList>
      <QualityRow tone="warning" icon={<Lock size={16} strokeWidth={1.9} />}>
        <strong>{packets.guardrails[0]}</strong>
        <span>{packets.guardrails[1]}</span>
      </QualityRow>
      <AdminSearchCandidateList>
        {visiblePackets.map((packet) => (
          <AdminSearchCandidateCard key={packet.packetId}>
            <AdminSearchCandidateHeader>
              <div>
                <AdminEyebrow>
                  {packet.taskType.replaceAll("_", " ")} / {packet.priority}
                </AdminEyebrow>
                <h3>{packet.displayName}</h3>
              </div>
              <StatusChip tone={packet.status === "ready_for_manual_publication_review" ? "ready" : ""}>
                {packet.status.replaceAll("_", " ")}
              </StatusChip>
            </AdminSearchCandidateHeader>

            <AdminIntakeStateGrid>
              <StateRow label="Path" value={packet.publicPresence.canonicalPath ?? "none"} />
              <StateRow label="Index" value={packet.publicPresence.indexStatus} />
              <StateRow label="App" value={packet.publicPresence.appVisibility} />
              <StateRow label="Evidence" value={String(packet.evidenceSummary.records)} />
              <StateRow label="Data blockers" value={String(packet.dataBlockers.length)} />
              <StateRow label="Evidence blockers" value={String(packet.evidenceBlockers.length)} />
            </AdminIntakeStateGrid>

            <QualityRow icon={<CheckCircle2 size={16} strokeWidth={1.9} />}>
              <strong>{packet.recommendedAction}</strong>
              <span>{packet.publicDraft.headline ?? packet.entityId}</span>
            </QualityRow>

            <AdminIntakeSection>
              <AdminIntakeSectionTitle>Evidence review</AdminIntakeSectionTitle>
              <AdminIntakeStateGrid>
                <StateRow label="Shown" value={`${packet.evidenceReview.shownRecords}/${packet.evidenceReview.totalRecords}`} />
                <StateRow label="Artifacts" value={String(packet.evidenceReview.artifactBackedRecords)} />
                <StateRow label="Manual" value={String(packet.evidenceReview.manualReportsWithoutArtifacts)} />
                <StateRow label="Unresolved" value={String(packet.evidenceReview.unresolvedLocalRefs)} />
              </AdminIntakeStateGrid>
              <AdminCommandStack>
                {packet.evidenceReview.records.slice(0, 6).map((record) => (
                  <AdminCommandRow key={record.evidenceId}>
                    <span>
                      {record.surface.platform} / {record.evidence.status.replaceAll("_", " ")}
                    </span>
                    <code>{publicationEvidenceReviewLine(record)}</code>
                    <AdminTagList>
                      <AdminTag tone={record.reviewerUse.artifactAvailable ? "neutral" : "muted"}>
                        {record.reviewerUse.artifactAvailable ? "artifact" : "no artifact"}
                      </AdminTag>
                      <AdminTag tone="muted">
                        {record.surface.status.replaceAll("_", " ")}
                      </AdminTag>
                      {record.riskFlags.slice(0, 4).map((flag) => (
                        <AdminTag key={flag} tone="muted">
                          {flag.replaceAll("_", " ")}
                        </AdminTag>
                      ))}
                    </AdminTagList>
                  </AdminCommandRow>
                ))}
                {packet.evidenceReview.truncated ? (
                  <AdminCommandRow>
                    <span>more</span>
                    <code>{packet.evidenceReview.totalRecords - packet.evidenceReview.shownRecords} additional evidence records</code>
                  </AdminCommandRow>
                ) : null}
              </AdminCommandStack>
            </AdminIntakeSection>

            <AdminTagList>
              {packet.publicDraft.formats.map((format) => (
                <AdminTag key={format}>
                  {format}
                </AdminTag>
              ))}
              {packet.evidenceSummary.riskFlags.map((flag) => (
                <AdminTag key={flag} tone="muted">
                  {flag.replaceAll("_", " ")}
                </AdminTag>
              ))}
            </AdminTagList>

            <AdminCommandStack>
              <AdminCommandRow>
                <span>decision</span>
                <code>{packet.adminDecision.command}</code>
              </AdminCommandRow>
              {packet.nextActions.map((action) => (
                <AdminCommandRow key={action}>
                  <span>next</span>
                  <code>{action}</code>
                </AdminCommandRow>
              ))}
            </AdminCommandStack>
          </AdminSearchCandidateCard>
        ))}
      </AdminSearchCandidateList>
    </AdminSearchCandidatePanel>
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
    <AdminSearchCandidatePanel>
      <AdminIntakeStateGrid>
        <StateRow label="Impacts" value={String(preview.summary.impacts)} />
        <StateRow label="Would publish" value={String(preview.summary.wouldPublish)} />
        <StateRow label="Would index" value={String(preview.summary.wouldIndex)} />
        <StateRow label="Claim targets" value={String(preview.summary.wouldCreateClaimTargets)} />
        <StateRow label="App visible" value={String(preview.summary.wouldBeAppDiscoverable)} />
        <StateRow label="Manual acks" value={String(preview.summary.reviewerAcknowledgementsRequired)} />
      </AdminIntakeStateGrid>
      <AdminTagList>
        {Object.entries(preview.summary.byStatus).map(([status, count]) => (
          <AdminTag key={status} tone="muted">
            {status.replaceAll("_", " ")} x{count}
          </AdminTag>
        ))}
      </AdminTagList>
      <QualityRow tone="warning" icon={<Lock size={16} strokeWidth={1.9} />}>
        <strong>{preview.guardrails[0]}</strong>
        <span>{preview.guardrails[1]}</span>
      </QualityRow>
      <AdminSearchCandidateList>
        {visibleEntries.map((entry) => (
          <AdminSearchCandidateCard key={entry.impactId}>
            <AdminSearchCandidateHeader>
              <div>
                <AdminEyebrow>
                  {entry.entityId} / {entry.decisionRequired.decision}
                </AdminEyebrow>
                <h3>{entry.displayName}</h3>
              </div>
              <StatusChip tone={entry.status.includes("would_publish") ? "ready" : ""}>
                {entry.status.replaceAll("_", " ")}
              </StatusChip>
            </AdminSearchCandidateHeader>

            <AdminIntakeStateGrid>
              <StateRow label="Path" value={entry.publicProjection.canonicalPath ?? "none"} />
              <StateRow label="Publish" value={entry.publicProjection.publishStatus} />
              <StateRow label="Index" value={entry.publicProjection.indexing} />
              <StateRow label="Claim" value={entry.claimTarget.path ?? "none"} />
              <StateRow label="App" value={entry.app.appVisibility} />
              <StateRow label="Sitemap" value={entry.remoteEffects.sitemapEligible ? "eligible" : "excluded"} />
            </AdminIntakeStateGrid>

            <AdminTagList>
              {entry.preconditions.reviewerAcknowledgementRequired ? (
                <AdminTag tone="muted">
                  manual reports require acknowledgement
                </AdminTag>
              ) : (
                <AdminTag>packet ready</AdminTag>
              )}
              {entry.publicProjection.legacyPaths.map((legacyPath) => (
                <AdminTag key={legacyPath} tone="muted">
                  legacy {legacyPath}
                </AdminTag>
              ))}
              {entry.preconditions.blockers?.map((blocker) => (
                <AdminTag key={blocker} tone="muted">
                  {blocker.replaceAll("_", " ")}
                </AdminTag>
              ))}
            </AdminTagList>

            <AdminCommandStack>
              {entry.commands.map((command) => (
                <AdminCommandRow key={command}>
                  <span>next</span>
                  <code>{command}</code>
                </AdminCommandRow>
              ))}
            </AdminCommandStack>
          </AdminSearchCandidateCard>
        ))}
      </AdminSearchCandidateList>
    </AdminSearchCandidatePanel>
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
    <AdminSearchCandidatePanel>
      <AdminIntakeStateGrid>
        <StateRow label="Targets" value={String(preview.summary.targets)} />
        <StateRow label="Creates" value={String(preview.summary.creates)} />
        <StateRow label="Refreshes" value={String(preview.summary.refreshes)} />
        <StateRow label="Owner-bound" value={String(preview.summary.skippedOwnerBound)} />
        <StateRow label="Writes" value={String(preview.summary.writesNeeded)} />
        <StateRow label="Remote writes" value={String(preview.mode.remoteWrites)} />
      </AdminIntakeStateGrid>
      <QualityRow tone="warning" icon={<Lock size={16} strokeWidth={1.9} />}>
        <strong>{preview.guardrails[0]}</strong>
        <span>{preview.guardrails[1]}</span>
      </QualityRow>
      <AdminTagList>
        <AdminTag tone="muted">
          source {preview.mode.existingDocsSource}
        </AdminTag>
        {preview.mode.assumesMissingWhenNotInFixture ? (
          <AdminTag tone="muted">missing docs assumed absent</AdminTag>
        ) : null}
      </AdminTagList>
      <AdminSearchCandidateList>
        {visibleActions.length === 0 ? (
          <EmptyState icon={<CheckCircle2 size={16} strokeWidth={1.9} />}>
            No claim-target sync actions until a public approval exists.
          </EmptyState>
        ) : (
          visibleActions.map((action) => (
            <AdminSearchCandidateCard key={`${action.path}-${action.status}`}>
              <AdminSearchCandidateHeader>
                <div>
                  <AdminEyebrow>
                    {action.entityId} / {action.reason.replaceAll("_", " ")}
                  </AdminEyebrow>
                  <h3>{action.path}</h3>
                </div>
                <StatusChip tone={action.writesRemoteData ? "ready" : ""}>
                  {action.status.replaceAll("_", " ")}
                </StatusChip>
              </AdminSearchCandidateHeader>

              <AdminIntakeStateGrid>
                <StateRow label="Merge" value={action.merge ? "merge" : "set"} />
                <StateRow label="Fields" value={String(action.writeFieldCount)} />
                <StateRow label="Dry run" value={action.requiresFirestoreDryRun ? "required" : "not required"} />
              </AdminIntakeStateGrid>

              <AdminTagList>
                {action.writeFields.slice(0, 12).map((field) => (
                  <AdminTag key={field} tone="muted">
                    {field}
                  </AdminTag>
                ))}
              </AdminTagList>
            </AdminSearchCandidateCard>
          ))
        )}
      </AdminSearchCandidateList>
      <AdminCommandStack>
        {Object.entries(preview.commands).map(([label, command]) => (
          <AdminCommandRow key={label}>
            <span>{label}</span>
            <code>{command}</code>
          </AdminCommandRow>
        ))}
      </AdminCommandStack>
    </AdminSearchCandidatePanel>
  );
}

function OrganizerCrawlRunPlanView({
  plan,
}: {
  plan: Intake.OrganizerCrawlRunPlan;
}) {
  const visibleIntents = plan.runIntents.slice(0, 8);

  return (
    <AdminSearchCandidatePanel>
      <AdminIntakeStateGrid>
        <StateRow label="Scheduler" value={plan.policy.schedulerEnabled ? "enabled" : "disabled"} />
        <StateRow label="Network" value={plan.policy.networkEnabled ? "enabled" : "disabled"} />
        <StateRow label="Request cap" value={String(plan.policy.maxRequestsPerRun)} />
        <StateRow label="Would fetch" value={String(plan.summary.wouldFetch)} />
        <StateRow label="Blocked" value={String(plan.summary.blocked)} />
        <StateRow label="Writes" value={String(plan.summary.firestoreWrites)} />
      </AdminIntakeStateGrid>
      <AdminTagList>
        {plan.policy.platformAllowlist.length === 0 ? (
          <AdminTag tone="muted">No platform allowlist</AdminTag>
        ) : (
          plan.policy.platformAllowlist.map((platform) => (
            <AdminTag key={platform}>{platform}</AdminTag>
          ))
        )}
        {plan.guardrails.map((guardrail) => (
          <AdminTag key={guardrail} tone="muted">
            {guardrail}
          </AdminTag>
        ))}
      </AdminTagList>
      <AdminIntakeSection>
        <AdminIntakeSectionTitle>Run blockers</AdminIntakeSectionTitle>
        <AdminTagList>
          {Object.entries(plan.summary.blockers)
            .sort(([left], [right]) => left.localeCompare(right))
            .map(([blocker, count]) => (
              <AdminTag key={blocker} tone="muted">
                {blocker} x{count}
              </AdminTag>
            ))}
        </AdminTagList>
      </AdminIntakeSection>
      <AdminSearchCandidateList>
        {visibleIntents.map((intent) => (
          <AdminSearchCandidateCard key={intent.crawlRunId}>
            <AdminSearchCandidateHeader>
              <div>
                <AdminEyebrow>
                  {intent.platform} / {intent.surfaceKind}
                </AdminEyebrow>
                <h3>{intent.displayName}</h3>
              </div>
              <StatusChip tone={intent.action === "would_fetch" ? "ready" : ""}>
                {intent.action.replaceAll("_", " ")}
              </StatusChip>
            </AdminSearchCandidateHeader>
            <AdminIntakeStateGrid>
              <StateRow label="Run" value={intent.crawlRunId} />
              <StateRow label="Surface" value={intent.surfaceId} />
              <StateRow label="Next" value={intent.nextGate.replaceAll("_", " ")} />
              <StateRow label="Output" value={intent.expectedOutput} />
            </AdminIntakeStateGrid>
            <AdminTagList>
              {intent.blockedBy.length === 0 ? (
                <AdminTag>ready for reviewed capture</AdminTag>
              ) : (
                intent.blockedBy.map((blocker) => (
                  <AdminTag key={blocker} tone="muted">
                    {blocker}
                  </AdminTag>
                ))
              )}
            </AdminTagList>
          </AdminSearchCandidateCard>
        ))}
      </AdminSearchCandidateList>
    </AdminSearchCandidatePanel>
  );
}

function OrganizerRawArtifactStorageView({
  manifest,
}: {
  manifest: Intake.OrganizerRawArtifactStorageManifest;
}) {
  const visibleArtifacts = manifest.artifacts.slice(0, 8);

  return (
    <AdminSearchCandidatePanel>
      <AdminIntakeStateGrid>
        <StateRow label="Policy" value={manifest.policy.status.replaceAll("_", " ")} />
        <StateRow label="Object storage" value={manifest.policy.remoteObjectStorageEnabled ? "enabled" : "disabled"} />
        <StateRow label="Firestore raw" value={manifest.summary.firestoreRawStorageAllowed ? "allowed" : "forbidden"} />
        <StateRow label="Raw payloads" value={String(manifest.summary.rawProviderPayloads)} />
        <StateRow label="Upload blocked" value={String(manifest.summary.remoteUploadBlocked)} />
        <StateRow label="Bytes" value={manifest.summary.totalBytes.toLocaleString()} />
      </AdminIntakeStateGrid>
      <AdminTagList>
        <AdminTag tone="muted">provider: {manifest.policy.provider}</AdminTag>
        <AdminTag tone="muted">
          bucket: {manifest.policy.bucket ?? "not configured"}
        </AdminTag>
        <AdminTag tone="muted">
          retention: {manifest.policy.rawPayloadRetentionDays ?? "not configured"}
        </AdminTag>
        {manifest.guardrails.map((guardrail) => (
          <AdminTag key={guardrail} tone="muted">
            {guardrail}
          </AdminTag>
        ))}
      </AdminTagList>
      <AdminIntakeSection>
        <AdminIntakeSectionTitle>Storage blockers</AdminIntakeSectionTitle>
        <AdminTagList>
          {Object.entries(manifest.summary.blockers).length === 0 ? (
            <AdminTag>No upload blockers</AdminTag>
          ) : (
            Object.entries(manifest.summary.blockers)
              .sort(([left], [right]) => left.localeCompare(right))
              .map(([blocker, count]) => (
                <AdminTag key={blocker} tone="muted">
                  {blocker} x{count}
                </AdminTag>
              ))
          )}
        </AdminTagList>
      </AdminIntakeSection>
      <AdminSearchCandidateList>
        {visibleArtifacts.map((artifact) => (
          <AdminSearchCandidateCard key={artifact.artifactId}>
            <AdminSearchCandidateHeader>
              <div>
                <AdminEyebrow>
                  {artifact.storageClass} / {artifact.artifactKind}
                </AdminEyebrow>
                <h3>{artifact.path}</h3>
              </div>
              <StatusChip tone={artifact.storagePlan.action === "would_upload" ? "ready" : ""}>
                {artifact.storagePlan.action.replaceAll("_", " ")}
              </StatusChip>
            </AdminSearchCandidateHeader>
            <AdminIntakeStateGrid>
              <StateRow label="Firestore" value={artifact.firestoreMode.replaceAll("_", " ")} />
              <StateRow label="Retention" value={artifact.retention.status.replaceAll("_", " ")} />
              <StateRow label="Bytes" value={artifact.sizeBytes.toLocaleString()} />
              <StateRow label="Object key" value={artifact.storagePlan.remoteObjectKey} />
            </AdminIntakeStateGrid>
            <AdminTagList>
              {artifact.storagePlan.blockedBy.length === 0 ? (
                <AdminTag>storage policy satisfied</AdminTag>
              ) : (
                artifact.storagePlan.blockedBy.map((blocker) => (
                  <AdminTag key={blocker} tone="muted">
                    {blocker}
                  </AdminTag>
                ))
              )}
            </AdminTagList>
          </AdminSearchCandidateCard>
        ))}
      </AdminSearchCandidateList>
    </AdminSearchCandidatePanel>
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
    <AdminSearchCandidatePanel>
      <AdminIntakeStateGrid>
        <StateRow label="Batches" value={String(queue.summary.batches)} />
        <StateRow label="Results" value={String(queue.summary.results)} />
        <StateRow label="Matched" value={String(queue.summary.matchedExistingEntities)} />
        <StateRow label="Duplicate keys" value={String(queue.summary.duplicateNormalizedKeys)} />
      </AdminIntakeStateGrid>
      <AdminTagList>
        {platformEntries.length === 0 ? (
          <AdminTag tone="muted">No captured surfaces</AdminTag>
        ) : (
          platformEntries.map(([platform, count]) => (
            <AdminTag key={platform}>
              {platform} x{count}
            </AdminTag>
          ))
        )}
      </AdminTagList>
      {queue.errors.length > 0 || queue.warnings.length > 0 ? (
        <AdminIntakeSection>
          <AdminIntakeSectionTitle>Queue Diagnostics</AdminIntakeSectionTitle>
          <AdminIntakeGateList>
            {[...queue.errors, ...queue.warnings].map((message) => (
              <AdminIntakeGate tone="blocked" key={message}>
                <FileWarning size={15} strokeWidth={1.9} />
                <div>
                  <strong>{message}</strong>
                </div>
              </AdminIntakeGate>
            ))}
          </AdminIntakeGateList>
        </AdminIntakeSection>
      ) : null}
      <AdminSearchCandidateList>
        {visibleCandidates.length === 0 ? (
          <EmptyState icon={<CheckCircle2 size={16} strokeWidth={1.9} />}>
            No captured search surfaces
          </EmptyState>
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
      </AdminSearchCandidateList>
      <AdminIntakeSection>
        <AdminIntakeSectionTitle>Queue Commands</AdminIntakeSectionTitle>
        <AdminCommandStack>
          {Object.entries(queue.commands).map(([label, command]) => (
            <AdminCommandRow key={label}>
              <span>{label}</span>
              <code>{command}</code>
            </AdminCommandRow>
          ))}
        </AdminCommandStack>
      </AdminIntakeSection>
    </AdminSearchCandidatePanel>
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
    <AdminSearchCandidatePanel>
      <AdminIntakeStateGrid>
        <StateRow label="Launch cities" value={plan.summary.launchCities.join(", ")} />
        <StateRow label="Planned launch queries" value={String(plan.summary.launchCityPlanned)} />
        <StateRow label="Fresh skipped" value={String(plan.summary.launchCitySkippedFresh)} />
        <StateRow label="Fresh for" value={plan.freshForDays ? `${plan.freshForDays} days` : "not configured"} />
        <StateRow label="As of" value={plan.asOf ?? "unknown"} />
        <StateRow label="Plan source" value={plan.generatedFrom.searchPlan} />
      </AdminIntakeStateGrid>
      <AdminTagList>
        {plan.launchCities.map((city) => (
          <AdminTag
            key={city.citySlug}
            tone={city.missingCategoryIds.length > 0 ? "muted" : "neutral"}
          >
            {city.city}: {city.categoryIds.length} categories
          </AdminTag>
        ))}
      </AdminTagList>
      <QualityRow tone="warning" icon={<Lock size={16} strokeWidth={1.9} />}>
        <strong>Repo-owned search configuration</strong>
        <span>{plan.commands.configure}</span>
        <span>Change the files below, regenerate the plan, then capture and ingest provider results.</span>
      </QualityRow>
      <AdminIntakeSection>
        <AdminIntakeSectionTitle>Configuration Sources</AdminIntakeSectionTitle>
        <AdminIntakeStateGrid>
          {sourceRows.map(([label, value]) => (
            <StateRow key={label} label={label} value={value} />
          ))}
        </AdminIntakeStateGrid>
      </AdminIntakeSection>
      <AdminIntakeSection>
        <AdminIntakeSectionTitle>Launch Search Terms</AdminIntakeSectionTitle>
        <AdminTagList>
          {launchQueryTemplates.length === 0 ? (
            <AdminTag tone="muted">No launch search terms planned.</AdminTag>
          ) : (
            launchQueryTemplates.map((entry) => (
              <AdminTag
                key={`${entry.queryTemplateId}-${entry.queryTemplate}`}
                tone="muted"
              >
                {entry.queryTemplateId}: {entry.queryTemplate}
              </AdminTag>
            ))
          )}
        </AdminTagList>
      </AdminIntakeSection>
      <AdminIntakeSection>
        <AdminIntakeSectionTitle>Operator Commands</AdminIntakeSectionTitle>
        <AdminCommandStack>
          {Object.entries(plan.commands).map(([label, command]) => (
            <AdminCommandRow key={label}>
              <span>{label}</span>
              <code>{command}</code>
            </AdminCommandRow>
          ))}
        </AdminCommandStack>
      </AdminIntakeSection>
      {plan.summary.missingLaunchCityCategories.length > 0 ? (
        <AdminIntakeSection>
          <AdminIntakeSectionTitle>Missing launch categories</AdminIntakeSectionTitle>
          <AdminIntakeGateList>
            {plan.summary.missingLaunchCityCategories.map((missing) => (
              <AdminIntakeGate
                tone="blocked"
                key={`${missing.citySlug}-${missing.categoryId}`}
              >
                <FileWarning size={15} strokeWidth={1.9} />
                <div>
                  <strong>{missing.city}</strong>
                  <span>{missing.categoryId}</span>
                </div>
              </AdminIntakeGate>
            ))}
          </AdminIntakeGateList>
        </AdminIntakeSection>
      ) : null}
      <AdminSearchCandidateList>
        {launchEntries.map((entry) => (
          <AdminSearchCandidateCard key={entry.runKey}>
            <AdminSearchCandidateHeader>
              <div>
                <AdminEyebrow>
                  {entry.city} / {entry.categoryId.replaceAll("_", " ")}
                </AdminEyebrow>
                <h3>{entry.renderedQuery}</h3>
              </div>
              <StatusChip>
                {entry.planKind.replaceAll("_", " ")}
              </StatusChip>
            </AdminSearchCandidateHeader>
            <AdminIntakeStateGrid>
              <StateRow label="Template" value={entry.queryTemplateId} />
              <StateRow label="Template text" value={entry.queryTemplate} />
              <StateRow label="Source" value={entry.source} />
              <StateRow label="Run key" value={entry.runKey} />
              <StateRow label="Candidate" value={entry.candidateName ?? "generic city search"} />
              <StateRow label="Searched" value={entry.searchedAt ?? "not captured"} />
              <StateRow label="Existing run" value={entry.existingRunFile ?? "none"} />
              <StateRow label="Fingerprint" value={entry.resultFingerprint ?? "none"} />
            </AdminIntakeStateGrid>
          </AdminSearchCandidateCard>
        ))}
        {launchEntries.length === 0 ? (
          <EmptyState icon={<FileWarning size={16} strokeWidth={1.9} />}>
            No planned launch-city discovery queries
          </EmptyState>
        ) : null}
      </AdminSearchCandidateList>
      {skippedEntries.length > 0 ? (
        <AdminIntakeSection>
          <AdminIntakeSectionTitle>Fresh skipped queries</AdminIntakeSectionTitle>
          <AdminSearchCandidateList>
            {skippedEntries.map((entry) => (
              <AdminSearchCandidateCard key={entry.runKey}>
                <AdminSearchCandidateHeader>
                  <div>
                    <AdminEyebrow>
                      {entry.city} / {entry.categoryId.replaceAll("_", " ")}
                    </AdminEyebrow>
                    <h3>{entry.renderedQuery}</h3>
                  </div>
                  <StatusChip>fresh</StatusChip>
                </AdminSearchCandidateHeader>
                <AdminIntakeStateGrid>
                  <StateRow label="Run key" value={entry.runKey} />
                  <StateRow label="Searched" value={entry.searchedAt ?? "unknown"} />
                  <StateRow label="Existing run" value={entry.existingRunFile ?? "none"} />
                  <StateRow label="Fingerprint" value={entry.resultFingerprint ?? "none"} />
                </AdminIntakeStateGrid>
              </AdminSearchCandidateCard>
            ))}
          </AdminSearchCandidateList>
        </AdminIntakeSection>
      ) : null}
    </AdminSearchCandidatePanel>
  );
}

function OrganizerPublishingContractsView({
  contracts,
}: {
  contracts: Intake.OrganizerPublishingContracts;
}) {
  return (
    <AdminSearchCandidatePanel>
      <AdminSearchCandidateList>
        {Object.entries(contracts).map(([key, contract]) => (
          <AdminSearchCandidateCard key={key}>
            <AdminSearchCandidateHeader>
              <div>
                <AdminEyebrow>
                  {contract.intakeTarget} / {contract.writeCallable}
                </AdminEyebrow>
                <h3>{contract.callablePayloadSchema}</h3>
              </div>
              <StatusChip tone="ready">schema source</StatusChip>
            </AdminSearchCandidateHeader>
            <AdminIntakeStateGrid>
              <StateRow label="Firestore" value={contract.firestoreSchema} />
              <StateRow label="Generated payload" value={contract.generatedCallablePayload} />
              <StateRow label="Callable" value={contract.writeCallable} />
            </AdminIntakeStateGrid>
            <AdminTagList>
              {contract.projectionNotes.map((note: string) => (
                <AdminTag key={note} tone="muted">
                  {note}
                </AdminTag>
              ))}
            </AdminTagList>
          </AdminSearchCandidateCard>
        ))}
      </AdminSearchCandidateList>
    </AdminSearchCandidatePanel>
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
    <AdminSearchCandidatePanel>
      <AdminIntakeStateGrid>
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
      </AdminIntakeStateGrid>
      <QualityRow tone="warning" icon={<Lock size={16} strokeWidth={1.9} />}>
        <strong>Canonical write boundary</strong>
        <span>{resolution.policy.canonicalBoundary.generatedCandidates}</span>
        <span>{resolution.policy.canonicalBoundary.platformVerifiedMeaning}</span>
      </QualityRow>
      <AdminIntakeSection>
        <AdminIntakeSectionTitle>Editable Resolution Policy</AdminIntakeSectionTitle>
        <AdminTagList>
          {thresholds.map(([key, value]) => (
            <AdminTag key={key} tone="muted">
              {key}: {value}
            </AdminTag>
          ))}
          {blockingKeys.map((key) => (
            <AdminTag key={key.id} tone="muted">
              {key.id} / {key.strength}
            </AdminTag>
          ))}
          {stableProviderPlatforms.length > 0 ? (
            <AdminTag tone="muted">
              provider hard keys: {stableProviderPlatforms.join(", ")}
            </AdminTag>
          ) : null}
        </AdminTagList>
      </AdminIntakeSection>
      <AdminIntakeSection>
        <AdminIntakeSectionTitle>Resolution review packets</AdminIntakeSectionTitle>
        <AdminSearchCandidateList>
          {reviewPackets.map((packet) => (
            <AdminSearchCandidateCard key={packet.packetId}>
              <AdminSearchCandidateHeader>
                <div>
                  <AdminEyebrow>
                    {packet.entityType} / {packet.recommendedAction.replaceAll("_", " ")}
                  </AdminEyebrow>
                  <h3>{packet.packetId}</h3>
                </div>
                <StatusChip tone={packet.humanReviewRequired ? "blocked" : "ready"}>
                  {packet.resolutionState.replaceAll("_", " ")}
                </StatusChip>
              </AdminSearchCandidateHeader>
              <AdminIntakeStateGrid>
                <StateRow label="Score" value={String(packet.score)} />
                <StateRow label="Candidates" value={String(packet.candidateIds.length)} />
                <StateRow label="Mentions" value={String(packet.mentionIds.length)} />
                <StateRow
                  label="LLM"
                  value={packet.llmReview.status.replaceAll("_", " ")}
                />
              </AdminIntakeStateGrid>
              <AdminTagList>
                {Object.entries(packet.checklist).map(([key, value]) => (
                  <AdminTag key={key} tone="muted">
                    {key}: {String(value)}
                  </AdminTag>
                ))}
                {packet.topSignals.slice(0, 5).map((signal) => (
                  <AdminTag key={signal}>
                    {signal.replaceAll("_", " ")}
                  </AdminTag>
                ))}
                {packet.conflicts.map((conflict) => (
                  <AdminTag key={conflict} tone="muted">
                    conflict: {conflict.replaceAll("_", " ")}
                  </AdminTag>
                ))}
              </AdminTagList>
            </AdminSearchCandidateCard>
          ))}
          {reviewPackets.length === 0 ? (
            <EmptyState icon={<FileWarning size={16} strokeWidth={1.9} />}>
              No source resolution review packets have been generated yet.
            </EmptyState>
          ) : null}
        </AdminSearchCandidateList>
      </AdminIntakeSection>
      <AdminSearchCandidateList>
        {clusters.map((cluster) => (
          <AdminSearchCandidateCard key={cluster.clusterId}>
            <AdminSearchCandidateHeader>
              <div>
                <AdminEyebrow>
                  {cluster.entityType} / {cluster.scoreBand.replaceAll("_", " ")}
                </AdminEyebrow>
                <h3>{cluster.displayNames.slice(0, 3).join(" / ") || cluster.clusterId}</h3>
              </div>
              <StatusChip tone={sourceResolutionTone(cluster.resolutionState)}>
                {cluster.resolutionState.replaceAll("_", " ")}
              </StatusChip>
            </AdminSearchCandidateHeader>
            <AdminIntakeStateGrid>
              <StateRow label="Score" value={String(cluster.score)} />
              <StateRow label="Mentions" value={String(cluster.mentionIds.length)} />
              <StateRow label="Cities" value={cluster.cities.join(", ") || "unknown"} />
              <StateRow label="Dates" value={cluster.dates.join(", ") || "unknown"} />
              <StateRow label="LLM" value={cluster.llmReview.status.replaceAll("_", " ")} />
            </AdminIntakeStateGrid>
            <AdminTagList>
              {cluster.hardSignals.map((signal) => (
                <AdminTag key={signal}>
                  {signal}
                </AdminTag>
              ))}
              {cluster.matchingSignals.slice(0, 6).map((signal) => (
                <AdminTag key={signal} tone="muted">
                  {signal.replaceAll("_", " ")}
                </AdminTag>
              ))}
              {cluster.conflictingSignals.map((signal) => (
                <AdminTag key={signal} tone="muted">
                  conflict: {signal.replaceAll("_", " ")}
                </AdminTag>
              ))}
            </AdminTagList>
            {cluster.publishBoundary ? (
              <QualityRow icon={<FileWarning size={16} strokeWidth={1.9} />}>
                <strong>Projection boundary</strong>
                <span>{cluster.publishBoundary}</span>
              </QualityRow>
            ) : null}
          </AdminSearchCandidateCard>
        ))}
        {clusters.length === 0 ? (
          <EmptyState icon={<FileWarning size={16} strokeWidth={1.9} />}>
            No source mentions have been captured for resolution yet.
          </EmptyState>
        ) : null}
      </AdminSearchCandidateList>
      {llmQueue.length > 0 ? (
        <AdminIntakeSection>
          <AdminIntakeSectionTitle>LLM Review Queue</AdminIntakeSectionTitle>
          <AdminTagList>
            {llmQueue.map((request) => (
              <AdminTag key={request.clusterId} tone="muted">
                {request.clusterId}: {request.status} / {request.promptVersion}
              </AdminTag>
            ))}
          </AdminTagList>
        </AdminIntakeSection>
      ) : null}
      <AdminIntakeSection>
        <AdminIntakeSectionTitle>LLM Prompt Queue</AdminIntakeSectionTitle>
        <QualityRow tone="warning" icon={<Lock size={16} strokeWidth={1.9} />}>
          <strong>{resolution.llmPromptQueue.policy.status.replaceAll("_", " ")}</strong>
          <span>{resolution.llmPromptQueue.policy.note}</span>
        </QualityRow>
        <AdminTagList>
          {promptQueue.map((request) => (
            <AdminTag key={request.requestId} tone="muted">
              {request.clusterId}: {request.status} / {request.promptVersion}
            </AdminTag>
          ))}
          {promptQueue.length === 0 ? (
            <AdminTag tone="muted">No prompt payloads queued.</AdminTag>
          ) : null}
        </AdminTagList>
      </AdminIntakeSection>
    </AdminSearchCandidatePanel>
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
    <AdminSearchCandidateCard>
      <AdminSearchCandidateHeader>
        <div>
          <AdminEyebrow>
            #{candidate.rank} / {candidate.platform} / {candidate.surfaceKind}
          </AdminEyebrow>
          <h3>{candidate.title}</h3>
        </div>
        <StatusChip tone={candidate.reviewAction.includes("attach") ? "ready" : ""}>
          {candidate.reviewAction.replaceAll("_", " ")}
        </StatusChip>
      </AdminSearchCandidateHeader>
      <AdminIntakeStateGrid>
        <StateRow label="Candidate" value={candidate.candidateId} />
        <StateRow label="Observed" value={candidate.observedAt} />
        <StateRow label="Normalized" value={candidate.normalizedKey ?? "none"} />
        <StateRow label="Canonical URL" value={candidate.canonicalUrl} />
      </AdminIntakeStateGrid>
      {candidate.snippet ? (
        <AdminSearchCandidateSnippet>{candidate.snippet}</AdminSearchCandidateSnippet>
      ) : null}
      <AdminTagList>
        {matchedEntityIds.length > 0 ? (
          matchedEntityIds.map((entityId) => (
            <AdminTag key={entityId}>
              matches {entityId}
            </AdminTag>
          ))
        ) : (
          <AdminTag tone="muted">no surface match</AdminTag>
        )}
        {candidate.queryIntent.marketSlug ? (
          <AdminTag tone="muted">{candidate.queryIntent.marketSlug}</AdminTag>
        ) : null}
        {candidate.queryIntent.entityHint ? (
          <AdminTag tone="muted">{candidate.queryIntent.entityHint}</AdminTag>
        ) : null}
        {candidate.diagnostics.map((diagnostic) => (
          <AdminTag key={diagnostic} tone="muted">{diagnostic}</AdminTag>
        ))}
      </AdminTagList>
      {candidate.reviewAction !== "supporting_evidence_only" ? (
        <AdminSearchCandidateActions>
          {localCuration ? (
            <AdminIntakeDecisionState>
              <CheckCircle2 size={16} strokeWidth={1.9} />
              <div>
                <strong>Attach recorded</strong>
                <span>{localCuration.decisionPath}</span>
              </div>
            </AdminIntakeDecisionState>
          ) : (
            <AdminButton
              disabled={!canAttach || inFlight}
              onClick={() => onAttachCandidate(candidate)}
            >
              {inFlight ? "Recording" : "Attach surface"}
            </AdminButton>
          )}
          <AdminCommandRow>
            <span>attach</span>
            <code>{attachCommand}</code>
          </AdminCommandRow>
        </AdminSearchCandidateActions>
      ) : null}
    </AdminSearchCandidateCard>
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
    <AdminSearchCandidatePanel>
      <AdminIntakeStateGrid>
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
      </AdminIntakeStateGrid>
      <QualityRow tone="warning" icon={<Clock3 size={16} strokeWidth={1.9} />}>
        <strong>{queue.policy.importWritesEnabled ? "Import writes enabled" : "Import writes disabled"}</strong>
        <span>{queue.policy.reason}</span>
      </QualityRow>
      <AdminTagList>
        {Object.entries(queue.summary.platforms).length === 0 ? (
          <AdminTag tone="muted">no provider batches</AdminTag>
        ) : (
          Object.entries(queue.summary.platforms)
            .sort(([left], [right]) => left.localeCompare(right))
            .map(([platform, count]) => (
              <AdminTag key={platform}>
                {platform} x{count}
              </AdminTag>
            ))
        )}
      </AdminTagList>
      {queue.errors.length > 0 || queue.warnings.length > 0 ? (
        <AdminIntakeSection>
          <AdminIntakeSectionTitle>Event Diagnostics</AdminIntakeSectionTitle>
          <AdminIntakeGateList>
            {[...queue.errors, ...queue.warnings].map((message) => (
              <AdminIntakeGate tone="blocked" key={message}>
                <FileWarning size={15} strokeWidth={1.9} />
                <div>
                  <strong>{message}</strong>
                </div>
              </AdminIntakeGate>
            ))}
          </AdminIntakeGateList>
        </AdminIntakeSection>
      ) : null}
      <AdminSearchCandidateList>
        {visibleCandidates.length === 0 ? (
          <EmptyState icon={<CheckCircle2 size={16} strokeWidth={1.9} />}>
            No external event candidates
          </EmptyState>
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
      </AdminSearchCandidateList>
      <AdminIntakeSection>
        <AdminIntakeSectionTitle>Event Commands</AdminIntakeSectionTitle>
        <AdminCommandStack>
          {Object.entries(queue.commands).map(([label, command]) => (
            <AdminCommandRow key={label}>
              <span>{label}</span>
              <code>{command}</code>
            </AdminCommandRow>
          ))}
        </AdminCommandStack>
      </AdminIntakeSection>
    </AdminSearchCandidatePanel>
  );
}

function OrganizerExternalEventImportPlanView({
  plan,
}: {
  plan: Intake.OrganizerExternalEventImportPlan;
}) {
  const visibleActions = plan.actions.slice(0, 8);

  return (
    <AdminSearchCandidatePanel>
      <AdminIntakeStateGrid>
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
      </AdminIntakeStateGrid>
      <QualityRow tone="warning" icon={<Lock size={16} strokeWidth={1.9} />}>
        <strong>{plan.policy.writeEnabled ? "Writes enabled" : "Writes disabled"}</strong>
        <span>{plan.policy.reason}</span>
      </QualityRow>
      <AdminTagList>
        {plan.guardrails.map((guardrail) => (
          <AdminTag key={guardrail} tone="muted">
            {guardrail}
          </AdminTag>
        ))}
      </AdminTagList>
      <AdminSearchCandidateList>
        {visibleActions.length === 0 ? (
          <EmptyState icon={<CheckCircle2 size={16} strokeWidth={1.9} />}>
            No event import actions
          </EmptyState>
        ) : (
          visibleActions.map((action) => (
            <AdminSearchCandidateCard key={action.actionId}>
              <AdminSearchCandidateHeader>
                <div>
                  <AdminEyebrow>
                    {action.platform} / {action.status}
                  </AdminEyebrow>
                  <h3>{action.proposedReadOnlyEventDraft.eventId}</h3>
                </div>
                <StatusChip tone={action.status === "write_ready" ? "ready" : ""}>
                  {action.action.replaceAll("_", " ")}
                </StatusChip>
              </AdminSearchCandidateHeader>

              <AdminIntakeStateGrid>
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
              </AdminIntakeStateGrid>

              <AdminTagList>
                {action.proposedReadOnlyEventDraft.booking.externalLinks.map((link) => (
                  <AdminTag key={`${link.platform}-${link.url}`} tone="ready">
                    {link.platform} outbound
                  </AdminTag>
                ))}
                {action.blockers.map((blocker) => (
                  <AdminTag key={blocker} tone="muted">
                    {blocker}
                  </AdminTag>
                ))}
                {action.duplicateCandidateIds.map((candidateId) => (
                  <AdminTag key={candidateId} tone="muted">
                    duplicate {candidateId}
                  </AdminTag>
                ))}
              </AdminTagList>
            </AdminSearchCandidateCard>
          ))
        )}
      </AdminSearchCandidateList>
      <AdminIntakeSection>
        <AdminIntakeSectionTitle>Import Commands</AdminIntakeSectionTitle>
        <AdminCommandStack>
          {Object.entries(plan.commands).map(([label, command]) => (
            <AdminCommandRow key={label}>
              <span>{label}</span>
              <code>{command}</code>
            </AdminCommandRow>
          ))}
        </AdminCommandStack>
      </AdminIntakeSection>
    </AdminSearchCandidatePanel>
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
    <AdminSearchCandidatePanel>
      <AdminIntakeStateGrid>
        <StateRow label="Candidates" value={String(queue.summary.candidates)} />
        <StateRow label="Tasks" value={String(queue.summary.tasks)} />
        <StateRow label="Missing coords" value={String(queue.summary.missingExactCoordinates)} />
        <StateRow label="Missing text" value={String(queue.summary.missingLocationText)} />
        <StateRow label="Provider disabled" value={String(queue.summary.providerDisabled)} />
        <StateRow label="Provider" value={queue.policy.provider} />
      </AdminIntakeStateGrid>
      <QualityRow tone="warning" icon={<Lock size={16} strokeWidth={1.9} />}>
        <strong>
          {queue.policy.providerLookupEnabled ? "Provider lookup enabled" : "Provider lookup disabled"}
        </strong>
        <span>{queue.policy.reason}</span>
      </QualityRow>
      <AdminTagList>
        {queue.guardrails.map((guardrail) => (
          <AdminTag key={guardrail} tone="muted">
            {guardrail}
          </AdminTag>
        ))}
      </AdminTagList>
      <AdminSearchCandidateList>
        {visibleTasks.length === 0 ? (
          <EmptyState icon={<CheckCircle2 size={16} strokeWidth={1.9} />}>
            No event location resolution tasks
          </EmptyState>
        ) : (
          visibleTasks.map((task) => {
            const form = forms[task.taskId] ??
              locationResolutionFormFromTask(task);
            const localResolution = localResolutions[task.candidateId];
            return (
              <AdminSearchCandidateCard key={task.taskId}>
                <AdminSearchCandidateHeader>
                  <div>
                    <AdminEyebrow>
                      {task.platform} / {task.resolutionState}
                    </AdminEyebrow>
                    <h3>{task.title}</h3>
                  </div>
                  <StatusChip>
                    {task.countryCode}
                  </StatusChip>
                </AdminSearchCandidateHeader>
                <AdminIntakeStateGrid>
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
                </AdminIntakeStateGrid>
                <AdminTagList>
                  {task.blockers.map((blocker) => (
                    <AdminTag key={blocker} tone="muted">
                      {blocker}
                    </AdminTag>
                  ))}
                </AdminTagList>
                <AdminOrganizerLocationResolutionForm>
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
                    span={2}
                    label="Resolution notes"
                    onChange={(notes) =>
                      onFormChange(task.taskId, {...form, notes})}
                    value={form.notes}
                  />
                  <TextareaField
                    span={2}
                    label="Review note"
                    onChange={(note) =>
                      onFormChange(task.taskId, {...form, note})}
                    rows={2}
                    value={form.note}
                  />
                </AdminOrganizerLocationResolutionForm>
                <AdminSearchCandidateActions>
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
                </AdminSearchCandidateActions>
              </AdminSearchCandidateCard>
            );
          })
        )}
      </AdminSearchCandidateList>
      <AdminIntakeSection>
        <AdminIntakeSectionTitle>Location Commands</AdminIntakeSectionTitle>
        <AdminCommandStack>
          {Object.entries(queue.commands).map(([label, command]) => (
            <AdminCommandRow key={label}>
              <span>{label}</span>
              <code>{command}</code>
            </AdminCommandRow>
          ))}
        </AdminCommandStack>
      </AdminIntakeSection>
    </AdminSearchCandidatePanel>
  );
}

function OrganizerExternalEventImportExecutionPlanView({
  plan,
}: {
  plan: Intake.OrganizerExternalEventImportExecutionPlan;
}) {
  const visibleActions = plan.actions.slice(0, 8);

  return (
    <AdminSearchCandidatePanel>
      <AdminIntakeStateGrid>
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
      </AdminIntakeStateGrid>
      <QualityRow tone="warning" icon={<Lock size={16} strokeWidth={1.9} />}>
        <strong>
          {plan.policy.writeEnabled ? "Execution writes enabled" : "Execution writes disabled"}
        </strong>
        <span>
          {plan.policy.authorityModel} / {plan.policy.reason}
        </span>
      </QualityRow>
      <AdminTagList>
        {plan.guardrails.map((guardrail) => (
          <AdminTag key={guardrail} tone="muted">
            {guardrail}
          </AdminTag>
        ))}
      </AdminTagList>
      <AdminSearchCandidateList>
        {visibleActions.length === 0 ? (
          <EmptyState icon={<CheckCircle2 size={16} strokeWidth={1.9} />}>
            No event import execution actions
          </EmptyState>
        ) : (
          visibleActions.map((action) => (
            <AdminSearchCandidateCard key={action.actionId}>
              <AdminSearchCandidateHeader>
                <div>
                  <AdminEyebrow>
                    {(action.targetWriter ?? action.targetCallable ?? "read-only projection")} / {action.status}
                  </AdminEyebrow>
                  <h3>{action.readOnlyEventProjection?.eventId ?? action.createEventPayload?.eventId ?? action.sourceActionId}</h3>
                </div>
                <StatusChip tone={action.status === "would_publish_read_only" ? "ready" : ""}>
                  {action.sourceAction.replaceAll("_", " ")}
                </StatusChip>
              </AdminSearchCandidateHeader>

              <AdminIntakeStateGrid>
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
              </AdminIntakeStateGrid>

              <AdminTagList>
                {action.blockers.map((blocker) => (
                  <AdminTag key={blocker} tone="muted">
                    {blocker}
                  </AdminTag>
                ))}
              </AdminTagList>

              {(action.projectionValidation?.errors ?? action.payloadValidation.errors).length > 0 ? (
                <AdminIntakeSection>
                  <AdminIntakeSectionTitle>Projection errors</AdminIntakeSectionTitle>
                  <AdminGuardrailList>
                    {(action.projectionValidation?.errors ?? action.payloadValidation.errors).map((error, index) => (
                      <QualityRow
                        key={`${error.path}-${error.keyword}-${index}`}
                        tone="warning"
                        icon={<FileWarning size={16} strokeWidth={1.9} />}>
                        <strong>{error.path}</strong>
                        <span>{error.message}</span>
                      </QualityRow>
                    ))}
                  </AdminGuardrailList>
                </AdminIntakeSection>
              ) : null}
            </AdminSearchCandidateCard>
          ))
        )}
      </AdminSearchCandidateList>
      <AdminIntakeSection>
        <AdminIntakeSectionTitle>Preflight Commands</AdminIntakeSectionTitle>
        <AdminCommandStack>
          {Object.entries(plan.commands).map(([label, command]) => (
            <AdminCommandRow key={label}>
              <span>{label}</span>
              <code>{command}</code>
            </AdminCommandRow>
          ))}
        </AdminCommandStack>
      </AdminIntakeSection>
    </AdminSearchCandidatePanel>
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
    <AdminSearchCandidateCard>
      <AdminSearchCandidateHeader>
        <div>
          <AdminEyebrow>
            {candidate.platform} / {candidate.reviewStatus}
          </AdminEyebrow>
          <h3>{candidate.title}</h3>
        </div>
        <StatusChip tone={candidate.reviewStatus === "approved_for_import" ? "ready" : ""}>
          {candidate.entityId}
        </StatusChip>
      </AdminSearchCandidateHeader>
      <AdminIntakeStateGrid>
        <StateRow label="Candidate" value={candidate.candidateId} />
        <StateRow label="Surface" value={candidate.surfaceId} />
        <StateRow label="Starts" value={candidate.startAt} />
        <StateRow label="Ends" value={candidate.endAt ?? "unknown"} />
        <StateRow label="Location" value={eventCandidateLocation(candidate)} />
        <StateRow label="Import" value={`${candidate.importReadiness} / ${candidate.importState}`} />
      </AdminIntakeStateGrid>
      <AdminTagList>
        {candidate.blockers.map((blocker) => (
          <AdminTag key={blocker} tone="muted">{blocker}</AdminTag>
        ))}
        {candidate.diagnostics.map((diagnostic) => (
          <AdminTag key={diagnostic} tone="muted">{diagnostic}</AdminTag>
        ))}
      </AdminTagList>
      {submittedDecision ? (
        <AdminIntakeDecisionState>
          <CheckCircle2 size={16} strokeWidth={1.9} />
          <div>
            <strong>{eventDecisionLabel(submittedDecision)}</strong>
            <span>
              {localDecision ?
                `${localDecision.decisionPath} / ${localDecision.importState}` :
                `Decision present in ${candidate.reviewDecision?.eventReviewBatchId}`}
            </span>
          </div>
        </AdminIntakeDecisionState>
      ) : (
        <AdminIntakeDecisionBox>
          <TextareaField
            label="Event review note"
            onChange={onNoteChange}
            rows={3}
            value={note}
          />
          <AdminIntakeDecisionActions>
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
          </AdminIntakeDecisionActions>
        </AdminIntakeDecisionBox>
      )}
    </AdminSearchCandidateCard>
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
    <AdminOrganizerIntakeCard>
      <AdminOrganizerIntakeCardHeader>
        <div>
          <AdminEyebrow>
            {item.priority} / {item.taskType.replaceAll("_", " ")}
          </AdminEyebrow>
          <h3>{item.displayName}</h3>
        </div>
        <AdminOrganizerIntakeBadges>
          <StatusChip tone={item.projectionStatus}>
            {item.projectionStatus}
          </StatusChip>
          <StatusChip>{item.relationshipToCatch}</StatusChip>
        </AdminOrganizerIntakeBadges>
      </AdminOrganizerIntakeCardHeader>
      <AdminIntakeStateGrid>
        <StateRow label="Entity ID" value={item.entityId} />
        <StateRow label="Canonical" value={item.canonicalPath} />
        <StateRow label="Website" value={`${item.publishStatus} / ${item.indexStatus}`} />
        <StateRow label="App" value={item.appVisibility} />
      </AdminIntakeStateGrid>
      {item.curation ? (
        <AdminOrganizerIntakeCurationPanel>
          <AdminIntakeSectionTitle>Curation</AdminIntakeSectionTitle>
          <AdminTagList>
            {item.curation.attachedSurfaces.map((surface) => (
              <AdminTag key={`attached-${surface.surfaceId}`}>
                attached {surface.surfaceId}
              </AdminTag>
            ))}
            {item.curation.mergedFrom.map((entityId) => (
              <AdminTag key={`merged-${entityId}`}>
                merged {entityId}
              </AdminTag>
            ))}
            {item.curation.mergedInto ? (
              <AdminTag tone="muted">
                merged into {item.curation.mergedInto}
              </AdminTag>
            ) : null}
            {item.curation.suppressed ? (
              <AdminTag tone="muted">
                suppressed
              </AdminTag>
            ) : null}
            {item.curation.surfaceDecisions.map((decision) => (
              <AdminTag key={`${decision.surfaceId}-${decision.decision}`}>
                {decision.surfaceId}: {decision.decision}
              </AdminTag>
            ))}
            {item.curation.splitSurfaces.map((split) => (
              <AdminTag key={`${split.surfaceId}-${split.newEntityId}`} tone="muted">
                split {split.surfaceId} to {split.newEntityId}
              </AdminTag>
            ))}
          </AdminTagList>
        </AdminOrganizerIntakeCurationPanel>
      ) : null}
      <AdminIntakeSection>
        <AdminIntakeSectionTitle>Markets</AdminIntakeSectionTitle>
        <AdminTagList>
          {item.markets.map((market) => (
            <AdminTag key={market.marketSlug}>
              {market.displayName} / {market.eventFilter.citySlug}
            </AdminTag>
          ))}
          {item.legacyPaths.map((path) => (
            <AdminTag key={path} tone="muted">{path}</AdminTag>
          ))}
        </AdminTagList>
      </AdminIntakeSection>
      <AdminIntakeSection>
        <AdminIntakeSectionTitle>Surface Inventory</AdminIntakeSectionTitle>
        <AdminOrganizerIntakeSurfaceGrid>
          <StateRow label="Active" value={String(item.surfaceSummary.active)} />
          <StateRow label="Candidate" value={String(item.surfaceSummary.candidate)} />
          <StateRow label="Ambiguous" value={String(item.surfaceSummary.ambiguous)} />
          <StateRow label="Rejected" value={String(item.surfaceSummary.rejected)} />
        </AdminOrganizerIntakeSurfaceGrid>
        <AdminTagList>
          {platformEntries.map(([platform, count]) => (
            <AdminTag key={platform}>
              {platform} x{count}
            </AdminTag>
          ))}
        </AdminTagList>
        <AdminOrganizerSurfaceList>
          {item.surfaces.map((surface) => (
            <AdminOrganizerSurfaceRow key={surface.surfaceId}>
              <div>
                <strong>{surface.surfaceId}</strong>
                <span>
                  {surface.platform} / {surface.surfaceKind} / {surface.status}
                </span>
              </div>
              <span>{surface.role}</span>
            </AdminOrganizerSurfaceRow>
          ))}
        </AdminOrganizerSurfaceList>
      </AdminIntakeSection>
      <AdminIntakeSection>
        <AdminIntakeSectionTitle>Review Gates</AdminIntakeSectionTitle>
        <AdminIntakeGateList>
          {item.gates.map((gate) => (
            <AdminIntakeGate
              tone={gate.passed ? "passed" : "blocked"}
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
            </AdminIntakeGate>
          ))}
        </AdminIntakeGateList>
      </AdminIntakeSection>
      <OrganizerCurationControl
        form={curationForm}
        inFlight={curationInFlight}
        item={item}
        localCuration={curationResult}
        onChange={onCurationFormChange}
        onSubmit={onCurationSubmit}
        targetOptions={entityOptions}
      />
      <AdminIntakeSection>
        <AdminIntakeSectionTitle>Admin Decision</AdminIntakeSectionTitle>
        {publicationPacket ? (
          <QualityRow
            tone={publicationPacketReady(publicationPacket) ? "" : "warning"}
            icon={publicationPacketReady(publicationPacket) ? (
              <CheckCircle2 size={16} strokeWidth={1.9} />
            ) : (
              <FileWarning size={16} strokeWidth={1.9} />
            )}>
            <strong>{publicationPacket.status.replaceAll("_", " ")}</strong>
            <span>
              {manualReportCount > 0 ?
                `${manualReportCount} manual report(s) require reviewer acknowledgement.` :
                publicationPacket.recommendedAction}
            </span>
          </QualityRow>
        ) : (
          <QualityRow tone="warning" icon={<FileWarning size={16} strokeWidth={1.9} />}>
            <strong>Publication packet missing</strong>
            <span>Regenerate organizer intake before public approval.</span>
          </QualityRow>
        )}
        {submittedDecision ? (
          <AdminIntakeDecisionState>
            <CheckCircle2 size={16} strokeWidth={1.9} />
            <div>
              <strong>{decisionLabel(submittedDecision)}</strong>
              <span>
                {localDecision ?
                  `${localDecision.decisionPath} / ${localDecision.projectionState}` :
                  "Decision present in generated review state"}
              </span>
            </div>
          </AdminIntakeDecisionState>
        ) : (
          <AdminIntakeDecisionBox>
            <TextareaField
              label="Review note"
              onChange={onNoteChange}
              rows={3}
              value={note}
            />
            {manualReportCount > 0 ? (
              <AdminOrganizerIntakeCheckboxField
                checked={manualReportsAcknowledged}
                disabled={isDeciding}
                label="Manual reports reviewed as prompts, not identity proof."
                onChange={onManualReportsAcknowledgedChange}
              />
            ) : null}
            <AdminIntakeDecisionActions>
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
            </AdminIntakeDecisionActions>
          </AdminIntakeDecisionBox>
        )}
      </AdminIntakeSection>
      <AdminIntakeSection>
        <AdminIntakeSectionTitle>Decision Commands</AdminIntakeSectionTitle>
        <AdminCommandStack>
          {commandEntries.map(([label, command]) => (
            <AdminCommandRow key={label}>
              <span>{label}</span>
              <code>{command}</code>
            </AdminCommandRow>
          ))}
        </AdminCommandStack>
      </AdminIntakeSection>
    </AdminOrganizerIntakeCard>
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
    <AdminOrganizerCurationControlSection>
      <AdminIntakeSectionTitle>Curation Operation</AdminIntakeSectionTitle>
      <AdminOrganizerCurationControlGrid>
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
      </AdminOrganizerCurationControlGrid>
      {usesSurface && selectedSurface ? (
        <AdminSurfacePreview>
          <strong>{selectedSurface.platform} / {selectedSurface.surfaceKind}</strong>
          <span>{selectedSurface.url ?? "no URL captured"}</span>
          <span>{selectedSurface.notes}</span>
        </AdminSurfacePreview>
      ) : null}
      <TextareaField
        label="Curation reason"
        onChange={(value) => update("reason", value)}
        rows={2}
        value={form.reason}
      />
      {localCuration ? (
        <AdminIntakeDecisionState>
          <CheckCircle2 size={16} strokeWidth={1.9} />
          <div>
            <strong>{localCuration.operationType.replaceAll("_", " ")}</strong>
            <span>{localCuration.decisionPath}</span>
          </div>
        </AdminIntakeDecisionState>
      ) : null}
      <AdminIntakeDecisionActions>
        <AdminButton
          disabled={inFlight}
          onClick={() => onSubmit(form)}
          variant="primary"
        >
          {inFlight ? "Recording" : "Record curation"}
        </AdminButton>
      </AdminIntakeDecisionActions>
    </AdminOrganizerCurationControlSection>
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
