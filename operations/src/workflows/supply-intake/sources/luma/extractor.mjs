import {hashValue} from "../../../../platform/canonical-json.mjs";

export function extractLumaEvents(raw, {artifactRef = null, observedAt = null, timezone = "Asia/Kolkata"} = {}) {
  const nodes = [];
  collectEvents(raw?.jsonLd ?? raw?.jsonld ?? raw?.ldJson ?? raw, nodes);
  return {
    schemaVersion: 1,
    sourceProfileId: "luma",
    templateFingerprint: fingerprint(raw),
    extractionMethod: "deterministic_json_ld_event_v1",
    artifactRef,
    observedAt,
    events: nodes.map((event, index) => normalizeEvent(event, {index, timezone})),
  };
}

function collectEvents(value, output) {
  if (Array.isArray(value)) {
    value.forEach((item) => collectEvents(item, output));
    return;
  }
  if (!value || typeof value !== "object") return;
  const types = Array.isArray(value["@type"]) ? value["@type"] : [value["@type"]];
  if (types.includes("Event")) output.push(value);
  for (const nested of Object.values(value)) collectEvents(nested, output);
}

function normalizeEvent(event, {index, timezone}) {
  const location = objectOrEmpty(event.location);
  const address = objectOrEmpty(location.address);
  const url = text(event.url) ?? text(event["@id"]);
  return {
    sourceEntityId: text(event.identifier) ?? lumaId(url) ?? `event-${index + 1}`,
    title: text(event.name) ?? "Untitled Luma event",
    description: text(event.description),
    startAt: text(event.startDate),
    endAt: text(event.endDate),
    timezone,
    venue: text(location.name),
    address: [address.streetAddress, address.addressLocality, address.addressRegion, address.addressCountry]
      .map(text)
      .filter(Boolean)
      .join(", ") || null,
    sourceUrl: url,
    status: eventStatus(event.eventStatus),
    evidenceFields: ["title", "startAt", "endAt", "venue", "sourceUrl"].filter((key) => {
      const mapped = {title: event.name, startAt: event.startDate, endAt: event.endDate, venue: location.name, sourceUrl: url};
      return Boolean(mapped[key]);
    }),
  };
}

function fingerprint(raw) {
  const paths = [];
  collectShape(raw, "$", paths, 0);
  return `luma-jsonld-${hashValue(paths.sort()).slice(0, 16)}`;
}

function collectShape(value, path, output, depth) {
  if (depth > 8 || value === null || value === undefined) return;
  if (Array.isArray(value)) {
    output.push(`${path}[]`);
    if (value[0] !== undefined) collectShape(value[0], `${path}[]`, output, depth + 1);
    return;
  }
  if (typeof value === "object") {
    for (const key of Object.keys(value).sort()) {
      output.push(`${path}.${key}`);
      collectShape(value[key], `${path}.${key}`, output, depth + 1);
    }
  }
}

function lumaId(value) {
  try {
    const url = new URL(value);
    return url.pathname.split("/").filter(Boolean).at(-1) ?? null;
  } catch {
    return null;
  }
}

function text(value) {
  return typeof value === "string" && value.trim() ? value.trim() : null;
}

function objectOrEmpty(value) {
  return value && typeof value === "object" && !Array.isArray(value) ? value : {};
}

function eventStatus(value) {
  const normalized = String(value ?? "").toLowerCase();
  if (normalized.includes("cancel")) return "cancelled";
  if (normalized.includes("postpon")) return "postponed";
  return "scheduled";
}
