import {
  CheckCircle2,
  Clock3,
  ExternalLink,
  FileWarning,
  ListChecks,
  RefreshCw,
  Search,
} from "lucide-react";
import {
  AdminButton,
  AdminCard,
  AdminLinkButton,
  AdminPanel,
  AdminStateRow,
  AdminTag,
  AdminTextField,
  AdminTextareaField,
  AlertRow,
  CardHeader,
  EmptyState,
  InlineTextField,
  PageHeader,
  SegmentedControl,
  StatusChip,
  TagList,
} from "../../../../shared/ui/AdminPrimitives";
import {
  eventIntakePublishabilityLabel,
  eventIntakeSourceStatusLabel,
  type EventIntakeDecisionHandler,
} from "../controllers/eventIntakeReviewDecisionHelpers";
import {
  type EventIntakeTab,
  useEventIntakeController,
} from "../controllers/useEventIntakeController";
import {DecisionFooter} from "../../../../shared/ui/ReviewDecisionControls";
import type {
  AdminRecordEventIntakeReviewDecisionResponse,
  EventIntakeBridge,
  EventIntakeCandidate,
  EventIntakeSourceProfile,
  EventIntakeSourceResult,
} from "../../../../shared/types/adminTypes";

const eventIntakeTabs: Array<{id: EventIntakeTab; label: string}> = [
  {id: "setup", label: "Crawl setup"},
  {id: "inbox", label: "Source inbox"},
  {id: "candidates", label: "Event candidates"},
];

export function EventIntakeWorkspace({
  onError,
  onNotice,
}: {
  onError: (message: string | null) => void;
  onNotice: (message: string | null) => void;
}) {
  const {
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
  } = useEventIntakeController({onError, onNotice});

  if (!bridge) {
    return (
      <EmptyState
        className="marketing-empty-state"
        icon={<RefreshCw size={18} strokeWidth={1.9} />}
      >
        {isLoading ? "Loading event intake..." : "Event intake is not available."}
      </EmptyState>
    );
  }

  return (
    <section className="marketing-ops-shell intake-event-workspace">
      <PageHeader
        actions={(
          <AdminButton
            disabled={isLoading}
            icon={<RefreshCw size={15} strokeWidth={1.9} />}
            onClick={() => void loadBridge()}
          >
            {isLoading ? "Refreshing" : "Refresh"}
          </AdminButton>
        )}
        eyebrow={`Event Intake / ${bridge.city.label}`}
        title={`${bridge.city.label} event intake review`}
      >
        Configure source coverage, review raw event leads, and verify deduped
        candidate records before Marketing or external import readiness consumes
        them. These records are decision-only intake artifacts until a separate
        Events import flow publishes read-only external supply.
      </PageHeader>

      <SegmentedControl<EventIntakeTab>
        ariaLabel="Event intake views"
        className="marketing-tabs"
        options={eventIntakeTabs}
        value={activeTab}
        onChange={setActiveTab}
      />

      {activeTab === "setup" ? (
        <div className="marketing-stacked-sections">
          <EventIntakeRunPlanView
            bridge={bridge}
            inFlight={inFlight}
            localDecisions={localDecisions}
            notes={notes}
            onDecision={targetDecision}
            onNoteChange={setNote}
          />
          <EventIntakeSources
            bridge={bridge}
            inFlight={inFlight}
            localDecisions={localDecisions}
            notes={notes}
            onDecision={targetDecision}
            onNoteChange={setNote}
            onSourceChange={updateSource}
          />
        </div>
      ) : activeTab === "inbox" ? (
        <EventIntakeSourceResults
          bridge={bridge}
          inFlight={inFlight}
          localDecisions={localDecisions}
          notes={notes}
          results={bridge.sourceResults}
          onDecision={targetDecision}
          onNoteChange={setNote}
          onResultChange={updateSourceResult}
        />
      ) : (
        <EventIntakeCandidates
          candidates={bridge.eventCandidates}
          bridge={bridge}
          inFlight={inFlight}
          localDecisions={localDecisions}
          notes={notes}
          sourceResultById={sourceResultById}
          onCandidateChange={updateCandidate}
          onDecision={targetDecision}
          onNoteChange={setNote}
        />
      )}
    </section>
  );
}

function EventIntakeSources({
  bridge,
  inFlight,
  localDecisions,
  notes,
  onDecision,
  onNoteChange,
  onSourceChange,
}: {
  bridge: EventIntakeBridge;
  inFlight: Record<string, boolean>;
  localDecisions: Record<string, AdminRecordEventIntakeReviewDecisionResponse>;
  notes: Record<string, string>;
  onDecision: EventIntakeDecisionHandler;
  onNoteChange: (key: string, value: string) => void;
  onSourceChange: (sourceId: string, patch: Partial<EventIntakeSourceProfile>) => void;
}) {
  return (
    <div className="marketing-card-list">
      {bridge.sourceProfiles.map((source) => {
        const key = `source_profile:${source.id}`;
        return (
          <AdminCard key={source.id}>
            <CardHeader
              action={(
                <StatusChip tone={source.riskLevel === "low" ? "success" : "neutral"}>
                  {source.riskLevel} risk
                </StatusChip>
              )}
            >
              <div>
                <div className="intake-eyebrow">{source.type} / {source.status}</div>
                <InlineTextField
                  ariaLabel={`Source label for ${source.id}`}
                  className="marketing-title-input"
                  onChange={(value) =>
                    onSourceChange(source.id, {label: value})}
                  value={source.label}
                />
              </div>
            </CardHeader>
            <AdminTextareaField
              label="Allowed use"
              rows={3}
              value={source.allowedUse}
              onChange={(value) => onSourceChange(source.id, {allowedUse: value})}
            />
            <TagList>
              {(source.items ?? []).map((item) => (
                <AdminTag href={item.url} key={item.url} rel="noreferrer" target="_blank">
                  {item.label}
                </AdminTag>
              ))}
            </TagList>
            <DecisionFooter
              defaultNote={`Source ${source.label} reviewed for event intake use.`}
              edits={source as unknown as Record<string, unknown>}
              inFlight={inFlight[key]}
              localDecision={localDecisions[key]}
              note={notes[key] ?? ""}
              targetId={source.id}
              targetType="source_profile"
              onDecision={onDecision}
              onNoteChange={(value) => onNoteChange(key, value)}
            />
          </AdminCard>
        );
      })}
    </div>
  );
}

function EventIntakeRunPlanView({
  bridge,
  inFlight,
  localDecisions,
  notes,
  onDecision,
  onNoteChange,
}: {
  bridge: EventIntakeBridge;
  inFlight: Record<string, boolean>;
  localDecisions: Record<string, AdminRecordEventIntakeReviewDecisionResponse>;
  notes: Record<string, string>;
  onDecision: EventIntakeDecisionHandler;
  onNoteChange: (key: string, value: string) => void;
}) {
  const key = `run_plan:${bridge.runPlan.id}`;
  return (
    <div className="marketing-grid">
      <AdminPanel
        className="span-2"
        icon={<Clock3 size={18} strokeWidth={1.9} />}
        title={bridge.runPlan.id}
        action={bridge.runPlan.status}
      >
        <div className="marketing-stat-grid">
          <AdminStateRow label="Cadence" value={bridge.runPlan.schedule.cadence} />
          <AdminStateRow label="Publish day" value={bridge.runPlan.schedule.publishDay} />
          <AdminStateRow label="Lookahead" value={`${bridge.runPlan.schedule.lookaheadDays} days`} />
          <AdminStateRow label="Max queries" value={String(bridge.runPlan.budgets.maxQueries)} />
          <AdminStateRow label="Max results" value={String(bridge.runPlan.budgets.maxSourceResults)} />
          <AdminStateRow label="Max candidates" value={String(bridge.runPlan.budgets.maxCandidatePool)} />
        </div>
        <TagList>
          <AdminTag tone="muted">search provider: {bridge.runPlan.automationPolicy.searchProvider}</AdminTag>
          <AdminTag tone="muted">network fetches: {String(bridge.runPlan.automationPolicy.networkFetchesEnabled)}</AdminTag>
          <AdminTag tone="muted">instagram scraping: {String(bridge.runPlan.automationPolicy.instagramScrapingEnabled)}</AdminTag>
        </TagList>
        <DecisionFooter
          defaultNote="Weekly run plan reviewed for query budget and source policy."
          edits={bridge.runPlan as unknown as Record<string, unknown>}
          inFlight={inFlight[key]}
          localDecision={localDecisions[key]}
          note={notes[key] ?? ""}
          targetId={bridge.runPlan.id}
          targetType="run_plan"
          onDecision={onDecision}
          onNoteChange={(value) => onNoteChange(key, value)}
        />
      </AdminPanel>

      <AdminPanel
        icon={<Search size={18} strokeWidth={1.9} />}
        title="Expanded queries"
        action={`${bridge.queryTemplates.length} queries`}
      >
        <div className="marketing-query-list">
          {bridge.queryTemplates.map((query) => (
            <div className="marketing-query" key={`${query.id}-${query.cityLabel}`}>
              <strong>{query.query}</strong>
              <span>{query.intent}</span>
              <span>
                {query.id} / {query.status} / priority {query.priority}
              </span>
              <code>{query.template}</code>
            </div>
          ))}
        </div>
      </AdminPanel>

      <AdminPanel
        className="span-2"
        icon={<ListChecks size={18} strokeWidth={1.9} />}
        title="Event intake contract"
        action={bridge.bridgeSource ?? "unknown"}
      >
        <div className="marketing-stat-grid">
          <AdminStateRow
            label="Dashboard"
            value="eventIntakeDashboards/current"
          />
          <AdminStateRow
            label="Decision writes"
            value="eventIntakeReviewDecisions/{decisionId}"
          />
          <AdminStateRow
            label="Callable read"
            value="adminGetEventIntakeDashboard"
          />
          <AdminStateRow
            label="Callable write"
            value="adminRecordEventIntakeReviewDecision"
          />
          <AdminStateRow
            label="Generated"
            value={formatEventIntakeTimestamp(bridge.generatedAt)}
          />
          <AdminStateRow
            label="Effect"
            value="decision only, no canonical event publish"
          />
        </div>
        <TagList>
          <AdminTag tone="muted">
            downstream: externalEvents import planning
          </AdminTag>
          <AdminTag tone="muted">
            canonical events stay in events/{`{id}`}
          </AdminTag>
          <AdminTag tone="muted">
            generated bridge is private admin supply state
          </AdminTag>
        </TagList>
        <div className="intake-section">
          <div className="intake-section-title">Operator Commands</div>
          <div className="command-stack">
            {Object.entries(bridge.commands).length === 0 ? (
              <div className="command-row">
                <span>none</span>
                <code>publish eventIntakeDashboards/current to enable commands</code>
              </div>
            ) : Object.entries(bridge.commands).map(([label, command]) => (
              <div className="command-row" key={`${label}:${command}`}>
                <span>{label}</span>
                <code>{command}</code>
              </div>
            ))}
          </div>
        </div>
      </AdminPanel>
    </div>
  );
}

function EventIntakeSourceResults({
  bridge,
  results,
  inFlight,
  localDecisions,
  notes,
  onDecision,
  onNoteChange,
  onResultChange,
}: {
  bridge: EventIntakeBridge;
  results: EventIntakeSourceResult[];
  inFlight: Record<string, boolean>;
  localDecisions: Record<string, AdminRecordEventIntakeReviewDecisionResponse>;
  notes: Record<string, string>;
  onDecision: EventIntakeDecisionHandler;
  onNoteChange: (key: string, value: string) => void;
  onResultChange: (resultId: string, patch: Partial<EventIntakeSourceResult>) => void;
}) {
  return (
    <div className="marketing-stacked-sections">
      <AdminPanel
        icon={<Search size={18} strokeWidth={1.9} />}
        title="Source inbox"
        action={`${results.length} raw leads`}
        className="marketing-panel"
      >
        <p className="marketing-help-text">
          This is the raw intake queue from search results and manual references.
          Approving something here only says the lead is worth processing. It is
          not the final event card. The deduped, editable event cards live in
          Candidates.
        </p>
        <TagList>
          <AdminTag>week: {bridge.weekStart}</AdminTag>
          <AdminTag tone="muted">manual Instagram references are leads only</AdminTag>
          <AdminTag tone="muted">candidate count: {bridge.summary.eventCandidates}</AdminTag>
        </TagList>
      </AdminPanel>
      <div className="marketing-card-list">
      {results.map((result) => {
        const key = `source_result:${result.id}`;
        return (
          <AdminCard key={result.id}>
            <CardHeader
              action={(
                <AdminLinkButton
                  href={result.url}
                  icon={<ExternalLink size={15} strokeWidth={1.9} />}
                  label={`Open source for ${result.title}`}
                  rel="noreferrer"
                  target="_blank"
                  variant="icon"
                />
              )}
            >
              <div>
                <div className="intake-eyebrow">{result.sourceLabel} / {result.status}</div>
                <InlineTextField
                  ariaLabel={`Source result title for ${result.id}`}
                  className="marketing-title-input"
                  onChange={(value) =>
                    onResultChange(result.id, {title: value})}
                  value={result.title}
                />
              </div>
            </CardHeader>
            <div className="marketing-stat-grid">
              <AdminStateRow
                label="Source profile"
                value={result.sourceProfileId}
              />
              <AdminStateRow
                label="Query template"
                value={result.queryTemplateId}
              />
              <AdminStateRow
                label="Observed"
                value={formatEventIntakeTimestamp(result.observedAt)}
              />
              <AdminStateRow label="Result type" value={result.resultType} />
            </div>
            <AdminTextareaField
              label="Snippet"
              rows={3}
              value={result.snippet}
              onChange={(value) => onResultChange(result.id, {snippet: value})}
            />
            <AdminTextareaField
              label="Operator notes"
              rows={2}
              value={result.operatorNotes}
              onChange={(value) =>
                onResultChange(result.id, {operatorNotes: value})}
            />
            <TagList>
              {result.riskFlags.map((flag) => (
                <AdminTag key={flag} tone="muted">{flag}</AdminTag>
              ))}
            </TagList>
            <DecisionFooter
              defaultNote={`Source result ${result.title} reviewed.`}
              edits={result as unknown as Record<string, unknown>}
              inFlight={inFlight[key]}
              localDecision={localDecisions[key]}
              note={notes[key] ?? ""}
              targetId={result.id}
              targetType="source_result"
              onDecision={onDecision}
              onNoteChange={(value) => onNoteChange(key, value)}
            />
          </AdminCard>
        );
      })}
      </div>
    </div>
  );
}

function EventIntakeCandidates({
  bridge,
  candidates,
  inFlight,
  localDecisions,
  notes,
  sourceResultById,
  onCandidateChange,
  onDecision,
  onNoteChange,
}: {
  bridge: EventIntakeBridge;
  candidates: EventIntakeCandidate[];
  inFlight: Record<string, boolean>;
  localDecisions: Record<string, AdminRecordEventIntakeReviewDecisionResponse>;
  notes: Record<string, string>;
  sourceResultById: Map<string, EventIntakeSourceResult>;
  onCandidateChange: (candidateId: string, patch: Partial<EventIntakeCandidate>) => void;
  onDecision: EventIntakeDecisionHandler;
  onNoteChange: (key: string, value: string) => void;
}) {
  const reviewable = candidates.filter((candidate) =>
    candidate.publishability !== "lead_needs_source"
  );
  const leads = candidates.filter((candidate) =>
    candidate.publishability === "lead_needs_source"
  );
  const duplicates = bridge.dedupeGroups ?? [];

  return (
    <div className="marketing-stacked-sections">
      <AdminPanel
        icon={<ListChecks size={18} strokeWidth={1.9} />}
        title="Event candidate queue"
        action={`${reviewable.length} reviewable / ${leads.length} need source`}
      >
        <p className="marketing-help-text">
          Candidates are deduped event intake records. Items without a source URL
          are not eligible for marketing shortlists, publication review, or
          canonical import planning until an operator adds a source URL and
          verifies the event. Approval here does not create a canonical Firestore
          event.
        </p>
        <TagList>
          <AdminTag>dedupe groups: {duplicates.length}</AdminTag>
          <AdminTag>lead cards: {candidates.length}</AdminTag>
          <AdminTag tone="muted">duplicate sources collapse into one candidate</AdminTag>
        </TagList>
      </AdminPanel>

      <CandidateSection
        candidates={reviewable}
        emptyText="No sourced candidates are ready for review."
        inFlight={inFlight}
        localDecisions={localDecisions}
        notes={notes}
        sourceResultById={sourceResultById}
        title="Reviewable candidates"
        onCandidateChange={onCandidateChange}
        onDecision={onDecision}
        onNoteChange={onNoteChange}
      />

      <CandidateSection
        approvalDisabledReason="Add a source URL before approving this lead."
        candidates={leads}
        emptyText="No source-missing leads."
        inFlight={inFlight}
        localDecisions={localDecisions}
        notes={notes}
        sourceResultById={sourceResultById}
        title="Leads that need a source"
        onCandidateChange={onCandidateChange}
        onDecision={onDecision}
        onNoteChange={onNoteChange}
      />
    </div>
  );
}

function CandidateSection({
  approvalDisabledReason,
  candidates,
  emptyText,
  inFlight,
  localDecisions,
  notes,
  sourceResultById,
  title,
  onCandidateChange,
  onDecision,
  onNoteChange,
}: {
  approvalDisabledReason?: string;
  candidates: EventIntakeCandidate[];
  emptyText: string;
  inFlight: Record<string, boolean>;
  localDecisions: Record<string, AdminRecordEventIntakeReviewDecisionResponse>;
  notes: Record<string, string>;
  sourceResultById: Map<string, EventIntakeSourceResult>;
  title: string;
  onCandidateChange: (candidateId: string, patch: Partial<EventIntakeCandidate>) => void;
  onDecision: EventIntakeDecisionHandler;
  onNoteChange: (key: string, value: string) => void;
}) {
  return (
    <section className="marketing-section">
      <header className="marketing-section-header">
        <h3>{title}</h3>
        <span>{candidates.length} items</span>
      </header>
      <div className="marketing-card-list">
      {candidates.length === 0 ? (
        <div className="marketing-empty-state compact">
          <CheckCircle2 size={16} strokeWidth={1.9} />
          <span>{emptyText}</span>
        </div>
      ) : candidates.map((candidate) => {
        const key = `event_candidate:${candidate.id}`;
        return (
          <AdminCard key={candidate.id}>
            <CardHeader
              action={(
                <StatusChip tone={candidate.reviewState === "approved" ? "success" : "neutral"}>
                  {candidate.score}
                </StatusChip>
              )}
            >
              <div>
                <div className="intake-eyebrow">
                  {candidate.category} / {candidate.reviewState}
                </div>
                <InlineTextField
                  ariaLabel={`Event candidate title for ${candidate.id}`}
                  className="marketing-title-input"
                  onChange={(value) =>
                    onCandidateChange(candidate.id, {title: value})}
                  value={candidate.title}
                />
              </div>
            </CardHeader>
            <CandidateStatusNotice candidate={candidate} />
            <CandidateProvenance
              candidate={candidate}
              sourceResultById={sourceResultById}
            />
            <div className="marketing-edit-grid">
              <AdminTextField
                label="Venue"
                value={candidate.venue}
                onChange={(value) => onCandidateChange(candidate.id, {venue: value})}
              />
              <AdminTextField
                label="Area"
                value={candidate.neighborhood}
                onChange={(value) =>
                  onCandidateChange(candidate.id, {neighborhood: value})}
              />
              <AdminTextField
                label="Start"
                value={candidate.startDate}
                onChange={(value) =>
                  onCandidateChange(candidate.id, {startDate: value})}
              />
              <AdminTextField
                label="Time"
                value={candidate.time}
                onChange={(value) => onCandidateChange(candidate.id, {time: value})}
              />
              <AdminTextField
                label="Price"
                value={candidate.price}
                onChange={(value) => onCandidateChange(candidate.id, {price: value})}
              />
              <AdminTextField
                label="Source URL"
                value={candidate.sourceUrl ?? ""}
                onChange={(value) =>
                  onCandidateChange(candidate.id, {sourceUrl: value || null})}
              />
            </div>
            <AdminTextareaField
              label="Public description"
              rows={2}
              value={candidate.publicDescription}
              onChange={(value) =>
                onCandidateChange(candidate.id, {publicDescription: value})}
            />
            <AdminTextareaField
              label="Singles-friendly rationale"
              rows={2}
              value={candidate.whySinglesFriendly}
              onChange={(value) =>
                onCandidateChange(candidate.id, {whySinglesFriendly: value})}
            />
            <TagList>
              <AdminTag>
                {eventIntakePublishabilityLabel(candidate.publishability)}
              </AdminTag>
              <AdminTag tone="muted">
                {eventIntakeSourceStatusLabel(candidate.sourceStatus)}
              </AdminTag>
              {candidate.warnings.map((warning) => (
                <AdminTag key={warning} tone="muted">{warning}</AdminTag>
              ))}
              {(candidate.dedupe?.duplicateCandidateIds ?? []).length > 0 ? (
                <AdminTag tone="muted">
                  duplicates hidden: {candidate.dedupe?.duplicateCandidateIds.join(", ")}
                </AdminTag>
              ) : null}
              {candidate.sourceResultIds.map((sourceId) => (
                <AdminTag key={sourceId}>
                  {sourceResultById.get(sourceId)?.sourceLabel ?? sourceId}
                </AdminTag>
              ))}
            </TagList>
            <DecisionFooter
              defaultNote={`Candidate ${candidate.title} reviewed for event intake use.`}
              edits={candidate as unknown as Record<string, unknown>}
              inFlight={inFlight[key]}
              localDecision={localDecisions[key]}
              note={notes[key] ?? ""}
              targetId={candidate.id}
              targetType="event_candidate"
              onDecision={onDecision}
              onNoteChange={(value) => onNoteChange(key, value)}
              approvalDisabledReason={approvalDisabledReason}
            />
          </AdminCard>
        );
      })}
      </div>
    </section>
  );
}

function CandidateProvenance({
  candidate,
  sourceResultById,
}: {
  candidate: EventIntakeCandidate;
  sourceResultById: Map<string, EventIntakeSourceResult>;
}) {
  const sources = candidate.sourceResultIds
    .map((sourceId) => sourceResultById.get(sourceId))
    .filter((source): source is EventIntakeSourceResult => source !== undefined);
  const sourceProfiles = uniqueNonEmpty(
    sources.map((source) => source.sourceProfileId)
  );
  const queryTemplates = uniqueNonEmpty(
    sources.map((source) => source.queryTemplateId)
  );
  const observedAt = uniqueNonEmpty(
    sources.map((source) => formatEventIntakeTimestamp(source.observedAt))
  );
  return (
    <div className="marketing-stat-grid">
      <AdminStateRow
        label="Source results"
        value={candidate.sourceResultIds.length === 0 ?
          "none" :
          candidate.sourceResultIds.join(", ")}
      />
      <AdminStateRow
        label="Source profiles"
        value={sourceProfiles.length === 0 ?
          candidate.sourceLabel :
          sourceProfiles.join(", ")}
      />
      <AdminStateRow
        label="Query templates"
        value={queryTemplates.length === 0 ? "n/a" : queryTemplates.join(", ")}
      />
      <AdminStateRow
        label="Observed"
        value={observedAt.length === 0 ? "n/a" : observedAt.join(", ")}
      />
    </div>
  );
}

function CandidateStatusNotice({candidate}: {candidate: EventIntakeCandidate}) {
  if (candidate.publishability === "lead_needs_source") {
    return (
      <AlertRow
        icon={<FileWarning size={16} strokeWidth={1.9} />}
        title="Lead only"
        tone="warning"
      >
        This candidate has no source URL, so it cannot enter publication review,
        canonical import planning, or marketing shortlist generation yet.
      </AlertRow>
    );
  }
  if (candidate.sourceStatus === "manual_reference_needs_official_verification") {
    return (
      <AlertRow
        icon={<Clock3 size={16} strokeWidth={1.9} />}
        title="Manual reference"
        tone="warning"
      >
        Verify details against an official event, venue, or ticketing page
        before public use.
      </AlertRow>
    );
  }
  return (
    <AlertRow
      icon={<CheckCircle2 size={16} strokeWidth={1.9} />}
      title="Source-backed"
    >
      This candidate can be reviewed for downstream use.
    </AlertRow>
  );
}

function uniqueNonEmpty(values: string[]): string[] {
  return Array.from(new Set(values.filter((value) => value.trim().length > 0)));
}

function formatEventIntakeTimestamp(value: string | null | undefined): string {
  if (!value) return "n/a";
  return value.replace("T", " ").replace(/\.\d{3}Z$/u, "Z");
}
