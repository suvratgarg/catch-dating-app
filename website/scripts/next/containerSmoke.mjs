import assert from "node:assert/strict";
import {hostLandingCopy} from "../../src/content/hostLanding.ts";
const base = process.argv[2];
assert.match(base ?? "", /^http:\/\/127\.0\.0\.1:\d+$/u);
async function get(path) {
  return fetch(`${base}${path}`, {redirect: "manual", signal: AbortSignal.timeout(15_000)});
}
let response;
for (let attempt = 0; attempt < 30; attempt++) {
  try { response = await get("/host/"); break; }
  catch (error) { if (attempt === 29) throw error; await new Promise(resolve => setTimeout(resolve, 1000)); }
}
assert.equal(response.status, 200, "Production-eligible container must render the authored Host page");
const hostHtml = await response.text();
assert.ok(hostHtml.includes(hostLandingCopy.hero.title), "Container must serve the redesigned Host page");
assert.ok(hostHtml.includes(hostLandingCopy.adoption.circlesLabel), "Adoption circles must survive packaging");
assert.equal((await get("/not-a-real-preview-route/")).status, 404);
const unavailable = await get("/");
assert.equal(unavailable.status, 503, "An uncredentialed container must fail closed on public database reads");
assert.match(unavailable.headers.get("cache-control"), /no-store/u);
const privatePage = await get("/f/preview-secret-token/");
assert.equal(privatePage.status, 200);
assert.match(privatePage.headers.get("x-robots-tag"), /noindex/u);
assert.doesNotMatch(await privatePage.text(), /preview-secret-token/u);
const association = await get("/.well-known/apple-app-site-association");
assert.equal(association.status, 200);
assert.ok((await association.json()).applinks);
console.log("Container source, production eligibility, failure, private-shell and app-link checks passed.");
