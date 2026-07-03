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
  AdminEditorGrid,
  AdminEditorPanel,
  AdminFieldGrid,
  AdminMetricCard,
  AdminMetricGrid,
  AdminRoadmapList,
  AdminRoadmapListItem,
  AdminTag,
  AdminToolbar,
  AdminWorkbenchNote,
  AdminWorkbenchStack,
  AlertRow,
  DataTable,
  EmptyState,
  Panel,
  QualityList,
  SegmentedControl,
  SelectField,
  StateRow,
  TextField,
  AdminTagList,
  AdminIntakeSection,
  AdminIntakeSectionTitle,
  AdminRowTitle,
} from "../../../shared/ui/AdminPrimitives";
import {
  type UserAnalyticsController,
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
  return <UserAnalyticsWorkspace controller={controller} />;
}

export function UserAnalyticsWorkspace({
  controller,
}: {
  controller: UserAnalyticsController;
}) {
  const missingCount = controller.report?.summaryCards.filter((metric) =>
    metric.status === "missing"
  ).length ?? 0;
  const partialCount = controller.report?.dataQuality.filter((row) =>
    row.state !== "ok"
  ).length ?? 0;

  return (
    <AdminWorkbenchStack>
      <AdminMetricGrid ariaLabel="User analytics state">
        {controller.report ? (
          controller.report.summaryCards.map((metric) => (
            <AdminMetricCard
              caption={metric.caption}
              key={metric.id}
              label={metric.label}
              tone={metric.status === "ready" ? "normal" : "attention"}
              value={formatMetricValue(metric)}
            />
          ))
        ) : (
          <>
            <AdminMetricCard label="Selected user" value={controller.userId || "none"} />
            <AdminMetricCard label="Range" value={controller.rangePreset} />
            <AdminMetricCard label="Missing metrics" value={String(missingCount)} />
            <AdminMetricCard label="Data warnings" value={String(partialCount)} />
          </>
        )}
      </AdminMetricGrid>

      <Panel
        icon={<Search size={18} strokeWidth={1.9} />}
        title="User analytics lookup"
        action={controller.isLoading ? "Loading" : "read-only"}
      >
        <AdminToolbar>
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
        </AdminToolbar>
        {controller.rangePreset === "custom" && (
          <AdminFieldGrid columns={2}>
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
          </AdminFieldGrid>
        )}
        <AdminWorkbenchNote>
          This tab reads the aggregate-only adminGetUserAnalytics response for
          one selected user. Enter an exact users/{"{uid}"}, uid:{"{uid}"}, or
          raw uid value; this tab does not expose identity search, account
          actions, moderation actions, payment records, or raw scoring columns.
        </AdminWorkbenchNote>
      </Panel>

      <UserLookupContractPanel contract={controller.lookupContract} />

      {controller.report ? (
        <UserAnalyticsReportView report={controller.report} />
      ) : (
        <EmptyState
          variant="workbench"
          icon={<Clock3 size={16} strokeWidth={1.9} />}
        >
          Enter a user id to load user-safe aggregate analytics.
        </EmptyState>
      )}
    </AdminWorkbenchStack>
  );
}

function UserLookupContractPanel({
  contract,
}: {
  contract: UserLookupContract;
}) {
  return (
    <Panel
      span={2}
      icon={<ShieldCheck size={18} strokeWidth={1.9} />}
      title="Lookup contract"
      action={contract.canLoad ? contract.mode.replaceAll("_", " ") : "blocked"}
    >
      <AdminEditorGrid as="div">
        <QualityList>
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
        </QualityList>
        <AdminWorkbenchStack compact>
          <AdminIntakeSection>
            <AdminIntakeSectionTitle>Unavailable Here</AdminIntakeSectionTitle>
            <AdminTagList>
              {contract.unavailableDomains.map((domain) => (
                <AdminTag key={domain}>{domain}</AdminTag>
              ))}
            </AdminTagList>
          </AdminIntakeSection>
          <AdminIntakeSection>
            <AdminIntakeSectionTitle>Blocked Actions</AdminIntakeSectionTitle>
            <AdminTagList>
              {contract.blockedActions.map((action) => (
                <AdminTag key={action}>{action}</AdminTag>
              ))}
            </AdminTagList>
          </AdminIntakeSection>
        </AdminWorkbenchStack>
      </AdminEditorGrid>
    </Panel>
  );
}

function UserAnalyticsReportView({report}: {report: UserAnalyticsResponse}) {
  return (
    <AdminEditorGrid>
      <AdminEditorPanel
        icon={<BarChart3 size={18} strokeWidth={1.9} />}
        title="Trend"
        action={`${report.trend.length} buckets`}
      >
        <TrendTable points={report.trend} />
      </AdminEditorPanel>
      <AdminWorkbenchStack>
        <Panel
          icon={<UserRound size={18} strokeWidth={1.9} />}
          title="Scope"
          action={report.scope.userId}
        >
          <QualityList>
            <StateRow label="User" value={`users/${report.scope.userId}`} />
            <StateRow label="Generated" value={formatDateTime(report.generatedAt)} />
            <StateRow label="Range start" value={formatDateTime(report.range.startDate)} />
            <StateRow label="Range end" value={formatDateTime(report.range.endDate)} />
            <StateRow label="Group by" value={report.range.granularity} />
          </QualityList>
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
          <AdminRoadmapList>
            {report.coachingTipRefs.map((tip) => (
              <AdminRoadmapListItem key={tip.id}>
                <Sparkles size={15} strokeWidth={1.9} />
                <span>
                  <strong>{tip.copyKey}</strong> · priority {tip.priority} ·{" "}
                  {tip.metricIds.join(", ")}
                </span>
              </AdminRoadmapListItem>
            ))}
          </AdminRoadmapList>
        </Panel>

        <DataQualityPanel rows={report.dataQuality} />

        <Panel
          icon={<ShieldCheck size={18} strokeWidth={1.9} />}
          title="Mutation boundary"
          action="read-only"
        >
          <QualityList>
            <StateRow label="Callable" value="adminGetUserAnalytics" />
            <StateRow label="Source" value="BigQuery user analytics mart" />
            <StateRow label="Audit log" value="adminAuditLogs/{id}" />
            <StateRow label="PII" value="No identity lookup in this tab" />
            <StateRow label="Actions" value="No account/safety/payment mutations" />
          </QualityList>
        </Panel>
      </AdminWorkbenchStack>
    </AdminEditorGrid>
  );
}

function TrendTable({points}: {points: UserAnalyticsTrendPoint[]}) {
  if (points.length === 0) {
    return (
      <EmptyState
        variant="workbench"
        icon={<Clock3 size={16} strokeWidth={1.9} />}
      >
        No trend buckets are available for this range.
      </EmptyState>
    );
  }
  return (
    <DataTable variant="workbench">
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
              <AdminRowTitle compact>
                <strong>{formatDate(point.periodStart)}</strong>
                <span>{formatDate(point.periodEnd)}</span>
              </AdminRowTitle>
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
      <QualityList>
        <StateRow label="Outgoing likes" value={connection.outgoingLikes} />
        <StateRow label="Incoming likes" value={connection.incomingLikes} />
        <StateRow label="Private interest" value={connection.privateInterestReceived} />
        <StateRow label="Mutual catches" value={connection.mutualCatches} />
        <StateRow label="Chats started" value={connection.chatsStarted} />
        <StateRow label="Messages sent" value={connection.chatMessagesSent} />
        <StateRow label="Profile dwell" value={`${profile.profileDwellSeconds}s`} />
        <StateRow label="Top photo" value={profile.topPhotoId} />
        <StateRow label="Active minutes" value={profile.activeMinutes} />
      </QualityList>
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
      <QualityList>
        {rows.map((row) => (
          <StateRow
            key={row.id}
            label={row.id}
            value={(
              <>
              <AdminTag tone={row.state === "ok" ? "muted" : "neutral"}>
                {row.state}
              </AdminTag>{" "}
              {row.detail}
              </>
            )}
          />
        ))}
      </QualityList>
    </Panel>
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
