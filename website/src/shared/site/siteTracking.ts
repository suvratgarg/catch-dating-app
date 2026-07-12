import {
  marketingCtaClickParameters,
  trackMarketingEvent,
} from "../../analytics";

export function trackSiteCtaClick(label: string, href: string) {
  trackMarketingEvent("cta_click", marketingCtaClickParameters(label, href));
}

export function slugForTracking(value: string) {
  return value.toLowerCase().replace(/[^a-z0-9]+/g, "_").replace(/^_|_$/g, "");
}
