type ConsentChoice = "accepted" | "essential";
type FormVariant = "member" | "host";

export const marketingContentVersion = "website_copy_v2" as const;

interface MarketingConsent {
  choice: ConsentChoice;
  analytics: boolean;
  marketing: boolean;
  updatedAt: string;
}

interface AttributionTouch {
  capturedAt: string;
  landingPath: string;
  landingUrl: string;
  referrer: string | null;
  values: Record<string, string>;
}

interface StoredAttribution {
  firstTouch: AttributionTouch;
  lastTouch: AttributionTouch;
}

export interface WaitlistAnalyticsPayload {
  attribution: StoredAttribution | null;
  analytics: {
    consent: MarketingConsent | null;
    eventId: string;
    formVariant: FormVariant;
    pagePath: string;
    pageTitle: string;
    submittedAt: string;
  };
}

declare global {
  interface Window {
    dataLayer?: Array<Record<string, unknown>>;
    gtag?: (...args: unknown[]) => void;
  }
}

const attributionStorageKey = "catch_marketing_attribution_v1";
const consentStorageKey = "catch_marketing_consent_v1";
const trackedPageViews = new Set<string>();
let gtmLoaded = false;
let clientErrorMonitoringInstalled = false;

const attributionKeys = [
  "utm_source",
  "utm_medium",
  "utm_campaign",
  "utm_content",
  "utm_term",
  "gclid",
  "gbraid",
  "wbraid",
  "fbclid",
  "ttclid",
  "msclkid",
  "li_fat_id",
  "rdt_cid",
];

function dataLayer() {
  window.dataLayer = window.dataLayer ?? [];
  return window.dataLayer;
}

function gtag(...args: unknown[]) {
  dataLayer().push(args as unknown as Record<string, unknown>);
}

export function initializeMarketingAnalytics() {
  captureAttribution();
  installConsentDefaults();
  installClientErrorMonitoring();
  maybeLoadGtm();
}

export function trackClientErrorSignal(errorSource: "window_error" | "unhandled_rejection") {
  if (!getMarketingConsent()?.analytics) return false;
  trackMarketingEvent("client_error", {
    error_source: errorSource,
    page_path: window.location.pathname,
  });
  return true;
}

export function getMarketingConsent(): MarketingConsent | null {
  const stored = readJson<MarketingConsent>(consentStorageKey);
  if (!stored || !stored.choice || typeof stored.updatedAt !== "string") {
    return null;
  }
  return stored;
}

export function shouldShowMarketingConsentBanner(
  consent: MarketingConsent | null = getMarketingConsent()
) {
  return consent === null;
}

export function setMarketingConsent(choice: ConsentChoice) {
  const consent: MarketingConsent = {
    choice,
    analytics: choice === "accepted",
    marketing: choice === "accepted",
    updatedAt: new Date().toISOString(),
  };
  writeJson(consentStorageKey, consent);
  updateConsentMode(consent);
  maybeLoadGtm();
  trackMarketingEvent("consent_updated", {
    analytics_consent: consent.analytics,
    marketing_consent: consent.marketing,
  });
  return consent;
}

export function trackPageView(pageName: string) {
  const pagePath = window.location.pathname;
  const pageKey = `${pageName}:${pagePath}`;
  if (trackedPageViews.has(pageKey)) return;
  trackedPageViews.add(pageKey);

  trackMarketingEvent("page_view", {
    page_name: pageName,
    page_path: pagePath,
    page_location: window.location.href,
    page_title: document.title,
  });
}

export function trackMarketingEvent(
  eventName: string,
  parameters: Record<string, unknown> = {}
) {
  const sanitizedParameters = {...parameters};
  sanitizeAnalyticsUrlParameter(sanitizedParameters, "page_path");
  sanitizeAnalyticsUrlParameter(sanitizedParameters, "page_location");

  dataLayer().push({
    event: eventName,
    ...sanitizedParameters,
    content_version: marketingContentVersion,
  });
}

export function marketingCtaClickParameters(label: string, href: string) {
  return {
    cta_href: href,
    cta_label: label,
    page_path: window.location.pathname,
  };
}

export function createMarketingEventId(prefix: string) {
  const random =
    typeof crypto !== "undefined" && "randomUUID" in crypto
      ? crypto.randomUUID()
      : Math.random().toString(36).slice(2);
  return `${prefix}_${Date.now()}_${random}`;
}

export function waitlistAnalyticsPayload(
  eventId: string,
  formVariant: FormVariant
): WaitlistAnalyticsPayload {
  return {
    attribution: readAttribution(),
    analytics: {
      consent: getMarketingConsent(),
      eventId,
      formVariant,
      pagePath: window.location.pathname,
      pageTitle: document.title,
      submittedAt: new Date().toISOString(),
    },
  };
}

function installConsentDefaults() {
  window.gtag = window.gtag ?? gtag;
  const consent = getMarketingConsent();
  if (consent) {
    updateConsentMode(consent);
    return;
  }

  window.gtag("consent", "default", {
    ad_personalization: "denied",
    ad_storage: "denied",
    ad_user_data: "denied",
    analytics_storage: "denied",
  });
}

function updateConsentMode(consent: MarketingConsent) {
  window.gtag = window.gtag ?? gtag;
  window.gtag("consent", "update", {
    ad_personalization: consent.marketing ? "granted" : "denied",
    ad_storage: consent.marketing ? "granted" : "denied",
    ad_user_data: consent.marketing ? "granted" : "denied",
    analytics_storage: consent.analytics ? "granted" : "denied",
  });
}

function maybeLoadGtm() {
  if (gtmLoaded) return;
  const gtmId = import.meta.env?.VITE_GTM_ID;
  if (!gtmId) return;

  const consent = getMarketingConsent();
  if (!consent?.analytics && !consent?.marketing) return;

  gtmLoaded = true;
  dataLayer().push({
    event: "gtm.js",
    "gtm.start": Date.now(),
  });

  const script = document.createElement("script");
  script.async = true;
  script.src = `https://www.googletagmanager.com/gtm.js?id=${encodeURIComponent(
    gtmId
  )}`;
  document.head.appendChild(script);
}

function installClientErrorMonitoring() {
  if (clientErrorMonitoringInstalled) return;
  clientErrorMonitoringInstalled = true;
  window.addEventListener("error", () => {
    trackClientErrorSignal("window_error");
  });
  window.addEventListener("unhandledrejection", () => {
    trackClientErrorSignal("unhandled_rejection");
  });
}

function captureAttribution() {
  const current = currentAttributionTouch();
  const stored = readAttribution();
  if (!stored) {
    writeJson(attributionStorageKey, {
      firstTouch: current,
      lastTouch: current,
    });
    return;
  }

  if (Object.keys(current.values).length === 0 && !current.referrer) {
    return;
  }

  writeJson(attributionStorageKey, {
    firstTouch: stored.firstTouch,
    lastTouch: current,
  });
}

function readAttribution(): StoredAttribution | null {
  const stored = readJson<StoredAttribution>(attributionStorageKey);
  if (!stored?.firstTouch || !stored?.lastTouch) return null;
  return stored;
}

function currentAttributionTouch(): AttributionTouch {
  const params = new URLSearchParams(window.location.search);
  const values: Record<string, string> = {};
  for (const key of attributionKeys) {
    const value = params.get(key);
    if (value) values[key] = value.slice(0, 240);
  }

  return {
    capturedAt: new Date().toISOString(),
    landingPath: `${window.location.pathname}${window.location.search}`,
    landingUrl: window.location.href,
    referrer: document.referrer || null,
    values,
  };
}

function sanitizeAnalyticsUrlParameter(
  parameters: Record<string, unknown>,
  key: "page_path" | "page_location"
) {
  const value = parameters[key];
  if (typeof value !== "string") return;
  parameters[key] = value.split("?", 1)[0];
}

function readJson<T>(key: string): T | null {
  try {
    const raw = window.localStorage.getItem(key);
    return raw ? (JSON.parse(raw) as T) : null;
  } catch {
    return null;
  }
}

function writeJson(key: string, value: unknown) {
  try {
    window.localStorage.setItem(key, JSON.stringify(value));
  } catch {
    // Attribution and consent storage should not block form submission.
  }
}
