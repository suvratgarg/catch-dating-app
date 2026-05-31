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
  const routes = extractRouteEnumEntries(enumBlock.body);
  const routeContract = normalizeRouteContract(`${enumBlock.text}\n${goRouterBlock.text}`);
  const routeReferences = uniqueSorted(
    [...goRouterBlock.text.matchAll(/\bRoutes\.([A-Za-z0-9_]+)/g)].map(
      (match) => match[1]
    )
  );
  const routeReferenceIds = new Set(routeReferences);

  return {
    version: 1,
    generatedBy: "tool/ui_capture/check_route_inventory.mjs",
    source: {
      path: "lib/routing/go_router.dart",
      normalizedFileSha256: sha256(normalizeRouteContract(source)),
      routeContractSha256: sha256(routeContract),
      goRouteCount: countMatches(goRouterBlock.text, /\bGoRoute\s*\(/g),
      shellBranchCount: countMatches(goRouterBlock.text, /\bStatefulShellBranch\s*\(/g),
      enumRouteCount: routes.length,
      referencedRouteCount: routeReferences.length,
    },
    routes: routes.map((route) => ({
      ...route,
      referencedByGoRouter: routeReferenceIds.has(route.id),
    })),
    goRouterRouteReferences: routeReferences,
  };
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
          text: source.slice(labelIndex, index + 1),
          body: source.slice(openIndex + 1, index),
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
