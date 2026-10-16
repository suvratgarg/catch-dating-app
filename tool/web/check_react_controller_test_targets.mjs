#!/usr/bin/env node
import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import ts from "typescript";
import {fromRepo} from "../lib/repo_paths.mjs";

try {
  if (process.argv.includes("--self-test")) await runSelfTest();
  else await runCheck();
} catch (error) {
  console.error(`React controller test-target check failed: ${error.message}`);
  process.exitCode = 1;
}

async function runCheck() {
  const manifest = JSON.parse(fs.readFileSync(fromRepo("tool/web/react_controller_test_targets.json"), "utf8"));
  const selectedByOwner = new Map();
  const optionsByOwner = new Map();
  for (const owner of ["admin", "website"]) {
    const root = fromRepo(owner);
    selectedByOwner.set(owner, await discoverUnitTests(root));
    const config = ts.readConfigFile(path.join(root, "tsconfig.json"), ts.sys.readFile);
    if (config.error) throw new Error(ts.flattenDiagnosticMessageText(config.error.messageText, "\n"));
    const parsed = ts.parseJsonConfigFileContent(config.config, ts.sys, root);
    if (parsed.errors.length) throw new Error(parsed.errors.map(error =>
      ts.flattenDiagnosticMessageText(error.messageText, "\n")).join("\n"));
    optionsByOwner.set(owner, parsed.options);
  }
  const findings = validateManifest(manifest, discoverControllerSources(), relative => {
    const absolute = fromRepo(relative);
    return fs.existsSync(absolute) ? fs.readFileSync(absolute, "utf8") : null;
  }, {root: fromRepo("."), selectedByOwner, optionsByOwner});
  if (findings.length) throw new Error(`${findings.length} finding(s):\n- ${findings.join("\n- ")}`);
  const counts = Object.groupBy(manifest.targets, target => target.status);
  console.log(`React controller test-target check passed: ${manifest.targets.length} classified hooks ` +
    `(${Object.entries(counts).map(([status, targets]) => `${status}=${targets.length}`).join(", ")}).`);
}

// Use the owning Vitest projects' actual include/exclude rules. File discovery
// does not collect or execute test modules, setup files or controller imports.
async function discoverUnitTests(root) {
  const {createVitest} = await import("vitest/node");
  const context = await createVitest("test", {root, project: ["unit"], watch: false, run: true});
  try {
    const specifications = await context.globTestSpecifications();
    return new Set(specifications.filter(spec => spec.project.name === "unit")
      .map(spec => path.resolve(spec.moduleId)));
  } finally {
    await context.close();
  }
}

function discoverControllerSources() {
  const roots = ["admin/src/features", "website/src/features"];
  const sources = new Set();
  for (const relativeRoot of roots) {
    walk(fromRepo(relativeRoot), (absolutePath) => {
      const relativePath = path.relative(fromRepo("."), absolutePath).split(path.sep).join("/");
      if (/\/use[A-Z][A-Za-z0-9]*(?:Controller|Mutation)\.tsx?$/u.test(relativePath)) {
        sources.add(relativePath);
      }
    });
  }
  return sources;
}

function walk(root, visit) {
  for (const entry of fs.readdirSync(root, {withFileTypes: true})) {
    const absolutePath = path.join(root, entry.name);
    if (entry.isDirectory()) walk(absolutePath, visit);
    else if (entry.isFile()) visit(absolutePath);
  }
}

function validateManifest(document, discovered, readSource, {root, selectedByOwner, optionsByOwner}) {
  const findings = [];
  if (document.schemaVersion !== 1) findings.push("schemaVersion must be 1");
  if (!Array.isArray(document.targets)) return [...findings, "targets must be an array"];
  const allowedStatuses = new Set(["required", "planned", "exempt"]);
  const seen = new Set();
  const suites = new Map();
  for (const target of document.targets) {
    if (!target.source) { findings.push("every target needs a source path"); continue; }
    if (seen.has(target.source)) findings.push(`${target.source}: duplicate target`);
    seen.add(target.source);
    if (!allowedStatuses.has(target.status)) findings.push(`${target.source}: unsupported status ${target.status}`);
    if (!discovered.has(target.source)) findings.push(`${target.source}: target is missing or no longer a controller/mutation hook`);
    if (target.status === "exempt" && !target.reason) findings.push(`${target.source}: exempt targets need a reason`);
    if (target.status !== "required") continue;
    if (!target.test) { findings.push(`${target.source}: required target needs a test path`); continue; }
    const source = readSource(target.test);
    if (source === null) { findings.push(`${target.source}: missing required test ${target.test}`); continue; }
    const owner = target.source.split("/")[0];
    const fileName = path.resolve(root, target.test);
    if (!target.test.startsWith(`${owner}/src/`) || !selectedByOwner.get(owner)?.has(fileName)) {
      findings.push(`${target.test}: not selected by the owning ${owner} Vitest unit project`);
    }
    if (!suites.has(fileName)) suites.set(fileName, inspectSuite(fileName, source, optionsByOwner.get(owner)));
    const suite = suites.get(fileName);
    if (suite.parseError) { findings.push(`${target.test}: invalid TypeScript: ${suite.parseError}`); continue; }
    if (!suite.imports.has(path.resolve(root, target.source))) {
      findings.push(`${target.test}: does not runtime-import exact target ${target.source}`);
    }
    if (!suite.hasTest) findings.push(`${target.test}: has no provable non-skipped Vitest test registration`);
  }
  for (const source of [...discovered].sort()) {
    if (!seen.has(source)) findings.push(`${source}: unclassified controller/mutation hook`);
  }
  return findings;
}

function inspectSuite(fileName, source, compilerOptions = {}) {
  const ast = ts.createSourceFile(fileName, source, ts.ScriptTarget.Latest, true);
  if (ast.parseDiagnostics.length) return {parseError: ts.flattenDiagnosticMessageText(ast.parseDiagnostics[0].messageText, "\n")};
  const imports = new Set();
  const bindings = new Map();
  for (const node of ast.statements) {
    if (!ts.isImportDeclaration(node) || !ts.isStringLiteral(node.moduleSpecifier)) continue;
    const clause = node.importClause;
    if (!clause || clause.isTypeOnly) continue;
    const named = clause.namedBindings;
    const runtimeNames = named && ts.isNamedImports(named) ? named.elements.filter(item => !item.isTypeOnly) : [];
    if (!clause.name && !(named && ts.isNamespaceImport(named)) && !runtimeNames.length) continue;
    const specifier = node.moduleSpecifier.text;
    const resolution = ts.resolveModuleName(specifier, fileName, compilerOptions, ts.sys).resolvedModule;
    if (resolution) imports.add(path.resolve(resolution.resolvedFileName));
    if (specifier !== "vitest") continue;
    if (named && ts.isNamespaceImport(named)) bindings.set(named.name.text, "namespace");
    for (const item of runtimeNames) {
      const role = (item.propertyName ?? item.name).text;
      if (["it", "test", "describe", "suite"].includes(role)) bindings.set(item.name.text, role);
    }
  }
  // This proves registration structure, not behavioral assertions. Only direct
  // registrations and recognized suite callbacks are visited; an uncalled
  // function, condition or skipped suite cannot manufacture coverage.
  function registration(expression, scope) {
    if (ts.isIdentifier(expression)) {
      const role = scope.get(expression.text);
      return role ? {role, modifiers: []} : null;
    }
    if (ts.isPropertyAccessExpression(expression)) {
      const base = registration(expression.expression, scope);
      if (!base) return null;
      if (base.role === "namespace") {
        return ["it", "test", "describe", "suite"].includes(expression.name.text)
          ? {role: expression.name.text, modifiers: []} : null;
      }
      return {...base, modifiers: [...base.modifiers, expression.name.text]};
    }
    if (ts.isCallExpression(expression)) {
      const base = registration(expression.expression, scope);
      // A literal nonempty case table is a bounded proof; unknown factories or
      // conditionals are deliberately not evaluated by this source checker.
      if (base?.modifiers.at(-1) !== "each" || expression.arguments.length !== 1 ||
          !ts.isArrayLiteralExpression(expression.arguments[0]) ||
          !expression.arguments[0].elements.length || expression.arguments[0].elements.some(element =>
            ts.isSpreadElement(element) || ts.isOmittedExpression(element))) return null;
      return {...base, modifiers: base.modifiers.slice(0, -1)};
    }
    if (ts.isTaggedTemplateExpression(expression)) {
      const base = registration(expression.tag, scope);
      if (base?.modifiers.at(-1) !== "each" || !ts.isTemplateExpression(expression.template)) return null;
      return {...base, modifiers: base.modifiers.slice(0, -1)};
    }
    return null;
  }
  function registrations(statements, inherited, parameters = [], ownName) {
    const scope = new Map(inherited);
    const shadow = node => {
      if (ts.isIdentifier(node)) scope.delete(node.text);
      else ts.forEachChild(node, shadow);
    };
    if (ownName) shadow(ownName);
    for (const parameter of parameters) shadow(parameter.name);
    const hoisted = node => {
      if (ts.isFunctionLike(node) || ts.isClassLike(node)) return;
      if (ts.isVariableDeclarationList(node) && !(node.flags & ts.NodeFlags.BlockScoped)) {
        node.declarations.forEach(item => shadow(item.name));
      }
      ts.forEachChild(node, hoisted);
    };
    for (const statement of statements) {
      hoisted(statement);
      if (ts.isVariableStatement(statement)) statement.declarationList.declarations.forEach(item => shadow(item.name));
      else if ((ts.isFunctionDeclaration(statement) || ts.isClassDeclaration(statement)) && statement.name) shadow(statement.name);
    }
    for (const statement of statements) {
      // Do not evaluate control flow or assume registration continues past an
      // early exit, conditional, loop, try block or other statement container.
      if (ts.isReturnStatement(statement) || ts.isThrowStatement(statement) ||
          ts.isIfStatement(statement) || ts.isSwitchStatement(statement) ||
          ts.isIterationStatement(statement, false) || ts.isTryStatement(statement) ||
          ts.isBlock(statement) || ts.isLabeledStatement(statement) || ts.isWithStatement(statement)) return false;
      if (!ts.isExpressionStatement(statement) || !ts.isCallExpression(statement.expression)) continue;
      const call = statement.expression;
      const match = registration(call.expression, scope);
      if (!match || match.modifiers.some(modifier => !["concurrent", "sequential", "fails", "only"].includes(modifier))) continue;
      if (call.arguments.length === 3) {
        const options = call.arguments[1];
        if (!ts.isObjectLiteralExpression(options) || options.properties.some(property =>
          !ts.isPropertyAssignment(property) || ts.isComputedPropertyName(property.name) ||
          ["skip", "todo"].includes(property.name.text) && property.initializer.kind !== ts.SyntaxKind.FalseKeyword)) continue;
      } else if (call.arguments.length !== 2) continue;
      const callback = call.arguments.at(-1);
      if (call.arguments.length < 2 || !callback || !(ts.isArrowFunction(callback) || ts.isFunctionExpression(callback))) continue;
      if (match.role === "it" || match.role === "test") return true;
      if ((match.role === "describe" || match.role === "suite") &&
          registrations(ts.isBlock(callback.body) ? callback.body.statements :
            [ts.factory.createExpressionStatement(callback.body)], scope, callback.parameters, callback.name)) return true;
    }
    return false;
  }
  return {imports, hasTest: registrations(ast.statements, bindings)};
}

async function runSelfTest() {
  const root = fs.realpathSync(fs.mkdtempSync(path.join(os.tmpdir(), "catch-controller-proof-")));
  const sourcePath = "website/src/example/useExampleController.ts";
  const testPath = "website/src/example/useExampleController.test.tsx";
  const target = {source: sourcePath, test: testPath, status: "required"};
  const write = (relative, text) => {
    const destination = path.join(root, relative);
    fs.mkdirSync(path.dirname(destination), {recursive: true});
    fs.writeFileSync(destination, text);
  };
  const options = {root,
    selectedByOwner: new Map([["website", new Set([path.join(root, testPath)])]]),
    optionsByOwner: new Map([["website", {moduleResolution: ts.ModuleResolutionKind.Bundler}]]),
  };
  const inspect = (source, entries = [target], overrides = {}) => validateManifest(
    {schemaVersion: 1, targets: entries}, new Set(entries.map(entry => entry.source)),
    () => source, {...options, ...overrides});
  const imports = "import {it, test, describe} from 'vitest'; import {useExampleController} from './useExampleController';\n";
  const normal = "it('works', () => useExampleController());";
  try {
    write(sourcePath, "export function useExampleController() {}\n");
    write("website/src/other/useExampleController.ts", "export function useExampleController() {}\n");
    for (const [name, source] of Object.entries({
      comments: "// useExampleController\n// it('fake', () => {});",
      strings: "const text = `useExampleController it('fake', () => {})`;",
      wrongTarget: "import {useExampleController} from '../other/useExampleController'; import {it} from 'vitest'; " + normal,
      typeOnly: "import type {useExampleController} from './useExampleController'; import {it} from 'vitest'; " + normal,
      typeSpecifier: "import {type useExampleController} from './useExampleController'; import {it} from 'vitest'; " + normal,
      unrelated: "// useExampleController\nimport {it} from 'vitest'; it('other', () => {});",
      skipped: imports + "it.skip('skip', () => useExampleController());",
      skippedSuite: imports + "describe.skip('skip', () => { " + normal + " });",
      todo: imports + "it.todo('later');",
      skippedOptions: imports + "it('skip', {skip: true}, () => useExampleController());",
      todoOptions: imports + "it('later', {todo: true}, () => useExampleController());",
      suiteOptions: imports + "describe('skip', {skip: true}, () => { " + normal + " });",
      unknownOptions: imports + "it('unknown', options, () => useExampleController());",
      spreadOptions: imports + "it('unknown', {...options}, () => useExampleController());",
      missingCallback: imports + "it('later');",
      fakeTest: "import {useExampleController} from './useExampleController'; function test() {} test('fake', () => {});",
      uncalled: imports + "function neverCalled() { " + normal + " }",
      earlyReturn: imports + "describe('suite', () => { return; " + normal + " });",
      earlyThrow: imports + "describe('suite', () => { throw new Error('stop'); " + normal + " });",
      conditionalReturn: imports + "describe('suite', () => { if (true) return; " + normal + " });",
      conditionalThrow: imports + "describe('suite', () => { if (condition) throw new Error('stop'); " + normal + " });",
      namedCallback: imports + "describe('suite', function it() { it('fake', () => {}); });",
      hoistedVar: imports + "describe('suite', () => { { var it = () => {}; } " + normal + " });",
      shadowed: imports + "describe('suite', (it) => { " + normal + " });",
      shadowedLocal: imports + "describe('suite', () => { const it = () => {}; " + normal + " });",
      conditional: imports + "if (false) { " + normal + " }",
      conditionalFactory: imports + "it.runIf(false)('case', () => useExampleController());",
      emptyEach: imports + "test.each([])('empty', () => useExampleController());",
      skippedEach: imports + "test.skip.each([1])('skip', () => useExampleController());",
      malformed: imports + "it('broken', () => {",
    })) assert.ok(inspect(source).length, `accepted ${name}`);

    for (const [name, source] of Object.entries({
      ordinary: imports + normal,
      nestedHelperScope: imports + "function helper() { var it = () => {}; return; } " + normal,
      literalOptions: imports + "it('works', {timeout: 100, skip: false, todo: false}, () => useExampleController());",
      jsExtension: imports.replace("./useExampleController", "./useExampleController.js") + normal,
      aliasTarget: "import {useExampleController as hook} from './useExampleController'; import {it} from 'vitest'; it('case', () => hook());",
      aliasTest: "import {useExampleController} from './useExampleController'; import {test as check} from 'vitest'; check('case', () => useExampleController());",
      namespace: "import {useExampleController} from './useExampleController'; import * as v from 'vitest'; v.describe('suite', () => v.it('case', () => useExampleController()));",
      nested: imports + "describe('outer', () => { describe('inner', () => { " + normal + " }); });",
      each: imports + "test.each([1, 2])('case %s', () => useExampleController());",
      taggedEach: imports + "test.each`value\n${1}`('case $value', () => useExampleController());",
      eachSuite: imports + "describe.each([1])('suite %s', () => { " + normal + " });",
      mixed: imports + "it.skip('skip', () => {}); " + normal,
    })) assert.deepEqual(inspect(source), [], `rejected ${name}`);

    const second = {source: "website/src/example/useOtherController.ts", test: testPath, status: "required"};
    write(second.source, "export function useOtherController() {}\n");
    assert.deepEqual(inspect(imports + "import {useOtherController} from './useOtherController'; " + normal +
      "it('other', () => useOtherController());", [target, second]), []);
    const aliasOptions = new Map([["website", {moduleResolution: ts.ModuleResolutionKind.Bundler,
      paths: {"@hooks/*": [path.join(root, "website/src/example/*")]}}]]);
    assert.deepEqual(inspect(imports.replace("./useExampleController", "@hooks/useExampleController") + normal,
      [target], {optionsByOwner: aliasOptions}), []);
    assert.ok(inspect(null).some(finding => finding.includes("missing required test")));
    assert.ok(inspect(imports + normal, [target], {selectedByOwner: new Map()})
      .some(finding => finding.includes("not selected")));
    assert.ok(inspect(imports + normal, [{...target, test: "admin/src/example.test.ts"}])
      .some(finding => finding.includes("not selected")));
    assert.ok(validateManifest({schemaVersion: 1, targets: []}, new Set([sourcePath]), () => null, options)
      .some(finding => finding.includes("unclassified")));

    // Real Vitest project discovery must honor include/exclude/project identity
    // without evaluating any fixture module or setup hook (all throw if loaded).
    const fixtureRoot = path.join(root, "website");
    write("website/vitest.config.mjs", `export default {test: {projects: [
      {test: {name: 'unit', include: ['src/**/*.test.tsx'], exclude: ['src/excluded.test.tsx'],
        setupFiles: ['src/setup.ts'], globalSetup: ['src/global-setup.ts']}},
      {test: {name: 'other', include: ['src/other-project.ts']}}
    ]}};`);
    for (const file of [testPath, "website/src/excluded.test.tsx", "website/src/other-project.ts",
      "website/src/setup.ts", "website/src/global-setup.ts"]) {
      write(file, "throw new Error('Discovery must not execute this module');\n");
    }
    const selected = await discoverUnitTests(fixtureRoot);
    assert.deepEqual([...selected], [path.join(root, testPath)]);
    const actualSelection = new Map([["website", selected]]);
    assert.deepEqual(inspect(imports + normal, [target], {selectedByOwner: actualSelection}), []);
    assert.ok(inspect(imports + normal, [{...target, test: "website/src/excluded.test.tsx"}],
      {selectedByOwner: actualSelection}).some(finding => finding.includes("not selected")));
    assert.ok(inspect(imports + normal, [{...target, test: "website/src/other-project.ts"}],
      {selectedByOwner: actualSelection}).some(finding => finding.includes("not selected")));
    console.log("React controller test-target self-test passed: 30 negative and 12 positive registration fixtures, shared suite, resolution and real project discovery.");
  } finally {
    fs.rmSync(root, {recursive: true, force: true});
  }
}
