import {
  ArrowLeft,
  CheckCircle2,
  Clock3,
  Database,
  ExternalLink,
  FileWarning,
  FolderSearch,
  RefreshCw,
  Save,
  Search,
  Smartphone,
  Settings2,
  UploadCloud,
  UserCheck,
  Users,
} from "lucide-react";
import type {
  AdminClubClaimListRow,
  AdminClubClaimRequestDetails,
  AdminClubDetails,
  AdminClubListRow,
  OrganizerAppVisibility,
  OrganizerEntityKind,
  OrganizerPublishStatus,
  OrganizerSourceConfidence,
  OrganizerVerificationStatus,
  ClubClaimDecision,
} from "../../../shared/types/adminTypes";
import {
  AdminButton,
  AdminChecklistStack,
  AdminDetailScreenStack,
  AdminDiffList,
  AdminDirectoryScreenStack,
  AdminDiffRow,
  AdminEditorGrid,
  AdminEditorPanel,
  AdminEditorSection,
  AdminFieldGrid,
  AdminForm,
  AdminLinkButton,
  AdminMetricCard,
  AdminMetricGrid,
  AdminMutedCell,
  AdminPublishingLoadbar,
  AdminRoadmapList,
  AdminRoadmapListItem,
  AdminStatusGrid,
  AdminSurfacePreview,
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
  SearchField,
  SegmentedControl,
  SelectField,
  StateRow,
  TableActionButton,
  TextareaField,
  TextField,
  AdminRowTitle,
  AdminTagRow,
} from "../../../shared/ui/AdminPrimitives";
import {
  countBlockingIssues,
  countDiffRows,
  organizerNeedsPublish,
  type OrganizerPublishingController,
  type OrganizerPublishingFilter,
  useOrganizerPublishingController,
} from "../controllers/useOrganizerPublishingController";
import {
  type OrganizerClaimReviewController,
  useOrganizerClaimReviewController,
} from "../controllers/useOrganizerClaimReviewController";
import type {
  OrganizerDiffRow,
  OrganizerPublishingFormState,
  OrganizerValidationIssue,
  PublishChecklistState,
} from "../controllers/organizerPublishingHelpers";
import {useAdminFeedback} from "../../../shared/feedback/AdminFeedbackContext";

const defaultPublicSiteOrigin = "https://catchdates.com";
const publicSiteOrigin = String(
  import.meta.env.VITE_ADMIN_PUBLIC_SITE_ORIGIN ?? defaultPublicSiteOrigin
).replace(/\/+$/u, "");

export function OrganizerPublishingScreen({
  selectedClubId,
  onBackToList,
  onSelectClubId,
}: {
  selectedClubId?: string | null;
  onBackToList?: () => void;
  onSelectClubId?: (clubId: string) => void;
}) {
  const {setError: onError, setNotice: onNotice} = useAdminFeedback();
  const controller = useOrganizerPublishingController({
    onBackToList,
    onError,
    onNotice,
    onSelectClubId,
    selectedClubId,
  });
  const claimReviewController = useOrganizerClaimReviewController({
    onError,
    onNotice,
  });
  return (
    <OrganizerPublishingWorkspace
      claimReviewController={claimReviewController}
      controller={controller}
    />
  );
}

export function OrganizerPublishingWorkspace({
  claimReviewController,
  controller,
}: {
  claimReviewController?: OrganizerClaimReviewController;
  controller: OrganizerPublishingController;
}) {
  const needsPublishCount = controller.rows.filter(organizerNeedsPublish).length;
  const publishedCount = controller.rows.filter((row) =>
    row.publishStatus === "published"
  ).length;
  const routeIssueCount = controller.rows.filter((row) =>
    row.routeStatus !== "valid" ||
    row.routeReservationStatus !== "reserved"
  ).length;
  const searchIssueCount = controller.rows.filter((row) =>
    row.searchIndexStatus !== "indexed"
  ).length;

  if (controller.view === "detail") {
    return <OrganizerDetailView controller={controller} />;
  }

  return (
    <OrganizerDirectoryView
      claimReviewController={claimReviewController}
      controller={controller}
      needsPublishCount={needsPublishCount}
      publishedCount={publishedCount}
      routeIssueCount={routeIssueCount}
      searchIssueCount={searchIssueCount}
    />
  );
}

function OrganizerDirectoryView({
  claimReviewController,
  controller,
  needsPublishCount,
  publishedCount,
  routeIssueCount,
  searchIssueCount,
}: {
  claimReviewController?: OrganizerClaimReviewController;
  controller: OrganizerPublishingController;
  needsPublishCount: number;
  publishedCount: number;
  routeIssueCount: number;
  searchIssueCount: number;
}) {
  return (
    <AdminDirectoryScreenStack>
      <PageHeader eyebrow="Organizers" title="Canonical Organizer Directory" />
      {claimReviewController ? (
        <OrganizerClaimReviewWorkspace controller={claimReviewController} />
      ) : null}
      <AdminMetricGrid ariaLabel="Organizer publishing state">
        <AdminMetricCard label="Canonical organizers" value={controller.rows.length} />
        <AdminMetricCard
          label="Needs review work"
          tone={needsPublishCount > 0 ? "attention" : "normal"}
          value={needsPublishCount}
        />
        <AdminMetricCard label="Published" value={publishedCount} />
        <AdminMetricCard
          label="Route issues"
          tone={routeIssueCount > 0 ? "attention" : "normal"}
          value={routeIssueCount}
        />
        <AdminMetricCard
          label="Search issues"
          tone={searchIssueCount > 0 ? "attention" : "normal"}
          value={searchIssueCount}
        />
      </AdminMetricGrid>

      <OrganizerDirectoryPanel controller={controller} />
    </AdminDirectoryScreenStack>
  );
}

function OrganizerClaimReviewWorkspace({
  controller,
}: {
  controller: OrganizerClaimReviewController;
}) {
  return (
    <AdminWorkbenchStack>
      <AdminMetricGrid ariaLabel="Organizer claim review state">
        <AdminMetricCard label="Pending claims" value={controller.rows.length} />
        <AdminMetricCard label="Shown" value={controller.filteredRows.length} />
        <AdminMetricCard
          label="Selected profile blocker"
          tone={controller.details &&
            !controller.details.requesterProfile.profileComplete ?
            "attention" :
            "normal"}
          value={controller.details &&
            !controller.details.requesterProfile.profileComplete ? 1 : 0}
        />
        <AdminMetricCard
          label="Selected proof links"
          value={controller.details?.proofUrls.length ?? 0}
        />
      </AdminMetricGrid>
      <Panel
        span={2}
        icon={<UserCheck size={18} strokeWidth={1.9} />}
        title="Organizer claim review"
        action={controller.isLoading ?
          "Loading" :
          `${controller.filteredRows.length} pending`}
      >
        <AdminToolbar>
          <SearchField
            ariaLabel="Search organizer claims"
            icon={<Search size={16} strokeWidth={1.8} />}
            onChange={controller.setQuery}
            placeholder="Search requester, organizer, role, contact"
            value={controller.query}
          />
          <AdminButton
            disabled={controller.isLoading}
            icon={<RefreshCw size={15} strokeWidth={1.9} />}
            onClick={() => void controller.refresh()}
          >
            Refresh claims
          </AdminButton>
        </AdminToolbar>
        <OrganizerClaimTable
          rows={controller.filteredRows}
          selectedRequestId={controller.selected?.requestId ?? null}
          onSelect={controller.select}
        />
      </Panel>
      <AdminEditorGrid>
        <OrganizerClaimEvidencePanel
          details={controller.details}
          isLoading={controller.isDetailLoading}
          selected={controller.selected}
        />
        <OrganizerClaimDecisionPanel controller={controller} />
      </AdminEditorGrid>
    </AdminWorkbenchStack>
  );
}

function OrganizerClaimTable({
  onSelect,
  rows,
  selectedRequestId,
}: {
  onSelect: (row: AdminClubClaimListRow) => void;
  rows: AdminClubClaimListRow[];
  selectedRequestId: string | null;
}) {
  if (rows.length === 0) {
    return (
      <EmptyState
        variant="workbench"
        icon={<CheckCircle2 size={16} strokeWidth={1.9} />}
      >
        No pending organizer claims match this filter.
      </EmptyState>
    );
  }
  return (
    <DataTable variant="workbench">
      <thead>
        <tr>
          <th>Requester</th>
          <th>Organizer</th>
          <th>Evidence</th>
          <th>Created</th>
          <th>Select</th>
        </tr>
      </thead>
      <tbody>
        {rows.map((row) => (
          <AdminTableRow
            key={row.requestId}
            selected={selectedRequestId === row.requestId}
          >
            <td>
              <AdminRowTitle>
                <strong>{row.requesterName}</strong>
                <span>{row.requesterRole} · {row.contact ?? "no contact"}</span>
              </AdminRowTitle>
            </td>
            <td>{row.clubId}</td>
            <td>{row.proofCount} proof link{row.proofCount === 1 ? "" : "s"}</td>
            <td>{formatDateTime(row.createdAt)}</td>
            <td>
              <TableActionButton onClick={() => onSelect(row)}>
                Review
              </TableActionButton>
            </td>
          </AdminTableRow>
        ))}
      </tbody>
    </DataTable>
  );
}

function OrganizerClaimEvidencePanel({
  details,
  isLoading,
  selected,
}: {
  details: AdminClubClaimRequestDetails | null;
  isLoading: boolean;
  selected: AdminClubClaimListRow | null;
}) {
  return (
    <AdminEditorPanel
      icon={<FolderSearch size={18} strokeWidth={1.9} />}
      title="Claim evidence"
      action={isLoading ? "Loading" : details?.status ?? "No claim"}
    >
      {details ? (
        <QualityList>
          <StateRow label="Request" value={details.requestId} />
          <StateRow label="Requester uid" value={details.requesterUid} />
          <StateRow label="Requested role" value={details.requesterRole} />
          <StateRow label="Email" value={details.businessEmail} />
          <StateRow label="Phone" value={details.businessPhone} />
          <StateRow label="Message" value={details.message} />
          <StateRow
            label="Catch profile"
            value={details.requesterProfile.exists ?
              details.requesterProfile.profileComplete ? "complete" : "incomplete" :
              "missing"}
          />
          <StateRow label="Organizer" value={details.club.name ?? details.clubId} />
          <StateRow label="Claim state" value={details.club.claimState} />
          <StateRow label="Ownership" value={details.club.ownershipState} />
          <StateRow label="Current owner" value={details.club.ownerUserId} />
          <StateRow label="Canonical path" value={details.club.canonicalPath} />
          <StateRow
            label="Proof links"
            value={<OrganizerClaimProofLinks urls={details.proofUrls} />}
          />
        </QualityList>
      ) : (
        <EmptyState
          variant="workbench"
          icon={<Clock3 size={16} strokeWidth={1.9} />}
        >
          {selected ?
            "Loading claim evidence." :
            "Select a pending claim to inspect its evidence."}
        </EmptyState>
      )}
    </AdminEditorPanel>
  );
}

function OrganizerClaimProofLinks({urls}: {urls: string[]}) {
  if (urls.length === 0) return "none";
  return (
    <AdminTagRow as="span">
      {urls.map((url, index) => (
        <AdminLinkButton
          href={url}
          key={url}
          rel="noreferrer"
          target="_blank"
        >
          Proof {index + 1}
        </AdminLinkButton>
      ))}
    </AdminTagRow>
  );
}

function OrganizerClaimDecisionPanel({
  controller,
}: {
  controller: OrganizerClaimReviewController;
}) {
  const isDeciding = controller.decisionInFlight !== null;
  const displayedIssue = controller.validationIssue ?? controller.approvalIssue;
  return (
    <AdminEditorPanel
      icon={<UploadCloud size={18} strokeWidth={1.9} />}
      title="Claim decision"
      action={controller.selected?.status ?? "No claim"}
    >
      {controller.selected ? (
        <AdminForm variant="publishing" onSubmit={(event) => event.preventDefault()}>
          <AdminEditorSection>
            <legend>Decision context</legend>
            <QualityList>
              <StateRow label="Requester" value={controller.selected.requesterName} />
              <StateRow label="Organizer" value={controller.selected.clubId} />
              <StateRow label="Proof count" value={String(controller.selected.proofCount)} />
            </QualityList>
          </AdminEditorSection>
          <AdminEditorSection>
            <legend>Audited review note</legend>
            <TextareaField
              label="Decision reason"
              onChange={controller.setNote}
              rows={5}
              value={controller.note}
            />
            {displayedIssue ? (
              <AdminRoadmapListItem>
                <FileWarning size={15} strokeWidth={1.9} />
                <span>{displayedIssue}</span>
              </AdminRoadmapListItem>
            ) : null}
          </AdminEditorSection>
          <AdminTagRow>
            <AdminButton
              disabled={isDeciding || Boolean(controller.approvalIssue)}
              icon={<CheckCircle2 size={15} strokeWidth={1.9} />}
              onClick={() => void controller.decide("approve")}
              variant="primary"
            >
              {decisionLabel(controller.decisionInFlight, "approve")}
            </AdminButton>
            <AdminButton
              disabled={isDeciding || Boolean(controller.rejectionIssue)}
              icon={<FileWarning size={15} strokeWidth={1.9} />}
              onClick={() => void controller.decide("reject")}
            >
              {decisionLabel(controller.decisionInFlight, "reject")}
            </AdminButton>
          </AdminTagRow>
        </AdminForm>
      ) : (
        <EmptyState
          variant="workbench"
          icon={<Clock3 size={16} strokeWidth={1.9} />}
        >
          Select a pending claim before deciding.
        </EmptyState>
      )}
    </AdminEditorPanel>
  );
}

function decisionLabel(
  inFlight: ClubClaimDecision | null,
  decision: ClubClaimDecision
): string {
  if (inFlight !== decision) return decision === "approve" ? "Approve" : "Reject";
  return decision === "approve" ? "Approving" : "Rejecting";
}

function OrganizerDetailView({
  controller,
}: {
  controller: OrganizerPublishingController;
}) {
  const title =
    controller.club?.name ||
    controller.form?.name ||
    controller.clubId ||
    "Organizer";
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
        eyebrow="Organizer detail"
        title={title}
      />
      <OrganizerDetailSummary controller={controller} />
      <OrganizerEditor
        checklist={controller.checklist}
        club={controller.club}
        clubId={controller.clubId}
        completeChecklist={controller.completeChecklist}
        diffRows={controller.diffRows}
        form={controller.form}
        isDetailLoading={controller.isDetailLoading}
        isPublishing={controller.isPublishing}
        isSaving={controller.isSaving}
        publishingIssues={controller.publishingIssues}
        onChecklistChange={controller.setChecklist}
        onClubIdChange={controller.setClubId}
        onFormChange={controller.setForm}
        onLoad={() => void controller.selectOrganizer(controller.clubId)}
        onPublish={() => void controller.saveAndPublish()}
        onSave={() => void controller.save()}
        validationIssues={controller.validationIssues}
      />
      <OrganizerPublishingContractPanel
        generatedAt={controller.listGeneratedAt}
      />
    </AdminDetailScreenStack>
  );
}

function OrganizerDirectoryPanel({
  controller,
}: {
  controller: OrganizerPublishingController;
}) {
  return (
    <Panel
      span={2}
      icon={<Users size={18} strokeWidth={1.9} />}
      title="Canonical organizer directory"
      action={
        controller.isListLoading ?
          "Loading" :
          `${controller.filteredRows.length} shown`
      }
    >
      <AdminToolbar>
        <SegmentedControl<OrganizerPublishingFilter>
          ariaLabel="Organizer filters"
          options={[
            {id: "launchCities", label: "Indore + Mumbai"},
            {id: "all", label: "All"},
            {id: "needsPublish", label: "Needs review"},
            {id: "published", label: "Published"},
            {id: "appHidden", label: "App hidden"},
            {id: "routeIssues", label: "Route issues"},
            {id: "searchIssues", label: "Search issues"},
          ]}
          value={controller.filter}
          onChange={controller.setFilter}
        />
        <SearchField
          ariaLabel="Search canonical organizers"
          icon={<Search size={16} strokeWidth={1.8} />}
          onChange={controller.setQuery}
          placeholder="Search name, id, path, city, status"
          value={controller.query}
        />
        <AdminButton
          disabled={controller.isListLoading}
          icon={<RefreshCw size={15} strokeWidth={1.9} />}
          onClick={() => void controller.refreshList()}
        >
          Refresh
        </AdminButton>
      </AdminToolbar>
      <OrganizerDirectoryTable
        rows={controller.filteredRows}
        selectedClubId={controller.club?.clubId ?? controller.clubId}
        onSelect={controller.selectOrganizer}
      />
    </Panel>
  );
}

function OrganizerDetailSummary({
  controller,
}: {
  controller: OrganizerPublishingController;
}) {
  const club = controller.club;
  const form = controller.form;
  return (
    <Panel
      span={2}
      icon={<Users size={18} strokeWidth={1.9} />}
      title="Profile status"
      action={club?.publicPage.publishStatus ?? "Not loaded"}
    >
      <AdminStatusGrid>
        <StateRow label="Document" value={club?.clubId ?? controller.clubId} />
        <StateRow label="City" value={form?.cityName || club?.cityName} />
        <StateRow
          label="Public path"
          value={form?.canonicalPath || club?.publicPage.canonicalPath}
        />
        <StateRow
          label="App visibility"
          value={form?.appVisibility ?? club?.appVisibility}
        />
        <StateRow label="Claim" value={club?.claimState} />
        <StateRow
          label="Verification"
          value={club?.provenance.verificationStatus}
        />
        <StateRow label="Index" value={club?.publicPage.indexStatus} />
        <StateRow
          label="Changes"
          value={`${controller.diffRows.length} pending`}
        />
      </AdminStatusGrid>
    </Panel>
  );
}

function OrganizerPublishingContractPanel({
  generatedAt,
}: {
  generatedAt: string | null;
}) {
  return (
    <Panel
      icon={<Database size={18} strokeWidth={1.9} />}
      title="Publishing contract"
      action="clubs"
    >
      <QualityList>
        <StateRow label="Source of truth" value="Cloud Firestore clubs/{id}" />
        <StateRow
          label="Search/list"
          value="adminListClubDetails + adminSearch.tokens"
        />
        <StateRow
          label="Canonical snapshot"
          value={formatDateTime(generatedAt)}
        />
        <StateRow
          label="Writes"
          value="Audited partial update + index publish callable"
        />
        <StateRow
          label="Route guard"
          value="canonicalPath shape + publicRouteReservations"
        />
        <StateRow
          label="Action cardinality"
          value="One publish state per organizer document"
        />
      </QualityList>
    </Panel>
  );
}

function OrganizerDirectoryTable({
  onSelect,
  rows,
  selectedClubId,
}: {
  onSelect: (clubId: string) => void;
  rows: AdminClubListRow[];
  selectedClubId: string;
}) {
  if (rows.length === 0) {
    return (
      <EmptyState
        variant="workbench"
        icon={<FolderSearch size={16} strokeWidth={1.9} />}
      >
        No canonical organizers match this filter.
      </EmptyState>
    );
  }
  return (
    <DataTable variant="workbench">
      <thead>
        <tr>
          <th>Organizer</th>
          <th>City</th>
          <th>Public page</th>
          <th>App / claim</th>
          <th>Readiness</th>
          <th>Select</th>
        </tr>
      </thead>
      <tbody>
        {rows.map((row) => (
          <AdminTableRow key={row.clubId} selected={selectedClubId === row.clubId}>
            <td>
              <AdminRowTitle>
                <strong>{row.name}</strong>
                <span>{row.clubId}</span>
              </AdminRowTitle>
            </td>
            <td>
              <AdminRowTitle compact>
                <span>{row.cityName ?? "Unknown city"}</span>
                <span>{row.citySlug ?? "No city slug"}</span>
              </AdminRowTitle>
            </td>
            <td>
              <AdminRowTitle compact>
                <span>{row.canonicalPath ?? "No public path"}</span>
                <span>{row.publishStatus ?? "no status"} / {row.indexStatus ?? "no index"}</span>
              </AdminRowTitle>
            </td>
            <td>
              <AdminTagRow>
                <AdminTag tone="muted">{row.appVisibility ?? "unset"}</AdminTag>
                <AdminTag tone="muted">{row.claimState ?? "no claim"}</AdminTag>
              </AdminTagRow>
            </td>
            <td>
              <AdminTagRow>
                <AdminTag tone={row.routeStatus === "valid" ? "neutral" : "muted"}>
                  {row.routeStatus}
                </AdminTag>
                <AdminTag
                  tone={
                    row.routeReservationStatus === "reserved" ?
                      "neutral" :
                      "muted"
                  }
                >
                  {row.routeReservationStatus}
                </AdminTag>
                <AdminTag
                  tone={
                    row.searchIndexStatus === "indexed" ?
                      "neutral" :
                      "muted"
                  }
                >
                  {row.searchIndexStatus}
                </AdminTag>
                <AdminTag
                  tone={
                    row.sourceConfidence === "high" ||
                    row.sourceConfidence === "ownerVerified" ?
                      "neutral" :
                      "muted"
                  }
                >
                  {row.sourceConfidence ?? "source unset"}
                </AdminTag>
                <AdminTag
                  tone={
                    row.verificationStatus &&
                    row.verificationStatus !== "unverified" ?
                      "neutral" :
                      "muted"
                  }
                >
                  {row.verificationStatus ?? "verification unset"}
                </AdminTag>
                <AdminTag tone="muted">
                  {organizerNeedsPublish(row) ? "needs work" : "ready"}
                </AdminTag>
              </AdminTagRow>
            </td>
            <td>
              <TableActionButton onClick={() => onSelect(row.clubId)}>
                {selectedClubId === row.clubId ? "Selected" : "Open"}
              </TableActionButton>
            </td>
          </AdminTableRow>
        ))}
      </tbody>
    </DataTable>
  );
}

function OrganizerEditor({
  checklist,
  club,
  clubId,
  completeChecklist,
  diffRows,
  form,
  isDetailLoading,
  isPublishing,
  isSaving,
  onChecklistChange,
  onClubIdChange,
  onFormChange,
  onLoad,
  onPublish,
  onSave,
  publishingIssues,
  validationIssues,
}: {
  checklist: PublishChecklistState;
  club: AdminClubDetails | null;
  clubId: string;
  completeChecklist: boolean;
  diffRows: OrganizerDiffRow[];
  form: OrganizerPublishingFormState | null;
  isDetailLoading: boolean;
  isPublishing: boolean;
  isSaving: boolean;
  onChecklistChange: (checklist: PublishChecklistState) => void;
  onClubIdChange: (clubId: string) => void;
  onFormChange: (form: OrganizerPublishingFormState | null) => void;
  onLoad: () => void;
  onPublish: () => void;
  onSave: () => void;
  publishingIssues: OrganizerValidationIssue[];
  validationIssues: OrganizerValidationIssue[];
}) {
  const update = <K extends keyof OrganizerPublishingFormState>(
    key: K,
    value: OrganizerPublishingFormState[K]
  ) => {
    if (!form) return;
    onFormChange({...form, [key]: value});
  };
  const publishBlockerCount = countBlockingIssues(publishingIssues);
  const publishDisabledReason =
    !form ? "Load an organizer before publishing." :
    publishBlockerCount > 0 ?
      `Resolve ${publishBlockerCount} publish blocker${
        publishBlockerCount === 1 ? "" : "s"
      } before publishing.` :
    !completeChecklist ? "Complete the publish checklist before publishing." :
    isSaving ? "Wait for the current save to finish." :
    isPublishing ? "Organizer publish is already in progress." :
    undefined;
  const canPublish =
    Boolean(form) &&
    completeChecklist &&
    publishBlockerCount === 0 &&
    !isSaving &&
    !isPublishing;
  return (
    <AdminEditorGrid>
      <AdminEditorPanel
        span={2}
        icon={<Settings2 size={18} strokeWidth={1.9} />}
        title="Canonical publisher"
        action={club?.clubId ?? "No organizer loaded"}
      >
        <AdminPublishingLoadbar>
          <TextField
            aria-label="Organizer document id"
            label="Document ID"
            onChange={onClubIdChange}
            value={clubId}
          />
          <AdminButton
            disabled={isDetailLoading}
            icon={<FolderSearch size={15} strokeWidth={1.9} />}
            onClick={onLoad}
          >
            {isDetailLoading ? "Loading" : "Load"}
          </AdminButton>
          <AdminButton
            disabled={!form || isSaving}
            icon={<Save size={15} strokeWidth={1.9} />}
            onClick={onSave}
          >
            {isSaving ? "Saving" : "Save changes"}
          </AdminButton>
          <AdminButton
            disabled={!canPublish}
            icon={<UploadCloud size={15} strokeWidth={1.9} />}
            onClick={onPublish}
            title={publishDisabledReason}
            variant="primary"
          >
            {isPublishing ? "Publishing" : "Save + publish"}
          </AdminButton>
        </AdminPublishingLoadbar>

        {form ? (
          <AdminForm variant="publishing">
            <AdminEditorSection>
              <legend>Identity</legend>
              <AdminFieldGrid columns={2}>
                <TextField
                  label="Name"
                  onChange={(value) => update("name", value)}
                  value={form.name}
                />
                <SelectField
                  label="Entity"
                  onChange={(value) =>
                    update("entityKind", value as OrganizerEntityKind)}
                  options={[
                    "club",
                    "venue",
                    "eventOrganizer",
                    "creatorCommunity",
                    "brand",
                  ]}
                  value={form.entityKind}
                />
                <TextField
                  label="Display category"
                  onChange={(value) => update("displayCategory", value)}
                  value={form.displayCategory}
                />
                <TextField
                  label="Area"
                  onChange={(value) => update("area", value)}
                  value={form.area}
                />
              </AdminFieldGrid>
              <TextareaField
                label="Description"
                onChange={(value) => update("description", value)}
                rows={4}
                value={form.description}
              />
              <AdminFieldGrid columns={2}>
                <TextareaField
                  label="Tags"
                  onChange={(value) => update("tagsText", value)}
                  rows={4}
                  value={form.tagsText}
                />
                <TextareaField
                  label="Subtypes"
                  onChange={(value) => update("entitySubtypesText", value)}
                  rows={4}
                  value={form.entitySubtypesText}
                />
              </AdminFieldGrid>
            </AdminEditorSection>

            <AdminEditorSection>
              <legend>Location And Contact</legend>
              <AdminFieldGrid columns={3}>
                <TextField
                  label="Location slug"
                  onChange={(value) => update("location", value)}
                  value={form.location}
                />
                <TextField
                  label="City"
                  onChange={(value) => update("cityName", value)}
                  value={form.cityName}
                />
                <TextField
                  label="Region"
                  onChange={(value) => update("regionName", value)}
                  value={form.regionName}
                />
                <TextField
                  label="Country code"
                  onChange={(value) => update("countryCode", value)}
                  value={form.countryCode}
                />
                <TextField
                  label="Country"
                  onChange={(value) => update("countryName", value)}
                  value={form.countryName}
                />
                <SelectField
                  label="App visibility"
                  onChange={(value) =>
                    update("appVisibility", value as OrganizerAppVisibility)}
                  options={["hidden", "discoverable"]}
                  value={form.appVisibility}
                />
                <TextField
                  label="Instagram"
                  onChange={(value) => update("instagramHandle", value)}
                  value={form.instagramHandle}
                />
                <TextField
                  label="Email"
                  onChange={(value) => update("email", value)}
                  value={form.email}
                />
                <TextField
                  label="Phone"
                  onChange={(value) => update("phoneNumber", value)}
                  value={form.phoneNumber}
                />
              </AdminFieldGrid>
            </AdminEditorSection>

            <AdminEditorSection>
              <legend>Public Page</legend>
              <AdminFieldGrid columns={2}>
                <TextField
                  label="Slug"
                  onChange={(value) => update("publicPageSlug", value)}
                  value={form.publicPageSlug}
                />
                <TextField
                  label="Page city slug"
                  onChange={(value) => update("publicPageCitySlug", value)}
                  value={form.publicPageCitySlug}
                />
                <TextField
                  label="Canonical path"
                  onChange={(value) => update("canonicalPath", value)}
                  value={form.canonicalPath}
                />
                <SelectField
                  label="Publish status"
                  onChange={(value) =>
                    update("publishStatus", value as OrganizerPublishStatus)}
                  options={["draft", "qa", "published", "suppressed", "removed"]}
                  value={form.publishStatus}
                />
                <TextField
                  label="Image URL"
                  onChange={(value) => update("imageUrl", value)}
                  value={form.imageUrl}
                />
                <TextField
                  label="Logo URL"
                  onChange={(value) => update("profileImageUrl", value)}
                  value={form.profileImageUrl}
                />
                <TextField
                  label="SEO title"
                  onChange={(value) => update("seoTitle", value)}
                  value={form.seoTitle}
                />
                <TextField
                  label="SEO description"
                  onChange={(value) => update("seoDescription", value)}
                  value={form.seoDescription}
                />
              </AdminFieldGrid>
            </AdminEditorSection>

            <AdminEditorSection>
              <legend>Listing Copy</legend>
              <TextField
                label="Headline"
                onChange={(value) => update("headline", value)}
                value={form.headline}
              />
              <TextareaField
                label="Summary"
                onChange={(value) => update("summary", value)}
                rows={5}
                value={form.summary}
              />
              <TextareaField
                label="Source summary"
                onChange={(value) => update("sourceSummary", value)}
                rows={4}
                value={form.sourceSummary}
              />
              <AdminFieldGrid columns={3}>
                <TextareaField
                  label="Formats"
                  onChange={(value) => update("formatsText", value)}
                  rows={5}
                  value={form.formatsText}
                />
                <TextareaField
                  label="Fit notes"
                  onChange={(value) => update("fitNotesText", value)}
                  rows={5}
                  value={form.fitNotesText}
                />
                <TextareaField
                  label="Missing evidence"
                  onChange={(value) => update("missingEvidenceText", value)}
                  rows={5}
                  value={form.missingEvidenceText}
                />
              </AdminFieldGrid>
            </AdminEditorSection>

            <AdminEditorSection>
              <legend>Review State</legend>
              <AdminFieldGrid columns={3}>
                <SelectField
                  label="Source confidence"
                  onChange={(value) =>
                    update("sourceConfidence", value as OrganizerSourceConfidence)}
                  options={["seedOnly", "low", "medium", "high", "ownerVerified"]}
                  value={form.sourceConfidence}
                />
                <SelectField
                  label="Verification"
                  onChange={(value) =>
                    update("verificationStatus", value as OrganizerVerificationStatus)}
                  options={["unverified", "sourceBacked", "ownerVerified"]}
                  value={form.verificationStatus}
                />
                <TextField
                  label="Review note"
                  onChange={(value) => update("reviewNote", value)}
                  value={form.reviewNote}
                />
              </AdminFieldGrid>
            </AdminEditorSection>
          </AdminForm>
        ) : (
          <EmptyState
            variant="editor"
            icon={<Clock3 size={16} strokeWidth={1.9} />}
          >
            Load an organizer document to review canonical fields.
          </EmptyState>
        )}
      </AdminEditorPanel>

      <PublishingSidePanel
        checklist={checklist}
        club={club}
        diffRows={diffRows}
        form={form}
        onChecklistChange={onChecklistChange}
        publishingIssues={publishingIssues}
        validationIssues={validationIssues}
      />
    </AdminEditorGrid>
  );
}

function PublishingSidePanel({
  checklist,
  club,
  diffRows,
  form,
  onChecklistChange,
  publishingIssues,
  validationIssues,
}: {
  checklist: PublishChecklistState;
  club: AdminClubDetails | null;
  diffRows: OrganizerDiffRow[];
  form: OrganizerPublishingFormState | null;
  onChecklistChange: (checklist: PublishChecklistState) => void;
  publishingIssues: OrganizerValidationIssue[];
  validationIssues: OrganizerValidationIssue[];
}) {
  return (
    <AdminWorkbenchStack>
      <Panel
        icon={<FileWarning size={18} strokeWidth={1.9} />}
        title="Save checks"
        action={`${countBlockingIssues(validationIssues)} blockers`}
      >
        <IssueList issues={validationIssues} />
      </Panel>
      <Panel
        icon={<CheckCircle2 size={18} strokeWidth={1.9} />}
        title="Publish checklist"
        action={`${countBlockingIssues(publishingIssues)} blockers`}
      >
        <AdminChecklistStack>
          {([
            ["sourceEvidenceVerified", "Source evidence verified"],
            ["mediaRightsVerified", "Media rights verified"],
            ["cadenceVerified", "Cadence/crawl fit verified"],
            ["ownerContactVerified", "Owner contact or claim path verified"],
          ] as const).map(([key, label]) => (
            <CheckboxField
              checked={checklist[key]}
              key={key}
              label={label}
              onChange={(checked) =>
                onChecklistChange({...checklist, [key]: checked})}
            />
          ))}
        </AdminChecklistStack>
      </Panel>
      <Panel
        icon={<FileWarning size={18} strokeWidth={1.9} />}
        title="Publishing checks"
        action={`${countBlockingIssues(publishingIssues)} blockers`}
      >
        <IssueList issues={publishingIssues} />
      </Panel>
      <Panel
        icon={<Database size={18} strokeWidth={1.9} />}
        title="Before / after diff"
        action={`${countDiffRows(diffRows)} changes`}
      >
        <DiffList rows={diffRows} />
      </Panel>
      <Panel
        icon={<Smartphone size={18} strokeWidth={1.9} />}
        title="App listing preview"
        action={form?.appVisibility ?? "No app"}
      >
        {form ? (
          <AppListingPreview club={club} form={form} />
        ) : (
          <EmptyState icon={<Clock3 size={16} strokeWidth={1.9} />}>
            No organizer loaded
          </EmptyState>
        )}
      </Panel>
      <Panel
        icon={<ExternalLink size={18} strokeWidth={1.9} />}
        title="Public page preview"
        action={club?.publicPage.indexStatus ?? "No page"}
      >
        {form ? (
          <QualityList>
            <StateRow label="Claim" value={club?.claimState} />
            <StateRow label="Ownership" value={club?.ownershipState} />
            <StateRow label="Canonical" value={form.canonicalPath} />
            <StateRow label="App visibility" value={form.appVisibility} />
            {form.canonicalPath && (
              <AdminLinkButton
                href={publicPreviewHref(form.canonicalPath)}
                rel="noreferrer"
                target="_blank"
              >
                Public preview
              </AdminLinkButton>
            )}
          </QualityList>
        ) : (
          <EmptyState icon={<Clock3 size={16} strokeWidth={1.9} />}>
            No organizer loaded
          </EmptyState>
        )}
      </Panel>
    </AdminWorkbenchStack>
  );
}

function publicPreviewHref(canonicalPath: string): string {
  const path = canonicalPath.startsWith("/") ?
    canonicalPath :
    `/${canonicalPath}`;
  return `${publicSiteOrigin}${path}`;
}

function AppListingPreview({
  club,
  form,
}: {
  club: AdminClubDetails | null;
  form: OrganizerPublishingFormState;
}) {
  const location = [form.cityName || form.area, form.regionName]
    .filter(Boolean)
    .join(", ");
  const tags = [
    ...splitPreviewList(form.tagsText),
    ...splitPreviewList(form.formatsText),
  ].slice(0, 6);
  return (
    <QualityList>
      <StateRow label="Collection" value={`clubs/${club?.clubId ?? ""}`} />
      <StateRow label="App visibility" value={form.appVisibility} />
      <StateRow label="Image" value={form.imageUrl ? "imageUrl set" : "missing"} />
      <StateRow
        label="Logo"
        value={form.profileImageUrl ? "profileImageUrl set" : "missing"}
      />
      <AdminSurfacePreview>
        <strong>{form.name || "Untitled organizer"}</strong>
        <span>
          {[form.displayCategory, location || form.location]
            .filter(Boolean)
            .join(" · ")}
        </span>
        <span>{form.headline || form.summary || form.description}</span>
        {tags.length > 0 && (
          <AdminTagRow>
            {tags.map((tag) => (
              <AdminTag key={tag} tone="muted">{tag}</AdminTag>
            ))}
          </AdminTagRow>
        )}
      </AdminSurfacePreview>
    </QualityList>
  );
}

function splitPreviewList(value: string): string[] {
  return value
    .split("\n")
    .map((item) => item.trim())
    .filter(Boolean);
}

function IssueList({issues}: {issues: OrganizerValidationIssue[]}) {
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

function DiffList({rows}: {rows: OrganizerDiffRow[]}) {
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

function formatDateTime(value: string | null | undefined): string {
  if (!value) return "none";
  const parsed = new Date(value);
  if (Number.isNaN(parsed.getTime())) return value;
  return parsed.toLocaleString(undefined, {
    dateStyle: "medium",
    timeStyle: "short",
  });
}
