import {
  BarChart3,
  Clock3,
  Database,
  FileWarning,
  RefreshCw,
  Search,
  ShieldCheck,
  Sparkles,
  UserRound,
} from "lucide-react";
import type {
  UserAnalyticsConnectionSummary,
  UserAnalyticsDataQuality,
  UserAnalyticsGranularity,
  UserAnalyticsMetricCard,
  UserAnalyticsProfileSummary,
  UserAnalyticsRangePreset,
  UserAnalyticsResponse,
  UserAnalyticsTrendPoint,
} from "../../../shared/types/adminTypes";
import {
  AdminButton,
  AdminTag,
  AlertRow,
  DataTable,
  EmptyState,
  Panel,
  SegmentedControl,
  SelectField,
  StateRow,
  TextField,
} from "../../../shared/ui/AdminPrimitives";
import {
  type UserLookupContract,
  useUserAnalyticsController,
} from
  "../controllers/useUserAnalyticsController";

export function UserAnalyticsScreen({
  handoffRequestId,
  handoffUserId,
  onError,
  onNotice,
}: {
  handoffRequestId?: number | null;
  handoffUserId?: string | null;
  onError: (message: string | null) => void;
  onNotice: (message: string | null) => void;
}) {
  const controller = useUserAnalyticsController({
    handoffRequestId,
    handoffUserId,
    onError,
    onNotice,
  });
  const missingCount = controller.report?.summaryCards.filter((metric) =>
    metric.status === "missing"
  ).length ?? 0;
  const partialCount = controller.report?.dataQuality.filter((row) =>
    row.state !== "ok"
  ).length ?? 0;

  return (
    <div className="workbench-stack">
      <section className="metric-grid" aria-label="User analytics state">
        {controller.report ? (
          controller.report.summaryCards.map((metric) => (
            <MetricCard metric={metric} key={metric.id} />
          ))
        ) : (
          <>
            <Metric label="Selected user" value={controller.userId || "none"} />
            <Metric label="Range" value={controller.rangePreset} />
            <Metric label="Missing metrics" value={String(missingCount)} />
            <Metric label="Data warnings" value={String(partialCount)} />
          </>
        )}
      </section>

      <Panel
        icon={<Search size={18} strokeWidth={1.9} />}
        title="User analytics lookup"
        action={controller.isLoading ? "Loading" : "read-only"}
      >
        <div className="workbench-toolbar">
          <TextField
            label="users/{uid}"
            onChange={controller.setUserId}
            placeholder="user uid"
            value={controller.userId}
          />
          <SegmentedControl<UserAnalyticsRangePreset>
            ariaLabel="User analytics range"
            options={[
              {id: "7d", label: "7d"},
              {id: "30d", label: "30d"},
              {id: "90d", label: "90d"},
              {id: "month", label: "Month"},
              {id: "custom", label: "Custom"},
            ]}
            value={controller.rangePreset}
            onChange={controller.setRangePreset}
          />
          <SelectField
            label="Group by"
            onChange={(value) =>
              controller.setGranularity(value as UserAnalyticsGranularity)}
            options={[
              {value: "day", label: "Day"},
              {value: "week", label: "Week"},
              {value: "month", label: "Month"},
            ]}
            value={controller.granularity}
          />
          <AdminButton
            disabled={controller.isLoading}
            icon={<RefreshCw size={15} strokeWidth={1.9} />}
            onClick={() => void controller.load()}
            variant="primary"
          >
            Load
          </AdminButton>
        </div>
        {controller.rangePreset === "custom" && (
          <div className="form-grid two">
            <TextField
              label="Start date"
              onChange={controller.setStartDate}
              type="date"
              value={controller.startDate}
            />
            <TextField
              label="End date"
              onChange={controller.setEndDate}
              type="date"
              value={controller.endDate}
            />
          </div>
        )}
        <p className="workbench-note">
          This tab reads the aggregate-only adminGetUserAnalytics response for
          one selected user. Enter an exact users/{"{uid}"}, uid:{"{uid}"}, or
          raw uid value; this tab does not expose identity search, account
          actions, moderation actions, payment records, or raw scoring columns.
        </p>
      </Panel>

      <UserLookupContractPanel contract={controller.lookupContract} />

      {controller.report ? (
        <UserAnalyticsReportView report={controller.report} />
      ) : (
        <EmptyState
          className="workbench-empty"
          icon={<Clock3 size={16} strokeWidth={1.9} />}
        >
          Enter a user id to load user-safe aggregate analytics.
        </EmptyState>
      )}
    </div>
  );
}

function UserLookupContractPanel({
  contract,
}: {
  contract: UserLookupContract;
}) {
  return (
    <Panel
      className="span-2"
      icon={<ShieldCheck size={18} strokeWidth={1.9} />}
      title="Lookup contract"
      action={contract.canLoad ? contract.mode.replaceAll("_", " ") : "blocked"}
    >
      <div className="publishing-editor-grid">
        <div className="quality-list">
          <AlertRow
            icon={<ShieldCheck size={16} strokeWidth={1.9} />}
            title={contract.statusLabel}
            tone={contract.canLoad ? "neutral" : "warning"}
          >
            {contract.statusDetail}
          </AlertRow>
          <StateRow label="Normalized uid" value={contract.normalizedUserId} />
          <StateRow label="Target path" value={contract.targetPath} />
          <StateRow label="Allowed source" value={contract.allowedSources.join(", ")} />
        </div>
        <div className="workbench-stack compact-stack">
          <div className="intake-section">
            <div className="intake-section-title">Unavailable Here</div>
            <div className="intake-tags">
              {contract.unavailableDomains.map((domain) => (
                <AdminTag key={domain}>{domain}</AdminTag>
              ))}
            </div>
          </div>
          <div className="intake-section">
            <div className="intake-section-title">Blocked Actions</div>
            <div className="intake-tags">
              {contract.blockedActions.map((action) => (
                <AdminTag key={action}>{action}</AdminTag>
              ))}
            </div>
          </div>
        </div>
      </div>
    </Panel>
  );
}

function UserAnalyticsReportView({report}: {report: UserAnalyticsResponse}) {
  return (
    <section className="publishing-editor-grid">
      <Panel
        className="publishing-editor-panel"
        icon={<BarChart3 size={18} strokeWidth={1.9} />}
        title="Trend"
        action={`${report.trend.length} buckets`}
      >
        <TrendTable points={report.trend} />
      </Panel>

      <div className="workbench-stack">
        <Panel
          icon={<UserRound size={18} strokeWidth={1.9} />}
          title="Scope"
          action={report.scope.userId}
        >
          <div className="quality-list">
            <StateRow label="User" value={`users/${report.scope.userId}`} />
            <StateRow label="Generated" value={formatDateTime(report.generatedAt)} />
            <StateRow label="Range start" value={formatDateTime(report.range.startDate)} />
            <StateRow label="Range end" value={formatDateTime(report.range.endDate)} />
            <StateRow label="Group by" value={report.range.granularity} />
          </div>
        </Panel>

        <SummaryPanel
          connection={report.connectionSummary}
          profile={report.profileSummary}
        />

        <Panel
          icon={<Sparkles size={18} strokeWidth={1.9} />}
          title="Coaching refs"
          action={`${report.coachingTipRefs.length} refs`}
        >
          <div className="roadmap-list">
            {report.coachingTipRefs.map((tip) => (
              <div className="roadmap-list-item" key={tip.id}>
                <Sparkles size={15} strokeWidth={1.9} />
                <span>
                  <strong>{tip.copyKey}</strong> · priority {tip.priority} ·{" "}
                  {tip.metricIds.join(", ")}
                </span>
              </div>
            ))}
          </div>
        </Panel>

        <DataQualityPanel rows={report.dataQuality} />

        <Panel
          icon={<ShieldCheck size={18} strokeWidth={1.9} />}
          title="Mutation boundary"
          action="read-only"
        >
          <div className="quality-list">
            <StateRow label="Callable" value="adminGetUserAnalytics" />
            <StateRow label="Source" value="BigQuery user analytics mart" />
            <StateRow label="Audit log" value="adminAuditLogs/{id}" />
            <StateRow label="PII" value="No identity lookup in this tab" />
            <StateRow label="Actions" value="No account/safety/payment mutations" />
          </div>
        </Panel>
      </div>
    </section>
  );
}

function TrendTable({points}: {points: UserAnalyticsTrendPoint[]}) {
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
          <th>Profile views</th>
          <th>Caught you</th>
          <th>Mutual catches</th>
          <th>Chats</th>
          <th>Events</th>
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
            <td>{numberValue(point.metrics.profileViews)}</td>
            <td>{numberValue(point.metrics.caughtYou)}</td>
            <td>{numberValue(point.metrics.mutualCatches)}</td>
            <td>{numberValue(point.metrics.chatsStarted)}</td>
            <td>{numberValue(point.metrics.eventsAttended)}</td>
          </tr>
        ))}
      </tbody>
    </DataTable>
  );
}

function SummaryPanel({
  connection,
  profile,
}: {
  connection: UserAnalyticsConnectionSummary;
  profile: UserAnalyticsProfileSummary;
}) {
  return (
    <Panel
      icon={<Database size={18} strokeWidth={1.9} />}
      title="Aggregate summary"
      action="user-safe"
    >
      <div className="quality-list">
        <StateRow label="Outgoing likes" value={connection.outgoingLikes} />
        <StateRow label="Incoming likes" value={connection.incomingLikes} />
        <StateRow label="Private interest" value={connection.privateInterestReceived} />
        <StateRow label="Mutual catches" value={connection.mutualCatches} />
        <StateRow label="Chats started" value={connection.chatsStarted} />
        <StateRow label="Messages sent" value={connection.chatMessagesSent} />
        <StateRow label="Profile dwell" value={`${profile.profileDwellSeconds}s`} />
        <StateRow label="Top photo" value={profile.topPhotoId} />
        <StateRow label="Active minutes" value={profile.activeMinutes} />
      </div>
    </Panel>
  );
}

function DataQualityPanel({rows}: {rows: UserAnalyticsDataQuality[]}) {
  return (
    <Panel
      icon={<FileWarning size={18} strokeWidth={1.9} />}
      title="Data quality"
      action={`${rows.filter((row) => row.state !== "ok").length} warnings`}
    >
      <div className="quality-list">
        {rows.map((row) => (
          <div className="state-row" key={row.id}>
            <span>{row.id}</span>
            <strong>
              <AdminTag tone={row.state === "ok" ? "muted" : "neutral"}>
                {row.state}
              </AdminTag>{" "}
              {row.detail}
            </strong>
          </div>
        ))}
      </div>
    </Panel>
  );
}

function MetricCard({metric}: {metric: UserAnalyticsMetricCard}) {
  return (
    <article
      className={`metric-card ${
        metric.status === "ready" ? "" : "attention"
      }`.trim()}
    >
      <span>{metric.label}</span>
      <div className="metric-value">{formatMetricValue(metric)}</div>
      {metric.caption ? <small className="muted-cell">{metric.caption}</small> : null}
    </article>
  );
}

function Metric({label, value}: {label: string; value: string}) {
  return (
    <article className="metric-card">
      <span>{label}</span>
      <div className="metric-value">{value}</div>
    </article>
  );
}

function formatMetricValue(metric: UserAnalyticsMetricCard): string {
  if (metric.unit === "percent") return `${metric.value}%`;
  if (metric.unit === "duration_seconds") return `${metric.value}s`;
  return numberValue(metric.value);
}

function numberValue(value: number | undefined): string {
  return new Intl.NumberFormat("en-IN", {
    maximumFractionDigits: 0,
  }).format(value ?? 0);
}

function formatDateTime(value: string): string {
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return value;
  return new Intl.DateTimeFormat("en-IN", {
    dateStyle: "medium",
    timeStyle: "short",
  }).format(date);
}

function formatDate(value: string): string {
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return value;
  return new Intl.DateTimeFormat("en-IN", {
    dateStyle: "medium",
  }).format(date);
}
