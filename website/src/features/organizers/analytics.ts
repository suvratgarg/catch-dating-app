import {getMarketingConsent, trackMarketingEvent} from "../../analytics";
import {recordOrganizerAnalyticsEvent} from "../../firebase";
import {isPublicApiEnabled} from "./selectors";
import type {HostListing} from "./types";

type OrganizerAnalyticsEventName =
  | "listingView"
  | "searchAppearance"
  | "eventView"
  | "organizerSave"
  | "eventSave"
  | "contactClick"
  | "claimClick"
  | "outboundClick";

const trackedOrganizerSearchAppearances = new Set<string>();

export function trackOrganizerSearchAppearance(
  listing: HostListing,
  appearanceContext: string
) {
  if (!isPublicApiEnabled(listing)) return;
  if (!hasOrganizerAnalyticsConsent()) return;
  const key = `${listing.id}:${appearanceContext}`;
  if (trackedOrganizerSearchAppearances.has(key)) return;
  if (trackedOrganizerSearchAppearances.size > 2000) {
    trackedOrganizerSearchAppearances.clear();
  }
  trackedOrganizerSearchAppearances.add(key);
  trackOrganizerAnalytics(listing, "searchAppearance", "directory_result");
}

export function trackOrganizerAnalytics(
  listing: HostListing,
  eventName: OrganizerAnalyticsEventName,
  source?: string,
  eventId?: string | null
) {
  if (!isPublicApiEnabled(listing)) return;
  if (!hasOrganizerAnalyticsConsent()) return;
  void recordOrganizerAnalyticsEvent({
    clubId: listing.id,
    eventId: eventId ?? null,
    eventName,
    pagePath: `${window.location.pathname}${window.location.search}`,
    source: source ?? null,
    sessionId: hostAnalyticsSessionId(),
    platform: "web",
  }).catch(() => undefined);
  trackMarketingEvent(`organizer_${eventName}`, {
    club_id: listing.id,
    event_id: eventId ?? null,
    source: source ?? null,
  });
}

function hasOrganizerAnalyticsConsent() {
  return getMarketingConsent()?.analytics === true;
}

function hostAnalyticsSessionId(): string | null {
  try {
    const key = "catch_host_analytics_session_v1";
    const existing = window.localStorage.getItem(key);
    if (existing) return existing;
    const next =
      typeof crypto !== "undefined" && "randomUUID" in crypto
        ? crypto.randomUUID()
        : `session_${Date.now()}_${Math.random().toString(36).slice(2)}`;
    window.localStorage.setItem(key, next);
    return next;
  } catch {
    return null;
  }
}
