#!/usr/bin/env node
import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";
import {fromRepo, relativeToRepo} from "../lib/repo_paths.mjs";

const routerPath = fromRepo("lib/routing/go_router.dart");
const inventoryPath = fromRepo("tool/ui_capture/route_inventory.json");
const args = process.argv.slice(2);
const command = args[0] ?? "--help";

if (command === "--help" || command === "-h" || command === "help") {
  printHelp();
} else if (command === "--update" || command === "update") {
  updateInventory();
} else if (command === "--check" || command === "check") {
  checkInventory();
} else if (command === "--list" || command === "list") {
  listInventory();
} else {
  console.error(`Unknown command: ${command}`);
  printHelp();
  process.exit(64);
}

function updateInventory() {
  const inventory = buildInventory();
  fs.mkdirSync(path.dirname(inventoryPath), {recursive: true});
  fs.writeFileSync(inventoryPath, stableJson(inventory));
  console.log(`Updated ${relativeToRepo(inventoryPath)}.`);
}

function checkInventory() {
  if (!fs.existsSync(inventoryPath)) {
    fail([
      `${relativeToRepo(inventoryPath)} is missing.`,
      "Run node tool/ui_capture/check_route_inventory.mjs --update.",
    ]);
  }

  const expected = stableJson(buildInventory());
  const actual = fs.readFileSync(inventoryPath, "utf8");
  if (actual !== expected) {
    fail([
      `${relativeToRepo(inventoryPath)} is stale for ${relativeToRepo(routerPath)}.`,
      "Run node tool/ui_capture/check_route_inventory.mjs --update and review the route/capture inventory impact.",
    ]);
  }

  console.log("UI capture route inventory is in sync.");
}

function listInventory() {
  const inventory = buildInventory();
  for (const route of inventory.routes) {
    console.log(`${route.id.padEnd(34)} ${route.path}`);
  }
}

function buildInventory() {
  const source = fs.readFileSync(routerPath, "utf8");
  const enumBlock = extractBalancedBlock(source, "enum Routes", "{", "}");
  const goRouterBlock = extractGoRouterReturnBlock(source);
  const routeGraph = extractRuntimeRouteGraph(source, goRouterBlock);
  const routes = extractRouteEnumEntries(enumBlock.body);
  const runtimeRoutes = extractRuntimeRouteEntries(routeGraph.text, routes);
  validateRuntimeRoutes(routes, runtimeRoutes);
  const routeContract = normalizeRouteContract(`${enumBlock.text}\n${routeGraph.text}`);
  const routeReferences = uniqueSorted(
    [...routeGraph.text.matchAll(/\bRoutes\.([A-Za-z0-9_]+)/g)].map(
      (match) => match[1]
    )
  );
  const routeReferenceIds = new Set(routeReferences);
  const runtimeRoutesById = new Map(
    runtimeRoutes.map((route) => [route.id, route])
  );

  return {
    version: 1,
    generatedBy: "tool/ui_capture/check_route_inventory.mjs",
    source: {
      path: "lib/routing/go_router.dart",
      normalizedFileSha256: sha256(normalizeRouteContract(source)),
      routeContractSha256: sha256(routeContract),
      goRouteCount: countMatches(routeGraph.text, /\bGoRoute\s*\(/g),
      shellBranchCount: countMatches(routeGraph.text, /\bStatefulShellBranch\s*\(/g),
      enumRouteCount: routes.length,
      referencedRouteCount: routeReferences.length,
      runtimeRouteCount: runtimeRoutes.length,
      routeHelperCount: routeGraph.routeHelperNames.length,
      routeHelpers: routeGraph.routeHelperNames,
    },
    routes: routes.map((route) => {
      const runtimeRoute = runtimeRoutesById.get(route.id) ?? null;
      return {
        ...route,
        runtimePath: runtimeRoute?.runtimePath ?? null,
        runtimeParentId: runtimeRoute?.parentId ?? null,
        runtimePathExpression: runtimeRoute?.pathExpression ?? null,
        runtimePathMatchesEnum: runtimeRoute?.runtimePath === route.path,
        referencedByGoRouter: routeReferenceIds.has(route.id),
      };
    }),
    goRouterRouteReferences: routeReferences,
  };
}

function extractRuntimeRouteGraph(source, goRouterBlock) {
  const routeListBlock = extractTopLevelNamedList(goRouterBlock.body, "routes");
  const routeHelperNames = [];
  const routeHelperBlocks = [];
  const routeFactoryBlocksByName = new Map();
  const routeFactoryMisses = new Set();
  const queue = extractRouteHelperCalls(routeListBlock.text);

  for (let index = 0; index < queue.length; index += 1) {
    const helperName = queue[index];
    if (
      routeFactoryBlocksByName.has(helperName) ||
      routeFactoryMisses.has(helperName)
    ) {
      continue;
    }

    const helperBlock = extractRouteFactoryBlock(source, helperName);
    if (!helperBlock) {
      routeFactoryMisses.add(helperName);
      continue;
    }

    routeFactoryBlocksByName.set(helperName, helperBlock);
    routeHelperNames.push(helperName);
    routeHelperBlocks.push(helperBlock.text);

    for (const nestedHelperName of extractRouteHelperCalls(helperBlock.text)) {
      if (
        routeFactoryBlocksByName.has(nestedHelperName) ||
        routeFactoryMisses.has(nestedHelperName) ||
        queue.includes(nestedHelperName)
      ) {
        continue;
      }
      queue.push(nestedHelperName);
    }
  }

  return {
    text: [routeListBlock.text, ...routeHelperBlocks].join("\n"),
    routeHelperNames,
  };
}

function extractTopLevelNamedList(source, name) {
  const labelIndex = findTopLevelNamedArgument(source, name);
  if (labelIndex === -1) {
    throw new Error(`Could not find top-level ${name}: argument.`);
  }
  return extractBalancedBlock(source, `${name}:`, "[", "]", labelIndex);
}

function findTopLevelNamedArgument(source, name) {
  let parenDepth = 0;
  let bracketDepth = 0;
  let braceDepth = 0;
  let stringQuote = null;
  let escaped = false;
  const label = `${name}:`;

  for (let index = 0; index < source.length; index += 1) {
    const char = source[index];

    if (stringQuote) {
      if (escaped) {
        escaped = false;
      } else if (char === "\\") {
        escaped = true;
      } else if (char === stringQuote) {
        stringQuote = null;
      }
      continue;
    }

    if (char === "'" || char === '"') {
      stringQuote = char;
      continue;
    }

    if (
      parenDepth === 0 &&
      bracketDepth === 0 &&
      braceDepth === 0 &&
      source.startsWith(label, index) &&
      !isIdentifierChar(source[index - 1] ?? "")
    ) {
      return index;
    }

    if (char === "(") parenDepth += 1;
    if (char === ")") parenDepth -= 1;
    if (char === "[") bracketDepth += 1;
    if (char === "]") bracketDepth -= 1;
    if (char === "{") braceDepth += 1;
    if (char === "}") braceDepth -= 1;
  }

  return -1;
}

function extractRouteHelperCalls(source) {
  const ignoredNames = new Set(["if", "for", "switch", "while"]);
  const names = [];
  for (const match of source.matchAll(
    /\b([A-Za-z_][A-Za-z0-9_]*)\s*(?:<[^>(){}]+>)?\s*\(/gu
  )) {
    const name = match[1];
    if (ignoredNames.has(name)) continue;
    if (source[match.index - 1] === ".") continue;
    names.push(name);
  }
  return uniqueInOrder(names);
}

function extractRouteFactoryBlock(source, functionName) {
  const match = findFunctionDefinition(source, functionName);
  if (!match || !isRouteFactoryReturnType(match.returnType)) return null;

  const signature = extractBalancedBlock(
    source,
    functionName,
    "(",
    ")",
    match.signatureStart
  );
  const bodyStart = firstNonWhitespaceIndex(source, signature.closeIndex + 1);
  if (source[bodyStart] !== "{") return null;

  return extractBalancedBlock(
    source,
    functionName,
    "{",
    "}",
    match.signatureStart
  );
}

function findFunctionDefinition(source, functionName) {
  const pattern = new RegExp(
    `(^|\\n)\\s*([A-Za-z_][A-Za-z0-9_<>?,]*(?:\\s+[A-Za-z_][A-Za-z0-9_<>?,]*)*)\\s+${escapeRegExp(
      functionName
    )}(?:<[^>(){}]+>)?\\s*\\(`,
    "u"
  );
  const match = source.match(pattern);
  if (!match) return null;

  return {
    returnType: match[2],
    signatureStart: match.index + match[0].indexOf(match[2]),
  };
}

function isRouteFactoryReturnType(returnType) {
  return /\b(?:GoRoute|ShellRoute|StatefulShellRoute|StatefulShellBranch|RouteBase)\b/u.test(
    returnType
  );
}

function extractRuntimeRouteEntries(routeGraphText, enumRoutes) {
  const enumRoutesById = new Map(enumRoutes.map((route) => [route.id, route]));
  const blocks = extractCallBlocks(routeGraphText, "GoRoute");
  const nodes = blocks.map((block) => {
    const pathExpression = extractTopLevelNamedArgumentExpression(
      block.body,
      "path"
    );
    const nameExpression = extractTopLevelNamedArgumentExpression(
      block.body,
      "name"
    );
    const id = parseRouteNameExpression(nameExpression);
    const path = parseRoutePathExpression(pathExpression, enumRoutesById);
    return {
      ...block,
      id,
      path,
      pathExpression: normalizeExpression(pathExpression),
      nameExpression: normalizeExpression(nameExpression),
      parentId: null,
      runtimePath: null,
    };
  });

  for (const node of nodes) {
    const parent = nearestParentGoRoute(node, nodes);
    node.parentId = parent?.id ?? null;
    node.runtimePath = composeRuntimePath(parent?.runtimePath ?? null, node.path);
  }

  return nodes.map((node) => ({
    id: node.id,
    path: node.path,
    runtimePath: node.runtimePath,
    parentId: node.parentId,
    pathExpression: node.pathExpression,
    nameExpression: node.nameExpression,
  }));
}

function extractCallBlocks(source, functionName) {
  const blocks = [];
  let searchIndex = 0;
  while (searchIndex < source.length) {
    const matchIndex = source.indexOf(functionName, searchIndex);
    if (matchIndex === -1) break;

    const before = source[matchIndex - 1] ?? "";
    const after = source[matchIndex + functionName.length] ?? "";
    if (isIdentifierChar(before) || after !== "(") {
      searchIndex = matchIndex + functionName.length;
      continue;
    }

    const block = extractBalancedBlock(
      source,
      functionName,
      "(",
      ")",
      matchIndex
    );
    blocks.push(block);
    searchIndex = block.openIndex + 1;
  }
  return blocks;
}

function nearestParentGoRoute(node, nodes) {
  let parent = null;
  for (const candidate of nodes) {
    if (candidate === node) continue;
    if (
      candidate.labelIndex < node.labelIndex &&
      node.closeIndex < candidate.closeIndex &&
      (parent == null ||
        candidate.closeIndex - candidate.labelIndex <
          parent.closeIndex - parent.labelIndex)
    ) {
      parent = candidate;
    }
  }
  return parent;
}

function extractTopLevelNamedArgumentExpression(source, name) {
  const labelIndex = findTopLevelNamedArgument(source, name);
  if (labelIndex === -1) return null;

  const expressionStart = firstNonWhitespaceIndex(
    source,
    labelIndex + `${name}:`.length
  );
  let parenDepth = 0;
  let bracketDepth = 0;
  let braceDepth = 0;
  let stringQuote = null;
  let escaped = false;

  for (let index = expressionStart; index < source.length; index += 1) {
    const char = source[index];

    if (stringQuote) {
      if (escaped) {
        escaped = false;
      } else if (char === "\\") {
        escaped = true;
      } else if (char === stringQuote) {
        stringQuote = null;
      }
      continue;
    }

    if (char === "'" || char === '"') {
      stringQuote = char;
      continue;
    }
    if (char === "(") parenDepth += 1;
    if (char === ")") parenDepth -= 1;
    if (char === "[") bracketDepth += 1;
    if (char === "]") bracketDepth -= 1;
    if (char === "{") braceDepth += 1;
    if (char === "}") braceDepth -= 1;
    if (
      char === "," &&
      parenDepth === 0 &&
      bracketDepth === 0 &&
      braceDepth === 0
    ) {
      return source.slice(expressionStart, index).trim();
    }
  }

  return source.slice(expressionStart).trim();
}

function parseRouteNameExpression(nameExpression) {
  const normalized = normalizeExpression(nameExpression);
  const match = normalized.match(/^Routes\.([A-Za-z][A-Za-z0-9_]*)\.name$/u);
  if (!match) {
    throw new Error(
      `Every GoRoute must use name: Routes.<id>.name; found ${normalized || "missing name"}.`
    );
  }
  return match[1];
}

function parseRoutePathExpression(pathExpression, enumRoutesById) {
  const normalized = normalizeExpression(pathExpression);
  const routePathMatch = normalized.match(
    /^Routes\.([A-Za-z][A-Za-z0-9_]*)\.path$/u
  );
  if (routePathMatch) {
    const route = enumRoutesById.get(routePathMatch[1]);
    if (!route) {
      throw new Error(
        `GoRoute path references unknown Routes.${routePathMatch[1]}.path.`
      );
    }
    return route.path;
  }

  const stringMatch = normalized.match(/^(['"])(.*)\1$/u);
  if (stringMatch) return stringMatch[2];

  throw new Error(
    `Every GoRoute path must be a string literal or Routes.<id>.path; found ${
      normalized || "missing path"
    }.`
  );
}

function composeRuntimePath(parentPath, pathSegment) {
  if (pathSegment.startsWith("/")) return normalizeRuntimePath(pathSegment);
  if (!parentPath || parentPath === "/") {
    return normalizeRuntimePath(`/${pathSegment}`);
  }
  return normalizeRuntimePath(`${parentPath}/${pathSegment}`);
}

function normalizeRuntimePath(routePath) {
  if (routePath === "/") return routePath;
  return routePath.replace(/\/+/gu, "/").replace(/\/$/u, "");
}

function validateRuntimeRoutes(enumRoutes, runtimeRoutes) {
  const errors = [];
  const enumRoutesById = new Map(enumRoutes.map((route) => [route.id, route]));
  const seenRuntimeIds = new Set();

  for (const runtimeRoute of runtimeRoutes) {
    if (seenRuntimeIds.has(runtimeRoute.id)) {
      errors.push(`Routes.${runtimeRoute.id} is wired by more than one GoRoute.`);
      continue;
    }
    seenRuntimeIds.add(runtimeRoute.id);

    const enumRoute = enumRoutesById.get(runtimeRoute.id);
    if (!enumRoute) {
      errors.push(`GoRoute references Routes.${runtimeRoute.id}, but the enum entry is missing.`);
      continue;
    }
    if (runtimeRoute.runtimePath !== enumRoute.path) {
      errors.push(
        `Routes.${runtimeRoute.id} enum path is ${enumRoute.path}, but the composed runtime path is ${runtimeRoute.runtimePath}.`
      );
    }
  }

  for (const enumRoute of enumRoutes) {
    if (!seenRuntimeIds.has(enumRoute.id)) {
      errors.push(`Routes.${enumRoute.id} is declared but not wired by a GoRoute.`);
    }
  }

  if (errors.length > 0) fail(errors);
}

function extractRouteEnumEntries(enumBody) {
  const entriesBody = enumBody.split(/\n\s*;\s*\n/u)[0] ?? "";
  const withoutLineComments = entriesBody
    .split("\n")
    .filter((line) => !line.trim().startsWith("//"))
    .join("\n");
  const matches = [
    ...withoutLineComments.matchAll(
      /^\s*([A-Za-z][A-Za-z0-9_]*)\s*\(\s*(['"])([^'"]+)\2\s*,?\s*\)\s*,?/gmu
    ),
  ];

  if (matches.length === 0) {
    throw new Error("No Routes enum entries found in lib/routing/go_router.dart.");
  }

  return matches.map((match) => ({
    id: match[1],
    path: match[3],
    pathParameters: extractPathParameters(match[3]),
    requiresFixture: match[3].includes(":"),
    gated: isDevRoute(match[3]),
  }));
}

function extractPathParameters(routePath) {
  return [...routePath.matchAll(/:([A-Za-z][A-Za-z0-9_]*)/g)].map(
    (match) => match[1]
  );
}

function isDevRoute(routePath) {
  return routePath.startsWith("/dev/");
}

function extractGoRouterReturnBlock(source) {
  const returnIndex = source.indexOf("return GoRouter(");
  if (returnIndex === -1) {
    throw new Error("Could not find `return GoRouter(` in lib/routing/go_router.dart.");
  }
  return extractBalancedBlock(source, "return GoRouter", "(", ")", returnIndex);
}

function extractBalancedBlock(source, label, openChar, closeChar, startAt = null) {
  const labelIndex = startAt ?? source.indexOf(label);
  if (labelIndex === -1) {
    throw new Error(`Could not find ${label}.`);
  }
  const openIndex = source.indexOf(openChar, labelIndex);
  if (openIndex === -1) {
    throw new Error(`Could not find ${openChar} after ${label}.`);
  }

  let depth = 0;
  let stringQuote = null;
  let escaped = false;
  for (let index = openIndex; index < source.length; index += 1) {
    const char = source[index];

    if (stringQuote) {
      if (escaped) {
        escaped = false;
      } else if (char === "\\") {
        escaped = true;
      } else if (char === stringQuote) {
        stringQuote = null;
      }
      continue;
    }

    if (char === "'" || char === '"') {
      stringQuote = char;
      continue;
    }
    if (char === openChar) depth += 1;
    if (char === closeChar) {
      depth -= 1;
      if (depth === 0) {
        return {
          labelIndex,
          text: source.slice(labelIndex, index + 1),
          body: source.slice(openIndex + 1, index),
          openIndex,
          closeIndex: index,
        };
      }
    }
  }

  throw new Error(`Could not find balanced ${openChar}${closeChar} block for ${label}.`);
}

function normalizeRouteContract(value) {
  return value
    .replace(/\/\/.*$/gmu, "")
    .replace(/\s+/gu, " ")
    .trim();
}

function normalizeExpression(value) {
  return (value ?? "").replace(/\s+/gu, " ").trim();
}

function stableJson(value) {
  return `${JSON.stringify(value, null, 2)}\n`;
}

function sha256(value) {
  return crypto.createHash("sha256").update(value).digest("hex");
}

function countMatches(value, pattern) {
  return [...value.matchAll(pattern)].length;
}

function uniqueSorted(values) {
  return [...new Set(values)].sort((a, b) => a.localeCompare(b));
}

function uniqueInOrder(values) {
  const seen = new Set();
  const unique = [];
  for (const value of values) {
    if (seen.has(value)) continue;
    seen.add(value);
    unique.push(value);
  }
  return unique;
}

function firstNonWhitespaceIndex(value, startAt) {
  for (let index = startAt; index < value.length; index += 1) {
    if (!/\s/u.test(value[index])) return index;
  }
  return value.length;
}

function isIdentifierChar(value) {
  return /[A-Za-z0-9_]/u.test(value);
}

function escapeRegExp(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/gu, "\\$&");
}

function fail(errors) {
  console.error("UI capture route inventory check failed:");
  for (const error of errors) console.error(`- ${error}`);
  process.exit(1);
}

function printHelp() {
  console.log(`Usage: node tool/ui_capture/check_route_inventory.mjs <command>

Commands:
  --update  Regenerate tool/ui_capture/route_inventory.json from lib/routing/go_router.dart.
  --check   Fail if the route inventory is stale.
  --list    Print the current route ids and paths.
`);
}
