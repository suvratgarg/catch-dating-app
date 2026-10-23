import type {CSSProperties, HTMLAttributes, ReactNode} from "react";
import type {ActivityMeta} from "./foundation";

import type {ActivityListing} from "./organizer";
import {classNames} from "@catch/web-ui";
import {marketingSectionClassNames, marketingSectionCopyClassNames} from "./layout";

export type ActivityMarkSize = "sm" | "md" | "lg";

export type MarketingLoopListVariant = "default" | "host";

export interface MarketingLoopListItem {
  body: ReactNode;
  key?: string;
  step: ReactNode;
  title: ReactNode;
}

export interface MarketingLoopListProps
  extends Omit<HTMLAttributes<HTMLOListElement>, "children"> {
  items: readonly MarketingLoopListItem[];
  reveal?: boolean;
  variant?: MarketingLoopListVariant;
}

export type MarketingSectionVariant =
  | "captures"
  | "download"
  | "featured-organizers"
  | "format"
  | "home-discovery"
  | "proof"
  | "proof-host"
  | "story"
  | "trust";

export type MarketingSectionCopyVariant = "download" | "proof";

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

export function AppleStoreMark() {
  return (
    <svg viewBox="0 0 24 24" role="img" focusable="false" aria-hidden="true">
      <path
        d="M16.48 12.74c.02-2.14 1.72-3.16 1.8-3.2-1.02-1.5-2.58-1.7-3.12-1.72-1.32-.14-2.6.78-3.27.78-.69 0-1.72-.76-2.83-.74-1.44.02-2.78.85-3.52 2.15-1.52 2.63-.39 6.5 1.07 8.63.73 1.04 1.58 2.2 2.7 2.16 1.09-.04 1.5-.69 2.82-.69 1.31 0 1.69.69 2.84.67 1.18-.02 1.92-1.05 2.62-2.1.84-1.2 1.17-2.39 1.18-2.45-.03-.01-2.26-.87-2.29-3.49Zm-2.18-6.32c.59-.74.99-1.74.88-2.76-.85.04-1.9.59-2.51 1.3-.55.64-1.04 1.68-.91 2.66.96.08 1.93-.48 2.54-1.2Z"
        fill="currentColor"
      />
    </svg>
  );
}

export function GooglePlayStoreMark() {
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

export interface CaptureRecord {
  id: string;
  webPath: string;
  alt: string;
  caption: string;
  walkthroughStep: string;
}
