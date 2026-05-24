import path from "node:path";
import {createRequire} from "node:module";
import {fileURLToPath} from "node:url";

const libDir = path.dirname(fileURLToPath(import.meta.url));

export const repoRoot = path.resolve(libDir, "../..");
export const toolRoot = path.join(repoRoot, "tool");

export function fromRepo(...segments) {
  return path.join(repoRoot, ...segments);
}

export function relativeToRepo(filePath) {
  return path.relative(repoRoot, filePath);
}

export function createFunctionsRequire() {
  return createRequire(fromRepo("functions/package.json"));
}
