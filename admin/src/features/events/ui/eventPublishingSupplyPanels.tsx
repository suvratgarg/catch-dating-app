import {useMemo, useState} from "react";
import {
  ArrowLeft,
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
  AdminDiffList,
  AdminDiffRow,
  AdminDetailScreenStack,
  AdminDirectoryScreenStack,
  AdminEditorGrid,
  AdminEditorPanel,
  AdminFieldGrid,
  AdminForm,
  AdminEventSupplyDetail,
  AdminEventSupplyDetailStack,
  AdminEventSupplyEmptyState,
  AdminEventSupplyLinks,
  AdminEventSupplyReviewGrid,
  AdminLinkButton,
  AdminMetricCard,
  AdminMetricGrid,
  AdminRoadmapList,
  AdminRoadmapListItem,
  AdminStatusGrid,
  AdminTableRow,
  AdminTag,
  AdminToolbar,
  AdminWorkbenchStack,
  CheckboxField,
  DataTable,
  EmptyState,
  PageHeader,
  Panel,
  QualityList,
  QualityRow,
  SearchField,
  SegmentedControl,
  SelectField,
  StateRow,
  StatusChip,
  TableActionButton,
  TextareaField,
  TextField,
  AdminCommandRow,
  AdminCommandStack,
  AdminEyebrow,
  AdminEditorSection,
  AdminTagList,
  AdminIntakeSection,
  AdminIntakeSectionTitle,
  AdminIntakeSourceList,
  AdminSearchCandidateHeader,
  AdminSearchCandidatePanel,
  AdminIntakeStateGrid,
  AdminMutedCell,
  AdminPanelActions,
  AdminPublishingLoadbar,
  AdminRowTitle,
  AdminSurfacePreview,
  AdminTagRow,
} from "../../../shared/ui/AdminPrimitives";
import {
  type ExternalEventPublishRequest,
  type ExternalEventSupplyFilter,
  type EventPublishingController,
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
import {isLaunchMarketId} from "../../../shared/config/launchMarkets";
import {useAdminFeedback} from "../../../shared/feedback/AdminFeedbackContext";
import {eventPublishingDirectoryPanels} from "./eventPublishingDirectoryPanels";
import {eventPublishingReadinessPanels} from "./eventPublishingReadinessPanels";
import {eventPublishingEditorPanels} from "./eventPublishingEditorPanels";

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

function EventContractPanel({
  externalListGeneratedAt,
  listGeneratedAt,
}: {
  externalListGeneratedAt: string | null;
  listGeneratedAt: string | null;
}) {
  return (
    <Panel
      icon={<Database size={18} strokeWidth={1.9} />}
      title="Event contract"
      action="events"
    >
      <QualityList>
        <StateRow label="Source of truth" value="Cloud Firestore events/{id}" />
        <StateRow
          label="Search/list"
          value="adminListEventDetails + startTime window + adminSearch.tokens"
        />
        <StateRow
          label="Canonical snapshot"
          value={eventPublishingEditorPanels.formatDateTime(listGeneratedAt)}
        />
        <StateRow
          label="External snapshot"
          value={eventPublishingEditorPanels.formatDateTime(externalListGeneratedAt)}
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
      </QualityList>
    </Panel>
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
        variant="workbench"
        icon={<FolderSearch size={16} strokeWidth={1.9} />}
      >
        No canonical events match this filter.
      </EmptyState>
    );
  }
  return (
    <DataTable ariaLabel="Event directory" variant="workbench">
      <thead>
        <tr>
          <th>Event</th>
          <th>City / venue</th>
          <th>Time</th>
          <th>Status / demand / readiness</th>
          <th>Open</th>
        </tr>
      </thead>
      <tbody>
        {rows.map((row) => (
          <AdminTableRow key={row.eventId} selected={selectedEventId === row.eventId}>
            <td>
              <AdminRowTitle>
                <strong>{row.title}</strong>
                <span>
                  {row.organizerName ?? "Unknown organizer"} · {row.eventId}
                </span>
              </AdminRowTitle>
            </td>
            <td>
              <AdminRowTitle compact>
                <span>{row.citySlug ?? "No city"}</span>
                <span>{row.meetingPoint || "No meeting point"}</span>
              </AdminRowTitle>
            </td>
            <td>{eventPublishingEditorPanels.formatDateTime(row.startTime)}</td>
            <td>
              <AdminRowTitle compact>
                <span>{row.status} / {row.availability ?? "no availability"}</span>
                <span>
                  {row.bookedCount}/{row.capacityLimit} · {eventPublishingEditorPanels.formatMoney(row)}
                </span>
              </AdminRowTitle>
              <AdminTagRow>
                <AdminTag tone={row.searchIndexStatus === "indexed" ? "muted" : "neutral"}>
                  {row.searchIndexStatus}
                </AdminTag>
                {eventIsFull(row) ? <AdminTag>full</AdminTag> : null}
              </AdminTagRow>
            </td>
            <td>
              <TableActionButton onClick={() => onSelect(row.eventId)}>
                Open
              </TableActionButton>
            </td>
          </AdminTableRow>
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
        variant="workbench"
        icon={<FolderSearch size={16} strokeWidth={1.9} />}
      >
        No read-only external events match this filter.
      </EmptyState>
    );
  }
  return (
    <DataTable ariaLabel="External event supply" variant="workbench">
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
          <AdminTableRow key={row.eventId} selected={selectedEventId === row.eventId}>
            <td>
              <AdminRowTitle>
                <strong>{row.title}</strong>
                <span>{row.targetPath}</span>
              </AdminRowTitle>
            </td>
            <td>
              <AdminRowTitle compact>
                <span>{row.canonicalHostId}</span>
                <span>compat: {row.compatibilityClubId}</span>
              </AdminRowTitle>
            </td>
            <td>
              <AdminRowTitle compact>
                <span>{row.citySlug ?? "No city"}</span>
                <span>{row.platform} / {row.sourceEventKey}</span>
              </AdminRowTitle>
            </td>
            <td>{eventPublishingEditorPanels.formatDateTime(row.startTime)}</td>
            <td>
              <AdminTagRow>
                <AdminTag
                  tone={row.publicationStatus === "public" ? "muted" : "neutral"}
                >
                  {row.publicationStatus}
                </AdminTag>
                <AdminTag tone="muted">{row.status}</AdminTag>
                <AdminTag tone="muted">{row.availability}</AdminTag>
              </AdminTagRow>
            </td>
            <td>
              <AdminTagRow>
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
              </AdminTagRow>
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
                <AdminMutedCell>none</AdminMutedCell>
              )}
            </td>
            <td>
              <TableActionButton onClick={() => onSelect(row.eventId)}>
                Inspect
              </TableActionButton>
            </td>
          </AdminTableRow>
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
      <AdminEventSupplyEmptyState icon={<Clock3 size={16} strokeWidth={1.9} />}>
        Select an external event to inspect source attribution.
      </AdminEventSupplyEmptyState>
    );
  }

  return (
    <AdminEventSupplyDetail
      aria-label={`External event supply detail for ${event.title}`}
    >
      <AdminSearchCandidateHeader>
        <div>
          <AdminEyebrow>{event.targetPath}</AdminEyebrow>
          <h3>{event.title}</h3>
        </div>
        <StatusChip tone={externalEventNeedsReview(event) ? "" : "ready"}>
          {externalEventNeedsReview(event) ? "review open" : "reviewed"}
        </StatusChip>
      </AdminSearchCandidateHeader>
      <QualityList>
        <StateRow label="Canonical organizer" value={event.canonicalHostId} />
        <StateRow label="Compatibility club" value={event.compatibilityClubId} />
        <StateRow label="City" value={event.citySlug} />
        <StateRow label="Starts" value={eventPublishingEditorPanels.formatDateTime(event.startTime)} />
        <StateRow label="Ends" value={eventPublishingEditorPanels.formatDateTime(event.endTime)} />
        <StateRow label="Venue" value={event.meetingPoint || null} />
        <StateRow label="Activity" value={formatEventLabel(event.activityKind)} />
        <StateRow
          label="Format"
          value={formatEventLabel(event.interactionModel)}
        />
        <StateRow
          label="Price"
          value={event.priceDisplayText ?? eventPublishingEditorPanels.formatExternalMoney(event)}
        />
        <StateRow label="Publication" value={event.publicationStatus} />
      </QualityList>
      <AdminTagRow>
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
      </AdminTagRow>
      <AdminIntakeSourceList>
        <StateRow label="Platform" value={event.platform} />
        <StateRow label="Source key" value={event.sourceEventKey} />
        <StateRow label="Candidate" value={event.candidateId} />
        <StateRow label="Normalized key" value={event.normalizedEventKey} />
        <StateRow label="Primary candidate" value={event.primaryCandidateId} />
        <StateRow label="Review batch" value={event.reviewBatchId} />
        <StateRow label="Reviewer" value={event.reviewer} />
        <StateRow label="Decided" value={event.decidedAt} />
      </AdminIntakeSourceList>
      <AdminEventSupplyLinks>
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
      </AdminEventSupplyLinks>
    </AdminEventSupplyDetail>
  );
}

function ExternalEventImportReviewPanel({
  review,
}: {
  review: ExternalEventImportReview | null;
}) {
  if (!review) {
    return (
      <AdminEventSupplyEmptyState icon={<Clock3 size={16} strokeWidth={1.9} />}>
        Select an external event to inspect import eligibility.
      </AdminEventSupplyEmptyState>
    );
  }

  return (
    <AdminEventSupplyDetail
      aria-label="External event import eligibility"
    >
      <QualityRow
        tone={eventPublishingReadinessPanels.importReviewToneClass(review.status)}
        icon={<Lock size={16} strokeWidth={1.9} />}>
        <strong>{review.label}</strong>
        <span>{review.detail}</span>
      </QualityRow>
      <QualityList>
        <StateRow label="Target" value={review.targetPath} />
        <StateRow label="Import action" value={review.importActionId} />
        <StateRow label="Preflight action" value={review.executionActionId} />
        <StateRow label="Next command" value={review.nextCommand} />
      </QualityList>
      {review.blockers.length > 0 ? (
        <AdminTagList>
          {review.blockers.map((blocker) => (
            <AdminTag key={blocker} tone="muted">
              {blocker.replaceAll("_", " ")}
            </AdminTag>
          ))}
        </AdminTagList>
      ) : (
        <EmptyState icon={<CheckCircle2 size={16} strokeWidth={1.9} />}>
          No deterministic blockers in the current snapshot.
        </EmptyState>
      )}
    </AdminEventSupplyDetail>
  );
}

export const eventPublishingSupplyPanels = {
  EventContractPanel,
  EventDirectoryTable,
  ExternalEventSupplyTable,
  ExternalEventSupplyDetail,
  ExternalEventImportReviewPanel,
};
