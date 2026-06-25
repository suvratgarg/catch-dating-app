import {
  Activity,
  BarChart3,
  Clock3,
  LineChart,
  RefreshCw,
  Search,
  ShieldCheck,
} from "lucide-react";
import type {HostAnalyticsTrendPoint} from "../../../shared/types/adminTypes";
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
  type GrowthRangePreset,
  type GrowthSignalRow,
  type GrowthStage,
  useGrowthKpiController,
} from "../controllers/useGrowthKpiController";

const rangeOptions: Array<{label: string; value: GrowthRangePreset}> = [
  {label: "7d", value: "7d"},
  {label: "30d", value: "30d"},
  {label: "90d", value: "90d"},
  {label: "Month", value: "month"},
];

const stageOptions: Array<{label: string; value: GrowthStage}> = [
  {label: "All stages", value: "all"},
  {label: "Acquisition", value: "acquisition"},
  {label: "Supply", value: "supply"},
  {label: "Conversion", value: "conversion"},
  {label: "Marketplace", value: "marketplace"},
];

export function GrowthKpiScreen({
  onError,
}: {
  onError: (message: string | null) => void;
}) {
  const controller = useGrowthKpiController({onError});
  return (
    <div className="workbench-stack">
      <section className="metric-grid" aria-label="Growth KPI state">
        <Metric label="Signals" value={controller.metrics.signals} />
        <Metric
          label="Watch"
          tone={controller.metrics.watch > 0 ? "attention" : "normal"}
          value={controller.metrics.watch}
        />
        <Metric label="Signups week" value={controller.metrics.signupsThisWeek} />
        <Metric label="Bookings" value={controller.metrics.bookings} />
      </section>

      <Panel
        className="span-2"
        icon={<LineChart size={18} strokeWidth={1.9} />}
        title="Launch funnel"
        action={controller.isLoading ? "Loading" : `${controller.filteredRows.length} shown`}
      >
        <div className="workbench-toolbar">
          <SearchField
            ariaLabel="Search growth signals"
            icon={<Search size={16} strokeWidth={1.8} />}
            onChange={controller.setQuery}
            placeholder="Search stage, metric, source"
            value={controller.query}
          />
          <SelectField
            label="Stage"
            onChange={(value) => controller.setStageFilter(value as GrowthStage)}
            options={stageOptions}
            value={controller.stageFilter}
          />
          <SelectField
            label="Range"
            onChange={(value) =>
              controller.setRangePreset(value as GrowthRangePreset)
            }
            options={rangeOptions}
            value={controller.rangePreset}
          />
          <AdminButton
            disabled={controller.isLoading}
            icon={<RefreshCw size={15} strokeWidth={1.9} />}
            onClick={() => void controller.refresh()}
          >
            Refresh
          </AdminButton>
        </div>
        <GrowthSignalTable
          onSelect={controller.select}
          rows={controller.filteredRows}
          selectedId={controller.selected?.id ?? null}
        />
      </Panel>

      <section className="publishing-editor-grid">
        <Panel
          className="publishing-editor-panel"
          icon={<Activity size={18} strokeWidth={1.9} />}
          title="Signal detail"
          action={controller.selected?.status ?? "No signal"}
        >
          <GrowthSignalDetail selected={controller.selected} />
        </Panel>
        <div className="workbench-stack">
          <Panel
            icon={<BarChart3 size={18} strokeWidth={1.9} />}
            title="Booking trend"
            action={controller.rangePreset}
          >
            <TrendTable points={controller.trend} />
          </Panel>
          <Panel
            icon={<ShieldCheck size={18} strokeWidth={1.9} />}
            title="Operations boundary"
            action="read-only"
          >
            <div className="quality-list">
              <StateRow label="Sources" value="adminGetOverview, adminGetHostAnalytics" />
              <StateRow label="Mutations" value="None from this tab" />
              <StateRow label="Needed next" value="channel, cohort, referral, and campaign attribution contracts" />
              <StateRow label="Signals loaded" value={formatDateTime(controller.loadedAt)} />
            </div>
          </Panel>
          <Panel
            icon={<Activity size={18} strokeWidth={1.9} />}
            title="Action model"
            action="manual"
          >
            <div className="roadmap-list">
              <ActionRow text="Use Marketing for content operations." />
              <ActionRow text="Use Organizers and Events for canonical supply cleanup." />
              <ActionRow text="Do not infer paid acquisition ROI until attribution exists." />
            </div>
          </Panel>
        </div>
      </section>
    </div>
  );
}

function GrowthSignalTable({
  onSelect,
  rows,
  selectedId,
}: {
  onSelect: (row: GrowthSignalRow) => void;
  rows: GrowthSignalRow[];
  selectedId: string | null;
}) {
  if (rows.length === 0) {
    return (
      <EmptyState
        className="workbench-empty"
        icon={<Clock3 size={16} strokeWidth={1.9} />}
      >
        No growth signals match this filter.
      </EmptyState>
    );
  }
  return (
    <DataTable className="workbench-table">
      <thead>
        <tr>
          <th>Metric</th>
          <th>Stage</th>
          <th>Value</th>
          <th>Status</th>
          <th>Source</th>
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
                <span>{row.detail}</span>
              </div>
            </td>
            <td>{row.stage}</td>
            <td>{formatValue(row.value, row.unit)}</td>
            <td>
              <RiskBadge tone={row.status === "ready" ? "low" : "watch"}>
                {row.status}
              </RiskBadge>
            </td>
            <td>{row.source}</td>
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

function GrowthSignalDetail({
  selected,
}: {
  selected: GrowthSignalRow | null;
}) {
  if (!selected) {
    return (
      <EmptyState
        className="workbench-empty"
        icon={<Clock3 size={16} strokeWidth={1.9} />}
      >
        Select a growth signal to inspect.
      </EmptyState>
    );
  }
  return (
    <div className="quality-list">
      <StateRow label="Metric" value={selected.label} />
      <StateRow label="Stage" value={selected.stage} />
      <StateRow label="Value" value={formatValue(selected.value, selected.unit)} />
      <StateRow
        label="Status"
        value={
          <RiskBadge tone={selected.status === "ready" ? "low" : "watch"}>
            {selected.status}
          </RiskBadge>
        }
      />
      <StateRow label="Source" value={selected.source} />
      <StateRow label="Detail" value={selected.detail} />
    </div>
  );
}

function TrendTable({points}: {points: HostAnalyticsTrendPoint[]}) {
  if (points.length === 0) {
    return (
      <EmptyState
        className="workbench-empty"
        icon={<Clock3 size={16} strokeWidth={1.9} />}
      >
        No trend buckets are available for this range.
      </EmptyState>
    );
  }
  return (
    <DataTable className="workbench-table">
      <thead>
        <tr>
          <th>Period</th>
          <th>Bookings</th>
          <th>Demand</th>
          <th>Checked in</th>
          <th>Drop-off</th>
          <th>Reviews</th>
        </tr>
      </thead>
      <tbody>
        {points.map((point) => (
          <tr key={point.periodStart}>
            <td>
              <div className="row-title compact">
                <strong>{formatDate(point.periodStart)}</strong>
                <span>{formatDate(point.periodEnd)}</span>
              </div>
            </td>
            <td>{numberValue(point.metrics.bookings)}</td>
            <td>{numberValue(point.metrics.demand)}</td>
            <td>{numberValue(point.metrics.checkedIn)}</td>
            <td>{numberValue(point.metrics.checkoutDropoff)}</td>
            <td>{numberValue(point.metrics.reviews)}</td>
          </tr>
        ))}
      </tbody>
    </DataTable>
  );
}

function ActionRow({text}: {text: string}) {
  return (
    <div className="roadmap-list-item">
      <ShieldCheck size={15} strokeWidth={1.9} />
      <span>{text}</span>
    </div>
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

function formatValue(
  value: number,
  unit: GrowthSignalRow["unit"]
): string {
  if (unit === "percent") return `${value}%`;
  if (unit === "money_minor") {
    return new Intl.NumberFormat("en-IN", {
      currency: "INR",
      maximumFractionDigits: 0,
      style: "currency",
    }).format(value / 100);
  }
  if (unit === "rating") return value.toFixed(1);
  return numberValue(value);
}

function numberValue(value: number | undefined): string {
  return new Intl.NumberFormat("en-IN").format(value ?? 0);
}

function formatDate(value: string): string {
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return value;
  return new Intl.DateTimeFormat("en-IN", {
    day: "2-digit",
    month: "short",
  }).format(date);
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
