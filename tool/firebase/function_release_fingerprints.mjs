import assert from "node:assert/strict";
import {createHash} from "node:crypto";
import {createRequire} from "node:module";
import path from "node:path";

export const FUNCTION_FINGERPRINT_SCHEMA = "catch.function-release-fingerprints/v1";
const hash = (value) => createHash("sha256").update(value).digest("hex");
const require = createRequire(import.meta.url);

// Analyze runtime declarations, not module filenames: a module may export many
// independent Functions. Both source emission and immutable compiled packages
// pass through the same CommonJS parser. No application module is executed.
export function fingerprintRuntimeExports({modules, entrypoint = "index.js", targets, parser}) {
  const ts = parser ?? require("typescript");
  assert.ok(modules instanceof Map && modules.has(entrypoint), "Exact runtime module map required.");
  assert.ok(Array.isArray(targets) && targets.length && new Set(targets).size === targets.length &&
    targets.every((name) => /^functions:[A-Za-z][A-Za-z0-9_-]*$/.test(name)), "Unique authorized Function exports required.");
  const printer = ts.createPrinter({removeComments: true});
  const parsed = new Map();
  const canonical = (node, source) => printer.printNode(ts.EmitHint.Unspecified, node, source);
  const helperEmission = ts.transpileModule('import value from "first"; import * as namespace from "second"; value.consume(namespace);',
    {compilerOptions: {module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2022, esModuleInterop: true}}).outputText;
  const helperSource = ts.createSourceFile("compiler-helpers.js", helperEmission, ts.ScriptTarget.Latest, true, ts.ScriptKind.JS);
  const compilerHelpers = new Map();
  for (const statement of helperSource.statements) if (ts.isVariableStatement(statement)) for (const declaration of statement.declarationList.declarations) {
    if (ts.isIdentifier(declaration.name) && declaration.name.text.startsWith("__")) compilerHelpers.set(declaration.name.text, canonical(declaration, helperSource));
  }
  const property = (node) => ts.isPropertyAccessExpression(node) ? node.name.text :
    ts.isElementAccessExpression(node) && ts.isStringLiteralLike(node.argumentExpression) ? node.argumentExpression.text : null;
  const isExports = (node) => (ts.isPropertyAccessExpression(node) || ts.isElementAccessExpression(node)) &&
    ts.isIdentifier(node.expression) && node.expression.text === "exports";
  const requireLiteral = (node) => {
    if (ts.isCallExpression(node) && ts.isIdentifier(node.expression) && node.expression.text === "require" &&
        node.arguments.length === 1 && ts.isStringLiteralLike(node.arguments[0])) return node.arguments[0].text;
    if (ts.isCallExpression(node) && ts.isIdentifier(node.expression) &&
        ["__importStar", "__importDefault"].includes(node.expression.text) && node.arguments.length === 1) return requireLiteral(node.arguments[0]);
    return null;
  };
  const resolve = (importer, specifier) => {
    if (!specifier.startsWith(".")) return null;
    const stem = path.posix.normalize(path.posix.join(path.posix.dirname(importer), specifier));
    assert.ok(!stem.startsWith("../") && !path.posix.isAbsolute(stem), "Runtime import escapes package.");
    const found = [stem, stem + ".js", stem + "/index.js"].find((name) => modules.has(name));
    assert.ok(found && found.endsWith(".js"), `Unresolved runtime import: ${importer} -> ${specifier}`);
    return found;
  };
  const namespaceKey = (importer, specifier) => {
    if (!specifier.startsWith(".")) return "external:" + specifier;
    const stem = path.posix.normalize(path.posix.join(path.posix.dirname(importer), specifier));
    const name = [stem, stem + ".js", stem + "/index.js"].find((candidate) => modules.has(candidate));
    return "local:" + (name ?? stem);
  };
  const untrustedNamespaces = new Set();
  // CommonJS caches namespace objects across consumers. Determine distrust
  // before any initializer receives a purity proof, including imports inside
  // deferred functions. Unreachable mutation is conservatively retained.
  for (const [name, text] of modules) {
    if (!name.endsWith(".js")) continue;
    const source = ts.createSourceFile(name, text, ts.ScriptTarget.Latest, true, ts.ScriptKind.JS);
    assert.equal(source.parseDiagnostics.length, 0, `Cannot parse runtime namespace: ${name}`);
    const bindings = new Map();
    const collect = (node) => {
      if (ts.isVariableDeclaration(node) && ts.isIdentifier(node.name) && node.initializer) {
        const specifier = requireLiteral(node.initializer);
        if (specifier) {
          if (!bindings.has(node.name.text)) bindings.set(node.name.text, new Set());
          bindings.get(node.name.text).add(namespaceKey(name, specifier));
        }
      }
      ts.forEachChild(node, collect);
    };
    collect(source);
    const inspect = (node) => {
      if (ts.isIdentifier(node) && bindings.has(node.text)) {
        const parent = node.parent;
        if (!(ts.isVariableDeclaration(parent) && parent.name === node)) {
          if ((ts.isPropertyAccessExpression(parent) || ts.isElementAccessExpression(parent)) && parent.expression === node) {
            const use = parent.parent;
            if (ts.isBinaryExpression(use) && use.left === parent && use.operatorToken.kind >= ts.SyntaxKind.FirstAssignment &&
                use.operatorToken.kind <= ts.SyntaxKind.LastAssignment || ts.isDeleteExpression(use) ||
                ts.isPrefixUnaryExpression(use) || ts.isPostfixUnaryExpression(use)) for (const key of bindings.get(node.text)) untrustedNamespaces.add(key);
          } else { for (const key of bindings.get(node.text)) untrustedNamespaces.add(key); }
        }
      }
      if (ts.isCallExpression(node) && ts.isIdentifier(node.expression) && node.expression.text === "require" &&
          node.arguments.length === 1 && ts.isStringLiteralLike(node.arguments[0])) {
        const parent = node.parent;
        const bound = ts.isVariableDeclaration(parent) && parent.initializer === node && ts.isIdentifier(parent.name);
        const bare = ts.isExpressionStatement(parent);
        const compilerWrapper = ts.isCallExpression(parent) && ts.isIdentifier(parent.expression) &&
          ["__importStar", "__importDefault"].includes(parent.expression.text) && parent.arguments.length === 1 && parent.arguments[0] === node &&
          ts.isVariableDeclaration(parent.parent) && parent.parent.initializer === parent && ts.isIdentifier(parent.parent.name);
        if (!bound && !bare && !compilerWrapper) untrustedNamespaces.add(namespaceKey(name, node.arguments[0].text));
      }
      // module.exports can expose or replace the namespace outside the strict
      // compiler-style export forms understood by this analyzer.
      if (ts.isPropertyAccessExpression(node) && ts.isIdentifier(node.expression) &&
          node.expression.text === "module" && node.name.text === "exports") untrustedNamespaces.add("local:" + name);
      if (node.kind === ts.SyntaxKind.ThisKeyword) {
        const parent = node.parent;
        if ((ts.isPropertyAccessExpression(parent) || ts.isElementAccessExpression(parent)) && parent.expression === node) {
          const use = parent.parent;
          if (ts.isBinaryExpression(use) && use.left === parent && use.operatorToken.kind >= ts.SyntaxKind.FirstAssignment &&
              use.operatorToken.kind <= ts.SyntaxKind.LastAssignment || ts.isDeleteExpression(use) ||
              ts.isPrefixUnaryExpression(use) || ts.isPostfixUnaryExpression(use)) untrustedNamespaces.add("local:" + name);
        } else if (!(ts.isBinaryExpression(parent) && parent.left === node &&
            parent.operatorToken.kind === ts.SyntaxKind.AmpersandAmpersandToken)) {
          untrustedNamespaces.add("local:" + name);
        }
      }
      ts.forEachChild(node, inspect);
    };
    inspect(source);
  }
  const trustedNamespace = (current, imported) => imported.trusted &&
    !untrustedNamespaces.has(namespaceKey(current.name, imported.specifier));
  const voidExports = (node) => ts.isVoidExpression(node) && ts.isNumericLiteral(node.expression) && node.expression.text === "0" ||
    ts.isBinaryExpression(node) && node.operatorToken.kind === ts.SyntaxKind.EqualsToken &&
      isExports(node.left) && voidExports(node.right);
  const calleeOf = (node) => {
    let callee = node;
    if (ts.isParenthesizedExpression(callee) && ts.isBinaryExpression(callee.expression) &&
        callee.expression.operatorToken.kind === ts.SyntaxKind.CommaToken) callee = callee.expression.right;
    return callee;
  };
  const triggerFactories = new Set(["onCall", "onRequest", "onSchedule", "onTaskDispatched", "onMessagePublished",
    "onDocumentCreated", "onDocumentUpdated", "onDocumentDeleted", "onDocumentWritten",
    "onDocumentCreatedWithAuthContext", "onDocumentUpdatedWithAuthContext", "onDocumentDeletedWithAuthContext", "onDocumentWrittenWithAuthContext",
    "onObjectFinalized", "onObjectDeleted", "onObjectArchived", "onObjectMetadataUpdated"]);
  const parameterFactories = new Set(["defineString", "defineInt", "defineBoolean", "defineSecret"]);
  const firebaseImport = (name) => name === "firebase-functions" || name.startsWith("firebase-functions/");
  const hasBinding = (node, name) => node && (ts.isIdentifier(node) ? node.text === name :
    (ts.isObjectBindingPattern(node) || ts.isArrayBindingPattern(node)) && node.elements.some((item) => item.name && hasBinding(item.name, name)));
  const functionShadow = (node, name) => {
    let scope = node.parent;
    while (scope && !ts.isSourceFile(scope)) {
      if (ts.isFunctionLike(scope)) {
        if (scope.parameters.some((parameter) => hasBinding(parameter.name, name)) || hasBinding(scope.name, name)) return true;
        let found = false;
        const visit = (child) => {
          if (child !== scope && ts.isFunctionLike(child)) return;
          if ((ts.isVariableDeclaration(child) || ts.isClassDeclaration(child) || ts.isCatchClause(child)) &&
              hasBinding(child.name ?? child.variableDeclaration?.name, name)) found = true;
          ts.forEachChild(child, visit);
        };
        if (scope.body) visit(scope.body);
        if (found) return true;
      }
      scope = scope.parent;
    }
    return false;
  };
  const safeInitializer = (node, current, seen = new Set()) => {
    if (!node || ts.isLiteralExpression(node) || ts.isArrowFunction(node) ||
        ts.isFunctionExpression(node) || [ts.SyntaxKind.TrueKeyword, ts.SyntaxKind.FalseKeyword, ts.SyntaxKind.NullKeyword].includes(node.kind)) return true;
    const safe = (child) => safeInitializer(child, current, seen);
    if (ts.isIdentifier(node)) return current.units.has(node.text) || current.imports.has(node.text) || ["undefined", "NaN", "Infinity"].includes(node.text);
    if (ts.isParenthesizedExpression(node)) return safe(node.expression);
    if (ts.isArrayLiteralExpression(node)) return node.elements.every(safe);
    if (ts.isObjectLiteralExpression(node)) return node.properties.every((item) =>
      ts.isPropertyAssignment(item) ? (!ts.isComputedPropertyName(item.name) || ts.isLiteralExpression(item.name.expression)) && safe(item.initializer) :
      ts.isShorthandPropertyAssignment(item) ? safe(item.name) :
      (ts.isMethodDeclaration(item) || ts.isGetAccessorDeclaration(item) || ts.isSetAccessorDeclaration(item)) &&
        (!ts.isComputedPropertyName(item.name) || ts.isLiteralExpression(item.name.expression)));
    // Only exact, immutable local data exports can prove a stored function
    // value harmless. Unknown getters remain observable initialization.
    if (ts.isPropertyAccessExpression(node) && ts.isIdentifier(node.expression)) {
      const imported = current.imports.get(node.expression.text);
      return Boolean(imported?.local && trustedNamespace(current, imported) && !functionShadow(node.expression, node.expression.text) && plainFunctionExport(imported.local, node.name.text));
    }
    if (ts.isCallExpression(node)) {
      const callee = calleeOf(node.expression);
      if (ts.isPropertyAccessExpression(callee) && ts.isIdentifier(callee.expression)) {
        const imported = current.imports.get(callee.expression.text);
        if (imported && trustedNamespace(current, imported) && !functionShadow(callee.expression, callee.expression.text) && !imported.local && firebaseImport(imported.specifier) &&
            (triggerFactories.has(callee.name.text) || parameterFactories.has(callee.name.text))) return node.arguments.every(safe);
      }
      // Unknown calls can mutate state or throw, even if a helper currently
      // appears to return a literal. No general helper/constructor/operator
      // purity assumption is sufficient for deployment authority.
    }
    return false;
  };
  function plainFunctionExport(name, symbol, seen = new Set()) {
    const key = name + "#" + symbol;
    if (seen.has(key)) return false;
    const next = new Set(seen); next.add(key);
    const current = module(name);
    if (!current.complete || !current.plainExports) return false;
    const exported = current.exports.get(symbol);
    if (exported?.module) return plainFunctionExport(exported.module, exported.symbol, next);
    const unit = exported && current.units.get(exported.binding);
    return Boolean(unit && (ts.isFunctionDeclaration(unit.node) ||
      unit.initializer && (ts.isArrowFunction(unit.initializer) || ts.isFunctionExpression(unit.initializer))));
  }
  function module(name) {
    if (parsed.has(name)) return parsed.get(name);
    const text = modules.get(name);
    assert.equal(typeof text, "string", `Missing runtime module: ${name}`);
    const source = ts.createSourceFile(name, text, ts.ScriptTarget.Latest, true, ts.ScriptKind.JS);
    assert.equal(source.parseDiagnostics.length, 0, `Cannot parse runtime module: ${name}`);
    const inspectBindings = (node) => {
      if ((ts.isFunctionDeclaration(node) || ts.isVariableDeclaration(node) || ts.isParameter(node)) &&
          node.name && ts.isIdentifier(node.name) && node.name.text === "require") {
        throw new Error(`Shadowed require prevents runtime analysis: ${name}`);
      }
      ts.forEachChild(node, inspectBindings);
    };
    inspectBindings(source);
    const value = {name, source, units: new Map(), imports: new Map(), exports: new Map(), bootstrap: [], exportEvents: [], plainExports: true};
    parsed.set(name, value);
    const add = (id, node, initializer = null) => {
      assert.ok(!value.units.has(id), `Duplicate runtime declaration: ${name}#${id}`);
      value.units.set(id, {id, node, initializer, code: canonical(node, source)});
    };
    for (const statement of source.statements) {
      if (ts.isVariableStatement(statement)) {
        for (const declaration of statement.declarationList.declarations) {
          assert.ok(ts.isIdentifier(declaration.name), `Unsupported runtime binding: ${name}`);
          const specifier = declaration.initializer && requireLiteral(declaration.initializer);
          if (specifier) value.imports.set(declaration.name.text, {specifier, local: resolve(name, specifier), position: declaration.pos,
            wrapper: ts.isCallExpression(declaration.initializer) && ts.isIdentifier(declaration.initializer.expression) &&
              ["__importStar", "__importDefault"].includes(declaration.initializer.expression.text) ? declaration.initializer.expression.text : null});
          else add(declaration.name.text, declaration, declaration.initializer);
        }
      } else if ((ts.isFunctionDeclaration(statement) || ts.isClassDeclaration(statement)) && statement.name) {
        add(statement.name.text, statement);
        if (ts.isClassDeclaration(statement)) {
          for (const clause of statement.heritageClauses ?? []) value.bootstrap.push(clause);
          for (const member of statement.members) {
            if (ts.isClassStaticBlockDeclaration(member) || member.modifiers?.some((item) => item.kind === ts.SyntaxKind.StaticKeyword) &&
                ts.isPropertyDeclaration(member) || member.name && ts.isComputedPropertyName(member.name)) value.bootstrap.push(member);
          }
        }
      } else if (ts.isExpressionStatement(statement)) {
        const expression = statement.expression;
        if (ts.isStringLiteral(expression) && expression.text === "use strict") continue;
        if (ts.isBinaryExpression(expression) && expression.operatorToken.kind === ts.SyntaxKind.EqualsToken && isExports(expression.left)) {
          value.exportEvents.push({position: statement.pos, code: canonical(statement, source)});
          if (voidExports(expression.right)) continue;
          const exported = property(expression.left);
          assert.ok(exported && !value.exports.has(exported), `Duplicate or computed export: ${name}`);
          if (ts.isIdentifier(expression.right)) value.exports.set(exported, {binding: expression.right.text});
          else {
            const id = "exports." + exported;
            add(id, expression.right, expression.right);
            value.exports.set(exported, {binding: id});
          }
        } else if (ts.isCallExpression(expression) && ts.isPropertyAccessExpression(expression.expression) &&
                   expression.expression.expression.getText(source) === "Object" && expression.expression.name.text === "defineProperty" &&
                   expression.arguments[0]?.getText(source) === "exports" && ts.isStringLiteral(expression.arguments[1])) {
          const exported = expression.arguments[1].text;
          if (exported === "__esModule") {
            const descriptor = expression.arguments[2];
            assert.ok(expression.arguments.length === 3 && ts.isObjectLiteralExpression(descriptor) && descriptor.properties.length === 1 &&
              ts.isPropertyAssignment(descriptor.properties[0]) &&
              descriptor.properties[0].name?.getText(source) === "value" &&
              descriptor.properties[0].initializer.kind === ts.SyntaxKind.TrueKeyword,
            `Unsupported __esModule descriptor: ${name}`);
            value.bootstrap.push(statement);
            continue;
          }
          const object = expression.arguments[2];
          assert.ok(expression.arguments.length === 3 && ts.isObjectLiteralExpression(object) &&
            object.properties.length >= 1 && object.properties.length <= 2 &&
            new Set(object.properties.map((item) => item.name?.getText(source))).size === object.properties.length &&
            object.properties.every((item) => ts.isPropertyAssignment(item) &&
              (item.name?.getText(source) === "get" ||
                item.name?.getText(source) === "enumerable" && item.initializer.kind === ts.SyntaxKind.TrueKeyword)),
          `Unsupported export descriptor: ${name}`);
          const getter = object.properties.find((item) => item.name?.getText(source) === "get");
          assert.ok(getter && ts.isPropertyAssignment(getter) && ts.isFunctionExpression(getter.initializer) &&
            !getter.initializer.asteriskToken && !getter.initializer.modifiers?.length &&
            getter.initializer.parameters.length === 0,
          `Unsupported export getter: ${name}`);
          const body = getter.initializer.body;
          const returned = body?.statements?.length === 1 && ts.isReturnStatement(body.statements[0]) && body.statements[0].expression;
          assert.ok(returned && ts.isPropertyAccessExpression(returned) && ts.isIdentifier(returned.expression), `Unsupported export getter: ${name}`);
          const imported = value.imports.get(returned.expression.text);
          assert.ok(imported?.local && !value.exports.has(exported), `Unresolved or duplicate re-export: ${name}`);
          value.exports.set(exported, {module: imported.local, symbol: returned.name.text});
        } else if (requireLiteral(expression) && ts.isIdentifier(expression.expression) && expression.expression.text === "require") {
          const specifier = requireLiteral(expression);
          value.imports.set("@side-effect:" + statement.pos, {specifier, local: resolve(name, specifier), position: statement.pos});
        } else value.bootstrap.push(statement);
      } else if (!ts.isEmptyStatement(statement)) value.bootstrap.push(statement);
    }
    for (const imported of value.imports.values()) imported.trusted = true;
    const inspectNamespaces = (node) => {
      if (ts.isIdentifier(node) && value.imports.has(node.text)) {
        const imported = value.imports.get(node.text), parent = node.parent;
        if (ts.isVariableDeclaration(parent) && parent.name === node) return;
        if ((ts.isPropertyAccessExpression(parent) || ts.isElementAccessExpression(parent)) && parent.expression === node) {
          const use = parent.parent;
          if (ts.isBinaryExpression(use) && use.left === parent && use.operatorToken.kind >= ts.SyntaxKind.FirstAssignment &&
              use.operatorToken.kind <= ts.SyntaxKind.LastAssignment || ts.isDeleteExpression(use) ||
              ts.isPrefixUnaryExpression(use) || ts.isPostfixUnaryExpression(use)) imported.trusted = false;
        } else imported.trusted = false;
      }
      ts.forEachChild(node, inspectNamespaces);
    };
    inspectNamespaces(source);
    // Re-export getters above are the only accepted getter form. Refuse
    // purity proofs if exports can escape or be mutated through another form.
    const inspectExports = (node) => {
      if (ts.isIdentifier(node) && node.text === "exports") {
        const parent = node.parent;
        if ((ts.isPropertyAccessExpression(parent) || ts.isElementAccessExpression(parent)) && parent.expression === node) {
          const use = parent.parent;
          if (ts.isBinaryExpression(use) && use.left === parent &&
              use.operatorToken.kind >= ts.SyntaxKind.FirstAssignment && use.operatorToken.kind <= ts.SyntaxKind.LastAssignment) {
            if (!ts.isExpressionStatement(use.parent) || use.parent.parent !== source || use.operatorToken.kind !== ts.SyntaxKind.EqualsToken)
              value.plainExports = false;
          } else if (ts.isDeleteExpression(use) || ts.isPrefixUnaryExpression(use) || ts.isPostfixUnaryExpression(use)) value.plainExports = false;
        } else if (!(ts.isCallExpression(parent) && parent.arguments[0] === node &&
            ts.isPropertyAccessExpression(parent.expression) && parent.expression.expression.getText(source) === "Object" &&
            parent.expression.name.text === "defineProperty" && ts.isExpressionStatement(parent.parent) && parent.parent.parent === source)) {
          value.plainExports = false;
        }
      }
      ts.forEachChild(node, inspectExports);
    };
    inspectExports(source);
    if ([...value.imports.values()].some((imported) => imported.wrapper)) {
      assert.ok(value.plainExports && !untrustedNamespaces.has("local:" + name), `Unsupported compiler wrapper namespace: ${name}`);
      const required = new Set([...value.imports.values()].filter((imported) => imported.wrapper).map((imported) => imported.wrapper));
      if (required.has("__importStar")) { required.add("__createBinding"); required.add("__setModuleDefault"); }
      for (const helper of required) {
        assert.equal(value.units.get(helper)?.code, compilerHelpers.get(helper), `Unsupported compiler wrapper: ${name}`);
        assert.ok(!value.exports.has(helper), `Compiler wrapper cannot be exported: ${name}`);
      }
      const inspectHelpers = (node) => {
        if (ts.isIdentifier(node) && required.has(node.text)) {
          const parent = node.parent;
          const definition = ts.isVariableDeclaration(parent) && parent.name === node;
          const call = ts.isCallExpression(parent) && parent.expression === node && !functionShadow(node, node.text);
          assert.ok(definition || call || ts.isPropertyAccessExpression(parent) && parent.name === node,
            `Compiler wrapper binding cannot be changed or escape: ${name}`);
        }
        ts.forEachChild(node, inspectHelpers);
      };
      inspectHelpers(source);
    }
    // Reject an eager read before a local lexical declaration. Function and
    // callback bodies are deferred; their dependencies are followed separately.
    const lexical = new Map([...value.units].filter(([, unit]) => ts.isVariableDeclaration(unit.node) ||
      ts.isClassDeclaration(unit.node)).map(([binding, unit]) => [binding, unit.node.pos]));
    const checkOrder = (node, position) => {
      if (ts.isFunctionExpression(node) || ts.isArrowFunction(node)) return;
      if (ts.isIdentifier(node) && lexical.has(node.text)) {
        const parent = node.parent;
        const nameOnly = parent && !ts.isShorthandPropertyAssignment(parent) && parent.name === node;
        if (!nameOnly && lexical.get(node.text) > position) throw new Error(`Unsafe initialization order: ${name}`);
      }
      ts.forEachChild(node, (child) => checkOrder(child, position));
    };
    for (const unit of value.units.values()) if (unit.initializer) checkOrder(unit.initializer, unit.node.pos);
    // Import evaluation and explicit side effects remain part of every export.
    // Known SDK trigger/parameter construction is export-local; unknown eager
    // calls remain shared initialization and cannot be silently omitted.
    for (const unit of value.units.values()) {
      if (!unit.initializer || safeInitializer(unit.initializer, value)) continue;
      const initializer = unit.initializer;
      const callee = ts.isCallExpression(initializer) && calleeOf(initializer.expression);
      const imported = callee && ts.isPropertyAccessExpression(callee) && ts.isIdentifier(callee.expression) && value.imports.get(callee.expression.text);
      if (imported && trustedNamespace(value, imported) && !functionShadow(callee.expression, callee.expression.text) && !imported.local && firebaseImport(imported.specifier) && triggerFactories.has(callee.name.text)) {
        // The SDK does not invoke this callback during trigger construction.
        // Retain eager option expressions, while the actual exported behavior
        // still contains the complete callback/handler dependency closure.
        const last = initializer.arguments.at(-1);
        const lastUnit = last && ts.isIdentifier(last) && value.units.get(last.text);
        const deferred = last && (ts.isArrowFunction(last) || ts.isFunctionExpression(last) ||
          lastUnit && (ts.isFunctionDeclaration(lastUnit.node) || lastUnit.initializer &&
            (ts.isArrowFunction(lastUnit.initializer) || ts.isFunctionExpression(lastUnit.initializer))));
        // Handler factories execute eagerly. Drop only a proven function value,
        // never a call expression such as makeHandler().
        const eager = ts.factory.updateCallExpression(initializer, initializer.expression, initializer.typeArguments,
          deferred ? initializer.arguments.slice(0, -1) : initializer.arguments);
        eager.pos = initializer.pos; eager.end = initializer.end;
        value.bootstrap.push(eager);
      } else value.bootstrap.push(unit.node);
    }
    value.complete = true;
    return value;
  }
  function staticPath(current, node, seen = new Set()) {
    if (ts.isParenthesizedExpression(node)) return staticPath(current, node.expression, seen);
    if (ts.isStringLiteralLike(node)) return node.text;
    if (ts.isIdentifier(node)) {
      if (node.text === "__dirname") return functionShadow(node, node.text) ? null : path.posix.dirname("/package/" + current.name);
      if (seen.has(node)) return null;
      let scope = node.parent;
      while (scope) {
        if (ts.isBlock(scope) || ts.isSourceFile(scope)) {
          for (const statement of scope.statements) {
            if (!ts.isVariableStatement(statement)) continue;
            const declaration = statement.declarationList.declarations.find((item) => ts.isIdentifier(item.name) && item.name.text === node.text);
            if (declaration) {
              if (!(statement.declarationList.flags & ts.NodeFlags.Const)) return null;
              if (!declaration.initializer || seen.has(declaration)) return null;
              const next = new Set(seen); next.add(declaration);
              return staticPath(current, declaration.initializer, next);
            }
          }
        }
        if (ts.isFunctionLike(scope) && (scope.parameters.some((parameter) => hasBinding(parameter.name, node.text)) || functionShadow(node, node.text))) return null;
        scope = scope.parent;
      }
      return null;
    }
    if (ts.isPropertyAccessExpression(node) && node.name.text === "href") {
      const value = staticPath(current, node.expression, seen);
      return value?.fileURL ?? null;
    }
    if (ts.isCallExpression(node)) {
      const callee = calleeOf(node.expression);
      if (!ts.isPropertyAccessExpression(callee)) return null;
      let namespace = callee.expression;
      if (ts.isPropertyAccessExpression(namespace) && namespace.name.text === "default") namespace = namespace.expression;
      if (!ts.isIdentifier(namespace)) return null;
      const imported = current.imports.get(namespace.text);
      if (!imported || !trustedNamespace(current, imported) || imported.local || functionShadow(namespace, namespace.text)) return null;
      const values = node.arguments.map((item) => staticPath(current, item, seen));
      if (!values.length || values.some((value) => typeof value !== "string")) return null;
      if (["path", "node:path"].includes(imported.specifier) && ["resolve", "join"].includes(callee.name.text)) {
        if (callee.name.text === "resolve" && !path.posix.isAbsolute(values[0])) return null;
        return path.posix[callee.name.text](...values);
      }
      if (["url", "node:url"].includes(imported.specifier) && callee.name.text === "pathToFileURL" && values.length === 1 && path.posix.isAbsolute(values[0])) {
        return {fileURL: values[0]};
      }
    }
    return null;
  }
  function opaqueAssetClosure(name) {
    const visited = new Map();
    const walk = (name) => {
      if (visited.has(name)) return;
      const text = modules.get(name);
      assert.equal(typeof text, "string", `Missing opaque runtime asset: ${name}`);
      visited.set(name, hash(text));
      if (!/\.(?:mjs|cjs|js)$/.test(name)) return;
      const source = ts.createSourceFile(name, text, ts.ScriptTarget.Latest, true, ts.ScriptKind.JS);
      assert.equal(source.parseDiagnostics.length, 0, `Cannot parse opaque runtime asset: ${name}`);
      const add = (literal) => {
        assert.ok(literal && ts.isStringLiteralLike(literal), `Unknown opaque runtime import: ${name}`);
        if (!literal.text.startsWith(".")) return; // Dependency lock is bound separately.
        const stem = path.posix.normalize(path.posix.join(path.posix.dirname(name), literal.text));
        assert.ok(!stem.startsWith("../") && !path.posix.isAbsolute(stem), "Opaque runtime import escapes package.");
        const found = [stem, stem + ".js", stem + ".mjs", stem + "/index.js"].find((name) => modules.has(name));
        assert.ok(found, `Unresolved opaque runtime import: ${name}`); walk(found);
      };
      const visit = (node) => {
        if ((ts.isImportDeclaration(node) || ts.isExportDeclaration(node)) && node.moduleSpecifier) add(node.moduleSpecifier);
        if (ts.isCallExpression(node) && (node.expression.kind === ts.SyntaxKind.ImportKeyword ||
            ts.isIdentifier(node.expression) && node.expression.text === "require")) add(node.arguments[0]);
        if (ts.isIdentifier(node) && ["eval", "Function"].includes(node.text)) throw new Error(`Unknown opaque code loading: ${name}`);
        ts.forEachChild(node, visit);
      };
      visit(source);
    };
    walk(name);
    return [...visited].sort(([a], [b]) => a.localeCompare(b));
  }
  const snapshots = {};
  let bootstrapState;
  const initializationOrder = [];
  const initializedExternal = new Set();
  const initializing = [];
  const initializationCycles = new Set();
  for (const target of [...targets].sort()) {
    const rows = new Map(bootstrapState?.rows);
    const unknown = new Set(bootstrapState?.unknown);
    const visiting = new Set(bootstrapState?.visiting);
    const enterModule = (name) => {
      const key = name + "#@initialize";
      if (visiting.has(key)) {
        const cycle = initializing.indexOf(name);
        if (cycle !== -1) for (const member of initializing.slice(cycle)) initializationCycles.add(member);
        return;
      }
      visiting.add(key);
      initializing.push(name);
      const current = module(name);
      const events = [...current.bootstrap.map((node, ordinal) => ({position: node.pos, node, ordinal})),
        ...[...current.imports].map(([, imported]) => ({position: imported.position, imported}))];
      events.sort((a, b) => a.position - b.position);
      if (current.bootstrap.length) rows.set(key, hash(JSON.stringify(current.bootstrap.map((node) => canonical(node, current.source)))));
      for (const event of events) {
        if (event.node) {
          initializationOrder.push([name, event.ordinal]);
          visitNode(current, event.node);
        } else if (event.imported.local) enterModule(event.imported.local);
        else if (!initializedExternal.has(event.imported.specifier)) {
          initializedExternal.add(event.imported.specifier);
          initializationOrder.push(["external", event.imported.specifier]);
        }
      }
      initializing.pop();
    };
    const enterExport = (name, symbol) => {
      enterModule(name);
      const current = module(name);
      const exported = current.exports.get(symbol);
      assert.ok(exported, `Missing runtime export: ${name}#${symbol}`);
      if (exported.module) enterExport(exported.module, exported.symbol);
      else enterBinding(current, exported.binding);
    };
    const enterBinding = (current, binding) => {
      const key = current.name + "#" + binding;
      if (visiting.has(key)) return;
      visiting.add(key);
      const imported = current.imports.get(binding);
      if (imported) {
        if (imported.local) {
          // Passing a namespace as a value can observe every export.
          for (const symbol of module(imported.local).exports.keys()) enterExport(imported.local, symbol);
        } else rows.set(key, hash("external:" + imported.specifier));
        return;
      }
      const unit = current.units.get(binding);
      if (!unit) return; // Parameter/local binding or a standard global.
      rows.set(key, hash(unit.code));
      visitNode(current, unit.node);
    };
    const visitNode = (current, node) => {
      if (ts.isPropertyAccessExpression(node) && ts.isIdentifier(node.expression)) {
        const imported = current.imports.get(node.expression.text);
        if (imported) {
          if (imported.local) enterExport(imported.local, node.name.text);
          else rows.set(current.name + "#" + node.expression.text + "." + node.name.text, hash("external:" + imported.specifier + "#" + node.name.text));
          return;
        }
      }
      if (isExports(node)) {
        const symbol = property(node);
        if (symbol && current.exports.has(symbol)) enterExport(current.name, symbol);
        return;
      }
      if (ts.isCallExpression(node) && (node.expression.kind === ts.SyntaxKind.ImportKeyword ||
          ts.isIdentifier(node.expression) && node.expression.text === "require")) {
        const literal = node.arguments[0];
        if (!literal || !ts.isStringLiteralLike(literal)) {
          const loaded = literal && staticPath(current, literal);
          const name = typeof loaded === "string" && loaded.startsWith("/package/") && loaded.slice("/package/".length);
          if (name && modules.has(name) && /\.mjs$/.test(name)) {
            // Fixed package-local ESM paths are opaque asset closures: bind all
            // asset bytes, including their local imports. An asset delta stops
            // at the separate immutable runtime-configuration guard.
            rows.set("@fixed-runtime-assets:" + name, hash(JSON.stringify(opaqueAssetClosure(name))));
          } else unknown.add(current.name + ":dynamic-module-load");
        } else {
          const local = resolve(current.name, literal.text);
          if (local) {
            enterModule(local);
            for (const symbol of module(local).exports.keys()) enterExport(local, symbol);
          }
        }
      }
      if (ts.isIdentifier(node)) {
        const parent = node.parent;
        if (node.text === "eval" || node.text === "Function" || node.text === "require" &&
            !(ts.isCallExpression(parent) && parent.expression === node)) unknown.add(current.name + ":indirect-code-load");
        const nonReference = parent && (!ts.isShorthandPropertyAssignment(parent) && parent.name === node ||
          ts.isPropertyAccessExpression(parent) && parent.name === node ||
          ts.isPropertyAssignment(parent) && parent.name === node);
        if (!nonReference) enterBinding(current, node.text);
      }
      ts.forEachChild(node, (child) => visitNode(current, child));
    };
    if (!bootstrapState) {
      enterModule(entrypoint);
      rows.set("@initialization-order", hash(JSON.stringify(initializationOrder)));
      // A cyclic importer can observe partially assigned exports. Preserve
      // assignment/import/effect interleaving for every member of that cycle.
      for (const name of initializationCycles) {
        const current = module(name);
        const events = [...current.exportEvents,
          ...current.bootstrap.map((node) => ({position: node.pos, code: canonical(node, current.source)})),
          ...[...current.imports].map(([, imported]) => ({position: imported.position, code: "require:" + imported.specifier}))];
        events.sort((a, b) => a.position - b.position);
        rows.set(name + "#@cyclic-initialization", hash(JSON.stringify(events.map((event) => event.code))));
      }
      // Every export observes the same entrypoint initialization. Cache its
      // graph once; cloning the visited sets preserves cycle handling while
      // each export still walks its own deferred behavior independently.
      bootstrapState = {rows: new Map(rows), unknown: new Set(unknown), visiting: new Set(visiting)};
    }
    enterExport(entrypoint, target.slice("functions:".length));
    for (const current of parsed.values()) {
      const order = [...current.units].filter(([binding, unit]) => rows.has(current.name + "#" + binding) &&
        (ts.isVariableDeclaration(unit.node) || ts.isClassDeclaration(unit.node))).map(([binding]) => binding);
      if (order.length) rows.set(current.name + "#@declaration-order", hash(JSON.stringify(order)));
    }
    if (unknown.size) rows.set("@unresolved-runtime-inventory", hash(JSON.stringify([...modules].map(([name, text]) => [name, hash(text)]).sort(([a], [b]) => a.localeCompare(b)))));
    const dependencies = [...rows].sort(([a], [b]) => a.localeCompare(b));
    snapshots[target] = {sha256: hash(JSON.stringify(dependencies)), dependencies, unknown: [...unknown].sort()};
  }
  return {schema: FUNCTION_FINGERPRINT_SCHEMA, functions: snapshots};
}

export function compareFunctionFingerprints(before, after, {authorizedTargets}) {
  assert.equal(before.schema, FUNCTION_FINGERPRINT_SCHEMA);
  assert.equal(after.schema, FUNCTION_FINGERPRINT_SCHEMA);
  const expected = [...authorizedTargets].sort();
  assert.deepEqual(Object.keys(before.functions).sort(), expected, "Baseline export inventory mismatch.");
  assert.deepEqual(Object.keys(after.functions).sort(), expected, "Candidate export inventory mismatch.");
  const changed = [];
  for (const target of expected) {
    const old = before.functions[target];
    const next = after.functions[target];
    assert.match(old.sha256 ?? "", /^[0-9a-f]{64}$/);
    assert.match(next.sha256 ?? "", /^[0-9a-f]{64}$/);
    if (old.sha256 !== next.sha256) {
      assert.equal([...old.unknown, ...next.unknown].length, 0,
        `Unknown runtime impact requires investigation, not a full-suite deployment: ${target}`);
      changed.push(target);
    }
  }
  return {mode: changed.length ? "affected" : "no-op", targets: changed,
    unchangedTargets: expected.filter((target) => !changed.includes(target))};
}
