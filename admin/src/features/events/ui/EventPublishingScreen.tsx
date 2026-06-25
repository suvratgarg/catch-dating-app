import {useMemo, useState} from "react";
import {
  CalendarDays,
  CheckCircle2,
  Clock3,
  Database,
  ExternalLink,
  FileWarning,
  FolderSearch,
  Lock,
  MapPin,
  RefreshCw,
  Save,
  Search,
  Settings2,
  Smartphone,
} from "lucide-react";
import type {
  AdminEventActivityKind,
  AdminEventDetails,
  AdminEventInteractionModel,
  AdminEventListRow,
  AdminExternalEventListRow,
  AdminEventPace,
  ExternalEventImportAction,
  ExternalEventImportExecutionAction,
  ExternalEventImportExecutionPlan,
  ExternalEventImportPlan,
} from "../../../shared/types/adminTypes";
import {
  AdminButton,
  AdminLinkButton,
  AdminTag,
  CheckboxField,
  DataTable,
  EmptyState,
  Panel,
  SearchField,
  SegmentedControl,
  SelectField,
  StateRow,
  TableActionButton,
  TextareaField,
  TextField,
} from "../../../shared/ui/AdminPrimitives";
import {
  type ExternalEventPublishRequest,
  type ExternalEventSupplyFilter,
  type EventPublishingFilter,
  useEventPublishingController,
} from "../controllers/useEventPublishingController";
import {
  countBlockingEventIssues,
  countEventDiffRows,
  eventActivityKindOptions,
  eventInteractionModelOptions,
  eventIsFull,
  eventNeedsSearchBackfill,
  eventPaceOptions,
  externalEventNeedsReview,
  formatEventLabel,
  type EventDiffRow,
  type ExternalEventImportReview,
  type EventPublishingFormState,
  type EventValidationIssue,
} from "../controllers/eventPublishingHelpers";

type EventImportReadinessFilter =
  | "needsAction"
  | "writeReady"
  | "blocked"
  | "waitingReview"
  | "rejected"
  | "all";

interface EventImportReadinessRow {
  key: string;
  title: string;
  platform: string;
  status: ExternalEventImportAction["status"];
  executionStatus: ExternalEventImportExecutionAction["status"] | null;
  targetPath: string;
  candidateId: string;
  sourceEventKey: string;
  canonicalHostId: string;
  startTime: string | null;
  outboundLinkCount: number;
  primaryExternalUrl: string | null;
  blockers: string[];
  validationErrorCount: number;
  sourceActionId: string;
  publishReady: boolean;
}

export function EventPublishingScreen({
  onError,
  onNotice,
}: {
  onError: (message: string | null) => void;
  onNotice: (message: string | null) => void;
}) {
  const controller = useEventPublishingController({onError, onNotice});
  const activeCount = controller.rows.filter((row) =>
    row.status === "active"
  ).length;
  const fullCount = controller.rows.filter(eventIsFull).length;
  const searchIssueCount = controller.rows.filter(eventNeedsSearchBackfill).length;
  const launchCityCount = controller.rows.filter((row) =>
    row.citySlug === "indore" || row.citySlug === "mumbai"
  ).length;
  const externalReviewCount =
    controller.externalRows.filter(externalEventNeedsReview).length;
  const importBlockedCount =
    (controller.supplyReadiness?.importPlan.summary.blocked ?? 0) +
    (controller.supplyReadiness?.executionPlan.summary.blocked ?? 0);
  const readOnlyImportCount =
    controller.supplyReadiness?.importPlan.summary.proposedReadOnlyEvents ??
    controller.supplyReadiness?.importPlan.summary.proposedCreates ??
    0;

  return (
    <div className="workbench-stack">
      <section className="metric-grid" aria-label="Event publishing state">
        <Metric label="Canonical events" value={controller.rows.length} />
        <Metric label="External supply" value={controller.externalRows.length} />
        <Metric label="Launch city events" value={launchCityCount} />
        <Metric label="Active" value={activeCount} />
        <Metric
          label="Full / waitlist"
          tone={fullCount > 0 ? "attention" : "normal"}
          value={fullCount}
        />
        <Metric
          label="Search issues"
          tone={searchIssueCount > 0 ? "attention" : "normal"}
          value={searchIssueCount}
        />
        <Metric
          label="External review"
          tone={externalReviewCount > 0 ? "attention" : "normal"}
          value={externalReviewCount}
        />
        <Metric label="Read-only drafts" value={readOnlyImportCount} />
        <Metric
          label="Import blockers"
          tone={importBlockedCount > 0 ? "attention" : "normal"}
          value={importBlockedCount}
        />
      </section>

      <Panel
        className="span-2"
        icon={<CalendarDays size={18} strokeWidth={1.9} />}
        title="Canonical event directory"
        action={controller.isListLoading ? "Loading" : `${controller.filteredRows.length} shown`}
      >
        <div className="workbench-toolbar">
          <SegmentedControl<EventPublishingFilter>
            ariaLabel="Event filters"
            options={[
              {id: "launchCities", label: "Indore + Mumbai"},
              {id: "upcoming", label: "Upcoming"},
              {id: "all", label: "All"},
              {id: "active", label: "Active"},
              {id: "cancelled", label: "Cancelled"},
              {id: "full", label: "Full"},
              {id: "searchIssues", label: "Search issues"},
            ]}
            value={controller.filter}
            onChange={controller.setFilter}
          />
          <SearchField
            ariaLabel="Search canonical events"
            icon={<Search size={16} strokeWidth={1.8} />}
            onChange={controller.setQuery}
            placeholder="Search event, organizer, id, city, venue"
            value={controller.query}
          />
          <AdminButton
            disabled={controller.isListLoading || controller.isExternalListLoading}
            icon={<RefreshCw size={15} strokeWidth={1.9} />}
            onClick={() => {
              void controller.refreshList();
              void controller.refreshExternalList();
              void controller.refreshSupplyReadiness();
            }}
          >
            Refresh
          </AdminButton>
        </div>
        <EventDirectoryTable
          rows={controller.filteredRows}
          selectedEventId={controller.event?.eventId ?? controller.eventId}
          onSelect={controller.selectEvent}
        />
      </Panel>

      <Panel
        className="span-2"
        icon={<ExternalLink size={18} strokeWidth={1.9} />}
        title="Read-only external event supply"
        action={
          controller.isExternalListLoading ?
            "Loading" :
          `${controller.filteredExternalRows.length} shown`
        }
      >
        <div className="workbench-toolbar">
          <SegmentedControl<ExternalEventSupplyFilter>
            ariaLabel="External event supply filters"
            options={[
              {id: "reviewOpen", label: "Review open"},
              {id: "launchCities", label: "Indore + Mumbai"},
              {id: "upcoming", label: "Upcoming"},
              {id: "public", label: "Public"},
              {id: "active", label: "Active"},
              {id: "cancelled", label: "Cancelled"},
              {id: "all", label: "All"},
            ]}
            value={controller.externalFilter}
            onChange={controller.setExternalFilter}
          />
          <SearchField
            ariaLabel="Search external event supply"
            icon={<Search size={16} strokeWidth={1.8} />}
            onChange={controller.setExternalQuery}
            placeholder="Search source, organizer, candidate, venue"
            value={controller.externalQuery}
          />
        </div>
        <div className="event-supply-review-grid">
          <ExternalEventSupplyTable
            onSelect={controller.selectExternalEvent}
            rows={controller.filteredExternalRows}
            selectedEventId={controller.selectedExternalEventId}
          />
          <div className="event-supply-detail-stack">
            <ExternalEventSupplyDetail event={controller.selectedExternalEvent} />
            <ExternalEventImportReviewPanel
              review={controller.selectedExternalImportReview}
            />
          </div>
        </div>
      </Panel>

      <EventSupplyReadinessPanel
        executionPlan={controller.supplyReadiness?.executionPlan ?? null}
        generatedAt={controller.supplyReadiness?.generatedAt ?? null}
        importPlan={controller.supplyReadiness?.importPlan ?? null}
        isLoading={controller.isSupplyReadinessLoading}
        onPublishExternalEvent={controller.publishExternalEvent}
        publishingExternalActionId={controller.publishingExternalActionId}
        source={controller.supplyReadiness?.source ?? null}
      />

      <Panel
        icon={<Database size={18} strokeWidth={1.9} />}
        title="Event contract"
        action="events"
      >
        <div className="quality-list">
          <StateRow label="Source of truth" value="Cloud Firestore events/{id}" />
          <StateRow
            label="Search/list"
            value="adminListEventDetails + startTime window + adminSearch.tokens"
          />
          <StateRow
            label="Canonical snapshot"
            value={formatDateTime(controller.listGeneratedAt)}
          />
          <StateRow
            label="External snapshot"
            value={formatDateTime(controller.externalListGeneratedAt)}
          />
          <StateRow
            label="Default"
            value="Upcoming active events in Indore and Mumbai"
          />
          <StateRow
            label="External default"
            value="Open review queue for Indore and Mumbai supply"
          />
          <StateRow
            label="Safe writes"
            value="description, photoUrl, format, distance, pace"
          />
          <StateRow
            label="Read-only here"
            value="schedule, capacity, price, status, cancellation"
          />
          <StateRow
            label="App title"
            value="Flutter derives title from time + eventFormat"
          />
          <StateRow
            label="Intake handoff"
            value="Approved external candidates target externalEvents/{id}, not events/{id}"
          />
          <StateRow
            label="External events"
            value="Read-only, outbound-only, no Catch booking/payments/waitlist"
          />
          <StateRow
            label="External publish"
            value="One preflight-ready row at a time through adminPublishExternalEvent"
          />
        </div>
      </Panel>

      <EventEditor
        diffRows={controller.diffRows}
        event={controller.event}
        eventId={controller.eventId}
        form={controller.form}
        isDetailLoading={controller.isDetailLoading}
        isSaving={controller.isSaving}
        validationIssues={controller.validationIssues}
        onEventIdChange={controller.setEventId}
        onFormChange={controller.setForm}
        onLoad={() => void controller.selectEvent(controller.eventId)}
        onSave={() => void controller.save()}
      />
    </div>
  );
}

function EventDirectoryTable({
  onSelect,
  rows,
  selectedEventId,
}: {
  onSelect: (eventId: string) => void;
  rows: AdminEventListRow[];
  selectedEventId: string;
}) {
  if (rows.length === 0) {
    return (
      <EmptyState
        className="workbench-empty"
        icon={<FolderSearch size={16} strokeWidth={1.9} />}
      >
        No canonical events match this filter.
      </EmptyState>
    );
  }
  return (
    <DataTable className="workbench-table">
      <thead>
        <tr>
          <th>Event</th>
          <th>Organizer</th>
          <th>City / venue</th>
          <th>Time</th>
          <th>Status / demand</th>
          <th>Readiness</th>
          <th>Select</th>
        </tr>
      </thead>
      <tbody>
        {rows.map((row) => (
          <tr
            className={selectedEventId === row.eventId ? "selected-row" : ""}
            key={row.eventId}
          >
            <td>
              <div className="row-title">
                <strong>{row.title}</strong>
                <span>{row.eventId}</span>
              </div>
            </td>
            <td>
              <div className="row-title compact">
                <span>{row.organizerName ?? "Unknown organizer"}</span>
                <span>{row.clubId}</span>
              </div>
            </td>
            <td>
              <div className="row-title compact">
                <span>{row.citySlug ?? "No city"}</span>
                <span>{row.meetingPoint || "No meeting point"}</span>
              </div>
            </td>
            <td>{formatDateTime(row.startTime)}</td>
            <td>
              <div className="row-title compact">
                <span>{row.status} / {row.availability ?? "no availability"}</span>
                <span>
                  {row.bookedCount}/{row.capacityLimit} · {formatMoney(row)}
                </span>
              </div>
            </td>
            <td>
              <div className="tag-row">
                <AdminTag tone={row.searchIndexStatus === "indexed" ? "muted" : "neutral"}>
                  {row.searchIndexStatus}
                </AdminTag>
                {eventIsFull(row) ? <AdminTag>full</AdminTag> : null}
              </div>
            </td>
            <td>
              <TableActionButton onClick={() => onSelect(row.eventId)}>
                Open
              </TableActionButton>
            </td>
          </tr>
        ))}
      </tbody>
    </DataTable>
  );
}

function ExternalEventSupplyTable({
  onSelect,
  rows,
  selectedEventId,
}: {
  onSelect: (eventId: string) => void;
  rows: AdminExternalEventListRow[];
  selectedEventId: string | null;
}) {
  if (rows.length === 0) {
    return (
      <EmptyState
        className="workbench-empty"
        icon={<FolderSearch size={16} strokeWidth={1.9} />}
      >
        No read-only external events match this filter.
      </EmptyState>
    );
  }
  return (
    <DataTable className="workbench-table">
      <thead>
        <tr>
          <th>External event</th>
          <th>Organizer</th>
          <th>City / source</th>
          <th>Time</th>
          <th>Status</th>
          <th>Import guard</th>
          <th>Source</th>
          <th>Select</th>
        </tr>
      </thead>
      <tbody>
        {rows.map((row) => (
          <tr
            className={selectedEventId === row.eventId ? "selected-row" : ""}
            key={row.eventId}
          >
            <td>
              <div className="row-title">
                <strong>{row.title}</strong>
                <span>{row.targetPath}</span>
              </div>
            </td>
            <td>
              <div className="row-title compact">
                <span>{row.canonicalHostId}</span>
                <span>compat: {row.compatibilityClubId}</span>
              </div>
            </td>
            <td>
              <div className="row-title compact">
                <span>{row.citySlug ?? "No city"}</span>
                <span>{row.platform} / {row.sourceEventKey}</span>
              </div>
            </td>
            <td>{formatDateTime(row.startTime)}</td>
            <td>
              <div className="tag-row">
                <AdminTag
                  tone={row.publicationStatus === "public" ? "muted" : "neutral"}
                >
                  {row.publicationStatus}
                </AdminTag>
                <AdminTag tone="muted">{row.status}</AdminTag>
                <AdminTag tone="muted">{row.availability}</AdminTag>
              </div>
            </td>
            <td>
              <div className="tag-row">
                <AdminTag
                  tone={row.importPolicyAcknowledged ? "muted" : "neutral"}
                >
                  policy {row.importPolicyAcknowledged ? "ok" : "open"}
                </AdminTag>
                <AdminTag tone={row.ownerSafeCopyReviewed ? "muted" : "neutral"}>
                  copy {row.ownerSafeCopyReviewed ? "ok" : "open"}
                </AdminTag>
                {row.duplicateCandidateCount > 0 ? (
                  <AdminTag tone="muted">
                    {row.duplicateCandidateCount} duplicate
                  </AdminTag>
                ) : null}
              </div>
            </td>
            <td>
              {row.primaryExternalUrl ? (
                <AdminLinkButton
                  href={row.primaryExternalUrl}
                  icon={<ExternalLink size={15} strokeWidth={1.9} />}
                  label={`Open source for ${row.title}`}
                  rel="noreferrer"
                  target="_blank"
                  variant="icon"
                />
              ) : (
                <span className="muted-cell">none</span>
              )}
            </td>
            <td>
              <TableActionButton onClick={() => onSelect(row.eventId)}>
                Inspect
              </TableActionButton>
            </td>
          </tr>
        ))}
      </tbody>
    </DataTable>
  );
}

function ExternalEventSupplyDetail({
  event,
}: {
  event: AdminExternalEventListRow | null;
}) {
  if (!event) {
    return (
      <EmptyState
        className="event-supply-detail workbench-empty"
        icon={<Clock3 size={16} strokeWidth={1.9} />}
      >
        Select an external event to inspect source attribution.
      </EmptyState>
    );
  }

  return (
    <aside
      aria-label={`External event supply detail for ${event.title}`}
      className="event-supply-detail"
    >
      <header className="search-candidate-header">
        <div>
          <div className="intake-eyebrow">{event.targetPath}</div>
          <h3>{event.title}</h3>
        </div>
        <span className={`intake-badge ${
          externalEventNeedsReview(event) ? "" : "ready"
        }`}>
          {externalEventNeedsReview(event) ? "review open" : "reviewed"}
        </span>
      </header>

      <div className="quality-list">
        <StateRow label="Canonical organizer" value={event.canonicalHostId} />
        <StateRow label="Compatibility club" value={event.compatibilityClubId} />
        <StateRow label="City" value={event.citySlug} />
        <StateRow label="Starts" value={formatDateTime(event.startTime)} />
        <StateRow label="Ends" value={formatDateTime(event.endTime)} />
        <StateRow label="Venue" value={event.meetingPoint || null} />
        <StateRow label="Activity" value={formatEventLabel(event.activityKind)} />
        <StateRow
          label="Format"
          value={formatEventLabel(event.interactionModel)}
        />
        <StateRow
          label="Price"
          value={event.priceDisplayText ?? formatExternalMoney(event)}
        />
        <StateRow label="Publication" value={event.publicationStatus} />
      </div>

      <div className="tag-row">
        <AdminTag tone={event.importPolicyAcknowledged ? "muted" : "neutral"}>
          import policy {event.importPolicyAcknowledged ? "ok" : "open"}
        </AdminTag>
        <AdminTag tone={event.ownerSafeCopyReviewed ? "muted" : "neutral"}>
          owner-safe copy {event.ownerSafeCopyReviewed ? "ok" : "open"}
        </AdminTag>
        <AdminTag tone={event.duplicateCandidateCount > 0 ? "neutral" : "muted"}>
          {event.duplicateCandidateCount} duplicate candidates
        </AdminTag>
        <AdminTag tone="muted">{event.availability}</AdminTag>
      </div>

      <div className="intake-source-list">
        <StateRow label="Platform" value={event.platform} />
        <StateRow label="Source key" value={event.sourceEventKey} />
        <StateRow label="Candidate" value={event.candidateId} />
        <StateRow label="Normalized key" value={event.normalizedEventKey} />
        <StateRow label="Primary candidate" value={event.primaryCandidateId} />
        <StateRow label="Review batch" value={event.reviewBatchId} />
        <StateRow label="Reviewer" value={event.reviewer} />
        <StateRow label="Decided" value={event.decidedAt} />
      </div>

      <div className="event-supply-links">
        {event.eventUrl ? (
          <AdminLinkButton
            href={event.eventUrl}
            icon={<ExternalLink size={15} strokeWidth={1.9} />}
            label={`Open external event page for ${event.title}`}
            rel="noreferrer"
            target="_blank"
          >
            Event page
          </AdminLinkButton>
        ) : null}
        {event.sourceUrl && event.sourceUrl !== event.eventUrl ? (
          <AdminLinkButton
            href={event.sourceUrl}
            icon={<ExternalLink size={15} strokeWidth={1.9} />}
            label={`Open source page for ${event.title}`}
            rel="noreferrer"
            target="_blank"
          >
            Source page
          </AdminLinkButton>
        ) : null}
        {event.primaryExternalUrl &&
          event.primaryExternalUrl !== event.eventUrl &&
          event.primaryExternalUrl !== event.sourceUrl ? (
            <AdminLinkButton
              href={event.primaryExternalUrl}
              icon={<ExternalLink size={15} strokeWidth={1.9} />}
              label={`Open primary outbound link for ${event.title}`}
              rel="noreferrer"
              target="_blank"
            >
              Primary outbound
            </AdminLinkButton>
          ) : null}
      </div>
    </aside>
  );
}

function ExternalEventImportReviewPanel({
  review,
}: {
  review: ExternalEventImportReview | null;
}) {
  if (!review) {
    return (
      <EmptyState
        className="event-supply-detail workbench-empty"
        icon={<Clock3 size={16} strokeWidth={1.9} />}
      >
        Select an external event to inspect import eligibility.
      </EmptyState>
    );
  }

  return (
    <aside
      aria-label="External event import eligibility"
      className="event-supply-detail"
    >
      <div className={`quality-row ${importReviewToneClass(review.status)}`}>
        <Lock size={16} strokeWidth={1.9} />
        <div>
          <strong>{review.label}</strong>
          <span>{review.detail}</span>
        </div>
      </div>

      <div className="quality-list">
        <StateRow label="Target" value={review.targetPath} />
        <StateRow label="Import action" value={review.importActionId} />
        <StateRow label="Preflight action" value={review.executionActionId} />
        <StateRow label="Next command" value={review.nextCommand} />
      </div>

      {review.blockers.length > 0 ? (
        <div className="intake-tags">
          {review.blockers.map((blocker) => (
            <span className="intake-tag muted" key={blocker}>
              {blocker.replaceAll("_", " ")}
            </span>
          ))}
        </div>
      ) : (
        <div className="empty-row">
          <CheckCircle2 size={16} strokeWidth={1.9} />
          <span>No deterministic blockers in the current snapshot.</span>
        </div>
      )}
    </aside>
  );
}

function EventSupplyReadinessPanel({
  executionPlan,
  generatedAt,
  importPlan,
  isLoading,
  onPublishExternalEvent,
  publishingExternalActionId,
  source,
}: {
  executionPlan: ExternalEventImportExecutionPlan | null;
  generatedAt: string | null;
  importPlan: ExternalEventImportPlan | null;
  isLoading: boolean;
  onPublishExternalEvent: (
    request: ExternalEventPublishRequest
  ) => Promise<boolean>;
  publishingExternalActionId: string | null;
  source: string | null;
}) {
  const [actionFilter, setActionFilter] =
    useState<EventImportReadinessFilter>("needsAction");
  const [actionQuery, setActionQuery] = useState("");
  const [publishReviewNote, setPublishReviewNote] = useState("");
  const [publishChecklist, setPublishChecklist] = useState(
    initialExternalPublishChecklist
  );
  const publishChecklistComplete = Object.values(publishChecklist)
    .every(Boolean);
  const publishDisabledReason =
    !publishReviewNote.trim() ?
      "Add an external publish review note before publishing." :
    !publishChecklistComplete ?
      "Complete the external publish checklist before publishing." :
    undefined;

  function initialExternalPublishChecklist() {
    return {
      preflightActionReviewed: false,
      outboundLinksReviewed: false,
      noCatchBookingPaymentsWaitlist: false,
      ownerSafeCopyReviewed: false,
    };
  }

  const actionRows = useMemo(
    () => buildImportReadinessRows(importPlan, executionPlan),
    [executionPlan, importPlan]
  );
  const filteredActionRows = useMemo(
    () => filterImportReadinessRows(actionRows, actionFilter, actionQuery),
    [actionFilter, actionQuery, actionRows]
  );
  const visibleActionRows = filteredActionRows.slice(0, 50);
  const actionLabel = isLoading ? "Loading" : importPlan?.policy.status ?? "No plan";

  return (
    <Panel
      className="span-2"
      icon={<Settings2 size={18} strokeWidth={1.9} />}
      title="External import readiness"
      action={actionLabel}
    >
      {importPlan && executionPlan ? (
        <div className="search-candidate-panel">
          <div className="intake-state-grid">
            <StateRow label="Candidates" value={String(importPlan.summary.candidates)} />
            <StateRow label="Source" value={source ?? "unknown"} />
            <StateRow label="Generated" value={formatDateTime(generatedAt)} />
            <StateRow
              label="Read-only drafts"
              value={String(
                importPlan.summary.proposedReadOnlyEvents ??
                  importPlan.summary.proposedCreates
              )}
            />
            <StateRow
              label="Merged links"
              value={String(importPlan.summary.mergedSourceLinks ?? 0)}
            />
            <StateRow label="Write-ready" value={String(importPlan.summary.writeReady)} />
            <StateRow label="Waiting review" value={String(importPlan.summary.waitingReview)} />
            <StateRow label="Blocked" value={String(importPlan.summary.blocked)} />
            <StateRow
              label="Preflight valid"
              value={String(
                executionPlan.summary.projectionValid ??
                  executionPlan.summary.payloadValid
              )}
            />
            <StateRow
              label="Preflight errors"
              value={String(
                executionPlan.summary.projectionInvalidCount ??
                  executionPlan.summary.payloadInvalid
              )}
            />
          </div>

          <div className="quality-row warning">
            <Lock size={16} strokeWidth={1.9} />
            <div>
              <strong>
                {importPlan.policy.writeEnabled ?
                  "Import writes enabled" :
                  "Import writes disabled"}
              </strong>
              <span>{importPlan.policy.reason}</span>
              <span>
                Preflight: {executionPlan.policy.authorityModel} /{" "}
                {executionPlan.policy.reason}
              </span>
            </div>
          </div>

          <div className="intake-tags">
            {importPlan.guardrails.slice(0, 10).map((guardrail) => (
              <span className="intake-tag muted" key={guardrail}>
                {guardrail.replaceAll("_", " ")}
              </span>
            ))}
          </div>

          <div className="intake-section">
            <div className="intake-section-title">Import Action Directory</div>
            <div className="workbench-toolbar">
              <SegmentedControl<EventImportReadinessFilter>
                ariaLabel="External import action filters"
                options={[
                  {id: "needsAction", label: "Needs action"},
                  {id: "writeReady", label: "Write-ready"},
                  {id: "blocked", label: "Blocked"},
                  {id: "waitingReview", label: "Waiting"},
                  {id: "rejected", label: "Rejected"},
                  {id: "all", label: "All"},
                ]}
                value={actionFilter}
                onChange={setActionFilter}
              />
              <SearchField
                ariaLabel="Search import actions"
                icon={<Search size={16} strokeWidth={1.8} />}
                onChange={setActionQuery}
                placeholder="Search title, target, candidate, source"
                value={actionQuery}
              />
            </div>
            <StateRow
              label="Visible rows"
              value={`${visibleActionRows.length} of ${filteredActionRows.length}`}
            />
            <div className="intake-section">
              <div className="intake-section-title">Publish Gates</div>
              <TextareaField
                label="External publish review note"
                onChange={setPublishReviewNote}
                placeholder="Why this reviewed external event can become public read-only supply"
                rows={3}
                value={publishReviewNote}
              />
              <div className="quality-list">
                <CheckboxField
                  checked={publishChecklist.preflightActionReviewed}
                  label="Selected action matches the latest preflight snapshot"
                  onChange={(checked) => setPublishChecklist((current) => ({
                    ...current,
                    preflightActionReviewed: checked,
                  }))}
                />
                <CheckboxField
                  checked={publishChecklist.outboundLinksReviewed}
                  label="Outbound event/source links were reviewed"
                  onChange={(checked) => setPublishChecklist((current) => ({
                    ...current,
                    outboundLinksReviewed: checked,
                  }))}
                />
                <CheckboxField
                  checked={publishChecklist.noCatchBookingPaymentsWaitlist}
                  label="No Catch booking, payments, reservations, or waitlist"
                  onChange={(checked) => setPublishChecklist((current) => ({
                    ...current,
                    noCatchBookingPaymentsWaitlist: checked,
                  }))}
                />
                <CheckboxField
                  checked={publishChecklist.ownerSafeCopyReviewed}
                  label="Owner-safe copy and attribution were reviewed"
                  onChange={(checked) => setPublishChecklist((current) => ({
                    ...current,
                    ownerSafeCopyReviewed: checked,
                  }))}
                />
              </div>
            </div>
            <EventImportReadinessTable
              publishDisabledReason={publishDisabledReason}
              publishingExternalActionId={publishingExternalActionId}
              rows={visibleActionRows}
              onPublish={async (row) => {
                const published = await onPublishExternalEvent({
                  sourceActionId: row.sourceActionId,
                  targetPath: row.targetPath,
                  reviewNote: publishReviewNote,
                  checklist: publishChecklist,
                });
                if (published) {
                  setPublishReviewNote("");
                  setPublishChecklist(initialExternalPublishChecklist());
                }
              }}
            />
          </div>

          <div className="intake-section">
            <div className="intake-section-title">Operator Commands</div>
            <div className="command-stack">
              {Object.entries({
                ...importPlan.commands,
                preflight: executionPlan.commands.preflight,
              }).map(([label, command]) => (
                <div className="command-row" key={`${label}:${command}`}>
                  <span>{label}</span>
                  <code>{command}</code>
                </div>
              ))}
            </div>
          </div>

          <div className="intake-source-list">
            <StateRow
              label="Candidate queue"
              value={importPlan.generatedFrom.externalEventCandidateQueue}
            />
            <StateRow
              label="Import plan"
              value={executionPlan.generatedFrom.externalEventImportPlan}
            />
          </div>
        </div>
      ) : (
        <EmptyState
          className="workbench-empty"
          icon={<FolderSearch size={16} strokeWidth={1.9} />}
        >
          No external import readiness snapshot is available.
        </EmptyState>
      )}
    </Panel>
  );
}

function EventImportReadinessTable({
  onPublish,
  publishDisabledReason,
  publishingExternalActionId,
  rows,
}: {
  onPublish: (row: EventImportReadinessRow) => Promise<void>;
  publishDisabledReason: string | undefined;
  publishingExternalActionId: string | null;
  rows: EventImportReadinessRow[];
}) {
  if (rows.length === 0) {
    return (
      <EmptyState
        className="workbench-empty"
        icon={<CheckCircle2 size={16} strokeWidth={1.9} />}
      >
        No import actions match this readiness filter.
      </EmptyState>
    );
  }

  return (
    <DataTable className="workbench-table">
      <thead>
        <tr>
          <th>Candidate</th>
          <th>Organizer / time</th>
          <th>Status</th>
          <th>Preflight</th>
          <th>Evidence</th>
          <th>Source</th>
          <th>Publish</th>
        </tr>
      </thead>
      <tbody>
        {rows.map((row) => {
          const isPublishing = publishingExternalActionId === row.sourceActionId;
          const rowDisabledReason = importPublishDisabledReason(
            row,
            publishDisabledReason,
            publishingExternalActionId
          );
          return (
            <tr key={row.key}>
              <td>
                <div className="row-title">
                  <strong>{row.title}</strong>
                  <span>{row.targetPath}</span>
                </div>
              </td>
              <td>
                <div className="row-title compact">
                  <span>{row.canonicalHostId}</span>
                  <span>{formatDateTime(row.startTime)}</span>
                </div>
              </td>
              <td>
                <div className="tag-row">
                  <AdminTag tone={row.status === "write_ready" ? "muted" : "neutral"}>
                    {row.status.replaceAll("_", " ")}
                  </AdminTag>
                  <AdminTag tone="muted">{row.platform}</AdminTag>
                </div>
              </td>
              <td>
                <div className="row-title compact">
                  <span>{row.executionStatus?.replaceAll("_", " ") ?? "not preflighted"}</span>
                  <span>
                    {row.validationErrorCount} validation error
                    {row.validationErrorCount === 1 ? "" : "s"}
                  </span>
                </div>
              </td>
              <td>
                <div className="row-title compact">
                  <span>{row.candidateId}</span>
                  <span>
                    {row.blockers.length} blocker
                    {row.blockers.length === 1 ? "" : "s"} ·{" "}
                    {row.outboundLinkCount} link
                    {row.outboundLinkCount === 1 ? "" : "s"}
                  </span>
                </div>
              </td>
              <td>
                {row.primaryExternalUrl ? (
                  <AdminLinkButton
                    href={row.primaryExternalUrl}
                    icon={<ExternalLink size={15} strokeWidth={1.9} />}
                    label={`Open source for ${row.title}`}
                    rel="noreferrer"
                    target="_blank"
                    variant="icon"
                  />
                ) : (
                  <span className="muted-cell">none</span>
                )}
              </td>
              <td>
                <TableActionButton
                  disabled={Boolean(rowDisabledReason)}
                  onClick={() => void onPublish(row)}
                  title={rowDisabledReason}
                >
                  {isPublishing ? "Publishing" : "Publish"}
                </TableActionButton>
              </td>
            </tr>
          );
        })}
      </tbody>
    </DataTable>
  );
}

function importPublishDisabledReason(
  row: EventImportReadinessRow,
  publishDisabledReason: string | undefined,
  publishingExternalActionId: string | null
): string | undefined {
  if (publishingExternalActionId) {
    return publishingExternalActionId === row.sourceActionId ?
      "External event publish is already in progress." :
      "Wait for the current external event publish to finish.";
  }
  if (!row.publishReady) {
    if (row.blockers.length > 0) {
      return `Resolve ${row.blockers.length} import blocker${
        row.blockers.length === 1 ? "" : "s"
      } before publishing.`;
    }
    if (row.validationErrorCount > 0) {
      return `Resolve ${row.validationErrorCount} preflight validation error${
        row.validationErrorCount === 1 ? "" : "s"
      } before publishing.`;
    }
    if (row.status !== "write_ready") {
      return `Import action is ${row.status.replaceAll("_", " ")}.`;
    }
    if (row.executionStatus !== "would_publish_read_only") {
      return `Preflight is ${
        row.executionStatus?.replaceAll("_", " ") ?? "not available"
      }.`;
    }
    return "Regenerate event supply readiness before publishing.";
  }
  return publishDisabledReason;
}

function buildImportReadinessRows(
  importPlan: ExternalEventImportPlan | null,
  executionPlan: ExternalEventImportExecutionPlan | null
): EventImportReadinessRow[] {
  const publishPolicyEnabled =
    importPlan?.policy.writeEnabled === true &&
    executionPlan?.policy.writeEnabled === true &&
    executionPlan.policy.authorityModel === "admin_import_service";
  const executionBySourceActionId = new Map(
    (executionPlan?.actions ?? []).map((action) => [
      action.sourceActionId,
      action,
    ])
  );
  return (importPlan?.actions ?? []).map((action) => {
    const executionAction =
      executionBySourceActionId.get(action.actionId) ?? null;
    const draft = action.proposedReadOnlyEventDraft;
    const primaryLink =
      draft.booking.externalLinks.find((link) => link.primary) ??
      draft.booking.externalLinks[0] ??
      null;
    const blockers = uniqueStrings([
      ...action.blockers,
      ...(executionAction?.blockers ?? []),
      ...(publishPolicyEnabled ? [] : ["external_event_import_policy_disabled"]),
    ]);
    const validationErrorCount =
      (executionAction?.projectionValidation?.errors.length ?? 0) +
      (executionAction?.payloadValidation.errors.length ?? 0);
    const executionStatus = executionAction?.status ?? null;
    return {
      key: action.actionId,
      title: draft.title || draft.eventId,
      platform: action.platform,
      status: action.status,
      executionStatus,
      targetPath: action.targetPath,
      candidateId: action.candidateId,
      sourceEventKey: action.sourceEventKey,
      canonicalHostId: draft.canonicalHostId,
      startTime: draft.startTime,
      outboundLinkCount: draft.booking.externalLinks.length,
      primaryExternalUrl: primaryLink?.url ?? null,
      blockers,
      validationErrorCount,
      sourceActionId: action.actionId,
      publishReady:
        action.status === "write_ready" &&
        executionStatus === "would_publish_read_only" &&
        publishPolicyEnabled &&
        blockers.length === 0 &&
        validationErrorCount === 0 &&
        executionAction?.projectionValidation?.valid === true &&
        executionAction?.payloadValidation.valid === true,
    };
  });
}

function filterImportReadinessRows(
  rows: EventImportReadinessRow[],
  filter: EventImportReadinessFilter,
  query: string
): EventImportReadinessRow[] {
  const tokens = query.toLowerCase().trim().split(/\s+/u).filter(Boolean);
  return rows.filter((row) => {
    if (!importReadinessRowMatchesFilter(row, filter)) return false;
    if (tokens.length === 0) return true;
    const haystack = [
      row.title,
      row.platform,
      row.status,
      row.executionStatus,
      row.targetPath,
      row.candidateId,
      row.sourceEventKey,
      row.canonicalHostId,
      row.startTime,
      row.primaryExternalUrl,
      ...row.blockers,
    ]
      .filter((item): item is string => typeof item === "string")
      .join(" ")
      .toLowerCase();
    return tokens.every((token) => haystack.includes(token));
  });
}

function importReadinessRowMatchesFilter(
  row: EventImportReadinessRow,
  filter: EventImportReadinessFilter
): boolean {
  if (filter === "all") return true;
  if (filter === "writeReady") {
    return row.status === "write_ready" ||
      row.executionStatus === "would_publish_read_only";
  }
  if (filter === "blocked") {
    return row.status === "blocked" ||
      row.executionStatus === "blocked" ||
      row.executionStatus === "projection_invalid" ||
      row.executionStatus === "schema_invalid" ||
      row.blockers.length > 0 ||
      row.validationErrorCount > 0;
  }
  if (filter === "waitingReview") return row.status === "waiting_review";
  if (filter === "rejected") return row.status === "rejected";
  return row.status === "blocked" ||
    row.status === "waiting_review" ||
    row.status === "rejected" ||
    row.executionStatus === "blocked" ||
    row.executionStatus === "projection_invalid" ||
    row.executionStatus === "schema_invalid" ||
    row.blockers.length > 0 ||
    row.validationErrorCount > 0;
}

function uniqueStrings(values: string[]): string[] {
  return Array.from(new Set(values.filter(Boolean))).sort();
}

function importReviewToneClass(status: ExternalEventImportReview["status"]):
  "success" | "warning" | "blocked" {
  if (
    status === "publishedExternal" ||
    status === "preflightReady" ||
    status === "mergedDuplicate"
  ) {
    return "success";
  }
  if (status === "blocked" || status === "rejected") return "blocked";
  return "warning";
}

function EventEditor({
  diffRows,
  event,
  eventId,
  form,
  isDetailLoading,
  isSaving,
  onEventIdChange,
  onFormChange,
  onLoad,
  onSave,
  validationIssues,
}: {
  diffRows: EventDiffRow[];
  event: AdminEventDetails | null;
  eventId: string;
  form: EventPublishingFormState | null;
  isDetailLoading: boolean;
  isSaving: boolean;
  onEventIdChange: (eventId: string) => void;
  onFormChange: (form: EventPublishingFormState | null) => void;
  onLoad: () => void;
  onSave: () => void;
  validationIssues: EventValidationIssue[];
}) {
  const update = <K extends keyof EventPublishingFormState>(
    key: K,
    value: EventPublishingFormState[K]
  ) => {
    if (!form) return;
    onFormChange({...form, [key]: value});
  };
  const saveBlockerCount = countBlockingEventIssues(validationIssues);
  const saveDisabledReason =
    !form ? "Load a canonical event before saving." :
    diffRows.length === 0 ? "No event changes to save." :
    saveBlockerCount > 0 ?
      `Resolve ${saveBlockerCount} save blocker${
        saveBlockerCount === 1 ? "" : "s"
      } before saving.` :
    isDetailLoading ? "Wait for the event to finish loading." :
    isSaving ? "Event save is already in progress." :
    undefined;
  const canSave = !saveDisabledReason;

  return (
    <section className="publishing-editor-grid">
      <Panel
        className="publishing-editor-panel"
        icon={<Save size={18} strokeWidth={1.9} />}
        title="Event editor"
        action={event?.status ?? "No event"}
      >
        <div className="publishing-loadbar">
          <TextField
            label="events/{id}"
            onChange={onEventIdChange}
            value={eventId}
          />
          <AdminButton
            disabled={isDetailLoading}
            icon={<FolderSearch size={15} strokeWidth={1.9} />}
            onClick={onLoad}
          >
            Load
          </AdminButton>
          <AdminButton
            disabled={!canSave}
            icon={<Save size={15} strokeWidth={1.9} />}
            onClick={onSave}
            title={saveDisabledReason}
            variant="primary"
          >
            Save
          </AdminButton>
        </div>

        {form ? (
          <form className="publishing-form" onSubmit={(submitEvent) => {
            submitEvent.preventDefault();
            if (canSave) onSave();
          }}>
            <fieldset className="editor-section">
              <legend>App-Facing Copy</legend>
              <TextareaField
                label="Description"
                onChange={(value) => update("description", value)}
                rows={5}
                value={form.description}
              />
              <TextField
                label="Photo URL"
                onChange={(value) => update("photoUrl", value)}
                value={form.photoUrl}
              />
            </fieldset>

            <fieldset className="editor-section">
              <legend>Format</legend>
              <div className="form-grid three">
                <SelectField
                  label="Activity kind"
                  onChange={(value) =>
                    update("activityKind", value as AdminEventActivityKind)}
                  options={eventActivityKindOptions.map((value) => ({
                    value,
                    label: formatEventLabel(value),
                  }))}
                  value={form.activityKind}
                />
                <SelectField
                  label="Interaction model"
                  onChange={(value) =>
                    update("interactionModel", value as AdminEventInteractionModel)}
                  options={eventInteractionModelOptions.map((value) => ({
                    value,
                    label: formatEventLabel(value),
                  }))}
                  value={form.interactionModel}
                />
                <TextField
                  label="Custom label"
                  onChange={(value) => update("customActivityLabel", value)}
                  value={form.customActivityLabel}
                />
                <TextField
                  inputMode="decimal"
                  label="Distance km"
                  onChange={(value) => update("distanceKm", value)}
                  type="number"
                  value={form.distanceKm}
                />
                <SelectField
                  label="Pace"
                  onChange={(value) => update("pace", value as AdminEventPace)}
                  options={eventPaceOptions.map((value) => ({
                    value,
                    label: formatEventLabel(value),
                  }))}
                  value={form.pace}
                />
                <TextField
                  label="Review note"
                  onChange={(value) => update("reviewNote", value)}
                  value={form.reviewNote}
                />
              </div>
            </fieldset>

            <fieldset className="editor-section">
              <legend>Read-Only Lifecycle</legend>
              <div className="form-grid three">
                <ReadonlyState label="Start" value={formatDateTime(event?.startTime)} />
                <ReadonlyState label="End" value={formatDateTime(event?.endTime)} />
                <ReadonlyState label="Status" value={event?.status ?? null} />
                <ReadonlyState
                  label="Capacity"
                  value={event ? `${event.bookedCount}/${event.capacityLimit}` : null}
                />
                <ReadonlyState
                  label="Waitlist"
                  value={event ? String(event.waitlistedCount) : null}
                />
                <ReadonlyState
                  label="Price"
                  value={event ? formatMoney(event) : null}
                />
              </div>
            </fieldset>
          </form>
        ) : (
          <EmptyState
            className="empty-editor"
            icon={<Clock3 size={16} strokeWidth={1.9} />}
          >
            Load an event document to review canonical fields.
          </EmptyState>
        )}
      </Panel>

      <EventSidePanel
        diffRows={diffRows}
        event={event}
        form={form}
        validationIssues={validationIssues}
      />
    </section>
  );
}

function EventSidePanel({
  diffRows,
  event,
  form,
  validationIssues,
}: {
  diffRows: EventDiffRow[];
  event: AdminEventDetails | null;
  form: EventPublishingFormState | null;
  validationIssues: EventValidationIssue[];
}) {
  return (
    <div className="workbench-stack">
      <Panel
        icon={<FileWarning size={18} strokeWidth={1.9} />}
        title="Save checks"
        action={`${countBlockingEventIssues(validationIssues)} blockers`}
      >
        <IssueList issues={validationIssues} />
      </Panel>

      <Panel
        icon={<Database size={18} strokeWidth={1.9} />}
        title="Before / after diff"
        action={`${countEventDiffRows(diffRows)} changes`}
      >
        <DiffList rows={diffRows} />
      </Panel>

      <Panel
        icon={<Smartphone size={18} strokeWidth={1.9} />}
        title="App event preview"
        action={event?.status ?? "No event"}
      >
        {form && event ? (
          <AppEventPreview event={event} form={form} />
        ) : (
          <EmptyState icon={<Clock3 size={16} strokeWidth={1.9} />}>
            No event loaded
          </EmptyState>
        )}
      </Panel>

      <Panel
        icon={<MapPin size={18} strokeWidth={1.9} />}
        title="Discovery projection"
        action={event?.discovery.availability ?? "No discovery"}
      >
        {event ? (
          <div className="quality-list">
            <StateRow label="City" value={event.discovery.citySlug} />
            <StateRow label="Activity" value={event.discovery.activityKind} />
            <StateRow label="Availability" value={event.discovery.availability} />
            <StateRow
              label="Open spots"
              value={event.discovery.hasOpenSpots === null ?
                null :
                event.discovery.hasOpenSpots ? "yes" : "no"}
            />
            <StateRow
              label="Gates"
              value={[
                event.discovery.inviteRequired ? "invite" : null,
                event.discovery.membershipRequired ? "membership" : null,
                event.discovery.manualApprovalRequired ? "manual" : null,
              ].filter(Boolean).join(", ") || "none"}
            />
            <StateRow
              label="Age"
              value={`${event.discovery.minAge ?? "?"}-${event.discovery.maxAge ?? "?"}`}
            />
            <StateRow label="Search index" value={event.searchIndexStatus} />
          </div>
        ) : (
          <EmptyState icon={<Clock3 size={16} strokeWidth={1.9} />}>
            No event loaded
          </EmptyState>
        )}
      </Panel>

      <Panel
        icon={<CheckCircle2 size={18} strokeWidth={1.9} />}
        title="Mutation boundary"
        action="safe fields"
      >
        <div className="quality-list">
          <StateRow label="Callable" value="adminUpdateEventDetails" />
          <StateRow label="Audit log" value="adminAuditLogs/{id}" />
          <StateRow label="Search rebuild" value="adminSearch projection" />
          <StateRow label="Discovery rebuild" value="eventDiscoveryProjection" />
          <StateRow label="Excluded" value="schedule, policy, cancellation" />
        </div>
      </Panel>
    </div>
  );
}

function AppEventPreview({
  event,
  form,
}: {
  event: AdminEventDetails;
  form: EventPublishingFormState;
}) {
  const label = form.customActivityLabel || formatEventLabel(form.activityKind);
  return (
    <div className="quality-list">
      <StateRow label="Collection" value={`events/${event.eventId}`} />
      <StateRow label="Organizer" value={event.organizerName} />
      <StateRow label="Time" value={formatDateTime(event.startTime)} />
      <StateRow label="Venue" value={event.meetingPoint} />
      <div className="surface-preview">
        <strong>{label}</strong>
        <span>
          {[event.organizerName, event.discovery.citySlug, formatDateTime(event.startTime)]
            .filter(Boolean)
            .join(" · ")}
        </span>
        <span>{form.description || "No description"}</span>
        <div className="tag-row">
          <AdminTag tone="muted">{formatEventLabel(form.interactionModel)}</AdminTag>
          <AdminTag tone="muted">{form.distanceKm} km</AdminTag>
          <AdminTag tone="muted">{formatEventLabel(form.pace)}</AdminTag>
        </div>
      </div>
    </div>
  );
}

function IssueList({issues}: {issues: EventValidationIssue[]}) {
  if (issues.length === 0) {
    return (
      <div className="quality-list">
        <StateRow label="Ready" value="No validation blockers" />
      </div>
    );
  }
  return (
    <div className="roadmap-list">
      {issues.map((issue) => (
        <div className="roadmap-list-item" key={issue.id}>
          <FileWarning size={15} strokeWidth={1.9} />
          <span>
            <strong>{issue.label}:</strong> {issue.detail}
          </span>
        </div>
      ))}
    </div>
  );
}

function DiffList({rows}: {rows: EventDiffRow[]}) {
  if (rows.length === 0) {
    return (
      <div className="quality-list">
        <StateRow label="Changes" value="No unsaved changes" />
      </div>
    );
  }
  return (
    <div className="diff-list">
      {rows.slice(0, 12).map((row) => (
        <div className="diff-row" key={row.field}>
          <strong>{row.field}</strong>
          <span>{row.before}</span>
          <span>{row.after}</span>
        </div>
      ))}
      {rows.length > 12 && (
        <span className="muted-cell">{rows.length - 12} more changes</span>
      )}
    </div>
  );
}

function ReadonlyState({
  label,
  value,
}: {
  label: string;
  value: string | null;
}) {
  return (
    <div className="state-row">
      <span>{label}</span>
      <strong>{value ?? "none"}</strong>
    </div>
  );
}

function Metric({
  label,
  tone = "normal",
  value,
}: {
  label: string;
  tone?: "normal" | "attention";
  value: number;
}) {
  return (
    <article className={`metric-card ${tone === "attention" ? "attention" : ""}`}>
      <span>{label}</span>
      <div className="metric-value">{value}</div>
    </article>
  );
}

function formatDateTime(value: string | null | undefined): string {
  if (!value) return "none";
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return value;
  return new Intl.DateTimeFormat("en-IN", {
    dateStyle: "medium",
    timeStyle: "short",
  }).format(date);
}

function formatMoney(row: {
  currency: string;
  priceInPaise: number;
}): string {
  const amount = row.priceInPaise / 100;
  return new Intl.NumberFormat("en-IN", {
    currency: row.currency,
    maximumFractionDigits: 0,
    style: "currency",
  }).format(amount);
}

function formatExternalMoney(row: {
  currency: string;
  parsedPriceInPaise: number | null;
}): string {
  if (row.parsedPriceInPaise === null) return "none";
  return formatMoney({
    currency: row.currency,
    priceInPaise: row.parsedPriceInPaise,
  });
}
