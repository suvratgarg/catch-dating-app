#!/usr/bin/env node
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";

const repoRoot = path.resolve(
  path.dirname(fileURLToPath(import.meta.url)),
  "../.."
);
const args = new Set(process.argv.slice(2));

if (args.has("--self-test")) {
  assert.deepEqual(todoExports(`
export const Clean = {parameters: {a11y: {test: "error"}}};
export const Debt = {parameters: {a11y: {test: "todo"}}};
`, "fixture.stories.tsx"), ["fixture.stories.tsx::Debt"]);
  console.log("Storybook accessibility debt checker self-test passed.");
  process.exit(0);
}

const registryPath = path.join(repoRoot, "design/website/a11y.todo.json");
const registry = JSON.parse(fs.readFileSync(registryPath, "utf8"));
const errors = [];
if (registry.debtId !== "WEB-A11Y-001") {
  errors.push("registry debtId must be WEB-A11Y-001");
}
if (!Array.isArray(registry.stories)) {
  errors.push("registry stories must be an array");
}

const registered = new Set();
for (const item of registry.stories ?? []) {
  const key = `${item.file}::${item.export}`;
  if (registered.has(key)) errors.push(`duplicate registry entry: ${key}`);
  registered.add(key);
  if (typeof item.reason !== "string" || item.reason.trim().length < 20) {
    errors.push(`registry entry needs a specific reason: ${key}`);
  }
  const absolutePath = path.join(repoRoot, item.file);
  if (!fs.existsSync(absolutePath)) errors.push(`registered story file is missing: ${item.file}`);
}

const actual = new Set();
const storiesRoot = path.join(repoRoot, "website/src/stories");
for (const name of fs.readdirSync(storiesRoot)) {
  if (!name.endsWith(".stories.tsx")) continue;
  const relativePath = `website/src/stories/${name}`;
  const source = fs.readFileSync(path.join(storiesRoot, name), "utf8");
  for (const key of todoExports(source, relativePath)) actual.add(key);
}

for (const key of actual) {
  if (!registered.has(key)) errors.push(`unregistered a11y todo: ${key}`);
}
for (const key of registered) {
  if (!actual.has(key)) errors.push(`stale a11y todo registry entry: ${key}`);
}

if (errors.length > 0) {
  console.error("Storybook accessibility debt check failed:");
  for (const error of errors) console.error(`- ${error}`);
  process.exit(1);
}
console.log(
  `Storybook accessibility debt check passed: ${actual.size} exact todo story contract(s).`
);

function todoExports(source, relativePath) {
  const matches = [...source.matchAll(/^export\s+const\s+([A-Za-z0-9_]+)\b/gmu)];
  const found = [];
  for (let index = 0; index < matches.length; index += 1) {
    const start = matches[index].index ?? 0;
    const end = matches[index + 1]?.index ?? source.length;
    const block = source.slice(start, end);
    if (/a11y\s*:\s*\{\s*test\s*:\s*["']todo["']/su.test(block)) {
      found.push(`${relativePath}::${matches[index][1]}`);
    }
  }
  return found;
}
