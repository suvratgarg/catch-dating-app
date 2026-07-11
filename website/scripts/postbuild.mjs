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
  "/404/": {
    title: "Page not found | Catch",
    description:
      "This Catch page does not exist. Search organizer profiles, browse the member site, or explore host tools.",
    canonical: `${baseUrl}/404/`,
    twitterDescription:
      "Search organizer profiles, browse the member site, or explore Catch host tools.",
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
writeRoute("/404/", routeMetas["/404/"]);
writeStaticHtml("404.html", routeMetas["/404/"]);

for (const listing of hostListings) {
  const listingMeta = {
    title: `${listing.name} | ${listing.city} organizer profile | Catch`,
    description: listing.description,
    canonical: `${baseUrl}${listing.path}`,
    twitterDescription: listing.sourceSummary,
    robots: listing.indexing,
    lastModified: listing.lastVerifiedAt,
    bodyHtml: buildListingStaticBody(listing),
    structuredData: buildListingStructuredData(listing),
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

function writeStaticHtml(fileName, meta) {
  fs.writeFileSync(path.join(distRoot, fileName), applyMeta(rootHtml, meta));
}

function applyMeta(html, meta) {
  let output = html
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
  if (meta.structuredData) {
    const json = JSON.stringify(meta.structuredData).replaceAll("<", "\\u003c");
    output = output.replace(
      /\n\s*<\/head>/s,
      `\n    <script type="application/ld+json">${json}</script>\n  </head>`
    );
  }
  if (meta.bodyHtml) {
    output = output.replace(
      /<div\s+id="root"\s*><\/div>/s,
      `<div id="root">${meta.bodyHtml}</div>`
    );
  }
  return output;
}

function buildListingStaticBody(listing) {
  const formats = (listing.formats ?? [])
    .map((format) => `<li>${escapeHtml(String(format))}</li>`)
    .join("");
  const facts = (listing.facts ?? [])
    .map((fact) =>
      `<div><dt>${escapeHtml(String(fact.label))}</dt>` +
        `<dd>${escapeHtml(String(fact.value))}</dd></div>`
    )
    .join("");
  const sources = (listing.sources ?? [])
    .filter((source) => safePublicUrl(source.href))
    .map((source) =>
      `<li><a href="${escapeHtml(source.href)}" rel="noopener noreferrer">` +
        `${escapeHtml(String(source.label))}</a>` +
        `${source.detail ? ` — ${escapeHtml(String(source.detail))}` : ""}</li>`
    )
    .join("");

  return [
    '<main data-static-organizer-profile="true">',
    `<header><p>Organizer profile · ${escapeHtml(String(listing.city))}</p>`,
    `<h1>${escapeHtml(String(listing.name))}</h1>`,
    `<p>${escapeHtml(String(listing.description))}</p></header>`,
    formats ? `<section><h2>Formats</h2><ul>${formats}</ul></section>` : "",
    facts ? `<section><h2>Profile facts</h2><dl>${facts}</dl></section>` : "",
    sources ? `<section><h2>Public sources</h2><ul>${sources}</ul></section>` : "",
    `<p>Last verified ${escapeHtml(String(listing.lastVerifiedAt ?? "not recorded"))}.</p>`,
    "</main>",
  ].join("");
}

function buildListingStructuredData(listing) {
  const canonical = `${baseUrl}${listing.path}`;
  const sameAs = (listing.sources ?? [])
    .map((source) => source.href)
    .filter(safePublicUrl);
  return {
    "@context": "https://schema.org",
    "@graph": [
      {
        "@type": "Organization",
        "@id": `${canonical}#organization`,
        name: listing.name,
        description: listing.description,
        url: canonical,
        sameAs: [...new Set(sameAs)],
        areaServed: {
          "@type": "Place",
          name: [listing.city, listing.region, listing.country]
            .filter(Boolean)
            .join(", "),
        },
      },
      {
        "@type": "BreadcrumbList",
        itemListElement: [
          {
            "@type": "ListItem",
            position: 1,
            name: "Catch",
            item: `${baseUrl}/`,
          },
          {
            "@type": "ListItem",
            position: 2,
            name: "Organizers",
            item: `${baseUrl}/organizers/`,
          },
          {
            "@type": "ListItem",
            position: 3,
            name: listing.name,
            item: canonical,
          },
        ],
      },
    ],
  };
}

function safePublicUrl(value) {
  if (typeof value !== "string") return false;
  try {
    const url = new URL(value);
    return url.protocol === "https:" || url.protocol === "http:";
  } catch {
    return false;
  }
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
  sitemapEntries.push({
    canonical: meta.canonical,
    lastModified: isoDateOrNull(meta.lastModified),
  });
}

function isNoindex(robots) {
  return typeof robots === "string" && /\bnoindex\b/i.test(robots);
}

function writeSitemap(entries) {
  const uniqueEntries = [...new Map(
    entries.map((entry) => [entry.canonical, entry])
  ).values()].sort((a, b) => a.canonical.localeCompare(b.canonical));
  const body = [
    '<?xml version="1.0" encoding="UTF-8"?>',
    '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">',
    ...uniqueEntries.map((entry) =>
      `  <url><loc>${escapeXml(entry.canonical)}</loc>` +
        `${entry.lastModified ? `<lastmod>${entry.lastModified}</lastmod>` : ""}` +
        `</url>`
    ),
    '</urlset>',
    '',
  ].join("\n");
  fs.writeFileSync(path.join(distRoot, "sitemap.xml"), body);
}

function isoDateOrNull(value) {
  return /^\d{4}-\d{2}-\d{2}$/.test(String(value ?? "")) ? String(value) : null;
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
