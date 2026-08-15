#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {spawnSync} from "node:child_process";
import {fileURLToPath} from "node:url";
import {matchesGlobPath} from "../lib/path_glob.mjs";

export class PreCommitGeneratedArtifactError extends Error {}

export function planPreCommitActions({graph, stagedPaths}) {
  const paths = [...new Set(stagedPaths)].sort();
  const generators = Array.isArray(graph?.compileCodegen) ? graph.compileCodegen : [];
  const triggeredGenerators = generators.filter((generator) => {
    if (
      generator.id === "contracts.schema-projections" &&
      paths.some((candidate) => pathIsWithin(candidate, "contracts"))
    ) return true;
    if (
      generator.id === "admin.callable-validators" &&
      paths.some((candidate) => pathIsWithin(candidate, "contracts/callables"))
    ) return true;
    return paths.some((candidate) =>
      [...generator.inputs, ...generator.outputs].some((pattern) =>
        matchesGlobPath(candidate, pattern)));
  });
  const l10n = generators.find((generator) => generator.id === "flutter.l10n");
  const l10nInputChanged = paths.some((candidate) =>
    matchesGlobPath(candidate, "lib/l10n/*.arb") ||
      (l10n?.inputs ?? []).some((pattern) => matchesGlobPath(candidate, pattern)));
  return {
    dartPaths: paths.filter((candidate) => candidate.endsWith(".dart")),
    l10nInputChanged,
    l10nOutputs: l10n?.outputs ?? [],
    l10nWriteCommand: l10n?.writeCommand ?? null,
    triggeredGenerators,
    triggeredGeneratorIds: triggeredGenerators.map((generator) => generator.id),
  };
}

export function runPreCommitGeneratedArtifacts({
  fileExists = defaultFileExists,
  graph,
  repoRoot,
  runCommand = defaultRunCommand,
  stagedPaths: injectedStagedPaths,
  unstagedPaths: injectedUnstagedPaths,
} = {}) {
  const resolvedRoot = path.resolve(repoRoot ?? defaultRepoRoot());
  const sourceGraph = graph ?? JSON.parse(fs.readFileSync(
    path.join(resolvedRoot, "tool/harness/component_graph.json"),
    "utf8",
  ));
  let stagedPaths = injectedStagedPaths ?? readGitPaths({
    args: ["diff", "--cached", "--name-only", "--diff-filter=ACMRD", "-z", "--"],
    repoRoot: resolvedRoot,
    runCommand,
  });
  if (stagedPaths.length === 0) {
    return {formattedDartPaths: [], generated: [], checked: []};
  }

  assertNoPartiallyStagedDart({
    repoRoot: resolvedRoot,
    runCommand,
    stagedPaths,
    unstagedPaths: injectedUnstagedPaths,
  });

  let plan = planPreCommitActions({graph: sourceGraph, stagedPaths});
  const generated = [];
  if (plan.l10nInputChanged) {
    if (!plan.l10nWriteCommand || plan.l10nOutputs.length === 0) {
      throw new PreCommitGeneratedArtifactError(
        "The compile-codegen catalog is missing the Flutter localization command or outputs.",
      );
    }
    runShellCommand({
      command: plan.l10nWriteCommand,
      failureMessage: `Localization generation failed: ${plan.l10nWriteCommand}`,
      repoRoot: resolvedRoot,
      runCommand,
    });
    const outputs = plan.l10nOutputs.filter((relativePath) =>
      fileExists(path.join(resolvedRoot, relativePath)));
    runRequiredCommand({
      args: ["add", "--", ...outputs],
      command: "git",
      failureMessage: "Could not stage generated localization outputs.",
      repoRoot: resolvedRoot,
      runCommand,
    });
    generated.push("flutter.l10n");
    stagedPaths = [...new Set([...stagedPaths, ...outputs])].sort();
    plan = planPreCommitActions({graph: sourceGraph, stagedPaths});
  }

  const formattedDartPaths = plan.dartPaths.filter((relativePath) =>
    fileExists(path.join(resolvedRoot, relativePath)));
  if (formattedDartPaths.length > 0) {
    runRequiredCommand({
      args: ["format", "--", ...formattedDartPaths],
      command: "dart",
      failureMessage: "dart format failed for staged Dart files.",
      repoRoot: resolvedRoot,
      runCommand,
    });
    runRequiredCommand({
      args: ["add", "--", ...formattedDartPaths],
      command: "git",
      failureMessage: "Could not re-stage formatted Dart files.",
      repoRoot: resolvedRoot,
      runCommand,
    });
  }

  const checked = [];
  for (const generator of plan.triggeredGenerators) {
    runShellCommand({
      command: generator.checkCommand,
      failureMessage:
        `Generated artifact drift for ${generator.id}. Regenerate and stage with:\n` +
        `  ${generator.writeCommand}`,
      repoRoot: resolvedRoot,
      runCommand,
    });
    checked.push(generator.id);
  }
  return {checked, formattedDartPaths, generated};
}

function assertNoPartiallyStagedDart({
  repoRoot,
  runCommand,
  stagedPaths,
  unstagedPaths,
}) {
  const stagedDart = new Set(stagedPaths.filter((candidate) => candidate.endsWith(".dart")));
  if (stagedDart.size === 0) return;
  const unstaged = unstagedPaths ?? readGitPaths({
    args: ["diff", "--name-only", "--diff-filter=ACMR", "-z", "--"],
    repoRoot,
    runCommand,
  });
  const partial = unstaged.filter((candidate) => stagedDart.has(candidate)).sort();
  if (partial.length > 0) {
    throw new PreCommitGeneratedArtifactError(
      "Refusing to format partially staged Dart files because re-staging would " +
      `include unstaged work:\n${partial.map((candidate) => `  ${candidate}`).join("\n")}`,
    );
  }
}

function readGitPaths({args, repoRoot, runCommand}) {
  const result = runCommand({args, command: "git", cwd: repoRoot, encoding: "buffer"});
  if (result.status !== 0) {
    throw new PreCommitGeneratedArtifactError(
      result.stderr?.toString().trim() || `git ${args.join(" ")} failed.`,
    );
  }
  const output = Buffer.isBuffer(result.stdout)
    ? result.stdout
    : Buffer.from(result.stdout ?? "");
  if (output.length === 0) return [];
  if (output.at(-1) !== 0) {
    throw new PreCommitGeneratedArtifactError("Git staged-path output was not NUL terminated.");
  }
  return output.toString("utf8").split("\0").filter(Boolean).sort();
}

function runShellCommand({command, failureMessage, repoRoot, runCommand}) {
  runRequiredCommand({
    args: ["-c", command],
    command: "/bin/sh",
    failureMessage,
    repoRoot,
    runCommand,
  });
}

function runRequiredCommand({args, command, failureMessage, repoRoot, runCommand}) {
  const result = runCommand({args, command, cwd: repoRoot});
  if (result.status !== 0) throw new PreCommitGeneratedArtifactError(failureMessage);
}

function defaultRunCommand({args, command, cwd, encoding}) {
  return spawnSync(command, args, {
    cwd,
    encoding: encoding === "buffer" ? undefined : "utf8",
    shell: false,
    stdio: encoding === "buffer" ? "pipe" : "inherit",
  });
}

function defaultFileExists(candidate) {
  try {
    return fs.lstatSync(candidate).isFile();
  } catch (error) {
    if (error?.code === "ENOENT" || error?.code === "ENOTDIR") return false;
    throw error;
  }
}

function pathIsWithin(candidate, parent) {
  return candidate === parent || candidate.startsWith(`${parent}/`);
}

function defaultRepoRoot() {
  return path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../..");
}

function main() {
  try {
    const result = runPreCommitGeneratedArtifacts();
    if (result.generated.length > 0) {
      console.log(`Generated and staged: ${result.generated.join(", ")}`);
    }
    if (result.formattedDartPaths.length > 0) {
      console.log(`Formatted and re-staged ${result.formattedDartPaths.length} Dart file(s).`);
    }
    if (result.checked.length > 0) {
      console.log(`Generated artifact checks passed: ${result.checked.join(", ")}`);
    }
  } catch (error) {
    console.error(error instanceof Error ? error.message : String(error));
    process.exitCode = 1;
  }
}

if (
  process.argv[1] != null &&
  fileURLToPath(import.meta.url) === path.resolve(process.argv[1])
) {
  main();
}
