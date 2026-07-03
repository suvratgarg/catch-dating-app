#!/usr/bin/env node
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import {fromRepo} from "../lib/repo_paths.mjs";

const args = parseArgs(process.argv.slice(2));

if (args.help) {
  printHelp();
  process.exit(0);
}

if (args.selfTest) {
  runSelfTest();
  process.exit(0);
}

const routesPath = fromRepo(args.routes ?? "design/website/routes.json");
const schemaPath = fromRepo("design/website/website.routes.schema.json");
const pageMetaPath = fromRepo("website/src/app/pageMeta.ts");
const postbuildPath = fromRepo("website/scripts/postbuild.mjs");
const routingPath = fromRepo("website/src/features/organizers/routing.ts");
const appPath = fromRepo("website/src/app/App.tsx");
const routeRegistryPath = fromRepo("website/src/app/routeRegistry.ts");
const hostListingsPath = fromRepo("website/src/generated/hostListings.json");
const storiesRoot = fromRepo("website/src/stories");

const errors = [];
const warnings = [];

const contract = readJson(routesPath, "website route contract");
const hostListings = readJson(hostListingsPath, "generated host listings");
const pageMetaSource = readText(pageMetaPath);
const postbuildSource = readText(postbuildPath);
const routingSource = readText(routingPath);
const appSource = readText(appPath);
const routeRegistrySource = readText(routeRegistryPath);
const appRoutingSource = `${appSource}\n${routeRegistrySource}`;
const routeStoryDeclarations = collectStoryRouteDeclarations(storiesRoot);

validateContractShape(contract);
validateRoutes(contract.routes ?? [], routeStoryDeclarations);
validateGeneratedListingFamilies(contract.routes ?? [], hostListings);

if (errors.length > 0) {
  console.error("Website route contract check failed:");
  for (const error of errors) console.error(`- ${error}`);
  process.exit(1);
}

if (args.summary || warnings.length > 0) {
  for (const warning of warnings) console.warn(`Warning: ${warning}`);
  console.log(
    [
      `Website route contract ok: ${contract.routes.length} route contract(s).`,
      `Generated organizer listings: ${hostListings.length}.`,
      `Contract: ${path.relative(fromRepo("."), routesPath)}`,
    ].join("\n")
  );
}

function validateContractShape(value) {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    errors.push("routes.json must be a JSON object.");
    return;
  }
  if (value.$schema !== "./website.routes.schema.json") {
    errors.push("routes.json must reference ./website.routes.schema.json.");
  }
  if (!fs.existsSync(schemaPath)) {
    errors.push("missing design/website/website.routes.schema.json.");
  }
  if (!Number.isInteger(value.version) || value.version < 1) {
    errors.push("routes.json version must be a positive integer.");
  }
  if (value.owner !== "marketing_website") {
    errors.push("routes.json owner must be marketing_website.");
  }
  if (!Array.isArray(value.routes) || value.routes.length === 0) {
    errors.push("routes.json must declare at least one route.");
  }
}

function validateRoutes(routes, storyDeclarations) {
  const ids = new Set();
  const exactPaths = new Set();
  const routeById = new Map();
  const storyDeclarationsByRouteId = groupStoryRouteDeclarations(storyDeclarations);
  const requiredRouteIds = new Set([
    "home",
    "host",
    "organizer_search",
    "claim",
    "not_found",
    "organizer_listing_canonical",
    "organizer_listing_legacy",
  ]);

  for (const route of routes) {
    validateRoute(route, storyDeclarationsByRouteId.get(route.id) ?? []);
    if (!route?.id) continue;
    if (ids.has(route.id)) errors.push(`${route.id}: duplicate route id.`);
    ids.add(route.id);
    routeById.set(route.id, route);
    if (route.path) {
      const normalized = normalizeRoutePath(route.path);
      if (exactPaths.has(normalized)) {
        errors.push(`${route.id}: duplicate route path ${normalized}.`);
      }
      exactPaths.add(normalized);
    }
  }

  for (const id of requiredRouteIds) {
    if (!ids.has(id)) errors.push(`missing required route contract ${id}.`);
  }

  validateStoryRouteDeclarations(storyDeclarations, routeById);
}

function validateRoute(route, storyDeclarations) {
  if (!route || typeof route !== "object" || Array.isArray(route)) {
    errors.push("route entries must be objects.");
    return;
  }
  const label = route.id ?? "<missing-id>";
  const allowedKinds = new Set(["static", "clientDynamic", "generatedFamily"]);
  const allowedOutputs = new Set(["postbuild", "generated-postbuild", "spa-rewrite"]);
  const allowedIndexing = new Set(["index", "noindex-follow", "listing-controlled"]);
  const allowedSitemap = new Set(["included", "excluded", "listing-controlled"]);

  if (!route.id) errors.push("route missing id.");
  if (!allowedKinds.has(route.kind)) errors.push(`${label}: invalid kind ${route.kind}.`);
  if (!allowedOutputs.has(route.staticOutput)) {
    errors.push(`${label}: invalid staticOutput ${route.staticOutput}.`);
  }
  if (!allowedIndexing.has(route.indexing)) {
    errors.push(`${label}: invalid indexing ${route.indexing}.`);
  }
  if (!allowedSitemap.has(route.sitemap)) {
    errors.push(`${label}: invalid sitemap ${route.sitemap}.`);
  }

  if (route.kind === "generatedFamily") {
    if (!route.pathPattern && !Array.isArray(route.pathPatterns)) {
      errors.push(`${label}: generated route needs pathPattern or pathPatterns.`);
    }
    if (route.path) errors.push(`${label}: generated route should not declare exact path.`);
  } else if (!route.path && !route.pathPattern) {
    errors.push(`${label}: route needs path or pathPattern.`);
  }

  if (route.path) {
    route.path = normalizeRoutePath(route.path);
  }

  if (!route.source || !fs.existsSync(fromRepo(route.source))) {
    errors.push(`${label}: source file does not exist: ${route.source}.`);
  }
  validatePageKey(route);
  validateMeta(route);
  validateStaticOutput(route);
  validateReview(route, storyDeclarations);
}

function validatePageKey(route) {
  const allowedPageKeys = new Set(["home", "host", "organizers", "listing", "claim", "not_found"]);
  if (!allowedPageKeys.has(route.pageKey)) {
    errors.push(`${route.id}: invalid pageKey ${route.pageKey}.`);
    return;
  }
  if (route.pageKey === "listing") {
    if (!appRoutingSource.includes("getHostListingRouteForPath")) {
      errors.push(`${route.id}: App.tsx must resolve generated listing routes first.`);
    }
    return;
  }

  const routePath = route.path ?? route.pathPattern ?? "";
  const expectedChecks = {
    claim: "pathname.startsWith(\"/claim\")",
    host: "pathname.startsWith(\"/host\")",
    organizers: "pathname.startsWith(\"/organizers\")",
  };
  const expected = expectedChecks[route.pageKey];
  if (expected && !pageMetaSource.includes(expected)) {
    errors.push(`${route.id}: getPageKey does not contain ${expected}.`);
  }
  if (route.pageKey === "home" && routePath !== "/") {
    errors.push(`${route.id}: home pageKey should be reserved for /.`);
  }
  if (route.id === "host_preview" && !appRoutingSource.includes("/host/preview")) {
    errors.push("host_preview: App.tsx must detect /host/preview.");
  }
  if (route.pageKey === "not_found") {
    if (route.id !== "not_found") {
      errors.push(`${route.id}: not_found pageKey is reserved for not_found.`);
    }
    if (!pageMetaSource.includes('return "not_found"')) {
      errors.push("not_found: getPageKey must return not_found for unknown paths.");
    }
    if (!appRoutingSource.includes("marketingRoutePaths.not_found")) {
      errors.push("not_found: App.tsx must route unknown paths through marketingRoutePaths.not_found.");
    }
    if (!appRoutingSource.includes("<NotFoundPage />")) {
      errors.push("not_found: App.tsx must render NotFoundPage for fallback routes.");
    }
  }
}

function validateMeta(route) {
  if (route.metaKey) {
    const block = pageMetaBlock(route.metaKey);
    if (!block) {
      errors.push(`${route.id}: pageMeta missing key ${route.metaKey}.`);
      return;
    }
    if (route.path && route.staticOutput === "postbuild") {
      const canonicalPattern = new RegExp(
        `canonicalPath:\\s*"${escapeRegExp(route.path)}"`,
        "u"
      );
      if (!canonicalPattern.test(block)) {
        errors.push(`${route.id}: pageMeta.${route.metaKey} canonicalPath must be ${route.path}.`);
      }
    }
    if (route.indexing === "noindex-follow" && !block.includes('robots: "noindex, follow"')) {
      errors.push(`${route.id}: pageMeta.${route.metaKey} must declare noindex, follow.`);
    }
    if (route.indexing === "index" && block.includes("robots:")) {
      warnings.push(`${route.id}: index route has explicit robots metadata.`);
    }
  }

  if (route.metaFactory && !pageMetaSource.includes(`function ${route.metaFactory}`)) {
    errors.push(`${route.id}: missing meta factory ${route.metaFactory}.`);
  }
  if (route.id === "organizer_listing_legacy" && !pageMetaSource.includes("noindexOverride")) {
    errors.push("organizer_listing_legacy: pageMetaForListing must accept noindexOverride.");
  }
}

function validateStaticOutput(route) {
  if (route.staticOutput === "postbuild") {
    const needle = `writeRoute("${route.path}"`;
    if (!postbuildSource.includes(needle)) {
      errors.push(`${route.id}: postbuild.mjs does not emit ${route.path}.`);
    }
    if (route.id === "not_found" && !postbuildSource.includes('writeStaticHtml("404.html"')) {
      errors.push("not_found: postbuild.mjs must emit root 404.html.");
    }
  }
  if (route.staticOutput === "generated-postbuild") {
    if (route.id === "organizer_listing_canonical" &&
        !postbuildSource.includes("writeRoute(listing.path")) {
      errors.push("organizer_listing_canonical: postbuild must emit listing.path.");
    }
    if (route.id === "organizer_listing_legacy") {
      if (!postbuildSource.includes("for (const legacyPath of listing.legacyPaths")) {
        errors.push("organizer_listing_legacy: postbuild must iterate listing.legacyPaths.");
      }
      if (!postbuildSource.includes('robots: "noindex, follow"')) {
        errors.push("organizer_listing_legacy: postbuild must force noindex, follow.");
      }
    }
  }
  if (route.staticOutput === "spa-rewrite" && route.sitemap !== "excluded") {
    errors.push(`${route.id}: SPA rewrite routes must be excluded from sitemap until static output exists.`);
  }
}

function validateReview(route, storyDeclarations) {
  const review = route.review;
  const label = route.id ?? "<missing-id>";
  if (!review || typeof review !== "object") {
    errors.push(`${label}: missing review contract.`);
    return;
  }
  if (!["p0", "p1", "p2"].includes(review.priority)) {
    errors.push(`${label}: invalid review priority.`);
  }
  if (!["planned", "manual", "captured", "ready", "excluded"].includes(review.status)) {
    errors.push(`${label}: invalid review status.`);
  }
  if (!Array.isArray(review.states) || review.states.length === 0) {
    errors.push(`${label}: review.states must list at least one state.`);
  }
  validateReviewStateCoverage(label, review, storyDeclarations);
  if (review.priority !== "p2") {
    for (const viewport of ["desktop", "mobile"]) {
      if (!review.viewports?.includes(viewport) && route.id !== "organizer_listing_legacy") {
        errors.push(`${label}: p0/p1 route review must include ${viewport} viewport.`);
      }
    }
  }
  if (review.status === "ready" && review.stateCoverage.storybook.length === 0) {
    errors.push(`${label}: ready route review needs at least one Storybook-backed state.`);
  }
  if (review.status === "manual" && review.stateCoverage.manual.length === 0) {
    errors.push(`${label}: manual route review needs at least one manual state.`);
  }
}

function validateReviewStateCoverage(label, review, storyDeclarations) {
  const coverage = review.stateCoverage;
  if (!coverage || typeof coverage !== "object" || Array.isArray(coverage)) {
    errors.push(`${label}: review.stateCoverage must declare storybook and manual states.`);
    return;
  }
  if (!Array.isArray(coverage.storybook)) {
    errors.push(`${label}: review.stateCoverage.storybook must be an array.`);
    return;
  }
  if (!Array.isArray(coverage.manual)) {
    errors.push(`${label}: review.stateCoverage.manual must be an array.`);
    return;
  }

  const states = new Set(review.states ?? []);
  const covered = new Set([...coverage.storybook, ...coverage.manual]);
  for (const state of states) {
    if (covered.has(state)) continue;
    errors.push(`${label}: review state ${state} must be storybook-backed or manual.`);
  }
  for (const state of covered) {
    if (states.has(state)) continue;
    errors.push(`${label}: stateCoverage references unknown state ${state}.`);
  }

  const storybookStates = new Set(
    storyDeclarations.flatMap((declaration) => declaration.stateCoverage.storybook)
  );
  for (const state of coverage.storybook) {
    if (storybookStates.has(state)) continue;
    errors.push(`${label}: Storybook coverage state ${state} is not declared by a catchRoute story.`);
  }
}

function validateGeneratedListingFamilies(routes, listings) {
  const canonical = routes.find((route) => route.id === "organizer_listing_canonical");
  const legacy = routes.find((route) => route.id === "organizer_listing_legacy");
  if (!canonical || !legacy) return;
  if (!Array.isArray(listings)) {
    errors.push("hostListings.json must be an array.");
    return;
  }
  if (!routingSource.includes("legacyPaths?.includes(normalizedPath)")) {
    errors.push("routing.ts must preserve legacy path resolution.");
  }

  const paths = new Set();
  for (const listing of listings) {
    if (!listing?.id) errors.push("host listing missing id.");
    if (!listing?.path) {
      errors.push(`${listing?.id ?? "unknown"}: listing missing canonical path.`);
      continue;
    }
    const listingPath = normalizeRoutePath(listing.path);
    if (paths.has(listingPath)) errors.push(`${listing.id}: duplicate listing route ${listingPath}.`);
    paths.add(listingPath);
    const canonicalPatterns = routePatterns(canonical);
    if (!canonicalPatterns.some((pattern) => matchesRoutePattern(listingPath, pattern))) {
      errors.push(`${listing.id}: ${listingPath} is not covered by ${canonicalPatterns.join(" or ")}.`);
    }
    if (!["index, follow", "noindex, follow"].includes(listing.indexing)) {
      errors.push(`${listing.id}: unsupported listing indexing ${listing.indexing}.`);
    }
    for (const legacyPath of listing.legacyPaths ?? []) {
      const normalizedLegacyPath = normalizeRoutePath(legacyPath);
      if (normalizedLegacyPath === listingPath) {
        errors.push(`${listing.id}: legacy path duplicates canonical path ${listingPath}.`);
      }
      if (paths.has(normalizedLegacyPath)) {
        errors.push(`${listing.id}: duplicate listing or legacy route ${normalizedLegacyPath}.`);
      }
      paths.add(normalizedLegacyPath);
    }
  }
}

function validateStoryRouteDeclarations(declarations, routeById) {
  for (const declaration of declarations) {
    const storyLabel = `${path.relative(fromRepo("."), declaration.storyPath)}:${declaration.exportName}`;
    const route = routeById.get(declaration.id);
    if (!route) {
      errors.push(`${storyLabel}: declares unknown catchRoute.id ${declaration.id}.`);
      continue;
    }

    if (declaration.path && route.path &&
        normalizeRoutePath(declaration.path) !== route.path) {
      errors.push(
        `${storyLabel}: catchRoute.path ${declaration.path} does not match ${route.path}.`
      );
    }

    assertSameStringSet(
      `${storyLabel}: catchRoute.reviewStates`,
      declaration.reviewStates,
      route.review.states
    );
    assertSameStringSet(
      `${storyLabel}: catchRoute.stateCoverage.storybook`,
      declaration.stateCoverage.storybook,
      route.review.stateCoverage.storybook
    );
    assertSameStringSet(
      `${storyLabel}: catchRoute.stateCoverage.manual`,
      declaration.stateCoverage.manual,
      route.review.stateCoverage.manual
    );
  }
}

function assertSameStringSet(label, actual, expected) {
  const actualSet = new Set(actual);
  const expectedSet = new Set(expected);
  for (const value of expectedSet) {
    if (actualSet.has(value)) continue;
    errors.push(`${label} is missing ${value}.`);
  }
  for (const value of actualSet) {
    if (expectedSet.has(value)) continue;
    errors.push(`${label} declares unknown ${value}.`);
  }
}

function groupStoryRouteDeclarations(declarations) {
  const grouped = new Map();
  for (const declaration of declarations) {
    const bucket = grouped.get(declaration.id) ?? [];
    bucket.push(declaration);
    grouped.set(declaration.id, bucket);
  }
  return grouped;
}

function collectStoryRouteDeclarations(root) {
  const declarations = [];
  for (const storyPath of walkStoryFiles(root)) {
    const source = readText(storyPath);
    declarations.push(...storyRouteDeclarations(source, storyPath));
  }
  return declarations;
}

function storyRouteDeclarations(source, storyPath) {
  const declarations = [];
  const constants = stringArrayConstants(source);
  const exportPattern = /^export\s+const\s+([A-Za-z0-9_]+)\b/gmu;
  const matches = [...source.matchAll(exportPattern)];

  for (let index = 0; index < matches.length; index += 1) {
    const match = matches[index];
    const exportName = match[1];
    const start = match.index ?? 0;
    const end = matches[index + 1]?.index ?? source.length;
    const block = source.slice(start, end);
    if (!block.includes("catchRoute")) continue;

    const catchRouteIndex = block.indexOf("catchRoute");
    const catchComponentIndex = block.indexOf("catchComponent", catchRouteIndex);
    const catchRouteBlock = block.slice(
      catchRouteIndex,
      catchComponentIndex >= 0 ? catchComponentIndex : undefined
    );
    const id = firstStringProperty(catchRouteBlock, "id");
    if (!id) continue;

    declarations.push({
      exportName,
      id,
      path: firstStringProperty(catchRouteBlock, "path"),
      reviewStates: stringArrayProperty(catchRouteBlock, "reviewStates", constants),
      stateCoverage: {
        storybook: stringArrayProperty(catchRouteBlock, "storybook", constants),
        manual: stringArrayProperty(catchRouteBlock, "manual", constants),
      },
      storyPath,
    });
  }

  return declarations;
}

function pageMetaBlock(key) {
  const match = pageMetaSource.match(new RegExp(`\\b${escapeRegExp(key)}:\\s*\\{([\\s\\S]*?)\\n\\s{2}\\},`, "u"));
  return match?.[1] ?? null;
}

function matchesRoutePattern(routePath, pattern) {
  if (!pattern || !pattern.startsWith("/")) return true;
  const normalizedPattern = normalizeRoutePath(pattern);
  const regex = new RegExp(
    `^${escapeRegExp(normalizedPattern).replace(/:([A-Za-z0-9_]+)/gu, "[^/]+")}$`,
    "u"
  );
  return regex.test(routePath);
}

function routePatterns(route) {
  if (Array.isArray(route.pathPatterns)) return route.pathPatterns;
  if (route.pathPattern) return [route.pathPattern];
  return [];
}

function normalizeRoutePath(value) {
  if (value === "/") return "/";
  return `/${String(value).replace(/^\/+|\/+$/g, "")}/`;
}

function readJson(filePath, label) {
  try {
    return JSON.parse(fs.readFileSync(filePath, "utf8"));
  } catch (error) {
    throw new Error(`Unable to read ${label} at ${filePath}: ${error.message}`);
  }
}

function readText(filePath) {
  return fs.readFileSync(filePath, "utf8");
}

function walkStoryFiles(directory) {
  const files = [];
  if (!fs.existsSync(directory)) return files;
  for (const entry of fs.readdirSync(directory, {withFileTypes: true})) {
    const fullPath = path.join(directory, entry.name);
    if (entry.isDirectory()) {
      files.push(...walkStoryFiles(fullPath));
      continue;
    }
    if (entry.name.endsWith(".stories.tsx")) files.push(fullPath);
  }
  return files;
}

function stringArrayConstants(source) {
  const constants = new Map();
  const constPattern =
    /const\s+([A-Za-z0-9_]+)\s*=\s*\[([\s\S]*?)\]\s*(?:as\s+const)?\s*;/gu;
  for (const match of source.matchAll(constPattern)) {
    constants.set(match[1], stringValues(match[2]));
  }
  return constants;
}

function firstStringProperty(source, propertyName) {
  const pattern = new RegExp(`${escapeRegExp(propertyName)}:\\s*"([^"]+)"`, "u");
  return source.match(pattern)?.[1] ?? null;
}

function stringArrayProperty(source, propertyName, constants) {
  const inlinePattern = new RegExp(
    `${escapeRegExp(propertyName)}:\\s*\\[([\\s\\S]*?)\\]`,
    "u"
  );
  const inline = source.match(inlinePattern);
  if (inline) return stringValues(inline[1]);

  const referencePattern = new RegExp(
    `${escapeRegExp(propertyName)}:\\s*([A-Za-z0-9_]+)`,
    "u"
  );
  const reference = source.match(referencePattern)?.[1] ?? null;
  return reference ? constants.get(reference) ?? [] : [];
}

function stringValues(source) {
  return [...source.matchAll(/"([^"]+)"/gu)].map((match) => match[1]);
}

function escapeRegExp(value) {
  return String(value).replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function parseArgs(argv) {
  const parsed = {help: false, routes: null, selfTest: false, summary: false};
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--help" || arg === "-h") parsed.help = true;
    else if (arg === "--self-test") parsed.selfTest = true;
    else if (arg === "--summary") parsed.summary = true;
    else if (arg === "--check") {
      // Default mode; accepted for parity with other repo checkers.
    } else if (arg === "--routes") parsed.routes = requiredValue(argv, ++index, arg);
    else fail(`Unknown argument: ${arg}`);
  }
  return parsed;
}

function requiredValue(argv, index, flag) {
  const value = argv[index];
  if (!value || value.startsWith("--")) fail(`${flag} requires a value.`);
  return value;
}

function printHelp() {
  console.log(`Usage: node tool/marketing/check_website_routes.mjs [--check] [--summary] [--self-test]

Validates design/website/routes.json against the marketing website route,
metadata, postbuild, generated organizer-listing sources, and route Storybook
coverage declarations.
`);
}

function runSelfTest() {
  const storyPath = fromRepo("website/src/stories/Example.stories.tsx");
  const declarations = storyRouteDeclarations(`
const searchStates = ["default", "filtered"] as const;

export const OrganizerSearch = {
  parameters: {
    catchRoute: {
      id: "organizer_search",
      path: "/organizers/",
      reviewStates: searchStates,
      stateCoverage: {
        storybook: ["default"],
        manual: ["filtered"],
      },
    },
    catchComponent: {
      id: "route_organizer_search",
      routeIds: ["organizer_search"],
      states: searchStates,
    },
  },
};
`, storyPath);
  assert.deepEqual(declarations, [
    {
      exportName: "OrganizerSearch",
      id: "organizer_search",
      path: "/organizers/",
      reviewStates: ["default", "filtered"],
      stateCoverage: {
        storybook: ["default"],
        manual: ["filtered"],
      },
      storyPath,
    },
  ]);
  console.log("Website route checker self-test passed.");
}

function fail(message) {
  console.error(message);
  process.exit(64);
}
