import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";

const source = fs.readFileSync(
  new URL("../../.github/workflows/_mobile-platform-authority.yml", import.meta.url),
  "utf8",
);

test("a single selected package receipt can be verified after download-artifact v7 flattens it", () => {
  const start = source.indexOf("- name: Verify every selected package receipt");
  const end = source.indexOf("- name: Compare every selected cross-role platform pair", start);
  assert.ok(start >= 0 && end > start);
  const verification = source.slice(start, end);
  assert.match(verification, /actual_count.*expected_count/u);
  assert.match(verification, /receipt_file=build\/mobile\/compare\/mobile-package-upload-receipt\.json/u);
  assert.match(verification, /expected_count" == 1/u);
  assert.match(verification, /test -f "\$receipt_file"/u);
  assert.match(verification, /package_mobile_release\.mjs verify-upload/u);
});
