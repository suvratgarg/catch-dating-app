import assert from "node:assert/strict";
import {spawnSync} from "node:child_process";
import path from "node:path";
import test from "node:test";
import {fileURLToPath} from "node:url";

import {
  buildLineStarts,
  collectCatalogWidgetSymbols,
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

test("prose-only catalog mentions do not satisfy exact widget inventory coverage", () => {
  const symbols = collectCatalogWidgetSymbols(`
CatchProseOnly is discussed here but has no inventory row.

| Family | Use | Do not use |
|---|---|---|
| \`CatchWrongTable\` | Example | Example |

| Widget | File | Purpose |
|---|---|---|
| \`CatchGroupedOne\` / \`CatchGroupedTwo<P>\` | lib/example.dart | Owners |
| See \`CatchMalformedCell\` | lib/example.dart | Not an exact first cell |
`);

  assert.equal(symbols.has("CatchProseOnly"), false);
  assert.equal(symbols.has("CatchWrongTable"), false);
  assert.equal(symbols.has("CatchMalformedCell"), false);
  assert.equal(symbols.has("CatchGroupedOne"), true);
  assert.equal(symbols.has("CatchGroupedTwo"), true);
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

test("exempts only exact canonical closed descriptor renderers", () => {
  const source = `
final class CatchRouteBody {
  Widget _build() => const SizedBox();
  Widget _buildStandard() => const SizedBox();
  Widget _buildStandardSlivers() => const SizedBox();
  Widget _unexpectedRenderer() => const SizedBox();
}

final class CatchTabbedPageSpec {
  Widget _build() => const SizedBox();
  Widget anotherHelper() => const SizedBox();
}

final class CatchTabbedScreenBody {
  Widget _build() => const SizedBox();
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
      {owner: "CatchTabbedPageSpec", name: "anotherHelper"},
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
