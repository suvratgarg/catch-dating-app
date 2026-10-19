import {hostProductCopy as copy, hostWorkflowExamples} from "@content/hostProduct";
import {
  ActionGroup, ButtonLink, ContentGrid, HostPreviewFaqList, MarketingFactList,
  HostPreviewSection, HostPreviewSectionHead, MarketingInfoCardGrid, MarketingLoopList, MarketingSection, MarketingSectionCopy,
} from "../../../shared/ui/primitives";

// Private composition helpers keep the canonical product route the sole page owner.
export function renderHostFeatures() {
  return <MarketingSection variant="story" id="features" aria-labelledby="features-title">
    <MarketingSectionCopy variant="proof" reveal={false} titleId="features-title" title={copy.features.title} body={copy.features.body} />
    <MarketingInfoCardGrid variant="trust" reveal={false} items={copy.features.items} />
  </MarketingSection>;
}

export function renderHostWorkflows() {
  return <>
    {hostWorkflowExamples.map((example) => <MarketingSection variant="story" id={example.id} key={example.id} aria-labelledby={`${example.id}-title`}>
      <ContentGrid variant="marketing-split">
        <MarketingSectionCopy variant="proof" reveal={false} titleId={`${example.id}-title`}
          eyebrow={example.audience} title={example.title} body={example.body}>
          <p>{example.outcome}</p>
        </MarketingSectionCopy>
        <MarketingFactList label={copy.exampleLabel} items={example.facts} note={example.boundary} />
      </ContentGrid>
      <MarketingLoopList items={example.steps} reveal={false} variant="host" />
    </MarketingSection>)}
  </>;
}

export function renderHostUseCases() {
  return <HostPreviewSection variant="faq" id="use-cases" aria-labelledby="use-cases-title">
    <HostPreviewSectionHead titleId="use-cases-title" title={copy.useCases.title} body={copy.useCases.body} />
    <HostPreviewFaqList items={[...copy.useCases.items]} />
  </HostPreviewSection>;
}

export function renderHostExistingTools() {
  return <HostPreviewSection variant="faq" id="existing-tools" aria-labelledby="existing-tools-title">
    <HostPreviewSectionHead titleId="existing-tools-title" title={copy.tools.title} body={copy.tools.body} />
    <HostPreviewFaqList items={[...copy.tools.items]} />
    <MarketingInfoCardGrid variant="trust" reveal={false} items={copy.tools.problems} />
  </HostPreviewSection>;
}

export function renderHostPricing() {
  return <MarketingSection variant="story" id="pricing" aria-labelledby="pricing-title">
    <MarketingSectionCopy variant="proof" reveal={false} titleId="pricing-title" title={copy.pricing.title} body={copy.pricing.body} />
    <MarketingInfoCardGrid variant="trust" reveal={false} items={copy.pricing.items} />
    <ActionGroup variant="marketing"><ButtonLink href="/host/apply/">{copy.application.action}</ButtonLink></ActionGroup>
  </MarketingSection>;
}
