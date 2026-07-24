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
import {DataTableControl} from "@catch/web-ui";
import {CheckCircle2, FileWarning, Lock, RefreshCw} from "lucide-react";

import {
  classNames,
  layoutSpanClass,
  type SelectOption,
  type ChipTone,
  type AlertTone,
  type TagTone,
  type MetricTone,
  type MetricVariant,
  type QualityRowTone,
  type AdminOverviewQueueIntent,
  type AdminOverviewSignalTone,
  type RiskTone,
  type DataTableVariant,
  type AdminFormVariant,
  type AdminEditorGridElement,
  type AdminTagRowElement,
  type EmptyStateVariant,
  type AdminLayoutSpan,
  type AdminEyebrowElement,
  type AdminIntakeGateTone,
  type AdminBrandMarkSize,
  type AdminMarketingStepStatus,
  type AdminMarketingNewPostAccent,
  type ReviewDecision,
  type ReviewDecisionHandler,
  type ReviewDecisionResponse,
  type PageHeaderProps,
  type PanelProps,
} from "./shared";

import {AdminTag, AdminTagList} from "./cards";
import {StateRow} from "./forms";

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
  ariaLabel,
  children,
  className = "",
  compact = false,
  variant = "default",
  ...props
}: {
  ariaLabel: string;
  children: ReactNode;
  className?: string;
  compact?: boolean;
  variant?: DataTableVariant;
} & HTMLAttributes<HTMLDivElement>) {
  return (
    <DataTableControl
      {...props}
      ariaLabel={ariaLabel}
      className={classNames(
        "table-wrap",
        variant === "workbench" && "workbench-table",
        compact && "compact",
        className
      )}
    >
      {children}
    </DataTableControl>
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
            "eventIntakeDashboards/current plus generated local-preview bridge" :
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
            "unchecked canonical organizers/{id} publication, route indexing, claim ownership transfer"}
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
