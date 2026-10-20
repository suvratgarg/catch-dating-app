import type {CatchProviderSession, SafeAcquisitionEvent} from "../analytics.ts";

/** Public destination identifiers, never credentials. Activation follows network
 * acceptance and refreshed consent copy; merely configuring an account is not activation. */
export const catchLiveDestinations = Object.freeze({
  enabled: false,
  serverConsentEnabled: false,
  previewOrigin: "https://catch-dating-app-64e51--next-candidate-tnpxnhes.web.app",
  googleMeasurementId: "G-HZFG0DL2DK",
  googleAdsLeadDestination: "AW-18526407471/dUL7CNKBn6MdEK-WioJF",
});

export type CatchMeasurementMode = "disabled" | "google-preview-v1" | "google-live-v1" | "host-server-live-v1";
export function catchMeasurementMode(origin = typeof window === "undefined" ? "" : window.location.origin): CatchMeasurementMode {
  if (origin === catchLiveDestinations.previewOrigin) return "google-preview-v1";
  return catchLiveDestinations.enabled && origin === "https://catchdates.com" ?
    catchLiveDestinations.serverConsentEnabled ? "host-server-live-v1" : "google-live-v1" : "disabled";
}

type RuntimePort = Pick<HTMLIFrameElement, "contentWindow" | "remove" | "addEventListener" | "removeEventListener">;
export interface RuntimeEnvironment {
  create(): RuntimePort;
  mount(frame: RuntimePort): void;
  channel(): string;
}

function browserEnvironment(): RuntimeEnvironment {
  return {
    create() {
      const frame = document.createElement("iframe");
      frame.setAttribute("sandbox", "allow-scripts");
      frame.referrerPolicy = "no-referrer";
      frame.hidden = true;
      frame.setAttribute("aria-hidden", "true");
      frame.title = "Catch acquisition measurement";
      frame.src = "/catch-acquisition-runtime.html";
      return frame;
    },
    mount(frame) { document.body.appendChild(frame as HTMLIFrameElement); },
    channel: () => crypto.randomUUID(),
  };
}

/** This factory never consumes window.dataLayer or an external gtag. An opaque
 * frame cannot read Catch's DOM/storage and is removed on every lifecycle exit.
 * Attribution is supplied only by the consented browser context. Provider
 * receipt and real ad-click attribution still require separate live acceptance. */
export function createCatchLiveGoogleSession(
  environment: RuntimeEnvironment = browserEnvironment(),
): CatchProviderSession {
  const frame = environment.create();
  const channel = environment.channel();
  let destroyed = false;
  let ready = false;
  const pending: SafeAcquisitionEvent[] = [];
  const post = (event: SafeAcquisitionEvent) => frame.contentWindow?.postMessage({
    type: "catch:acquisition-event", channel, event,
  }, "*");
  const loaded = () => {
    if (destroyed) return;
    ready = true;
    frame.contentWindow?.postMessage({type: "catch:acquisition-init", channel,
      measurementId: catchLiveDestinations.googleMeasurementId,
      leadDestination: catchLiveDestinations.googleAdsLeadDestination}, "*");
    for (const event of pending.splice(0)) post(event);
  };
  frame.addEventListener("load", loaded, {once: true});
  environment.mount(frame);
  return {
    send(event) {
      if (destroyed || event.consent.analytics !== true) return;
      // Only the already wired outcomes. Contract seams are not live authority.
      if (!["page_view", "cta_click", "acquisition_start", "lead_accepted"].includes(event.name)) return;
      if (ready) post(event);
      else if (pending.length < 20) pending.push(event);
    },
    destroy() {
      destroyed = true;
      pending.length = 0;
      frame.removeEventListener("load", loaded);
      frame.remove();
    },
  };
}

export function configuredCatchTransport(provider: "google" | "meta"): CatchProviderSession {
  if (catchMeasurementMode() === "disabled" || provider !== "google") {
    return {send() {}, destroy() {}};
  }
  return createCatchLiveGoogleSession();
}
