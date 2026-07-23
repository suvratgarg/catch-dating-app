#!/usr/bin/env node
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";

const adminRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const repoRoot = path.resolve(adminRoot, "..");
const contractsRoot = path.join(repoRoot, "contracts");
const apiPath = path.join(adminRoot, "src/shared/api/adminApi.ts");
const outputPath = path.join(
  adminRoot,
  "src/generated/validators/adminCallableValidators.ts"
);
const checkOnly = process.argv.includes("--check");
const selfTest = process.argv.includes("--self-test");

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function snakeToCamel(value) {
  return value.replace(/_([a-z0-9])/gu, (_, character) => character.toUpperCase());
}

function callableNames() {
  const source = fs.readFileSync(apiPath, "utf8");
  return [...new Set(
    [...source.matchAll(/\(\s*functions,\s*"(admin[A-Z][A-Za-z0-9]+)"\s*\)/gu)]
      .map((match) => match[1])
  )].sort();
}

function referencedSchemaFiles(filePath, schema) {
  const files = [];
  const visit = (value) => {
    if (Array.isArray(value)) {
      value.forEach(visit);
      return;
    }
    if (!value || typeof value !== "object") return;
    if (typeof value.$ref === "string" && !value.$ref.startsWith("#")) {
      const relative = value.$ref.split("#", 1)[0];
      files.push(path.resolve(path.dirname(filePath), relative));
    }
    Object.values(value).forEach(visit);
  };
  visit(schema);
  return files;
}

function collectSchemas(entryPaths) {
  const schemas = new Map();
  const visit = (filePath) => {
    const resolved = path.resolve(filePath);
    if (schemas.has(resolved)) return;
    const schema = readJson(resolved);
    if (!schema.$id) throw new Error(`Schema ${resolved} is missing $id.`);
    schemas.set(resolved, schema);
    referencedSchemaFiles(resolved, schema).forEach(visit);
  };
  entryPaths.forEach(visit);
  return schemas;
}

function buildModel() {
  const names = callableNames();
  const requestPaths = new Map();
  const strictRequests = new Set();
  const callableDir = path.join(contractsRoot, "callables");
  for (const filename of fs.readdirSync(callableDir).filter((name) => name.endsWith(".schema.json"))) {
    const filePath = path.join(callableDir, filename);
    const schema = readJson(filePath);
    const base = filename.replace(/_payload\.schema\.json$/u, "");
    const inferred = snakeToCamel(base);
    const aliases = Array.isArray(schema["x-callable-aliases"]) ?
      schema["x-callable-aliases"] : [];
    for (const name of [inferred, ...aliases]) {
      if (!names.includes(name)) continue;
      requestPaths.set(name, filePath);
      strictRequests.add(name);
    }
  }

  const responsePaths = new Map([
    ["adminListActionExecutions", path.join(contractsRoot, "callable_responses/admin_list_action_executions_response.schema.json")],
    ["adminListIntakeOperations", path.join(contractsRoot, "callable_responses/admin_list_intake_operations_response.schema.json")],
    ["adminGetHostAnalytics", path.join(contractsRoot, "callable_responses/host_analytics_response.schema.json")],
    ["adminGetUserAnalytics", path.join(contractsRoot, "callable_responses/user_analytics_response.schema.json")],
  ]);
  const strictResponses = new Set(responsePaths.keys());
  const entryPaths = [...requestPaths.values(), ...responsePaths.values()];
  const schemas = collectSchemas(entryPaths);
  const requestSchemaIds = {};
  const responseSchemaIds = {};

  for (const name of names) {
    const requestPath = requestPaths.get(name);
    if (requestPath) {
      requestSchemaIds[name] = schemas.get(path.resolve(requestPath)).$id;
    } else {
      const schema = {
        $id: `https://catch.app/contracts/admin_runtime/${name}_payload.schema.json`,
        type: "object",
        additionalProperties: true,
      };
      schemas.set(schema.$id, schema);
      requestSchemaIds[name] = schema.$id;
    }

    const responsePath = responsePaths.get(name);
    if (responsePath) {
      responseSchemaIds[name] = schemas.get(path.resolve(responsePath)).$id;
    } else {
      const schema = {
        $id: `https://catch.app/contracts/admin_runtime/${name}_response.schema.json`,
        type: "object",
        additionalProperties: true,
      };
      schemas.set(schema.$id, schema);
      responseSchemaIds[name] = schema.$id;
    }
  }

  return {
    names,
    schemas: [...schemas.values()],
    requestSchemaIds,
    responseSchemaIds,
    strictRequests: [...strictRequests].sort(),
    strictResponses: [...strictResponses].sort(),
  };
}

function render(model) {
  const data = JSON.stringify(model, null, 2);
  return `// GENERATED FILE. Run: npm --workspace catch-admin run generate:callable-validators\n` +
`import Ajv, {type ErrorObject, type ValidateFunction} from "ajv";\n` +
`import addFormats from "ajv-formats";\n\n` +
`const model = ${data} as const;\n` +
`const ajv = new Ajv({allErrors: true, strict: false, validateSchema: false});\n` +
`addFormats(ajv);\n` +
`for (const schema of model.schemas) ajv.addSchema(schema);\n\n` +
`function validators(ids: Record<string, string>): Record<string, ValidateFunction> {\n` +
`  return Object.fromEntries(Object.entries(ids).map(([name, id]) => {\n` +
`    const validate = ajv.getSchema(id);\n` +
`    if (!validate) throw new Error(\`Missing generated validator for \${name}.\`);\n` +
`    return [name, validate];\n` +
`  }));\n` +
`}\n\n` +
`const requestValidators = validators(model.requestSchemaIds);\n` +
`const responseValidators = validators(model.responseSchemaIds);\n\n` +
`export const adminCallableValidationCoverage = {\n` +
`  callables: model.names,\n` +
`  strictRequests: model.strictRequests,\n` +
`  strictResponses: model.strictResponses,\n` +
`} as const;\n\n` +
`export class AdminCallableValidationError extends Error {\n` +
`  constructor(\n` +
`    readonly callable: string,\n` +
`    readonly direction: "request" | "response",\n` +
`    readonly instancePath: string,\n` +
`    readonly validationErrors: ErrorObject[]\n` +
`  ) {\n` +
`    const first = validationErrors[0];\n` +
`    super(\`Invalid \${direction} for \${callable} at \${instancePath}: \${first?.message ?? "schema validation failed"}\`);\n` +
`    this.name = "AdminCallableValidationError";\n` +
`  }\n` +
`}\n\n` +
`function validate(\n` +
`  direction: "request" | "response",\n` +
`  callable: string,\n` +
`  value: unknown\n` +
`) {\n` +
`  const validateFunction = direction === "request" ? requestValidators[callable] : responseValidators[callable];\n` +
`  if (!validateFunction) {\n` +
`    throw new AdminCallableValidationError(callable, direction, "/", [{\n` +
`      instancePath: "", schemaPath: "", keyword: "missing-validator", params: {}, message: "validator is not generated",\n` +
`    }]);\n` +
`  }\n` +
`  if (validateFunction(value)) return;\n` +
`  const errors = validateFunction.errors ?? [];\n` +
`  const instancePath = errors[0]?.instancePath || "/";\n` +
`  throw new AdminCallableValidationError(callable, direction, instancePath, [...errors]);\n` +
`}\n\n` +
`export function validateAdminCallableRequest(callable: string, value: unknown) {\n` +
`  validate("request", callable, value);\n` +
`}\n\n` +
`export function validateAdminCallableResponse(callable: string, value: unknown) {\n` +
`  validate("response", callable, value);\n` +
`}\n`;
}

const model = buildModel();
const output = render(model);
if (selfTest) {
  const changed = structuredClone(model);
  changed.schemas[0] = {...changed.schemas[0], title: "simulated schema drift"};
  assert.notEqual(render(changed), output);
  console.log("Admin callable validator drift self-test passed.");
  process.exit(0);
}
if (checkOnly) {
  const current = fs.existsSync(outputPath) ? fs.readFileSync(outputPath, "utf8") : "";
  if (current !== output) {
    console.error("Admin callable validators are stale. Run npm --workspace catch-admin run generate:callable-validators.");
    process.exit(1);
  }
  console.log(`Admin callable validators are current (${model.names.length} callables, ${model.strictRequests.length} strict request schemas, ${model.strictResponses.length} strict response schemas).`);
  process.exit(0);
}
fs.mkdirSync(path.dirname(outputPath), {recursive: true});
fs.writeFileSync(outputPath, output);
console.log(`Generated validators for ${model.names.length} admin callables (${model.strictRequests.length} strict requests, ${model.strictResponses.length} strict responses).`);
