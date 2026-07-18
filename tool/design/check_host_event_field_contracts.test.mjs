import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {
  scanHostEventFieldContracts,
  scanHostEventFieldSource,
} from "./check_host_event_field_contracts.mjs";

test("flags activity choice fields without itemAccent", () => {
  const findings = scanHostEventFieldSource({
    relativePath:
      "lib/hosts/presentation/event_management/widgets/event_details_step.dart",
    source: [
      "CatchField.choices<ActivityKind>(",
      "  values: ActivityKind.values,",
      "  itemLabel: (value) => value.label,",
      ")",
    ].join("\n"),
  });

  assert.equal(findings.length, 1);
  assert.equal(findings[0].rule, "HOST-EVENT-FIELD-001");
});

test("allows activity choice fields with itemAccent", () => {
  const findings = scanHostEventFieldSource({
    relativePath:
      "lib/hosts/presentation/event_management/widgets/event_details_step.dart",
    source: [
      "CatchField.choices<PaceLevel>(",
      "  values: PaceLevel.values,",
      "  itemAccent: (_) => activity.accent,",
      ")",
    ].join("\n"),
  });

  assert.equal(findings.length, 0);
});

test("flags initially open event create fields", () => {
  const findings = scanHostEventFieldSource({
    relativePath:
      "lib/hosts/presentation/event_management/widgets/event_details_step.dart",
    source: "CatchField.choices<String>(initiallyOpen: true)",
  });

  assert.equal(findings.length, 1);
  assert.equal(findings[0].rule, "HOST-EVENT-FIELD-002");
});

test("flags event accordions seeded with an expanded field", () => {
  const findings = scanHostEventFieldSource({
    relativePath: "lib/hosts/presentation/edit_hosted_event_screen.dart",
    source: "final accordion = CatchFieldAccordion(initialExpanded: 'pace');",
  });

  assert.equal(findings.length, 1);
  assert.equal(findings[0].rule, "HOST-EVENT-FIELD-002");
});

test("repository scan covers all Host Dart sources", () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-host-fields-"));
  const sourcePath = path.join(
    root,
    "lib/hosts/presentation/event_management/widgets/event_details_step.dart",
  );
  fs.mkdirSync(path.dirname(sourcePath), {recursive: true});
  fs.writeFileSync(
    sourcePath,
    "CatchField.choices<ActivityKind>(itemAccent: (_) => accent)",
  );

  const result = scanHostEventFieldContracts({root});

  assert.equal(result.filesScanned, 1);
  assert.equal(result.findings.length, 0);
});
