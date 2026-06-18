import assert from "node:assert/strict";
import test from "node:test";
import {buildLumaEventSourceBatch} from "./capture_luma_events.mjs";

test("buildLumaEventSourceBatch extracts Event JSON-LD", () => {
  const batch = buildLumaEventSourceBatch({
    jsonLd: {
      "@id": "https://luma.com/pxgmph3b",
      "@type": "Event",
      name: "Takeoff: Run + Rave",
      description: "Reviewed event.",
      startDate: "2025-03-15T18:00:00+05:30",
      endDate: "2025-03-15T21:00:00+05:30",
      url: "https://luma.com/pxgmph3b",
      image: "https://images.lumacdn.com/event-afterfly.jpg",
      offers: {price: "0", priceCurrency: "INR"},
      location: {
        name: "Indore",
        address: {
          addressLocality: "Indore",
          addressRegion: "Madhya Pradesh",
          addressCountry: "IN",
        },
      },
    },
  }, {
    batchId: "2026-06-17-afterfly-luma-events",
    citySlug: "indore",
    countryCode: "IN",
    createdAt: "2026-06-17",
    entityId: "afterfly",
    sourceUrl: "https://luma.com/pxgmph3b",
    surfaceId: "afterfly-luma-takeoff-run-rave",
    timezone: "Asia/Kolkata",
  });

  assert.equal(batch.platform, "luma");
  assert.equal(batch.events.length, 1);
  assert.equal(batch.events[0].sourceEventId, "pxgmph3b");
  assert.equal(batch.events[0].priceText, "0 INR");
  assert.equal(batch.events[0].citySlug, "indore");
});
