import type {ButtonHTMLAttributes, CSSProperties, ReactNode} from "react";
import {DataTableControl, classNames} from "@catch/web-ui";

import {PlainButton} from "./actionControls";

export function ClaimResultButton({
  activityToken,
  children,
  className,
  selected = false,
  style,
  ...props
}: ButtonHTMLAttributes<HTMLButtonElement> & {
  activityToken: string;
  children: ReactNode;
  selected?: boolean;
}) {
  return (
    <PlainButton
      {...props}
      className={classNames("claim-result", selected && "is-selected", className)}
      style={{...style, "--activity": activityToken} as CSSProperties}
      type={props.type ?? "button"}
    >
      {children}
    </PlainButton>
  );
}

export function ToggleChipButton({
  children,
  className,
  selected,
  ...props
}: ButtonHTMLAttributes<HTMLButtonElement> & {
  children: ReactNode;
  selected: boolean;
}) {
  return (
    <PlainButton
      aria-pressed={selected}
      className={classNames("filter-chip-button", selected && "is-on", className)}
      type="button"
      {...props}
    >
      {children}
    </PlainButton>
  );
}

export function DataTable({
  ariaLabel,
  children,
  className,
  reveal = false,
  tableClassName,
}: {
  ariaLabel: string;
  children: ReactNode;
  className?: string;
  reveal?: boolean;
  tableClassName?: string;
}) {
  return (
    <DataTableControl
      ariaLabel={ariaLabel}
      className={className}
      data-reveal={reveal || undefined}
      tableClassName={tableClassName}
    >
      {children}
    </DataTableControl>
  );
}
