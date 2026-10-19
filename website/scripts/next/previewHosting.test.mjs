import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";
const read = name => JSON.parse(fs.readFileSync(new URL(`../../../${name}`, import.meta.url), "utf8"));
test("preview retains API priority, association files and current redirects without changing the production target", () => {
  const live = read("firebase.json").hosting.find(item => item.target === "marketing");
  const preview = read("website/next-hosting.preview.json").hosting;
  assert.equal(live.public, "website/dist");
  assert.equal(preview.public, "public");
  assert(fs.statSync(new URL(`../../${preview.public}`, import.meta.url)).isDirectory());
  assert.deepEqual(preview.rewrites.slice(0, -1), live.rewrites.filter(item => item.function));
  assert.deepEqual(preview.redirects, live.redirects);
  assert.deepEqual(preview.rewrites.at(-1), {source: "**", run: {serviceId: "catch-website-next-preview", region: "asia-south1", pinTag: true}});
  assert(!preview.ignore.includes("**/.*"), "association files must remain deployable");
  assert(preview.headers.some(rule => rule.source === "**" && rule.headers.some(header => header.key === "X-Robots-Tag" && header.value.includes("noindex"))));
});
