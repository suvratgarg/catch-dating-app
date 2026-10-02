type ConsentChoice = "accepted" | "analytics" | "essential";
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

const legacyAttributionStorageKey = "catch_marketing_attribution_v1";
const attributionStorageKey = "catch_marketing_attribution_v2";
const attributionMaxAgeMs = 24 * 60 * 60 * 1000;
export const marketingConsentChangedEvent = "catch:marketing-consent-changed";
const consentStorageKey = "catch_marketing_consent_v1";
const trackedPageViews = new Set<string>();
let clientErrorMonitoringInstalled = false;

const attributionKeys = [
  "utm_source",
  "utm_medium",
  "utm_campaign",
  "utm_content",
  "utm_term",
];

function dataLayer() {
  window.dataLayer = window.dataLayer ?? [];
  return window.dataLayer;
}

function gtag(...args: unknown[]) {
  dataLayer().push(args as unknown as Record<string, unknown>);
}

export function initializeMarketingAnalytics() {
  clearLegacyAttribution();
  captureAttribution();
  if (isPrivateEventUpdate()) return;
  installConsentDefaults();
  installClientErrorMonitoring();
  // Arbitrary GTM is deferred. Only the isolated, typed organizer adapters may load providers.
}

export function trackClientErrorSignal(errorSource: "window_error" | "unhandled_rejection") {
  if (isPrivateEventUpdate() || !getMarketingConsent()?.analytics) return false;
  trackMarketingEvent("client_error", {
    error_source: errorSource,
    page_path: window.location.pathname,
  });
  return true;
}

export function getMarketingConsent(): MarketingConsent | null {
  const stored = readJson<MarketingConsent>(consentStorageKey);
  if (!stored || !["accepted", "analytics", "essential"].includes(stored.choice) ||
    typeof stored.updatedAt !== "string" || !Number.isFinite(Date.parse(stored.updatedAt)) ||
    stored.analytics !== (stored.choice !== "essential") ||
    stored.marketing !== (stored.choice === "accepted")) {
    clearAttribution();
    return null;
  }
  if (!stored.analytics) clearAttribution();
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
    analytics: choice !== "essential",
    marketing: choice === "accepted",
    updatedAt: new Date().toISOString(),
  };
  writeJson(consentStorageKey, consent);
  updateConsentMode(consent);
  captureAttribution();
  trackMarketingEvent("consent_updated", {
    analytics_consent: consent.analytics,
    marketing_consent: consent.marketing,
  });
  if (typeof window.dispatchEvent === "function") {
    window.dispatchEvent(new Event(marketingConsentChangedEvent));
  }
  return consent;
}

export function trackPageView(pageName: string) {
  if (isPrivateEventUpdate()) return;
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
  if (isPrivateEventUpdate()) return;
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
  // Keep consent compatibility events local; never call an externally supplied gtag.
  const consent = getMarketingConsent();
  if (consent) {
    updateConsentMode(consent);
    return;
  }

  gtag("consent", "default", {
    ad_personalization: "denied",
    ad_storage: "denied",
    ad_user_data: "denied",
    analytics_storage: "denied",
  });
}

function updateConsentMode(consent: MarketingConsent) {
  // Keep consent compatibility events local; never call an externally supplied gtag.
  gtag("consent", "update", {
    ad_personalization: consent.marketing ? "granted" : "denied",
    ad_storage: consent.marketing ? "granted" : "denied",
    ad_user_data: consent.marketing ? "granted" : "denied",
    analytics_storage: consent.analytics ? "granted" : "denied",
  });
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

const attributionPaths = new Set([
  "/", "/host/", "/host/overview/", "/host/platform/", "/host/planners/",
  "/host/mixers/", "/host/clubs/", "/host/directory/", "/host/claim/",
  "/host/apply/", "/host/stack/", "/host/workflows/",
]);

function canCaptureAttribution() {
  return attributionPaths.has(window.location.pathname) && getMarketingConsent()?.analytics === true;
}

function clearLegacyAttribution() {
  try { window.localStorage.removeItem(legacyAttributionStorageKey); } catch { /* Optional storage. */ }
}

function clearAttribution() {
  clearLegacyAttribution();
  try { window.sessionStorage?.removeItem(attributionStorageKey); } catch { /* Optional storage. */ }
}

function captureAttribution() {
  clearLegacyAttribution();
  if (!canCaptureAttribution()) { clearAttribution(); return; }
  const current = currentAttributionTouch();
  const stored = readAttribution();
  if (stored && Object.keys(current.values).length === 0) return;
  try {
    window.sessionStorage.setItem(attributionStorageKey, JSON.stringify({
      firstTouch: stored?.firstTouch ?? current, lastTouch: current,
    }));
  } catch { /* Attribution must not block a submission. */ }
}

function readAttribution(): StoredAttribution | null {
  clearLegacyAttribution();
  if (!canCaptureAttribution()) { clearAttribution(); return null; }
  try {
    const stored = JSON.parse(window.sessionStorage.getItem(attributionStorageKey) ?? "null") as StoredAttribution | null;
    const firstTouch = safeStoredTouch(stored?.firstTouch);
    const lastTouch = safeStoredTouch(stored?.lastTouch);
    if (!firstTouch || !lastTouch) { clearAttribution(); return null; }
    return {firstTouch, lastTouch};
  } catch { clearAttribution(); return null; }
}

function campaignValues(values: Record<string, unknown>): Record<string, string> {
  const safe: Record<string, string> = {};
  for (const key of attributionKeys) {
    const value = values[key];
    // Campaign labels only: reject addresses, URLs, whitespace, and free-text values.
    if (typeof value === "string" && /^[A-Za-z0-9][A-Za-z0-9_-]{0,79}$/u.test(value)) safe[key] = value;
  }
  return safe;
}

function attributionTouch(capturedAt: string, landingPath: string, values: Record<string, string>): AttributionTouch {
  return {capturedAt, landingPath, landingUrl: `${new URL(window.location.href).origin}${landingPath}`, referrer: null, values};
}

function safeStoredTouch(touch?: AttributionTouch): AttributionTouch | null {
  if (!touch || typeof touch.capturedAt !== "string" || !attributionPaths.has(touch.landingPath) ||
    !touch.values || typeof touch.values !== "object" || Array.isArray(touch.values)) return null;
  const age = Date.now() - Date.parse(touch.capturedAt);
  if (!Number.isFinite(age) || age < 0 || age > attributionMaxAgeMs) return null;
  return attributionTouch(touch.capturedAt, touch.landingPath, campaignValues(touch.values));
}

function currentAttributionTouch(): AttributionTouch {
  const params = new URLSearchParams(window.location.search);
  const values: Record<string, string> = {};
  for (const key of attributionKeys) {
    const value = params.get(key);
    if (value !== null) values[key] = value;
  }
  return attributionTouch(new Date().toISOString(), window.location.pathname, campaignValues(values));
}

function sanitizeAnalyticsUrlParameter(
  parameters: Record<string, unknown>,
  key: "page_path" | "page_location"
) {
  const value = parameters[key];
  if (typeof value !== "string") return;
  parameters[key] = value.split(/[?#]/u, 1)[0];
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

function isPrivateEventUpdate(): boolean {
  return window.location.pathname.startsWith("/demo/") ||
    window.location.pathname.startsWith("/event-update/") ||
    window.location.pathname.startsWith("/booking/") ||
    window.location.pathname === "/offer" || window.location.pathname === "/offer/";
}
