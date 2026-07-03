#!/usr/bin/env node
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import {spawn} from "node:child_process";
import {pathToFileURL} from "node:url";
import {fromRepo} from "../lib/repo_paths.mjs";

const chromePath =
  process.env.CHROME_PATH ??
  "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";
const sourcePath =
  "/Users/suvratgarg/Downloads/Catch Design System (2)/templates/catch-onboarding/OnboardingV2.dc.html";
const outputDir = fromRepo("design/reference_screens/screen.onboarding.flow");
const viewport = {width: 900, height: 940};
const clip = {x: 255, y: 37, width: 390, height: 812, scale: 1};
const references = [
  {id: "name_dob_step", step: 4, label: "04 Name + DOB"},
  {id: "gender_interest_step", step: 5, label: "05 Gender"},
  {id: "instagram_step", step: 6, label: "06 Instagram"},
  {id: "photos_count_met", step: 7, label: "07 Photos"},
  {id: "prompts_partial", step: 8, label: "08 Prompts"},
  {id: "running_prefs_step", step: 9, label: "09 Running prefs"},
];

const args = process.argv.slice(2);
const write = args.includes("--write");
const check = args.includes("--check");

if (args.includes("--help") || args.includes("-h")) {
  console.log(`Usage: node tool/design/export_onboarding_references.mjs [--check|--write]

Exports onboarding Claude reference PNGs for steps 4-9 into:
  design/reference_screens/screen.onboarding.flow/

--check validates the repo-owned generated PNG outputs without launching Chrome.
--write launches Chrome and regenerates the PNG outputs from the local handoff.

Set CHROME_PATH to override the Chrome binary.`);
  process.exit(0);
}

if (check) {
  validateConfig();
  validateOutputs();
  console.log("Onboarding reference exporter config ok.");
  process.exit(0);
}

if (!write) {
  console.error("Refusing to write references without --write. Use --check for validation.");
  process.exit(64);
}

if (!fs.existsSync(chromePath)) {
  console.error(`Chrome not found at ${chromePath}. Set CHROME_PATH.`);
  process.exit(1);
}
if (!fs.existsSync(sourcePath)) {
  console.error(`Onboarding source not found at ${sourcePath}.`);
  process.exit(1);
}
fs.mkdirSync(outputDir, {recursive: true});

const userDataDir = fs.mkdtempSync(
  path.join(os.tmpdir(), "catch-onboarding-ref-chrome-"),
);
const port = 9337;
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

  const sourceUrl = pathToFileURL(sourcePath).href;
  for (const ref of references) {
    await navigate(browser, sessionId, sourceUrl);
    await browser.send("Runtime.evaluate", {
      expression: `
        localStorage.setItem('onboarding_v2.tweaks', JSON.stringify({direction: 'run', welcome: 'dark'}));
        localStorage.setItem('onboarding_v2.step', '${ref.step}');
        location.reload();
      `,
      awaitPromise: false,
    }, sessionId);
    await waitForActiveScreen(browser, sessionId, ref.label);
    await sleep(600);

    const screenshot = await browser.send("Page.captureScreenshot", {
      format: "png",
      fromSurface: true,
      clip,
    }, sessionId);
    const outputPath = path.join(outputDir, `${ref.id}.png`);
    fs.writeFileSync(outputPath, Buffer.from(screenshot.data, "base64"));
    console.log(`Exported ${path.relative(fromRepo("."), outputPath)}`);
  }

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

function validateConfig() {
  const ids = new Set();
  const steps = new Set();
  for (const ref of references) {
    if (!ref.id || !ref.label || typeof ref.step !== "number") {
      throw new Error(`Invalid onboarding reference config: ${JSON.stringify(ref)}`);
    }
    if (ids.has(ref.id)) throw new Error(`Duplicate onboarding reference id: ${ref.id}`);
    if (steps.has(ref.step)) throw new Error(`Duplicate onboarding reference step: ${ref.step}`);
    ids.add(ref.id);
    steps.add(ref.step);
  }
}

function validateOutputs() {
  for (const ref of references) {
    const outputPath = path.join(outputDir, `${ref.id}.png`);
    if (!fs.existsSync(outputPath)) {
      throw new Error(`Missing onboarding reference output: ${path.relative(fromRepo("."), outputPath)}`);
    }
    const dimensions = pngDimensions(outputPath);
    if (dimensions.width !== clip.width || dimensions.height !== clip.height) {
      throw new Error(
        `Unexpected dimensions for ${path.relative(fromRepo("."), outputPath)}: ` +
          `${dimensions.width}x${dimensions.height}; expected ${clip.width}x${clip.height}`,
      );
    }
  }
}

function pngDimensions(filePath) {
  const buffer = fs.readFileSync(filePath);
  if (buffer.length < 24 || buffer.toString("ascii", 1, 4) !== "PNG") {
    throw new Error(`Not a PNG file: ${path.relative(fromRepo("."), filePath)}`);
  }
  return {
    width: buffer.readUInt32BE(16),
    height: buffer.readUInt32BE(20),
  };
}

async function waitForChrome(portToPoll) {
  const deadline = Date.now() + 15000;
  while (Date.now() < deadline) {
    try {
      const response = await fetch(`http://127.0.0.1:${portToPoll}/json/version`);
      if (response.ok) return;
    } catch (_) {
      // Retry until Chrome starts listening.
    }
    await sleep(150);
  }
  throw new Error(`Chrome did not start. stderr:\n${stderr}`);
}

async function browserWebSocketUrl(portToQuery) {
  const response = await fetch(`http://127.0.0.1:${portToQuery}/json/version`);
  if (!response.ok) {
    throw new Error(`DevTools version endpoint failed: ${response.status}`);
  }
  const data = await response.json();
  if (!data.webSocketDebuggerUrl) {
    throw new Error("Missing browser webSocketDebuggerUrl.");
  }
  return data.webSocketDebuggerUrl;
}

async function navigate(cdp, sessionId, url) {
  await cdp.send("Page.navigate", {url}, sessionId);
  await waitForLoad(cdp, sessionId);
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

async function waitForActiveScreen(cdp, sessionId, label) {
  const deadline = Date.now() + 15000;
  const escapedLabel = JSON.stringify(label);
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
  throw new Error(`Timed out waiting for active onboarding screen ${label}.`);
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
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
          return new Promise((sendResolve, sendReject) => {
            pending.set(id, {resolve: sendResolve, reject: sendReject});
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
