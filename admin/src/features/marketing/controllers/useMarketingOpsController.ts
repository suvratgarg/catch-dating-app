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

export type MarketingStudioTab =
  | "posts"
  | "composer"
  | "eventLibrary"
  | "mediaLibrary"
  | "activity"
  | "newPost";

export type MarketingTypeFilter =
  | "all"
  | "event_highlights"
  | "feature_explainer";

export function useMarketingOpsController({
  onError,
  onNotice,
}: {
  onError: (message: string | null) => void;
  onNotice: (message: string | null) => void;
}) {
  const queryClient = useQueryClient();
  const bridgeQueryKey = adminQueryKeys.marketing.opsBridge();
  const bridgeQuery = useQuery({
    queryKey: bridgeQueryKey,
    queryFn: loadMarketingOpsBridge,
  });
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
  const bridge = bridgeQuery.data?.bridge ?? null;
  const [activeTab, setActiveTab] = useState<MarketingStudioTab>("posts");
  const [typeFilter, setTypeFilter] =
    useState<MarketingTypeFilter>("all");
  const [selectedDraftId, setSelectedDraftId] = useState<string | null>(null);
  const [composerStep, setComposerStep] = useState(0);
  const [localDecisions, setLocalDecisions] =
    useState<Record<string, AdminRecordMarketingReviewDecisionResponse>>({});
  const [notes, setNotes] = useState<Record<string, string>>({});
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

  const setBridge = useCallback((
    update: (current: MarketingOpsBridge | null) => MarketingOpsBridge | null
  ) => {
    queryClient.setQueryData<AdminGetMarketingOpsDashboardResponse>(
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
          "Unable to load marketing ops dashboard."
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
          "Unable to load marketing ops dashboard."
      );
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
    if (!bridge) return;
    const key = `${targetType}:${targetId}`;
    const note = notes[key]?.trim() || defaultNote;
    const payload: AdminRecordMarketingReviewDecisionPayload = {
      targetType,
      targetId,
      decision,
      runId: bridge.runPlan.id,
      note,
      edits,
      checklist: checklistForDecision(targetType, decision),
    };
    onError(null);
    onNotice(null);
    try {
      const response = await decisionMutation.mutateAsync(payload);
      setLocalDecisions((current) => ({...current, [key]: response}));
      setBridge((current) =>
        current ? applyLocalDecision(current, response, note) : current
      );
      onNotice(
        `Recorded ${response.decisionStatus.replaceAll("_", " ")} for ${targetId}.`
      );
    } catch (error) {
      onError(
        error instanceof Error ?
          error.message :
          "Unable to record marketing review decision."
      );
    }
  }, [bridge, decisionMutation, notes, onError, onNotice, setBridge]);

  const updateRecommendationItem = useCallback((
    setId: string,
    itemId: string,
    patch: Partial<MarketingRecommendationItem>
  ) => {
    setBridge((current) => current ? {
      ...current,
      recommendationSets: current.recommendationSets.map((set) =>
        set.id === setId ? {
          ...set,
          items: set.items.map((item) =>
            item.id === itemId ? {...item, ...patch} : item
          ),
        } : set
      ),
    } : current);
  }, []);

  const updateDraft = useCallback((
    draftId: string,
    patch: Partial<MarketingContentDraft>
  ) => {
    setBridge((current) => current ? {
      ...current,
      contentDrafts: current.contentDrafts.map((draft) =>
        draft.id === draftId ? {...draft, ...patch} : draft
      ),
    } : current);
  }, []);

  const updateDraftSlide = useCallback((
    draftId: string,
    slideId: string,
    patch: Partial<MarketingContentDraftSlide>
  ) => {
    setBridge((current) => current ? {
      ...current,
      contentDrafts: current.contentDrafts.map((draft) =>
        draft.id === draftId ? {
          ...draft,
          slides: draft.slides.map((slide) =>
            slide.id === slideId ? {...slide, ...patch} : slide
          ),
        } : draft
      ),
    } : current);
  }, []);

  const setNote = useCallback((key: string, value: string) => {
    setNotes((current) => ({...current, [key]: value}));
  }, []);

  const createDraft = useCallback(async (
    draftType: MarketingContentDraftType
  ) => {
    if (!bridge) return;
    const recommendationSet = bridge.recommendationSets.find((set) =>
      set.items.length > 0
    ) ?? bridge.recommendationSets[0] ?? null;
    const payload: AdminCreateMarketingContentDraftPayload = {
      draftType,
      cityId: bridge.city.id,
      weekStart: bridge.weekStart,
      sourceRecommendationSetId:
        draftType === "event_highlights" ? recommendationSet?.id ?? null : null,
    };
    onError(null);
    onNotice(null);
    try {
      const response = await createDraftMutation.mutateAsync(payload);
      queryClient.setQueryData<AdminGetMarketingOpsDashboardResponse>(
        bridgeQueryKey,
        {bridge: response.bridge}
      );
      setSelectedDraftId(response.draft.id);
      setComposerStep(0);
      setActiveTab("composer");
      onNotice(
        `Created ${draftTypeLabel(draftType).toLowerCase()} draft ${response.draft.id}.`
      );
    } catch (error) {
      onError(
        error instanceof Error ?
          error.message :
          "Unable to create marketing draft."
      );
    }
  }, [
    bridge,
    bridgeQueryKey,
    createDraftMutation,
    onError,
    onNotice,
    queryClient,
  ]);

  const selectedDraft = useMemo(() => {
    if (!selectedDraftId) return null;
    return bridge?.contentDrafts.find((draft) =>
      draft.id === selectedDraftId
    ) ?? null;
  }, [bridge, selectedDraftId]);

  return {
    activeTab,
    bridge,
    composerStep,
    createDraft,
    inFlight,
    isLoading: bridgeQuery.isPending || bridgeQuery.isFetching,
    loadBridge,
    localDecisions,
    notes,
    selectedDraft,
    selectedDraftId,
    setActiveTab,
    setComposerStep,
    setNote,
    setSelectedDraftId,
    setTypeFilter,
    targetDecision,
    typeFilter,
    updateDraft,
    updateDraftSlide,
    updateRecommendationItem,
  };
}

function draftTypeLabel(draftType: MarketingContentDraftType): string {
  return draftType === "feature_explainer" ?
    "Feature explainer" :
    "Event highlights";
}

export type MarketingOpsController =
  ReturnType<typeof useMarketingOpsController>;
