const safeDefaultsByGapId = {
  recurring_event_crawl_policy: {
    defaultAction: "keep_scheduler_disabled",
    decisionPrompt:
      "Should recurring provider crawls be enabled for any organizer surface?",
    implementationGate:
      "scheduler, platform allowlist, budget caps, and takedown policy encoded",
  },
  external_event_location_provider_policy: {
    defaultAction: "keep_manual_location_resolution",
    decisionPrompt:
      "Should provider-backed location lookup be allowed for external events?",
    implementationGate:
      "provider, confidence thresholds, spend caps, and retention encoded",
  },
  external_event_import_write_policy: {
    defaultAction: "keep_event_import_writes_disabled",
    decisionPrompt:
      "When may reviewed external event candidates become live app events?",
    implementationGate:
      "import service authority, approval threshold, conflict policy, and rollback encoded",
  },
  external_event_defaults_policy: {
    defaultAction: "keep_imports_blocked_without_event_defaults",
    decisionPrompt:
      "What default event fields should imported external events receive?",
    implementationGate:
      "capacity, admission, pricing, cancellation, and activity defaults encoded",
  },
  organizer_host_naming_migration_policy: {
    defaultAction: "keep_organizer_entity_with_club_compatibility",
    decisionPrompt:
      "What public entity and operator role labels should Catch standardize on?",
    implementationGate:
      "naming terms, migration order, URL policy, and compatibility plan encoded",
  },
};

export function buildOrganizerPolicyDecisionPackets(policyGapRegister) {
  const gaps = policyGapRegister?.gaps ?? [];
  const packets = gaps.map(packetForGap).sort((a, b) =>
    severityRank(a.severity) - severityRank(b.severity) ||
    a.area.localeCompare(b.area) ||
    a.gapId.localeCompare(b.gapId)
  );
  const allQuestions = packets.flatMap((packet) => packet.questions);

  return {
    schemaVersion: 1,
    generatedFrom: {
      policyGapRegister:
        "tool/organizer_intake/generated/organizer_policy_gap_register.json",
      policyGapDecisionBatches:
        "tool/organizer_intake/policy_gap_decisions/*.json",
    },
    summary: {
      packets: packets.length,
      decisionRequired: packets.filter((packet) =>
        packet.status === "decision_required").length,
      ready: packets.filter((packet) => packet.status === "ready").length,
      notReviewed: packets.filter((packet) =>
        packet.decisionStatus === "not_reviewed").length,
      accepted: packets.filter((packet) =>
        packet.decisionStatus === "accepted").length,
      held: packets.filter((packet) =>
        packet.decisionStatus === "held").length,
      rejected: packets.filter((packet) =>
        packet.decisionStatus === "rejected").length,
      invalid: packets.filter((packet) =>
        packet.decisionStatus === "invalid").length,
      questions: allQuestions.length,
      unansweredQuestions: allQuestions.filter((question) =>
        question.answerState !== "reviewed").length,
      requiredQuestions: allQuestions.filter((question) =>
        question.requiredForAcceptance).length,
      questionsByArea: countBy(packets, "area"),
      questionsByAnswerState: countBy(allQuestions, "answerState"),
    },
    guardrails: [
      "Decision packets ask for policy input only; they never enable crawls, provider lookups, uploads, imports, or naming migrations.",
      "Accepting a policy gap is not sufficient; the implementation gate must be encoded in repo-backed config and pass checks.",
      "The safe default for every unresolved packet is to keep the related behavior disabled.",
    ],
    packets,
  };
}

function packetForGap(gap) {
  const defaults = safeDefaultsByGapId[gap.gapId] ?? fallbackDefaults(gap);
  const reviewedInputs = new Set(
    gap.reviewDecision?.requiredInputsReviewed ?? []
  );
  const questions = (gap.requiredInputs ?? []).map((input, index) => ({
    questionId: `${gap.gapId}:${slugify(input) || `input-${index + 1}`}`,
    input,
    prompt: questionPrompt(input, gap),
    currentDefault: defaults.defaultAction,
    recommendedSafeDefault: defaults.defaultAction,
    requiredForAcceptance: true,
    answerState: reviewedInputs.has(input) ? "reviewed" : "needs_input",
  }));

  return {
    packetId: `policy-packet-${gap.gapId}`,
    gapId: gap.gapId,
    area: gap.area,
    severity: gap.severity,
    status: gap.status,
    decisionStatus: gap.decisionStatus,
    decisionOwner: gap.decisionOwner,
    decisionPrompt: defaults.decisionPrompt,
    currentState: gap.currentState,
    safeDefaultAction: defaults.defaultAction,
    implementationGate: defaults.implementationGate,
    blockedArtifacts: gap.blockedArtifacts ?? [],
    unblockCriteria: gap.unblockCriteria ?? [],
    nextAction: gap.nextAction,
    reviewDecision: gap.reviewDecision,
    questions,
  };
}

function questionPrompt(input, gap) {
  return `${input} for ${gap.area.replaceAll("_", " ")}.`;
}

function fallbackDefaults(gap) {
  return {
    defaultAction: gap.defaultPosition ?? "keep_disabled",
    decisionPrompt: gap.nextAction ?? `Review ${gap.gapId}.`,
    implementationGate:
      (gap.unblockCriteria ?? []).join("; ") || "repo-backed policy encoded",
  };
}

function countBy(items, field) {
  const counts = {};
  for (const item of items) {
    const key = item[field] ?? "unknown";
    counts[key] = (counts[key] ?? 0) + 1;
  }
  return Object.fromEntries(
    Object.entries(counts).sort(([a], [b]) => a.localeCompare(b))
  );
}

function severityRank(severity) {
  return {
    critical: 0,
    high: 1,
    medium: 2,
    low: 3,
  }[severity] ?? 9;
}

function slugify(value) {
  return String(value ?? "")
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}
