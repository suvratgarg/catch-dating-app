import {
  marketingCtaClickParameters,
  trackMarketingEvent,
} from "../../analytics";

export function trackCtaClick(label: string, href: string) {
  trackMarketingEvent("cta_click", marketingCtaClickParameters(label, href));
}
