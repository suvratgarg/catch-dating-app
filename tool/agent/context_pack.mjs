#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fromRepo} from "../lib/repo_paths.mjs";

const args = parseArgs(process.argv.slice(2));
const task = args.task ?? "unspecified";
const scopePaths = normalizePaths(args.paths);
const generatedAt = new Date().toISOString();

const docVersions = readJson("docs/audit_registry/doc_versions.json", {});
const rulesFile = readJson("docs/audit_registry/rules.json", {rules: {}});
const regressionLedger = readJson("docs/agent_regression_ledger.json", {entries: []});
const skillManifest = readJson("docs/agent_skills/skills_manifest.json", {skills: []});

const matchedSkills = selectSkills(skillManifest.skills ?? [], task, scopePaths);
const ownerDocs = buildOwnerDocs({task, scopePaths, matchedSkills, docVersions});
const matchedRules = selectRules(rulesFile.rules ?? {}, scopePaths);
const matchedRegressions = selectRegressions(regressionLedger.entries ?? [], scopePaths);
const commands = buildCommandPlan({matchedSkills, matchedRegressions});
const acceptance = buildAcceptance({task, scopePaths, matchedSkills});

const pack = {
  generatedAt,
  task,
  scope: {
    paths: scopePaths,
    note: scopePaths.length === 0
      ? "No paths supplied. Treat this as strategy/planning until scope is declared."
      : "Use these paths as the first pass scope; preserve unrelated dirty work.",
  },
  ownerDocs,
  skills: matchedSkills.map((skill) => ({
    skill_id: skill.skill_id,
    path: skill.path,
    version: skill.version,
    required_tools: skill.required_tools ?? [],
    required_commands: skill.required_commands ?? [],
    success_receipt: skill.success_receipt,
  })),
  activeRules: matchedRules,
  regressionGuards: matchedRegressions,
  commandPlan: commands,
  acceptance,
};

const rendered = args.json ? `${JSON.stringify(pack, null, 2)}\n` : renderMarkdown(pack);

if (args.output) {
  const outputPath = path.isAbsolute(args.output) ? args.output : fromRepo(args.output);
  fs.mkdirSync(path.dirname(outputPath), {recursive: true});
  fs.writeFileSync(outputPath, rendered);
}

process.stdout.write(rendered);

function buildOwnerDocs({task, scopePaths, matchedSkills, docVersions}) {
  const docs = new Map();

  addDoc(docs, "AGENTS.md", "Agent routing entrypoint.", null);
  addDoc(docs, "docs/agent_operating_model.md", "Execution mode and completion contract.", docVersions.agent_operating_model);
  addDoc(docs, "docs/agent_regression_ledger.json", "Regression guards for repeated failure modes.", docVersions.agent_regression_ledger);
  addDoc(docs, "docs/audit_registry/README.md", "Audit registry workflow and pass receipts.", docVersions.audit_registry);

  for (const skill of matchedSkills) {
    addDoc(docs, skill.path, `Project-local skill ${skill.skill_id}.`, null);
    for (const sourceDoc of skill.source_docs ?? []) {
      addDoc(docs, sourceDoc, `Required by ${skill.skill_id}.`, docVersionForPath(sourceDoc, docVersions));
    }
  }

  if (matchesAny(scopePaths, ["lib/**", "test/**"])) {
    addDoc(docs, "docs/app_architecture.md", "Canonical app architecture for lib/test changes.", docVersions.app_architecture);
    addDoc(docs, "lib/README.md", "Feature map for lib/.", docVersions.lib_code_map);
  }
  if (matchesAny(scopePaths, ["docs/**", "PROJECT_CONTEXT.md", "README.md", "AGENTS.md"])) {
    addDoc(docs, "docs/README.md", "Docs source-of-truth index and hygiene policy.", docVersions.docs_index);
    addDoc(docs, "docs/audit_registry/doc_versions.json", "Versioned read policies.", docVersions.audit_doc_versions);
  }
  if (matchesAny(scopePaths, ["tool/**"])) {
    addDoc(docs, "tool/README.md", "Tool ownership, registration, and validation policy.", null);
  }
  if (matchesAny(scopePaths, ["website/**", "packages/web-config/**", "tool/marketing/**", "design/website/**", "docs/marketing_website_architecture.md", "docs/web_surface_architecture.md", "docs/marketing_landing_page_research.md", "docs/marketing_app_media_pipeline.md"])) {
    addDoc(docs, "docs/marketing_website_architecture.md", "Marketing website feature structure and refactor ownership.", docVersions.marketing_website_architecture);
    addDoc(docs, "docs/web_surface_architecture.md", "Marketing website route, deployment, and public surface ownership.", docVersions.web_surface_architecture);
    addDoc(docs, "docs/marketing_landing_page_research.md", "Marketing page positioning, content, and redesign guardrails.", docVersions.marketing_landing_page_research);
    addDoc(docs, "docs/marketing_app_media_pipeline.md", "App-derived marketing media ownership and drift checks.", docVersions.marketing_app_media_pipeline);
    addDoc(docs, "website/README.md", "Marketing app local workflow and analytics setup.", docVersionForPath("website/README.md", docVersions));
    addDoc(docs, "packages/web-config/README.md", "Shared React web config and token plumbing.", docVersionForPath("packages/web-config/README.md", docVersions));
    addDoc(docs, "design/website/routes.json", "Machine-readable marketing website route contract.", docVersionForPath("design/website/routes.json", docVersions));
  }
  if (matchesAny(scopePaths, ["contracts/**", "functions/src/**", "firestore.rules", "storage.rules", "lib/**/data/**", "lib/**/domain/**"])) {
    addDoc(docs, "docs/data_contracts.md", "Data/schema/rules contract source of truth.", docVersions.data_contracts);
    addDoc(docs, "docs/backend_operation_catalog.md", "Backend write and projection ownership catalog.", docVersions.backend_operation_catalog);
  }
  if (matchesAny(scopePaths, ["lib/**/presentation/**", "lib/core/widgets/**", "widgetbook/**", "docs/design_parity/**", "design/components/**", "design/screens/**", "design/tokens/**", "design_context_pack/**"])) {
    addDoc(docs, "docs/design_parity/README.md", "Design parity workflow and state matrix owner.", docVersions.design_parity_tracker);
    addDoc(docs, "docs/widget_catalog.md", "Widget ownership and catalog update rules.", docVersions.widget_catalog);
    addDoc(docs, "docs/design_language.md", "Visual identity and design language source of truth.", docVersions.design_language);
  }
  if (matchesAny(scopePaths, [".github/workflows/**", "firebase.json", ".firebaserc", "ios/**", "android/**"])) {
    addDoc(docs, "docs/release_operations.md", "Release, CI, deploy, and environment gates.", docVersions.release_operations);
    addDoc(docs, "docs/web_surface_architecture.md", "Web/deploy surface ownership.", docVersions.web_surface_architecture);
  }

  if (task.includes("doc")) {
    addDoc(docs, "docs/README.md", "Task name indicates documentation work.", docVersions.docs_index);
  }

  return [...docs.values()].filter((doc) => fileExists(doc.path));
}

function addDoc(docs, docPath, reason, versionEntry) {
  const existing = docs.get(docPath);
  const nextReason = existing ? `${existing.reason} ${reason}` : reason;
  docs.set(docPath, {
    path: docPath,
    version: versionEntry?.version ?? null,
    status: versionEntry?.status ?? null,
    read_policy: versionEntry?.read_policy ?? null,
    reason: nextReason.trim(),
  });
}

function docVersionForPath(docPath, docVersions) {
  return Object.values(docVersions).find((entry) => entry.path === docPath) ?? null;
}

function selectSkills(skills, task, scopePaths) {
  const scoped = skills.filter((skill) => matchesAny(scopePaths, skill.applies_to ?? []));
  if (scoped.length > 0) return scoped;

  const taskText = task.toLowerCase();
  const selected = skills.filter((skill) => {
    const id = String(skill.skill_id ?? "").toLowerCase();
    return taskText.split(/[^a-z0-9]+/).some((part) => part.length > 2 && id.includes(part));
  });
  return selected.length > 0 ? selected : skills.filter((skill) => skill.skill_id === "catch-doc-hygiene");
}

function selectRules(rules, scopePaths) {
  return Object.entries(rules)
    .filter(([, rule]) => ["active", "watch"].includes(rule.status))
    .filter(([id, rule]) => {
      if (scopePaths.length === 0) return ["AUDIT-REGISTRY-001", "DOC-HYGIENE-001"].includes(id);
      return matchesAny(scopePaths, rule.applies_to ?? []);
    })
    .map(([id, rule]) => ({
      id,
      title: rule.title,
      status: rule.status,
      applies_to: rule.applies_to ?? [],
      instruction: rule.instruction,
    }));
}

function selectRegressions(entries, scopePaths) {
  return entries
    .filter((entry) => ["active", "watch"].includes(entry.status))
    .filter((entry) => scopePaths.length === 0 || matchesAny(scopePaths, entry.applies_to ?? []))
    .map((entry) => ({
      id: entry.id,
      title: entry.title,
      status: entry.status,
      applies_to: entry.applies_to ?? [],
      symptom: entry.symptom,
      guard: entry.guard,
      owner_docs: entry.owner_docs ?? [],
    }));
}

function buildCommandPlan({matchedSkills, matchedRegressions}) {
  const commands = [];
  addCommand(commands, "node tool/agent/check_agent_readiness.mjs", "Validate agent harness before handoff.");
  for (const skill of matchedSkills) {
    for (const command of skill.required_commands ?? []) {
      addCommand(commands, command, `Required by ${skill.skill_id}.`);
    }
  }
  for (const regression of matchedRegressions) {
    if (regression.guard?.type === "command") {
      addCommand(commands, regression.guard.command, `Regression guard ${regression.id}.`);
    }
  }
  return commands;
}

function addCommand(commands, command, reason) {
  if (!command) return;
  const existing = commands.find((entry) => entry.command === command);
  if (existing) {
    existing.reason = `${existing.reason} ${reason}`.trim();
    return;
  }
  commands.push({command, reason});
}

function buildAcceptance({task, scopePaths, matchedSkills}) {
  const items = [
    "Scope and excluded dirty work are stated before edits.",
    "Owner docs are updated or explicitly left unchanged.",
    "Relevant checks from the command plan are run or blockers are documented.",
    "New recurring debt or regression risk has a stable id.",
  ];
  if (matchedSkills.some((skill) => skill.skill_id.includes("architecture") || skill.skill_id.includes("doc"))) {
    items.push("Audit registry is refreshed and cleanup/refactor proof is stamped when source files change.");
  }
  if (matchedSkills.some((skill) => skill.skill_id.includes("ui") || skill.skill_id.includes("design"))) {
    items.push("Widgetbook, contracts, captures, or design ledgers are refreshed when UI/API coverage changed.");
  }
  if (scopePaths.length === 0 || task === "unspecified") {
    items.unshift("Task name and paths are narrowed before implementation.");
  }
  return items;
}

function renderMarkdown(pack) {
  const lines = [];
  lines.push("# Agent Context Pack");
  lines.push("");
  lines.push(`- Task: ${pack.task}`);
  lines.push(`- Generated: ${pack.generatedAt}`);
  lines.push(`- Scope: ${pack.scope.paths.length > 0 ? pack.scope.paths.join(", ") : "(none supplied)"}`);
  lines.push("");
  lines.push("## Owner Docs");
  for (const doc of pack.ownerDocs) {
    const version = doc.version ? ` v${doc.version}` : "";
    lines.push(`- ${doc.path}${version}: ${doc.reason}`);
  }
  lines.push("");
  lines.push("## Matching Skills");
  for (const skill of pack.skills) {
    lines.push(`- ${skill.skill_id} (${skill.path})`);
  }
  lines.push("");
  lines.push("## Active Rules");
  for (const rule of pack.activeRules) {
    lines.push(`- ${rule.id}: ${rule.title}`);
  }
  lines.push("");
  lines.push("## Regression Guards");
  for (const regression of pack.regressionGuards) {
    lines.push(`- ${regression.id}: ${regression.title} (${regression.guard?.type ?? "unknown"})`);
  }
  lines.push("");
  lines.push("## Command Plan");
  for (const command of pack.commandPlan) {
    lines.push(`- \`${command.command}\`: ${command.reason}`);
  }
  lines.push("");
  lines.push("## Acceptance");
  for (const item of pack.acceptance) {
    lines.push(`- ${item}`);
  }
  lines.push("");
  return `${lines.join("\n")}\n`;
}

function parseArgs(argv) {
  const parsed = {
    task: null,
    paths: [],
    output: null,
    json: false,
  };
  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg === "--task") parsed.task = requireValue(argv, ++i, arg);
    else if (arg === "--path" || arg === "--paths") parsed.paths.push(requireValue(argv, ++i, arg));
    else if (arg === "--output") parsed.output = requireValue(argv, ++i, arg);
    else if (arg === "--json") parsed.json = true;
    else if (arg === "--help" || arg === "-h") {
      printHelp();
      process.exit(0);
    } else if (arg.startsWith("--")) {
      throw new Error(`Unknown argument: ${arg}`);
    } else {
      parsed.paths.push(arg);
    }
  }
  return parsed;
}

function requireValue(argv, index, flag) {
  const value = argv[index];
  if (!value || value.startsWith("--")) throw new Error(`${flag} requires a value.`);
  return value;
}

function normalizePaths(values) {
  return values
    .flatMap((value) => String(value).split(","))
    .map((value) => value.trim())
    .filter(Boolean)
    .map((value) => value.replace(/^\.?\//, ""))
    .filter((value, index, all) => all.indexOf(value) === index);
}

function readJson(relativePath, fallback) {
  try {
    return JSON.parse(fs.readFileSync(fromRepo(relativePath), "utf8"));
  } catch {
    return fallback;
  }
}

function fileExists(relativePath) {
  return fs.existsSync(fromRepo(relativePath));
}

function matchesAny(candidates, patterns) {
  if (!patterns || patterns.length === 0) return false;
  return candidates.some((candidate) => patterns.some((pattern) => matchesPattern(candidate, pattern)));
}

function matchesPattern(candidate, pattern) {
  if (!candidate || !pattern) return false;
  const normalizedCandidate = candidate.replace(/^\.?\//, "");
  const normalizedPattern = pattern.replace(/^\.?\//, "");
  if (normalizedPattern === normalizedCandidate) return true;
  if (normalizedPattern.endsWith("/**")) {
    const prefix = normalizedPattern.slice(0, -3);
    return normalizedCandidate === prefix || normalizedCandidate.startsWith(`${prefix}/`);
  }
  if (!normalizedPattern.includes("*")) {
    return normalizedCandidate.startsWith(`${normalizedPattern}/`);
  }
  const globPattern = escapeRegex(normalizedPattern)
    .replaceAll("**", "__DOUBLE_STAR__")
    .replaceAll("*", "[^/]*")
    .replaceAll("__DOUBLE_STAR__", ".*");
  const regex = new RegExp(`^${globPattern}$`);
  return regex.test(normalizedCandidate);
}

function escapeRegex(value) {
  return value.replace(/[.+?^${}()|[\]\\]/g, "\\$&");
}

function printHelp() {
  console.log(`Usage: node tool/agent/context_pack.mjs --task <name> --paths <path[,path...]>

Options:
  --task name          Task label used to select matching skills.
  --paths paths        Comma-separated or repeated path scope.
  --output path        Write the rendered pack to a file.
  --json               Print JSON instead of Markdown.
`);
}
