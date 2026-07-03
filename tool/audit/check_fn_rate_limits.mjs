#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {fromRepo} from "../lib/repo_paths.mjs";

const isCliEntrypoint =
  process.argv[1] != null &&
  path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);

if (isCliEntrypoint) runCli();

export function scanFunctionRateLimits({root}) {
  const sourceRoot = path.join(root, "functions/src");
  const files = collectTypeScriptFiles(sourceRoot);
  const actions = new Map();
  let rateLimitKeys = new Set();

  for (const file of files) {
    const source = fs.readFileSync(file, "utf8");
    const relativePath = normalizePath(path.relative(root, file));
    if (relativePath.endsWith("functions/src/shared/rateLimit.ts")) {
      rateLimitKeys = extractRateLimitKeys(source);
    }
    for (const action of extractCheckRateLimitActions(source)) {
      if (!actions.has(action.value)) actions.set(action.value, []);
      actions.get(action.value).push({
        path: relativePath,
        line: lineForOffset(source, action.offset),
      });
    }
  }

  const findings = [];
  for (const [action, locations] of [...actions.entries()].sort()) {
    if (rateLimitKeys.has(action)) continue;
    findings.push({
      rule: "missingRateLimitEntry",
      action,
      locations,
      reason: "checkRateLimit action must have an explicit RATE_LIMITS entry",
    });
  }

  return {
    checkedFiles: files.length,
    actions: [...actions.keys()].sort(),
    rateLimitKeys: [...rateLimitKeys].sort(),
    findings,
  };
}

export function extractRateLimitKeys(source) {
  const assignment = /RATE_LIMITS\s*:\s*Record<[^>]+>\s*=\s*\{/u.exec(source);
  if (!assignment) return new Set();
  const openBrace = source.indexOf("{", assignment.index);
  const closeBrace = findMatchingBrace(source, openBrace);
  if (closeBrace == null) return new Set();
  const body = source.slice(openBrace + 1, closeBrace);
  return extractTopLevelObjectKeys(body);
}

function extractTopLevelObjectKeys(body) {
  const keys = new Set();
  let depth = 0;
  let quote = null;
  for (let index = 0; index < body.length; index += 1) {
    const char = body[index];
    const previous = body[index - 1];
    if (quote != null) {
      if (char === quote && previous !== "\\") quote = null;
      continue;
    }
    if (char === "\"" || char === "'" || char === "`") {
      quote = char;
      continue;
    }
    if (depth === 0) {
      const key = readObjectKeyAt(body, index);
      if (key != null) {
        keys.add(key.name);
        index = key.end - 1;
        continue;
      }
    }
    if (char === "{") depth += 1;
    if (char === "}") depth -= 1;
  }
  return keys;
}

function readObjectKeyAt(source, index) {
  const match = /^\s*,?\s*(?:["']([^"']+)["']|([A-Za-z_$][\w$]*))\s*:/u.exec(
    source.slice(index),
  );
  if (!match) return null;
  return {
    name: match[1] ?? match[2],
    end: index + match[0].length,
  };
}

export function extractCheckRateLimitActions(source) {
  const actions = [];
  const callPattern = /(?:\b\w+\.)?checkRateLimit\s*\(/gu;
  for (const match of source.matchAll(callPattern)) {
    const openParen = source.indexOf("(", match.index);
    const closeParen = findMatchingParen(source, openParen);
    if (closeParen == null) continue;
    const callBody = source.slice(openParen + 1, closeParen);
    const literal = /["']([^"']+)["']/u.exec(callBody);
    if (!literal) continue;
    actions.push({
      value: literal[1],
      offset: openParen + 1 + (literal.index ?? 0),
    });
  }
  return actions;
}

function collectTypeScriptFiles(root) {
  if (!fs.existsSync(root)) return [];
  const files = [];
  walk(root, files);
  return files
    .filter((file) => file.endsWith(".ts"))
    .filter((file) => !file.endsWith(".test.ts"))
    .sort((a, b) => a.localeCompare(b));
}

function walk(directory, files) {
  for (const entry of fs.readdirSync(directory, {withFileTypes: true})) {
    const absolutePath = path.join(directory, entry.name);
    if (entry.isDirectory()) {
      walk(absolutePath, files);
    } else if (entry.isFile()) {
      files.push(absolutePath);
    }
  }
}

function findMatchingParen(source, openIndex) {
  return findMatchingDelimited(source, openIndex, "(", ")");
}

function findMatchingBrace(source, openIndex) {
  return findMatchingDelimited(source, openIndex, "{", "}");
}

function findMatchingDelimited(source, openIndex, openChar, closeChar) {
  let depth = 0;
  let quote = null;
  for (let index = openIndex; index < source.length; index += 1) {
    const char = source[index];
    const previous = source[index - 1];
    if (quote != null) {
      if (char === quote && previous !== "\\") quote = null;
      continue;
    }
    if (char === "\"" || char === "'" || char === "`") {
      quote = char;
      continue;
    }
    if (char === openChar) depth += 1;
    if (char === closeChar) {
      depth -= 1;
      if (depth === 0) return index;
    }
  }
  return null;
}

function lineForOffset(source, offset) {
  let line = 1;
  for (let index = 0; index < offset; index += 1) {
    if (source.charCodeAt(index) === 10) line += 1;
  }
  return line;
}

function parseArgs(rawArgs) {
  const parsed = {help: false, json: false, root: null};
  for (let index = 0; index < rawArgs.length; index += 1) {
    const arg = rawArgs[index];
    if (arg === "--help" || arg === "-h") {
      parsed.help = true;
    } else if (arg === "--json") {
      parsed.json = true;
    } else if (arg === "--root") {
      parsed.root = path.resolve(requireValue(rawArgs, (index += 1), arg));
    } else {
      console.error(`Unknown argument: ${arg}`);
      process.exit(2);
    }
  }
  return parsed;
}

function requireValue(argsList, index, flag) {
  const value = argsList[index];
  if (value == null || value.startsWith("--")) {
    console.error(`Missing value for ${flag}`);
    process.exit(2);
  }
  return value;
}

function printFindings(result) {
  console.error(
    `Function rate-limit check failed: ${result.findings.length} action(s) lack RATE_LIMITS entries.`,
  );
  for (const finding of result.findings) {
    console.error(`- ${finding.action}: ${finding.reason}`);
    for (const location of finding.locations) {
      console.error(`  ${location.path}:${location.line}`);
    }
  }
}

function runCli() {
  const args = parseArgs(process.argv.slice(2));
  if (args.help) {
    console.log(`Usage:
  node tool/audit/check_fn_rate_limits.mjs
  node tool/audit/check_fn_rate_limits.mjs --json

Checks every literal checkRateLimit action under functions/src has a matching
RATE_LIMITS entry in functions/src/shared/rateLimit.ts.`);
    return;
  }

  const result = scanFunctionRateLimits({root: args.root ?? fromRepo()});
  if (args.json) console.log(JSON.stringify(result, null, 2));
  if (result.findings.length > 0) {
    if (!args.json) printFindings(result);
    process.exit(1);
  }
  if (!args.json) {
    console.log(
      `Function rate-limit check passed (${result.actions.length} action(s) checked).`,
    );
  }
}

function normalizePath(filePath) {
  return filePath.split(path.sep).join("/");
}
