import {useEffect, useState} from "react";
import {ButtonLink, PlainLink} from "../ui/primitives";
import {slugForTracking, trackSiteCtaClick} from "./siteTracking";

export interface SiteNavItem {
  href: string;
  label: string;
}

export interface SiteHeaderAction extends SiteNavItem {
  variant?: "primary" | "secondary";
}

export function SiteHeader({
  brandHref,
  nav,
  actions,
  ctaHref,
  ctaLabel,
}: {
  brandHref: string;
  nav: SiteNavItem[];
  actions?: SiteHeaderAction[];
  ctaHref?: string;
  ctaLabel?: string;
}) {
  const [isScrolled, setIsScrolled] = useState(false);
  const headerActions = actions ?? (
    ctaHref && ctaLabel ? [{href: ctaHref, label: ctaLabel}] : []
  );

  useEffect(() => {
    const syncHeader = () => setIsScrolled(window.scrollY > 18);
    syncHeader();
    window.addEventListener("scroll", syncHeader, {passive: true});
    return () => window.removeEventListener("scroll", syncHeader);
  }, []);

  return (
    <header className={`site-header ${isScrolled ? "is-scrolled" : ""}`}>
      <PlainLink className="brand" href={brandHref} aria-label={"Catch home"}>
        <span className="brand__mark" aria-hidden="true">{"C"}</span>
        <span className="brand__word">{"Catch"}</span>
      </PlainLink>

      <nav className="site-nav" aria-label={"Primary"}>
        {nav.map((item) => (
          <PlainLink
            href={item.href}
            key={`${item.href}-${item.label}`}
            onClick={() => trackSiteCtaClick(`nav_${slugForTracking(item.label)}`, item.href)}
          >
            {item.label}
          </PlainLink>
        ))}
      </nav>

      <div className="site-header__actions">
        {headerActions.map((action) => (
          <ButtonLink
            href={action.href}
            key={`${action.href}-${action.label}`}
            onClick={() => trackSiteCtaClick(`header_${slugForTracking(action.label)}`, action.href)}
            size="small"
            variant={action.variant === "secondary" ? "ghost" : "primary"}
          >
            {action.label}
          </ButtonLink>
        ))}
      </div>
    </header>
  );
}
