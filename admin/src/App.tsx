import {useCallback, useEffect, useMemo, useState} from "react";
import type {ReactNode} from "react";
import {
  Activity,
  AlertTriangle,
  BarChart3,
  CheckCircle2,
  CircleDollarSign,
  Clock3,
  Database,
  FileWarning,
  FolderSearch,
  LineChart,
  Lock,
  RefreshCw,
  Save,
  Search,
  Settings2,
  ShieldAlert,
  Sparkles,
  UserCheck,
  Users,
} from "lucide-react";
import {onAuthStateChanged, User} from "firebase/auth";
import {auth, signInWithGoogle, signOutAdmin} from "./firebase";
import {
  dataMode,
  decideAccessApplication,
  decideClubClaim,
  loadClubDetails,
  loadOverview,
  saveClubDetails,
  setClubIndexStatus,
} from "./adminApi";
import {
  eventRows,
  hostGrowth,
  retentionPoints,
  sampleOverview,
} from "./sampleData";
import {
  AccessApplicationDecision,
  AdminClubDetails,
  AdminOverviewMetric,
  AdminOverviewResponse,
  AdminQueueItem,
  AdminUpdateClubDetailsPayload,
  ClubClaimDecision,
  ClubIndexDecision,
  OrganizerAppVisibility,
  OrganizerEntityKind,
  OrganizerPublishStatus,
  OrganizerSourceConfidence,
  OrganizerVerificationStatus,
} from "./types";

const navigation = [
  {id: "overview", label: "Overview", icon: Activity},
  {id: "safety", label: "Safety", icon: ShieldAlert},
  {id: "access", label: "Access", icon: UserCheck},
  {id: "growth", label: "Growth", icon: LineChart},
  {id: "hosts", label: "Hosts", icon: Users},
  {id: "events", label: "Events", icon: BarChart3},
  {id: "users", label: "Users", icon: Sparkles},
  {id: "finance", label: "Finance", icon: CircleDollarSign},
  {id: "quality", label: "Data quality", icon: Database},
];

const priorityMetricIds = [
  "signupsToday",
  "signupsThisWeek",
  "openReports",
  "pendingApplications",
  "pendingClubClaims",
  "indexReviewPages",
  "activeHosts",
  "failedPayments",
];

interface OrganizerDetailsFormState {
  clubId: string;
  name: string;
  description: string;
  location: string;
  area: string;
  tagsText: string;
  instagramHandle: string;
  phoneNumber: string;
  email: string;
  imageUrl: string;
  profileImageUrl: string;
  entityKind: OrganizerEntityKind;
  entitySubtypesText: string;
  displayCategory: string;
  cityName: string;
  regionName: string;
  countryCode: string;
  countryName: string;
  appVisibility: OrganizerAppVisibility;
  publicPageSlug: string;
  publicPageCitySlug: string;
  canonicalPath: string;
  publishStatus: OrganizerPublishStatus;
  seoTitle: string;
  seoDescription: string;
  sourceConfidence: OrganizerSourceConfidence;
  verificationStatus: OrganizerVerificationStatus;
  headline: string;
  summary: string;
  sourceSummary: string;
  formatsText: string;
  fitNotesText: string;
  missingEvidenceText: string;
  reviewNote: string;
}

export function App() {
  const mode = dataMode();
  const [activeNav, setActiveNav] = useState("overview");
  const [activeRange, setActiveRange] = useState("7d");
  const [overview, setOverview] =
    useState<AdminOverviewResponse>(sampleOverview);
  const [isLoading, setIsLoading] = useState(false);
  const [decisionInFlight, setDecisionInFlight] =
    useState<Record<string, AccessApplicationDecision>>({});
  const [claimDecisionInFlight, setClaimDecisionInFlight] =
    useState<Record<string, ClubClaimDecision>>({});
  const [indexDecisionInFlight, setIndexDecisionInFlight] =
    useState<Record<string, ClubIndexDecision>>({});
  const [clubDetailsId, setClubDetailsId] =
    useState("afterfly-run-club-indore");
  const [clubDetails, setClubDetails] =
    useState<AdminClubDetails | null>(null);
  const [clubDetailsForm, setClubDetailsForm] =
    useState<OrganizerDetailsFormState | null>(null);
  const [isClubDetailsLoading, setIsClubDetailsLoading] = useState(false);
  const [isClubDetailsSaving, setIsClubDetailsSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [notice, setNotice] = useState<string | null>(null);
  const [user, setUser] = useState<User | null>(null);

  useEffect(() => {
    if (mode === "sample") return undefined;
    return onAuthStateChanged(auth, setUser);
  }, [mode]);

  const refresh = useCallback(async () => {
    setIsLoading(true);
    setError(null);
    try {
      setOverview(await loadOverview());
    } catch (loadError) {
      setError(
        loadError instanceof Error ?
          loadError.message :
          "Unable to load admin overview."
      );
    } finally {
      setIsLoading(false);
    }
  }, []);

  useEffect(() => {
    if (mode === "live" && !user) return;
    void refresh();
  }, [mode, refresh, user]);

  const handleLoadClubDetails = useCallback(async (clubId: string) => {
    const normalizedClubId = clubId.trim();
    if (!normalizedClubId) {
      setError("Enter an organizer document id.");
      return;
    }
    setIsClubDetailsLoading(true);
    setError(null);
    setNotice(null);
    try {
      const response = await loadClubDetails({clubId: normalizedClubId});
      setClubDetails(response.club);
      setClubDetailsForm(formFromClubDetails(response.club));
      setClubDetailsId(response.club.clubId);
    } catch (loadError) {
      setError(
        loadError instanceof Error ?
          loadError.message :
          "Unable to load organizer details."
      );
    } finally {
      setIsClubDetailsLoading(false);
    }
  }, []);

  useEffect(() => {
    if (mode === "live" && !user) return;
    if (activeNav !== "hosts" || clubDetailsForm) return;
    void handleLoadClubDetails(clubDetailsId);
  }, [
    activeNav,
    clubDetailsForm,
    clubDetailsId,
    handleLoadClubDetails,
    mode,
    user,
  ]);

  const handleSaveClubDetails = useCallback(async () => {
    if (!clubDetailsForm) {
      setError("Load an organizer before saving.");
      return;
    }
    setIsClubDetailsSaving(true);
    setError(null);
    setNotice(null);
    try {
      const payload = payloadFromOrganizerDetailsForm(clubDetailsForm);
      const result = await saveClubDetails(payload);
      const refreshed = await loadClubDetails({clubId: result.clubId});
      setClubDetails(refreshed.club);
      setClubDetailsForm(formFromClubDetails(refreshed.club));
      setNotice(
        `Saved ${result.updatedFieldCount} organizer detail fields.`
      );
      if (mode === "live") void refresh();
    } catch (saveError) {
      setError(
        saveError instanceof Error ?
          saveError.message :
          "Unable to save organizer details."
      );
    } finally {
      setIsClubDetailsSaving(false);
    }
  }, [clubDetailsForm, mode, refresh]);

  const primaryMetrics = useMemo(
    () => priorityMetricIds
      .map((id) => overview.metrics.find((metric) => metric.id === id))
      .filter((metric): metric is AdminOverviewMetric => Boolean(metric)),
    [overview.metrics]
  );

  const handleAccessDecision = useCallback(async (
    item: AdminQueueItem,
    decision: AccessApplicationDecision
  ) => {
    const applicationUid = applicationUidFromTargetPath(item.targetPath);
    if (!applicationUid) {
      setError("Cannot decide an access application without a valid target.");
      return;
    }

    setDecisionInFlight((current) => ({
      ...current,
      [item.targetPath]: decision,
    }));
    setError(null);
    setNotice(null);

    try {
      await decideAccessApplication({applicationUid, decision});
      setOverview((current) =>
        removeAccessApplication(current, item.targetPath)
      );
      setNotice(
        `${decision === "approve" ? "Approved" : "Denied"} ${item.title}.`
      );
      if (mode === "live") void refresh();
    } catch (decisionError) {
      setError(
        decisionError instanceof Error ?
          decisionError.message :
          "Unable to review access application."
      );
    } finally {
      setDecisionInFlight((current) => {
        const next = {...current};
        delete next[item.targetPath];
        return next;
      });
    }
  }, [mode, refresh]);

  const handleClubClaimDecision = useCallback(async (
    item: AdminQueueItem,
    decision: ClubClaimDecision
  ) => {
    const requestId = clubClaimRequestIdFromTargetPath(item.targetPath);
    if (!requestId) {
      setError("Cannot decide an organizer claim without a valid request.");
      return;
    }

    setClaimDecisionInFlight((current) => ({
      ...current,
      [item.targetPath]: decision,
    }));
    setError(null);
    setNotice(null);

    try {
      await decideClubClaim({requestId, decision});
      setOverview((current) =>
        removeClubClaimRequest(current, item.targetPath)
      );
      setNotice(
        `${decision === "approve" ? "Approved" : "Rejected"} ${item.title}.`
      );
      if (mode === "live") void refresh();
    } catch (decisionError) {
      setError(
        decisionError instanceof Error ?
          decisionError.message :
          "Unable to review organizer claim."
      );
    } finally {
      setClaimDecisionInFlight((current) => {
        const next = {...current};
        delete next[item.targetPath];
        return next;
      });
    }
  }, [mode, refresh]);

  const handleClubIndexDecision = useCallback(async (
    item: AdminQueueItem,
    decision: ClubIndexDecision
  ) => {
    const clubId = clubIdFromTargetPath(item.targetPath);
    if (!clubId) {
      setError("Cannot review indexing without a valid organizer profile.");
      return;
    }

    setIndexDecisionInFlight((current) => ({
      ...current,
      [item.targetPath]: decision,
    }));
    setError(null);
    setNotice(null);

    try {
      await setClubIndexStatus({
        clubId,
        indexStatus: decision,
        checklist: decision === "indexReady" ?
          completeIndexChecklist() :
          emptyIndexChecklist(),
        reviewNote: decision === "indexReady" ?
          "Admin marked source evidence, media rights, cadence, and owner/contact checks complete." :
          "Admin kept this organizer page noindex from the overview queue.",
      });
      setOverview((current) =>
        removeClubIndexReview(current, item.targetPath)
      );
      setNotice(
        `${decision === "indexReady" ? "Marked index-ready" : "Kept noindex"} ${item.title}.`
      );
      if (mode === "live") void refresh();
    } catch (decisionError) {
      setError(
        decisionError instanceof Error ?
          decisionError.message :
          "Unable to review organizer indexing."
      );
    } finally {
      setIndexDecisionInFlight((current) => {
        const next = {...current};
        delete next[item.targetPath];
        return next;
      });
    }
  }, [mode, refresh]);

  if (mode === "live" && !user) {
    return <SignInScreen onSignIn={() => void signInWithGoogle()} />;
  }

  return (
    <div className="app-shell">
      <aside className="sidebar" aria-label="Admin sections">
        <div className="brand-block">
          <div className="brand-mark">C</div>
          <div>
            <div className="brand-title">Catch Ops</div>
            <div className="brand-subtitle">{mode} console</div>
          </div>
        </div>
        <nav className="nav-list">
          {navigation.map((item) => {
            const Icon = item.icon;
            const selected = activeNav === item.id;
            return (
              <button
                className={`nav-item ${selected ? "selected" : ""}`}
                key={item.id}
                onClick={() => setActiveNav(item.id)}
                type="button"
              >
                <Icon aria-hidden="true" size={17} strokeWidth={1.8} />
                <span>{item.label}</span>
              </button>
            );
          })}
        </nav>
        <div className="sidebar-footer">
          <Lock size={15} strokeWidth={1.8} />
          <span>Admin claim required</span>
        </div>
      </aside>

      <main className="workspace">
        <header className="topbar">
          <div>
            <h1>{activeNav === "hosts" ? "Organizer details" : "Overview"}</h1>
            <p>
              {activeNav === "hosts" ?
                "Review and clean up canonical organizer fields before publishing, indexing, or claim handoff." :
                "Live operations, cohort health, finance risk, and marketplace signals."}
            </p>
          </div>
          <div className="topbar-actions">
            <div className="search-control">
              <Search size={16} strokeWidth={1.8} />
              <input aria-label="Search users or events" placeholder="Search user, host, event" />
            </div>
            <select aria-label="Environment" defaultValue="dev">
              <option value="dev">Dev</option>
              <option value="staging">Staging</option>
              <option value="prod">Prod</option>
            </select>
            <div className="segmented" aria-label="Time range">
              {["24h", "7d", "30d"].map((range) => (
                <button
                  className={activeRange === range ? "selected" : ""}
                  key={range}
                  onClick={() => setActiveRange(range)}
                  type="button"
                >
                  {range}
                </button>
              ))}
            </div>
            <button
              className="icon-button"
              disabled={isLoading}
              onClick={() => void refresh()}
              title="Refresh"
              type="button"
            >
              <RefreshCw
                className={isLoading ? "spin" : ""}
                size={17}
                strokeWidth={1.9}
              />
            </button>
            {mode === "live" && (
              <button className="ghost-button" onClick={() => void signOutAdmin()} type="button">
                Sign out
              </button>
            )}
          </div>
        </header>

        {error && (
          <div className="error-banner" role="alert">
            <AlertTriangle size={17} strokeWidth={1.9} />
            <span>{error}</span>
          </div>
        )}
        {notice && (
          <div className="success-banner" role="status">
            <CheckCircle2 size={17} strokeWidth={1.9} />
            <span>{notice}</span>
          </div>
        )}

        {activeNav === "hosts" ? (
          <OrganizerDetailsScreen
            club={clubDetails}
            clubId={clubDetailsId}
            form={clubDetailsForm}
            isLoading={isClubDetailsLoading}
            isSaving={isClubDetailsSaving}
            onClubIdChange={setClubDetailsId}
            onFormChange={setClubDetailsForm}
            onLoad={() => void handleLoadClubDetails(clubDetailsId)}
            onSave={() => void handleSaveClubDetails()}
          />
        ) : (
          <>
            <section className="metric-grid" aria-label="Key metrics">
              {primaryMetrics.map((metric) => (
                <MetricTile key={metric.id} metric={metric} />
              ))}
            </section>

            <section className="main-grid">
              <Panel
                className="span-2"
                icon={<ShieldAlert size={18} strokeWidth={1.9} />}
                title="Live queues"
                action={`${queueCount(overview)} open`}
              >
                <div className="queue-columns">
                  <QueueList
                    intent="danger"
                    items={[
                      ...overview.queues.safetyReports,
                      ...overview.queues.eventSafetyReports,
                    ]}
                    title="Safety reports"
                  />
                  <QueueList
                    decisionInFlight={decisionInFlight}
                    intent="warning"
                    items={overview.queues.accessApplications}
                    onAccessDecision={handleAccessDecision}
                    title="Access applications"
                  />
                  <QueueList
                    claimDecisionInFlight={claimDecisionInFlight}
                    intent="neutral"
                    items={overview.queues.clubClaimRequests}
                    onClubClaimDecision={handleClubClaimDecision}
                    title="Organizer claims"
                  />
                  <QueueList
                    indexDecisionInFlight={indexDecisionInFlight}
                    intent="neutral"
                    items={overview.queues.clubIndexReviews}
                    onClubIndexDecision={handleClubIndexDecision}
                    title="Index reviews"
                  />
                  <QueueList
                    intent="neutral"
                    items={[
                      ...overview.queues.moderationFlags,
                      ...overview.queues.paymentIssues,
                    ]}
                    title="Moderation and payments"
                  />
                </div>
              </Panel>

              <Panel
                icon={<LineChart size={18} strokeWidth={1.9} />}
                title="Cohort retention"
                action="M1 58%"
              >
                <LineMiniChart points={retentionPoints} />
              </Panel>

              <Panel
                icon={<Users size={18} strokeWidth={1.9} />}
                title="Host MoM growth"
                action="+21%"
              >
                <BarMiniChart points={hostGrowth} />
              </Panel>

              <Panel
                className="span-2"
                icon={<BarChart3 size={18} strokeWidth={1.9} />}
                title="Event performance"
                action="Top active events"
              >
                <EventPerformanceTable />
              </Panel>

              <Panel
                icon={<Sparkles size={18} strokeWidth={1.9} />}
                title="User value signals"
                action="Draft model"
              >
                <ValueSignals />
              </Panel>

              <Panel
                icon={<Database size={18} strokeWidth={1.9} />}
                title="Data quality"
                action={overview.timezone}
              >
                <DataQualityRows overview={overview} />
              </Panel>
            </section>
          </>
        )}
      </main>
    </div>
  );
}

function SignInScreen({onSignIn}: {onSignIn: () => void}) {
  return (
    <main className="signin-screen">
      <section className="signin-panel">
        <div className="brand-mark large">C</div>
        <h1>Catch Ops</h1>
        <p>Internal admin access requires Firebase Auth and an admin claim.</p>
        <button className="primary-button" onClick={onSignIn} type="button">
          Sign in with Google
        </button>
      </section>
    </main>
  );
}

function MetricTile({metric}: {metric: AdminOverviewMetric}) {
  const tone = metric.id.includes("failed") ||
    metric.id.includes("Reports") ||
    metric.id.includes("Applications") ?
    "attention" :
    "normal";
  return (
    <article className={`metric-tile ${tone}`}>
      <div className="metric-label">{metric.label}</div>
      <div className="metric-value">
        {metric.value.toLocaleString()}
        {metric.unit && <span>{metric.unit}</span>}
      </div>
    </article>
  );
}

function Panel({
  action,
  children,
  className = "",
  icon,
  title,
}: {
  action: string;
  children: ReactNode;
  className?: string;
  icon: ReactNode;
  title: string;
}) {
  return (
    <section className={`panel ${className}`}>
      <header className="panel-header">
        <div className="panel-title">
          {icon}
          <h2>{title}</h2>
        </div>
        <span>{action}</span>
      </header>
      {children}
    </section>
  );
}

function OrganizerDetailsScreen({
  club,
  clubId,
  form,
  isLoading,
  isSaving,
  onClubIdChange,
  onFormChange,
  onLoad,
  onSave,
}: {
  club: AdminClubDetails | null;
  clubId: string;
  form: OrganizerDetailsFormState | null;
  isLoading: boolean;
  isSaving: boolean;
  onClubIdChange: (clubId: string) => void;
  onFormChange: (form: OrganizerDetailsFormState | null) => void;
  onLoad: () => void;
  onSave: () => void;
}) {
  const update = <K extends keyof OrganizerDetailsFormState>(
    key: K,
    value: OrganizerDetailsFormState[K]
  ) => {
    if (!form) return;
    onFormChange({...form, [key]: value});
  };

  return (
    <section className="organizer-editor-grid">
      <Panel
        className="span-2 organizer-editor-panel"
        icon={<Settings2 size={18} strokeWidth={1.9} />}
        title="Organizer editor"
        action={club?.clubId ?? "No organizer loaded"}
      >
        <div className="organizer-loadbar">
          <label>
            <span>Document ID</span>
            <input
              aria-label="Organizer document id"
              onChange={(event) => onClubIdChange(event.target.value)}
              value={clubId}
            />
          </label>
          <button
            className="ghost-button"
            disabled={isLoading}
            onClick={onLoad}
            type="button"
          >
            <FolderSearch size={15} strokeWidth={1.9} />
            {isLoading ? "Loading" : "Load"}
          </button>
          <button
            className="primary-button"
            disabled={!form || isSaving}
            onClick={onSave}
            type="button"
          >
            <Save size={15} strokeWidth={1.9} />
            {isSaving ? "Saving" : "Save"}
          </button>
        </div>

        {form ? (
          <form className="organizer-form">
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
                    update(
                      "sourceConfidence",
                      value as OrganizerSourceConfidence
                    )}
                  options={["seedOnly", "low", "medium", "high", "ownerVerified"]}
                  value={form.sourceConfidence}
                />
                <SelectField
                  label="Verification"
                  onChange={(value) =>
                    update(
                      "verificationStatus",
                      value as OrganizerVerificationStatus
                    )}
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
          <div className="empty-editor">
            <FolderSearch size={18} strokeWidth={1.9} />
            <span>Load an organizer document to review details.</span>
          </div>
        )}
      </Panel>

      <Panel
        icon={<Database size={18} strokeWidth={1.9} />}
        title="Current state"
        action={club?.publicPage.indexStatus ?? "No page"}
      >
        {club ? (
          <div className="organizer-state-list">
            <StateRow label="Claim" value={club.claimState} />
            <StateRow label="Ownership" value={club.ownershipState} />
            <StateRow label="Origin" value={club.provenance.origin} />
            <StateRow label="Index" value={club.publicPage.indexStatus} />
            <StateRow label="Robots" value={club.publicPage.robots} />
            <StateRow label="Canonical" value={club.publicPage.canonicalPath} />
          </div>
        ) : (
          <div className="empty-row">
            <Clock3 size={16} strokeWidth={1.9} />
            <span>No organizer loaded</span>
          </div>
        )}
      </Panel>
    </section>
  );
}

function TextField({
  label,
  onChange,
  value,
}: {
  label: string;
  onChange: (value: string) => void;
  value: string;
}) {
  return (
    <label className="field-control">
      <span>{label}</span>
      <input onChange={(event) => onChange(event.target.value)} value={value} />
    </label>
  );
}

function TextareaField({
  label,
  onChange,
  rows,
  value,
}: {
  label: string;
  onChange: (value: string) => void;
  rows: number;
  value: string;
}) {
  return (
    <label className="field-control">
      <span>{label}</span>
      <textarea
        onChange={(event) => onChange(event.target.value)}
        rows={rows}
        value={value}
      />
    </label>
  );
}

function SelectField({
  label,
  onChange,
  options,
  value,
}: {
  label: string;
  onChange: (value: string) => void;
  options: string[];
  value: string;
}) {
  return (
    <label className="field-control">
      <span>{label}</span>
      <select onChange={(event) => onChange(event.target.value)} value={value}>
        {options.map((option) => (
          <option key={option} value={option}>{option}</option>
        ))}
      </select>
    </label>
  );
}

function StateRow({
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

function QueueList({
  claimDecisionInFlight = {},
  decisionInFlight = {},
  indexDecisionInFlight = {},
  intent,
  items,
  onAccessDecision,
  onClubClaimDecision,
  onClubIndexDecision,
  title,
}: {
  claimDecisionInFlight?: Record<string, ClubClaimDecision>;
  decisionInFlight?: Record<string, AccessApplicationDecision>;
  indexDecisionInFlight?: Record<string, ClubIndexDecision>;
  intent: "danger" | "warning" | "neutral";
  items: AdminQueueItem[];
  onAccessDecision?: (
    item: AdminQueueItem,
    decision: AccessApplicationDecision
  ) => void;
  onClubClaimDecision?: (
    item: AdminQueueItem,
    decision: ClubClaimDecision
  ) => void;
  onClubIndexDecision?: (
    item: AdminQueueItem,
    decision: ClubIndexDecision
  ) => void;
  title: string;
}) {
  return (
    <div className="queue-list">
      <div className="queue-heading">
        <span>{title}</span>
        <strong>{items.length}</strong>
      </div>
      <div className="queue-items">
        {items.length === 0 ? (
          <div className="empty-row">
            <CheckCircle2 size={16} strokeWidth={1.9} />
            <span>Clear</span>
          </div>
        ) : (
          items.slice(0, 3).map((item) => (
            <QueueRow
              claimDecisionInFlight={claimDecisionInFlight[item.targetPath]}
              decisionInFlight={decisionInFlight[item.targetPath]}
              indexDecisionInFlight={indexDecisionInFlight[item.targetPath]}
              intent={intent}
              item={item}
              key={item.id}
              onAccessDecision={onAccessDecision}
              onClubClaimDecision={onClubClaimDecision}
              onClubIndexDecision={onClubIndexDecision}
            />
          ))
        )}
      </div>
    </div>
  );
}

function QueueRow({
  claimDecisionInFlight,
  decisionInFlight,
  indexDecisionInFlight,
  intent,
  item,
  onAccessDecision,
  onClubClaimDecision,
  onClubIndexDecision,
}: {
  claimDecisionInFlight?: ClubClaimDecision;
  decisionInFlight?: AccessApplicationDecision;
  indexDecisionInFlight?: ClubIndexDecision;
  intent: "danger" | "warning" | "neutral";
  item: AdminQueueItem;
  onAccessDecision?: (
    item: AdminQueueItem,
    decision: AccessApplicationDecision
  ) => void;
  onClubClaimDecision?: (
    item: AdminQueueItem,
    decision: ClubClaimDecision
  ) => void;
  onClubIndexDecision?: (
    item: AdminQueueItem,
    decision: ClubIndexDecision
  ) => void;
}) {
  const isDeciding = Boolean(
    decisionInFlight ||
    claimDecisionInFlight ||
    indexDecisionInFlight
  );
  return (
    <article className={`queue-row ${intent}`}>
      <div>
        <h3>{item.title}</h3>
        <p>{item.detail}</p>
      </div>
      <div className="queue-row-actions">
        <span>{relativeTime(item.createdAt)}</span>
        {intent === "warning" && onAccessDecision && (
          <div className="decision-actions">
            <button
              disabled={isDeciding}
              onClick={() => onAccessDecision(item, "approve")}
              type="button"
            >
              {decisionInFlight === "approve" ? "Approving" : "Approve"}
            </button>
            <button
              disabled={isDeciding}
              onClick={() => onAccessDecision(item, "deny")}
              type="button"
            >
              {decisionInFlight === "deny" ? "Denying" : "Deny"}
            </button>
          </div>
        )}
        {onClubClaimDecision && (
          <div className="decision-actions">
            <button
              disabled={isDeciding}
              onClick={() => onClubClaimDecision(item, "approve")}
              type="button"
            >
              {claimDecisionInFlight === "approve" ? "Approving" : "Approve"}
            </button>
            <button
              disabled={isDeciding}
              onClick={() => onClubClaimDecision(item, "reject")}
              type="button"
            >
              {claimDecisionInFlight === "reject" ? "Rejecting" : "Reject"}
            </button>
          </div>
        )}
        {onClubIndexDecision && (
          <div className="decision-actions">
            <button
              disabled={isDeciding}
              onClick={() => onClubIndexDecision(item, "indexReady")}
              type="button"
            >
              {indexDecisionInFlight === "indexReady" ?
                "Marking" :
                "Index ready"}
            </button>
            <button
              disabled={isDeciding}
              onClick={() => onClubIndexDecision(item, "noindex")}
              type="button"
            >
              {indexDecisionInFlight === "noindex" ?
                "Keeping" :
                "Keep noindex"}
            </button>
          </div>
        )}
      </div>
    </article>
  );
}

function LineMiniChart({points}: {points: Array<{label: string; value: number}>}) {
  const path = points.map((point, index) => {
    const x = (index / (points.length - 1)) * 100;
    const y = 100 - point.value;
    return `${index === 0 ? "M" : "L"} ${x.toFixed(2)} ${y.toFixed(2)}`;
  }).join(" ");
  return (
    <div className="line-chart">
      <svg viewBox="0 0 100 100" preserveAspectRatio="none" aria-hidden="true">
        <path className="line-area" d={`${path} L 100 100 L 0 100 Z`} />
        <path className="line-stroke" d={path} />
      </svg>
      <div className="chart-labels">
        {points.map((point) => (
          <span key={point.label}>{point.label}</span>
        ))}
      </div>
    </div>
  );
}

function BarMiniChart({points}: {points: Array<{label: string; value: number}>}) {
  const max = Math.max(...points.map((point) => point.value), 1);
  return (
    <div className="bar-chart">
      {points.map((point) => (
        <div className="bar-column" key={point.label}>
          <div
            className="bar"
            style={{height: `${Math.max(8, (point.value / max) * 100)}%`}}
          />
          <span>{point.label}</span>
        </div>
      ))}
    </div>
  );
}

function EventPerformanceTable() {
  return (
    <div className="table-wrap">
      <table>
        <thead>
          <tr>
            <th>Event</th>
            <th>Host</th>
            <th>Fill</th>
            <th>Check-in</th>
            <th>Rating</th>
            <th>GMV</th>
            <th>Risk</th>
          </tr>
        </thead>
        <tbody>
          {eventRows.map((row) => (
            <tr key={row.event}>
              <td>{row.event}</td>
              <td>{row.host}</td>
              <td>{row.fill}</td>
              <td>{row.checkIn}</td>
              <td>{row.rating}</td>
              <td>{row.gmv}</td>
              <td><span className={`risk ${row.risk}`}>{row.risk}</span></td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

function ValueSignals() {
  const signals = [
    {label: "Spend", value: 72, color: "green"},
    {label: "Referrals", value: 46, color: "teal"},
    {label: "Attendance", value: 64, color: "orange"},
    {label: "Match quality", value: 58, color: "red"},
  ];
  return (
    <div className="signals">
      {signals.map((signal) => (
        <div className="signal-row" key={signal.label}>
          <div>
            <span>{signal.label}</span>
            <strong>{signal.value}</strong>
          </div>
          <div className="signal-track">
            <div
              className={`signal-fill ${signal.color}`}
              style={{width: `${signal.value}%`}}
            />
          </div>
        </div>
      ))}
    </div>
  );
}

function DataQualityRows({overview}: {overview: AdminOverviewResponse}) {
  return (
    <div className="quality-list">
      {overview.dataQuality.map((item) => (
        <div className={`quality-row ${item.state}`} key={item.id}>
          {item.state === "blocked" ? (
            <FileWarning size={16} strokeWidth={1.9} />
          ) : (
            <Clock3 size={16} strokeWidth={1.9} />
          )}
          <div>
            <strong>{item.label}</strong>
            <span>{item.detail}</span>
          </div>
        </div>
      ))}
    </div>
  );
}

function queueCount(overview: AdminOverviewResponse) {
  return Object.values(overview.queues)
    .reduce((sum, items) => sum + items.length, 0);
}

function applicationUidFromTargetPath(targetPath: string): string | null {
  const [collection, uid, extra] = targetPath.split("/");
  if (collection !== "accessApplications" || !uid || extra) return null;
  return uid;
}

function clubClaimRequestIdFromTargetPath(targetPath: string): string | null {
  const [collection, requestId, extra] = targetPath.split("/");
  if (collection !== "clubClaimRequests" || !requestId || extra) return null;
  return requestId;
}

function clubIdFromTargetPath(targetPath: string): string | null {
  const [collection, clubId, extra] = targetPath.split("/");
  if (collection !== "clubs" || !clubId || extra) return null;
  return clubId;
}

function completeIndexChecklist() {
  return {
    sourceEvidenceVerified: true,
    mediaRightsVerified: true,
    cadenceVerified: true,
    ownerContactVerified: true,
  };
}

function emptyIndexChecklist() {
  return {
    sourceEvidenceVerified: false,
    mediaRightsVerified: false,
    cadenceVerified: false,
    ownerContactVerified: false,
  };
}

function removeAccessApplication(
  overview: AdminOverviewResponse,
  targetPath: string
): AdminOverviewResponse {
  const applications = overview.queues.accessApplications.filter(
    (item) => item.targetPath !== targetPath
  );
  const removed = applications.length !==
    overview.queues.accessApplications.length;
  return {
    ...overview,
    metrics: overview.metrics.map((metric) => {
      if (metric.id !== "pendingApplications" || !removed) return metric;
      return {...metric, value: Math.max(0, metric.value - 1)};
    }),
    queues: {
      ...overview.queues,
      accessApplications: applications,
    },
  };
}

function removeClubClaimRequest(
  overview: AdminOverviewResponse,
  targetPath: string
): AdminOverviewResponse {
  const claimRequests = overview.queues.clubClaimRequests.filter(
    (item) => item.targetPath !== targetPath
  );
  const removed = claimRequests.length !==
    overview.queues.clubClaimRequests.length;
  return {
    ...overview,
    metrics: overview.metrics.map((metric) => {
      if (metric.id !== "pendingClubClaims" || !removed) return metric;
      return {...metric, value: Math.max(0, metric.value - 1)};
    }),
    queues: {
      ...overview.queues,
      clubClaimRequests: claimRequests,
    },
  };
}

function removeClubIndexReview(
  overview: AdminOverviewResponse,
  targetPath: string
): AdminOverviewResponse {
  const indexReviews = overview.queues.clubIndexReviews.filter(
    (item) => item.targetPath !== targetPath
  );
  const removed = indexReviews.length !== overview.queues.clubIndexReviews.length;
  return {
    ...overview,
    metrics: overview.metrics.map((metric) => {
      if (metric.id !== "indexReviewPages" || !removed) return metric;
      return {...metric, value: Math.max(0, metric.value - 1)};
    }),
    queues: {
      ...overview.queues,
      clubIndexReviews: indexReviews,
    },
  };
}

function formFromClubDetails(
  club: AdminClubDetails
): OrganizerDetailsFormState {
  return {
    clubId: club.clubId,
    name: club.name,
    description: club.description,
    location: club.location ?? "",
    area: club.area,
    tagsText: listToText(club.tags),
    instagramHandle: club.instagramHandle ?? "",
    phoneNumber: club.phoneNumber ?? "",
    email: club.email ?? "",
    imageUrl: club.imageUrl ?? "",
    profileImageUrl: club.profileImageUrl ?? "",
    entityKind: club.entityKind ?? "club",
    entitySubtypesText: listToText(club.entitySubtypes),
    displayCategory: club.displayCategory ?? "",
    cityName: club.cityName ?? "",
    regionName: club.regionName ?? "",
    countryCode: club.countryCode ?? "",
    countryName: club.countryName ?? "",
    appVisibility: club.appVisibility ?? "hidden",
    publicPageSlug: club.publicPage.slug ?? "",
    publicPageCitySlug: club.publicPage.citySlug ?? "",
    canonicalPath: club.publicPage.canonicalPath ?? "",
    publishStatus: club.publicPage.publishStatus ?? "qa",
    seoTitle: club.publicPage.seoTitle ?? "",
    seoDescription: club.publicPage.seoDescription ?? "",
    sourceConfidence: club.provenance.sourceConfidence ?? "seedOnly",
    verificationStatus: club.provenance.verificationStatus ?? "unverified",
    headline: club.publicProfile.headline ?? "",
    summary: club.publicProfile.summary ?? "",
    sourceSummary: club.publicProfile.sourceSummary ?? "",
    formatsText: listToText(club.publicProfile.formats),
    fitNotesText: listToText(club.publicProfile.fitNotes),
    missingEvidenceText: listToText(club.publicProfile.missingEvidence),
    reviewNote: "",
  };
}

function payloadFromOrganizerDetailsForm(
  form: OrganizerDetailsFormState
): AdminUpdateClubDetailsPayload {
  return {
    clubId: form.clubId.trim(),
    reviewNote: nullableText(form.reviewNote),
    fields: {
      name: form.name,
      description: form.description,
      location: nullableText(form.location),
      area: form.area,
      tags: textToList(form.tagsText),
      instagramHandle: nullableText(form.instagramHandle),
      phoneNumber: nullableText(form.phoneNumber),
      email: nullableText(form.email),
      imageUrl: nullableText(form.imageUrl),
      profileImageUrl: nullableText(form.profileImageUrl),
      entityKind: form.entityKind,
      entitySubtypes: textToList(form.entitySubtypesText),
      displayCategory: nullableText(form.displayCategory),
      cityName: nullableText(form.cityName),
      regionName: nullableText(form.regionName),
      countryCode: nullableText(form.countryCode),
      countryName: nullableText(form.countryName),
      appVisibility: form.appVisibility,
      publicPage: {
        slug: form.publicPageSlug,
        citySlug: nullableText(form.publicPageCitySlug),
        canonicalPath: form.canonicalPath,
        publishStatus: form.publishStatus,
        seoTitle: nullableText(form.seoTitle),
        seoDescription: nullableText(form.seoDescription),
      },
      provenance: {
        sourceConfidence: form.sourceConfidence,
        verificationStatus: form.verificationStatus,
      },
      publicProfile: {
        headline: nullableText(form.headline),
        summary: nullableText(form.summary),
        sourceSummary: nullableText(form.sourceSummary),
        formats: textToList(form.formatsText),
        fitNotes: textToList(form.fitNotesText),
        missingEvidence: textToList(form.missingEvidenceText),
      },
    },
  };
}

function listToText(items: string[]): string {
  return items.join("\n");
}

function textToList(value: string): string[] {
  return Array.from(new Set(
    value
      .split("\n")
      .map((item) => item.trim())
      .filter((item) => item.length > 0)
  ));
}

function nullableText(value: string): string | null {
  const trimmed = value.trim();
  return trimmed.length === 0 ? null : trimmed;
}

function relativeTime(value: string | null) {
  if (!value) return "queued";
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return "queued";
  const diffMinutes = Math.max(
    1,
    Math.round((Date.now() - date.getTime()) / 60000)
  );
  if (diffMinutes < 60) return `${diffMinutes}m`;
  const diffHours = Math.round(diffMinutes / 60);
  if (diffHours < 24) return `${diffHours}h`;
  return `${Math.round(diffHours / 24)}d`;
}
