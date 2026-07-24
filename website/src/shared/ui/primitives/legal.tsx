import type {HTMLAttributes, ReactNode} from "react";

export function LegalDocument({children}: {children: ReactNode}) {
  return <article className="legal-document">{children}</article>;
}

export function LegalDocumentHeader({children}: {children: ReactNode}) {
  return <header className="legal-document__header">{children}</header>;
}

export function LegalDocumentEyebrow(props: HTMLAttributes<HTMLParagraphElement>) {
  return <p {...props} className="legal-document__eyebrow" />;
}

export function LegalDocumentSummary(props: HTMLAttributes<HTMLParagraphElement>) {
  return <p {...props} className="legal-document__summary" />;
}

export function LegalDocumentEffective(props: HTMLAttributes<HTMLParagraphElement>) {
  return <p {...props} className="legal-document__effective" />;
}

export function LegalDocumentSections({children}: {children: ReactNode}) {
  return <div className="legal-document__sections">{children}</div>;
}

export function LegalDocumentContact({children}: {children: ReactNode}) {
  return <aside className="legal-document__contact">{children}</aside>;
}
