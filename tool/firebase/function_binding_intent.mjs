#!/usr/bin/env node
// Static source projection only: never import the Functions entry point, load
// credentials, evaluate environment variables, or execute authored helpers.
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {createFunctionsRequire} from "../lib/repo_paths.mjs";

const ts = createFunctionsRequire()("typescript");
const helperNames = new Map([
  ["shared/callableOptions.ts", new Set(["appCheckCallableOptionsWithLimits",
    "appCheckCallableOptionsWithSecrets"])],
  ["shared/organizerFormUploadIdentity.ts", new Set([
    "appCheckCallableOptionsForFormUpload", "appCheckCallableOptionsForFormReview"])],
]);
const factories = new Map([
  ["https", new Set(["onCall", "onRequest"])],
  ["scheduler", new Set(["onSchedule"])],
  ["firestore", new Set(["onDocumentCreated", "onDocumentUpdated",
    "onDocumentDeleted", "onDocumentWritten", "onDocumentCreatedWithAuthContext",
    "onDocumentUpdatedWithAuthContext", "onDocumentDeletedWithAuthContext",
    "onDocumentWrittenWithAuthContext"])],
  ["tasks", new Set(["onTaskDispatched"])],
  ["pubsub", new Set(["onMessagePublished"])],
  ["storage", new Set(["onObjectFinalized", "onObjectDeleted",
    "onObjectArchived", "onObjectMetadataUpdated"])],
]);
const fail = () => { throw new Error("Function binding intent is unresolved."); };
const validName = (value) => typeof value === "string" &&
  /^[A-Za-z][A-Za-z0-9_]{0,127}$/u.test(value);
const publicString = (value, pattern) => typeof value === "string" &&
  !/\s/u.test(value) && pattern.test(value);
const unwrap = (node) => {
  while (ts.isParenthesizedExpression(node) || ts.isAsExpression(node) ||
    ts.isSatisfiesExpression(node) || ts.isNonNullExpression(node)) node = node.expression;
  return node;
};

/** sourceSha is an assertion: the caller must verify approved source bytes. */
export function collectFunctionBindingIntent({sourceRoot, environment, projectId,
  projectNumber, sourceSha, consumers}) {
  try {
    if (!publicString(sourceSha, /^[0-9a-f]{40}$/u) ||
        !["dev", "staging", "prod"].includes(environment) ||
        !publicString(projectId, /^[a-z][a-z0-9-]{4,61}[a-z0-9]$/u) ||
        !publicString(projectNumber, /^[1-9][0-9]{0,29}$/u) ||
        !Array.isArray(consumers) || !consumers.length ||
        consumers.length > 2000 || !consumers.every(validName) ||
        new Set(consumers).size !== consumers.length) fail();
    const functionsDir = path.join(sourceRoot, "functions");
    const lockPath = path.join(functionsDir, "package-lock.json");
    for (const filename of [functionsDir, path.join(functionsDir, "src"), lockPath]) {
      if (fs.lstatSync(filename).isSymbolicLink()) fail();
    }
    if (fs.statSync(lockPath).size > 5 * 1024 * 1024) fail();
    // These reset/merge/shorthand semantics were inspected in this pinned SDK.
    // An SDK change needs review, not an assumed default runtime identity.
    const lock = JSON.parse(fs.readFileSync(lockPath, "utf8"));
    if (lock.packages?.["node_modules/firebase-functions"]?.version !== "7.4.0") fail();
    const src = fs.realpathSync(path.join(functionsDir, "src"));
    // SDK global options are shared process state. Only the entry point may
    // establish them; another module would make import ordering significant.
    let inspected = 0;
    const inspectGlobals = (directory) => {
      for (const item of fs.readdirSync(directory, {withFileTypes: true})) {
        if (++inspected > 20000 || item.isSymbolicLink()) fail();
        const filename = path.join(directory, item.name);
        if (item.isDirectory()) inspectGlobals(filename);
        else if (item.isFile() && item.name.endsWith(".ts") &&
            !item.name.endsWith(".test.ts") && filename !== path.join(src, "index.ts")) {
          if (fs.statSync(filename).size > 2 * 1024 * 1024) fail();
          if (/\bsetGlobalOptions\b/u.test(fs.readFileSync(filename, "utf8"))) fail();
        }
      }
    };
    inspectGlobals(src);
    const modules = new Map();
    const active = new Set();
    let steps = 0;
    const enter = (key, fn) => {
      if (++steps > 100000 || active.has(key)) fail();
      active.add(key);
      try { return fn(); } finally { active.delete(key); }
    };
    const load = (filename) => {
      const real = fs.realpathSync(filename);
      if (!real.startsWith(src + path.sep) || !real.endsWith(".ts") ||
          real.endsWith(".test.ts") || fs.lstatSync(filename).isSymbolicLink()) fail();
      if (modules.has(real)) return modules.get(real);
      if (fs.statSync(real).size > 2 * 1024 * 1024) fail();
      const ast = ts.createSourceFile(real, fs.readFileSync(real, "utf8"),
        ts.ScriptTarget.Latest, true);
      if (ast.parseDiagnostics.length) fail();
      const mod = {ast, file: real, imports: new Map(), defs: new Map(),
        exports: new Map()};
      modules.set(real, mod);
      const add = (map, name, value) => {
        if (map.has(name)) fail();
        map.set(name, value);
      };
      for (const statement of ast.statements) {
        if (ts.isImportDeclaration(statement)) {
          const bindings = statement.importClause?.namedBindings;
          if (statement.importClause?.isTypeOnly) continue;
          if (bindings && ts.isNamedImports(bindings)) {
            for (const item of bindings.elements) {
              if (!item.isTypeOnly) add(mod.imports, item.name.text,
                {module: statement.moduleSpecifier.text,
                  name: (item.propertyName ?? item.name).text});
            }
          } else if (bindings && ts.isNamespaceImport(bindings)) {
            add(mod.imports, bindings.name.text,
              {module: statement.moduleSpecifier.text, namespace: true});
          }
        } else if (ts.isVariableStatement(statement)) {
          for (const declaration of statement.declarationList.declarations) {
            if (!ts.isIdentifier(declaration.name)) continue;
            add(mod.defs, declaration.name.text, {node: declaration.initializer,
              constant: !!(statement.declarationList.flags & ts.NodeFlags.Const)});
            if (statement.modifiers?.some((m) => m.kind === ts.SyntaxKind.ExportKeyword)) {
              add(mod.exports, declaration.name.text, {name: declaration.name.text});
            }
          }
        } else if (ts.isFunctionDeclaration(statement) && statement.name) {
          add(mod.defs, statement.name.text, {node: statement, constant: true});
          if (statement.modifiers?.some((m) => m.kind === ts.SyntaxKind.ExportKeyword)) {
            add(mod.exports, statement.name.text, {name: statement.name.text});
          }
        } else if (ts.isExportDeclaration(statement)) {
          if (statement.isTypeOnly) continue;
          if (!statement.exportClause || !ts.isNamedExports(statement.exportClause)) fail();
          for (const item of statement.exportClause.elements) {
            if (!item.isTypeOnly) add(mod.exports, item.name.text, {
              module: statement.moduleSpecifier?.text,
              name: (item.propertyName ?? item.name).text,
            });
          }
        }
      }
      return mod;
    };
    const imported = (entry, mod) => {
      if (!entry.module.startsWith(".")) return {sdk: entry.module, name: entry.name};
      if (entry.module.includes("\\") || entry.module.includes("\0")) fail();
      const target = load(path.resolve(path.dirname(mod.file), entry.module + ".ts"));
      return exported(entry.name, target);
    };
    const exported = (name, mod) => enter(`export:${mod.file}:${name}`, () => {
      const entry = mod.exports.get(name);
      if (!entry) fail();
      return entry.module ? imported(entry, mod) : symbol(entry.name, mod, new Map());
    });
    const symbol = (name, mod, locals) => {
      if (locals.has(name)) return locals.get(name);
      if (mod.imports.has(name)) return imported(mod.imports.get(name), mod);
      const value = mod.defs.get(name);
      if (!value?.node || !value.constant) fail();
      // Const does not prevent object mutation. Refuse post-declaration writes.
      const visit = (node) => {
        if (ts.isBinaryExpression(node) &&
            node.operatorToken.kind >= ts.SyntaxKind.FirstAssignment &&
            node.operatorToken.kind <= ts.SyntaxKind.LastAssignment) {
          let left = node.left;
          while (ts.isPropertyAccessExpression(left) || ts.isElementAccessExpression(left)) {
            left = left.expression;
          }
          if (ts.isIdentifier(left) && left.text === name) fail();
        }
        if (ts.isCallExpression(node) && ts.isPropertyAccessExpression(node.expression) &&
            ts.isIdentifier(node.expression.expression) &&
            node.expression.expression.text === "Object" &&
            ["assign", "defineProperty", "defineProperties", "setPrototypeOf"]
              .includes(node.expression.name.text) &&
            node.arguments.some((arg) => ts.isIdentifier(arg) && arg.text === name)) fail();
        if (ts.isDeleteExpression(node) || ts.isPostfixUnaryExpression(node) ||
            ts.isPrefixUnaryExpression(node)) {
          let expression = node.expression ?? node.operand;
          while (ts.isPropertyAccessExpression(expression) ||
              ts.isElementAccessExpression(expression)) expression = expression.expression;
          if (ts.isIdentifier(expression) && expression.text === name) fail();
        }
        if (ts.isCallExpression(node) && ts.isPropertyAccessExpression(node.expression)) {
          let receiver = node.expression.expression;
          while (ts.isPropertyAccessExpression(receiver) ||
              ts.isElementAccessExpression(receiver)) receiver = receiver.expression;
          if (ts.isIdentifier(receiver) && receiver.text === name &&
              node.expression.name.text !== "value") fail();
        }
        if (ts.isCallExpression(node) && node.arguments.some((arg) =>
          ts.isIdentifier(arg) && arg.text === name)) {
          const callee = resolve(node.expression, mod, new Map());
          const sdkFactory = callee.sdk?.startsWith("firebase-functions/v2/") &&
            [...factories.values()].some((names) => names.has(callee.name));
          const helper = callee.node && ts.isFunctionDeclaration(callee.node) &&
            helperNames.get(path.relative(src, callee.mod.file).split(path.sep).join("/"))
              ?.has(callee.node.name.text);
          if (!sdkFactory && !helper) fail();
        }
        ts.forEachChild(node, visit);
      };
      visit(mod.ast);
      return {node: value.node, mod, locals: new Map()};
    };
    const resolve = (node, mod, locals) => {
      node = unwrap(node);
      if (ts.isIdentifier(node)) {
        return enter(`symbol:${mod.file}:${node.text}:${node.pos}`, () => {
          const result = symbol(node.text, mod, locals);
          return result.node && ts.isIdentifier(unwrap(result.node)) ?
            resolve(result.node, result.mod, result.locals) : result;
        });
      }
      if (ts.isPropertyAccessExpression(node) && ts.isIdentifier(node.expression)) {
        const entry = mod.imports.get(node.expression.text);
        if (entry?.namespace) return imported({...entry, name: node.name.text}, mod);
      }
      return {node, mod, locals};
    };
    const scalar = (node, mod, locals) => {
      const value = resolve(node, mod, locals);
      if (!value.node) fail();
      const n = value.node;
      if (ts.isStringLiteral(n) || ts.isNoSubstitutionTemplateLiteral(n)) return n.text;
      if (n.kind === ts.SyntaxKind.NullKeyword) return null;
      if (n.kind === ts.SyntaxKind.TrueKeyword) return true;
      if (n.kind === ts.SyntaxKind.FalseKeyword) return false;
      fail();
    };
    const secret = (node, mod, locals) => {
      const value = resolve(node, mod, locals);
      if (!value.node) fail();
      const n = unwrap(value.node);
      if (ts.isCallExpression(n)) {
        const factory = resolve(n.expression, value.mod, value.locals);
        if (factory.sdk !== "firebase-functions/params" ||
            factory.name !== "defineSecret" || n.arguments.length !== 1) fail();
        return secret(n.arguments[0], value.mod, value.locals);
      }
      const name = scalar(n, value.mod, value.locals);
      if (!publicString(name, /^[A-Z][A-Z0-9_]{0,254}$/u)) fail();
      return name;
    };
    const secrets = (node, mod, locals) => {
      const value = resolve(node, mod, locals);
      if (!value.node || !ts.isArrayLiteralExpression(unwrap(value.node))) fail();
      return unwrap(value.node).elements.flatMap((item) =>
        ts.isSpreadElement(item) ? secrets(item.expression, value.mod, value.locals) :
          [secret(item, value.mod, value.locals)]);
    };
    const options = (node, mod, locals = new Map()) => enter(
      `options:${mod.file}:${node.pos}:${[...locals.keys()].join(",")}`, () => {
        const value = resolve(node, mod, locals);
        if (!value.node) fail();
        const n = unwrap(value.node);
        if (ts.isCallExpression(n)) {
          const helper = resolve(n.expression, value.mod, value.locals);
          const def = helper.node;
          if (!def || !ts.isFunctionDeclaration(def) ||
              !helperNames.get(path.relative(src, helper.mod.file).split(path.sep).join("/"))
                ?.has(def.name.text) || def.body?.statements.length !== 1 ||
              !ts.isReturnStatement(def.body.statements[0]) ||
              !def.body.statements[0].expression ||
              n.arguments.length > def.parameters.length) fail();
          const args = new Map();
          def.parameters.forEach((parameter, i) => {
            if (!ts.isIdentifier(parameter.name)) fail();
            if (n.arguments[i]) args.set(parameter.name.text,
              {node: n.arguments[i], mod: value.mod, locals: value.locals});
            else if (parameter.initializer) args.set(parameter.name.text,
              {node: parameter.initializer, mod: helper.mod, locals: args});
            else fail();
          });
          return options(def.body.statements[0].expression, helper.mod, args);
        }
        if (!ts.isObjectLiteralExpression(n)) fail();
        const result = {};
        for (const item of n.properties) {
          if (ts.isSpreadAssignment(item)) {
            Object.assign(result, options(item.expression, value.mod, value.locals));
            continue;
          }
          if (!ts.isPropertyAssignment(item) && !ts.isShorthandPropertyAssignment(item)) fail();
          if (!ts.isIdentifier(item.name) && !ts.isStringLiteral(item.name)) fail();
          const name = item.name.text;
          const expression = ts.isPropertyAssignment(item) ? item.initializer : item.name;
          if (name === "secrets") result.secretNames = secrets(expression, value.mod, value.locals);
          else if (["serviceAccount", "preserveExternalChanges", "omit"].includes(name)) {
            result[name] = scalar(expression, value.mod, value.locals);
            if (name !== "serviceAccount" && result[name] !== null &&
                typeof result[name] !== "boolean") fail();
          } else if (["serviceAccountEmail", "secretEnvironmentVariables", "__proto__"]
            .includes(name)) fail();
        }
        return result;
      });
    const index = load(path.join(src, "index.ts"));
    let globalOptions = {};
    let globals = 0;
    for (const statement of index.ast.statements) {
      if (!ts.isExpressionStatement(statement) ||
          !ts.isCallExpression(statement.expression)) continue;
      const call = statement.expression;
      const callee = resolve(call.expression, index, new Map());
      if (["firebase-functions", "firebase-functions/v2", "firebase-functions/v2/options"]
        .includes(callee.sdk) && callee.name === "setGlobalOptions") {
        if (++globals > 1 || call.arguments.length !== 1) fail();
        const earlierImports = index.ast.statements.filter((s) => s.pos < statement.pos);
        if (earlierImports.some((s) =>
          (ts.isExportDeclaration(s) || ts.isImportDeclaration(s)) &&
            s.moduleSpecifier?.text?.startsWith(".") &&
            !s.isTypeOnly && !s.importClause?.isTypeOnly)) fail();
        globalOptions = options(call.arguments[0], index);
      }
    }
    const functions = [...consumers].sort().map((consumer) => {
      const target = exported(consumer, index);
      const call = target.node && unwrap(target.node);
      if (!call || !ts.isCallExpression(call)) fail();
      const factory = resolve(call.expression, target.mod, target.locals);
      const module = factory.sdk?.match(/^firebase-functions\/v2\/([a-z]+)$/u)?.[1];
      if (!module || !factories.get(module)?.has(factory.name) ||
          ![1, 2].includes(call.arguments.length)) fail();
      let local = {};
      if (call.arguments.length === 2) {
        const arg = unwrap(call.arguments[0]);
        // String trigger selectors cannot contain runtime options.
        if (!ts.isStringLiteral(arg) && !ts.isNoSubstitutionTemplateLiteral(arg) &&
            !ts.isTemplateExpression(arg)) local = options(arg, target.mod, target.locals);
        else if (module === "https" || module === "tasks") fail();
      } else if (module !== "https") fail();
      const opts = {...globalOptions, ...local};
      if (globalOptions.preserveExternalChanges === true ||
          local.preserveExternalChanges === true || opts.omit === true) fail();
      let serviceAccount = opts.serviceAccount;
      if (serviceAccount === undefined || serviceAccount === null || serviceAccount === "default") {
        serviceAccount = `${projectNumber}-compute@developer.gserviceaccount.com`;
      } else if (publicString(serviceAccount, /^[a-z][a-z0-9-]{4,28}[a-z0-9]@$/u)) {
        serviceAccount += `${projectId}.iam.gserviceaccount.com`;
      } else if (!publicString(serviceAccount,
        /^[a-z][a-z0-9-]{4,28}[a-z0-9]@[a-z][a-z0-9-]+\.iam\.gserviceaccount\.com$/u)) fail();
      if (new Set(opts.secretNames ?? []).size !== (opts.secretNames ?? []).length) fail();
      return {consumer, platform: "gcfv2", serviceAccount,
        secretNames: [...new Set(opts.secretNames ?? [])].sort()};
    });
    return {schemaVersion: 1, sourceSha, environment, projectId, projectNumber, functions};
  } catch {
    // Never serialize ASTs, option values, process env, parser/FS errors or causes.
    fail();
  }
}

export function runCli(argv) {
  try {
    const names = new Map([["--source-root", "sourceRoot"], ["--env", "environment"],
      ["--project", "projectId"], ["--project-number", "projectNumber"],
      ["--source-sha", "sourceSha"], ["--consumers", "consumers"]]);
    const args = {};
    for (let i = 0; i < argv.length; i += 2) {
      const name = names.get(argv[i]);
      if (!name || name in args || !argv[i + 1]) fail();
      args[name] = name === "consumers" ? argv[i + 1].split(",") : argv[i + 1];
    }
    if (Object.keys(args).length !== names.size) fail();
    return collectFunctionBindingIntent(args);
  } catch { fail(); }
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  try { process.stdout.write(JSON.stringify(runCli(process.argv.slice(2))) + "\n"); }
  catch { process.stderr.write("Function binding intent is unresolved.\n"); process.exitCode = 1; }
}
