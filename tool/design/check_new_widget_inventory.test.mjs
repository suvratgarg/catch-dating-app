import assert from "node:assert/strict";
import {spawnSync} from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {fileURLToPath} from "node:url";

import {
  buildLineStarts,
  collectClassDeclarations,
  collectClassRanges,
  collectWidgetClasses,
  collectWidgetHelpers,
  requireResolvedMergeBase,
  resolveWidgetTypeNames,
  unresolvedInventoryItems,
} from "./lib/new_widget_inventory_declarations.mjs";
import {
  isGeneratedProductionWidgetDartPath,
} from "./lib/production_widget_roots.mjs";

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../..");

test("new-widget gate uses exact registry and Widgetbook identities without reading markdown", (t) => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-new-widget-policy-"));
  t.after(() => fs.rmSync(root, {recursive: true, force: true}));
  for (const file of [
    "tool/lib/repo_paths.mjs",
    "tool/design/check_new_widget_inventory.mjs",
    "tool/design/component_concepts.mjs",
    "tool/design/lib/new_widget_inventory_declarations.mjs",
    "tool/design/lib/production_widget_roots.mjs",
  ]) {
    fs.mkdirSync(path.dirname(path.join(root, file)), {recursive: true});
    fs.copyFileSync(path.join(repoRoot, file), path.join(root, file));
  }
  const git = (args) => {
    const result = spawnSync("git", args, {cwd: root, encoding: "utf8"});
    assert.equal(result.status, 0, result.stderr);
  };
  git(["init", "--quiet"]);
  git(["-c", "user.name=Fixture", "-c", "user.email=fixture@example.invalid",
    "-c", "commit.gpgsign=false", "commit", "--quiet", "--allow-empty", "-m", "Fixture base"]);
  const write = (file, text) => {
    fs.mkdirSync(path.dirname(path.join(root, file)), {recursive: true});
    fs.writeFileSync(path.join(root, file), text);
  };
  const sourceFile = "lib/core/widgets/catch_button.dart";
  write(sourceFile, "class CatchButton extends StatelessWidget { Widget build(BuildContext context) => const SizedBox(); }\n");
  const widgetbookFile = "widgetbook/lib/main.directories.g.dart";
  const registryFile = "design/components/catch.components.json";
  write(widgetbookFile, "WidgetbookComponent(name: 'CatchButton', useCases: [])");
  const registry = {components: [{dart: {symbol: "CatchButton", file: sourceFile}}]};
  write(registryFile, JSON.stringify(registry));
  const run = () => spawnSync(process.execPath,
    ["tool/design/check_new_widget_inventory.mjs", "--base", "HEAD", "--check", "--json", "--no-write"],
    {cwd: root, encoding: "utf8"});

  const covered = run();
  assert.equal(covered.status, 0, covered.stderr);
  const report = JSON.parse(covered.stdout);
  assert.equal(report.summary.coveredNewWidgets, 1);
  assert.equal(report.sourceOfTruth.registry, registryFile);
  assert.equal("catalog" in report.sourceOfTruth, false);
  assert.equal("catalogMentioned" in report.addedWidgets[0], false);
  assert.equal(fs.existsSync(path.join(root, "docs")), false);

  registry.components[0].dart.file = "lib/core/widgets/old_button.dart";
  write(registryFile, JSON.stringify(registry));
  // Even a matching prose row cannot make a stale registry path valid.
  write("docs/widget_catalog.md", "| Widget | File | Purpose |\n|---|---|---|\n| `CatchButton` | lib/core/widgets/catch_button.dart | A button |\n");
  const stale = run();
  assert.equal(stale.status, 1);
  assert.deepEqual(JSON.parse(stale.stdout).addedWidgets[0].issues, ["missing-component-contract"]);

  registry.components[0].dart.file = sourceFile;
  write(registryFile, JSON.stringify(registry));
  write(widgetbookFile, "WidgetbookComponent(name: 'CatchOtherButton', useCases: [])");
  const missingPreview = run();
  assert.equal(missingPreview.status, 1);
  assert.deepEqual(JSON.parse(missingPreview.stdout).addedWidgets[0].issues, ["missing-widgetbook"]);
});

test("discovers direct and transitive widget subclasses without matching prose", () => {
  const source = `
// class CommentedOutWidget extends StatelessWidget {}
const prose = 'class StringWidget extends StatefulWidget {}';
abstract class BaseScreen<T> extends StatelessWidget {}
class _DerivedScreen extends BaseScreen<int> {}
class RenderProbe extends SingleChildRenderObjectWidget {}
class MixinProbe = ConsumerWidget with Diagnosticable;
class NotAWidget extends ChangeNotifier {}
`;
  const lineStarts = buildLineStarts(source);
  const declarations = collectClassDeclarations(source, lineStarts);
  const widgetTypes = resolveWidgetTypeNames(declarations);
  const widgets = collectWidgetClasses(source, lineStarts, widgetTypes);

  assert.deepEqual(
    widgets.map(({name, baseClass}) => ({name, baseClass})),
    [
      {name: "BaseScreen", baseClass: "StatelessWidget"},
      {name: "_DerivedScreen", baseClass: "BaseScreen"},
      {name: "RenderProbe", baseClass: "SingleChildRenderObjectWidget"},
      {name: "MixinProbe", baseClass: "ConsumerWidget"},
    ],
  );
});

test("generated exclusions are file-specific rather than directory-wide", () => {
  assert.equal(
    isGeneratedProductionWidgetDartPath(
      "lib/example/generated/catch_hand_authored_widget.dart",
    ),
    false,
  );
  assert.equal(
    isGeneratedProductionWidgetDartPath("lib/example/generated/model.g.dart"),
    true,
  );
  assert.equal(
    isGeneratedProductionWidgetDartPath(
      "apps/host/lib/generated/model.freezed.dart",
    ),
    true,
  );
  assert.equal(
    isGeneratedProductionWidgetDartPath(
      "lib/l10n/generated/app_localizations.dart",
    ),
    true,
  );
  assert.equal(
    isGeneratedProductionWidgetDartPath(
      "lib/l10n/generated/app_localizations_en.dart",
    ),
    true,
  );
});

test("discovers nullable, interface, generic, getter, and top-level widget helpers", () => {
  const source = `
class HelperOwner extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const SizedBox();

  Widget? _nullableHelper() => null;
  PreferredSizeWidget topBar<T extends Object>() => const PreferredSize(
    preferredSize: Size.zero,
    child: SizedBox(),
  );
  Widget get child => const SizedBox();
  int _notAWidget() => 0;
}

Widget topLevelHelper() => const SizedBox();
void acceptsCallback(
  Widget callback(),
) {}
// Widget commentedHelper() => const SizedBox();
`;
  const lineStarts = buildLineStarts(source);
  const declarations = collectClassDeclarations(source, lineStarts);
  const widgetTypes = resolveWidgetTypeNames(declarations);
  const helpers = collectWidgetHelpers(
    source,
    lineStarts,
    collectClassRanges(source, lineStarts),
    widgetTypes,
  );

  assert.deepEqual(
    helpers.map(({name, returnType, declarationKind, owner}) => ({
      name,
      returnType,
      declarationKind,
      owner,
    })),
    [
      {
        name: "_nullableHelper",
        returnType: "Widget?",
        declarationKind: "function",
        owner: "HelperOwner",
      },
      {
        name: "topBar",
        returnType: "PreferredSizeWidget",
        declarationKind: "function",
        owner: "HelperOwner",
      },
      {
        name: "child",
        returnType: "Widget",
        declarationKind: "getter",
        owner: "HelperOwner",
      },
      {
        name: "topLevelHelper",
        returnType: "Widget",
        declarationKind: "function",
        owner: null,
      },
    ],
  );
});

test("discovers Object, dynamic, and inferred widget helpers without treating behavior callbacks as helpers", () => {
  const source = `
class LooseHelperOwner extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const SizedBox();

  Object objectHelper() => (const SizedBox());
  dynamic dynamicHelper(bool compact) {
    if (compact) {
      return typedHelper();
    }
    if (!compact) {
      return const SizedBox.shrink();
    }
    throw StateError('unreachable');
  }
  inferredHelper() => const CatchLooseProbe();
  Object get objectGetter => inferredHelper();
  get inferredGetter => objectGetter;
  Widget typedHelper() => const SizedBox();
  Object aliasedHelper() {
    final child = const SizedBox();
    return (child as Object);
  }

  handleTap() {
    registerCallback(() {
      return const SizedBox();
    });
  }
  dynamic openRoute() => Navigator.of(context).pushNamed('/next');
  dynamic openDialog() {
    return showDialog(
      context: context,
      builder: (_) {
        return const SizedBox();
      },
    );
  }
  Object callbackFactory() => () => openRoute();
  Object mapState(Object state) => switch (state) {
    SomeState() => 1,
    _ => 0,
  };
  Object ambiguousCapitalizedFactory() => SomeDescriptor();
  void acceptsCallback(
    Object callback(),
  ) {}
}

class CatchLooseProbe extends StatelessWidget {
  const CatchLooseProbe();

  @override
  Widget build(BuildContext context) => const SizedBox();
}

Object topLevelObjectHelper() => const CatchLooseProbe();
topLevelInferredHelper() => topLevelObjectHelper();
`;
  const lineStarts = buildLineStarts(source);
  const declarations = collectClassDeclarations(source, lineStarts);
  const widgetTypes = resolveWidgetTypeNames(declarations);
  const helpers = collectWidgetHelpers(
    source,
    lineStarts,
    collectClassRanges(source, lineStarts),
    widgetTypes,
  );

  assert.deepEqual(helpers.map(({name, returnType, declarationKind}) => [
    name,
    returnType,
    declarationKind,
  ]), [
    ["objectHelper", "Object", "function"],
    ["dynamicHelper", "dynamic", "function"],
    ["inferredHelper", "inferred", "function"],
    ["objectGetter", "Object", "getter"],
    ["inferredGetter", "inferred", "getter"],
    ["typedHelper", "Widget", "function"],
    ["aliasedHelper", "Object", "function"],
    // A new loosely typed capitalized factory is deliberately blocked when
    // syntax alone cannot prove that it is non-Widget.
    ["ambiguousCapitalizedFactory", "Object", "function"],
    ["topLevelObjectHelper", "Object", "function"],
    ["topLevelInferredHelper", "inferred", "function"],
  ]);
  assert.equal(helpers.some(({name}) => name === "handleTap"), false);
  assert.equal(helpers.some(({name}) => name === "openRoute"), false);
  assert.equal(helpers.some(({name}) => name === "openDialog"), false);
  assert.equal(helpers.some(({name}) => name === "callbackFactory"), false);
  assert.equal(helpers.some(({name}) => name === "SomeState"), false);
  assert.equal(helpers.some(({name}) => name === "callback"), false);
});

test("exempts only exact canonical closed descriptor renderers", () => {
  const source = `
final class CatchRouteBody {
  Widget _build() => const SizedBox();
  Widget _buildStandard() => const SizedBox();
  Widget _buildStandardSlivers() => const SizedBox();
  Widget _unexpectedRenderer() => const SizedBox();
}

final class CatchRootScreenPageSpec {
  Widget build() => const SizedBox();
  Widget anotherHelper() => const SizedBox();
}

final class CatchRootScreenBody {
  Widget build() => const SizedBox();
}

final class CatchRootScreenHeader {
  Widget _build() => const SizedBox();
  Widget anotherHeaderHelper() => const SizedBox();
}

final class UnrelatedDescriptor {
  Widget _build() => const SizedBox();
}
`;
  const widgetTypes = new Set(["Widget"]);
  const lineStarts = buildLineStarts(source);
  const helpers = collectWidgetHelpers(
    source,
    lineStarts,
    collectClassRanges(source, lineStarts),
    widgetTypes,
  );

  assert.deepEqual(
    helpers.map(({owner, name}) => ({owner, name})),
    [
      {owner: "CatchRouteBody", name: "_unexpectedRenderer"},
      {owner: "CatchRootScreenPageSpec", name: "anotherHelper"},
      {owner: "CatchRootScreenHeader", name: "anotherHeaderHelper"},
      {owner: "UnrelatedDescriptor", name: "_build"},
    ],
  );
});

test("moved widget classes and helpers remain blocking inventory items", () => {
  assert.deepEqual(
    unresolvedInventoryItems({
      movedWidgets: [{name: "_MovedWidget", status: "unresolved"}],
      movedWidgetHelpers: [{name: "movedHelper", status: "unresolved"}],
      addedWidgets: [{name: "CoveredWidget", status: "covered"}],
    }).map((entry) => entry.name),
    ["_MovedWidget", "movedHelper"],
  );
});

test("an unavailable default merge base fails closed instead of using HEAD parent", () => {
  assert.throws(
    () => requireResolvedMergeBase({status: 1, stdout: "", stderr: "missing"}),
    /refusing to fall back to HEAD\^/u,
  );
  assert.throws(
    () => requireResolvedMergeBase({status: 0, stdout: "\n", stderr: ""}),
    /refusing to fall back to HEAD\^/u,
  );
});

test("an unavailable explicit base fails closed without scanning the working tree", () => {
  const result = spawnSync(
    process.execPath,
    [
      "tool/design/check_new_widget_inventory.mjs",
      "--base",
      "refs/catch-tests/definitely-missing-widget-base",
      "--check",
      "--no-write",
    ],
    {cwd: repoRoot, encoding: "utf8"},
  );

  assert.equal(result.status, 64);
  assert.match(result.stderr, /refusing to run a vacuous new-widget check/u);
  assert.doesNotMatch(result.stderr, /using the working tree as the baseline/u);
});
