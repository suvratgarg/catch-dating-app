import type {AnchorHTMLAttributes, CSSProperties, HTMLAttributes, MouseEvent, ReactNode} from "react";
import {ToggleGroupControl, UiLabel as WebUiLabel} from "@catch/web-ui";
import type {HostFeatureGridVariant, HostFeatureRailVariant, HostFeatureSectionVariant, HostPageSectionVariant, HostPreviewSectionVariant} from "./host";
import type {CaptureGridVariant, MarketingSectionCopyVariant, MarketingSectionVariant} from "./media";
import type {ListingGridVariant, ListingSectionVariant, OrganizerSearchSectionVariant} from "./organizer";
import {PlainLink} from "./actions";
import {classNames} from "./foundation";

export type SuccessGridVariant = "event-success-module" | "listing";

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

export type PanelShellElement = "aside" | "div";

export type PanelShellVariant = "claim-unlocks" | "event-ticket" | "hero" | "listing";

export type ProductShellVariant =
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

export type ContentGridVariant =
  | "claim-review"
  | "format"
  | "listing-event"
  | "public-event"
  | "surface"
  | "trust";

export function UiLabel({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLSpanElement> & {
  children: ReactNode;
}) {
  return (
    <WebUiLabel {...props} className={classNames("ui-label", className)}>
      {children}
    </WebUiLabel>
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
          {event.waitlistedCount ? <span>{event.waitlistedCount}{"waitlisted"}</span> : null}
          {event.sourceLabel ? <span>{event.sourceLabel}</span> : null}
          {event.externalLinkCount ? (
            <span>{event.externalLinkCount}{"external"}{event.externalLinkCount === 1 ? "link" : "links"}</span>
          ) : null}
          {event.readOnlyLabel ? <span>{event.readOnlyLabel}</span> : null}
        </div>
      </div>
    </PlainLink>
  );
}

export const successGridClassNames: Record<SuccessGridVariant, string> = {
  "event-success-module": "event-success-module-grid",
  listing: "listing-success-grid",
};

export const contentGridClassNames: Record<ContentGridVariant, string> = {
  "claim-review": "claim-review-grid",
  format: "format-grid",
  "listing-event": "listing-catch-event-grid",
  "public-event": "public-event-grid",
  surface: "surface-grid",
  trust: "trust-grid",
};

export const marketingSectionClassNames: Record<MarketingSectionVariant, string> = {
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

export const marketingSectionCopyClassNames: Record<MarketingSectionCopyVariant, string> = {
  download: "download-section__copy",
  proof: "proof-section__copy",
};

export const captureGridClassNames: Record<CaptureGridVariant, string> = {
  default: "capture-grid",
  host: "capture-grid capture-grid--host",
};

export const hostPageSectionClassNames: Record<HostPageSectionVariant, string> = {
  evidence: "host-evidence",
  "fill-room": "host-fill-room",
  "proof-ledger": "proof-ledger",
  surface: "surface-section",
};

export const hostFeatureSectionClassNames: Record<HostFeatureSectionVariant, string> = {
  comparison: "host-comparison",
  "create-flow": "host-create-flow",
  "event-success": "event-success-showcase",
};

export const hostFeatureGridClassNames: Record<HostFeatureGridVariant, string> = {
  "comparison-split": "host-comparison__split",
  "create-flow": "host-create-flow__grid",
  "event-success": "event-success-showcase__grid",
};

export const hostFeatureRailClassNames: Record<HostFeatureRailVariant, string> = {
  "create-flow": "host-create-flow__rail",
  "event-success": "event-success-stage-rail",
};

export const organizerSearchSectionClassNames: Record<OrganizerSearchSectionVariant, string> = {
  "claim-pressure": "directory-claim-pressure",
  hero: "organizer-search-hero",
  results: "organizer-results",
};

export const listingGridClassNames: Record<ListingGridVariant, string> = {
  default: "listing-grid",
  fit: "listing-grid listing-grid--fit",
};

export const listingSectionClassNames: Record<ListingSectionVariant, string> = {
  default: "listing-section",
  events: "listing-section listing-section--events",
  reviews: "listing-section listing-section--reviews",
  split: "listing-section listing-section--split",
  success: "listing-section listing-section--success",
};

export const panelShellClassNames: Record<PanelShellVariant, string> = {
  "claim-unlocks": "claim-unlocks",
  "event-ticket": "event-ticket",
  hero: "hero-panel",
  listing: "listing-panel",
};

export const productShellClassNames: Record<ProductShellVariant, string> = {
  "host-console": "host-console",
  "host-create-mock": "host-create-flow__mock",
  "module-stack": "module-stack",
  "product-board": "product-board",
};

export const hostPreviewSectionClassNames: Record<HostPreviewSectionVariant, string> = {
  after: "host-preview-section host-preview-after",
  default: "host-preview-section",
  faq: "host-preview-section host-preview-faq",
  live: "host-preview-section host-preview-live",
  loop: "host-preview-section host-preview-loop",
  payments: "host-preview-section host-preview-payments",
  "product-split": "host-preview-section host-preview-product-split",
  trust: "host-preview-section host-preview-trust",
};

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

export function VerificationMethodGrid({
  children,
  className,
  ...props
}: Parameters<typeof ToggleGroupControl>[0]) {
  return (
    <ToggleGroupControl
      {...props}
      className={classNames("verification-methods", className)}
    >
      {children}
    </ToggleGroupControl>
  );
}

export function SuccessGrid({
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

export interface ModuleStackItem {
  key?: string;
  label: ReactNode;
  title: ReactNode;
  body: ReactNode;
}
