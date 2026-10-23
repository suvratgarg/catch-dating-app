import type {HTMLAttributes, ReactNode} from "react";
import {ToggleGroupControl, UiLabel as WebUiLabel} from "@catch/web-ui";
import type {HostPreviewSectionVariant} from "./host";

import type {ListingGridVariant, ListingSectionVariant} from "./organizer";
import {classNames} from "@catch/web-ui";

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

export type PanelShellElement = "aside" | "div";

export type PanelShellVariant = "claim-unlocks" | "event-ticket" | "hero" | "listing";

export type ContentGridVariant =
  | "claim-review"
  | "format"
  | "listing-event"
  | "marketing-split"
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

export const successGridClassNames: Record<SuccessGridVariant, string> = {
  "event-success-module": "event-success-module-grid",
  listing: "listing-success-grid",
};

export const contentGridClassNames: Record<ContentGridVariant, string> = {
  "claim-review": "claim-review-grid",
  format: "format-grid",
  "listing-event": "listing-catch-event-grid",
  "marketing-split": "marketing-content-split",
  "public-event": "public-event-grid",
  surface: "surface-grid",
  trust: "trust-grid",
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
