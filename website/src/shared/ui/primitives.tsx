import type {
  AnchorHTMLAttributes,
  ButtonHTMLAttributes,
  InputHTMLAttributes,
  ReactNode,
  SelectHTMLAttributes,
  TextareaHTMLAttributes,
} from "react";
import type {FormStatus as FormStatusModel} from "../forms/types";

type ButtonVariant = "primary" | "ghost" | "ghost-light";
type ButtonSize = "default" | "small";

function classNames(...values: Array<string | false | null | undefined>) {
  return values.filter(Boolean).join(" ");
}

function buttonClassName({
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

export function Button({
  children,
  className,
  size,
  variant,
  ...props
}: ButtonHTMLAttributes<HTMLButtonElement> & {
  children: ReactNode;
  size?: ButtonSize;
  variant?: ButtonVariant;
}) {
  return (
    <button className={buttonClassName({className, size, variant})} {...props}>
      {children}
    </button>
  );
}

export function ButtonLink({
  children,
  className,
  size,
  variant,
  ...props
}: AnchorHTMLAttributes<HTMLAnchorElement> & {
  children: ReactNode;
  size?: ButtonSize;
  variant?: ButtonVariant;
}) {
  return (
    <a className={buttonClassName({className, size, variant})} {...props}>
      {children}
    </a>
  );
}

export function PlainButton({
  children,
  className,
  ...props
}: ButtonHTMLAttributes<HTMLButtonElement> & {
  children: ReactNode;
}) {
  return (
    <button className={className} {...props}>
      {children}
    </button>
  );
}

export function PlainLink({
  children,
  className,
  ...props
}: AnchorHTMLAttributes<HTMLAnchorElement> & {
  children: ReactNode;
}) {
  return (
    <a className={className} {...props}>
      {children}
    </a>
  );
}

export function TextActionButton({
  children,
  className,
  ...props
}: ButtonHTMLAttributes<HTMLButtonElement> & {
  children: ReactNode;
}) {
  return (
    <PlainButton className={classNames("see-all-button", className)} type="button" {...props}>
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

export function Field({
  children,
  className,
  hidden,
  label,
  span = false,
}: {
  children: ReactNode;
  className?: string;
  hidden?: boolean;
  label?: ReactNode;
  span?: boolean;
}) {
  return (
    <div className={classNames("field-block", span && "span-2", className)} hidden={hidden}>
      {label}
      {children}
    </div>
  );
}

export function TextField({
  className,
  id,
  label,
  hidden,
  span,
  ...props
}: InputHTMLAttributes<HTMLInputElement> & {
  label: ReactNode;
  hidden?: boolean;
  span?: boolean;
}) {
  return (
    <Field
      className={className}
      hidden={hidden}
      span={span}
      label={<label htmlFor={id}>{label}</label>}
    >
      <input id={id} {...props} />
    </Field>
  );
}

export function InlineInputField({
  className,
  label,
  ...props
}: InputHTMLAttributes<HTMLInputElement> & {
  label: ReactNode;
}) {
  return (
    <label className={className}>
      <span>{label}</span>
      <input {...props} />
    </label>
  );
}

export function SelectField({
  children,
  className,
  id,
  label,
  hidden,
  span,
  ...props
}: SelectHTMLAttributes<HTMLSelectElement> & {
  children: ReactNode;
  hidden?: boolean;
  label: ReactNode;
  span?: boolean;
}) {
  return (
    <Field
      className={className}
      hidden={hidden}
      span={span}
      label={<label htmlFor={id}>{label}</label>}
    >
      <select id={id} {...props}>
        {children}
      </select>
    </Field>
  );
}

export function TextAreaField({
  className,
  id,
  label,
  hidden,
  span,
  ...props
}: TextareaHTMLAttributes<HTMLTextAreaElement> & {
  hidden?: boolean;
  label: ReactNode;
  span?: boolean;
}) {
  return (
    <Field
      className={className}
      hidden={hidden}
      span={span}
      label={<label htmlFor={id}>{label}</label>}
    >
      <textarea id={id} {...props} />
    </Field>
  );
}

export function CheckboxField({
  children,
  className,
  ...props
}: InputHTMLAttributes<HTMLInputElement> & {
  children: ReactNode;
}) {
  return (
    <label className={className}>
      <input type="checkbox" {...props} />
      {children}
    </label>
  );
}

export function HoneypotField({
  name = "website",
}: {
  name?: string;
}) {
  return (
    <input
      aria-hidden="true"
      autoComplete="off"
      className="honeypot"
      name={name}
      tabIndex={-1}
    />
  );
}

export function FormStatus({
  status,
}: {
  status: FormStatusModel;
}) {
  return (
    <p className={classNames("form-status", status.tone)} role="status" aria-live="polite">
      {status.message}
    </p>
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

export function StepRail<TId extends string>({
  currentIndex,
  getDisabled,
  items,
  label,
  onSelect,
}: {
  currentIndex: number;
  getDisabled?: (item: {id: TId}, index: number) => boolean;
  items: Array<{id: TId; label: string; body?: string}>;
  label: string;
  onSelect: (id: TId) => void;
}) {
  return (
    <nav className="operational-step-rail" aria-label={label}>
      {items.map((item, index) => (
        <button
          className={index === currentIndex ? "is-active" : index < currentIndex ? "is-done" : ""}
          disabled={getDisabled?.(item, index)}
          key={item.id}
          onClick={() => onSelect(item.id)}
          type="button"
        >
          <span>{String(index + 1).padStart(2, "0")}</span>
          <strong>{item.label}</strong>
          {item.body ? <small>{item.body}</small> : null}
        </button>
      ))}
    </nav>
  );
}

export function ChoiceChip({
  children,
  selected,
  ...props
}: ButtonHTMLAttributes<HTMLButtonElement> & {
  children: ReactNode;
  selected: boolean;
}) {
  return (
    <button
      className={classNames("choice-chip", selected && "is-selected")}
      type="button"
      {...props}
    >
      {children}
    </button>
  );
}

export function ChoiceChipGrid({children}: {children: ReactNode}) {
  return <div className="choice-chip-grid">{children}</div>;
}

export function ChoiceCard({
  body,
  selected,
  title,
  ...props
}: ButtonHTMLAttributes<HTMLButtonElement> & {
  body: ReactNode;
  selected: boolean;
  title: ReactNode;
}) {
  return (
    <button
      className={classNames("choice-card", selected && "is-selected")}
      type="button"
      {...props}
    >
      <strong>{title}</strong>
      <span>{body}</span>
    </button>
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

export function AuthStatusRow({
  action,
  children,
  className,
}: {
  action: ReactNode;
  children: ReactNode;
  className?: string;
}) {
  return (
    <div className={classNames("claim-auth-row", className)}>
      <span>{children}</span>
      {action}
    </div>
  );
}
