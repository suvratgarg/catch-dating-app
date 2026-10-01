import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import {cleanup, render, screen, within} from "@testing-library/react";
import {afterEach, describe, expect, it, vi} from "vitest";
import {HomePage, VisitorDiscoveryPage} from "../features/home/HomePage";
import {ClaimPage} from "../features/claims/ClaimPage";
import {emptyClaimRouteState} from "../features/claims/claimRouting";
import {websiteCopy} from "../content/generated";

vi.mock("../analytics", () => ({trackMarketingEvent: vi.fn()}));
vi.mock("../firebaseConfig", () => ({claimFirebaseConfigured: false,
  publicReviewsFirebaseConfigured: false}));
vi.mock("../firebase", () => ({watchClaimAuthState: (callback: (user: null) => void) => {
  callback(null); return () => undefined;
}, requestOrganizerClaim: vi.fn(), signInForClaim: vi.fn(), signOutClaimUser: vi.fn()}));
afterEach(cleanup);

function renderPage(page: React.ReactNode) {
  return render(<QueryClientProvider client={new QueryClient({defaultOptions: {
    queries: {retry: false}, mutations: {retry: false},
  }})}>{page}</QueryClientProvider>);
}

describe("public route navigation targets", () => {
  it("keeps every canonical root section reachable without a duplicate local menu", () => {
    const {container} = renderPage(<HomePage captures={{}} />);
    const nav = screen.getByRole("navigation", {name: "Primary"});
    for (const link of within(nav).getAllByRole("link")) {
      const href = link.getAttribute("href")!;
      expect(href.startsWith("/#")).toBe(true);
      expect(container.querySelector(href.slice(1))).toBeTruthy();
    }
    expect(screen.queryByRole("navigation", {name: "On this page"})).toBeNull();
  });

  it("preserves the discovery menu labels, local anchors and visitor waitlist", () => {
    const {container} = renderPage(<VisitorDiscoveryPage captures={{}} />);
    const local = screen.getByRole("navigation", {name: "On this page"});
    expect(within(local).getAllByRole("link").map((link) => link.textContent)).toEqual([
      websiteCopy.homepage_0110, websiteCopy.homepage_0112, websiteCopy.homepage_0115,
      websiteCopy.homepage_0113, websiteCopy.homepage_0117, websiteCopy.homepage_0116,
      websiteCopy.homepage_0111, websiteCopy.homepage_0114,
    ]);
    const links = [...within(local).getAllByRole("link"),
      ...within(screen.getByRole("navigation", {name: "Related links"})).getAllByRole("link")];
    for (const link of links) {
      const href = link.getAttribute("href")!;
      if (href.startsWith("#")) expect(container.querySelector(href)).toBeTruthy();
    }
  });

  it("sends claim Trust and Member site to the preserved visitor route", () => {
    renderPage(<ClaimPage routeState={emptyClaimRouteState} />);
    const local = screen.getByRole("navigation", {name: "On this page"});
    expect(within(local).getByRole("link", {name: websiteCopy.claimpage_0031})
      .getAttribute("href")).toBe("/explore/#trust");
    const footer = screen.getByRole("navigation", {name: "Related links"});
    expect(within(footer).getByRole("link", {name: websiteCopy.claimpage_0028})
      .getAttribute("href")).toBe("/explore/");
  });
});
