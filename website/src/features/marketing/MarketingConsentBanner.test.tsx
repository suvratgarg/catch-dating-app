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
