import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";
import test from "node:test";
import ts from "typescript";
import * as canonical from "./generated/schema_contract_registry.mjs";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../..");

test("modular Functions schemas preserve every canonical schema and catalog value", () => {
  const actual = {};
  for (const directory of ["schemas", "catalogs"]) {
    const folder = path.join(root, "functions/src/shared/generated", directory);
    for (const filename of fs.readdirSync(folder)) {
      assert.ok(filename.endsWith(".ts"), `Unexpected generated file: ${filename}`);
      const source = ts.createSourceFile(filename, fs.readFileSync(path.join(folder, filename), "utf8"), ts.ScriptTarget.Latest, true);
      assert.equal(source.parseDiagnostics.length, 0);
      assert.equal(source.statements.length, 1, `Expected one isolated export: ${filename}`);
      const statement = source.statements[0];
      assert.ok(ts.isVariableStatement(statement));
      assert.equal(statement.declarationList.declarations.length, 1);
      const declaration = statement.declarationList.declarations[0];
      const name = declaration.name.getText(source);
      assert.ok(!Object.hasOwn(actual, name), `Duplicate generated export: ${name}`);
      const expression = ts.isAsExpression(declaration.initializer) ? declaration.initializer.expression : declaration.initializer;
      actual[name] = JSON.parse(expression.getText(source));
    }
  }
  assert.deepEqual(Object.keys(actual).sort(), Object.keys(canonical).sort());
  for (const [name, value] of Object.entries(canonical)) {
    assert.deepEqual(actual[name], value, `Schema/catalog semantics drifted: ${name}`);
  }
});
