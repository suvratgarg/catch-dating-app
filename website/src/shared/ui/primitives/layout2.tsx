import {ToggleButtonControl, ToggleGroupControl} from "@catch/web-ui";
import type {ButtonHTMLAttributes, HTMLAttributes, ReactNode} from "react";
import type {ModuleStackItem} from "./layout";
import {PlainButton} from "./actions";
import {classNames} from "./foundation";
import {ProductShell} from "./layout";

export function ModuleStack({
  className,
  items,
  reveal = false,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  items: ModuleStackItem[];
  reveal?: boolean;
}) {
  return (
    <ProductShell {...props} className={className} reveal={reveal} variant="module-stack">
      {items.map((item, index) => (
        <article key={item.key ?? index}>
          <span>{item.label}</span>
          <strong>{item.title}</strong>
          <p>{item.body}</p>
        </article>
      ))}
    </ProductShell>
  );
}

export interface ChipRailItem {
  active?: boolean;
  key?: string;
  label: ReactNode;
}

export function ChipRail({
  className,
  itemElement = "span",
  items,
  reveal = false,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  itemElement?: "span" | "b";
  items: ChipRailItem[];
  reveal?: boolean;
}) {
  return (
    <div
      {...props}
      className={classNames("chip-rail", className)}
      data-reveal={reveal || undefined}
    >
      {items.map((item, index) => {
        const itemKey = item.key ?? index;
        const itemClassName = item.active ? "is-active" : undefined;
        return itemElement === "b" ? (
          <b className={itemClassName} key={itemKey}>{item.label}</b>
        ) : (
          <span className={itemClassName} key={itemKey}>{item.label}</span>
        );
      })}
    </div>
  );
}

export function CardGrid({
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
      className={classNames("card-grid", className)}
      data-reveal={reveal || undefined}
    >
      {children}
    </div>
  );
}

export function FilterRail({
  children,
  className,
  reveal = false,
}: {
  children: ReactNode;
  className?: string;
  reveal?: boolean;
}) {
  return (
    <div
      className={classNames("organizer-filter-rail", className)}
      data-reveal={reveal || undefined}
    >
      {children}
    </div>
  );
}

export function PublicSearchResultsPanel({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("public-search__results", className)}>
      {children}
    </div>
  );
}

export function NumberedRail<TId extends string>({
  activeId,
  bodyVisibility = "active",
  className,
  items,
  label,
  onSelect,
  reveal = false,
}: {
  activeId: TId;
  bodyVisibility?: "active" | "always";
  className: string;
  items: Array<{id: TId; label: ReactNode; body?: ReactNode}>;
  label: string;
  onSelect: (id: TId) => void;
  reveal?: boolean;
}) {
  return (
    <div className={className} aria-label={label} data-reveal={reveal || undefined}>
      {items.map((item, index) => {
        const active = item.id === activeId;
        return (
          <PlainButton
            aria-current={active ? "step" : undefined}
            aria-expanded={active}
            className={active ? "is-active" : ""}
            key={item.id}
            onClick={() => onSelect(item.id)}
            type="button"
          >
            <span>{String(index + 1).padStart(2, "0")}</span>
            <strong>{item.label}</strong>
            {item.body && (bodyVisibility === "always" || active) ? <small>{item.body}</small> : null}
          </PlainButton>
        );
      })}
    </div>
  );
}

export function ChoiceChip({
  children,
  selected,
  ...props
}: Omit<ButtonHTMLAttributes<HTMLButtonElement>, "aria-pressed" | "type"> & {
  children: ReactNode;
  selected: boolean;
}) {
  return (
    <ToggleButtonControl
      className={classNames("choice-chip", selected && "is-selected")}
      selected={selected}
      {...props}
    >
      {children}
    </ToggleButtonControl>
  );
}

export function ChoiceChipGrid({
  children,
  className,
  ...props
}: Parameters<typeof ToggleGroupControl>[0]) {
  return (
    <ToggleGroupControl
      {...props}
      className={classNames("choice-chip-grid", className)}
    >
      {children}
    </ToggleGroupControl>
  );
}

export function ChoiceCard({
  body,
  selected,
  title,
  ...props
}: Omit<ButtonHTMLAttributes<HTMLButtonElement>, "aria-pressed" | "type"> & {
  body: ReactNode;
  selected: boolean;
  title: ReactNode;
}) {
  return (
    <ToggleButtonControl
      className={classNames("choice-card", selected && "is-selected")}
      selected={selected}
      {...props}
    >
      <strong>{title}</strong>
      <span>{body}</span>
    </ToggleButtonControl>
  );
}

export function MetricCard({
  label,
  value,
}: {
  label: ReactNode;
  value: ReactNode;
}) {
  return (
    <article className="listing-card" data-reveal>
      <span>{label}</span>
      <strong>{value}</strong>
    </article>
  );
}
