import {getMarketingConsent, marketingConsentChangedEvent} from "../../analytics";
import {organizerPolicyForListing} from "./organizerPolicy";
import {isPublicApiEnabled} from "./selectors";
import {readOrganizerProviderSettings} from "./trackingProvidersRepository";
import {createOrganizerTrackingController, type OrganizerTrackingSettings, type ProviderTransport} from "./trackingProviders";
import type {HostListing} from "./types";

interface ProviderObserverDependencies {
  readSettings?: (payload: {organizerId: string; eventId: string | null}) => Promise<OrganizerTrackingSettings>;
  transport?: ProviderTransport;
}
const active = new Map<object, {organizerId: string; eventId: string | null;
  publicPath: string; controller: ReturnType<typeof createOrganizerTrackingController>}>();

// Lifecycle is owned by existing public page effects. A fresh epoch fences every
// async response after navigation/revocation; failed settings never load a tag.
export function observeOrganizerProviders(
  listing: HostListing,
  eventId: string | null = null,
  dependencies: ProviderObserverDependencies = {}
): () => void {
  const controller = createOrganizerTrackingController(dependencies.transport);
  const publicPath = window.location.pathname;
  const identity = {};
  const eligible = isPublicApiEnabled(listing) && organizerPolicyForListing(listing).isPubliclyReadable &&
    /^\/(?:organizers|events)\/[A-Za-z0-9_-]{1,160}\/$/u.test(publicPath);
  let epoch = 0;
  let stopped = false;
  const refresh = async () => {
    const generation = ++epoch;
    controller.destroy();
    active.delete(identity);
    const consent = getMarketingConsent();
    if (stopped || !eligible || window.location.pathname !== publicPath ||
      (!consent?.analytics && !consent?.marketing)) return;
    try {
      const settings = await (dependencies.readSettings ?? readOrganizerProviderSettings)({organizerId: listing.id, eventId});
      const latest = getMarketingConsent();
      if (stopped || generation !== epoch || window.location.pathname !== publicPath ||
        (!latest?.analytics && !latest?.marketing)) return;
      controller.update({organizerId: listing.id, eventId, publicPath, eligible, settings,
        consent: {analytics: latest.analytics === true, marketing: latest.marketing === true}});
      active.set(identity, {organizerId: listing.id, eventId, publicPath, controller});
      controller.track("page_view");
    } catch { /* Provider settings are optional; a denied/missing owner is silent. */ }
  };
  void refresh();
  window.addEventListener(marketingConsentChangedEvent, refresh);
  return () => {
    stopped = true; ++epoch; active.delete(identity); controller.destroy();
    window.removeEventListener(marketingConsentChangedEvent, refresh);
  };
}

export function trackOrganizerProviderOutboundClick(organizerId: string, eventId: string) {
  const consent = getMarketingConsent();
  if (!consent?.analytics && !consent?.marketing) return;
  for (const session of active.values()) {
    // Event-specific approval must match. Listing-page event cards do not imply
    // approval for the clicked event and therefore are first-party only.
    if (session.organizerId === organizerId && session.eventId === eventId &&
      session.publicPath === window.location.pathname) session.controller.track("outbound_booking_click");
  }
}
