import assert from "node:assert/strict";
import {describe, it} from "node:test";

import {
  materializeWeddingPreset,
  weddingFunctionPresets,
  weddingPresetCapabilities,
} from "./weddingPreset.js";

const MINUTE = 60 * 1000;
const DAY = 24 * 60 * MINUTE;
const ANCHOR = 1_800_000_000_000;

describe("weddingFunctionPresets", () => {
  it("covers the typical multi-day run of events", () => {
    assert.deepEqual(
      weddingFunctionPresets.map((fn) => fn.key),
      ["mehndi", "haldi", "sangeet", "ceremony", "reception"],
    );
  });

  it("specs are sorted by day then start time", () => {
    for (let i = 1; i < weddingFunctionPresets.length; i += 1) {
      const prev = weddingFunctionPresets[i - 1];
      const next = weddingFunctionPresets[i];
      const prevOrder = prev.dayOffset * DAY +
        prev.startMinutes * MINUTE;
      const nextOrder = next.dayOffset * DAY +
        next.startMinutes * MINUTE;
      assert.ok(prevOrder < nextOrder);
    }
  });

  it("all specs invite all guests and enable check-in", () => {
    for (const fn of weddingFunctionPresets) {
      assert.equal(fn.invitationMode, "allGuests");
      assert.equal(fn.checkInEnabled, true);
      assert.ok(fn.dressCode.length > 0);
      assert.ok(fn.durationMinutes > 0);
    }
  });
});

describe("weddingPresetCapabilities", () => {
  it("requests the wedding upsell capabilities", () => {
    assert.deepEqual(
      [...weddingPresetCapabilities].sort(),
      ["accommodation", "arrivalsTransport", "forms", "messaging"],
    );
  });
});

describe("materializeWeddingPreset", () => {
  it("anchors each function at day offset plus local start", () => {
    const out = materializeWeddingPreset(ANCHOR);
    assert.equal(out.length, weddingFunctionPresets.length);
    const sangeet = out[2];
    assert.equal(sangeet.name, "Sangeet");
    assert.equal(sangeet.startsAtMillis, ANCHOR + DAY + 19 * 60 * MINUTE);
    assert.equal(
      sangeet.endsAtMillis - sangeet.startsAtMillis,
      4 * 60 * MINUTE,
    );
  });

  it("preserves metadata through materialization", () => {
    const out = materializeWeddingPreset(ANCHOR);
    for (let i = 0; i < out.length; i += 1) {
      const spec = weddingFunctionPresets[i];
      assert.equal(out[i].dressCode, spec.dressCode);
      assert.equal(out[i].instructions, spec.instructions);
      assert.equal(out[i].invitationMode, spec.invitationMode);
      assert.equal(out[i].checkInEnabled, spec.checkInEnabled);
      assert.ok(out[i].endsAtMillis > out[i].startsAtMillis);
    }
  });

  it("rejects invalid anchors", () => {
    assert.throws(() => materializeWeddingPreset(-1), RangeError);
    assert.throws(() => materializeWeddingPreset(1.5), RangeError);
    assert.throws(() => materializeWeddingPreset(NaN), RangeError);
  });
});
