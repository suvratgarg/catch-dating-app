import {useEffect, useId, useRef, useState} from "react";
import type {
  AnchorHTMLAttributes,
  ButtonHTMLAttributes,
  FieldsetHTMLAttributes,
  FormHTMLAttributes,
  HTMLAttributes,
  ImgHTMLAttributes,
  InputHTMLAttributes,
  ReactNode,
  SelectHTMLAttributes,
  TextareaHTMLAttributes,
} from "react";
import {
  CheckCircle2,
  ChevronDown,
  FileWarning,
  Lock,
  LogOut,
  RefreshCw,
  UserRound,
} from "lucide-react";

type SelectOption = string | {label: ReactNode; value: string};

type ChipTone = "base" | "neutral" | "muted" | "warning" | "success" | "danger" | "ready" | "blocked" | string;
type AlertTone = "neutral" | "warning" | "success" | "blocked";
type TagTone = "base" | "neutral" | "muted" | "ready" | "blocked" | "warning" | "success" | "danger" | string;
type MetricTone = "normal" | "attention";
type MetricVariant = "card" | "tile";
type QualityRowTone = "base" | AlertTone | string;
type AdminOverviewQueueIntent = "danger" | "warning" | "neutral";
type AdminOverviewSignalTone = "green" | "teal" | "orange" | "red";
type RiskTone = "low" | "medium" | "high" | "watch";
type DataTableVariant = "default" | "workbench";
type AdminFormVariant = "default" | "publishing";
type AdminEditorGridElement = "div" | "section";
type AdminTagRowElement = "div" | "span";
type EmptyStateVariant = "row" | "workbench" | "editor" | "marketing";
type AdminLayoutSpan = 1 | 2;
type AdminEyebrowElement = "div" | "span";
type AdminIntakeGateTone = "passed" | "blocked" | string;
type AdminBrandMarkSize = "default" | "large";
type AdminMarketingStepStatus = "active" | "done" | "todo";
type AdminMarketingNewPostAccent = "event" | "feature" | "soon";
type ReviewDecision = "approve" | "needs_changes" | "hold" | "reject" |
  "export_ready";

type ReviewDecisionHandler = (input: {
  targetType: string;
  targetId: string;
  decision: ReviewDecision;
  edits?: Record<string, unknown>;
  defaultNote: string;
}) => Promise<void>;

interface ReviewDecisionResponse {
  decisionStatus: string;
  decisionPath: string;
}

type PageHeaderProps = {
  actions?: ReactNode;
  children?: ReactNode;
  className?: string;
  eyebrow?: ReactNode;
  title: ReactNode;
};

type PanelProps = {
  action?: ReactNode;
  children: ReactNode;
  className?: string;
  icon: ReactNode;
  span?: AdminLayoutSpan;
  title: string;
};

function classNames(...values: Array<string | false | null | undefined>) {
  return values.filter(Boolean).join(" ");
}

function layoutSpanClass(span?: AdminLayoutSpan) {
  return span === 2 ? "span-2" : undefined;
}

export function AdminAppShell({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("app-shell", className)}>
      {children}
    </div>
  );
}

export function AdminSidebar({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLElement> & {
  children: ReactNode;
}) {
  return (
    <aside {...props} className={classNames("sidebar", className)}>
      {children}
    </aside>
  );
}

export function AdminBrandBlock({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("brand-block", className)}>
      {children}
    </div>
  );
}

export function AdminBrandMark({
  children,
  className = "",
  size = "default",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
  size?: AdminBrandMarkSize;
}) {
  return (
    <div {...props} className={classNames("brand-mark", size === "large" && "large", className)}>
      {children}
    </div>
  );
}

export function AdminBrandCopy({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("brand-copy", className)}>
      {children}
    </div>
  );
}

export function AdminBrandTitle({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("brand-title", className)}>
      {children}
    </div>
  );
}

export function AdminBrandSubtitle({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("brand-subtitle", className)}>
      {children}
    </div>
  );
}

export function AdminNavList({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLElement> & {
  children: ReactNode;
}) {
  return (
    <nav {...props} className={classNames("nav-list", className)}>
      {children}
    </nav>
  );
}

export function AdminWorkspace({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLElement> & {
  children: ReactNode;
}) {
  return (
    <main {...props} className={classNames("workspace", className)}>
      {children}
    </main>
  );
}

export function AdminTopbar({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLElement> & {
  children: ReactNode;
}) {
  return (
    <header {...props} className={classNames("topbar", className)}>
      {children}
    </header>
  );
}

export function AdminTopbarActions({
  children,
  className = "",
  ...props
}: FormHTMLAttributes<HTMLFormElement> & {
  children: ReactNode;
}) {
  return (
    <form {...props} className={classNames("topbar-actions", className)}>
      {children}
    </form>
  );
}

export function AdminAccountMenu({
  defaultOpen = false,
  isSigningOut = false,
  mode,
  onSignOut,
  roles,
  userLabel = "Signed in",
}: {
  defaultOpen?: boolean;
  isSigningOut?: boolean;
  mode: string;
  onSignOut?: () => void;
  roles: readonly string[];
  userLabel?: string;
}) {
  const [isOpen, setIsOpen] = useState(defaultOpen);
  const containerRef = useRef<HTMLDivElement>(null);
  const triggerRef = useRef<HTMLButtonElement>(null);
  const panelId = useId();
  const primaryRole = roles[0] ? adminAccountRoleLabel(roles[0]) : "Account";
  const accountMeta = mode === "sample" ?
    "Sample mode" :
    roles.length > 1 ? `${roles.length} roles` : "Live account";

  useEffect(() => {
    if (!isOpen) return undefined;

    const closeOnOutsidePointer = (event: PointerEvent) => {
      if (
        event.target instanceof Node &&
        !containerRef.current?.contains(event.target)
      ) {
        setIsOpen(false);
      }
    };
    const closeOnEscape = (event: globalThis.KeyboardEvent) => {
      if (event.key !== "Escape") return;
      event.preventDefault();
      setIsOpen(false);
      triggerRef.current?.focus();
    };

    document.addEventListener("pointerdown", closeOnOutsidePointer);
    document.addEventListener("keydown", closeOnEscape);
    return () => {
      document.removeEventListener("pointerdown", closeOnOutsidePointer);
      document.removeEventListener("keydown", closeOnEscape);
    };
  }, [isOpen]);

  const handleSignOut = () => {
    setIsOpen(false);
    onSignOut?.();
  };

  return (
    <div className="admin-account-menu" ref={containerRef}>
      <button
        aria-controls={panelId}
        aria-expanded={isOpen}
        aria-haspopup="dialog"
        aria-label="Account menu"
        className="admin-account-trigger"
        onClick={() => setIsOpen((current) => !current)}
        ref={triggerRef}
        type="button"
      >
        <span aria-hidden="true" className="admin-account-avatar">
          <UserRound size={15} strokeWidth={1.9} />
        </span>
        <span className="admin-account-trigger-copy">
          <strong>{primaryRole}</strong>
          <span>{accountMeta}</span>
        </span>
        <ChevronDown
          aria-hidden="true"
          className="admin-account-chevron"
          size={15}
          strokeWidth={1.9}
        />
      </button>
      {isOpen ? (
        <div
          aria-label="Account details"
          className="admin-account-panel"
          id={panelId}
          role="dialog"
        >
          <span className="admin-account-label">Signed in as</span>
          <strong className="admin-account-identity" title={userLabel}>
            {userLabel}
          </strong>
          <div aria-label="Admin roles" className="admin-account-roles">
            {roles.length > 0 ? (
              roles.map((role) => (
                <span className="admin-account-role" key={role}>
                  {adminAccountRoleLabel(role)}
                </span>
              ))
            ) : (
              <span className="admin-account-role muted">No admin roles</span>
            )}
          </div>
          {onSignOut ? (
            <button
              className="admin-account-sign-out"
              disabled={isSigningOut}
              onClick={handleSignOut}
              type="button"
            >
              <LogOut aria-hidden="true" size={16} strokeWidth={1.9} />
              {isSigningOut ? "Signing out" : "Sign out"}
            </button>
          ) : null}
        </div>
      ) : null}
    </div>
  );
}

function adminAccountRoleLabel(role: string): string {
  const words = role
    .replace(/([a-z0-9])([A-Z])/gu, "$1 $2")
    .replace(/[-_]+/gu, " ")
    .trim()
    .toLowerCase();
  return words ? `${words[0]!.toUpperCase()}${words.slice(1)}` : "Account";
}

export function AdminSignInScreen({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLElement> & {
  children: ReactNode;
}) {
  return (
    <main {...props} className={classNames("signin-screen", className)}>
      {children}
    </main>
  );
}

export function AdminSignInPanel({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLElement> & {
  children: ReactNode;
}) {
  return (
    <section {...props} className={classNames("signin-panel", className)}>
      {children}
    </section>
  );
}

export function AdminSignInMeta({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("signin-meta", className)}>
      {children}
    </div>
  );
}

export function AdminSignInActions({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("signin-actions", className)}>
      {children}
    </div>
  );
}

export function AdminEyebrow({
  as = "div",
  children,
  className = "",
}: {
  as?: AdminEyebrowElement;
  children: ReactNode;
  className?: string;
}) {
  const classes = classNames("intake-eyebrow", className);
  if (as === "span") {
    return <span className={classes}>{children}</span>;
  }
  return <div className={classes}>{children}</div>;
}

export function AdminButton({
  children,
  className = "",
  icon,
  selected = false,
  type = "button",
  variant = "ghost",
  ...props
}: {
  children: ReactNode;
  className?: string;
  icon?: ReactNode;
  selected?: boolean;
  variant?: "ghost" | "primary";
} & ButtonHTMLAttributes<HTMLButtonElement>) {
  const classes = [
    variant === "primary" ? "primary-button" : "ghost-button",
    selected ? "selected" : "",
    className,
  ].filter(Boolean).join(" ");
  return (
    <button className={classes} type={type} {...props}>
      {icon}
      {children}
    </button>
  );
}

export function AdminOverviewMainGrid({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLElement> & {
  children: ReactNode;
}) {
  return (
    <section {...props} className={classNames("main-grid", className)}>
      {children}
    </section>
  );
}

export function AdminOverviewQueueColumns({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("queue-columns", className)}>
      {children}
    </div>
  );
}

export function AdminOverviewAnalyticsClearButton({
  className = "",
  ...props
}: ButtonHTMLAttributes<HTMLButtonElement> & {
  children: ReactNode;
}) {
  return (
    <AdminButton
      {...props}
      className={classNames("analytics-clear", className)}
    />
  );
}

export function AdminOverviewQueueList({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("queue-list", className)}>
      {children}
    </div>
  );
}

export function AdminOverviewQueueHeading({
  count,
  title,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  count: ReactNode;
  title: ReactNode;
}) {
  return (
    <div {...props} className={classNames("queue-heading", className)}>
      <span>{title}</span>
      <strong>{count}</strong>
    </div>
  );
}

export function AdminOverviewQueueItems({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("queue-items", className)}>
      {children}
    </div>
  );
}

export function AdminOverviewQueueRow({
  children,
  className = "",
  intent,
  selected = false,
  ...props
}: HTMLAttributes<HTMLElement> & {
  children: ReactNode;
  intent: AdminOverviewQueueIntent;
  selected?: boolean;
}) {
  return (
    <article
      {...props}
      className={classNames("queue-row", intent, selected && "selected", className)}
    >
      {children}
    </article>
  );
}

export function AdminOverviewQueueRowActions({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("queue-row-actions", className)}>
      {children}
    </div>
  );
}

export function AdminOverviewQueueActionHint({
  children,
}: {
  children: ReactNode;
}) {
  return <AdminTag tone="muted">{children}</AdminTag>;
}

export function AdminOverviewQueueDecisionButton({
  className = "",
  ...props
}: ButtonHTMLAttributes<HTMLButtonElement> & {
  children: ReactNode;
}) {
  return (
    <AdminButton
      {...props}
      className={classNames("queue-decision-button", className)}
    />
  );
}

export function AdminOverviewQueueDetailPanel({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLElement> & {
  children: ReactNode;
}) {
  return (
    <section {...props} className={classNames("queue-detail-panel", className)}>
      {children}
    </section>
  );
}

export function AdminOverviewLineChart({
  emptyLabel,
  points,
}: {
  emptyLabel: ReactNode;
  points: Array<{label: string; value: number}>;
}) {
  if (points.length === 0) {
    return (
      <EmptyState className="empty-panel">
        {emptyLabel}
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

export function AdminOverviewBarChart({
  emptyLabel,
  points,
}: {
  emptyLabel: ReactNode;
  points: Array<{label: string; value: number}>;
}) {
  if (points.length === 0) {
    return (
      <EmptyState className="empty-panel">
        {emptyLabel}
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

export function AdminOverviewValueSignals({
  signals,
}: {
  signals: Array<{
    label: string;
    tone: AdminOverviewSignalTone;
    value: number;
  }>;
}) {
  return (
    <div className="signals">
      {signals.map((signal) => {
        const width = Math.max(0, Math.min(100, signal.value));
        return (
          <div className="signal-row" key={signal.label}>
            <div>
              <span>{signal.label}</span>
              <strong>{signal.value}</strong>
            </div>
            <div className="signal-track">
              <div
                className={classNames("signal-fill", signal.tone)}
                style={{width: `${width}%`}}
              />
            </div>
          </div>
        );
      })}
    </div>
  );
}

export function AdminIconButton({
  children,
  className = "",
  label,
  title,
  type = "button",
  ...props
}: {
  children: ReactNode;
  className?: string;
  label: string;
} & ButtonHTMLAttributes<HTMLButtonElement>) {
  return (
    <button
      aria-label={label}
      className={`icon-button ${className}`.trim()}
      title={title ?? label}
      type={type}
      {...props}
    >
      {children}
    </button>
  );
}

export function AdminLinkButton({
  children,
  className = "",
  icon,
  label,
  variant = "ghost",
  ...props
}: {
  children?: ReactNode;
  className?: string;
  icon?: ReactNode;
  label?: string;
  variant?: "ghost" | "icon";
} & AnchorHTMLAttributes<HTMLAnchorElement>) {
  const classes = [
    variant === "icon" ? "icon-button" : "ghost-button",
    className,
  ].filter(Boolean).join(" ");
  return (
    <a
      aria-label={label}
      className={classes}
      title={props.title ?? label}
      {...props}
    >
      {icon}
      {children}
    </a>
  );
}

export function FilePickerButton({
  children,
  className = "",
  icon,
  inputLabel,
  ...props
}: {
  children: ReactNode;
  className?: string;
  icon?: ReactNode;
  inputLabel: string;
} & Omit<InputHTMLAttributes<HTMLInputElement>, "aria-label" | "type">) {
  return (
    <label className={`ghost-button ${className}`.trim()}>
      {icon}
      {children}
      <input aria-label={inputLabel} type="file" {...props} />
    </label>
  );
}

export function AdminNavButton({
  icon,
  label,
  selected,
  type = "button",
  ...props
}: {
  icon: ReactNode;
  label: string;
  selected: boolean;
} & ButtonHTMLAttributes<HTMLButtonElement>) {
  return (
    <button
      className={`nav-item ${selected ? "selected" : ""}`}
      type={type}
      {...props}
    >
      {icon}
      <span>{label}</span>
    </button>
  );
}

export function SearchField({
  ariaLabel,
  className = "",
  icon,
  onChange,
  value,
  ...props
}: {
  ariaLabel: string;
  className?: string;
  icon?: ReactNode;
  onChange?: (value: string) => void;
  value?: string;
} & Omit<InputHTMLAttributes<HTMLInputElement>, "aria-label" | "onChange" | "value">) {
  return (
    <div className={`search-control ${className}`.trim()}>
      {icon}
      <input
        aria-label={ariaLabel}
        onChange={(event) => onChange?.(event.target.value)}
        value={value}
        {...props}
      />
    </div>
  );
}

export function InlineTextField({
  ariaLabel,
  className = "",
  onChange,
  value,
  ...props
}: {
  ariaLabel: string;
  className?: string;
  onChange: (value: string) => void;
  value: string;
} & Omit<InputHTMLAttributes<HTMLInputElement>, "aria-label" | "className" | "onChange" | "value">) {
  return (
    <input
      aria-label={ariaLabel}
      className={className}
      onChange={(event) => onChange(event.target.value)}
      value={value}
      {...props}
    />
  );
}

export function SegmentedControl<T extends string>({
  ariaLabel,
  className = "",
  options,
  value,
  onChange,
}: {
  ariaLabel: string;
  className?: string;
  options: Array<{disabled?: boolean; id: T; label: ReactNode}>;
  value: T;
  onChange: (value: T) => void;
}) {
  return (
    <div className={`segmented ${className}`.trim()} aria-label={ariaLabel}>
      {options.map((option) => (
        <button
          className={value === option.id ? "selected" : ""}
          disabled={option.disabled}
          key={option.id}
          onClick={() => onChange(option.id)}
          type="button"
        >
          {option.label}
        </button>
      ))}
    </div>
  );
}

export function StatusBanner({
  children,
  icon,
  tone,
}: {
  children: ReactNode;
  icon: ReactNode;
  tone: "error" | "success";
}) {
  return (
    <div
      className={tone === "error" ? "error-banner" : "success-banner"}
      role={tone === "error" ? "alert" : "status"}
    >
      {icon}
      <span>{children}</span>
    </div>
  );
}

export function AdminMetricGrid({
  ariaLabel,
  children,
  className = "",
}: {
  ariaLabel: string;
  children: ReactNode;
  className?: string;
}) {
  return (
    <section className={classNames("metric-grid", className)} aria-label={ariaLabel}>
      {children}
    </section>
  );
}

export function AdminMetricCard({
  caption,
  label,
  tone = "normal",
  value,
  variant = "card",
}: {
  caption?: ReactNode;
  label: ReactNode;
  tone?: MetricTone;
  value: ReactNode;
  variant?: MetricVariant;
}) {
  return (
    <article className={classNames(
      variant === "tile" ? "metric-tile" : "metric-card",
      tone === "attention" && "attention"
    )}>
      <span className={variant === "tile" ? "metric-label" : undefined}>{label}</span>
      <div className="metric-value">{value}</div>
      {caption ? <small className="muted-cell">{caption}</small> : null}
    </article>
  );
}

export function AdminPublishingLoadbar({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement>) {
  return (
    <div {...props} className={classNames("publishing-loadbar", className)}>
      {children}
    </div>
  );
}

export function AdminSurfacePreview({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement>) {
  return (
    <div {...props} className={classNames("surface-preview", className)}>
      {children}
    </div>
  );
}

export function AdminMutedCell({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLSpanElement>) {
  return (
    <span {...props} className={classNames("muted-cell", className)}>
      {children}
    </span>
  );
}

export function AdminPanelActions({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement>) {
  return (
    <div {...props} className={classNames("admin-panel-actions", className)}>
      {children}
    </div>
  );
}

export function AdminEventSupplyReviewGrid({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement>) {
  return (
    <div {...props} className={classNames("event-supply-review-grid", className)}>
      {children}
    </div>
  );
}

export function AdminEventSupplyDetailStack({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement>) {
  return (
    <div {...props} className={classNames("event-supply-detail-stack", className)}>
      {children}
    </div>
  );
}

export function AdminEventSupplyDetail({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLElement>) {
  return (
    <aside {...props} className={classNames("event-supply-detail", className)}>
      {children}
    </aside>
  );
}

export function AdminEventSupplyLinks({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement>) {
  return (
    <div {...props} className={classNames("event-supply-links", className)}>
      {children}
    </div>
  );
}

export function AdminToolbar({
  children,
  className = "",
  compact = false,
}: {
  children: ReactNode;
  className?: string;
  compact?: boolean;
}) {
  return (
    <div className={classNames("workbench-toolbar", compact && "compact", className)}>
      {children}
    </div>
  );
}

export function AdminCommandStack({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("command-stack", className)}>
      {children}
    </div>
  );
}

export function AdminCommandRow({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("command-row", className)}>
      {children}
    </div>
  );
}

export function AdminWorkbenchNote({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLParagraphElement> & {
  children: ReactNode;
}) {
  return (
    <p {...props} className={classNames("workbench-note", className)}>
      {children}
    </p>
  );
}

export function AdminWorkbenchStack({
  children,
  className = "",
  compact = false,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
  compact?: boolean;
}) {
  return (
    <div
      {...props}
      className={classNames("workbench-stack", compact && "compact-stack", className)}
    >
      {children}
    </div>
  );
}

export function AdminChecklistStack({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("checklist-stack", className)}>
      {children}
    </div>
  );
}

export function AdminDirectoryScreenStack({
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <AdminWorkbenchStack {...props} className={classNames("admin-directory-screen", className)} />
  );
}

export function AdminDetailScreenStack({
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <AdminWorkbenchStack {...props} className={classNames("admin-detail-screen", className)} />
  );
}

export function AdminEditorGrid({
  as = "section",
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLElement> & {
  as?: AdminEditorGridElement;
  children: ReactNode;
}) {
  if (as === "div") {
    return (
      <div
        {...props}
        className={classNames("publishing-editor-grid", className)}
      >
        {children}
      </div>
    );
  }

  return (
    <section
      {...props}
      className={classNames("publishing-editor-grid", className)}
    >
      {children}
    </section>
  );
}

export function AdminStatusGrid({
  children,
  className = "",
  compact = false,
}: {
  children: ReactNode;
  className?: string;
  compact?: boolean;
}) {
  return (
    <div className={classNames("admin-status-grid", compact && "compact", className)}>
      {children}
    </div>
  );
}

export function AdminFilterBar({
  ariaLabel,
  children,
  className = "",
}: {
  ariaLabel: string;
  children: ReactNode;
  className?: string;
}) {
  return (
    <section className={classNames("analytics-controls", className)} aria-label={ariaLabel}>
      {children}
    </section>
  );
}

export function EmptyState({
  children,
  className = "",
  compact = false,
  icon,
  variant = "row",
}: {
  children: ReactNode;
  className?: string;
  compact?: boolean;
  icon?: ReactNode;
  variant?: EmptyStateVariant;
}) {
  const variantClass = variant === "workbench" ?
    "workbench-empty" :
    variant === "editor" ?
    "empty-editor" :
    variant === "marketing" ?
    "marketing-empty-state" :
    "empty-row";
  return (
    <div className={classNames(variantClass, compact && "compact", className)}>
      {icon}
      <span>{children}</span>
    </div>
  );
}

export function AdminEventSupplyEmptyState({
  children,
  className = "",
  icon,
}: {
  children: ReactNode;
  className?: string;
  icon?: ReactNode;
}) {
  return (
    <EmptyState
      className={classNames("event-supply-detail", className)}
      icon={icon}
      variant="workbench"
    >
      {children}
    </EmptyState>
  );
}

export function AdminFeatureLoadingState({
  label,
}: {
  label: ReactNode;
}) {
  return (
    <EmptyState
      variant="marketing"
      icon={<AdminLoadingIcon size={18} />}
    >
      {label}...
    </EmptyState>
  );
}

export function AdminLoadingIcon({
  active = true,
  size = 17,
  strokeWidth = 1.9,
}: {
  active?: boolean;
  size?: number;
  strokeWidth?: number;
}) {
  return (
    <RefreshCw
      aria-hidden="true"
      className={active ? "spin" : undefined}
      size={size}
      strokeWidth={strokeWidth}
    />
  );
}

export function AdminEnvironmentStatus({
  environment,
  mode,
  title = "Configured by Vite environment variables",
}: {
  environment: ReactNode;
  mode: ReactNode;
  title?: string;
}) {
  return (
    <span className="admin-env-status" title={title}>
      {environment} · {mode}
    </span>
  );
}

export function PageHeader({
  actions,
  children,
  className = "",
  eyebrow,
  title,
}: PageHeaderProps) {
  return (
    <header className={`marketing-ops-header ${className}`.trim()}>
      <div>
        {eyebrow ? <AdminEyebrow>{eyebrow}</AdminEyebrow> : null}
        <h2>{title}</h2>
        {children ? <p>{children}</p> : null}
      </div>
      {actions}
    </header>
  );
}

export function AdminMarketingOpsShell({
  children,
  className = "",
  variant,
  ...props
}: HTMLAttributes<HTMLElement> & {
  children: ReactNode;
  variant?: "studio";
}) {
  return (
    <section
      {...props}
      className={classNames("marketing-ops-shell", variant === "studio" && "marketing-studio-shell", className)}
    >
      {children}
    </section>
  );
}

export function AdminIntakeEventWorkspaceShell({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLElement> & {
  children: ReactNode;
}) {
  return (
    <AdminMarketingOpsShell
      {...props}
      className={classNames("intake-event-workspace", className)}
    >
      {children}
    </AdminMarketingOpsShell>
  );
}

export function AdminIntakeWorkspaceHeader({
  actions,
  children,
  className = "",
  eyebrow,
  title,
  ...props
}: HTMLAttributes<HTMLElement> & {
  actions?: ReactNode;
  children?: ReactNode;
  eyebrow?: ReactNode;
  title: ReactNode;
}) {
  return (
    <section {...props} className={classNames("intake-workspace-header", className)}>
      <div>
        {eyebrow ? <AdminEyebrow>{eyebrow}</AdminEyebrow> : null}
        <h2>{title}</h2>
        {children ? <p>{children}</p> : null}
      </div>
      {actions}
    </section>
  );
}

export function AdminIntakeWorkspaceTabs<T extends string>({
  ariaLabel,
  className = "",
  options,
  value,
  onChange,
}: {
  ariaLabel: string;
  className?: string;
  options: Array<{disabled?: boolean; id: T; label: ReactNode}>;
  value: T;
  onChange: (value: T) => void;
}) {
  return (
    <SegmentedControl
      ariaLabel={ariaLabel}
      className={classNames("intake-workspace-tabs", className)}
      options={options}
      value={value}
      onChange={onChange}
    />
  );
}

export function AdminIntakeLayout({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLElement> & {
  children: ReactNode;
}) {
  return (
    <section {...props} className={classNames("main-grid", "intake-layout", className)}>
      {children}
    </section>
  );
}

export function AdminMarketingStudioHeader({
  className = "",
  ...props
}: PageHeaderProps) {
  return (
    <PageHeader
      {...props}
      className={classNames("marketing-studio-header", className)}
    />
  );
}

export function AdminMarketingStudioActions({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("marketing-studio-actions", className)}>
      {children}
    </div>
  );
}

export function AdminMarketingStudioNav({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("marketing-studio-nav", className)}>
      {children}
    </div>
  );
}

export function AdminMarketingTabs<T extends string>({
  ariaLabel,
  className = "",
  options,
  value,
  onChange,
}: {
  ariaLabel: string;
  className?: string;
  options: Array<{disabled?: boolean; id: T; label: ReactNode}>;
  value: T;
  onChange: (value: T) => void;
}) {
  return (
    <SegmentedControl
      ariaLabel={ariaLabel}
      className={classNames("marketing-tabs", className)}
      options={options}
      value={value}
      onChange={onChange}
    />
  );
}

export function AdminMarketingStudioStack({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("marketing-studio-stack", className)}>
      {children}
    </div>
  );
}

export function AdminMarketingStudioSummary({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLElement> & {
  children: ReactNode;
}) {
  return (
    <section {...props} className={classNames("marketing-studio-summary", className)}>
      {children}
    </section>
  );
}

export function AdminMarketingStudioSummaryItem({
  label,
  value,
}: {
  label: ReactNode;
  value: ReactNode;
}) {
  return (
    <div>
      <span>{label}</span>
      <strong>{value}</strong>
    </div>
  );
}

export function AdminMarketingStudioFilterTabs<T extends string>({
  ariaLabel,
  className = "",
  options,
  value,
  onChange,
}: {
  ariaLabel: string;
  className?: string;
  options: Array<{disabled?: boolean; id: T; label: ReactNode}>;
  value: T;
  onChange: (value: T) => void;
}) {
  return (
    <SegmentedControl
      ariaLabel={ariaLabel}
      className={classNames("marketing-studio-filter-row", className)}
      options={options}
      value={value}
      onChange={onChange}
    />
  );
}

export function AdminMarketingPostBoard({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("marketing-post-board", className)}>
      {children}
    </div>
  );
}

export function AdminMarketingBoardColumn({
  children,
  className = "",
  count,
  title,
  ...props
}: HTMLAttributes<HTMLElement> & {
  children: ReactNode;
  count: ReactNode;
  title: ReactNode;
}) {
  return (
    <section {...props} className={classNames("marketing-board-column", className)}>
      <header>
        <span>{title}</span>
        <strong>{count}</strong>
      </header>
      {children}
    </section>
  );
}

export function AdminMarketingBoardList({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("marketing-board-list", className)}>
      {children}
    </div>
  );
}

export function AdminMarketingPostTypeBadge({
  children,
  className = "",
  draftType,
  ...props
}: HTMLAttributes<HTMLSpanElement> & {
  children: ReactNode;
  draftType: string;
}) {
  return (
    <span {...props} className={classNames("marketing-post-type", draftType, className)}>
      {children}
    </span>
  );
}

export function AdminMarketingComposer({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLElement> & {
  children: ReactNode;
}) {
  return (
    <section {...props} className={classNames("marketing-composer", className)}>
      {children}
    </section>
  );
}

export function AdminMarketingComposerHeader({
  children,
  className = "",
  status,
  ...props
}: HTMLAttributes<HTMLElement> & {
  children: ReactNode;
  status: ReactNode;
}) {
  return (
    <header {...props} className={classNames("marketing-composer-header", className)}>
      <div>{children}</div>
      {status}
    </header>
  );
}

export function AdminMarketingComposerBackButton({
  children,
  className = "",
  ...props
}: {
  children: ReactNode;
  className?: string;
} & ButtonHTMLAttributes<HTMLButtonElement>) {
  return (
    <AdminButton {...props} className={classNames("marketing-composer-back", className)}>
      {children}
    </AdminButton>
  );
}

export function AdminMarketingStepStrip({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("marketing-step-strip", className)}>
      {children}
    </div>
  );
}

export function AdminMarketingStepChip({
  children,
  className = "",
  marker,
  status = "todo",
  ...props
}: {
  children: ReactNode;
  className?: string;
  marker: ReactNode;
  status?: AdminMarketingStepStatus;
} & ButtonHTMLAttributes<HTMLButtonElement>) {
  return (
    <SelectableCardButton
      {...props}
      className={classNames(
        "marketing-step-chip",
        status === "active" && "active",
        status === "done" && "done",
        className
      )}
    >
      <span>{marker}</span>
      <strong>{children}</strong>
    </SelectableCardButton>
  );
}

export function AdminMarketingStepLayout({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("marketing-step-layout", className)}>
      {children}
    </div>
  );
}

export function AdminMarketingComposerFooter({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("marketing-composer-footer", className)}>
      {children}
    </div>
  );
}

export function AdminMarketingPickerList({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("marketing-picker-list", className)}>
      {children}
    </div>
  );
}

export function AdminMarketingPickerRow({
  children,
  className = "",
  marker,
  selected = false,
  status,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
  marker?: ReactNode;
  selected?: boolean;
  status: ReactNode;
}) {
  return (
    <div {...props} className={classNames("marketing-picker-row", selected && "selected", className)}>
      <span>{marker}</span>
      <div>{children}</div>
      <em>{status}</em>
    </div>
  );
}

export function AdminMarketingFeatureShotGrid({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("marketing-feature-shot-grid", className)}>
      {children}
    </div>
  );
}

export function AdminMarketingFeatureShotCard({
  children,
  className = "",
  headline,
  meta,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
  headline: ReactNode;
  meta: ReactNode;
}) {
  return (
    <div {...props} className={classNames("marketing-feature-shot-card", className)}>
      {meta}
      <strong>{headline}</strong>
      {children}
    </div>
  );
}

export function AdminMarketingBrandContract({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("marketing-brand-contract", className)}>
      {children}
    </div>
  );
}

export function AdminMarketingBrandContractItem({
  className = "",
  label,
  value,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  label: ReactNode;
  value: ReactNode;
}) {
  return (
    <div {...props} className={className}>
      <span>{label}</span>
      <strong>{value}</strong>
    </div>
  );
}

export function AdminMarketingHelpText({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLParagraphElement> & {
  children: ReactNode;
}) {
  return (
    <p {...props} className={classNames("marketing-help-text", className)}>
      {children}
    </p>
  );
}

export function AdminMarketingComplianceList({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("marketing-compliance-list", className)}>
      {children}
    </div>
  );
}

export function AdminMarketingEventLibraryGrid({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("marketing-event-library-grid", className)}>
      {children}
    </div>
  );
}

export function AdminMarketingLibraryCard({
  action,
  children,
  className = "",
  description,
  eyebrow,
  title,
  ...props
}: HTMLAttributes<HTMLElement> & {
  action?: ReactNode;
  children?: ReactNode;
  description: ReactNode;
  eyebrow: ReactNode;
  title: ReactNode;
}) {
  return (
    <article {...props} className={classNames("marketing-library-card", className)}>
      <header>
        <AdminEyebrow as="span">{eyebrow}</AdminEyebrow>
        <h3>{title}</h3>
      </header>
      <p>{description}</p>
      {children}
      {action}
    </article>
  );
}

export function AdminMarketingCardLink({
  className = "",
  ...props
}: Parameters<typeof AdminLinkButton>[0]) {
  return (
    <AdminLinkButton
      {...props}
      className={classNames("marketing-card-link", className)}
    />
  );
}

export function AdminMarketingMediaGrid({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("marketing-media-grid", className)}>
      {children}
    </div>
  );
}

export function AdminMarketingMediaCard({
  children,
  className = "",
  description,
  eyebrow,
  previewAlt,
  previewFallback,
  previewSrc,
  title,
  ...props
}: HTMLAttributes<HTMLElement> & {
  children?: ReactNode;
  description: ReactNode;
  eyebrow: ReactNode;
  previewAlt: string;
  previewFallback: ReactNode;
  previewSrc: string | null | undefined;
  title: ReactNode;
}) {
  return (
    <article {...props} className={classNames("marketing-media-card", className)}>
      {previewSrc ? (
        <img alt={previewAlt} loading="lazy" src={previewSrc} />
      ) : (
        previewFallback
      )}
      <div>
        <AdminEyebrow as="span">{eyebrow}</AdminEyebrow>
        <h3>{title}</h3>
        <p>{description}</p>
      </div>
      {children}
    </article>
  );
}

export function AdminMarketingNewPostGrid({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("marketing-new-post-grid", className)}>
      {children}
    </div>
  );
}

export function AdminMarketingNewPostCard({
  accent,
  actionLabel,
  className = "",
  description,
  label,
  meta,
  ...props
}: Omit<ButtonHTMLAttributes<HTMLButtonElement>, "children"> & {
  accent: AdminMarketingNewPostAccent;
  actionLabel: ReactNode;
  description: ReactNode;
  label: ReactNode;
  meta: ReactNode;
}) {
  return (
    <SelectableCardButton
      {...props}
      className={classNames("marketing-new-post-card", accent, className)}
    >
      <span>{meta}</span>
      <strong>{label}</strong>
      <p>{description}</p>
      <small>{actionLabel}</small>
    </SelectableCardButton>
  );
}

export function AdminMarketingGuideLayout({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("marketing-guide-layout", className)}>
      {children}
    </div>
  );
}

export function AdminMarketingDeliverable({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("marketing-deliverable", className)}>
      {children}
    </div>
  );
}

export function AdminMarketingStackedSections({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("marketing-stacked-sections", className)}>
      {children}
    </div>
  );
}

export function AdminMarketingGrid({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("marketing-grid", className)}>
      {children}
    </div>
  );
}

export function AdminMarketingPanel({
  className = "",
  ...props
}: PanelProps) {
  return (
    <AdminPanel
      {...props}
      className={classNames("marketing-panel", className)}
    />
  );
}

export function AdminMarketingTitleInput({
  className = "",
  ...props
}: Parameters<typeof InlineTextField>[0]) {
  return (
    <InlineTextField
      {...props}
      className={classNames("marketing-title-input", className)}
    />
  );
}

export function AdminMarketingSection({
  children,
  className = "",
  meta,
  title,
  ...props
}: Omit<HTMLAttributes<HTMLElement>, "title"> & {
  children: ReactNode;
  meta?: ReactNode;
  title: ReactNode;
}) {
  return (
    <section {...props} className={classNames("marketing-section", className)}>
      <AdminMarketingSectionHeader meta={meta} title={title} />
      {children}
    </section>
  );
}

export function AdminMarketingSectionHeader({
  className = "",
  meta,
  title,
  ...props
}: Omit<HTMLAttributes<HTMLElement>, "title"> & {
  meta?: ReactNode;
  title: ReactNode;
}) {
  return (
    <header {...props} className={classNames("marketing-section-header", className)}>
      <h3>{title}</h3>
      {meta ? <span>{meta}</span> : null}
    </header>
  );
}

export function AdminMarketingEditGrid({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("marketing-edit-grid", className)}>
      {children}
    </div>
  );
}

export function AdminMarketingAppCapturePreview({
  className = "",
  ...props
}: ImgHTMLAttributes<HTMLImageElement>) {
  return (
    <img
      {...props}
      className={classNames("marketing-app-capture-preview", className)}
    />
  );
}

export function AdminMarketingAppMediaPaths({
  className = "",
  sourcePath,
  webPath,
  websitePath,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  sourcePath: ReactNode;
  webPath?: ReactNode;
  websitePath: ReactNode;
}) {
  return (
    <div {...props} className={classNames("marketing-app-media-paths", className)}>
      <div>
        <span>Source</span>
        <code>{sourcePath}</code>
      </div>
      <div>
        <span>Website</span>
        <code>{websitePath}</code>
      </div>
      {webPath ? (
        <div>
          <span>Public path</span>
          <code>{webPath}</code>
        </div>
      ) : null}
    </div>
  );
}

export function AdminCard({
  children,
  className = "",
  span,
  variant = "marketing",
}: {
  children: ReactNode;
  className?: string;
  span?: AdminLayoutSpan;
  variant?: "marketing" | "searchCandidate" | "intake";
}) {
  const baseClass = variant === "searchCandidate" ?
    "search-candidate-card" :
    variant === "intake" ?
    "intake-card" :
    "marketing-card";
  return (
    <article className={classNames(baseClass, layoutSpanClass(span), className)}>
      {children}
    </article>
  );
}

export function AdminCardList({
  children,
  className = "",
}: {
  children: ReactNode;
  className?: string;
}) {
  return <div className={classNames("marketing-card-list", className)}>{children}</div>;
}

export function AdminStatGrid({
  children,
  className = "",
}: {
  children: ReactNode;
  className?: string;
}) {
  return <div className={classNames("marketing-stat-grid", className)}>{children}</div>;
}

export function AdminDiffList({
  children,
  className = "",
}: {
  children: ReactNode;
  className?: string;
}) {
  return <div className={classNames("diff-list", className)}>{children}</div>;
}

export function AdminDiffRow({
  after,
  before,
  field,
}: {
  after: ReactNode;
  before: ReactNode;
  field: ReactNode;
}) {
  return (
    <div className="diff-row">
      <strong>{field}</strong>
      <span>{before}</span>
      <span>{after}</span>
    </div>
  );
}

export function SelectableCardButton({
  children,
  className = "marketing-post-card",
  selected = false,
  type = "button",
  ...props
}: {
  children: ReactNode;
  className?: string;
  selected?: boolean;
} & ButtonHTMLAttributes<HTMLButtonElement>) {
  return (
    <button
      className={`${className} ${selected ? "selected" : ""}`.trim()}
      type={type}
      {...props}
    >
      {children}
    </button>
  );
}

export function CardHeader({
  action,
  children,
  className = "",
  variant = "marketing",
}: {
  action?: ReactNode;
  children: ReactNode;
  className?: string;
  variant?: "marketing" | "searchCandidate" | "intake";
}) {
  const baseClass = variant === "searchCandidate" ?
    "search-candidate-header" :
    variant === "intake" ?
    "intake-card-header" :
    "marketing-card-header";
  return (
    <header className={`${baseClass} ${className}`.trim()}>
      {children}
      {action}
    </header>
  );
}

export function StatusChip({
  children,
  className = "",
  tone = "base",
  ...props
}: {
  children: ReactNode;
  className?: string;
  tone?: ChipTone;
} & HTMLAttributes<HTMLSpanElement>) {
  const toneClass = tone === "base" || tone === "neutral" ?
    "" :
    tone === "warning" ?
    "blocked" :
    tone === "success" ?
    "ready" :
    tone;
  return (
    <span className={`intake-badge ${toneClass} ${className}`.trim()} {...props}>
      {children}
    </span>
  );
}

export function AdminTag({
  children,
  className = "",
  href,
  rel,
  target,
  tone = "neutral",
}: {
  children: ReactNode;
  className?: string;
  href?: string;
  rel?: string;
  target?: string;
  tone?: TagTone;
}) {
  const toneClass = tone === "base" || tone === "neutral" ?
    "" :
    tone === "warning" || tone === "danger" ?
    "blocked" :
    tone === "success" ?
    "ready" :
    tone;
  const classes = [
    "intake-tag",
    toneClass,
    className,
  ].filter(Boolean).join(" ");
  if (href) {
    return (
      <a className={classes} href={href} rel={rel} target={target}>
        {children}
      </a>
    );
  }
  return <span className={classes}>{children}</span>;
}

export function AdminTagList({
  children,
  className = "",
}: {
  children: ReactNode;
  className?: string;
}) {
  return (
    <div className={classNames("intake-tags", className)}>
      {children}
    </div>
  );
}

export function AdminRowTitle({
  children,
  className = "",
  compact = false,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
  compact?: boolean;
}) {
  return (
    <div {...props} className={classNames("row-title", compact && "compact", className)}>
      {children}
    </div>
  );
}

export function AdminTagRow({
  as = "div",
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLElement> & {
  as?: AdminTagRowElement;
  children: ReactNode;
}) {
  if (as === "span") {
    return (
      <span {...props} className={classNames("tag-row", className)}>
        {children}
      </span>
    );
  }

  return (
    <div {...props} className={classNames("tag-row", className)}>
      {children}
    </div>
  );
}

export function AdminRoadmapList({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("roadmap-list", className)}>
      {children}
    </div>
  );
}

export function AdminRoadmapListItem({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("roadmap-list-item", className)}>
      {children}
    </div>
  );
}

export function AdminIntakeSection({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("intake-section", className)}>
      {children}
    </div>
  );
}

export function AdminOrganizerIntakeCurationPanel({
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <AdminIntakeSection
      {...props}
      className={classNames("curation-panel", className)}
    />
  );
}

export function AdminIntakeSectionTitle({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("intake-section-title", className)}>
      {children}
    </div>
  );
}

export function AdminIntakeStateGrid({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("intake-state-grid", className)}>
      {children}
    </div>
  );
}

export function AdminOrganizerIntakeList({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("intake-list", className)}>
      {children}
    </div>
  );
}

export function AdminOrganizerIntakeCard({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLElement> & {
  children: ReactNode;
}) {
  return (
    <article {...props} className={classNames("intake-card", className)}>
      {children}
    </article>
  );
}

export function AdminOrganizerIntakeCardHeader({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLElement> & {
  children: ReactNode;
}) {
  return (
    <header {...props} className={classNames("intake-card-header", className)}>
      {children}
    </header>
  );
}

export function AdminOrganizerIntakeBadges({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("intake-badges", className)}>
      {children}
    </div>
  );
}

export function AdminOrganizerPolicyGapColumns({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("policy-gap-columns", className)}>
      {children}
    </div>
  );
}

export function AdminOrganizerLocationResolutionForm({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("location-resolution-form", className)}>
      {children}
    </div>
  );
}

export function AdminOrganizerIntakeSurfaceGrid({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("intake-surface-grid", className)}>
      {children}
    </div>
  );
}

export function AdminOrganizerSurfaceList({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("surface-list", className)}>
      {children}
    </div>
  );
}

export function AdminOrganizerSurfaceRow({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("surface-row", className)}>
      {children}
    </div>
  );
}

export function AdminOrganizerCurationControlSection({
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <AdminIntakeSection
      {...props}
      className={classNames("curation-control", className)}
    />
  );
}

export function AdminOrganizerCurationControlGrid({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("curation-control-grid", className)}>
      {children}
    </div>
  );
}

export function AdminIntakeDecisionState({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("intake-decision-state", className)}>
      {children}
    </div>
  );
}

export function AdminIntakeDecisionBox({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("intake-decision-box", className)}>
      {children}
    </div>
  );
}

export function AdminIntakeDecisionActions({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("intake-decision-actions", className)}>
      {children}
    </div>
  );
}

export function AdminDecisionFooterShell({
  children,
  className = "",
  compact = false,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
  compact?: boolean;
}) {
  return (
    <div
      {...props}
      className={classNames("marketing-decision-footer", compact && "compact", className)}
    >
      {children}
    </div>
  );
}

export function AdminSearchCandidatePanel({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("search-candidate-panel", className)}>
      {children}
    </div>
  );
}

export function AdminSearchCandidateList({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("search-candidate-list", className)}>
      {children}
    </div>
  );
}

export function AdminSearchCandidateCard({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLElement> & {
  children: ReactNode;
}) {
  return (
    <article {...props} className={classNames("search-candidate-card", className)}>
      {children}
    </article>
  );
}

export function AdminSearchCandidateHeader({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLElement> & {
  children: ReactNode;
}) {
  return (
    <header {...props} className={classNames("search-candidate-header", className)}>
      {children}
    </header>
  );
}

export function AdminSearchCandidateSnippet({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLParagraphElement> & {
  children: ReactNode;
}) {
  return (
    <p {...props} className={classNames("search-candidate-snippet", className)}>
      {children}
    </p>
  );
}

export function AdminSearchCandidateActions({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("search-candidate-actions", className)}>
      {children}
    </div>
  );
}

export function TagList({
  children,
  className = "",
}: {
  children: ReactNode;
  className?: string;
}) {
  return (
    <div className={`marketing-tag-row ${className}`.trim()}>
      {children}
    </div>
  );
}

export function AdminQueryList({
  children,
  className = "",
}: {
  children: ReactNode;
  className?: string;
}) {
  return (
    <div className={classNames("marketing-query-list", className)}>
      {children}
    </div>
  );
}

export function AdminQueryRow({
  children,
  className = "",
}: {
  children: ReactNode;
  className?: string;
}) {
  return (
    <div className={classNames("marketing-query", className)}>
      {children}
    </div>
  );
}

export function AdminMarketingSlideList({
  children,
  className = "",
  single = false,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
  single?: boolean;
}) {
  return (
    <div
      {...props}
      className={classNames("marketing-slide-list", single && "single", className)}
    >
      {children}
    </div>
  );
}

export function AdminMarketingSlideEditor({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("marketing-slide-editor", className)}>
      {children}
    </div>
  );
}

export function AdminMarketingSlideEditorTopline({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("marketing-slide-editor-topline", className)}>
      {children}
    </div>
  );
}

export function AdminMarketingRecommendationList({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("marketing-recommendation-list", className)}>
      {children}
    </div>
  );
}

export function AdminMarketingRecommendationItem({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("marketing-recommendation-item", className)}>
      {children}
    </div>
  );
}

export function AdminMarketingAuditList({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("marketing-audit-list", className)}>
      {children}
    </div>
  );
}

export function AdminMarketingAuditRow({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("marketing-audit-row", className)}>
      {children}
    </div>
  );
}

export function AdminFeatureDropFeatureList({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("feature-drop-feature-list", className)}>
      {children}
    </div>
  );
}

export function AdminFeatureDropFeatureEditor({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("feature-drop-feature-editor", className)}>
      {children}
    </div>
  );
}

export function AdminFeatureDropControlGrid({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("feature-drop-control-grid", className)}>
      {children}
    </div>
  );
}

export function AdminFeatureDropWideField({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("feature-drop-span-2", className)}>
      {children}
    </div>
  );
}

export function AdminFeatureDropPreviewGrid({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("feature-drop-preview-grid", className)}>
      {children}
    </div>
  );
}

export function AdminFeatureDropPreviewCard({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLElement> & {
  children: ReactNode;
}) {
  return (
    <figure {...props} className={classNames("feature-drop-preview-card", className)}>
      {children}
    </figure>
  );
}

export function AdminMarketingPreviewShell({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("marketing-preview-shell", className)}>
      {children}
    </div>
  );
}

export function AdminMarketingPreviewToolbar({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("marketing-preview-toolbar", className)}>
      {children}
    </div>
  );
}

export function AdminMarketingPreviewActions({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("marketing-preview-actions", className)}>
      {children}
    </div>
  );
}

export function AdminMarketingCarouselPreview({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("marketing-carousel-preview", className)}>
      {children}
    </div>
  );
}

export function AdminMarketingPreviewSlide({
  children,
  className = "",
  hasImage = false,
  ...props
}: HTMLAttributes<HTMLElement> & {
  children: ReactNode;
  hasImage?: boolean;
}) {
  return (
    <article
      {...props}
      className={classNames("marketing-preview-slide", hasImage && "has-image", className)}
    >
      {children}
    </article>
  );
}

export function AdminMarketingPreviewMeta({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("marketing-preview-meta", className)}>
      {children}
    </div>
  );
}

export function AdminMarketingPreviewImage({
  className = "",
  ...props
}: ImgHTMLAttributes<HTMLImageElement>) {
  return (
    <img {...props} className={classNames("marketing-preview-image", className)} />
  );
}

export function AdminMarketingPreviewBrandNote({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("marketing-preview-brand-note", className)}>
      {children}
    </div>
  );
}

export function AdminMarketingPreviewCopy({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("marketing-preview-copy", className)}>
      {children}
    </div>
  );
}

export function AdminMarketingExportStatus({
  children,
  className = "",
  tone,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
  tone?: "error";
}) {
  return (
    <div
      {...props}
      className={classNames("marketing-export-status", tone === "error" && "error", className)}
    >
      {children}
    </div>
  );
}

export function AdminMarketingImageEditor({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("marketing-image-editor", className)}>
      {children}
    </div>
  );
}

export function AdminMarketingImageEditorHeader({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("marketing-image-editor-header", className)}>
      {children}
    </div>
  );
}

export function AdminMarketingImageControls({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("marketing-image-controls", className)}>
      {children}
    </div>
  );
}

export function AdminMarketingFilePickerButton({
  className = "",
  ...props
}: {
  children: ReactNode;
  className?: string;
  icon?: ReactNode;
  inputLabel: string;
} & Omit<InputHTMLAttributes<HTMLInputElement>, "aria-label" | "type">) {
  return (
    <FilePickerButton
      {...props}
      className={classNames("marketing-file-button", className)}
    />
  );
}

export function AdminMarketingImageReviewRow({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("marketing-image-review-row", className)}>
      {children}
    </div>
  );
}

export function AdminMarketingImageThumb({
  className = "",
  ...props
}: ImgHTMLAttributes<HTMLImageElement>) {
  return (
    <img {...props} className={classNames("marketing-image-thumb", className)} />
  );
}

export function AdminFeatureDropCaptureThumb({
  className = "",
  ...props
}: ImgHTMLAttributes<HTMLImageElement>) {
  return (
    <img {...props} className={classNames("feature-drop-capture-thumb", className)} />
  );
}

export function AdminMarketingImageMetaFields({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("marketing-image-meta-fields", className)}>
      {children}
    </div>
  );
}

export function AdminMarketingImageSourceNote({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("marketing-image-source-note", className)}>
      {children}
    </div>
  );
}

export function AdminMarketingImageEmpty({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("marketing-image-empty", className)}>
      {children}
    </div>
  );
}

export function AdminGuardrailList({
  children,
  className = "",
}: {
  children: ReactNode;
  className?: string;
}) {
  return (
    <div className={classNames("guardrail-list", className)}>
      {children}
    </div>
  );
}

export function AdminIntakeSourceList({
  children,
  className = "",
}: {
  children: ReactNode;
  className?: string;
}) {
  return (
    <div className={classNames("intake-source-list", className)}>
      {children}
    </div>
  );
}

export function AdminIntakeGateList({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("intake-gate-list", className)}>
      {children}
    </div>
  );
}

export function AdminIntakeGate({
  children,
  className = "",
  tone,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
  tone?: AdminIntakeGateTone;
}) {
  return (
    <div {...props} className={classNames("intake-gate", tone, className)}>
      {children}
    </div>
  );
}

export function AlertRow({
  children,
  className = "",
  icon,
  title,
  tone = "neutral",
}: {
  children: ReactNode;
  className?: string;
  icon?: ReactNode;
  title?: ReactNode;
  tone?: AlertTone;
}) {
  return (
    <QualityRow className={className} icon={icon} tone={tone}>
      {title ? <strong>{title}</strong> : null}
      <span>{children}</span>
    </QualityRow>
  );
}

export function QualityRow({
  children,
  className = "",
  icon,
  tone = "base",
  ...props
}: {
  children: ReactNode;
  className?: string;
  icon?: ReactNode;
  tone?: QualityRowTone;
} & HTMLAttributes<HTMLDivElement>) {
  const toneClass = tone === "base" || tone === "neutral" ? "" : tone;
  return (
    <div className={classNames("quality-row", toneClass, className)} {...props}>
      {icon}
      <div>
        {children}
      </div>
    </div>
  );
}

export function QualityList({
  children,
  className = "",
  ...props
}: {
  children: ReactNode;
  className?: string;
} & HTMLAttributes<HTMLDivElement>) {
  return (
    <div className={classNames("quality-list", className)} {...props}>
      {children}
    </div>
  );
}

export function DataTable({
  children,
  className = "",
  compact = false,
  variant = "default",
  ...props
}: {
  children: ReactNode;
  className?: string;
  compact?: boolean;
  variant?: DataTableVariant;
} & HTMLAttributes<HTMLDivElement>) {
  return (
    <div
      {...props}
      className={classNames(
        "table-wrap",
        variant === "workbench" && "workbench-table",
        compact && "compact",
        className
      )}
    >
      <table>{children}</table>
    </div>
  );
}

export function AdminTableRow({
  children,
  className = "",
  selected = false,
  ...props
}: HTMLAttributes<HTMLTableRowElement> & {
  children: ReactNode;
  selected?: boolean;
}) {
  return (
    <tr {...props} className={classNames(selected && "selected-row", className)}>
      {children}
    </tr>
  );
}

export function AdminForm({
  children,
  className = "",
  variant = "default",
  ...props
}: {
  children: ReactNode;
  className?: string;
  variant?: AdminFormVariant;
} & FormHTMLAttributes<HTMLFormElement>) {
  return (
    <form
      {...props}
      className={classNames(variant === "publishing" && "publishing-form", className)}
    >
      {children}
    </form>
  );
}

export function AdminPublishingFormShell({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("publishing-form", className)}>
      {children}
    </div>
  );
}

export function AdminEditorSection({
  children,
  className = "",
  ...props
}: FieldsetHTMLAttributes<HTMLFieldSetElement> & {
  children: ReactNode;
}) {
  return (
    <fieldset {...props} className={classNames("editor-section", className)}>
      {children}
    </fieldset>
  );
}

export function AdminFieldGrid({
  children,
  className = "",
  columns = 2,
}: {
  children: ReactNode;
  className?: string;
  columns?: 2 | 3;
}) {
  return (
    <div className={classNames("form-grid", columns === 2 ? "two" : "three", className)}>
      {children}
    </div>
  );
}

export function TableActionButton({
  children,
  className = "",
  type = "button",
  ...props
}: {
  children: ReactNode;
  className?: string;
} & ButtonHTMLAttributes<HTMLButtonElement>) {
  return (
    <button
      className={`table-action ${className}`.trim()}
      type={type}
      {...props}
    >
      {children}
    </button>
  );
}

export function RiskBadge({
  children,
  tone,
}: {
  children: ReactNode;
  tone: RiskTone;
}) {
  return <span className={`risk ${tone}`}>{children}</span>;
}

export function AdminPanel({
  action,
  children,
  className = "",
  icon,
  span,
  title,
}: PanelProps) {
  return (
    <article className={classNames("panel", layoutSpanClass(span), className)}>
      <header className="panel-header">
        <div className="panel-title">
          {icon}
          <h2>{title}</h2>
        </div>
        {action ? <span>{action}</span> : null}
      </header>
      {children}
    </article>
  );
}

export function Panel({
  action,
  children,
  className = "",
  icon,
  span,
  title,
}: PanelProps) {
  return (
    <section className={classNames("panel", layoutSpanClass(span), className)}>
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

export function AdminIntakePublicationBoundaryPanel({
  activeWorkspace,
}: {
  activeWorkspace: "events" | "organizers";
}) {
  const isEvents = activeWorkspace === "events";
  return (
    <Panel
      span={2}
      icon={<Lock size={18} strokeWidth={1.9} />}
      title="Intake publication boundary"
      action={isEvents ? "event review only" : "organizer review only"}
    >
      <AlertRow
        icon={<Lock size={16} strokeWidth={1.9} />}
        title={isEvents ? "Event candidates are not app events" : "Organizer approvals are not final publication"}
      >
        {isEvents ?
          "Event Intake reads eventIntakeDashboards/current and writes eventIntakeReviewDecisions. Canonical event creation, external event promotion, booking, payments, and waitlists stay outside this workspace." :
          "Organizer Intake records review, curation, policy, and location decisions. Canonical organizer publishing, public route indexing, and claim ownership still pass through promotion tooling and the Organizers workspace."}
      </AlertRow>
      <QualityList>
        <StateRow
          label="Read model"
          value={isEvents ?
            "eventIntakeDashboards/current plus generated sample bridge" :
            "repo-owned organizer intake bridge JSON"}
        />
        <StateRow
          label="Writes here"
          value={isEvents ?
            "eventIntakeReviewDecisions/{decisionId}" :
            "organizer review, curation, policy, and location decision records"}
        />
        {isEvents ? (
          <StateRow
            label="Callable boundary"
            value="adminGetEventIntakeDashboard + adminRecordEventIntakeReviewDecision"
          />
        ) : null}
        <StateRow
          label="Not here"
          value={isEvents ?
            "events/{id}, externalEvents/{id}, bookings, payments, waitlists" :
            "unchecked canonical clubs/{id} publication, route indexing, claim ownership transfer"}
        />
      </QualityList>
      <AdminTagList>
        {(isEvents ? [
          "source evidence",
          "dedupe",
          "location",
          "policy",
          "review note",
        ] : [
          "evidence",
          "surface curation",
          "policy gaps",
          "publication packet",
          "claim handoff",
        ]).map((label) => (
          <AdminTag key={label}>{label}</AdminTag>
        ))}
      </AdminTagList>
    </Panel>
  );
}

export function AdminEditorPanel({
  className = "",
  ...props
}: PanelProps) {
  return (
    <Panel
      {...props}
      className={classNames("publishing-editor-panel", className)}
    />
  );
}

export function AdminStateRow({
  label,
  value,
}: {
  label: string;
  value: ReactNode;
}) {
  return (
    <div className="state-row">
      <span>{label}</span>
      <strong>{value}</strong>
    </div>
  );
}

export function StateRow({
  label,
  value,
}: {
  label: string;
  value: ReactNode | null;
}) {
  return (
    <div className="state-row">
      <span>{label}</span>
      <strong>{value ?? "none"}</strong>
    </div>
  );
}

export function AdminTextField({
  className = "marketing-field",
  label,
  value,
  onChange,
  ...props
}: {
  className?: string;
  label: string;
  value: string;
  onChange: (value: string) => void;
} & Omit<InputHTMLAttributes<HTMLInputElement>, "className" | "onChange" | "value">) {
  return (
    <label className={className}>
      <span>{label}</span>
      <input
        value={value}
        onChange={(event) => onChange(event.target.value)}
        {...props}
      />
    </label>
  );
}

export function TextField({
  className = "field-control",
  label,
  onChange,
  span,
  value,
  ...props
}: {
  className?: string;
  label: string;
  onChange: (value: string) => void;
  span?: AdminLayoutSpan;
  value: string;
} & Omit<InputHTMLAttributes<HTMLInputElement>, "className" | "onChange" | "value">) {
  return (
    <label className={classNames(className, layoutSpanClass(span))}>
      <span>{label}</span>
      <input
        onChange={(event) => onChange(event.target.value)}
        value={value}
        {...props}
      />
    </label>
  );
}

export function CheckboxField({
  checked,
  className = "check-row",
  label,
  onChange,
  ...props
}: {
  checked: boolean;
  className?: string;
  label: ReactNode;
  onChange: (checked: boolean) => void;
} & Omit<InputHTMLAttributes<HTMLInputElement>, "checked" | "className" | "onChange" | "type">) {
  return (
    <label className={className}>
      <input
        checked={checked}
        onChange={(event) => onChange(event.currentTarget.checked)}
        type="checkbox"
        {...props}
      />
      <span>{label}</span>
    </label>
  );
}

export function AdminOrganizerIntakeCheckboxField({
  className = "",
  ...props
}: Parameters<typeof CheckboxField>[0]) {
  return (
    <CheckboxField
      {...props}
      className={classNames("intake-checkbox-row", className)}
    />
  );
}

export function AdminTextareaField({
  className = "marketing-field",
  label,
  rows,
  value,
  onChange,
  ...props
}: {
  className?: string;
  label: string;
  rows: number;
  value: string;
  onChange: (value: string) => void;
} & Omit<TextareaHTMLAttributes<HTMLTextAreaElement>, "className" | "onChange" | "rows" | "value">) {
  return (
    <label className={className}>
      <span>{label}</span>
      <textarea
        rows={rows}
        value={value}
        onChange={(event) => onChange(event.target.value)}
        {...props}
      />
    </label>
  );
}

export function DecisionFooter<TTargetType extends string = string>({
  approvalDisabledReason,
  compact = false,
  defaultNote,
  edits,
  inFlight,
  localDecision,
  note,
  showExportReady = false,
  targetId,
  targetType,
  onDecision,
  onNoteChange,
}: {
  approvalDisabledReason?: string;
  compact?: boolean;
  defaultNote: string;
  edits: Record<string, unknown>;
  inFlight?: boolean;
  localDecision?: ReviewDecisionResponse;
  note: string;
  showExportReady?: boolean;
  targetId: string;
  targetType: TTargetType;
  onDecision: (
    input: Omit<Parameters<ReviewDecisionHandler>[0], "targetType"> & {
      targetType: TTargetType;
    }
  ) => Promise<void>;
  onNoteChange: (value: string) => void;
}) {
  const approveDisabled = Boolean(inFlight || approvalDisabledReason);
  return (
    <AdminDecisionFooterShell compact={compact}>
      {localDecision ? (
        <AdminIntakeDecisionState>
          <CheckCircle2 size={16} strokeWidth={1.9} />
          <div>
            <strong>{localDecision.decisionStatus.replaceAll("_", " ")}</strong>
            <span>{localDecision.decisionPath}</span>
          </div>
        </AdminIntakeDecisionState>
      ) : (
        <>
          <AdminTextareaField
            label="Review note"
            rows={compact ? 2 : 3}
            value={note}
            onChange={onNoteChange}
          />
          <AdminIntakeDecisionActions>
            <AdminButton
              disabled={approveDisabled}
              onClick={() => onDecision({
                targetType,
                targetId,
                decision: "approve",
                edits,
                defaultNote,
              })}
              variant="primary"
            >
              {inFlight ? "Saving" : "Approve"}
            </AdminButton>
            <AdminButton
              disabled={inFlight}
              onClick={() => onDecision({
                targetType,
                targetId,
                decision: "needs_changes",
                edits,
                defaultNote,
              })}
            >
              Needs changes
            </AdminButton>
            <AdminButton
              disabled={inFlight}
              onClick={() => onDecision({
                targetType,
                targetId,
                decision: "hold",
                edits,
                defaultNote,
              })}
            >
              Hold
            </AdminButton>
            <AdminButton
              disabled={inFlight}
              onClick={() => onDecision({
                targetType,
                targetId,
                decision: "reject",
                edits,
                defaultNote,
              })}
            >
              Reject
            </AdminButton>
            {showExportReady ? (
              <AdminButton
                disabled={approveDisabled}
                onClick={() => onDecision({
                  targetType,
                  targetId,
                  decision: "export_ready",
                  edits,
                  defaultNote,
                })}
              >
                Export ready
              </AdminButton>
            ) : null}
          </AdminIntakeDecisionActions>
          {approvalDisabledReason ? (
            <AlertRow
              icon={<FileWarning size={16} strokeWidth={1.9} />}
              title="Approval blocked"
              tone="warning"
            >
              {approvalDisabledReason}
            </AlertRow>
          ) : null}
        </>
      )}
    </AdminDecisionFooterShell>
  );
}

export function TextareaField({
  className = "field-control",
  label,
  onChange,
  rows,
  span,
  value,
  ...props
}: {
  className?: string;
  label: string;
  onChange: (value: string) => void;
  rows: number;
  span?: AdminLayoutSpan;
  value: string;
} & Omit<TextareaHTMLAttributes<HTMLTextAreaElement>, "className" | "onChange" | "rows" | "value">) {
  return (
    <label className={classNames(className, layoutSpanClass(span))}>
      <span>{label}</span>
      <textarea
        onChange={(event) => onChange(event.target.value)}
        rows={rows}
        value={value}
        {...props}
      />
    </label>
  );
}

type SelectFieldProps = {
  className?: string;
  label: string;
  onChange: (value: string) => void;
  options: SelectOption[];
  value: string;
} & Omit<SelectHTMLAttributes<HTMLSelectElement>, "className" | "onChange" | "value">;

export function AdminMarketingSelectField({
  className = "marketing-field",
  ...props
}: SelectFieldProps) {
  return <SelectField {...props} className={className} />;
}

export function SelectField({
  className = "field-control",
  label,
  onChange,
  options,
  value,
  ...props
}: SelectFieldProps) {
  return (
    <label className={className}>
      <span>{label}</span>
      <select
        onChange={(event) => onChange(event.target.value)}
        value={value}
        {...props}
      >
        {options.map((option) => {
          const value = typeof option === "string" ? option : option.value;
          const label = typeof option === "string" ? option : option.label;
          return <option key={value} value={value}>{label}</option>;
        })}
      </select>
    </label>
  );
}
