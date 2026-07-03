import {
  CheckCircle2,
  Clock3,
  FileWarning,
  RefreshCw,
  Search,
  ShieldCheck,
  UserCheck,
} from "lucide-react";
import type {
  AccessApplicationDecision,
  AdminAccessApplicationDetails,
  AdminQueueItem,
} from "../../../shared/types/adminTypes";
import {
  AdminButton,
  AdminEditorGrid,
  AdminEditorPanel,
  AdminEditorSection,
  AdminFieldGrid,
  AdminForm,
  AdminMetricCard,
  AdminMetricGrid,
  AdminMutedCell,
  AdminRoadmapList,
  AdminRoadmapListItem,
  AdminTableRow,
  AdminTag,
  AdminToolbar,
  AdminWorkbenchStack,
  DataTable,
  EmptyState,
  Panel,
  QualityList,
  SearchField,
  StateRow,
  TableActionButton,
  TextareaField,
  TextField,
  AdminRowTitle,
  AdminTagRow,
} from "../../../shared/ui/AdminPrimitives";
import {
  applicationUidFromTargetPath,
  type AccessReviewFormState,
  type AccessReviewController,
  type AccessRecentDecision,
  useAccessReviewController,
} from "../controllers/useAccessReviewController";

export function AccessReviewScreen({
  onError,
  onNotice,
}: {
  onError: (message: string | null) => void;
  onNotice: (message: string | null) => void;
}) {
  const controller = useAccessReviewController({onError, onNotice});
  return <AccessReviewWorkspace controller={controller} />;
}

export function AccessReviewWorkspace({
  controller,
}: {
  controller: AccessReviewController;
}) {
  return (
    <AdminWorkbenchStack>
      <AdminMetricGrid ariaLabel="Access review state">
        <AdminMetricCard label="Pending" value={controller.rows.length} />
        <AdminMetricCard label="Shown" value={controller.filteredRows.length} />
        <AdminMetricCard label="Recent decisions" value={controller.recentDecisions.length} />
        <AdminMetricCard
          label="Needs note"
          tone={controller.selected && controller.validationIssue ?
            "attention" :
            "normal"}
          value={controller.selected && controller.validationIssue ? 1 : 0}
        />
      </AdminMetricGrid>
      <Panel
        span={2}
        icon={<UserCheck size={18} strokeWidth={1.9} />}
        title="Access applications"
        action={controller.isLoading ? "Loading" : `${controller.filteredRows.length} shown`}
      >
        <AdminToolbar>
          <SearchField
            ariaLabel="Search access applications"
            icon={<Search size={16} strokeWidth={1.8} />}
            onChange={controller.setQuery}
            placeholder="Search applicant, city, role, uid, source"
            value={controller.query}
          />
          <AdminButton
            disabled={controller.isLoading}
            icon={<RefreshCw size={15} strokeWidth={1.9} />}
            onClick={() => void controller.refresh()}
          >
            Refresh
          </AdminButton>
        </AdminToolbar>
        <AccessTable
          rows={controller.filteredRows}
          selectedTargetPath={controller.selected?.targetPath ?? null}
          onSelect={controller.select}
        />
      </Panel>
      <AdminEditorGrid>
        <AccessDecisionPanel
          decisionInFlight={controller.decisionInFlight}
          form={controller.form}
          selected={controller.selected}
          validationIssue={controller.validationIssue}
          onDecide={(decision) => void controller.decide(decision)}
          onFormChange={controller.setForm}
        />
        <AdminWorkbenchStack>
          <AccessApplicantDetailPanel
            details={controller.selectedDetails}
            isLoading={controller.isDetailLoading}
            selected={controller.selected}
          />
          <RecentDecisionsPanel decisions={controller.recentDecisions} />
          <Panel
            icon={<ShieldCheck size={18} strokeWidth={1.9} />}
            title="Mutation boundary"
            action="audited"
          >
            <QualityList>
              <StateRow label="Callable" value="adminDecideAccessApplication" />
              <StateRow label="Collection" value="accessApplications/{uid}" />
              <StateRow label="Audit log" value="adminAuditLogs/{id}" />
              <StateRow label="Required role" value="admin, adminOwner, support" />
              <StateRow label="Not here" value="profile lookup, safety, payments" />
            </QualityList>
          </Panel>
        </AdminWorkbenchStack>
      </AdminEditorGrid>
    </AdminWorkbenchStack>
  );
}

function AccessTable({
  onSelect,
  rows,
  selectedTargetPath,
}: {
  onSelect: (row: AdminQueueItem) => void;
  rows: AdminQueueItem[];
  selectedTargetPath: string | null;
}) {
  if (rows.length === 0) {
    return (
      <EmptyState
        variant="workbench"
        icon={<CheckCircle2 size={16} strokeWidth={1.9} />}
      >
        No pending access applications match this filter.
      </EmptyState>
    );
  }
  return (
    <DataTable variant="workbench">
      <thead>
        <tr>
          <th>Applicant</th>
          <th>Signal</th>
          <th>Status</th>
          <th>Created</th>
          <th>Select</th>
        </tr>
      </thead>
      <tbody>
        {rows.map((row) => (
          <AdminTableRow key={row.id} selected={selectedTargetPath === row.targetPath}>
            <td>
              <AdminRowTitle>
                <strong>{row.title}</strong>
                <span>{applicationUidFromTargetPath(row.targetPath) ?? row.id}</span>
              </AdminRowTitle>
            </td>
            <td>{row.detail}</td>
            <td><AdminTag tone="muted">{row.status}</AdminTag></td>
            <td>{relativeTime(row.createdAt)}</td>
            <td>
              <TableActionButton onClick={() => onSelect(row)}>
                Review
              </TableActionButton>
            </td>
          </AdminTableRow>
        ))}
      </tbody>
    </DataTable>
  );
}

function AccessApplicantDetailPanel({
  details,
  isLoading,
  selected,
}: {
  details: AdminAccessApplicationDetails | null;
  isLoading: boolean;
  selected: AdminQueueItem | null;
}) {
  return (
    <Panel
      icon={<UserCheck size={18} strokeWidth={1.9} />}
      title="Applicant detail"
      action={isLoading ? "Loading" : details?.status ?? "No application"}
    >
      {details ? (
        <QualityList>
          <StateRow label="Application" value={details.targetPath} />
          <StateRow label="City" value={details.city} />
          <StateRow label="Role" value={details.role} />
          <StateRow
            label="Wants to host"
            value={details.wantsToHost ? "yes" : "no"}
          />
          <StateRow label="Invite code" value={details.inviteCode} />
          <StateRow label="Instagram" value={details.instagramHandle} />
          <StateRow label="Referral" value={details.referralSource} />
          <StateRow label="Submissions" value={String(details.submissionCount)} />
          <StateRow label="Submitted" value={formatDateTime(details.submittedAt)} />
          <StateRow
            label="Event types"
            value={<TagList values={details.eventTypes} />}
          />
          <StateRow
            label="Availability"
            value={<TagList values={details.availabilityWindows} />}
          />
          <StateRow label="Why Catch" value={details.whyCatch} />
          <DuplicateSignals signals={details.duplicateSignals} />
        </QualityList>
      ) : (
        <EmptyState
          variant="workbench"
          icon={<Clock3 size={16} strokeWidth={1.9} />}
        >
          {selected ?
            "Loading applicant detail." :
            "Select an access application to inspect source detail."}
        </EmptyState>
      )}
    </Panel>
  );
}

function TagList({values}: {values: string[]}) {
  if (values.length === 0) return "none";
  return (
    <AdminTagRow as="span">
      {values.map((value) => (
        <AdminTag key={value} tone="muted">{formatLabel(value)}</AdminTag>
      ))}
    </AdminTagRow>
  );
}

function DuplicateSignals({
  signals,
}: {
  signals: AdminAccessApplicationDetails["duplicateSignals"];
}) {
  if (signals.length === 0) {
    return (
      <AdminRoadmapListItem>
        <CheckCircle2 size={15} strokeWidth={1.9} />
        <span>No deterministic overlap signals found.</span>
      </AdminRoadmapListItem>
    );
  }
  return (
    <AdminRoadmapList>
      {signals.map((signal) => (
        <AdminRoadmapListItem key={signal.id}>
          <FileWarning size={15} strokeWidth={1.9} />
          <span>
            <strong>{signal.label}</strong> · {signal.count} overlaps ·{" "}
            {signal.value}
            {signal.sampleTargetPaths.length > 0 ? (
              <AdminMutedCell>
                {" "}({signal.sampleTargetPaths.join(", ")})
              </AdminMutedCell>
            ) : null}
          </span>
        </AdminRoadmapListItem>
      ))}
    </AdminRoadmapList>
  );
}

function AccessDecisionPanel({
  decisionInFlight,
  form,
  onDecide,
  onFormChange,
  selected,
  validationIssue,
}: {
  decisionInFlight: AccessApplicationDecision | null;
  form: AccessReviewFormState;
  onDecide: (decision: AccessApplicationDecision) => void;
  onFormChange: (form: AccessReviewFormState) => void;
  selected: AdminQueueItem | null;
  validationIssue: string | null;
}) {
  const isDeciding = decisionInFlight !== null;
  const isDecisionDisabled = isDeciding || Boolean(validationIssue);
  return (
    <AdminEditorPanel
      icon={<ShieldCheck size={18} strokeWidth={1.9} />}
      title="Review decision"
      action={selected?.status ?? "No application"}
    >
      {selected ? (
        <AdminForm variant="publishing" onSubmit={(event) => {
          event.preventDefault();
        }}>
          <AdminEditorSection>
            <legend>Applicant context</legend>
            <QualityList>
              <StateRow label="Applicant" value={selected.title} />
              <StateRow
                label="Application uid"
                value={applicationUidFromTargetPath(selected.targetPath)}
              />
              <StateRow label="Detail" value={selected.detail} />
              <StateRow label="Created" value={formatDateTime(selected.createdAt)} />
            </QualityList>
          </AdminEditorSection>
          <AdminEditorSection>
            <legend>Decision inputs</legend>
            <AdminFieldGrid columns={2}>
              <TextField
                label="Cohort id"
                onChange={(cohortId) => onFormChange({...form, cohortId})}
                placeholder="indore-founders"
                value={form.cohortId}
              />
              <ReadonlyState
                label="Review note"
                value={`${form.note.trim().length}/1000`}
              />
            </AdminFieldGrid>
            <TextareaField
              label="Review note"
              onChange={(note) => onFormChange({...form, note})}
              rows={5}
              value={form.note}
            />
            {validationIssue ? (
              <AdminRoadmapListItem>
                <FileWarning size={15} strokeWidth={1.9} />
                <span>{validationIssue}</span>
              </AdminRoadmapListItem>
            ) : null}
          </AdminEditorSection>
          <AdminTagRow>
            <AdminButton
              disabled={isDecisionDisabled}
              icon={<CheckCircle2 size={15} strokeWidth={1.9} />}
              onClick={() => onDecide("approve")}
              variant="primary"
            >
              {decisionInFlight === "approve" ? "Approving" : "Approve"}
            </AdminButton>
            <AdminButton
              disabled={isDecisionDisabled}
              icon={<FileWarning size={15} strokeWidth={1.9} />}
              onClick={() => onDecide("deny")}
            >
              {decisionInFlight === "deny" ? "Denying" : "Deny"}
            </AdminButton>
          </AdminTagRow>
        </AdminForm>
      ) : (
        <EmptyState
          variant="workbench"
          icon={<Clock3 size={16} strokeWidth={1.9} />}
        >
          Select an access application to review.
        </EmptyState>
      )}
    </AdminEditorPanel>
  );
}

function RecentDecisionsPanel({
  decisions,
}: {
  decisions: AccessRecentDecision[];
}) {
  return (
    <Panel
      icon={<CheckCircle2 size={18} strokeWidth={1.9} />}
      title="Recent decisions"
      action={`${decisions.length} local`}
    >
      {decisions.length === 0 ? (
        <EmptyState icon={<Clock3 size={16} strokeWidth={1.9} />}>
          No decisions in this session.
        </EmptyState>
      ) : (
        <AdminRoadmapList>
          {decisions.map((decision) => (
            <AdminRoadmapListItem
              key={`${decision.applicationUid}-${decision.status}`}
            >
              <CheckCircle2 size={15} strokeWidth={1.9} />
              <span>
                <strong>{decision.title}</strong> · {decision.decision} ·{" "}
                {decision.status}
              </span>
            </AdminRoadmapListItem>
          ))}
        </AdminRoadmapList>
      )}
    </Panel>
  );
}

function ReadonlyState({
  label,
  value,
}: {
  label: string;
  value: string;
}) {
  return <StateRow label={label} value={value} />;
}

function relativeTime(value: string | null): string {
  if (!value) return "unknown";
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return value;
  const diffMs = Date.now() - date.getTime();
  const diffHours = Math.round(diffMs / 3600000);
  if (Math.abs(diffHours) < 24) return `${diffHours}h ago`;
  return `${Math.round(diffHours / 24)}d ago`;
}

function formatDateTime(value: string | null): string {
  if (!value) return "unknown";
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return value;
  return new Intl.DateTimeFormat("en-IN", {
    dateStyle: "medium",
    timeStyle: "short",
  }).format(date);
}

function formatLabel(value: string): string {
  return value
    .replace(/([a-z])([A-Z])/g, "$1 $2")
    .replace(/[_-]+/g, " ")
    .replace(/\b\w/g, (character) => character.toUpperCase());
}
