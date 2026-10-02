import {beforeEach, expect, test, vi} from "vitest";
import {initializeMarketingAnalytics, setMarketingConsent,
  getMarketingConsent, trackClientErrorSignal, trackMarketingEvent, trackPageView, waitlistAnalyticsPayload} from "./analytics";

beforeEach(() => {
  localStorage.clear();
  sessionStorage.clear();
  window.dataLayer = [];
  window.history.replaceState(null, "", "/");
});

test("private demo direct entry neither stores attribution nor emits events", () => {
  window.history.replaceState(null, "", "/demo/synthetic-invite/#grant=synthetic");
  initializeMarketingAnalytics();
  trackPageView("sales_demo");
  trackMarketingEvent("synthetic-event");
  expect(window.dataLayer).toEqual([]);
  expect(localStorage.getItem("catch_marketing_attribution_v1")).toBeNull();
});

test("marketing listeners stop emitting after navigation to a private demo", () => {
  setMarketingConsent("accepted");
  initializeMarketingAnalytics();
  const before = localStorage.getItem("catch_marketing_attribution_v1");
  window.dataLayer = [];
  window.history.replaceState(null, "", "/demo/synthetic-invite/#grant=synthetic");
  initializeMarketingAnalytics();
  expect(trackClientErrorSignal("window_error")).toBe(false);
  window.dispatchEvent(new ErrorEvent("error", {message: new Error("Synthetic error").message}));
  trackPageView("sales_demo");
  expect(window.dataLayer).toEqual([]);
  expect(localStorage.getItem("catch_marketing_attribution_v1")).toEqual(before);
});

const legacyKey = "catch_marketing_attribution_v1";
const ephemeralKey = "catch_marketing_attribution_v2";

function attribution() { return waitlistAnalyticsPayload("test", "host").attribution; }

test("unset and essential consent clear obsolete raw attribution without storing a touch", () => {
  window.history.replaceState(null, "", "/host/?utm_campaign=launch&email=person@example.com#private");
  localStorage.setItem(legacyKey, JSON.stringify({firstTouch: {landingUrl: location.href}}));
  initializeMarketingAnalytics();
  expect(localStorage.getItem(legacyKey)).toBeNull();
  expect(sessionStorage.getItem(ephemeralKey)).toBeNull();
  expect(attribution()).toBeNull();
  setMarketingConsent("essential");
  expect(attribution()).toBeNull();
});

test("analytics consent captures only campaign labels in ephemeral public marketing touches", () => {
  window.history.replaceState(null, "", "/host/?utm_source=newsletter&utm_medium=email&utm_campaign=launch_2026&utm_content=person%40example.com&utm_term=private%20answer&gclid=ad-secret&fbclid=ad-secret&email=private%40example.com#private-token");
  setMarketingConsent("analytics");
  expect(attribution()?.firstTouch).toMatchObject({landingPath: "/host/", referrer: null,
    values: {utm_source: "newsletter", utm_medium: "email", utm_campaign: "launch_2026"}});
  const stored = sessionStorage.getItem(ephemeralKey)!;
  expect(stored).not.toMatch(/private|person|gclid|fbclid|ad-secret|[?#]/u);
  expect(localStorage.getItem(legacyKey)).toBeNull();
  window.history.replaceState(null, "", "/host/planners/?utm_campaign=planner_launch");
  initializeMarketingAnalytics();
  expect(attribution()?.firstTouch.landingPath).toBe("/host/");
  expect(attribution()?.lastTouch.values).toEqual({utm_campaign: "planner_launch"});
  setMarketingConsent("essential");
  expect(sessionStorage.getItem(ephemeralKey)).toBeNull();
  expect(attribution()).toBeNull();
});

test.each(["/events/social-event/", "/organizers/dating-host/", "/f/private-form/", "/offer/", "/booking/private-booking/", "/demo/private-demo/"])(
  "never captures campaign attribution on %s even after accepted consent", (path) => {
    setMarketingConsent("accepted");
    window.history.replaceState(null, "", `${path}?utm_campaign=private_campaign#secret`);
    initializeMarketingAnalytics();
    expect(attribution()).toBeNull();
    expect(sessionStorage.getItem(ephemeralKey)).toBeNull();
  });

test("invalid consent flags fail closed and delete previous attribution", () => {
  setMarketingConsent("analytics");
  localStorage.setItem("catch_marketing_consent_v1", JSON.stringify({choice: "essential", analytics: true, marketing: true, updatedAt: new Date().toISOString()}));
  expect(getMarketingConsent()).toBeNull();
  expect(sessionStorage.getItem(ephemeralKey)).toBeNull();
  localStorage.setItem("catch_marketing_consent_v1", JSON.stringify({choice: "unknown", analytics: true, marketing: true, updatedAt: "bad"}));
  expect(getMarketingConsent()).toBeNull();
});

test("legacy raw attribution is discarded, expired touches are not reused", () => {
  window.history.replaceState(null, "", "/host/?utm_campaign=safe");
  setMarketingConsent("accepted");
  localStorage.setItem(legacyKey, JSON.stringify({firstTouch: {landingUrl: "https://private.test/?email=secret#token"}}));
  expect(attribution()?.firstTouch.values).toEqual({utm_campaign: "safe"});
  expect(localStorage.getItem(legacyKey)).toBeNull();
  const touch = {...attribution()!.firstTouch, capturedAt: "2020-01-01T00:00:00Z"};
  sessionStorage.setItem(ephemeralKey, JSON.stringify({firstTouch: touch, lastTouch: touch}));
  expect(attribution()).toBeNull();
  expect(sessionStorage.getItem(ephemeralKey)).toBeNull();
});

test("an environment GTM ID cannot load a script or call an external global gtag", () => {
  vi.stubEnv("VITE_GTM_ID", "GTM-SYNTHETIC");
  const external = vi.fn();
  window.gtag = external;
  const append = vi.spyOn(document.head, "appendChild");
  setMarketingConsent("accepted"); initializeMarketingAnalytics();
  window.history.replaceState(null, "", "/events/social-event/");
  initializeMarketingAnalytics();
  expect(external).not.toHaveBeenCalled();
  expect(append).not.toHaveBeenCalled();
  expect(window.dataLayer?.some((entry) => entry.event === "gtm.js")).toBe(false);
  delete window.gtag; vi.unstubAllEnvs();
});
