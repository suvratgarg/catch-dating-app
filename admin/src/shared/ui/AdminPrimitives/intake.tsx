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
  sticky = false,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
  compact?: boolean;
  sticky?: boolean;
}) {
  return (
    <div
      {...props}
      className={classNames(
        "marketing-decision-footer",
        "admin-decision-footer",
        compact && "compact",
        sticky && "sticky",
        className
      )}
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

export type AdminIntakeWorkbenchTone =
  | "neutral"
  | "warning"
  | "danger"
  | "success";

export interface AdminIntakeStageOption<TStage extends string> {
  id: TStage;
  label: ReactNode;
  meta: ReactNode;
}

export function AdminIntakeTaskToolbar({
  children,
  className = "",
  ...props
}: HTMLAttributes<HTMLElement> & {
  children: ReactNode;
}) {
  return (
    <section
      {...props}
      className={classNames("intake-task-toolbar", className)}
    >
      {children}
    </section>
  );
}

export function AdminIntakeStageRail<TStage extends string>({
  ariaLabel,
  className = "",
  options,
  value,
  onChange,
}: {
  ariaLabel: string;
  className?: string;
  options: Array<AdminIntakeStageOption<TStage>>;
  value: TStage;
  onChange: (value: TStage) => void;
}) {
  return (
    <nav
      aria-label={ariaLabel}
      className={classNames("intake-stage-rail", className)}
    >
      {options.map((option, index) => {
        const selected = option.id === value;
        return (
          <button
            aria-current={selected ? "step" : undefined}
            className={selected ? "selected" : ""}
            key={option.id}
            onClick={() => onChange(option.id)}
            type="button"
          >
            <span>{index + 1}</span>
            <strong>{option.label}</strong>
            <small>{option.meta}</small>
          </button>
        );
      })}
    </nav>
  );
}

export function AdminIntakeBoundaryNotice({
  actionLabel,
  children,
  className = "",
  title,
  onAction,
}: {
  actionLabel?: ReactNode;
  children: ReactNode;
  className?: string;
  title: ReactNode;
  onAction?: () => void;
}) {
  return (
    <section className={classNames("intake-boundary-notice", className)}>
      <div>
        <strong>{title}</strong>
        <span>{children}</span>
      </div>
      {actionLabel && onAction ? (
        <button onClick={onAction} type="button">{actionLabel}</button>
      ) : null}
    </section>
  );
}

export interface AdminIntakeQueueItem {
  description: ReactNode;
  id: string;
  initials: ReactNode;
  meta: ReactNode;
  status: ReactNode;
  statusTone?: AdminIntakeWorkbenchTone;
  title: ReactNode;
}

export interface AdminIntakeQueueFilter {
  id: string;
  label: ReactNode;
  selected: boolean;
}

export interface AdminIntakeEvidenceRow {
  href?: string | null;
  id: string;
  meta: ReactNode;
  status: ReactNode;
  statusTone?: AdminIntakeWorkbenchTone;
  title: ReactNode;
}

export interface AdminIntakeImpactRow {
  id: string;
  label: ReactNode;
  tone?: AdminIntakeWorkbenchTone;
  value: ReactNode;
}

export interface AdminIntakeChecklistRow {
  id: string;
  label: ReactNode;
  meta: ReactNode;
  passed: boolean;
}

export interface AdminIntakeWorkbenchDetail {
  action?: ReactNode;
  checklistRows: AdminIntakeChecklistRow[];
  checklistTitle: ReactNode;
  footerActions: ReactNode;
  footerHint: ReactNode;
  impactRows: AdminIntakeImpactRow[];
  impactTitle: ReactNode;
  initials: ReactNode;
  note: ReactNode;
  noteTitle: ReactNode;
  primaryRows: AdminIntakeEvidenceRow[];
  primaryTitle: ReactNode;
  readiness: {
    blockers: number;
    complete: number;
    label: ReactNode;
    total: number;
  };
  status: ReactNode;
  statusTone?: AdminIntakeWorkbenchTone;
  subtitle: ReactNode;
  title: ReactNode;
}

export function AdminIntakeReviewWorkbench({
  className = "",
  detail,
  emptyDetail,
  emptyQueue,
  filters = [],
  items,
  queueMeta,
  queueTitle,
  selectedId,
  onFilterChange,
  onSelect,
}: {
  className?: string;
  detail?: AdminIntakeWorkbenchDetail | null;
  emptyDetail?: ReactNode;
  emptyQueue?: ReactNode;
  filters?: AdminIntakeQueueFilter[];
  items: AdminIntakeQueueItem[];
  queueMeta: ReactNode;
  queueTitle: ReactNode;
  selectedId?: string | null;
  onFilterChange?: (filterId: string) => void;
  onSelect: (itemId: string) => void;
}) {
  const readinessTotal = Math.max(detail?.readiness.total ?? 0, 1);
  const readinessPercent = Math.min(
    100,
    Math.round(((detail?.readiness.complete ?? 0) / readinessTotal) * 100)
  );
  return (
    <section className={classNames("intake-review-workbench", className)}>
      <section className="intake-review-queue">
        <header>
          <div>
            <h3>{queueTitle}</h3>
            <span>{queueMeta}</span>
          </div>
          {filters.length > 0 ? (
            <div className="intake-review-filters">
              {filters.map((filter) => (
                <button
                  aria-pressed={filter.selected}
                  className={filter.selected ? "selected" : ""}
                  key={filter.id}
                  onClick={() => onFilterChange?.(filter.id)}
                  type="button"
                >
                  {filter.label}
                </button>
              ))}
            </div>
          ) : null}
        </header>
        <div className="intake-review-queue-items">
          {items.length === 0 ? (
            <div className="intake-review-empty">{emptyQueue}</div>
          ) : items.map((item) => (
            <button
              aria-pressed={item.id === selectedId}
              className={item.id === selectedId ? "selected" : ""}
              key={item.id}
              onClick={() => onSelect(item.id)}
              type="button"
            >
              <span className="intake-review-mark">{item.initials}</span>
              <span className="intake-review-item-copy">
                <strong>{item.title}</strong>
                <span>{item.description}</span>
                <small>{item.meta}</small>
              </span>
              <span className={workbenchToneClass(item.statusTone)}>
                {item.status}
              </span>
            </button>
          ))}
        </div>
      </section>

      <section className="intake-review-detail">
        {!detail ? (
          <div className="intake-review-empty">{emptyDetail}</div>
        ) : (
          <>
            <header className="intake-review-detail-header">
              <div>
                <span className="intake-review-mark">{detail.initials}</span>
                <span>
                  <h3>{detail.title}</h3>
                  <small>{detail.subtitle}</small>
                </span>
              </div>
              <div>
                <span className={workbenchToneClass(detail.statusTone)}>
                  {detail.status}
                </span>
                {detail.action}
              </div>
            </header>

            <section className="intake-review-readiness">
              <div>
                <div>
                  <strong>{detail.readiness.label}</strong>
                  <span>
                    {detail.readiness.complete} of {detail.readiness.total} checks complete
                  </span>
                </div>
                <progress
                  aria-label={`${detail.readiness.label} ${readinessPercent}%`}
                  max={100}
                  value={readinessPercent}
                />
              </div>
              <strong>
                {detail.readiness.blockers} {detail.readiness.blockers === 1 ? "blocker" : "blockers"}
              </strong>
            </section>

            <div className="intake-review-detail-grid">
              <section>
                <h4>{detail.primaryTitle}</h4>
                <div className="intake-review-evidence-list">
                  {detail.primaryRows.map((row) => (
                    <div key={row.id}>
                      <span>
                        {row.href ? (
                          <a href={row.href} rel="noreferrer" target="_blank">
                            {row.title}
                          </a>
                        ) : <strong>{row.title}</strong>}
                        <small>{row.meta}</small>
                      </span>
                      <span className={workbenchToneClass(row.statusTone)}>
                        {row.status}
                      </span>
                    </div>
                  ))}
                </div>

                <h4>{detail.checklistTitle}</h4>
                <div className="intake-review-checklist">
                  {detail.checklistRows.map((row) => (
                    <div key={row.id}>
                      <span className={row.passed ? "passed" : "open"}>
                        {row.passed ? "\u2713" : "!"}
                      </span>
                      <strong>{row.label}</strong>
                      <small>{row.meta}</small>
                    </div>
                  ))}
                </div>
              </section>

              <section>
                <h4>{detail.impactTitle}</h4>
                <div className="intake-review-impact-list">
                  {detail.impactRows.map((row) => (
                    <div key={row.id}>
                      <span>{row.label}</span>
                      <strong className={workbenchToneClass(row.tone)}>
                        {row.value}
                      </strong>
                    </div>
                  ))}
                </div>
              </section>
            </div>

            <section className="intake-review-note">
              <h4>{detail.noteTitle}</h4>
              {detail.note}
            </section>

            <footer className="intake-review-decision-footer">
              <p>{detail.footerHint}</p>
              <div>{detail.footerActions}</div>
            </footer>
          </>
        )}
      </section>
    </section>
  );
}

function workbenchToneClass(tone: AdminIntakeWorkbenchTone = "neutral") {
  return classNames("intake-review-status", tone);
}
