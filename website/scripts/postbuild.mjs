import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {checkOrganizerBuildOutputs} from "./checkOrganizerBuildOutputs.mjs";

const dirname = path.dirname(fileURLToPath(import.meta.url));
const websiteRoot = path.resolve(dirname, "..");
const args = parseArgs(process.argv.slice(2));
if (args.help) {
  printHelp();
  process.exit(0);
}

const distRoot = path.resolve(args.distRoot ?? path.join(websiteRoot, "dist"));
const hostListingsPath = path.resolve(
  args.hostListings ?? path.join(websiteRoot, "src", "generated", "hostListings.json")
);
const baseUrl = String(args.baseUrl ?? "https://catchdates.com").replace(/\/+$/, "");
const hostListings = JSON.parse(fs.readFileSync(hostListingsPath, "utf8"));

const routeMetas = {
  "/": {
    title: "Catch | The event before the match",
    description:
      "Catch turns curated singles events into real dating context. Choose a hosted event, show up, catch privately, and match with people you actually met.",
    canonical: `${baseUrl}/`,
    twitterDescription: "Curated singles events become real dating context.",
  },
  "/host/": {
    title: "Catch for Hosts | Host better singles events",
    description:
      "Catch helps hosts publish curated singles events, manage admission and waitlists, run live facilitation, and turn real attendance into post-event connections.",
    canonical: `${baseUrl}/host/`,
    twitterDescription:
      "Event setup, admission, waitlists, live facilitation, check-in, and aggregate post-event reporting for hosts.",
  },
  "/organizers/": {
    title: "Organizer Search | Catch",
    description:
      "Search Catch organizer profiles by name, city, format, and review signal.",
    canonical: `${baseUrl}/organizers/`,
    twitterDescription: "Search Catch organizer and club profiles.",
    robots: "noindex, follow",
  },
  "/claim/": {
    title: "Claim your organizer listing | Catch",
    description:
      "Find an unclaimed organizer profile, verify ownership, and request access to Catch host tools.",
    canonical: `${baseUrl}/claim/`,
    twitterDescription: "Claim an organizer profile and unlock Catch host tools.",
    robots: "noindex, follow",
  },
};

const rootHtmlPath = path.join(distRoot, "index.html");
const rootHtml = fs.readFileSync(rootHtmlPath, "utf8");
const sitemapEntries = [];
writeRoute("/", routeMetas["/"]);

writeRoute("/host/", routeMetas["/host/"]);
writeRoute("/organizers/", routeMetas["/organizers/"]);
writeRoute("/claim/", routeMetas["/claim/"]);

for (const listing of hostListings) {
  const listingMeta = {
    title: `${listing.name} | ${listing.city} organizer profile | Catch`,
    description: listing.description,
    canonical: `${baseUrl}${listing.path}`,
    twitterDescription: listing.sourceSummary,
    robots: listing.indexing,
  };
  writeRoute(listing.path, listingMeta);
  for (const legacyPath of listing.legacyPaths ?? []) {
    writeRoute(legacyPath, {
      ...listingMeta,
      robots: "noindex, follow",
    });
  }
}

writeSitemap(sitemapEntries);
writeRobotsTxt();
validateOrganizerBuildOutputs();

function writeRoute(routePath, meta) {
  if (routePath === "/") {
    fs.writeFileSync(rootHtmlPath, applyMeta(rootHtml, meta));
    addSitemapEntry(meta);
    return;
  }

  const routeDir = path.join(distRoot, ...routePath.split("/").filter(Boolean));
  fs.mkdirSync(routeDir, {recursive: true});
  fs.writeFileSync(path.join(routeDir, "index.html"), applyMeta(rootHtml, meta));
  addSitemapEntry(meta);
}

function applyMeta(html, meta) {
  return html
    .replace(/<title>.*?<\/title>/s, `<title>${escapeHtml(meta.title)}</title>`)
    .replace(
      /<meta\s+name="description"\s+content="[^"]*"\s*\/?>/s,
      `<meta name="description" content="${escapeHtml(meta.description)}" />`
    )
    .replace(
      /<meta\s+property="og:title"\s+content="[^"]*"\s*\/?>/s,
      `<meta property="og:title" content="${escapeHtml(meta.title)}" />`
    )
    .replace(
      /<meta\s+property="og:description"\s+content="[^"]*"\s*\/?>/s,
      `<meta property="og:description" content="${escapeHtml(meta.description)}" />`
    )
    .replace(
      /<meta\s+property="og:url"\s+content="[^"]*"\s*\/?>/s,
      `<meta property="og:url" content="${escapeHtml(meta.canonical)}" />`
    )
    .replace(
      /<meta\s+name="twitter:title"\s+content="[^"]*"\s*\/?>/s,
      `<meta name="twitter:title" content="${escapeHtml(meta.title)}" />`
    )
    .replace(
      /<meta\s+name="twitter:description"\s+content="[^"]*"\s*\/?>/s,
      `<meta name="twitter:description" content="${escapeHtml(
        meta.twitterDescription
      )}" />`
    )
    .replace(
      /<link\s+rel="canonical"\s+href="[^"]*"\s*\/?>/s,
      `<link rel="canonical" href="${escapeHtml(meta.canonical)}" />`
    )
    .replace(/\n\s*<meta\s+name="robots"\s+content="[^"]*"\s*\/?>/s, "")
    .replace(
      /\n\s*(<link\s+rel="canonical"\s+href="[^"]*"\s*\/?>)/s,
      `\n${meta.robots ? `    <meta name="robots" content="${escapeHtml(meta.robots)}" />\n` : ""}    $1`
    );
}

function escapeHtml(value) {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll('"', "&quot;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;");
}

function addSitemapEntry(meta) {
  if (isNoindex(meta.robots)) return;
  sitemapEntries.push(meta.canonical);
}

function isNoindex(robots) {
  return typeof robots === "string" && /\bnoindex\b/i.test(robots);
}

function writeSitemap(urls) {
  const uniqueUrls = [...new Set(urls)].sort();
  const body = [
    '<?xml version="1.0" encoding="UTF-8"?>',
    '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">',
    ...uniqueUrls.map((url) =>
      `  <url><loc>${escapeXml(url)}</loc></url>`
    ),
    '</urlset>',
    '',
  ].join("\n");
  fs.writeFileSync(path.join(distRoot, "sitemap.xml"), body);
}

function writeRobotsTxt() {
  fs.writeFileSync(
    path.join(distRoot, "robots.txt"),
    [
      "User-agent: *",
      "Allow: /",
      `Sitemap: ${baseUrl}/sitemap.xml`,
      "",
    ].join("\n")
  );
}

function validateOrganizerBuildOutputs() {
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
}

function escapeXml(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll('"', "&quot;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;");
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
  console.log(`Usage: node website/scripts/postbuild.mjs [options]

Options:
  --dist-root <path>      Directory containing Vite build output.
  --host-listings <path>  Generated host listings JSON file.
  --base-url <url>        Public website base URL.
`);
}

function fail(message) {
  console.error(message);
  process.exit(1);
}
