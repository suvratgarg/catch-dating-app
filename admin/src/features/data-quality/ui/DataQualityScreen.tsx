import {
  CheckCircle2,
  Database,
  RefreshCw,
  Search,
  ShieldCheck,
} from "lucide-react";
import {
  AdminButton,
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
  type DataQualityRow,
  type DataQualityState,
  type DataQualityStateFilter,
  useDataQualityController,
} from "../controllers/useDataQualityController";

const stateOptions: Array<{label: string; value: DataQualityStateFilter}> = [
  {label: "All states", value: "all"},
  {label: "Blocked", value: "blocked"},
  {label: "Missing", value: "missing"},
  {label: "Warning", value: "warning"},
  {label: "Partial", value: "partial"},
  {label: "OK", value: "ok"},
];

export function DataQualityScreen({
  onError,
}: {
  onError: (message: string | null) => void;
}) {
  const controller = useDataQualityController({onError});
  return (
    <div className="workbench-stack">
      <section className="metric-grid" aria-label="Data quality state">
        <Metric label="Signals" value={controller.metrics.total} />
        <Metric
          label="Blocking"
          tone={controller.metrics.blocking > 0 ? "attention" : "normal"}
          value={controller.metrics.blocking}
        />
        <Metric label="Watch" value={controller.metrics.watch} />
        <Metric label="Sources" value={controller.metrics.sources} />
      </section>

      <Panel
        className="span-2"
        icon={<Database size={18} strokeWidth={1.9} />}
        title="Quality signals"
        action={controller.isLoading ? "Loading" : `${controller.filteredRows.length} shown`}
      >
        <div className="workbench-toolbar">
          <SearchField
            ariaLabel="Search data quality signals"
            icon={<Search size={16} strokeWidth={1.8} />}
            onChange={controller.setQuery}
            placeholder="Search source, owner, runbook, issue"
            value={controller.query}
          />
          <SelectField
            label="State"
            onChange={(value) =>
              controller.setStateFilter(value as DataQualityStateFilter)
            }
            options={stateOptions}
            value={controller.stateFilter}
          />
          <AdminButton
            disabled={controller.isLoading}
            icon={<RefreshCw size={15} strokeWidth={1.9} />}
            onClick={() => void controller.refresh()}
          >
            Refresh
          </AdminButton>
        </div>
        <QualityTable
          onSelect={controller.select}
          rows={controller.filteredRows}
          selectedId={controller.selected?.id ?? null}
        />
      </Panel>

      <section className="publishing-editor-grid">
        <QualityDetailPanel selected={controller.selected} />
        <div className="workbench-stack">
          <Panel
            icon={<ShieldCheck size={18} strokeWidth={1.9} />}
            title="Operations boundary"
            action="read-only"
          >
            <div className="quality-list">
              <StateRow label="Sources" value="adminGetOverview, adminGetHostAnalytics, adminGetMarketingOpsDashboard, adminGetEventIntakeDashboard, adminGetEventSupplyReadiness" />
              <StateRow label="Mutations" value="None from this tab" />
              <StateRow label="Metadata" value="Owner/runbook/action fields come from source payloads" />
              <StateRow label="Not here" value="finance reconciliation, safety actions, crawler edits" />
            </div>
          </Panel>
          <Panel
            icon={<CheckCircle2 size={18} strokeWidth={1.9} />}
            title="Current read"
            action={formatDateTime(controller.generatedAt)}
          >
            <div className="quality-list">
              <StateRow label="OK" value={controller.metrics.ok} />
              <StateRow label="Needs watch" value={controller.metrics.watch} />
              <StateRow label="Blocking/missing" value={controller.metrics.blocking} />
              <StateRow label="Visible rows" value={controller.filteredRows.length} />
            </div>
          </Panel>
        </div>
      </section>
    </div>
  );
}

function QualityTable({
  onSelect,
  rows,
  selectedId,
}: {
  onSelect: (row: DataQualityRow) => void;
  rows: DataQualityRow[];
  selectedId: string | null;
}) {
  if (rows.length === 0) {
    return (
      <EmptyState
        className="workbench-empty"
        icon={<CheckCircle2 size={16} strokeWidth={1.9} />}
      >
        No data-quality signals match this filter.
      </EmptyState>
    );
  }
  return (
    <DataTable className="workbench-table">
      <thead>
        <tr>
          <th>Signal</th>
          <th>State</th>
          <th>Owner</th>
          <th>Runbook</th>
          <th>Next action</th>
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
                <strong>{row.label}</strong>
                <span>{row.source} · {row.detail}</span>
              </div>
            </td>
            <td>
              <RiskBadge tone={riskTone(row.state)}>
                {stateLabel(row.state)}
              </RiskBadge>
            </td>
            <td>{row.owner}</td>
            <td>{row.runbook}</td>
            <td>{row.nextAction}</td>
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

function QualityDetailPanel({
  selected,
}: {
  selected: DataQualityRow | null;
}) {
  return (
    <Panel
      className="publishing-editor-panel"
      icon={<Database size={18} strokeWidth={1.9} />}
      title="Signal detail"
      action={selected ? stateLabel(selected.state) : "No signal"}
    >
      {selected ? (
        <div className="quality-list">
          <StateRow label="Source" value={selected.source} />
          <StateRow label="Signal" value={selected.label} />
          <StateRow
            label="State"
            value={
              <RiskBadge tone={riskTone(selected.state)}>
                {stateLabel(selected.state)}
              </RiskBadge>
            }
          />
          <StateRow label="Owner" value={selected.owner} />
          <StateRow label="Runbook" value={selected.runbook} />
          <StateRow label="Updated" value={formatDateTime(selected.updatedAt)} />
          <StateRow label="Detail" value={selected.detail} />
          <StateRow label="Next action" value={selected.nextAction} />
        </div>
      ) : (
        <EmptyState
          className="workbench-empty"
          icon={<CheckCircle2 size={16} strokeWidth={1.9} />}
        >
          Select a data-quality signal to inspect.
        </EmptyState>
      )}
    </Panel>
  );
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

function riskTone(state: DataQualityState): "low" | "medium" | "high" | "watch" {
  if (state === "blocked" || state === "missing") return "high";
  if (state === "warning") return "medium";
  if (state === "partial") return "watch";
  return "low";
}

function stateLabel(state: DataQualityState): string {
  if (state === "ok") return "OK";
  return state;
}

function formatDateTime(value: string | null): string {
  if (!value) return "not loaded";
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return value;
  return new Intl.DateTimeFormat("en-IN", {
    dateStyle: "medium",
    timeStyle: "short",
  }).format(date);
}
