#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {spawnSync} from "node:child_process";
import {fromRepo} from "../lib/repo_paths.mjs";
import {createRepositorySnapshot} from "../lib/repository_snapshot.mjs";
import {parseDocumentLifecycleStatus} from "../docs/check_doc_version_monotonic.mjs";
import {taskCommandTemplates} from "../harness/lib/task_contract.mjs";
import {
  buildTaskStartContract,
  CONTEXT_PACK_SCHEMA_V3,
  deriveTaskCheckSelection,
  matchesTaskScopePatterns,
  normalizeTaskScopePaths,
  resolveStructuredCheckPlan,
  TASK_START_MODE,
  taskImpactBlockers,
  taskStartabilityBlockers,
} from "./lib/task_input.mjs";

let parsedCli;
try {
  const parsedArgs = parseArgs(process.argv.slice(2));
  parsedCli = {args: parsedArgs, outputFormat: resolveOutputFormat(parsedArgs)};
} catch (error) {
  console.error(error instanceof Error ? error.message : String(error));
  process.exit(64);
}
const {args, outputFormat} = parsedCli;
const repositorySnapshot = createRepositorySnapshot();
const task = args.task ?? "unspecified";
const mode = args.mode ?? "standard";
const ownedPaths = normalizePaths(args.ownedPaths);
const plannedImpactPaths = args.plannedImpactPaths.length > 0
  ? normalizePaths(args.plannedImpactPaths)
  : ownedPaths;
const selectionPaths = expandSelectionPaths(plannedImpactPaths);
const generatedAt = new Date().toISOString();

const docVersions = readJson("docs/audit_registry/doc_versions.json", {});
const rulesFile = readJson("docs/audit_registry/rules.json", {rules: {}});
const regressionLedger = readJson("docs/agent_regression_ledger.json", {entries: []});
const skillManifest = readJson("docs/agent_skills/skills_manifest.json", {skills: []});
const toolsManifest = readJson("tool/tools_manifest.json", {tools: []});

const selection = deriveTaskCheckSelection({
  task,
  mode,
  impactPaths: selectionPaths,
  skills: skillManifest.skills ?? [],
  regressions: regressionLedger.entries ?? [],
});
const matchedSkills = selection.matchedSkills;
const ownerDocs = buildOwnerDocs({task, selectionPaths, matchedSkills, docVersions});
const matchedRules = selectRules(rulesFile.rules ?? {}, selectionPaths, mode);
const matchedRegressions = selection.matchedRegressions.map(projectRegression);
const sourceState = readSourceState();
const checkPlan = resolveStructuredCheckPlan({
  manifest: toolsManifest,
  requestedChecks: selection.requests,
});
const commands = buildCommandPlan({
  matchedSkills,
  matchedRegressions,
  mode,
  checkPlan,
});
const acceptance = buildAcceptance({task, ownedPaths, plannedImpactPaths, matchedSkills, mode});
const startabilityBlockers = taskStartabilityBlockers({
  taskId: task,
  scopePaths: ownedPaths,
  inspectPath: (relativePath) => {
    if (repositorySnapshot.exists(relativePath)) return "blob";
    if (repositorySnapshot.listPaths({prefix: `${relativePath}/`}).length > 0) return "tree";
    return null;
  },
});
const impactBlockers = taskImpactBlockers({
  ownedPaths,
  plannedImpactPaths,
  inspectPath: (relativePath) => {
    if (repositorySnapshot.exists(relativePath)) return "blob";
    if (repositorySnapshot.listPaths({prefix: `${relativePath}/`}).length > 0) return "tree";
    return null;
  },
});
const explicitImpactBlockers = mode === TASK_START_MODE && args.plannedImpactPaths.length === 0 &&
  ownedPaths.some((relativePath) =>
    repositorySnapshot.listPaths({prefix: `${relativePath}/`}).length > 0)
  ? ["planned_impact_required_for_owned_directory"]
  : [];
const taskStart = buildTaskStartContract({
  taskId: task,
  mode,
  sourceSha: sourceState.sha,
  ownedPaths,
  plannedImpactPaths,
  checkPlan,
  sourceClean: sourceState.clean,
  blockers: [
    ...(mode === TASK_START_MODE ? [] : ["task_start_requires_parallel_delegation_mode"]),
    ...startabilityBlockers,
    ...impactBlockers,
    ...explicitImpactBlockers,
    ...checkPlan.blockers,
  ],
  deferredRegressionIds: selection.deferredRegressionIds,
});

const pack = {
  schema: CONTEXT_PACK_SCHEMA_V3,
  generatedAt,
  sourceSha: sourceState.sha,
  sourceClean: sourceState.clean,
  task,
  mode,
  scope: {
    ownedPaths,
    plannedImpactPaths,
    note: ownedPaths.length === 0
      ? "No owned paths supplied. Treat this as strategy/planning until write authority is declared."
      : "Owned paths are the write ceiling; planned impacts select checks and constrain the actual diff.",
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
  checkPlan,
  taskStart,
  acceptance,
};

const rendered = outputFormat === "json"
  ? `${JSON.stringify(pack, null, 2)}\n`
  : renderMarkdown(pack);

if (args.output) {
  const outputPath = path.isAbsolute(args.output) ? args.output : fromRepo(args.output);
  fs.mkdirSync(path.dirname(outputPath), {recursive: true});
  fs.writeFileSync(outputPath, rendered);
  const relativeOutput = path.relative(fromRepo(), outputPath);
  const receipt = {
    output: relativeOutput === "" || relativeOutput.startsWith("..")
      ? outputPath
      : relativeOutput,
    format: outputFormat,
    schema: pack.schema,
    task: pack.task,
    complete: pack.taskStart.complete,
    digest: pack.taskStart.digest,
    blockerCount: pack.taskStart.blockers.length,
    blockers: pack.taskStart.blockers.slice(0, 10),
    blockersTruncated: pack.taskStart.blockers.length > 10,
  };
  process.stdout.write(outputFormat === "json"
    ? `${JSON.stringify(receipt)}\n`
    : `Context pack written: ${receipt.output} (format=${receipt.format}, task=${receipt.task}, complete=${receipt.complete}, blockers=${receipt.blockers.join(",") || "none"}, digest=${receipt.digest})\n`);
} else {
  process.stdout.write(rendered);
}

function buildOwnerDocs({task, selectionPaths, matchedSkills, docVersions}) {
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

  if (matchesTaskScopePatterns(selectionPaths, ["lib/**", "test/**"])) {
    addDoc(docs, "docs/app_architecture.md", "Canonical app architecture for lib/test changes.", docVersions.app_architecture);
    addDoc(docs, "lib/README.md", "Feature map for lib/.", docVersions.lib_code_map);
  }
  if (matchesTaskScopePatterns(selectionPaths, ["docs/**", "PROJECT_CONTEXT.md", "README.md", "AGENTS.md"])) {
    addDoc(docs, "docs/README.md", "Docs source-of-truth index and hygiene policy.", docVersions.docs_index);
    addDoc(docs, "docs/audit_registry/doc_versions.json", "Versioned read policies.", docVersions.audit_doc_versions);
  }
  if (matchesTaskScopePatterns(selectionPaths, ["tool/**"])) {
    addDoc(docs, "tool/README.md", "Tool ownership, registration, and validation policy.", null);
  }
  if (matchesTaskScopePatterns(selectionPaths, ["website/**", "packages/web-config/**", "tool/marketing/**", "design/website/**", "docs/marketing_website_architecture.md", "docs/web_surface_architecture.md", "docs/marketing_landing_page_research.md", "docs/marketing_app_media_pipeline.md"])) {
    addDoc(docs, "docs/marketing_website_architecture.md", "Marketing website feature structure and refactor ownership.", docVersions.marketing_website_architecture);
    addDoc(docs, "docs/web_surface_architecture.md", "Marketing website route, deployment, and public surface ownership.", docVersions.web_surface_architecture);
    addDoc(docs, "docs/marketing_landing_page_research.md", "Marketing page positioning, content, and redesign guardrails.", docVersions.marketing_landing_page_research);
    addDoc(docs, "docs/marketing_app_media_pipeline.md", "App-derived marketing media ownership and drift checks.", docVersions.marketing_app_media_pipeline);
    addDoc(docs, "website/README.md", "Marketing app local workflow and analytics setup.", docVersionForPath("website/README.md", docVersions));
    addDoc(docs, "packages/web-config/README.md", "Shared React web config and token plumbing.", docVersionForPath("packages/web-config/README.md", docVersions));
    addDoc(docs, "design/website/routes.json", "Machine-readable marketing website route contract.", docVersionForPath("design/website/routes.json", docVersions));
  }
  if (matchesTaskScopePatterns(selectionPaths, ["contracts/**", "functions/src/**", "firestore.rules", "storage.rules", "lib/**/data/**", "lib/**/domain/**"])) {
    addDoc(docs, "docs/data_contracts.md", "Data/schema/rules contract source of truth.", docVersions.data_contracts);
    addDoc(docs, "docs/backend_operation_catalog.md", "Backend write and projection ownership catalog.", docVersions.backend_operation_catalog);
  }
  if (matchesTaskScopePatterns(selectionPaths, ["lib/**/presentation/**", "lib/core/widgets/**", "widgetbook/**", "docs/design_parity/**", "design/components/**", "design/screens/**", "design/tokens/**", "design_context_pack/**"])) {
    addDoc(docs, "docs/design_parity/README.md", "Design parity workflow and state matrix owner.", docVersions.design_parity_tracker);
    addDoc(docs, "docs/widget_catalog.md", "Widget ownership and catalog update rules.", docVersions.widget_catalog);
    addDoc(docs, "docs/design_language.md", "Visual identity and design language source of truth.", docVersions.design_language);
  }
  if (matchesTaskScopePatterns(selectionPaths, [".github/workflows/**", "firebase.json", ".firebaserc", "ios/**", "android/**"])) {
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
  const markdown = docPath.endsWith(".md");
  const status = markdown
    ? parseDocumentLifecycleStatus(repositorySnapshot.readText(docPath) ?? "")
    : versionEntry?.status ?? null;
  if (markdown && versionEntry != null && status == null) {
    throw new Error(
      `Governed Markdown ${docPath} has no single valid source-frontmatter lifecycle status.`,
    );
  }
  docs.set(docPath, {
    path: docPath,
    version: versionEntry?.version ?? null,
    status,
    read_policy: versionEntry?.read_policy ?? null,
    reason: nextReason.trim(),
  });
}

function docVersionForPath(docPath, docVersions) {
  return Object.values(docVersions).find((entry) => entry.path === docPath) ?? null;
}

function selectRules(rules, selectionPaths, mode) {
  return Object.entries(rules)
    .filter(([, rule]) => ["active", "watch"].includes(rule.status))
    .filter(([id, rule]) => {
      if (mode === "parallel-delegation" && id === "AGENT-DELEGATION-001") return true;
      if (selectionPaths.length === 0) return ["AUDIT-REGISTRY-001", "DOC-HYGIENE-001"].includes(id);
      return matchesTaskScopePatterns(selectionPaths, rule.applies_to ?? []);
    })
    .map(([id, rule]) => ({
      id,
      title: rule.title,
      status: rule.status,
      applies_to: rule.applies_to ?? [],
      instruction: rule.instruction,
    }));
}

function projectRegression(entry) {
  return {
    id: entry.id,
    title: entry.title,
    status: entry.status,
    applies_to: entry.applies_to ?? [],
    symptom: entry.symptom,
    guard: entry.guard,
    owner_docs: entry.owner_docs ?? [],
  };
}

function buildCommandPlan({matchedSkills, matchedRegressions, mode, checkPlan}) {
  const commands = [];
  if (mode === TASK_START_MODE) {
    addCommand(commands, taskCommandTemplates.start, "Create the bounded task worktree from this pack.", {
      owner: "parent",
      phase: "lifecycle-start",
    });
    addCommand(commands, taskCommandTemplates.doctor, "Verify task integrity before worker execution.", {
      owner: "worker",
      phase: "preflight",
    });
    addCommand(commands, taskCommandTemplates.finish, "Verify, close, and unlock the pushed task branch.", {
      owner: "parent",
      phase: "lifecycle-finish",
    });
    addCommand(
      commands,
      taskCommandTemplates.recoverLease,
      "Recover a stale execution lease only after its owner, transition claimant, and recorded child process groups are dead.",
      {owner: "parent", phase: "lifecycle-recovery"},
    );
    addCommand(commands, taskCommandTemplates.reap, "Report stale terminal worktrees without mutating them.", {
      owner: "parent",
      phase: "maintenance",
    });
    addCommand(
      commands,
      "node tool/agent/record_delegation_outcome.mjs --help",
      "Record the parent-reviewed delegation outcome.",
      {owner: "parent", phase: "receipt-guidance"},
    );
    addCheckCommand(commands, checkPlan.task, "worker", "task-check", "Run the bounded task checks.");
    addCheckCommand(
      commands,
      checkPlan.integration,
      "parent",
      "integration-check",
      "Run checks that require the full repository view.",
    );
  } else {
    addCommand(commands, "node tool/agent/check_agent_readiness.mjs", "Validate agent harness before handoff.", {
      owner: "current-agent",
      phase: "current-task",
    });
  }
  for (const skill of matchedSkills) {
    for (const command of skill.required_commands ?? []) {
      addCommand(commands, command, `Guidance from ${skill.skill_id}; the parent owns integration.`, {
        owner: mode === TASK_START_MODE ? "parent" : "current-agent",
        phase: mode === TASK_START_MODE ? "integration-guidance" : "current-task",
      });
    }
  }
  for (const regression of matchedRegressions) {
    if (regression.guard?.type === "command" &&
        (!Array.isArray(regression.guard.check_ids) || regression.guard.check_ids.length === 0)) {
      addCommand(commands, regression.guard.command, `Unstructured regression guard ${regression.id}.`, {
        owner: mode === TASK_START_MODE ? "parent" : "current-agent",
        phase: mode === TASK_START_MODE ? "deferred-regression" : "current-task",
      });
    }
  }
  return commands;
}

function addCheckCommand(commands, checks, owner, phase, reason) {
  const ids = checks.map((entry) => entry.id);
  if (ids.length === 0) return;
  addCommand(commands, `node tool/run.mjs check ${ids.join(" ")}`, reason, {owner, phase});
}

function addCommand(commands, command, reason, {owner, phase}) {
  if (!command) return;
  const existing = commands.find((entry) =>
    entry.command === command && entry.owner === owner && entry.phase === phase);
  if (existing) {
    existing.reason = `${existing.reason} ${reason}`.trim();
    return;
  }
  commands.push({command, owner, phase, reason});
}

function buildAcceptance({task, ownedPaths, plannedImpactPaths, matchedSkills, mode}) {
  const items = [
    "Owned write paths, planned impact paths, and excluded dirty work are stated before edits.",
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
  if (mode === "parallel-delegation") {
    items.push("Worker runs only worker-owned commands; parent retains integration checks, canonical docs, registries, audit receipts, and final verification.");
  }
  if (ownedPaths.length === 0 || plannedImpactPaths.length === 0 || task === "unspecified") {
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
  lines.push(`- Owned write paths: ${pack.scope.ownedPaths.length > 0 ? pack.scope.ownedPaths.join(", ") : "(none supplied)"}`);
  lines.push(`- Planned impact paths: ${pack.scope.plannedImpactPaths.length > 0 ? pack.scope.plannedImpactPaths.join(", ") : "(none supplied)"}`);
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
  lines.push("## Task Start Contract");
  lines.push(`- Schema: ${pack.taskStart.schema}`);
  lines.push(`- Source SHA: ${pack.sourceSha}`);
  lines.push(`- Complete: ${pack.taskStart.complete}`);
  lines.push(`- Task checks: ${pack.taskStart.checkIds.join(", ") || "(none)"}`);
  lines.push(`- Deferred integration checks: ${pack.taskStart.deferredCheckIds.join(", ") || "(none)"}`);
  lines.push(`- Deferred unstructured regressions: ${pack.taskStart.deferredRegressionIds.join(", ") || "(none)"}`);
  lines.push(`- Support paths: ${pack.taskStart.supportPaths.join(", ") || "(none)"}`);
  lines.push(`- Required entrypoints: ${pack.taskStart.requiredEntrypoints.join(", ") || "(none)"}`);
  for (const blocker of pack.taskStart.blockers) lines.push(`- Blocker: ${blocker}`);
  lines.push("");
  for (const group of [
    {title: "Worker Task Commands", owners: ["worker"]},
    {title: "Parent Integration Commands", owners: ["parent"]},
    {title: "Current-Agent Commands", owners: ["current-agent"]},
  ]) {
    const commands = pack.commandPlan.filter((entry) => group.owners.includes(entry.owner));
    if (commands.length === 0) continue;
    lines.push(`## ${group.title}`);
    for (const command of commands) {
      lines.push(`- [${command.phase}] \`${command.command}\`: ${command.reason}`);
    }
    lines.push("");
  }
  lines.push("## Acceptance");
  for (const item of pack.acceptance) {
    lines.push(`- ${item}`);
  }
  lines.push("");
  return `${lines.join("\n")}\n`;
}

function readSourceState() {
  const sha = runGit(["rev-parse", "HEAD"]).trim();
  const status = runGit(["status", "--porcelain", "--untracked-files=normal"]);
  return {sha, clean: status.trim() === ""};
}

function runGit(args) {
  const result = spawnSync("git", args, {
    cwd: fromRepo(),
    encoding: "utf8",
    shell: false,
    env: {...process.env, GIT_OPTIONAL_LOCKS: "0", GIT_NO_LAZY_FETCH: "1"},
  });
  if (result.error) throw result.error;
  if (result.status !== 0) {
    throw new Error(result.stderr || `git ${args.join(" ")} failed.`);
  }
  return result.stdout;
}

function parseArgs(argv) {
  const parsed = {
    task: null,
    mode: null,
    ownedPaths: [],
    plannedImpactPaths: [],
    output: null,
    json: false,
  };
  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg === "--task") parsed.task = requireValue(argv, ++i, arg);
    else if (arg === "--mode") parsed.mode = requireValue(argv, ++i, arg);
    else if (arg === "--owned-paths") parsed.ownedPaths.push(requireValue(argv, ++i, arg));
    else if (arg === "--planned-impact-paths") {
      parsed.plannedImpactPaths.push(requireValue(argv, ++i, arg));
    }
    else if (arg === "--output") parsed.output = requireValue(argv, ++i, arg);
    else if (arg === "--json") parsed.json = true;
    else if (arg === "--help" || arg === "-h") {
      printHelp();
      process.exit(0);
    } else if (arg.startsWith("--")) {
      throw new Error(`Unknown argument: ${arg}`);
    } else throw new Error(`Unexpected positional context-pack argument: ${arg}`);
  }
  if (parsed.mode != null && parsed.mode !== "parallel-delegation") {
    throw new Error(`Unsupported context-pack mode: ${parsed.mode}`);
  }
  return parsed;
}

function resolveOutputFormat({json, output}) {
  const explicitFormat = json ? "json" : null;
  const extension = output == null ? "" : path.extname(output).toLowerCase();
  const inferredFormat = extension === ".json"
    ? "json"
    : ([".md", ".markdown"].includes(extension) ? "markdown" : null);

  if (explicitFormat != null && inferredFormat != null && explicitFormat !== inferredFormat) {
    throw new Error(
      `Output suffix ${extension} conflicts with requested ${explicitFormat} format: ${output}`,
    );
  }
  if (explicitFormat != null) return explicitFormat;
  if (inferredFormat != null) return inferredFormat;
  if (output != null) {
    throw new Error(
      "--output requires a .json, .md, or .markdown suffix unless --json is supplied.",
    );
  }
  return "markdown";
}

function requireValue(argv, index, flag) {
  const value = argv[index];
  if (!value || value.startsWith("--")) throw new Error(`${flag} requires a value.`);
  return value;
}

function normalizePaths(values) {
  return normalizeTaskScopePaths(values);
}

function expandSelectionPaths(scopePaths) {
  const selected = new Set(scopePaths);
  for (const scopePath of scopePaths) {
    for (const descendant of repositorySnapshot.listPaths({prefix: `${scopePath}/`})) {
      selected.add(descendant);
    }
  }
  return [...selected].sort();
}

function readJson(relativePath, fallback) {
  return repositorySnapshot.readJson(relativePath) ?? fallback;
}

function fileExists(relativePath) {
  return repositorySnapshot.exists(relativePath);
}

function printHelp() {
  console.log(`Usage: node tool/agent/context_pack.mjs --task <name> --owned-paths <path[,path...]> [--planned-impact-paths <path[,path...]>] [--mode parallel-delegation]

Options:
  --task name          Task label used to select matching skills.
  --mode mode          Add the canonical parallel-delegation lifecycle.
  --owned-paths paths          Comma-separated or repeated owned/write paths.
  --planned-impact-paths paths Comma-separated or repeated expected change paths. Defaults to owned paths except delegated directory ownership requires an explicit value.
  --output path        Write the pack and print only a compact receipt. .json, .md, and .markdown infer format.
  --json               Serialize as JSON. Required for an unrecognized output suffix and must agree with recognized suffixes.
`);
}
