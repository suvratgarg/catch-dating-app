import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {spawnSync} from "node:child_process";
import {fileURLToPath} from "node:url";
import {scanDartSource} from "../lib/dart_source.mjs";
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
  writeJson(root, "tool/architecture/pattern_adoption.json", {
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
  writeJson(root, "tool/architecture/pattern_adoption.json", {
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

function trackerFor(paths) {
  return {patterns: [{id: "ARCH-TEST", adopters: paths.map((file) => ({
    path: file, status: "aligned", providerFree: true,
  }))}]};
}

test("production package adopters are selected and deduplicated with root adopters", () => {
  const production = ["lib/view.dart", "packages/catch_ui/lib/src/view.dart"];
  const tracker = trackerFor([...production, ...production,
    "test/view_test.dart", "packages/catch_ui/test/view_test.dart",
    "packages/catch_ui/example/lib/main.dart"]);
  assert.deepEqual(collectAdoptedProviderFreePaths(tracker).map(({path: file}) => file), production);
});

test("noncanonical adopter paths fail instead of reading outside production roots", () => {
  for (const file of ["/tmp/view.dart", "lib/../view.dart", "lib//view.dart",
    "./lib/view.dart", "packages/../lib/view.dart", "lib\\view.dart"]) {
    assert.throws(() => collectAdoptedProviderFreePaths(trackerFor([file])), /Noncanonical/u, file);
  }
});

test("all current promised production adopters are selected, including catch_ui", () => {
  const tracker = JSON.parse(fs.readFileSync(new URL("./pattern_adoption.json", import.meta.url), "utf8"));
  const promised = [...new Set(tracker.patterns.flatMap((pattern) => pattern.adopters ?? [])
    .filter((adopter) => adopter.status === "aligned" && adopter.providerFree === true &&
      /^(?:lib\/|packages\/[^/]+\/lib\/).*\.dart$/u.test(adopter.path))
    .map((adopter) => adopter.path))].sort();
  const selected = collectAdoptedProviderFreePaths(tracker).map(({path: file}) => file).sort();
  assert.deepEqual(selected, promised);
  assert.ok(selected.includes("packages/catch_ui/lib/src/components/catch_empty_state.dart"));
  assert.ok(selected.includes("packages/catch_ui/lib/src/components/catch_polaroid.dart"));
  assert.ok(selected.includes("packages/catch_ui/lib/src/patterns/catch_sliver_error_state.dart"));
});

test("real CLI checks valid, violating and missing package adopters", (t) => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-package-boundary-"));
  t.after(() => fs.rmSync(root, {recursive: true, force: true}));
  const file = "packages/catch_ui/lib/src/view.dart";
  writeJson(root, "tool/architecture/pattern_adoption.json", trackerFor([file]));
  const scanner = fileURLToPath(new URL("./check_adopted_architecture_boundaries.mjs", import.meta.url));
  const env = {...process.env};
  delete env.NODE_TEST_CONTEXT;
  const run = () => spawnSync(process.execPath, [scanner, "--root", root, "--json"], {encoding: "utf8", env});
  writeFile(root, file, "final message = 'ref.watch(provider)';\n");
  let result = run();
  assert.equal(result.status, 0, result.stderr);
  assert.equal(JSON.parse(result.stdout).checkedProviderFreeAdopters, 1);
  writeFile(root, file, 'import "package:flutter_riverpod/flutter_riverpod.dart" show AsyncValue;\n');
  result = run();
  assert.equal(result.status, 1, result.stderr);
  assert.equal(JSON.parse(result.stdout).findings[0].evidence[0].label, "Riverpod");
  fs.unlinkSync(path.join(root, file));
  result = run();
  assert.equal(result.status, 1, result.stderr);
  assert.match(JSON.parse(result.stdout).findings[0].reason, /missing on disk/u);
});

test("forbidden imports include every qualified and conditional URI form", () => {
  const uri = "package:flutter_riverpod/flutter_riverpod.dart";
  for (const source of [
    `import '${uri}';`, `import "${uri}" as state;`,
    `import r'${uri}' deferred as state;`,
    `import '${uri}' show AsyncData, AsyncValue hide ConsumerWidget;`,
    `import /* nested /* text */ comment */\n '${uri}' hide AsyncData;`,
    `import 'safe.dart' if (dart.library.io) '${uri}';`,
    `import 'safe.dart' if (dart.library.io == 'true') "${uri}" as state;`,
    String.raw`import 'package:\u0066lutter_riverpod/flutter_riverpod.dart';`,
    String.raw`import 'package:\x66lutter_riverpod/flutter_riverpod.dart';`,
    String.raw`import 'package:\u{66}lutter_riverpod/flutter_riverpod.dart';`,
    `import ''' \t\r\n${uri}''';`,
    `import r'''\n${uri}''';`,
    "import 'package:flutter_' /* join */ 'riverpod/flutter_riverpod.dart';",
  ]) {
    const evidence = scanBoundaryFile({source});
    assert.equal(evidence.length, 1, source);
    assert.equal(evidence[0].label, "Riverpod", source);
    assert.equal(evidence[0].text, source, source);
  }
  const source = `import '${uri}' if (dart.library.io) 'package:go_router/go_router.dart' if (dart.library.html) '${uri}' as providers;`;
  assert.deepEqual(scanBoundaryFile({source}).map(({label}) => label), ["Riverpod", "go_router", "Riverpod"]);
});

test("condition equality strings and import combinator names are not API usage", () => {
  const source = "import 'safe.dart' if (dart.library.io == 'package:flutter_riverpod/fake.dart') 'other.dart' as GoRouter show WidgetRef;";
  assert.deepEqual(scanBoundaryFile({source}), []);
  assert.deepEqual(scanDartSource(source).imports[0].uris.map(({uri}) => uri), ["safe.dart", "other.dart"]);
});

test("comments and ordinary/raw/triple strings do not create imports or API findings", () => {
  const source = [
    "// import 'package:flutter_riverpod/fake.dart'; ref.watch(value);",
    "/* outer /* ConsumerWidget */ import 'package:go_router/fake.dart'; */",
    'final a = "import \'package:flutter_riverpod/fake.dart\'; ref.watch(value)";',
    "final b = r'${ref.watch(value)} context.go(path)';",
    "final c = '''ref.watch(value); // /* GoRouter */''';",
    'final d = """WidgetRef ref; import \'package:go_router/fake.dart\';""";',
    String.raw`final e = '\${ref.watch(value)}';`,
    "final f = 'https://example.com/*literal*/';",
    "import 'safe.dart';",
  ].join("\n");
  assert.deepEqual(scanBoundaryFile({source}), []);
  assert.equal(scanDartSource(source).imports.length, 1);
});

test("executable and nested interpolation code keeps original UTF-16 locations", () => {
  const source = [
    "// 😀 ref.watch(fake);",
    "final value = '''😀 ${ {'key': \"${ref.watch(provider)}\"} }''';",
    'import "safe.dart";',
  ].join("\r\n");
  const offset = source.indexOf("ref.watch(provider)");
  const [finding] = scanBoundaryFile({source});
  assert.equal(finding.label, "Riverpod ref access");
  assert.equal(finding.line, 2);
  assert.equal(finding.column, offset - source.lastIndexOf("\n", offset));
  assert.equal(finding.text, "ref.watch(");
  const {code} = scanDartSource(source);
  assert.equal(code.length, source.length);
  assert.equal(code.indexOf("ref.watch"), offset);
  assert.deepEqual([...code.matchAll(/\r\n/gu)].map((match) => match.index),
    [...source.matchAll(/\r\n/gu)].map((match) => match.index));
});

test("conditional URI evidence points to its actual line and column", () => {
  const source = "// 😀\r\nimport 'safe.dart'\r\n  if (dart.library.io) \"package:go_router/go_router.dart\" as routes;";
  const [finding] = scanBoundaryFile({source});
  assert.equal(finding.line, 3);
  assert.equal(finding.column, 24);
  assert.equal(finding.text, source.slice(source.indexOf("import")));
});

test("unsupported import literals and incomplete directives fail clearly", () => {
  for (const source of ["import '${package}/view.dart';", "import 'unterminated",
    "import 'safe.dart' if (dart.library.io);", "import 'safe.dart' show;",
    "import 'safe.dart' deferred;", "import 'safe.dart'"]) {
    assert.throws(() => scanBoundaryFile({source}), /Unsupported Dart import directive/u, source);
  }
});

test("masking does not concatenate tokens across literals or comments", () => {
  for (const source of ["final a = re/* middle */f.watch(value);", "final a = re'ignored'f.watch(value);"])
    assert.deepEqual(scanBoundaryFile({source}), []);
});

test("comments between executable access tokens preserve violations and evidence", () => {
  const source = "ref /* note */ . watch(provider); context\n . go(route);";
  const evidence = scanBoundaryFile({source});
  assert.deepEqual(evidence.map(({label}) => label), ["Riverpod ref access", "route navigation API"]);
  assert.equal(evidence[0].text, "ref /* note */ . watch(");
  assert.equal(evidence[1].text, "context\n . go(");
});
