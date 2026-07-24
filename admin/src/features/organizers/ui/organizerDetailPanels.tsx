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
  OrganizerType,
  OrganizerPublishStatus,
  OrganizerSourceConfidence,
  OrganizerVerificationStatus,
  ClubClaimDecision,
} from "../../../shared/types/adminTypes";
import {
  AdminButton,
  AdminChecklistStack,
  AdminDetailScreenStack,
  AdminDecisionFooterShell,
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
  AdminWorkbenchNote,
  AlertRow,
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
import {organizerTypeLabel} from
  "../controllers/organizerPublishingHelpers";
import {useAdminFeedback} from "../../../shared/feedback/AdminFeedbackContext";
import {organizerDirectoryPanels} from "./organizerDirectoryPanels";

const defaultPublicSiteOrigin = "https://catchdates.com";
const publicSiteOrigin = String(
  import.meta.env.VITE_ADMIN_PUBLIC_SITE_ORIGIN ?? defaultPublicSiteOrigin
).replace(/\/+$/u, "");

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
      <AdminWorkbenchNote>
        {controller.filteredRows.length} shown from {controller.rows.length} loaded
        organizers. Source generated at {formatDateTime(controller.listGeneratedAt)}.
      </AdminWorkbenchNote>
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
  const saveBlockers = countBlockingIssues(controller.validationIssues);
  const publishBlockers = countBlockingIssues(controller.publishingIssues);
  const readinessIssues = [
    ...controller.validationIssues,
    ...controller.publishingIssues,
  ].filter((issue, index, issues) =>
    issues.findIndex((candidate) => candidate.id === issue.id) === index
  );
  const blockerCount = countBlockingIssues(readinessIssues);
  const isReady = blockerCount === 0;
  return (
    <Panel
      span={2}
      icon={<Users size={18} strokeWidth={1.9} />}
      title="Readiness"
      action={isReady ? "Ready" : `${blockerCount} blockers`}
    >
      <AlertRow
        icon={isReady ?
          <CheckCircle2 size={16} strokeWidth={1.9} /> :
          <FileWarning size={16} strokeWidth={1.9} />}
        title={isReady ? "Ready for operator review" : "Resolve blockers before publishing"}
        tone={isReady ? "neutral" : "warning"}
      >
        App visibility, public-web publication, and search indexing are separate
        states. Publishing and indexing run only through the dedicated action.
      </AlertRow>
      <AdminStatusGrid>
        <StateRow label="Document" value={club?.clubId ?? controller.clubId} />
        <StateRow
          label="App · member visibility"
          value={form?.appVisibility ?? club?.appVisibility}
        />
        <StateRow
          label="Public web · publication"
          value={form?.publishStatus ?? club?.publicPage.publishStatus}
        />
        <StateRow label="Public web · indexing" value={club?.publicPage.indexStatus} />
        <StateRow label="Ownership claim" value={club?.claimState} />
        <StateRow label="Ownership state" value={club?.ownershipState} />
        <StateRow
          label="Verification"
          value={club?.provenance.verificationStatus}
        />
        <StateRow
          label="Pending field changes"
          value={`${controller.diffRows.length} pending`}
        />
        <StateRow label="Save blockers" value={saveBlockers} />
        <StateRow label="Publish blockers" value={publishBlockers} />
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
        <StateRow
          label="Source of truth"
          value="Cloud Firestore organizers/{id}"
        />
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
    <DataTable ariaLabel="Organizer directory" variant="workbench">
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
    <>
    <AdminEditorGrid>
      <AdminEditorPanel
        span={2}
        icon={<Settings2 size={18} strokeWidth={1.9} />}
        title="Canonical organizer record"
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
                  label="Organizer type"
                  onChange={(value) =>
                    update("organizerType", value as OrganizerType)}
                  options={[
                    "club",
                    "community",
                    "individual",
                    "eventProducer",
                    "venue",
                    "brand",
                  ]}
                  value={form.organizerType}
                />
                <TextField
                  label="Public category label"
                  onChange={(value) => update("publicCategoryLabel", value)}
                  value={form.publicCategoryLabel}
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
              <TextareaField
                label="Tags"
                onChange={(value) => update("tagsText", value)}
                rows={4}
                value={form.tagsText}
              />
            </AdminEditorSection>

            <AdminEditorSection>
              <legend>Ownership and contact</legend>
              <QualityList>
                <StateRow label="Claim state" value={club?.claimState ?? "Unavailable"} />
                <StateRow label="Ownership state" value={club?.ownershipState ?? "Unavailable"} />
              </QualityList>
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
              <legend>Routes and visibility</legend>
              <AlertRow
                icon={<ExternalLink size={16} strokeWidth={1.9} />}
                title="App and public web are independent"
                tone="neutral"
              >
                App visibility controls member discovery. Public-web publication
                is a separate state, and search indexing changes only through
                Save + publish.
              </AlertRow>
              <AdminFieldGrid columns={2}>
                <SelectField
                  label="App visibility"
                  onChange={(value) =>
                    update("appVisibility", value as OrganizerAppVisibility)}
                  options={["hidden", "discoverable"]}
                  value={form.appVisibility}
                />
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
                  label="Public-web publication"
                  onChange={(value) =>
                    update("publishStatus", value as OrganizerPublishStatus)}
                  options={["draft", "qa", "published", "suppressed", "removed"]}
                  value={form.publishStatus}
                />
                <StateRow
                  label="Search indexing"
                  value={`${club?.publicPage.indexStatus ?? "Unavailable"} · changed only by Save + publish`}
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
              <legend>Member-facing fields</legend>
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
              <legend>Evidence and review note</legend>
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
    <AdminDecisionFooterShell sticky>
      <div>
        <strong>{diffRows.length} pending field change{diffRows.length === 1 ? "" : "s"}</strong>
        <span>{publishDisabledReason ?? "Ready for save or publish review."}</span>
      </div>
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
    </AdminDecisionFooterShell>
    </>
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
  const readinessIssues = [...validationIssues, ...publishingIssues].filter(
    (issue, index, rows) => rows.findIndex((item) => item.id === issue.id) === index
  );
  const blockerCount = countBlockingIssues(readinessIssues);
  return (
    <AdminWorkbenchStack>
      <Panel
        icon={<FileWarning size={18} strokeWidth={1.9} />}
        title="Readiness and blockers"
        action={`${blockerCount} blockers`}
      >
        <AlertRow
          icon={blockerCount === 0 ?
            <CheckCircle2 size={16} strokeWidth={1.9} /> :
            <FileWarning size={16} strokeWidth={1.9} />}
          title={blockerCount === 0 ? "Validation is clear" : "Publishing is blocked"}
          tone={blockerCount === 0 ? "neutral" : "warning"}
        >
          This single summary combines save validation, publish validation, and
          the explicit publication checklist.
        </AlertRow>
        <IssueList issues={readinessIssues} />
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
            <StateRow label="Public-web publication" value={form.publishStatus} />
            <StateRow label="Search indexing" value={club?.publicPage.indexStatus} />
            <StateRow label="Robots" value={club?.publicPage.robots} />
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
      <StateRow
        label="Collection"
        value={`organizers/${club?.clubId ?? ""}`}
      />
      <StateRow label="App visibility" value={form.appVisibility} />
      <StateRow label="Image" value={form.imageUrl ? "imageUrl set" : "missing"} />
      <StateRow
        label="Logo"
        value={form.profileImageUrl ? "profileImageUrl set" : "missing"}
      />
      <AdminSurfacePreview>
        <strong>{form.name || "Untitled organizer"}</strong>
        <span>
          {[
            form.publicCategoryLabel || organizerTypeLabel(form.organizerType),
            location || form.location,
          ]
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

export const organizerDetailPanels = {
  OrganizerDetailView,
  OrganizerDirectoryPanel,
  OrganizerDetailSummary,
  OrganizerPublishingContractPanel,
  OrganizerDirectoryTable,
  OrganizerEditor,
  PublishingSidePanel,
  publicPreviewHref,
  AppListingPreview,
  splitPreviewList,
  IssueList,
  DiffList,
  formatDateTime,
};
