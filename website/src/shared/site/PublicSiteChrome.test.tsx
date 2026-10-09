import {cleanup, fireEvent, render, screen, within} from "@testing-library/react";
import {afterEach, beforeEach, describe, expect, it, vi} from "vitest";
import {getMarketingConsent, setMarketingConsent} from "../../analytics";
import {websiteCopy} from "../../content/generated";
import {marketingConsentPreferencesCopy} from "../../content/marketingConsent";
import {publicSiteCopy, siteFooterLegalLinks} from "../../content/site";
import {Button, MarketingConsentBannerShell} from "../ui/primitives";
import {PublicSiteFooter, PublicSiteHeader} from "./PublicSiteChrome";

vi.mock("./siteTracking", () => ({slugForTracking: (value: string) => value, trackSiteCtaClick: vi.fn()}));
beforeEach(() => {localStorage.clear(); window.dataLayer = [];});
afterEach(() => {cleanup(); document.body.style.overflow = "";});
const globalLabels = ["Product", "Solutions", "Explore", "Resources"];

describe("canonical public chrome", () => {
  it("uses root destinations and honest claim actions while keeping profile sections local", () => {
    render(<PublicSiteHeader localNav={[{href: "#events", label: "Events"},
      {href: "#about", label: "About"}, {href: "#reviews", label: "Reviews"}]}
      localActions={[{href: "/claim/example/", label: "Claim listing"}]} />);
    const primary = screen.getByRole("navigation", {name: "Primary"});
    expect(within(primary).getAllByRole("link").map((link) => link.textContent)).toEqual(globalLabels);
    expect(within(primary).getAllByRole("link").map((link) => link.getAttribute("href")))
      .toEqual(["/#product", "/#solutions", "/#explore", "/#resources"]);
    expect(screen.getByRole("link", {name: "Catch home"}).getAttribute("href")).toBe("/");
    const local = screen.getByRole("navigation", {name: "On this page"});
    expect(within(local).getAllByRole("link").map((link) => link.getAttribute("href")))
      .toEqual(["#events", "#about", "#reviews", "/claim/example/"]);
    for (const name of ["Sign in for a claim", "Get started free"]) {
      expect(within(screen.getByRole("banner")).getByRole("link", {name}).getAttribute("href")).toBe("/claim/");
    }
  });

  it("omits empty or repeated global secondary navigation on the root", () => {
    render(<PublicSiteHeader localNav={[{href: "#product", label: "Product"}]} />);
    expect(screen.queryByRole("navigation", {name: "On this page"})).toBeNull();
  });

  it("owns global/footer/legal links once and retains contextual copy, labels and anchors", () => {
    render(<PublicSiteFooter body="Existing page description" links={[
      ...publicSiteCopy.nav, ...siteFooterLegalLinks,
      {href: "#resources", label: "Resources"},
      {href: "#about", label: "About this organiser"},
      {href: "/host/", label: "For hosts"},
      {href: "/host/", label: "For hosts"},
    ]} />);
    const global = screen.getByRole("navigation", {name: "Footer"});
    expect(within(global).getAllByRole("link").map((link) => link.textContent))
      .toEqual([...globalLabels, "Privacy", "Terms", "Help"]);
    expect(within(screen.getByRole("navigation", {name: "Related links"}))
      .getAllByRole("link").map((link) => link.getAttribute("href")))
      .toEqual(["#about", "/host/"]);
    expect(screen.getByText("Existing page description")).toBeTruthy();
    expect(screen.getAllByText(publicSiteCopy.footerOperator)).toHaveLength(1);
  });

  it("does not repeat the published operator fact on legal pages", () => {
    render(<PublicSiteFooter body={publicSiteCopy.footerOperator} />);
    expect(screen.getAllByText(publicSiteCopy.footerOperator)).toHaveLength(1);
    expect(screen.queryByRole("navigation", {name: "Related links"})).toBeNull();
  });

  it("contains Tab focus, closes with Escape or navigation, and restores focus and body scrolling", () => {
    document.body.style.overflow = "auto";
    const {container} = render(<PublicSiteHeader />);
    const menu = screen.getByRole("button", {name: "Menu"});
    const dialog = container.querySelector('[role="dialog"]')!;
    expect(dialog.hasAttribute("inert")).toBe(true);
    fireEvent.click(menu);
    const close = screen.getByRole("button", {name: "Close"});
    expect(document.activeElement).toBe(close);
    expect(menu.getAttribute("aria-expanded")).toBe("true");
    expect(document.body.style.overflow).toBe("hidden");
    expect(dialog.hasAttribute("inert")).toBe(false);
    const mobile = within(dialog as HTMLElement);
    expect(mobile.getAllByRole("link").slice(0, 4).map((link) => link.textContent)).toEqual(globalLabels);
    const last = mobile.getByRole("link", {name: "Get started free"});
    fireEvent.keyDown(document, {key: "Tab", shiftKey: true});
    expect(document.activeElement).toBe(last);
    fireEvent.keyDown(document, {key: "Tab"});
    expect(document.activeElement).toBe(close);
    fireEvent.keyDown(document, {key: "Escape"});
    expect(document.activeElement).toBe(menu);
    expect(menu.getAttribute("aria-expanded")).toBe("false");
    expect(document.body.style.overflow).toBe("auto");
    fireEvent.click(menu);
    fireEvent.click(mobile.getByRole("link", {name: "Product"}));
    expect(menu.getAttribute("aria-expanded")).toBe("false");
    expect(document.activeElement).toBe(menu);
    document.body.style.overflow = "";
  });

  const consentStates = [null, "essential", "analytics", "accepted"] as const;
  const exits = ["Escape", "Close", "Sign in for a claim", "Get started free"] as const;
  it.each(consentStates.flatMap((choice) => exits.map((exit) => ({choice, exit}))))(
    "preserves $choice consent through menu focus ownership and $exit, then returns access to choices",
    ({choice, exit}) => {
      if (choice) setMarketingConsent(choice);
      document.body.style.overflow = "auto";
      // Compose the real consent shell and service at the shared-site boundary.
      // Fresh/reopened adapter state and geometry are covered in the real browser.
      render(<><PublicSiteHeader /><MarketingConsentBannerShell
        aria-label={websiteCopy["marketingconsentbanner_0328"]}
        body={marketingConsentPreferencesCopy.body}
        actions={<>
          <Button onClick={() => setMarketingConsent("analytics")}>{marketingConsentPreferencesCopy.allowAnalytics}</Button>
          <Button onClick={() => setMarketingConsent("accepted")}>{marketingConsentPreferencesCopy.allowMarketing}</Button>
          <Button onClick={() => setMarketingConsent("essential")}>{websiteCopy["marketingconsentbanner_0330"]}</Button>
        </>}
      /></>);
      const analyticsChoice = screen.getByRole("button", {name: marketingConsentPreferencesCopy.allowAnalytics});
      const marketingChoice = screen.getByRole("button", {name: marketingConsentPreferencesCopy.allowMarketing});
      const essentialChoice = screen.getByRole("button", {name: "Essential only"});
      const storedConsent = localStorage.getItem("catch_marketing_consent_v2");
      const consent = getMarketingConsent();
      const consentMode = [...(window.dataLayer ?? [])];
      const menu = screen.getByRole("button", {name: "Menu"});
      fireEvent.click(menu);
      const dialog = screen.getByRole("dialog");
      const mobile = within(dialog);
      const close = mobile.getByRole("button", {name: "Close"});
      const last = mobile.getByRole("link", {name: "Get started free"});
      expect(document.activeElement).toBe(close);
      expect(document.body.style.overflow).toBe("hidden");
      fireEvent.keyDown(document, {key: "Tab", shiftKey: true});
      expect(document.activeElement).toBe(last);
      fireEvent.keyDown(document, {key: "Tab"});
      expect(document.activeElement).toBe(close);
      // An outside focus target must rejoin the active menu's keyboard cycle.
      analyticsChoice.focus();
      fireEvent.keyDown(document, {key: "Tab"});
      expect(document.activeElement).toBe(close);
      marketingChoice.focus();
      fireEvent.keyDown(document, {key: "Tab", shiftKey: true});
      expect(document.activeElement).toBe(last);
      if (exit === "Escape") fireEvent.keyDown(document, {key: "Escape"});
      else if (exit === "Close") fireEvent.click(close);
      else {
        const action = mobile.getByRole("link", {name: exit});
        // jsdom covers close ownership; real navigation is checked in the browser.
        action.addEventListener("click", (event) => event.preventDefault(), {once: true});
        fireEvent.click(action);
      }
      expect(menu.getAttribute("aria-expanded")).toBe("false");
      expect(dialog.hasAttribute("inert")).toBe(true);
      expect(document.activeElement).toBe(menu);
      expect(document.body.style.overflow).toBe("auto");
      expect(localStorage.getItem("catch_marketing_consent_v2")).toBe(storedConsent);
      expect(getMarketingConsent()).toEqual(consent);
      expect(window.dataLayer).toEqual(consentMode);
      expect(screen.getByRole("button", {name: marketingConsentPreferencesCopy.allowAnalytics})).toBe(analyticsChoice);
      expect(screen.getByRole("button", {name: marketingConsentPreferencesCopy.allowMarketing})).toBe(marketingChoice);
      expect(screen.getByRole("button", {name: "Essential only"})).toBe(essentialChoice);
      fireEvent.click(essentialChoice);
      expect(getMarketingConsent()).toMatchObject({version: 2, choice: "essential", analytics: false, marketing: false});
    }
  );
});
