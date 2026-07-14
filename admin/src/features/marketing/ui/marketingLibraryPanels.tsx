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
  AdminCardList,
  AdminIconButton,
  AdminLinkButton,
  AdminPanel,
  AdminStateRow,
  AdminStatGrid,
  AdminTextareaField,
  AdminTextField,
  AlertRow,
  CardHeader,
  EmptyState,
  QualityRow,
  SegmentedControl,
  SelectableCardButton,
  StatusChip,
  AdminCommandRow,
  AdminCommandStack,
  AdminEyebrow,
  AdminFeatureDropCaptureThumb,
  AdminFeatureDropControlGrid,
  AdminFeatureDropFeatureEditor,
  AdminFeatureDropFeatureList,
  AdminFeatureDropPreviewCard,
  AdminFeatureDropPreviewGrid,
  AdminFeatureDropWideField,
  AdminMarketingExportStatus,
  AdminMarketingAuditList,
  AdminMarketingAuditRow,
  AdminMarketingAppCapturePreview,
  AdminMarketingAppMediaPaths,
  AdminMarketingBrandContract,
  AdminMarketingBrandContractItem,
  AdminMarketingComplianceList,
  AdminMarketingFeatureShotCard,
  AdminMarketingFeatureShotGrid,
  AdminMarketingFilePickerButton,
  AdminMarketingDeliverable,
  AdminMarketingGuideLayout,
  AdminMarketingHelpText,
  AdminMarketingCardLink,
  AdminMarketingCarouselPreview,
  AdminMarketingEventLibraryGrid,
  AdminMarketingImageControls,
  AdminMarketingImageEditor,
  AdminMarketingImageEditorHeader,
  AdminMarketingImageEmpty,
  AdminMarketingImageMetaFields,
  AdminMarketingImageReviewRow,
  AdminMarketingImageSourceNote,
  AdminMarketingImageThumb,
  AdminMarketingOpsShell,
  AdminMarketingPreviewActions,
  AdminMarketingPreviewBrandNote,
  AdminMarketingPreviewCopy,
  AdminMarketingPreviewImage,
  AdminMarketingPreviewMeta,
  AdminMarketingPreviewShell,
  AdminMarketingPreviewSlide,
  AdminMarketingPreviewToolbar,
  AdminMarketingLibraryCard,
  AdminMarketingMediaCard,
  AdminMarketingMediaGrid,
  AdminMarketingNewPostCard,
  AdminMarketingNewPostGrid,
  AdminMarketingRecommendationItem,
  AdminMarketingRecommendationList,
  AdminMarketingSelectField,
  AdminMarketingSlideEditor,
  AdminMarketingSlideEditorTopline,
  AdminMarketingSlideList,
  AdminMarketingStackedSections,
  AdminMarketingStudioActions,
  AdminMarketingBoardColumn,
  AdminMarketingBoardList,
  AdminMarketingPostBoard,
  AdminMarketingPostTypeBadge,
  AdminMarketingStudioFilterTabs,
  AdminMarketingStudioHeader,
  AdminMarketingStudioNav,
  AdminMarketingStudioStack,
  AdminMarketingStudioSummary,
  AdminMarketingStudioSummaryItem,
  AdminMarketingTabs,
  AdminMarketingComposer,
  AdminMarketingComposerBackButton,
  AdminMarketingComposerFooter,
  AdminMarketingComposerHeader,
  AdminMarketingPickerList,
  AdminMarketingPickerRow,
  AdminMarketingStepChip,
  AdminMarketingStepLayout,
  AdminMarketingStepStrip,
  AdminQueryList,
  AdminQueryRow,
  AdminTag,
  DecisionFooter,
  TagList,
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
  type MarketingOpsController,
  type MarketingStudioTab,
  type MarketingTypeFilter,
  useMarketingOpsController,
} from "../controllers/useMarketingOpsController";
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
import {marketingComposerPanels} from "./marketingComposerPanels";
import {marketingWorkflowPanels} from "./marketingWorkflowPanels";
import {marketingPreviewPanels} from "./marketingPreviewPanels";

const studioTabs: Array<{id: MarketingStudioTab; label: string}> = [
  {id: "posts", label: "Posts"},
  {id: "events", label: "Events"},
  {id: "media", label: "Media"},
  {id: "activity", label: "Activity"},
];

const typeFilters: Array<{id: MarketingTypeFilter; label: string}> = [
  {id: "all", label: "All"},
  {id: "event_highlights", label: "Event highlights"},
  {id: "feature_explainer", label: "Feature explainers"},
];

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
    <AdminMarketingStudioStack>
      <AdminPanel
        icon={<Library size={18} strokeWidth={1.9} />}
        title="Verified event pool"
        action={`${verifiedEvents.length} usable`}
      >
        <AdminMarketingHelpText>
          Marketing can curate approved event lead records here. Crawl setup,
          source inbox triage, event editing, canonical imports, and
          verification actions stay in Intake, Events, and Organizers.
        </AdminMarketingHelpText>
        <AdminMarketingEventLibraryGrid>
          {verifiedEvents.map((event) => (
            <AdminMarketingLibraryCard
              key={event.id}
              eyebrow={`${event.category} / ${event.reviewState}`}
              title={event.title}
              description={event.publicDescription}
              action={event.sourceUrl ? (
                <AdminMarketingCardLink
                  href={event.sourceUrl}
                  icon={<ExternalLink size={15} strokeWidth={1.9} />}
                  rel="noreferrer"
                  target="_blank"
                >
                  Source
                </AdminMarketingCardLink>
              ) : null}
            >
              <TagList>
                <AdminTag>{event.venue}</AdminTag>
                <AdminTag>{event.neighborhood}</AdminTag>
                <AdminTag>{event.startDate}</AdminTag>
                <AdminTag tone="muted">{event.price}</AdminTag>
              </TagList>
            </AdminMarketingLibraryCard>
          ))}
          {verifiedEvents.length === 0 ? (
            <EmptyState
              compact variant="marketing"
              icon={<FileWarning size={16} strokeWidth={1.9} />}
            >
              No verified events are currently available.
            </EmptyState>
          ) : null}
        </AdminMarketingEventLibraryGrid>
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
    </AdminMarketingStudioStack>
  );
}

function MarketingMediaLibrary({
  media,
}: {
  media: MarketingAppFeatureMedia | null;
}) {
  if (!media) return <MarketingAppFeatureMediaView media={media} />;
  return (
    <AdminMarketingStudioStack>
      <AdminPanel
        icon={<ImagePlus size={18} strokeWidth={1.9} />}
        title="Media library"
        action={media.status.replaceAll("_", " ")}
      >
        <AdminMarketingHelpText>
          App screenshot inventory for feature explainers. These assets come
          from the deterministic app media pipeline.
        </AdminMarketingHelpText>
        <AdminStatGrid>
          <AdminStateRow
            label="Active"
            value={`${media.summary.activeCaptures}/${media.summary.totalCaptures}`}
          />
          <AdminStateRow label="Member" value={String(media.summary.memberCaptures)} />
          <AdminStateRow label="Host" value={String(media.summary.hostCaptures)} />
        </AdminStatGrid>
      </AdminPanel>
      <AdminMarketingMediaGrid>
        {media.captures.map((capture) => {
          const previewUrl = appScreenshotPreviewUrl(capture);
          return (
            <AdminMarketingMediaCard
              key={capture.id}
              description={capture.caption}
              eyebrow={`${capture.audience} / ${capture.walkthroughStep}`}
              previewAlt={capture.alt}
              previewFallback={
                <EmptyState
                  compact variant="marketing"
                  icon={<FileWarning size={16} strokeWidth={1.9} />}
                >
                  No preview
                </EmptyState>
              }
              previewSrc={previewUrl}
              title={capture.surface}
            >
              <TagList>
                <StatusChip>{capture.status}</StatusChip>
                <StatusChip tone="muted">
                  {capture.assetState.replaceAll("_", " ")}
                </StatusChip>
              </TagList>
            </AdminMarketingMediaCard>
          );
        })}
      </AdminMarketingMediaGrid>
      <AdminPanel
        icon={<Settings2 size={18} strokeWidth={1.9} />}
        title="Media automation"
        action={media.sourceDocs.pipelineDoc}
      >
        <AdminCommandStack>
          {Object.entries(media.commands).map(([label, command]) => (
            <AdminCommandRow key={label}>
              <span>{label}</span>
              <code>{command}</code>
            </AdminCommandRow>
          ))}
        </AdminCommandStack>
      </AdminPanel>
      <AdminPanel
        icon={<Lock size={18} strokeWidth={1.9} />}
        title="Direct Instagram publishing"
        action="Backend required"
      >
        <QualityRow tone="warning" icon={<Clock3 size={16} strokeWidth={1.9} />}>
          <strong>Not a browser-only action</strong>
          <span>
            The admin can approve drafts now. Token handling, hosted assets,
            retries, and publish audit logs still need a backend job.
          </span>
        </QualityRow>
      </AdminPanel>
      <marketingWorkflowPanels.MarketingFeatureDropView appCaptures={media.captures} />
    </AdminMarketingStudioStack>
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
    <AdminMarketingNewPostGrid>
      <AdminMarketingNewPostCard
        actionLabel="Create draft"
        accent="event"
        description={`${bridge.summary.approvedCandidates} approved marketing event leads can seed the first draft.`}
        disabled={Boolean(inFlight[eventCreateKey])}
        label="Event highlights"
        meta="Weekly verified event carousel"
        onClick={() => void onCreateDraft("event_highlights")}
      />
      <AdminMarketingNewPostCard
        actionLabel="Create draft"
        accent="feature"
        description={`${bridge.appFeatureMedia?.summary.activeCaptures ?? 0} active app screenshots available.`}
        disabled={Boolean(inFlight[featureCreateKey])}
        label="Feature explainer"
        meta="Product screenshot carousel"
        onClick={() => void onCreateDraft("feature_explainer")}
      />
      <AdminMarketingNewPostCard
        actionLabel="Unavailable"
        accent="soon"
        description="Needs organizer profile copy, rights policy, and claim-state routing."
        disabled
        label="Organizer spotlight"
        meta="Soon"
      />
      <AdminMarketingNewPostCard
        actionLabel="Unavailable"
        accent="soon"
        description="Needs a canonical hosted event detail contract before creation."
        disabled
        label="Event spotlight"
        meta="Soon"
      />
    </AdminMarketingNewPostGrid>
  );
}

function MarketingGuide({bridge}: {bridge: MarketingOpsBridge}) {
  const recommendedDraft = bridge.contentDrafts.find((draft) =>
    draft.tone === "singles-friendly"
  ) ?? bridge.contentDrafts[0] ?? null;
  const recommendedSet = bridge.recommendationSets.find((set) =>
    set.tone === "singles-friendly"
  ) ?? bridge.recommendationSets[0] ?? null;
  const nextAction = marketingPreviewPanels.guideNextAction(bridge);

  return (
    <AdminMarketingGuideLayout>
      <AdminPanel
        span={2}
        icon={<Megaphone size={18} strokeWidth={1.9} />}
        title="What this produces"
        action="Manual export"
      >
        <AdminMarketingDeliverable>
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
        </AdminMarketingDeliverable>
      </AdminPanel>

      <AdminPanel
        icon={<ListChecks size={18} strokeWidth={1.9} />}
        title="Current state"
        action={bridge.summary.status}
      >
        <AdminStatGrid>
          <AdminStateRow label="Source results" value={String(bridge.summary.sourceResults)} />
          <AdminStateRow label="Reviewable candidates" value={String(bridge.summary.reviewableCandidates ?? 0)} />
          <AdminStateRow label="Needs source" value={String(bridge.summary.sourceMissingCandidates ?? 0)} />
          <AdminStateRow label="Dedupe groups" value={String(bridge.summary.duplicateGroups ?? 0)} />
          <AdminStateRow label="Shortlists" value={String(bridge.summary.recommendationSets)} />
          <AdminStateRow label="Export-ready" value={String(bridge.summary.exportReadyDrafts)} />
        </AdminStatGrid>
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
        <AdminMarketingHelpText>
          Candidates are reviewed marketing event leads, not canonical Firestore
          event documents. The same candidate may be reused in multiple tone
          variants, but it should appear only once in the candidate queue after
          dedupe.
        </AdminMarketingHelpText>
        <AdminQueryList>
          {(recommendedSet?.items ?? []).map((item) => (
            <AdminQueryRow key={item.id}>
              <strong>{item.rank}. {item.title}</strong>
              <span>{item.neighborhood} / {publishabilityLabel(item.publishability)}</span>
            </AdminQueryRow>
          ))}
          {(recommendedSet?.items.length ?? 0) === 0 ? (
            <EmptyState
              compact variant="marketing"
              icon={<FileWarning size={16} strokeWidth={1.9} />}
            >
              No sourced events are eligible for this shortlist yet.
            </EmptyState>
          ) : null}
        </AdminQueryList>
      </AdminPanel>

      {recommendedDraft ? (
        <AdminPanel
          span={2}
          icon={<Sparkles size={18} strokeWidth={1.9} />}
          title="Post preview"
          action={recommendedDraft.aspectRatio}
        >
          <marketingPreviewPanels.MarketingDraftPreview draft={recommendedDraft} />
        </AdminPanel>
      ) : null}
    </AdminMarketingGuideLayout>
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
    <AdminMarketingStackedSections>
      <AdminPanel
        icon={<Sparkles size={18} strokeWidth={1.9} />}
        title="Shortlist variants"
        action="Choose one direction"
      >
        <AdminMarketingHelpText>
          These are alternate editorial treatments built from the same reviewed
          candidate pool. Singles-friendly is the default for third-party
          events. Singles-social should stay blocked unless the source
          explicitly says the event is for singles, dating, or mixers.
        </AdminMarketingHelpText>
      </AdminPanel>
      <AdminCardList>
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
              <AdminEyebrow>{set.tone} / {set.status}</AdminEyebrow>
              <h3>{set.title}</h3>
            </div>
          </CardHeader>
          <AdminMarketingHelpText>{set.explanation}</AdminMarketingHelpText>
          {set.status.startsWith("blocked") ? (
            <AlertRow
              icon={<FileWarning size={16} strokeWidth={1.9} />}
              title="Variant blocked"
              tone="warning"
            >
              No sourced candidates currently match this tone.
            </AlertRow>
          ) : null}
          <AdminMarketingRecommendationList>
            {set.items.map((item) => {
              const key = `recommendation_item:${item.id}`;
              return (
                <AdminMarketingRecommendationItem key={item.id}>
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
                </AdminMarketingRecommendationItem>
              );
            })}
          </AdminMarketingRecommendationList>
        </AdminCard>
      ))}
    </AdminCardList>
    </AdminMarketingStackedSections>
  );
}

function MarketingAppFeatureMediaView({
  media,
}: {
  media: MarketingAppFeatureMedia | null;
}) {
  if (!media) {
    return (
      <AdminCardList>
        <AdminPanel
          span={2}
          icon={<FileWarning size={18} strokeWidth={1.9} />}
          title="App media pipeline"
          action="Not generated"
        >
          <EmptyState
            compact variant="marketing"
            icon={<FileWarning size={16} strokeWidth={1.9} />}
          >
            The marketing ops bridge does not include app screenshot metadata.
            Regenerate it from the event-guide script to attach the existing
            screenshot capture manifest.
          </EmptyState>
        </AdminPanel>
      </AdminCardList>
    );
  }

  return (
    <AdminMarketingStackedSections>
      <AdminPanel
        icon={<ImagePlus size={18} strokeWidth={1.9} />}
        title="App screenshot slots"
        action={media.status.replaceAll("_", " ")}
      >
        <AdminMarketingHelpText>
          These slots come from the existing deterministic app media pipeline.
          Use this inventory for app-feature carousel imagery instead of
          hand-authored screenshots.
        </AdminMarketingHelpText>
        <AdminStatGrid>
          <AdminStateRow
            label="Active"
            value={`${media.summary.activeCaptures}/${media.summary.totalCaptures}`}
          />
          <AdminStateRow label="Member" value={String(media.summary.memberCaptures)} />
          <AdminStateRow label="Host" value={String(media.summary.hostCaptures)} />
        </AdminStatGrid>
      </AdminPanel>
      <AdminPanel
        icon={<Settings2 size={18} strokeWidth={1.9} />}
        title="Existing automation"
        action={media.sourceDocs.pipelineDoc}
      >
        <AdminCommandStack>
          {Object.entries(media.commands).map(([label, command]) => (
            <AdminCommandRow key={label}>
              <span>{label}</span>
              <code>{command}</code>
            </AdminCommandRow>
          ))}
        </AdminCommandStack>
      </AdminPanel>
      <AdminPanel
        icon={<Lock size={18} strokeWidth={1.9} />}
        title="Direct Instagram publishing"
        action="Backend required"
      >
        <QualityRow icon={<CheckCircle2 size={16} strokeWidth={1.9} />}>
          <strong>Feasible without operator downloads</strong>
          <span>
            The backend can publish from approved hosted assets after the
            Catch Instagram professional account is connected and approved.
          </span>
        </QualityRow>
        <QualityRow tone="warning" icon={<Clock3 size={16} strokeWidth={1.9} />}>
          <strong>Not a browser-only action</strong>
          <span>
            Instagram publishing uses container creation and publish calls, so
            the admin should approve a draft while a server job owns token
            handling, public asset URLs, retries, and audit logging.
          </span>
        </QualityRow>
      </AdminPanel>
      <AdminCardList>
        {media.captures.map((capture) => {
          const previewUrl = appScreenshotPreviewUrl(capture);
          return (
            <AdminCard key={capture.id}>
              <CardHeader
                action={(
                  <StatusChip tone={capture.assetState === "website_synced" ? "ready" : ""}>
                    {capture.assetState.replaceAll("_", " ")}
                  </StatusChip>
                )}
              >
                <div>
                  <AdminEyebrow>
                    {capture.audience} / {capture.walkthroughStep}
                  </AdminEyebrow>
                  <h3>{capture.surface}</h3>
                </div>
              </CardHeader>
              {previewUrl ? (
                <AdminMarketingAppCapturePreview
                  alt={capture.alt}
                  src={previewUrl}
                />
              ) : (
                <EmptyState
                  compact variant="marketing"
                  icon={<FileWarning size={16} strokeWidth={1.9} />}
                >
                  No preview asset found for this slot.
                </EmptyState>
              )}
              <AdminMarketingHelpText>{capture.caption}</AdminMarketingHelpText>
              <TagList>
                <StatusChip>{capture.status}</StatusChip>
                <StatusChip>{capture.device}</StatusChip>
                {capture.captureId ? (
                  <StatusChip>{capture.captureId}</StatusChip>
                ) : null}
              </TagList>
              <AdminMarketingAppMediaPaths
                sourcePath={capture.sourcePath}
                webPath={capture.webPath}
                websitePath={capture.websitePath}
              />
            </AdminCard>
          );
        })}
      </AdminCardList>
    </AdminMarketingStackedSections>
  );
}

export const marketingLibraryPanels = {
  MarketingEventLibrary,
  MarketingMediaLibrary,
  MarketingNewPost,
  MarketingGuide,
  MarketingRecommendations,
  MarketingAppFeatureMediaView,
};
