import {useEffect, useRef, useState} from "react";
import type {ChangeEvent, FormHTMLAttributes, PointerEvent, ReactNode} from "react";
import {Button, PlainLink} from "./actions";
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

export function PublicFormFileInput({
  accept,
  disabled,
  label,
  multiple,
  onFiles,
  status,
}: {
  accept: string;
  disabled?: boolean;
  label: ReactNode;
  multiple?: boolean;
  onFiles: (files: File[]) => void;
  status?: ReactNode;
}) {
  function change(event: ChangeEvent<HTMLInputElement>) {
    onFiles([...event.target.files ?? []]);
    event.target.value = "";
  }
  return (
    <div className="public-form__upload">
      <label aria-disabled={disabled || undefined}>
        <input
          accept={accept}
          disabled={disabled}
          multiple={multiple}
          onChange={change}
          type="file"
        />
        <span>{label}</span>
      </label>
      {status ? <p role="status">{status}</p> : null}
    </div>
  );
}

export function PublicFormSignatureInput({
  clearLabel,
  disabled,
  instruction,
  onSave,
  saveLabel,
  status,
  typedNameLabel,
}: {
  clearLabel: ReactNode;
  disabled?: boolean;
  instruction: ReactNode;
  onSave: (blob: Blob) => Promise<void> | void;
  saveLabel: ReactNode;
  status?: ReactNode;
  typedNameLabel: string;
}) {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const drawingRef = useRef(false);
  const [hasInk, setHasInk] = useState(false);
  const [typedName, setTypedName] = useState("");

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const bounds = canvas.getBoundingClientRect();
    const scale = Math.max(1, window.devicePixelRatio || 1);
    canvas.width = Math.round(bounds.width * scale);
    canvas.height = Math.round(bounds.height * scale);
    const context = canvas.getContext("2d");
    context?.scale(scale, scale);
    if (context) {
      context.lineCap = "round";
      context.lineJoin = "round";
      context.lineWidth = 2.4;
      context.strokeStyle = "#171512";
    }
  }, []);

  function point(event: PointerEvent<HTMLCanvasElement>) {
    const bounds = event.currentTarget.getBoundingClientRect();
    return {x: event.clientX - bounds.left, y: event.clientY - bounds.top};
  }

  function start(event: PointerEvent<HTMLCanvasElement>) {
    if (disabled) return;
    event.currentTarget.setPointerCapture(event.pointerId);
    const context = event.currentTarget.getContext("2d");
    const value = point(event);
    context?.beginPath();
    context?.moveTo(value.x, value.y);
    drawingRef.current = true;
  }

  function move(event: PointerEvent<HTMLCanvasElement>) {
    if (!drawingRef.current || disabled) return;
    const value = point(event);
    const context = event.currentTarget.getContext("2d");
    context?.lineTo(value.x, value.y);
    context?.stroke();
    setHasInk(true);
  }

  function stop(event: PointerEvent<HTMLCanvasElement>) {
    drawingRef.current = false;
    if (event.currentTarget.hasPointerCapture(event.pointerId)) {
      event.currentTarget.releasePointerCapture(event.pointerId);
    }
  }

  function clear() {
    const canvas = canvasRef.current;
    const context = canvas?.getContext("2d");
    if (canvas && context) {
      context.clearRect(0, 0, canvas.width, canvas.height);
    }
    setHasInk(false);
    setTypedName("");
  }

  async function save() {
    const canvas = canvasRef.current;
    if (!canvas) return;
    if (!hasInk && typedName.trim()) {
      const context = canvas.getContext("2d");
      if (context) {
        context.font = "italic 36px Georgia, serif";
        context.fillStyle = "#171512";
        context.fillText(typedName.trim(), 18, 78);
      }
    }
    const blob = await new Promise<Blob | null>((resolve) =>
      canvas.toBlob(resolve, "image/png"));
    if (blob) await onSave(blob);
  }

  return (
    <div className="public-form__signature">
      <p>{instruction}</p>
      <canvas
        aria-label={typedNameLabel}
        onPointerCancel={stop}
        onPointerDown={start}
        onPointerMove={move}
        onPointerUp={stop}
        ref={canvasRef}
        role="img"
      />
      <label>
        <span>{typedNameLabel}</span>
        <input
          disabled={disabled}
          onChange={(event) => setTypedName(event.target.value)}
          type="text"
          value={typedName}
        />
      </label>
      <div>
        <Button disabled={disabled} onClick={clear} type="button" variant="ghost">
          {clearLabel}
        </Button>
        <Button
          disabled={disabled || (!hasInk && !typedName.trim())}
          onClick={() => void save()}
          type="button"
        >
          {saveLabel}
        </Button>
      </div>
      {status ? <p role="status">{status}</p> : null}
    </div>
  );
}
