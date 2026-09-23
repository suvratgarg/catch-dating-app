import {existsSync} from "node:fs";
import {mkdtemp, writeFile, mkdir, symlink} from "node:fs/promises";
import {tmpdir} from "node:os";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {execFileSync} from "node:child_process";
import {createServer} from "vite";
import {chromium} from "playwright";

// Example: RSVP_SOURCE_REPO=/path/to/pinned-checkout RSVP_SOURCE_SHA=<full-sha>
// RSVP_CAPTURE_OUTPUT=/path/to/ignored-output node website/scripts/rsvpPublicFormSyntheticCapture.mjs
const here = path.dirname(fileURLToPath(import.meta.url));
const repo = path.resolve(here, "../..");
const sharedRoot = existsSync(path.join(repo, "node_modules/react")) ? repo :
  path.resolve(repo, "../../..");
if (!existsSync(path.join(sharedRoot, "node_modules/react"))) {
  throw new Error("Install workspace dependencies before capture");
}
const sourceRepo = process.env.RSVP_SOURCE_REPO;
const output = process.env.RSVP_CAPTURE_OUTPUT;
if (!sourceRepo || !output) throw new Error("Set RSVP_SOURCE_REPO and RSVP_CAPTURE_OUTPUT");
const website = path.join(sourceRepo, "website");
const pageSource = path.join(website, "src/features/forms/PublicFormPage.tsx");
const controllerSource = path.join(website, "src/features/forms/usePublicFormController.ts");
const sourceSha = execFileSync("git", ["rev-parse", "HEAD"], {cwd: sourceRepo, encoding: "utf8"}).trim();
if (sourceSha !== process.env.RSVP_SOURCE_SHA) throw new Error(`Source changed: ${sourceSha}`);
const sourceDirty = execFileSync("git", ["status", "--porcelain", "--", "website/src/features/forms/PublicFormPage.tsx", "website/public/form-embed-resize.js", "website/src/styles.css", "website/src/styles/public-forms.css"], {cwd: sourceRepo, encoding: "utf8"}).trim();
if (sourceDirty) throw new Error(`Pinned renderer has uncommitted edits: ${sourceDirty}`);
const scratch = await mkdtemp(path.join(tmpdir(), "catch-rsvp-capture-"));
const mock = path.join(scratch, "controller.ts");
const entry = path.join(scratch, "entry.tsx");
await symlink(path.join(sharedRoot, "node_modules"), path.join(scratch, "node_modules"));
const html = `<!doctype html><html><head><meta name="viewport" content="width=device-width,initial-scale=1"></head><body><div id="root"></div><script type="module" src="/@fs${entry}"></script></body></html>`;
const wrapper = `<!doctype html><html><head><meta name="viewport" content="width=device-width,initial-scale=1"><style>body{margin:0;padding:24px;background:#f5f1eb;font:16px sans-serif}main{max-width:760px;margin:auto}iframe{display:block;width:100%;height:500px;border:0;border-radius:12px;background:white}</style></head><body><main><p>LOCAL SYNTHETIC EMBED PREVIEW</p><h1>Saket Run Club application</h1><p>Fixture host page; no applicant or payment service is connected.</p><iframe title="Saket Run Club RSVP" src="/__rsvp_evidence?embed=1&embedId=fixture_1"></iframe><script src="/form-embed-resize.js"></script></main></body></html>`;
await writeFile(mock, `export function usePublicFormController() { return window.__rsvpController; }\n`);
await writeFile(entry, `import React from "react";\nimport {createRoot} from "react-dom/client";\nimport {MemoryRouter} from "react-router";\nimport "${path.join(website, "src/styles.css")}";\nimport {PublicFormPage} from "${pageSource}";\ncreateRoot(document.getElementById("root")).render(<MemoryRouter><PublicFormPage /></MemoryRouter>);\n`);
const server = await createServer({
  configFile: false,
  root: website,
  plugins: [{name: "rsvp-evidence-controller", enforce: "pre", resolveId(source, importer) {
    if (source === "./usePublicFormController" && importer?.includes("/features/forms/PublicFormPage.tsx")) return mock;
  }}, {name: "rsvp-evidence-html", configureServer(vite) {
    vite.middlewares.use(async (req, res, next) => {
      if (req.url?.startsWith("/__rsvp_wrapper")) {
        res.setHeader("content-type", "text/html");
        res.end(wrapper);
        return;
      }
      if (!req.url?.startsWith("/__rsvp_evidence")) return next();
      res.setHeader("content-type", "text/html");
      res.end(await vite.transformIndexHtml(req.url, html));
    });
  }}],
  resolve: {alias: [{find: controllerSource, replacement: mock}]},
  optimizeDeps: {entries: [entry], include: ["react", "react-dom/client", "react-router"]},
  server: {host: "127.0.0.1", port: 0, fs: {allow: [repo, sourceRepo, scratch, sharedRoot]}},
});
await server.listen();
const port = server.httpServer.address().port;
const browser = await chromium.launch({headless: true});
await mkdir(output, {recursive: true});
const fixture = {
  organizer: {name: "Saket Run Club"},
  messagingOffer: {termsVersion: "form-whatsapp-v2", organizerOperationsWhatsapp: "Application updates", organizerMarketingWhatsapp: "Organizer future events", catchMarketingWhatsapp: "Catch future experiences"},
  definition: {title: "Saket Run Club RSVP", description: "A synthetic customer preview of the RSVP flow.", appearance: {preset: "editorial"}, sections: [], consent: {retentionCopy: "Kept until you withdraw.", consentCopy: "Share my answers with Saket Run Club"}, payment: {amountPaise: 20000, description: "Event fee", refundPolicy: "Refunded if cancelled"}},
};
const noop = () => {};
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
const selected = process.env.RSVP_CAPTURE_SCENARIOS?.split(",") ?? null;
try {
  for (const scenario of scenarios) {
    if (selected && !selected.includes(scenario.name)) continue;
    const context = await browser.newContext({viewport: {width: scenario.width, height: scenario.height}, deviceScaleFactor: 1});
    await context.route("**/*", (route) => route.request().url().startsWith(`http://127.0.0.1:${port}/`) ? route.continue() : route.abort());
    await context.addInitScript((state) => {window.__rsvpController = state;}, scenario.state);
    const page = await context.newPage();
    const errors = [];
    page.on("pageerror", (error) => errors.push(error.message));
    await page.goto(`http://127.0.0.1:${port}/${scenario.wrapper ? "__rsvp_wrapper" : "__rsvp_evidence"}?state=${scenario.name}`);
    const rendered = scenario.wrapper ? page.frameLocator("iframe") : page;
    await rendered.locator(".public-form").waitFor();
    if (scenario.wrapper) await page.waitForFunction(() => Number.parseInt(document.querySelector("iframe").style.height, 10) > 500);
    if (scenario.name.startsWith("purpose") || scenario.wrapper) {
      for (const label of ["Application updates", "Organizer future events", "Catch future experiences"]) {
        const checkbox = rendered.getByRole("checkbox", {name: label});
        if (await checkbox.isChecked()) throw new Error(`${scenario.name}: ${label} was preselected`);
      }
      await rendered.getByText("₹200").waitFor();
    }
    if (scenario.name.startsWith("audience")) {
      await rendered.getByText(/Catch profile field/).waitFor();
      await rendered.getByText(/Organizer card field/).waitFor();
    }
    if (scenario.name.startsWith("payment")) await rendered.getByText(/Test checkout/).waitFor();
    await page.screenshot({path: path.join(output, `${scenario.name}.png`), fullPage: true});
    if (errors.length) throw new Error(`${scenario.name}: ${errors.join("; ")}`);
    await context.close();
  }
  if (!selected) await writeFile(path.join(output, "manifest.json"), JSON.stringify({kind: "synthetic-browser-fixture", sourceSha, sourcePath: pageSource, fixture: "Actual pinned React page and embed installer with mocked controller; no API, applicant, or payment provider. Captures are visual evidence, not end-to-end submission proof.", scenarios: scenarios.map(({name, width, height}) => ({name, width, height}))}, null, 2));
} finally {
  await browser.close();
  await server.close();
}
console.log(output);
