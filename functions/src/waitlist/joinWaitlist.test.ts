import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import test from "node:test";
import * as admin from "firebase-admin";
import {
  joinWaitlist,
  normalizeHostApplication,
  normalizeMarketingAnalytics,
  normalizeMarketingAttribution,
  normalizeWaitlistRole,
  resolveWaitlistCorsOrigin,
  waitlistAllowedOrigins,
} from "./joinWaitlist";
import {
  validateJoinWaitlistHTTPRequest,
  validateJoinWaitlistHTTPResponse,
} from "../shared/generated/schemaValidators";

const contractRoot = fs.existsSync(path.resolve(process.cwd(), "contracts")) ?
  path.resolve(process.cwd(), "contracts") :
  path.resolve(process.cwd(), "..", "contracts");

function readFixture(relativePath: string): unknown {
  return JSON.parse(
    fs.readFileSync(path.resolve(contractRoot, relativePath), "utf8")
  );
}

test(
  "join waitlist schemas cover member, host, and runner compatibility",
  () => {
    for (const fixture of [
      "fixtures/valid/join_waitlist_request_member.json",
      "fixtures/valid/join_waitlist_request_host.json",
      "fixtures/valid/join_waitlist_request_runner_compatibility.json",
    ]) {
      assert.equal(validateJoinWaitlistHTTPRequest(readFixture(fixture)), true);
    }
    assert.equal(
      validateJoinWaitlistHTTPRequest(
        readFixture("fixtures/invalid/join_waitlist_request_missing_city.json")
      ),
      false
    );
  }
);

test("join waitlist response schema distinguishes success and errors", () => {
  assert.equal(
    validateJoinWaitlistHTTPResponse(
      readFixture("fixtures/valid/join_waitlist_response_success.json")
    ),
    true
  );
  assert.equal(
    validateJoinWaitlistHTTPResponse(
      readFixture("fixtures/valid/join_waitlist_response_error.json")
    ),
    true
  );
  assert.equal(
    validateJoinWaitlistHTTPResponse(
      readFixture("fixtures/invalid/join_waitlist_response_missing_ok.json")
    ),
    false
  );
});

test("waitlistAllowedOrigins includes production custom domains", () => {
  const origins = waitlistAllowedOrigins("catch-dating-app-64e51");

  assert.equal(origins.has("https://catchdates.com"), true);
  assert.equal(origins.has("https://www.catchdates.com"), true);
  assert.equal(origins.has("http://127.0.0.1:5175"), true);
  assert.equal(origins.has("http://127.0.0.1:4187"), true);
  assert.equal(
    origins.has("https://catch-dating-app-64e51.web.app"),
    true
  );
});

test("waitlistAllowedOrigins scopes non-prod projects", () => {
  const origins = waitlistAllowedOrigins("catchdates-dev");

  assert.equal(origins.has("https://catchdates-dev.web.app"), true);
  assert.equal(origins.has("https://catchdates-dev.firebaseapp.com"), true);
  assert.equal(origins.has("https://catchdates.com"), false);
});

test("resolveWaitlistCorsOrigin rejects unknown origins", () => {
  assert.equal(
    resolveWaitlistCorsOrigin(
      "https://attacker.example",
      "catch-dating-app-64e51"
    ),
    null
  );
});

test("normalizeWaitlistRole maps legacy runner to member", () => {
  assert.equal(normalizeWaitlistRole("runner"), "member");
  assert.equal(normalizeWaitlistRole("member"), "member");
  assert.equal(normalizeWaitlistRole("host"), "host");
});

test("normalizeMarketingAttribution keeps known campaign fields", () => {
  const attribution = normalizeMarketingAttribution({
    firstTouch: {
      capturedAt: "2026-06-02T00:00:00.000Z",
      landingPath: "/?utm_source=meta&utm_campaign=mumbai",
      landingUrl: "https://catchdates.com/?utm_source=meta",
      referrer: "https://instagram.com/",
      values: {
        fbclid: "fb-1",
        ignored: "drop-me",
        utm_campaign: "mumbai_hosts",
        utm_source: "meta",
      },
    },
    lastTouch: {
      values: {
        gclid: "google-click",
      },
    },
  });

  assert.deepEqual(attribution, {
    firstTouch: {
      capturedAt: "2026-06-02T00:00:00.000Z",
      landingPath: "/?utm_source=meta&utm_campaign=mumbai",
      landingUrl: "https://catchdates.com/?utm_source=meta",
      referrer: "https://instagram.com/",
      values: {
        fbclid: "fb-1",
        utm_campaign: "mumbai_hosts",
        utm_source: "meta",
      },
    },
    lastTouch: {
      capturedAt: null,
      landingPath: null,
      landingUrl: null,
      referrer: null,
      values: {
        gclid: "google-click",
      },
    },
  });
});

test("normalizeMarketingAnalytics keeps consent and event metadata", () => {
  assert.deepEqual(
    normalizeMarketingAnalytics({
      consent: {
        analytics: true,
        choice: "accepted",
        marketing: true,
        updatedAt: "2026-06-02T00:00:00.000Z",
      },
      eventId: "waitlist_123",
      formVariant: "member",
      pagePath: "/?utm_source=meta",
      pageTitle: "Catch",
      submittedAt: "2026-06-02T00:01:00.000Z",
    }),
    {
      consent: {
        analytics: true,
        choice: "accepted",
        marketing: true,
        updatedAt: "2026-06-02T00:00:00.000Z",
      },
      eventId: "waitlist_123",
      formVariant: "member",
      pagePath: "/?utm_source=meta",
      pageTitle: "Catch",
      submittedAt: "2026-06-02T00:01:00.000Z",
    }
  );
});

test("normalizeHostApplication keeps bounded operating fields", () => {
  assert.deepEqual(
    normalizeHostApplication({
      organizationName: "  Sunday Table  ",
      organizationType: "Venue",
      operatingCity: "Mumbai",
      communityLink: "https://example.com/events",
      formats: ["Dinner", "Dinner", "Singles mixer"],
      eventCadence: "Monthly",
      nextEventName: "Long table no. 1",
      nextEventDate: "2026-06-21",
      eventLocation: "Bandra",
      expectedCapacity: "24",
      bookingPlatform: "Luma",
      guestListFormat: "CSV",
      priceRange: "₹1,000–₹2,000",
      admissionModel: "Request to join",
      waitlistPlan: "Ranked timed offers",
      paymentReadiness: "Need Catch payment onboarding",
      eventSuccessModules: [
        "Attendance and live roster",
        "Private catch window",
      ],
      hostGoals: "Improve review quality",
      operatingNotes: "Need help with arrival flow",
      ignored: "drop me",
    }),
    {
      organizationName: "Sunday Table",
      organizationType: "Venue",
      operatingCity: "Mumbai",
      communityLink: "https://example.com/events",
      formats: ["Dinner", "Singles mixer"],
      eventCadence: "Monthly",
      nextEventName: "Long table no. 1",
      nextEventDate: "2026-06-21",
      eventLocation: "Bandra",
      expectedCapacity: "24",
      bookingPlatform: "Luma",
      guestListFormat: "CSV",
      priceRange: "₹1,000–₹2,000",
      admissionModel: "Request to join",
      waitlistPlan: "Ranked timed offers",
      paymentReadiness: "Need Catch payment onboarding",
      eventSuccessModules: [
        "Attendance and live roster",
        "Private catch window",
      ],
      hostGoals: "Improve review quality",
      operatingNotes: "Need help with arrival flow",
    }
  );
});

test("normalizeHostApplication drops empty payloads", () => {
  assert.equal(normalizeHostApplication({formats: []}), null);
  assert.equal(normalizeHostApplication(null), null);
});


test("host intents preserve changes and exact retries", async (context) => {
  if (!admin.apps.length) admin.initializeApp({projectId: "demo-sales-intent"});
  const database = admin.firestore();
  const records = new Map<string, Record<string, unknown>>();
  let committedWrites = 0;
  type TransactionRunner = (tx: unknown) => Promise<unknown>;
  context.mock.method(database,
    "runTransaction",
    async (run: TransactionRunner) => {
      const writes: Array<{path: string; value: Record<string, unknown>}> = [];
      const tx = {
        get: async (ref: {path: string}) => ({
          exists: records.has(ref.path), data: () => records.get(ref.path),
        }),
        create: (ref: {path: string}, value: Record<string, unknown>) => {
          assert.equal(records.has(ref.path), false);
          writes.push({path: ref.path, value});
        },
        update: (ref: {path: string}, value: Record<string, unknown>) => {
          assert.equal(records.has(ref.path), true);
          writes.push({path: ref.path,
            value: {...records.get(ref.path),
              ...value}});
        },
        set: (ref: {path: string}, value: Record<string, unknown>) => {
          writes.push({path: ref.path, value});
        },
      };
      await run(tx);
      for (const write of writes) records.set(write.path, write.value);
      committedWrites += writes.length;
    });
  const body = readFixture("fixtures/valid/join_waitlist_request_host.json") as
    Record<string, unknown>;
  body.email = "synthetic-intent@example.test";
  const analytics = body.analytics as Record<string, unknown>;
  let attempt = 0;
  const submit = async (payload: unknown) => {
    let status = 0;
    let result: unknown;
    const response = {
      set: () => undefined,
      status: (value: number) => {
        status = value; return response;
      },
      json: (value: unknown) => {
        result = value; return response;
      },
      send: () => undefined,
    };
    await joinWaitlist({method: "POST",
      body: payload,
      ip: `synthetic-intent-test-${++attempt}`,
      get: () => undefined} as never, response as never);
    return {status, result};
  };
  const first = await submit(body);
  assert.deepEqual(
    first, {status: 200, result: {ok: true, alreadyJoined: false}});
  const count = committedWrites;
  assert.deepEqual(await submit(body), first);
  assert.equal(committedWrites, count);
  const changed = {...body, city: "Different City"};
  assert.equal((await submit(changed)).status, 409);
  assert.equal(committedWrites, count);
  const next = {...changed,
    analytics: {...analytics,
      eventId: "distinct-submission"}};
  assert.deepEqual(
    await submit(next), {status: 200, result: {ok: true, alreadyJoined: true}});
  assert.equal(
    [...records.keys()].filter(
      (key) => key.startsWith("salesInboundIntents/")).length,
    2);
  assert.equal(
    [...records.keys()].filter(
      (key) => key.startsWith("launchWaitlist/")).length,
    1);
  assert.equal(
    [...records.keys()].some((key) => key.startsWith("organizers/")), false);
  const captured =
    [...records.values()].filter(
      (row) => row.classification === "sales_private");
  assert.deepEqual(
    captured.map((row) => row.city), [body.city, "Different City"]);
});
