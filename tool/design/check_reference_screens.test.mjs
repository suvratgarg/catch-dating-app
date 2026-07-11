import assert from "node:assert/strict";
import {spawnSync} from "node:child_process";
import crypto from "node:crypto";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import {fileURLToPath} from "node:url";
import zlib from "node:zlib";
import test from "node:test";

const checkerPath = path.join(
  path.dirname(fileURLToPath(import.meta.url)),
  "check_reference_screens.mjs",
);

test("accepts a pinned Host source pack and force-compares app navigation chrome", () => {
  const fixture = createFixture();
  const check = runChecker(fixture.root, "--check", "--summary");

  assert.equal(check.status, 0, check.stderr);
  assert.match(check.stdout, /Reference screens: 1 references across 1 screen/u);

  const compare = runChecker(
    fixture.root,
    "--compare",
    "--capture-dir",
    fixture.captureDir,
  );
  assert.equal(compare.status, 0, compare.stderr);
  assert.match(compare.stdout, /masked=1/u);
  assert.match(compare.stdout, /mismatch=100\.00%/u);
});

test("strict focused comparison fails missing captures", () => {
  const fixture = createFixture();
  fs.unlinkSync(path.join(fixture.captureDir, "host_today", "light.png"));
  const result = runChecker(
    fixture.root,
    "--compare",
    "--capture-dir",
    fixture.captureDir,
    "--ids",
    "host_today",
    "--strict",
  );

  assert.equal(result.status, 1);
  assert.match(result.stderr, /missing capture/u);
});

test("strict comparison bounds a stable known parity debt", () => {
  const fixture = createFixture(({reference}) => {
    reference.parityDebtId = "HOST-V2-FIXTURE-001";
    reference.thresholds = {maxMismatchRatio: 0.18, maxMeanDelta: 18};
    reference.regressionThresholds = {
      maxMismatchRatio: 1,
      maxMeanDelta: 255,
    };
  });
  const result = runChecker(
    fixture.root,
    "--compare",
    "--capture-dir",
    fixture.captureDir,
    "--ids",
    "host_today",
    "--strict",
  );

  assert.equal(result.status, 0, result.stderr);
  assert.match(result.stdout, /known parity debt HOST-V2-FIXTURE-001/u);
});

test("rejects Host sources outside a repo-owned source pack", () => {
  const fixture = createFixture(({reference}) => {
    reference.source.path = "/tmp/Today.dc.html";
  });
  const result = runChecker(fixture.root, "--check");

  assert.equal(result.status, 1);
  assert.match(result.stderr, /Host source\.path must be a normalized repo-relative path/u);
});

test("rejects missing and hash-drifted Host source files", async (t) => {
  await t.test("missing source", () => {
    const fixture = createFixture(({sourceFile}) => fs.unlinkSync(sourceFile));
    const result = runChecker(fixture.root, "--check");

    assert.equal(result.status, 1);
    assert.match(result.stderr, /missing Host source\.path/u);
  });

  await t.test("source hash drift", () => {
    const fixture = createFixture(({reference}) => {
      reference.source.sha256 = "0".repeat(64);
    });
    const result = runChecker(fixture.root, "--check");

    assert.equal(result.status, 1);
    assert.match(result.stderr, /Host source\.sha256 does not match/u);
  });

  await t.test("unreferenced source-pack file drift", () => {
    const fixture = createFixture(({notesFile}) => {
      fs.writeFileSync(notesFile, "tampered handoff notes\n");
    });
    const result = runChecker(fixture.root, "--check");

    assert.equal(result.status, 1);
    assert.match(result.stderr, /notes\.txt: sha256 does not match/u);
  });
});

test("rejects broken repo-local links in a pinned Host source pack", () => {
  const fixture = createFixture(({sourceFile}) => {
    fs.writeFileSync(sourceFile, '<html><script src="missing.js"></script></html>\n');
  });
  const packPath = path.join(
    fixture.root,
    "design/source_packs/host-v2/source-pack.json",
  );
  const pack = JSON.parse(fs.readFileSync(packPath, "utf8"));
  const entry = pack.files.find((item) => item.path.endsWith("Today.dc.html"));
  entry.sha256 = sha256File(
    path.join(
      fixture.root,
      "design/source_packs/host-v2/templates/hosts-today/Today.dc.html",
    ),
  );
  fs.writeFileSync(packPath, `${JSON.stringify(pack, null, 2)}\n`);
  const manifestPath = path.join(
    fixture.root,
    "design/reference_screens/manifest.json",
  );
  const manifest = JSON.parse(fs.readFileSync(manifestPath, "utf8"));
  manifest.references[0].source.sha256 = entry.sha256;
  fs.writeFileSync(manifestPath, `${JSON.stringify(manifest, null, 2)}\n`);

  const result = runChecker(fixture.root, "--check");
  assert.equal(result.status, 1);
  assert.match(result.stderr, /missing declared local dependency .*missing\.js/u);
});

test("requires full-shell Host chrome and an explicit nav-mask removal", async (t) => {
  await t.test("missing full-shell policy", () => {
    const fixture = createFixture(({reference}) => {
      delete reference.chromePolicy;
    });
    const result = runChecker(fixture.root, "--check");

    assert.equal(result.status, 1);
    assert.match(result.stderr, /chromePolicy to full-shell/u);
  });

  await t.test("nav mask still applied", () => {
    const fixture = createFixture(({reference}) => {
      delete reference.forceCompareMaskIds;
    });
    const result = runChecker(fixture.root, "--check");

    assert.equal(result.status, 1);
    assert.match(result.stderr, /must force-compare app navigation mask host_tab_bar/u);
  });
});

function createFixture(mutate) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-reference-screens-"));
  const sourceRelative =
    "design/source_packs/host-v2/templates/hosts-today/Today.dc.html";
  const sourceFile = writeFile(root, sourceRelative, "<html>Host Today</html>\n");
  const notesFile = writeFile(
    root,
    "design/source_packs/host-v2/notes.txt",
    "Pinned Host redesign notes\n",
  );
  const sourceSha = sha256File(sourceFile);
  const notesSha = sha256File(notesFile);
  writeJson(root, "design/source_packs/host-v2/source-pack.json", {
    $schema: "catch.design-source-pack/v1",
    id: "host-v2",
    importedAt: "2026-07-10",
    entrypoints: ["templates/hosts-today/Today.dc.html"],
    files: [
      {
        path: "notes.txt",
        sha256: notesSha,
      },
      {
        path: "templates/hosts-today/Today.dc.html",
        sha256: sourceSha,
      },
    ],
  });

  const referencePath = "design/reference_screens/screen.host.home/today.png";
  const referenceFile = path.join(root, referencePath);
  writePng(referenceFile, [
    [0, 0, 0, 255],
    [0, 0, 0, 255],
  ]);
  const maskPath = "design/reference_screens/screen.host.home/masks.json";
  writeJson(root, maskPath, {
    version: 1,
    regions: [
      {id: "status_bar", rect: {x: 0, y: 0, width: 1, height: 1}},
      {id: "host_tab_bar", rect: {x: 0, y: 1, width: 1, height: 1}},
    ],
  });

  const reference = {
    id: "screen.host.home.today",
    screenId: "screen.host.home",
    stateId: "today",
    captureId: "host_today",
    theme: "light",
    textScale: 1,
    device: {id: "fixture", width: 1, height: 2, pixelRatio: 1},
    chromePolicy: "full-shell",
    referencePath,
    maskPath,
    forceCompareMaskIds: ["host_tab_bar"],
    source: {
      kind: "claude",
      id: "fixture.host-today",
      path: sourceRelative,
      packManifest: "design/source_packs/host-v2/source-pack.json",
      sha256: sourceSha,
    },
  };
  mutate?.({notesFile, reference, root, sourceFile});
  writeJson(root, "design/reference_screens/manifest.json", {
    version: 1,
    updated: "2026-07-10",
    references: [reference],
  });

  const captureDir = path.join(root, "captures");
  writePng(path.join(captureDir, "host_today", "light.png"), [
    [255, 255, 255, 255],
    [255, 255, 255, 255],
  ]);
  return {captureDir, root};
}

function runChecker(root, ...commandArgs) {
  return spawnSync(
    process.execPath,
    [
      checkerPath,
      ...commandArgs,
      "--repo-root",
      root,
      "--manifest",
      "design/reference_screens/manifest.json",
    ],
    {encoding: "utf8"},
  );
}

function writeFile(root, relativePath, contents) {
  const filePath = path.join(root, relativePath);
  fs.mkdirSync(path.dirname(filePath), {recursive: true});
  fs.writeFileSync(filePath, contents);
  return filePath;
}

function writeJson(root, relativePath, value) {
  writeFile(root, relativePath, `${JSON.stringify(value, null, 2)}\n`);
}

function sha256File(filePath) {
  return crypto.createHash("sha256").update(fs.readFileSync(filePath)).digest("hex");
}

function writePng(filePath, pixels) {
  fs.mkdirSync(path.dirname(filePath), {recursive: true});
  const width = 1;
  const height = pixels.length;
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(width, 0);
  ihdr.writeUInt32BE(height, 4);
  ihdr[8] = 8;
  ihdr[9] = 6;
  const raw = Buffer.concat(pixels.map((pixel) => Buffer.from([0, ...pixel])));
  const signature = Buffer.from("89504e470d0a1a0a", "hex");
  fs.writeFileSync(
    filePath,
    Buffer.concat([
      signature,
      pngChunk("IHDR", ihdr),
      pngChunk("IDAT", zlib.deflateSync(raw)),
      pngChunk("IEND", Buffer.alloc(0)),
    ]),
  );
}

function pngChunk(type, data) {
  const length = Buffer.alloc(4);
  length.writeUInt32BE(data.length);
  return Buffer.concat([length, Buffer.from(type), data, Buffer.alloc(4)]);
}
