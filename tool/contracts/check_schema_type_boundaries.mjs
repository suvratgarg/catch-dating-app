#!/usr/bin/env node
import fs from "node:fs";
import {createRequire} from "node:module";
import path from "node:path";
import {fileURLToPath} from "node:url";

const requireFromFunctions = createRequire(
  new URL("../../functions/package.json", import.meta.url)
);
const ts = requireFromFunctions("typescript");

const toolDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(toolDir, "../..");
const overlayPath = path.join(toolDir, "firestore_ts_overlay.json");
const legacyFirestoreFacadePath = path.join(
  repoRoot,
  "functions/src/shared/firestore.ts"
);
const firestoreAdminTypesPath = path.join(
  repoRoot,
  "functions/src/shared/generated/firestoreAdminTypes.ts"
);

function main() {
  const errors = [];

  if (fs.existsSync(overlayPath)) {
    errors.push(
      "tool/contracts/firestore_ts_overlay.json should not exist; Admin SDK " +
        "types now come from generate_schema_contracts.mjs."
    );
  }

  if (fs.existsSync(legacyFirestoreFacadePath)) {
    errors.push(
      "functions/src/shared/firestore.ts should not exist; import " +
        "schema-derived Admin SDK types from " +
        "functions/src/shared/generated/firestoreAdminTypes.ts."
    );
  }

  if (!fs.existsSync(firestoreAdminTypesPath)) {
    errors.push(
      "functions/src/shared/generated/firestoreAdminTypes.ts is missing."
    );
  } else {
    const source = fs.readFileSync(firestoreAdminTypesPath, "utf8");
    const sourceLower = source.toLowerCase();
    if (
      !sourceLower.includes("schema-derived admin sdk firestore document types") ||
      !source.includes("FirebaseFirestore.Timestamp")
    ) {
      errors.push(
        "firestoreAdminTypes.ts must describe itself as the schema-derived " +
          "Admin SDK Timestamp projection."
      );
    }
  }

  if (hasLegacyFirestoreImports()) {
    errors.push(
      "Functions code still imports ../shared/firestore; use " +
        "../shared/generated/firestoreAdminTypes instead."
    );
  }

  for (const file of walk(path.join(repoRoot, "functions/src"))) {
    if (!file.endsWith(".ts")) continue;
    errors.push(...schemaRuntimeImportErrors(
      fs.readFileSync(file, "utf8"), path.relative(repoRoot, file)
    ));
  }

  if (errors.length > 0) {
    console.error("Schema/type boundary check failed:");
    for (const error of errors) console.error(`- ${error}`);
    process.exit(1);
  }

  console.log("Schema/type boundary check passed.");

}

function hasLegacyFirestoreImports() {
  const srcRoot = path.join(repoRoot, "functions/src");
  if (!fs.existsSync(srcRoot)) return false;
  for (const filePath of walk(srcRoot)) {
    if (!filePath.endsWith(".ts")) continue;
    const relativePath = path.relative(repoRoot, filePath);
    if (relativePath === "functions/src/shared/generated/firestoreAdminTypes.ts") {
      continue;
    }
    const source = fs.readFileSync(filePath, "utf8");
    if (source.includes("../shared/firestore")) return true;
  }
  return false;
}

function* walk(dir) {
  for (const entry of fs.readdirSync(dir, {withFileTypes: true})) {
    const childPath = path.join(dir, entry.name);
    if (entry.isDirectory()) yield* walk(childPath);
    else if (entry.isFile()) yield childPath;
  }
}

/** Production dependencies must stay on individual generated modules. */
export function schemaRuntimeImportErrors(text, file) {
  if (/\.(?:test|spec)\.ts$/.test(file) ||
      /(?:^|\/)generated\/(?:schemaRegistry|schemaValidators)\.ts$/.test(file)) return [];
  const source = ts.createSourceFile(file, text, ts.ScriptTarget.Latest, true);
  const errors = [];
  const check = (literal, typeOnly = false) => {
    if (!literal || !ts.isStringLiteralLike(literal)) return;
    const name = path.posix.basename(literal.text).replace(/\.(?:js|ts)$/, "");
    if (name === "schemaRegistry" || name === "schemaValidators") {
      errors.push(`${file}: import the individual schema, validator or catalog; aggregate ${name} is test/tool-only.`);
    }
    if (name === "firestoreAdminTypes" && !typeOnly) {
      errors.push(`${file}: use an explicit import type or export type for firestoreAdminTypes.`);
    }
  };
  const visit = (node) => {
    if (ts.isImportDeclaration(node)) check(node.moduleSpecifier, node.importClause?.isTypeOnly);
    else if (ts.isExportDeclaration(node)) check(node.moduleSpecifier, node.isTypeOnly);
    else if (ts.isImportEqualsDeclaration(node) && ts.isExternalModuleReference(node.moduleReference)) {
      check(node.moduleReference.expression, node.isTypeOnly);
    } else if (ts.isCallExpression(node) &&
      (node.expression.kind === ts.SyntaxKind.ImportKeyword ||
       ts.isIdentifier(node.expression) && node.expression.text === "require")) {
      check(node.arguments[0]);
    }
    ts.forEachChild(node, visit);
  };
  visit(source);
  return errors;
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) main();
