import {useEffect, useMemo, useRef, useState} from "react";
import {classNames} from "@catch/web-ui";
import type {CSSProperties, FormEvent, FormHTMLAttributes, HTMLAttributes, MouseEvent, ReactNode} from "react";
import type {ActionGroupVariant, ButtonSize, ButtonVariant} from "./actions";
import type {EmptyStateVariant} from "./feedback";
import type {ChipRailItem} from "./layout2";
import {PlainLink} from "./actions";
import {PublicSearchCityButton, PublicSearchSubmitButton} from "./actions2";
import {PublicSearchInputField, SearchFormShell} from "./forms2";
import {ChipRail, PublicSearchResultsPanel} from "./layout2";

export interface ActivityMeta {
  label: string;
  token: string;
  short: string;
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

export {classNames};

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

export function buttonClassName({
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

export const actionGroupClassNames: Record<ActionGroupVariant, string> = {
  flow: "flow-actions",
  hero: "hero__actions",
  "host-create-flow": "host-create-flow__actions",
};

export const listingHeroClassNames = {
  copy: "listing-hero__copy",
  eyebrow: "listing-hero__eyebrow",
  inner: "listing-hero__inner",
  shell: "listing-hero",
};

export function LiveMeter({
  className,
  items,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  items: readonly ReactNode[];
}) {
  return (
    <div {...props} className={classNames("live-meter", className)}>
      {items.map((item, index) => (
        <span key={index}>{item}</span>
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

export const emptyStateClassNames: Record<EmptyStateVariant, string | null> = {
  claim: "claim-empty-state",
  default: null,
  "listing-review": "listing-review-empty",
  "organizer-results": "empty-results",
  "public-event": "public-event-empty",
  "review-signal-lane": "review-signal-lane__empty",
};

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
        label={"Search Catch"}
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
