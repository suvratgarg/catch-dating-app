import type {AnchorHTMLAttributes, CSSProperties, HTMLAttributes, ReactNode} from "react";
import {PlainLink} from "./actions";
import {StatStrip, classNames, listingHeroClassNames} from "./foundation";
import {UiLabel, listingGridClassNames, listingSectionClassNames, organizerSearchSectionClassNames} from "./layout";
import {CardGrid} from "./layout2";

export interface ActivityListing {
  logo: {
    text: string;
  };
  status: string;
}

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

export type ListingSuccessMetricGridItem = {
  label: ReactNode;
  value: ReactNode;
};

export type ListingFactGridItem = {
  key?: string;
  label: ReactNode;
  value: ReactNode;
};

export type ListingNoteGridItem = {
  body: ReactNode;
  key?: string;
};

export type ListingSourceLedgerItem = {
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

export type ListingEventEvidenceItem = {
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

export type OrganizerSearchSectionVariant = "claim-pressure" | "hero" | "results";

export type ListingHeroElement = "section";

export type ListingGridVariant = "default" | "fit";

export type ListingSectionVariant =
  | "default"
  | "events"
  | "reviews"
  | "split"
  | "success";

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

export function ListingGrid({
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

export function ListingCard({
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
