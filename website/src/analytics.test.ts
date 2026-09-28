import {beforeEach, expect, test} from "vitest";
import {initializeMarketingAnalytics, setMarketingConsent,
  trackClientErrorSignal, trackMarketingEvent, trackPageView} from "./analytics";

beforeEach(() => {
  localStorage.clear();
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
