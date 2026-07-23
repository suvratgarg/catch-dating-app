import type {
  AnchorHTMLAttributes,
  HTMLAttributes,
  ReactNode,
} from "react";
import {PlainLink} from "./actions";
import {classNames} from "./foundation";
import {UiLabel} from "./layout";

export function EventDetailHeroLayout({
  badge,
  children,
  eyebrow,
  organizerLine,
  summary,
  supplyLabel,
  title,
}: {
  badge: ReactNode;
  children: ReactNode;
  eyebrow: ReactNode;
  organizerLine: ReactNode;
  summary: ReactNode;
  supplyLabel: ReactNode;
  title: ReactNode;
}) {
  return (
    <section className="event-detail-hero" aria-labelledby="event-detail-title">
      <div className="wrap event-detail-hero__inner">
        <div className="event-detail-hero__copy" data-reveal>
          <UiLabel>{eyebrow}</UiLabel>
          <h1 id="event-detail-title">{title}</h1>
          <p className="event-detail-hero__summary">{summary}</p>
          <div className="event-detail-hero__badges">
            {badge}
            <span>{supplyLabel}</span>
          </div>
          <p className="event-detail-hero__organizer">{organizerLine}</p>
        </div>
        {children}
      </div>
    </section>
  );
}

export function EventDetailActionPanel({
  children,
  date,
  description,
  title,
}: {
  children: ReactNode;
  date: ReactNode;
  description: ReactNode;
  title: ReactNode;
}) {
  return (
    <aside className="event-detail-action-panel" data-reveal>
      <UiLabel>{date}</UiLabel>
      <h2>{title}</h2>
      <p>{description}</p>
      {children}
    </aside>
  );
}

export function EventDetailSection({
  children,
  className,
  variant = "default",
  ...props
}: HTMLAttributes<HTMLElement> & {
  children: ReactNode;
  variant?: "default" | "provenance" | "reviews";
}) {
  return (
    <section
      {...props}
      className={classNames(
        "event-detail-section",
        variant === "provenance" && "event-detail-section--provenance",
        variant === "reviews" && "event-detail-section--reviews",
        className
      )}
    >
      <div className="wrap">{children}</div>
    </section>
  );
}

export function EventDetailFactGrid({
  items,
}: {
  items: Array<{label: ReactNode; value: ReactNode}>;
}) {
  return (
    <dl className="event-detail-facts" data-reveal>
      {items.map((item, index) => (
        <div key={typeof item.label === "string" ? item.label : index}>
          <dt>{item.label}</dt>
          <dd>{item.value}</dd>
        </div>
      ))}
    </dl>
  );
}

export function EventDetailProvenanceLayout({
  children,
  intro,
}: {
  children: ReactNode;
  intro: ReactNode;
}) {
  return (
    <div className="event-detail-provenance">
      {intro}
      {children}
    </div>
  );
}

export function EventDetailProvenanceFacts({
  items,
}: {
  items: Array<{label: ReactNode; value: ReactNode}>;
}) {
  return (
    <dl data-reveal>
      {items.map((item, index) => (
        <div key={typeof item.label === "string" ? item.label : index}>
          <dt>{item.label}</dt>
          <dd>{item.value}</dd>
        </div>
      ))}
    </dl>
  );
}

export function EventDetailSourceLink({
  children,
  ...props
}: AnchorHTMLAttributes<HTMLAnchorElement> & {
  children: ReactNode;
}) {
  return <PlainLink {...props}>{children}</PlainLink>;
}
