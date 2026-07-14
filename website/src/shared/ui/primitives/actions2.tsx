import type {AnchorHTMLAttributes, ButtonHTMLAttributes, CSSProperties, HTMLAttributes, MouseEvent, ReactNode} from "react";
import {DataTableControl} from "@catch/web-ui";
import type {AppDownloadCtaItem} from "./actions";
import {PlainButton, PlainLink} from "./actions";
import {classNames} from "./foundation";
import {AppleStoreMark, GooglePlayStoreMark} from "./media";

export function StoreButtonMark({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLSpanElement> & {
  children: ReactNode;
}) {
  return (
    <span
      {...props}
      className={classNames("store-button__mark", className)}
      aria-hidden={props["aria-hidden"] ?? "true"}
    >
      {children}
    </span>
  );
}

export function StoreButtonKicker({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLSpanElement> & {
  children: ReactNode;
}) {
  return (
    <span {...props} className={classNames("store-button__kicker", className)}>
      {children}
    </span>
  );
}

export function StoreButtonAction({
  children,
  className,
  pending = false,
  ...props
}: ButtonHTMLAttributes<HTMLButtonElement> & {
  children: ReactNode;
  pending?: boolean;
}) {
  return (
    <PlainButton
      {...props}
      className={classNames("store-button", pending && "is-pending", className)}
      type={props.type ?? "button"}
    >
      {children}
    </PlainButton>
  );
}

export function StoreButtonLink({
  children,
  className,
  ...props
}: AnchorHTMLAttributes<HTMLAnchorElement> & {
  children: ReactNode;
}) {
  return (
    <PlainLink {...props} className={classNames("store-button", className)}>
      {children}
    </PlainLink>
  );
}

export function StoreButton({
  item,
  statusId,
  onPendingClick,
  onStoreLinkClick,
}: {
  item: AppDownloadCtaItem;
  statusId: string;
  onPendingClick: (
    item: AppDownloadCtaItem,
    event: MouseEvent<HTMLButtonElement>
  ) => void;
  onStoreLinkClick: (
    item: AppDownloadCtaItem,
    event: MouseEvent<HTMLAnchorElement>
  ) => void;
}) {
  const content = (
    <>
      <StoreButtonMark>
        {item.platform === "ios" ? <AppleStoreMark /> : <GooglePlayStoreMark />}
      </StoreButtonMark>
      <span>
        <StoreButtonKicker>{item.kicker}</StoreButtonKicker>
        <strong>{item.label}</strong>
      </span>
    </>
  );

  if (!item.href) {
    return (
      <StoreButtonAction
        pending
        aria-describedby={statusId}
        onClick={(event) => onPendingClick(item, event)}
      >
        {content}
      </StoreButtonAction>
    );
  }

  return (
    <StoreButtonLink
      href={item.href}
      target="_blank"
      rel="noreferrer"
      onClick={(event) => onStoreLinkClick(item, event)}
    >
      {content}
    </StoreButtonLink>
  );
}

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

export function FeaturedOrganizersCta({
  body,
  children,
  className,
  reveal = false,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  body: ReactNode;
  children: ReactNode;
  reveal?: boolean;
}) {
  return (
    <div
      {...props}
      className={classNames("featured-organizers__cta", className)}
      data-reveal={reveal || undefined}
    >
      <p>{body}</p>
      {children}
    </div>
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

export function PublicSearchCityButton({
  children,
  className,
  ...props
}: ButtonHTMLAttributes<HTMLButtonElement> & {
  children: ReactNode;
}) {
  return (
    <PlainButton
      {...props}
      className={classNames("public-search__city", className)}
      type={props.type ?? "button"}
    >
      {children}
    </PlainButton>
  );
}

export function PublicSearchSubmitButton({
  children = "Search",
  className,
  ...props
}: ButtonHTMLAttributes<HTMLButtonElement> & {
  children?: ReactNode;
}) {
  return (
    <PlainButton
      {...props}
      className={classNames("public-search__go", className)}
      type="submit"
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
