import {forwardRef} from "react";
import type {FormHTMLAttributes, HTMLAttributes, ReactNode} from "react";
import {Form} from "./forms";
import {classNames} from "./foundation";

export interface HostPreviewTrustItem {
  key?: string;
  title: ReactNode;
  body: ReactNode;
}

export function HostPreviewTrustGrid({
  className,
  items,
  reveal = false,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  items: readonly HostPreviewTrustItem[];
  reveal?: boolean;
}) {
  return (
    <div {...props} className={classNames("host-preview-trust__grid", className)}>
      {items.map((item, index) => (
        <article data-reveal={reveal || undefined} key={item.key ?? String(item.title) ?? index}>
          <h3>{item.title}</h3>
          <p>{item.body}</p>
        </article>
      ))}
    </div>
  );
}

export interface HostPreviewFaqItem {
  answer: ReactNode;
  key?: string;
  question: ReactNode;
}

export function HostPreviewFaqList({
  className,
  items,
  reveal = false,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  items: HostPreviewFaqItem[];
  reveal?: boolean;
}) {
  return (
    <div {...props} className={classNames("host-preview-faq__list", className)}>
      {items.map((item, index) => (
        <details data-reveal={reveal || undefined} key={item.key ?? String(item.question) ?? index}>
          <summary>{item.question}</summary>
          <p>{item.answer}</p>
        </details>
      ))}
    </div>
  );
}

export const HostApplicationShell = forwardRef<
  HTMLFormElement,
  FormHTMLAttributes<HTMLFormElement> & {reveal?: boolean}
>(function HostApplicationShell({
  children,
  className,
  reveal = false,
  ...props
}, ref) {
  return (
    <Form
      {...props}
      className={classNames("host-application", className)}
      ref={ref}
      reveal={reveal}
    >
      {children}
    </Form>
  );
});

export function HostApplicationPanel({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("host-application__panel", className)}>
      {children}
    </div>
  );
}

export function HostApplicationStage({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("host-application__stage", className)}>
      {children}
    </div>
  );
}

export function HostApplicationSubmitted({
  body,
  className,
  label,
  mark = "✓",
  title,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  body: ReactNode;
  label: ReactNode;
  mark?: ReactNode;
  title: ReactNode;
}) {
  return (
    <div {...props} className={classNames("host-application__submitted", className)}>
      <span className="submitted-panel__mark" aria-hidden="true">{mark}</span>
      <div>
        <span className="ui-label">{label}</span>
        <h3>{title}</h3>
        <p>{body}</p>
      </div>
    </div>
  );
}

export function HostApplicationReviewGrid({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("host-application__review", className)}>
      {children}
    </div>
  );
}

export function HostApplicationReviewCard({
  className,
  fallback = "Not provided",
  rows,
  title,
  ...props
}: HTMLAttributes<HTMLElement> & {
  fallback?: ReactNode;
  rows: Array<[ReactNode, ReactNode]>;
  title: ReactNode;
}) {
  return (
    <article {...props} className={className}>
      <span className="ui-label">{title}</span>
      <dl>
        {rows.map(([label, value], index) => (
          <div key={typeof label === "string" ? label : index}>
            <dt>{label}</dt>
            <dd>{value || fallback}</dd>
          </div>
        ))}
      </dl>
    </article>
  );
}

export function HostApplicationCompletenessSummary({
  className,
  items,
  label,
  meter,
  pendingMark = "·",
  doneMark = "✓",
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  doneMark?: ReactNode;
  items: Array<{done: boolean; label: ReactNode}>;
  label: ReactNode;
  meter: ReactNode;
  pendingMark?: ReactNode;
}) {
  return (
    <div {...props} className={classNames("host-application__summary", className)}>
      <div>
        <span className="ui-label">{label}</span>
        {meter}
      </div>
      <ul>
        {items.map((item, index) => (
          <li className={item.done ? "is-done" : undefined} key={index}>
            <span aria-hidden="true">{item.done ? doneMark : pendingMark}</span>
            {item.label}
          </li>
        ))}
      </ul>
    </div>
  );
}
