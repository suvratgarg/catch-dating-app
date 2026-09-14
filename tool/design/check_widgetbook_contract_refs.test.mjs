import assert from "node:assert/strict";
import test from "node:test";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import {
  collectPrimitiveContractUseCases,
  parsePrimitiveContractUseCases,
  validatePrimitiveContractUseCases,
} from "./check_widgetbook_contract_refs.mjs";

const registry = {
  components: [{
    id: "catch.banner",
    dart: {symbol: "CatchBanner"},
    contract: {states: ["message", "error", "offline", "stacked"]},
  }],
};
const recipe = (states) => `
@widgetbook.UseCase(name: 'Recipe', type: CatchBanner,)
Widget specimen(BuildContext context) => WidgetbookContractFrame(
  contractId: 'catch.banner', states: const [${states.map((s) => `'${s}'`).join(",")}],
);`;

test("all named recipes contribute to their canonical component contract", () => {
  const inventory = parsePrimitiveContractUseCases(
    recipe(["message", "error"]) + recipe(["offline", "stacked"]),
  );
  assert.deepEqual(inventory.statesByContractId.get("catch.banner"),
    ["message", "error", "offline", "stacked"]);
  assert.deepEqual(validatePrimitiveContractUseCases(registry, inventory), []);
});

test("removing a recipe or a state cannot be masked by a later preview", () => {
  for (const source of [
    recipe(["offline", "stacked"]),
    recipe(["message", "error"]) + recipe(["offline"]),
    recipe(["message", "error"]) + recipe(["offline", "stacked", "unexpected"]),
  ]) {
    assert.match(validatePrimitiveContractUseCases(
      registry, parsePrimitiveContractUseCases(source),
    ).join("\n"), /do not match component contract states/);
  }
});

test("repeated states do not hide missing states or change declaration order", () => {
  const inventory = parsePrimitiveContractUseCases(
    recipe(["message", "error"]) + recipe(["message", "offline", "stacked"]),
  );
  assert.deepEqual(validatePrimitiveContractUseCases(registry, inventory), []);
});

test("split contract families are discovered and a deleted family cannot pass", (t) => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-contract-families-"));
  t.after(() => fs.rmSync(root, {recursive: true, force: true}));
  const directory = path.join(root, "widgetbook/lib/primitives/contracts");
  fs.mkdirSync(directory, {recursive: true});
  fs.writeFileSync(path.join(directory, "banner.dart"), recipe(["message", "error"]));
  fs.writeFileSync(path.join(directory, "statuses.dart"), recipe(["offline", "stacked"]));
  assert.deepEqual(validatePrimitiveContractUseCases(registry, collectPrimitiveContractUseCases({root})), []);
  fs.unlinkSync(path.join(directory, "banner.dart"));
  assert.match(validatePrimitiveContractUseCases(registry, collectPrimitiveContractUseCases({root})).join("\n"),
    /do not match component contract states/);
  fs.unlinkSync(path.join(directory, "statuses.dart"));
  assert.throws(() => collectPrimitiveContractUseCases({root}), /no Dart sources/);
});
