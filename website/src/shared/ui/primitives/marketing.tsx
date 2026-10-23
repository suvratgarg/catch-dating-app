import type {HTMLAttributes, ReactNode} from "react";
import {classNames} from "./foundation";

export type AppDownloadStorePlatform = "android" | "ios";

export function HomeHeroShell({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLElement> & {
  children: ReactNode;
}) {
  return (
    <section {...props} className={classNames("hero hero--home catch-dark", className)}>
      {children}
    </section>
  );
}

export function HomeHeroInner({
  children,
  className,
  layout = "split",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
  layout?: "split" | "content";
}) {
  return (
    <div {...props} className={classNames("hero__inner", layout === "content" && "hero__inner--content", className)}>
      {children}
    </div>
  );
}

export function HomeHeroCopy({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("hero__copy", className)}>
      {children}
    </div>
  );
}

export function HomeHeroBody({
  children,
  className,
  reveal = false,
  ...props
}: HTMLAttributes<HTMLParagraphElement> & {
  children: ReactNode;
  reveal?: boolean;
}) {
  return (
    <p
      {...props}
      className={classNames("hero__body", className)}
      data-reveal={reveal || undefined}
    >
      {children}
    </p>
  );
}
