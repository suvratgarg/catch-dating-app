import type {
  AdminDecideOrganizerIntakeResponse,
  AdminDecideOrganizerPolicyGapResponse,
  AdminRecordOrganizerCurationPayload,
  OrganizerCurationSurface,
  OrganizerEventCandidateDecision,
  OrganizerIntakeDecision,
  OrganizerPolicyGapDecision,
} from "../../../../shared/types/adminTypes";
import type * as Intake from "../types/organizerIntakeTypes";

export type OrganizerPendingInputSubmittedDecision =
  | AdminDecideOrganizerIntakeResponse
  | AdminDecideOrganizerPolicyGapResponse;

export function pendingInputSubmittedDecision({
  input,
  policyDecisions,
  publicationDecisions,
}: {
  input: Intake.OrganizerPendingInputItem;
  policyDecisions: Record<string, AdminDecideOrganizerPolicyGapResponse>;
  publicationDecisions: Record<string, AdminDecideOrganizerIntakeResponse>;
}): OrganizerPendingInputSubmittedDecision | null {
  if (input.requestType === "admin_publication_decision") {
    return publicationDecisions[input.subjectId] ?? null;
  }
  if (input.requestType === "policy_decision") {
    return policyDecisions[input.subjectId] ?? null;
  }
  return null;
}

export function pendingInputInFlightDecision({
  input,
  policyInFlight,
  publicationInFlight,
}: {
  input: Intake.OrganizerPendingInputItem;
  policyInFlight: Record<string, OrganizerPolicyGapDecision>;
  publicationInFlight: Record<string, OrganizerIntakeDecision>;
}): string | undefined {
  if (input.requestType === "admin_publication_decision") {
    return publicationInFlight[input.subjectId];
  }
  if (input.requestType === "policy_decision") {
    return policyInFlight[input.subjectId];
  }
  return undefined;
}

export function pendingInputDecisionState(
  decision: OrganizerPendingInputSubmittedDecision
) {
  return "projectionState" in decision ?
    decision.projectionState :
    decision.operationalState;
}

export function pendingInputDecisionLabel(decision: string) {
  if (decision === "approve_public") return "Approve public";
  if (decision === "accept") return "Accept";
  return decision.charAt(0).toUpperCase() +
    decision.slice(1).replaceAll("_", " ");
}

export function pendingInputDecisionProgressLabel(decision: string) {
  if (decision === "approve_public") return "Approving";
  if (decision === "accept") return "Accepting";
  if (decision === "hold") return "Holding";
  if (decision === "suppress") return "Suppressing";
  if (decision === "reject") return "Rejecting";
  return "Recording";
}

export function organizerIntakeDecisionFromString(
  decision: string
): OrganizerIntakeDecision | null {
  if (
    decision === "approve_public" ||
    decision === "hold" ||
    decision === "suppress"
  ) {
    return decision;
  }
  return null;
}

export function organizerPolicyGapDecisionFromString(
  decision: string
): OrganizerPolicyGapDecision | null {
  if (decision === "accept" || decision === "hold" || decision === "reject") {
    return decision;
  }
  return null;
}

export function surfaceForCandidateCuration(
  candidate: Intake.OrganizerSearchCandidate
): OrganizerCurationSurface {
  return {
    ...candidate.suggestedSurface,
    evidenceRefs: [
      ...candidate.suggestedSurface.evidenceRefs,
      {
        type: "manualNote",
        ref: "admin/src/features/intake/organizer/generated/organizerIntakeBridge.json",
        description:
          `Search candidate ${candidate.candidateId} observed ${candidate.observedAt}.`,
      },
    ],
    notes: appendSentence(
      candidate.suggestedSurface.notes,
      `Candidate title: ${candidate.title}`
    ),
  };
}

export function defaultCurationForm(
  item: Intake.OrganizerIntakeItem
): Intake.OrganizerCurationFormState {
  return {
    operationType: item.surfaces.length > 0 ?
      "surface_decision" :
      "suppress_entity",
    targetEntityId: "",
    surfaceId: item.surfaces[0]?.surfaceId ?? "",
    newEntityId: "",
    decision: "reject_wrong_entity",
    reason: "",
  };
}

export function curationFormKey(
  item: Intake.OrganizerIntakeItem,
  form: Intake.OrganizerCurationFormState
) {
  return [
    item.entityId,
    form.operationType,
    form.targetEntityId,
    form.surfaceId,
    form.decision,
    form.newEntityId,
  ].filter(Boolean).join(":");
}

export function curationPayloadForItem(
  item: Intake.OrganizerIntakeItem,
  form: Intake.OrganizerCurationFormState
): {ok: true; value: AdminRecordOrganizerCurationPayload} |
  {ok: false; message: string} {
  const reason = form.reason.trim() || defaultCurationReason(item, form);
  if (form.operationType === "suppress_entity") {
    return {
      ok: true,
      value: {
        operationType: "suppress_entity",
        entityId: item.entityId,
        reason,
      },
    };
  }
  if (form.operationType === "merge_entity") {
    if (!form.targetEntityId) {
      return {ok: false, message: "Choose a target entity for merge."};
    }
    if (form.targetEntityId === item.entityId) {
      return {ok: false, message: "Choose a different merge target."};
    }
    return {
      ok: true,
      value: {
        operationType: "merge_entity",
        sourceEntityId: item.entityId,
        targetEntityId: form.targetEntityId,
        reason,
      },
    };
  }
  if (form.operationType === "surface_decision") {
    if (!form.surfaceId) {
      return {ok: false, message: "Choose a surface for this decision."};
    }
    return {
      ok: true,
      value: {
        operationType: "surface_decision",
        entityId: item.entityId,
        surfaceId: form.surfaceId,
        decision: form.decision,
        reason,
      },
    };
  }
  if (!form.surfaceId) {
    return {ok: false, message: "Choose a surface to split."};
  }
  if (!form.newEntityId.trim()) {
    return {ok: false, message: "Enter the new entity id for the split."};
  }
  return {
    ok: true,
    value: {
      operationType: "split_surface",
      entityId: item.entityId,
      surfaceId: form.surfaceId,
      newEntityId: form.newEntityId.trim(),
      reason,
    },
  };
}

export function intakeChecklistForDecision(
  item: Intake.OrganizerIntakeItem,
  decision: OrganizerIntakeDecision
) {
  const gatePassed = (id: string) =>
    item.gates.find((gate) => gate.id === id)?.passed === true;
  return {
    identityReviewed: gatePassed("identity_surface_present"),
    surfaceInventoryReviewed: gatePassed("surface_inventory_reviewable"),
    ownerSafeCopyReviewed: gatePassed("owner_safe_public_draft"),
    marketScopeReviewed: gatePassed("market_model_present"),
    mediaRightsReviewed: decision === "approve_public",
    crawlDisabledReviewed: gatePassed("crawl_disabled_by_default"),
  };
}

export function publicationPacketReady(
  packet?: Intake.OrganizerPublicationReviewPacket
) {
  if (!packet) return false;
  return packet.status === "ready_for_manual_publication_review" &&
    packet.dataBlockers.length === 0 &&
    packet.evidenceBlockers.length === 0 &&
    Object.values(packet.approvalChecklist).every(Boolean);
}

export function defaultIntakeDecisionNote(
  item: Intake.OrganizerIntakeItem,
  decision: OrganizerIntakeDecision
) {
  if (decision === "approve_public") {
    return `Manual QA approved ${item.displayName} for public website projection.`;
  }
  if (decision === "hold") {
    return `Manual QA held ${item.displayName} for additional evidence.`;
  }
  return `Manual QA suppressed ${item.displayName} from public projection.`;
}

export function eventCandidateChecklistForDecision(
  candidate: Intake.OrganizerExternalEventCandidate,
  decision: OrganizerEventCandidateDecision
) {
  if (decision === "approve_for_import") {
    return {
      identityReviewed: true,
      sourceEventReviewed: true,
      timeReviewed: true,
      locationReviewed: true,
      dedupeReviewed: true,
      ownerSafeCopyReviewed: true,
      importPolicyAcknowledged: true,
    };
  }
  return {
    identityReviewed: Boolean(candidate.entityId && candidate.surfaceId),
    sourceEventReviewed: Boolean(candidate.eventUrl),
    timeReviewed: Boolean(candidate.startAt),
    locationReviewed: Boolean(
      candidate.location.name ||
        candidate.location.address ||
        candidate.location.citySlug
    ),
    dedupeReviewed: false,
    ownerSafeCopyReviewed: false,
    importPolicyAcknowledged: true,
  };
}

export function defaultEventCandidateDecisionNote(
  candidate: Intake.OrganizerExternalEventCandidate,
  decision: OrganizerEventCandidateDecision
) {
  if (decision === "approve_for_import") {
    return `Manual QA approved ${candidate.title} for future event import. Import writes remain disabled by policy.`;
  }
  if (decision === "hold") {
    return `Manual QA held ${candidate.title} for additional event evidence.`;
  }
  return `Manual QA rejected ${candidate.title} from external event import.`;
}

export function policyGapChecklistForDecision(
  decision: OrganizerPolicyGapDecision
) {
  if (decision === "accept") {
    return {
      requiredInputsReviewed: true,
      costAndSafetyReviewed: true,
      implementationOwnerReviewed: true,
      behaviorStillDisabledAcknowledged: true,
    };
  }
  return {
    requiredInputsReviewed: false,
    costAndSafetyReviewed: false,
    implementationOwnerReviewed: true,
    behaviorStillDisabledAcknowledged: true,
  };
}

export function defaultPolicyGapDecisionNote(
  gap: Intake.OrganizerPolicyGap,
  decision: OrganizerPolicyGapDecision
) {
  if (decision === "accept") {
    return `Product policy accepted for ${gap.gapId}; behavior remains disabled until encoded in repo-backed policy.`;
  }
  if (decision === "hold") {
    return `Product policy held for ${gap.gapId}; required inputs remain unresolved.`;
  }
  return `Product policy rejected for ${gap.gapId}.`;
}

export function locationResolutionFormFromTask(
  task: Intake.OrganizerExternalEventLocationResolutionTask
): Intake.OrganizerLocationResolutionFormState {
  return {
    name: task.sourceLocation.name ?? "",
    address: task.sourceLocation.address ?? "",
    placeId: task.sourceLocation.placeId ?? "",
    latitude: task.sourceLocation.latitude == null ?
      "" :
      String(task.sourceLocation.latitude),
    longitude: task.sourceLocation.longitude == null ?
      "" :
      String(task.sourceLocation.longitude),
    notes: "",
    note: `Manual location QA complete for ${task.title}.`,
  };
}

export function nullableInput(value: string): string | null {
  const trimmed = value.trim();
  return trimmed ? trimmed : null;
}

export function decisionLabel(decision: string) {
  if (decision === "approve_public") return "Approve public";
  return decision.charAt(0).toUpperCase() + decision.slice(1);
}

export function eventDecisionLabel(decision: string) {
  if (decision === "approve_for_import") return "Approve future import";
  return decision.charAt(0).toUpperCase() + decision.slice(1);
}

export function policyGapDecisionLabel(decision: string) {
  if (decision === "accept") return "Accepted policy";
  if (decision === "hold") return "Held policy";
  if (decision === "reject") return "Rejected policy";
  return decision.charAt(0).toUpperCase() + decision.slice(1);
}

function defaultCurationReason(
  item: Intake.OrganizerIntakeItem,
  form: Intake.OrganizerCurationFormState
) {
  if (form.operationType === "suppress_entity") {
    return `${item.displayName} is a false-positive organizer candidate.`;
  }
  if (form.operationType === "merge_entity") {
    return `${item.entityId} is the same organizer as ${form.targetEntityId}.`;
  }
  if (form.operationType === "surface_decision") {
    return `${form.surfaceId} is ${form.decision.replaceAll("_", " ")}.`;
  }
  return `${form.surfaceId} belongs to ${form.newEntityId}.`;
}

function appendSentence(value: string, sentence: string) {
  const base = value.trim();
  const next = sentence.trim();
  if (!base) return next;
  if (!next) return base;
  return `${base} ${next}`;
}
