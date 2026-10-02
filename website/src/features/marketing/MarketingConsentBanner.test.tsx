import {cleanup, fireEvent, render, screen} from "@testing-library/react";
import {afterEach, beforeEach, expect, test, vi} from "vitest";
import {getMarketingConsent, marketingConsentChangedEvent} from "../../analytics";
import {MarketingConsentBanner} from "./MarketingConsentBanner";
afterEach(cleanup);
beforeEach(() => {localStorage.clear(); window.dataLayer = [];});
test("analytics consent is separate from advertising and remains revocable", () => {
  const changed = vi.fn();
  window.addEventListener(marketingConsentChangedEvent, changed);
  render(<MarketingConsentBanner />);
  fireEvent.click(screen.getByRole("button", {name: "Allow analytics"}));
  expect(getMarketingConsent()).toMatchObject({choice: "analytics", analytics: true, marketing: false});
  expect(screen.queryByRole("button", {name: "Accept all"})).toBeNull();
  expect(window.dataLayer).toContainEqual(["consent", "update", {
    analytics_storage: "granted",
    ad_storage: "denied",
    ad_user_data: "denied",
    ad_personalization: "denied",
  }]);
  fireEvent.click(screen.getByRole("button", {name: "Privacy choices"}));
  fireEvent.click(screen.getByRole("button", {name: "Essential only"}));
  expect(getMarketingConsent()).toMatchObject({analytics: false, marketing: false});
  expect(changed).toHaveBeenCalledTimes(2);
  window.removeEventListener(marketingConsentChangedEvent, changed);
});

test("explicit marketing choice is versioned and can be withdrawn", () => {
  render(<MarketingConsentBanner />);
  fireEvent.click(screen.getByRole("button", {name: "Allow analytics and marketing"}));
  expect(getMarketingConsent()).toMatchObject({version: 2, analytics: true, marketing: true});
  fireEvent.click(screen.getByRole("button", {name: "Privacy choices"}));
  fireEvent.click(screen.getByRole("button", {name: "Allow analytics"}));
  expect(getMarketingConsent()).toMatchObject({version: 2, analytics: true, marketing: false});
});

test("legacy accepted choice still presents all choices and sibling-tab revocation refreshes the UI", () => {
  localStorage.setItem("catch_marketing_consent_v1", JSON.stringify({choice: "accepted", analytics: true,
    marketing: true, updatedAt: new Date().toISOString()}));
  render(<MarketingConsentBanner />);
  expect(screen.getByRole("button", {name: "Allow analytics and marketing"})).toBeTruthy();
  fireEvent.click(screen.getByRole("button", {name: "Allow analytics"}));
  expect(screen.getByRole("button", {name: "Privacy choices"})).toBeTruthy();
  fireEvent(window, new Event(marketingConsentChangedEvent));
  expect(getMarketingConsent()?.marketing).toBe(false);
});
