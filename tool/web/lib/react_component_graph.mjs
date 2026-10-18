import fs from "node:fs";
import path from "node:path";
import ts from "typescript";

// Symbol-level graph of the exported React components in the web surfaces,
// resolved by the TypeScript checker through barrels and re-exports.
export const reactComponentSurfaces = Object.freeze([
  {id: "website", root: "website/src", tsconfig: "website/tsconfig.json"},
  {id: "admin", root: "admin/src", tsconfig: "admin/tsconfig.json"},
  {id: "web-ui", root: "packages/web-ui/src", tsconfig: "packages/web-ui/tsconfig.json"},
]);

const sourceExtensions = new Set([".ts", ".tsx"]);

/** Tests and stories consume components without making them production code. */
export function isNonProductionSource(relativePath) {
  return /\.(?:test|spec|stories)\.tsx?$/u.test(relativePath) ||
    relativePath.split("/").some((segment) => segment === "__tests__" || segment === "test");
}

/**
 * Returns `components` (every exported PascalCase function, class, or
 * callable const declared in a production source file) and `references`
 * (each use of a component from another declaration or module scope).
 */
export function buildReactComponentGraph({repoRoot, surfaces = reactComponentSurfaces} = {}) {
  const root = path.resolve(repoRoot);
  const components = new Map();
  const references = new Map();
  for (const surface of surfaces) {
    const program = createProgram(root, surface);
    const checker = program.getTypeChecker();
    const surfaceRoot = path.join(root, surface.root);
    const files = program.getSourceFiles().filter((file) =>
      isWithin(realPath(file.fileName), surfaceRoot) &&
      sourceExtensions.has(path.extname(file.fileName)) &&
      !file.isDeclarationFile);
    for (const file of files) {
      const relative = repoRelative(root, file.fileName);
      if (isNonProductionSource(relative)) continue;
      for (const component of declaredComponents(file, checker, relative, surface.id)) {
        components.set(component.id, component);
      }
    }
    for (const file of files) {
      collectReferences(file, checker, root, references);
    }
  }
  const resolved = [...references.values()]
    .filter((reference) => components.has(reference.to))
    .sort((left, right) => compare(left.from, right.from) || compare(left.to, right.to));
  return {
    components: [...components.values()].sort((left, right) => compare(left.id, right.id)),
    references: resolved,
  };
}

function createProgram(root, surface) {
  const configPath = path.join(root, surface.tsconfig);
  const config = ts.readConfigFile(configPath, ts.sys.readFile);
  if (config.error) throw new Error(diagnosticText(config.error));
  const parsed = ts.parseJsonConfigFileContent(config.config, ts.sys, path.dirname(configPath));
  if (parsed.errors.length > 0) throw new Error(parsed.errors.map(diagnosticText).join("\n"));
  return ts.createProgram({rootNames: parsed.fileNames, options: {...parsed.options, noEmit: true}});
}

function declaredComponents(file, checker, relative, surface) {
  const moduleSymbol = checker.getSymbolAtLocation(file);
  if (!moduleSymbol) return [];
  const output = [];
  for (const exported of checker.getExportsOfModule(moduleSymbol)) {
    const symbol = resolveAlias(checker, exported);
    const declaration = symbol.declarations?.find((entry) => entry.getSourceFile() === file);
    if (!declaration || !isComponentDeclaration(declaration, symbol, checker)) continue;
    const name = exported.getName() === "default" ? symbol.getName() : exported.getName();
    if (!isComponentName(name)) continue;
    output.push({
      id: `${relative}::${name}`,
      surface,
      file: relative,
      name,
      line: file.getLineAndCharacterOfPosition(declaration.getStart(file)).line + 1,
    });
  }
  return output;
}

export function isComponentName(name) {
  return /^[A-Z][A-Za-z0-9]*$/u.test(name) && !/^[A-Z0-9_]+$/u.test(name);
}

function isComponentDeclaration(declaration, symbol, checker) {
  if (ts.isFunctionDeclaration(declaration) || ts.isClassDeclaration(declaration)) return true;
  if (!ts.isVariableDeclaration(declaration)) return false;
  const type = checker.getTypeOfSymbolAtLocation(symbol, declaration);
  return type.getCallSignatures().length > 0 || type.getConstructSignatures().length > 0 ||
    // memo() and forwardRef() return exotic components without call signatures.
    /\b(?:Memo|ForwardRef|Lazy)ExoticComponent\b/u.test(checker.typeToString(type));
}

function collectReferences(file, checker, root, references) {
  const relative = repoRelative(root, file.fileName);
  const visit = (node, owner) => {
    const nextOwner = ownerOf(node, file) ?? owner;
    if (ts.isIdentifier(node) && !isDeclarationName(node)) {
      const symbol = checker.getSymbolAtLocation(node);
      const target = symbol ? resolveAlias(checker, symbol) : null;
      const declaration = target?.declarations?.[0];
      if (declaration && !ts.isImportSpecifier(node.parent) && !ts.isExportSpecifier(node.parent)) {
        const to = `${repoRelative(root, declaration.getSourceFile().fileName)}::${target.getName()}`;
        const from = nextOwner ? `${relative}::${nextOwner}` : relative;
        if (from !== to) references.set(`${from}->${to}`, {from, to, file: relative});
      }
    }
    ts.forEachChild(node, (child) => visit(child, nextOwner));
  };
  visit(file, null);
}

// The exported top-level declaration that encloses a node, if any.
function ownerOf(node, file) {
  if (node.parent !== file) return null;
  if ((ts.isFunctionDeclaration(node) || ts.isClassDeclaration(node)) && node.name) {
    return node.name.text;
  }
  if (ts.isVariableStatement(node)) {
    const names = node.declarationList.declarations
      .filter((declaration) => ts.isIdentifier(declaration.name))
      .map((declaration) => declaration.name.text);
    return names.length === 1 ? names[0] : null;
  }
  return null;
}

function isDeclarationName(node) {
  const parent = node.parent;
  return (ts.isFunctionDeclaration(parent) || ts.isClassDeclaration(parent) ||
    ts.isVariableDeclaration(parent) || ts.isInterfaceDeclaration(parent) ||
    ts.isTypeAliasDeclaration(parent)) && parent.name === node;
}

function resolveAlias(checker, symbol) {
  return symbol.flags & ts.SymbolFlags.Alias ? checker.getAliasedSymbol(symbol) : symbol;
}

function realPath(file) {
  try {
    return fs.realpathSync(file);
  } catch {
    return file;
  }
}

function isWithin(file, directory) {
  const relative = path.relative(directory, file);
  return relative !== "" && !relative.startsWith("..") && !path.isAbsolute(relative);
}

function repoRelative(root, file) {
  return path.relative(root, realPath(file)).split(path.sep).join("/");
}

function diagnosticText(diagnostic) {
  return ts.flattenDiagnosticMessageText(diagnostic.messageText, "\n");
}

function compare(left, right) {
  return left < right ? -1 : left > right ? 1 : 0;
}
