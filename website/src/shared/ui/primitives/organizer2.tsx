import type {CSSProperties, HTMLAttributes, ReactNode} from "react";
import type {ListingEventEvidenceItem, ListingNoteGridItem, ListingSourceLedgerItem} from "./organizer";
import {PlainLink} from "./actions";
import {classNames} from "./foundation";
import {ListingCard, ListingGrid} from "./organizer";

export function ListingNoteGrid({
  items,
}: {
  items: ListingNoteGridItem[];
}) {
  return (
    <ListingGrid variant="fit">
      {items.map((item, index) => (
        <ListingCard key={item.key ?? index}>
          <p>{item.body}</p>
        </ListingCard>
      ))}
    </ListingGrid>
  );
}

export function ListingDiagnostics({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("listing-diagnostics", className)}>
      {children}
    </div>
  );
}

export function ListingDiagnosticsHead({
  className,
  label,
  value,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  label: ReactNode;
  value: ReactNode;
}) {
  return (
    <div {...props} className={classNames("listing-diagnostics__head", className)}>
      <span className="ui-label">{label}</span>
      <strong>{value}</strong>
    </div>
  );
}

export function ListingDiagnosticList({
  items,
}: {
  items: Array<{ok: boolean; label: ReactNode}>;
}) {
  return (
    <ul>
      {items.map((item, index) => (
        <li className={item.ok ? "is-ok" : "is-missing"} key={index}>
          <span aria-hidden="true">{item.ok ? "✓" : "!"}</span>
          {item.label}
        </li>
      ))}
    </ul>
  );
}

export function ListingEventDownload({
  children,
  className,
  reveal = true,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
  reveal?: boolean;
}) {
  return (
    <div
      {...props}
      className={classNames("listing-event-download", className)}
      data-reveal={reveal || undefined}
    >
      {children}
    </div>
  );
}

export function ListingEventDownloadPanel({
  body,
  children,
  heading,
  kicker,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  body: ReactNode;
  children: ReactNode;
  heading: ReactNode;
  kicker: ReactNode;
  reveal?: boolean;
}) {
  return (
    <ListingEventDownload {...props}>
      <div>
        <span className="ui-label">{kicker}</span>
        <h3>{heading}</h3>
        <p>{body}</p>
      </div>
      {children}
    </ListingEventDownload>
  );
}

export function ListingEventStack({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("listing-event-stack", className)}>
      {children}
    </div>
  );
}

export function ListingEventCard({
  children,
  className,
  reveal = true,
  ...props
}: HTMLAttributes<HTMLElement> & {
  children: ReactNode;
  reveal?: boolean;
}) {
  return (
    <article
      {...props}
      className={classNames("listing-event-card", className)}
      data-reveal={reveal || undefined}
    >
      {children}
    </article>
  );
}

export function ListingEventMeta({
  items,
}: {
  items: Array<{label: ReactNode; value: ReactNode}>;
}) {
  return (
    <dl className="listing-event-meta">
      {items.map((item, index) => (
        <div key={index}>
          <dt>{item.label}</dt>
          <dd>{item.value}</dd>
        </div>
      ))}
    </dl>
  );
}

export function ListingEventFacts({
  items,
}: {
  items: ReactNode[];
}) {
  return (
    <ul className="listing-event-facts">
      {items.map((item, index) => (
        <li key={index}>{item}</li>
      ))}
    </ul>
  );
}

export function ListingEventEvidenceList({
  items,
}: {
  items: ListingEventEvidenceItem[];
}) {
  return (
    <ListingEventStack>
      {items.map((item, index) => (
        <ListingEventCard key={item.key ?? index}>
          <div>
            <span className="ui-label">{item.date}</span>
            <h3>{item.title}</h3>
            <p>{item.summary}</p>
          </div>
          <ListingEventMeta
            items={[
              {label: "Location", value: item.location},
              {
                label: "Source",
                value: (
                  <PlainLink
                    href={item.sourceHref}
                    target={item.sourceTarget ?? "_blank"}
                    rel={item.sourceRel ?? "noreferrer"}
                    onClick={item.onSourceClick}
                  >
                    {item.sourceLabel}
                  </PlainLink>
                ),
              },
            ]}
          />
          <ListingEventFacts items={item.facts} />
        </ListingEventCard>
      ))}
    </ListingEventStack>
  );
}

export function ListingReviewSummary({
  children,
  className,
  reveal = true,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
  reveal?: boolean;
}) {
  return (
    <div
      {...props}
      className={classNames("listing-review-summary", className)}
      data-reveal={reveal || undefined}
    >
      {children}
    </div>
  );
}

export function ListingReviewWorkspace({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("listing-review-workspace", className)}>
      {children}
    </div>
  );
}

export function ListingReviewLanes({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("listing-review-lanes", className)}>
      {children}
    </div>
  );
}

export function ListingLedger({
  children,
  className,
  reveal = true,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
  reveal?: boolean;
}) {
  return (
    <div
      {...props}
      className={classNames("listing-ledger", className)}
      data-reveal={reveal || undefined}
    >
      {children}
    </div>
  );
}

export function ListingSourceLedger({
  className,
  items,
  linkLabel = "Open source",
  reveal = true,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  items: ListingSourceLedgerItem[];
  linkLabel?: ReactNode;
  reveal?: boolean;
}) {
  return (
    <ListingLedger
      {...props}
      className={className}
      reveal={reveal}
    >
      {items.map((item, index) => (
        <article key={item.key ?? (typeof item.label === "string" ? item.label : index)}>
          <div>
            <strong>{item.label}</strong>
            <span>{item.confidence}{" confidence"}</span>
          </div>
          <p>{item.detail}</p>
          {item.href ? (
            <PlainLink
              className="source-link"
              href={item.href}
              target={item.target ?? "_blank"}
              rel={item.rel ?? "noreferrer"}
              onClick={item.onClick}
            >
              {item.linkLabel ?? linkLabel}
            </PlainLink>
          ) : null}
        </article>
      ))}
    </ListingLedger>
  );
}

export function OrganizerResultCardShell({
  activityToken,
  children,
  className,
  style,
  ...props
}: HTMLAttributes<HTMLElement> & {
  activityToken: string;
  children: ReactNode;
}) {
  return (
    <article
      {...props}
      className={classNames("organizer-result-card", className)}
      style={{...style, "--activity": activityToken} as CSSProperties}
    >
      {children}
    </article>
  );
}

export function OrganizerResultCardBody({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("organizer-result-card__body", className)}>
      {children}
    </div>
  );
}

export function OrganizerResultCardTopline({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("organizer-card-topline", className)}>
      {children}
    </div>
  );
}

export interface OrganizerEventHighlightItem {
  activityToken: string;
  detail: ReactNode;
  id: string;
  kind: ReactNode;
  title: ReactNode;
}

export function OrganizerEventHighlights({
  ariaLabel,
  className,
  items,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  ariaLabel: string;
  items: OrganizerEventHighlightItem[];
}) {
  return (
    <div
      {...props}
      className={classNames("organizer-event-highlights", className)}
      aria-label={ariaLabel}
    >
      {items.map((item) => (
        <span key={item.id} style={{"--activity": item.activityToken} as CSSProperties}>
          <strong>{item.title}</strong>
          <small>{item.kind} · {item.detail}</small>
        </span>
      ))}
    </div>
  );
}
