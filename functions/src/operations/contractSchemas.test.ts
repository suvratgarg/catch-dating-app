import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import test from "node:test";
import Ajv, {AnySchema} from "ajv";
import addFormats from "ajv-formats";

const schemaNames = [
  "common",
  "run",
  "work_item",
  "action_receipt",
  "decision",
  "lease",
  "publication_plan",
  "rule_proposal",
  "rule_evaluation",
] as const;

function contractsDirectory(): string {
  const candidates = [
    path.resolve(process.cwd(), "contracts/operations"),
    path.resolve(process.cwd(), "../contracts/operations"),
    path.resolve(__dirname, "../../../contracts/operations"),
  ];
  const directory = candidates.find((candidate) => fs.existsSync(candidate));
  assert.ok(directory, "contracts/operations directory should be discoverable");
  return directory;
}

function readJson(filePath: string): unknown {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

test("draft-07 operation schemas accept their canonical fixtures", () => {
  const directory = contractsDirectory();
  const ajv = new Ajv({allErrors: true, strict: false});
  addFormats(ajv);
  for (const name of schemaNames) {
    ajv.addSchema(
      readJson(path.join(directory, `${name}.schema.json`)) as AnySchema
    );
  }
  for (const name of schemaNames.filter((name) => name !== "common")) {
    const schemaId = `https://catch.app/contracts/operations/${name}.schema.json`;
    const fixture = readJson(path.join(
      directory,
      "fixtures",
      "valid",
      `${name}.json`
    ));
    const validate = ajv.getSchema(schemaId);
    assert.ok(validate, `validator should exist for ${name}`);
    assert.equal(
      validate(fixture),
      true,
      `${name}: ${JSON.stringify(validate.errors)}`
    );
  }
});

test("draft-07 operation schemas reject unsafe lifecycle fixtures", () => {
  const directory = contractsDirectory();
  const ajv = new Ajv({allErrors: true, strict: false});
  addFormats(ajv);
  for (const name of schemaNames) {
    ajv.addSchema(
      readJson(path.join(directory, `${name}.schema.json`)) as AnySchema
    );
  }
  const fixtures = [
    ["work_item", "work_item_terminal_without_outcome"],
    ["rule_proposal", "rule_proposal_without_approval"],
  ] as const;
  for (const [schemaName, fixtureName] of fixtures) {
    const fixture = readJson(path.join(
      directory,
      "fixtures",
      "invalid",
      `${fixtureName}.json`
    )) as {document: unknown};
    const validate = ajv.getSchema(
      `https://catch.app/contracts/operations/${schemaName}.schema.json`
    );
    assert.ok(validate, `validator should exist for ${schemaName}`);
    assert.equal(validate(fixture.document), false, fixtureName);
  }
});
