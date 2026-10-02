/** Controlled public-page adapters. Settings must come from the public callable,
 * never organizer-authored snippets. A destroyed iframe cannot observe later routes.
 * Provider delivery and cookie support in an opaque sandbox need live review.
 */
import type {PublicOrganizerTrackingSettingsCallableResponse} from "../../firebase";

export interface OrganizerTrackingSettings extends Pick<PublicOrganizerTrackingSettingsCallableResponse, "organizerId" | "eventId"> {
  enabled: boolean;
  metaPixelId: string | null;
  googleMeasurementId: string | null;
}

export interface OrganizerTrackingContext {
  organizerId: string;
  eventId: string | null;
  publicPath: string;
  eligible: boolean;
  consent: {analytics: boolean; marketing: boolean};
  settings: OrganizerTrackingSettings | null;
}

export type OrganizerProviderEvent = "page_view" | "outbound_booking_click";
export interface ProviderSession {
  send(event: OrganizerProviderEvent): void;
  destroy(): void;
}
export interface ProviderSessionConfiguration {
  provider: "ga4" | "meta";
  id: string;
  publicPath: string;
}
export type ProviderTransport = (configuration: ProviderSessionConfiguration) => ProviderSession;
const providerPageViews = new Set<string>();

export function createOrganizerTrackingController(
  transport: ProviderTransport = createSandboxedProviderSession,
  views: Set<string> = providerPageViews
) {
  const sessions = new Map<string, ProviderSession>();
  let current: OrganizerTrackingContext | null = null;

  function update(context: OrganizerTrackingContext) {
    current = context;
    const wanted = new Map<string, ProviderSessionConfiguration>();
    const settings = context.settings;
    if (context.eligible && safePublicPath(context.publicPath) && settings?.enabled === true &&
      settings.organizerId === context.organizerId && settings.eventId === context.eventId) {
      if (context.consent.analytics === true && /^G-[A-Z0-9]{4,20}$/u.test(settings.googleMeasurementId ?? "")) {
        wanted.set(key("ga4", settings.googleMeasurementId!), {
          provider: "ga4", id: settings.googleMeasurementId!, publicPath: context.publicPath,
        });
      }
      if (context.consent.marketing === true && /^[0-9]{5,20}$/u.test(settings.metaPixelId ?? "")) {
        wanted.set(key("meta", settings.metaPixelId!), {
          provider: "meta", id: settings.metaPixelId!, publicPath: context.publicPath,
        });
      }
    }
    for (const [sessionKey, session] of sessions) {
      if (!wanted.has(sessionKey)) { session.destroy(); sessions.delete(sessionKey); }
    }
    for (const [sessionKey, configuration] of wanted) {
      if (!sessions.has(sessionKey)) {
        try { sessions.set(sessionKey, transport(configuration)); } catch { /* Optional tags cannot block a page. */ }
      }
    }
  }

  function key(provider: string, id: string) {
    return JSON.stringify([current?.organizerId, current?.eventId, current?.publicPath, provider, id]);
  }

  function track(event: OrganizerProviderEvent) {
    // Runtime guard also protects plain JS callers; there is no purchase/success API.
    if (event !== "page_view" && event !== "outbound_booking_click") return;
    for (const [sessionKey, session] of sessions) {
      if (event === "page_view" && views.has(sessionKey)) continue;
      try {
        session.send(event);
        if (event === "page_view") {
          if (views.size >= 1000) views.clear();
          views.add(sessionKey);
        }
      } catch { /* Optional provider failures cannot block booking navigation. */ }
    }
  }

  function destroy() {
    for (const session of sessions.values()) session.destroy();
    sessions.clear();
    current = null;
  }
  return {update, track, destroy};
}

function safePublicPath(path: string) {
  return /^\/(?:organizers|events)\/[A-Za-z0-9_-]{1,160}\/$/u.test(path);
}

function createSandboxedProviderSession(configuration: ProviderSessionConfiguration): ProviderSession {
  const frame = document.createElement("iframe");
  // Opaque origin deliberately prevents vendor code reading Catch storage/DOM.
  // Do not add allow-same-origin: that would let vendor scripts escape this sandbox.
  frame.setAttribute("sandbox", "allow-scripts");
  frame.referrerPolicy = "no-referrer";
  frame.hidden = true;
  frame.setAttribute("aria-hidden", "true");
  frame.src = "/organizer-tracking-runtime.html";
  let destroyed = false;
  let initialized = false;
  const queue: OrganizerProviderEvent[] = [];
  const channel = crypto.randomUUID();
  const send = (event: OrganizerProviderEvent) => {
    frame.contentWindow?.postMessage({type: "catch:provider-event", channel, event}, "*");
  };
  const loaded = () => {
    if (destroyed) return;
    initialized = true;
    frame.contentWindow?.postMessage({type: "catch:provider-init", channel, ...configuration,
      publicOrigin: window.location.origin}, "*");
    for (const event of queue.splice(0)) send(event);
  };
  frame.addEventListener("load", loaded, {once: true});
  document.body.appendChild(frame);
  return {
    send(event) {
      if (destroyed) return;
      if (initialized) send(event);
      else if (queue.length < 50) queue.push(event);
    },
    destroy() {
      destroyed = true;
      queue.length = 0;
      frame.removeEventListener("load", loaded);
      frame.remove();
    },
  };
}
