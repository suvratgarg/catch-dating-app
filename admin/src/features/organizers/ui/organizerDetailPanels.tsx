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
  AdminChecklistCopy,
  AdminChecklistHeader,
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
import {
  countIncompletePublishChecklist,
  organizerAppVisibilityOptions,
  organizerLaunchMarketOptions,
  organizerPublishStatusOptions,
  organizerPublishingFieldIds,
  organizerSourceConfidenceOptions,
  organizerTypeLabel,
  organizerTypeOptions,
  organizerVerificationStatusOptions,
  publishChecklistItems,
  updateOrganizerLaunchMarket,
} from
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
  const checklistTaskCount =
    countIncompletePublishChecklist(controller.checklist);
  const remainingTaskCount = blockerCount + checklistTaskCount;
  const isReady = remainingTaskCount === 0;
  return (
    <Panel
      span={2}
      icon={<Users size={18} strokeWidth={1.9} />}
      title="Readiness"
      action={isReady ? "Ready" : `${remainingTaskCount} tasks`}
    >
      <AlertRow
        icon={isReady ?
          <CheckCircle2 size={16} strokeWidth={1.9} /> :
          <FileWarning size={16} strokeWidth={1.9} />}
        title={isReady ?
          "Ready for operator review" :
          `${remainingTaskCount} steps before publishing`}
        tone={isReady ? "neutral" : "warning"}
      >
        App visibility, public-web publication, and search indexing are separate
        states. Required fields and the evidence checklist are shown beside the
        editor; each field blocker links to its control.
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
        <StateRow label="Checklist tasks" value={checklistTaskCount} />
      </AdminStatusGrid>
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
  const updateLaunchMarket = (marketId: string) => {
    if (!form) return;
    onFormChange(updateOrganizerLaunchMarket(form, marketId));
  };
  const hasTargetIssue = (targetId: string) =>
    publishingIssues.some((issue) =>
      issue.severity === "blocker" && issue.targetId === targetId);
  const publishBlockerCount = countBlockingIssues(publishingIssues);
  const checklistTaskCount = countIncompletePublishChecklist(checklist);
  const remainingPublishTaskCount =
    publishBlockerCount + checklistTaskCount;
  const publishDisabledReason =
    !form ? "Load an organizer before publishing." :
    remainingPublishTaskCount > 0 ?
      `${publishBlockerCount} field blocker${
        publishBlockerCount === 1 ? "" : "s"
      } · ${checklistTaskCount} checklist item${
        checklistTaskCount === 1 ? "" : "s"
      } remaining.` :
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
                  id={organizerPublishingFieldIds.name}
                  invalid={hasTargetIssue(organizerPublishingFieldIds.name)}
                  label="Name"
                  onChange={(value) => update("name", value)}
                  value={form.name}
                />
                <SelectField
                  label="Organizer type"
                  onChange={(value) =>
                    update("organizerType", value as OrganizerType)}
                  options={[...organizerTypeOptions]}
                  value={form.organizerType}
                />
                <TextField
                  label="Public listing descriptor (optional)"
                  onChange={(value) => update("publicCategoryLabel", value)}
                  value={form.publicCategoryLabel}
                />
                <TextField
                  id={organizerPublishingFieldIds.area}
                  invalid={hasTargetIssue(organizerPublishingFieldIds.area)}
                  label="Verified area / locality"
                  onChange={(value) => update("area", value)}
                  value={form.area}
                />
              </AdminFieldGrid>
              <AdminWorkbenchNote>
                Organizer type is the governed classification. The public
                listing descriptor is optional reader-facing copy, not a
                grouping category. Leave locality blank until a source
                establishes an area within the launch market.
              </AdminWorkbenchNote>
              <TextareaField
                id={organizerPublishingFieldIds.description}
                invalid={hasTargetIssue(
                  organizerPublishingFieldIds.description
                )}
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
              <SelectField
                id={organizerPublishingFieldIds.launchMarket}
                invalid={hasTargetIssue(
                  organizerPublishingFieldIds.launchMarket
                )}
                label="Launch market"
                onChange={updateLaunchMarket}
                options={[
                  ...(!organizerLaunchMarketOptions.some(
                    (option) => option.value === form.location
                  ) && form.location ?
                    [{
                      value: form.location,
                      label: `Current unsupported market · ${form.location}`,
                    }] :
                    []),
                  ...organizerLaunchMarketOptions,
                ]}
                value={form.location}
              />
              <AdminWorkbenchNote>
                This governed choice sets the canonical market, city, region,
                country, and public page city slug together.
              </AdminWorkbenchNote>
              <AdminStatusGrid compact>
                <StateRow label="Market ID" value={form.location} />
                <StateRow label="City" value={form.cityName} />
                <StateRow label="Region" value={form.regionName} />
                <StateRow
                  label="Country"
                  value={[form.countryName, form.countryCode]
                    .filter(Boolean).join(" · ")}
                />
                <StateRow
                  label="Page city slug"
                  value={form.publicPageCitySlug}
                />
              </AdminStatusGrid>
              <AdminFieldGrid columns={3}>
                <TextField
                  label="Instagram"
                  onChange={(value) => update("instagramHandle", value)}
                  value={form.instagramHandle}
                />
                <TextField
                  id={organizerPublishingFieldIds.email}
                  invalid={hasTargetIssue(organizerPublishingFieldIds.email)}
                  label="Email"
                  onChange={(value) => update("email", value)}
                  type="email"
                  value={form.email}
                />
                <TextField
                  label="Phone"
                  onChange={(value) => update("phoneNumber", value)}
                  type="tel"
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
                  options={[...organizerAppVisibilityOptions]}
                  value={form.appVisibility}
                />
                <TextField
                  id={organizerPublishingFieldIds.publicPageSlug}
                  invalid={hasTargetIssue(
                    organizerPublishingFieldIds.publicPageSlug
                  )}
                  label="Slug"
                  onChange={(value) => update("publicPageSlug", value)}
                  pattern="[a-z0-9-]+"
                  value={form.publicPageSlug}
                />
                <TextField
                  label="Page city slug"
                  onChange={() => undefined}
                  readOnly
                  value={form.publicPageCitySlug}
                />
                <TextField
                  id={organizerPublishingFieldIds.canonicalPath}
                  invalid={hasTargetIssue(
                    organizerPublishingFieldIds.canonicalPath
                  )}
                  label="Canonical path"
                  onChange={(value) => update("canonicalPath", value)}
                  value={form.canonicalPath}
                />
                <SelectField
                  label="Public-web publication"
                  onChange={(value) =>
                    update("publishStatus", value as OrganizerPublishStatus)}
                  options={[...organizerPublishStatusOptions]}
                  value={form.publishStatus}
                />
                <StateRow
                  label="Search indexing"
                  value={`${club?.publicPage.indexStatus ?? "Unavailable"} · changed only by Save + publish`}
                />
                <TextField
                  id={organizerPublishingFieldIds.imageUrl}
                  invalid={hasTargetIssue(organizerPublishingFieldIds.imageUrl)}
                  label="Image URL"
                  onChange={(value) => update("imageUrl", value)}
                  type="url"
                  value={form.imageUrl}
                />
                <TextField
                  id={organizerPublishingFieldIds.logoUrl}
                  invalid={hasTargetIssue(organizerPublishingFieldIds.logoUrl)}
                  label="Logo URL"
                  onChange={(value) => update("profileImageUrl", value)}
                  type="url"
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
                id={organizerPublishingFieldIds.headline}
                invalid={hasTargetIssue(organizerPublishingFieldIds.headline)}
                label="Headline"
                onChange={(value) => update("headline", value)}
                value={form.headline}
              />
              <TextareaField
                id={organizerPublishingFieldIds.summary}
                invalid={hasTargetIssue(organizerPublishingFieldIds.summary)}
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
                  id={organizerPublishingFieldIds.sourceConfidence}
                  invalid={hasTargetIssue(
                    organizerPublishingFieldIds.sourceConfidence
                  )}
                  label="Source confidence"
                  onChange={(value) =>
                    update("sourceConfidence", value as OrganizerSourceConfidence)}
                  options={[...organizerSourceConfidenceOptions]}
                  value={form.sourceConfidence}
                />
                <SelectField
                  id={organizerPublishingFieldIds.verificationStatus}
                  invalid={hasTargetIssue(
                    organizerPublishingFieldIds.verificationStatus
                  )}
                  label="Verification"
                  onChange={(value) =>
                    update("verificationStatus", value as OrganizerVerificationStatus)}
                  options={[...organizerVerificationStatusOptions]}
                  value={form.verificationStatus}
                />
                <TextareaField
                  id={organizerPublishingFieldIds.reviewNote}
                  invalid={hasTargetIssue(
                    organizerPublishingFieldIds.reviewNote
                  )}
                  label="Review note"
                  onChange={(value) => update("reviewNote", value)}
                  rows={3}
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
    <AdminDecisionFooterShell
      layout="publishing-actions"
      sticky
    >
      <div>
        <strong>{diffRows.length} pending field change{diffRows.length === 1 ? "" : "s"}</strong>
        <span>{publishDisabledReason ?? "Ready for save or publish review."}</span>
      </div>
      {remainingPublishTaskCount > 0 && (
        <AdminButton
          onClick={() => focusOrganizerPublishingTarget(
            "organizer-publishing-readiness"
          )}
        >
          Review {remainingPublishTaskCount} tasks
        </AdminButton>
      )}
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
  const checklistTaskCount = countIncompletePublishChecklist(checklist);
  const remainingTaskCount = blockerCount + checklistTaskCount;
  return (
    <AdminWorkbenchStack alignStart>
      <div id="organizer-publishing-readiness">
        <Panel
          icon={<FileWarning size={18} strokeWidth={1.9} />}
          title="Readiness and blockers"
          action={remainingTaskCount === 0 ?
            "Ready" :
            `${remainingTaskCount} tasks`}
        >
        <AlertRow
          icon={remainingTaskCount === 0 ?
            <CheckCircle2 size={16} strokeWidth={1.9} /> :
            <FileWarning size={16} strokeWidth={1.9} />}
          title={remainingTaskCount === 0 ?
            "Ready for final operator review" :
            `${blockerCount} fields · ${checklistTaskCount} checks remaining`}
          tone={remainingTaskCount === 0 ? "neutral" : "warning"}
        >
          Fix required fields first, then confirm each evidence check. Selecting
          a blocker moves focus to the owning control.
        </AlertRow>
        <IssueList
          issues={readinessIssues}
          onResolve={focusOrganizerPublishingIssue}
        />
        <AdminChecklistHeader
          label="Publication checklist"
          detail={<>{publishChecklistItems.length - checklistTaskCount} of {
            publishChecklistItems.length
          } complete</>}
        />
        <AdminChecklistStack>
          {publishChecklistItems.map((item) => (
            <CheckboxField
              checked={checklist[item.key]}
              key={item.key}
              label={(
                <AdminChecklistCopy
                  detail={item.detail}
                  label={item.label}
                />
              )}
              onChange={(checked) =>
                onChecklistChange({...checklist, [item.key]: checked})}
            />
          ))}
        </AdminChecklistStack>
        </Panel>
      </div>
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
  const tags = [...new Set([
    ...splitPreviewList(form.tagsText),
    ...splitPreviewList(form.formatsText),
  ])].slice(0, 6);
  return (
    <QualityList>
      <StateRow
        label="Record ID"
        value={club?.clubId}
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

function IssueList({
  issues,
  onResolve,
}: {
  issues: OrganizerValidationIssue[];
  onResolve: (issue: OrganizerValidationIssue) => void;
}) {
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
        <AdminRoadmapListItem
          actionable
          key={issue.id}
          tone={issue.severity}
        >
          <FileWarning size={15} strokeWidth={1.9} />
          <span>
            <strong>{issue.label}:</strong> {issue.detail}
          </span>
          {issue.targetId && (
            <AdminButton
              onClick={() => onResolve(issue)}
              variant="link"
            >
              Go to field
            </AdminButton>
          )}
        </AdminRoadmapListItem>
      ))}
    </AdminRoadmapList>
  );
}

function focusOrganizerPublishingIssue(issue: OrganizerValidationIssue) {
  if (!issue.targetId) return;
  focusOrganizerPublishingTarget(issue.targetId);
}

function focusOrganizerPublishingTarget(targetId: string) {
  const target = document.getElementById(targetId);
  if (!target) return;
  target.scrollIntoView({behavior: "smooth", block: "center"});
  if (target instanceof HTMLElement) target.focus({preventScroll: true});
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
