import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import test from "node:test";
import {fileURLToPath} from "node:url";
import {ownerGatedSiteDestinations, siteFooterLegalLinks} from "../src/content/site.ts";

const websiteRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const publishedLegalContent = JSON.parse(fs.readFileSync(
  path.join(websiteRoot, "src/content/legal.json"),
  "utf8"
));

test("confirmed legal, help, and contact contracts are publication-ready", () => {
  assert.deepEqual(
    Object.values(publishedLegalContent.pages).map((page) => page.path).sort(),
    ["/help/", "/privacy/", "/terms/"]
  );
  assert.equal(publishedLegalContent.operator.name, "Torana");
  assert.equal(publishedLegalContent.operator.supportEmail, "suvrat@catchdates.com");
  assert.equal(ownerGatedSiteDestinations.contactHref, "mailto:suvrat@catchdates.com");
  assert.deepEqual(
    siteFooterLegalLinks.map((link) => link.href).sort(),
    ["/help/", "/privacy/", "/terms/"]
  );

  const serialized = JSON.stringify(publishedLegalContent);
  assert.doesNotMatch(serialized, /CONFIRM|PLACEHOLDER|\[(?:TODO|TBD)/u);
  for (const page of Object.values(publishedLegalContent.pages)) {
    assert.ok(page.title.trim());
    assert.ok(page.summary.trim());
    assert.ok(page.sections.length >= 6);
    for (const section of page.sections) {
      assert.ok(section.heading.trim());
      assert.ok(section.paragraphs.every((paragraph) => paragraph.trim().length > 0));
    }
  }

  const routeRegistry = fs.readFileSync(
    path.join(websiteRoot, "src/app/routeRegistry.ts"),
    "utf8"
  );
  for (const route of ["privacy", "terms", "help"]) {
    assert.match(routeRegistry, new RegExp(`id: "${route}"`));
  }
});
