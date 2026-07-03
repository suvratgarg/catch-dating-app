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
  AdminEditorGrid,
  AdminEditorPanel,
  AdminMetricCard,
  AdminMetricGrid,
  AdminRoadmapList,
  AdminRoadmapListItem,
  AdminTableRow,
  AdminTag,
  AdminToolbar,
  AdminWorkbenchStack,
  AlertRow,
  DataTable,
  EmptyState,
  Panel,
  QualityList,
  RiskBadge,
  SearchField,
  SelectField,
  StateRow,
  TableActionButton,
  AdminTagList,
  AdminIntakeSection,
  AdminIntakeSectionTitle,
  AdminRowTitle,
  AdminTagRow,
} from "../../../shared/ui/AdminPrimitives";
import {
  type FinanceOpsController,
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
  return <FinanceOpsWorkspace controller={controller} />;
}

export function FinanceOpsWorkspace({
  controller,
}: {
  controller: FinanceOpsController;
}) {
  return (
    <AdminWorkbenchStack>
      <AdminMetricGrid ariaLabel="Finance state">
        <AdminMetricCard label="Completed" value={numberValue(controller.metrics.completedPayments)} />
        <AdminMetricCard
          label="Failed"
          tone={controller.metrics.failedPayments > 0 ? "attention" : "normal"}
          value={numberValue(controller.metrics.failedPayments)}
        />
        <AdminMetricCard
          label="Signup failed"
          value={numberValue(controller.metrics.signupFailedPayments)}
        />
        <AdminMetricCard
          label="Revenue"
          value={`INR ${numberValue(controller.metrics.revenueMinor / 100)}`}
        />
      </AdminMetricGrid>
      <Panel
        span={2}
        icon={<CircleDollarSign size={18} strokeWidth={1.9} />}
        title="Finance issues"
        action={controller.isLoading ? "Loading" : `${controller.filteredRows.length} shown`}
      >
        <AdminToolbar>
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
        </AdminToolbar>
        <FinanceTable
          rows={controller.filteredRows}
          selectedId={controller.selected?.id ?? null}
          onSelect={controller.select}
        />
      </Panel>
      <AdminEditorGrid>
        <FinanceDetailPanel
          loadedAt={controller.loadedAt}
          selected={controller.selected}
          review={controller.selectedReview}
        />
        <AdminWorkbenchStack>
          <Panel
            icon={<ShieldCheck size={18} strokeWidth={1.9} />}
            title="Authority boundary"
            action="read-only"
          >
            <QualityList>
              <StateRow label="Sources" value="adminGetOverview, adminGetHostAnalytics" />
              <StateRow label="Mutations" value="None from this tab" />
              <StateRow label="Needed next" value="provider ledger/read model and audited finance callables" />
              <StateRow label="Not here" value="refund execution, payout release, settlement edits" />
            </QualityList>
          </Panel>
          <FinanceReconciliationPanel review={controller.selectedReview} />
        </AdminWorkbenchStack>
      </AdminEditorGrid>
    </AdminWorkbenchStack>
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
        variant="workbench"
        icon={<Clock3 size={16} strokeWidth={1.9} />}
      >
        No finance issues match this filter.
      </EmptyState>
    );
  }
  return (
    <DataTable variant="workbench">
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
          <AdminTableRow key={row.id} selected={selectedId === row.id}>
            <td>
              <AdminRowTitle>
                <strong>{row.title}</strong>
                <span>{row.kind} · {row.detail}</span>
              </AdminRowTitle>
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
          </AdminTableRow>
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
    <AdminEditorPanel
      icon={<CircleDollarSign size={18} strokeWidth={1.9} />}
      title="Issue detail"
      action={selected?.status ?? "No issue"}
    >
      {selected ? (
        <QualityList>
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
              <AdminTagRow>
                <AdminTag tone="muted">provider {review.provider}</AdminTag>
                <AdminTag tone="muted">
                  {review.actionStatus.replaceAll("_", " ")}
                </AdminTag>
              </AdminTagRow>
              <StateRow label="Authority" value={review.sourceOfTruth} />
              <StateRow
                label="Reconciliation"
                value={review.reconciliationStatus}
              />
              <StateRow label="Mutation boundary" value={review.mutationBoundary} />
            </>
          ) : null}
        </QualityList>
      ) : (
        <EmptyState
          variant="workbench"
          icon={<Clock3 size={16} strokeWidth={1.9} />}
        >
          Select a finance issue to inspect.
        </EmptyState>
      )}
    </AdminEditorPanel>
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
        <AdminWorkbenchStack compact>
          <QualityList>
            <StateRow label="Source model" value={review.sourceModel} />
            <StateRow label="Provider authority" value={review.sourceOfTruth} />
          </QualityList>
          <AdminIntakeSection>
            <AdminIntakeSectionTitle>Required Evidence</AdminIntakeSectionTitle>
            <AdminRoadmapList>
              {review.requiredEvidence.map((item) => (
                <ReviewRow key={item} text={item} />
              ))}
            </AdminRoadmapList>
          </AdminIntakeSection>
          <AdminIntakeSection>
            <AdminIntakeSectionTitle>Blocked Here</AdminIntakeSectionTitle>
            <AdminTagList>
              {review.blockedActions.map((action) => (
                <AdminTag key={action}>{action}</AdminTag>
              ))}
            </AdminTagList>
          </AdminIntakeSection>
        </AdminWorkbenchStack>
      ) : (
        <EmptyState
          variant="workbench"
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
    <AdminRoadmapListItem>
      <ShieldCheck size={15} strokeWidth={1.9} />
      <span>{text}</span>
    </AdminRoadmapListItem>
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
