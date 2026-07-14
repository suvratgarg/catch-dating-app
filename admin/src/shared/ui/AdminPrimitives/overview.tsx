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
import {CheckCircle2, FileWarning, Lock, RefreshCw} from "lucide-react";
import {ButtonControl} from "@catch/web-ui";

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
  type AdminSignalTone,
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

import {AdminTag} from "./cards";
import {AdminEyebrow} from "./shell";
import {EmptyState} from "./workbench";

export function AdminButton({
  children,
  className = "",
  icon,
  loading = false,
  loadingLabel,
  selected = false,
  type = "button",
  variant = "ghost",
  ...props
}: {
  children: ReactNode;
  className?: string;
  icon?: ReactNode;
  loading?: boolean;
  loadingLabel?: ReactNode;
  selected?: boolean;
  variant?: "ghost" | "primary";
} & ButtonHTMLAttributes<HTMLButtonElement>) {
  const classes = [
    variant === "primary" ? "primary-button" : "ghost-button",
    selected ? "selected" : "",
    className,
  ].filter(Boolean).join(" ");
  return (
    <ButtonControl className={classes} loading={loading} type={type} {...props}>
      {icon}
      {loading ? loadingLabel ?? children : children}
    </ButtonControl>
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
  owner,
  title,
  className = "",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  count: ReactNode;
  owner?: ReactNode;
  title: ReactNode;
}) {
  return (
    <div {...props} className={classNames("queue-heading", className)}>
      <span className="queue-heading-copy">
        <span>{title}</span>
        {owner ? <small>owned by {owner}</small> : null}
      </span>
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
  ariaLabel = "Trend chart",
  emptyLabel,
  points,
}: {
  ariaLabel?: string;
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
    const y = 100 - Math.max(0, Math.min(100, point.value));
    return `${index === 0 ? "M" : "L"} ${x.toFixed(2)} ${y.toFixed(2)}`;
  }).join(" ");
  return (
    <figure aria-label={ariaLabel} className="line-chart">
      <svg viewBox="0 0 100 100" preserveAspectRatio="none" aria-hidden="true">
        <path className="line-area" d={`${path} L 100 100 L 0 100 Z`} />
        <path className="line-stroke" d={path} />
      </svg>
      <figcaption className="chart-labels">
        {points.map((point) => (
          <span key={point.label}>
            <span>{point.label}</span>
            <strong>{point.value}</strong>
          </span>
        ))}
      </figcaption>
    </figure>
  );
}

export function AdminOverviewBarChart({
  ariaLabel = "Category chart",
  emptyLabel,
  points,
}: {
  ariaLabel?: string;
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
    <figure aria-label={ariaLabel} className="bar-chart">
      {points.map((point) => (
        <div className="bar-column" key={point.label}>
          <div
            aria-hidden="true"
            className="bar"
            style={{height: point.value <= 0 ? "0%" : `${(point.value / max) * 100}%`}}
          />
          <span>
            <span>{point.label}</span>
            <strong>{point.value}</strong>
          </span>
        </div>
      ))}
    </figure>
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
    <AdminSignalBars
      ariaLabel="User value signals"
      maxValue={100}
      signals={signals}
    />
  );
}

export function AdminSignalBars({
  ariaLabel,
  eyebrow,
  maxValue,
  signals,
}: {
  ariaLabel: string;
  eyebrow?: ReactNode;
  maxValue?: number;
  signals: Array<{
    label: string;
    tone: AdminSignalTone;
    value: number;
  }>;
}) {
  const scale = Math.max(
    1,
    maxValue ?? Math.max(0, ...signals.map((signal) => signal.value))
  );
  return (
    <div aria-label={ariaLabel} className="signals" role="list">
      {eyebrow ? <AdminEyebrow>{eyebrow}</AdminEyebrow> : null}
      {signals.map((signal) => {
        const width = Math.max(
          0,
          Math.min(100, (signal.value / scale) * 100)
        );
        return (
          <div className="signal-row" key={signal.label} role="listitem">
            <div>
              <span>{signal.label}</span>
              <strong>{signal.value}</strong>
            </div>
            <div aria-hidden="true" className="signal-track">
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
