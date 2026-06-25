import {
  AlertTriangle,
  Clock3,
  RefreshCw,
  Search,
  ShieldAlert,
  ShieldCheck,
} from "lucide-react";
import {
  AdminButton,
  AdminTag,
  DataTable,
  EmptyState,
  Panel,
  RiskBadge,
  SearchField,
  SelectField,
  StateRow,
  TableActionButton,
  TextareaField,
  TextField,
} from "../../../shared/ui/AdminPrimitives";
import type {
  AdminSafetyTriageDecision,
  AdminSafetyTriageDetails,
} from
  "../../../shared/types/adminTypes";
import {
  type SafetyAssignmentFormState,
  type SafetyAssignmentRecord,
  type SafetyDecisionFormState,
  type SafetyDecisionRecord,
  type SafetyQueueKind,
  type SafetyTriageRow,
  useSafetyTriageController,
} from "../controllers/useSafetyTriageController";

const queueOptions: Array<{label: string; value: SafetyQueueKind}> = [
  {label: "All queues", value: "all"},
  {label: "User reports", value: "reports"},
  {label: "Moderation flags", value: "moderation"},
  {label: "Event reports", value: "event"},
];

export function SafetyTriageScreen({
  onError,
  onNotice,
}: {
  onError: (message: string | null) => void;
  onNotice: (message: string | null) => void;
}) {
  const controller = useSafetyTriageController({onError, onNotice});
  return (
    <div className="workbench-stack">
      <section className="metric-grid" aria-label="Safety triage state">
        <Metric label="Open reports" value={controller.metrics.reports} />
        <Metric label="Moderation" value={controller.metrics.moderation} />
        <Metric label="Event reports" value={controller.metrics.eventReports} />
        <Metric
          label="High priority"
          tone={controller.metrics.highPriority > 0 ? "attention" : "normal"}
          value={controller.metrics.highPriority}
        />
      </section>

      <Panel
        className="span-2"
        icon={<ShieldAlert size={18} strokeWidth={1.9} />}
        title="Safety triage"
        action={controller.isLoading ? "Loading" : `${controller.filteredRows.length} shown`}
      >
        <div className="workbench-toolbar">
          <SearchField
            ariaLabel="Search safety queues"
            icon={<Search size={16} strokeWidth={1.8} />}
            onChange={controller.setQuery}
            placeholder="Search report, target, status, owner"
            value={controller.query}
          />
          <SelectField
            label="Queue"
            onChange={(value) =>
              controller.setQueueFilter(value as SafetyQueueKind)
            }
            options={queueOptions}
            value={controller.queueFilter}
          />
          <AdminButton
            disabled={controller.isLoading}
            icon={<RefreshCw size={15} strokeWidth={1.9} />}
            onClick={() => void controller.refresh()}
          >
            Refresh
          </AdminButton>
        </div>
        <SafetyTable
          rows={controller.filteredRows}
          selectedTargetPath={controller.selected?.targetPath ?? null}
          onSelect={controller.select}
        />
      </Panel>

      <section className="publishing-editor-grid">
        <SafetyDetailPanel
          detail={controller.selectedDetail}
          generatedAt={controller.generatedAt}
          isDetailLoading={controller.isDetailLoading}
          selected={controller.selected}
        />
        <div className="workbench-stack">
          <SafetyAssignmentPanel
            assignmentForm={controller.assignmentForm}
            assignmentInFlight={controller.assignmentInFlight}
            assignmentValidationIssue={controller.assignmentValidationIssue}
            onAssign={controller.assign}
            onAssignmentFormChange={controller.setAssignmentForm}
            recentAssignments={controller.recentAssignments}
            selected={controller.selected}
          />
          <SafetyDecisionPanel
            decisionForm={controller.decisionForm}
            decisionInFlight={controller.decisionInFlight}
            decisionValidationIssue={controller.decisionValidationIssue}
            onDecision={controller.decide}
            onDecisionFormChange={controller.setDecisionForm}
            recentDecisions={controller.recentDecisions}
            selected={controller.selected}
          />
          <Panel
            icon={<ShieldCheck size={18} strokeWidth={1.9} />}
            title="Action boundary"
            action="status-only"
          >
            <div className="quality-list">
              <StateRow label="Source" value="adminGetOverview + adminGetSafetyTriageDetails" />
              <StateRow label="Mutations" value="adminAssignSafetyTriageItem, adminDecideSafetyTriageItem" />
              <StateRow label="Scope" value="assignment plus reviewed/dismissed status with required notes" />
              <StateRow label="Read contract" value="assignment, SLA, evidence, next actions" />
              <StateRow label="Not here" value="restrictions, escalation, payment disputes, organizer publishing" />
            </div>
          </Panel>
          <Panel
            icon={<AlertTriangle size={18} strokeWidth={1.9} />}
            title="Policy checklist"
            action="manual"
          >
            <div className="roadmap-list">
              <ChecklistRow text="Open the source document before resolving." />
              <ChecklistRow text="Confirm reporter, subject, event, and channel context." />
              <ChecklistRow text="Use backend-owned actions only after policy outcome is explicit." />
            </div>
          </Panel>
        </div>
      </section>
    </div>
  );
}

function SafetyAssignmentPanel({
  assignmentForm,
  assignmentInFlight,
  assignmentValidationIssue,
  onAssign,
  onAssignmentFormChange,
  recentAssignments,
  selected,
}: {
  assignmentForm: SafetyAssignmentFormState;
  assignmentInFlight: boolean;
  assignmentValidationIssue: string | null;
  onAssign: () => Promise<boolean>;
  onAssignmentFormChange: (value: SafetyAssignmentFormState) => void;
  recentAssignments: SafetyAssignmentRecord[];
  selected: SafetyTriageRow | null;
}) {
  const isDisabled =
    !selected || Boolean(assignmentValidationIssue) || assignmentInFlight;
  return (
    <Panel
      icon={<ShieldCheck size={18} strokeWidth={1.9} />}
      title="Assignment"
      action={selected ? "audited" : "No item"}
    >
      <div className="quality-list">
        <StateRow
          label="Selected"
          value={selected ? selected.targetPath : "Select a queue row"}
        />
        <TextField
          label="Assignee uid"
          onChange={(assigneeUid) =>
            onAssignmentFormChange({...assignmentForm, assigneeUid})
          }
          placeholder="reviewer_uid"
          value={assignmentForm.assigneeUid}
        />
        <TextareaField
          label="Assignment note"
          onChange={(note) =>
            onAssignmentFormChange({...assignmentForm, note})
          }
          placeholder="Record why this owner should take the next action."
          rows={3}
          value={assignmentForm.note}
        />
        <StateRow
          label="Assignment check"
          value={assignmentValidationIssue ?? "Ready"}
        />
        <AdminButton
          disabled={isDisabled}
          onClick={() => void onAssign()}
          variant="primary"
        >
          {assignmentInFlight ? "Saving" : "Save assignment"}
        </AdminButton>
        {recentAssignments.length ? (
          <div className="roadmap-list">
            {recentAssignments.map((record) => (
              <ChecklistRow
                key={`${record.targetPath}-${record.assignment.assigneeUid ?? "unassigned"}`}
                text={
                  `${record.targetPath}: ` +
                  `${record.assignment.assigneeUid ?? "Unassigned"}`
                }
              />
            ))}
          </div>
        ) : (
          <StateRow label="Recent assignments" value="None this session" />
        )}
      </div>
    </Panel>
  );
}

function SafetyDecisionPanel({
  decisionForm,
  decisionInFlight,
  decisionValidationIssue,
  onDecision,
  onDecisionFormChange,
  recentDecisions,
  selected,
}: {
  decisionForm: SafetyDecisionFormState;
  decisionInFlight: AdminSafetyTriageDecision | null;
  decisionValidationIssue: string | null;
  onDecision: (decision: AdminSafetyTriageDecision) => Promise<boolean>;
  onDecisionFormChange: (value: SafetyDecisionFormState) => void;
  recentDecisions: SafetyDecisionRecord[];
  selected: SafetyTriageRow | null;
}) {
  const isDisabled =
    !selected || Boolean(decisionValidationIssue) || Boolean(decisionInFlight);
  return (
    <Panel
      icon={<ShieldCheck size={18} strokeWidth={1.9} />}
      title="Decision"
      action={selected ? "audited" : "No item"}
    >
      <div className="quality-list">
        <StateRow
          label="Selected"
          value={selected ? selected.targetPath : "Select a queue row"}
        />
        <TextareaField
          label="Review note"
          onChange={(note) => onDecisionFormChange({note})}
          placeholder="Record the evidence checked and why this status is correct."
          rows={4}
          value={decisionForm.note}
        />
        <StateRow
          label="Decision check"
          value={decisionValidationIssue ?? "Ready"}
        />
        <div className="workbench-toolbar">
          <AdminButton
            disabled={isDisabled}
            onClick={() => void onDecision("review")}
            variant="primary"
          >
            {decisionInFlight === "review" ? "Reviewing" : "Mark reviewed"}
          </AdminButton>
          <AdminButton
            disabled={isDisabled}
            onClick={() => void onDecision("dismiss")}
          >
            {decisionInFlight === "dismiss" ? "Dismissing" : "Dismiss"}
          </AdminButton>
        </div>
        {recentDecisions.length ? (
          <div className="roadmap-list">
            {recentDecisions.map((record) => (
              <ChecklistRow
                key={`${record.targetPath}-${record.status}`}
                text={`${record.status}: ${record.targetPath}`}
              />
            ))}
          </div>
        ) : (
          <StateRow label="Recent decisions" value="None this session" />
        )}
      </div>
    </Panel>
  );
}

function SafetyTable({
  onSelect,
  rows,
  selectedTargetPath,
}: {
  onSelect: (row: SafetyTriageRow) => void;
  rows: SafetyTriageRow[];
  selectedTargetPath: string | null;
}) {
  if (rows.length === 0) {
    return (
      <EmptyState
        className="workbench-empty"
        icon={<ShieldCheck size={16} strokeWidth={1.9} />}
      >
        No safety queue rows match this filter.
      </EmptyState>
    );
  }
  return (
    <DataTable className="workbench-table">
      <thead>
        <tr>
          <th>Queue item</th>
          <th>Priority</th>
          <th>Status</th>
          <th>Owner</th>
          <th>Created</th>
          <th>Select</th>
        </tr>
      </thead>
      <tbody>
        {rows.map((row) => (
          <tr
            className={selectedTargetPath === row.targetPath ? "selected-row" : ""}
            key={row.id}
          >
            <td>
              <div className="row-title">
                <strong>{row.title}</strong>
                <span>{row.queueLabel} · {row.detail}</span>
              </div>
            </td>
            <td>
              <RiskBadge tone={riskTone(row.priority)}>
                {row.priority}
              </RiskBadge>
            </td>
            <td>{row.status}</td>
            <td>{row.routeOwner}</td>
            <td>{relativeTime(row.createdAt)}</td>
            <td>
              <TableActionButton onClick={() => onSelect(row)}>
                Review
              </TableActionButton>
            </td>
          </tr>
        ))}
      </tbody>
    </DataTable>
  );
}

function SafetyDetailPanel({
  detail,
  generatedAt,
  isDetailLoading,
  selected,
}: {
  detail: AdminSafetyTriageDetails | null;
  generatedAt: string | null;
  isDetailLoading: boolean;
  selected: SafetyTriageRow | null;
}) {
  return (
    <Panel
      className="publishing-editor-panel"
      icon={<ShieldAlert size={18} strokeWidth={1.9} />}
      title="Triage detail"
      action={selected?.priority ?? "No item"}
    >
      {selected ? (
        <div className="quality-list">
          <StateRow label="Queue" value={selected.queueLabel} />
          <StateRow label="Target" value={selected.targetPath} />
          <StateRow label="Status" value={selected.status} />
          <StateRow label="Owner" value={selected.routeOwner} />
          <StateRow label="Detail" value={selected.detail} />
          <StateRow
            label="Detail read"
            value={isDetailLoading ? "Loading" : detail ? "Loaded" : "Unavailable"}
          />
          {detail ? (
            <>
              <StateRow label="Summary" value={detail.summary} />
              <StateRow label="Primary user" value={detail.primaryUserId} />
              <StateRow label="Secondary user" value={detail.secondaryUserId} />
              <StateRow label="Event" value={detail.eventId} />
              <StateRow label="Club" value={detail.clubId} />
              <StateRow label="Source" value={detail.source} />
              <StateRow label="Context" value={detail.contextId} />
              <StateRow
                label="Owner team"
                value={detail.assignment.ownerTeam}
              />
              <StateRow
                label="Assignee"
                value={detail.assignment.assigneeUid ?? "Unassigned"}
              />
              <StateRow
                label="Severity"
                value={detail.assignment.severity}
              />
              <StateRow label="SLA" value={formatSla(detail)} />
              <StateRow label="SLA policy" value={detail.sla.policy} />
              <StateRow
                label="Prior history"
                value={<PriorHistoryList detail={detail} />}
              />
              <StateRow
                label="Outcome guidance"
                value={<OutcomeGuidanceList detail={detail} />}
              />
              {detail.evidence.map((item) => (
                <StateRow
                  key={`${item.label}-${item.value}`}
                  label={`Evidence: ${item.label}`}
                  value={formatEvidence(item)}
                />
              ))}
              {detail.fields.map((field) => (
                <StateRow
                  key={`${field.label}-${field.value}`}
                  label={field.label}
                  value={field.value}
                />
              ))}
            </>
          ) : null}
          <StateRow label="Created" value={formatDateTime(selected.createdAt)} />
          <StateRow label="Queue generated" value={formatDateTime(generatedAt)} />
          {detail?.nextActions.length ? (
            <div className="roadmap-list">
              {detail.nextActions.map((action) => (
                <ChecklistRow key={action} text={action} />
              ))}
            </div>
          ) : null}
        </div>
      ) : (
        <EmptyState
          className="workbench-empty"
          icon={<Clock3 size={16} strokeWidth={1.9} />}
        >
          Select a safety queue row to inspect.
        </EmptyState>
      )}
    </Panel>
  );
}

function PriorHistoryList({detail}: {detail: AdminSafetyTriageDetails}) {
  if (detail.priorHistory.length === 0) {
    return "No related safety history found";
  }
  return (
    <span className="tag-row">
      {detail.priorHistory.map((signal) => (
        <AdminTag key={signal.id} tone="muted">
          {signal.label}: {signal.count}
        </AdminTag>
      ))}
    </span>
  );
}

function OutcomeGuidanceList({detail}: {detail: AdminSafetyTriageDetails}) {
  if (detail.outcomeGuidance.length === 0) return "No guidance available";
  return (
    <div className="roadmap-list">
      {detail.outcomeGuidance.map((item) => (
        <div className="roadmap-list-item" key={item.id}>
          <ShieldCheck size={15} strokeWidth={1.9} />
          <span>
            <strong>{item.label}</strong> · {formatGuidanceStatus(item.actionStatus)}
            <br />
            {item.detail}
          </span>
        </div>
      ))}
    </div>
  );
}

function ChecklistRow({text}: {text: string}) {
  return (
    <div className="roadmap-list-item">
      <ShieldCheck size={15} strokeWidth={1.9} />
      <span>{text}</span>
    </div>
  );
}

function formatSla(detail: AdminSafetyTriageDetails): string {
  const dueAt = detail.sla.dueAt ?
    ` by ${formatDateTime(detail.sla.dueAt)}` :
    "";
  return `${detail.sla.state}${dueAt}`;
}

function formatEvidence(
  item: AdminSafetyTriageDetails["evidence"][number]
): string {
  const source = item.sourcePath ? ` (${item.sourcePath})` : "";
  const sensitivity = item.sensitive ? " sensitive preview" : "";
  return `${item.value}${source}${sensitivity}`;
}

function formatGuidanceStatus(
  status: AdminSafetyTriageDetails["outcomeGuidance"][number]["actionStatus"]
): string {
  if (status === "needs_contract") return "needs contract";
  return status;
}

function Metric({
  label,
  tone = "normal",
  value,
}: {
  label: string;
  tone?: "normal" | "attention";
  value: number;
}) {
  return (
    <article className={`metric-card ${tone === "attention" ? "attention" : ""}`}>
      <span>{label}</span>
      <div className="metric-value">{value}</div>
    </article>
  );
}

function riskTone(priority: SafetyTriageRow["priority"]):
  "low" | "medium" | "high" | "watch" {
  if (priority === "high") return "high";
  if (priority === "medium") return "medium";
  return "watch";
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
