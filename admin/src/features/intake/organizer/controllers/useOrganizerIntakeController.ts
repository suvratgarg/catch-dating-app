import {useMutation} from "@tanstack/react-query";
import {useCallback, useMemo, useState} from "react";
import organizerIntakeBridgeJson from "../generated/organizerIntakeBridge.json";
import {
  decideOrganizerEventCandidate,
  decideOrganizerIntake,
  decideOrganizerPolicyGap,
  recordOrganizerCuration,
  resolveOrganizerEventLocation,
} from "../api/organizerIntakeRepository";
import {
  curationFormKey,
  curationPayloadForItem,
  decisionLabel,
  defaultEventCandidateDecisionNote,
  defaultIntakeDecisionNote,
  defaultPolicyGapDecisionNote,
  eventCandidateChecklistForDecision,
  eventDecisionLabel,
  intakeChecklistForDecision,
  locationResolutionFormFromTask,
  nullableInput,
  organizerIntakeDecisionFromString,
  organizerPolicyGapDecisionFromString,
  policyGapChecklistForDecision,
  policyGapDecisionLabel,
  publicationPacketReady,
  surfaceForCandidateCuration,
} from "./organizerIntakeHelpers";
import type {
  AdminDecideOrganizerEventCandidatePayload,
  AdminDecideOrganizerEventCandidateResponse,
  AdminDecideOrganizerIntakePayload,
  AdminDecideOrganizerIntakeResponse,
  AdminDecideOrganizerPolicyGapPayload,
  AdminDecideOrganizerPolicyGapResponse,
  AdminRecordOrganizerCurationPayload,
  AdminRecordOrganizerCurationResponse,
  AdminResolveOrganizerEventLocationPayload,
  AdminResolveOrganizerEventLocationResponse,
  OrganizerEventCandidateDecision,
  OrganizerIntakeDecision,
  OrganizerPolicyGapDecision,
} from "../../../../shared/types/adminTypes";
import type * as Intake from "../types/organizerIntakeTypes";
import {adminQueryKeys} from "../../../../shared/query/queryKeys";
import {usePendingMutationRecord} from "../../../../shared/query/usePendingMutationRecord";

const organizerIntakeBridge =
  organizerIntakeBridgeJson as unknown as Intake.OrganizerIntakeBridge;

type LocationResolutionMutationPayload =
  AdminResolveOrganizerEventLocationPayload & {taskId: string};

export function useOrganizerIntakeController({
  onError,
  onNotice,
}: {
  onError: (message: string | null) => void;
  onNotice: (message: string | null) => void;
}) {
  const bridge = organizerIntakeBridge;
  const [decisionNotes, setDecisionNotes] = useState<Record<string, string>>(
    {}
  );
  const [localDecisions, setLocalDecisions] =
    useState<Record<string, AdminDecideOrganizerIntakeResponse>>({});
  const [localCuration, setLocalCuration] =
    useState<Record<string, AdminRecordOrganizerCurationResponse>>({});
  const [curationForms, setCurationForms] =
    useState<Record<string, Intake.OrganizerCurationFormState>>({});
  const [eventDecisionNotes, setEventDecisionNotes] =
    useState<Record<string, string>>({});
  const [localEventDecisions, setLocalEventDecisions] =
    useState<Record<string, AdminDecideOrganizerEventCandidateResponse>>({});
  const [locationResolutionForms, setLocationResolutionForms] =
    useState<Record<string, Intake.OrganizerLocationResolutionFormState>>({});
  const [localLocationResolutions, setLocalLocationResolutions] =
    useState<Record<string, AdminResolveOrganizerEventLocationResponse>>({});
  const [policyDecisionNotes, setPolicyDecisionNotes] =
    useState<Record<string, string>>({});
  const [localPolicyDecisions, setLocalPolicyDecisions] =
    useState<Record<string, AdminDecideOrganizerPolicyGapResponse>>({});
  const [manualReportAcknowledgements, setManualReportAcknowledgements] =
    useState<Record<string, boolean>>({});
  const decisionMutationKey = adminQueryKeys.organizerIntake.decision();
  const curationMutationKey = adminQueryKeys.organizerIntake.curation();
  const eventDecisionMutationKey =
    adminQueryKeys.organizerIntake.eventDecision();
  const policyDecisionMutationKey =
    adminQueryKeys.organizerIntake.policyDecision();
  const locationResolutionMutationKey =
    adminQueryKeys.organizerIntake.locationResolution();
  const decideOrganizerIntakeMutation = useMutation({
    mutationKey: decisionMutationKey,
    mutationFn: decideOrganizerIntake,
  });
  const decideOrganizerEventCandidateMutation = useMutation({
    mutationKey: eventDecisionMutationKey,
    mutationFn: decideOrganizerEventCandidate,
  });
  const decideOrganizerPolicyGapMutation = useMutation({
    mutationKey: policyDecisionMutationKey,
    mutationFn: decideOrganizerPolicyGap,
  });
  const recordOrganizerCurationMutation = useMutation({
    mutationKey: curationMutationKey,
    mutationFn: recordOrganizerCuration,
  });
  const resolveOrganizerEventLocationMutation = useMutation({
    mutationKey: locationResolutionMutationKey,
    mutationFn: ({taskId: _taskId, ...payload}: LocationResolutionMutationPayload) =>
      resolveOrganizerEventLocation(payload),
  });
  const decisionInFlight = usePendingMutationRecord<
    AdminDecideOrganizerIntakePayload,
    OrganizerIntakeDecision
  >(decisionMutationKey, (payload) => ({
    key: payload.entityId,
    value: payload.decision,
  }));
  const curationInFlight = usePendingMutationRecord<
    AdminRecordOrganizerCurationPayload,
    boolean
  >(curationMutationKey, (payload) => ({
    key: curationKeyForPayload(payload),
    value: true,
  }));
  const eventDecisionInFlight = usePendingMutationRecord<
    AdminDecideOrganizerEventCandidatePayload,
    OrganizerEventCandidateDecision
  >(eventDecisionMutationKey, (payload) => ({
    key: payload.candidateId,
    value: payload.decision,
  }));
  const policyDecisionInFlight = usePendingMutationRecord<
    AdminDecideOrganizerPolicyGapPayload,
    OrganizerPolicyGapDecision
  >(policyDecisionMutationKey, (payload) => ({
    key: payload.gapId,
    value: payload.decision,
  }));
  const locationResolutionInFlight = usePendingMutationRecord<
    LocationResolutionMutationPayload,
    boolean
  >(locationResolutionMutationKey, (payload) => ({
    key: payload.taskId,
    value: true,
  }));

  const publicationPacketByEntity = useMemo(() =>
    new Map(
      bridge.publicationReviewPackets.packets.map((packet) => [
        packet.entityId,
        packet,
      ])
    ), [bridge.publicationReviewPackets.packets]);

  const metrics = useMemo(() => [
    {label: "Host entities", value: bridge.summary.canonicalHostEntities ?? 0},
    {label: "Evidence refs", value: bridge.summary.canonicalEvidenceRecords ?? 0},
    {label: "Review packets", value: bridge.summary.publicationReviewPackets ?? 0},
    {label: "Would publish", value: bridge.summary.publicationImpactWouldPublish ?? 0},
    {label: "Would index", value: bridge.summary.publicationImpactWouldIndex ?? 0},
    {label: "Review items", value: bridge.summary.reviewItems},
    {label: "Promotion", value: bridge.summary.promotionReview},
    {label: "Evidence", value: bridge.summary.evidenceReview},
    {label: "Blocked", value: bridge.summary.blocked},
    {label: "Public", value: bridge.summary.approvedPublic},
    {label: "App visible", value: bridge.summary.appDiscoverable},
    {label: "Claim writes", value: bridge.summary.claimTargetSyncPreviewWrites ?? 0},
    {label: "Search surfaces", value: bridge.summary.searchResultCandidates ?? 0},
    {label: "Event candidates", value: bridge.summary.externalEventCandidates ?? 0},
    {label: "Location tasks", value: bridge.summary.externalEventLocationTasks ?? 0},
    {
      label: "Read-only events",
      value: bridge.summary.externalEventImportProposedReadOnlyEvents ??
        bridge.summary.externalEventImportProposedCreates ??
        0,
    },
    {
      label: "Projection errors",
      value: bridge.summary.externalEventImportExecutionProjectionInvalidCount ??
        bridge.summary.externalEventImportExecutionPayloadInvalid ??
        0,
    },
    {label: "Crawl surfaces", value: bridge.summary.crawlCapableSurfaces ?? 0},
    {label: "Crawl runs", value: bridge.summary.crawlRunIntents ?? 0},
    {label: "Raw payloads", value: bridge.summary.rawProviderPayloads ?? 0},
    {label: "Curation", value: bridge.summary.curationOperations ?? 0},
    {label: "Policy gates", value: bridge.summary.readinessPolicyNeeded ?? 0},
    {label: "Policy gaps", value: bridge.summary.policyGapsDecisionRequired ?? 0},
    {label: "Policy inputs", value: bridge.summary.policyDecisionUnanswered ?? 0},
    {label: "Pending inputs", value: bridge.summary.pendingInputRequests ?? 0},
    {label: "Admin inputs", value: bridge.summary.pendingAdminPublicationInputs ?? 0},
    {label: "Answer packets", value: bridge.summary.reviewedAnswerPackets ?? 0},
    {label: "Ready packets", value: bridge.summary.reviewedAnswerPacketsReady ?? 0},
    {label: "Work covered", value: bridge.summary.pendingWorkCovered ?? 0},
    {label: "Untriaged work", value: bridge.summary.pendingWorkUntriaged ?? 0},
  ], [bridge.summary]);

  const handleDecision = useCallback(async (
    item: Intake.OrganizerIntakeItem,
    decision: OrganizerIntakeDecision
  ) => {
    const publicationPacket = publicationPacketByEntity.get(item.entityId);
    if (decision === "approve_public" &&
      !publicationPacketReady(publicationPacket)) {
      onError(
        publicationPacket ?
          "Resolve publication packet blockers before approving this organizer." :
          "Generate a publication review packet before approving this organizer."
      );
      return;
    }
    const manualReportCount =
      publicationPacket?.evidenceSummary.manualReportsWithoutArtifacts ?? 0;
    if (decision === "approve_public" &&
      manualReportCount > 0 &&
      manualReportAcknowledgements[item.entityId] !== true) {
      onError("Acknowledge manual reports before approving this organizer.");
      return;
    }
    const checklist = {
      ...intakeChecklistForDecision(item, decision),
      ...(decision === "approve_public" && manualReportCount > 0 ?
        {manualReportsReviewed: true} :
        {}),
    };
    if (decision === "approve_public" &&
      !Object.values(checklist).every(Boolean)) {
      onError("Resolve review gates before approving this organizer.");
      return;
    }
    const note = decisionNotes[item.entityId]?.trim() ||
      defaultIntakeDecisionNote(item, decision);
    onError(null);
    onNotice(null);
    try {
      const response = await decideOrganizerIntakeMutation.mutateAsync({
        entityId: item.entityId,
        decision,
        appVisibility: "hidden",
        checklist,
        note,
      });
      setLocalDecisions((current) => ({
        ...current,
        [item.entityId]: response,
      }));
      onNotice(
        `Recorded ${decisionLabel(decision)} for ${item.displayName}.`
      );
    } catch (decisionError) {
      onError(
        decisionError instanceof Error ?
          decisionError.message :
          "Unable to record organizer intake decision."
      );
    }
  }, [
    decisionNotes,
    decideOrganizerIntakeMutation,
    manualReportAcknowledgements,
    onError,
    onNotice,
    publicationPacketByEntity,
  ]);

  const handleAttachCandidate = useCallback(async (
    candidate: Intake.OrganizerSearchCandidate
  ) => {
    const entityId = candidate.existingEntityMatches[0]?.entityId;
    if (!entityId) {
      onError("Choose a matched organizer before attaching this surface.");
      return;
    }
    onError(null);
    onNotice(null);
    try {
      const response = await recordOrganizerCurationMutation.mutateAsync({
        operationType: "attach_surface",
        entityId,
        sourceCandidateId: candidate.candidateId,
        surface: surfaceForCandidateCuration(candidate),
        reason: `Search candidate ${candidate.candidateId} belongs to ${entityId}.`,
      });
      setLocalCuration((current) => ({
        ...current,
        [candidate.candidateId]: response,
      }));
      onNotice(`Recorded curation attach for ${candidate.title}.`);
    } catch (curationError) {
      onError(
        curationError instanceof Error ?
          curationError.message :
          "Unable to record organizer curation operation."
      );
    }
  }, [onError, onNotice, recordOrganizerCurationMutation]);

  const handleItemCuration = useCallback(async (
    item: Intake.OrganizerIntakeItem,
    form: Intake.OrganizerCurationFormState
  ) => {
    const payload = curationPayloadForItem(item, form);
    if (!payload.ok) {
      onError(payload.message);
      return;
    }
    const operationKey = curationFormKey(item, form);
    onError(null);
    onNotice(null);
    try {
      const response = await recordOrganizerCurationMutation.mutateAsync(payload.value);
      setLocalCuration((current) => ({
        ...current,
        [operationKey]: response,
      }));
      onNotice(
        `Recorded ${form.operationType.replaceAll("_", " ")} for ${item.displayName}.`
      );
    } catch (curationError) {
      onError(
        curationError instanceof Error ?
          curationError.message :
          "Unable to record organizer curation operation."
      );
    }
  }, [onError, onNotice, recordOrganizerCurationMutation]);

  const handleEventDecision = useCallback(async (
    candidate: Intake.OrganizerExternalEventCandidate,
    decision: OrganizerEventCandidateDecision
  ) => {
    const checklist = eventCandidateChecklistForDecision(candidate, decision);
    if (decision === "approve_for_import" &&
      !Object.values(checklist).every(Boolean)) {
      onError("Resolve event candidate review gates before import approval.");
      return;
    }
    const note = eventDecisionNotes[candidate.candidateId]?.trim() ||
      defaultEventCandidateDecisionNote(candidate, decision);
    onError(null);
    onNotice(null);
    try {
      const response = await decideOrganizerEventCandidateMutation.mutateAsync({
        candidateId: candidate.candidateId,
        decision,
        checklist,
        note,
      });
      setLocalEventDecisions((current) => ({
        ...current,
        [candidate.candidateId]: response,
      }));
      onNotice(
        `Recorded ${eventDecisionLabel(decision)} for ${candidate.title}.`
      );
    } catch (decisionError) {
      onError(
        decisionError instanceof Error ?
          decisionError.message :
          "Unable to record event candidate decision."
      );
    }
  }, [
    decideOrganizerEventCandidateMutation,
    eventDecisionNotes,
    onError,
    onNotice,
  ]);

  const handlePolicyGapDecision = useCallback(async (
    gap: Intake.OrganizerPolicyGap,
    decision: OrganizerPolicyGapDecision
  ) => {
    const checklist = policyGapChecklistForDecision(decision);
    const requiredInputsReviewed = decision === "accept" ?
      gap.requiredInputs :
      [];
    if (decision === "accept" &&
      (!Object.values(checklist).every(Boolean) ||
        requiredInputsReviewed.length === 0)) {
      onError("Review all policy inputs before accepting this policy gap.");
      return;
    }
    const note = policyDecisionNotes[gap.gapId]?.trim() ||
      defaultPolicyGapDecisionNote(gap, decision);
    onError(null);
    onNotice(null);
    try {
      const response = await decideOrganizerPolicyGapMutation.mutateAsync({
        gapId: gap.gapId,
        decision,
        requiredInputsReviewed,
        checklist,
        note,
      });
      setLocalPolicyDecisions((current) => ({
        ...current,
        [gap.gapId]: response,
      }));
      onNotice(
        `Recorded ${policyGapDecisionLabel(decision)} for ${gap.gapId}.`
      );
    } catch (decisionError) {
      onError(
        decisionError instanceof Error ?
          decisionError.message :
          "Unable to record policy gap decision."
      );
    }
  }, [
    decideOrganizerPolicyGapMutation,
    policyDecisionNotes,
    onError,
    onNotice,
  ]);

  const handlePendingInputDecision = useCallback(async (
    input: Intake.OrganizerPendingInputItem,
    decision: string
  ) => {
    const payload = input.callableSubmission?.payloadsByDecision[decision];
    if (!payload) {
      onError("Generated pending-input payload is missing for this decision.");
      return;
    }
    onError(null);
    onNotice(null);
    if (input.requestType === "admin_publication_decision") {
      const intakeDecision = organizerIntakeDecisionFromString(decision);
      if (!intakeDecision) {
        onError("Pending input decision is not a publication decision.");
        return;
      }
      try {
        const response = await decideOrganizerIntakeMutation.mutateAsync(
          payload as unknown as AdminDecideOrganizerIntakePayload
        );
        setLocalDecisions((current) => ({
          ...current,
          [response.entityId]: response,
        }));
        onNotice(
          `Recorded ${decisionLabel(response.decision)} for ${input.subjectName}.`
        );
      } catch (decisionError) {
        onError(
          decisionError instanceof Error ?
            decisionError.message :
            "Unable to record organizer intake decision."
        );
      }
      return;
    }
    if (input.requestType === "policy_decision") {
      const policyDecision = organizerPolicyGapDecisionFromString(decision);
      if (!policyDecision) {
        onError("Pending input decision is not a policy decision.");
        return;
      }
      try {
        const response = await decideOrganizerPolicyGapMutation.mutateAsync(
          payload as unknown as AdminDecideOrganizerPolicyGapPayload
        );
        setLocalPolicyDecisions((current) => ({
          ...current,
          [response.gapId]: response,
        }));
        onNotice(
          `Recorded ${policyGapDecisionLabel(response.decision)} for ${input.subjectName}.`
        );
      } catch (decisionError) {
        onError(
          decisionError instanceof Error ?
            decisionError.message :
            "Unable to record policy gap decision."
        );
      }
      return;
    }
    onError("Pending input request type is not wired for admin action.");
  }, [
    decideOrganizerIntakeMutation,
    decideOrganizerPolicyGapMutation,
    onError,
    onNotice,
  ]);

  const handleLocationResolution = useCallback(async (
    task: Intake.OrganizerExternalEventLocationResolutionTask
  ) => {
    const form = locationResolutionForms[task.taskId] ??
      locationResolutionFormFromTask(task);
    const latitude = Number(form.latitude);
    const longitude = Number(form.longitude);
    const name = form.name.trim() ||
      task.sourceLocation.name?.trim() ||
      task.resolutionQuery.trim();
    if (!name) {
      onError("Enter a reviewed location name before resolving coordinates.");
      return;
    }
    if (!Number.isFinite(latitude) || latitude < -90 || latitude > 90 ||
      !Number.isFinite(longitude) || longitude < -180 || longitude > 180) {
      onError("Enter reviewed latitude and longitude values.");
      return;
    }
    const note = form.note.trim() ||
      `Manual location QA complete for ${task.title}.`;
    onError(null);
    onNotice(null);
    try {
      const response = await resolveOrganizerEventLocationMutation.mutateAsync({
        taskId: task.taskId,
        candidateId: task.candidateId,
        location: {
          name,
          address: nullableInput(form.address),
          placeId: nullableInput(form.placeId),
          latitude,
          longitude,
          notes: nullableInput(form.notes),
        },
        checklist: {
          sourceLocationReviewed: true,
          coordinatesReviewed: true,
          placeIdentityReviewed: true,
          importSafetyReviewed: true,
        },
        note,
      });
      setLocalLocationResolutions((current) => ({
        ...current,
        [task.candidateId]: response,
      }));
      onNotice(`Resolved event location for ${task.title}.`);
    } catch (resolutionError) {
      onError(
        resolutionError instanceof Error ?
          resolutionError.message :
          "Unable to record event location resolution."
      );
    }
  }, [
    locationResolutionForms,
    onError,
    onNotice,
    resolveOrganizerEventLocationMutation,
  ]);

  return {
    bridge,
    curationForms,
    curationInFlight,
    decisionInFlight,
    decisionNotes,
    eventDecisionInFlight,
    eventDecisionNotes,
    handleAttachCandidate,
    handleDecision,
    handleEventDecision,
    handleItemCuration,
    handleLocationResolution,
    handlePendingInputDecision,
    handlePolicyGapDecision,
    localCuration,
    localDecisions,
    localEventDecisions,
    localLocationResolutions,
    localPolicyDecisions,
    locationResolutionForms,
    locationResolutionInFlight,
    manualReportAcknowledgements,
    metrics,
    policyDecisionInFlight,
    policyDecisionNotes,
    publicationPacketByEntity,
    setCurationForms,
    setDecisionNotes,
    setEventDecisionNotes,
    setLocationResolutionForms,
    setManualReportAcknowledgements,
    setPolicyDecisionNotes,
  };
}

function curationKeyForPayload(payload: AdminRecordOrganizerCurationPayload) {
  if (payload.sourceCandidateId) return payload.sourceCandidateId;
  return [
    payload.entityId ?? payload.sourceEntityId,
    payload.operationType,
    payload.targetEntityId,
    payload.surfaceId,
    payload.decision,
    payload.newEntityId,
  ].filter(Boolean).join(":");
}

export type OrganizerIntakeController =
  ReturnType<typeof useOrganizerIntakeController>;
