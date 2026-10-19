import {consumerSiteCopy, publicSiteCopy, siteFooterLegalLinks} from "../../content/site";
import {ConsumerHome} from "../ui/primitives/consumerHome";
import {PlainLink} from "../ui/primitives";
import {SiteHeader, type SiteNavItem, type SiteMenuCopy} from "./SiteHeader";
import {SiteFooter} from "./SiteFooter";
import {slugForTracking, trackSiteCtaClick} from "./siteTracking";

const globalFooterLinks = [...publicSiteCopy.nav, ...siteFooterLegalLinks];

function contextualLinks(links: readonly SiteNavItem[]) {
  const seen = new Set(globalFooterLinks.map((link) => `${link.href}|${link.label}`));
  return links.filter((link) => {
    const href = link.href.startsWith("#") ? `/${link.href}` : link.href;
    const key = `${href}|${link.label}`;
    if (seen.has(key)) return false;
    seen.add(key);
    return true;
  });
}

export function PublicSiteHeader({localNav = [], localActions = [], tone = "light", audience = "public", guestMenuCopy}: {
  guestMenuCopy?: SiteMenuCopy;
  audience?: "public" | "guest" | "consumer";
  localNav?: readonly SiteNavItem[];
  localActions?: readonly SiteNavItem[];
  tone?: "light" | "dark";
}) {
  if (audience === "consumer") return <ConsumerHome><SiteHeader brandHref="/" menuCopy={consumerSiteCopy.menu} nav={[...consumerSiteCopy.nav]} actions={[]} tone="light" /></ConsumerHome>;
  if (audience === "guest") return <SiteHeader brandHref="/" menuCopy={guestMenuCopy ?? publicSiteCopy.menu}
    nav={[...localNav]} actions={localActions.map((item) => ({...item, variant: "secondary" as const}))} tone={tone} />;
  const links = contextualLinks([...localNav, ...localActions]);
  return <>
    <SiteHeader brandHref="/" menuCopy={publicSiteCopy.menu}
      nav={[...publicSiteCopy.nav]} actions={[...publicSiteCopy.actions]} tone={tone} />
    {links.length ? <nav className={`site-local-nav${tone === "dark" ? " site-local-nav--over-dark" : ""}`}
      aria-label={publicSiteCopy.localNavLabel}>
      {links.map((link) => <PlainLink key={`${link.href}-${link.label}`} href={link.href}
        onClick={() => trackSiteCtaClick(`local_nav_${slugForTracking(link.label)}`, link.href)}>
        {link.label}
      </PlainLink>)}
    </nav> : null}
  </>;
}

export function PublicSiteFooter({body, links = [], audience = "public"}: {
  audience?: "public" | "guest" | "consumer";
  body?: string;
  links?: readonly SiteNavItem[];
}) {
  if (audience === "consumer") return <ConsumerHome><SiteFooter brandHref="/" body={publicSiteCopy.footerOperator} links={[...consumerSiteCopy.nav, ...siteFooterLegalLinks]} /></ConsumerHome>;
  if (audience === "guest") return <SiteFooter brandHref="/" body={body ?? publicSiteCopy.footerOperator}
    links={[...siteFooterLegalLinks, ...contextualLinks(links)]} />;
  const related = contextualLinks(links);
  return <SiteFooter brandHref="/" body={publicSiteCopy.footerBody} links={globalFooterLinks}>
    <p className="site-footer__context">{publicSiteCopy.footerOperator}</p>
    {body && body !== publicSiteCopy.footerBody && body !== publicSiteCopy.footerOperator ? <p className="site-footer__context">{body}</p> : null}
    {related.length ? <nav className="site-footer__context" aria-label={publicSiteCopy.relatedLinksLabel}>
      {related.map((link) => <PlainLink key={`${link.href}-${link.label}`} href={link.href}
        onClick={() => trackSiteCtaClick(`footer_${slugForTracking(link.label)}`, link.href)}>
        {link.label}
      </PlainLink>)}
    </nav> : null}
  </SiteFooter>;
}
