import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";

const repoRoot = path.resolve(
  path.dirname(fileURLToPath(import.meta.url)),
  "../.."
);
const adminSrcRoot = path.join(repoRoot, "admin/src");
const allowedSourceExtensions = new Set([".ts", ".tsx"]);

function walkSourceFiles(directory) {
  const files = [];
  for (const entry of fs.readdirSync(directory, {withFileTypes: true})) {
    const absolutePath = path.join(directory, entry.name);
    if (entry.isDirectory()) {
      files.push(...walkSourceFiles(absolutePath));
      continue;
    }
    if (allowedSourceExtensions.has(path.extname(entry.name))) {
      files.push(absolutePath);
    }
  }
  return files;
}

function relativeToAdminSource(absolutePath) {
  return path.relative(adminSrcRoot, absolutePath).split(path.sep).join("/");
}

function isInside(parent, child) {
  const relativePath = path.relative(parent, child);
  return relativePath === "" ||
    (!relativePath.startsWith("..") && !path.isAbsolute(relativePath));
}

function layerFor(relativePath) {
  const parts = relativePath.split("/");
  if (parts[0] === "app") {
    return {name: "app"};
  }
  if (parts[0] === "features") {
    return {name: "feature", feature: parts[1] ?? ""};
  }
  if (parts[0] === "shared") {
    return {name: "shared"};
  }
  if (parts[0] === "generated") {
    return {name: "generated"};
  }
  return {name: "root"};
}

function importSpecifiers(source) {
  const staticImports =
    /\bimport\s+(?:type\s+)?(?:[\s\S]*?\s+from\s+)?["']([^"']+)["']/g;
  const dynamicImports = /\bimport\(\s*["']([^"']+)["']\s*\)/g;
  const specifiers = [];
  for (const match of source.matchAll(staticImports)) {
    specifiers.push(match[1]);
  }
  for (const match of source.matchAll(dynamicImports)) {
    specifiers.push(match[1]);
  }
  return specifiers;
}

function allowedExternalImport(sourceRelativePath, targetAbsolutePath) {
  return sourceRelativePath.startsWith("shared/contracts/") &&
    isInside(path.join(repoRoot, "functions/src/shared/generated"), targetAbsolutePath);
}

function violationFor(sourceLayer, targetLayer) {
  if (sourceLayer.name === "shared") {
    if (targetLayer.name === "app" || targetLayer.name === "feature") {
      return "shared modules must not import app or feature modules";
    }
    return null;
  }

  if (sourceLayer.name === "feature") {
    if (targetLayer.name === "app" || targetLayer.name === "root") {
      return "feature modules must not import app-shell or root modules";
    }
    if (
      targetLayer.name === "feature" &&
      targetLayer.feature !== sourceLayer.feature
    ) {
      return `feature '${sourceLayer.feature}' must not import feature '${targetLayer.feature}'`;
    }
    return null;
  }

  if (sourceLayer.name === "app") {
    if (targetLayer.name === "root") {
      return "app-shell modules must not import root entry modules";
    }
    return null;
  }

  return null;
}

const violations = [];
for (const file of walkSourceFiles(adminSrcRoot)) {
  const sourceRelativePath = relativeToAdminSource(file);
  const sourceLayer = layerFor(sourceRelativePath);
  const source = fs.readFileSync(file, "utf8");

  for (const specifier of importSpecifiers(source)) {
    if (specifier.startsWith("@catch/web-ui/")) {
      violations.push({
        source: sourceRelativePath,
        specifier,
        reason: "shared web UI must be imported from @catch/web-ui without deep imports",
      });
      continue;
    }
    if (!specifier.startsWith(".")) {
      continue;
    }

    const targetAbsolutePath = path.resolve(path.dirname(file), specifier);
    if (!isInside(adminSrcRoot, targetAbsolutePath)) {
      if (!allowedExternalImport(sourceRelativePath, targetAbsolutePath)) {
        violations.push({
          source: sourceRelativePath,
          specifier,
          reason: "relative import leaves admin/src without an explicit allowlist",
        });
      }
      continue;
    }

    const targetLayer = layerFor(relativeToAdminSource(targetAbsolutePath));
    const reason = violationFor(sourceLayer, targetLayer);
    if (reason !== null) {
      violations.push({source: sourceRelativePath, specifier, reason});
    }
  }
}

if (violations.length > 0) {
  console.error("Admin import boundary violations:");
  for (const violation of violations) {
    console.error(
      `- ${violation.source} imports ${violation.specifier}: ${violation.reason}`
    );
  }
  process.exitCode = 1;
} else {
  console.log("Admin import boundaries passed.");
}
