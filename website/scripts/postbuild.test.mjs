import assert from "node:assert/strict";
import {execFileSync} from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {fileURLToPath} from "node:url";

const scriptPath = fileURLToPath(new URL("./postbuild.mjs", import.meta.url));
const canonicalMetaPath = fileURLToPath(
  new URL("../src/content/meta.json", import.meta.url)
);

test("postbuild writes route metadata, robots, and an indexable-only sitemap", () => {
  const tmpRoot = fs.mkdtempSync(path.join(os.tmpdir(), "catch-postbuild-"));
  const distRoot = path.join(tmpRoot, "dist");
  const hostListingsPath = path.join(tmpRoot, "hostListings.json");
  fs.mkdirSync(distRoot, {recursive: true});
  fs.writeFileSync(path.join(distRoot, "index.html"), baseHtml());
  fs.writeFileSync(
    hostListingsPath,
    `${JSON.stringify(hostListings(), null, 2)}\n`
  );

  execFileSync(process.execPath, [
    scriptPath,
    "--dist-root",
    distRoot,
    "--host-listings",
    hostListingsPath,
    "--base-url",
    "https://example.test",
  ], {stdio: "pipe"});

  const listingHtml = fs.readFileSync(
    path.join(distRoot, "organizers", "afterfly", "index.html"),
    "utf8"
  );
  assert.match(listingHtml, /<title>AFTER FLY \| Indore events &amp; reviews \| Catch<\/title>/);
  assert.match(
    listingHtml,
    /<link rel="canonical" href="https:\/\/example\.test\/organizers\/afterfly\/" \/>/
  );
  assert.match(listingHtml, /<meta name="robots" content="index, follow" \/>/);
  assert.match(listingHtml, /data-static-organizer-profile="true"/);
  assert.match(listingHtml, /<h1>AFTER FLY<\/h1>/);
  assert.match(listingHtml, /<h2>Public sources<\/h2>/);
  assert.match(listingHtml, /type="application\/ld\+json"/);
  assert.match(listingHtml, /"@type":"Organization"/);
  assert.match(listingHtml, /"@type":"BreadcrumbList"/);

  const legacyHtml = fs.readFileSync(
    path.join(distRoot, "organizers", "indore", "afterfly-run-club", "index.html"),
    "utf8"
  );
  assert.match(legacyHtml, /<meta name="robots" content="noindex, follow" \/>/);
  assert.match(
    legacyHtml,
    /<link rel="canonical" href="https:\/\/example\.test\/organizers\/afterfly\/" \/>/
  );

  const claimHtml = fs.readFileSync(
    path.join(distRoot, "claim", "index.html"),
    "utf8"
  );
  assert.match(claimHtml, /<title>Claim your organizer page \| Catch<\/title>/);
  assert.match(
    claimHtml,
    /<link rel="canonical" href="https:\/\/example\.test\/claim\/" \/>/
  );
  assert.match(claimHtml, /<meta name="robots" content="noindex, follow" \/>/);

  const notFoundHtml = fs.readFileSync(
    path.join(distRoot, "404.html"),
    "utf8"
  );
  assert.match(notFoundHtml, /<title>Page not found \| Catch<\/title>/);
  assert.match(
    notFoundHtml,
    /<link rel="canonical" href="https:\/\/example\.test\/404\/" \/>/
  );
  assert.match(notFoundHtml, /<meta name="robots" content="noindex, follow" \/>/);

  const canonicalMeta = JSON.parse(fs.readFileSync(canonicalMetaPath, "utf8"));
  for (const [routeKey, relativeOutput] of [
    ["home", "index.html"],
    ["host", path.join("host", "index.html")],
    ["organizers", path.join("organizers", "index.html")],
    ["claim", path.join("claim", "index.html")],
    ["not_found", "404.html"],
  ]) {
    assertStaticRouteMeta(
      fs.readFileSync(path.join(distRoot, relativeOutput), "utf8"),
      canonicalMeta.routes[routeKey],
      "https://example.test"
    );
  }

  const sitemap = fs.readFileSync(path.join(distRoot, "sitemap.xml"), "utf8");
  assert.match(sitemap, /<loc>https:\/\/example\.test\/<\/loc>/);
  assert.match(sitemap, /<loc>https:\/\/example\.test\/host\/<\/loc>/);
  assert.match(sitemap, /<loc>https:\/\/example\.test\/organizers\/afterfly\/<\/loc>/);
  assert.match(
    sitemap,
    /<loc>https:\/\/example\.test\/organizers\/afterfly\/<\/loc><lastmod>2026-06-18<\/lastmod>/
  );
  assert.doesNotMatch(sitemap, /claim\/<\/loc>/);
  assert.doesNotMatch(sitemap, /404\/<\/loc>/);
  assert.doesNotMatch(sitemap, /organizers\/$/);
  assert.doesNotMatch(sitemap, /afterfly-run-club/);
  assert.doesNotMatch(sitemap, /noindex-sample/);

  const robots = fs.readFileSync(path.join(distRoot, "robots.txt"), "utf8");
  assert.match(robots, /User-agent: \*/);
  assert.match(robots, /Sitemap: https:\/\/example\.test\/sitemap\.xml/);
});

test("postbuild reads static and listing metadata from the validated content source", () => {
  const tmpRoot = fs.mkdtempSync(path.join(os.tmpdir(), "catch-postbuild-content-"));
  const distRoot = path.join(tmpRoot, "dist");
  const hostListingsPath = path.join(tmpRoot, "hostListings.json");
  const metaContentPath = path.join(tmpRoot, "meta.json");
  const metaContent = JSON.parse(fs.readFileSync(canonicalMetaPath, "utf8"));
  metaContent.routes.claim.title = "Custom claim metadata";
  metaContent.listing.titleTemplate = "{name} in {city} | Custom profile";
  metaContent.listing.staticLabels.sourcesHeading = "Verified links";

  fs.mkdirSync(distRoot, {recursive: true});
  fs.writeFileSync(path.join(distRoot, "index.html"), baseHtml());
  fs.writeFileSync(hostListingsPath, `${JSON.stringify(hostListings(), null, 2)}\n`);
  fs.writeFileSync(metaContentPath, `${JSON.stringify(metaContent, null, 2)}\n`);

  execFileSync(process.execPath, [
    scriptPath,
    "--dist-root",
    distRoot,
    "--host-listings",
    hostListingsPath,
    "--meta-content",
    metaContentPath,
    "--base-url",
    "https://example.test",
  ], {stdio: "pipe"});

  const claimHtml = fs.readFileSync(path.join(distRoot, "claim", "index.html"), "utf8");
  const listingHtml = fs.readFileSync(
    path.join(distRoot, "organizers", "afterfly", "index.html"),
    "utf8"
  );
  assert.match(claimHtml, /<title>Custom claim metadata<\/title>/u);
  assert.match(listingHtml, /<title>AFTER FLY in Indore \| Custom profile<\/title>/u);
  assert.match(listingHtml, /<h2>Verified links<\/h2>/u);
});

function baseHtml() {
  return `<!DOCTYPE html>
<html lang="en">
  <head>
    <title>Catch | The event before the match</title>
    <meta name="description" content="Default description." />
    <meta property="og:title" content="Default title" />
    <meta property="og:description" content="Default OG description" />
    <meta property="og:url" content="https://catchdates.com/" />
    <meta name="twitter:title" content="Default title" />
    <meta name="twitter:description" content="Default Twitter description" />
    <link rel="canonical" href="https://catchdates.com/" />
  </head>
  <body><div id="root"></div></body>
</html>
`;
}

function assertStaticRouteMeta(html, meta, baseUrl) {
  const canonical = `${baseUrl}${meta.canonicalPath}`;
  const expectedTags = [
    `<title>${escapeHtml(meta.title)}</title>`,
    `<meta name="description" content="${escapeHtml(meta.description)}" />`,
    `<meta property="og:title" content="${escapeHtml(meta.title)}" />`,
    `<meta property="og:description" content="${escapeHtml(meta.description)}" />`,
    `<meta property="og:url" content="${escapeHtml(canonical)}" />`,
    `<meta name="twitter:title" content="${escapeHtml(meta.title)}" />`,
    `<meta name="twitter:description" content="${escapeHtml(meta.twitterDescription)}" />`,
    `<link rel="canonical" href="${escapeHtml(canonical)}" />`,
  ];
  if (meta.robots) {
    expectedTags.push(`<meta name="robots" content="${escapeHtml(meta.robots)}" />`);
  }
  for (const tag of expectedTags) {
    assert.ok(html.includes(tag), `expected built HTML to include ${tag}`);
  }
  if (!meta.robots) {
    assert.doesNotMatch(html, /<meta name="robots"/u);
  }
}

function escapeHtml(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#39;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;");
}

function hostListings() {
  return [
    {
      city: "Indore",
      description: "Admin-approved organizer profile.",
      formats: ["Social runs"],
      facts: [{label: "Market", value: "Indore"}],
      indexing: "index, follow",
      lastVerifiedAt: "2026-06-18",
      legacyPaths: ["/organizers/indore/afterfly-run-club/"],
      name: "AFTER FLY",
      path: "/organizers/afterfly/",
      sourceSummary: "Admin-reviewed public source summary.",
      sources: [{
        detail: "Reviewed public source.",
        href: "https://example.test/afterfly",
        label: "Official website",
      }],
    },
    {
      city: "Delhi",
      description: "Noindex organizer profile.",
      formats: [],
      facts: [],
      indexing: "noindex, follow",
      legacyPaths: [],
      name: "Noindex Sample",
      path: "/organizers/noindex-sample/",
      sourceSummary: "Noindex source summary.",
      sources: [],
    },
  ];
}
