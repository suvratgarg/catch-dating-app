import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import test from "node:test";
import {fileURLToPath} from "node:url";
import stylelint from "stylelint";
import config, {rawColorDebt} from "../stylelint.config.mjs";

const websiteRoot = fileURLToPath(new URL("../", import.meta.url));

async function warningRules(code, file) {
  const result = await stylelint.lint({
    code,
    codeFilename: path.join(websiteRoot, file),
    config,
    configBasedir: websiteRoot,
  });
  return result.results[0].warnings.map((warning) => warning.rule).sort();
}

test("raw-color debt only lists stylesheets that still need the exemption", async () => {
  const strict = {...config, overrides: []};
  for (const file of rawColorDebt) {
    const result = await stylelint.lint({
      code: fs.readFileSync(path.join(websiteRoot, file), "utf8"),
      codeFilename: path.join(websiteRoot, file),
      config: strict,
      configBasedir: websiteRoot,
    });
    assert.ok(result.results[0].warnings.length > 0,
      `${file} has no literal colors left; remove it from rawColorDebt`);
  }
});

test("literal colors fail outside the debt list and token colors pass", async () => {
  assert.deepEqual(
    await warningRules(".probe { color: #16140f; background: rgba(0, 0, 0, .4); border-color: white; }",
      "src/styles/probe.css"),
    ["color-named", "color-no-hex", "function-disallowed-list"],
  );
  assert.deepEqual(
    await warningRules(
      ".probe { color: var(--website-text); border-color: transparent; " +
        "background: color-mix(in srgb, var(--website-text) 8%, transparent); }",
      "src/styles/probe.css",
    ),
    [],
  );
});
