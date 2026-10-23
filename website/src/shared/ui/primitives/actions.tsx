import {ButtonLink, PlainButton, PlainLink, buttonClassName} from "./actionControls";
import type {ButtonSize, ButtonVariant} from "./actionControls";

import type {
  AnchorHTMLAttributes,
  ButtonHTMLAttributes,
  CSSProperties,
  HTMLAttributes,
  MouseEvent,
  ReactNode,
} from "react";
import {ButtonControl, classNames} from "@catch/web-ui";
import type {AppDownloadStorePlatform} from "./marketing";

import {StatStrip, actionGroupClassNames} from "./foundation";
import {UiLabel} from "./layout";

export {ButtonLink, PlainButton, PlainLink} from "./actionControls";
export type {ButtonSize, ButtonVariant} from "./actionControls";

export type ActionGroupVariant = "flow" | "hero" | "host-create-flow" | "marketing";

export interface ProcessStatusAction {
  href: string;
  label: ReactNode;
  onClick?: AnchorHTMLAttributes<HTMLAnchorElement>["onClick"];
  rel?: AnchorHTMLAttributes<HTMLAnchorElement>["rel"];
  target?: AnchorHTMLAttributes<HTMLAnchorElement>["target"];
  trackingLabel?: string;
  variant?: "primary" | "secondary";
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
  badge?: ReactNode;
  onActionClick?: (
    action: EventActionCardAction,
    event: MouseEvent<HTMLAnchorElement>
  ) => void;
  reveal?: boolean;
}

export interface AppDownloadCtaItem {
  href: string;
  kicker: string;
  label: string;
  platform: AppDownloadStorePlatform;
}

export function Button({
  children,
  className,
  loading = false,
  loadingLabel,
  size,
  variant,
  ...props
}: ButtonHTMLAttributes<HTMLButtonElement> & {
  children: ReactNode;
  loading?: boolean;
  loadingLabel?: ReactNode;
  size?: ButtonSize;
  variant?: ButtonVariant;
}) {
  return (
    <ButtonControl
      className={buttonClassName({className, size, variant})}
      loading={loading}
      {...props}
    >
      {loading ? loadingLabel ?? children : children}
    </ButtonControl>
  );
}

export function EventActionCard({
  className,
  event,
  badge,
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
        {badge}
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
      {event.actions.length ? (
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
      ) : null}
    </article>
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
