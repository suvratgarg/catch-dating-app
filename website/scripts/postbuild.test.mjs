import assert from "node:assert/strict";
import {execFileSync} from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {fileURLToPath} from "node:url";

const scriptPath = fileURLToPath(new URL("./postbuild.mjs", import.meta.url));

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
  assert.match(listingHtml, /<title>AFTER FLY \| Indore organizer profile \| Catch<\/title>/);
  assert.match(
    listingHtml,
    /<link rel="canonical" href="https:\/\/example\.test\/organizers\/afterfly\/" \/>/
  );
  assert.match(listingHtml, /<meta name="robots" content="index, follow" \/>/);

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
  assert.match(claimHtml, /<title>Claim your organizer listing \| Catch<\/title>/);
  assert.match(
    claimHtml,
    /<link rel="canonical" href="https:\/\/example\.test\/claim\/" \/>/
  );
  assert.match(claimHtml, /<meta name="robots" content="noindex, follow" \/>/);

  const sitemap = fs.readFileSync(path.join(distRoot, "sitemap.xml"), "utf8");
  assert.match(sitemap, /<loc>https:\/\/example\.test\/<\/loc>/);
  assert.match(sitemap, /<loc>https:\/\/example\.test\/host\/<\/loc>/);
  assert.match(sitemap, /<loc>https:\/\/example\.test\/organizers\/afterfly\/<\/loc>/);
  assert.doesNotMatch(sitemap, /claim\/<\/loc>/);
  assert.doesNotMatch(sitemap, /organizers\/$/);
  assert.doesNotMatch(sitemap, /afterfly-run-club/);
  assert.doesNotMatch(sitemap, /noindex-sample/);

  const robots = fs.readFileSync(path.join(distRoot, "robots.txt"), "utf8");
  assert.match(robots, /User-agent: \*/);
  assert.match(robots, /Sitemap: https:\/\/example\.test\/sitemap\.xml/);
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

function hostListings() {
  return [
    {
      city: "Indore",
      description: "Admin-approved organizer profile.",
      indexing: "index, follow",
      legacyPaths: ["/organizers/indore/afterfly-run-club/"],
      name: "AFTER FLY",
      path: "/organizers/afterfly/",
      sourceSummary: "Admin-reviewed public source summary.",
    },
    {
      city: "Delhi",
      description: "Noindex organizer profile.",
      indexing: "noindex, follow",
      legacyPaths: [],
      name: "Noindex Sample",
      path: "/organizers/noindex-sample/",
      sourceSummary: "Noindex source summary.",
    },
  ];
}
