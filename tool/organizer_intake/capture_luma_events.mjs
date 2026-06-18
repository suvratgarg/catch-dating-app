#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(scriptDir, "..", "..");
const defaultOutputRoot = path.join(scriptDir, "event_source_batches");

if (isMain()) {
  try {
    main();
  } catch (error) {
    console.error(error instanceof Error ? error.message : String(error));
    process.exit(1);
  }
}

export function main(argv = process.argv.slice(2)) {
  const flags = parseFlags(argv);

  if (flags.help) {
    printHelp();
    return;
  }

  if (!flags.entity) throw new Error("--entity is required.");
  if (!flags.surface) throw new Error("--surface is required.");
  if (!flags.rawResults) throw new Error("--raw-results is required.");
  if (!flags.date || !/^\d{4}-\d{2}-\d{2}$/.test(flags.date)) {
    throw new Error("--date YYYY-MM-DD is required.");
  }

  const rawPath = path.resolve(repoRoot, flags.rawResults);
  const raw = readJson(rawPath);
  const batch = buildLumaEventSourceBatch(raw, {
    batchId: flags.batchId ??
      `${flags.date}-${flags.entity}-luma-events`,
    citySlug: flags.citySlug,
    countryCode: flags.countryCode,
    createdAt: flags.date,
    entityId: flags.entity,
    sourceUrl: flags.sourceUrl,
    surfaceId: flags.surface,
    timezone: flags.timezone,
  });
  const outputPath = path.resolve(
    repoRoot,
    flags.output ??
      path.join(defaultOutputRoot, `${batch.batchId}.json`)
  );
  const rendered = `${stableStringify(batch)}\n`;

  if (flags.dryRun) {
    console.log(rendered.trimEnd());
    process.exit(0);
  }

  if (flags.check) {
    if (!fs.existsSync(outputPath)) {
      console.error(`Missing Luma event capture output: ${relative(outputPath)}`);
      process.exit(1);
    }
    const current = fs.readFileSync(outputPath, "utf8");
    if (current !== rendered) {
      console.error(`Luma event capture is stale: ${relative(outputPath)}`);
      process.exit(1);
    }
    console.log(`Luma event capture is current: ${relative(outputPath)}`);
    process.exit(0);
  }

  fs.mkdirSync(path.dirname(outputPath), {recursive: true});
  fs.writeFileSync(outputPath, rendered);
  console.log(`Captured ${batch.events.length} Luma event(s).`);
  console.log(`Wrote ${relative(outputPath)}.`);
}

export function buildLumaEventSourceBatch(raw, options) {
  const events = extractLumaEvents(raw).map((event) =>
    normalizeLumaEvent(event, options)
  );
  return {
    schemaVersion: 1,
    batchId: options.batchId,
    createdAt: options.createdAt,
    source: "reviewed_luma_payload",
    entityId: options.entityId,
    surfaceId: options.surfaceId,
    platform: "luma",
    sourceUrl: options.sourceUrl ?? firstEventUrl(events),
    timezone: options.timezone ?? "Asia/Kolkata",
    citySlug: options.citySlug ?? null,
    countryCode: options.countryCode ?? null,
    events,
  };
}

function extractLumaEvents(raw) {
  if (Array.isArray(raw?.events)) return raw.events;
  const jsonLd = raw?.jsonLd ?? raw?.jsonld ?? raw?.ldJson ?? raw;
  const values = Array.isArray(jsonLd) ? jsonLd : [jsonLd];
  const events = [];
  for (const value of values) {
    collectSchemaEvents(value, events);
  }
  return events;
}

function collectSchemaEvents(value, events) {
  if (!value || typeof value !== "object") return;
  const type = value["@type"];
  if (type === "Event" || (Array.isArray(type) && type.includes("Event"))) {
    events.push(value);
  }
  for (const nested of Object.values(value)) {
    if (Array.isArray(nested)) {
      for (const item of nested) collectSchemaEvents(item, events);
    } else if (nested && typeof nested === "object") {
      collectSchemaEvents(nested, events);
    }
  }
}

function normalizeLumaEvent(event, options) {
  const url = stringOrNull(event.url) ?? options.sourceUrl ?? null;
  const sourceEventId = slugify(
    event.id ??
      event.eventId ??
      lumaIdFromUrl(event["@id"]) ??
      lumaIdFromUrl(url) ??
      "event"
  );
  const location = event.location && typeof event.location === "object" ?
    event.location :
    {};
  const address = location.address && typeof location.address === "object" ?
    location.address :
    {};
  return {
    sourceEventId,
    title: stringOrNull(event.name) ?? "Untitled Luma event",
    description: stringOrNull(event.description),
    startAt: stringOrNull(event.startDate) ?? stringOrNull(event.startAt),
    endAt: stringOrNull(event.endDate) ?? stringOrNull(event.endAt),
    timezone: options.timezone ?? "Asia/Kolkata",
    locationName: stringOrNull(location.name),
    address: addressText(address),
    citySlug: options.citySlug ?? null,
    countryCode: options.countryCode ?? null,
    eventUrl: url,
    imageUrl: imageUrl(event.image),
    priceText: priceText(event.offers),
    status: statusFor(event.eventStatus),
  };
}

function lumaIdFromUrl(value) {
  try {
    const url = new URL(String(value ?? ""));
    return path.basename(url.pathname);
  } catch {
    return null;
  }
}

function firstEventUrl(events) {
  return events.find((event) => event.eventUrl)?.eventUrl ?? null;
}

function addressText(address) {
  if (!address || typeof address !== "object") return null;
  const parts = [
    address.streetAddress,
    address.addressLocality,
    address.addressRegion,
    address.addressCountry,
  ].filter(Boolean);
  return parts.length > 0 ? parts.join(", ") : null;
}

function imageUrl(value) {
  if (typeof value === "string") return value;
  if (Array.isArray(value)) return value.find((item) => typeof item === "string") ?? null;
  if (value && typeof value === "object") return stringOrNull(value.url);
  return null;
}

function priceText(offers) {
  const offer = Array.isArray(offers) ? offers[0] : offers;
  if (!offer || typeof offer !== "object") return null;
  if (offer.price === undefined || offer.price === null) return null;
  return `${offer.price} ${offer.priceCurrency ?? ""}`.trim();
}

function statusFor(value) {
  const text = String(value ?? "").toLowerCase();
  if (text.includes("cancel")) return "cancelled";
  if (text.includes("postpon")) return "postponed";
  return "scheduled";
}

function stringOrNull(value) {
  return typeof value === "string" && value.trim() ? value.trim() : null;
}

function parseFlags(argv) {
  const flags = {
    batchId: null,
    check: false,
    citySlug: null,
    countryCode: null,
    date: null,
    dryRun: false,
    entity: null,
    help: false,
    output: null,
    rawResults: null,
    sourceUrl: null,
    surface: null,
    timezone: null,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--check") flags.check = true;
    else if (arg === "--dry-run") flags.dryRun = true;
    else if (arg === "--help" || arg === "-h") flags.help = true;
    else if ([
      "--batch-id",
      "--city-slug",
      "--country-code",
      "--date",
      "--entity",
      "--output",
      "--raw-results",
      "--source-url",
      "--surface",
      "--timezone",
    ].includes(arg)) {
      const value = argv[index + 1];
      if (!value || value.startsWith("--")) throw new Error(`${arg} requires a value.`);
      flags[camelFlag(arg)] = value;
      index += 1;
    } else {
      throw new Error(`Unknown argument: ${arg}`);
    }
  }
  return flags;
}

function camelFlag(flag) {
  return flag
    .slice(2)
    .replace(/-([a-z])/g, (_match, letter) => letter.toUpperCase());
}

function readJson(file) {
  return JSON.parse(fs.readFileSync(file, "utf8"));
}

function relative(file) {
  return path.relative(repoRoot, file);
}

function stableStringify(value) {
  return JSON.stringify(sortValue(value), null, 2);
}

function sortValue(value) {
  if (Array.isArray(value)) return value.map(sortValue);
  if (value && typeof value === "object") {
    return Object.fromEntries(
      Object.entries(value)
        .sort(([a], [b]) => a.localeCompare(b))
        .map(([key, nested]) => [key, sortValue(nested)])
    );
  }
  return value;
}

function slugify(value) {
  return String(value ?? "event")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .slice(0, 80) || "event";
}

function printHelp() {
  console.log(`Usage:
  node tool/organizer_intake/capture_luma_events.mjs \\
    --entity ENTITY --surface SURFACE --raw-results LUMA_JSON --date YYYY-MM-DD

Flags:
  --entity <id>          Organizer entity id.
  --surface <id>         Organizer surface id.
  --raw-results <file>   Reviewed Luma JSON or JSON-LD payload.
  --date YYYY-MM-DD      Deterministic capture date.
  --batch-id <id>        Optional output batch id.
  --source-url <url>     Source page URL when absent from payload.
  --city-slug <slug>     Optional event city slug.
  --country-code <code>  Optional country code.
  --timezone <tz>        Optional timezone. Defaults to Asia/Kolkata.
  --output <file>        Output path. Defaults to event_source_batches/.
  --check                Compare output with existing file.
  --dry-run              Print batch without writing.
`);
}

function isMain() {
  return process.argv[1] &&
    fileURLToPath(import.meta.url) === path.resolve(process.argv[1]);
}
