import assert from "node:assert/strict";
import test from "node:test";
import {extractCnTravellerLeads} from "../src/workflows/supply-intake/sources/cntraveller/extractor.mjs";
import {extractLumaEvents} from "../src/workflows/supply-intake/sources/luma/extractor.mjs";

test("Luma extractor deterministically normalizes JSON-LD without network access", () => {
  const result = extractLumaEvents({jsonLd: {
    "@type": "Event",
    name: "Morning Run",
    startDate: "2026-07-20T07:00:00+05:30",
    url: "https://lu.ma/run-one",
    location: {name: "Marine Drive", address: {addressLocality: "Mumbai"}},
  }});
  assert.equal(result.events.length, 1);
  assert.equal(result.events[0].sourceEntityId, "run-one");
  assert.equal(result.events[0].title, "Morning Run");
  assert.match(result.templateFingerprint, /^luma-jsonld-/);
});

test("CN Traveller extractor always emits discovery-only leads and rejects unsafe links", () => {
  const result = extractCnTravellerLeads({
    sourceUrl: "https://www.cntraveller.in/story/mumbai-guide/",
    document: {cards: [{
      id: "lead-one",
      heading: "Gallery Night",
      links: [
        {url: "javascript:alert(1)", relationship: "official"},
        {url: "https://gallery.example/night", relationship: "official"},
      ],
    }]},
  });
  assert.equal(result.leads[0].discoveryOnly, true);
  assert.equal(result.leads[0].requiresOfficialSource, true);
  assert.deepEqual(result.leads[0].citedUrls, ["https://gallery.example/night"]);
});
