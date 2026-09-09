import assert from "node:assert/strict";
import test from "node:test";
import {
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
Widget specimen(BuildContext context) => _ContractScreen(
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
