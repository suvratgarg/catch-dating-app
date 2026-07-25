import {useEffect, useRef, useState} from "react";
import type {CSSProperties} from "react";
import {ButtonLink, PlainButton, PlainLink} from "../ui/primitives";
import {slugForTracking, trackSiteCtaClick} from "./siteTracking";

export interface SiteNavItem {
  href: string;
  label: string;
}

export interface SiteMenuCopy {
  dialogLabel: string;
  openLabel: string;
  closeLabel: string;
  kicker: string;
  hint: string;
  navLabel: string;
}

export interface SiteHeaderAction extends SiteNavItem {
  variant?: "primary" | "secondary";
}

export function SiteHeader({
  brandHref,
  menuCopy,
  nav,
  actions,
  ctaHref,
  ctaLabel,
  tone = "light",
}: {
  brandHref: string;
  menuCopy: SiteMenuCopy;
  nav: SiteNavItem[];
  actions?: SiteHeaderAction[];
  ctaHref?: string;
  ctaLabel?: string;
  tone?: "light" | "dark";
}) {
  const [isScrolled, setIsScrolled] = useState(false);
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const menuButtonRef = useRef<HTMLButtonElement>(null);
  const menuCloseRef = useRef<HTMLButtonElement>(null);
  const headerActions = actions ?? (
    ctaHref && ctaLabel ? [{href: ctaHref, label: ctaLabel}] : []
  );

  useEffect(() => {
    const syncHeader = () => setIsScrolled(window.scrollY > 18);
    syncHeader();
    window.addEventListener("scroll", syncHeader, {passive: true});
    return () => window.removeEventListener("scroll", syncHeader);
  }, []);

  useEffect(() => {
    if (!isMenuOpen) return undefined;
    const previousOverflow = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    menuCloseRef.current?.focus();
    const onKeyDown = (event: KeyboardEvent) => {
      if (event.key === "Escape") setIsMenuOpen(false);
    };
    document.addEventListener("keydown", onKeyDown);
    return () => {
      document.body.style.overflow = previousOverflow;
      document.removeEventListener("keydown", onKeyDown);
      menuButtonRef.current?.focus();
    };
  }, [isMenuOpen]);

  const closeMenu = () => setIsMenuOpen(false);

  return (
    <>
      <header
        className={`site-header ${isScrolled ? "is-scrolled" : ""} ${
          tone === "dark" ? "site-header--over-dark" : ""
        }`}
      >
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

        <PlainButton
          aria-controls="site-menu"
          aria-expanded={isMenuOpen}
          className="site-menu-button"
          onClick={() => setIsMenuOpen(true)}
          ref={menuButtonRef}
        >
          {menuCopy.openLabel}
        </PlainButton>
      </header>

      <div
        aria-label={menuCopy.dialogLabel}
        aria-modal="true"
        className={`site-menu ${isMenuOpen ? "is-open" : ""}`}
        id="site-menu"
        inert={!isMenuOpen}
        role="dialog"
      >
        <div className="site-menu__top">
          <span className="site-menu__hint">{menuCopy.kicker}</span>
          <PlainButton className="site-menu__close" onClick={closeMenu} ref={menuCloseRef}>
            {menuCopy.closeLabel}
          </PlainButton>
        </div>

        <nav className="site-menu__nav" aria-label={menuCopy.navLabel}>
          {nav.map((item, index) => (
            <PlainLink
              href={item.href}
              key={`${item.href}-${item.label}`}
              onClick={() => {
                trackSiteCtaClick(`nav_${slugForTracking(item.label)}`, item.href);
                closeMenu();
              }}
              style={{"--menu-index": index} as CSSProperties}
            >
              {item.label}
            </PlainLink>
          ))}
        </nav>

        <div className="site-menu__footer">
          {headerActions.map((action) => (
            <ButtonLink
              href={action.href}
              key={`${action.href}-${action.label}`}
              onClick={() => {
                trackSiteCtaClick(`header_${slugForTracking(action.label)}`, action.href);
                closeMenu();
              }}
              variant={action.variant === "secondary" ? "ghost" : "primary"}
            >
              {action.label}
            </ButtonLink>
          ))}
          <span className="site-menu__hint">{menuCopy.hint}</span>
        </div>
      </div>
    </>
  );
}
