import type {HTMLAttributes, ReactNode} from "react";
import type {HostPreviewSectionVariant} from "./host";
import {classNames} from "./foundation";
import {hostPreviewSectionClassNames} from "./layout";

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
