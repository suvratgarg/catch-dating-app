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
    ["/delete-account/", "/help/", "/privacy/", "/terms/"]
  );
  assert.equal(publishedLegalContent.operator.name, "Torana");
  assert.equal(publishedLegalContent.operator.supportEmail, "suvrat.garg@gmail.com");
  assert.equal(ownerGatedSiteDestinations.contactHref, "mailto:suvrat.garg@gmail.com");
  assert.deepEqual(
    siteFooterLegalLinks.map((link) => link.href).sort(),
    ["/help/", "/privacy/", "/terms/"]
  );

  const publishedPaths = new Set(Object.values(publishedLegalContent.pages).map((page) => page.path));
  const serialized = JSON.stringify(publishedLegalContent);
  assert.doesNotMatch(serialized, /CONFIRM|PLACEHOLDER|\[(?:TODO|TBD)/u);
  for (const page of Object.values(publishedLegalContent.pages)) {
    assert.ok(page.title.trim());
    assert.ok(page.summary.trim());
    assert.ok(page.sections.length >= 6);
    const pageCopy = page.sections.flatMap((section) => section.paragraphs).join("\n");
    assert.match(pageCopy, /suvrat\.garg@gmail\.com/u, `${page.path} must publish the contact address`);
    assert.doesNotMatch(pageCopy, /suvrat@catchdates\.com/u, `${page.path} must not publish the inactive address`);
    for (const section of page.sections) {
      assert.ok(section.heading.trim());
      assert.ok(section.paragraphs.every((paragraph) => paragraph.trim().length > 0));
      for (const link of section.links ?? []) {
        assert.ok(link.label.trim(), `${page.path} link labels must be non-empty`);
        assert.ok(publishedPaths.has(link.href), `${page.path} links to unpublished ${link.href}`);
      }
    }
  }

  const routeRegistry = fs.readFileSync(
    path.join(websiteRoot, "src/app/routeRegistry.ts"),
    "utf8"
  );
  for (const route of ["privacy", "terms", "help", "account_deletion"]) {
    assert.match(routeRegistry, new RegExp(`id: "${route}"`));
  }
});

test("account deletion resource meets the store web-deletion requirement", () => {
  const {pages} = publishedLegalContent;
  const deletion = pages.account_deletion;
  assert.equal(deletion.path, "/delete-account/");
  const copy = deletion.sections
    .flatMap((section) => [section.heading, ...section.paragraphs, ...(section.bullets ?? [])])
    .join("\n");
  // Both in-app paths, matching the shipped consumer Settings row and Host account menu.
  assert.match(copy, /Settings[^.]*Delete account/u);
  assert.match(copy, /Catch Host[^.]*Account menu[^.]*Delete account/u);
  // A request path that needs neither the app nor a reinstall.
  assert.match(copy, /without (?:installing|reinstalling)[^.]*app/u);
  assert.match(copy, /Account deletion/u, "the email subject must be named");
  // Deleted and retained data are both disclosed.
  assert.ok(deletion.sections.some((section) => /deleted/u.test(section.heading) && section.bullets?.length));
  assert.ok(deletion.sections.some((section) => /kept|retain/u.test(section.heading) && section.bullets?.length));
  // Pricing stays unpublished until its owner decision lands.
  assert.doesNotMatch(copy, /₹|\bINR\b|\bpric(?:e|es|ing)\b|commission/iu);

  const linksTo = (page) => page.sections.flatMap((section) => section.links ?? [])
    .map((link) => link.href);
  assert.ok(linksTo(pages.help).includes("/delete-account/"), "Help must link the deletion page");
  assert.ok(linksTo(pages.privacy).includes("/delete-account/"), "Privacy must link the deletion page");
});
