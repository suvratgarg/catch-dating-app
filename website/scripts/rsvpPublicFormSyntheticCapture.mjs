import {existsSync, readFileSync, lstatSync, readdirSync, realpathSync} from "node:fs";
import {mkdtemp, writeFile, mkdir, rename, rm} from "node:fs/promises";
import {tmpdir} from "node:os";
import path from "node:path";
import {fileURLToPath, pathToFileURL} from "node:url";
import {execFileSync} from "node:child_process";
import {createHash} from "node:crypto";
import {createRequire} from "node:module";

// RSVP_SOURCE_REPO=/path/to/repo RSVP_SOURCE_SHA=<full-commit-sha>
// RSVP_CAPTURE_OUTPUT=/absolute/new/output npm --workspace catch-marketing run capture:rsvp
// Optional RSVP_CAPTURE_SCENARIOS is a comma-separated subset of scenario names.
// Only committed source is captured. A temporary Git archive has its own locked
// dependencies, installed OFFLINE from npm's cache (bootstrap the checkout first).
// The browser cannot access external services. These are synthetic visual
// fixtures, not submission, payment, verification, or release evidence.
const runnerPath = fileURLToPath(import.meta.url);
const repo = path.resolve(path.dirname(runnerPath), "../..");
const snapshotPaths = ["package.json", "package-lock.json", "admin/package.json", "website", "packages", "functions/src/shared"];
export const scenarioNames = Object.freeze([
  "audience-form-desktop", "purpose-review-desktop", "purpose-review-mobile",
  "payment-test-mobile", "embedded-purpose-mobile",
]);

export function selectScenarios(value) {
  if (value === undefined) return [...scenarioNames];
  const names = value.split(",").map((name) => name.trim());
  if (!names.length || names.some((name) => !scenarioNames.includes(name)) ||
      new Set(names).size !== names.length) {
    throw new Error(`Select unique known scenarios: ${scenarioNames.join(", ")}`);
  }
  return names;
}

export function validateOutput(output, sourceRepo) {
  if (!output || !path.isAbsolute(output)) throw new Error("RSVP_CAPTURE_OUTPUT must be an absolute new directory");
  if (existsSync(output)) throw new Error("Capture output already exists; choose a new directory to preserve its evidence");
  for (const checkout of new Set([repo, path.resolve(sourceRepo)])) {
    const relative = path.relative(checkout, output);
    if (relative && !relative.startsWith(`..${path.sep}`) && relative !== ".." && !path.isAbsolute(relative)) {
      try {
        execFileSync("git", ["check-ignore", "--no-index", "-q", "--", `${relative}/`], {cwd: checkout});
      } catch {
        throw new Error("Capture output inside a checkout must be Git-ignored");
      }
    }
  }
}

export function assertNoSymlinks(directory) {
  for (const entry of readdirSync(directory)) {
    const item = path.join(directory, entry);
    const stat = lstatSync(item);
    if (stat.isSymbolicLink()) throw new Error(`Pinned source contains a symlink: ${path.relative(directory, item)}`);
    if (stat.isDirectory()) assertNoSymlinks(item);
  }
}

export function extractSnapshot(sourceRepo, sourceSha, destination, archivePath) {
  if (!/^[a-f0-9]{40}$/.test(sourceSha ?? "")) throw new Error("RSVP_SOURCE_SHA must be a full commit SHA");
  const resolved = execFileSync("git", ["rev-parse", "--verify", `${sourceSha}^{commit}`], {cwd: sourceRepo, encoding: "utf8"}).trim();
  if (resolved !== sourceSha) throw new Error("RSVP_SOURCE_SHA is not the requested commit");
  execFileSync("git", ["archive", "--format=tar", `--output=${archivePath}`, sourceSha, ...snapshotPaths], {cwd: sourceRepo});
  execFileSync("tar", ["-xf", archivePath, "-C", destination]);
  assertNoSymlinks(destination);
  return {sourceSha, sourceTree: execFileSync("git", ["rev-parse", `${sourceSha}^{tree}`], {cwd: sourceRepo, encoding: "utf8"}).trim(),
    packageLockSha256: digest(readFileSync(path.join(destination, "package-lock.json")))};
}

const digest = (bytes) => createHash("sha256").update(bytes).digest("hex");

export async function publishCaptures(staging, output, manifest) {
  // No existing directory may be replaced; successful runs publish together.
  if (existsSync(output)) throw new Error("Capture output appeared during capture; refusing to replace it");
  await writeFile(path.join(staging, "manifest.json"), `${JSON.stringify(manifest, null, 2)}\n`);
  await rename(staging, output);
}

async function run(env = process.env) {
  const sourceRepo = env.RSVP_SOURCE_REPO;
  if (!sourceRepo) throw new Error("Set RSVP_SOURCE_REPO");
  const selected = selectScenarios(env.RSVP_CAPTURE_SCENARIOS);
  const output = env.RSVP_CAPTURE_OUTPUT;
  validateOutput(output, sourceRepo);
  const scratch = realpathSync(await mkdtemp(path.join(tmpdir(), "catch-rsvp-capture-")));
  let staging;
  let server;
  let browser;
  try {
    const snapshot = path.join(scratch, "source");
    await mkdir(snapshot);
    const provenance = extractSnapshot(sourceRepo, env.RSVP_SOURCE_SHA, snapshot, path.join(scratch, "source.tar"));
    // This snapshot owns its dependencies. Never resolve modules from another
    // checkout or link its node_modules into the captured renderer.
    execFileSync("npm", ["ci", "--offline", "--ignore-scripts", "--no-audit", "--no-fund"], {cwd: snapshot, stdio: "inherit"});
    const require = createRequire(path.join(snapshot, "website/package.json"));
    const {createServer} = await import(pathToFileURL(require.resolve("vite")).href);
    const {chromium} = require("playwright");
    const website = path.join(snapshot, "website");
    const pageSource = path.join(website, "src/features/forms/PublicFormPage.tsx");
    const controllerSource = path.join(website, "src/features/forms/usePublicFormController.ts");
    const fixtureRoot = path.join(snapshot, ".rsvp-capture");
    await mkdir(fixtureRoot);
    const mock = path.join(fixtureRoot, "controller.ts");
    const entry = path.join(fixtureRoot, "entry.tsx");
    const html = `<!doctype html><html><head><meta name="viewport" content="width=device-width,initial-scale=1"></head><body><div id="root"></div><script type="module" src="/@fs${entry}"></script></body></html>`;
    const wrapper = `<!doctype html><html><head><meta name="viewport" content="width=device-width,initial-scale=1"><style>body{margin:0;padding:24px;background:#f5f1eb;font:16px sans-serif}main{max-width:760px;margin:auto}iframe{display:block;width:100%;height:500px;border:0;border-radius:12px;background:white}</style></head><body><main><p>LOCAL SYNTHETIC EMBED PREVIEW</p><h1>Saket Run Club application</h1><p>Fixture host page; no applicant or payment service is connected.</p><iframe title="Saket Run Club RSVP" src="/__rsvp_evidence?embed=1&embedId=fixture_1"></iframe><script src="/form-embed-resize.js"></script></main></body></html>`;
    await writeFile(mock, `const noop = () => {}; export function usePublicFormController() { return {...window.__rsvpController, updateAnswer: noop, blurQuestion: noop, uploadAnswer: noop, nextSection: noop, previousSection: noop, updateConsent: noop, updateMessagingChoice: noop, setSectionIndex: noop, setStage: noop, submit: noop}; }\n`);
    await writeFile(entry, `import React from "react";\nimport {createRoot} from "react-dom/client";\nimport {MemoryRouter} from "react-router";\nimport ${JSON.stringify(path.join(website, "src/styles.css"))};\nimport {PublicFormPage} from ${JSON.stringify(pageSource)};\ncreateRoot(document.getElementById("root")).render(<MemoryRouter><PublicFormPage /></MemoryRouter>);\n`);
    server = await createServer({
      configFile: false, root: website,
      plugins: [{name: "rsvp-evidence-controller", enforce: "pre", resolveId(source, importer) {
        if (source === "./usePublicFormController" && importer === pageSource) return mock;
      }}, {name: "rsvp-evidence-html", configureServer(vite) {
        vite.middlewares.use(async (req, res, next) => {
          if (req.url?.startsWith("/__rsvp_wrapper")) {
            res.setHeader("content-type", "text/html"); res.end(wrapper); return;
          }
          if (!req.url?.startsWith("/__rsvp_evidence")) return next();
          try {
            res.setHeader("content-type", "text/html"); res.end(await vite.transformIndexHtml(req.url, html));
          } catch (error) { next(error); }
        });
      }}],
      resolve: {alias: [{find: controllerSource, replacement: mock}, {find: "@content", replacement: path.join(website, "src/content")}]},
      optimizeDeps: {entries: [entry], include: ["react", "react-dom/client", "react-router"]},
      server: {host: "127.0.0.1", port: 0, fs: {allow: [snapshot]}},
    });
    await server.listen();
    const port = server.httpServer.address().port;
    const origin = `http://127.0.0.1:${port}`;
    browser = await chromium.launch({headless: true});
    await mkdir(path.dirname(output), {recursive: true});
    staging = await mkdtemp(path.join(path.dirname(output), ".rsvp-capture-"));
    const fixture = {
      organizer: {name: "Saket Run Club"},
      messagingOffer: {termsVersion: "form-whatsapp-v2", organizerOperationsWhatsapp: "Application updates", organizerMarketingWhatsapp: "Organizer future events", catchMarketingWhatsapp: "Catch future experiences"},
      definition: {title: "Saket Run Club RSVP", description: "A synthetic customer preview of the RSVP flow.", appearance: {preset: "editorial"}, sections: [], consent: {retentionCopy: "Kept until you withdraw.", consentCopy: "Share my answers with Saket Run Club"}, payment: {amountPaise: 20000, description: "Event fee", refundPolicy: "Refunded if cancelled"}},
    };
    const noop = null; // Functions are supplied inside the browser, not serialized.
    const base = {form: fixture, answers: {}, errors: {}, uploads: {}, visibleSections: [], sectionIndex: 0, consentAccepted: false, messagingChoices: {organizerOperationsWhatsapp: false, organizerMarketingWhatsapp: false, catchMarketingWhatsapp: false}, messagingEndpointAvailable: true, status: {message: "", tone: ""}, pending: false, updateConsent: noop, updateMessagingChoice: noop, setSectionIndex: noop, setStage: noop, submit: noop};
    const audienceSection = {sectionId: "audience", title: "Your running profile", description: "Choose what belongs in each destination.", questions: [
      {questionId: "pace", kind: "singleChoice", label: "Comfortable pace", required: false, answerDestination: "catchProfile", options: [{optionId: "relaxed", label: "Relaxed", value: "Relaxed"}, {optionId: "brisk", label: "Brisk", value: "Brisk"}], validation: {}},
      {questionId: "note", kind: "longText", label: "Note for this organizer", required: false, answerDestination: "organizerCard", options: [], validation: {maxLength: 250}},
    ]};
    const review = {...base, form: {...fixture, definition: {...fixture.definition,
      sections: [audienceSection]}}, visibleSections: [audienceSection],
    answers: {pace: "Relaxed", note: "I enjoy easy social runs."}};
    const scenarios = [
      {name: "audience-form-desktop", state: {...base, stage: "form", embed: false, form: {...fixture, definition: {...fixture.definition, sections: [audienceSection]}}, activeSection: audienceSection, visibleSections: [audienceSection], answers: {pace: "Relaxed", note: "I enjoy easy social runs."}, updateAnswer: noop, uploadAnswer: noop, nextSection: noop}, width: 1280, height: 900},
      {name: "purpose-review-desktop", state: {...review, stage: "review", embed: false}, width: 1280, height: 900},
      {name: "purpose-review-mobile", state: {...review, stage: "review", embed: false}, width: 390, height: 844},
      {name: "payment-test-mobile", state: {...base, stage: "payment", embed: false, payments: {payment: {status: "pending", amountPaise: 20000, refundPolicy: "Refunded if cancelled", mode: "test", checkout: null}, pending: false, status: {message: "", tone: ""}, refresh: noop, pay: noop}}, width: 390, height: 844},
      {name: "embedded-purpose-mobile", state: {...review, stage: "review", embed: true}, width: 390, height: 844, wrapper: true},
    ];

    const completed = [];
    for (const name of selected) {
      const scenario = scenarios.find((candidate) => candidate.name === name);
      const context = await browser.newContext({viewport: {width: scenario.width, height: scenario.height}, deviceScaleFactor: 1, serviceWorkers: "block"});
      context.setDefaultTimeout(15000);
      const errors = [];
      const blockedRequests = [];
      try {
        await context.route("**/*", (route) => {
          if (new URL(route.request().url()).origin === origin) return route.continue();
          blockedRequests.push(route.request().url()); return route.abort();
        });
        await context.routeWebSocket("**/*", (socket) => socket.close());
        await context.addInitScript((state) => {window.__rsvpController = state;}, scenario.state);
        const page = await context.newPage();
        page.on("pageerror", (error) => errors.push(error.message));
        await page.goto(`${origin}/${scenario.wrapper ? "__rsvp_wrapper" : "__rsvp_evidence"}?state=${scenario.name}`);
        const rendered = scenario.wrapper ? page.frameLocator("iframe") : page;
        await rendered.locator(".public-form").waitFor();
        if (scenario.wrapper) await page.waitForFunction(() => Number.parseInt(document.querySelector("iframe").style.height, 10) > 500);
        if (scenario.name.startsWith("purpose") || scenario.wrapper) {
          for (const label of ["Application updates", "Organizer future events", "Catch future experiences"]) {
            if (await rendered.getByRole("checkbox", {name: label}).isChecked()) throw new Error(`${scenario.name}: ${label} was preselected`);
          }
          await rendered.getByText("₹200").waitFor();
          await rendered.getByText("I enjoy easy social runs.", {exact: true}).waitFor();
        }
        if (scenario.name.startsWith("audience")) {
          await rendered.getByText(/Catch profile field/).waitFor();
          await rendered.getByText(/Organizer card field/).waitFor();
        }
        if (scenario.name.startsWith("payment")) await rendered.getByText(/Test checkout/).waitFor();
        await page.evaluate(async () => {await document.fonts.ready;});
        if (scenario.wrapper) await page.frames()[1].evaluate(async () => {await document.fonts.ready;});
        const filename = `${scenario.name}.png`;
        const bytes = await page.screenshot({path: path.join(staging, filename), fullPage: true, animations: "disabled"});
        if (errors.length || blockedRequests.length) throw new Error(`${scenario.name}: ${[...errors, ...blockedRequests.map((url) => `Blocked external request: ${url}`)].join("; ")}`);
        completed.push({name: scenario.name, width: scenario.width, height: scenario.height, file: filename, sha256: digest(bytes)});
      } finally { await context.close(); }
    }
    await publishCaptures(staging, output, {
      kind: "synthetic-browser-fixture", ...provenance,
      sourcePath: "website/src/features/forms/PublicFormPage.tsx", sourcePaths: snapshotPaths,
      runnerSha256: digest(readFileSync(runnerPath)), browser: browser.version(),
      fixture: "Immutable committed React page and embed installer with mocked controller; no API, applicant, or payment provider. Visual evidence only, not end-to-end submission or release proof.",
      scenarios: completed,
    });
    console.log(output);
  } finally {
    try {
      await Promise.all([browser?.close(), server?.close()]);
    } finally {
      if (staging) await rm(staging, {recursive: true, force: true});
      await rm(scratch, {recursive: true, force: true});
    }
  }
}

if (process.argv[1] && path.resolve(process.argv[1]) === runnerPath) {
  run().catch((error) => {console.error(error); process.exitCode = 1;});
}
