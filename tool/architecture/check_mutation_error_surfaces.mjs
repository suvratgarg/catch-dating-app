#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {fromRepo} from "../lib/repo_paths.mjs";

const isCliEntrypoint =
  process.argv[1] != null &&
  path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);

if (isCliEntrypoint) runCli();

export function scanMutationErrorSurfaces({root = fromRepo()} = {}) {
  const dartFiles = collectDartFiles(path.join(root, "lib"));
  const findings = [];

  for (const file of dartFiles) {
    const source = fs.readFileSync(file, "utf8");
    const relativePath = normalizePath(path.relative(root, file));
    findings.push(...scanFile({relativePath, source}));
  }

  return {
    checkedFiles: dartFiles.length,
    findings,
  };
}

export function scanFile({relativePath, source}) {
  if (!isBuildMethodMutationPendingCandidate(source)) return [];
  if (hasMutationErrorSurface(source)) return [];

  return [
    {
      path: relativePath,
      reason:
        "build method reads mutation pending state but has no mutation error surface",
      pendingLines: pendingLines(source).slice(0, 8),
    },
  ];
}

function collectDartFiles(root) {
  if (!fs.existsSync(root)) return [];
  const files = [];
  walk(root, files);
  return files
    .filter((file) => file.endsWith(".dart"))
    .filter((file) => !file.endsWith(".g.dart"))
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

function isBuildMethodMutationPendingCandidate(source) {
  return (
    /\bWidget\s+build\s*\(/u.test(source) &&
    /\bref\.(?:watch|read)\s*\(/u.test(source) &&
    /\.isPending\b/u.test(source) &&
    /\b[Mm]utation\b/u.test(source)
  );
}

function hasMutationErrorSurface(source) {
  return [
    /\.hasError\b/u,
    /\bCatchMutationErrorBanner\b/u,
    /\bCatchMutationErrorListener(?:s)?\b/u,
    /\bmutationErrorMessage\s*\(/u,
    /\bshowCatchErrorSnackBar\s*\(/u,
  ].some((pattern) => pattern.test(source));
}

function pendingLines(source) {
  const lines = source.split(/\r?\n/u);
  const matches = [];
  for (const [index, line] of lines.entries()) {
    if (!line.includes(".isPending")) continue;
    matches.push({
      line: index + 1,
      text: line.trim(),
    });
  }
  return matches;
}

function parseArgs(rawArgs) {
  const parsed = {
    help: false,
    json: false,
    root: fromRepo(),
  };

  for (let index = 0; index < rawArgs.length; index += 1) {
    const arg = rawArgs[index];
    if (arg === "--help" || arg === "-h") {
      parsed.help = true;
    } else if (arg === "--json") {
      parsed.json = true;
    } else if (arg === "--root") {
      parsed.root = requireValue(rawArgs, (index += 1), arg);
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
  return path.resolve(value);
}

function normalizePath(filePath) {
  return filePath.split(path.sep).join("/");
}

function printFindings(result) {
  console.error(
    `Mutation error surface check failed (${result.findings.length} finding(s)).`,
  );
  for (const finding of result.findings) {
    console.error(`- ${finding.path}: ${finding.reason}`);
    for (const pending of finding.pendingLines) {
      console.error(`  L${pending.line}: ${pending.text}`);
    }
  }
}

function printHelp() {
  console.log(`Usage:
  node tool/architecture/check_mutation_error_surfaces.mjs
  node tool/architecture/check_mutation_error_surfaces.mjs --json
  node tool/architecture/check_mutation_error_surfaces.mjs --root <repo-root>

Scans production lib/**/*.dart build methods. Any file that reads mutation
isPending state from Riverpod must also include a mutation error surface in the
same file, such as CatchMutationErrorListener, CatchMutationErrorBanner,
mutationErrorMessage, showCatchErrorSnackBar, or a direct hasError branch.`);
}

function runCli() {
  const args = parseArgs(process.argv.slice(2));

  if (args.help) {
    printHelp();
    process.exit(0);
  }

  const result = scanMutationErrorSurfaces({root: args.root});

  if (args.json) {
    console.log(JSON.stringify(result, null, 2));
  }

  if (result.findings.length > 0) {
    if (!args.json) printFindings(result);
    process.exit(1);
  }

  if (!args.json) {
    console.log(
      `Mutation error surface check passed (${result.checkedFiles} lib Dart files scanned).`,
    );
  }
}
