import type {PublishedLegalPage} from "../../content/types";
import {siteFooterLegalLinks} from "../../content/site";
import {publishedLegalContent} from "../../content/legal";
import {SiteFooter, SiteHeader, WebsitePageMain} from "../../shared/site";
import {
  LegalDocument,
  LegalDocumentContact,
  LegalDocumentEffective,
  LegalDocumentEyebrow,
  LegalDocumentHeader,
  LegalDocumentSections,
  LegalDocumentSummary,
  PlainLink,
} from "../../shared/ui/primitives";

export function LegalPage({page, effectiveDate}: {
  page: PublishedLegalPage;
  effectiveDate: string;
}) {
  const {operator, ui} = publishedLegalContent;
  return (
    <>
      <SiteHeader
        brandHref="/"
        nav={[
          {href: "/", label: ui.homeLabel},
          {href: "/organizers/", label: ui.organizersLabel},
          {href: "/host/", label: ui.hostsLabel},
        ]}
        actions={[{href: `mailto:${operator.supportEmail}`, label: ui.contactLabel}]}
      />
      <WebsitePageMain id="top">
        <LegalDocument>
          <LegalDocumentHeader>
            <LegalDocumentEyebrow>{page.eyebrow}</LegalDocumentEyebrow>
            <h1>{page.title}</h1>
            <LegalDocumentSummary>{page.summary}</LegalDocumentSummary>
            <LegalDocumentEffective>{ui.effectivePrefix} {effectiveDate}</LegalDocumentEffective>
          </LegalDocumentHeader>
          <LegalDocumentSections>
            {page.sections.map((section) => (
              <section key={section.heading}>
                <h2>{section.heading}</h2>
                {section.paragraphs.map((paragraph) => (
                  <p key={paragraph}>{paragraph}</p>
                ))}
                {section.bullets ? (
                  <ul>
                    {section.bullets.map((bullet) => <li key={bullet}>{bullet}</li>)}
                  </ul>
                ) : null}
              </section>
            ))}
          </LegalDocumentSections>
          <LegalDocumentContact>
            <p>{ui.contactPrompt}</p>
            <PlainLink href={`mailto:${operator.supportEmail}`}>{operator.supportEmail}</PlainLink>
          </LegalDocumentContact>
        </LegalDocument>
      </WebsitePageMain>
      <SiteFooter
        brandHref="/"
        body={ui.footerBody}
        links={siteFooterLegalLinks.map((link) => ({...link}))}
      />
    </>
  );
}
