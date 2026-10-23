import {forwardRef} from "react";
import type {FormHTMLAttributes} from "react";
import type {SearchFormVariant} from "./forms";
import {Form, searchFormClassNames} from "./forms";
import {ButtonControl, classNames} from "@catch/web-ui";

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
        <ButtonControl
          aria-current={index === currentIndex ? "step" : undefined}
          className={index === currentIndex ? "is-active" : index < currentIndex ? "is-done" : ""}
          disabled={getDisabled?.(item, index)}
          key={item.id}
          onClick={() => onSelect(item.id)}
          type="button"
        >
          <span>{String(index + 1).padStart(2, "0")}</span>
          <strong>{item.label}</strong>
          {item.body ? <small>{item.body}</small> : null}
        </ButtonControl>
      ))}
    </nav>
  );
}
