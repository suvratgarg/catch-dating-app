import {forwardRef} from "react";
import {
  CheckboxControl,
  SelectControl,
  TextareaControl,
  TextInputControl,
} from "@catch/web-ui";
import type {FormHTMLAttributes, HTMLAttributes, InputHTMLAttributes, ReactNode, SelectHTMLAttributes, TextareaHTMLAttributes} from "react";
import type {FormStatus as FormStatusModel} from "../../forms/types";
import type {ChipRailItem} from "./layout2";
import {LiveStatus} from "./feedback";
import {classNames} from "./foundation";
import {ChipRail} from "./layout2";

export type SearchFormVariant = "organizer" | "public";

type FieldValidationProps = {
  descriptionId?: string;
  invalid?: boolean;
};

export function WaitlistSection({
  body,
  children,
  className,
  id,
  introReveal = true,
  title,
  titleId,
}: HTMLAttributes<HTMLElement> & {
  body: ReactNode;
  children: ReactNode;
  introReveal?: boolean;
  title: ReactNode;
  titleId: string;
}) {
  return (
    <section
      className={classNames("waitlist-section", className)}
      id={id}
      aria-labelledby={titleId}
    >
      <div className="waitlist__intro" data-reveal={introReveal || undefined}>
        <h2 id={titleId}>{title}</h2>
        <p>{body}</p>
      </div>
      {children}
    </section>
  );
}

export function MarketingFormatCard({
  body,
  className,
  mark,
  reveal = true,
  title,
  ...props
}: HTMLAttributes<HTMLElement> & {
  body: ReactNode;
  mark: ReactNode;
  reveal?: boolean;
  title: ReactNode;
}) {
  return (
    <article
      {...props}
      className={classNames("format-card", className)}
      data-reveal={reveal || undefined}
    >
      <span className="format-card__mark">{mark}</span>
      <h3>{title}</h3>
      <p>{body}</p>
    </article>
  );
}

export function ListingFormatRow({
  children,
  className,
  items,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children?: ReactNode;
  items?: ReactNode[];
}) {
  return (
    <div {...props} className={classNames("listing-format-row", className)}>
      {children ?? items?.map((item, index) => <span key={index}>{item}</span>)}
    </div>
  );
}

export function SelectedListingCard({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  children: ReactNode;
}) {
  return (
    <div {...props} className={classNames("selected-listing-card", className)}>
      {children}
    </div>
  );
}

export function PlaybookFormatNote({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLParagraphElement> & {children: ReactNode}) {
  return <p {...props} className={classNames("playbook-format-note", className)}>{children}</p>;
}

export interface HostCreateMockField {
  activeOption?: string;
  label: string;
  note?: ReactNode;
  options?: string[];
  value: ReactNode;
  wide?: boolean;
}

export function HostCreateFieldGrid({
  className,
  fields,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  fields: HostCreateMockField[];
}) {
  return (
    <div {...props} className={classNames("host-create-flow__fields", className)}>
      {fields.map((field) => (
        <div className={field.wide ? "is-wide" : ""} key={field.label}>
          <span className="ui-label">{field.label}</span>
          {field.options ? (
            <ChipRail
              aria-label={`${field.label}: ${field.value}`}
              className="host-create-flow__chips"
              itemElement="b"
              items={field.options.map((option) => ({
                active: option === field.activeOption,
                key: option,
                label: option,
              }))}
            />
          ) : (
            <strong>{field.value}</strong>
          )}
          {field.note ? <p>{field.note}</p> : null}
        </div>
      ))}
    </div>
  );
}

export function HostPreviewFormatRail({
  className,
  items,
  reveal = true,
  ...props
}: HTMLAttributes<HTMLDivElement> & {
  items: ChipRailItem[];
  reveal?: boolean;
}) {
  return (
    <ChipRail
      {...props}
      className={classNames("host-preview-format-rail", className)}
      items={items}
      reveal={reveal}
    />
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
  descriptionId,
  id,
  invalid,
  label,
  hidden,
  span,
  ...props
}: Omit<
  InputHTMLAttributes<HTMLInputElement>,
  "aria-describedby" | "aria-invalid" | "id"
> & FieldValidationProps & {
  id: string;
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
      <TextInputControl
        descriptionId={descriptionId}
        id={id}
        invalid={invalid}
        {...props}
      />
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
  descriptionId,
  id,
  invalid,
  label,
  hidden,
  span,
  ...props
}: Omit<
  SelectHTMLAttributes<HTMLSelectElement>,
  "aria-describedby" | "aria-invalid" | "id"
> & FieldValidationProps & {
  children: ReactNode;
  hidden?: boolean;
  id: string;
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
      <SelectControl
        descriptionId={descriptionId}
        id={id}
        invalid={invalid}
        {...props}
      >
        {children}
      </SelectControl>
    </Field>
  );
}

export function TextAreaField({
  className,
  descriptionId,
  id,
  invalid,
  label,
  hidden,
  span,
  ...props
}: Omit<
  TextareaHTMLAttributes<HTMLTextAreaElement>,
  "aria-describedby" | "aria-invalid" | "id"
> & FieldValidationProps & {
  hidden?: boolean;
  id: string;
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
      <TextareaControl
        descriptionId={descriptionId}
        id={id}
        invalid={invalid}
        {...props}
      />
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
      <CheckboxControl {...props} />
      {children}
    </label>
  );
}

export function ListingReviewCheckbox({
  className,
  ...props
}: Parameters<typeof CheckboxField>[0]) {
  return <CheckboxField {...props} className={classNames("listing-review-checkbox", className)} />;
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
    <LiveStatus className={classNames("form-status", status.tone)}>
      {status.message}
    </LiveStatus>
  );
}

export const Form = forwardRef<
  HTMLFormElement,
  FormHTMLAttributes<HTMLFormElement> & {reveal?: boolean}
>(function Form({
  children,
  reveal = false,
  ...props
}, ref) {
  return (
    <form data-reveal={reveal || undefined} ref={ref} {...props}>
      {children}
    </form>
  );
});

export const WaitlistFormShell = forwardRef<
  HTMLFormElement,
  FormHTMLAttributes<HTMLFormElement> & {reveal?: boolean}
>(function WaitlistFormShell({
  className,
  ...props
}, ref) {
  return (
    <Form
      {...props}
      className={classNames("waitlist-form", className)}
      ref={ref}
    />
  );
});

export const ListingReviewForm = forwardRef<
  HTMLFormElement,
  FormHTMLAttributes<HTMLFormElement> & {reveal?: boolean}
>(function ListingReviewForm({
  className,
  ...props
}, ref) {
  return (
    <Form
      {...props}
      className={classNames("listing-review-form", className)}
      ref={ref}
    />
  );
});

export const ClaimRequestForm = forwardRef<
  HTMLFormElement,
  FormHTMLAttributes<HTMLFormElement> & {reveal?: boolean}
>(function ClaimRequestForm({
  className,
  ...props
}, ref) {
  return (
    <Form
      {...props}
      className={classNames("claim-request-form", className)}
      ref={ref}
    />
  );
});

export const searchFormClassNames: Record<SearchFormVariant, string> = {
  organizer: "organizer-search-form",
  public: "public-search",
};
