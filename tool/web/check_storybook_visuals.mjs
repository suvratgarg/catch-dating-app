#!/usr/bin/env node
import assert from "node:assert/strict";
import fs from "node:fs";
import http from "node:http";
import path from "node:path";
import {chromium} from "playwright";
import {PNG} from "pngjs";
import {fromRepo} from "../lib/repo_paths.mjs";

const args = parseArgs(process.argv.slice(2));
if (args.help) {
  printHelp();
  process.exit(0);
}
if (args.selfTest) {
  runSelfTest();
  process.exit(0);
}

const surfaceConfig = {
  admin: {
    registry: "design/admin/components.json",
    defaultStorybook: "admin/storybook-static",
    previewKey: "preview",
  },
  website: {
    registry: "design/website/components.json",
    defaultStorybook: "website/storybook-static",
    previewKey: "storybook",
  },
  webui: {
    registry: "design/web-ui/components.json",
    defaultStorybook: "website/storybook-static",
    previewKey: "storybook",
  },
};
const config = surfaceConfig[args.surface];
if (!config) fail(`Unknown surface: ${args.surface}`);

const storybookRoot = fromRepo(args.storybook ?? config.defaultStorybook);
const indexPath = path.join(storybookRoot, "index.json");
if (!fs.existsSync(indexPath)) {
  fail(`Built Storybook index not found: ${path.relative(fromRepo("."), indexPath)}`);
}

const registry = readJson(fromRepo(config.registry));
const storyIndex = readJson(indexPath);
let expectedStories;
try {
  expectedStories = selectStories(
    readyStories(registry, config.previewKey),
    args.components
  );
} catch (error) {
  fail(error.message);
}
const resolvedStories = resolveStories(expectedStories, storyIndex.entries ?? {});
const viewports = [
  {name: "desktop", width: 1280, height: 800},
  {name: "mobile", width: 375, height: 812},
];
const baselineRoot = fromRepo(`design/visual_baselines/${args.surface}`);
const diffRoot = fromRepo(`artifacts/visual-diffs/${args.surface}`);
fs.mkdirSync(baselineRoot, {recursive: true});
fs.mkdirSync(diffRoot, {recursive: true});

const server = await startServer(storybookRoot);
const browser = await chromium.launch({headless: true});
const jobs = resolvedStories.flatMap((story) =>
  viewports.map((viewport) => ({story, viewport}))
);
const failures = [];
let completed = 0;

try {
  await runPool(jobs, 6, async ({story, viewport}) => {
    const page = await browser.newPage({
      colorScheme: "light",
      reducedMotion: "reduce",
      viewport: {width: viewport.width, height: viewport.height},
    });
    try {
      await page.goto(`${server.origin}/iframe.html?id=${encodeURIComponent(story.id)}&viewMode=story`, {
        waitUntil: "networkidle",
      });
      await page.evaluate(async () => {
        await document.fonts.ready;
      });
      await page.addStyleTag({content: `
        *, *::before, *::after {
          animation-delay: 0s !important;
          animation-duration: 0s !important;
          caret-color: transparent !important;
          scroll-behavior: auto !important;
          transition: none !important;
        }
      `});
      await page.waitForTimeout(40);
      const errorDisplay = page.locator(".sb-errordisplay");
      const storyError = await errorDisplay.isVisible().catch(() => false)
        ? await errorDisplay.textContent()
        : null;
      if (storyError?.trim()) throw new Error(storyError.trim().replace(/\s+/gu, " ").slice(0, 2000));
      const actual = await page.screenshot({animations: "disabled", fullPage: false});
      const fileName = `${sanitize(story.id)}.${viewport.name}.png`;
      const baselinePath = path.join(baselineRoot, fileName);
      if (args.update) {
        fs.writeFileSync(baselinePath, actual);
      } else if (!fs.existsSync(baselinePath)) {
        failures.push(`${story.id} (${viewport.name}): missing baseline`);
      } else {
        const comparison = comparePng(fs.readFileSync(baselinePath), actual, args.threshold);
        if (!comparison.matches) {
          const diffPath = path.join(diffRoot, fileName);
          fs.writeFileSync(diffPath, comparison.diff);
          failures.push(
            `${story.id} (${viewport.name}): ${(comparison.ratio * 100).toFixed(3)}% pixels changed; ` +
            `diff ${path.relative(fromRepo("."), diffPath)}`
          );
        }
      }
    } catch (error) {
      failures.push(`${story.id} (${viewport.name}): ${error.message}`);
    } finally {
      await page.close();
      completed += 1;
      if (completed % 50 === 0 || completed === jobs.length) {
        console.log(`Visual progress: ${completed}/${jobs.length}`);
      }
    }
  });
} finally {
  await browser.close();
  await server.close();
}

if (failures.length > 0) {
  console.error(`Storybook visual check failed (${failures.length}/${jobs.length} capture(s)):`);
  failures.forEach((failure) => console.error(`- ${failure}`));
  process.exit(1);
}

console.log(
  `Storybook visuals ${args.update ? "updated" : "passed"}: ` +
  `${resolvedStories.length} ready story(s), ${jobs.length} capture(s), surface ${args.surface}.`
);

function readyStories(document, previewKey) {
  const stories = [];
  const seen = new Set();
  for (const component of document.components ?? []) {
    const preview = component[previewKey];
    if (preview?.status !== "ready") continue;
    if (!preview.story || !preview.exportName) {
      fail(`${component.id}: ready visual entry needs a story path and export name`);
    }
    const key = `${preview.story}::${preview.exportName}`;
    if (seen.has(key)) continue;
    seen.add(key);
    stories.push({componentId: component.id, storyPath: preview.story, exportName: preview.exportName});
  }
  return stories;
}

function selectStories(stories, componentIds) {
  if (componentIds.length === 0) return stories;
  const requested = new Set(componentIds);
  const available = new Set(stories.map((story) => story.componentId));
  const missing = [...requested].filter((componentId) => !available.has(componentId));
  if (missing.length > 0) {
    throw new Error(`Ready visual component not found: ${missing.join(", ")}`);
  }
  return stories.filter((story) => requested.has(story.componentId));
}

function resolveStories(expected, entries) {
  const stories = Object.values(entries).filter((entry) => entry.type === "story");
  return expected.map((item) => {
    const matches = stories.filter((entry) =>
      entry.exportName === item.exportName && pathsMatch(item.storyPath, entry.importPath)
    );
    if (matches.length !== 1) {
      fail(`${item.componentId}: expected one built story for ${item.storyPath}::${item.exportName}, found ${matches.length}`);
    }
    return matches[0];
  });
}

function pathsMatch(expected, actual) {
  const clean = (value) => String(value).replaceAll("\\", "/").replace(/^(?:\.\.\/|\.\/)+/u, "");
  const expectedPath = clean(expected);
  const actualPath = clean(actual);
  return expectedPath.endsWith(actualPath) || actualPath.endsWith(expectedPath) ||
    path.posix.basename(expectedPath) === path.posix.basename(actualPath);
}

function comparePng(expectedBuffer, actualBuffer, ratioThreshold) {
  const expected = PNG.sync.read(expectedBuffer);
  const actual = PNG.sync.read(actualBuffer);
  if (expected.width !== actual.width || expected.height !== actual.height) {
    return {matches: false, ratio: 1, diff: actualBuffer};
  }
  const diff = new PNG({width: actual.width, height: actual.height});
  let changed = 0;
  const pixelCount = actual.width * actual.height;
  for (let offset = 0; offset < actual.data.length; offset += 4) {
    const delta = Math.max(
      Math.abs(expected.data[offset] - actual.data[offset]),
      Math.abs(expected.data[offset + 1] - actual.data[offset + 1]),
      Math.abs(expected.data[offset + 2] - actual.data[offset + 2]),
      Math.abs(expected.data[offset + 3] - actual.data[offset + 3])
    );
    if (delta > 24) {
      changed += 1;
      diff.data.set([255, 0, 128, 255], offset);
    } else {
      const gray = Math.round((actual.data[offset] + actual.data[offset + 1] + actual.data[offset + 2]) / 3);
      diff.data.set([gray, gray, gray, 110], offset);
    }
  }
  const ratio = changed / pixelCount;
  return {matches: ratio <= ratioThreshold, ratio, diff: PNG.sync.write(diff)};
}

async function runPool(items, concurrency, worker) {
  let cursor = 0;
  await Promise.all(Array.from({length: Math.min(concurrency, items.length)}, async () => {
    while (cursor < items.length) {
      const item = items[cursor];
      cursor += 1;
      await worker(item);
    }
  }));
}

async function startServer(root) {
  const server = http.createServer((request, response) => {
    const requestPath = decodeURIComponent(new URL(request.url ?? "/", "http://localhost").pathname);
    let filePath = path.join(root, requestPath);
    if (requestPath.endsWith("/")) filePath = path.join(filePath, "index.html");
    if (!filePath.startsWith(root) || !fs.existsSync(filePath) || fs.statSync(filePath).isDirectory()) {
      response.writeHead(404).end("Not found");
      return;
    }
    const extension = path.extname(filePath);
    const contentTypes = {
      ".css": "text/css",
      ".html": "text/html",
      ".js": "text/javascript",
      ".json": "application/json",
      ".png": "image/png",
      ".svg": "image/svg+xml",
      ".woff2": "font/woff2",
    };
    response.setHeader("Content-Type", contentTypes[extension] ?? "application/octet-stream");
    fs.createReadStream(filePath).pipe(response);
  });
  await new Promise((resolve) => server.listen(0, "127.0.0.1", resolve));
  const address = server.address();
  return {
    origin: `http://127.0.0.1:${address.port}`,
    close: () => new Promise((resolve, reject) => server.close((error) => error ? reject(error) : resolve())),
  };
}

function sanitize(value) {
  return String(value).replace(/[^a-z0-9_.-]+/giu, "-");
}

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function parseArgs(argv) {
  const parsed = {
    components: [],
    help: false,
    selfTest: false,
    storybook: null,
    surface: "website",
    threshold: 0.001,
    update: false,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--help" || arg === "-h") parsed.help = true;
    else if (arg === "--self-test") parsed.selfTest = true;
    else if (arg === "--update") parsed.update = true;
    else if (arg === "--check") {}
    else if (arg === "--component") parsed.components.push(requiredValue(argv, ++index, arg));
    else if (arg === "--surface") parsed.surface = requiredValue(argv, ++index, arg);
    else if (arg === "--storybook") parsed.storybook = requiredValue(argv, ++index, arg);
    else if (arg === "--threshold") parsed.threshold = Number(requiredValue(argv, ++index, arg));
    else fail(`Unknown argument: ${arg}`);
  }
  if (!Number.isFinite(parsed.threshold) || parsed.threshold < 0 || parsed.threshold > 1) {
    fail("--threshold must be between 0 and 1");
  }
  return parsed;
}

function requiredValue(argv, index, flag) {
  const value = argv[index];
  if (!value || value.startsWith("--")) fail(`${flag} requires a value`);
  return value;
}

function runSelfTest() {
  const first = new PNG({width: 2, height: 1});
  first.data.set([10, 10, 10, 255, 20, 20, 20, 255]);
  const same = comparePng(PNG.sync.write(first), PNG.sync.write(first), 0);
  assert.equal(same.matches, true);
  const second = new PNG({width: 2, height: 1});
  second.data.set([10, 10, 10, 255, 255, 255, 255, 255]);
  const changed = comparePng(PNG.sync.write(first), PNG.sync.write(second), 0.1);
  assert.equal(changed.matches, false);
  assert.equal(changed.ratio, 0.5);
  const stories = [
    {componentId: "one", exportName: "One", storyPath: "One.stories.tsx"},
    {componentId: "two", exportName: "Two", storyPath: "Two.stories.tsx"},
  ];
  assert.deepEqual(selectStories(stories, ["two"]), [stories[1]]);
  assert.throws(() => selectStories(stories, ["missing"]), /Ready visual component not found: missing/u);
  console.log("Storybook visual checker self-test passed.");
}

function printHelp() {
  console.log(`Usage: node tool/web/check_storybook_visuals.mjs [options]

Options:
  --surface website|admin|webui  Registry surface to capture.
  --storybook <path>             Built Storybook directory.
  --component <registry-id>      Limit to one ready registry component; repeatable.
  --update                       Write committed baselines.
  --check                        Compare against committed baselines (default).
  --threshold <ratio>            Maximum changed-pixel ratio (default 0.001).
  --self-test                    Run deterministic pixel-comparison proof.
`);
}

function fail(message) {
  console.error(message);
  process.exit(64);
}
