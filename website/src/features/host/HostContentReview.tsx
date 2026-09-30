import {hostOrganizationCopy, hostOrganizationNavigation, hostWorkflowExamples} from "@content/hostOrganization";
import {ownerGatedSiteDestinations, siteFooterLegalLinks} from "@content/site";
import {SiteFooter, SiteHeader, WebsitePageMain} from "../../shared/site";
import {
  ActionGroup, ButtonLink, ContentGrid, MarketingFactList, MarketingInfoCardGrid,
  MarketingLoopList, MarketingSection, MarketingSectionCopy, UiLabel,
} from "../../shared/ui/primitives";

// Workbench-only composition. No controller, remote data or mutation boundary.
export function HostContentReview() {
  const copy = hostOrganizationCopy;
  return (
    <>
      <SiteHeader brandHref="/" menuCopy={copy.menu} nav={[...hostOrganizationNavigation]}
        ctaHref={ownerGatedSiteDestinations.contactHref} ctaLabel={copy.hero.primaryAction} />
      <WebsitePageMain id="top">
        <MarketingSection variant="story" aria-labelledby="content-review-title">
          <UiLabel>{copy.review.title}</UiLabel>
          <p>{copy.review.body}</p>
          <UiLabel>{copy.hero.eyebrow}</UiLabel>
          <h1 id="content-review-title">{copy.hero.title}</h1>
          <p>{copy.hero.body}</p>
          <ActionGroup variant="marketing">
            <ButtonLink href={ownerGatedSiteDestinations.contactHref}>{copy.hero.primaryAction}</ButtonLink>
            <ButtonLink href="#workflows" variant="ghost">{copy.hero.secondaryAction}</ButtonLink>
          </ActionGroup>
          <p>{copy.hero.contactNote}</p>
        </MarketingSection>
        <MarketingSection variant="story" id="workflows" aria-labelledby="workflows-title">
          <MarketingSectionCopy variant="proof" reveal={false} titleId="workflows-title" {...copy.workflows} />
          <MarketingInfoCardGrid variant="surface" reveal={false} items={hostWorkflowExamples.map((example) => ({
            key: example.id, label: example.audience, title: example.title, body: example.outcome,
            action: {href: `#${example.id}`, label: copy.detailAction},
          }))} />
        </MarketingSection>
        {hostWorkflowExamples.map((example) => (
          <MarketingSection variant="story" id={example.id} key={example.id} aria-labelledby={`${example.id}-title`}>
            <ContentGrid variant="marketing-split">
              <MarketingSectionCopy variant="proof" reveal={false} titleId={`${example.id}-title`}
                eyebrow={example.audience} title={example.title} body={example.body}>
                <p>{example.outcome}</p>
              </MarketingSectionCopy>
              <MarketingFactList label={copy.exampleLabel} items={example.facts} note={example.boundary} />
            </ContentGrid>
            <MarketingLoopList items={example.steps} reveal={false} variant="host" />
          </MarketingSection>
        ))}
        <MarketingSection variant="story" id="capabilities" aria-labelledby="capabilities-title">
          <MarketingSectionCopy variant="proof" reveal={false} titleId="capabilities-title"
            eyebrow={copy.capabilities.eyebrow} title={copy.capabilities.title} body={copy.capabilities.body} />
          <MarketingInfoCardGrid variant="trust" reveal={false} items={copy.capabilities.items} />
        </MarketingSection>
        <MarketingSection variant="story" id="supported-pilot" aria-labelledby="pilot-title">
          <MarketingSectionCopy variant="proof" reveal={false} titleId="pilot-title"
            eyebrow={copy.pilot.eyebrow} title={copy.pilot.title} body={copy.pilot.body} />
          <MarketingInfoCardGrid variant="trust" reveal={false} items={copy.pilot.items} />
          <ActionGroup variant="marketing">
            <ButtonLink href={ownerGatedSiteDestinations.contactHref}>{copy.hero.primaryAction}</ButtonLink>
            <ButtonLink href="/host/#founding-hosts" variant="ghost">{copy.pilot.betaAction}</ButtonLink>
          </ActionGroup>
          <p>{copy.pilot.betaNote}</p>
        </MarketingSection>
      </WebsitePageMain>
      <SiteFooter brandHref="/" body={copy.footer} links={[...hostOrganizationNavigation, ...siteFooterLegalLinks]} />
    </>
  );
}
