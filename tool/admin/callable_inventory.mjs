import fs from "node:fs";
import path from "node:path";

/** Shared discovery for the Admin validator generator and catalog parity check. */
export function adminCallableNames(source) {
  const direct = [...source.matchAll(/\(\s*functions,\s*["'](admin[A-Z][A-Za-z0-9]+)["']\s*\)/gu)];
  const wrappers = [...source.matchAll(/\b(?:call|invokeAdminCallable)(?:<[^;()]+>)?\s*\(\s*["'](admin[A-Z][A-Za-z0-9]+)["']/gu)];
  return [...new Set([...direct, ...wrappers].map(match => match[1]))].sort();
}

export function readAdminCallableSources(repoRoot) {
  const sources = [];
  const walk = directory => {
    for (const entry of fs.readdirSync(directory, {withFileTypes: true})) {
      const file = path.join(directory, entry.name);
      if (entry.isDirectory()) {
        if (entry.name !== "generated") walk(file);
      } else if (/\.tsx?$/u.test(entry.name) && !/\.(?:test|stories)\./u.test(entry.name)) {
        const source = fs.readFileSync(file, "utf8");
        if (source.includes('from "firebase/functions"')) sources.push(source);
      }
    }
  };
  walk(path.join(repoRoot, "admin/src"));
  return sources.join("\n");
}
