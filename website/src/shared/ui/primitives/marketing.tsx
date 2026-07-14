import type {HTMLAttributes, ReactNode} from "react";
import type {StatStripItem} from "./foundation";
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
    <section {...props} className={classNames("hero hero--home", className)}>
      {children}
    </section>
  );
}

export function HomeHeroInner({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("hero__inner", className)}>
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

export function EvidenceStrip({
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
      className={classNames("evidence-strip", className)}
      data-reveal={reveal || undefined}
    >
      {items.map((item, index) => (
        <div key={item.key ?? index}>
          <strong>{item.value}</strong>
          <span>{item.label}</span>
        </div>
      ))}
    </div>
  );
}

export interface ProofLedgerItem {
  key?: string;
  label: ReactNode;
  proof: ReactNode;
}

export function ProofLedgerRows({
  className,
  items,
  reveal = false,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  items: ProofLedgerItem[];
  reveal?: boolean;
}) {
  return (
    <div {...props} className={classNames("proof-ledger__rows", className)}>
      {items.map((item, index) => (
        <article data-reveal={reveal || undefined} key={item.key ?? index}>
          <strong>{item.label}</strong>
          <p>{item.proof}</p>
        </article>
      ))}
    </div>
  );
}
