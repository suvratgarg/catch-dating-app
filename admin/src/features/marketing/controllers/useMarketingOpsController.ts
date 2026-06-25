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
  const [bridge, setBridge] = useState<MarketingOpsBridge | null>(null);
  const [activeTab, setActiveTab] = useState<MarketingStudioTab>("posts");
  const [typeFilter, setTypeFilter] =
    useState<MarketingTypeFilter>("all");
  const [selectedDraftId, setSelectedDraftId] = useState<string | null>(null);
  const [composerStep, setComposerStep] = useState(0);
  const [isLoading, setIsLoading] = useState(false);
  const [inFlight, setInFlight] = useState<Record<string, boolean>>({});
  const [localDecisions, setLocalDecisions] =
    useState<Record<string, AdminRecordMarketingReviewDecisionResponse>>({});
  const [notes, setNotes] = useState<Record<string, string>>({});

  const loadBridge = useCallback(async () => {
    setIsLoading(true);
    onError(null);
    try {
      const result = await loadMarketingOpsBridge();
      setBridge(result.bridge);
    } catch (error) {
      onError(
        error instanceof Error ?
          error.message :
          "Unable to load marketing ops dashboard."
      );
    } finally {
      setIsLoading(false);
    }
  }, [onError]);

  useEffect(() => {
    void loadBridge();
  }, [loadBridge]);

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
    setInFlight((current) => ({...current, [key]: true}));
    onError(null);
    onNotice(null);
    try {
      const response = await recordMarketingReviewDecision(payload);
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
    } finally {
      setInFlight((current) => {
        const next = {...current};
        delete next[key];
        return next;
      });
    }
  }, [bridge, notes, onError, onNotice]);

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
    const key = `create:${draftType}`;
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
    setInFlight((current) => ({...current, [key]: true}));
    onError(null);
    onNotice(null);
    try {
      const response = await createMarketingContentDraft(payload);
      setBridge(response.bridge);
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
    } finally {
      setInFlight((current) => {
        const next = {...current};
        delete next[key];
        return next;
      });
    }
  }, [bridge, onError, onNotice]);

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
    isLoading,
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
