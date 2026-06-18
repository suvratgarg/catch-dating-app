#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath, pathToFileURL} from "node:url";
import {repoRoot, relativeToRepo} from "../lib/repo_paths.mjs";
import {fingerprintDecisionAnswerPacket} from
  "./lib/decision_answer_packet_fingerprint.mjs";

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const defaultSourcePath = path.join(
  scriptDir,
  "generated",
  "organizer_pending_decision_answer_packet.json"
);
const defaultOutputRoot = path.join(scriptDir, "answer_packets");

if (isMain()) {
  try {
    main();
  } catch (error) {
    console.error(error instanceof Error ? error.message : String(error));
    process.exit(64);
  }
}

export function createDecisionAnswerPacketDraft(packet, {
  date,
  reviewer,
  slug = "review",
  sourcePath = defaultSourcePath,
} = {}) {
  const errors = [];
  if (!date || !/^\d{4}-\d{2}-\d{2}$/.test(date)) {
    errors.push("date must use YYYY-MM-DD.");
  }
  if (!reviewer || typeof reviewer !== "string" || reviewer.trim().length === 0) {
    errors.push("reviewer is required.");
  }
  if (!packet || typeof packet !== "object") {
    errors.push("source packet must be an object.");
  }
  if (errors.length > 0) return {ok: false, errors};

  const draft = clone(packet);
  draft.reviewDraft = {
    createdAt: date,
    reviewer: reviewer.trim(),
    slug: slugFor(slug),
    sourcePacket: relativeToRepo(sourcePath),
    sourceFingerprint: {
      algorithm: "sha256",
      value: fingerprintDecisionAnswerPacket(packet),
    },
    instructions: [
      "Fill answerTemplate.answers[*].decision with one allowed option.",
      "Fill answerTemplate.answers[*].note with reviewer rationale.",
      "Set required acknowledgements to true only after review.",
      "For accepted policy decisions, copy every required input string into requiredInputsReviewed.",
      "Run pending_decision_answer_plan.mjs --packet <this file> --require-complete before applying.",
    ],
  };
  draft.answerTemplate = {
    ...(draft.answerTemplate ?? {}),
    reviewer: reviewer.trim(),
    decidedAt: date,
  };
  return {
    ok: true,
    errors: [],
    draft,
    summary: {
      answerSlots: Array.isArray(draft.answerSlots) ? draft.answerSlots.length : 0,
      reviewer: reviewer.trim(),
      date,
      slug: slugFor(slug),
    },
  };
}

export function outputPathForDraft({
  date,
  outputRoot = defaultOutputRoot,
  slug = "review",
}) {
  return path.join(outputRoot, `${date}-${slugFor(slug)}.json`);
}

function main(argv = process.argv.slice(2)) {
  const args = parseArgs(argv);
  if (args.help) {
    printHelp();
    return;
  }

  const sourcePath = path.resolve(args.source);
  const outputRoot = path.resolve(args.outputRoot);
  const outputPath = args.output ?
    path.resolve(args.output) :
    outputPathForDraft({
      date: args.date,
      outputRoot,
      slug: args.slug,
    });
  const packet = readJson(sourcePath);
  const draftResult = createDecisionAnswerPacketDraft(packet, {
    date: args.date,
    reviewer: args.reviewer,
    slug: args.slug,
    sourcePath,
  });
  if (!draftResult.ok) {
    for (const error of draftResult.errors) console.error(`- ${error}`);
    process.exit(64);
  }
  if (args.check) {
    console.log(
      "Organizer decision answer packet draft ready: " +
        `${draftResult.summary.answerSlots} answer slot(s), ` +
        `reviewer ${draftResult.summary.reviewer}, ` +
        `date ${draftResult.summary.date}.`
    );
    console.log(`Output: ${relativeToRepo(outputPath)}`);
    return;
  }
  if (fs.existsSync(outputPath) && !args.allowOverwrite) {
    console.error(`Answer packet already exists: ${relativeToRepo(outputPath)}`);
    console.error("Use --allow-overwrite to replace it.");
    process.exit(1);
  }
  const rendered = `${stableStringify(draftResult.draft)}\n`;
  if (args.dryRun) {
    console.log(`Would write ${relativeToRepo(outputPath)}:`);
    console.log(rendered);
    return;
  }
  fs.mkdirSync(path.dirname(outputPath), {recursive: true});
  fs.writeFileSync(outputPath, rendered);
  console.log(`Wrote ${relativeToRepo(outputPath)}.`);
  console.log(
    "Next: node tool/organizer_intake/pending_decision_answer_plan.mjs " +
      `--packet ${relativeToRepo(outputPath)} --require-complete`
  );
}

function parseArgs(argv) {
  const args = {
    allowOverwrite: false,
    check: false,
    date: null,
    dryRun: false,
    help: false,
    output: null,
    outputRoot: defaultOutputRoot,
    reviewer: null,
    slug: "review",
    source: defaultSourcePath,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--allow-overwrite") args.allowOverwrite = true;
    else if (arg === "--check") args.check = true;
    else if (arg === "--date") args.date = requiredValue(argv, ++index, arg);
    else if (arg === "--dry-run") args.dryRun = true;
    else if (arg === "--output") args.output = requiredValue(argv, ++index, arg);
    else if (arg === "--output-root") args.outputRoot = requiredValue(argv, ++index, arg);
    else if (arg === "--reviewer") args.reviewer = requiredValue(argv, ++index, arg);
    else if (arg === "--slug") args.slug = requiredValue(argv, ++index, arg);
    else if (arg === "--source") args.source = requiredValue(argv, ++index, arg);
    else if (arg === "--help" || arg === "-h") args.help = true;
    else throw new Error(`Unknown argument: ${arg}`);
  }
  if (!args.help) {
    if (!args.date) throw new Error("--date is required.");
    if (!args.reviewer) throw new Error("--reviewer is required.");
  }
  return args;
}

function readJson(file) {
  if (!fs.existsSync(file)) {
    throw new Error(`Missing source answer packet: ${relativeToRepo(file)}`);
  }
  return JSON.parse(fs.readFileSync(file, "utf8"));
}

function requiredValue(argv, index, flag) {
  const value = argv[index];
  if (!value || value.startsWith("--")) throw new Error(`${flag} requires a value.`);
  return value;
}

function clone(value) {
  return JSON.parse(JSON.stringify(value));
}

function slugFor(value) {
  const slug = String(value ?? "")
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
  return slug || "review";
}

function stableStringify(value) {
  return JSON.stringify(sortValue(value), null, 2);
}

function sortValue(value) {
  if (Array.isArray(value)) return value.map(sortValue);
  if (!value || typeof value !== "object") return value;
  return Object.fromEntries(
    Object.entries(value)
      .sort(([left], [right]) => left.localeCompare(right))
      .map(([key, nested]) => [key, sortValue(nested)])
  );
}

function printHelp() {
  console.log(`Usage: node tool/organizer_intake/create_decision_answer_packet.mjs [options]

Creates a repo-backed reviewed-answer packet draft from the generated pending
decision answer template. The draft sets reviewer/date metadata but leaves every
decision null for manual review.

Options:
  --date YYYY-MM-DD        Review date to write into answerTemplate.decidedAt.
  --reviewer <name>        Reviewer name to write into answerTemplate.reviewer.
  --slug <slug>            Output slug. Default: review.
  --source <path>          Source generated answer packet.
  --output-root <path>     Output directory. Default: ${relativeToRepo(defaultOutputRoot)}
  --output <path>          Exact output path.
  --dry-run                Print the packet without writing it.
  --check                  Validate and print the output path without writing.
  --allow-overwrite        Replace an existing output file.
  -h, --help               Show this help.
`);
}

function isMain() {
  return process.argv[1] &&
    import.meta.url === pathToFileURL(process.argv[1]).href;
}
