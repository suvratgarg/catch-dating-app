import {useCallback, useEffect, useMemo, useState} from "react";
import type {ReactNode} from "react";
import {
  Activity,
  AlertTriangle,
  BarChart3,
  CheckCircle2,
  CircleDollarSign,
  Clock3,
  Database,
  FileWarning,
  LineChart,
  Lock,
  RefreshCw,
  Search,
  ShieldAlert,
  Sparkles,
  UserCheck,
  Users,
} from "lucide-react";
import {onAuthStateChanged, User} from "firebase/auth";
import {auth, signInWithGoogle, signOutAdmin} from "./firebase";
import {
  dataMode,
  decideAccessApplication,
  loadOverview,
} from "./adminApi";
import {
  eventRows,
  hostGrowth,
  retentionPoints,
  sampleOverview,
} from "./sampleData";
import {
  AccessApplicationDecision,
  AdminOverviewMetric,
  AdminOverviewResponse,
  AdminQueueItem,
} from "./types";

const navigation = [
  {id: "overview", label: "Overview", icon: Activity},
  {id: "safety", label: "Safety", icon: ShieldAlert},
  {id: "access", label: "Access", icon: UserCheck},
  {id: "growth", label: "Growth", icon: LineChart},
  {id: "hosts", label: "Hosts", icon: Users},
  {id: "events", label: "Events", icon: BarChart3},
  {id: "users", label: "Users", icon: Sparkles},
  {id: "finance", label: "Finance", icon: CircleDollarSign},
  {id: "quality", label: "Data quality", icon: Database},
];

const priorityMetricIds = [
  "signupsToday",
  "signupsThisWeek",
  "openReports",
  "pendingApplications",
  "activeHosts",
  "failedPayments",
];

export function App() {
  const mode = dataMode();
  const [activeNav, setActiveNav] = useState("overview");
  const [activeRange, setActiveRange] = useState("7d");
  const [overview, setOverview] =
    useState<AdminOverviewResponse>(sampleOverview);
  const [isLoading, setIsLoading] = useState(false);
  const [decisionInFlight, setDecisionInFlight] =
    useState<Record<string, AccessApplicationDecision>>({});
  const [error, setError] = useState<string | null>(null);
  const [notice, setNotice] = useState<string | null>(null);
  const [user, setUser] = useState<User | null>(null);

  useEffect(() => {
    if (mode === "sample") return undefined;
    return onAuthStateChanged(auth, setUser);
  }, [mode]);

  const refresh = useCallback(async () => {
    setIsLoading(true);
    setError(null);
    try {
      setOverview(await loadOverview());
    } catch (loadError) {
      setError(
        loadError instanceof Error ?
          loadError.message :
          "Unable to load admin overview."
      );
    } finally {
      setIsLoading(false);
    }
  }, []);

  useEffect(() => {
    if (mode === "live" && !user) return;
    void refresh();
  }, [mode, refresh, user]);

  const primaryMetrics = useMemo(
    () => priorityMetricIds
      .map((id) => overview.metrics.find((metric) => metric.id === id))
      .filter((metric): metric is AdminOverviewMetric => Boolean(metric)),
    [overview.metrics]
  );

  const handleAccessDecision = useCallback(async (
    item: AdminQueueItem,
    decision: AccessApplicationDecision
  ) => {
    const applicationUid = applicationUidFromTargetPath(item.targetPath);
    if (!applicationUid) {
      setError("Cannot decide an access application without a valid target.");
      return;
    }

    setDecisionInFlight((current) => ({
      ...current,
      [item.targetPath]: decision,
    }));
    setError(null);
    setNotice(null);

    try {
      await decideAccessApplication({applicationUid, decision});
      setOverview((current) =>
        removeAccessApplication(current, item.targetPath)
      );
      setNotice(
        `${decision === "approve" ? "Approved" : "Denied"} ${item.title}.`
      );
      if (mode === "live") void refresh();
    } catch (decisionError) {
      setError(
        decisionError instanceof Error ?
          decisionError.message :
          "Unable to review access application."
      );
    } finally {
      setDecisionInFlight((current) => {
        const next = {...current};
        delete next[item.targetPath];
        return next;
      });
    }
  }, [mode, refresh]);

  if (mode === "live" && !user) {
    return <SignInScreen onSignIn={() => void signInWithGoogle()} />;
  }

  return (
    <div className="app-shell">
      <aside className="sidebar" aria-label="Admin sections">
        <div className="brand-block">
          <div className="brand-mark">C</div>
          <div>
            <div className="brand-title">Catch Ops</div>
            <div className="brand-subtitle">{mode} console</div>
          </div>
        </div>
        <nav className="nav-list">
          {navigation.map((item) => {
            const Icon = item.icon;
            const selected = activeNav === item.id;
            return (
              <button
                className={`nav-item ${selected ? "selected" : ""}`}
                key={item.id}
                onClick={() => setActiveNav(item.id)}
                type="button"
              >
                <Icon aria-hidden="true" size={17} strokeWidth={1.8} />
                <span>{item.label}</span>
              </button>
            );
          })}
        </nav>
        <div className="sidebar-footer">
          <Lock size={15} strokeWidth={1.8} />
          <span>Admin claim required</span>
        </div>
      </aside>

      <main className="workspace">
        <header className="topbar">
          <div>
            <h1>Overview</h1>
            <p>
              Live operations, cohort health, finance risk, and marketplace
              signals.
            </p>
          </div>
          <div className="topbar-actions">
            <div className="search-control">
              <Search size={16} strokeWidth={1.8} />
              <input aria-label="Search users or events" placeholder="Search user, host, event" />
            </div>
            <select aria-label="Environment" defaultValue="dev">
              <option value="dev">Dev</option>
              <option value="staging">Staging</option>
              <option value="prod">Prod</option>
            </select>
            <div className="segmented" aria-label="Time range">
              {["24h", "7d", "30d"].map((range) => (
                <button
                  className={activeRange === range ? "selected" : ""}
                  key={range}
                  onClick={() => setActiveRange(range)}
                  type="button"
                >
                  {range}
                </button>
              ))}
            </div>
            <button
              className="icon-button"
              disabled={isLoading}
              onClick={() => void refresh()}
              title="Refresh"
              type="button"
            >
              <RefreshCw
                className={isLoading ? "spin" : ""}
                size={17}
                strokeWidth={1.9}
              />
            </button>
            {mode === "live" && (
              <button className="ghost-button" onClick={() => void signOutAdmin()} type="button">
                Sign out
              </button>
            )}
          </div>
        </header>

        {error && (
          <div className="error-banner" role="alert">
            <AlertTriangle size={17} strokeWidth={1.9} />
            <span>{error}</span>
          </div>
        )}
        {notice && (
          <div className="success-banner" role="status">
            <CheckCircle2 size={17} strokeWidth={1.9} />
            <span>{notice}</span>
          </div>
        )}

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
                items={[
                  ...overview.queues.safetyReports,
                  ...overview.queues.eventSafetyReports,
                ]}
                title="Safety reports"
              />
              <QueueList
                decisionInFlight={decisionInFlight}
                intent="warning"
                items={overview.queues.accessApplications}
                onAccessDecision={handleAccessDecision}
                title="Access applications"
              />
              <QueueList
                intent="neutral"
                items={[
                  ...overview.queues.moderationFlags,
                  ...overview.queues.paymentIssues,
                ]}
                title="Moderation and payments"
              />
            </div>
          </Panel>

          <Panel
            icon={<LineChart size={18} strokeWidth={1.9} />}
            title="Cohort retention"
            action="M1 58%"
          >
            <LineMiniChart points={retentionPoints} />
          </Panel>

          <Panel
            icon={<Users size={18} strokeWidth={1.9} />}
            title="Host MoM growth"
            action="+21%"
          >
            <BarMiniChart points={hostGrowth} />
          </Panel>

          <Panel
            className="span-2"
            icon={<BarChart3 size={18} strokeWidth={1.9} />}
            title="Event performance"
            action="Top active events"
          >
            <EventPerformanceTable />
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
            <DataQualityRows overview={overview} />
          </Panel>
        </section>
      </main>
    </div>
  );
}

function SignInScreen({onSignIn}: {onSignIn: () => void}) {
  return (
    <main className="signin-screen">
      <section className="signin-panel">
        <div className="brand-mark large">C</div>
        <h1>Catch Ops</h1>
        <p>Internal admin access requires Firebase Auth and an admin claim.</p>
        <button className="primary-button" onClick={onSignIn} type="button">
          Sign in with Google
        </button>
      </section>
    </main>
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

function Panel({
  action,
  children,
  className = "",
  icon,
  title,
}: {
  action: string;
  children: ReactNode;
  className?: string;
  icon: ReactNode;
  title: string;
}) {
  return (
    <section className={`panel ${className}`}>
      <header className="panel-header">
        <div className="panel-title">
          {icon}
          <h2>{title}</h2>
        </div>
        <span>{action}</span>
      </header>
      {children}
    </section>
  );
}

function QueueList({
  decisionInFlight = {},
  intent,
  items,
  onAccessDecision,
  title,
}: {
  decisionInFlight?: Record<string, AccessApplicationDecision>;
  intent: "danger" | "warning" | "neutral";
  items: AdminQueueItem[];
  onAccessDecision?: (
    item: AdminQueueItem,
    decision: AccessApplicationDecision
  ) => void;
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
          <div className="empty-row">
            <CheckCircle2 size={16} strokeWidth={1.9} />
            <span>Clear</span>
          </div>
        ) : (
          items.slice(0, 3).map((item) => (
            <QueueRow
              decisionInFlight={decisionInFlight[item.targetPath]}
              intent={intent}
              item={item}
              key={item.id}
              onAccessDecision={onAccessDecision}
            />
          ))
        )}
      </div>
    </div>
  );
}

function QueueRow({
  decisionInFlight,
  intent,
  item,
  onAccessDecision,
}: {
  decisionInFlight?: AccessApplicationDecision;
  intent: "danger" | "warning" | "neutral";
  item: AdminQueueItem;
  onAccessDecision?: (
    item: AdminQueueItem,
    decision: AccessApplicationDecision
  ) => void;
}) {
  const isDeciding = Boolean(decisionInFlight);
  return (
    <article className={`queue-row ${intent}`}>
      <div>
        <h3>{item.title}</h3>
        <p>{item.detail}</p>
      </div>
      <div className="queue-row-actions">
        <span>{relativeTime(item.createdAt)}</span>
        {intent === "warning" && onAccessDecision && (
          <div className="decision-actions">
            <button
              disabled={isDeciding}
              onClick={() => onAccessDecision(item, "approve")}
              type="button"
            >
              {decisionInFlight === "approve" ? "Approving" : "Approve"}
            </button>
            <button
              disabled={isDeciding}
              onClick={() => onAccessDecision(item, "deny")}
              type="button"
            >
              {decisionInFlight === "deny" ? "Denying" : "Deny"}
            </button>
          </div>
        )}
      </div>
    </article>
  );
}

function LineMiniChart({points}: {points: Array<{label: string; value: number}>}) {
  const path = points.map((point, index) => {
    const x = (index / (points.length - 1)) * 100;
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
  const max = Math.max(...points.map((point) => point.value), 1);
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

function EventPerformanceTable() {
  return (
    <div className="table-wrap">
      <table>
        <thead>
          <tr>
            <th>Event</th>
            <th>Host</th>
            <th>Fill</th>
            <th>Check-in</th>
            <th>Rating</th>
            <th>GMV</th>
            <th>Risk</th>
          </tr>
        </thead>
        <tbody>
          {eventRows.map((row) => (
            <tr key={row.event}>
              <td>{row.event}</td>
              <td>{row.host}</td>
              <td>{row.fill}</td>
              <td>{row.checkIn}</td>
              <td>{row.rating}</td>
              <td>{row.gmv}</td>
              <td><span className={`risk ${row.risk}`}>{row.risk}</span></td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
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

function DataQualityRows({overview}: {overview: AdminOverviewResponse}) {
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
    </div>
  );
}

function queueCount(overview: AdminOverviewResponse) {
  return Object.values(overview.queues)
    .reduce((sum, items) => sum + items.length, 0);
}

function applicationUidFromTargetPath(targetPath: string): string | null {
  const [collection, uid, extra] = targetPath.split("/");
  if (collection !== "accessApplications" || !uid || extra) return null;
  return uid;
}

function removeAccessApplication(
  overview: AdminOverviewResponse,
  targetPath: string
): AdminOverviewResponse {
  const applications = overview.queues.accessApplications.filter(
    (item) => item.targetPath !== targetPath
  );
  const removed = applications.length !==
    overview.queues.accessApplications.length;
  return {
    ...overview,
    metrics: overview.metrics.map((metric) => {
      if (metric.id !== "pendingApplications" || !removed) return metric;
      return {...metric, value: Math.max(0, metric.value - 1)};
    }),
    queues: {
      ...overview.queues,
      accessApplications: applications,
    },
  };
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
