import type {
  AnchorHTMLAttributes,
  CSSProperties,
  HTMLAttributes,
  ReactNode,
} from "react";
import {PlainLink} from "./actions";
import {classNames} from "./foundation";
import {UiLabel} from "./layout";

export function EventDetailHeroLayout({
  activityToken,
  children,
  eyebrow,
  facts,
  media,
  metaLine,
  planLabel,
  reviewPreview,
  summary,
  supplyLabel,
  title,
}: {
  activityToken: string;
  children: ReactNode;
  eyebrow: ReactNode;
  facts: Array<{label: ReactNode; value: ReactNode}>;
  media: ReactNode;
  metaLine: ReactNode;
  planLabel: ReactNode;
  reviewPreview: ReactNode;
  summary: ReactNode;
  supplyLabel: ReactNode;
  title: ReactNode;
}) {
  return (
    <section
      className="event-detail-hero"
      aria-labelledby="event-detail-title"
      style={{"--activity": activityToken} as CSSProperties}
    >
      <div className="event-detail-hero__inner">
        <article className="event-detail-ticket" data-reveal>
          {media}
          <div className="event-detail-ticket__body">
            <div className="event-detail-ticket__provenance">
              <UiLabel>{eyebrow}</UiLabel>
              <span>{supplyLabel}</span>
            </div>
            <h1 id="event-detail-title">{title}</h1>
            <p className="event-detail-ticket__meta">{metaLine}</p>
            <EventDetailHeroFacts items={facts} />
            <div className="event-detail-ticket__plan">
              <UiLabel>{planLabel}</UiLabel>
              <p>{summary}</p>
            </div>
            {reviewPreview}
          </div>
        </article>
        <div className="event-detail-hero__rail">{children}</div>
      </div>
    </section>
  );
}

export function EventDetailMedia({
  alt,
  src,
  srcSet,
}: {
  alt: string;
  src: string;
  srcSet: string;
}) {
  return (
    <picture className="event-detail-media">
      <source media="(max-width: 640px)" srcSet={srcSet} />
      <img alt={alt} src={src} />
    </picture>
  );
}

export function EventDetailOrganizerPanel({
  activity,
  badge,
  claimAction,
  eyebrow,
  location,
  metrics,
  name,
  primaryAction,
}: {
  activity: ReactNode;
  badge: ReactNode;
  claimAction?: ReactNode;
  eyebrow: ReactNode;
  location: ReactNode;
  metrics: Array<{label: ReactNode; value: ReactNode}>;
  name: ReactNode;
  primaryAction: ReactNode;
}) {
  return (
    <aside className="event-detail-organizer-panel" data-reveal>
      <UiLabel>{eyebrow}</UiLabel>
      <div className="event-detail-organizer-panel__identity">
        {activity}
        <div>
          <h2>{name}</h2>
          <p>{location}</p>
        </div>
      </div>
      <div className="event-detail-organizer-panel__status">{badge}</div>
      {metrics.length ? (
        <dl className="event-detail-organizer-panel__metrics">
          {metrics.map((item, index) => (
            <div key={typeof item.label === "string" ? item.label : index}>
              <dd>{item.value}</dd>
              <dt>{item.label}</dt>
            </div>
          ))}
        </dl>
      ) : null}
      <div className="event-detail-organizer-panel__actions">
        {primaryAction}
        {claimAction}
      </div>
    </aside>
  );
}

export function EventDetailReviewPreview({
  body,
  eyebrow,
  meta,
  title,
}: {
  body: ReactNode;
  eyebrow: ReactNode;
  meta?: ReactNode;
  title: ReactNode;
}) {
  return (
    <div className="event-detail-ticket__review-preview">
      <div>
        <UiLabel>{eyebrow}</UiLabel>
        {meta ? <span>{meta}</span> : null}
      </div>
      <div>
        <strong>{title}</strong>
        <p>{body}</p>
      </div>
    </div>
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
      <div className="event-detail-action-panel__actions">{children}</div>
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
      <div className="event-detail-section__inner">{children}</div>
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

function EventDetailHeroFacts({
  items,
}: {
  items: Array<{label: ReactNode; value: ReactNode}>;
}) {
  return (
    <dl className="event-detail-ticket__facts">
      {items.map((item, index) => (
        <div key={typeof item.label === "string" ? item.label : index}>
          <dt>{item.label}</dt>
          <dd>{item.value}</dd>
        </div>
      ))}
    </dl>
  );
}
