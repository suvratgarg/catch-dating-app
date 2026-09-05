import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";
import {selectOrdinaryDocuments} from "./flutter_document_selection.mjs";

const graph = JSON.parse(fs.readFileSync(new URL("../component_graph.json", import.meta.url), "utf8"));
const select = (changed, options = {}) => selectOrdinaryDocuments({
  beforeGraph: graph, afterGraph: graph, changed,
  manifests: [{"pubspec.yaml": "name: catch_dating_app\n", "apps/host/pubspec.yaml": "dependencies:\n  catch_dating_app:\n    path: ../..\n"}],
  ...options,
});

test("uses ordinary documentation ownership in both committed graphs", () => {
  assert.deepEqual(select(["lib/widget.dart", "docs/feature.md", "README.md"]), ["README.md", "docs/feature.md"]);
  for (const name of ["AGENTS.md", "tool/README.md", "design/components/README.md", "widgetbook/README.md", "functions/README.md", "docs/agent_operating_model.md", "test/fixture.json", "test/fixture.md", "assets/README.md"]) {
    assert.deepEqual(select([name]), [], name);
  }
  const changed = structuredClone(graph);
  const classification = changed.classifications.find((item) => item.components.includes("docs.ordinary"));
  classification.paths.exclude.push("docs/feature.md");
  changed.classifications.push({
    id: "moved-doc-fixture", terminal: true, paths: {include: ["docs/feature.md"]},
    components: ["policy.agent"],
  });
  assert.deepEqual(select(["docs/feature.md"], {beforeGraph: changed}), []);
  assert.deepEqual(select(["docs/feature.md"], {afterGraph: changed}), []);
  assert.throws(() => select(["docs/feature.md"], {beforeGraph: {}}));
});

test("possible assets in either manifest snapshot retain full impact", () => {
  for (const value of ["docs/feature.md", "docs/", "./", "../", '"d\\u006fcs/"']) {
    for (const manifests of [
      [{"pubspec.yaml": `flutter:\n  assets:\n    - ${value}\n`}, {"pubspec.yaml": "name: example\n"}],
      [{"pubspec.yaml": "name: example\n"}, {"pubspec.yaml": `flutter:\n  assets:\n    - ${value}\n`}],
    ]) {
      assert.deepEqual(select(["docs/feature.md"], {manifests}), [], value);
    }
  }
  assert.deepEqual(select(["packages/example/assets/help.md"], {
    manifests: [{"packages/example/pubspec.yaml": "flutter:\n  assets: [assets/]\n"}],
  }), []);
  assert.deepEqual(select(["docs/feature.md"], {
    manifests: [{"apps/host/pubspec.yaml": "flutter:\n  assets: [../../docs/]\n"}],
  }), []);
});

test("current repository manifests keep ordinary prose selective", () => {
  const root = new URL("../../../", import.meta.url);
  const paths = ["pubspec.yaml", "apps/consumer/pubspec.yaml", "apps/host/pubspec.yaml"];
  assert.deepEqual(select(["docs/release_operations.md"], {
    manifests: [Object.fromEntries(paths.map((name) => [name, fs.readFileSync(new URL(name, root), "utf8")]))],
  }), ["docs/release_operations.md"]);
});
