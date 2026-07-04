import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {
  scanSectionDividers,
  scanSourceForSectionDividers,
} from "./check_section_dividers.mjs";

test("flags caller-owned internalDividerColor on divided sections", () => {
  const findings = scanSourceForSectionDividers({
    relativePath: "lib/safety/presentation/settings_screen.dart",
    source: [
      "Widget build(BuildContext context) {",
      "  final t = CatchTokens.of(context);",
      "  return CatchSection.divided(",
      "    title: 'Account',",
      "    dividerIndent: CatchFieldRow.textLaneInset,",
      "    internalDividerColor: t.line.withValues(alpha: CatchOpacity.fieldRowDivider),",
      "    children: const [],",
      "  );",
      "}",
    ].join("\n"),
  });

  assert.equal(findings.length, 1);
  assert.equal(findings[0].level, "high");
  assert.match(findings[0].reason, /internalDividerColor/u);
});

test("flags raw dividers using old row divider opacities", () => {
  const findings = scanSourceForSectionDividers({
    relativePath: "lib/dashboard/presentation/widgets/activity_section.dart",
    source: [
      "Widget build(BuildContext context) {",
      "  final t = CatchTokens.of(context);",
      "  return Divider(",
      "    height: 1,",
      "    color: t.line.withValues(alpha: CatchOpacity.subtleBorder),",
      "  );",
      "}",
    ].join("\n"),
  });

  assert.equal(findings.length, 1);
  assert.equal(findings[0].level, "high");
  assert.match(findings[0].reason, /CatchDivider/u);
});

test("keeps raw Divider inventory visible in presentation files", () => {
  const findings = scanSourceForSectionDividers({
    relativePath: "lib/example/presentation/example_screen.dart",
    source: "Widget build(BuildContext context) => Divider(height: 1, color: t.line);",
  });

  assert.equal(findings.length, 1);
  assert.equal(findings[0].level, "medium");
});

test("scanSectionDividers covers lib, test, and widgetbook sources", () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-section-dividers-"));
  writeFile(
    root,
    "lib/dashboard/presentation/widgets/activity_section.dart",
    "Widget build(BuildContext context) => Divider(height: 1, color: t.line);",
  );
  writeFile(
    root,
    "test/core/catch_primitives_test.dart",
    "void main() { final divider = Divider(height: 1, color: t.line); }",
  );
  writeFile(
    root,
    "widgetbook/lib/primitives/primitive_contract_use_cases.dart",
    "Widget useCase() => Divider(height: 1, color: t.line);",
  );

  const result = scanSectionDividers({root});

  assert.equal(result.filesScanned, 3);
  assert.equal(result.counts.medium, 3);
});

function writeFile(root, relativePath, source) {
  const file = path.join(root, relativePath);
  fs.mkdirSync(path.dirname(file), {recursive: true});
  fs.writeFileSync(file, source);
}
