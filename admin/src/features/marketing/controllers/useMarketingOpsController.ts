import {useMutation, useQuery, useQueryClient} from "@tanstack/react-query";
import {useCallback, useEffect, useMemo, useState} from "react";
import {
  createMarketingContentDraft,
  loadMarketingOpsBridge,
  recordMarketingReviewDecision,
} from "../api/marketingRepository";
import {
  applyLocalDecision,
  checklistForDecision,
  type DecisionHandler,
} from "../../../shared/controllers/marketingReviewDecisionHelpers";
import type {
  AdminCreateMarketingContentDraftPayload,
  AdminGetMarketingOpsDashboardResponse,
  AdminRecordMarketingReviewDecisionPayload,
  AdminRecordMarketingReviewDecisionResponse,
  MarketingContentDraft,
  MarketingContentDraftSlide,
  MarketingContentDraftType,
  MarketingOpsBridge,
  MarketingOpsDecision,
  MarketingOpsTargetType,
  MarketingRecommendationItem,
} from "../../../shared/types/adminTypes";
import {adminQueryKeys} from "../../../shared/query/queryKeys";
import {usePendingMutationRecord} from "../../../shared/query/usePendingMutationRecord";
import {useAdminPendingOperationGuard} from "../../../shared/pendingOperation";

export type MarketingStudioTab =
  | "posts"
  | "new"
  | "events"
  | "media"
  | "activity"
  | "diagnostics"
  | "draft";
export type MarketingComposerStep = "source" | "copy" | "compliance" | "export";
export type MarketingTypeFilter = "all" | "event_highlights" | "feature_explainer";
export const marketingEditSizeLimit = 50000;

const composerSteps: MarketingComposerStep[] = ["source", "copy", "compliance", "export"];

export function useMarketingOpsController({
  activeTab = "posts",
  composerStep = "source",
  onComposerStepChange,
  onDraftOpen,
  onError,
  onNotice,
  onTabChange,
  selectedDraftId = null,
}: {
  activeTab?: MarketingStudioTab;
  composerStep?: MarketingComposerStep;
  onComposerStepChange?: (step: MarketingComposerStep) => void;
  onDraftOpen?: (draftId: string, step: MarketingComposerStep) => void;
  onError: (message: string | null) => void;
  onNotice: (message: string | null) => void;
  onTabChange?: (tab: Exclude<MarketingStudioTab, "draft">) => void;
  selectedDraftId?: string | null;
}) {
  const queryClient = useQueryClient();
  const {beginOperation, endOperation} = useAdminPendingOperationGuard();
  const bridgeQueryKey = adminQueryKeys.marketing.opsBridge();
  const bridgeQuery = useQuery({queryKey: bridgeQueryKey, queryFn: loadMarketingOpsBridge});
  const decisionMutationKey = adminQueryKeys.marketing.decision();
  const decisionMutation = useMutation({
    mutationKey: decisionMutationKey,
    mutationFn: recordMarketingReviewDecision,
  });
  const createDraftMutationKey = adminQueryKeys.marketing.createDraft();
  const createDraftMutation = useMutation({
    mutationKey: createDraftMutationKey,
    mutationFn: createMarketingContentDraft,
  });
  const savedBridge = bridgeQuery.data?.bridge ?? null;
  const [typeFilter, setTypeFilter] = useState<MarketingTypeFilter>("all");
  const [draftWorkingCopies, setDraftWorkingCopies] =
    useState<Record<string, MarketingContentDraft>>({});
  const [recommendationItemEdits, setRecommendationItemEdits] =
    useState<Record<string, Partial<MarketingRecommendationItem>>>({});
  const [decisionApplications, setDecisionApplications] = useState<Array<{
    response: AdminRecordMarketingReviewDecisionResponse;
    note: string;
  }>>([]);
  const [localDecisions, setLocalDecisions] =
    useState<Record<string, AdminRecordMarketingReviewDecisionResponse>>({});
  const [notes, setNotes] = useState<Record<string, string>>({});
  const [rightsConfirmations, setRightsConfirmations] =
    useState<Record<string, boolean>>({});
  const decisionInFlight = usePendingMutationRecord<
    AdminRecordMarketingReviewDecisionPayload,
    boolean
  >(decisionMutationKey, (payload) => ({
    key: `${payload.targetType}:${payload.targetId}`,
    value: true,
  }));
  const createDraftInFlight = usePendingMutationRecord<
    AdminCreateMarketingContentDraftPayload,
    boolean
  >(createDraftMutationKey, (payload) => ({
    key: `create:${payload.draftType}`,
    value: true,
  }));
  const inFlight = useMemo(
    () => ({...decisionInFlight, ...createDraftInFlight}),
    [createDraftInFlight, decisionInFlight]
  );

  const bridge = useMemo(() => {
    if (!savedBridge) return null;
    let next = decisionApplications.reduce(
      (current, item) => applyLocalDecision(current, item.response, item.note),
      savedBridge
    );
    next = {
      ...next,
      contentDrafts: next.contentDrafts.map((draft) =>
        draftWorkingCopies[draft.id] ?? draft),
      recommendationSets: next.recommendationSets.map((set) => ({
        ...set,
        items: set.items.map((item) => ({
          ...item,
          ...(recommendationItemEdits[`${set.id}:${item.id}`] ?? {}),
        })),
      })),
    };
    return next;
  }, [decisionApplications, draftWorkingCopies, recommendationItemEdits, savedBridge]);

  const hasUnsavedChanges = Object.keys(draftWorkingCopies).length > 0 ||
    Object.keys(recommendationItemEdits).length > 0;
  useEffect(() => {
    if (!hasUnsavedChanges) return undefined;
    const handleBeforeUnload = (event: BeforeUnloadEvent) => {
      event.preventDefault();
      event.returnValue = "";
    };
    window.addEventListener("beforeunload", handleBeforeUnload);
    return () => window.removeEventListener("beforeunload", handleBeforeUnload);
  }, [hasUnsavedChanges]);

  const loadBridge = useCallback(async () => {
    const result = await bridgeQuery.refetch();
    if (result.error) {
      onError(messageFromError(result.error, "Unable to load the marketing dashboard."));
      return false;
    }
    onError(null);
    return true;
  }, [bridgeQuery, onError]);

  useEffect(() => {
    if (bridgeQuery.isError) {
      onError(messageFromError(bridgeQuery.error, "Unable to load the marketing dashboard."));
      return;
    }
    if (bridgeQuery.isSuccess) onError(null);
  }, [bridgeQuery.error, bridgeQuery.isError, bridgeQuery.isSuccess, onError]);

  const targetDecision = useCallback<DecisionHandler>(async ({
    targetType,
    targetId,
    decision,
    edits,
    defaultNote,
  }: {
    targetType: MarketingOpsTargetType;
    targetId: string;
    decision: MarketingOpsDecision;
    edits?: Record<string, unknown>;
    defaultNote: string;
  }) => {
    if (!savedBridge) return;
    const editSize = serializedEditLength(edits);
    if (editSize > marketingEditSizeLimit) {
      onError(`Edited payload is ${editSize.toLocaleString()} characters; the maximum is ${marketingEditSizeLimit.toLocaleString()}.`);
      return;
    }
    const requiresRights = targetType === "content_draft" &&
      (decision === "approve" || decision === "export_ready");
    const rightsReviewed = rightsConfirmations[targetId] === true;
    if (requiresRights && !rightsReviewed) {
      onError("Confirm image and media rights before approving or marking this draft export ready.");
      return;
    }
    const key = `${targetType}:${targetId}`;
    const note = notes[key]?.trim() || defaultNote;
    const payload: AdminRecordMarketingReviewDecisionPayload = {
      targetType,
      targetId,
      decision,
      runId: savedBridge.runPlan.id,
      note,
      edits,
      checklist: checklistForDecision(targetType, decision, {rightsReviewed}),
    };
    const operation = beginOperation();
    if (!operation) return;
    onError(null);
    onNotice(null);
    try {
      const response = await decisionMutation.mutateAsync(payload);
      setLocalDecisions((current) => ({...current, [key]: response}));
      setDecisionApplications((current) => [...current, {response, note}]);
      onNotice(
        `Review receipt recorded at ${response.decisionPath}. Unsaved dashboard edits remain session-only.`
      );
    } catch (error) {
      onError(messageFromError(error, "Unable to record the marketing review decision."));
    } finally {
      endOperation(operation);
    }
  }, [
    beginOperation,
    decisionMutation,
    endOperation,
    notes,
    onError,
    onNotice,
    rightsConfirmations,
    savedBridge,
  ]);

  const updateRecommendationItem = useCallback((
    setId: string,
    itemId: string,
    patch: Partial<MarketingRecommendationItem>
  ) => {
    setRecommendationItemEdits((current) => ({
      ...current,
      [`${setId}:${itemId}`]: {...current[`${setId}:${itemId}`], ...patch},
    }));
  }, []);

  const updateDraft = useCallback((
    draftId: string,
    patch: Partial<MarketingContentDraft>
  ) => {
    setDraftWorkingCopies((current) => {
      const base = current[draftId] ?? savedBridge?.contentDrafts.find((draft) => draft.id === draftId);
      return base ? {...current, [draftId]: {...base, ...patch}} : current;
    });
  }, [savedBridge?.contentDrafts]);

  const updateDraftSlide = useCallback((
    draftId: string,
    slideId: string,
    patch: Partial<MarketingContentDraftSlide>
  ) => {
    setDraftWorkingCopies((current) => {
      const base = current[draftId] ?? savedBridge?.contentDrafts.find((draft) => draft.id === draftId);
      if (!base) return current;
      return {
        ...current,
        [draftId]: {
          ...base,
          slides: base.slides.map((slide) => slide.id === slideId ? {...slide, ...patch} : slide),
        },
      };
    });
  }, [savedBridge?.contentDrafts]);

  const setNote = useCallback((key: string, value: string) => {
    setNotes((current) => ({...current, [key]: value}));
  }, []);

  const createDraft = useCallback(async (draftType: MarketingContentDraftType) => {
    if (!savedBridge) return;
    const recommendationSet = savedBridge.recommendationSets.find((set) => set.items.length > 0) ??
      savedBridge.recommendationSets[0] ?? null;
    const payload: AdminCreateMarketingContentDraftPayload = {
      draftType,
      cityId: savedBridge.city.id,
      weekStart: savedBridge.weekStart,
      sourceRecommendationSetId: draftType === "event_highlights" ? recommendationSet?.id ?? null : null,
    };
    const operation = beginOperation();
    if (!operation) return;
    onError(null);
    onNotice(null);
    try {
      const response = await createDraftMutation.mutateAsync(payload);
      queryClient.setQueryData<AdminGetMarketingOpsDashboardResponse>(
        bridgeQueryKey,
        {bridge: response.bridge}
      );
      setDraftWorkingCopies((current) => {
        const next = {...current};
        delete next[response.draft.id];
        return next;
      });
      onDraftOpen?.(response.draft.id, "source");
      onNotice(`Created ${draftTypeLabel(draftType).toLowerCase()} draft ${response.draft.id}.`);
    } catch (error) {
      onError(messageFromError(error, "Unable to create marketing draft."));
    } finally {
      endOperation(operation);
    }
  }, [
    beginOperation,
    bridgeQueryKey,
    createDraftMutation,
    endOperation,
    onDraftOpen,
    onError,
    onNotice,
    queryClient,
    savedBridge,
  ]);

  const selectedDraft = useMemo(() => selectedDraftId ?
    bridge?.contentDrafts.find((draft) => draft.id === selectedDraftId) ?? null :
    null, [bridge?.contentDrafts, selectedDraftId]);
  const selectedDraftDirty = Boolean(selectedDraftId && draftWorkingCopies[selectedDraftId]);
  const selectedEditSize = selectedDraft ?
    serializedEditLength(selectedDraft as unknown as Record<string, unknown>) : 0;
  const rightsConfirmed = Boolean(selectedDraftId && rightsConfirmations[selectedDraftId]);
  const reviewReceiptRecorded = Boolean(selectedDraftId && localDecisions[`content_draft:${selectedDraftId}`]);
  const composerStepIndex = Math.max(0, composerSteps.indexOf(composerStep));

  return {
    activeTab,
    bridge,
    bridgeError: bridgeQuery.error ? messageFromError(bridgeQuery.error, "Marketing dashboard unavailable") : null,
    bridgeGeneratedAt: savedBridge?.generatedAt ?? null,
    bridgeIsStale: isStale(savedBridge?.generatedAt ?? null),
    composerStep: composerStepIndex,
    createDraft,
    discardSelectedDraftEdits: () => {
      if (!selectedDraftId) return;
      setDraftWorkingCopies((current) => {
        const next = {...current};
        delete next[selectedDraftId];
        return next;
      });
    },
    hasUnsavedChanges,
    inFlight,
    isLoading: bridgeQuery.isPending || bridgeQuery.isFetching,
    loadBridge,
    localDecisions,
    notes,
    reviewReceiptRecorded,
    rightsConfirmed,
    savedBridge,
    selectedDraft,
    selectedDraftDirty,
    selectedDraftId,
    selectedDraftUnavailable: Boolean(activeTab === "draft" && selectedDraftId && !selectedDraft && !bridgeQuery.isPending),
    selectedEditSize,
    selectedEditTooLarge: selectedEditSize > marketingEditSizeLimit,
    setActiveTab: (tab: Exclude<MarketingStudioTab, "draft">) => onTabChange?.(tab),
    setComposerStep: (stepIndex: number) => {
      onComposerStepChange?.(composerSteps[Math.min(Math.max(stepIndex, 0), composerSteps.length - 1)]!);
    },
    setNote,
    setRightsConfirmed: (confirmed: boolean) => {
      if (!selectedDraftId) return;
      setRightsConfirmations((current) => ({...current, [selectedDraftId]: confirmed}));
    },
    setTypeFilter,
    targetDecision,
    typeFilter,
    updateDraft,
    updateDraftSlide,
    updateRecommendationItem,
    openDraft: (draftId: string) => onDraftOpen?.(draftId, "source"),
  };
}

export function serializedEditLength(edits?: Record<string, unknown>): number {
  try {
    return JSON.stringify(edits ?? {}).length;
  } catch {
    return Number.POSITIVE_INFINITY;
  }
}

function isStale(value: string | null): boolean {
  if (!value) return false;
  const time = Date.parse(value);
  return Number.isFinite(time) && Date.now() - time > 7 * 86400000;
}

function draftTypeLabel(draftType: MarketingContentDraftType): string {
  return draftType === "feature_explainer" ? "Feature explainer" : "Event highlights";
}

function messageFromError(error: unknown, fallback: string): string {
  if (error && typeof error === "object" && "message" in error) {
    const message = (error as {message?: unknown}).message;
    if (typeof message === "string" && message.trim()) return message;
  }
  return fallback;
}

export type MarketingOpsController = ReturnType<typeof useMarketingOpsController>;
