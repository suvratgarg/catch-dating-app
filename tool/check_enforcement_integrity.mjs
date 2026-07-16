#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {fromRepo} from "./lib/repo_paths.mjs";

const allowedStages = new Set([
  "manual",
  "prose",
  "scanner-ratchet",
  "scanner-gate",
  "analyzer-info",
  "analyzer-warning",
  "retired",
]);

const allowedRoles = new Set(["gate", "ratchet", "finder", "generator", "operator"]);
const activeRuleStatuses = new Set(["active"]);
const allowedRuleKinds = new Set([
  "contract",
  "scar",
  "process",
  "product-marker",
]);
const allowedSunsetSignalTypes = new Set([
  "tool-exists",
  "baseline-empty",
  "manual",
]);
const allowedSunsetReviewDecisions = new Set(["keep", "graduate", "retire"]);
const explicitRolePathExemptions = [
  /^tool\/web\//u,
  /^tool\/marketing\//u,
  /^tool\/admin\//u,
  /^tool\/design\//u,
  /^tool\/contracts\//u,
  /^tool\/data\//u,
  /^tool\/firebase\//u,
  /^tool\/env\//u,
  /^tool\/ci\//u,
  /^tool\/agent\//u,
  /^tool\/migrations\//u,
];

const isCliEntrypoint =
  process.argv[1] != null &&
  path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);

if (isCliEntrypoint) {
  const result = checkEnforcementIntegrity({root: fromRepo()});
  if (result.errors.length > 0) {
    console.error("Enforcement integrity check failed:");
    for (const error of result.errors) console.error(`- ${error}`);
    process.exitCode = 1;
  } else {
    console.log(
      `Enforcement integrity passed: ${result.activeRules} active rules, ` +
        `${result.boundTools} bound tools.`,
    );
  }
}

export function checkEnforcementIntegrity({root}) {
  const errors = [];
  const rulesPath = path.join(root, "docs/audit_registry/rules.json");
  const manifestPath = path.join(root, "tool/tools_manifest.json");
  const metricsPath = path.join(root, "docs/audit_registry/agent_metrics.jsonl");
  const regressionLedgerPath = path.join(root, "docs/agent_regression_ledger.json");
  const rulesDocument = readJson(rulesPath);
  const manifest = readJson(manifestPath);
  const metrics = readJsonLines(metricsPath);

  const rules = Object.entries(rulesDocument.rules ?? {}).map(([id, value]) => ({
    id,
    ...value,
  }));
  const rulesById = new Map(rules.map((rule) => [rule.id, rule]));
  const tools = Array.isArray(manifest.tools) ? manifest.tools : [];
  const toolsById = new Map(tools.map((tool) => [tool.id, tool]));
  const toolsByPath = new Map(tools.map((tool) => [tool.path, tool]));
  const boundToolIds = new Set();

  for (const rule of rules) {
    if (!activeRuleStatuses.has(rule.status)) continue;
    validateRuleMetadata({
      rule,
      root,
      toolsById,
      errors,
    });
    if (!Array.isArray(rule.enforcement) || rule.enforcement.length === 0) {
      errors.push(`${rule.id}: active rule has no enforcement entries.`);
      continue;
    }
    for (const entry of rule.enforcement) {
      validateRuleEnforcementEntry({
        entry,
        rule,
        root,
        toolsById,
        toolsByPath,
        errors,
      });
      const tool = toolForEntry(entry, toolsById, toolsByPath);
      if (tool) boundToolIds.add(tool.id);
    }
  }

  for (const tool of tools) {
    if (tool.rules != null) {
      if (!Array.isArray(tool.rules) || tool.rules.length === 0) {
        errors.push(`${tool.id}: rules must be a non-empty array when present.`);
      } else {
        for (const ruleId of tool.rules) {
          const rule = rulesById.get(ruleId);
          if (!rule) {
            errors.push(`${tool.id}: references unknown rule ${ruleId}.`);
            continue;
          }
          const ruleHasReverseEntry = (rule.enforcement ?? []).some((entry) => {
            const boundTool = toolForEntry(entry, toolsById, toolsByPath);
            return boundTool?.id === tool.id;
          });
          if (!ruleHasReverseEntry) {
            errors.push(
              `${tool.id}: lists ${ruleId}, but ${ruleId} does not bind back to this tool.`,
            );
          }
        }
      }
    }
    validateToolMetadata({tool, root, metrics, errors});
  }

  for (const scriptPath of discoverArchitectureScripts(root)) {
    const relativePath = normalizePath(path.relative(root, scriptPath));
    const tool = toolsByPath.get(relativePath);
    if (!tool) continue;
    if (tool.status !== "active") continue;
    if (!Array.isArray(tool.rules) || tool.rules.length === 0) {
      errors.push(`${tool.id}: active architecture scanner has no rule mapping.`);
    }
  }

  validateRegressionLedgerGuards({
    root,
    ledgerPath: regressionLedgerPath,
    errors,
  });

  return {
    activeRules: rules.filter((rule) => activeRuleStatuses.has(rule.status))
      .length,
    boundTools: boundToolIds.size,
    errors,
  };
}

function validateRegressionLedgerGuards({root, ledgerPath, errors}) {
  if (!fs.existsSync(ledgerPath)) return;
  const ledger = readJson(ledgerPath);
  for (const entry of ledger.entries ?? []) {
    if (entry?.status !== "active") continue;
    const command = entry.guard?.command;
    if (typeof command !== "string") continue;
    const flutterTest = /^flutter\s+test\s+([^\s]+\.dart)(?:\s|$)/u.exec(command);
    if (!flutterTest) continue;
    if (/\s--plain-name(?:\s|=|$)/u.test(command)) continue;

    const guardEvidence = entry.guard?.guardEvidence ?? entry.guardEvidence;
    if (typeof guardEvidence !== "string" || guardEvidence.trim().length === 0) {
      errors.push(
        `${entry.id}: active flutter test guard for ${flutterTest[1]} needs --plain-name or guardEvidence.`,
      );
      continue;
    }

    const targetPath = path.join(root, flutterTest[1]);
    validateRepoFile({
      root,
      filePath: flutterTest[1],
      owner: entry.id,
      errors,
    });
    const targetSource = readTextIfExists(targetPath);
    if (!targetSource.includes(guardEvidence)) {
      errors.push(
        `${entry.id}: guardEvidence not found in ${flutterTest[1]}: ${guardEvidence}`,
      );
    }
  }
}

function validateRuleEnforcementEntry({
  entry,
  rule,
  root,
  toolsById,
  toolsByPath,
  errors,
}) {
  if (entry == null || typeof entry !== "object" || Array.isArray(entry)) {
    errors.push(`${rule.id}: enforcement entry must be an object.`);
    return;
  }
  if (!allowedStages.has(entry.stage)) {
    errors.push(`${rule.id}: enforcement entry has invalid stage ${entry.stage}.`);
  }
  if (!entry.docAnchor) {
    errors.push(`${rule.id}: enforcement entry is missing docAnchor.`);
  } else {
    validateDocAnchor({root, docAnchor: entry.docAnchor, owner: rule.id, errors});
  }

  if (entry.stage !== "manual" && entry.stage !== "prose" && entry.stage !== "retired") {
    if (!entry.tool) {
      errors.push(`${rule.id}: ${entry.stage} enforcement requires a tool.`);
      return;
    }
    const tool = toolForEntry(entry, toolsById, toolsByPath);
    if (!tool) {
      errors.push(`${rule.id}: enforcement references unknown tool ${entry.tool}.`);
      return;
    }
    if (!Array.isArray(tool.rules) || !tool.rules.includes(rule.id)) {
      errors.push(`${rule.id}: tool ${tool.id} is missing reverse rules mapping.`);
    }
    if (entry.baseline) {
      validateRepoFile({root, filePath: entry.baseline, owner: rule.id, errors});
    }
  }
}

function validateRuleMetadata({rule, root, toolsById, errors}) {
  if (!allowedRuleKinds.has(rule.kind)) {
    errors.push(`${rule.id}: active rule has invalid or missing kind.`);
  }
  if (
    !Array.isArray(rule.sunset_signals) ||
    rule.sunset_signals.length === 0
  ) {
    errors.push(`${rule.id}: active rule has no sunset_signals.`);
    return;
  }

  const satisfiedSignals = [];
  for (const signal of rule.sunset_signals) {
    const result = evaluateSunsetSignal({signal, rule, root, toolsById, errors});
    if (result?.satisfied) satisfiedSignals.push(result.label);
  }

  if (satisfiedSignals.length === 0) return;
  if (!isValidSunsetReview(rule.sunset_review)) {
    errors.push(
      `${rule.id}: sunset signal satisfied (${satisfiedSignals.join(", ")}) but sunset_review is missing or invalid.`,
    );
  }
}

function evaluateSunsetSignal({signal, rule, root, toolsById, errors}) {
  if (signal == null || typeof signal !== "object" || Array.isArray(signal)) {
    errors.push(`${rule.id}: sunset signal must be an object.`);
    return null;
  }
  if (!allowedSunsetSignalTypes.has(signal.type)) {
    errors.push(`${rule.id}: sunset signal has invalid type ${signal.type}.`);
    return null;
  }
  if (signal.type === "manual") return {satisfied: false, label: "manual"};
  if (signal.type === "tool-exists") {
    if (!signal.tool) {
      errors.push(`${rule.id}: tool-exists sunset signal is missing tool.`);
      return null;
    }
    return {
      satisfied: toolsById.has(signal.tool),
      label: `tool-exists:${signal.tool}`,
    };
  }
  if (signal.type === "baseline-empty") {
    if (!signal.baseline || !signal.countKey) {
      errors.push(
        `${rule.id}: baseline-empty sunset signal requires baseline and countKey.`,
      );
      return null;
    }
    const baselinePath = path.join(root, signal.baseline);
    validateRepoFile({
      root,
      filePath: signal.baseline,
      owner: rule.id,
      errors,
    });
    if (!fs.existsSync(baselinePath)) {
      return {satisfied: false, label: `baseline-empty:${signal.baseline}`};
    }
    const baseline = readJson(baselinePath);
    return {
      satisfied: baselineCountForSignal(baseline, signal.countKey) === 0,
      label: `baseline-empty:${signal.baseline}:${signal.countKey}`,
    };
  }
  return null;
}

function baselineCountForSignal(baseline, countKey) {
  if (countKey === "entries") {
    return Array.isArray(baseline.entries) ? baseline.entries.length : null;
  }
  if (countKey === "allowedFindings") {
    return Array.isArray(baseline.allowedFindings)
      ? baseline.allowedFindings.length
      : null;
  }
  if (baseline.maxCounts != null && typeof baseline.maxCounts === "object") {
    return baseline.maxCounts[countKey] ?? null;
  }
  return null;
}

function isValidSunsetReview(review) {
  return (
    review != null &&
    typeof review === "object" &&
    !Array.isArray(review) &&
    /^\d{4}-\d{2}-\d{2}$/u.test(review.date ?? "") &&
    allowedSunsetReviewDecisions.has(review.decision) &&
    typeof review.note === "string" &&
    review.note.trim().length > 0
  );
}

function validateToolMetadata({tool, root, metrics, errors}) {
  if (requiresExplicitRole(tool) && tool.role == null) {
    errors.push(`${tool.id}: active checked tool must declare role.`);
  }
  if (tool.role != null && !allowedRoles.has(tool.role)) {
    errors.push(`${tool.id}: invalid role ${tool.role}.`);
  }
  if (tool.role === "gate" || tool.role === "ratchet") {
    if (!hasRuntimeCheck(tool)) {
      errors.push(
        `${tool.id}: ${tool.role} tool needs a manifest check that can execute the guard, not only syntax/count/help checks.`,
      );
    }
    validateVacuityProof({tool, root, errors});
  }
  if (tool.baseline) {
    validateRepoFile({root, filePath: tool.baseline, owner: tool.id, errors});
    validateBaselineMetric({tool, root, metrics, errors});
  }
}

function validateVacuityProof({tool, root, errors}) {
  const proof = tool.vacuityProof;
  if (proof == null) {
    errors.push(`${tool.id}: ${tool.role} tool is missing vacuityProof.`);
    return;
  }
  if (proof.type === "test") {
    validateRepoFile({root, filePath: proof.path, owner: tool.id, errors});
    if (Array.isArray(proof.contains)) {
      const source = readTextIfExists(path.join(root, proof.path));
      for (const text of proof.contains) {
        if (!source.includes(text)) {
          errors.push(`${tool.id}: vacuity test ${proof.path} does not contain ${text}.`);
        }
      }
    }
    return;
  }
  if (proof.type === "probe-harness") {
    validateRepoFile({root, filePath: proof.path, owner: tool.id, errors});
    const source = readTextIfExists(path.join(root, proof.path));
    for (const diagnostic of proof.diagnostics ?? []) {
      if (!source.includes(diagnostic)) {
        errors.push(
          `${tool.id}: probe harness ${proof.path} does not assert ${diagnostic}.`,
        );
      }
    }
    return;
  }
  if (proof.type === "self-test") {
    if (!proof.command) {
      errors.push(`${tool.id}: self-test vacuityProof requires command.`);
      return;
    }
    if (!(tool.checks ?? []).includes(proof.command)) {
      errors.push(`${tool.id}: self-test command is not listed in manifest checks.`);
    }
    return;
  }
  errors.push(`${tool.id}: unsupported vacuityProof type ${proof.type}.`);
}

function validateBaselineMetric({tool, root, metrics, errors}) {
  const baseline = readJson(path.join(root, tool.baseline));
  const requiredReceipt = baselineReceiptFields(baseline);
  if (requiredReceipt == null) return;
  const matchingMetrics = metrics.filter((entry) => {
    return (
      entry.event === "enforcement_baseline" &&
      entry.baseline === tool.baseline
    );
  });
  const latestMetric = matchingMetrics.at(-1);
  if (!latestMetric) {
    errors.push(`${tool.id}: baseline ${tool.baseline} has no metric receipt.`);
    return;
  }
  if (
    requiredReceipt.maxCounts != null &&
    JSON.stringify(latestMetric.maxCounts) !== JSON.stringify(requiredReceipt.maxCounts)
  ) {
    errors.push(
      `${tool.id}: latest baseline metric does not match ${tool.baseline} maxCounts.`,
    );
  }
  if (
    requiredReceipt.allowedFindingsCount != null &&
    latestMetric.counts?.allowedFindings !==
      requiredReceipt.allowedFindingsCount
  ) {
    errors.push(
      `${tool.id}: latest baseline metric does not match ${tool.baseline} allowedFindings count.`,
    );
  }
}

function hasRuntimeCheck(tool) {
  return (tool.checks ?? []).some((check) => {
    if (/\b(--check|--self-test)\b/u.test(check)) return true;
    if (check.includes("node --test")) return true;
    if (check.includes(tool.command ?? "") && !check.includes("--count")) {
      return true;
    }
    if ((tool.command ?? "").startsWith("bash ") && check === tool.command) {
      return true;
    }
    return false;
  });
}

function requiresExplicitRole(tool) {
  if (tool.status !== "active") return false;
  if (isExplicitRoleExemptPath(tool.path ?? "")) return false;
  if (isCoveredToolPath(tool.path ?? "")) return true;
  return (tool.checks ?? []).some((check) => isRealManifestRun(check));
}

function isCoveredToolPath(toolPath) {
  return (
    /^tool\/[^/]+\.sh$/u.test(toolPath) ||
    /^tool\/check_[^/]+\.mjs$/u.test(toolPath) ||
    /^tool\/(?:architecture|audit)\//u.test(toolPath)
  );
}

function isExplicitRoleExemptPath(toolPath) {
  return explicitRolePathExemptions.some((pattern) => pattern.test(toolPath));
}

function isRealManifestRun(check) {
  const trimmed = String(check).trim();
  if (trimmed.startsWith("bash -n ")) return false;
  if (trimmed.startsWith("node --check ")) return false;
  if (trimmed.startsWith("node --test ")) return false;
  if (trimmed.startsWith("dart analyze ")) return false;
  if (/^python3\b.+\bast\.parse\b/u.test(trimmed)) return false;
  return trimmed.length > 0;
}

function baselineReceiptFields(baseline) {
  const fields = {};
  if (baseline.maxCounts != null) fields.maxCounts = baseline.maxCounts;
  if (Array.isArray(baseline.allowedFindings)) {
    fields.allowedFindingsCount = baseline.allowedFindings.length;
  }
  return Object.keys(fields).length > 0 ? fields : null;
}

function toolForEntry(entry, toolsById, toolsByPath) {
  if (!entry?.tool) return null;
  return toolsById.get(entry.tool) ?? toolsByPath.get(entry.tool) ?? null;
}

function validateDocAnchor({root, docAnchor, owner, errors}) {
  const [filePath, fragment] = String(docAnchor).split("#");
  const absolutePath = path.join(root, filePath);
  if (!fs.existsSync(absolutePath)) {
    errors.push(`${owner}: docAnchor file does not exist: ${filePath}.`);
    return;
  }
  if (!fragment) return;
  if (!filePath.endsWith(".md")) {
    errors.push(`${owner}: docAnchor fragments are supported only for markdown files.`);
    return;
  }
  const source = fs.readFileSync(absolutePath, "utf8");
  const anchors = new Set();
  for (const line of source.split(/\r?\n/u)) {
    const match = /^(#{1,6})\s+(.+)$/u.exec(line);
    if (!match) continue;
    anchors.add(slugifyHeading(match[2]));
  }
  if (!anchors.has(fragment)) {
    errors.push(`${owner}: docAnchor heading not found: ${docAnchor}.`);
  }
}

function slugifyHeading(heading) {
  return heading
    .trim()
    .toLowerCase()
    .replace(/`([^`]+)`/gu, "$1")
    .replace(/[^\p{Letter}\p{Number}\s-]/gu, "")
    .replace(/\s+/gu, "-");
}

function validateRepoFile({root, filePath, owner, errors}) {
  if (!fs.existsSync(path.join(root, filePath))) {
    errors.push(`${owner}: referenced file does not exist: ${filePath}.`);
  }
}

function discoverArchitectureScripts(root) {
  const directory = path.join(root, "tool/architecture");
  if (!fs.existsSync(directory)) return [];
  return fs
    .readdirSync(directory)
    .filter((entry) => entry.endsWith(".mjs") && !entry.endsWith(".test.mjs"))
    .map((entry) => path.join(directory, entry));
}

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function readJsonLines(filePath) {
  if (!fs.existsSync(filePath)) return [];
  return fs
    .readFileSync(filePath, "utf8")
    .split(/\r?\n/u)
    .filter((line) => line.trim().length > 0)
    .map((line) => JSON.parse(line));
}

function readTextIfExists(filePath) {
  return fs.existsSync(filePath) ? fs.readFileSync(filePath, "utf8") : "";
}

function normalizePath(filePath) {
  return filePath.split(path.sep).join("/");
}
