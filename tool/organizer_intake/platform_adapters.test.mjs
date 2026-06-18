import assert from "node:assert/strict";
import test from "node:test";
import {
  normalizeOrganizerSurfaceUrl,
  surfaceFromUrl,
  surfaceIdFromNormalizedKey,
} from "./lib/platform_adapters.mjs";

test("normalizes Luma event URLs", () => {
  const result = normalizeOrganizerSurfaceUrl("https://lu.ma/pxgmph3b?utm_source=google");
  assert.equal(result.canonicalUrl, "https://luma.com/pxgmph3b");
  assert.equal(result.platform, "luma");
  assert.equal(result.surfaceKind, "eventListing");
  assert.equal(result.normalizedKey, "luma:event:pxgmph3b");
  assert.equal(result.crawl.supportsEventExtraction, true);
});

test("normalizes Luma calendar URLs", () => {
  const result = normalizeOrganizerSurfaceUrl("https://luma.com/calendar/afterfly");
  assert.equal(result.platform, "luma");
  assert.equal(result.surfaceKind, "eventCalendar");
  assert.equal(result.normalizedKey, "luma:calendar:afterfly");
});

test("normalizes Instagram profile URLs without using query tokens", () => {
  const result = normalizeOrganizerSurfaceUrl("https://www.instagram.com/AfterFly.In/?igshid=abc");
  assert.equal(result.canonicalUrl, "https://instagram.com/AfterFly.In");
  assert.equal(result.platform, "instagram");
  assert.equal(result.surfaceKind, "socialProfile");
  assert.equal(result.normalizedKey, "instagram:afterfly.in");
  assert.equal(result.crawl.supportsEventExtraction, false);
});

test("does not mint a strong identity key for Instagram content URLs", () => {
  const result = normalizeOrganizerSurfaceUrl("https://instagram.com/p/ABC123/");
  assert.equal(result.platform, "instagram");
  assert.equal(result.surfaceKind, "socialProfile");
  assert.equal(result.normalizedKey, null);
  assert.deepEqual(result.diagnostics, ["instagram_content_url_not_identity_surface"]);
});

test("normalizes Partiful event URLs", () => {
  const result = normalizeOrganizerSurfaceUrl("https://partiful.com/e/abcDEF");
  assert.equal(result.platform, "partiful");
  assert.equal(result.surfaceKind, "eventListing");
  assert.equal(result.normalizedKey, "partiful:event:abcdef");
  assert.equal(result.crawl.supportsEventExtraction, true);
});

test("normalizes District event URLs", () => {
  const result = normalizeOrganizerSurfaceUrl("https://www.district.in/events/late-night-run");
  assert.equal(result.platform, "district");
  assert.equal(result.surfaceKind, "eventListing");
  assert.equal(result.normalizedKey, "district:event:late-night-run");
});

test("normalizes BookMyShow India event URLs", () => {
  const result = normalizeOrganizerSurfaceUrl("https://in.bookmyshow.com/events/run-party/ET00432123");
  assert.equal(result.platform, "bookMyShow");
  assert.equal(result.surfaceKind, "eventListing");
  assert.equal(result.normalizedKey, "bookMyShow:event:run-party");
});

test("normalizes BookMyShow artist URLs as person profiles", () => {
  const result = normalizeOrganizerSurfaceUrl("https://bookmyshow.com/artists/sample-host/1234");
  assert.equal(result.platform, "bookMyShow");
  assert.equal(result.surfaceKind, "personProfile");
  assert.equal(result.normalizedKey, "bookMyShow:artist:sample-host");
});

test("normalizes Sort My Scene organizer URLs", () => {
  const result = normalizeOrganizerSurfaceUrl("https://sortmyscene.com/organizers/afterfly");
  assert.equal(result.platform, "sortMyScene");
  assert.equal(result.surfaceKind, "organizerProfile");
  assert.equal(result.normalizedKey, "sortMyScene:profile:afterfly");
});

test("normalizes LinkedIn company and person surfaces", () => {
  const company = normalizeOrganizerSurfaceUrl("https://www.linkedin.com/company/afterfly/");
  const person = normalizeOrganizerSurfaceUrl("https://linkedin.com/in/sample-founder/");
  assert.equal(company.surfaceKind, "organizerProfile");
  assert.equal(company.normalizedKey, "linkedin:company:afterfly");
  assert.equal(person.surfaceKind, "personProfile");
  assert.equal(person.normalizedKey, "linkedin:person:sample-founder");
});

test("classifies known publication domains as press without identity keys", () => {
  const result = normalizeOrganizerSurfaceUrl("https://lbb.in/mumbai/afterfly-profile/");
  assert.equal(result.platform, "news");
  assert.equal(result.surfaceKind, "press");
  assert.equal(result.normalizedKey, null);
});

test("falls back to an official website candidate for unknown domains", () => {
  const result = normalizeOrganizerSurfaceUrl("https://www.thebhag.in/?utm_campaign=launch");
  assert.equal(result.canonicalUrl, "https://thebhag.in/");
  assert.equal(result.platform, "officialWebsite");
  assert.equal(result.surfaceKind, "website");
  assert.equal(result.normalizedKey, "domain:thebhag.in");
});

test("creates schema-shaped surfaces", () => {
  const surface = surfaceFromUrl("https://luma.com/pxgmph3b", {
    surfaceId: "afterfly-luma-event",
  });
  assert.deepEqual(Object.keys(surface).sort(), [
    "confidence",
    "crawl",
    "evidenceRefs",
    "normalizedKey",
    "notes",
    "platform",
    "role",
    "status",
    "surfaceId",
    "surfaceKind",
    "url",
  ]);
  assert.equal(surface.surfaceId, "afterfly-luma-event");
  assert.equal(surface.normalizedKey, "luma:event:pxgmph3b");
});

test("generates deterministic surface ids from normalized keys", () => {
  assert.equal(
    surfaceIdFromNormalizedKey("instagram:afterfly.in", null),
    surfaceIdFromNormalizedKey("instagram:afterfly.in", null)
  );
});
