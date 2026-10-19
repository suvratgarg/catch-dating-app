import assert from "node:assert/strict";
import fs from "node:fs";
import http from "node:http";
import {initializeApp} from "firebase-admin/app";
import {getFirestore, Timestamp} from "firebase-admin/firestore";
import {chromium} from "playwright";
import {organizerFixture} from "./organizerFixture.mjs";

// Writes are hard-bound to the task's isolated emulator; never a live project.
if (process.env.FIRESTORE_EMULATOR_HOST !== "127.0.0.1:8765") throw new Error("Isolated emulator required");
const origin = "http://127.0.0.1:3107";
const db = getFirestore(initializeApp({projectId: "demo-catch-nextjs"}, "next-runtime-acceptance"));
const organizer = organizerFixture();
organizer.publicPage.legacyPaths = ["/organizers/old-next-proof/"];
await db.doc("organizers/next-proof").set(organizer);
await db.doc("events/next-native-event").set({name: "Next proof event", organizerId: "next-proof", clubId: "next-proof",
  publicationState: "published", status: "active", eventFormat: {activityKind: "socialRun"},
  startTime: Timestamp.fromDate(new Date("2090-01-01T12:00:00Z")), endTime: Timestamp.fromDate(new Date("2090-01-01T14:00:00Z")),
  meetingLocation: {name: "Public park"}, currency: "INR", priceInPaise: 0, capacityLimit: 20, bookedCount: 2});
const external = JSON.parse(fs.readFileSync(new URL("../../../contracts/fixtures/valid/external_event_doc.json", import.meta.url), "utf8"));
external.canonicalHostId = external.compatibilityClubId = "next-proof";
await db.doc(`externalEvents/${external.eventId}`).set(external);
const results = [];
function customHostRequest(path) {
  return new Promise((resolve, reject) => {
    http.get(origin + path, {headers: {Host: "forms.client.example"}}, response => {
      let body = ""; response.setEncoding("utf8"); response.on("data", chunk => {body += chunk;});
      response.on("end", () => resolve({status: response.statusCode, headers: response.headers, body}));
    }).on("error", reject);
  });
}
async function check(path, status, needle) {
  const response = await fetch(origin + path, {redirect: "manual"});
  const text = await response.text();
  assert.equal(response.status, status, path);
  if (needle) assert(text.includes(needle), `${path} missing ${needle}`);
  if (status === 200 && path !== "/robots.txt" && !path.startsWith("/.well-known/")) assert.match(response.headers.get("cache-control"), /no-store/);
  results.push({path, status});
  return {response, text};
}
let browser;
try {
  for (const path of ["/", "/explore/", "/host/", "/host/apply/", "/privacy/", "/terms/", "/help/", "/organizers/"]) await check(path, 200, "<h1");
  await check("/", 200, "Next proof organizer");
  await check("/claim/", 200, "Next proof organizer");
  const listing = await check("/organizers/next-proof/", 200, "Next proof organizer");
  assert(listing.text.includes('application/ld+json'));
  await check("/events/next-native-event/", 200, "Next proof event");
  await check(`/events/${external.eventId}/`, 200, "Takeoff: Run + Rave");
  await check("/missing-route-proof/", 404);
  await check("/events/not-published/", 404);
  const alias = await check("/organizers/old-next-proof/?utm_source=proof", 301);
  assert.equal(alias.response.headers.get("location"), "/organizers/next-proof/?utm_source=proof");
  const retired = await check("/host/platform/?utm_source=proof", 301);
  assert.equal(retired.response.headers.get("location"), "/host/?utm_source=proof#features");
  for (const family of ["join", "booking", "event-update", "rehearse", "invite", "rsvp", "f", "demo"]) {
    const {response, text} = await check(`/${family}/private-proof-token/?grant=private-proof-grant`, 200);
    assert(!text.includes("private-proof-token") && !text.includes("private-proof-grant") && !text.includes("self.__next_f"));
    assert.match(response.headers.get("x-robots-tag"), /noindex/);
  }
  await check("/offer/?grant=private-proof-grant", 200);
  const association = await check("/.well-known/apple-app-site-association", 200);
  assert.match(association.response.headers.get("content-type"), /application\/json/);
  const custom = await customHostRequest("/organizers/next-proof/");
  const customBody = custom.body;
  assert(!customBody.includes("Next proof organizer") && !customBody.includes("self.__next_f"));
  assert.match(custom.headers["cache-control"], /no-store/);
  assert.equal((await customHostRequest("/api/public-catalog")).status, 404);
  browser = await chromium.launch({headless: true});
  const nojs = await browser.newContext({javaScriptEnabled: false, viewport: {width: 1440, height: 1000}});
  const nojsPage = await nojs.newPage();
  await nojsPage.goto(origin + "/organizers/next-proof/");
  assert.equal(await nojsPage.getByRole("heading", {level: 1}).innerText(), "Next proof organizer");
  assert(await nojsPage.getByRole("heading", {level: 1}).isVisible());
  await nojs.close();
  const context = await browser.newContext({viewport: {width: 1440, height: 1000}, permissions: ["clipboard-read", "clipboard-write"]});
  const page = await context.newPage(); const errors = [];
  page.on("pageerror", error => errors.push(error.message));
  await page.goto(origin + "/organizers/next-proof/");
  await page.getByRole("button", {name: "Essential only", exact: true}).click();
  await page.getByRole("button", {name: "Share", exact: true}).click();
  await page.getByText("Listing link copied.", {exact: true}).waitFor();
  await page.screenshot({path: "/tmp/catch-nextjs-organizer-desktop.png"});
  await page.setViewportSize({width: 390, height: 844});
  await page.screenshot({path: "/tmp/catch-nextjs-organizer-mobile.png"});
  await page.goto(origin + "/organizers/");
  const field = page.getByPlaceholder("Search clubs, venues, hosts…");
  await field.fill("no-matching-organizer-proof");
  await page.locator('a[href="/organizers/next-proof/"]').first().waitFor({state: "hidden"});
  assert(new URL(page.url()).searchParams.get("q")?.includes("no-matching"));
  await field.fill("Next proof");
  await page.locator('a[href="/organizers/next-proof/"]').first().waitFor({state: "visible"});
  await page.goto(origin + "/organizers/next-proof/");
  await db.doc("organizers/next-proof").update({"publicPage.publishStatus": "removed"});
  await check("/organizers/next-proof/", 404);
  await check("/events/next-native-event/", 404);
  const sitemap = await check("/sitemap.xml", 200);
  assert(!sitemap.text.includes("next-proof") && !sitemap.text.includes("next-native-event"));
  await page.evaluate(() => window.dispatchEvent(new Event("focus")));
  await page.getByRole("heading", {level: 1, name: "Next proof organizer", exact: true}).waitFor({state: "hidden"});
  await db.doc("organizers/next-proof").set({...organizer, publicPage: {...organizer.publicPage, indexStatus: "noindex", robots: "noindex, follow"}});
  const noindex = await check("/organizers/next-proof/", 200);
  assert(noindex.text.includes('content="noindex, follow"'));
  assert(!(await check("/sitemap.xml", 200)).text.includes("next-proof"));
  assert.deepEqual(errors, []);
  console.log(JSON.stringify({passed: true, http: results, browser: ["no-JS content", "desktop/mobile", "share", "directory filter", "live withdrawal", "no hydration errors"]}, null, 2));
} finally {
  await browser?.close();
  await db.doc("organizers/next-proof").set(organizer);
  await db.terminate();
}
