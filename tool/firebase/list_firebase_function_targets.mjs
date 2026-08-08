#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";

const toolDir = path.dirname(fileURLToPath(import.meta.url));
const defaultRepoRoot = path.resolve(toolDir, "../..");

export function listFirebaseFunctionTargets(sourceRoot = defaultRepoRoot) {
  const indexPath = path.join(path.resolve(sourceRoot), "functions/src/index.ts");
  const stat = fs.lstatSync(indexPath);
  if (!stat.isFile() || stat.isSymbolicLink()) {
    throw new Error(`Functions export source must be a regular file: ${indexPath}`);
  }
  const source = fs.readFileSync(indexPath, "utf8");
  const names = [];

  for (const match of source.matchAll(/export\s*\{([\s\S]*?)\}\s*from\s*["']/g)) {
    const exportsBlock = match[1];
    for (const rawPart of exportsBlock.split(",")) {
      const part = rawPart.trim();
      if (!part) continue;

      const aliasMatch = part.match(/\s+as\s+([A-Za-z_$][\w$]*)$/);
      const name = aliasMatch?.[1] ?? part.match(/^([A-Za-z_$][\w$]*)/)?.[1];
      if (!name) {
        throw new Error(`Could not parse exported function target from: ${part}`);
      }
      names.push(name);
    }
  }

  if (names.length === 0) {
    throw new Error(`No Firebase function exports found in ${indexPath}`);
  }
  return names.map((name) => `functions:${name}`);
}

function main() {
  const args = new Set(process.argv.slice(2));
  for (const arg of args) {
    if (arg !== "--csv") throw new Error(`Unknown argument: ${arg}`);
  }
  const targets = listFirebaseFunctionTargets();
  const output = args.has("--csv") ? targets.join(",") : `${targets.join("\n")}\n`;
  process.stdout.write(output);
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  try {
    main();
  } catch (error) {
    process.stderr.write(`${error.message}\n`);
    process.exitCode = 1;
  }
}
