import type {CatchProviderSession, SafeAcquisitionEvent} from "../../analytics/catchMeasurement";

export interface SyntheticDestinationMessage {
  destination: "ga4_synthetic" | "google_ads_synthetic" | "meta_synthetic";
  name: string;
  consent: SafeAcquisitionEvent["consent"];
  parameters: Readonly<Record<string, string | number>>;
}
export type SyntheticDestination = (message: SyntheticDestinationMessage) => void;
const googleNames = {
  page_view: "page_view", cta_click: "cta_click", acquisition_start: "acquisition_start",
  lead_accepted: "generate_lead", organizer_signup: "sign_up", claim_approved: "claim_approved",
  organizer_activated: "organizer_activated", purchase: "purchase",
} as const;
const metaNames = {
  page_view: "PageView", cta_click: "CatchCtaClick", acquisition_start: "CatchAcquisitionStart",
  lead_accepted: "Lead", organizer_signup: "CompleteRegistration", claim_approved: "CatchClaimApproved",
  organizer_activated: "CatchOrganizerActivated", purchase: "Purchase",
} as const;
const selectedGoogleOutcomes = new Set(["lead_accepted", "organizer_signup", "claim_approved", "purchase"]);

/** Fixed adapters take only the rebuilt safe event. No tag stack or live ID support. */
export function createGoogleAcquisitionAdapter(destination: SyntheticDestination): CatchProviderSession {
  return adapter((event) => {
    destination({destination: "ga4_synthetic", name: googleNames[event.name], parameters: event.parameters, consent: event.consent});
    if (event.consent.marketing && event.parameters.audience === "organizer" && selectedGoogleOutcomes.has(event.name)) {
      destination({destination: "google_ads_synthetic", name: googleNames[event.name], parameters: event.parameters, consent: event.consent});
    }
  });
}

export function createMetaAcquisitionAdapter(destination: SyntheticDestination): CatchProviderSession {
  return adapter((event) => {
    // Attendee waitlist/booking behavior is separate from organizer acquisition ads.
    if (!event.consent.marketing || event.parameters.audience !== "organizer") return;
    destination({destination: "meta_synthetic", name: metaNames[event.name], parameters: event.parameters, consent: event.consent});
  });
}

function adapter(send: (event: SafeAcquisitionEvent) => void): CatchProviderSession {
  let destroyed = false;
  return {send(event) { if (!destroyed) send(event); }, destroy() { destroyed = true; }};
}
