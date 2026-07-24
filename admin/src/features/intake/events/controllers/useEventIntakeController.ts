import {useMutation, useQuery, useQueryClient} from "@tanstack/react-query";
import {useCallback, useEffect, useMemo, useState} from "react";
import {
  loadEventIntakeBridge,
  recordEventIntakeReviewDecision,
} from "../api/eventIntakeRepository";
import {
  applyLocalEventIntakeDecision,
  checklistForEventIntakeDecision,
  type EventIntakeDecisionHandler,
} from "./eventIntakeReviewDecisionHelpers";
import type {
  AdminGetEventIntakeDashboardResponse,
  AdminRecordEventIntakeReviewDecisionPayload,
  AdminRecordEventIntakeReviewDecisionResponse,
  EventIntakeDecision,
  EventIntakeBridge,
  EventIntakeCandidate,
  EventIntakeSourceProfile,
  EventIntakeSourceResult,
  EventIntakeTargetType,
} from "../../../../shared/types/adminTypes";
import {adminQueryKeys} from "../../../../shared/query/queryKeys";
import {usePendingMutationRecord} from "../../../../shared/query/usePendingMutationRecord";
import {useAdminPendingOperationGuard} from "../../../../shared/pendingOperation";

export type EventIntakeTab = "setup" | "inbox" | "candidates";

export function useEventIntakeController({
  onError,
  onNotice,
}: {
  onError: (message: string | null) => void;
  onNotice: (message: string | null) => void;
}) {
  const queryClient = useQueryClient();
  const {beginOperation, endOperation} = useAdminPendingOperationGuard();
  const bridgeQueryKey = adminQueryKeys.eventIntake.dashboardBridge();
  const bridgeQuery = useQuery({
    queryKey: bridgeQueryKey,
    queryFn: loadEventIntakeBridge,
  });
  const decisionMutationKey = adminQueryKeys.eventIntake.decision();
  const decisionMutation = useMutation({
    mutationKey: decisionMutationKey,
    mutationFn: recordEventIntakeReviewDecision,
  });
  const bridge = bridgeQuery.data?.bridge ?? null;
  const [activeTab, setActiveTab] = useState<EventIntakeTab>("candidates");
  const [localDecisions, setLocalDecisions] =
    useState<Record<string, AdminRecordEventIntakeReviewDecisionResponse>>({});
  const [notes, setNotes] = useState<Record<string, string>>({});
  const inFlight = usePendingMutationRecord<
    AdminRecordEventIntakeReviewDecisionPayload,
    boolean
  >(decisionMutationKey, (payload) => ({
    key: `${payload.targetType}:${payload.targetId}`,
    value: true,
  }));

  const setBridge = useCallback((
    update: (current: EventIntakeBridge | null) => EventIntakeBridge | null
  ) => {
    queryClient.setQueryData<AdminGetEventIntakeDashboardResponse>(
      bridgeQueryKey,
      (current) => {
        const nextBridge = update(current?.bridge ?? null);
        return nextBridge ? {bridge: nextBridge} : current;
      }
    );
  }, [bridgeQueryKey, queryClient]);

  const loadBridge = useCallback(async () => {
    onError(null);
    const result = await bridgeQuery.refetch();
    if (result.error) {
      onError(
        result.error instanceof Error ?
          result.error.message :
          "Unable to load event intake workspace."
      );
      return false;
    }
    return true;
  }, [bridgeQuery, onError]);

  useEffect(() => {
    if (bridgeQuery.isError) {
      onError(
        bridgeQuery.error instanceof Error ?
          bridgeQuery.error.message :
          "Unable to load event intake workspace."
      );
      return;
    }
    if (bridgeQuery.isSuccess) onError(null);
  }, [bridgeQuery.error, bridgeQuery.isError, bridgeQuery.isSuccess, onError]);

  const targetDecision = useCallback<EventIntakeDecisionHandler>(async ({
    targetType,
    targetId,
    decision,
    edits,
    defaultNote,
  }: {
    targetType: EventIntakeTargetType;
    targetId: string;
    decision: EventIntakeDecision | "export_ready";
    edits?: Record<string, unknown>;
    defaultNote: string;
  }) => {
    if (!bridge) return;
    if (decision === "export_ready") {
      onError("Event intake decisions do not support export-ready state.");
      return;
    }
    const key = `${targetType}:${targetId}`;
    const note = notes[key]?.trim() || defaultNote;
    const payload: AdminRecordEventIntakeReviewDecisionPayload = {
      targetType,
      targetId,
      decision,
      runId: bridge.runPlan.id,
      note,
      edits,
      checklist: checklistForEventIntakeDecision(targetType, decision),
    };
    const operation = beginOperation();
    if (!operation) return;
    onError(null);
    onNotice(null);
    try {
      const response = await decisionMutation.mutateAsync(payload);
      setLocalDecisions((current) => ({...current, [key]: response}));
      setBridge((current) =>
        current ? applyLocalEventIntakeDecision(current, response, note) :
          current
      );
      onNotice(
        `Recorded ${response.decisionStatus.replaceAll("_", " ")} for ${targetId}.`
      );
    } catch (error) {
      onError(
        error instanceof Error ?
          error.message :
          "Unable to record event intake decision."
      );
    } finally {
      endOperation(operation);
    }
  }, [
    beginOperation,
    bridge,
    decisionMutation,
    endOperation,
    notes,
    onError,
    onNotice,
    setBridge,
  ]);

  const updateSource = useCallback((
    sourceId: string,
    patch: Partial<EventIntakeSourceProfile>
  ) => {
    setBridge((current) => current ? {
      ...current,
      sourceProfiles: current.sourceProfiles.map((source) =>
        source.id === sourceId ? {...source, ...patch} : source
      ),
    } : current);
  }, []);

  const updateSourceResult = useCallback((
    resultId: string,
    patch: Partial<EventIntakeSourceResult>
  ) => {
    setBridge((current) => current ? {
      ...current,
      sourceResults: current.sourceResults.map((result) =>
        result.id === resultId ? {...result, ...patch} : result
      ),
    } : current);
  }, []);

  const updateCandidate = useCallback((
    candidateId: string,
    patch: Partial<EventIntakeCandidate>
  ) => {
    setBridge((current) => current ? {
      ...current,
      eventCandidates: current.eventCandidates.map((candidate) =>
        candidate.id === candidateId ? {...candidate, ...patch} : candidate
      ),
    } : current);
  }, []);

  const setNote = useCallback((key: string, value: string) => {
    setNotes((current) => ({...current, [key]: value}));
  }, []);

  const sourceResultById = useMemo(() => {
    const map = new Map<string, EventIntakeSourceResult>();
    for (const result of bridge?.sourceResults ?? []) map.set(result.id, result);
    return map;
  }, [bridge]);

  return {
    activeTab,
    bridge,
    inFlight,
    isLoading: bridgeQuery.isPending || bridgeQuery.isFetching,
    loadBridge,
    localDecisions,
    notes,
    setActiveTab,
    setNote,
    sourceResultById,
    targetDecision,
    updateCandidate,
    updateSource,
    updateSourceResult,
  };
}

export type EventIntakeController =
  ReturnType<typeof useEventIntakeController>;
