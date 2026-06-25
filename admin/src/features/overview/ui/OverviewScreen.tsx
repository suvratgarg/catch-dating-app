import {useMemo, useState} from "react";
import {
  BarChart3,
  CheckCircle2,
  Clock3,
  Database,
  FileWarning,
  LineChart,
  ShieldAlert,
  Sparkles,
  Users,
} from "lucide-react";
import {
  AdminButton,
  AdminTag,
  DataTable,
  EmptyState,
  Panel,
  RiskBadge,
  SelectField,
  StateRow,
  TableActionButton,
  TextField,
} from "../../../shared/ui/AdminPrimitives";
import type {
  AdminOverviewMetric,
  AdminOverviewResponse,
  AdminQueueItem,
  HostAnalyticsEventRow,
  HostAnalyticsQueryPayload,
  HostAnalyticsResponse,
} from "../../../shared/types/adminTypes";

export type OverviewAnalyticsRangePreset = NonNullable<
  HostAnalyticsQueryPayload["rangePreset"]
>;
export type OverviewAnalyticsGranularity = NonNullable<
  HostAnalyticsQueryPayload["granularity"]
>;

const priorityMetricIds = [
  "openReports",
  "pendingApplications",
  "pendingClubClaims",
  "activeHosts",
  "activeEvents",
  "signupsToday",
  "signupsThisWeek",
  "completedProfiles",
  "failedPayments",
  "payoutRestrictedHosts",
];

interface OverviewQueueSelection {
  group: string;
  intent: "danger" | "warning" | "neutral";
  item: AdminQueueItem;
  key: string;
}

export function OverviewScreen({
  analyticsClubId,
  analyticsEndDate,
  analyticsEventId,
  analyticsGranularity,
  analyticsRangePreset,
  analyticsStartDate,
  hostAnalytics,
  overview,
  onAnalyticsClubIdChange,
  onAnalyticsEndDateChange,
  onAnalyticsEventIdChange,
  onAnalyticsGranularityChange,
  onAnalyticsRangePresetChange,
  onAnalyticsStartDateChange,
  onClearAnalyticsScope,
}: {
  analyticsClubId: string;
  analyticsEndDate: string;
  analyticsEventId: string;
  analyticsGranularity: OverviewAnalyticsGranularity;
  analyticsRangePreset: OverviewAnalyticsRangePreset;
  analyticsStartDate: string;
  hostAnalytics: HostAnalyticsResponse;
  overview: AdminOverviewResponse;
  onAnalyticsClubIdChange: (value: string) => void;
  onAnalyticsEndDateChange: (value: string) => void;
  onAnalyticsEventIdChange: (value: string) => void;
  onAnalyticsGranularityChange: (value: OverviewAnalyticsGranularity) => void;
  onAnalyticsRangePresetChange: (value: OverviewAnalyticsRangePreset) => void;
  onAnalyticsStartDateChange: (value: string) => void;
  onClearAnalyticsScope: () => void;
}) {
  const primaryMetrics = priorityMetricIds
    .map((id) => overview.metrics.find((metric) => metric.id === id))
    .filter((metric): metric is AdminOverviewMetric => Boolean(metric));
  const [selectedQueueKey, setSelectedQueueKey] = useState<string | null>(null);
  const queueGroups = useMemo(
    () => buildQueueGroups(overview),
    [overview]
  );
  const queueSelections = useMemo(
    () => queueGroups.flatMap((group) => group.items.map((item) => ({
      group: group.title,
      intent: group.intent,
      item,
      key: queueSelectionKey(group.title, item),
    }))),
    [queueGroups]
  );
  const selectedQueue = queueSelections.find((selection) =>
    selection.key === selectedQueueKey
  ) ?? queueSelections[0] ?? null;
  return (
    <>
      <AnalyticsControls
        clubId={analyticsClubId}
        endDate={analyticsEndDate}
        eventId={analyticsEventId}
        granularity={analyticsGranularity}
        rangePreset={analyticsRangePreset}
        startDate={analyticsStartDate}
        onClearScope={onClearAnalyticsScope}
        onClubIdChange={onAnalyticsClubIdChange}
        onEndDateChange={onAnalyticsEndDateChange}
        onEventIdChange={onAnalyticsEventIdChange}
        onGranularityChange={onAnalyticsGranularityChange}
        onRangePresetChange={onAnalyticsRangePresetChange}
        onStartDateChange={onAnalyticsStartDateChange}
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
              items={queueGroups[0]?.items ?? []}
              onInspect={(item) =>
                setSelectedQueueKey(queueSelectionKey("Safety reports", item))}
              selectedKey={selectedQueue?.key ?? null}
              title="Safety reports"
            />
            <QueueList
              actionHint="Use Access tab"
              intent="warning"
              items={queueGroups[1]?.items ?? []}
              onInspect={(item) =>
                setSelectedQueueKey(queueSelectionKey("Access applications", item))}
              selectedKey={selectedQueue?.key ?? null}
              title="Access applications"
            />
            <QueueList
              actionHint="Use Organizers tab"
              intent="neutral"
              items={queueGroups[2]?.items ?? []}
              onInspect={(item) =>
                setSelectedQueueKey(queueSelectionKey("Organizer claims", item))}
              selectedKey={selectedQueue?.key ?? null}
              title="Organizer claims"
            />
            <QueueList
              actionHint="Use Organizers tab"
              intent="neutral"
              items={queueGroups[3]?.items ?? []}
              onInspect={(item) =>
                setSelectedQueueKey(queueSelectionKey("Index reviews", item))}
              selectedKey={selectedQueue?.key ?? null}
              title="Index reviews"
            />
            <QueueList
              intent="neutral"
              items={queueGroups[4]?.items ?? []}
              onInspect={(item) =>
                setSelectedQueueKey(queueSelectionKey("Moderation and payments", item))}
              selectedKey={selectedQueue?.key ?? null}
              title="Moderation and payments"
            />
          </div>
          <QueueDetailPanel selection={selectedQueue} />
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
          <BarMiniChart points={analyticsTrendPoints(hostAnalytics, "bookings")} />
        </Panel>

        <Panel
          className="span-2"
          icon={<BarChart3 size={18} strokeWidth={1.9} />}
          title="Event performance"
          action={`${hostAnalytics.topEvents.length} ranked`}
        >
          <EventPerformanceTable
            events={hostAnalytics.topEvents}
            onFocusEvent={onAnalyticsEventIdChange}
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
  );
}

function buildQueueGroups(overview: AdminOverviewResponse) {
  return [
    {
      intent: "danger" as const,
      items: [
        ...overview.queues.safetyReports,
        ...overview.queues.eventSafetyReports,
      ],
      title: "Safety reports",
    },
    {
      intent: "warning" as const,
      items: overview.queues.accessApplications,
      title: "Access applications",
    },
    {
      intent: "neutral" as const,
      items: overview.queues.clubClaimRequests,
      title: "Organizer claims",
    },
    {
      intent: "neutral" as const,
      items: overview.queues.clubIndexReviews,
      title: "Index reviews",
    },
    {
      intent: "neutral" as const,
      items: [
        ...overview.queues.moderationFlags,
        ...overview.queues.paymentIssues,
      ],
      title: "Moderation and payments",
    },
  ];
}

function queueSelectionKey(group: string, item: AdminQueueItem): string {
  return `${group}:${item.id}:${item.targetPath}`;
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
  granularity: OverviewAnalyticsGranularity;
  rangePreset: OverviewAnalyticsRangePreset;
  startDate: string;
  onClearScope: () => void;
  onClubIdChange: (value: string) => void;
  onEndDateChange: (value: string) => void;
  onEventIdChange: (value: string) => void;
  onGranularityChange: (value: OverviewAnalyticsGranularity) => void;
  onRangePresetChange: (value: OverviewAnalyticsRangePreset) => void;
  onStartDateChange: (value: string) => void;
}) {
  const hasScope = clubId.trim() || eventId.trim();
  return (
    <section className="analytics-controls" aria-label="Organizer analytics filters">
      <SelectField
        label="Range"
        onChange={(value) =>
          onRangePresetChange(value as OverviewAnalyticsRangePreset)}
        options={[
          {label: "Last 7 days", value: "7d"},
          {label: "Last 30 days", value: "30d"},
          {label: "Last 90 days", value: "90d"},
          {label: "This month", value: "month"},
          {label: "Custom", value: "custom"},
        ]}
        value={rangePreset}
      />
      <SelectField
        label="Group by"
        onChange={(value) =>
          onGranularityChange(value as OverviewAnalyticsGranularity)}
        options={[
          {label: "Day", value: "day"},
          {label: "Week", value: "week"},
          {label: "Month", value: "month"},
        ]}
        value={granularity}
      />
      {rangePreset === "custom" && (
        <>
          <TextField
            label="Start date"
            onChange={onStartDateChange}
            type="date"
            value={startDate}
          />
          <TextField
            label="End date"
            onChange={onEndDateChange}
            type="date"
            value={endDate}
          />
        </>
      )}
      <TextField
        label="Organizer id"
        onChange={onClubIdChange}
        placeholder="all organizers"
        value={clubId}
      />
      <TextField
        label="Event id"
        onChange={onEventIdChange}
        placeholder="all events"
        value={eventId}
      />
      <AdminButton
        className="analytics-clear"
        disabled={!hasScope}
        onClick={onClearScope}
      >
        Clear scope
      </AdminButton>
    </section>
  );
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

function QueueList({
  actionHint,
  intent,
  items,
  onInspect,
  selectedKey,
  title,
}: {
  actionHint?: string;
  intent: "danger" | "warning" | "neutral";
  items: AdminQueueItem[];
  onInspect: (item: AdminQueueItem) => void;
  selectedKey: string | null;
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
          <EmptyState icon={<CheckCircle2 size={16} strokeWidth={1.9} />}>
            Clear
          </EmptyState>
        ) : (
          items.map((item) => (
            <QueueRow
              actionHint={actionHint}
              intent={intent}
              isSelected={selectedKey === queueSelectionKey(title, item)}
              item={item}
              key={item.id}
              onInspect={onInspect}
            />
          ))
        )}
      </div>
    </div>
  );
}

function QueueRow({
  actionHint,
  intent,
  isSelected,
  item,
  onInspect,
}: {
  actionHint?: string;
  intent: "danger" | "warning" | "neutral";
  isSelected: boolean;
  item: AdminQueueItem;
  onInspect: (item: AdminQueueItem) => void;
}) {
  return (
    <article className={`queue-row ${intent} ${isSelected ? "selected" : ""}`.trim()}>
      <div>
        <h3>{item.title}</h3>
        <p>{item.detail}</p>
      </div>
      <div className="queue-row-actions">
        <span>{relativeTime(item.createdAt)}</span>
        <AdminButton
          className="queue-decision-button"
          onClick={() => onInspect(item)}
          selected={isSelected}
        >
          Inspect
        </AdminButton>
        {actionHint ? <AdminTag tone="muted">{actionHint}</AdminTag> : null}
      </div>
    </article>
  );
}

function QueueDetailPanel({
  selection,
}: {
  selection: OverviewQueueSelection | null;
}) {
  if (!selection) {
    return (
      <EmptyState
        className="workbench-empty"
        icon={<CheckCircle2 size={16} strokeWidth={1.9} />}
      >
        No open queue rows.
      </EmptyState>
    );
  }
  return (
    <section className="queue-detail-panel" aria-label="Selected queue detail">
      <div className="queue-heading">
        <span>Selected queue row</span>
        <strong>{selection.group}</strong>
      </div>
      <div className="quality-list">
        <StateRow label="Title" value={selection.item.title} />
        <StateRow label="Status" value={selection.item.status} />
        <StateRow label="Target" value={selection.item.targetPath} />
        <StateRow label="Created" value={relativeTime(selection.item.createdAt)} />
        <StateRow label="Detail" value={selection.item.detail} />
        <StateRow
          label="Owner flow"
          value={ownerFlowForQueueGroup(selection.group)}
        />
      </div>
    </section>
  );
}

function ownerFlowForQueueGroup(group: string): string {
  if (group === "Safety reports") return "Safety tab";
  if (group === "Access applications") return "Access tab";
  if (group === "Organizer claims") return "Organizers tab";
  if (group === "Index reviews") return "Organizers tab";
  return "Safety, Finance, or owning support workflow";
}

function LineMiniChart({points}: {points: Array<{label: string; value: number}>}) {
  if (points.length === 0) {
    return (
      <EmptyState className="empty-panel">
        No trend data yet.
      </EmptyState>
    );
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
    return (
      <EmptyState className="empty-panel">
        No trend data yet.
      </EmptyState>
    );
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
    <DataTable>
      <thead>
        <tr>
          <th>Event</th>
          <th>Organizer</th>
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
        {events.map((row) => {
          const risk = eventRisk(row);
          return (
            <tr key={row.eventId}>
              <td>{row.title}</td>
              <td>{row.clubId}</td>
              <td>{Math.round(row.fillRate)}%</td>
              <td>{Math.round(row.checkInRate)}%</td>
              <td>
                {row.averageRating > 0 ? row.averageRating.toFixed(1) : "n/a"}
              </td>
              <td>
                {row.checkoutStartedCount
                  ? `${row.checkoutDropoffCount}/${row.checkoutStartedCount} drop`
                  : "n/a"}
              </td>
              <td>{formatMinorCurrency(row.grossRevenueMinor, row.currency)}</td>
              <td>
                <RiskBadge tone={risk}>{risk}</RiskBadge>
              </td>
              <td>
                <TableActionButton onClick={() => onFocusEvent(row.eventId)}>
                  Focus
                </TableActionButton>
              </td>
            </tr>
          );
        })}
      </tbody>
    </DataTable>
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
