#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {execFileSync} from "node:child_process";
import {fileURLToPath} from "node:url";

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const outputPath = path.join(repoRoot, "docs/audit_registry/test_inventory.json");
const lifecyclePath = path.join(
  repoRoot,
  "docs/audit_registry/test_lifecycle.json",
);

function trackedFiles() {
  return execFileSync(
    "git",
    ["ls-files", "--cached", "--others", "--exclude-standard"],
    {cwd: repoRoot, encoding: "utf8"},
  )
    .trim()
    .split("\n")
    .filter(Boolean);
}

function lifecycleConfig() {
  if (!fs.existsSync(lifecyclePath)) return {exceptionalTests: []};
  return JSON.parse(fs.readFileSync(lifecyclePath, "utf8"));
}

export function looksLikeExecutableTest(file) {
  if (/^(?:functions\/lib|node_modules|build)\//u.test(file)) return false;
  if (/_test\.dart$/u.test(file)) return true;
  if (/(?:\.test|\.spec|_test)\.[cm]?[jt]sx?$/u.test(file)) return true;
  return /\.test\.sh$/u.test(file);
}

export function classifyTest(file) {
  if (/^integration_test\/.*_test\.dart$/.test(file)) return "flutter_integration";
  if (/^test\/.*_test\.dart$/.test(file)) return "flutter_unit_widget";
  if (/^apps\/consumer\/test\/.*_test\.dart$/u.test(file)) {
    return "flutter_consumer_app";
  }
  if (/^apps\/host\/test\/.*_test\.dart$/u.test(file)) {
    return "flutter_host_app";
  }
  if (/^functions\/src\/.*\.test\.ts$/.test(file)) return "functions_source";
  if (/^functions\/test\/.*rules\.test\.cjs$/.test(file)) return "firebase_rules";
  if (/^admin\/.*\.(?:test|spec)\.[cm]?[jt]sx?$/u.test(file)) {
    return "web_admin";
  }
  if (/^website\/.*\.(?:test|spec)\.[cm]?[jt]sx?$/u.test(file)) {
    return "web_marketing";
  }
  if (/^packages\/web-ui\/.*\.(?:test|spec)\.[cm]?[jt]sx?$/u.test(file)) {
    return "web_shared_ui";
  }
  if (/^operations\/test\/.*\.test\.mjs$/u.test(file)) return "operations";
  if (/^tool\/.*(?:\.test|\.spec|_test)\.(?:mjs|cjs|js|dart)$/u.test(file)) {
    return "tooling";
  }
  if (/^tool\/.*\.test\.sh$/u.test(file)) return "tooling";
  if (/^functions\/test\/.*\.test\.cjs$/.test(file)) return "functions_harness";
  return null;
}

export function inferTestKind(file, category = classifyTest(file)) {
  if (file.startsWith("test/goldens/")) return "golden";
  if (category === "flutter_integration") return "integration";
  if (category?.startsWith("flutter_")) return "unit_widget";
  if (category === "firebase_rules") return "rules";
  if (category === "functions_harness") return "harness";
  if (category === "functions_source") return "backend_unit";
  if (category?.startsWith("web_")) return "web_unit_component";
  if (category === "operations") return "workflow_unit_integration";
  if (category === "tooling") return "tool_contract";
  return "unknown";
}

export function inferTestOwner(file, category = classifyTest(file)) {
  if (category === "flutter_consumer_app") return "app/consumer";
  if (category === "flutter_host_app") return "app/host";
  if (category === "flutter_integration") return "flutter/app-shell";
  if (category === "flutter_unit_widget") {
    const feature = file.split("/")[1]?.replace(/_test\.dart$/u, "") ?? "root";
    const aliases = {
      analytics: "core/analytics",
      calendar: "events/calendar",
      profile: "user_profile",
    };
    return `flutter/${aliases[feature] ?? feature}`;
  }
  if (category === "functions_source") {
    return `functions/${file.split("/")[2] ?? "root"}`;
  }
  if (category === "firebase_rules") return "firebase/rules";
  if (category === "functions_harness") return "functions/harness";
  if (category === "web_admin") {
    return inferWebOwner(file, "admin");
  }
  if (category === "web_marketing") {
    return inferWebOwner(file, "website");
  }
  if (category === "web_shared_ui") return "web/shared-ui";
  if (category === "operations") return "operations";
  if (category === "tooling") {
    return `tool/${file.split("/")[1] ?? "root"}`;
  }
  return "unclassified";
}

function inferWebOwner(file, surface) {
  const parts = file.split("/");
  const featureIndex = parts.indexOf("features");
  if (featureIndex >= 0 && parts[featureIndex + 1]) {
    return `${surface}/${parts[featureIndex + 1]}`;
  }
  const sharedIndex = parts.indexOf("shared");
  if (sharedIndex >= 0 && parts[sharedIndex + 1]) {
    return `${surface}/shared/${parts[sharedIndex + 1]}`;
  }
  return `${surface}/${parts[1] ?? "root"}`;
}

function inferredLifecycle(file, kind) {
  if (kind === "golden") return "platform_specific";
  if (file.startsWith("integration_test/")) return "active";
  return "active";
}

export function buildInventory(
  files = trackedFiles(),
  {lifecycle = lifecycleConfig()} = {},
) {
  const executableTests = files.filter(looksLikeExecutableTest);
  const unclassified = executableTests.filter((file) => !classifyTest(file));
  if (unclassified.length > 0) {
    throw new Error(
      `Executable tests are not classified:\n${unclassified.join("\n")}`,
    );
  }

  const exceptionalByPath = new Map(
    (lifecycle.exceptionalTests ?? []).map((entry) => [entry.path, entry]),
  );
  const groups = {};
  const entries = [];
  for (const file of executableTests) {
    const category = classifyTest(file);
    (groups[category] ??= []).push(file);
    const kind = inferTestKind(file, category);
    const exceptional = exceptionalByPath.get(file);
    entries.push({
      path: file,
      category,
      owner: exceptional?.owner ?? inferTestOwner(file, category),
      kind,
      lifecycle: exceptional?.lifecycle ?? inferredLifecycle(file, kind),
      lifecycleSource: exceptional ? "explicit" : "inferred",
    });
  }
  for (const values of Object.values(groups)) values.sort();
  entries.sort((a, b) => a.path.localeCompare(b.path));
  const categories = Object.fromEntries(
    Object.entries(groups)
      .sort()
      .map(([name, values]) => [
        name,
        {count: values.length, files: values},
      ]),
  );
  const owners = Object.fromEntries(
    [...Map.groupBy(entries, (entry) => entry.owner).entries()]
      .sort(([left], [right]) => left.localeCompare(right))
      .map(([owner, ownerEntries]) => [
        owner,
        {
          count: ownerEntries.length,
          files: ownerEntries.map((entry) => entry.path),
        },
      ]),
  );
  const lifecycleCounts = Object.fromEntries(
    [...Map.groupBy(entries, (entry) => entry.lifecycle).entries()]
      .sort(([left], [right]) => left.localeCompare(right))
      .map(([name, lifecycleEntries]) => [name, lifecycleEntries.length]),
  );
  return {
    schemaVersion: 2,
    generatedFrom: "git ls-files --cached --others --exclude-standard",
    generatedBy: "node tool/test_inventory.mjs",
    lifecycleSource: "docs/audit_registry/test_lifecycle.json",
    total: entries.length,
    categories,
    owners,
    lifecycle: {
      counts: lifecycleCounts,
      explicitCount: entries.filter(
        (entry) => entry.lifecycleSource === "explicit",
      ).length,
    },
    entries,
  };
}

export function renderInventory(inventory = buildInventory()) {
  return `${JSON.stringify(inventory, null, 2)}\n`;
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const rendered = renderInventory();
  if (process.argv.includes("--check")) {
    if (!fs.existsSync(outputPath) || fs.readFileSync(outputPath, "utf8") !== rendered) {
      console.error("Test inventory is stale. Run: node tool/test_inventory.mjs");
      process.exit(1);
    }
    console.log("Test inventory is current.");
  } else {
    fs.writeFileSync(outputPath, rendered);
    console.log(`Wrote ${path.relative(repoRoot, outputPath)}.`);
  }
}
