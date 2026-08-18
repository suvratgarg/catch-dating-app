import type {FormHTMLAttributes, ReactNode} from "react";
import {PlainLink} from "./actions";
import {Form} from "./forms";

export function PublicFormFrame({
  brandLabel,
  brandWord,
  children,
  embed,
  organizerName,
}: {
  brandLabel: string;
  brandWord: string;
  children: ReactNode;
  embed: boolean;
  organizerName?: string | null;
}) {
  return (
    <div className="public-form" data-embed={embed || undefined}>
      <header className="public-form__brand">
        <PlainLink aria-label={brandLabel} href="/">
          {brandWord}<span>●</span>
        </PlainLink>
        {organizerName ? <span>{organizerName}</span> : null}
      </header>
      {children}
    </div>
  );
}

export function PublicFormPanel({
  body,
  children,
  kicker,
  title,
}: {
  body?: ReactNode;
  children: ReactNode;
  kicker: ReactNode;
  title: ReactNode;
}) {
  return (
    <main className="public-form__panel">
      <header className="public-form__intro">
        <p>{kicker}</p>
        <h1>{title}</h1>
        {body ? <p>{body}</p> : null}
      </header>
      {children}
    </main>
  );
}

export function PublicFormLoading({label}: {label: ReactNode}) {
  return <div className="public-form__loading" role="status"><span /><p>{label}</p></div>;
}

export function PublicFormProgress({
  current,
  label,
  total,
}: {
  current: number;
  label: ReactNode;
  total: number;
}) {
  const percent = total === 0 ? 0 : Math.round((current / total) * 100);
  return (
    <div className="public-form__progress">
      <span>{label}</span><strong>{percent}%</strong>
      <span aria-hidden="true"><i style={{width: `${percent}%`}} /></span>
    </div>
  );
}

export function PublicFormSection({
  children,
  description,
  title,
}: {
  children: ReactNode;
  description?: ReactNode;
  title: ReactNode;
}) {
  return (
    <section className="public-form__section">
      <header><h2>{title}</h2>{description ? <p>{description}</p> : null}</header>
      <div className="public-form__questions">{children}</div>
    </section>
  );
}

export function PublicFormQuestion({
  children,
  error,
  help,
  label,
  requiredLabel,
}: {
  children: ReactNode;
  error?: ReactNode;
  help?: ReactNode;
  label: ReactNode;
  requiredLabel?: ReactNode;
}) {
  return (
    <fieldset className="public-form__question">
      <legend>{label}{requiredLabel ? <small>{requiredLabel}</small> : null}</legend>
      {help ? <p>{help}</p> : null}
      {children}
      {error ? <p className="public-form__error" role="alert">{error}</p> : null}
    </fieldset>
  );
}

export function PublicFormActions({children}: {children: ReactNode}) {
  return <div className="public-form__actions">{children}</div>;
}

export function PublicFormChoiceList({children}: {children: ReactNode}) {
  return <div className="public-form__choices">{children}</div>;
}

export function PublicFormReview({children}: {children: ReactNode}) {
  return <dl className="public-form__review">{children}</dl>;
}

export function PublicFormReviewAnswer({
  answer,
  label,
}: {
  answer: ReactNode;
  label: ReactNode;
}) {
  return <div><dt>{label}</dt><dd>{answer}</dd></div>;
}

export function PublicFormConsent({children}: {children: ReactNode}) {
  return <aside className="public-form__consent">{children}</aside>;
}

export function PublicFormPrivacy({children}: {children: ReactNode}) {
  return <footer className="public-form__privacy">{children}</footer>;
}

export function PublicFormForm(
  props: FormHTMLAttributes<HTMLFormElement> & {pending?: boolean}
) {
  return <Form {...props} className="public-form__form" />;
}
