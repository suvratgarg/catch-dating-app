#!/usr/bin/env node
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import {spawn} from "node:child_process";
import {pathToFileURL} from "node:url";
import {fromRepo, repoRoot} from "../lib/repo_paths.mjs";

const args = process.argv.slice(2);
const chromePath =
  valueAfter("--chrome-path") ??
  process.env.CHROME_PATH ??
  "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";
const sourcePath = resolvePath(valueAfter("--source"));
const label = valueAfter("--label");
const outputPath = resolvePath(valueAfter("--out"));
const viewport = parseViewport(valueAfter("--viewport") ?? "1320x920");
const clipOverride = parseClip(valueAfter("--clip"));
const waitMs = Number.parseInt(valueAfter("--wait-ms") ?? "600", 10);
const localStorageEntries = valuesAfter("--local-storage").map(
  parseLocalStorageEntry,
);
const write = args.includes("--write");

if (args.includes("--help") || args.includes("-h")) {
  printHelp();
  process.exit(0);
}

if (!write) {
  console.error("Refusing to write a reference without --write.");
  printHelp();
  process.exit(64);
}
if (!sourcePath || !label || !outputPath) {
  console.error("--source, --label, and --out are required.");
  printHelp();
  process.exit(64);
}
if (!Number.isFinite(waitMs) || waitMs < 0) {
  console.error("--wait-ms must be a non-negative integer.");
  process.exit(64);
}
if (!fs.existsSync(chromePath)) {
  console.error(`Chrome not found at ${chromePath}. Set CHROME_PATH or --chrome-path.`);
  process.exit(1);
}
if (!fs.existsSync(sourcePath)) {
  console.error(`Source not found at ${sourcePath}.`);
  process.exit(1);
}

fs.mkdirSync(path.dirname(outputPath), {recursive: true});

const userDataDir = fs.mkdtempSync(path.join(os.tmpdir(), "catch-ref-export-chrome-"));
const port = 9341;
const chrome = spawn(chromePath, [
  "--headless=new",
  "--disable-gpu",
  "--no-first-run",
  "--no-default-browser-check",
  "--allow-file-access-from-files",
  `--remote-debugging-port=${port}`,
  `--user-data-dir=${userDataDir}`,
  `--window-size=${viewport.width},${viewport.height}`,
  "about:blank",
], {
  stdio: ["ignore", "pipe", "pipe"],
});

let stderr = "";
chrome.stderr.on("data", (chunk) => {
  stderr += chunk.toString();
});

try {
  await waitForChrome(port);
  const browserWsUrl = await browserWebSocketUrl(port);
  const browser = await connectCdp(browserWsUrl);
  const {targetId} = await browser.send("Target.createTarget", {
    url: "about:blank",
  });
  const {sessionId} = await browser.send("Target.attachToTarget", {
    targetId,
    flatten: true,
  });

  await browser.send("Page.enable", {}, sessionId);
  await browser.send("Runtime.enable", {}, sessionId);
  await browser.send("Emulation.setDeviceMetricsOverride", {
    width: viewport.width,
    height: viewport.height,
    deviceScaleFactor: 1,
    mobile: false,
  }, sessionId);

  await navigate(browser, sessionId, pathToFileURL(sourcePath).href);
  if (localStorageEntries.length > 0) {
    await applyLocalStorage(browser, sessionId, localStorageEntries);
    await waitForLoad(browser, sessionId);
  }
  await waitForElement(browser, sessionId, label);
  await sleep(waitMs);

  const clip = clipOverride ?? await elementClip(browser, sessionId, label);
  const screenshot = await browser.send("Page.captureScreenshot", {
    format: "png",
    fromSurface: true,
    clip,
  }, sessionId);
  fs.writeFileSync(outputPath, Buffer.from(screenshot.data, "base64"));
  console.log(`Exported ${displayPath(outputPath)} from ${JSON.stringify(label)}.`);

  await browser.close();
} finally {
  chrome.kill("SIGTERM");
  try {
    fs.rmSync(userDataDir, {
      recursive: true,
      force: true,
      maxRetries: 5,
      retryDelay: 200,
    });
  } catch (error) {
    console.warn(`Could not remove temporary Chrome profile ${userDataDir}: ${error.message}`);
  }
}

function valueAfter(flag) {
  const index = args.indexOf(flag);
  if (index === -1) return null;
  const value = args[index + 1];
  if (!value || value.startsWith("--")) {
    console.error(`${flag} requires a value.`);
    process.exit(64);
  }
  return value;
}

function valuesAfter(flag) {
  const values = [];
  for (let index = 0; index < args.length; index += 1) {
    if (args[index] !== flag) continue;
    const value = args[index + 1];
    if (!value || value.startsWith("--")) {
      console.error(`${flag} requires a value.`);
      process.exit(64);
    }
    values.push(value);
  }
  return values;
}

function resolvePath(value) {
  if (!value) return null;
  return path.isAbsolute(value) ? value : fromRepo(value);
}

function parseLocalStorageEntry(value) {
  const separatorIndex = value.indexOf("=");
  if (separatorIndex <= 0) {
    console.error("--local-storage must use key=value.");
    process.exit(64);
  }
  return {
    key: value.slice(0, separatorIndex),
    value: value.slice(separatorIndex + 1),
  };
}

function parseViewport(value) {
  const match = /^(\d+)x(\d+)$/u.exec(value);
  if (!match) {
    console.error("--viewport must use WIDTHxHEIGHT, for example 1320x920.");
    process.exit(64);
  }
  return {
    width: Number.parseInt(match[1], 10),
    height: Number.parseInt(match[2], 10),
  };
}

function parseClip(value) {
  if (!value) return null;
  const match = /^(\d+),(\d+),(\d+),(\d+)$/u.exec(value);
  if (!match) {
    console.error("--clip must use x,y,width,height, for example 255,37,390,812.");
    process.exit(64);
  }
  return {
    x: Number.parseInt(match[1], 10),
    y: Number.parseInt(match[2], 10),
    width: Number.parseInt(match[3], 10),
    height: Number.parseInt(match[4], 10),
    scale: 1,
  };
}

async function navigate(cdp, sessionId, url) {
  await cdp.send("Page.navigate", {url}, sessionId);
  await waitForLoad(cdp, sessionId);
}

async function applyLocalStorage(cdp, sessionId, entries) {
  const serializedEntries = JSON.stringify(entries);
  await cdp.send("Runtime.evaluate", {
    expression: `
      (() => {
        for (const entry of ${serializedEntries}) {
          localStorage.setItem(entry.key, entry.value);
        }
        location.reload();
      })()
    `,
    awaitPromise: false,
  }, sessionId);
}

async function waitForLoad(cdp, sessionId) {
  const deadline = Date.now() + 15000;
  while (Date.now() < deadline) {
    const result = await cdp.send("Runtime.evaluate", {
      expression: "document.readyState",
      returnByValue: true,
    }, sessionId);
    if (result.result?.value === "complete") return;
    await sleep(100);
  }
  throw new Error("Timed out waiting for document.readyState=complete.");
}

async function waitForElement(cdp, sessionId, screenLabel) {
  const deadline = Date.now() + 15000;
  const escapedLabel = JSON.stringify(screenLabel);
  while (Date.now() < deadline) {
    const result = await cdp.send("Runtime.evaluate", {
      expression: `
        (() => {
          const el = Array.from(document.querySelectorAll('[data-screen-label]'))
            .find((candidate) => candidate.dataset.screenLabel === ${escapedLabel});
          if (!el) return false;
          const rect = el.getBoundingClientRect();
          const style = getComputedStyle(el);
          return rect.width > 300 && rect.height > 700 && style.display !== 'none';
        })()
      `,
      returnByValue: true,
    }, sessionId);
    if (result.result?.value === true) return;
    await sleep(120);
  }
  throw new Error(`Timed out waiting for data-screen-label ${screenLabel}.`);
}

async function elementClip(cdp, sessionId, screenLabel) {
  const escapedLabel = JSON.stringify(screenLabel);
  const result = await cdp.send("Runtime.evaluate", {
    expression: `
      (() => {
        const el = Array.from(document.querySelectorAll('[data-screen-label]'))
          .find((candidate) => candidate.dataset.screenLabel === ${escapedLabel});
        if (!el) return null;
        const rect = el.getBoundingClientRect();
        return {
          x: rect.x,
          y: rect.y,
          width: rect.width,
          height: rect.height,
          scale: 1,
        };
      })()
    `,
    returnByValue: true,
  }, sessionId);
  const clip = result.result?.value;
  if (!clip) throw new Error(`No element clip found for ${screenLabel}.`);
  return clip;
}

async function waitForChrome(port) {
  const deadline = Date.now() + 15000;
  while (Date.now() < deadline) {
    try {
      const response = await fetch(`http://127.0.0.1:${port}/json/version`);
      if (response.ok) return;
    } catch {
      // Retry until Chrome starts listening.
    }
    await sleep(100);
  }
  throw new Error(`Chrome did not start. stderr:\n${stderr}`);
}

async function browserWebSocketUrl(port) {
  const response = await fetch(`http://127.0.0.1:${port}/json/version`);
  if (!response.ok) {
    throw new Error(`Chrome DevTools version endpoint returned ${response.status}.`);
  }
  const json = await response.json();
  if (!json.webSocketDebuggerUrl) {
    throw new Error("Chrome DevTools response did not include webSocketDebuggerUrl.");
  }
  return json.webSocketDebuggerUrl;
}

function connectCdp(url) {
  const ws = new WebSocket(url);
  let nextId = 1;
  const pending = new Map();

  ws.addEventListener("message", (event) => {
    const message = JSON.parse(event.data);
    if (!message.id || !pending.has(message.id)) return;
    const {resolve, reject} = pending.get(message.id);
    pending.delete(message.id);
    if (message.error) reject(new Error(message.error.message));
    else resolve(message.result ?? {});
  });

  return new Promise((resolve, reject) => {
    ws.addEventListener("open", () => {
      resolve({
        send(method, params = {}, sessionId) {
          const id = nextId++;
          const payload = {id, method, params};
          if (sessionId) payload.sessionId = sessionId;
          ws.send(JSON.stringify(payload));
          return new Promise((innerResolve, innerReject) => {
            pending.set(id, {resolve: innerResolve, reject: innerReject});
          });
        },
        close() {
          ws.close();
        },
      });
    });
    ws.addEventListener("error", () => {
      reject(new Error(`Failed to connect to Chrome DevTools at ${url}`));
    });
  });
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function displayPath(filePath) {
  const relative = path.relative(repoRoot, filePath);
  return relative && !relative.startsWith("..") ? relative : filePath;
}

function printHelp() {
  console.log(`Usage: node tool/design/export_reference_screen.mjs --write --source <html> --label <data-screen-label> --out <png> [options]

Options:
  --source <html>       Local Claude/DC HTML handoff file.
  --label <label>       Exact data-screen-label value to capture.
  --out <png>           Output PNG path, relative to repo or absolute.
  --viewport <WxH>      Chrome viewport. Default: 1320x920.
  --clip <x,y,w,h>      Capture this viewport clip after the target appears.
  --wait-ms <ms>        Delay after the target appears. Default: 600.
  --local-storage <k=v> Set localStorage before capture. Repeatable.
  --chrome-path <path>  Override Chrome binary. CHROME_PATH is also supported.

The exporter captures the target element's bounding box directly, which avoids
manual crop coordinates for multi-panel Claude handoffs.`);
}
