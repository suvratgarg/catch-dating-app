import {fireEvent, render, renderHook, screen} from "@testing-library/react";
import {beforeEach, describe, expect, it, vi} from "vitest";
import {AppDownloadCtaGroup} from "../../shared/ui/primitives";

const trackMarketingEvent = vi.hoisted(() => vi.fn());
const trackCtaClick = vi.hoisted(() => vi.fn());

vi.mock("../../analytics", () => ({trackMarketingEvent}));
vi.mock("./tracking", () => ({trackCtaClick}));

import {useAppDownloadCtas} from "./useAppDownloadCtas";

describe("useAppDownloadCtas", () => {
  beforeEach(() => {
    trackMarketingEvent.mockReset();
    trackCtaClick.mockReset();
    window.history.replaceState({}, "", "/?source=test");
  });

  it("records unavailable store CTAs as pending instead of navigating", () => {
    const {result} = renderHook(() => useAppDownloadCtas({placement: "home_hero"}));
    const store = {...result.current.items[0], href: ""};

    render(<AppDownloadCtaGroup {...result.current} items={[store]} />);
    fireEvent.click(screen.getByRole("button", {name: new RegExp(store.label)}));

    expect(trackMarketingEvent).toHaveBeenCalledWith("store_cta_pending", {
      platform: store.platform,
      placement: "home_hero",
      page_path: "/?source=test",
    });
    expect(trackCtaClick).not.toHaveBeenCalled();
  });

  it("records configured store navigation with placement and destination", () => {
    const {result} = renderHook(() => useAppDownloadCtas({placement: "home_download_section"}));
    const store = {...result.current.items[0], href: "https://store.example/catch"};

    render(<AppDownloadCtaGroup {...result.current} items={[store]} />);
    fireEvent.click(screen.getByRole("link", {name: new RegExp(store.label)}));

    expect(trackCtaClick).toHaveBeenCalledWith(
      `store_home_download_section_${store.platform}`,
      store.href
    );
    expect(trackMarketingEvent).toHaveBeenCalledWith("store_cta_click", {
      platform: store.platform,
      placement: "home_download_section",
      store_href: store.href,
      page_path: "/?source=test",
    });
  });
});
