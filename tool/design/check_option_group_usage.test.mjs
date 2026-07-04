import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {
  scanOptionGroupUsage,
  scanSourceForOptionGroupUsage,
} from "./check_option_group_usage.mjs";

test("flags direct CatchOptionGroupItem usage in production feature code", () => {
  const findings = scanSourceForOptionGroupUsage({
    relativePath: "lib/explore/presentation/widgets/example_filter_rail.dart",
    source:
      "Widget build(context) => CatchOptionGroupItem<String>(option: option, selected: true);",
  });

  assert.equal(findings.length, 1);
  assert.equal(findings[0].level, "high");
});

test("allows the canonical CatchOptionGroup implementation", () => {
  const findings = scanSourceForOptionGroupUsage({
    relativePath: "lib/core/widgets/catch_option_group.dart",
    source:
      "Widget build(context) => CatchOptionGroupItem<String>(option: option, selected: true);",
  });

  assert.equal(findings.length, 0);
});

test("ignores direct item usage outside production lib sources", () => {
  const findings = scanSourceForOptionGroupUsage({
    relativePath: "test/core/catch_primitives_test.dart",
    source:
      "Widget build(context) => CatchOptionGroupItem<String>(option: option, selected: true);",
  });

  assert.equal(findings.length, 0);
});

test("scanOptionGroupUsage reports production files only", () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-option-group-"));
  writeFile(
    root,
    "lib/explore/presentation/widgets/example_filter_rail.dart",
    "Widget build(context) => CatchOptionGroupItem<String>(option: option, selected: true);",
  );
  writeFile(
    root,
    "lib/core/widgets/catch_option_group.dart",
    "Widget build(context) => CatchOptionGroupItem<String>(option: option, selected: true);",
  );
  writeFile(
    root,
    "test/core/catch_primitives_test.dart",
    "Widget build(context) => CatchOptionGroupItem<String>(option: option, selected: true);",
  );

  const result = scanOptionGroupUsage({root});

  assert.equal(result.counts.high, 1);
  assert.equal(result.findings[0].path, "lib/explore/presentation/widgets/example_filter_rail.dart");
});

function writeFile(root, relativePath, source) {
  const file = path.join(root, relativePath);
  fs.mkdirSync(path.dirname(file), {recursive: true});
  fs.writeFileSync(file, source);
}
