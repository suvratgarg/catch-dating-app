import type {HTMLAttributes, ReactNode} from "react";
import type {StatStripItem} from "./foundation";
import type {MarketingInfoCardItem} from "./media";
import {classNames} from "./foundation";
import {PrivacyGuardrail} from "./feedback";
import {SuccessGrid, hostFeatureGridClassNames, hostFeatureRailClassNames, hostFeatureSectionClassNames, hostPageSectionClassNames} from "./layout";
import {NumberedRail} from "./layout2";
import {MarketingInfoCard} from "./media";

export type EventSuccessModuleGridItem = {
  attendee: ReactNode;
  host: ReactNode;
  stage: ReactNode;
  title: ReactNode;
};

export type HostPageSectionVariant = "evidence" | "fill-room" | "proof-ledger" | "surface";

export type HostFeatureSectionVariant = "comparison" | "create-flow" | "event-success";

export type HostFeatureGridVariant = "comparison-split" | "create-flow" | "event-success";

export type HostFeatureRailVariant = "create-flow" | "event-success";

export type HostPreviewSectionVariant =
  | "after"
  | "default"
  | "faq"
  | "live"
  | "loop"
  | "payments"
  | "product-split"
  | "trust";

export function HostHeroShell({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLElement> & {
  children: ReactNode;
}) {
  return (
    <section {...props} className={classNames("host-hero catch-dark", className)}>
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

export interface HostBridgeDemoGuest {
  name: ReactNode;
  status: ReactNode;
  time: ReactNode;
}

export function HostBridgeDemo({
  checkedInLabel,
  eventName,
  guestLabel,
  guestListLabel,
  guests,
  hostLabel,
  runtimeBody,
  runtimeItems,
  runtimeLabel,
  runtimeTitle,
  shareLabel,
  statusLabel,
  timeLabel,
}: {
  checkedInLabel: ReactNode;
  eventName: ReactNode;
  guestLabel: ReactNode;
  guestListLabel: ReactNode;
  guests: readonly HostBridgeDemoGuest[];
  hostLabel: ReactNode;
  runtimeBody: ReactNode;
  runtimeItems: readonly ReactNode[];
  runtimeLabel: ReactNode;
  runtimeTitle: ReactNode;
  shareLabel: ReactNode;
  statusLabel: ReactNode;
  timeLabel: ReactNode;
}) {
  const checkedInCount = guests.filter((guest) => guest.time !== "—").length;
  return (
    <div className="host-bridge-demo" data-reveal="scale">
      <div className="host-bridge-demo__console">
        <header>
          <div>
            <span>{hostLabel}</span>
            <strong>{eventName}</strong>
          </div>
          <span className="host-bridge-demo__share">{shareLabel}</span>
        </header>
        <div className="host-bridge-demo__summary">
          <span>{guestListLabel}</span>
          <strong>{checkedInCount}/{guests.length} {checkedInLabel}</strong>
        </div>
        <div className="host-bridge-demo__table" role="table">
          <div role="row">
            <span role="columnheader">{guestLabel}</span>
            <span role="columnheader">{statusLabel}</span>
            <span role="columnheader">{timeLabel}</span>
          </div>
          {guests.map((guest, index) => (
            <div key={index} role="row">
              <strong role="cell">{guest.name}</strong>
              <span role="cell">{guest.status}</span>
              <span role="cell">{guest.time}</span>
            </div>
          ))}
        </div>
      </div>
      <div className="host-bridge-demo__join" aria-hidden="true">
        {Array.from({length: 16}, (_, index) => <span key={index} />)}
      </div>
      <div className="host-bridge-demo__runtime">
        <span>{runtimeLabel}</span>
        <strong>{eventName}</strong>
        <h3>{runtimeTitle}</h3>
        <p>{runtimeBody}</p>
        <ul>
          {runtimeItems.map((item, index) => <li key={index}>{item}</li>)}
        </ul>
      </div>
    </div>
  );
}

export function HostCompatibilityLine({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLParagraphElement> & {children: ReactNode}) {
  return (
    <p {...props} className={classNames("host-compatibility-line", className)}>
      {children}
    </p>
  );
}

export function HostComparisonCallout({
  children,
  limits,
}: {
  children: ReactNode;
  limits: ReactNode;
}) {
  return (
    <>
      <PrivacyGuardrail className="host-comparison__callout">
        {children}
      </PrivacyGuardrail>
      <p className="host-comparison__limits">{limits}</p>
    </>
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
          <p><strong>{"For attendees:"}</strong> {item.attendee}</p>
          <p><strong>{"For hosts:"}</strong> {item.host}</p>
        </article>
      ))}
    </SuccessGrid>
  );
}

export function PlaybookIntro({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLDivElement> & {children: ReactNode}) {
  return <div {...props} className={classNames("playbook-intro", className)}>{children}</div>;
}

export function PlaybookStageCopy({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLDivElement> & {children: ReactNode}) {
  return <div {...props} className={classNames("playbook-stage-copy", className)}>{children}</div>;
}

export interface PlaybookCatalogItem {
  anchor: string;
  chip?: ReactNode;
  fits: ReactNode;
  id: string;
  more: ReactNode;
  oneLiner: ReactNode;
  publicName: ReactNode;
}

export function PlaybookCatalog({
  activeAnchor,
  className,
  items,
  onExpand,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  activeAnchor?: string;
  items: readonly PlaybookCatalogItem[];
  onExpand?: (id: string) => void;
}) {
  return (
    <div {...props} className={classNames("playbook-catalog", className)}>
      {items.map((item) => (
        <details
          id={item.anchor}
          key={item.id}
          open={activeAnchor === item.anchor || undefined}
          onToggle={(event) => {
            if (event.currentTarget.open) onExpand?.(item.id);
          }}
        >
          <summary>
            <span>
              <strong>{item.publicName}</strong>
              {item.chip ? <small>{item.chip}</small> : null}
            </span>
            <span>{item.oneLiner}</span>
          </summary>
          <p>{item.more}</p>
          <p><strong>{"Fits:"}</strong> {item.fits}</p>
        </details>
      ))}
    </div>
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
