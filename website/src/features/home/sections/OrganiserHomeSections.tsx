import {organiserHomeCopy as copy} from "@content/marketingOrganization";
import {SectionHeader} from "../../../shared/site";
import {
  ActionGroup, ButtonLink, HomeHeroBody, HomeHeroCopy, HomeHeroInner,
  HomeHeroShell, MarketingInfoCardGrid, MarketingSection, UiLabel,
} from "../../../shared/ui/primitives";
import {HomeDiscoverySection, HomeFeaturedOrganizersSection} from "./HomePageSections";
import {trackCtaClick} from "../../marketing/tracking";

// Composition stays feature-private; the public route owns registry coverage.
export function renderOrganiserHomeSections() {
  return <OrganiserHomeSections />;
}

function OrganiserHomeSections() {
  return (
    <>
      <HomeHeroShell aria-labelledby="organiser-home-title">
        <HomeHeroInner layout="content">
          <HomeHeroCopy>
            <UiLabel>{copy.hero.kicker}</UiLabel>
            <h1 id="organiser-home-title">{copy.hero.title}</h1>
            <HomeHeroBody>{copy.hero.body}</HomeHeroBody>
            <ActionGroup variant="hero">
              <ButtonLink href={copy.actions.start.href}
                onClick={() => trackCtaClick("organiser_home_start_claim", copy.actions.start.href)}>
                {copy.actions.start.label}
              </ButtonLink>
              <ButtonLink variant="ghost" href={copy.actions.walkthrough.href}
                onClick={() => trackCtaClick("organiser_home_walkthrough", copy.actions.walkthrough.href)}>
                {copy.actions.walkthrough.label}
              </ButtonLink>
            </ActionGroup>
            <p>{copy.hero.claimNote}</p>
            <p>{copy.hero.signInNote}</p>
          </HomeHeroCopy>
        </HomeHeroInner>
      </HomeHeroShell>
      <MarketingSection variant="story" id="product" aria-labelledby="organiser-product-title">
        <SectionHeader id="organiser-product-title" eyebrow={copy.nav[0].label}
          title={copy.product.title} body={copy.product.body} wide />
        <MarketingInfoCardGrid items={copy.product.items} variant="trust" labelVariant="ui" />
      </MarketingSection>
      <MarketingSection variant="trust" id="solutions" aria-labelledby="organiser-solutions-title">
        <SectionHeader id="organiser-solutions-title" eyebrow={copy.nav[1].label}
          title={copy.solutions.title} body={copy.solutions.body} wide />
        <MarketingInfoCardGrid items={copy.solutions.items} variant="trust" labelVariant="ui" />
      </MarketingSection>
      <MarketingSection variant="story" id="explore" aria-labelledby="organiser-explore-title">
        <SectionHeader id="organiser-explore-title" eyebrow={copy.explore.eyebrow}
          title={copy.explore.title} body={copy.explore.body} wide />
        <ActionGroup>
          <ButtonLink href={copy.explore.directory.href}>{copy.explore.directory.label}</ButtonLink>
          <ButtonLink variant="ghost" href={copy.explore.visitors.href}>{copy.explore.visitors.label}</ButtonLink>
          <ButtonLink variant="ghost" href={copy.explore.claim.href}>{copy.explore.claim.label}</ButtonLink>
        </ActionGroup>
      </MarketingSection>
      <HomeDiscoverySection copy={copy.discovery} />
      <HomeFeaturedOrganizersSection copy={copy.featured} />
      <MarketingSection variant="story" id="resources" aria-labelledby="organiser-resources-title">
        <SectionHeader id="organiser-resources-title" eyebrow={copy.nav[3].label}
          title={copy.resources.title} body={copy.resources.body} wide />
        <MarketingInfoCardGrid items={copy.resources.items} variant="surface" />
      </MarketingSection>
    </>
  );
}
