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
  AdminRecordEventIntakeReviewDecisionPayload,
  AdminRecordEventIntakeReviewDecisionResponse,
  EventIntakeDecision,
  EventIntakeBridge,
  EventIntakeCandidate,
  EventIntakeSourceProfile,
  EventIntakeSourceResult,
  EventIntakeTargetType,
} from "../../../../shared/types/adminTypes";

export type EventIntakeTab = "setup" | "inbox" | "candidates";

export function useEventIntakeController({
  onError,
  onNotice,
}: {
  onError: (message: string | null) => void;
  onNotice: (message: string | null) => void;
}) {
  const [bridge, setBridge] = useState<EventIntakeBridge | null>(null);
  const [activeTab, setActiveTab] = useState<EventIntakeTab>("setup");
  const [isLoading, setIsLoading] = useState(false);
  const [inFlight, setInFlight] = useState<Record<string, boolean>>({});
  const [localDecisions, setLocalDecisions] =
    useState<Record<string, AdminRecordEventIntakeReviewDecisionResponse>>({});
  const [notes, setNotes] = useState<Record<string, string>>({});

  const loadBridge = useCallback(async () => {
    setIsLoading(true);
    onError(null);
    try {
      const result = await loadEventIntakeBridge();
      setBridge(result.bridge);
    } catch (error) {
      onError(
        error instanceof Error ?
          error.message :
          "Unable to load event intake workspace."
      );
    } finally {
      setIsLoading(false);
    }
  }, [onError]);

  useEffect(() => {
    void loadBridge();
  }, [loadBridge]);

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
    setInFlight((current) => ({...current, [key]: true}));
    onError(null);
    onNotice(null);
    try {
      const response = await recordEventIntakeReviewDecision(payload);
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
      setInFlight((current) => {
        const next = {...current};
        delete next[key];
        return next;
      });
    }
  }, [bridge, notes, onError, onNotice]);

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
    isLoading,
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
