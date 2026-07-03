import {trackMarketingEvent} from "../../analytics";

export function trackSiteCtaClick(label: string, href: string) {
  trackMarketingEvent("cta_click", {
    cta_href: href,
    cta_label: label,
    page_path: `${window.location.pathname}${window.location.search}`,
  });
}

export function slugForTracking(value: string) {
  return value.toLowerCase().replace(/[^a-z0-9]+/g, "_").replace(/^_|_$/g, "");
}
