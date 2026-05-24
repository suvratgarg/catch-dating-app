#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";

const toolDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(toolDir, "../..");
const indexPath = path.join(repoRoot, "functions/src/index.ts");

const args = new Set(process.argv.slice(2));
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

const targets = names.map((name) => `functions:${name}`);
const output = args.has("--csv") ? targets.join(",") : `${targets.join("\n")}\n`;
process.stdout.write(output);
