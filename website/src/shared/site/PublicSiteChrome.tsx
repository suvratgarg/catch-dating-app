import {publicSiteCopy, siteFooterLegalLinks} from "../../content/site";
import {PlainLink} from "../ui/primitives";
import {SiteHeader, type SiteNavItem} from "./SiteHeader";
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

export function PublicSiteHeader({localNav = [], localActions = [], tone = "light"}: {
  localNav?: readonly SiteNavItem[];
  localActions?: readonly SiteNavItem[];
  tone?: "light" | "dark";
}) {
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

export function PublicSiteFooter({body, links = []}: {
  body?: string;
  links?: readonly SiteNavItem[];
}) {
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
