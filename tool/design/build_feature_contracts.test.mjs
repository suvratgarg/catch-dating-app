import assert from "node:assert/strict";
import test from "node:test";

import {
  compileFeatureContract,
  FeatureContractError,
  parseWidgetbookPreviewIds,
} from "./build_feature_contracts.mjs";

const actionOwnerPath = "lib/events/presentation/event_detail_screen_state.dart";
const testPath = "test/events/event_detail_widgets_test.dart";

function fixture() {
  return {
    source: {
      version: 1,
      updated: "2026-07-23",
      id: "feature.example",
      name: "Example",
      owner: "events",
      status: "pilot",
      description: "Fixture contract.",
      actionScope: {
        included: "Fixture actions.",
        excluded: ["Actions outside this fixture."],
      },
      screenContract: "screen.example",
      bindings: {
        widgetbookSources: ["widgetbook/lib/events/example.dart"],
        actionOwner: {file: actionOwnerPath, symbol: "ExampleAction"},
        componentContracts: ["catch.example"],
        dataContracts: ["contracts/firestore/events.schema.json"],
      },
      dimensions: {
        load: {default: "ready", values: ["ready", "loading"]},
      },
      actions: [
        {
          id: "book",
          codeValue: "book",
          cardinality: "singleton",
          scopeKeys: ["viewerUid", "eventId"],
          resultState: "ready",
          description: "Book once.",
        },
      ],
      scenarios: [
        {
          id: "loading",
          screenStateId: "loading",
          dimensions: {load: "loading"},
          actionCases: [{id: "default"}],
        },
        {
          id: "ready",
          screenStateId: "ready",
          dimensions: {},
          actionCases: [{id: "eligible", enabledActions: ["book"]}],
        },
      ],
      requiredEvidence: {captures: true, previews: true, tests: true},
    },
    screenRegistry: {
      screens: [
        {
          id: "screen.example",
          captures: [
            {id: "example_loading"},
            {id: "example_ready"},
          ],
          states: [
            {
              id: "loading",
              kind: "loading",
              status: "captured",
              captureIds: ["example_loading"],
              previewIds: ["ExampleScreen/Screen states"],
              tests: [testPath],
            },
            {
              id: "ready",
              kind: "populated",
              status: "captured",
              captureIds: ["example_ready"],
              previewIds: ["ExampleScreen/Screen states"],
              tests: [testPath],
            },
          ],
        },
      ],
    },
    componentRegistry: {
      components: [{id: "catch.example", dart: {symbol: "ExampleWidget"}}],
    },
    availablePreviews: new Set(["ExampleScreen/Screen states"]),
    pathExists: () => true,
    readPath: (filePath) => filePath === actionOwnerPath
      ? "enum ExampleAction { book }"
      : "",
  };
}

function compile(overrides = {}) {
  return compileFeatureContract({
    ...fixture(),
    sourcePath: "design/features/example.feature.json",
    ...overrides,
  });
}

test("compiles exact screen-state coverage and action availability", () => {
  const artifact = compile();

  assert.deepEqual(artifact.coverage, {
    screenStates: 2,
    scenarios: 2,
    actionCases: 2,
    actions: 1,
    captures: 2,
    previews: 1,
    testFiles: 1,
  });
  assert.deepEqual(
    artifact.scenarios[0].actionCases[0].actions.notAllowed,
    ["book"],
  );
  assert.deepEqual(
    artifact.scenarios[1].actionCases[0].actions.enabled,
    ["book"],
  );
  assert.match(artifact.sourceDigest, /^sha256:[a-f0-9]{64}$/u);
});

test("rejects duplicate and missing screen-state mappings", () => {
  const data = fixture();
  data.source.scenarios[1].screenStateId = "loading";

  assert.throws(
    () => compileFeatureContract({
      ...data,
      sourcePath: "design/features/example.feature.json",
    }),
    (error) => {
      assert.ok(error instanceof FeatureContractError);
      assert.match(error.message, /mapped by more than one scenario/u);
      assert.match(error.message, /unmapped screen states: ready/u);
      return true;
    },
  );
});

test("rejects missing capture, preview, and test evidence", () => {
  const data = fixture();
  const state = data.screenRegistry.screens[0].states[0];
  state.captureIds = [];
  state.previewIds = [];
  state.tests = [];

  assert.throws(
    () => compileFeatureContract({
      ...data,
      sourcePath: "design/features/example.feature.json",
    }),
    (error) => {
      assert.ok(error instanceof FeatureContractError);
      assert.match(error.message, /capture evidence is required/u);
      assert.match(error.message, /Widgetbook preview evidence is required/u);
      assert.match(error.message, /test evidence is required/u);
      return true;
    },
  );
});

test("rejects unknown action and dimension references", () => {
  const data = fixture();
  data.source.scenarios[1].dimensions = {viewer: "member"};
  data.source.scenarios[1].actionCases[0].enabledActions = ["reserve"];

  assert.throws(
    () => compileFeatureContract({
      ...data,
      sourcePath: "design/features/example.feature.json",
    }),
    (error) => {
      assert.ok(error instanceof FeatureContractError);
      assert.match(error.message, /unknown dimension viewer/u);
      assert.match(error.message, /unknown action reserve/u);
      return true;
    },
  );
});

test("parses Widgetbook preview ids from annotated use cases", () => {
  const previews = parseWidgetbookPreviewIds(`
@widgetbook.UseCase(
  name: 'Screen states',
  type: ExampleScreen,
  path: '[Example]/Screens',
)
Widget example(BuildContext context) => const SizedBox();
`);

  assert.deepEqual([...previews], ["ExampleScreen/Screen states"]);
});
