import type {
  AnchorHTMLAttributes,
  CSSProperties,
  HTMLAttributes,
  ReactNode,
} from "react";
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

export type ListingStatusLedgerItem = {
  key?: string;
  label: ReactNode;
  value: ReactNode;
};

export type ListingRailLinkItem = {
  href?: string;
  key?: string;
  label: ReactNode;
  onClick?: AnchorHTMLAttributes<HTMLAnchorElement>["onClick"];
  rel?: AnchorHTMLAttributes<HTMLAnchorElement>["rel"];
  target?: AnchorHTMLAttributes<HTMLAnchorElement>["target"];
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

export function ListingProfileLayout({
  activityToken,
  children,
  className,
  style,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  activityToken: string;
  children: ReactNode;
}) {
  return (
    <div
      {...props}
      className={classNames("listing-profile-layout", className)}
      style={{...style, "--activity": activityToken} as CSSProperties}
    >
      {children}
    </div>
  );
}

export function ListingProfilePrimary({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("listing-profile-primary", className)}>
      {children}
    </div>
  );
}

export function ListingProfileRail({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLElement> & {
  children: ReactNode;
}) {
  return (
    <aside {...props} className={classNames("listing-profile-rail", className)}>
      {children}
    </aside>
  );
}

export function ListingPolaroid({
  caption,
  fallback,
  media,
  provenance,
  title,
  titleId,
}: {
  caption: ReactNode;
  fallback: ReactNode;
  media: null | {
    alt: string;
    mobileSrcSet: string;
    src: string;
  };
  provenance: ReactNode;
  title: ReactNode;
  titleId: string;
}) {
  return (
    <article className="listing-polaroid" data-reveal>
      <div className="listing-polaroid__media">
        {media ? (
          <picture>
            <source media="(max-width: 640px)" srcSet={media.mobileSrcSet} />
            <img alt={media.alt} src={media.src} />
          </picture>
        ) : (
          <div className="listing-polaroid__fallback">{fallback}</div>
        )}
      </div>
      <div className="listing-polaroid__caption">
        <span>{caption}</span>
        <h1 id={titleId}>{title}</h1>
        <small>{provenance}</small>
      </div>
    </article>
  );
}

export function ListingStatusLedger({
  items,
}: {
  items: ListingStatusLedgerItem[];
}) {
  return (
    <dl className="listing-status-ledger" data-reveal>
      {items.map((item, index) => (
        <div key={item.key ?? (typeof item.label === "string" ? item.label : index)}>
          <dt>{item.label}</dt>
          <dd>{item.value}</dd>
        </div>
      ))}
    </dl>
  );
}

export function ListingRailIdentity({
  activity,
  eyebrow,
  location,
  name,
  status,
}: {
  activity: ReactNode;
  eyebrow: ReactNode;
  location: ReactNode;
  name: ReactNode;
  status: ReactNode;
}) {
  return (
    <div className="listing-profile-rail__identity">
      <UiLabel>{eyebrow}</UiLabel>
      {activity}
      <div>
        <h2>{name}</h2>
        <p>{location}</p>
      </div>
      <div className="listing-profile-rail__status">{status}</div>
    </div>
  );
}

export function ListingRailActions({
  children,
  description,
  shareStatus,
}: {
  children: ReactNode;
  description: ReactNode;
  shareStatus?: ReactNode;
}) {
  return (
    <div className="listing-profile-rail__actions">
      {children}
      <p>{description}</p>
      {shareStatus ? (
        <div className="listing-profile-rail__live">{shareStatus}</div>
      ) : null}
    </div>
  );
}

export function ListingRailSection({
  children,
  className,
  eyebrow,
  ...props
}: HTMLAttributes<HTMLElement> & {
  children: ReactNode;
  eyebrow: ReactNode;
}) {
  return (
    <section
      {...props}
      className={classNames("listing-profile-rail__section", className)}
    >
      <UiLabel>{eyebrow}</UiLabel>
      {children}
    </section>
  );
}

export function ListingRailLinkList({
  items,
}: {
  items: ListingRailLinkItem[];
}) {
  return (
    <ul className="listing-profile-rail__links">
      {items.map((item, index) => (
        <li key={item.key ?? (typeof item.label === "string" ? item.label : index)}>
          {item.href ? (
            <PlainLink
              href={item.href}
              onClick={item.onClick}
              rel={item.rel}
              target={item.target}
            >
              {item.label}
            </PlainLink>
          ) : (
            <span>{item.label}</span>
          )}
        </li>
      ))}
    </ul>
  );
}

export function ListingRailEmptyState({
  body,
  title,
}: {
  body: ReactNode;
  title: ReactNode;
}) {
  return (
    <div className="listing-profile-rail__empty">
      <strong>{title}</strong>
      <p>{body}</p>
    </div>
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
