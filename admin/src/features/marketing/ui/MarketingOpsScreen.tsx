import {type ChangeEvent, useCallback, useEffect, useState} from "react";
import {
  CheckCircle2,
  Clock3,
  Download,
  ExternalLink,
  FileWarning,
  ImagePlus,
  Library,
  ListChecks,
  Lock,
  Megaphone,
  Plus,
  RefreshCw,
  Search,
  Settings2,
  ShieldCheck,
  Sparkles,
  Trash2,
} from "lucide-react";
import {
  AdminButton,
  AdminCard,
  AdminIconButton,
  AdminLinkButton,
  AdminPanel,
  AdminStateRow,
  AdminTextField,
  AdminTextareaField,
  AlertRow,
  CardHeader,
  EmptyState,
  FilePickerButton,
  PageHeader,
  SegmentedControl,
  SelectField,
  SelectableCardButton,
  StatusChip,
} from "../../../shared/ui/AdminPrimitives";
import {
  appScreenshotPreviewUrl,
  appScreenshotRawPreviewUrl,
} from "../assets/marketingAppScreenshotAssets";
import {
  exportFeatureDropPngSlides,
  marketingFeatureDropDefaults,
  renderFeatureDropPreviewUrls,
  type FeatureDropImageResolver,
  type MarketingFeatureDropAccent,
  type MarketingFeatureDropAudience,
  type MarketingFeatureDropConfig,
  type MarketingFeatureDropRegister,
} from "../renderers/marketingFeatureDropRenderer";
import {
  publishabilityLabel,
  type DecisionHandler,
} from "../../../shared/controllers/marketingReviewDecisionHelpers";
import {
  type MarketingStudioTab,
  type MarketingTypeFilter,
  useMarketingOpsController,
} from "../controllers/useMarketingOpsController";
import {DecisionFooter} from "../../../shared/ui/ReviewDecisionControls";
import {
  AdminRecordMarketingReviewDecisionResponse,
  MarketingContentDraftType,
  MarketingAppFeatureMedia,
  MarketingAppScreenshotCapture,
  MarketingContentDraft,
  MarketingContentDraftSlideImage,
  MarketingContentDraftSlide,
  MarketingEventCandidate,
  MarketingOpsBridge,
  MarketingRecommendationItem,
  MarketingRecommendationSet,
  MarketingSourceProfile,
  MarketingSourceResult,
} from "../../../shared/types/adminTypes";

const studioTabs: Array<{id: MarketingStudioTab; label: string}> = [
  {id: "posts", label: "Posts"},
  {id: "eventLibrary", label: "Event library"},
  {id: "mediaLibrary", label: "Media library"},
  {id: "activity", label: "Activity"},
];

const typeFilters: Array<{id: MarketingTypeFilter; label: string}> = [
  {id: "all", label: "All"},
  {id: "event_highlights", label: "Event highlights"},
  {id: "feature_explainer", label: "Feature explainers"},
];

export function MarketingOpsScreen({
  onError,
  onNotice,
}: {
  onError: (message: string | null) => void;
  onNotice: (message: string | null) => void;
}) {
  const controller = useMarketingOpsController({onError, onNotice});
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
  } = controller;

  if (!bridge) {
    return (
      <EmptyState
        className="marketing-empty-state"
        icon={<RefreshCw size={18} strokeWidth={1.9} />}
      >
        {isLoading ? "Loading marketing ops..." : "Marketing ops is not available."}
      </EmptyState>
    );
  }

  return (
    <section className="marketing-ops-shell marketing-studio-shell">
      <PageHeader
        actions={(
          <div className="marketing-studio-actions">
            <AdminButton
              disabled={isLoading}
              icon={<RefreshCw size={15} strokeWidth={1.9} />}
              onClick={() => void loadBridge()}
            >
              {isLoading ? "Refreshing" : "Refresh"}
            </AdminButton>
            <AdminButton
              icon={<Plus size={15} strokeWidth={2} />}
              onClick={() => setActiveTab("newPost")}
              variant="primary"
            >
              New post
            </AdminButton>
          </div>
        )}
        className="marketing-studio-header"
        eyebrow={`Marketing / ${bridge.city.label}`}
        title="Content studio"
      >
        Create, review, and export event-highlight and feature-explainer posts.
        Marketing consumes approved intake records and lead lists; it does not
        create canonical organizer or event documents.
      </PageHeader>

      <div className="marketing-studio-nav">
        <SegmentedControl<MarketingStudioTab>
          ariaLabel="Marketing studio views"
          className="marketing-tabs"
          options={studioTabs}
          value={activeTab === "composer" ? "posts" : activeTab}
          onChange={setActiveTab}
        />
        <AdminButton
          icon={<Plus size={15} strokeWidth={2} />}
          onClick={() => setActiveTab("newPost")}
          selected={activeTab === "newPost"}
        >
          New post
        </AdminButton>
      </div>

      <MarketingActionBoundaryPanel bridge={bridge} />

      {activeTab === "posts" ? (
        <MarketingPostsWorkspace
          bridge={bridge}
          selectedDraftId={selectedDraftId}
          typeFilter={typeFilter}
          onDraftSelect={(draftId) => {
            setSelectedDraftId(draftId);
            setComposerStep(0);
            setActiveTab("composer");
          }}
          onTypeFilterChange={setTypeFilter}
        />
      ) : activeTab === "composer" ? (
        selectedDraft ? (
          <MarketingDraftComposer
            appCaptures={bridge.appFeatureMedia?.captures ?? []}
            bridge={bridge}
            draft={selectedDraft}
            inFlight={inFlight}
            localDecisions={localDecisions}
            notes={notes}
            stepIndex={composerStep}
            onBack={() => setActiveTab("posts")}
            onDecision={targetDecision}
            onDraftChange={updateDraft}
            onNoteChange={setNote}
            onSlideChange={updateDraftSlide}
            onStepChange={setComposerStep}
          />
        ) : (
          <EmptyState
            className="marketing-empty-state compact"
            icon={<Megaphone size={16} strokeWidth={1.9} />}
          >
            Select a post from the board before opening the composer.
          </EmptyState>
        )
      ) : activeTab === "eventLibrary" ? (
        <MarketingEventLibrary
          bridge={bridge}
          inFlight={inFlight}
          localDecisions={localDecisions}
          notes={notes}
          onDecision={targetDecision}
          onItemChange={updateRecommendationItem}
          onNoteChange={setNote}
        />
      ) : activeTab === "mediaLibrary" ? (
        <MarketingMediaLibrary media={bridge.appFeatureMedia ?? null} />
      ) : activeTab === "activity" ? (
        <MarketingAudit bridge={bridge} localDecisions={localDecisions} />
      ) : (
        <MarketingNewPost
          bridge={bridge}
          inFlight={inFlight}
          onCreateDraft={createDraft}
        />
      )}
    </section>
  );
}

function MarketingActionBoundaryPanel({
  bridge,
}: {
  bridge: MarketingOpsBridge;
}) {
  return (
    <AdminPanel
      icon={<Lock size={18} strokeWidth={1.9} />}
      title="Marketing action boundary"
      action="manual export"
    >
      <AlertRow
        icon={<ShieldCheck size={16} strokeWidth={1.9} />}
        title="Content packaging only"
      >
        Marketing consumes reviewed source-backed leads and draft records. App
        supply changes stay in Intake, Events, and Organizers.
      </AlertRow>
      <div className="marketing-stat-grid">
        <AdminStateRow
          label="Dashboard read"
          value="marketingOpsDashboards/current"
        />
        <AdminStateRow
          label="Run snapshot"
          value={`${bridge.runPlan.id} / ${bridge.weekStart}`}
        />
        <AdminStateRow
          label="Allowed writes"
          value="marketingReviewDecisions/{decisionId} and content drafts"
        />
        <AdminStateRow
          label="Callables"
          value="adminRecordMarketingReviewDecision + adminCreateMarketingContentDraft"
        />
        <AdminStateRow
          label="Manual output"
          value="PNG export and Instagram upload outside Catch"
        />
        <AdminStateRow
          label="Blocked here"
          value="events/{id}, externalEvents/{id}, organizer imports, booking, payments, direct posting"
        />
      </div>
      <div className="command-stack">
        {Object.entries(bridge.commands).length > 0 ? (
          Object.entries(bridge.commands).map(([label, command]) => (
            <div className="command-row" key={label}>
              <span>{label}</span>
              <code>{command}</code>
            </div>
          ))
        ) : (
          <div className="marketing-empty-state compact">
            <FileWarning size={16} strokeWidth={1.9} />
            <span>No generated marketing commands are attached to this dashboard.</span>
          </div>
        )}
      </div>
    </AdminPanel>
  );
}

function MarketingPostsWorkspace({
  bridge,
  selectedDraftId,
  typeFilter,
  onDraftSelect,
  onTypeFilterChange,
}: {
  bridge: MarketingOpsBridge;
  selectedDraftId: string | null;
  typeFilter: MarketingTypeFilter;
  onDraftSelect: (draftId: string | null) => void;
  onTypeFilterChange: (value: MarketingTypeFilter) => void;
}) {
  const filteredDrafts = bridge.contentDrafts.filter((draft) =>
    typeFilter === "all" || draftTypeForDraft(draft) === typeFilter
  );
  const board = boardColumns(filteredDrafts);

  return (
    <div className="marketing-studio-stack">
      <section className="marketing-studio-summary">
        <div>
          <span>Week</span>
          <strong>{bridge.weekStart} to {bridge.weekEnd}</strong>
        </div>
        <div>
          <span>Drafts</span>
          <strong>{bridge.summary.contentDrafts}</strong>
        </div>
        <div>
          <span>Export ready</span>
          <strong>{bridge.summary.exportReadyDrafts}</strong>
        </div>
        <div>
          <span>Verified pool</span>
          <strong>{bridge.summary.approvedCandidates}</strong>
        </div>
      </section>

      <SegmentedControl
        ariaLabel="Marketing content type filter"
        className="marketing-studio-filter-row"
        onChange={onTypeFilterChange}
        options={typeFilters}
        value={typeFilter}
      />

      <div className="marketing-post-board">
        {board.map((column) => (
          <section className="marketing-board-column" key={column.id}>
            <header>
              <span>{column.title}</span>
              <strong>{column.drafts.length}</strong>
            </header>
            <div className="marketing-board-list">
              {column.drafts.length === 0 ? (
                <div className="marketing-empty-state compact">
                  <CheckCircle2 size={16} strokeWidth={1.9} />
                  <span>{column.emptyText}</span>
                </div>
              ) : column.drafts.map((draft) => (
                <MarketingPostCard
                  draft={draft}
                  isSelected={draft.id === selectedDraftId}
                  key={draft.id}
                  onSelect={() => onDraftSelect(draft.id)}
                />
              ))}
            </div>
          </section>
        ))}
      </div>
    </div>
  );
}

interface MarketingBoardColumn {
  id: "sourcing" | "composing" | "compliance" | "ready";
  title: string;
  emptyText: string;
  drafts: MarketingContentDraft[];
}

function boardColumns(drafts: MarketingContentDraft[]): MarketingBoardColumn[] {
  const columns: MarketingBoardColumn[] = [
    {
      id: "sourcing",
      title: "Sourcing",
      emptyText: "No drafts waiting on a source pool.",
      drafts: [],
    },
    {
      id: "composing",
      title: "Composing",
      emptyText: "No active copy work.",
      drafts: [],
    },
    {
      id: "compliance",
      title: "Brand & compliance",
      emptyText: "No drafts waiting on final checks.",
      drafts: [],
    },
    {
      id: "ready",
      title: "Ready to post",
      emptyText: "No export-ready posts yet.",
      drafts: [],
    },
  ];
  for (const draft of drafts) {
    const stage = boardStageForDraft(draft);
    columns.find((column) => column.id === stage)?.drafts.push(draft);
  }
  return columns;
}

function boardStageForDraft(
  draft: MarketingContentDraft
): MarketingBoardColumn["id"] {
  if (
    draft.latestDecision?.decision === "export_ready" ||
    draft.status === "export_ready"
  ) {
    return "ready";
  }
  if (
    draftTypeForDraft(draft) === "event_highlights" &&
    !draft.slides.some((slide) => slide.role === "event")
  ) {
    return "sourcing";
  }
  if (draft.reviewState === "new" || draft.reviewState === "needs_changes") {
    return "composing";
  }
  if (draft.reviewState === "approved") return "ready";
  return "compliance";
}

function MarketingPostCard({
  draft,
  isSelected,
  onSelect,
}: {
  draft: MarketingContentDraft;
  isSelected: boolean;
  onSelect: () => void;
}) {
  const draftType = draftTypeForDraft(draft);
  const eventCount = draft.slides.filter((slide) => slide.role === "event")
    .length;
  const featureCount = draft.slides.filter((slide) => slide.role === "feature")
    .length;
  const countLabel = draftType === "event_highlights" ?
    `${eventCount} events` :
    `${featureCount} shots`;
  return (
    <SelectableCardButton
      onClick={onSelect}
      selected={isSelected}
    >
      <span className={`marketing-post-type ${draftType}`}>
        {draftLabel(draftType)}
      </span>
      <strong>{draftTitle(draft)}</strong>
      <span>{draft.cityId} / {draft.weekStart}</span>
      <div>
        <StatusChip>{draft.reviewState}</StatusChip>
        <StatusChip tone="muted">{countLabel}</StatusChip>
      </div>
      <small>{nextActionForDraft(draft)}</small>
    </SelectableCardButton>
  );
}

function MarketingDraftComposer({
  appCaptures,
  bridge,
  draft,
  inFlight,
  localDecisions,
  notes,
  stepIndex,
  onBack,
  onDecision,
  onDraftChange,
  onNoteChange,
  onSlideChange,
  onStepChange,
}: {
  appCaptures: MarketingAppScreenshotCapture[];
  bridge: MarketingOpsBridge;
  draft: MarketingContentDraft;
  inFlight: Record<string, boolean>;
  localDecisions: Record<string, AdminRecordMarketingReviewDecisionResponse>;
  notes: Record<string, string>;
  stepIndex: number;
  onBack: () => void;
  onDecision: DecisionHandler;
  onDraftChange: (draftId: string, patch: Partial<MarketingContentDraft>) => void;
  onNoteChange: (key: string, value: string) => void;
  onSlideChange: (
    draftId: string,
    slideId: string,
    patch: Partial<MarketingContentDraftSlide>
  ) => void;
  onStepChange: (stepIndex: number) => void;
}) {
  const draftType = draftTypeForDraft(draft);
  const key = `content_draft:${draft.id}`;
  const steps = draftType === "event_highlights" ?
    ["Pick events", "Order & copy", "Brand & compliance", "Export"] :
    ["Pick feature & shots", "Copy & layout", "Brand & compliance", "Export"];
  const exportDisabledReason = exportBlockerForDraft(draft);
  const boundedStep = Math.min(Math.max(stepIndex, 0), steps.length - 1);

  return (
    <section className="marketing-composer">
      <header className="marketing-composer-header">
        <div>
          <AdminButton
            className="marketing-composer-back"
            onClick={onBack}
          >
            Back to posts
          </AdminButton>
          <span className={`marketing-post-type ${draftType}`}>
            {draftLabel(draftType)}
          </span>
          <h3>{draftTitle(draft)}</h3>
          <p>
            {draft.format} / {draft.aspectRatio} / manual Instagram export
          </p>
        </div>
        <StatusChip>{draft.reviewState}</StatusChip>
      </header>

      <div className="marketing-step-strip">
        {steps.map((step, index) => (
          <SelectableCardButton
            className={
              index === boundedStep ?
                "marketing-step-chip active" :
                index < boundedStep ?
                "marketing-step-chip done" :
                "marketing-step-chip"
            }
            key={step}
            onClick={() => onStepChange(index)}
          >
            <span>{index < boundedStep ? "OK" : index + 1}</span>
            <strong>{step}</strong>
          </SelectableCardButton>
        ))}
      </div>

      {boundedStep === 0 ? (
        draftType === "event_highlights" ? (
          <MarketingEventPickStep bridge={bridge} draft={draft} />
        ) : (
          <MarketingFeaturePickStep
            appCaptures={appCaptures}
            draft={draft}
            onSlideChange={onSlideChange}
          />
        )
      ) : boundedStep === 1 ? (
        <MarketingCopyStep
          draft={draft}
          draftType={draftType}
          onDraftChange={onDraftChange}
          onSlideChange={onSlideChange}
        />
      ) : boundedStep === 2 ? (
        <MarketingComplianceStep draft={draft} draftType={draftType} />
      ) : (
        <MarketingExportStep
          draft={draft}
          exportDisabledReason={exportDisabledReason}
          inFlight={inFlight[key]}
          localDecision={localDecisions[key]}
          note={notes[key] ?? ""}
          onDecision={onDecision}
          onNoteChange={(value) => onNoteChange(key, value)}
        />
      )}

      <div className="marketing-composer-footer">
        {boundedStep > 0 ? (
          <AdminButton
            onClick={() => onStepChange(boundedStep - 1)}
          >
            {steps[boundedStep - 1]}
          </AdminButton>
        ) : <span />}
        {boundedStep < steps.length - 1 ? (
          <AdminButton
            onClick={() => onStepChange(boundedStep + 1)}
            variant="primary"
          >
            {steps[boundedStep + 1]}
          </AdminButton>
        ) : null}
      </div>
    </section>
  );
}

function MarketingEventPickStep({
  bridge,
  draft,
}: {
  bridge: MarketingOpsBridge;
  draft: MarketingContentDraft;
}) {
  const eventSlides = draft.slides.filter((slide) => slide.role === "event");
  const pickedIds = new Set(eventSlides.map((slide) => slide.eventCandidateId)
    .filter(Boolean));
  const verifiedEvents = bridge.eventCandidates.filter((event) =>
    event.reviewState === "approved" ||
    event.latestDecision?.decision === "approve" ||
    event.publishability === "publishable_after_approval"
  );

  return (
    <AdminPanel
      icon={<Library size={18} strokeWidth={1.9} />}
      title="Pick events from the library"
      action={`${eventSlides.length} picked`}
    >
      <p className="marketing-help-text">
        This step is read-only event selection visibility for the current draft.
        Event sourcing, verification, canonical imports, booking, payments, and
        waitlists stay in Intake, Events, and Organizers.
      </p>
      <div className="marketing-picker-list">
        {verifiedEvents.map((event) => {
          const isPicked = pickedIds.has(event.id);
          return (
            <div
              className={`marketing-picker-row ${isPicked ? "selected" : ""}`}
              key={event.id}
            >
              <span>{isPicked ? "OK" : ""}</span>
              <div>
                <strong>{event.title}</strong>
                <small>
                  {event.category} / {event.neighborhood} / {event.startDate}
                </small>
              </div>
              <em>{isPicked ? "In draft" : "Verified"}</em>
            </div>
          );
        })}
        {verifiedEvents.length === 0 ? (
          <div className="marketing-empty-state compact">
            <FileWarning size={16} strokeWidth={1.9} />
            <span>No verified events are available for this draft.</span>
          </div>
        ) : null}
      </div>
    </AdminPanel>
  );
}

function MarketingFeaturePickStep({
  appCaptures,
  draft,
  onSlideChange,
}: {
  appCaptures: MarketingAppScreenshotCapture[];
  draft: MarketingContentDraft;
  onSlideChange: (
    draftId: string,
    slideId: string,
    patch: Partial<MarketingContentDraftSlide>
  ) => void;
}) {
  const featureSlides = draft.slides.filter((slide) => slide.role === "feature");
  return (
    <AdminPanel
      icon={<ImagePlus size={18} strokeWidth={1.9} />}
      title="Pick feature shots"
      action={`${featureSlides.length} frames`}
    >
      <p className="marketing-help-text">
        Pair each feature frame with one approved app screenshot from the media
        library. Copy comes next.
      </p>
      <div className="marketing-feature-shot-grid">
        {featureSlides.map((slide, index) => (
          <div className="marketing-feature-shot-card" key={slide.id}>
            <div className="marketing-slide-editor-topline">
              <div className="intake-eyebrow">Frame {index + 1}</div>
              <span className="intake-badge muted">{slide.role}</span>
            </div>
            <strong>{slide.headline}</strong>
            <MarketingSlideImageEditor
              appCaptures={appCaptures}
              image={slide.image ?? null}
              slideId={slide.id}
              onChange={(image) => onSlideChange(draft.id, slide.id, {image})}
            />
          </div>
        ))}
        {featureSlides.length === 0 ? (
          <div className="marketing-empty-state compact">
            <FileWarning size={16} strokeWidth={1.9} />
            <span>No feature frames are available in this draft.</span>
          </div>
        ) : null}
      </div>
    </AdminPanel>
  );
}

function MarketingCopyStep({
  draft,
  draftType,
  onDraftChange,
  onSlideChange,
}: {
  draft: MarketingContentDraft;
  draftType: MarketingContentDraftType;
  onDraftChange: (draftId: string, patch: Partial<MarketingContentDraft>) => void;
  onSlideChange: (
    draftId: string,
    slideId: string,
    patch: Partial<MarketingContentDraftSlide>
  ) => void;
}) {
  return (
    <div className="marketing-step-layout">
      <AdminPanel
        icon={<ListChecks size={18} strokeWidth={1.9} />}
        title={draftType === "event_highlights" ? "Order & copy" : "Copy & layout"}
        action={`${draft.slides.length} slides`}
      >
        <div className="marketing-slide-list single">
          {draft.slides.map((slide, index) => (
            <div className="marketing-slide-editor" key={slide.id}>
              <div className="marketing-slide-editor-topline">
                <div className="intake-eyebrow">
                  {String(index + 1).padStart(2, "0")} / {slide.role}
                </div>
                {slide.eventCandidateId ? (
                  <span className="intake-badge muted">
                    {slide.eventCandidateId}
                  </span>
                ) : null}
              </div>
              <AdminTextField
                label="Headline"
                value={slide.headline}
                onChange={(value) =>
                  onSlideChange(draft.id, slide.id, {headline: value})}
              />
              <AdminTextareaField
                label="Body"
                rows={3}
                value={slide.body}
                onChange={(value) =>
                  onSlideChange(draft.id, slide.id, {body: value})}
              />
            </div>
          ))}
        </div>
      </AdminPanel>
      <AdminPanel
        icon={<Megaphone size={18} strokeWidth={1.9} />}
        title="Caption"
        action="Manual upload copy"
      >
        <AdminTextareaField
          label="Caption"
          rows={10}
          value={draft.caption}
          onChange={(value) => onDraftChange(draft.id, {caption: value})}
        />
        <div className="marketing-tag-row">
          {draft.ctas.map((cta) => (
            <span className="intake-tag muted" key={cta.id}>
              CTA / {cta.label}
            </span>
          ))}
        </div>
      </AdminPanel>
    </div>
  );
}

function MarketingComplianceStep({
  draft,
  draftType,
}: {
  draft: MarketingContentDraft;
  draftType: MarketingContentDraftType;
}) {
  return (
    <div className="marketing-step-layout">
      <AdminPanel
        icon={<CheckCircle2 size={18} strokeWidth={1.9} />}
        title="Brand & compliance check"
        action={draft.brandContract.rendererStatus}
      >
        <ComplianceChecklist draftType={draftType} />
      </AdminPanel>
      <AdminPanel
        icon={<Lock size={18} strokeWidth={1.9} />}
        title="Brand contract"
        action={draft.aspectRatio}
      >
        <div className="marketing-brand-contract">
          <div><span>Wordmark</span><strong>{draft.brandContract.logo}</strong></div>
          <div><span>Headlines</span><strong>{draft.brandContract.headlineFont}</strong></div>
          <div><span>Labels</span><strong>{draft.brandContract.labelFont}</strong></div>
          <div><span>Body</span><strong>{draft.brandContract.bodyFont}</strong></div>
          <div><span>Export</span><strong>{draft.delivery?.finalImageExport ?? "1080x1350 PNG"}</strong></div>
        </div>
      </AdminPanel>
    </div>
  );
}

function MarketingExportStep({
  draft,
  exportDisabledReason,
  inFlight,
  localDecision,
  note,
  onDecision,
  onNoteChange,
}: {
  draft: MarketingContentDraft;
  exportDisabledReason?: string;
  inFlight?: boolean;
  localDecision?: AdminRecordMarketingReviewDecisionResponse;
  note: string;
  onDecision: DecisionHandler;
  onNoteChange: (value: string) => void;
}) {
  return (
    <AdminPanel
      icon={<Download size={18} strokeWidth={1.9} />}
      title="Preview & export"
      action="Manual Instagram upload"
    >
      <MarketingDraftPreview draft={draft} />
      <DecisionFooter
        defaultNote={`Content draft ${draft.id} reviewed for export.`}
        edits={draft as unknown as Record<string, unknown>}
        inFlight={inFlight}
        localDecision={localDecision}
        note={note}
        targetId={draft.id}
        targetType="content_draft"
        onDecision={onDecision}
        onNoteChange={onNoteChange}
        showExportReady
        approvalDisabledReason={exportDisabledReason}
      />
    </AdminPanel>
  );
}

function ComplianceChecklist({
  draftType,
}: {
  draftType: MarketingContentDraftType;
}) {
  const checks = draftType === "event_highlights" ? [
    "Source verified",
    "Dates, venue, and price confirmed",
    "No Catch-host implication",
    "No singles-only claim unless source says it",
    "Image rights cleared",
  ] : [
    "Approved screenshots",
    "Accurate feature behavior",
    "Brand contract followed",
    "No unsupported product claim",
    "Image rights cleared",
  ];
  return (
    <div className="marketing-compliance-list">
      {checks.map((check) => (
        <AlertRow
          icon={<CheckCircle2 size={16} strokeWidth={1.9} />}
          key={check}
          title={check}
        >
          Required before marking the draft export ready.
        </AlertRow>
      ))}
    </div>
  );
}

function MarketingEventLibrary({
  bridge,
  inFlight,
  localDecisions,
  notes,
  onDecision,
  onItemChange,
  onNoteChange,
}: {
  bridge: MarketingOpsBridge;
  inFlight: Record<string, boolean>;
  localDecisions: Record<string, AdminRecordMarketingReviewDecisionResponse>;
  notes: Record<string, string>;
  onDecision: DecisionHandler;
  onItemChange: (
    setId: string,
    itemId: string,
    patch: Partial<MarketingRecommendationItem>
  ) => void;
  onNoteChange: (key: string, value: string) => void;
}) {
  const verifiedEvents = bridge.eventCandidates.filter((candidate) =>
    candidate.reviewState === "approved" ||
    candidate.latestDecision?.decision === "approve" ||
    candidate.publishability === "publishable_after_approval"
  );
  return (
    <div className="marketing-studio-stack">
      <AdminPanel
        icon={<Library size={18} strokeWidth={1.9} />}
        title="Verified event pool"
        action={`${verifiedEvents.length} usable`}
      >
        <p className="marketing-help-text">
          Marketing can curate approved event lead records here. Crawl setup,
          source inbox triage, event editing, canonical imports, and
          verification actions stay in Intake, Events, and Organizers.
        </p>
        <div className="marketing-event-library-grid">
          {verifiedEvents.map((event) => (
            <article className="marketing-library-card" key={event.id}>
              <header>
                <span className="intake-eyebrow">
                  {event.category} / {event.reviewState}
                </span>
                <h3>{event.title}</h3>
              </header>
              <p>{event.publicDescription}</p>
              <div className="marketing-tag-row">
                <span className="intake-tag">{event.venue}</span>
                <span className="intake-tag">{event.neighborhood}</span>
                <span className="intake-tag">{event.startDate}</span>
                <span className="intake-tag muted">{event.price}</span>
              </div>
              {event.sourceUrl ? (
                <AdminLinkButton
                  className="marketing-card-link"
                  href={event.sourceUrl}
                  icon={<ExternalLink size={15} strokeWidth={1.9} />}
                  rel="noreferrer"
                  target="_blank"
                >
                  Source
                </AdminLinkButton>
              ) : null}
            </article>
          ))}
          {verifiedEvents.length === 0 ? (
            <div className="marketing-empty-state compact">
              <FileWarning size={16} strokeWidth={1.9} />
              <span>No verified events are currently available.</span>
            </div>
          ) : null}
        </div>
      </AdminPanel>
      <MarketingRecommendations
        inFlight={inFlight}
        localDecisions={localDecisions}
        notes={notes}
        recommendationSets={bridge.recommendationSets}
        onDecision={onDecision}
        onItemChange={onItemChange}
        onNoteChange={onNoteChange}
      />
    </div>
  );
}

function MarketingMediaLibrary({
  media,
}: {
  media: MarketingAppFeatureMedia | null;
}) {
  if (!media) return <MarketingAppFeatureMediaView media={media} />;
  return (
    <div className="marketing-studio-stack">
      <AdminPanel
        icon={<ImagePlus size={18} strokeWidth={1.9} />}
        title="Media library"
        action={media.status.replaceAll("_", " ")}
      >
        <p className="marketing-help-text">
          App screenshot inventory for feature explainers. These assets come
          from the deterministic app media pipeline.
        </p>
        <div className="marketing-stat-grid">
          <AdminStateRow
            label="Active"
            value={`${media.summary.activeCaptures}/${media.summary.totalCaptures}`}
          />
          <AdminStateRow label="Member" value={String(media.summary.memberCaptures)} />
          <AdminStateRow label="Host" value={String(media.summary.hostCaptures)} />
        </div>
      </AdminPanel>

      <div className="marketing-media-grid">
        {media.captures.map((capture) => {
          const previewUrl = appScreenshotPreviewUrl(capture);
          return (
            <article className="marketing-media-card" key={capture.id}>
              {previewUrl ? (
                <img alt={capture.alt} src={previewUrl} />
              ) : (
                <div className="marketing-empty-state compact">
                  <FileWarning size={16} strokeWidth={1.9} />
                  <span>No preview</span>
                </div>
              )}
              <div>
                <span className="intake-eyebrow">
                  {capture.audience} / {capture.walkthroughStep}
                </span>
                <h3>{capture.surface}</h3>
                <p>{capture.caption}</p>
              </div>
              <div className="marketing-tag-row">
                <span className="intake-badge">{capture.status}</span>
                <span className="intake-badge muted">
                  {capture.assetState.replaceAll("_", " ")}
                </span>
              </div>
            </article>
          );
        })}
      </div>

      <AdminPanel
        icon={<Settings2 size={18} strokeWidth={1.9} />}
        title="Media automation"
        action={media.sourceDocs.pipelineDoc}
      >
        <div className="command-stack">
          {Object.entries(media.commands).map(([label, command]) => (
            <div className="command-row" key={label}>
              <span>{label}</span>
              <code>{command}</code>
            </div>
          ))}
        </div>
      </AdminPanel>

      <AdminPanel
        icon={<Lock size={18} strokeWidth={1.9} />}
        title="Direct Instagram publishing"
        action="Backend required"
      >
        <div className="quality-row warning">
          <Clock3 size={16} strokeWidth={1.9} />
          <div>
            <strong>Not a browser-only action</strong>
            <span>
              The admin can approve drafts now. Token handling, hosted assets,
              retries, and publish audit logs still need a backend job.
            </span>
          </div>
        </div>
      </AdminPanel>

      <MarketingFeatureDropView appCaptures={media.captures} />
    </div>
  );
}

function MarketingNewPost({
  bridge,
  inFlight,
  onCreateDraft,
}: {
  bridge: MarketingOpsBridge;
  inFlight: Record<string, boolean>;
  onCreateDraft: (draftType: MarketingContentDraftType) => Promise<void>;
}) {
  const eventCreateKey = "create:event_highlights";
  const featureCreateKey = "create:feature_explainer";
  return (
    <div className="marketing-new-post-grid">
      <NewPostTypeCard
        accent="event"
        description={`${bridge.summary.approvedCandidates} approved marketing event leads can seed the first draft.`}
        disabled={Boolean(inFlight[eventCreateKey])}
        label="Event highlights"
        meta="Weekly verified event carousel"
        onClick={() => void onCreateDraft("event_highlights")}
      />
      <NewPostTypeCard
        accent="feature"
        description={`${bridge.appFeatureMedia?.summary.activeCaptures ?? 0} active app screenshots available.`}
        disabled={Boolean(inFlight[featureCreateKey])}
        label="Feature explainer"
        meta="Product screenshot carousel"
        onClick={() => void onCreateDraft("feature_explainer")}
      />
      <NewPostTypeCard
        accent="soon"
        description="Needs organizer profile copy, rights policy, and claim-state routing."
        disabled
        label="Organizer spotlight"
        meta="Soon"
      />
      <NewPostTypeCard
        accent="soon"
        description="Needs a canonical hosted event detail contract before creation."
        disabled
        label="Event spotlight"
        meta="Soon"
      />
    </div>
  );
}

function NewPostTypeCard({
  accent,
  description,
  disabled = false,
  label,
  meta,
  onClick,
}: {
  accent: "event" | "feature" | "soon";
  description: string;
  disabled?: boolean;
  label: string;
  meta: string;
  onClick?: () => void;
}) {
  return (
    <SelectableCardButton
      className={`marketing-new-post-card ${accent}`}
      disabled={disabled}
      onClick={onClick}
    >
      <span>{meta}</span>
      <strong>{label}</strong>
      <p>{description}</p>
      <small>{disabled ? "Unavailable" : "Create draft"}</small>
    </SelectableCardButton>
  );
}

function MarketingGuide({bridge}: {bridge: MarketingOpsBridge}) {
  const recommendedDraft = bridge.contentDrafts.find((draft) =>
    draft.tone === "singles-friendly"
  ) ?? bridge.contentDrafts[0] ?? null;
  const recommendedSet = bridge.recommendationSets.find((set) =>
    set.tone === "singles-friendly"
  ) ?? bridge.recommendationSets[0] ?? null;
  const nextAction = guideNextAction(bridge);

  return (
    <div className="marketing-guide-layout">
      <AdminPanel
        className="span-2"
        icon={<Megaphone size={18} strokeWidth={1.9} />}
        title="What this produces"
        action="Manual export"
      >
        <div className="marketing-deliverable">
          <div>
            <strong>Deliverable</strong>
            <span>{bridge.summary.deliverable ?? "Manual content packet; no auto-posting."}</span>
          </div>
          <div>
            <strong>Posting</strong>
            <span>Instagram is manual upload for now. This tool prepares copy, slide text, and a reviewable layout preview.</span>
          </div>
          <div>
            <strong>Image files</strong>
            <span>Preview and export can download 1080x1350 PNG slides for manual Instagram upload. Posting still stays manual.</span>
          </div>
        </div>
      </AdminPanel>

      <AdminPanel
        icon={<ListChecks size={18} strokeWidth={1.9} />}
        title="Current state"
        action={bridge.summary.status}
      >
        <div className="marketing-stat-grid">
          <AdminStateRow label="Source results" value={String(bridge.summary.sourceResults)} />
          <AdminStateRow label="Reviewable candidates" value={String(bridge.summary.reviewableCandidates ?? 0)} />
          <AdminStateRow label="Needs source" value={String(bridge.summary.sourceMissingCandidates ?? 0)} />
          <AdminStateRow label="Dedupe groups" value={String(bridge.summary.duplicateGroups ?? 0)} />
          <AdminStateRow label="Shortlists" value={String(bridge.summary.recommendationSets)} />
          <AdminStateRow label="Export-ready" value={String(bridge.summary.exportReadyDrafts)} />
        </div>
        <AlertRow
          icon={<Clock3 size={16} strokeWidth={1.9} />}
          title="Next action"
          tone="warning"
        >
          {nextAction}
        </AlertRow>
      </AdminPanel>

      <AdminPanel
        icon={<Search size={18} strokeWidth={1.9} />}
        title="What is being shortlisted"
        action={recommendedSet?.tone ?? "none"}
      >
        <p className="marketing-help-text">
          Candidates are reviewed marketing event leads, not canonical Firestore
          event documents. The same candidate may be reused in multiple tone
          variants, but it should appear only once in the candidate queue after
          dedupe.
        </p>
        <div className="marketing-query-list">
          {(recommendedSet?.items ?? []).map((item) => (
            <div className="marketing-query" key={item.id}>
              <strong>{item.rank}. {item.title}</strong>
              <span>{item.neighborhood} / {publishabilityLabel(item.publishability)}</span>
            </div>
          ))}
          {(recommendedSet?.items.length ?? 0) === 0 ? (
            <div className="marketing-empty-state compact">
              <FileWarning size={16} strokeWidth={1.9} />
              <span>No sourced events are eligible for this shortlist yet.</span>
            </div>
          ) : null}
        </div>
      </AdminPanel>

      {recommendedDraft ? (
        <AdminPanel
          className="span-2"
          icon={<Sparkles size={18} strokeWidth={1.9} />}
          title="Post preview"
          action={recommendedDraft.aspectRatio}
        >
          <MarketingDraftPreview draft={recommendedDraft} />
        </AdminPanel>
      ) : null}
    </div>
  );
}

function MarketingRecommendations({
  recommendationSets,
  inFlight,
  localDecisions,
  notes,
  onDecision,
  onItemChange,
  onNoteChange,
}: {
  recommendationSets: MarketingRecommendationSet[];
  inFlight: Record<string, boolean>;
  localDecisions: Record<string, AdminRecordMarketingReviewDecisionResponse>;
  notes: Record<string, string>;
  onDecision: DecisionHandler;
  onItemChange: (
    setId: string,
    itemId: string,
    patch: Partial<MarketingRecommendationItem>
  ) => void;
  onNoteChange: (key: string, value: string) => void;
}) {
  return (
    <div className="marketing-stacked-sections">
      <AdminPanel
        icon={<Sparkles size={18} strokeWidth={1.9} />}
        title="Shortlist variants"
        action="Choose one direction"
      >
        <p className="marketing-help-text">
          These are alternate editorial treatments built from the same reviewed
          candidate pool. Singles-friendly is the default for third-party
          events. Singles-social should stay blocked unless the source
          explicitly says the event is for singles, dating, or mixers.
        </p>
      </AdminPanel>
      <div className="marketing-card-list">
      {recommendationSets.map((set) => (
        <AdminCard key={set.id}>
          <CardHeader
            action={(
              <StatusChip tone={set.items.length > 0 ? "success" : "neutral"}>
                {set.items.length} picks
              </StatusChip>
            )}
          >
            <div>
              <div className="intake-eyebrow">{set.tone} / {set.status}</div>
              <h3>{set.title}</h3>
            </div>
          </CardHeader>
          <p className="marketing-help-text">{set.explanation}</p>
          {set.status.startsWith("blocked") ? (
            <AlertRow
              icon={<FileWarning size={16} strokeWidth={1.9} />}
              title="Variant blocked"
              tone="warning"
            >
              No sourced candidates currently match this tone.
            </AlertRow>
          ) : null}
          <div className="marketing-recommendation-list">
            {set.items.map((item) => {
              const key = `recommendation_item:${item.id}`;
              return (
                <div className="marketing-recommendation-item" key={item.id}>
                  <AdminTextField
                    label="Rank"
                    value={String(item.rank)}
                    onChange={(value) =>
                      onItemChange(set.id, item.id, {rank: Number(value) || item.rank})}
                  />
                  <AdminTextField
                    label="Title"
                    value={item.title}
                    onChange={(value) => onItemChange(set.id, item.id, {title: value})}
                  />
                  <AdminTextareaField
                    label="Inclusion reason"
                    rows={2}
                    value={item.inclusionReason}
                    onChange={(value) =>
                      onItemChange(set.id, item.id, {inclusionReason: value})}
                  />
                  <DecisionFooter
                    compact
                    defaultNote={`Recommendation ${item.title} reviewed for ${set.tone}.`}
                    edits={item as unknown as Record<string, unknown>}
                    inFlight={inFlight[key]}
                    localDecision={localDecisions[key]}
                    note={notes[key] ?? ""}
                    targetId={item.id}
                    targetType="recommendation_item"
                    onDecision={onDecision}
                    onNoteChange={(value) => onNoteChange(key, value)}
                  />
                </div>
              );
            })}
          </div>
        </AdminCard>
      ))}
      </div>
    </div>
  );
}

function MarketingAppFeatureMediaView({
  media,
}: {
  media: MarketingAppFeatureMedia | null;
}) {
  if (!media) {
    return (
      <div className="marketing-card-list">
        <AdminPanel
          className="span-2"
          icon={<FileWarning size={18} strokeWidth={1.9} />}
          title="App media pipeline"
          action="Not generated"
        >
          <div className="marketing-empty-state compact">
            <FileWarning size={16} strokeWidth={1.9} />
            <span>
              The marketing ops bridge does not include app screenshot metadata.
              Regenerate it from the event-guide script to attach the existing
              screenshot capture manifest.
            </span>
          </div>
        </AdminPanel>
      </div>
    );
  }

  return (
    <div className="marketing-stacked-sections">
      <AdminPanel
        icon={<ImagePlus size={18} strokeWidth={1.9} />}
        title="App screenshot slots"
        action={media.status.replaceAll("_", " ")}
      >
        <p className="marketing-help-text">
          These slots come from the existing deterministic app media pipeline.
          Use this inventory for app-feature carousel imagery instead of
          hand-authored screenshots.
        </p>
        <div className="marketing-stat-grid">
          <AdminStateRow
            label="Active"
            value={`${media.summary.activeCaptures}/${media.summary.totalCaptures}`}
          />
          <AdminStateRow label="Member" value={String(media.summary.memberCaptures)} />
          <AdminStateRow label="Host" value={String(media.summary.hostCaptures)} />
        </div>
      </AdminPanel>

      <AdminPanel
        icon={<Settings2 size={18} strokeWidth={1.9} />}
        title="Existing automation"
        action={media.sourceDocs.pipelineDoc}
      >
        <div className="command-stack">
          {Object.entries(media.commands).map(([label, command]) => (
            <div className="command-row" key={label}>
              <span>{label}</span>
              <code>{command}</code>
            </div>
          ))}
        </div>
      </AdminPanel>

      <AdminPanel
        icon={<Lock size={18} strokeWidth={1.9} />}
        title="Direct Instagram publishing"
        action="Backend required"
      >
        <div className="quality-row">
          <CheckCircle2 size={16} strokeWidth={1.9} />
          <div>
            <strong>Feasible without operator downloads</strong>
            <span>
              The backend can publish from approved hosted assets after the
              Catch Instagram professional account is connected and approved.
            </span>
          </div>
        </div>
        <div className="quality-row warning">
          <Clock3 size={16} strokeWidth={1.9} />
          <div>
            <strong>Not a browser-only action</strong>
            <span>
              Instagram publishing uses container creation and publish calls, so
              the admin should approve a draft while a server job owns token
              handling, public asset URLs, retries, and audit logging.
            </span>
          </div>
        </div>
      </AdminPanel>

      <div className="marketing-card-list">
        {media.captures.map((capture) => {
          const previewUrl = appScreenshotPreviewUrl(capture);
          return (
            <article className="marketing-card" key={capture.id}>
              <header className="marketing-card-header">
                <div>
                  <div className="intake-eyebrow">
                    {capture.audience} / {capture.walkthroughStep}
                  </div>
                  <h3>{capture.surface}</h3>
                </div>
                <span className={`intake-badge ${capture.assetState === "website_synced" ? "ready" : ""}`}>
                  {capture.assetState.replaceAll("_", " ")}
                </span>
              </header>
              {previewUrl ? (
                <img
                  alt={capture.alt}
                  className="marketing-app-capture-preview"
                  src={previewUrl}
                />
              ) : (
                <div className="marketing-empty-state compact">
                  <FileWarning size={16} strokeWidth={1.9} />
                  <span>No preview asset found for this slot.</span>
                </div>
              )}
              <p className="marketing-help-text">{capture.caption}</p>
              <div className="marketing-tag-row">
                <span className="intake-badge">{capture.status}</span>
                <span className="intake-badge">{capture.device}</span>
                {capture.captureId ? (
                  <span className="intake-badge">{capture.captureId}</span>
                ) : null}
              </div>
              <div className="marketing-app-media-paths">
                <div>
                  <span>Source</span>
                  <code>{capture.sourcePath}</code>
                </div>
                <div>
                  <span>Website</span>
                  <code>{capture.websitePath}</code>
                </div>
                {capture.webPath ? (
                  <div>
                    <span>Public path</span>
                    <code>{capture.webPath}</code>
                  </div>
                ) : null}
              </div>
            </article>
          );
        })}
      </div>
    </div>
  );
}

function MarketingFeatureDropView({
  appCaptures,
}: {
  appCaptures: MarketingAppScreenshotCapture[];
}) {
  const [config, setConfig] = useState<MarketingFeatureDropConfig>(() =>
    marketingFeatureDropDefaults("members")
  );
  const [previewUrls, setPreviewUrls] = useState<string[]>([]);
  const [isRendering, setIsRendering] = useState(false);
  const [isExporting, setIsExporting] = useState(false);
  const [renderError, setRenderError] = useState<string | null>(null);
  const [exportMessage, setExportMessage] = useState<string | null>(null);
  const [exportError, setExportError] = useState<string | null>(null);

  const resolveFeatureImage = useCallback<FeatureDropImageResolver>((
    feature,
    currentConfig
  ) => {
    const capture = appCaptures.find((item) => item.id === feature.captureId);
    return appScreenshotRawPreviewUrl(capture, currentConfig.register);
  }, [appCaptures]);

  useEffect(() => {
    let cancelled = false;
    setIsRendering(true);
    setRenderError(null);
    void renderFeatureDropPreviewUrls(config, resolveFeatureImage)
      .then((urls) => {
        if (!cancelled) setPreviewUrls(urls);
      })
      .catch((error) => {
        if (!cancelled) {
          setRenderError(
            error instanceof Error ?
              error.message :
              "Unable to render feature drop preview."
          );
        }
      })
      .finally(() => {
        if (!cancelled) setIsRendering(false);
      });
    return () => {
      cancelled = true;
    };
  }, [config, resolveFeatureImage]);

  const updateConfig = useCallback((
    patch: Partial<MarketingFeatureDropConfig>
  ) => {
    setConfig((current) => ({...current, ...patch}));
  }, []);

  const updateAudience = useCallback((audience: MarketingFeatureDropAudience) => {
    setConfig((current) => {
      const next = marketingFeatureDropDefaults(audience);
      return {
        ...next,
        register: current.register,
        showWordmark: current.showWordmark,
        monthLabel: current.monthLabel,
        coverMeta: current.coverMeta,
      };
    });
  }, []);

  const updateFeature = useCallback((
    featureId: string,
    patch: Partial<MarketingFeatureDropConfig["features"][number]>
  ) => {
    setConfig((current) => ({
      ...current,
      features: current.features.map((feature) =>
        feature.id === featureId ? {...feature, ...patch} : feature
      ),
    }));
  }, []);

  const exportSlides = useCallback(async () => {
    setIsExporting(true);
    setExportMessage(null);
    setExportError(null);
    try {
      const count = await exportFeatureDropPngSlides(config, resolveFeatureImage);
      setExportMessage(`Downloaded ${count} feature-drop PNG slides.`);
    } catch (error) {
      setExportError(
        error instanceof Error ?
          error.message :
          "Unable to export feature-drop slides."
      );
    } finally {
      setIsExporting(false);
    }
  }, [config, resolveFeatureImage]);

  const selectedCaptureIds = new Set(config.features.map((feature) =>
    feature.captureId
  ));

  return (
    <div className="marketing-stacked-sections">
      <AdminPanel
        className="span-2"
        icon={<Sparkles size={18} strokeWidth={1.9} />}
        title="Feature drop renderer"
        action="1080x1350 / 6 frames"
      >
        <p className="marketing-help-text">
          This renderer follows the design-system feature-drop template: 4:5
          Instagram frames, Catch wordmark, Archivo headline system, IBM Plex
          Mono labels, activity pigment as the only chroma, and approved app
          screenshots inside the template phone shell.
        </p>
        <div className="quality-row">
          <CheckCircle2 size={16} strokeWidth={1.9} />
          <div>
            <strong>Uses existing capture automation</strong>
            <span>
              Phone imagery resolves from the app media bridge and prefers raw
              402x874 screenshots before falling back to synced website assets.
            </span>
          </div>
        </div>
      </AdminPanel>

      <AdminPanel
        className="span-2"
        icon={<Settings2 size={18} strokeWidth={1.9} />}
        title="Template controls"
        action={`${config.audience} / ${config.register} / ${config.accent}`}
      >
        <div className="feature-drop-control-grid">
          <SelectField
            className="marketing-field"
            label="Audience"
            onChange={(value) =>
              updateAudience(value as MarketingFeatureDropAudience)}
            options={[
              {label: "Members", value: "members"},
              {label: "Hosts", value: "hosts"},
            ]}
            value={config.audience}
          />
          <SelectField
            className="marketing-field"
            label="Register"
            onChange={(value) =>
              updateConfig({register: value as MarketingFeatureDropRegister})}
            options={[
              {label: "Dark", value: "dark"},
              {label: "Light", value: "light"},
              {label: "System", value: "system"},
            ]}
            value={config.register}
          />
          <SelectField
            className="marketing-field"
            label="Accent"
            onChange={(value) =>
              updateConfig({accent: value as MarketingFeatureDropAccent})}
            options={[
              {label: "Run", value: "run"},
              {label: "Padel", value: "padel"},
              {label: "Yoga", value: "yoga"},
              {label: "Cycling", value: "cycling"},
              {label: "Dinner", value: "dinner"},
            ]}
            value={config.accent}
          />
          <SelectField
            className="marketing-field"
            label="Wordmark"
            onChange={(value) =>
              updateConfig({showWordmark: value === "shown"})}
            options={[
              {label: "Shown", value: "shown"},
              {label: "Hidden", value: "hidden"},
            ]}
            value={config.showWordmark ? "shown" : "hidden"}
          />
          <AdminTextField
            label="Cover meta"
            value={config.coverMeta}
            onChange={(value) => updateConfig({coverMeta: value})}
          />
          <AdminTextField
            label="Month label"
            value={config.monthLabel}
            onChange={(value) => updateConfig({monthLabel: value})}
          />
          <AdminTextField
            label="Cover headline"
            value={config.coverHeadline}
            onChange={(value) => updateConfig({coverHeadline: value})}
          />
          <AdminTextField
            label="Outro line"
            value={config.outroLine}
            onChange={(value) => updateConfig({outroLine: value})}
          />
          <AdminTextareaField
            className="marketing-field feature-drop-span-2"
            label="Cover body"
            rows={2}
            value={config.coverBody}
            onChange={(value) => updateConfig({coverBody: value})}
          />
        </div>
      </AdminPanel>

      <AdminPanel
        className="span-2"
        icon={<ImagePlus size={18} strokeWidth={1.9} />}
        title="Feature slides"
        action={`${selectedCaptureIds.size} capture slots`}
      >
        {appCaptures.length === 0 ? (
          <div className="marketing-empty-state compact">
            <FileWarning size={16} strokeWidth={1.9} />
            <span>No app capture slots are available in the marketing bridge.</span>
          </div>
        ) : null}
        <div className="feature-drop-feature-list">
          {config.features.map((feature, index) => {
            const selectedCapture = appCaptures.find((capture) =>
              capture.id === feature.captureId
            );
            const previewUrl = selectedCapture ?
              appScreenshotPreviewUrl(selectedCapture) :
              null;
            return (
              <div className="feature-drop-feature-editor" key={feature.id}>
                <div className="marketing-image-editor-header">
                  <div>
                    <strong>Slide {index + 2}</strong>
                    <span>{feature.id.replaceAll("-", " ")}</span>
                  </div>
                  {previewUrl ? (
                    <img
                      alt={selectedCapture?.alt ?? ""}
                      className="feature-drop-capture-thumb"
                      src={previewUrl}
                    />
                  ) : null}
                </div>
                <AdminTextField
                  label="Title"
                  value={feature.title}
                  onChange={(value) => updateFeature(feature.id, {title: value})}
                />
                <AdminTextareaField
                  label="Body"
                  rows={4}
                  value={feature.body}
                  onChange={(value) => updateFeature(feature.id, {body: value})}
                />
                <SelectField
                  className="marketing-field"
                  label="App capture"
                  onChange={(value) =>
                    updateFeature(feature.id, {captureId: value})}
                  options={appCaptures.map((capture) => ({
                    label: `${capture.audience} / ${capture.surface}`,
                    value: capture.id,
                  }))}
                  value={feature.captureId}
                />
              </div>
            );
          })}
        </div>
      </AdminPanel>

      <AdminPanel
        className="span-2"
        icon={<Megaphone size={18} strokeWidth={1.9} />}
        title="Template preview"
        action={isRendering ? "Rendering" : "Ready"}
      >
        <div className="marketing-preview-toolbar">
          <div>
            <strong>Feature-drop carousel</strong>
            <span>Six export frames generated from the current editable copy.</span>
          </div>
          <AdminButton
            disabled={isExporting || previewUrls.length !== 6}
            icon={<Download size={15} strokeWidth={1.9} />}
            onClick={() => void exportSlides()}
          >
            {isExporting ? "Exporting" : "Download PNG slides"}
          </AdminButton>
        </div>
        {renderError ? (
          <div className="marketing-export-status error">{renderError}</div>
        ) : null}
        {exportError ? (
          <div className="marketing-export-status error">{exportError}</div>
        ) : null}
        {exportMessage ? (
          <div className="marketing-export-status">{exportMessage}</div>
        ) : null}
        <div className="feature-drop-preview-grid">
          {previewUrls.map((url, index) => (
            <figure className="feature-drop-preview-card" key={url}>
              <img
                alt={`Feature drop slide ${index + 1}`}
                src={url}
              />
              <figcaption>
                {String(index + 1).padStart(2, "0")} / {index === 0 ? "Cover" : index === 5 ? "Outro" : "Feature"}
              </figcaption>
            </figure>
          ))}
        </div>
      </AdminPanel>
    </div>
  );
}

function MarketingDrafts({
  appCaptures,
  drafts,
  inFlight,
  localDecisions,
  notes,
  onDecision,
  onDraftChange,
  onNoteChange,
  onSlideChange,
}: {
  appCaptures: MarketingAppScreenshotCapture[];
  drafts: MarketingContentDraft[];
  inFlight: Record<string, boolean>;
  localDecisions: Record<string, AdminRecordMarketingReviewDecisionResponse>;
  notes: Record<string, string>;
  onDecision: DecisionHandler;
  onDraftChange: (draftId: string, patch: Partial<MarketingContentDraft>) => void;
  onNoteChange: (key: string, value: string) => void;
  onSlideChange: (
    draftId: string,
    slideId: string,
    patch: Partial<MarketingContentDraftSlide>
  ) => void;
}) {
  return (
    <div className="marketing-stacked-sections">
      <AdminPanel
        icon={<Megaphone size={18} strokeWidth={1.9} />}
        title="Preview and export"
        action="Manual Instagram upload"
      >
        <p className="marketing-help-text">
          This preview shows the carousel copy and slide order. PNG export
          creates individual 4:5 image files for manual Instagram upload. It is
          not an auto-posting integration.
        </p>
      </AdminPanel>
      <div className="marketing-card-list">
      {drafts.map((draft) => {
        const key = `content_draft:${draft.id}`;
        const eventSlideCount = draft.slides.filter((slide) =>
          slide.role === "event"
        ).length;
        return (
          <article className="marketing-card span-2" key={draft.id}>
            <header className="marketing-card-header">
              <div>
                <div className="intake-eyebrow">{draft.format} / {draft.tone}</div>
                <h3>{draft.id}</h3>
              </div>
              <span className="intake-badge">{draft.aspectRatio}</span>
            </header>
            <div className="quality-row">
              <CheckCircle2 size={16} strokeWidth={1.9} />
              <div>
                <strong>PNG export available</strong>
                <span>
                  Downloads one 1080x1350 PNG per slide using the current
                  editable draft copy and existing Catch web tokens.
                </span>
              </div>
            </div>
            <MarketingDraftPreview draft={draft} />
            <div className="marketing-slide-list">
              {draft.slides.map((slide) => (
                <div className="marketing-slide-editor" key={slide.id}>
                  <div className="intake-eyebrow">{slide.role}</div>
                  <AdminTextField
                    label="Headline"
                    value={slide.headline}
                    onChange={(value) =>
                      onSlideChange(draft.id, slide.id, {headline: value})}
                  />
                  <AdminTextareaField
                    label="Body"
                    rows={2}
                    value={slide.body}
                    onChange={(value) =>
                      onSlideChange(draft.id, slide.id, {body: value})}
                  />
                  <MarketingSlideImageEditor
                    appCaptures={appCaptures}
                    image={slide.image ?? null}
                    slideId={slide.id}
                    onChange={(image) =>
                      onSlideChange(draft.id, slide.id, {image})}
                  />
                </div>
              ))}
            </div>
            <AdminTextareaField
              label="Caption"
              rows={8}
              value={draft.caption}
              onChange={(value) => onDraftChange(draft.id, {caption: value})}
            />
            <DecisionFooter
              defaultNote={`Content draft ${draft.id} reviewed for export.`}
              edits={draft as unknown as Record<string, unknown>}
              inFlight={inFlight[key]}
              localDecision={localDecisions[key]}
              note={notes[key] ?? ""}
              targetId={draft.id}
              targetType="content_draft"
              onDecision={onDecision}
              onNoteChange={(value) => onNoteChange(key, value)}
              showExportReady
              approvalDisabledReason={
                eventSlideCount === 0 ?
                  "This draft has no sourced event slides yet." :
                  undefined
              }
            />
          </article>
        );
      })}
      </div>
    </div>
  );
}

function MarketingSlideImageEditor({
  appCaptures,
  image,
  slideId,
  onChange,
}: {
  appCaptures: MarketingAppScreenshotCapture[];
  image: MarketingContentDraftSlideImage | null;
  slideId: string;
  onChange: (image: MarketingContentDraftSlideImage | null) => void;
}) {
  const selectedCapture = image?.sourceType === "app_capture" && image.captureId ?
    appCaptures.find((capture) => capture.id === image.captureId) ?? null :
    null;
  const previewUrl = selectedCapture ?
    appScreenshotPreviewUrl(selectedCapture) :
    image?.url ?? null;

  const updateImage = useCallback((
    patch: Partial<MarketingContentDraftSlideImage>
  ) => {
    onChange({
      sourceType: image?.sourceType ?? "url",
      url: image?.url ?? "",
      fit: image?.fit ?? "cover",
      altText: image?.altText ?? "",
      credit: image?.credit ?? "",
      fileName: image?.fileName ?? null,
      captureId: image?.captureId ?? null,
      sourcePath: image?.sourcePath ?? null,
      websitePath: image?.websitePath ?? null,
      webPath: image?.webPath ?? null,
      ...patch,
    });
  }, [image, onChange]);

  const selectAppCapture = useCallback((captureId: string) => {
    if (!captureId) {
      onChange(null);
      return;
    }
    const capture = appCaptures.find((item) => item.id === captureId);
    if (!capture) return;
    onChange({
      sourceType: "app_capture",
      url: appScreenshotPreviewUrl(capture) ?? "",
      captureId: capture.id,
      sourcePath: capture.sourcePath,
      websitePath: capture.websitePath,
      webPath: capture.webPath,
      fileName: `${capture.id}.png`,
      altText: capture.alt,
      credit: "Catch deterministic app screenshot pipeline",
      fit: "contain",
    });
  }, [appCaptures, onChange]);

  const handleUpload = useCallback(async (
    event: ChangeEvent<HTMLInputElement>
  ) => {
    const file = event.target.files?.[0] ?? null;
    event.target.value = "";
    if (!file) return;
    const dataUrl = await readImageFileAsDataUrl(file);
    onChange({
      sourceType: "upload",
      url: dataUrl,
      fileName: file.name,
      altText: image?.altText ?? "",
      credit: image?.credit ?? "",
      fit: image?.fit ?? "cover",
    });
  }, [image, onChange]);

  return (
    <div className="marketing-image-editor">
      <div className="marketing-image-editor-header">
        <div>
          <strong>Slide image</strong>
          <span>Use approved app screenshot slots when the post references product UI. Uploads and URLs are for sourced non-app imagery.</span>
        </div>
        {image?.url ? (
          <AdminIconButton
            label="Remove slide image"
            onClick={() => onChange(null)}
          >
            <Trash2 size={15} strokeWidth={1.9} />
          </AdminIconButton>
        ) : null}
      </div>
      <div className="marketing-image-controls">
        <SelectField
          className="marketing-field"
          label="App screenshot"
          onChange={selectAppCapture}
          options={[
            {label: "No app screenshot", value: ""},
            ...appCaptures.map((capture) => ({
              label: `${capture.walkthroughStep} / ${capture.surface}`,
              value: capture.id,
            })),
          ]}
          value={selectedCapture?.id ?? ""}
        />
        <FilePickerButton
          accept="image/*"
          className="marketing-file-button"
          icon={<ImagePlus size={15} strokeWidth={1.9} />}
          inputLabel={`Choose image for ${slideId}`}
          onChange={(event) => void handleUpload(event)}
        >
          Choose image
        </FilePickerButton>
        <AdminTextField
          label="Image URL"
          value={image?.sourceType === "url" ? image.url : ""}
          onChange={(value) =>
            value.trim() ?
              updateImage({
                sourceType: "url",
                url: value.trim(),
                captureId: null,
                sourcePath: null,
                websitePath: null,
                webPath: null,
                fileName: null,
              }) :
              onChange(null)}
        />
        <SelectField
          className="marketing-field"
          label="Fit"
          onChange={(value) =>
            updateImage({fit: value as "cover" | "contain"})}
          options={[
            {label: "Cover crop", value: "cover"},
            {label: "Contain", value: "contain"},
          ]}
          value={image?.fit ?? "cover"}
        />
      </div>
      {previewUrl ? (
        <div className="marketing-image-review-row">
          <img
            alt={image?.altText || "Selected slide image"}
            className="marketing-image-thumb"
            src={previewUrl}
          />
          <div className="marketing-image-meta-fields">
            <AdminTextField
              label="Alt text"
              value={image?.altText ?? ""}
              onChange={(value) => updateImage({altText: value})}
            />
            <AdminTextField
              label="Credit / rights note"
              value={image?.credit ?? ""}
              onChange={(value) => updateImage({credit: value})}
            />
            <div className="marketing-image-source-note">
              {image?.sourceType === "app_capture" ?
                `App screenshot slot: ${image.captureId ?? "unknown"}` :
                image?.sourceType === "upload" ?
                `Uploaded file: ${image.fileName ?? "local image"}` :
                "External image URL"}
            </div>
          </div>
        </div>
      ) : (
        <div className="marketing-image-empty">
          <ImagePlus size={15} strokeWidth={1.9} />
          <span>No image attached to this slide.</span>
        </div>
      )}
    </div>
  );
}

function MarketingAudit({
  bridge,
  localDecisions,
}: {
  bridge: MarketingOpsBridge;
  localDecisions: Record<string, AdminRecordMarketingReviewDecisionResponse>;
}) {
  const local = Object.values(localDecisions);
  return (
    <div className="marketing-card-list">
      <AdminPanel
        icon={<Settings2 size={18} strokeWidth={1.9} />}
        title="Generated commands"
        action={bridge.generatedAt}
      >
        <div className="command-stack">
          {Object.entries(bridge.commands).map(([label, command]) => (
            <div className="command-row" key={label}>
              <span>{label}</span>
              <code>{command}</code>
            </div>
          ))}
        </div>
      </AdminPanel>
      <AdminPanel
        icon={<CheckCircle2 size={18} strokeWidth={1.9} />}
        title="Review decisions"
        action={`${bridge.auditTrail.length + local.length} shown`}
      >
        <div className="marketing-audit-list">
          {bridge.auditTrail.map((item) => (
            <div className="marketing-audit-row" key={`${item.targetType}-${item.targetId}`}>
              <strong>{item.targetType}: {item.targetId}</strong>
              <span>{String(item.decision)} by {item.reviewer ?? "unknown"}</span>
              {item.note ? <p>{item.note}</p> : null}
            </div>
          ))}
          {local.map((item) => (
            <div className="marketing-audit-row" key={item.decisionPath}>
              <strong>{item.targetType}: {item.targetId}</strong>
              <span>{item.decisionStatus} saved to {item.decisionPath}</span>
            </div>
          ))}
        </div>
      </AdminPanel>
    </div>
  );
}

function MarketingDraftPreview({draft}: {draft: MarketingContentDraft}) {
  const [isExportingImages, setIsExportingImages] = useState(false);
  const [imageExportMessage, setImageExportMessage] = useState<string | null>(null);
  const [imageExportError, setImageExportError] = useState<string | null>(null);
  const exportBlocker = exportBlockerForDraft(draft);
  const draftType = draftTypeForDraft(draft);
  const downloadHref =
    `data:application/json;charset=utf-8,${encodeURIComponent(JSON.stringify(draft, null, 2))}`;
  const canExportImages = draft.slides.length > 0 && !exportBlocker;

  const downloadImages = useCallback(async () => {
    setIsExportingImages(true);
    setImageExportMessage(null);
    setImageExportError(null);
    try {
      const count = await exportDraftPngSlides(draft);
      setImageExportMessage(`Downloaded ${count} PNG slide${count === 1 ? "" : "s"}.`);
    } catch (error) {
      setImageExportError(
        error instanceof Error ?
          error.message :
          "Unable to export PNG slides."
      );
    } finally {
      setIsExportingImages(false);
    }
  }, [draft]);

  return (
    <div className="marketing-preview-shell">
      <div className="marketing-preview-toolbar">
        <div>
          <strong>{draft.tone.replaceAll("-", " ")} preview</strong>
          <span>{draft.delivery?.currentExport ?? "copy and layout preview"} / no auto-posting</span>
        </div>
        <div className="marketing-preview-actions">
          <AdminLinkButton
            download={`${draft.id}.json`}
            href={downloadHref}
            icon={<Download size={15} strokeWidth={1.9} />}
          >
            Download JSON
          </AdminLinkButton>
          <AdminButton
            disabled={!canExportImages || isExportingImages}
            icon={<Download size={15} strokeWidth={1.9} />}
            onClick={() => void downloadImages()}
            title={
              canExportImages ?
                "Download each carousel slide as a 1080x1350 PNG." :
                exportBlocker ?? "Add slides before exporting images."
            }
          >
            {isExportingImages ? "Exporting" : "Download PNG slides"}
          </AdminButton>
        </div>
      </div>
      {imageExportMessage ? (
        <div className="marketing-export-status">{imageExportMessage}</div>
      ) : null}
      {imageExportError ? (
        <div className="marketing-export-status error">{imageExportError}</div>
      ) : null}
      {exportBlocker && draftType === "event_highlights" ? (
        <div className="marketing-empty-state compact">
          <FileWarning size={16} strokeWidth={1.9} />
          <span>{exportBlocker}</span>
        </div>
      ) : null}
      {exportBlocker && draftType === "feature_explainer" ? (
        <div className="marketing-empty-state compact">
          <FileWarning size={16} strokeWidth={1.9} />
          <span>{exportBlocker}</span>
        </div>
      ) : null}
      <div className="marketing-carousel-preview" aria-label={`${draft.tone} carousel preview`}>
        {draft.slides.map((slide, index) => (
          <article
            className={`marketing-preview-slide ${slide.image?.url ? "has-image" : ""}`}
            key={slide.id}
          >
            <div className="marketing-preview-meta">
              <span>{index + 1}/{draft.slides.length}</span>
              <span>{slide.role}</span>
            </div>
            {slide.image?.url ? (
              <img
                alt={slide.image.altText || ""}
                className="marketing-preview-image"
                src={slide.image.url}
              />
            ) : null}
            <div className="marketing-preview-brand-note">
              Export design: Catch _ logo text, Archivo token headlines, IBM Plex Mono labels, SF body
            </div>
            <div className="marketing-preview-copy">
              <h4>{slide.headline}</h4>
              <p>{slide.body}</p>
            </div>
          </article>
        ))}
      </div>
    </div>
  );
}

const instagramExportSize = {
  width: 1080,
  height: 1350,
} as const;

const headlineFontFamily = "\"Archivo\", ui-sans-serif, system-ui, sans-serif";
const labelFontFamily = "\"IBM Plex Mono\", ui-monospace, SFMono-Regular, Menlo, monospace";
const bodyFontFamily = "-apple-system, BlinkMacSystemFont, \"SF Pro Text\", \"Segoe UI\", sans-serif";

interface CanvasPalette {
  background: string;
  raised: string;
  ink: string;
  muted: string;
  faint: string;
  line: string;
  primary: string;
  primaryInk: string;
  primarySoft: string;
  accent: string;
}

async function exportDraftPngSlides(draft: MarketingContentDraft): Promise<number> {
  if (draft.slides.length === 0) {
    throw new Error("This draft does not have any slides to export.");
  }
  const blocker = exportBlockerForDraft(draft);
  if (blocker) throw new Error(blocker);

  await document.fonts?.ready;
  const palette = readCanvasPalette();
  for (let index = 0; index < draft.slides.length; index += 1) {
    const slide = draft.slides[index];
    const slideImage = slide.image?.url ?
      await loadCanvasImage(slide.image.url, slide.id) :
      null;
    const canvas = renderMarketingSlideCanvas({
      draft,
      index,
      palette,
      slide,
      slideImage,
      totalSlides: draft.slides.length,
    });
    const blob = await canvasToBlob(canvas);
    downloadBlob(
      blob,
      `${sanitizeDownloadName(draft.id)}-${String(index + 1).padStart(2, "0")}-${sanitizeDownloadName(slide.id)}.png`
    );
    await waitForDownloadTick();
  }
  return draft.slides.length;
}

function readCanvasPalette(): CanvasPalette {
  const styles = getComputedStyle(document.documentElement);
  const color = (name: string, fallback: string) =>
    styles.getPropertyValue(name).trim() || fallback;
  return {
    background: color("--catch-color-light-bg", "#F4F4F1"),
    raised: color("--catch-color-light-raised", "#FAFAF8"),
    ink: color("--catch-color-light-ink", "#16140F"),
    muted: color("--catch-color-light-ink2", "#544F47"),
    faint: color("--catch-color-light-ink3", "#9C958A"),
    line: color("--catch-color-light-line2", "rgba(22, 20, 15, 0.14)"),
    primary: color("--catch-color-light-primary", "#16140F"),
    primaryInk: color("--catch-color-light-primary-ink", "#F4F4F1"),
    primarySoft: color("--catch-color-light-primary-soft", "#ECEAE4"),
    accent: color("--catch-activity-singles-mixer-accent", "#D85A6E"),
  };
}

function renderMarketingSlideCanvas({
  draft,
  index,
  palette,
  slide,
  slideImage,
  totalSlides,
}: {
  draft: MarketingContentDraft;
  index: number;
  palette: CanvasPalette;
  slide: MarketingContentDraftSlide;
  slideImage: HTMLImageElement | null;
  totalSlides: number;
}): HTMLCanvasElement {
  const canvas = document.createElement("canvas");
  canvas.width = instagramExportSize.width;
  canvas.height = instagramExportSize.height;
  const ctx = canvas.getContext("2d");
  if (!ctx) throw new Error("Canvas export is not available in this browser.");

  const {width, height} = instagramExportSize;
  const margin = 72;
  const contentWidth = width - margin * 2;
  const hasImage = Boolean(slideImage);

  ctx.fillStyle = palette.background;
  ctx.fillRect(0, 0, width, height);

  ctx.fillStyle = palette.primarySoft;
  ctx.fillRect(0, 0, width, 18);
  ctx.fillStyle = palette.accent;
  ctx.fillRect(0, 0, Math.round(width * ((index + 1) / totalSlides)), 18);

  drawExportHeader(ctx, {
    draft,
    index,
    margin,
    palette,
    slide,
    totalSlides,
    width,
  });

  if (slideImage) {
    drawSlideImage(ctx, {
      image: slideImage,
      fit: slide.image?.fit ?? "cover",
      palette,
      rect: {
        x: margin,
        y: 168,
        width: contentWidth,
        height: 472,
      },
    });
  }

  const role = slide.role.toLowerCase();
  const isCover = role === "cover";
  const isCta = role === "cta";
  const headlineY = hasImage ? 760 : isCover ? 410 : isCta ? 390 : 350;
  const headlineStartSize = hasImage ? isCover ? 76 : 66 : isCover ? 104 : isCta ? 86 : 80;
  const headlineMaxLines = hasImage ? 3 : isCover ? 5 : 4;
  const bodyStartSize = hasImage ? 30 : isCover ? 36 : 34;
  const bodyMaxLines = hasImage ? isCta ? 5 : 4 : isCover ? 4 : isCta ? 6 : 5;

  if (!isCover) {
    drawRoleMarker(ctx, {
      eventOrdinal: slide.role === "event" ?
        draft.slides.slice(0, index + 1).filter((item) => item.role === "event").length :
        null,
      index,
      margin,
      palette,
      slide,
      totalSlides,
      y: hasImage ? 664 : 214,
    });
  }

  const headline = fitTextBlock(ctx, {
    fontFamily: headlineFontFamily,
    fontWeight: 760,
    maxLines: headlineMaxLines,
    maxWidth: contentWidth,
    minSize: 50,
    startSize: headlineStartSize,
    text: slide.headline,
  });
  drawTextBlock(ctx, {
    color: palette.ink,
    fontFamily: headlineFontFamily,
    fontSize: headline.fontSize,
    fontWeight: 760,
    lineHeight: Math.round(headline.fontSize * 1.03),
    lines: headline.lines,
    x: margin,
    y: headlineY,
  });

  const bodyY = headlineY +
    headline.lines.length * Math.round(headline.fontSize * 1.03) +
    44;
  const body = fitTextBlock(ctx, {
    fontFamily: bodyFontFamily,
    fontWeight: 500,
    maxLines: bodyMaxLines,
    maxWidth: contentWidth,
    minSize: 25,
    startSize: bodyStartSize,
    text: slide.body,
  });
  drawTextBlock(ctx, {
    color: palette.muted,
    fontFamily: bodyFontFamily,
    fontSize: body.fontSize,
    fontWeight: 500,
    lineHeight: Math.round(body.fontSize * 1.38),
    lines: body.lines,
    x: margin,
    y: bodyY,
  });

  if (isCta) {
    drawCtaChips(ctx, {
      margin,
      palette,
      y: Math.min(bodyY + body.lines.length * Math.round(body.fontSize * 1.38) + 58, 930),
    });
  }

  drawExportFooter(ctx, {
    draft,
    margin,
    palette,
    slide,
    width,
    y: height - 164,
  });

  return canvas;
}

function drawExportHeader(
  ctx: CanvasRenderingContext2D,
  {
    draft,
    index,
    margin,
    palette,
    slide,
    totalSlides,
    width,
  }: {
    draft: MarketingContentDraft;
    index: number;
    margin: number;
    palette: CanvasPalette;
    slide: MarketingContentDraftSlide;
    totalSlides: number;
    width: number;
  }
) {
  ctx.fillStyle = palette.ink;
  ctx.font = canvasFont(760, 48, headlineFontFamily);
  ctx.textBaseline = "alphabetic";
  ctx.fillText("Catch _", margin, 102);

  const weekLabel = formatExportWeek(draft.weekStart);
  const cityLabel = draft.cityId.replaceAll("-", " ").toUpperCase();
  const meta = `${cityLabel} / ${weekLabel}`;
  ctx.font = canvasFont(700, 20, labelFontFamily);
  ctx.fillStyle = palette.muted;
  ctx.textAlign = "right";
  ctx.fillText(meta, width - margin, 78);
  ctx.fillText(`${index + 1}/${totalSlides} / ${slide.role.toUpperCase()}`, width - margin, 108);
  ctx.textAlign = "left";
}

function drawSlideImage(
  ctx: CanvasRenderingContext2D,
  {
    fit,
    image,
    palette,
    rect,
  }: {
    fit: "cover" | "contain";
    image: HTMLImageElement;
    palette: CanvasPalette;
    rect: {x: number; y: number; width: number; height: number};
  }
) {
  ctx.save();
  roundedRect(ctx, rect.x, rect.y, rect.width, rect.height, 8);
  ctx.clip();
  ctx.fillStyle = palette.raised;
  ctx.fillRect(rect.x, rect.y, rect.width, rect.height);

  const imageRatio = image.naturalWidth / image.naturalHeight;
  const rectRatio = rect.width / rect.height;
  const scale = fit === "contain" ?
    imageRatio > rectRatio ? rect.width / image.naturalWidth : rect.height / image.naturalHeight :
    imageRatio > rectRatio ? rect.height / image.naturalHeight : rect.width / image.naturalWidth;
  const drawWidth = image.naturalWidth * scale;
  const drawHeight = image.naturalHeight * scale;
  const drawX = rect.x + (rect.width - drawWidth) / 2;
  const drawY = rect.y + (rect.height - drawHeight) / 2;
  ctx.drawImage(image, drawX, drawY, drawWidth, drawHeight);
  ctx.restore();

  roundedRect(ctx, rect.x, rect.y, rect.width, rect.height, 8);
  ctx.strokeStyle = palette.line;
  ctx.lineWidth = 2;
  ctx.stroke();
}

function drawRoleMarker(
  ctx: CanvasRenderingContext2D,
  {
    eventOrdinal,
    index,
    margin,
    palette,
    slide,
    totalSlides,
    y,
  }: {
    eventOrdinal: number | null;
    index: number;
    margin: number;
    palette: CanvasPalette;
    slide: MarketingContentDraftSlide;
    totalSlides: number;
    y: number;
  }
) {
  const isEvent = slide.role === "event";
  const label = isEvent ? `PICK ${String(eventOrdinal ?? 1).padStart(2, "0")}` : slide.role.toUpperCase();
  drawPill(ctx, {
    fill: isEvent ? palette.primary : palette.raised,
    label,
    stroke: isEvent ? palette.primary : palette.line,
    textColor: isEvent ? palette.primaryInk : palette.ink,
    x: margin,
    y,
  });
  ctx.font = canvasFont(700, 20, labelFontFamily);
  ctx.fillStyle = palette.faint;
  ctx.fillText(`SLIDE ${index + 1}`, margin + 208, y + 36);
  ctx.fillText(`${totalSlides} TOTAL`, margin + 336, y + 36);
}

function drawCtaChips(
  ctx: CanvasRenderingContext2D,
  {
    margin,
    palette,
    y,
  }: {
    margin: number;
    palette: CanvasPalette;
    y: number;
  }
) {
  drawPill(ctx, {
    fill: palette.primary,
    label: "JOIN WAITLIST",
    stroke: palette.primary,
    textColor: palette.primaryInk,
    x: margin,
    y,
  });
  drawPill(ctx, {
    fill: palette.raised,
    label: "SUBMIT HOST EVENT",
    stroke: palette.line,
    textColor: palette.ink,
    x: margin + 282,
    y,
  });
}

function drawExportFooter(
  ctx: CanvasRenderingContext2D,
  {
    draft,
    margin,
    palette,
    slide,
    width,
    y,
  }: {
    draft: MarketingContentDraft;
    margin: number;
    palette: CanvasPalette;
    slide: MarketingContentDraftSlide;
    width: number;
    y: number;
  }
) {
  ctx.strokeStyle = palette.line;
  ctx.lineWidth = 2;
  ctx.beginPath();
  ctx.moveTo(margin, y);
  ctx.lineTo(width - margin, y);
  ctx.stroke();

  ctx.font = canvasFont(700, 19, labelFontFamily);
  ctx.fillStyle = palette.muted;
  ctx.fillText(draft.tone.replaceAll("-", " ").toUpperCase(), margin, y + 48);

  ctx.font = canvasFont(500, 26, bodyFontFamily);
  ctx.fillStyle = palette.ink;
  const footerText = slide.role === "cta" ?
    "Join the waitlist or submit an event for review." :
    "More city plans and host submissions on Catch.";
  ctx.fillText(footerText, margin, y + 92);
}

function drawPill(
  ctx: CanvasRenderingContext2D,
  {
    fill,
    label,
    stroke,
    textColor,
    x,
    y,
  }: {
    fill: string;
    label: string;
    stroke: string;
    textColor: string;
    x: number;
    y: number;
  }
) {
  ctx.font = canvasFont(700, 20, labelFontFamily);
  const width = Math.ceil(ctx.measureText(label).width + 44);
  const height = 52;
  roundedRect(ctx, x, y, width, height, 26);
  ctx.fillStyle = fill;
  ctx.fill();
  ctx.strokeStyle = stroke;
  ctx.lineWidth = 2;
  ctx.stroke();
  ctx.fillStyle = textColor;
  ctx.textBaseline = "middle";
  ctx.fillText(label, x + 22, y + height / 2 + 1);
  ctx.textBaseline = "alphabetic";
}

function roundedRect(
  ctx: CanvasRenderingContext2D,
  x: number,
  y: number,
  width: number,
  height: number,
  radius: number
) {
  const resolvedRadius = Math.min(radius, width / 2, height / 2);
  ctx.beginPath();
  ctx.moveTo(x + resolvedRadius, y);
  ctx.lineTo(x + width - resolvedRadius, y);
  ctx.quadraticCurveTo(x + width, y, x + width, y + resolvedRadius);
  ctx.lineTo(x + width, y + height - resolvedRadius);
  ctx.quadraticCurveTo(x + width, y + height, x + width - resolvedRadius, y + height);
  ctx.lineTo(x + resolvedRadius, y + height);
  ctx.quadraticCurveTo(x, y + height, x, y + height - resolvedRadius);
  ctx.lineTo(x, y + resolvedRadius);
  ctx.quadraticCurveTo(x, y, x + resolvedRadius, y);
  ctx.closePath();
}

function fitTextBlock(
  ctx: CanvasRenderingContext2D,
  {
    fontFamily,
    fontWeight,
    maxLines,
    maxWidth,
    minSize,
    startSize,
    text,
  }: {
    fontFamily: string;
    fontWeight: number;
    maxLines: number;
    maxWidth: number;
    minSize: number;
    startSize: number;
    text: string;
  }
): {fontSize: number; lines: string[]} {
  for (let size = startSize; size >= minSize; size -= 2) {
    ctx.font = canvasFont(fontWeight, size, fontFamily);
    const lines = wrapText(ctx, text, maxWidth);
    if (lines.length <= maxLines) {
      return {fontSize: size, lines};
    }
  }
  ctx.font = canvasFont(fontWeight, minSize, fontFamily);
  const lines = wrapText(ctx, text, maxWidth).slice(0, maxLines);
  if (lines.length > 0) {
    lines[lines.length - 1] = truncateLine(ctx, lines[lines.length - 1], maxWidth);
  }
  return {fontSize: minSize, lines};
}

function drawTextBlock(
  ctx: CanvasRenderingContext2D,
  {
    color,
    fontFamily,
    fontSize,
    fontWeight,
    lineHeight,
    lines,
    x,
    y,
  }: {
    color: string;
    fontFamily: string;
    fontSize: number;
    fontWeight: number;
    lineHeight: number;
    lines: string[];
    x: number;
    y: number;
  }
) {
  ctx.fillStyle = color;
  ctx.font = canvasFont(fontWeight, fontSize, fontFamily);
  ctx.textBaseline = "alphabetic";
  lines.forEach((line, index) => {
    ctx.fillText(line, x, y + index * lineHeight);
  });
}

function wrapText(
  ctx: CanvasRenderingContext2D,
  text: string,
  maxWidth: number
): string[] {
  const paragraphs = text.split(/\n+/).map((paragraph) => paragraph.trim()).filter(Boolean);
  const lines: string[] = [];
  for (const paragraph of paragraphs) {
    const words = paragraph.split(/\s+/).filter(Boolean);
    let line = "";
    for (const word of words) {
      const candidate = line ? `${line} ${word}` : word;
      if (ctx.measureText(candidate).width <= maxWidth) {
        line = candidate;
        continue;
      }
      if (line) lines.push(line);
      if (ctx.measureText(word).width <= maxWidth) {
        line = word;
      } else {
        const splitWords = splitLongWord(ctx, word, maxWidth);
        lines.push(...splitWords.slice(0, -1));
        line = splitWords[splitWords.length - 1] ?? "";
      }
    }
    if (line) lines.push(line);
  }
  return lines.length > 0 ? lines : [""];
}

function splitLongWord(
  ctx: CanvasRenderingContext2D,
  word: string,
  maxWidth: number
): string[] {
  const chunks: string[] = [];
  let current = "";
  for (const character of word) {
    const candidate = `${current}${character}`;
    if (ctx.measureText(candidate).width <= maxWidth) {
      current = candidate;
      continue;
    }
    if (current) chunks.push(current);
    current = character;
  }
  if (current) chunks.push(current);
  return chunks;
}

function truncateLine(
  ctx: CanvasRenderingContext2D,
  line: string,
  maxWidth: number
): string {
  let current = line;
  while (current.length > 0 && ctx.measureText(`${current}...`).width > maxWidth) {
    current = current.slice(0, -1).trimEnd();
  }
  return current ? `${current}...` : "...";
}

function canvasFont(
  weight: number,
  size: number,
  family: string
): string {
  return `${weight} ${size}px ${family}`;
}

function formatExportWeek(weekStart: string): string {
  const parsed = new Date(`${weekStart}T00:00:00.000Z`);
  if (Number.isNaN(parsed.getTime())) return weekStart;
  return new Intl.DateTimeFormat("en-IN", {
    day: "2-digit",
    month: "short",
  }).format(parsed).toUpperCase();
}

function sanitizeDownloadName(value: string): string {
  return value
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    || "marketing-slide";
}

function readImageFileAsDataUrl(file: File): Promise<string> {
  if (!file.type.startsWith("image/")) {
    return Promise.reject(new Error("Choose an image file."));
  }
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => {
      if (typeof reader.result === "string") {
        resolve(reader.result);
        return;
      }
      reject(new Error("Unable to read the image file."));
    };
    reader.onerror = () => {
      reject(new Error(reader.error?.message ?? "Unable to read the image file."));
    };
    reader.readAsDataURL(file);
  });
}

function loadCanvasImage(src: string, slideId: string): Promise<HTMLImageElement> {
  return new Promise((resolve, reject) => {
    const image = new Image();
    if (!src.startsWith("data:") && !src.startsWith("blob:")) {
      image.crossOrigin = "anonymous";
    }
    image.onload = () => resolve(image);
    image.onerror = () => {
      reject(
        new Error(
          `Unable to load image for ${slideId}. If this is an external URL, upload the image file instead so the PNG export can use it.`
        )
      );
    };
    image.src = src;
  });
}

function canvasToBlob(canvas: HTMLCanvasElement): Promise<Blob> {
  return new Promise((resolve, reject) => {
    try {
      canvas.toBlob((blob) => {
        if (blob) {
          resolve(blob);
          return;
        }
        reject(
          new Error(
            "Unable to create PNG from canvas. If the slide uses an external image URL, upload the image file instead."
          )
        );
      }, "image/png");
    } catch (error) {
      reject(
        error instanceof Error ?
          error :
          new Error("Unable to create PNG from canvas.")
      );
    }
  });
}

function downloadBlob(blob: Blob, fileName: string) {
  const href = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = href;
  link.download = fileName;
  document.body.appendChild(link);
  link.click();
  link.remove();
  window.setTimeout(() => URL.revokeObjectURL(href), 1000);
}

function waitForDownloadTick(): Promise<void> {
  return new Promise((resolve) => {
    window.setTimeout(resolve, 120);
  });
}

function guideNextAction(bridge: MarketingOpsBridge): string {
  if ((bridge.summary.reviewableCandidates ?? 0) === 0) {
    return "Capture or add source-backed candidates.";
  }
  if ((bridge.summary.sourceMissingCandidates ?? 0) > 0) {
    return `${bridge.summary.reviewableCandidates ?? 0} candidates can be reviewed now; add source URLs for ${bridge.summary.sourceMissingCandidates ?? 0} leads to grow the carousel.`;
  }
  if (bridge.summary.approvedCandidates === 0) {
    return "Review source-backed candidates and approve the ones safe for public copy.";
  }
  if (bridge.summary.exportReadyDrafts === 0) {
    return "Review the preview, edit the caption/slides, then mark a draft export ready.";
  }
  return "Export the reviewed packet for manual Instagram upload.";
}

function draftTypeForDraft(
  draft: MarketingContentDraft
): MarketingContentDraftType {
  if (draft.tone === "feature_explainer" || draft.recommendationSetId === "app-feature-media") {
    return "feature_explainer";
  }
  return "event_highlights";
}

function draftLabel(draftType: MarketingContentDraftType): string {
  return draftType === "feature_explainer" ?
    "Feature explainer" :
    "Event highlights";
}

function draftTitle(draft: MarketingContentDraft): string {
  return draft.slides[0]?.headline || draft.id;
}

function nextActionForDraft(draft: MarketingContentDraft): string {
  const blocker = exportBlockerForDraft(draft);
  if (blocker) return blocker;
  if (
    draft.latestDecision?.decision === "export_ready" ||
    draft.status === "export_ready"
  ) {
    return "Export PNG slides for manual upload.";
  }
  if (draft.reviewState === "new") return "Edit copy and run compliance checks.";
  if (draft.reviewState === "needs_changes") return "Resolve requested changes.";
  return "Review and mark export ready.";
}

function exportBlockerForDraft(draft: MarketingContentDraft): string | undefined {
  if (draft.slides.length === 0) {
    return "This draft has no slides yet.";
  }
  if (draftTypeForDraft(draft) === "event_highlights" &&
    !draft.slides.some((slide) => slide.role === "event")) {
    return "This draft has no sourced event slides yet.";
  }
  if (draftTypeForDraft(draft) === "feature_explainer" &&
    !draft.slides.some((slide) => slide.role === "feature")) {
    return "This draft has no feature screenshot slides yet.";
  }
  if (!draft.caption.trim()) return "Add a caption before export review.";
  return undefined;
}
