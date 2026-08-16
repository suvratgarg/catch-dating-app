/**
 * Extract runnable shell steps from a GitHub Actions workflow.
 *
 * This exists so that local verification is *derived from* the CI definition
 * rather than restated alongside it. Every hand-maintained list of "the gates
 * to run before pushing" in this repository has drifted from CI at least once;
 * a list that is generated from `.github/workflows/*.yml` cannot.
 *
 * The parser is deliberately narrow: it understands the subset of workflow
 * syntax this repository actually uses (steps at six-space indentation, `run:`
 * as a plain scalar or a `|` block) and refuses to guess at anything else. A
 * step it cannot interpret is reported as skipped with a reason, never silently
 * dropped — a verifier that quietly omits gates is worse than no verifier.
 */

const STEP_INDENT = "      - ";
const KEY_INDENT = "        ";

/** Runtime-coupled references that cannot be evaluated outside Actions. */
const GITHUB_COUPLED = /\$\{\{|\$GITHUB_|GITHUB_OUTPUT|GITHUB_ENV|GITHUB_STEP_SUMMARY/;

const stripComment = (line) => {
  // Only strip comments that begin a token; `run: echo "a # b"` must survive.
  const match = /^(\s*)#/.exec(line);
  return match ? "" : line;
};

const dedent = (lines) => {
  const present = lines.filter((line) => line.trim().length > 0);
  if (present.length === 0) return "";
  const indent = Math.min(...present.map((line) => /^\s*/.exec(line)[0].length));
  return present.map((line) => line.slice(indent)).join("\n");
};

/**
 * @param {string} source raw workflow YAML
 * @returns {{name: string, run: string|null, uses: string|null, if: string|null,
 *            runnable: boolean, skipReason: string|null}[]}
 */
export function extractSteps(source) {
  const lines = source.split("\n").map(stripComment);
  const steps = [];
  let current = null;

  const flush = () => {
    if (!current) return;
    if (current.blockKey === "run") current.run = dedent(current.blockLines);
    delete current.blockKey;
    delete current.blockLines;
    steps.push(current);
    current = null;
  };

  for (let index = 0; index < lines.length; index += 1) {
    const line = lines[index];

    if (line.startsWith(STEP_INDENT)) {
      flush();
      current = {
        name: null, run: null, uses: null, if: null, raw: `${line}\n`,
        blockKey: null, blockLines: [],
      };
      // The first key of a step sits on the dash line itself.
      const inline = line.slice(STEP_INDENT.length);
      applyKey(current, inline);
      continue;
    }

    if (!current) continue;
    current.raw += `${line}\n`;

    if (line.startsWith(KEY_INDENT) && !line.startsWith(`${KEY_INDENT} `)) {
      // A sibling key ends any block scalar in progress.
      if (current.blockKey === "run") {
        current.run = dedent(current.blockLines);
        current.blockKey = null;
        current.blockLines = [];
      }
      applyKey(current, line.slice(KEY_INDENT.length));
      continue;
    }

    if (current.blockKey === "run") {
      current.blockLines.push(line);
      continue;
    }

    // Anything shallower than a step key closes the step.
    if (line.trim().length > 0 && !line.startsWith(KEY_INDENT)) flush();
  }
  flush();

  return steps.map(classify).filter((step) => step.name || step.run);
}

function applyKey(step, text) {
  const match = /^([a-zA-Z_-]+):\s?(.*)$/.exec(text);
  if (!match) return;
  const [, key, rawValue] = match;
  const value = rawValue.trim();

  if (key === "run") {
    if (value === "|" || value === "|-" || value === ">" || value === ">-") {
      step.blockKey = "run";
      step.blockLines = [];
    } else {
      step.run = value;
    }
    return;
  }
  if (key === "name") step.name = value.replace(/^["']|["']$/g, "");
  if (key === "uses") step.uses = value;
  if (key === "if") step.if = value;
}

function classify(step) {
  let skipReason = null;
  if (!step.run) {
    skipReason = step.uses
      ? `composite action (${step.uses})`
      : "no run block";
  } else if (GITHUB_COUPLED.test(step.raw ?? step.run)) {
    // Test the whole step definition: `env:` blocks routinely inject
    // `${{ needs.* }}` values that the `run:` body then reads as plain shell
    // variables, so inspecting the body alone reports CI-only aggregation
    // steps as locally runnable.
    skipReason = "references GitHub Actions runtime context";
  }
  return {
    name: step.name ?? "(unnamed)",
    run: step.run,
    raw: undefined,
    uses: step.uses,
    if: step.if,
    runnable: skipReason === null,
    skipReason,
  };
}

/**
 * Derive the ciTarget → workflow mapping from the orchestrator workflow.
 *
 * `ci.yml` is where the mapping actually lives: each downstream job is gated on
 * `needs.plan.outputs.<target>` and delegates via `uses: ./.github/workflows/X`.
 * Reading it means the mapping cannot drift from CI — adding a target and its
 * job is enough, with nothing here to update in step.
 *
 * A job that runs its gates inline (`steps:` rather than `uses:`) maps the
 * target to the orchestrator itself, so those steps are still collected.
 *
 * @param {string} orchestrator raw contents of .github/workflows/ci.yml
 * @returns {Map<string, string[]>} target → workflow filenames
 */
export function deriveTargetWorkflows(orchestrator) {
  const lines = orchestrator.split("\n");
  const mapping = new Map();

  let inJobs = false;
  let block = null;
  const flush = () => {
    if (!block) return;
    const targets = [...block.text.matchAll(/outputs\.([a-z0-9_]+)/g)].map((m) => m[1]);
    const uses = /uses:\s*\.\/\.github\/workflows\/([\w.-]+\.yml)/.exec(block.text);
    const workflow = uses ? uses[1] : (/\n\s+steps:/.test(block.text) ? "ci.yml" : null);
    if (workflow) {
      for (const target of targets) {
        const list = mapping.get(target) ?? [];
        if (!list.includes(workflow)) list.push(workflow);
        mapping.set(target, list);
      }
    }
    block = null;
  };

  for (const line of lines) {
    if (/^jobs:/.test(line)) { inJobs = true; continue; }
    if (!inJobs) continue;
    if (/^  [\w-]+:/.test(line)) { flush(); block = {text: ""}; }
    if (block) block.text += `${line}\n`;
  }
  flush();
  return mapping;
}

/**
 * Resolve a harness ciTarget to its workflow file(s).
 *
 * Callers must treat an unresolved target as a failure rather than as "nothing
 * to run" — an unmapped target means the harness graph and CI have diverged,
 * which is exactly the drift this module exists to catch.
 */
export function workflowForTarget(target, availableFiles, derived) {
  const fromCi = derived?.get(target)?.filter((f) => availableFiles.includes(f)) ?? [];
  if (fromCi.length > 0) return fromCi;
  const conventional = [
    `${target.replace(/_/g, "-")}-ci.yml`,
    `${target.replace(/_/g, "-")}.yml`,
  ].find((file) => availableFiles.includes(file));
  return conventional ? [conventional] : [];
}
