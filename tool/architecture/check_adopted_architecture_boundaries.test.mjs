import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {
  collectAdoptedProviderFreePaths,
  scanAdoptedArchitectureBoundaries,
  scanBoundaryFile,
} from "./check_adopted_architecture_boundaries.mjs";

test("collectAdoptedProviderFreePaths requires structured providerFree", () => {
  const tracker = {
    patterns: [
      {
        id: "ARCH-TEST-001",
        adopters: [
          {
            path: "lib/events/presentation/event_detail_screen_state.dart",
            role: "provider-free display adapter",
            status: "aligned",
          },
          {
            path: "lib/events/presentation/event_detail_body.dart",
            providerFree: true,
            role: "widget body",
            status: "aligned",
          },
          {
            path: "test/events/event_detail_body_test.dart",
            providerFree: true,
            status: "aligned",
          },
          {
            path: "lib/events/presentation/variant.dart",
            providerFree: true,
            status: "variant_needed",
          },
        ],
      },
    ],
  };

  assert.deepEqual(collectAdoptedProviderFreePaths(tracker), [
    {
      path: "lib/events/presentation/event_detail_body.dart",
      patternId: "ARCH-TEST-001",
      role: "widget body",
    },
  ]);
});

test("scanBoundaryFile flags provider, routing, data, and repository access", () => {
  const evidence = scanBoundaryFile({
    source: [
      "import 'package:flutter_riverpod/flutter_riverpod.dart';",
      "import 'package:catch_dating_app/routing/go_router.dart';",
      "import 'package:catch_dating_app/events/data/event_repository.dart';",
      "import 'package:catch_dating_app/events/application/event_repository.dart';",
      "Widget build(WidgetRef ref) => Text('${ref.watch(fooProvider)}');",
    ].join("\n"),
  });

  assert.deepEqual(
    evidence.map((entry) => entry.label),
    [
      "Riverpod",
      "app routing",
      "feature data layer",
      "repository API",
      "Riverpod widget/ref API",
      "Riverpod ref access",
    ],
  );
});

test("scanAdoptedArchitectureBoundaries ignores prose-only provider-free roles", () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-boundaries-"));
  writeJson(root, "docs/audit_registry/architecture_pattern_adoption.json", {
    patterns: [
      {
        id: "ARCH-TEST-001",
        adopters: [
          {
            path: "lib/events/presentation/prose_only_adapter.dart",
            role: "provider-free adapter",
            status: "aligned",
          },
          {
            path: "lib/events/presentation/structured_adapter.dart",
            providerFree: true,
            role: "display adapter",
            status: "aligned",
          },
        ],
      },
    ],
  });
  writeFile(
    root,
    "lib/events/presentation/prose_only_adapter.dart",
    "final leak = ref.watch(fooProvider);\n",
  );
  writeFile(
    root,
    "lib/events/presentation/structured_adapter.dart",
    "final leak = ref.watch(fooProvider);\n",
  );

  const result = scanAdoptedArchitectureBoundaries({root});

  assert.equal(result.checkedProviderFreeAdopters, 1);
  assert.equal(result.findings.length, 1);
  assert.equal(
    result.findings[0].path,
    "lib/events/presentation/structured_adapter.dart",
  );
});

test("scanAdoptedArchitectureBoundaries reports missing tracked files", () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-boundaries-"));
  writeJson(root, "docs/audit_registry/architecture_pattern_adoption.json", {
    patterns: [
      {
        id: "ARCH-TEST-001",
        adopters: [
          {
            path: "lib/events/presentation/missing_adapter.dart",
            providerFree: true,
            status: "aligned",
          },
        ],
      },
    ],
  });

  const result = scanAdoptedArchitectureBoundaries({root});

  assert.equal(result.checkedProviderFreeAdopters, 1);
  assert.equal(result.findings.length, 1);
  assert.equal(
    result.findings[0].reason,
    "tracked aligned provider-free adopter is missing on disk",
  );
});

function writeFile(root, relativePath, source) {
  const file = path.join(root, relativePath);
  fs.mkdirSync(path.dirname(file), {recursive: true});
  fs.writeFileSync(file, source);
}

function writeJson(root, relativePath, value) {
  writeFile(root, relativePath, `${JSON.stringify(value, null, 2)}\n`);
}
