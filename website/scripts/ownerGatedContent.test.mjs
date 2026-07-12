import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import test from "node:test";
import {fileURLToPath} from "node:url";
import {ownerGatedLegalPages} from "../src/content/legal.ts";
import {ownerGatedSiteDestinations} from "../src/content/site.ts";

const websiteRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");

test("owner-gated legal and contact contracts remain dormant", () => {
  assert.deepEqual(
    Object.values(ownerGatedLegalPages).map((page) => page.path).sort(),
    ["/help", "/privacy", "/terms"]
  );
  for (const page of Object.values(ownerGatedLegalPages)) {
    assert.equal(page.body, null);
  }
  assert.equal(ownerGatedSiteDestinations.contactHref, "");

  const productionSources = productionTypeScriptFiles(path.join(websiteRoot, "src"));
  for (const sourcePath of productionSources) {
    if (sourcePath.includes(`${path.sep}content${path.sep}`)) continue;
    const source = fs.readFileSync(sourcePath, "utf8");
    assert.doesNotMatch(source, /@content\/legal|content\/legal/u);
  }

  const routeRegistry = fs.readFileSync(
    path.join(websiteRoot, "src/app/routeRegistry.ts"),
    "utf8"
  );
  for (const page of Object.values(ownerGatedLegalPages)) {
    assert.equal(
      routeRegistry.includes(`"${page.path}"`) || routeRegistry.includes(`'${page.path}'`),
      false,
      `${page.path} must remain unregistered until its body is supplied`
    );
  }
});

function productionTypeScriptFiles(directory) {
  const files = [];
  for (const entry of fs.readdirSync(directory, {withFileTypes: true})) {
    const fullPath = path.join(directory, entry.name);
    if (entry.isDirectory()) {
      if (["generated", "stories"].includes(entry.name)) continue;
      files.push(...productionTypeScriptFiles(fullPath));
      continue;
    }
    if (/\.(?:ts|tsx)$/u.test(entry.name) && !entry.name.includes(".test.")) {
      files.push(fullPath);
    }
  }
  return files;
}
