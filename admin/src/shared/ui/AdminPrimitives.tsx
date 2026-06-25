import type {
  AnchorHTMLAttributes,
  ButtonHTMLAttributes,
  InputHTMLAttributes,
  ReactNode,
  SelectHTMLAttributes,
  TextareaHTMLAttributes,
} from "react";

type SelectOption = string | {label: ReactNode; value: string};

type ChipTone = "neutral" | "muted" | "warning" | "success" | "danger";
type AlertTone = "neutral" | "warning" | "success" | "blocked";
type TagTone = "neutral" | "muted";
type RiskTone = "low" | "medium" | "high" | "watch";

export function AdminButton({
  children,
  className = "",
  icon,
  selected = false,
  type = "button",
  variant = "ghost",
  ...props
}: {
  children: ReactNode;
  className?: string;
  icon?: ReactNode;
  selected?: boolean;
  variant?: "ghost" | "primary";
} & ButtonHTMLAttributes<HTMLButtonElement>) {
  const classes = [
    variant === "primary" ? "primary-button" : "ghost-button",
    selected ? "selected" : "",
    className,
  ].filter(Boolean).join(" ");
  return (
    <button className={classes} type={type} {...props}>
      {icon}
      {children}
    </button>
  );
}

export function AdminIconButton({
  children,
  className = "",
  label,
  title,
  type = "button",
  ...props
}: {
  children: ReactNode;
  className?: string;
  label: string;
} & ButtonHTMLAttributes<HTMLButtonElement>) {
  return (
    <button
      aria-label={label}
      className={`icon-button ${className}`.trim()}
      title={title ?? label}
      type={type}
      {...props}
    >
      {children}
    </button>
  );
}

export function AdminLinkButton({
  children,
  className = "",
  icon,
  label,
  variant = "ghost",
  ...props
}: {
  children?: ReactNode;
  className?: string;
  icon?: ReactNode;
  label?: string;
  variant?: "ghost" | "icon";
} & AnchorHTMLAttributes<HTMLAnchorElement>) {
  const classes = [
    variant === "icon" ? "icon-button" : "ghost-button",
    className,
  ].filter(Boolean).join(" ");
  return (
    <a
      aria-label={label}
      className={classes}
      title={props.title ?? label}
      {...props}
    >
      {icon}
      {children}
    </a>
  );
}

export function FilePickerButton({
  children,
  className = "",
  icon,
  inputLabel,
  ...props
}: {
  children: ReactNode;
  className?: string;
  icon?: ReactNode;
  inputLabel: string;
} & Omit<InputHTMLAttributes<HTMLInputElement>, "aria-label" | "type">) {
  return (
    <label className={`ghost-button ${className}`.trim()}>
      {icon}
      {children}
      <input aria-label={inputLabel} type="file" {...props} />
    </label>
  );
}

export function AdminNavButton({
  icon,
  label,
  selected,
  type = "button",
  ...props
}: {
  icon: ReactNode;
  label: string;
  selected: boolean;
} & ButtonHTMLAttributes<HTMLButtonElement>) {
  return (
    <button
      className={`nav-item ${selected ? "selected" : ""}`}
      type={type}
      {...props}
    >
      {icon}
      <span>{label}</span>
    </button>
  );
}

export function SearchField({
  ariaLabel,
  className = "",
  icon,
  onChange,
  value,
  ...props
}: {
  ariaLabel: string;
  className?: string;
  icon?: ReactNode;
  onChange?: (value: string) => void;
  value?: string;
} & Omit<InputHTMLAttributes<HTMLInputElement>, "aria-label" | "onChange" | "value">) {
  return (
    <div className={`search-control ${className}`.trim()}>
      {icon}
      <input
        aria-label={ariaLabel}
        onChange={(event) => onChange?.(event.target.value)}
        value={value}
        {...props}
      />
    </div>
  );
}

export function InlineTextField({
  ariaLabel,
  className = "",
  onChange,
  value,
  ...props
}: {
  ariaLabel: string;
  className?: string;
  onChange: (value: string) => void;
  value: string;
} & Omit<InputHTMLAttributes<HTMLInputElement>, "aria-label" | "className" | "onChange" | "value">) {
  return (
    <input
      aria-label={ariaLabel}
      className={className}
      onChange={(event) => onChange(event.target.value)}
      value={value}
      {...props}
    />
  );
}

export function SegmentedControl<T extends string>({
  ariaLabel,
  className = "",
  options,
  value,
  onChange,
}: {
  ariaLabel: string;
  className?: string;
  options: Array<{disabled?: boolean; id: T; label: ReactNode}>;
  value: T;
  onChange: (value: T) => void;
}) {
  return (
    <div className={`segmented ${className}`.trim()} aria-label={ariaLabel}>
      {options.map((option) => (
        <button
          className={value === option.id ? "selected" : ""}
          disabled={option.disabled}
          key={option.id}
          onClick={() => onChange(option.id)}
          type="button"
        >
          {option.label}
        </button>
      ))}
    </div>
  );
}

export function StatusBanner({
  children,
  icon,
  tone,
}: {
  children: ReactNode;
  icon: ReactNode;
  tone: "error" | "success";
}) {
  return (
    <div
      className={tone === "error" ? "error-banner" : "success-banner"}
      role={tone === "error" ? "alert" : "status"}
    >
      {icon}
      <span>{children}</span>
    </div>
  );
}

export function EmptyState({
  children,
  className = "empty-row",
  icon,
}: {
  children: ReactNode;
  className?: string;
  icon?: ReactNode;
}) {
  return (
    <div className={className}>
      {icon}
      <span>{children}</span>
    </div>
  );
}

export function PageHeader({
  actions,
  children,
  className = "",
  eyebrow,
  title,
}: {
  actions?: ReactNode;
  children?: ReactNode;
  className?: string;
  eyebrow?: ReactNode;
  title: ReactNode;
}) {
  return (
    <header className={`marketing-ops-header ${className}`.trim()}>
      <div>
        {eyebrow ? <div className="intake-eyebrow">{eyebrow}</div> : null}
        <h2>{title}</h2>
        {children ? <p>{children}</p> : null}
      </div>
      {actions}
    </header>
  );
}

export function AdminCard({
  children,
  className = "",
  variant = "marketing",
}: {
  children: ReactNode;
  className?: string;
  variant?: "marketing" | "searchCandidate" | "intake";
}) {
  const baseClass = variant === "searchCandidate" ?
    "search-candidate-card" :
    variant === "intake" ?
    "intake-card" :
    "marketing-card";
  return (
    <article className={`${baseClass} ${className}`.trim()}>
      {children}
    </article>
  );
}

export function SelectableCardButton({
  children,
  className = "marketing-post-card",
  selected = false,
  type = "button",
  ...props
}: {
  children: ReactNode;
  className?: string;
  selected?: boolean;
} & ButtonHTMLAttributes<HTMLButtonElement>) {
  return (
    <button
      className={`${className} ${selected ? "selected" : ""}`.trim()}
      type={type}
      {...props}
    >
      {children}
    </button>
  );
}

export function CardHeader({
  action,
  children,
  className = "",
  variant = "marketing",
}: {
  action?: ReactNode;
  children: ReactNode;
  className?: string;
  variant?: "marketing" | "searchCandidate" | "intake";
}) {
  const baseClass = variant === "searchCandidate" ?
    "search-candidate-header" :
    variant === "intake" ?
    "intake-card-header" :
    "marketing-card-header";
  return (
    <header className={`${baseClass} ${className}`.trim()}>
      {children}
      {action}
    </header>
  );
}

export function StatusChip({
  children,
  className = "",
  tone = "neutral",
}: {
  children: ReactNode;
  className?: string;
  tone?: ChipTone;
}) {
  const toneClass = tone === "warning" ?
    "blocked" :
    tone === "success" ?
    "ready" :
    tone;
  return (
    <span className={`intake-badge ${toneClass} ${className}`.trim()}>
      {children}
    </span>
  );
}

export function AdminTag({
  children,
  className = "",
  href,
  rel,
  target,
  tone = "neutral",
}: {
  children: ReactNode;
  className?: string;
  href?: string;
  rel?: string;
  target?: string;
  tone?: TagTone;
}) {
  const classes = [
    "intake-tag",
    tone === "muted" ? "muted" : "",
    className,
  ].filter(Boolean).join(" ");
  if (href) {
    return (
      <a className={classes} href={href} rel={rel} target={target}>
        {children}
      </a>
    );
  }
  return <span className={classes}>{children}</span>;
}

export function TagList({
  children,
  className = "",
}: {
  children: ReactNode;
  className?: string;
}) {
  return (
    <div className={`marketing-tag-row ${className}`.trim()}>
      {children}
    </div>
  );
}

export function AlertRow({
  children,
  className = "",
  icon,
  title,
  tone = "neutral",
}: {
  children: ReactNode;
  className?: string;
  icon?: ReactNode;
  title?: ReactNode;
  tone?: AlertTone;
}) {
  return (
    <div className={`quality-row ${tone} ${className}`.trim()}>
      {icon}
      <div>
        {title ? <strong>{title}</strong> : null}
        <span>{children}</span>
      </div>
    </div>
  );
}

export function DataTable({
  children,
  className = "",
}: {
  children: ReactNode;
  className?: string;
}) {
  return (
    <div className={`table-wrap ${className}`.trim()}>
      <table>{children}</table>
    </div>
  );
}

export function TableActionButton({
  children,
  className = "",
  type = "button",
  ...props
}: {
  children: ReactNode;
  className?: string;
} & ButtonHTMLAttributes<HTMLButtonElement>) {
  return (
    <button
      className={`table-action ${className}`.trim()}
      type={type}
      {...props}
    >
      {children}
    </button>
  );
}

export function RiskBadge({
  children,
  tone,
}: {
  children: ReactNode;
  tone: RiskTone;
}) {
  return <span className={`risk ${tone}`}>{children}</span>;
}

export function AdminPanel({
  action,
  children,
  className = "",
  icon,
  title,
}: {
  action?: ReactNode;
  children: ReactNode;
  className?: string;
  icon: ReactNode;
  title: string;
}) {
  return (
    <article className={`panel ${className}`}>
      <header className="panel-header">
        <div className="panel-title">
          {icon}
          <h2>{title}</h2>
        </div>
        {action ? <span>{action}</span> : null}
      </header>
      {children}
    </article>
  );
}

export function Panel({
  action,
  children,
  className = "",
  icon,
  title,
}: {
  action?: ReactNode;
  children: ReactNode;
  className?: string;
  icon: ReactNode;
  title: string;
}) {
  return (
    <section className={`panel ${className}`}>
      <header className="panel-header">
        <div className="panel-title">
          {icon}
          <h2>{title}</h2>
        </div>
        <span>{action}</span>
      </header>
      {children}
    </section>
  );
}

export function AdminStateRow({
  label,
  value,
}: {
  label: string;
  value: ReactNode;
}) {
  return (
    <div className="state-row">
      <span>{label}</span>
      <strong>{value}</strong>
    </div>
  );
}

export function StateRow({
  label,
  value,
}: {
  label: string;
  value: ReactNode | null;
}) {
  return (
    <div className="state-row">
      <span>{label}</span>
      <strong>{value ?? "none"}</strong>
    </div>
  );
}

export function AdminTextField({
  className = "marketing-field",
  label,
  value,
  onChange,
  ...props
}: {
  className?: string;
  label: string;
  value: string;
  onChange: (value: string) => void;
} & Omit<InputHTMLAttributes<HTMLInputElement>, "className" | "onChange" | "value">) {
  return (
    <label className={className}>
      <span>{label}</span>
      <input
        value={value}
        onChange={(event) => onChange(event.target.value)}
        {...props}
      />
    </label>
  );
}

export function TextField({
  className = "field-control",
  label,
  onChange,
  value,
  ...props
}: {
  className?: string;
  label: string;
  onChange: (value: string) => void;
  value: string;
} & Omit<InputHTMLAttributes<HTMLInputElement>, "className" | "onChange" | "value">) {
  return (
    <label className={className}>
      <span>{label}</span>
      <input
        onChange={(event) => onChange(event.target.value)}
        value={value}
        {...props}
      />
    </label>
  );
}

export function CheckboxField({
  checked,
  className = "check-row",
  label,
  onChange,
  ...props
}: {
  checked: boolean;
  className?: string;
  label: ReactNode;
  onChange: (checked: boolean) => void;
} & Omit<InputHTMLAttributes<HTMLInputElement>, "checked" | "className" | "onChange" | "type">) {
  return (
    <label className={className}>
      <input
        checked={checked}
        onChange={(event) => onChange(event.currentTarget.checked)}
        type="checkbox"
        {...props}
      />
      <span>{label}</span>
    </label>
  );
}

export function AdminTextareaField({
  className = "marketing-field",
  label,
  rows,
  value,
  onChange,
  ...props
}: {
  className?: string;
  label: string;
  rows: number;
  value: string;
  onChange: (value: string) => void;
} & Omit<TextareaHTMLAttributes<HTMLTextAreaElement>, "className" | "onChange" | "rows" | "value">) {
  return (
    <label className={className}>
      <span>{label}</span>
      <textarea
        rows={rows}
        value={value}
        onChange={(event) => onChange(event.target.value)}
        {...props}
      />
    </label>
  );
}

export function TextareaField({
  className = "field-control",
  label,
  onChange,
  rows,
  value,
  ...props
}: {
  className?: string;
  label: string;
  onChange: (value: string) => void;
  rows: number;
  value: string;
} & Omit<TextareaHTMLAttributes<HTMLTextAreaElement>, "className" | "onChange" | "rows" | "value">) {
  return (
    <label className={className}>
      <span>{label}</span>
      <textarea
        onChange={(event) => onChange(event.target.value)}
        rows={rows}
        value={value}
        {...props}
      />
    </label>
  );
}

export function SelectField({
  className = "field-control",
  label,
  onChange,
  options,
  value,
  ...props
}: {
  className?: string;
  label: string;
  onChange: (value: string) => void;
  options: SelectOption[];
  value: string;
} & Omit<SelectHTMLAttributes<HTMLSelectElement>, "className" | "onChange" | "value">) {
  return (
    <label className={className}>
      <span>{label}</span>
      <select
        onChange={(event) => onChange(event.target.value)}
        value={value}
        {...props}
      >
        {options.map((option) => {
          const value = typeof option === "string" ? option : option.value;
          const label = typeof option === "string" ? option : option.label;
          return <option key={value} value={value}>{label}</option>;
        })}
      </select>
    </label>
  );
}
