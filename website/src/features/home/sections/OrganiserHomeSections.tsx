import {organiserHomeCopy as copy} from "@content/marketingOrganization";
import {SectionHeader} from "../../../shared/site";
import {
  ActionGroup, ButtonLink, HomeHeroBody, HomeHeroCopy, HomeHeroInner,
  HomeHeroShell, MarketingInfoCardGrid, MarketingSection, UiLabel,
} from "../../../shared/ui/primitives";
import {trackCtaClick} from "../../marketing/tracking";

export function renderOrganiserHomeSections() {
  return <>
    <HomeHeroShell aria-labelledby="organiser-home-title">
      <HomeHeroInner layout="content"><HomeHeroCopy>
        <UiLabel>{copy.hero.kicker}</UiLabel>
        <h1 id="organiser-home-title">{copy.hero.title}</h1>
        <HomeHeroBody>{copy.hero.body}</HomeHeroBody>
        <ActionGroup variant="hero">
          <ButtonLink href={copy.actions.start.href} onClick={() => trackCtaClick("organiser_home_host", copy.actions.start.href)}>{copy.actions.start.label}</ButtonLink>
          <ButtonLink variant="ghost" href={copy.actions.attend.href}>{copy.actions.attend.label}</ButtonLink>
          <ButtonLink variant="ghost" href={copy.actions.claim.href}>{copy.actions.claim.label}</ButtonLink>
        </ActionGroup>
        <HomeHeroBody>{copy.hero.claimNote}</HomeHeroBody>
      </HomeHeroCopy></HomeHeroInner>
    </HomeHeroShell>
    <MarketingSection variant="story" id="product" aria-labelledby="organiser-product-title">
      <SectionHeader id="organiser-product-title" title={copy.product.title} body={copy.product.body} wide />
      <MarketingInfoCardGrid items={copy.product.items} variant="trust" />
    </MarketingSection>
    <MarketingSection variant="story" id="explore" aria-labelledby="organiser-explore-title">
      <SectionHeader id="organiser-explore-title" eyebrow={copy.explore.eyebrow} title={copy.explore.title} body={copy.explore.body} wide />
      <ActionGroup>
        <ButtonLink href={copy.explore.visitors.href}>{copy.explore.visitors.label}</ButtonLink>
        <ButtonLink variant="ghost" href={copy.explore.directory.href}>{copy.explore.directory.label}</ButtonLink>
      </ActionGroup>
    </MarketingSection>
  </>;
}
