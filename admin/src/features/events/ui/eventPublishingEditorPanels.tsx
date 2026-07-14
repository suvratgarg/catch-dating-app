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
import {eventPublishingSupplyPanels} from "./eventPublishingSupplyPanels";
import {eventPublishingReadinessPanels} from "./eventPublishingReadinessPanels";

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
    <AdminEditorGrid>
      <AdminEditorPanel
        icon={<Save size={18} strokeWidth={1.9} />}
        title="Event editor"
        action={event?.status ?? "No event"}
      >
        <AdminPublishingLoadbar>
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
        </AdminPublishingLoadbar>

        {form ? (
          <AdminForm variant="publishing" onSubmit={(submitEvent) => {
            submitEvent.preventDefault();
            if (canSave) onSave();
          }}>
            <AdminEditorSection>
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
            </AdminEditorSection>

            <AdminEditorSection>
              <legend>Format</legend>
              <AdminFieldGrid columns={3}>
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
              </AdminFieldGrid>
            </AdminEditorSection>

            <AdminEditorSection>
              <legend>Read-Only Lifecycle</legend>
              <AdminFieldGrid columns={3}>
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
              </AdminFieldGrid>
            </AdminEditorSection>
          </AdminForm>
        ) : (
          <EmptyState
            variant="editor"
            icon={<Clock3 size={16} strokeWidth={1.9} />}
          >
            Load an event document to review canonical fields.
          </EmptyState>
        )}
      </AdminEditorPanel>

      <EventSidePanel
        diffRows={diffRows}
        event={event}
        form={form}
        validationIssues={validationIssues}
      />
    </AdminEditorGrid>
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
    <AdminWorkbenchStack>
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
          <QualityList>
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
          </QualityList>
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
        <QualityList>
          <StateRow label="Callable" value="adminUpdateEventDetails" />
          <StateRow label="Audit log" value="adminAuditLogs/{id}" />
          <StateRow label="Search rebuild" value="adminSearch projection" />
          <StateRow label="Discovery rebuild" value="eventDiscoveryProjection" />
          <StateRow label="Excluded" value="schedule, policy, cancellation" />
        </QualityList>
      </Panel>
    </AdminWorkbenchStack>
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
    <QualityList>
      <StateRow label="Collection" value={`events/${event.eventId}`} />
      <StateRow label="Organizer" value={event.organizerName} />
      <StateRow label="Time" value={formatDateTime(event.startTime)} />
      <StateRow label="Venue" value={event.meetingPoint} />
      <AdminSurfacePreview>
        <strong>{label}</strong>
        <span>
          {[event.organizerName, event.discovery.citySlug, formatDateTime(event.startTime)]
            .filter(Boolean)
            .join(" · ")}
        </span>
        <span>{form.description || "No description"}</span>
        <AdminTagRow>
          <AdminTag tone="muted">{formatEventLabel(form.interactionModel)}</AdminTag>
          <AdminTag tone="muted">{form.distanceKm} km</AdminTag>
          <AdminTag tone="muted">{formatEventLabel(form.pace)}</AdminTag>
        </AdminTagRow>
      </AdminSurfacePreview>
    </QualityList>
  );
}

function IssueList({issues}: {issues: EventValidationIssue[]}) {
  if (issues.length === 0) {
    return (
      <QualityList>
        <StateRow label="Ready" value="No validation blockers" />
      </QualityList>
    );
  }
  return (
    <AdminRoadmapList>
      {issues.map((issue) => (
        <AdminRoadmapListItem key={issue.id}>
          <FileWarning size={15} strokeWidth={1.9} />
          <span>
            <strong>{issue.label}:</strong> {issue.detail}
          </span>
        </AdminRoadmapListItem>
      ))}
    </AdminRoadmapList>
  );
}

function DiffList({rows}: {rows: EventDiffRow[]}) {
  if (rows.length === 0) {
    return (
      <QualityList>
        <StateRow label="Changes" value="No unsaved changes" />
      </QualityList>
    );
  }
  return (
    <AdminDiffList>
      {rows.slice(0, 12).map((row) => (
        <AdminDiffRow
          key={row.field}
          field={row.field}
          before={row.before}
          after={row.after}
        />
      ))}
      {rows.length > 12 && (
        <AdminMutedCell>{rows.length - 12} more changes</AdminMutedCell>
      )}
    </AdminDiffList>
  );
}

function ReadonlyState({
  label,
  value,
}: {
  label: string;
  value: string | null;
}) {
  return <StateRow label={label} value={value} />;
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

export const eventPublishingEditorPanels = {
  EventEditor,
  EventSidePanel,
  AppEventPreview,
  IssueList,
  DiffList,
  ReadonlyState,
  formatDateTime,
  formatMoney,
  formatExternalMoney,
};
