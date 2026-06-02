import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";

const dirname = path.dirname(fileURLToPath(import.meta.url));
const websiteRoot = path.resolve(dirname, "..");
const distRoot = path.join(websiteRoot, "dist");

const routeMetas = {
  "/": {
    title: "Catch | The room before the match",
    description:
      "Catch turns curated singles events into real dating context. Choose a hosted event, show up, catch privately, and match with people you actually met.",
    canonical: "https://catchdates.com/",
    twitterDescription: "Curated singles events become real dating context.",
  },
  "/host/": {
    title: "Catch for Hosts | Host better singles events",
    description:
      "Catch helps hosts publish curated singles events, manage admission and waitlists, run live facilitation, and turn real rooms into better post-event connections.",
    canonical: "https://catchdates.com/host/",
    twitterDescription:
      "Event setup, admission, waitlists, live facilitation, check-in, and aggregate post-event reporting for hosts.",
  },
};

const rootHtmlPath = path.join(distRoot, "index.html");
const rootHtml = fs.readFileSync(rootHtmlPath, "utf8");
fs.writeFileSync(rootHtmlPath, applyMeta(rootHtml, routeMetas["/"]));

const hostDir = path.join(distRoot, "host");
fs.mkdirSync(hostDir, {recursive: true});
fs.writeFileSync(path.join(hostDir, "index.html"), applyMeta(rootHtml, routeMetas["/host/"]));

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
    );
}

function escapeHtml(value) {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll('"', "&quot;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;");
}
