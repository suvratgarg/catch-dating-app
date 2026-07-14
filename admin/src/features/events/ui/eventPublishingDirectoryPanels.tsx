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
import {eventPublishingSupplyPanels} from "./eventPublishingSupplyPanels";
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

function EventDirectoryView({
  activeCount,
  controller,
  fullCount,
  searchIssueCount,
}: {
  activeCount: number;
  controller: EventPublishingController;
  fullCount: number;
  searchIssueCount: number;
}) {
  return (
    <AdminDirectoryScreenStack>
      <AdminMetricGrid ariaLabel="Event publishing state">
        <AdminMetricCard label="Loaded events" value={controller.rows.length} />
        <AdminMetricCard label="Active" value={activeCount} />
        <AdminMetricCard
          label="Full"
          tone={fullCount > 0 ? "attention" : "normal"}
          value={fullCount}
        />
        <AdminMetricCard
          label="Search issues"
          tone={searchIssueCount > 0 ? "attention" : "normal"}
          value={searchIssueCount}
        />
      </AdminMetricGrid>

      <EventDirectoryPanel controller={controller} />
    </AdminDirectoryScreenStack>
  );
}

function EventDetailView({
  controller,
}: {
  controller: EventPublishingController;
}) {
  const title = controller.event?.title || controller.eventId || "Event";
  return (
    <AdminDetailScreenStack>
      <PageHeader
        actions={
          <AdminButton
            icon={<ArrowLeft size={15} strokeWidth={1.9} />}
            onClick={controller.backToList}
          >
            Directory
          </AdminButton>
        }
        title={title}
      />
      <EventDetailSummary controller={controller} />
      <eventPublishingEditorPanels.EventEditor
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
      <eventPublishingSupplyPanels.EventContractPanel
        externalListGeneratedAt={controller.externalListGeneratedAt}
        listGeneratedAt={controller.listGeneratedAt}
      />
    </AdminDetailScreenStack>
  );
}

function EventReadinessView({
  controller,
}: {
  controller: EventPublishingController;
}) {
  return (
    <AdminDetailScreenStack>
      <eventPublishingReadinessPanels.EventSupplyReadinessPanel
        executionPlan={controller.supplyReadiness?.executionPlan ?? null}
        generatedAt={controller.supplyReadiness?.generatedAt ?? null}
        importPlan={controller.supplyReadiness?.importPlan ?? null}
        isLoading={controller.isSupplyReadinessLoading}
        onPublishExternalEvent={controller.publishExternalEvent}
        onSelectSourceActionId={controller.selectReadinessAction}
        publishingExternalActionId={controller.publishingExternalActionId}
        selectedSourceActionId={controller.selectedReadinessActionId}
        source={controller.supplyReadiness?.source ?? null}
      />
    </AdminDetailScreenStack>
  );
}

function ExternalEventInventoryView({
  controller,
}: {
  controller: EventPublishingController;
}) {
  if (controller.selectedExternalEventId) {
    return (
      <AdminDetailScreenStack>
        <PageHeader
          actions={
            <AdminButton
              icon={<ArrowLeft size={15} strokeWidth={1.9} />}
              onClick={() => controller.selectExternalEvent(null)}
            >
              External inventory
            </AdminButton>
          }
          title={controller.selectedExternalEvent?.title ?? "External event"}
        />
        {!controller.isExternalListLoading && !controller.selectedExternalEvent ? (
          <Panel
            span={2}
            icon={<FileWarning size={18} strokeWidth={1.9} />}
            title="External event unavailable"
            action="Bounded source query"
          >
            <EmptyState
              variant="workbench"
              icon={<FileWarning size={16} strokeWidth={1.9} />}
            >
              This record was not found in the current external-event source query.
              A dedicated point-read contract is not available.
            </EmptyState>
          </Panel>
        ) : (
          <Panel
            span={2}
            icon={<ExternalLink size={18} strokeWidth={1.9} />}
            title="Source record"
            action={controller.isExternalListLoading ? "Loading" :
              controller.selectedExternalEvent?.publicationStatus ?? "Unavailable"}
          >
            <AdminEventSupplyReviewGrid>
              <eventPublishingSupplyPanels.ExternalEventSupplyDetail
                event={controller.selectedExternalEvent}
              />
              <eventPublishingSupplyPanels.ExternalEventImportReviewPanel
                review={controller.selectedExternalImportReview}
              />
            </AdminEventSupplyReviewGrid>
          </Panel>
        )}
      </AdminDetailScreenStack>
    );
  }

  return (
    <AdminDirectoryScreenStack>
      <ExternalEventSupplyPanel controller={controller} />
    </AdminDirectoryScreenStack>
  );
}

function EventDirectoryPanel({
  controller,
}: {
  controller: EventPublishingController;
}) {
  return (
    <Panel
      span={2}
      icon={<CalendarDays size={18} strokeWidth={1.9} />}
      title="Canonical event directory"
      action={
        controller.isListLoading ?
          "Loading" :
          `${controller.filteredRows.length} shown`
      }
    >
      <AdminToolbar>
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
          disabled={controller.isListLoading}
          icon={<RefreshCw size={15} strokeWidth={1.9} />}
          onClick={() => {
            void controller.refreshList();
          }}
        >
          Refresh
        </AdminButton>
      </AdminToolbar>
      <eventPublishingSupplyPanels.EventDirectoryTable
        rows={controller.filteredRows}
        selectedEventId={controller.event?.eventId ?? controller.eventId}
        onSelect={controller.selectEvent}
      />
    </Panel>
  );
}

function EventDetailSummary({
  controller,
}: {
  controller: EventPublishingController;
}) {
  const event = controller.event;
  const capacityFill = event && event.capacityLimit > 0 ?
    Math.round((event.bookedCount / event.capacityLimit) * 100) :
    null;
  const checkInRate = event && event.bookedCount > 0 ?
    Math.round((event.checkedInCount / event.bookedCount) * 100) :
    null;
  return (
    <Panel
      span={2}
      icon={<CalendarDays size={18} strokeWidth={1.9} />}
      title="Event status"
      action={event?.status ?? "Not loaded"}
    >
      <AdminMetricGrid ariaLabel="Backed event performance">
        <AdminMetricCard
          label="Capacity fill"
          value={capacityFill === null ? "—" : `${capacityFill}%`}
        />
        <AdminMetricCard
          label="Checked in"
          value={event ? `${event.checkedInCount} (${checkInRate ?? 0}%)` : "—"}
        />
        <AdminMetricCard
          label="Waitlist"
          value={event?.waitlistedCount ?? "—"}
        />
        <AdminMetricCard
          label="Listed price"
          value={event ? eventPublishingEditorPanels.formatMoney(event) : "—"}
        />
      </AdminMetricGrid>
      <AdminStatusGrid>
        <StateRow label="Document" value={event?.eventId ?? controller.eventId} />
        <StateRow label="Organizer" value={event?.organizerName} />
        <StateRow label="City" value={event?.discovery.citySlug} />
        <StateRow label="Venue" value={event?.meetingPoint} />
        <StateRow label="Starts" value={eventPublishingEditorPanels.formatDateTime(event?.startTime)} />
        <StateRow label="Bookings" value={event ? `${event.bookedCount}/${event.capacityLimit}` : null} />
        <StateRow label="Search" value={event?.searchIndexStatus} />
        <StateRow
          label="Changes"
          value={`${controller.diffRows.length} pending`}
        />
      </AdminStatusGrid>
    </Panel>
  );
}

function ExternalEventSupplyPanel({
  controller,
}: {
  controller: EventPublishingController;
}) {
  return (
    <Panel
      span={2}
      icon={<ExternalLink size={18} strokeWidth={1.9} />}
      title="Read-only external event supply"
      action={
        controller.isExternalListLoading ?
          "Loading" :
          `${controller.filteredExternalRows.length} shown`
      }
    >
      <AdminToolbar>
        <SegmentedControl<ExternalEventSupplyFilter>
          ariaLabel="External event supply filters"
          options={[
            {id: "public", label: "All public"},
            {id: "launchCities", label: "Indore + Mumbai"},
            {id: "upcoming", label: "Upcoming"},
            {id: "active", label: "Active"},
            {id: "cancelled", label: "Cancelled"},
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
        <AdminButton
          disabled={controller.isExternalListLoading}
          icon={<RefreshCw size={15} strokeWidth={1.9} />}
          onClick={() => void controller.refreshExternalList()}
        >
          Refresh
        </AdminButton>
      </AdminToolbar>
      <eventPublishingSupplyPanels.ExternalEventSupplyTable
        onSelect={controller.selectExternalEvent}
        rows={controller.filteredExternalRows}
        selectedEventId={controller.selectedExternalEventId}
      />
    </Panel>
  );
}

export const eventPublishingDirectoryPanels = {
  EventDirectoryView,
  EventDetailView,
  EventReadinessView,
  ExternalEventInventoryView,
  EventDirectoryPanel,
  EventDetailSummary,
  ExternalEventSupplyPanel,
};
