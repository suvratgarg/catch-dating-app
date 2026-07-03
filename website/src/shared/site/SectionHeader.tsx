import type {ReactNode} from "react";

export function SectionHeader({
  eyebrow,
  title,
  body,
  headingLevel = "h2",
  id,
  wide = false,
}: {
  eyebrow?: ReactNode;
  title: ReactNode;
  body?: ReactNode;
  headingLevel?: "h1" | "h2";
  id?: string;
  wide?: boolean;
}) {
  const Heading = headingLevel;
  return (
    <div className={`section-heading ${wide ? "section-heading--wide" : ""}`} data-reveal>
      {eyebrow ? <span className="ui-label">{eyebrow}</span> : null}
      <Heading id={id}>{title}</Heading>
      {body ? <p>{body}</p> : null}
    </div>
  );
}
