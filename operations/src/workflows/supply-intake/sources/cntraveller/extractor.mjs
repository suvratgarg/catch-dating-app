import {hashValue} from "../../../../platform/canonical-json.mjs";

// This extractor consumes a sanitized document projection produced by a
// policy-approved collector. It never fetches a page or interprets page text as
// instructions. The editorial output is always a lead, never a publishable fact.
export function extractCnTravellerLeads(documentArtifact, {artifactRef = null} = {}) {
  const document = documentArtifact?.document ?? documentArtifact;
  const cards = Array.isArray(document?.cards) ? document.cards : [];
  const leads = cards.map((card, index) => ({
    sourceEntityId: text(card.id) ?? `lead-${index + 1}`,
    title: text(card.heading) ?? "Untitled editorial lead",
    summary: text(card.summary),
    dateText: text(card.dateText),
    venueText: text(card.venueText),
    editorialUrl: text(documentArtifact?.sourceUrl),
    citedUrls: links(card).map((link) => link.url),
    officialSourceUrl: links(card).find((link) => link.relationship === "official")?.url ?? null,
    discoveryOnly: true,
    requiresOfficialSource: true,
    extractionMethod: "deterministic_editorial_link_card_v1",
  }));
  return {
    schemaVersion: 1,
    sourceProfileId: "cntraveller",
    templateFingerprint: text(document?.templateFingerprint) ?? `cntraveller-${hashValue(shapeFor(document)).slice(0, 16)}`,
    artifactRef,
    leads,
  };
}

function links(card) {
  if (!Array.isArray(card?.links)) return [];
  return card.links
    .filter((link) => safeHttpsUrl(link?.url))
    .map((link) => ({url: link.url, relationship: text(link.relationship) ?? "reference"}));
}

function safeHttpsUrl(value) {
  try {
    return new URL(value).protocol === "https:";
  } catch {
    return false;
  }
}

function shapeFor(document) {
  return {
    keys: Object.keys(document ?? {}).sort(),
    cardKeys: Object.keys(document?.cards?.[0] ?? {}).sort(),
    linkKeys: Object.keys(document?.cards?.[0]?.links?.[0] ?? {}).sort(),
  };
}

function text(value) {
  return typeof value === "string" && value.trim() ? value.trim() : null;
}
