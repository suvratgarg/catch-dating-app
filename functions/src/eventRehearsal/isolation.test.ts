import assert from "node:assert/strict";
import {readFileSync} from "node:fs";
import {resolve} from "node:path";
import test from "node:test";

const forbiddenLiveCollections = [
  "eventAttendees",
  "eventParticipations",
  "payments",
  "organizerContacts",
  "notifications",
  "matches",
  "chats",
  "eventSuccessPlans",
  "users",
  "profiles",
] as const;

test("rehearsal backend contains no live-domain collection seam", () => {
  const source = ["engine.ts", "handlers.ts"].map((file) =>
    readFileSync(resolve(process.cwd(), "src/eventRehearsal", file), "utf8")
  ).join("\n");
  for (const collection of forbiddenLiveCollections) {
    assert.equal(
      source.includes(`"${collection}"`),
      false,
      `rehearsal code must not reference ${collection}`
    );
  }
  assert.match(source, /const sessions = "eventRehearsals"/u);
  assert.match(source, /const actors = "eventRehearsalActors"/u);
  assert.match(source, /const actions = "eventRehearsalActions"/u);
  assert.match(source, /const guestViews = "eventRehearsalGuestViews"/u);
  assert.equal(source.match(/collection\("events"\)/gu)?.length, 1);
  assert.match(source, /collection\("events"\)\.doc\(eventId\)\.get\(\)/u);
});

test("host rehearsal bootstrap retains its measured memory ceiling", () => {
  const source = readFileSync(
    resolve(process.cwd(), "src/eventRehearsal/handlers.ts"),
    "utf8"
  );
  const callableDeclaration = "on" + "Call(";
  const bootstrapExport = [
    `export const getEventRehearsalBootstrap = ${callableDeclaration}`,
    "  appCheckCallableOptionsWithLimits({memory: \"512MiB\"}),",
  ].join("\n");
  assert.equal(source.includes(bootstrapExport), true);
});
