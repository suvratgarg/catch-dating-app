#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(scriptDir, "..", "..");
const defaultClustersPath = path.join(
  scriptDir,
  "generated",
  "source_mention_resolution_clusters.json"
);
const defaultCandidatesPath = path.join(
  scriptDir,
  "generated",
  "source_mention_resolution_candidates.json"
);
const defaultOutputPath = path.join(
  scriptDir,
  "generated",
  "source_mention_llm_prompt_queue.json"
);

if (isMain()) {
  main();
}

function main() {
  const args = parseArgs(process.argv.slice(2));

  if (args.help) {
    printHelp();
    process.exit(0);
  }

  try {
    if (args.callModel) {
      throw new Error(
        "LLM calls are intentionally disabled in this scaffold. " +
          "Generate prompt payloads, review cost/caching policy, then wire a backend runner explicitly."
      );
    }
    const clusters = readJson(path.resolve(repoRoot, args.clusters ?? defaultClustersPath));
    const candidates = readJson(path.resolve(repoRoot, args.candidates ?? defaultCandidatesPath));
    const promptQueue = buildPromptQueue({clusters, candidates});
    const rendered = `${stableStringify(promptQueue)}\n`;
    if (args.check) {
      const outputPath = path.resolve(repoRoot, args.output ?? defaultOutputPath);
      if (!fs.existsSync(outputPath)) {
        throw new Error(`Missing LLM prompt queue: ${relative(outputPath)}`);
      }
      const current = fs.readFileSync(outputPath, "utf8");
      if (current !== rendered) {
        throw new Error(`LLM prompt queue is stale: ${relative(outputPath)}`);
      }
      console.log(`LLM prompt queue is current: ${relative(outputPath)}`);
      process.exit(0);
    }
    if (args.write) {
      const outputPath = path.resolve(repoRoot, args.output ?? defaultOutputPath);
      fs.mkdirSync(path.dirname(outputPath), {recursive: true});
      fs.writeFileSync(outputPath, rendered);
      console.log(`Wrote ${relative(outputPath)}.`);
      process.exit(0);
    }
    console.log(rendered.trimEnd());
    if (!args.dryRun) {
      console.error("\nDry run only. Re-run with --write to persist prompt payloads.");
    }
  } catch (error) {
    console.error(error instanceof Error ? error.message : String(error));
    process.exit(1);
  }
}

export function buildPromptQueue({clusters, candidates}) {
  const candidateById = new Map(
    (candidates.candidates ?? []).map((candidate) => [candidate.candidateId, candidate])
  );
  const requests = (clusters.llmReviewQueue ?? []).map((request) => {
    const cluster = (clusters.clusters ?? [])
      .find((entry) => entry.clusterId === request.clusterId);
    const clusterCandidates = (cluster?.candidateIds ?? [])
      .map((candidateId) => candidateById.get(candidateId))
      .filter(Boolean);
    return {
      requestId: `llm-adjudication:${request.clusterId}`,
      clusterId: request.clusterId,
      status: "prompt_ready_model_call_disabled",
      promptVersion: request.promptVersion,
      modelEnv: "LLM_DEDUPE_MODEL",
      apiKeyEnv: "OPENAI_API_KEY",
      inputHash: request.inputHash,
      system:
        "You review already-extracted source mentions. Deterministic rules are primary. " +
        "Use the provided scorecard and evidence only. Return whether the cluster appears " +
        "to describe one event, multiple events, or needs human review. Do not create new facts.",
      payload: {
        task: "adjudicate_event_cluster",
        promptVersion: request.promptVersion,
        clusterId: request.clusterId,
        deterministicScore: {
          score: request.deterministicScore,
          status: request.status,
          reason: request.reason,
          matchingSignals: cluster?.matchingSignals ?? [],
          conflictingSignals: cluster?.conflictingSignals ?? [],
          hardSignals: cluster?.hardSignals ?? [],
        },
        mentions: clusterCandidates.map((candidate) => ({
          candidateId: candidate.candidateId,
          mentionId: candidate.mentionId,
          entityType: candidate.entityType,
          displayName: candidate.displayName,
          citySlug: candidate.citySlug,
          date: candidate.date,
          categoryId: candidate.categoryId,
          sourceUrl: candidate.source.sourceUrl,
          canonicalUrl: candidate.source.canonicalUrl,
          sourceType: candidate.source.sourceType,
          citations: candidate.citations,
        })),
      },
      expectedJsonShape: {
        schemaVersion: 1,
        clusterId: request.clusterId,
        decision: "same_event | separate_events | needs_human_review",
        confidence: "high | medium | low",
        recommendedCanonicalMentionId: "string or null",
        reasons: ["string"],
        conflicts: [{field: "string", values: ["string"]}],
        humanReviewChecklist: ["string"],
      },
    };
  });
  return {
    schemaVersion: 1,
    generatedFrom: {
      clusters: "tool/organizer_intake/generated/source_mention_resolution_clusters.json",
      candidates: "tool/organizer_intake/generated/source_mention_resolution_candidates.json",
    },
    policy: {
      status: "model_calls_disabled",
      cacheRoot: "tool/organizer_intake/llm_cache",
      note:
        "This artifact is prompt preparation only. A backend runner must add cache reads/writes and explicit model-call approval.",
    },
    summary: {
      requests: requests.length,
      promptReady: requests.length,
    },
    requests,
  };
}

function parseArgs(argv) {
  const args = {
    callModel: false,
    candidates: null,
    check: false,
    clusters: null,
    dryRun: false,
    help: false,
    output: null,
    write: false,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--call-model") args.callModel = true;
    else if (arg === "--check") args.check = true;
    else if (arg === "--dry-run") args.dryRun = true;
    else if (arg === "--help" || arg === "-h") args.help = true;
    else if (arg === "--write") args.write = true;
    else if (["--candidates", "--clusters", "--output"].includes(arg)) {
      const value = argv[index + 1];
      if (!value || value.startsWith("--")) throw new Error(`${arg} requires a value.`);
      args[arg.slice(2)] = value;
      index += 1;
    } else {
      throw new Error(`Unknown argument: ${arg}`);
    }
  }
  return args;
}

function readJson(file) {
  return JSON.parse(fs.readFileSync(file, "utf8"));
}

function relative(file) {
  return path.relative(repoRoot, file);
}

function stableStringify(value) {
  return JSON.stringify(sortValue(value), null, 2);
}

function sortValue(value) {
  if (Array.isArray(value)) return value.map(sortValue);
  if (value && typeof value === "object") {
    return Object.fromEntries(
      Object.entries(value)
        .sort(([a], [b]) => a.localeCompare(b))
        .map(([key, nested]) => [key, sortValue(nested)])
    );
  }
  return value;
}

function printHelp() {
  console.log(`Usage:
  node tool/organizer_intake/llm_source_resolution.mjs [flags]

Flags:
  --clusters <file>    Defaults to generated source-mention clusters.
  --candidates <file>  Defaults to generated source-mention candidates.
  --output <file>      Defaults to generated/source_mention_llm_prompt_queue.json.
  --write              Persist prompt payloads.
  --check              Compare prompt payload output with --output.
  --dry-run            Print prompt payloads without writing.
  --call-model         Refused by design; model calls need a separate approved runner.
`);
}

function isMain() {
  return process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);
}
