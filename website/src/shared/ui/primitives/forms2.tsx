import {forwardRef} from "react";
import type {FormHTMLAttributes, InputHTMLAttributes, ReactNode} from "react";
import type {SearchFormVariant} from "./forms";
import {Form, InlineInputField, searchFormClassNames} from "./forms";
import {classNames} from "./foundation";

export const SearchFormShell = forwardRef<
  HTMLFormElement,
  FormHTMLAttributes<HTMLFormElement> & {
    reveal?: boolean;
    variant: SearchFormVariant;
  }
>(function SearchFormShell({
  children,
  className,
  reveal = false,
  variant,
  ...props
}, ref) {
  return (
    <Form
      {...props}
      className={classNames(searchFormClassNames[variant], className)}
      ref={ref}
      reveal={reveal}
    >
      {children}
    </Form>
  );
});

export function PublicSearchInputField({
  className,
  label,
  ...props
}: InputHTMLAttributes<HTMLInputElement> & {
  label: ReactNode;
}) {
  return (
    <InlineInputField
      {...props}
      className={classNames("public-search__input", className)}
      label={label}
    />
  );
}

export function FieldGrid({
  children,
  className,
}: {
  children: ReactNode;
  className?: string;
}) {
  return <div className={classNames("flow-field-grid", className)}>{children}</div>;
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
