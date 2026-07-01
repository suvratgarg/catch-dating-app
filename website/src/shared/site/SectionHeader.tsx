import type {ReactNode} from "react";

export function SectionHeader({
  eyebrow,
  title,
  body,
  id,
  wide = false,
}: {
  eyebrow?: string;
  title: ReactNode;
  body?: ReactNode;
  id?: string;
  wide?: boolean;
}) {
  return (
    <div className={`section-heading ${wide ? "section-heading--wide" : ""}`} data-reveal>
      {eyebrow ? <span className="ui-label">{eyebrow}</span> : null}
      <h2 id={id}>{title}</h2>
      {body ? <p>{body}</p> : null}
    </div>
  );
}
