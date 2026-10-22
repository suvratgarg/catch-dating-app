"use strict";

const assert = require("node:assert/strict");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const test = require("node:test");
const {parseArgs, run} = require("./repair-organizer-public-content.cjs");

class FakeTimestamp {
  constructor(seconds, nanoseconds) {
    this._seconds = seconds;
    this._nanoseconds = nanoseconds;
  }
}

function leakedOrganizer() {
  return {
    name: "AFTER FLY",
    description: "AFTER FLY is an Indore organizer discovered through a " +
      "public Luma event page.",
    publicPage: {seoTitle: "AFTER FLY", seoDescription: null},
    publicProfile: {
      headline: "AFTER FLY run club in Indore",
      summary: "This unclaimed profile stays out of search until verified.",
      sourceSummary: null,
      formats: ["Social runs"],
      facts: [
        {label: "Location", value: "Indore, Madhya Pradesh"},
        {label: "Claim state", value: "Unclaimed seed listing"},
      ],
      fitNotes: ["Internal market rationale."],
      missingEvidence: ["Owner verification or claim"],
      eventEvidence: [],
    },
    publicSources: [
      {
        type: "user_supplied",
        label: "User seed input",
        detail: "User requested an initial listing.",
        href: null,
        confidence: "medium",
        lastCheckedAt: new FakeTimestamp(1781049600, 0),
      },
      {
        type: "public_event_page",
        label: "Luma event page",
        detail: "Public Luma page for AFTERFLY TAKEOFF RUN & RAVE.",
        href: "https://luma.com/pxgmph3b",
        confidence: "high",
        lastCheckedAt: new FakeTimestamp(1781049600, 0),
      },
    ],
  };
}

function cleanOrganizer() {
  return {
    name: "Courtside",
    description: "Racket sports and socials in Mumbai.",
    publicProfile: {fitNotes: [], missingEvidence: [], facts: []},
    publicSources: [],
  };
}

// Like Firestore, snapshots hand out copies that keep Timestamp instances.
function clone(value) {
  if (value instanceof FakeTimestamp) {
    return new FakeTimestamp(value._seconds, value._nanoseconds);
  }
  if (Array.isArray(value)) return value.map(clone);
  if (!value || typeof value !== "object") return value;
  return Object.fromEntries(Object.entries(value).map(([key, nested]) =>
    [key, clone(nested)]));
}

function fakeDb(docs, {beforeTransaction} = {}) {
  const snapshot = (docPath) => ({
    ref: {path: docPath},
    exists: docs[docPath] !== undefined,
    data: () => clone(docs[docPath]),
  });
  return {
    writes: [],
    collection(name) {
      return {
        doc: (id) => ({get: async () => snapshot(`${name}/${id}`)}),
        get: async () => ({
          docs: Object.keys(docs)
            .filter((docPath) => docPath.startsWith(`${name}/`))
            .map(snapshot),
        }),
      };
    },
    doc(docPath) {
      return {path: docPath};
    },
    async runTransaction(callback) {
      beforeTransaction?.(docs);
      const tx = {
        get: async (ref) => snapshot(ref.path),
        update: (ref, patch) => {
          this.writes.push({path: ref.path, patch});
          const next = docs[ref.path];
          for (const [field, value] of Object.entries(patch)) {
            const segments = field.split(".");
            let cursor = next;
            for (const segment of segments.slice(0, -1)) {
              cursor = cursor[segment];
            }
            cursor[segments.at(-1)] = value;
          }
        },
      };
      return callback(tx);
    },
  };
}

async function invoke(argv, db, prodProject = "catchdates-prod") {
  const lines = [];
  const status = await run(argv, {
    db,
    prodProject,
    Timestamp: FakeTimestamp,
    log: (line) => lines.push(line),
  });
  return {status, report: JSON.parse(lines[0]), lines};
}

function writeReplacements(value) {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "organizer-content-"));
  const file = path.join(dir, "replacements.json");
  fs.writeFileSync(file, JSON.stringify(value));
  return file;
}

const afterflyCopy = {
  "organizers/afterfly": {
    "description": "AFTER FLY pairs social runs with post-run music in Indore.",
    "publicProfile.summary":
      "AFTER FLY pairs social runs with post-run music in Indore.",
  },
};

test("dry run plans repairs without writing", async () => {
  const db = fakeDb({
    "organizers/afterfly": leakedOrganizer(),
    "organizers/courtside": cleanOrganizer(),
  });
  const {status, report, lines} = await invoke(["--project", "demo"], db);

  assert.equal(status, 0);
  assert.equal(report.mode, "dry_run");
  assert.equal(report.scanned, 2);
  assert.equal(report.clean, 1);
  assert.deepEqual(report.blocked, ["organizers/afterfly"]);
  assert.deepEqual(Object.keys(report.plans[0].patch).sort(), [
    "publicProfile.facts",
    "publicProfile.fitNotes",
    "publicProfile.missingEvidence",
    "publicSources",
  ]);
  assert.deepEqual(
    report.plans[0].remainingIssues.map((issue) => issue.field),
    ["description", "publicProfile.summary"]
  );
  assert.match(report.planHash, /^[0-9a-f]{64}$/u);
  assert.equal(lines.at(-1), "Dry run only. Nothing was written.");
  assert.deepEqual(db.writes, []);
});

test("check exits non-zero until every organizer is clean", async () => {
  const leaked = await invoke(
    ["--project", "demo", "--check"],
    fakeDb({"organizers/afterfly": leakedOrganizer()})
  );
  assert.equal(leaked.status, 1);
  const clean = await invoke(
    ["--project", "demo", "--check"],
    fakeDb({"organizers/courtside": cleanOrganizer()})
  );
  assert.equal(clean.status, 0);
});

test("apply writes only the reviewed plan and leaves a clean check",
  async () => {
    const docs = {"organizers/afterfly": leakedOrganizer()};
    const db = fakeDb(docs);
    const replacements = writeReplacements(afterflyCopy);
    const base = [
      "--project", "demo", "--organizer", "afterfly",
      "--replacements", replacements,
    ];

    await assert.rejects(
      invoke([...base, "--apply"], db),
      /requires --plan-hash/u
    );
    const reviewed = await invoke(base, db);
    assert.deepEqual(reviewed.report.blocked, []);
    await assert.rejects(
      invoke([...base, "--apply", "--plan-hash", "0".repeat(64)], db),
      /does not match the current plan/u
    );
    assert.deepEqual(db.writes, []);

    const applied = await invoke(
      [...base, "--apply", "--plan-hash", reviewed.report.planHash],
      db
    );
    assert.equal(applied.status, 0);
    assert.equal(db.writes.length, 1);
    assert.equal(docs["organizers/afterfly"].publicProfile.summary,
      afterflyCopy["organizers/afterfly"]["publicProfile.summary"]);
    assert.deepEqual(docs["organizers/afterfly"].publicProfile.facts,
      [{label: "Location", value: "Indore, Madhya Pradesh"}]);
    assert.deepEqual(
      docs["organizers/afterfly"].publicSources.map((source) => source.label),
      ["Luma event page"]
    );
    assert.ok(docs["organizers/afterfly"].publicSources[0].lastCheckedAt
      instanceof FakeTimestamp);

    const verified = await invoke([...base, "--check"], db);
    assert.equal(verified.status, 0);
    assert.equal(verified.report.pending, 0);
  });

test("apply refuses blocked plans, prod without opt-in and drifted docs",
  async () => {
    const blockedDb = fakeDb({"organizers/afterfly": leakedOrganizer()});
    const blocked = await invoke(["--project", "demo"], blockedDb);
    await assert.rejects(
      invoke(
        ["--project", "demo", "--apply", "--plan-hash", blocked.report.planHash],
        blockedDb
      ),
      /still have intake wording/u
    );

    await assert.rejects(
      invoke(
        ["--project", "catchdates-prod", "--apply", "--plan-hash", "a"],
        fakeDb({})
      ),
      /without --allow-prod/u
    );

    const replacements = writeReplacements(afterflyCopy);
    const base = ["--project", "demo", "--replacements", replacements];
    const driftDb = fakeDb({"organizers/afterfly": leakedOrganizer()}, {
      beforeTransaction: (docs) => {
        docs["organizers/afterfly"].publicProfile.fitNotes.push("New note");
      },
    });
    const reviewed = await invoke(base, driftDb);
    await assert.rejects(
      invoke([...base, "--apply", "--plan-hash", reviewed.report.planHash],
        driftDb),
      /changed after the reviewed dry run/u
    );
    assert.deepEqual(driftDb.writes, []);
  });

test("rejects unknown flags, missing projects and unscanned replacements",
  async () => {
    assert.throws(() => parseArgs(["--project", "demo", "--force"]),
      /Unknown argument: --force/u);
    assert.throws(() => parseArgs([]), /explicit --project/u);
    assert.throws(() => parseArgs(["--project", "demo", "--check", "--apply",
      "--plan-hash", "a"]), /--check or --apply/u);
    const replacements = writeReplacements({
      "organizers/missing": {"publicProfile.summary": "Visitor copy."},
    });
    await assert.rejects(
      invoke(["--project", "demo", "--replacements", replacements],
        fakeDb({"organizers/afterfly": leakedOrganizer()})),
      /Replacement target was not scanned: organizers\/missing/u
    );
  });
