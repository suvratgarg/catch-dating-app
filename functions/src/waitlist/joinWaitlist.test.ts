import assert from "node:assert/strict";
import test from "node:test";
import {
  normalizeHostApplication,
  normalizeMarketingAnalytics,
  normalizeMarketingAttribution,
  normalizeWaitlistRole,
  resolveWaitlistCorsOrigin,
  waitlistAllowedOrigins,
} from "./joinWaitlist";

test("waitlistAllowedOrigins includes production custom domains", () => {
  const origins = waitlistAllowedOrigins("catch-dating-app-64e51");

  assert.equal(origins.has("https://catchdates.com"), true);
  assert.equal(origins.has("https://www.catchdates.com"), true);
  assert.equal(origins.has("http://127.0.0.1:5175"), true);
  assert.equal(origins.has("http://127.0.0.1:4187"), true);
  assert.equal(
    origins.has("https://catch-dating-app-64e51.web.app"),
    true
  );
});

test("waitlistAllowedOrigins scopes non-prod projects", () => {
  const origins = waitlistAllowedOrigins("catchdates-dev");

  assert.equal(origins.has("https://catchdates-dev.web.app"), true);
  assert.equal(origins.has("https://catchdates-dev.firebaseapp.com"), true);
  assert.equal(origins.has("https://catchdates.com"), false);
});

test("resolveWaitlistCorsOrigin rejects unknown origins", () => {
  assert.equal(
    resolveWaitlistCorsOrigin(
      "https://attacker.example",
      "catch-dating-app-64e51"
    ),
    null
  );
});

test("normalizeWaitlistRole maps legacy runner to member", () => {
  assert.equal(normalizeWaitlistRole("runner"), "member");
  assert.equal(normalizeWaitlistRole("member"), "member");
  assert.equal(normalizeWaitlistRole("host"), "host");
});

test("normalizeMarketingAttribution keeps known campaign fields", () => {
  const attribution = normalizeMarketingAttribution({
    firstTouch: {
      capturedAt: "2026-06-02T00:00:00.000Z",
      landingPath: "/?utm_source=meta&utm_campaign=mumbai",
      landingUrl: "https://catchdates.com/?utm_source=meta",
      referrer: "https://instagram.com/",
      values: {
        fbclid: "fb-1",
        ignored: "drop-me",
        utm_campaign: "mumbai_hosts",
        utm_source: "meta",
      },
    },
    lastTouch: {
      values: {
        gclid: "google-click",
      },
    },
  });

  assert.deepEqual(attribution, {
    firstTouch: {
      capturedAt: "2026-06-02T00:00:00.000Z",
      landingPath: "/?utm_source=meta&utm_campaign=mumbai",
      landingUrl: "https://catchdates.com/?utm_source=meta",
      referrer: "https://instagram.com/",
      values: {
        fbclid: "fb-1",
        utm_campaign: "mumbai_hosts",
        utm_source: "meta",
      },
    },
    lastTouch: {
      capturedAt: null,
      landingPath: null,
      landingUrl: null,
      referrer: null,
      values: {
        gclid: "google-click",
      },
    },
  });
});

test("normalizeMarketingAnalytics keeps consent and event metadata", () => {
  assert.deepEqual(
    normalizeMarketingAnalytics({
      consent: {
        analytics: true,
        choice: "accepted",
        marketing: true,
        updatedAt: "2026-06-02T00:00:00.000Z",
      },
      eventId: "waitlist_123",
      formVariant: "member",
      pagePath: "/?utm_source=meta",
      pageTitle: "Catch",
      submittedAt: "2026-06-02T00:01:00.000Z",
    }),
    {
      consent: {
        analytics: true,
        choice: "accepted",
        marketing: true,
        updatedAt: "2026-06-02T00:00:00.000Z",
      },
      eventId: "waitlist_123",
      formVariant: "member",
      pagePath: "/?utm_source=meta",
      pageTitle: "Catch",
      submittedAt: "2026-06-02T00:01:00.000Z",
    }
  );
});

test("normalizeHostApplication keeps bounded operating fields", () => {
  assert.deepEqual(
    normalizeHostApplication({
      organizationName: "  Sunday Table  ",
      organizationType: "Venue",
      operatingCity: "Mumbai",
      communityLink: "https://example.com/events",
      formats: ["Dinner", "Dinner", "Singles mixer"],
      eventCadence: "Monthly",
      nextEventName: "Long table no. 1",
      nextEventDate: "2026-06-21",
      eventLocation: "Bandra",
      expectedCapacity: "24",
      priceRange: "₹1,000–₹2,000",
      admissionModel: "Request to join",
      waitlistPlan: "Ranked timed offers",
      paymentReadiness: "Need Catch payment onboarding",
      eventSuccessModules: [
        "Attendance and live roster",
        "Private catch window",
      ],
      hostGoals: "Improve review quality",
      operatingNotes: "Need help with arrival flow",
      ignored: "drop me",
    }),
    {
      organizationName: "Sunday Table",
      organizationType: "Venue",
      operatingCity: "Mumbai",
      communityLink: "https://example.com/events",
      formats: ["Dinner", "Singles mixer"],
      eventCadence: "Monthly",
      nextEventName: "Long table no. 1",
      nextEventDate: "2026-06-21",
      eventLocation: "Bandra",
      expectedCapacity: "24",
      priceRange: "₹1,000–₹2,000",
      admissionModel: "Request to join",
      waitlistPlan: "Ranked timed offers",
      paymentReadiness: "Need Catch payment onboarding",
      eventSuccessModules: [
        "Attendance and live roster",
        "Private catch window",
      ],
      hostGoals: "Improve review quality",
      operatingNotes: "Need help with arrival flow",
    }
  );
});

test("normalizeHostApplication drops empty payloads", () => {
  assert.equal(normalizeHostApplication({formats: []}), null);
  assert.equal(normalizeHostApplication(null), null);
});
