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
  Users,
} from "lucide-react";
import type {
  AdminClubDetails,
  AdminClubListRow,
  OrganizerAppVisibility,
  OrganizerEntityKind,
  OrganizerPublishStatus,
  OrganizerSourceConfidence,
  OrganizerVerificationStatus,
} from "../../../shared/types/adminTypes";
import {
  AdminButton,
  AdminLinkButton,
  AdminTag,
  CheckboxField,
  DataTable,
  EmptyState,
  PageHeader,
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
  countBlockingIssues,
  countDiffRows,
  organizerNeedsPublish,
  type OrganizerPublishingFilter,
  useOrganizerPublishingController,
} from "../controllers/useOrganizerPublishingController";
import type {
  OrganizerDiffRow,
  OrganizerPublishingFormState,
  OrganizerValidationIssue,
  PublishChecklistState,
} from "../controllers/organizerPublishingHelpers";

type OrganizerPublishingController = ReturnType<
  typeof useOrganizerPublishingController
>;

const defaultPublicSiteOrigin = "https://catchdates.com";
const publicSiteOrigin = String(
  import.meta.env.VITE_ADMIN_PUBLIC_SITE_ORIGIN ?? defaultPublicSiteOrigin
).replace(/\/+$/u, "");

export function OrganizerPublishingScreen({
  onError,
  onNotice,
}: {
  onError: (message: string | null) => void;
  onNotice: (message: string | null) => void;
}) {
  const controller = useOrganizerPublishingController({onError, onNotice});
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
      controller={controller}
      needsPublishCount={needsPublishCount}
      publishedCount={publishedCount}
      routeIssueCount={routeIssueCount}
      searchIssueCount={searchIssueCount}
    />
  );
}

function OrganizerDirectoryView({
  controller,
  needsPublishCount,
  publishedCount,
  routeIssueCount,
  searchIssueCount,
}: {
  controller: OrganizerPublishingController;
  needsPublishCount: number;
  publishedCount: number;
  routeIssueCount: number;
  searchIssueCount: number;
}) {
  return (
    <div className="workbench-stack admin-directory-screen">
      <PageHeader eyebrow="Organizers" title="Canonical Organizer Directory" />
      <section className="metric-grid" aria-label="Organizer publishing state">
        <Metric label="Canonical organizers" value={controller.rows.length} />
        <Metric
          label="Needs review work"
          tone={needsPublishCount > 0 ? "attention" : "normal"}
          value={needsPublishCount}
        />
        <Metric label="Published" value={publishedCount} />
        <Metric
          label="Route issues"
          tone={routeIssueCount > 0 ? "attention" : "normal"}
          value={routeIssueCount}
        />
        <Metric
          label="Search issues"
          tone={searchIssueCount > 0 ? "attention" : "normal"}
          value={searchIssueCount}
        />
      </section>

      <OrganizerDirectoryPanel controller={controller} />
    </div>
  );
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
    <div className="workbench-stack admin-detail-screen">
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
    </div>
  );
}

function OrganizerDirectoryPanel({
  controller,
}: {
  controller: OrganizerPublishingController;
}) {
  return (
    <Panel
      className="span-2"
      icon={<Users size={18} strokeWidth={1.9} />}
      title="Canonical organizer directory"
      action={
        controller.isListLoading ?
          "Loading" :
          `${controller.filteredRows.length} shown`
      }
    >
      <div className="workbench-toolbar">
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
      </div>
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
      className="span-2"
      icon={<Users size={18} strokeWidth={1.9} />}
      title="Profile status"
      action={club?.publicPage.publishStatus ?? "Not loaded"}
    >
      <div className="admin-status-grid">
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
      </div>
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
      <div className="quality-list">
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
      </div>
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
        className="workbench-empty"
        icon={<FolderSearch size={16} strokeWidth={1.9} />}
      >
        No canonical organizers match this filter.
      </EmptyState>
    );
  }
  return (
    <DataTable className="workbench-table">
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
          <tr
            className={selectedClubId === row.clubId ? "selected-row" : ""}
            key={row.clubId}
          >
            <td>
              <div className="row-title">
                <strong>{row.name}</strong>
                <span>{row.clubId}</span>
              </div>
            </td>
            <td>
              <div className="row-title compact">
                <span>{row.cityName ?? "Unknown city"}</span>
                <span>{row.citySlug ?? "No city slug"}</span>
              </div>
            </td>
            <td>
              <div className="row-title compact">
                <span>{row.canonicalPath ?? "No public path"}</span>
                <span>{row.publishStatus ?? "no status"} / {row.indexStatus ?? "no index"}</span>
              </div>
            </td>
            <td>
              <div className="tag-row">
                <AdminTag tone="muted">{row.appVisibility ?? "unset"}</AdminTag>
                <AdminTag tone="muted">{row.claimState ?? "no claim"}</AdminTag>
              </div>
            </td>
            <td>
              <div className="tag-row">
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
              </div>
            </td>
            <td>
              <TableActionButton onClick={() => onSelect(row.clubId)}>
                {selectedClubId === row.clubId ? "Selected" : "Open"}
              </TableActionButton>
            </td>
          </tr>
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
    <section className="publishing-editor-grid">
      <Panel
        className="span-2 publishing-editor-panel"
        icon={<Settings2 size={18} strokeWidth={1.9} />}
        title="Canonical publisher"
        action={club?.clubId ?? "No organizer loaded"}
      >
        <div className="publishing-loadbar">
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
        </div>

        {form ? (
          <form className="publishing-form">
            <fieldset className="editor-section">
              <legend>Identity</legend>
              <div className="form-grid two">
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
              </div>
              <TextareaField
                label="Description"
                onChange={(value) => update("description", value)}
                rows={4}
                value={form.description}
              />
              <div className="form-grid two">
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
              </div>
            </fieldset>

            <fieldset className="editor-section">
              <legend>Location And Contact</legend>
              <div className="form-grid three">
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
              </div>
            </fieldset>

            <fieldset className="editor-section">
              <legend>Public Page</legend>
              <div className="form-grid two">
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
              </div>
            </fieldset>

            <fieldset className="editor-section">
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
              <div className="form-grid three">
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
              </div>
            </fieldset>

            <fieldset className="editor-section">
              <legend>Review State</legend>
              <div className="form-grid three">
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
              </div>
            </fieldset>
          </form>
        ) : (
          <EmptyState
            className="empty-editor"
            icon={<Clock3 size={16} strokeWidth={1.9} />}
          >
            Load an organizer document to review canonical fields.
          </EmptyState>
        )}
      </Panel>

      <PublishingSidePanel
        checklist={checklist}
        club={club}
        diffRows={diffRows}
        form={form}
        onChecklistChange={onChecklistChange}
        publishingIssues={publishingIssues}
        validationIssues={validationIssues}
      />
    </section>
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
    <div className="workbench-stack">
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
        <div className="checklist-stack">
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
        </div>
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
          <div className="quality-list">
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
          </div>
        ) : (
          <EmptyState icon={<Clock3 size={16} strokeWidth={1.9} />}>
            No organizer loaded
          </EmptyState>
        )}
      </Panel>
    </div>
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
    <div className="quality-list">
      <StateRow label="Collection" value={`clubs/${club?.clubId ?? ""}`} />
      <StateRow label="App visibility" value={form.appVisibility} />
      <StateRow label="Image" value={form.imageUrl ? "imageUrl set" : "missing"} />
      <StateRow
        label="Logo"
        value={form.profileImageUrl ? "profileImageUrl set" : "missing"}
      />
      <div className="surface-preview">
        <strong>{form.name || "Untitled organizer"}</strong>
        <span>
          {[form.displayCategory, location || form.location]
            .filter(Boolean)
            .join(" · ")}
        </span>
        <span>{form.headline || form.summary || form.description}</span>
        {tags.length > 0 && (
          <div className="tag-row">
            {tags.map((tag) => (
              <AdminTag key={tag} tone="muted">{tag}</AdminTag>
            ))}
          </div>
        )}
      </div>
    </div>
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

function DiffList({rows}: {rows: OrganizerDiffRow[]}) {
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
  const parsed = new Date(value);
  if (Number.isNaN(parsed.getTime())) return value;
  return parsed.toLocaleString(undefined, {
    dateStyle: "medium",
    timeStyle: "short",
  });
}
