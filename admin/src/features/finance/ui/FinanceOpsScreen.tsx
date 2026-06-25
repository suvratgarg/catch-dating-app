import {
  CircleDollarSign,
  Clock3,
  CreditCard,
  RefreshCw,
  Search,
  ShieldCheck,
} from "lucide-react";
import {
  AdminButton,
  AdminTag,
  AlertRow,
  DataTable,
  EmptyState,
  Panel,
  RiskBadge,
  SearchField,
  SelectField,
  StateRow,
  TableActionButton,
} from "../../../shared/ui/AdminPrimitives";
import {
  type FinanceIssueKind,
  type FinanceIssueReview,
  type FinanceIssueRow,
  useFinanceOpsController,
} from "../controllers/useFinanceOpsController";

const kindOptions: Array<{label: string; value: FinanceIssueKind}> = [
  {label: "All issues", value: "all"},
  {label: "Payments", value: "payment"},
  {label: "Events", value: "event"},
  {label: "Payouts", value: "payout"},
];

export function FinanceOpsScreen({
  onError,
}: {
  onError: (message: string | null) => void;
}) {
  const controller = useFinanceOpsController({onError});
  return (
    <div className="workbench-stack">
      <section className="metric-grid" aria-label="Finance state">
        <Metric label="Completed" value={controller.metrics.completedPayments} />
        <Metric
          label="Failed"
          tone={controller.metrics.failedPayments > 0 ? "attention" : "normal"}
          value={controller.metrics.failedPayments}
        />
        <Metric label="Signup failed" value={controller.metrics.signupFailedPayments} />
        <Metric
          label="Revenue"
          prefix="INR "
          value={controller.metrics.revenueMinor / 100}
        />
      </section>

      <Panel
        className="span-2"
        icon={<CircleDollarSign size={18} strokeWidth={1.9} />}
        title="Finance issues"
        action={controller.isLoading ? "Loading" : `${controller.filteredRows.length} shown`}
      >
        <div className="workbench-toolbar">
          <SearchField
            ariaLabel="Search finance issues"
            icon={<Search size={16} strokeWidth={1.8} />}
            onChange={controller.setQuery}
            placeholder="Search payment, event, provider state"
            value={controller.query}
          />
          <SelectField
            label="Issue type"
            onChange={(value) =>
              controller.setKindFilter(value as FinanceIssueKind)
            }
            options={kindOptions}
            value={controller.kindFilter}
          />
          <AdminButton
            disabled={controller.isLoading}
            icon={<RefreshCw size={15} strokeWidth={1.9} />}
            onClick={() => void controller.refresh()}
          >
            Refresh
          </AdminButton>
        </div>
        <FinanceTable
          rows={controller.filteredRows}
          selectedId={controller.selected?.id ?? null}
          onSelect={controller.select}
        />
      </Panel>

      <section className="publishing-editor-grid">
        <FinanceDetailPanel
          loadedAt={controller.loadedAt}
          selected={controller.selected}
          review={controller.selectedReview}
        />
        <div className="workbench-stack">
          <Panel
            icon={<ShieldCheck size={18} strokeWidth={1.9} />}
            title="Authority boundary"
            action="read-only"
          >
            <div className="quality-list">
              <StateRow label="Sources" value="adminGetOverview, adminGetHostAnalytics" />
              <StateRow label="Mutations" value="None from this tab" />
              <StateRow label="Needed next" value="provider ledger/read model and audited finance callables" />
              <StateRow label="Not here" value="refund execution, payout release, settlement edits" />
            </div>
          </Panel>
          <FinanceReconciliationPanel review={controller.selectedReview} />
        </div>
      </section>
    </div>
  );
}

function FinanceTable({
  onSelect,
  rows,
  selectedId,
}: {
  onSelect: (row: FinanceIssueRow) => void;
  rows: FinanceIssueRow[];
  selectedId: string | null;
}) {
  if (rows.length === 0) {
    return (
      <EmptyState
        className="workbench-empty"
        icon={<Clock3 size={16} strokeWidth={1.9} />}
      >
        No finance issues match this filter.
      </EmptyState>
    );
  }
  return (
    <DataTable className="workbench-table">
      <thead>
        <tr>
          <th>Issue</th>
          <th>Severity</th>
          <th>Status</th>
          <th>Amount</th>
          <th>Target</th>
          <th>Select</th>
        </tr>
      </thead>
      <tbody>
        {rows.map((row) => (
          <tr
            className={selectedId === row.id ? "selected-row" : ""}
            key={row.id}
          >
            <td>
              <div className="row-title">
                <strong>{row.title}</strong>
                <span>{row.kind} · {row.detail}</span>
              </div>
            </td>
            <td>
              <RiskBadge tone={riskTone(row.severity)}>
                {row.severity}
              </RiskBadge>
            </td>
            <td>{row.status}</td>
            <td>{amountValue(row)}</td>
            <td>{row.targetPath}</td>
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

function FinanceDetailPanel({
  loadedAt,
  review,
  selected,
}: {
  loadedAt: string | null;
  review: FinanceIssueReview | null;
  selected: FinanceIssueRow | null;
}) {
  return (
    <Panel
      className="publishing-editor-panel"
      icon={<CircleDollarSign size={18} strokeWidth={1.9} />}
      title="Issue detail"
      action={selected?.status ?? "No issue"}
    >
      {selected ? (
        <div className="quality-list">
          <StateRow label="Type" value={selected.kind} />
          <StateRow label="Target" value={selected.targetPath} />
          <StateRow label="Status" value={selected.status} />
          <StateRow label="Amount" value={amountValue(selected)} />
          <StateRow label="Next action" value={selected.nextAction} />
          <StateRow label="Created/start" value={formatDateTime(selected.createdAt)} />
          <StateRow label="Signals loaded" value={formatDateTime(loadedAt)} />
          {review ? (
            <>
              <AlertRow
                icon={<ShieldCheck size={16} strokeWidth={1.9} />}
                title={review.statusLabel}
                tone={reviewTone(review.actionStatus)}
              >
                {review.statusDetail}
              </AlertRow>
              <div className="tag-row">
                <AdminTag tone="muted">provider {review.provider}</AdminTag>
                <AdminTag tone="muted">
                  {review.actionStatus.replaceAll("_", " ")}
                </AdminTag>
              </div>
              <StateRow label="Authority" value={review.sourceOfTruth} />
              <StateRow
                label="Reconciliation"
                value={review.reconciliationStatus}
              />
              <StateRow label="Mutation boundary" value={review.mutationBoundary} />
            </>
          ) : null}
        </div>
      ) : (
        <EmptyState
          className="workbench-empty"
          icon={<Clock3 size={16} strokeWidth={1.9} />}
        >
          Select a finance issue to inspect.
        </EmptyState>
      )}
    </Panel>
  );
}

function FinanceReconciliationPanel({
  review,
}: {
  review: FinanceIssueReview | null;
}) {
  return (
    <Panel
      icon={<CreditCard size={18} strokeWidth={1.9} />}
      title="Reconciliation model"
      action={review ? review.actionStatus.replaceAll("_", " ") : "select issue"}
    >
      {review ? (
        <div className="workbench-stack compact-stack">
          <div className="quality-list">
            <StateRow label="Source model" value={review.sourceModel} />
            <StateRow label="Provider authority" value={review.sourceOfTruth} />
          </div>
          <div className="intake-section">
            <div className="intake-section-title">Required Evidence</div>
            <div className="roadmap-list">
              {review.requiredEvidence.map((item) => (
                <ReviewRow key={item} text={item} />
              ))}
            </div>
          </div>
          <div className="intake-section">
            <div className="intake-section-title">Blocked Here</div>
            <div className="intake-tags">
              {review.blockedActions.map((action) => (
                <AdminTag key={action}>{action}</AdminTag>
              ))}
            </div>
          </div>
        </div>
      ) : (
        <EmptyState
          className="workbench-empty"
          icon={<Clock3 size={16} strokeWidth={1.9} />}
        >
          Select a finance issue to inspect reconciliation evidence.
        </EmptyState>
      )}
    </Panel>
  );
}

function ReviewRow({text}: {text: string}) {
  return (
    <div className="roadmap-list-item">
      <ShieldCheck size={15} strokeWidth={1.9} />
      <span>{text}</span>
    </div>
  );
}

function Metric({
  label,
  prefix = "",
  tone = "normal",
  value,
}: {
  label: string;
  prefix?: string;
  tone?: "normal" | "attention";
  value: number;
}) {
  return (
    <article className={`metric-card ${tone === "attention" ? "attention" : ""}`}>
      <span>{label}</span>
      <div className="metric-value">{prefix}{numberValue(value)}</div>
    </article>
  );
}

function amountValue(row: FinanceIssueRow): string {
  if (row.amountMinor === null) return "n/a";
  return new Intl.NumberFormat("en-IN", {
    currency: row.currency,
    maximumFractionDigits: 0,
    style: "currency",
  }).format(row.amountMinor / 100);
}

function riskTone(severity: FinanceIssueRow["severity"]):
  "low" | "medium" | "high" | "watch" {
  if (severity === "high") return "high";
  if (severity === "medium") return "medium";
  return "watch";
}

function reviewTone(
  status: FinanceIssueReview["actionStatus"]
): "neutral" | "warning" | "success" | "blocked" {
  if (status === "needs_finance_contract") return "blocked";
  if (status === "aggregate_only") return "warning";
  return "neutral";
}

function numberValue(value: number): string {
  return new Intl.NumberFormat("en-IN", {
    maximumFractionDigits: 0,
  }).format(value);
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
