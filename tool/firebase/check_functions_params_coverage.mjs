#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";

import {createFunctionsRequire} from "../lib/repo_paths.mjs";

import {materializedNonSecretParams} from
  "./prepare_functions_params_for_deploy.mjs";

const ts = createFunctionsRequire()("typescript");

function assert(condition, message) {
  if (!condition) throw new Error(message);
}

function optionalOption(name) {
  const offset = process.argv.indexOf(name);
  if (offset < 0) return undefined;
  assert(process.argv[offset + 1], `${name} requires a value`);
  return process.argv[offset + 1];
}

// Parse authored source without importing or executing it. Secret parameters
// resolve through Secret Manager and intentionally stay outside dotenv.
const parameterFactories = new Set([
  "defineBoolean", "defineString", "defineInt", "defineFloat", "defineList",
]);

function listTypeScriptSources(directory) {
  const files = [];
  for (const entry of fs.readdirSync(directory, {withFileTypes: true})) {
    const entryPath = path.join(directory, entry.name);
    if (entry.isDirectory()) {
      files.push(...listTypeScriptSources(entryPath));
    } else if (entry.isFile() && entry.name.endsWith(".ts")) {
      files.push(entryPath);
    }
  }
  return files.sort();
}

export function discoverDeclaredParams(functionsDir) {
  const sourceDir = path.join(functionsDir, "src");
  assert(fs.statSync(sourceDir).isDirectory(),
    `Functions source directory is missing: ${sourceDir}`);
  const declared = new Map();
  for (const file of listTypeScriptSources(sourceDir)) {
    const relative = path.relative(functionsDir, file);
    const source = ts.createSourceFile(file, fs.readFileSync(file, "utf8"),
      ts.ScriptTarget.Latest, true);
    assert(source.parseDiagnostics.length === 0,
      `Unable to parse Functions source: ${relative}`);
    const factories = new Set(parameterFactories);
    const namespaces = new Set();
    for (const statement of source.statements) {
      if (!ts.isImportDeclaration(statement) ||
          statement.moduleSpecifier.text !== "firebase-functions/params") continue;
      const bindings = statement.importClause?.namedBindings;
      if (bindings && ts.isNamespaceImport(bindings)) {
        namespaces.add(bindings.name.text);
      } else if (bindings && ts.isNamedImports(bindings)) {
        for (const element of bindings.elements) {
          const imported = element.propertyName?.text ?? element.name.text;
          if (parameterFactories.has(imported)) factories.add(element.name.text);
        }
      }
    }
    const visit = (node) => {
      if (ts.isImportDeclaration(node)) return;
      if (ts.isIdentifier(node) && factories.has(node.text)) {
        const directCall = ts.isCallExpression(node.parent) &&
          node.parent.expression === node;
        const namespaceMember = ts.isPropertyAccessExpression(node.parent) &&
          node.parent.name === node && ts.isIdentifier(node.parent.expression) &&
          namespaces.has(node.parent.expression.text) &&
          ts.isCallExpression(node.parent.parent) &&
          node.parent.parent.expression === node.parent;
        assert(directCall || namespaceMember,
          `Non-secret param factories must be called directly: ${relative}`);
      }
      if (ts.isIdentifier(node) && namespaces.has(node.text)) {
        assert(ts.isPropertyAccessExpression(node.parent) &&
          node.parent.expression === node,
        `Firebase params namespace must use explicit members: ${relative}`);
        if (parameterFactories.has(node.parent.name.text)) {
          assert(ts.isCallExpression(node.parent.parent) &&
            node.parent.parent.expression === node.parent,
          `Non-secret param factories must be called directly: ${relative}`);
        }
      }
      if (ts.isCallExpression(node)) {
        const callee = node.expression;
        const direct = ts.isIdentifier(callee) && factories.has(callee.text);
        const member = ts.isPropertyAccessExpression(callee) &&
          ts.isIdentifier(callee.expression) &&
          namespaces.has(callee.expression.text) &&
          parameterFactories.has(callee.name.text);
        if (direct || member) {
          const name = node.arguments[0];
          assert(name && (ts.isStringLiteral(name) ||
            ts.isNoSubstitutionTemplateLiteral(name)) &&
            /^[A-Za-z][A-Za-z0-9_]*$/.test(name.text),
          `Non-secret param must use a literal name: ${relative}`);
          if (!declared.has(name.text)) declared.set(name.text, []);
          declared.get(name.text).push(relative);
        }
      }
      ts.forEachChild(node, visit);
    };
    visit(source);
  }
  return declared;
}

function dotenvKeys(contents) {
  const keys = new Set();
  const populated = new Set();
  for (const line of contents.split("\n")) {
    const match = /^\s*(?:export\s+)?([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)$/.exec(line);
    if (!match) continue;
    assert(!keys.has(match[1]), `Duplicate dotenv param: ${match[1]}`);
    keys.add(match[1]);
    const value = match[2].trim();
    // Quoted whitespace is intentional for disabled legacy Meta identifiers.
    if (value && value !== '""' && value !== "''" && !value.startsWith("#")) {
      populated.add(match[1]);
    }
  }
  return populated;
}

export function checkParamsCoverage({functionsDir, envFile}) {
  const declared = discoverDeclaredParams(functionsDir);
  const materialized = new Set(materializedNonSecretParams);
  const uncovered = [];
  for (const [name, files] of [...declared.entries()].sort()) {
    if (!materialized.has(name)) uncovered.push({name, files});
  }
  const envMissing = [];
  if (envFile) {
    assert(fs.existsSync(envFile), `dotenv file is missing: ${envFile}`);
    const keys = dotenvKeys(fs.readFileSync(envFile, "utf8"));
    for (const name of declared.keys()) {
      if (!keys.has(name)) envMissing.push(name);
    }
  }
  return {declared, uncovered, envMissing};
}

function runCli() {
  const repoRoot = path.resolve(
    path.dirname(fileURLToPath(import.meta.url)), "../..");
  const functionsDir = path.resolve(
    optionalOption("--functions-dir") ?? path.join(repoRoot, "functions"));
  const envFile = optionalOption("--env-file");
  const result = checkParamsCoverage({functionsDir, envFile});
  let failed = false;
  for (const {name, files} of result.uncovered) {
    console.error(`Uncovered non-secret param ${name} declared in ` +
      `${files.join(", ")}; materialize it in ` +
      "tool/firebase/prepare_functions_params_for_deploy.mjs");
    failed = true;
  }
  for (const name of result.envMissing.sort()) {
    console.error(`Declared param ${name} has no value in ${envFile}`);
    failed = true;
  }
  if (failed) {
    process.exitCode = 1;
    return;
  }
  console.log(`All ${result.declared.size} declared non-secret Functions ` +
    "params are materialized for deploy" +
    (envFile ? ` and present in ${envFile}.` : "."));
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  try {
    runCli();
  } catch (error) {
    console.error(error.message);
    process.exitCode = 1;
  }
}
