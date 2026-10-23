import assert from "node:assert/strict";
import test from "node:test";
import stylelint from "stylelint";
import {reportingOptions, tokenRules} from "./stylelint.mjs";

const config = {...reportingOptions, rules: tokenRules};

async function rules(code) {
  const result = await stylelint.lint({code, codeFilename: "probe.css", config});
  return result.results[0].warnings.map((warning) => warning.rule).sort();
}

const unit = "declaration-property-unit-allowed-list";
const value = "declaration-property-value-allowed-list";
const media = "media-feature-name-value-allowed-list";

test("each raw value family fails", async () => {
  const probes = [
    [".p { color: #16140f; }", "color-no-hex"],
    [".p { border-color: white; }", "color-named"],
    [".p { background: rgba(0, 0, 0, .4); }", "function-disallowed-list"],
    [".p { padding: 12px; }", unit],
    [".p { gap: 1rem; }", unit],
    [".p { border-radius: 8px; }", unit],
    [".p { border: 1px solid var(--catch-theme-line); }", unit],
    [".p { font-size: 13px; }", unit],
    [".p { letter-spacing: .1em; }", unit],
    [".p { box-shadow: 0 8px 20px var(--catch-theme-overlay); }", unit],
    [".p { transition: opacity 200ms; }", unit],
    [".p { width: 260px; }", unit],
    [".p { grid-template-columns: 220px 1fr; }", unit],
    [".p { z-index: 30; }", value],
    [".p { font-weight: 600; }", value],
    [".p { font-family: system-ui; }", value],
    [".p { line-height: 1.4; }", value],
    ["@media (max-width: 760px) { .p { display: none; } }", media],
  ];
  for (const [code, rule] of probes) {
    assert.ok((await rules(code)).includes(rule), `${code} should fail ${rule}`);
  }
});

test("token and relative values pass", async () => {
  const clean = [
    ".p { color: var(--catch-theme-ink); background: color-mix(in srgb, var(--catch-theme-ink) 8%, transparent); }",
    ".p { padding: var(--catch-space-s3) 0; gap: var(--catch-gap-related); margin: calc(-1 * var(--catch-space-s4)); }",
    ".p { border: var(--catch-stroke-hairline) solid var(--catch-theme-line); border-radius: 50%; }",
    ".p { font: inherit; font-size: var(--catch-typography-web-body-size); line-height: var(--catch-typography-web-body-line-height); }",
    ".p { font-family: var(--catch-font-mono); font-weight: var(--catch-typography-brand-kicker-weight); letter-spacing: var(--catch-typography-brand-kicker-tracking); }",
    ".p { box-shadow: var(--catch-elevation-card); transition: opacity var(--catch-motion-fast) var(--catch-motion-standard-curve); }",
    ".p { width: 100%; max-width: 62ch; flex: 1; grid-template-columns: repeat(2, 1fr); z-index: var(--catch-layer-sticky); }",
    "@media (min-width: 840px) and (max-width: 1199px) { .p { display: none; } }",
  ];
  for (const code of clean) {
    assert.deepEqual(await rules(code), [], code);
  }
});
