#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath, pathToFileURL} from "node:url";

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const defaultRequestPath = path.join(
  scriptDir,
  "generated",
  "organizer_pending_input_request.json"
);

const priorityRank = {
  p0: 0,
  p1: 1,
  p2: 2,
  p3: 3,
};

if (isMain()) {
  main();
}

export function checkOrganizerPendingInputRequest(request) {
  const errors = [];
  const warnings = [];
  if (!request || typeof request !== "object") {
    return {
      ok: false,
      errors: ["Pending input request payload must be an object."],
      warnings,
      summary: emptySummary(),
    };
  }

  const requests = Array.isArray(request.requests) ? request.requests : [];
  const followUps = Array.isArray(request.followUps) ? request.followUps : [];
  const summary = request.summary ?? {};
  if (request.schemaVersion !== 1) {
    errors.push(`Expected schemaVersion 1, got ${request.schemaVersion}.`);
  }
  if (!Array.isArray(requests)) {
    errors.push("requests must be an array.");
  }
  if (!Array.isArray(followUps)) {
    errors.push("followUps must be an array.");
  }
  if (summary.requests !== requests.length) {
    errors.push(
      `summary.requests ${summary.requests} does not match ` +
        `requests length ${requests.length}.`
    );
  }
  const publicationRequests = requests.filter((item) =>
    item.requestType === "admin_publication_decision");
  if (summary.adminPublicationRequests !== publicationRequests.length) {
    errors.push(
      `summary.adminPublicationRequests ${summary.adminPublicationRequests} ` +
        `does not match ${publicationRequests.length}.`
    );
  }
  const policyRequests = requests.filter((item) =>
    item.requestType === "policy_decision");
  if (summary.policyDecisionRequests !== policyRequests.length) {
    errors.push(
      `summary.policyDecisionRequests ${summary.policyDecisionRequests} ` +
        `does not match ${policyRequests.length}.`
    );
  }
  if (summary.workflowFollowUps !== followUps.length) {
    errors.push(
      `summary.workflowFollowUps ${summary.workflowFollowUps} ` +
        `does not match ${followUps.length}.`
    );
  }

  compareCountMap({
    actual: countBy(requests, "requestType"),
    errors,
    expected: summary.requestsByType ?? {},
    label: "requestsByType",
  });
  compareCountMap({
    actual: countBy(requests, "priority"),
    errors,
    expected: summary.requestsByPriority ?? {},
    label: "requestsByPriority",
  });
  compareCountMap({
    actual: countBy(requests, "owner"),
    errors,
    expected: summary.requestsByOwner ?? {},
    label: "requestsByOwner",
  });
  compareCountMap({
    actual: countBy(followUps, "status"),
    errors,
    expected: summary.followUpsByStatus ?? {},
    label: "followUpsByStatus",
  });

  const requiredQuestions = requests.reduce((total, item) =>
    total + (item.requiredInputs ?? []).filter((input) =>
      input.requiredForAcceptance).length, 0);
  if (summary.requiredPolicyQuestions !== requiredQuestions) {
    errors.push(
      `summary.requiredPolicyQuestions ${summary.requiredPolicyQuestions} ` +
        `does not match ${requiredQuestions}.`
    );
  }
  const manualAcknowledgements = publicationRequests.filter((item) =>
    item.requiredAcknowledgements?.manualReportsReviewed).length;
  if (summary.manualPublicationAcknowledgements !== manualAcknowledgements) {
    errors.push(
      `summary.manualPublicationAcknowledgements ` +
        `${summary.manualPublicationAcknowledgements} does not match ` +
        `${manualAcknowledgements}.`
    );
  }

  const highestPriority = highestPriorityFor([
    ...requests.map((item) => item.priority),
    ...followUps.map((item) => item.priority),
  ]);
  if ((summary.highestPriority ?? null) !== highestPriority) {
    errors.push(
      `summary.highestPriority ${summary.highestPriority ?? "null"} ` +
        `does not match ${highestPriority ?? "null"}.`
    );
  }

  for (const item of requests) validateRequest(item, errors);
  for (const item of followUps) validateFollowUp(item, errors);
  const callableSubmissions = requests.filter((item) =>
    item.callableSubmission).length;
  if (requests.length > 0) {
    warnings.push(`${requests.length} admin/product input request(s) pending.`);
  }

  return {
    ok: errors.length === 0,
    errors,
    warnings,
    summary: {
      requests: requests.length,
      adminPublicationRequests:
        summary.adminPublicationRequests ?? 0,
      policyDecisionRequests:
        summary.policyDecisionRequests ?? 0,
      requiredPolicyQuestions: requiredQuestions,
      manualPublicationAcknowledgements:
        summary.manualPublicationAcknowledgements ?? 0,
      callableSubmissions,
      workflowFollowUps: followUps.length,
      highestPriority,
    },
  };
}

export function renderPendingInputRequestMarkdown(request) {
  const publication = (request.requests ?? [])
    .filter((item) => item.requestType === "admin_publication_decision");
  const policy = (request.requests ?? [])
    .filter((item) => item.requestType === "policy_decision");
  const lines = [
    "# Organizer Pending Inputs",
    "",
    `Status: ${request.summary?.requests ?? 0} input request(s), ` +
      `${request.summary?.requiredPolicyQuestions ?? 0} policy question(s), ` +
      `highest priority ${request.summary?.highestPriority ?? "none"}.`,
    "",
    "## Admin Publication Decisions",
    "",
  ];

  if (publication.length === 0) {
    lines.push("No publication decisions are pending.", "");
  } else {
    for (const item of publication) {
      lines.push(
        `### ${item.subjectName}`,
        "",
        item.prompt,
        "",
        `Options: ${(item.decisionOptions ?? []).join(", ")}`,
        `Safe default: ${item.safeDefaultAction}`,
        `Impact: ${impactSummary(item.impact)}`,
      );
      if (item.requiredAcknowledgements?.manualReportsReviewed) {
        lines.push("Required acknowledgement: manual reports reviewed.");
      }
      if (item.currentState?.riskFlags?.length > 0) {
        lines.push(`Risk flags: ${item.currentState.riskFlags.join(", ")}`);
      }
      appendCallableSubmissionLines(lines, item);
      if (item.commands?.[0]) lines.push(`Command: \`${item.commands[0]}\``);
      lines.push("");
    }
  }

  lines.push("## Policy Decisions", "");
  if (policy.length === 0) {
    lines.push("No policy decisions are pending.", "");
  } else {
    for (const item of policy) {
      lines.push(
        `### ${item.subjectId}`,
        "",
        item.prompt,
        "",
        `Owner: ${item.owner}`,
        `Options: ${(item.decisionOptions ?? []).join(", ")}`,
        `Safe default: ${item.safeDefaultAction}`,
        `Implementation gate: ${item.currentState?.implementationGate ?? "not specified"}`,
      );
      for (const input of item.requiredInputs ?? []) {
        lines.push(`- ${input.prompt} Default: ${input.recommendedSafeDefault}.`);
      }
      appendCallableSubmissionLines(lines, item);
      if (item.commands?.[0]) lines.push(`Command: \`${item.commands[0]}\``);
      lines.push("");
    }
  }

  lines.push("## Workflow Follow-Ups", "");
  for (const item of request.followUps ?? []) {
    lines.push(
      `- ${item.priority} ${item.workstreamId}: ${item.status}` +
        (item.nextActions?.[0] ? `; next: ${item.nextActions[0]}` : "")
    );
  }
  if ((request.followUps ?? []).length === 0) {
    lines.push("No workflow follow-ups are pending.");
  }
  lines.push("");
  return `${lines.join("\n")}\n`;
}

function validateRequest(item, errors) {
  for (const field of [
    "requestId",
    "requestType",
    "priority",
    "owner",
    "subjectId",
    "prompt",
  ]) {
    if (!item[field]) errors.push(`${item.requestId ?? "request"} missing ${field}.`);
  }
  if (!Array.isArray(item.decisionOptions)) {
    errors.push(`${item.requestId}: decisionOptions must be an array.`);
  }
  if (!Array.isArray(item.commands)) {
    errors.push(`${item.requestId}: commands must be an array.`);
  }
  if (!priorityRank.hasOwnProperty(item.priority)) {
    errors.push(`${item.requestId}: unknown priority ${item.priority}.`);
  }
  validateCallableSubmission(item, errors);
}

function validateFollowUp(item, errors) {
  for (const field of ["followUpId", "workstreamId", "status", "priority"]) {
    if (!item[field]) errors.push(`${item.followUpId ?? "follow-up"} missing ${field}.`);
  }
  if (!Array.isArray(item.commands)) {
    errors.push(`${item.followUpId}: commands must be an array.`);
  }
}

function validateCallableSubmission(item, errors) {
  const expected = expectedCallableForRequest(item);
  if (!expected) return;
  const prefix = `${item.requestId}: callableSubmission`;
  const submission = item.callableSubmission;
  if (!submission || typeof submission !== "object") {
    errors.push(`${prefix} is required.`);
    return;
  }
  for (const [field, value] of Object.entries(expected)) {
    if (submission[field] !== value) {
      errors.push(`${prefix}.${field} must be ${value}.`);
    }
  }
  if (!submission.payloadsByDecision ||
    typeof submission.payloadsByDecision !== "object") {
    errors.push(`${prefix}.payloadsByDecision is required.`);
    return;
  }
  for (const decision of item.decisionOptions ?? []) {
    const payload = submission.payloadsByDecision[decision];
    if (!payload || typeof payload !== "object") {
      errors.push(`${prefix}.payloadsByDecision.${decision} is required.`);
      continue;
    }
    if (item.requestType === "admin_publication_decision") {
      validatePublicationPayload({decision, errors, item, payload, prefix});
    } else if (item.requestType === "policy_decision") {
      validatePolicyPayload({decision, errors, item, payload, prefix});
    }
  }
  const expectedSafeDecision = (item.decisionOptions ?? [])
    .includes(item.safeDefaultAction) ?
    item.safeDefaultAction :
    "hold";
  if (submission.safeDefaultPayload?.decision !== expectedSafeDecision) {
    errors.push(
      `${prefix}.safeDefaultPayload must use ${expectedSafeDecision}.`
    );
  }
}

function expectedCallableForRequest(item) {
  if (item.requestType === "admin_publication_decision") {
    return {
      callableName: "adminDecideOrganizerIntake",
      adminApiWrapper: "decideOrganizerIntake",
      payloadType: "AdminDecideOrganizerIntakePayload",
      firestoreCollection: "organizerIntakeReviewDecisions",
    };
  }
  if (item.requestType === "policy_decision") {
    return {
      callableName: "adminDecideOrganizerPolicyGap",
      adminApiWrapper: "decideOrganizerPolicyGap",
      payloadType: "AdminDecideOrganizerPolicyGapPayload",
      firestoreCollection: "organizerPolicyGapReviewDecisions",
    };
  }
  return null;
}

function validatePublicationPayload({decision, errors, item, payload, prefix}) {
  if (payload.entityId !== item.subjectId) {
    errors.push(`${prefix}.${decision}.entityId must be ${item.subjectId}.`);
  }
  if (payload.decision !== decision) {
    errors.push(`${prefix}.${decision}.decision must be ${decision}.`);
  }
  if (payload.appVisibility !== "hidden") {
    errors.push(`${prefix}.${decision}.appVisibility must be hidden.`);
  }
  validateRequiredNote({decision, errors, payload, prefix});
  const checklist = payload.checklist;
  for (const field of [
    "identityReviewed",
    "surfaceInventoryReviewed",
    "ownerSafeCopyReviewed",
    "marketScopeReviewed",
    "mediaRightsReviewed",
    "crawlDisabledReviewed",
  ]) {
    if (typeof checklist?.[field] !== "boolean") {
      errors.push(`${prefix}.${decision}.checklist.${field} is required.`);
    }
  }
  if (decision === "approve_public" &&
    item.requiredAcknowledgements?.manualReportsReviewed === true &&
    checklist?.manualReportsReviewed !== true) {
    errors.push(
      `${prefix}.approve_public.checklist.manualReportsReviewed is required.`
    );
  }
}

function validatePolicyPayload({decision, errors, item, payload, prefix}) {
  if (payload.gapId !== item.subjectId) {
    errors.push(`${prefix}.${decision}.gapId must be ${item.subjectId}.`);
  }
  if (payload.decision !== decision) {
    errors.push(`${prefix}.${decision}.decision must be ${decision}.`);
  }
  if (!Array.isArray(payload.requiredInputsReviewed)) {
    errors.push(
      `${prefix}.${decision}.requiredInputsReviewed must be an array.`
    );
  }
  validateRequiredNote({decision, errors, payload, prefix});
  const checklist = payload.checklist;
  for (const field of [
    "requiredInputsReviewed",
    "costAndSafetyReviewed",
    "implementationOwnerReviewed",
    "behaviorStillDisabledAcknowledged",
  ]) {
    if (typeof checklist?.[field] !== "boolean") {
      errors.push(`${prefix}.${decision}.checklist.${field} is required.`);
    }
  }
  if (decision !== "accept") return;
  const expectedInputs = (item.requiredInputs ?? [])
    .filter((input) => input.requiredForAcceptance === true)
    .map((input) => input.input)
    .filter(Boolean)
    .sort();
  const actualInputs = [...(payload.requiredInputsReviewed ?? [])].sort();
  if (JSON.stringify(actualInputs) !== JSON.stringify(expectedInputs)) {
    errors.push(
      `${prefix}.accept.requiredInputsReviewed must match required inputs.`
    );
  }
}

function validateRequiredNote({decision, errors, payload, prefix}) {
  if (typeof payload.note !== "string" || payload.note.trim().length === 0) {
    errors.push(`${prefix}.${decision}.note is required.`);
  }
}

function appendCallableSubmissionLines(lines, item) {
  const submission = item.callableSubmission;
  if (!submission) return;
  const decisions = Object.keys(submission.payloadsByDecision ?? {});
  lines.push(
    `Callable: \`${submission.callableName}\` via ` +
      `\`${submission.adminApiWrapper}\``,
    `Payload options: ${decisions.join(", ") || "none"}`,
  );
  if (submission.safeDefaultPayload) {
    lines.push(
      `Safe payload: \`${JSON.stringify(submission.safeDefaultPayload)}\``
    );
  }
}

function impactSummary(impact) {
  if (!impact) return "none";
  const parts = [];
  if (impact.wouldPublish) parts.push("publish public page");
  if (impact.wouldIndex) parts.push("indexable");
  if (impact.wouldCreateClaimTarget) parts.push(`claim target ${impact.claimTargetPath}`);
  if (impact.appVisibility) parts.push(`app visibility ${impact.appVisibility}`);
  return parts.join(", ") || "none";
}

function compareCountMap({actual, errors, expected, label}) {
  const keys = new Set([...Object.keys(actual), ...Object.keys(expected)]);
  for (const key of [...keys].sort()) {
    if ((actual[key] ?? 0) !== (expected[key] ?? 0)) {
      errors.push(
        `${label}.${key} ${expected[key] ?? 0} does not match ` +
          `${actual[key] ?? 0}.`
      );
    }
  }
}

function countBy(items, field) {
  return Object.fromEntries([...items.reduce((counts, item) => {
    const key = item[field] ?? "unknown";
    counts.set(key, (counts.get(key) ?? 0) + 1);
    return counts;
  }, new Map()).entries()].sort(([left], [right]) =>
    String(left).localeCompare(String(right))));
}

function highestPriorityFor(priorities) {
  return priorities
    .filter(Boolean)
    .sort((left, right) =>
      (priorityRank[left] ?? 99) - (priorityRank[right] ?? 99))[0] ?? null;
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  if (args.help) {
    printHelp();
    process.exit(0);
  }

  const requestPath = path.resolve(args.request ?? defaultRequestPath);
  const request = readJson(requestPath);
  const result = checkOrganizerPendingInputRequest(request);
  if (args.check && !result.ok) {
    printErrors(result);
    process.exit(1);
  }

  if (args.format === "json") {
    console.log(JSON.stringify(args.check ? result : request, null, 2));
  } else if (args.format === "markdown") {
    console.log(renderPendingInputRequestMarkdown(request));
  } else {
    printText({requestPath, result});
  }
  if (!result.ok) process.exit(1);
}

function printText({requestPath, result}) {
  console.log(
    `Organizer pending inputs: ${result.summary.requests} request(s), ` +
      `${result.summary.requiredPolicyQuestions} policy question(s), ` +
      `${result.summary.callableSubmissions} callable payload(s), ` +
      `highest ${result.summary.highestPriority ?? "none"}.`
  );
  console.log(`Source: ${relative(requestPath)}`);
  if (result.warnings.length > 0) {
    for (const warning of result.warnings) console.log(`- ${warning}`);
  }
}

function printErrors(result) {
  console.error("Organizer pending input request check failed:");
  for (const error of result.errors) console.error(`- ${error}`);
}

function readJson(filePath) {
  try {
    return JSON.parse(fs.readFileSync(filePath, "utf8"));
  } catch (error) {
    console.error(`Unable to read ${relative(filePath)}: ${error.message}`);
    process.exit(1);
  }
}

function parseArgs(argv) {
  const args = {
    check: false,
    format: "text",
    help: false,
    request: null,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--check") {
      args.check = true;
    } else if (arg === "--format") {
      args.format = requiredValue(argv, index += 1, arg);
    } else if (arg === "--request") {
      args.request = requiredValue(argv, index += 1, arg);
    } else if (arg === "--help" || arg === "-h") {
      args.help = true;
    } else {
      console.error(`Unknown argument: ${arg}`);
      printHelp();
      process.exit(1);
    }
  }
  if (!["json", "markdown", "text"].includes(args.format)) {
    console.error("--format must be json, markdown, or text.");
    process.exit(1);
  }
  return args;
}

function requiredValue(argv, index, flag) {
  const value = argv[index];
  if (!value) {
    console.error(`${flag} requires a value.`);
    process.exit(1);
  }
  return value;
}

function emptySummary() {
  return {
    adminPublicationRequests: 0,
    highestPriority: null,
    manualPublicationAcknowledgements: 0,
    policyDecisionRequests: 0,
    requiredPolicyQuestions: 0,
    requests: 0,
    callableSubmissions: 0,
    workflowFollowUps: 0,
  };
}

function printHelp() {
  console.log(`Usage: node tool/organizer_intake/pending_input_request.mjs [options]

Validates or renders the generated organizer pending-input request.

Options:
  --check                  Validate the generated request.
  --request PATH           Read a specific request JSON file.
  --format text|json|markdown
                           Output format. Defaults to text.
  --help                   Show this message.
`);
}

function relative(filePath) {
  return path.relative(process.cwd(), filePath) || ".";
}

function isMain() {
  return import.meta.url === pathToFileURL(process.argv[1]).href;
}
