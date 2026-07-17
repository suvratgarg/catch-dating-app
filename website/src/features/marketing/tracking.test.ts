import {beforeEach, describe, expect, it, vi} from "vitest";

const marketingCtaClickParameters = vi.hoisted(() => vi.fn());
const trackMarketingEvent = vi.hoisted(() => vi.fn());

vi.mock("../../analytics", () => ({
  marketingCtaClickParameters,
  trackMarketingEvent,
}));

import {trackCtaClick} from "./tracking";

describe("trackCtaClick", () => {
  beforeEach(() => {
    marketingCtaClickParameters.mockReturnValue({
      cta_label: "Apply",
      cta_href: "/host/",
      page_path: "/",
    });
  });

  it("preserves the analytics CTA transport shape", () => {
    trackCtaClick("Apply", "/host/");
    expect(marketingCtaClickParameters).toHaveBeenCalledWith("Apply", "/host/");
    expect(trackMarketingEvent).toHaveBeenCalledWith("cta_click", {
      cta_label: "Apply",
      cta_href: "/host/",
      page_path: "/",
    });
  });
});
