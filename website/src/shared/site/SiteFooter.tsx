import {PlainLink} from "../ui/primitives";
import type {SiteNavItem} from "./SiteHeader";
import {slugForTracking, trackSiteCtaClick} from "./siteTracking";

export function SiteFooter({
  brandHref,
  body,
  links,
}: {
  brandHref: string;
  body: string;
  links: SiteNavItem[];
}) {
  return (
    <footer className="site-footer">
      <PlainLink className="brand" href={brandHref} aria-label="Catch home">
        <span className="brand__mark" aria-hidden="true">C</span>
        <span className="brand__word">Catch</span>
      </PlainLink>
      <p>{body}</p>
      <nav aria-label="Footer">
        {links.map((link) => (
          <PlainLink
            href={link.href}
            key={`${link.href}-${link.label}`}
            onClick={() => trackSiteCtaClick(`footer_${slugForTracking(link.label)}`, link.href)}
          >
            {link.label}
          </PlainLink>
        ))}
      </nav>
    </footer>
  );
}
