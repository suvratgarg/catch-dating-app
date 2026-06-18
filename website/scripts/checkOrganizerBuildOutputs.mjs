#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath, pathToFileURL} from "node:url";

const dirname = path.dirname(fileURLToPath(import.meta.url));
const websiteRoot = path.resolve(dirname, "..");

if (isMain()) {
  try {
    main();
  } catch (error) {
    console.error(error instanceof Error ? error.message : String(error));
    process.exit(1);
  }
}

export function main(argv = process.argv.slice(2)) {
  const args = parseArgs(argv);
  if (args.help) {
    printHelp();
    return;
  }

  const distRoot = path.resolve(
    args.distRoot ?? path.join(websiteRoot, "dist")
  );
  const hostListingsPath = path.resolve(
    args.hostListings ??
      path.join(websiteRoot, "src", "generated", "hostListings.json")
  );
  const baseUrl = String(args.baseUrl ?? "https://catchdates.com")
    .replace(/\/+$/, "");
  const hostListings = readJson(hostListingsPath);
  const result = checkOrganizerBuildOutputs({
    baseUrl,
    distRoot,
    hostListings,
  });

  for (const warning of result.warnings) console.warn(`Warning: ${warning}`);
  if (result.errors.length > 0) {
    console.error("Organizer website build-output validation failed:");
    for (const error of result.errors) console.error(`- ${error}`);
    process.exit(1);
  }

  console.log(
    "Organizer website build outputs ok: " +
      `${result.summary.listings} listing route(s), ` +
      `${result.summary.legacyRoutes} legacy route(s), ` +
      `${result.summary.indexableListings} sitemap listing(s).`
  );
}

export function checkOrganizerBuildOutputs({
  baseUrl,
  distRoot,
  hostListings,
}) {
  const errors = [];
  const warnings = [];
  const sitemapPath = path.join(distRoot, "sitemap.xml");
  const robotsPath = path.join(distRoot, "robots.txt");
  const sitemap = readTextIfExists(sitemapPath);
  const robots = readTextIfExists(robotsPath);

  if (sitemap === null) errors.push("missing dist/sitemap.xml");
  if (robots === null) errors.push("missing dist/robots.txt");
  if (robots !== null && !robots.includes(`Sitemap: ${baseUrl}/sitemap.xml`)) {
    errors.push("robots.txt missing canonical sitemap URL");
  }

  const sitemapUrls = new Set(extractSitemapUrls(sitemap ?? ""));
  const paths = new Set();
  let indexableListings = 0;
  let legacyRoutes = 0;

  for (const listing of hostListings) {
    if (!listing?.path) {
      errors.push(`${listing?.id ?? "unknown"}: missing listing path`);
      continue;
    }
    if (paths.has(listing.path)) {
      errors.push(`${listing.id}: duplicate listing path ${listing.path}`);
    }
    paths.add(listing.path);

    const canonicalUrl = `${baseUrl}${listing.path}`;
    const routeHtml = readRouteHtml({distRoot, routePath: listing.path});
    if (routeHtml === null) {
      errors.push(`${listing.id}: missing route HTML for ${listing.path}`);
    } else {
      checkRouteHtml({
        canonicalUrl,
        errors,
        expectedRobots: listing.indexing,
        listingId: listing.id,
        routeHtml,
        routePath: listing.path,
      });
    }

    const indexable = !isNoindex(listing.indexing);
    if (indexable) {
      indexableListings += 1;
      if (!sitemapUrls.has(canonicalUrl)) {
        errors.push(`${listing.id}: indexable listing missing from sitemap`);
      }
    } else if (sitemapUrls.has(canonicalUrl)) {
      errors.push(`${listing.id}: noindex listing present in sitemap`);
    }

    for (const legacyPath of listing.legacyPaths ?? []) {
      legacyRoutes += 1;
      const legacyUrl = `${baseUrl}${legacyPath}`;
      if (sitemapUrls.has(legacyUrl)) {
        errors.push(`${listing.id}: legacy path present in sitemap ${legacyPath}`);
      }
      const legacyHtml = readRouteHtml({distRoot, routePath: legacyPath});
      if (legacyHtml === null) {
        errors.push(`${listing.id}: missing legacy route HTML for ${legacyPath}`);
      } else {
        checkRouteHtml({
          canonicalUrl,
          errors,
          expectedRobots: "noindex, follow",
          listingId: listing.id,
          routeHtml: legacyHtml,
          routePath: legacyPath,
        });
      }
    }
  }

  for (const url of sitemapUrls) {
    if (!url.startsWith(`${baseUrl}/`)) {
      warnings.push(`sitemap URL does not use base URL: ${url}`);
    }
  }

  return {
    errors,
    warnings,
    summary: {
      indexableListings,
      legacyRoutes,
      listings: hostListings.length,
      sitemapUrls: sitemapUrls.size,
    },
  };
}

function checkRouteHtml({
  canonicalUrl,
  errors,
  expectedRobots,
  listingId,
  routeHtml,
  routePath,
}) {
  const canonicalPattern = new RegExp(
    `<link\\s+rel="canonical"\\s+href="${escapeRegExp(canonicalUrl)}"\\s*\\/>`
  );
  if (!canonicalPattern.test(routeHtml)) {
    errors.push(`${listingId}: ${routePath} canonical does not match ${canonicalUrl}`);
  }

  const robots = robotsMetaFor(routeHtml);
  if (expectedRobots) {
    if (robots !== expectedRobots) {
      errors.push(
        `${listingId}: ${routePath} robots ${robots ?? "missing"} ` +
          `does not match ${expectedRobots}`
      );
    }
  } else if (robots !== null) {
    errors.push(`${listingId}: ${routePath} has unexpected robots meta`);
  }
}

function readRouteHtml({distRoot, routePath}) {
  const routeDir = path.join(distRoot, ...routePath.split("/").filter(Boolean));
  return readTextIfExists(path.join(routeDir, "index.html"));
}

function robotsMetaFor(html) {
  return html.match(/<meta\s+name="robots"\s+content="([^"]*)"\s*\/?>/s)?.[1] ??
    null;
}

function extractSitemapUrls(sitemap) {
  return [...sitemap.matchAll(/<loc>(.*?)<\/loc>/g)]
    .map((match) => unescapeXml(match[1]))
    .sort();
}

function isNoindex(robots) {
  return typeof robots === "string" && /\bnoindex\b/i.test(robots);
}

function readJson(file) {
  return JSON.parse(fs.readFileSync(file, "utf8"));
}

function readTextIfExists(file) {
  if (!fs.existsSync(file)) return null;
  return fs.readFileSync(file, "utf8");
}

function escapeRegExp(value) {
  return String(value).replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function unescapeXml(value) {
  return String(value)
    .replaceAll("&quot;", '"')
    .replaceAll("&gt;", ">")
    .replaceAll("&lt;", "<")
    .replaceAll("&amp;", "&");
}

function parseArgs(argv) {
  const parsed = {
    baseUrl: null,
    distRoot: null,
    help: false,
    hostListings: null,
  };

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--help" || arg === "-h") parsed.help = true;
    else if (arg === "--base-url") parsed.baseUrl = requiredValue(argv, ++index, arg);
    else if (arg === "--dist-root") parsed.distRoot = requiredValue(argv, ++index, arg);
    else if (arg === "--host-listings") parsed.hostListings = requiredValue(argv, ++index, arg);
    else throw new Error(`Unknown argument: ${arg}`);
  }

  return parsed;
}

function requiredValue(argv, index, flag) {
  const value = argv[index];
  if (!value || value.startsWith("--")) throw new Error(`${flag} requires a value.`);
  return value;
}

function printHelp() {
  console.log(`Usage: node website/scripts/checkOrganizerBuildOutputs.mjs [options]

Options:
  --dist-root <path>      Directory containing Vite build output.
  --host-listings <path>  Generated host listings JSON file.
  --base-url <url>        Public website base URL.
`);
}

function isMain() {
  return process.argv[1] &&
    import.meta.url === pathToFileURL(process.argv[1]).href;
}
