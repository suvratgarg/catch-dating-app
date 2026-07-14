import {
  AlertTriangle,
  CheckCircle2,
  Clock3,
  Megaphone,
  Plus,
  RefreshCw,
} from "lucide-react";
import {
  AdminButton,
  AdminMarketingOpsShell,
  AdminMarketingStudioActions,
  AdminMarketingStudioNav,
  AdminMarketingTabs,
  AdminPanel,
  AdminStateRow,
  AdminStatGrid,
  AlertRow,
  EmptyState,
} from "../../../shared/ui/AdminPrimitives";
import {
  marketingEditSizeLimit,
  type MarketingComposerStep,
  type MarketingOpsController,
  type MarketingStudioTab,
  type MarketingTypeFilter,
  useMarketingOpsController,
} from "../controllers/useMarketingOpsController";
import {marketingComposerPanels} from "./marketingComposerPanels";
import {marketingLibraryPanels} from "./marketingLibraryPanels";
import {marketingWorkflowPanels} from "./marketingWorkflowPanels";

const studioTabs: Array<{
  id: Exclude<MarketingStudioTab, "draft" | "new">;
  label: string;
}> = [
  {id: "posts", label: "Posts"},
  {id: "events", label: "Events"},
  {id: "media", label: "Media"},
  {id: "activity", label: "Activity"},
  {id: "diagnostics", label: "Diagnostics"},
];

export function MarketingOpsScreen({
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
  const controller = useMarketingOpsController({
    activeTab,
    composerStep,
    onComposerStepChange,
    onDraftOpen,
    onError,
    onNotice,
    onTabChange,
    selectedDraftId,
  });
  return <MarketingOpsWorkspace controller={controller} />;
}

export function MarketingOpsWorkspace({
  controller,
}: {
  controller: MarketingOpsController;
}) {
  const {
    activeTab,
    bridge,
    composerStep,
    createDraft,
    inFlight,
    isLoading,
    loadBridge,
    localDecisions,
    notes,
    openDraft,
    rightsConfirmed,
    selectedDraft,
    selectedDraftId,
    setActiveTab,
    setComposerStep,
    setNote,
    setRightsConfirmed,
    setTypeFilter,
    targetDecision,
    typeFilter,
    updateDraft,
    updateDraftSlide,
    updateRecommendationItem,
  } = controller;

  if (!bridge) {
    return (
      <AdminMarketingOpsShell variant="studio">
        <AdminPanel
          icon={<AlertTriangle size={18} strokeWidth={1.9} />}
          title={isLoading ? "Loading marketing dashboard" : "Marketing dashboard unavailable"}
          action={isLoading ? "Loading" : "Retry available"}
        >
          <AlertRow
            icon={<AlertTriangle size={16} strokeWidth={1.9} />}
            title={controller.bridgeError ?? "No dashboard bridge was returned"}
            tone="warning"
          >
            No draft is available from the current source. Retry the source read.
          </AlertRow>
          <AdminButton
            disabled={isLoading}
            icon={<RefreshCw size={15} strokeWidth={1.9} />}
            onClick={() => void loadBridge()}
          >
            Retry dashboard read
          </AdminButton>
        </AdminPanel>
      </AdminMarketingOpsShell>
    );
  }

  return (
    <AdminMarketingOpsShell variant="studio">
      <AdminMarketingStudioNav>
        <AdminMarketingTabs
          ariaLabel="Marketing studio views"
          options={studioTabs}
          value={activeTab === "draft" || activeTab === "new" ? "posts" : activeTab}
          onChange={setActiveTab}
        />
        <AdminMarketingStudioActions>
          <AdminButton
            disabled={isLoading}
            icon={<RefreshCw size={15} strokeWidth={1.9} />}
            onClick={() => void loadBridge()}
          >
            {isLoading ? "Refreshing" : "Refresh"}
          </AdminButton>
          <AdminButton
            icon={<Plus size={15} strokeWidth={2} />}
            onClick={() => setActiveTab("new")}
            selected={activeTab === "new"}
            variant="primary"
          >
            New post
          </AdminButton>
        </AdminMarketingStudioActions>
      </AdminMarketingStudioNav>

      <MarketingPersistenceAlerts controller={controller} />

      {activeTab === "posts" ? (
        <marketingComposerPanels.MarketingPostsWorkspace
          bridge={bridge}
          selectedDraftId={selectedDraftId}
          typeFilter={typeFilter}
          onDraftSelect={(draftId) => {
            if (draftId) openDraft(draftId);
          }}
          onTypeFilterChange={setTypeFilter}
        />
      ) : activeTab === "draft" ? (
        selectedDraft ? (
          <marketingComposerPanels.MarketingDraftComposer
            appCaptures={bridge.appFeatureMedia?.captures ?? []}
            bridge={bridge}
            draft={selectedDraft}
            editSize={controller.selectedEditSize}
            editTooLarge={controller.selectedEditTooLarge}
            inFlight={inFlight}
            localDecisions={localDecisions}
            notes={notes}
            rightsConfirmed={rightsConfirmed}
            stepIndex={composerStep}
            onBack={() => setActiveTab("posts")}
            onDecision={targetDecision}
            onDraftChange={updateDraft}
            onNoteChange={setNote}
            onRightsConfirmedChange={setRightsConfirmed}
            onSlideChange={updateDraftSlide}
            onStepChange={setComposerStep}
          />
        ) : controller.selectedDraftUnavailable ? (
          <AdminPanel
            icon={<AlertTriangle size={18} strokeWidth={1.9} />}
            title="Draft unavailable"
            action="No fallback selected"
          >
            <AlertRow
              icon={<AlertTriangle size={16} strokeWidth={1.9} />}
              title="This draft is not in the saved dashboard snapshot"
              tone="warning"
            >
              Return to Posts or refresh the bridge. Another draft has not been auto-selected.
            </AlertRow>
          </AdminPanel>
        ) : (
          <EmptyState compact variant="marketing" icon={<Clock3 size={16} strokeWidth={1.9} />}>
            Loading draft.
          </EmptyState>
        )
      ) : activeTab === "events" ? (
        <marketingLibraryPanels.MarketingEventLibrary
          bridge={bridge}
          inFlight={inFlight}
          localDecisions={localDecisions}
          notes={notes}
          onDecision={targetDecision}
          onItemChange={updateRecommendationItem}
          onNoteChange={setNote}
        />
      ) : activeTab === "media" ? (
        <marketingLibraryPanels.MarketingMediaLibrary media={bridge.appFeatureMedia ?? null} />
      ) : activeTab === "activity" ? (
        <marketingWorkflowPanels.MarketingAudit bridge={bridge} localDecisions={localDecisions} />
      ) : activeTab === "diagnostics" ? (
        <MarketingDiagnostics controller={controller} />
      ) : (
        <marketingLibraryPanels.MarketingNewPost
          bridge={bridge}
          inFlight={inFlight}
          onCreateDraft={createDraft}
        />
      )}
    </AdminMarketingOpsShell>
  );
}

function MarketingPersistenceAlerts({controller}: {controller: MarketingOpsController}) {
  return (
    <>
      {controller.selectedDraftId && !controller.hasUnsavedChanges ? (
        <AlertRow
          icon={<CheckCircle2 size={16} strokeWidth={1.9} />}
          title="Saved dashboard snapshot"
          tone="neutral"
        >
          This draft matches the last loaded dashboard snapshot. A review receipt
          records a decision separately and does not persist later session edits.
        </AlertRow>
      ) : null}
      {controller.hasUnsavedChanges ? (
        <AlertRow
          icon={<AlertTriangle size={16} strokeWidth={1.9} />}
          title="Unsaved session edits"
          tone="warning"
        >
          These edits are not in the saved dashboard snapshot. Refreshing, closing,
          or leaving Marketing can discard them; a browser unload warning is active.
        </AlertRow>
      ) : null}
      {controller.reviewReceiptRecorded ? (
        <AlertRow
          icon={<Megaphone size={16} strokeWidth={1.9} />}
          title="Review receipt recorded"
          tone="neutral"
        >
          The receipt records a decision; it does not save the dashboard draft edits.
        </AlertRow>
      ) : null}
      {controller.bridgeIsStale ? (
        <AlertRow
          icon={<Clock3 size={16} strokeWidth={1.9} />}
          title="Dashboard bridge is stale by the 7-day heuristic"
          tone="warning"
        >
          Generated {formatDateTime(controller.bridgeGeneratedAt)}. Refresh or regenerate
          the bridge before relying on source freshness.
        </AlertRow>
      ) : null}
      {controller.selectedEditTooLarge ? (
        <AlertRow
          icon={<AlertTriangle size={16} strokeWidth={1.9} />}
          title="Edited payload exceeds the decision limit"
          tone="blocked"
        >
          {controller.selectedEditSize.toLocaleString()} / {marketingEditSizeLimit.toLocaleString()} serialized characters.
        </AlertRow>
      ) : null}
    </>
  );
}

function MarketingDiagnostics({controller}: {controller: MarketingOpsController}) {
  if (!controller.bridge) return null;
  return (
    <>
      <marketingComposerPanels.MarketingActionBoundaryPanel bridge={controller.bridge} />
      <AdminPanel
        icon={<RefreshCw size={18} strokeWidth={1.9} />}
        title="Dashboard source"
        action="Diagnostics"
      >
        <AdminStatGrid>
          <AdminStateRow label="Generated" value={formatDateTime(controller.bridgeGeneratedAt)} />
          <AdminStateRow label="Source state" value={controller.bridgeIsStale ? "Stale heuristic (>7 days)" : "Current by 7-day heuristic"} />
          <AdminStateRow label="Unsaved session edits" value={controller.hasUnsavedChanges ? "Present" : "None"} />
          <AdminStateRow label="Decision edit limit" value={`${marketingEditSizeLimit.toLocaleString()} serialized characters`} />
          <AdminStateRow label="Automatic posting" value="Unavailable; export and upload remain manual" />
        </AdminStatGrid>
      </AdminPanel>
    </>
  );
}

function formatDateTime(value: string | null): string {
  if (!value) return "Unavailable";
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return "Malformed timestamp";
  return new Intl.DateTimeFormat("en-IN", {dateStyle: "medium", timeStyle: "short"}).format(date);
}
