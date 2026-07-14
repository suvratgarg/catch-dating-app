import type {HTMLAttributes, ReactNode} from "react";
import type {HostPreviewSectionVariant} from "./host";
import type {ChipRailItem} from "./layout2";
import {WaitlistSection} from "./forms";
import {classNames} from "./foundation";
import {hostPreviewSectionClassNames} from "./layout";
import {ChipRail} from "./layout2";

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
  items: readonly ReactNode[];
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
