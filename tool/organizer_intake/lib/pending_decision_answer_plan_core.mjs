export function buildPendingDecisionAnswerPlan(packet, {
  requireComplete = false,
} = {}) {
  const errors = [];
  const warnings = [];
  if (!packet || typeof packet !== "object") {
    return invalidPlan(["Decision answer packet must be an object."]);
  }

  const slots = Array.isArray(packet.answerSlots) ? packet.answerSlots : [];
  const answers = Array.isArray(packet.answerTemplate?.answers) ?
    packet.answerTemplate.answers :
    [];
  const answerById = new Map(answers.map((answer) => [answer.answerId, answer]));
  const reviewer = packet.answerTemplate?.reviewer ?? "";
  const decidedAt = packet.answerTemplate?.decidedAt ?? "";
  const plannedActions = [];
  const pendingAnswers = [];

  for (const slot of slots) {
    const answer = answerById.get(slot.answerId);
    if (!answer) {
      errors.push(`${slot.answerId}: missing answer template entry.`);
      continue;
    }
    if (answer.decision === null || answer.decision === undefined || answer.decision === "") {
      pendingAnswers.push(slot.answerId);
      continue;
    }
    validateAnsweredSlot({
      answer,
      decidedAt,
      errors,
      reviewer,
      slot,
    });
    plannedActions.push(actionForAnsweredSlot({answer, decidedAt, reviewer, slot}));
  }

  if (plannedActions.length > 0) {
    if (!reviewer.trim()) errors.push("answerTemplate.reviewer is required when answers are filled.");
    if (!/^\d{4}-\d{2}-\d{2}$/.test(decidedAt)) {
      errors.push("answerTemplate.decidedAt must use YYYY-MM-DD when answers are filled.");
    }
  }
  if (requireComplete && pendingAnswers.length > 0) {
    errors.push(`${pendingAnswers.length} answer(s) are still pending.`);
  }
  if (pendingAnswers.length > 0) {
    warnings.push(`${pendingAnswers.length} answer(s) are pending.`);
  }

  return {
    ok: errors.length === 0,
    errors,
    warnings,
    summary: {
      status: errors.length > 0 ?
        "invalid" :
        pendingAnswers.length > 0 ?
          "awaiting_answers" :
          "ready_to_draft_decisions",
      answerSlots: slots.length,
      plannedActions: plannedActions.length,
      pendingAnswers: pendingAnswers.length,
      adminPublicationActions: plannedActions.filter((action) =>
        action.requestType === "admin_publication_decision").length,
      policyDecisionActions: plannedActions.filter((action) =>
        action.requestType === "policy_decision").length,
      dryRunOnly: true,
    },
    plannedActions,
    pendingAnswers,
  };
}

function validateAnsweredSlot({
  answer,
  decidedAt,
  errors,
  reviewer,
  slot,
}) {
  const prefix = answer.answerId;
  if (!slot.decisionOptions?.includes(answer.decision)) {
    errors.push(`${prefix}: decision ${answer.decision} is not allowed.`);
  }
  if (typeof answer.note !== "string" || answer.note.trim().length === 0) {
    errors.push(`${prefix}: note is required when a decision is filled.`);
  }
  if (!answer.acknowledgements || typeof answer.acknowledgements !== "object") {
    errors.push(`${prefix}: acknowledgements must be an object.`);
  }
  if (!Array.isArray(answer.requiredInputsReviewed)) {
    errors.push(`${prefix}: requiredInputsReviewed must be an array.`);
  }

  if (slot.requestType === "admin_publication_decision") {
    validatePublicationAnswer({answer, errors, prefix, slot});
  } else if (slot.requestType === "policy_decision") {
    validatePolicyAnswer({answer, errors, prefix, slot});
  } else {
    errors.push(`${prefix}: unsupported requestType ${slot.requestType}.`);
  }

  const action = actionForAnsweredSlot({answer, decidedAt, reviewer, slot});
  if (!action.dryRunCommand.includes("--dry-run")) {
    errors.push(`${prefix}: dry-run command must include --dry-run.`);
  }
}

function validatePublicationAnswer({answer, errors, prefix, slot}) {
  if (answer.decision !== "approve_public") return;
  for (const acknowledgement of slot.requiredAcknowledgements ?? []) {
    if (answer.acknowledgements?.[acknowledgement] !== true) {
      errors.push(`${prefix}: ${acknowledgement} acknowledgement is required.`);
    }
  }
}

function validatePolicyAnswer({answer, errors, prefix, slot}) {
  if (answer.decision !== "accept") return;
  for (const acknowledgement of slot.requiredAcknowledgements ?? []) {
    if (answer.acknowledgements?.[acknowledgement] !== true) {
      errors.push(`${prefix}: ${acknowledgement} acknowledgement is required.`);
    }
  }
  const requiredInputs = (slot.requiredInputs ?? []).map((input) => input.input);
  const reviewed = answer.requiredInputsReviewed ?? [];
  const missing = requiredInputs.filter((input) => !reviewed.includes(input));
  const unknown = reviewed.filter((input) => !requiredInputs.includes(input));
  if (missing.length > 0) {
    errors.push(`${prefix}: missing required inputs ${missing.join(", ")}.`);
  }
  if (unknown.length > 0) {
    errors.push(`${prefix}: unknown required inputs ${unknown.join(", ")}.`);
  }
}

function actionForAnsweredSlot({answer, decidedAt, reviewer, slot}) {
  if (slot.requestType === "admin_publication_decision") {
    return publicationAction({answer, decidedAt, reviewer, slot});
  }
  return policyAction({answer, decidedAt, reviewer, slot});
}

function publicationAction({answer, decidedAt, reviewer, slot}) {
  const parts = [
    "node",
    "tool/organizer_intake/review_decision.mjs",
    "draft",
    slot.subjectId,
    "--decision",
    answer.decision,
    "--app-visibility",
    answer.appVisibility ?? slot.safeDefaultPayload?.appVisibility ?? "hidden",
    "--reviewer",
    reviewer,
    "--date",
    decidedAt,
    "--note",
    answer.note,
  ];
  if (answer.decision === "approve_public") {
    parts.push("--confirm-publication-checklist");
    if ((slot.requiredAcknowledgements ?? []).includes("manualReportsReviewed")) {
      parts.push("--confirm-manual-reports-reviewed");
    }
  }
  return {
    actionId: `answer-plan:${slot.answerId}`,
    answerId: slot.answerId,
    requestType: slot.requestType,
    subjectId: slot.subjectId,
    subjectName: slot.subjectName,
    decision: answer.decision,
    dryRunCommandParts: [...parts, "--dry-run"],
    dryRunCommand: renderCommand([...parts, "--dry-run"]),
    writeCommandParts: parts,
    writeCommand: renderCommand(parts),
  };
}

function policyAction({answer, decidedAt, reviewer, slot}) {
  const parts = [
    "node",
    "tool/organizer_intake/policy_gap_decision.mjs",
    "draft",
    slot.subjectId,
    "--decision",
    answer.decision,
    "--reviewer",
    reviewer,
    "--date",
    decidedAt,
    "--note",
    answer.note,
  ];
  if (answer.decision === "accept") {
    parts.push("--confirm-required-inputs");
  }
  return {
    actionId: `answer-plan:${slot.answerId}`,
    answerId: slot.answerId,
    requestType: slot.requestType,
    subjectId: slot.subjectId,
    subjectName: slot.subjectName,
    decision: answer.decision,
    dryRunCommandParts: [...parts, "--dry-run"],
    dryRunCommand: renderCommand([...parts, "--dry-run"]),
    writeCommandParts: parts,
    writeCommand: renderCommand(parts),
  };
}

function renderCommand(parts) {
  return parts.map((part) => shellQuote(String(part))).join(" ");
}

function shellQuote(value) {
  if (/^[A-Za-z0-9_./:=@+-]+$/.test(value)) return value;
  return `'${value.replaceAll("'", "'\\''")}'`;
}

function invalidPlan(errors) {
  return {
    ok: false,
    errors,
    warnings: [],
    summary: {
      status: "invalid",
      answerSlots: 0,
      plannedActions: 0,
      pendingAnswers: 0,
      adminPublicationActions: 0,
      policyDecisionActions: 0,
      dryRunOnly: true,
    },
    plannedActions: [],
    pendingAnswers: [],
  };
}
