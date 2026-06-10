import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";

const dirname = path.dirname(fileURLToPath(import.meta.url));
const websiteRoot = path.resolve(dirname, "..");
const distRoot = path.join(websiteRoot, "dist");
const hostListingsPath = path.join(websiteRoot, "src", "generated", "hostListings.json");
const hostListings = JSON.parse(fs.readFileSync(hostListingsPath, "utf8"));

const routeMetas = {
  "/": {
    title: "Catch | The event before the match",
    description:
      "Catch turns curated singles events into real dating context. Choose a hosted event, show up, catch privately, and match with people you actually met.",
    canonical: "https://catchdates.com/",
    twitterDescription: "Curated singles events become real dating context.",
  },
  "/host/": {
    title: "Catch for Hosts | Host better singles events",
    description:
      "Catch helps hosts publish curated singles events, manage admission and waitlists, run live facilitation, and turn real attendance into post-event connections.",
    canonical: "https://catchdates.com/host/",
    twitterDescription:
      "Event setup, admission, waitlists, live facilitation, check-in, and aggregate post-event reporting for hosts.",
  },
  "/organizers/": {
    title: "Organizer Search | Catch",
    description:
      "Search Catch organizer profiles by name, city, format, and review signal.",
    canonical: "https://catchdates.com/organizers/",
    twitterDescription: "Search Catch organizer and club profiles.",
    robots: "noindex, follow",
  },
};

const rootHtmlPath = path.join(distRoot, "index.html");
const rootHtml = fs.readFileSync(rootHtmlPath, "utf8");
writeRoute("/", routeMetas["/"]);

writeRoute("/host/", routeMetas["/host/"]);
writeRoute("/organizers/", routeMetas["/organizers/"]);

for (const listing of hostListings) {
  writeRoute(listing.path, {
    title: `${listing.name} | ${listing.city} organizer profile | Catch`,
    description: listing.description,
    canonical: `https://catchdates.com${listing.path}`,
    twitterDescription: listing.sourceSummary,
    robots: listing.indexing,
  });
}

function writeRoute(routePath, meta) {
  if (routePath === "/") {
    fs.writeFileSync(rootHtmlPath, applyMeta(rootHtml, meta));
    return;
  }

  const routeDir = path.join(distRoot, ...routePath.split("/").filter(Boolean));
  fs.mkdirSync(routeDir, {recursive: true});
  fs.writeFileSync(path.join(routeDir, "index.html"), applyMeta(rootHtml, meta));
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
