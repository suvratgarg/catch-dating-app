import {forwardRef, useState} from "react";
import type {AnchorHTMLAttributes, ButtonHTMLAttributes, CSSProperties, HTMLAttributes, MouseEvent, ReactNode} from "react";
import {ButtonControl} from "@catch/web-ui";
import type {AppDownloadStorePlatform} from "./marketing";
import {DataTable, StoreButton} from "./actions2";
import {LiveStatus, defaultAppDownloadPendingStatus} from "./feedback";
import {StatStrip, actionGroupClassNames, buttonClassName, classNames} from "./foundation";
import {UiLabel} from "./layout";

export type ButtonVariant = "primary" | "ghost" | "ghost-light";

export type ButtonSize = "default" | "small";

export type ActionGroupVariant = "flow" | "hero" | "host-create-flow";

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
  onActionClick?: (
    action: EventActionCardAction,
    event: MouseEvent<HTMLAnchorElement>
  ) => void;
  reveal?: boolean;
}

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

export const appDownloadCtaClassNames: Record<AppDownloadCtaVariant, string> = {
  compact: "app-download-ctas app-download-ctas--compact",
  default: "app-download-ctas",
  panel: "app-download-ctas app-download-ctas--panel",
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
