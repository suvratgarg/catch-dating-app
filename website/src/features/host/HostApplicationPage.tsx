import {hostProductCopy} from "@content/hostProduct";
import {PublicSiteFooter, PublicSiteHeader, WebsitePageMain} from "../../shared/site";
import {ActionGroup, ButtonLink, HomeHeroBody, HomeHeroCopy, HomeHeroInner, HomeHeroShell, UiLabel} from "../../shared/ui/primitives";
import {HostApplySection} from "./sections/HostPageSections";

export function HostApplicationPage() {
  const copy = hostProductCopy.application;
  return <>
    <PublicSiteHeader tone="dark" localNav={[{href: "/host/", label: copy.back}]} />
    <WebsitePageMain id="top">
      <HomeHeroShell><HomeHeroInner layout="content"><HomeHeroCopy>
        <UiLabel>{copy.back}</UiLabel>
        <h1>{copy.title}</h1><HomeHeroBody>{copy.body}</HomeHeroBody><HomeHeroBody>{copy.note}</HomeHeroBody>
        <ActionGroup variant="marketing"><ButtonLink href="#founding-hosts">{copy.action}</ButtonLink></ActionGroup>
      </HomeHeroCopy></HomeHeroInner></HomeHeroShell>
      <HostApplySection />
    </WebsitePageMain>
    <PublicSiteFooter links={[{href: "/host/", label: copy.back}]} />
  </>;
}
