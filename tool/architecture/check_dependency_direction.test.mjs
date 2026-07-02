import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {scanDependencyDirection, scanFile} from "./check_dependency_direction.mjs";

test("scanFile flags domain framework imports", () => {
  const findings = scanFile({
    relativePath: "lib/events/domain/event.dart",
    source: "import 'package:cloud_firestore/cloud_firestore.dart';\n",
  });

  assert.deepEqual(findings.map((finding) => finding.rule), [
    "domainFrameworkImport",
  ]);
  assert.equal(findings[0].import, "package:cloud_firestore/cloud_firestore.dart");
});

test("scanFile flags data/domain imports of feature presentation", () => {
  const findings = scanFile({
    relativePath: "lib/events/data/event_repository.dart",
    source:
      "import 'package:catch_dating_app/events/presentation/event_detail_screen.dart';\n",
  });

  assert.deepEqual(findings.map((finding) => finding.rule), [
    "dataDomainPresentationImport",
  ]);
});

test("scanFile flags sibling feature presentation imports", () => {
  const findings = scanFile({
    relativePath: "lib/hosts/presentation/host_event_manage_screen.dart",
    source:
      "import 'package:catch_dating_app/events/presentation/event_booking_controller.dart';\n",
  });

  assert.deepEqual(findings.map((finding) => finding.rule), [
    "crossFeaturePresentationImport",
  ]);
});

test("scanFile allows same-feature and core presentation imports", () => {
  const findings = scanFile({
    relativePath: "lib/events/presentation/event_detail_screen.dart",
    source: [
      "import 'package:catch_dating_app/core/presentation/catch_async_state.dart';",
      "import 'package:catch_dating_app/events/presentation/event_detail_screen_state.dart';",
    ].join("\n"),
  });

  assert.deepEqual(findings, []);
});

test("scanDependencyDirection ratchets baseline findings", () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-dependency-"));
  writeFile(
    root,
    "lib/events/domain/event.dart",
    "import 'package:cloud_firestore/cloud_firestore.dart';\n",
  );
  writeFile(
    root,
    "lib/hosts/presentation/host_event_manage_screen.dart",
    "import 'package:catch_dating_app/events/presentation/event_booking_controller.dart';\n",
  );

  const baseline = {
    allowedFindings: [
      {
        rule: "domainFrameworkImport",
        path: "lib/events/domain/event.dart",
        import: "package:cloud_firestore/cloud_firestore.dart",
      },
    ],
  };

  const result = scanDependencyDirection({root, baseline});

  assert.equal(result.baselineFindings.length, 1);
  assert.equal(result.findings.length, 1);
  assert.equal(result.findings[0].rule, "crossFeaturePresentationImport");
});

function writeFile(root, relativePath, source) {
  const file = path.join(root, relativePath);
  fs.mkdirSync(path.dirname(file), {recursive: true});
  fs.writeFileSync(file, source);
}
