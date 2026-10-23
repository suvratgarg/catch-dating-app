import fs from "node:fs";
import path from "node:path";
import {pathToFileURL} from "node:url";
import {repoRoot} from "./repo_paths.mjs";

// dependency-cruiser, and the TypeScript it reads functions/ with, are pinned in
// this package and installed with `npm ci --prefix tool/impact`.
export const importGraphPackageDir = "tool/impact";

/** Loads the pinned dependency-cruiser, or null when tool/impact is not installed. */
export async function loadDependencyCruiser({cwd = repoRoot} = {}) {
  const packageDir = path.join(cwd, importGraphPackageDir, "node_modules", "dependency-cruiser");
  let meta;
  try {
    meta = JSON.parse(fs.readFileSync(path.join(packageDir, "package.json"), "utf8"));
  } catch {
    return null;
  }
  const load = (entry) => import(pathToFileURL(path.join(packageDir, meta.exports[entry].import)).href);
  const {cruise} = await load(".");
  const {default: extractTSConfig} = await load("./config-utl/extract-ts-config");
  return {version: meta.version, cruise, extractTSConfig};
}

export function cruiseModules(result) {
  const output = typeof result.output === "string" ? JSON.parse(result.output) : result.output;
  return output.modules;
}
