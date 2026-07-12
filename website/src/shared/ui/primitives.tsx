import {forwardRef, useEffect, useMemo, useRef, useState} from "react";
import type {
  AnchorHTMLAttributes,
  ButtonHTMLAttributes,
  CSSProperties,
  FormEvent,
  FormHTMLAttributes,
  HTMLAttributes,
  InputHTMLAttributes,
  MouseEvent,
  ReactNode,
  SelectHTMLAttributes,
  TextareaHTMLAttributes,
} from "react";
import type {FormStatus as FormStatusModel} from "../forms/types";

type ButtonVariant = "primary" | "ghost" | "ghost-light";
type ButtonSize = "default" | "small";
type ActionGroupVariant = "flow" | "hero" | "host-create-flow";
type StatusBadgeTone = "claimed" | "unclaimed" | "verified";
type ReviewSignalBadgeTone = "neutral" | "unverified" | "verified";
export type ActivityMarkSize = "sm" | "md" | "lg";
type SearchFormVariant = "organizer" | "public";
type SuccessGridVariant = "event-success-module" | "listing";
type MarketingLoopListVariant = "default" | "host";
type AuthStatusRowVariant = "default" | "flow";
type EmptyStateVariant =
  | "claim"
  | "default"
  | "listing-review"
  | "organizer-results"
  | "public-event"
  | "review-signal-lane";
export interface MarketingConsentBannerShellProps
  extends Omit<HTMLAttributes<HTMLElement>, "children"> {
  actions: ReactNode;
  body: ReactNode;
}
export interface ActivityMeta {
  label: string;
  token: string;
  short: string;
}
export interface ActivityListing {
  logo: {
    text: string;
  };
  status: string;
}
export interface ProcessStatusAction {
  href: string;
  label: ReactNode;
  onClick?: AnchorHTMLAttributes<HTMLAnchorElement>["onClick"];
  rel?: AnchorHTMLAttributes<HTMLAnchorElement>["rel"];
  target?: AnchorHTMLAttributes<HTMLAnchorElement>["target"];
  trackingLabel?: string;
  variant?: "primary" | "secondary";
}
export interface ProcessStatusItem {
  body: ReactNode;
  key?: string;
  title: ReactNode;
}
export interface ProcessStatusPanelProps extends Omit<HTMLAttributes<HTMLElement>, "title"> {
  actions: ProcessStatusAction[];
  body: ReactNode;
  eyebrow: ReactNode;
  items: ProcessStatusItem[];
  mark: ReactNode;
  onActionClick?: (action: ProcessStatusAction, event: MouseEvent<HTMLAnchorElement>) => void;
  reveal?: boolean;
  title: ReactNode;
}
export interface EventActionCardAction {
  href: string;
  label: ReactNode;
  onClick?: () => void;
  rel?: AnchorHTMLAttributes<HTMLAnchorElement>["rel"];
  target?: AnchorHTMLAttributes<HTMLAnchorElement>["target"];
  trackingLabel?: string;
  variant?: "primary" | "secondary";
}
export interface EventActionCardModel {
  actions: EventActionCardAction[];
  activityToken: string;
  body: ReactNode;
  counts: Array<{label: ReactNode; value: ReactNode}>;
  eyebrow: ReactNode;
  id: string;
  meta: Array<{label: ReactNode; value: ReactNode}>;
  title: ReactNode;
}
export interface EventActionCardProps extends HTMLAttributes<HTMLElement> {
  event: EventActionCardModel;
  onActionClick?: (
    action: EventActionCardAction,
    event: MouseEvent<HTMLAnchorElement>
  ) => void;
  reveal?: boolean;
}
export interface PublicEventCardModel {
  activityLabel: string;
  activityToken: string;
  bookedCount?: number;
  capacityLimit?: number;
  city: string;
  date: string;
  externalLinkCount?: number;
  hostName: string;
  href: string;
  id: string;
  location: string;
  priceLabel: string;
  readOnlyLabel?: string;
  sourceLabel?: string;
  summary: string;
  title: string;
  waitlistedCount?: number;
}
export interface PublicEventCardProps
  extends Omit<AnchorHTMLAttributes<HTMLAnchorElement>, "href"> {
  event: PublicEventCardModel;
  onCardClick?: (
    event: PublicEventCardModel,
    clickEvent: MouseEvent<HTMLAnchorElement>
  ) => void;
  reveal?: boolean;
}
export interface PublicSearchSuggestion {
  id: string;
  href: string;
  label: string;
  meta: string;
  type: "organizer" | "event" | "format";
  activityToken?: string;
}
export interface PublicSearchBarProps
  extends Omit<FormHTMLAttributes<HTMLFormElement>, "onSubmit"> {
  cityHref: string;
  cityName: string;
  onCityClick?: (
    href: string,
    event: MouseEvent<HTMLButtonElement>
  ) => void;
  onSearchSubmit?: (
    href: string,
    query: string,
    event: FormEvent<HTMLFormElement>
  ) => void;
  onSuggestionClick?: (
    suggestion: PublicSearchSuggestion,
    event: MouseEvent<HTMLAnchorElement>
  ) => void;
  placeholder?: string;
  reveal?: boolean;
  searchHrefForQuery: (query: string) => string;
  suggestions: PublicSearchSuggestion[];
}
export interface MarketingLoopListItem {
  body: ReactNode;
  key?: string;
  step: ReactNode;
  title: ReactNode;
}
export interface MarketingLoopListProps
  extends Omit<HTMLAttributes<HTMLOListElement>, "children"> {
  items: MarketingLoopListItem[];
  reveal?: boolean;
  variant?: MarketingLoopListVariant;
}
export interface MarketingInfoCardItem {
  body: ReactNode;
  key?: string;
  label?: ReactNode;
  title: ReactNode;
}
type MarketingInfoCardLabelVariant = "plain" | "ui";
type EventSuccessModuleGridItem = {
  attendee: ReactNode;
  host: ReactNode;
  stage: ReactNode;
  title: ReactNode;
};
export type FeaturedOrganizerCardItem = {
  activity: ReactNode;
  activityColor?: string;
  detail: ReactNode;
  href: string;
  key?: string;
  name: ReactNode;
  onClick?: AnchorHTMLAttributes<HTMLAnchorElement>["onClick"];
  status: ReactNode;
};
type ListingSuccessMetricGridItem = {
  label: ReactNode;
  value: ReactNode;
};
type ListingFactGridItem = {
  key?: string;
  label: ReactNode;
  value: ReactNode;
};
type ListingNoteGridItem = {
  body: ReactNode;
  key?: string;
};
type ListingSourceLedgerItem = {
  confidence: ReactNode;
  detail: ReactNode;
  href?: string;
  key?: string;
  label: ReactNode;
  linkLabel?: ReactNode;
  onClick?: AnchorHTMLAttributes<HTMLAnchorElement>["onClick"];
  rel?: AnchorHTMLAttributes<HTMLAnchorElement>["rel"];
  target?: AnchorHTMLAttributes<HTMLAnchorElement>["target"];
};
type ListingEventEvidenceItem = {
  date: ReactNode;
  facts: ReactNode[];
  key?: string;
  location: ReactNode;
  onSourceClick?: AnchorHTMLAttributes<HTMLAnchorElement>["onClick"];
  sourceHref: string;
  sourceLabel: ReactNode;
  sourceRel?: AnchorHTMLAttributes<HTMLAnchorElement>["rel"];
  sourceTarget?: AnchorHTMLAttributes<HTMLAnchorElement>["target"];
  summary: ReactNode;
  title: ReactNode;
};
type MarketingSectionVariant =
  | "captures"
  | "download"
  | "featured-organizers"
  | "format"
  | "home-discovery"
  | "proof"
  | "proof-host"
  | "story"
  | "trust";
type MarketingSectionCopyVariant = "download" | "proof";
export type AppDownloadStorePlatform = "android" | "ios";
export type AppDownloadCtaVariant = "compact" | "default" | "panel";
export interface AppDownloadCtaItem {
  href: string;
  kicker: string;
  label: string;
  platform: AppDownloadStorePlatform;
}
export interface AppDownloadCtaGroupProps
  extends Omit<HTMLAttributes<HTMLDivElement>, "children" | "className"> {
  initialStatus?: string;
  items: AppDownloadCtaItem[];
  onPendingClick?: (
    item: AppDownloadCtaItem,
    event: MouseEvent<HTMLButtonElement>
  ) => void;
  onStoreLinkClick?: (
    item: AppDownloadCtaItem,
    event: MouseEvent<HTMLAnchorElement>
  ) => void;
  pendingStatusForItem?: (item: AppDownloadCtaItem) => string;
  placement: string;
  reveal?: boolean;
  variant?: AppDownloadCtaVariant;
}
type CaptureGridVariant = "default" | "host";
type HostPageSectionVariant = "evidence" | "fill-room" | "proof-ledger" | "surface";
type HostFeatureSectionVariant = "comparison" | "create-flow" | "event-success";
type HostFeatureGridVariant = "comparison-split" | "create-flow" | "event-success";
type HostFeatureRailVariant = "create-flow" | "event-success";
type OrganizerSearchSectionVariant = "claim-pressure" | "hero" | "results";
type ListingHeroElement = "section";
type ListingGridVariant = "default" | "fit";
type ListingSectionVariant =
  | "default"
  | "events"
  | "reviews"
  | "split"
  | "success";
type PanelShellElement = "aside" | "div";
type PanelShellVariant = "claim-unlocks" | "event-ticket" | "hero" | "listing";
type ProductShellVariant =
  | "host-console"
  | "host-create-mock"
  | "module-stack"
  | "product-board";
export interface ProductModuleCardItem {
  activityToken?: string;
  body: ReactNode;
  facts: ReactNode[];
  id: string;
  label: ReactNode;
  title: ReactNode;
}
type HostPreviewSectionVariant =
  | "after"
  | "default"
  | "faq"
  | "live"
  | "loop"
  | "payments"
  | "product-split"
  | "trust";
type ContentGridVariant =
  | "claim-review"
  | "format"
  | "listing-event"
  | "public-event"
  | "surface"
  | "trust";

function classNames(...values: Array<string | false | null | undefined>) {
  return values.filter(Boolean).join(" ");
}

export function UiLabel({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLSpanElement> & {
  children: ReactNode;
}) {
  return (
    <span {...props} className={classNames("ui-label", className)}>
      {children}
    </span>
  );
}

export function ActivityMark({
  activity,
  className,
  listing,
  size = "md",
  ...props
}: HTMLAttributes<HTMLSpanElement> & {
  activity: ActivityMeta;
  listing: ActivityListing;
  size?: ActivityMarkSize;
}) {
  const isUnclaimed = listing.status.toLowerCase() === "unclaimed";
  return (
    <span
      {...props}
      className={classNames(
        "activity-mark",
        `activity-mark--${size}`,
        isUnclaimed && "is-unclaimed",
        className
      )}
      style={{"--activity": activity.token, ...props.style} as CSSProperties}
      aria-hidden={props["aria-hidden"] ?? "true"}
    >
      {listing.logo.text || activity.short}
    </span>
  );
}

export function ProfileStrength({
  className,
  value,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  value: number;
}) {
  return (
    <div
      {...props}
      className={classNames("profile-strength", className)}
      aria-label={props["aria-label"] ?? `Profile strength ${value}%`}
    >
      <span>{value}%</span>
      <i><b style={{width: `${value}%`}} /></i>
    </div>
  );
}

function buttonClassName({
  className,
  size = "default",
  variant = "primary",
}: {
  className?: string;
  size?: ButtonSize;
  variant?: ButtonVariant;
}) {
  return classNames(
    "button",
    size === "small" && "button--small",
    variant === "ghost" && "button--ghost",
    variant === "ghost-light" && "button--ghost-light",
    className
  );
}

export function Button({
  children,
  className,
  size,
  variant,
  ...props
}: ButtonHTMLAttributes<HTMLButtonElement> & {
  children: ReactNode;
  size?: ButtonSize;
  variant?: ButtonVariant;
}) {
  return (
    <button className={buttonClassName({className, size, variant})} {...props}>
      {children}
    </button>
  );
}

export function ButtonLink({
  children,
  className,
  size,
  variant,
  ...props
}: AnchorHTMLAttributes<HTMLAnchorElement> & {
  children: ReactNode;
  size?: ButtonSize;
  variant?: ButtonVariant;
}) {
  return (
    <a className={buttonClassName({className, size, variant})} {...props}>
      {children}
    </a>
  );
}

export function ProcessStatusPanel({
  actions,
  body,
  className,
  eyebrow,
  items,
  mark,
  onActionClick,
  reveal = true,
  title,
  ...props
}: ProcessStatusPanelProps) {
  return (
    <section
      {...props}
      className={classNames("process-status-panel", className)}
      data-reveal={reveal || undefined}
    >
      <div className="process-status-panel__card">
        <span className="process-status-panel__mark" aria-hidden="true">
          {mark}
        </span>
        <div>
          <UiLabel>{eyebrow}</UiLabel>
          <h2>{title}</h2>
          <p>{body}</p>
        </div>
      </div>
      <div className="process-status-panel__grid">
        {items.map((item, index) => (
          <article key={item.key ?? index}>
            <strong>{item.title}</strong>
            <p>{item.body}</p>
          </article>
        ))}
      </div>
      <div className="process-status-panel__actions">
        {actions.map((action) => (
          <ButtonLink
            href={action.href}
            key={`${action.href}-${String(action.label)}`}
            rel={action.rel}
            target={action.target}
            variant={action.variant === "secondary" ? "ghost" : "primary"}
            onClick={(event) => {
              action.onClick?.(event);
              onActionClick?.(action, event);
            }}
          >
            {action.label}
          </ButtonLink>
        ))}
      </div>
    </section>
  );
}

export function EventActionCard({
  className,
  event,
  onActionClick,
  reveal = true,
  ...props
}: EventActionCardProps) {
  return (
    <article
      {...props}
      className={classNames("event-action-card", className)}
      data-reveal={reveal || undefined}
      id={event.id}
      style={{"--activity": event.activityToken, ...props.style} as CSSProperties}
    >
      <div className="event-action-card__lead">
        <UiLabel>{event.eyebrow}</UiLabel>
        <h3>{event.title}</h3>
        <p>{event.body}</p>
      </div>
      <dl className="event-action-card__meta">
        {event.meta.map((item, index) => (
          <div key={`${event.id}-meta-${index}`}>
            <dt>{item.label}</dt>
            <dd>{item.value}</dd>
          </div>
        ))}
      </dl>
      {event.counts.length ? (
        <StatStrip
          aria-label={`${String(event.title)} event counts`}
          className="event-action-card__counts"
          items={event.counts}
        />
      ) : null}
      <div className="event-action-card__actions">
        {event.actions.map((action, index) => (
          <ButtonLink
            href={action.href}
            key={`${action.href}-${index}`}
            target={action.target}
            rel={action.rel}
            variant={action.variant === "secondary" ? "ghost" : "primary"}
            onClick={(clickEvent) => {
              onActionClick?.(action, clickEvent);
              action.onClick?.();
            }}
          >
            {action.label}
          </ButtonLink>
        ))}
      </div>
    </article>
  );
}

export function MarketingLoopList({
  className,
  items,
  reveal = true,
  variant = "default",
  ...props
}: MarketingLoopListProps) {
  return (
    <ol
      {...props}
      className={classNames(
        "loop-list",
        variant === "host" && "loop-list--host",
        className
      )}
    >
      {items.map((item, index) => (
        <li data-reveal={reveal || undefined} key={item.key ?? `${String(item.step)}-${index}`}>
          <span>{item.step}</span>
          <h3>{item.title}</h3>
          <p>{item.body}</p>
        </li>
      ))}
    </ol>
  );
}

export function MarketingConsentBannerShell({
  actions,
  body,
  className,
  ...props
}: MarketingConsentBannerShellProps) {
  return (
    <aside {...props} className={classNames("consent-banner", className)}>
      <p>{body}</p>
      <div>{actions}</div>
    </aside>
  );
}

export function PlainButton({
  children,
  className,
  ...props
}: ButtonHTMLAttributes<HTMLButtonElement> & {
  children: ReactNode;
}) {
  return (
    <button className={className} {...props}>
      {children}
    </button>
  );
}

export function PlainLink({
  children,
  className,
  ...props
}: AnchorHTMLAttributes<HTMLAnchorElement> & {
  children: ReactNode;
}) {
  return (
    <a className={className} {...props}>
      {children}
    </a>
  );
}

export function PublicEventCard({
  className,
  event,
  onCardClick,
  reveal = true,
  ...props
}: PublicEventCardProps) {
  const capacityLabel = typeof event.bookedCount === "number"
    ? event.capacityLimit && event.capacityLimit > 0
      ? `${event.bookedCount}/${event.capacityLimit} booked`
      : `${event.bookedCount} booked`
    : null;
  return (
    <PlainLink
      {...props}
      className={classNames("public-event-card", className)}
      href={event.href}
      data-reveal={reveal || undefined}
      onClick={(clickEvent) => {
        onCardClick?.(event, clickEvent);
        props.onClick?.(clickEvent);
      }}
      style={{"--activity": event.activityToken, ...props.style} as CSSProperties}
    >
      <div className="public-event-card__art" aria-hidden="true">
        <span>{event.activityLabel.slice(0, 2).toUpperCase()}</span>
      </div>
      <div className="public-event-card__body">
        <div className="public-event-card__meta">
          <span>{event.date}</span>
          <span>{event.city}</span>
        </div>
        <h3>{event.title}</h3>
        <p>{event.summary}</p>
        <div className="public-event-card__facts">
          <span>{event.hostName}</span>
          <span>{event.location}</span>
          <span>{event.priceLabel}</span>
          {capacityLabel ? <span>{capacityLabel}</span> : null}
          {event.waitlistedCount ? <span>{event.waitlistedCount} waitlisted</span> : null}
          {event.sourceLabel ? <span>{event.sourceLabel}</span> : null}
          {event.externalLinkCount ? (
            <span>{event.externalLinkCount} external {event.externalLinkCount === 1 ? "link" : "links"}</span>
          ) : null}
          {event.readOnlyLabel ? <span>{event.readOnlyLabel}</span> : null}
        </div>
      </div>
    </PlainLink>
  );
}

export function TextActionButton({
  children,
  className,
  ...props
}: ButtonHTMLAttributes<HTMLButtonElement> & {
  children: ReactNode;
}) {
  return (
    <PlainButton className={classNames("see-all-button", className)} type="button" {...props}>
      {children}
    </PlainButton>
  );
}

const actionGroupClassNames: Record<ActionGroupVariant, string> = {
  flow: "flow-actions",
  hero: "hero__actions",
  "host-create-flow": "host-create-flow__actions",
};

const successGridClassNames: Record<SuccessGridVariant, string> = {
  "event-success-module": "event-success-module-grid",
  listing: "listing-success-grid",
};

const contentGridClassNames: Record<ContentGridVariant, string> = {
  "claim-review": "claim-review-grid",
  format: "format-grid",
  "listing-event": "listing-catch-event-grid",
  "public-event": "public-event-grid",
  surface: "surface-grid",
  trust: "trust-grid",
};

const marketingSectionClassNames: Record<MarketingSectionVariant, string> = {
  captures: "captures-section",
  download: "download-section",
  "featured-organizers": "featured-organizers",
  format: "format-band",
  "home-discovery": "home-discovery",
  proof: "proof-section",
  "proof-host": "proof-section proof-section--host",
  story: "story-section",
  trust: "trust-section",
};

const marketingSectionCopyClassNames: Record<MarketingSectionCopyVariant, string> = {
  download: "download-section__copy",
  proof: "proof-section__copy",
};

const appDownloadCtaClassNames: Record<AppDownloadCtaVariant, string> = {
  compact: "app-download-ctas app-download-ctas--compact",
  default: "app-download-ctas",
  panel: "app-download-ctas app-download-ctas--panel",
};

const captureGridClassNames: Record<CaptureGridVariant, string> = {
  default: "capture-grid",
  host: "capture-grid capture-grid--host",
};

const hostPageSectionClassNames: Record<HostPageSectionVariant, string> = {
  evidence: "host-evidence",
  "fill-room": "host-fill-room",
  "proof-ledger": "proof-ledger",
  surface: "surface-section",
};

const hostFeatureSectionClassNames: Record<HostFeatureSectionVariant, string> = {
  comparison: "host-comparison",
  "create-flow": "host-create-flow",
  "event-success": "event-success-showcase",
};

const hostFeatureGridClassNames: Record<HostFeatureGridVariant, string> = {
  "comparison-split": "host-comparison__split",
  "create-flow": "host-create-flow__grid",
  "event-success": "event-success-showcase__grid",
};

const hostFeatureRailClassNames: Record<HostFeatureRailVariant, string> = {
  "create-flow": "host-create-flow__rail",
  "event-success": "event-success-stage-rail",
};

const organizerSearchSectionClassNames: Record<OrganizerSearchSectionVariant, string> = {
  "claim-pressure": "directory-claim-pressure",
  hero: "organizer-search-hero",
  results: "organizer-results",
};

const listingHeroClassNames = {
  copy: "listing-hero__copy",
  eyebrow: "listing-hero__eyebrow",
  inner: "listing-hero__inner",
  shell: "listing-hero",
};

const listingGridClassNames: Record<ListingGridVariant, string> = {
  default: "listing-grid",
  fit: "listing-grid listing-grid--fit",
};

const listingSectionClassNames: Record<ListingSectionVariant, string> = {
  default: "listing-section",
  events: "listing-section listing-section--events",
  reviews: "listing-section listing-section--reviews",
  split: "listing-section listing-section--split",
  success: "listing-section listing-section--success",
};

const panelShellClassNames: Record<PanelShellVariant, string> = {
  "claim-unlocks": "claim-unlocks",
  "event-ticket": "event-ticket",
  hero: "hero-panel",
  listing: "listing-panel",
};

const productShellClassNames: Record<ProductShellVariant, string> = {
  "host-console": "host-console",
  "host-create-mock": "host-create-flow__mock",
  "module-stack": "module-stack",
  "product-board": "product-board",
};

const hostPreviewSectionClassNames: Record<HostPreviewSectionVariant, string> = {
  after: "host-preview-section host-preview-after",
  default: "host-preview-section",
  faq: "host-preview-section host-preview-faq",
  live: "host-preview-section host-preview-live",
  loop: "host-preview-section host-preview-loop",
  payments: "host-preview-section host-preview-payments",
  "product-split": "host-preview-section host-preview-product-split",
  trust: "host-preview-section host-preview-trust",
};

export function ActionGroup({
  children,
  className,
  reveal = false,
  variant = "flow",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
  reveal?: boolean;
  variant?: ActionGroupVariant;
}) {
  return (
    <div
      {...props}
      className={classNames(actionGroupClassNames[variant], className)}
      data-reveal={reveal || undefined}
    >
      {children}
    </div>
  );
}

export function ControlRow({
  className,
  label,
  value,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  label: ReactNode;
  value: ReactNode;
}) {
  return (
    <div {...props} className={classNames("control-row", className)}>
      <span>{label}</span>
      <strong>{value}</strong>
    </div>
  );
}

export function WaitlistSection({
  body,
  children,
  className,
  id,
  introReveal = true,
  title,
  titleId,
}: HTMLAttributes<HTMLElement> & {
  body: ReactNode;
  children: ReactNode;
  introReveal?: boolean;
  title: ReactNode;
  titleId: string;
}) {
  return (
    <section
      className={classNames("waitlist-section", className)}
      id={id}
      aria-labelledby={titleId}
    >
      <div className="waitlist__intro" data-reveal={introReveal || undefined}>
        <h2 id={titleId}>{title}</h2>
        <p>{body}</p>
      </div>
      {children}
    </section>
  );
}

export function HomeHeroShell({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLElement> & {
  children: ReactNode;
}) {
  return (
    <section {...props} className={classNames("hero hero--home", className)}>
      {children}
    </section>
  );
}

export function HomeHeroMedia({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("hero__media", className)}>
      {children}
    </div>
  );
}

export function HomeHeroInner({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("hero__inner", className)}>
      {children}
    </div>
  );
}

export function HomeHeroCopy({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("hero__copy", className)}>
      {children}
    </div>
  );
}

export function HomeHeroBody({
  children,
  className,
  reveal = false,
  ...props
}: HTMLAttributes<HTMLParagraphElement> & {
  children: ReactNode;
  reveal?: boolean;
}) {
  return (
    <p
      {...props}
      className={classNames("hero__body", className)}
      data-reveal={reveal || undefined}
    >
      {children}
    </p>
  );
}

export function HostHeroShell({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLElement> & {
  children: ReactNode;
}) {
  return (
    <section {...props} className={classNames("host-hero", className)}>
      {children}
    </section>
  );
}

export function HostHeroInner({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("host-hero__inner", className)}>
      {children}
    </div>
  );
}

export function HostHeroCopy({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("host-hero__copy", className)}>
      {children}
    </div>
  );
}

export function HostPageSection({
  children,
  className,
  variant,
  ...props
}: HTMLAttributes<HTMLElement> & {
  children: ReactNode;
  variant: HostPageSectionVariant;
}) {
  return (
    <section {...props} className={classNames(hostPageSectionClassNames[variant], className)}>
      {children}
    </section>
  );
}

export function HostFeatureSection({
  children,
  className,
  variant,
  ...props
}: HTMLAttributes<HTMLElement> & {
  children: ReactNode;
  variant: HostFeatureSectionVariant;
}) {
  return (
    <section {...props} className={classNames(hostFeatureSectionClassNames[variant], className)}>
      {children}
    </section>
  );
}

export function HostFeatureGrid({
  children,
  className,
  variant,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
  variant: HostFeatureGridVariant;
}) {
  return (
    <div {...props} className={classNames(hostFeatureGridClassNames[variant], className)}>
      {children}
    </div>
  );
}

export function HostFeatureRail<TId extends string>({
  activeId,
  bodyVisibility,
  className,
  items,
  label,
  onSelect,
  reveal,
  variant,
}: {
  activeId: TId;
  bodyVisibility?: "active" | "always";
  className?: string;
  items: Array<{id: TId; label: ReactNode; body?: ReactNode}>;
  label: string;
  onSelect: (id: TId) => void;
  reveal?: boolean;
  variant: HostFeatureRailVariant;
}) {
  return (
    <NumberedRail
      activeId={activeId}
      bodyVisibility={bodyVisibility}
      className={classNames(hostFeatureRailClassNames[variant], className)}
      items={items}
      label={label}
      onSelect={onSelect}
      reveal={reveal}
    />
  );
}

export function HostCreateFlowCapture({
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
      className={classNames("host-create-flow__capture", className)}
      data-reveal={reveal || undefined}
    >
      {children}
    </div>
  );
}

export const HostComparisonTableHeading = forwardRef<
  HTMLDivElement,
  HTMLAttributes<HTMLDivElement> & {
    children: ReactNode;
    reveal?: boolean;
  }
>(function HostComparisonTableHeading({
  children,
  className,
  reveal = true,
  ...props
}, ref) {
  return (
    <div
      {...props}
      className={classNames("comparison-table-heading", className)}
      data-reveal={reveal || undefined}
      ref={ref}
    >
      {children}
    </div>
  );
});

export function HostComparisonTable({
  ariaLabel = "Host platform comparison",
  children,
  className,
  reveal = true,
  tableClassName,
}: {
  ariaLabel?: string;
  children: ReactNode;
  className?: string;
  reveal?: boolean;
  tableClassName?: string;
}) {
  return (
    <DataTable
      ariaLabel={ariaLabel}
      className={classNames("comparison-table-wrap", className)}
      reveal={reveal}
      tableClassName={classNames("comparison-table", tableClassName)}
    >
      {children}
    </DataTable>
  );
}

export function PrivacyGuardrail({
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
      className={classNames("privacy-guardrail", className)}
      data-reveal={reveal || undefined}
    >
      {children}
    </div>
  );
}

export function OrganizerSearchSection({
  children,
  className,
  reveal = false,
  variant,
  ...props
}: HTMLAttributes<HTMLElement> & {
  children: ReactNode;
  reveal?: boolean;
  variant: OrganizerSearchSectionVariant;
}) {
  return (
    <section
      {...props}
      className={classNames(organizerSearchSectionClassNames[variant], className)}
      data-reveal={reveal || undefined}
    >
      {children}
    </section>
  );
}

export function OrganizerSearchStats({
  className,
  ...props
}: Parameters<typeof StatStrip>[0]) {
  return <StatStrip {...props} className={classNames("organizer-search-stats", className)} />;
}

export function OrganizerResultSummary({
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
      className={classNames("organizer-result-summary", className)}
      data-reveal={reveal || undefined}
    >
      {children}
    </div>
  );
}

export function DirectoryClaimPressureCopy({
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
      className={classNames("directory-claim-pressure__copy", className)}
      data-reveal={reveal || undefined}
    >
      {children}
    </div>
  );
}

export function DirectoryClaimPressureStats({
  className,
  ...props
}: Parameters<typeof StatStrip>[0]) {
  return <StatStrip {...props} className={classNames("directory-claim-pressure__stats", className)} />;
}

export function DirectoryClaimPressureList({
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
      className={classNames("directory-claim-pressure__list", className)}
      data-reveal={reveal || undefined}
    >
      {children}
    </div>
  );
}

export function DirectoryClaimPressureCta({
  children,
  className,
  ...props
}: AnchorHTMLAttributes<HTMLAnchorElement> & {
  children: ReactNode;
}) {
  return (
    <PlainLink {...props} className={classNames("directory-claim-pressure__cta", className)}>
      {children}
    </PlainLink>
  );
}

export function ListingHeroShell({
  as: Element = "section",
  children,
  className,
  ...props
}: HTMLAttributes<HTMLElement> & {
  as?: ListingHeroElement;
  children: ReactNode;
}) {
  return (
    <Element {...props} className={classNames(listingHeroClassNames.shell, className)}>
      {children}
    </Element>
  );
}

export function ListingHeroInner({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames(listingHeroClassNames.inner, className)}>
      {children}
    </div>
  );
}

export function ListingHeroCopy({
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
      className={classNames(listingHeroClassNames.copy, className)}
      data-reveal={reveal || undefined}
    >
      {children}
    </div>
  );
}

export function ListingHeroEyebrow({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames(listingHeroClassNames.eyebrow, className)}>
      {children}
    </div>
  );
}

export function ListingHeroMetrics({
  className,
  ...props
}: Parameters<typeof StatStrip>[0]) {
  return <StatStrip {...props} className={classNames("listing-panel__metrics", className)} />;
}

export function ListingHeroShareStatus({
  className,
  ...props
}: Parameters<typeof LiveStatus>[0]) {
  return <LiveStatus {...props} className={classNames("listing-share-status", className)} />;
}

export function MarketingSection({
  children,
  className,
  variant,
  ...props
}: HTMLAttributes<HTMLElement> & {
  children: ReactNode;
  variant: MarketingSectionVariant;
}) {
  return (
    <section {...props} className={classNames(marketingSectionClassNames[variant], className)}>
      {children}
    </section>
  );
}

export function MarketingSectionCopy({
  body,
  children,
  className,
  eyebrow,
  reveal = true,
  title,
  titleId,
  variant,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  body: ReactNode;
  children?: ReactNode;
  eyebrow?: ReactNode;
  reveal?: boolean;
  title: ReactNode;
  titleId?: string;
  variant: MarketingSectionCopyVariant;
}) {
  return (
    <div
      {...props}
      className={classNames(marketingSectionCopyClassNames[variant], className)}
      data-reveal={reveal || undefined}
    >
      {eyebrow ? <span className="ui-label">{eyebrow}</span> : null}
      <h2 id={titleId}>{title}</h2>
      <p>{body}</p>
      {children}
    </div>
  );
}

export function MarketingFormatCard({
  body,
  className,
  mark,
  reveal = true,
  title,
  ...props
}: HTMLAttributes<HTMLElement> & {
  body: ReactNode;
  mark: ReactNode;
  reveal?: boolean;
  title: ReactNode;
}) {
  return (
    <article
      {...props}
      className={classNames("format-card", className)}
      data-reveal={reveal || undefined}
    >
      <span className="format-card__mark">{mark}</span>
      <h3>{title}</h3>
      <p>{body}</p>
    </article>
  );
}

export function MarketingInfoCardGrid({
  className,
  items,
  labelVariant = "plain",
  reveal = true,
  variant,
  ...props
}: Omit<HTMLAttributes<HTMLDivElement>, "children"> & {
  items: MarketingInfoCardItem[];
  labelVariant?: MarketingInfoCardLabelVariant;
  reveal?: boolean;
  variant: Extract<ContentGridVariant, "surface" | "trust">;
}) {
  return (
    <ContentGrid {...props} className={className} variant={variant}>
      {items.map((item, index) => (
        <MarketingInfoCard
          body={item.body}
          key={item.key ?? (typeof item.title === "string" ? item.title : index)}
          label={item.label}
          labelVariant={labelVariant}
          reveal={reveal}
          title={item.title}
        />
      ))}
    </ContentGrid>
  );
}

export function HostComparisonSummaryCards({
  className,
  items,
  reveal = true,
  ...props
}: Omit<HTMLAttributes<HTMLDivElement>, "children"> & {
  items: MarketingInfoCardItem[];
  reveal?: boolean;
}) {
  return (
    <HostFeatureGrid {...props} className={className} variant="comparison-split">
      {items.map((item, index) => (
        <MarketingInfoCard
          body={item.body}
          key={item.key ?? (typeof item.title === "string" ? item.title : index)}
          label={item.label}
          labelVariant="ui"
          reveal={reveal}
          title={item.title}
        />
      ))}
    </HostFeatureGrid>
  );
}

function MarketingInfoCard({
  body,
  className,
  label,
  labelVariant = "plain",
  reveal = true,
  title,
  ...props
}: Omit<HTMLAttributes<HTMLElement>, "title"> & {
  body: ReactNode;
  label?: ReactNode;
  labelVariant?: MarketingInfoCardLabelVariant;
  reveal?: boolean;
  title: ReactNode;
}) {
  return (
    <article
      {...props}
      className={className}
      data-reveal={reveal || undefined}
    >
      {label ? (
        labelVariant === "ui" ? (
          <UiLabel>{label}</UiLabel>
        ) : (
          <span>{label}</span>
        )
      ) : null}
      <h3>{title}</h3>
      <p>{body}</p>
    </article>
  );
}

export function FeaturedOrganizersGrid({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <CardGrid {...props} className={classNames("featured-organizers__grid", className)}>
      {children}
    </CardGrid>
  );
}

export function FeaturedOrganizerCardGrid({
  items,
}: {
  items: FeaturedOrganizerCardItem[];
}) {
  return (
    <FeaturedOrganizersGrid>
      {items.map((item, index) => (
        <PlainLink
          className="organizer-mini-card"
          href={item.href}
          data-reveal
          style={item.activityColor ? ({"--activity": item.activityColor} as CSSProperties) : undefined}
          onClick={item.onClick}
          key={item.key ?? index}
        >
          {item.activity}
          <div>
            {item.status}
            <h3>{item.name}</h3>
            <p>{item.detail}</p>
          </div>
        </PlainLink>
      ))}
    </FeaturedOrganizersGrid>
  );
}

export function LiveMeter({
  className,
  items,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  items: ReactNode[];
}) {
  return (
    <div {...props} className={classNames("live-meter", className)}>
      {items.map((item, index) => (
        <span key={index}>{item}</span>
      ))}
    </div>
  );
}

function defaultAppDownloadPendingStatus(item: AppDownloadCtaItem) {
  return `${item.label} is not live yet. Join the waitlist and we will send the link when it opens.`;
}

export function AppDownloadCtaGroup({
  initialStatus = "App Store and Play Store links are coming soon.",
  items,
  onPendingClick,
  onStoreLinkClick,
  pendingStatusForItem = defaultAppDownloadPendingStatus,
  placement,
  reveal = true,
  variant = "default",
  ...props
}: AppDownloadCtaGroupProps) {
  const [status, setStatus] = useState(initialStatus);
  const statusId = `${placement}-store-status`;

  function handlePendingStoreClick(
    item: AppDownloadCtaItem,
    event: MouseEvent<HTMLButtonElement>
  ) {
    setStatus(pendingStatusForItem(item));
    onPendingClick?.(item, event);
  }

  function handleStoreLinkClick(
    item: AppDownloadCtaItem,
    event: MouseEvent<HTMLAnchorElement>
  ) {
    onStoreLinkClick?.(item, event);
  }

  return (
    <AppDownloadCtasShell {...props} reveal={reveal} variant={variant}>
      <AppDownloadCtasButtons>
        {items.map((item) => (
          <StoreButton
            key={item.platform}
            item={item}
            statusId={statusId}
            onPendingClick={handlePendingStoreClick}
            onStoreLinkClick={handleStoreLinkClick}
          />
        ))}
      </AppDownloadCtasButtons>
      <AppDownloadCtasStatus id={statusId}>
        {status}
      </AppDownloadCtasStatus>
    </AppDownloadCtasShell>
  );
}

export function AppDownloadCtasShell({
  children,
  className,
  reveal = true,
  variant = "default",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
  reveal?: boolean;
  variant?: AppDownloadCtaVariant;
}) {
  return (
    <div
      {...props}
      className={classNames(appDownloadCtaClassNames[variant], className)}
      data-reveal={reveal || undefined}
    >
      {children}
    </div>
  );
}

export function AppDownloadCtasButtons({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("app-download-ctas__buttons", className)}>
      {children}
    </div>
  );
}

export function AppDownloadCtasStatus({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLParagraphElement> & {
  children: ReactNode;
}) {
  return (
    <LiveStatus {...props} className={classNames("app-download-ctas__status", className)}>
      {children}
    </LiveStatus>
  );
}

export function StoreButtonMark({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLSpanElement> & {
  children: ReactNode;
}) {
  return (
    <span
      {...props}
      className={classNames("store-button__mark", className)}
      aria-hidden={props["aria-hidden"] ?? "true"}
    >
      {children}
    </span>
  );
}

export function StoreButtonKicker({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLSpanElement> & {
  children: ReactNode;
}) {
  return (
    <span {...props} className={classNames("store-button__kicker", className)}>
      {children}
    </span>
  );
}

export function StoreButtonAction({
  children,
  className,
  pending = false,
  ...props
}: ButtonHTMLAttributes<HTMLButtonElement> & {
  children: ReactNode;
  pending?: boolean;
}) {
  return (
    <PlainButton
      {...props}
      className={classNames("store-button", pending && "is-pending", className)}
      type={props.type ?? "button"}
    >
      {children}
    </PlainButton>
  );
}

export function StoreButtonLink({
  children,
  className,
  ...props
}: AnchorHTMLAttributes<HTMLAnchorElement> & {
  children: ReactNode;
}) {
  return (
    <PlainLink {...props} className={classNames("store-button", className)}>
      {children}
    </PlainLink>
  );
}

function StoreButton({
  item,
  statusId,
  onPendingClick,
  onStoreLinkClick,
}: {
  item: AppDownloadCtaItem;
  statusId: string;
  onPendingClick: (
    item: AppDownloadCtaItem,
    event: MouseEvent<HTMLButtonElement>
  ) => void;
  onStoreLinkClick: (
    item: AppDownloadCtaItem,
    event: MouseEvent<HTMLAnchorElement>
  ) => void;
}) {
  const content = (
    <>
      <StoreButtonMark>
        {item.platform === "ios" ? <AppleStoreMark /> : <GooglePlayStoreMark />}
      </StoreButtonMark>
      <span>
        <StoreButtonKicker>{item.kicker}</StoreButtonKicker>
        <strong>{item.label}</strong>
      </span>
    </>
  );

  if (!item.href) {
    return (
      <StoreButtonAction
        pending
        aria-describedby={statusId}
        onClick={(event) => onPendingClick(item, event)}
      >
        {content}
      </StoreButtonAction>
    );
  }

  return (
    <StoreButtonLink
      href={item.href}
      target="_blank"
      rel="noreferrer"
      onClick={(event) => onStoreLinkClick(item, event)}
    >
      {content}
    </StoreButtonLink>
  );
}

function AppleStoreMark() {
  return (
    <svg viewBox="0 0 24 24" role="img" focusable="false" aria-hidden="true">
      <path
        d="M16.48 12.74c.02-2.14 1.72-3.16 1.8-3.2-1.02-1.5-2.58-1.7-3.12-1.72-1.32-.14-2.6.78-3.27.78-.69 0-1.72-.76-2.83-.74-1.44.02-2.78.85-3.52 2.15-1.52 2.63-.39 6.5 1.07 8.63.73 1.04 1.58 2.2 2.7 2.16 1.09-.04 1.5-.69 2.82-.69 1.31 0 1.69.69 2.84.67 1.18-.02 1.92-1.05 2.62-2.1.84-1.2 1.17-2.39 1.18-2.45-.03-.01-2.26-.87-2.29-3.49Zm-2.18-6.32c.59-.74.99-1.74.88-2.76-.85.04-1.9.59-2.51 1.3-.55.64-1.04 1.68-.91 2.66.96.08 1.93-.48 2.54-1.2Z"
        fill="currentColor"
      />
    </svg>
  );
}

function GooglePlayStoreMark() {
  return (
    <svg viewBox="0 0 24 24" role="img" focusable="false" aria-hidden="true">
      <path
        d="M4.5 3.7c-.26.28-.42.72-.42 1.28v14.04c0 .56.16 1 .42 1.28l7.7-8.3-7.7-8.3Z"
        fill="currentColor"
        opacity="0.86"
      />
      <path
        d="m14.84 9.15-2.64 2.84 2.64 2.85 3.26-1.85c1.09-.62 1.09-1.36 0-1.98l-3.26-1.86Z"
        fill="currentColor"
      />
      <path
        d="m14.84 9.15-3.07-1.74-5.1-2.9 5.53 7.48 2.64-2.84Z"
        fill="currentColor"
        opacity="0.68"
      />
      <path
        d="m6.67 19.49 5.1-2.9 3.07-1.75-2.64-2.85-5.53 7.5Z"
        fill="currentColor"
        opacity="0.68"
      />
    </svg>
  );
}

export function ListingSection({
  children,
  className,
  variant = "default",
  ...props
}: HTMLAttributes<HTMLElement> & {
  children: ReactNode;
  variant?: ListingSectionVariant;
}) {
  return (
    <section {...props} className={classNames(listingSectionClassNames[variant], className)}>
      {children}
    </section>
  );
}

export function ListingSectionIntro({
  body,
  className,
  eyebrow,
  reveal = true,
  title,
  titleId,
  ...props
}: Omit<HTMLAttributes<HTMLDivElement>, "title"> & {
  body: ReactNode;
  eyebrow: ReactNode;
  reveal?: boolean;
  title: ReactNode;
  titleId?: string;
}) {
  return (
    <div
      {...props}
      className={className}
      data-reveal={reveal || undefined}
    >
      <UiLabel>{eyebrow}</UiLabel>
      <h2 id={titleId}>{title}</h2>
      <p>{body}</p>
    </div>
  );
}

export function RecommendedOrganizersSectionShell({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLElement> & {
  children: ReactNode;
}) {
  return (
    <ListingSection
      {...props}
      className={classNames("recommended-organizers", className)}
    >
      {children}
    </ListingSection>
  );
}

function ListingGrid({
  children,
  className,
  variant = "default",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
  variant?: ListingGridVariant;
}) {
  return (
    <CardGrid {...props} className={classNames(listingGridClassNames[variant], className)}>
      {children}
    </CardGrid>
  );
}

function ListingCard({
  children,
  className,
  label,
  reveal = true,
  value,
  ...props
}: HTMLAttributes<HTMLElement> & {
  children?: ReactNode;
  label?: ReactNode;
  reveal?: boolean;
  value?: ReactNode;
}) {
  return (
    <article
      {...props}
      className={classNames("listing-card", className)}
      data-reveal={reveal || undefined}
    >
      {children ?? (
        <>
          <span>{label}</span>
          <strong>{value}</strong>
        </>
      )}
    </article>
  );
}

export function ListingFactGrid({
  items,
}: {
  items: ListingFactGridItem[];
}) {
  return (
    <ListingGrid>
      {items.map((item, index) => (
        <ListingCard
          label={item.label}
          value={item.value}
          key={item.key ?? index}
        />
      ))}
    </ListingGrid>
  );
}

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

export function ListingFormatRow({
  children,
  className,
  items,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children?: ReactNode;
  items?: ReactNode[];
}) {
  return (
    <div {...props} className={classNames("listing-format-row", className)}>
      {children ?? items?.map((item, index) => <span key={index}>{item}</span>)}
    </div>
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

function ListingEventDownload({
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

function ListingEventStack({
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

function ListingEventCard({
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

function ListingEventMeta({
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

function ListingEventFacts({
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

function ListingLedger({
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
            <span>{item.confidence} confidence</span>
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

export function OrganizerResultCardFooter({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("organizer-result-card__footer", className)}>
      {children}
    </div>
  );
}

export function ClaimFlowMain({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLElement> & {
  children: ReactNode;
}) {
  return (
    <main {...props} className={classNames("claim-flow", className)}>
      {children}
    </main>
  );
}

export function ClaimFlowHero({
  body,
  className,
  eyebrow,
  reveal = true,
  summaryBody,
  summaryTitle,
  title,
  ...props
}: HTMLAttributes<HTMLElement> & {
  body: ReactNode;
  eyebrow: ReactNode;
  reveal?: boolean;
  summaryBody: ReactNode;
  summaryTitle: ReactNode;
  title: ReactNode;
}) {
  return (
    <section {...props} className={classNames("claim-flow__hero", className)}>
      <div className="claim-flow__intro" data-reveal={reveal || undefined}>
        <span className="ui-label">{eyebrow}</span>
        <h1>{title}</h1>
        <p>{body}</p>
      </div>
      <div className="claim-flow__summary" data-reveal={reveal || undefined}>
        <strong>{summaryTitle}</strong>
        <span>{summaryBody}</span>
      </div>
    </section>
  );
}

export function ClaimFlowWorkspace({
  children,
  className,
  ...props
}: FormHTMLAttributes<HTMLFormElement> & {
  children: ReactNode;
}) {
  return (
    <Form {...props} className={classNames("claim-flow__workspace", className)}>
      {children}
    </Form>
  );
}

export function ClaimFlowPanel({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLElement> & {
  children: ReactNode;
}) {
  return (
    <section {...props} className={classNames("claim-flow__panel", className)}>
      {children}
    </section>
  );
}

export function ClaimFlowStage({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("claim-flow__stage", className)}>
      {children}
    </div>
  );
}

export function ClaimListingResults({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("claim-listing-results", className)}>
      {children}
    </div>
  );
}

export function ClaimResultButton({
  activityToken,
  children,
  className,
  selected = false,
  style,
  ...props
}: ButtonHTMLAttributes<HTMLButtonElement> & {
  activityToken: string;
  children: ReactNode;
  selected?: boolean;
}) {
  return (
    <PlainButton
      {...props}
      className={classNames("claim-result", selected && "is-selected", className)}
      style={{...style, "--activity": activityToken} as CSSProperties}
      type={props.type ?? "button"}
    >
      {children}
    </PlainButton>
  );
}

export function SelectedListingCard({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("selected-listing-card", className)}>
      {children}
    </div>
  );
}

export function VerificationMethodGrid({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("verification-methods", className)}>
      {children}
    </div>
  );
}

export interface OwnerUnlockBoardItem {
  body: ReactNode;
  key?: string;
  title: ReactNode;
}

export function OwnerUnlockBoard({
  className,
  items,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  items: OwnerUnlockBoardItem[];
}) {
  return (
    <div {...props} className={classNames("owner-unlock-board", className)}>
      {items.map((item, index) => (
        <article key={item.key ?? index}>
          <span>{item.title}</span>
          <p>{item.body}</p>
        </article>
      ))}
    </div>
  );
}

function SuccessGrid({
  children,
  className,
  reveal = false,
  variant,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
  reveal?: boolean;
  variant: SuccessGridVariant;
}) {
  return (
    <div
      {...props}
      className={classNames(successGridClassNames[variant], className)}
      data-reveal={reveal || undefined}
    >
      {children}
    </div>
  );
}

export function EventSuccessModuleGrid({
  className,
  items,
  reveal = true,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  items: EventSuccessModuleGridItem[];
  reveal?: boolean;
}) {
  return (
    <SuccessGrid
      {...props}
      className={className}
      reveal={reveal}
      variant="event-success-module"
    >
      {items.map((item, index) => (
        <article
          key={typeof item.title === "string" ? item.title : index}
        >
          <span className="ui-label">{item.stage}</span>
          <h3>{item.title}</h3>
          <p><strong>For attendees:</strong> {item.attendee}</p>
          <p><strong>For hosts:</strong> {item.host}</p>
        </article>
      ))}
    </SuccessGrid>
  );
}

export function ListingSuccessMetricGrid({
  className,
  items,
  reveal = true,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  items: ListingSuccessMetricGridItem[];
  reveal?: boolean;
}) {
  return (
    <SuccessGrid
      {...props}
      className={className}
      reveal={reveal}
      variant="listing"
    >
      {items.map((item, index) => (
        <div key={typeof item.label === "string" ? item.label : index}>
          <strong>{item.value}</strong>
          <span>{item.label}</span>
        </div>
      ))}
    </SuccessGrid>
  );
}

export function ContentGrid({
  children,
  className,
  variant,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
  variant: ContentGridVariant;
}) {
  return (
    <div {...props} className={classNames(contentGridClassNames[variant], className)}>
      {children}
    </div>
  );
}

export function PanelShell({
  as: Element = "div",
  children,
  className,
  reveal = false,
  variant,
  ...props
}: HTMLAttributes<HTMLElement> & {
  as?: PanelShellElement;
  children: ReactNode;
  reveal?: boolean;
  variant: PanelShellVariant;
}) {
  return (
    <Element
      {...props}
      className={classNames(panelShellClassNames[variant], className)}
      data-reveal={reveal || undefined}
    >
      {children}
    </Element>
  );
}

export function ProductShell({
  children,
  className,
  reveal = false,
  variant,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
  reveal?: boolean;
  variant: ProductShellVariant;
}) {
  return (
    <div
      {...props}
      className={classNames(productShellClassNames[variant], className)}
      data-reveal={reveal || undefined}
    >
      {children}
    </div>
  );
}

export function ProductModuleGrid({
  className,
  modules,
  reveal = true,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  modules: ProductModuleCardItem[];
  reveal?: boolean;
}) {
  return (
    <div {...props} className={classNames("product-module-grid", className)}>
      {modules.map((module) => (
        <article
          className="product-module-card"
          data-reveal={reveal || undefined}
          key={module.id}
          style={{"--activity": module.activityToken ?? "var(--website-accent)"} as CSSProperties}
        >
          <UiLabel>{module.label}</UiLabel>
          <h3>{module.title}</h3>
          <p>{module.body}</p>
          <ul>
            {module.facts.map((fact, index) => (
              <li key={`${module.id}-${index}`}>{fact}</li>
            ))}
          </ul>
        </article>
      ))}
    </div>
  );
}

export function ProductBoardNav({
  className,
  items,
  ...props
}: Omit<HTMLAttributes<HTMLDivElement>, "children"> & {
  items: ChipRailItem[];
}) {
  return <ChipRail {...props} className={classNames("product-board__nav", className)} items={items} />;
}

export function ProductBoardMain({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("product-board__main", className)}>
      {children}
    </div>
  );
}

export function ProductBoardCard({
  children,
  className,
  tone = "light",
  ...props
}: HTMLAttributes<HTMLElement> & {
  children: ReactNode;
  tone?: "dark" | "light";
}) {
  return (
    <article
      {...props}
      className={classNames(tone === "dark" && "product-board__dark", className)}
    >
      {children}
    </article>
  );
}

export function HostConsoleHeader({
  label,
  title,
  className,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  label: ReactNode;
  title: ReactNode;
}) {
  return (
    <div {...props} className={classNames("host-console__top", className)}>
      <span>{label}</span>
      <strong>{title}</strong>
    </div>
  );
}

export interface HostConsoleGridItem {
  key?: string;
  label: ReactNode;
  value: ReactNode;
}

export function HostConsoleGrid({
  className,
  items,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  items: HostConsoleGridItem[];
}) {
  return (
    <div {...props} className={classNames("host-console__grid", className)}>
      {items.map((item, index) => (
        <div key={item.key ?? index}>
          <span className="ui-label">{item.label}</span>
          <strong>{item.value}</strong>
        </div>
      ))}
    </div>
  );
}

export function HostConsoleTimeline({
  className,
  items,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  items: StatStripItem[];
}) {
  return (
    <div {...props} className={classNames("host-console__timeline", className)}>
      {items.map((item, index) => (
        <span key={item.key ?? index}>
          <strong>{item.value}</strong>
          {item.label}
        </span>
      ))}
    </div>
  );
}

export interface ModuleStackItem {
  key?: string;
  label: ReactNode;
  title: ReactNode;
  body: ReactNode;
}

export function ModuleStack({
  className,
  items,
  reveal = false,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  items: ModuleStackItem[];
  reveal?: boolean;
}) {
  return (
    <ProductShell {...props} className={className} reveal={reveal} variant="module-stack">
      {items.map((item, index) => (
        <article key={item.key ?? index}>
          <span>{item.label}</span>
          <strong>{item.title}</strong>
          <p>{item.body}</p>
        </article>
      ))}
    </ProductShell>
  );
}

export function HostCreateMockBar({
  activeIndex,
  children,
  className,
  items,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  activeIndex: number;
  children: ReactNode;
  items: Array<{id: string}>;
}) {
  return (
    <div {...props} className={classNames("mock-window__bar", className)}>
      {children}
      <div className="host-create-flow__progress" aria-hidden="true">
        {items.map((item, index) => (
          <span className={index <= activeIndex ? "is-complete" : ""} key={item.id} />
        ))}
      </div>
    </div>
  );
}

export interface HostCreateMockField {
  activeOption?: string;
  label: string;
  note?: ReactNode;
  options?: string[];
  value: ReactNode;
  wide?: boolean;
}

export function HostCreateFieldGrid({
  className,
  fields,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  fields: HostCreateMockField[];
}) {
  return (
    <div {...props} className={classNames("host-create-flow__fields", className)}>
      {fields.map((field) => (
        <div className={field.wide ? "is-wide" : ""} key={field.label}>
          <span className="ui-label">{field.label}</span>
          {field.options ? (
            <ChipRail
              aria-label={`${field.label}: ${field.value}`}
              className="host-create-flow__chips"
              itemElement="b"
              items={field.options.map((option) => ({
                active: option === field.activeOption,
                key: option,
                label: option,
              }))}
            />
          ) : (
            <strong>{field.value}</strong>
          )}
          {field.note ? <p>{field.note}</p> : null}
        </div>
      ))}
    </div>
  );
}

export function EvidenceStrip({
  className,
  items,
  reveal = false,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  items: StatStripItem[];
  reveal?: boolean;
}) {
  return (
    <div
      {...props}
      className={classNames("evidence-strip", className)}
      data-reveal={reveal || undefined}
    >
      {items.map((item, index) => (
        <div key={item.key ?? index}>
          <strong>{item.value}</strong>
          <span>{item.label}</span>
        </div>
      ))}
    </div>
  );
}

export interface ProofLedgerItem {
  key?: string;
  label: ReactNode;
  proof: ReactNode;
}

export function ProofLedgerRows({
  className,
  items,
  reveal = false,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  items: ProofLedgerItem[];
  reveal?: boolean;
}) {
  return (
    <div {...props} className={classNames("proof-ledger__rows", className)}>
      {items.map((item, index) => (
        <article data-reveal={reveal || undefined} key={item.key ?? index}>
          <strong>{item.label}</strong>
          <p>{item.proof}</p>
        </article>
      ))}
    </div>
  );
}

export function FeaturedOrganizersCta({
  body,
  children,
  className,
  reveal = false,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  body: ReactNode;
  children: ReactNode;
  reveal?: boolean;
}) {
  return (
    <div
      {...props}
      className={classNames("featured-organizers__cta", className)}
      data-reveal={reveal || undefined}
    >
      <p>{body}</p>
      {children}
    </div>
  );
}

export function HostPreviewMain({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLElement> & {
  children: ReactNode;
}) {
  return (
    <main {...props} className={classNames("host-preview", className)}>
      {children}
    </main>
  );
}

export function HostPreviewHeroShell({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLElement> & {
  children: ReactNode;
}) {
  return (
    <section {...props} className={classNames("host-preview-hero", className)}>
      {children}
    </section>
  );
}

export function HostPreviewHeroMedia({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("host-preview-hero__media", className)}>
      {children}
    </div>
  );
}

export function HostPreviewHeroInner({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("host-preview-hero__inner", className)}>
      {children}
    </div>
  );
}

export function HostPreviewHeroCopy({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("host-preview-hero__copy", className)}>
      {children}
    </div>
  );
}

export function HostPreviewHeroStores({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("host-preview-hero__stores", className)}>
      {children}
    </div>
  );
}

export function HostPreviewHeroProduct({
  children,
  className,
  reveal = false,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
  reveal?: boolean;
}) {
  return (
    <div
      {...props}
      className={classNames("host-preview-hero__product", className)}
      data-reveal={reveal || undefined}
    >
      {children}
    </div>
  );
}

export function HostPreviewOfferShell({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLElement> & {
  children: ReactNode;
}) {
  return (
    <section {...props} className={classNames("host-preview-offer", className)}>
      {children}
    </section>
  );
}

export interface HostPreviewConsoleItem {
  key?: string;
  label: ReactNode;
  value: ReactNode;
}

export function HostPreviewConsole({
  className,
  items,
  label,
  title,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  items: HostPreviewConsoleItem[];
  label: ReactNode;
  title: ReactNode;
}) {
  return (
    <div {...props} className={classNames("host-preview-console", className)}>
      <div>
        <span>{label}</span>
        <strong>{title}</strong>
      </div>
      <dl>
        {items.map((item, index) => (
          <div key={item.key ?? index}>
            <dt>{item.label}</dt>
            <dd>{item.value}</dd>
          </div>
        ))}
      </dl>
    </div>
  );
}

export function HostPreviewOfferCard({
  badgeAriaLabel,
  badgeLabel,
  badgeValue,
  body,
  className,
  reveal = false,
  title,
  titleId,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  badgeAriaLabel: string;
  badgeLabel: ReactNode;
  badgeValue: ReactNode;
  body: ReactNode;
  reveal?: boolean;
  title: ReactNode;
  titleId: string;
}) {
  return (
    <div
      {...props}
      className={classNames("host-preview-offer__card", className)}
      data-reveal={reveal || undefined}
    >
      <div>
        <h2 id={titleId}>{title}</h2>
        <p>{body}</p>
      </div>
      <div className="host-preview-badge" aria-label={badgeAriaLabel}>
        <span>{badgeLabel}</span>
        <strong>{badgeValue}</strong>
      </div>
    </div>
  );
}

export function HostPreviewOfferSteps({
  className,
  items,
  reveal = false,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  items: ReactNode[];
  reveal?: boolean;
}) {
  return (
    <div
      {...props}
      className={classNames("host-preview-offer__steps", className)}
      data-reveal={reveal || undefined}
    >
      {items.map((item, index) => (
        <div key={String(item)}>
          <span>0{index + 1}</span>
          <strong>{item}</strong>
        </div>
      ))}
    </div>
  );
}

export function HostPreviewSection({
  children,
  className,
  variant = "default",
  ...props
}: HTMLAttributes<HTMLElement> & {
  children: ReactNode;
  variant?: HostPreviewSectionVariant;
}) {
  return (
    <section {...props} className={classNames(hostPreviewSectionClassNames[variant], className)}>
      {children}
    </section>
  );
}

export function HostPreviewSectionHead({
  body,
  className,
  reveal = false,
  title,
  titleId,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  body?: ReactNode;
  reveal?: boolean;
  title: ReactNode;
  titleId: string;
}) {
  return (
    <div
      {...props}
      className={classNames("host-preview-section__head", className)}
      data-reveal={reveal || undefined}
    >
      <h2 id={titleId}>{title}</h2>
      {body ? <p>{body}</p> : null}
    </div>
  );
}

export function HostPreviewFormatRail({
  className,
  items,
  reveal = true,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  items: ChipRailItem[];
  reveal?: boolean;
}) {
  return (
    <ChipRail
      {...props}
      className={classNames("host-preview-format-rail", className)}
      items={items}
      reveal={reveal}
    />
  );
}

export function HostPreviewChipRow({
  className,
  items,
  reveal = false,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  items: ChipRailItem[];
  reveal?: boolean;
}) {
  return (
    <ChipRail
      {...props}
      className={classNames("host-preview-chip-row", className)}
      items={items}
      reveal={reveal}
    />
  );
}

export function HostPreviewApplyShell({
  body,
  children,
  className,
  id,
  title,
  titleId,
  ...props
}: HTMLAttributes<HTMLElement> & {
  body: ReactNode;
  children: ReactNode;
  title: ReactNode;
  titleId: string;
}) {
  return (
    <WaitlistSection
      {...props}
      className={classNames("host-preview-apply", className)}
      id={id}
      title={title}
      titleId={titleId}
      body={body}
    >
      {children}
    </WaitlistSection>
  );
}

export interface HostPreviewLoopItem {
  key?: string;
  step: ReactNode;
  title: ReactNode;
  body: ReactNode;
}

export function HostPreviewLoopGrid({
  className,
  items,
  reveal = false,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  items: HostPreviewLoopItem[];
  reveal?: boolean;
}) {
  return (
    <div {...props} className={classNames("host-preview-loop__grid", className)}>
      {items.map((item, index) => (
        <article data-reveal={reveal || undefined} key={item.key ?? String(item.step)}>
          <span>0{index + 1}</span>
          <div>
            <strong>{item.step}</strong>
            <h3>{item.title}</h3>
            <p>{item.body}</p>
          </div>
        </article>
      ))}
    </div>
  );
}

export function HostPreviewProductSplitCopy({
  body,
  children,
  className,
  reveal = false,
  title,
  titleId,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  body: ReactNode;
  children?: ReactNode;
  reveal?: boolean;
  title: ReactNode;
  titleId: string;
}) {
  return (
    <div
      {...props}
      className={classNames("host-preview-product-split__copy", className)}
      data-reveal={reveal || undefined}
    >
      <h2 id={titleId}>{title}</h2>
      <p>{body}</p>
      {children}
    </div>
  );
}

export interface HostPreviewRosterItem {
  key?: string;
  name: ReactNode;
  note: ReactNode;
  status: ReactNode;
}

export function HostPreviewRoster({
  className,
  items,
  reveal = false,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  items: HostPreviewRosterItem[];
  reveal?: boolean;
}) {
  return (
    <div
      {...props}
      className={classNames("host-preview-roster", className)}
      data-reveal={reveal || undefined}
    >
      {items.map((item, index) => (
        <div key={item.key ?? index}>
          <strong>{item.name}</strong>
          <span>{item.status}</span>
          <small>{item.note}</small>
        </div>
      ))}
    </div>
  );
}

export function HostPreviewFlowChips({
  className,
  items,
  reveal = false,
  variant,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  items: ReactNode[];
  reveal?: boolean;
  variant: "live-modules" | "payment-flow";
}) {
  return (
    <div
      {...props}
      className={classNames(
        variant === "live-modules" ? "host-preview-live__modules" : "host-preview-payment-flow",
        className
      )}
      data-reveal={reveal || undefined}
    >
      {items.map((item, index) => (
        <span key={index}>{item}</span>
      ))}
    </div>
  );
}

export function HostPreviewPaymentFlow({
  className,
  items,
  reveal = false,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  items: ReactNode[];
  reveal?: boolean;
}) {
  return (
    <HostPreviewFlowChips
      {...props}
      className={className}
      items={items}
      reveal={reveal}
      variant="payment-flow"
    />
  );
}

export function HostPreviewLiveGrid({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("host-preview-live__grid", className)}>
      {children}
    </div>
  );
}

export function HostPreviewLiveModules({
  className,
  items,
  reveal = false,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  items: ReactNode[];
  reveal?: boolean;
}) {
  return (
    <HostPreviewFlowChips
      {...props}
      className={className}
      items={items}
      reveal={reveal}
      variant="live-modules"
    />
  );
}

export interface HostPreviewTrustItem {
  key?: string;
  title: ReactNode;
  body: ReactNode;
}

export function HostPreviewTrustGrid({
  className,
  items,
  reveal = false,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  items: HostPreviewTrustItem[];
  reveal?: boolean;
}) {
  return (
    <div {...props} className={classNames("host-preview-trust__grid", className)}>
      {items.map((item, index) => (
        <article data-reveal={reveal || undefined} key={item.key ?? String(item.title) ?? index}>
          <h3>{item.title}</h3>
          <p>{item.body}</p>
        </article>
      ))}
    </div>
  );
}

export interface HostPreviewFaqItem {
  answer: ReactNode;
  key?: string;
  question: ReactNode;
}

export function HostPreviewFaqList({
  className,
  items,
  reveal = false,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  items: HostPreviewFaqItem[];
  reveal?: boolean;
}) {
  return (
    <div {...props} className={classNames("host-preview-faq__list", className)}>
      {items.map((item, index) => (
        <details data-reveal={reveal || undefined} key={item.key ?? String(item.question) ?? index}>
          <summary>{item.question}</summary>
          <p>{item.answer}</p>
        </details>
      ))}
    </div>
  );
}

export function EventTicketStatus({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLSpanElement> & {
  children: ReactNode;
}) {
  return (
    <span {...props} className={classNames("event-ticket__status", className)}>
      {children}
    </span>
  );
}

export function EventTicketMeta({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("event-ticket__meta", className)}>
      {children}
    </div>
  );
}

export function ClaimBandSection({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLElement> & {
  children: ReactNode;
}) {
  return (
    <section {...props} className={classNames("claim-band", className)}>
      {children}
    </section>
  );
}

export function ClaimBandGrid({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("claim-band__grid", className)}>
      {children}
    </div>
  );
}

export function ClaimBandRail({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("claim-band__rail", className)}>
      {children}
    </div>
  );
}

export function ClaimMissingEvidenceList({
  className,
  items,
  reveal = true,
  ...props
}: HTMLAttributes<HTMLUListElement> & {
  items: ReactNode[];
  reveal?: boolean;
}) {
  return (
    <ul
      {...props}
      className={classNames("missing-list", className)}
      data-reveal={reveal || undefined}
    >
      {items.map((item, index) => (
        <li key={typeof item === "string" ? item : index}>{item}</li>
      ))}
    </ul>
  );
}

export function ClaimRequestPanel({
  children,
  className,
  reveal = false,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
  reveal?: boolean;
}) {
  return (
    <div
      {...props}
      className={classNames("claim-request-panel", className)}
      data-reveal={reveal || undefined}
    >
      {children}
    </div>
  );
}

export function ClaimRequestPanelHeading({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("claim-request-panel__heading", className)}>
      {children}
    </div>
  );
}

export function ToggleChipButton({
  children,
  className,
  selected,
  ...props
}: ButtonHTMLAttributes<HTMLButtonElement> & {
  children: ReactNode;
  selected: boolean;
}) {
  return (
    <PlainButton
      aria-pressed={selected}
      className={classNames("filter-chip-button", selected && "is-on", className)}
      type="button"
      {...props}
    >
      {children}
    </PlainButton>
  );
}

export interface ChipRailItem {
  active?: boolean;
  key?: string;
  label: ReactNode;
}

export function ChipRail({
  className,
  itemElement = "span",
  items,
  reveal = false,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  itemElement?: "span" | "b";
  items: ChipRailItem[];
  reveal?: boolean;
}) {
  return (
    <div
      {...props}
      className={classNames("chip-rail", className)}
      data-reveal={reveal || undefined}
    >
      {items.map((item, index) => {
        const itemKey = item.key ?? index;
        const itemClassName = item.active ? "is-active" : undefined;
        return itemElement === "b" ? (
          <b className={itemClassName} key={itemKey}>{item.label}</b>
        ) : (
          <span className={itemClassName} key={itemKey}>{item.label}</span>
        );
      })}
    </div>
  );
}

export function CaptureGrid({
  children,
  className,
  reveal = false,
  variant = "default",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
  reveal?: boolean;
  variant?: CaptureGridVariant;
}) {
  return (
    <div
      {...props}
      className={classNames(captureGridClassNames[variant], className)}
      data-reveal={reveal || undefined}
    >
      {children}
    </div>
  );
}

export interface CaptureRecord {
  id: string;
  webPath: string;
  alt: string;
  caption: string;
  walkthroughStep: string;
}

export function CaptureCard({
  captures,
  className,
  fallbackStep,
  id,
  reveal = true,
  ...props
}: HTMLAttributes<HTMLElement> & {
  captures: Record<string, CaptureRecord>;
  fallbackStep: ReactNode;
  id: string;
  reveal?: boolean;
}) {
  const capture = captures[id];
  const imagePath = capture?.webPath ?? `/assets/app-screenshots/placeholders/${id}.svg`;

  return (
    <figure
      {...props}
      className={classNames("capture-card", className)}
      data-capture-slot={id}
      data-reveal={reveal || undefined}
    >
      <img
        src={imagePath}
        alt={capture?.alt ?? fallbackAltForCapture(id)}
        loading="lazy"
      />
      <figcaption>
        <span>{capture?.walkthroughStep ?? fallbackStep}</span>
        <strong>{capture?.caption ?? fallbackCaptionForCapture(id)}</strong>
      </figcaption>
    </figure>
  );
}

export function PhoneCaptureShell({
  caption,
  captureSlotId,
  children,
  className,
  ...props
}: HTMLAttributes<HTMLElement> & {
  caption: ReactNode;
  captureSlotId: string;
  children: ReactNode;
}) {
  return (
    <figure {...props} className={classNames("phone-capture", className)} data-capture-slot={captureSlotId}>
      <div className="phone-capture__device">
        <span className="phone-capture__notch" aria-hidden="true" />
        <div className="phone-capture__screen">{children}</div>
      </div>
      <figcaption>{caption}</figcaption>
    </figure>
  );
}

function fallbackAltForCapture(id: string) {
  switch (id) {
    case "member-event-discovery":
      return "Catch event discovery screen showing hosted singles events";
    case "post-run-catch-window":
      return "Catch post-event roster screen for the 24 hour catch window";
    case "match-chat-context":
      return "Catch match chat screen with shared event context";
    case "host-event-setup":
      return "Catch host event setup screen";
    case "host-live-console":
      return "Catch host live console with roster and check-in controls";
    case "host-post-event-report":
      return "Catch host post-event report screen";
    default:
      return "Catch app screen";
  }
}

function fallbackCaptionForCapture(id: string) {
  switch (id) {
    case "member-event-discovery":
      return "Members browse real hosted events before any dating surface opens.";
    case "post-run-catch-window":
      return "The roster opens after attendance creates shared context.";
    case "match-chat-context":
      return "Matches start with the event they already shared.";
    case "host-event-setup":
      return "Set admission rules, invite links, waitlist, payments, and Event Success before publishing.";
    case "host-live-console":
      return "Check in guests, manage waitlist movement, and run Event Success modules from one screen.";
    case "host-post-event-report":
      return "Review invite conversion, waitlist movement, attendance, catches, matches, and chats after the event closes.";
    default:
      return "Catch app screen for members and hosts.";
  }
}

export function CardGrid({
  children,
  className,
  reveal = false,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
  reveal?: boolean;
}) {
  return (
    <div
      {...props}
      className={classNames("card-grid", className)}
      data-reveal={reveal || undefined}
    >
      {children}
    </div>
  );
}

export interface StatStripItem {
  key?: string;
  label: ReactNode;
  value: ReactNode;
}

export function StatStrip({
  className,
  items,
  reveal = false,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  items: StatStripItem[];
  reveal?: boolean;
}) {
  return (
    <div
      {...props}
      className={classNames("stat-strip", className)}
      data-reveal={reveal || undefined}
    >
      {items.map((item, index) => (
        <span key={item.key ?? index}>
          <strong>{item.value}</strong>
          {item.label}
        </span>
      ))}
    </div>
  );
}

export function FilterRail({
  children,
  className,
  reveal = false,
}: {
  children: ReactNode;
  className?: string;
  reveal?: boolean;
}) {
  return (
    <div
      className={classNames("organizer-filter-rail", className)}
      data-reveal={reveal || undefined}
    >
      {children}
    </div>
  );
}

export function EmptyState({
  children,
  className,
  reveal = false,
  variant = "default",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
  reveal?: boolean;
  variant?: EmptyStateVariant;
}) {
  return (
    <div
      {...props}
      className={classNames("empty-state", emptyStateClassNames[variant], className)}
      data-reveal={reveal || undefined}
    >
      {children}
    </div>
  );
}

const emptyStateClassNames: Record<EmptyStateVariant, string | null> = {
  claim: "claim-empty-state",
  default: null,
  "listing-review": "listing-review-empty",
  "organizer-results": "empty-results",
  "public-event": "public-event-empty",
  "review-signal-lane": "review-signal-lane__empty",
};

export function ListingReviewEmptyState({
  className,
  ...props
}: Parameters<typeof EmptyState>[0]) {
  return <EmptyState {...props} variant="listing-review" className={className} />;
}

export function StatusBadge({
  children,
  className,
  tone,
  ...props
}: HTMLAttributes<HTMLSpanElement> & {
  children: ReactNode;
  tone: StatusBadgeTone;
}) {
  return (
    <span
      {...props}
      className={classNames("status-badge", `is-${tone}`, className)}
    >
      {children}
    </span>
  );
}

export function ReviewSignalBadge({
  children,
  className,
  tone = "neutral",
  ...props
}: HTMLAttributes<HTMLSpanElement> & {
  children: ReactNode;
  tone?: ReviewSignalBadgeTone;
}) {
  return (
    <span
      {...props}
      className={classNames(
        "review-signal-badge",
        tone !== "neutral" && `is-${tone}`,
        className
      )}
    >
      {children}
    </span>
  );
}

export interface PublicReviewCardModel {
  id: string;
  reviewerName: string;
  createdAtLabel: string;
  rating: number;
  comment: string;
  verified: boolean;
  verificationLabel: string;
  sourceLabel: string;
  ownerResponse?: {
    hostName: string;
    message: string;
    updatedAtLabel: string;
  } | null;
}

export function ReviewSignalLane({
  body,
  emptyBody,
  emptyTitle,
  reviews,
  title,
}: {
  body: ReactNode;
  emptyBody: ReactNode;
  emptyTitle: ReactNode;
  reviews: PublicReviewCardModel[];
  title: string;
}) {
  return (
    <section className="review-signal-lane" aria-label={title}>
      <div className="review-signal-lane__head">
        <div>
          <UiLabel>{reviews.length} visible</UiLabel>
          <h3>{title}</h3>
        </div>
        <p>{body}</p>
      </div>
      {reviews.length ? (
        <div className="review-signal-lane__stack">
          {reviews.map((review) => (
            <ReviewSignalCard key={review.id} review={review} />
          ))}
        </div>
      ) : (
        <EmptyState variant="review-signal-lane">
          <strong>{emptyTitle}</strong>
          <p>{emptyBody}</p>
        </EmptyState>
      )}
    </section>
  );
}

export function ReviewSignalCard({review}: {review: PublicReviewCardModel}) {
  return (
    <article className="review-signal-card">
      <div className="review-signal-card__header">
        <div>
          <strong>{review.reviewerName}</strong>
          <span>{review.createdAtLabel}</span>
        </div>
        <span aria-label={`${review.rating} out of 5 stars`}>
          {"★".repeat(Math.max(0, Math.min(5, Math.round(review.rating))))}
        </span>
      </div>
      <div className="review-signal-card__badges">
        <ReviewSignalBadge tone={review.verified ? "verified" : "unverified"}>
          {review.verificationLabel}
        </ReviewSignalBadge>
        <ReviewSignalBadge>{review.sourceLabel}</ReviewSignalBadge>
      </div>
      {review.comment ? <p>{review.comment}</p> : null}
      {review.ownerResponse ? (
        <div className="listing-owner-response">
          <span>Host response · {review.ownerResponse.hostName}</span>
          <p>{review.ownerResponse.message}</p>
          <small>{review.ownerResponse.updatedAtLabel}</small>
        </div>
      ) : null}
    </article>
  );
}

export function OwnerResponsePrompt({
  body,
  ctaHref,
  ctaLabel,
  onCtaClick,
  stats,
  title,
}: {
  body: ReactNode;
  ctaHref?: string;
  ctaLabel?: ReactNode;
  onCtaClick?: (href: string) => void;
  stats: StatStripItem[];
  title: ReactNode;
}) {
  return (
    <aside className="owner-response-prompt" data-reveal>
      <div>
        <UiLabel>Owner response</UiLabel>
        <h3>{title}</h3>
        <p>{body}</p>
      </div>
      <StatStrip className="owner-response-prompt__stats" items={stats} />
      {ctaHref && ctaLabel ? (
        <ButtonLink
          href={ctaHref}
          variant="ghost"
          onClick={() => {
            onCtaClick?.(ctaHref);
          }}
        >
          {ctaLabel}
        </ButtonLink>
      ) : null}
    </aside>
  );
}

export interface BadgeRowItem {
  key?: string;
  label: ReactNode;
}

export function BadgeRow({
  children,
  className,
  items,
  reveal = false,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children?: ReactNode;
  items?: BadgeRowItem[];
  reveal?: boolean;
}) {
  return (
    <div
      {...props}
      className={classNames("listing-badge-row", className)}
      data-reveal={reveal || undefined}
    >
      {items?.map((item, index) => (
        <span key={item.key ?? index}>{item.label}</span>
      )) ?? children}
    </div>
  );
}

export function LiveStatus({
  children,
  className,
  "aria-live": ariaLive = "polite",
  ...props
}: HTMLAttributes<HTMLParagraphElement> & {
  children: ReactNode;
}) {
  return (
    <p
      {...props}
      aria-live={ariaLive}
      className={classNames("live-status", className)}
      role="status"
    >
      {children}
    </p>
  );
}

export function RouteLoadingState({
  className,
  label = "Loading",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  label?: string;
}) {
  return (
    <div
      {...props}
      aria-busy="true"
      aria-label={label}
      className={classNames("route-loading", className)}
      role="status"
    />
  );
}

export function Field({
  children,
  className,
  hidden,
  label,
  span = false,
}: {
  children: ReactNode;
  className?: string;
  hidden?: boolean;
  label?: ReactNode;
  span?: boolean;
}) {
  return (
    <div className={classNames("field-block", span && "span-2", className)} hidden={hidden}>
      {label}
      {children}
    </div>
  );
}

export function TextField({
  className,
  id,
  label,
  hidden,
  span,
  ...props
}: InputHTMLAttributes<HTMLInputElement> & {
  label: ReactNode;
  hidden?: boolean;
  span?: boolean;
}) {
  return (
    <Field
      className={className}
      hidden={hidden}
      span={span}
      label={<label htmlFor={id}>{label}</label>}
    >
      <input id={id} {...props} />
    </Field>
  );
}

export function InlineInputField({
  className,
  label,
  ...props
}: InputHTMLAttributes<HTMLInputElement> & {
  label: ReactNode;
}) {
  return (
    <label className={className}>
      <span>{label}</span>
      <input {...props} />
    </label>
  );
}

export function SelectField({
  children,
  className,
  id,
  label,
  hidden,
  span,
  ...props
}: SelectHTMLAttributes<HTMLSelectElement> & {
  children: ReactNode;
  hidden?: boolean;
  label: ReactNode;
  span?: boolean;
}) {
  return (
    <Field
      className={className}
      hidden={hidden}
      span={span}
      label={<label htmlFor={id}>{label}</label>}
    >
      <select id={id} {...props}>
        {children}
      </select>
    </Field>
  );
}

export function TextAreaField({
  className,
  id,
  label,
  hidden,
  span,
  ...props
}: TextareaHTMLAttributes<HTMLTextAreaElement> & {
  hidden?: boolean;
  label: ReactNode;
  span?: boolean;
}) {
  return (
    <Field
      className={className}
      hidden={hidden}
      span={span}
      label={<label htmlFor={id}>{label}</label>}
    >
      <textarea id={id} {...props} />
    </Field>
  );
}

export function CheckboxField({
  children,
  className,
  ...props
}: InputHTMLAttributes<HTMLInputElement> & {
  children: ReactNode;
}) {
  return (
    <label className={className}>
      <input type="checkbox" {...props} />
      {children}
    </label>
  );
}

export function ListingReviewCheckbox({
  className,
  ...props
}: Parameters<typeof CheckboxField>[0]) {
  return <CheckboxField {...props} className={classNames("listing-review-checkbox", className)} />;
}

export function HoneypotField({
  name = "website",
}: {
  name?: string;
}) {
  return (
    <input
      aria-hidden="true"
      autoComplete="off"
      className="honeypot"
      name={name}
      tabIndex={-1}
    />
  );
}

export function FormStatus({
  status,
}: {
  status: FormStatusModel;
}) {
  return (
    <LiveStatus className={classNames("form-status", status.tone)}>
      {status.message}
    </LiveStatus>
  );
}

export const Form = forwardRef<
  HTMLFormElement,
  FormHTMLAttributes<HTMLFormElement> & {reveal?: boolean}
>(function Form({
  children,
  reveal = false,
  ...props
}, ref) {
  return (
    <form data-reveal={reveal || undefined} ref={ref} {...props}>
      {children}
    </form>
  );
});

export const WaitlistFormShell = forwardRef<
  HTMLFormElement,
  FormHTMLAttributes<HTMLFormElement> & {reveal?: boolean}
>(function WaitlistFormShell({
  className,
  ...props
}, ref) {
  return (
    <Form
      {...props}
      className={classNames("waitlist-form", className)}
      ref={ref}
    />
  );
});

export const ListingReviewForm = forwardRef<
  HTMLFormElement,
  FormHTMLAttributes<HTMLFormElement> & {reveal?: boolean}
>(function ListingReviewForm({
  className,
  ...props
}, ref) {
  return (
    <Form
      {...props}
      className={classNames("listing-review-form", className)}
      ref={ref}
    />
  );
});

export const ClaimRequestForm = forwardRef<
  HTMLFormElement,
  FormHTMLAttributes<HTMLFormElement> & {reveal?: boolean}
>(function ClaimRequestForm({
  className,
  ...props
}, ref) {
  return (
    <Form
      {...props}
      className={classNames("claim-request-form", className)}
      ref={ref}
    />
  );
});

export const HostApplicationShell = forwardRef<
  HTMLFormElement,
  FormHTMLAttributes<HTMLFormElement> & {reveal?: boolean}
>(function HostApplicationShell({
  children,
  className,
  reveal = false,
  ...props
}, ref) {
  return (
    <Form
      {...props}
      className={classNames("host-application", className)}
      ref={ref}
      reveal={reveal}
    >
      {children}
    </Form>
  );
});

export function HostApplicationPanel({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("host-application__panel", className)}>
      {children}
    </div>
  );
}

export function HostApplicationStage({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("host-application__stage", className)}>
      {children}
    </div>
  );
}

export function HostApplicationSubmitted({
  body,
  className,
  label,
  mark = "✓",
  title,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  body: ReactNode;
  label: ReactNode;
  mark?: ReactNode;
  title: ReactNode;
}) {
  return (
    <div {...props} className={classNames("host-application__submitted", className)}>
      <span className="submitted-panel__mark" aria-hidden="true">{mark}</span>
      <div>
        <span className="ui-label">{label}</span>
        <h3>{title}</h3>
        <p>{body}</p>
      </div>
    </div>
  );
}

export function HostApplicationReviewGrid({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("host-application__review", className)}>
      {children}
    </div>
  );
}

export function HostApplicationReviewCard({
  className,
  fallback = "Not provided",
  rows,
  title,
  ...props
}: HTMLAttributes<HTMLElement> & {
  fallback?: ReactNode;
  rows: Array<[ReactNode, ReactNode]>;
  title: ReactNode;
}) {
  return (
    <article {...props} className={className}>
      <span className="ui-label">{title}</span>
      <dl>
        {rows.map(([label, value], index) => (
          <div key={typeof label === "string" ? label : index}>
            <dt>{label}</dt>
            <dd>{value || fallback}</dd>
          </div>
        ))}
      </dl>
    </article>
  );
}

export function OperationalNote({
  body,
  className,
  title,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  body: ReactNode;
  title: ReactNode;
}) {
  return (
    <div {...props} className={classNames("operational-note", className)}>
      <strong>{title}</strong>
      <p>{body}</p>
    </div>
  );
}

export function HostApplicationCompletenessSummary({
  className,
  items,
  label,
  meter,
  pendingMark = "·",
  doneMark = "✓",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  doneMark?: ReactNode;
  items: Array<{done: boolean; label: ReactNode}>;
  label: ReactNode;
  meter: ReactNode;
  pendingMark?: ReactNode;
}) {
  return (
    <div {...props} className={classNames("host-application__summary", className)}>
      <div>
        <span className="ui-label">{label}</span>
        {meter}
      </div>
      <ul>
        {items.map((item, index) => (
          <li className={item.done ? "is-done" : undefined} key={index}>
            <span aria-hidden="true">{item.done ? doneMark : pendingMark}</span>
            {item.label}
          </li>
        ))}
      </ul>
    </div>
  );
}

const searchFormClassNames: Record<SearchFormVariant, string> = {
  organizer: "organizer-search-form",
  public: "public-search",
};

export const SearchFormShell = forwardRef<
  HTMLFormElement,
  FormHTMLAttributes<HTMLFormElement> & {
    reveal?: boolean;
    variant: SearchFormVariant;
  }
>(function SearchFormShell({
  children,
  className,
  reveal = false,
  variant,
  ...props
}, ref) {
  return (
    <Form
      {...props}
      className={classNames(searchFormClassNames[variant], className)}
      ref={ref}
      reveal={reveal}
    >
      {children}
    </Form>
  );
});

export function PublicSearchCityButton({
  children,
  className,
  ...props
}: ButtonHTMLAttributes<HTMLButtonElement> & {
  children: ReactNode;
}) {
  return (
    <PlainButton
      {...props}
      className={classNames("public-search__city", className)}
      type={props.type ?? "button"}
    >
      {children}
    </PlainButton>
  );
}

export function PublicSearchInputField({
  className,
  label,
  ...props
}: InputHTMLAttributes<HTMLInputElement> & {
  label: ReactNode;
}) {
  return (
    <InlineInputField
      {...props}
      className={classNames("public-search__input", className)}
      label={label}
    />
  );
}

export function PublicSearchSubmitButton({
  children = "Search",
  className,
  ...props
}: ButtonHTMLAttributes<HTMLButtonElement> & {
  children?: ReactNode;
}) {
  return (
    <PlainButton
      {...props}
      className={classNames("public-search__go", className)}
      type="submit"
    >
      {children}
    </PlainButton>
  );
}

export function PublicSearchResultsPanel({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("public-search__results", className)}>
      {children}
    </div>
  );
}

export function PublicSearchResultGlyph({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLSpanElement> & {
  children: ReactNode;
}) {
  return (
    <span
      {...props}
      className={classNames("public-search__glyph", className)}
      aria-hidden={props["aria-hidden"] ?? "true"}
    >
      {children}
    </span>
  );
}

export function PublicSearchBar({
  cityHref,
  cityName,
  onCityClick,
  onSearchSubmit,
  onSuggestionClick,
  placeholder = "Clubs, organizers, venues, formats, events...",
  reveal = true,
  searchHrefForQuery,
  suggestions,
  ...props
}: PublicSearchBarProps) {
  const [query, setQuery] = useState("");
  const [open, setOpen] = useState(false);
  const rootRef = useRef<HTMLFormElement | null>(null);
  const normalizedQuery = query.trim().toLowerCase();
  const results = useMemo(() => {
    if (normalizedQuery.length < 2) return suggestions.slice(0, 5);
    return suggestions
      .filter((item) =>
        [item.label, item.meta, item.type].join(" ").toLowerCase().includes(normalizedQuery)
      )
      .slice(0, 7);
  }, [normalizedQuery, suggestions]);

  useEffect(() => {
    const handlePointerDown = (event: globalThis.MouseEvent) => {
      if (!rootRef.current?.contains(event.target as Node)) {
        setOpen(false);
      }
    };
    document.addEventListener("mousedown", handlePointerDown);
    return () => document.removeEventListener("mousedown", handlePointerDown);
  }, []);

  function submitSearch(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const trimmedQuery = query.trim();
    onSearchSubmit?.(searchHrefForQuery(trimmedQuery), trimmedQuery, event);
  }

  return (
    <SearchFormShell {...props} variant="public" onSubmit={submitSearch} ref={rootRef} reveal={reveal}>
      <PublicSearchCityButton
        type="button"
        onClick={(event) => onCityClick?.(cityHref, event)}
      >
        {cityName}
      </PublicSearchCityButton>
      <PublicSearchInputField
        label="Search Catch"
        name="q"
        value={query}
        placeholder={placeholder}
        onChange={(event) => {
          setQuery(event.currentTarget.value);
          setOpen(true);
        }}
        onFocus={() => setOpen(true)}
      />
      <PublicSearchSubmitButton />
      {open && results.length ? (
        <PublicSearchResultsPanel>
          {results.map((item) => (
            <PlainLink
              href={item.href}
              key={item.id}
              onClick={(event) => onSuggestionClick?.(item, event)}
              style={{"--activity": item.activityToken ?? "var(--website-accent)"} as CSSProperties}
            >
              <PublicSearchResultGlyph>
                {item.type === "event" ? "EV" : item.type === "format" ? "FT" : "OR"}
              </PublicSearchResultGlyph>
              <span>
                <strong>{item.label}</strong>
                <small>{item.meta}</small>
              </span>
              <em>{item.type}</em>
            </PlainLink>
          ))}
        </PublicSearchResultsPanel>
      ) : null}
    </SearchFormShell>
  );
}

export function FieldGrid({
  children,
  className,
}: {
  children: ReactNode;
  className?: string;
}) {
  return <div className={classNames("flow-field-grid", className)}>{children}</div>;
}

export function DataTable({
  ariaLabel,
  children,
  className,
  reveal = false,
  tableClassName,
}: {
  ariaLabel: string;
  children: ReactNode;
  className?: string;
  reveal?: boolean;
  tableClassName?: string;
}) {
  return (
    <div className={className} data-reveal={reveal || undefined}>
      <table aria-label={ariaLabel} className={tableClassName}>
        {children}
      </table>
    </div>
  );
}

export function NumberedRail<TId extends string>({
  activeId,
  bodyVisibility = "active",
  className,
  items,
  label,
  onSelect,
  reveal = false,
}: {
  activeId: TId;
  bodyVisibility?: "active" | "always";
  className: string;
  items: Array<{id: TId; label: ReactNode; body?: ReactNode}>;
  label: string;
  onSelect: (id: TId) => void;
  reveal?: boolean;
}) {
  return (
    <div className={className} aria-label={label} data-reveal={reveal || undefined}>
      {items.map((item, index) => {
        const active = item.id === activeId;
        return (
          <PlainButton
            aria-current={active ? "step" : undefined}
            aria-expanded={active}
            className={active ? "is-active" : ""}
            key={item.id}
            onClick={() => onSelect(item.id)}
            type="button"
          >
            <span>{String(index + 1).padStart(2, "0")}</span>
            <strong>{item.label}</strong>
            {item.body && (bodyVisibility === "always" || active) ? <small>{item.body}</small> : null}
          </PlainButton>
        );
      })}
    </div>
  );
}

export function StepRail<TId extends string>({
  currentIndex,
  getDisabled,
  items,
  label,
  onSelect,
}: {
  currentIndex: number;
  getDisabled?: (item: {id: TId}, index: number) => boolean;
  items: Array<{id: TId; label: string; body?: string}>;
  label: string;
  onSelect: (id: TId) => void;
}) {
  return (
    <nav className="operational-step-rail" aria-label={label}>
      {items.map((item, index) => (
        <button
          className={index === currentIndex ? "is-active" : index < currentIndex ? "is-done" : ""}
          disabled={getDisabled?.(item, index)}
          key={item.id}
          onClick={() => onSelect(item.id)}
          type="button"
        >
          <span>{String(index + 1).padStart(2, "0")}</span>
          <strong>{item.label}</strong>
          {item.body ? <small>{item.body}</small> : null}
        </button>
      ))}
    </nav>
  );
}

export function ChoiceChip({
  children,
  selected,
  ...props
}: ButtonHTMLAttributes<HTMLButtonElement> & {
  children: ReactNode;
  selected: boolean;
}) {
  return (
    <button
      className={classNames("choice-chip", selected && "is-selected")}
      type="button"
      {...props}
    >
      {children}
    </button>
  );
}

export function ChoiceChipGrid({children}: {children: ReactNode}) {
  return <div className="choice-chip-grid">{children}</div>;
}

export function ChoiceCard({
  body,
  selected,
  title,
  ...props
}: ButtonHTMLAttributes<HTMLButtonElement> & {
  body: ReactNode;
  selected: boolean;
  title: ReactNode;
}) {
  return (
    <button
      className={classNames("choice-card", selected && "is-selected")}
      type="button"
      {...props}
    >
      <strong>{title}</strong>
      <span>{body}</span>
    </button>
  );
}

export function MetricCard({
  label,
  value,
}: {
  label: ReactNode;
  value: ReactNode;
}) {
  return (
    <article className="listing-card" data-reveal>
      <span>{label}</span>
      <strong>{value}</strong>
    </article>
  );
}

export function AuthStatusRow({
  action,
  children,
  className,
  variant = "default",
}: {
  action: ReactNode;
  children: ReactNode;
  className?: string;
  variant?: AuthStatusRowVariant;
}) {
  return (
    <div className={classNames("claim-auth-row", variant === "flow" && "claim-auth-row--flow", className)}>
      <span>{children}</span>
      {action}
    </div>
  );
}
