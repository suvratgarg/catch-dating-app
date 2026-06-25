import {
  lazy,
  Suspense,
  type FormEvent,
  type KeyboardEvent,
  useCallback,
  useEffect,
  useMemo,
  useState,
} from "react";
import {
  Activity,
  AlertTriangle,
  BarChart3,
  CheckCircle2,
  CircleDollarSign,
  Database,
  FolderSearch,
  LineChart,
  Lock,
  Megaphone,
  RefreshCw,
  Search,
  ShieldAlert,
  Sparkles,
  UserCheck,
  Users,
} from "lucide-react";
import {getIdTokenResult, onAuthStateChanged, User} from "firebase/auth";
import {
  AdminButton,
  AdminIconButton,
  AdminNavButton,
  SearchField,
  SegmentedControl,
  StatusBanner,
} from "../shared/ui/AdminPrimitives";
import {auth, signInWithGoogle, signOutAdmin} from "../shared/api/firebase";
import type {
  OverviewAnalyticsRangePreset,
} from "../features/overview/controllers/useOverviewController";
import {useOverviewController} from
  "../features/overview/controllers/useOverviewController";
import {dataMode} from "../shared/api/adminApi";
import {
  AdminRoleClaim,
  DataMode,
  adminRoleClaimKeys,
} from "../shared/types/adminTypes";

type AdminNavId =
  | "overview"
  | "safety"
  | "access"
  | "growth"
  | "marketing-ops"
  | "organizer-intake"
  | "organizers"
  | "events"
  | "users"
  | "finance"
  | "quality"
  | "admin-roles";

type AnalyticsRangePreset = NonNullable<
  OverviewAnalyticsRangePreset
>;

interface AdminSectionCopy {
  title: string;
  subtitle: string;
}

interface UserAnalyticsSearchHandoff {
  userId: string;
  requestId: number;
}

const MarketingOpsScreen = lazy(() =>
  import("../features/marketing/ui/MarketingOpsScreen").then((module) => ({
    default: module.MarketingOpsScreen,
  }))
);

const OrganizerIntakeScreen = lazy(() =>
  import("../features/intake/organizer/ui/OrganizerIntakeScreen").then(
    (module) => ({
      default: module.OrganizerIntakeScreen,
    })
  )
);
const SafetyTriageScreen = lazy(() =>
  import("../features/safety/ui/SafetyTriageScreen").then((module) => ({
    default: module.SafetyTriageScreen,
  }))
);
const AccessReviewScreen = lazy(() =>
  import("../features/access/ui/AccessReviewScreen").then((module) => ({
    default: module.AccessReviewScreen,
  }))
);
const GrowthKpiScreen = lazy(() =>
  import("../features/growth/ui/GrowthKpiScreen").then((module) => ({
    default: module.GrowthKpiScreen,
  }))
);
const FinanceOpsScreen = lazy(() =>
  import("../features/finance/ui/FinanceOpsScreen").then((module) => ({
    default: module.FinanceOpsScreen,
  }))
);
const OrganizerPublishingScreen = lazy(() =>
  import("../features/organizers/ui/OrganizerPublishingScreen").then(
    (module) => ({
      default: module.OrganizerPublishingScreen,
    })
  )
);
const EventPublishingScreen = lazy(() =>
  import("../features/events/ui/EventPublishingScreen").then((module) => ({
    default: module.EventPublishingScreen,
  }))
);
const UserAnalyticsScreen = lazy(() =>
  import("../features/users/ui/UserAnalyticsScreen").then((module) => ({
    default: module.UserAnalyticsScreen,
  }))
);
const OverviewScreen = lazy(() =>
  import("../features/overview/ui/OverviewScreen").then((module) => ({
    default: module.OverviewScreen,
  }))
);
const DataQualityScreen = lazy(() =>
  import("../features/data-quality/ui/DataQualityScreen").then((module) => ({
    default: module.DataQualityScreen,
  }))
);
const AdminRoleManagementScreen = lazy(() =>
  import("../features/admin-roles/ui/AdminRoleManagementScreen").then(
    (module) => ({
      default: module.AdminRoleManagementScreen,
    })
  )
);

const navigation: Array<{
  id: AdminNavId;
  label: string;
  icon: typeof Activity;
}> = [
  {id: "overview", label: "Overview", icon: Activity},
  {id: "safety", label: "Safety", icon: ShieldAlert},
  {id: "access", label: "Access", icon: UserCheck},
  {id: "growth", label: "Growth", icon: LineChart},
  {id: "marketing-ops", label: "Marketing", icon: Megaphone},
  {id: "organizer-intake", label: "Intake", icon: FolderSearch},
  {id: "organizers", label: "Organizers", icon: Users},
  {id: "events", label: "Events", icon: BarChart3},
  {id: "users", label: "Users", icon: Sparkles},
  {id: "finance", label: "Finance", icon: CircleDollarSign},
  {id: "quality", label: "Data quality", icon: Database},
  {id: "admin-roles", label: "Admin roles", icon: Lock},
];

const navRoleMap: Record<AdminNavId, readonly AdminRoleClaim[]> = {
  overview: adminRoleClaimKeys,
  safety: ["admin", "adminOwner", "safetyReviewer", "support"],
  access: ["admin", "adminOwner", "support"],
  growth: ["adminOwner", "analyticsViewer"],
  "marketing-ops": ["admin", "adminOwner", "support"],
  "organizer-intake": ["admin", "adminOwner", "support"],
  organizers: ["admin", "adminOwner", "support"],
  events: ["admin", "adminOwner", "support"],
  users: ["adminOwner", "analyticsViewer"],
  finance: ["adminOwner", "analyticsViewer"],
  quality: ["adminOwner"],
  "admin-roles": ["adminOwner"],
};

const hostAnalyticsRoles: readonly AdminRoleClaim[] = [
  "adminOwner",
  "analyticsViewer",
];

const adminSectionCopy: Partial<Record<AdminNavId, AdminSectionCopy>> = {
  safety: {
    title: "Safety",
    subtitle:
      "Review user reports, moderation flags, and event safety reports before policy actions move to audited safety callables.",
  },
  access: {
    title: "Access",
    subtitle:
      "Review launch access applications with required notes, optional cohorts, and auditable approve/deny decisions.",
  },
  growth: {
    title: "Growth",
    subtitle:
      "Inspect launch KPIs across acquisition, supply, conversion, and marketplace stages.",
  },
  users: {
    title: "Users",
    subtitle:
      "Load a role-scoped aggregate user analytics view by exact users/{uid} handoff or selected user id.",
  },
  finance: {
    title: "Finance",
    subtitle:
      "Inspect read-only payment, payout, and event revenue signals before finance mutation contracts exist.",
  },
  quality: {
    title: "Data quality",
    subtitle:
      "Monitor source freshness, bridge readiness, import blockers, owners, runbooks, and next actions.",
  },
  "admin-roles": {
    title: "Admin roles",
    subtitle:
      "Look up exact Firebase Auth users and assign audited Catch admin custom claims.",
  },
};

export function App() {
  const mode = dataMode();
  const adminEnvironment = String(
    import.meta.env.VITE_ADMIN_FIREBASE_ENV ?? "dev"
  );
  const [activeNav, setActiveNav] = useState<AdminNavId>("overview");
  const [error, setError] = useState<string | null>(null);
  const [notice, setNotice] = useState<string | null>(null);
  const [globalSearchQuery, setGlobalSearchQuery] = useState("");
  const [userAnalyticsHandoff, setUserAnalyticsHandoff] =
    useState<UserAnalyticsSearchHandoff | null>(null);
  const [authError, setAuthError] = useState<string | null>(null);
  const [isAuthActionPending, setIsAuthActionPending] = useState(false);
  const [isRoleCheckPending, setIsRoleCheckPending] = useState(false);
  const [rolesResolved, setRolesResolved] = useState(mode === "sample");
  const [user, setUser] = useState<User | null>(null);
  const [adminRoles, setAdminRoles] = useState<string[]>([]);

  useEffect(() => {
    if (mode === "sample") {
      setRolesResolved(true);
      return undefined;
    }
    return onAuthStateChanged(auth, (nextUser) => {
      setUser(nextUser);
      if (nextUser) setAuthError(null);
    });
  }, [mode]);

  useEffect(() => {
    if (mode !== "live") {
      setAdminRoles([]);
      setRolesResolved(true);
      setIsRoleCheckPending(false);
      return undefined;
    }
    if (!user) {
      setAdminRoles([]);
      setRolesResolved(false);
      setIsRoleCheckPending(false);
      return undefined;
    }

    let cancelled = false;
    setRolesResolved(false);
    setIsRoleCheckPending(true);
    void getIdTokenResult(user)
      .then((token) => {
        if (cancelled) return;
        setAdminRoles(adminRoleClaimKeys.filter(
          (claim) => token.claims[claim] === true
        ));
        setAuthError(null);
      })
      .catch(() => {
        if (!cancelled) {
          setAdminRoles([]);
          setAuthError("Unable to read admin claims for this Firebase session.");
        }
      })
      .finally(() => {
        if (!cancelled) {
          setRolesResolved(true);
          setIsRoleCheckPending(false);
        }
      });
    return () => {
      cancelled = true;
    };
  }, [mode, user]);

  const visibleNavigation = useMemo(
    () => navigation.filter((item) =>
      mode === "sample" ||
      hasAnyAdminRole(adminRoles, navRoleMap[item.id])),
    [adminRoles, mode]
  );
  const currentNav = visibleNavigation.some((item) => item.id === activeNav) ?
    activeNav :
    visibleNavigation[0]?.id ?? "overview";

  useEffect(() => {
    if (currentNav !== activeNav) setActiveNav(currentNav);
  }, [activeNav, currentNav]);

  const overviewController = useOverviewController({
    adminRoles,
    isSessionReady: mode === "sample" ||
      (rolesResolved && adminRoles.length > 0),
    mode,
    onError: setError,
    onNotice: setNotice,
  });

  const handleSignIn = useCallback(async () => {
    setAuthError(null);
    setIsAuthActionPending(true);
    try {
      await signInWithGoogle();
    } catch (signInError) {
      setAuthError(
        signInError instanceof Error ?
          signInError.message :
          "Unable to sign in with Google."
      );
    } finally {
      setIsAuthActionPending(false);
    }
  }, []);

  const handleSignOut = useCallback(async () => {
    setAuthError(null);
    setIsAuthActionPending(true);
    try {
      await signOutAdmin();
      setNotice(null);
      setError(null);
    } catch (signOutError) {
      setError(
        signOutError instanceof Error ?
          signOutError.message :
          "Unable to sign out."
      );
    } finally {
      setIsAuthActionPending(false);
    }
  }, []);

  const handleRefreshAdminClaims = useCallback(async () => {
    if (!user) return;
    setAuthError(null);
    setIsRoleCheckPending(true);
    try {
      const token = await getIdTokenResult(user, true);
      const roles = adminRoleClaimKeys.filter(
        (claim) => token.claims[claim] === true
      );
      setAdminRoles(roles);
      setRolesResolved(true);
      if (roles.length === 0) {
        setAuthError("This Firebase account does not have a Catch admin claim.");
      }
    } catch (refreshError) {
      setAdminRoles([]);
      setRolesResolved(true);
      setAuthError(
        refreshError instanceof Error ?
          refreshError.message :
          "Unable to refresh admin claims."
      );
    } finally {
      setIsRoleCheckPending(false);
    }
  }, [user]);

  const runGlobalSearch = useCallback(() => {
    const parsed = parseGlobalSearchQuery(globalSearchQuery);
    if (!parsed) {
      setNotice(null);
      setError(
        "Global search currently supports exact user analytics jumps: users/{uid} or uid:{uid}."
      );
      return;
    }
    if (!visibleNavigation.some((item) => item.id === "users")) {
      setNotice(null);
      setError("Your admin role cannot open Users analytics.");
      return;
    }
    setUserAnalyticsHandoff({
      userId: parsed.userId,
      requestId: Date.now(),
    });
    setGlobalSearchQuery(`users/${parsed.userId}`);
    setActiveNav("users");
    setError(null);
    setNotice(`Opening aggregate analytics for users/${parsed.userId}.`);
  }, [globalSearchQuery, visibleNavigation]);

  const handleGlobalSearchSubmit = useCallback((
    event: FormEvent<HTMLFormElement>
  ) => {
    event.preventDefault();
    runGlobalSearch();
  }, [runGlobalSearch]);

  const handleGlobalSearchKeyDown = useCallback((
    event: KeyboardEvent<HTMLInputElement>
  ) => {
    if (event.key !== "Enter") return;
    event.preventDefault();
    runGlobalSearch();
  }, [runGlobalSearch]);

  if (mode === "live" && !user) {
    return (
      <SignInScreen
        error={authError}
        isSigningIn={isAuthActionPending}
        onSignIn={() => void handleSignIn()}
      />
    );
  }
  if (mode === "live" && user && !rolesResolved) {
    return (
      <AuthCheckScreen
        email={user.email ?? user.uid}
        error={authError}
        isPending={isRoleCheckPending}
        onSignOut={() => void handleSignOut()}
      />
    );
  }
  if (mode === "live" && user && adminRoles.length === 0) {
    return (
      <UnauthorizedAdminScreen
        email={user.email ?? user.uid}
        error={authError}
        isPending={isRoleCheckPending || isAuthActionPending}
        onRefreshClaims={() => void handleRefreshAdminClaims()}
        onSignOut={() => void handleSignOut()}
      />
    );
  }

  const topbarCopy = copyForAdminSection(currentNav);

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
          {visibleNavigation.map((item) => {
            const Icon = item.icon;
            const selected = currentNav === item.id;
            return (
              <AdminNavButton
                icon={<Icon aria-hidden="true" size={17} strokeWidth={1.8} />}
                key={item.id}
                label={item.label}
                onClick={() => setActiveNav(item.id)}
                selected={selected}
              />
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
            <h1>{topbarCopy.title}</h1>
            <p>{topbarCopy.subtitle}</p>
          </div>
          <form
            className="topbar-actions"
            onSubmit={handleGlobalSearchSubmit}
          >
            <SearchField
              ariaLabel="Jump to user analytics"
              icon={<Search size={16} strokeWidth={1.8} />}
              onChange={setGlobalSearchQuery}
              onKeyDown={handleGlobalSearchKeyDown}
              placeholder="Jump to users/{uid}"
              value={globalSearchQuery}
            />
            <span
              className="admin-env-status"
              title="Configured by Vite environment variables"
            >
              {adminEnvironment} · {mode}
            </span>
            <AdminAuthStatus
              mode={mode}
              roles={adminRoles}
              user={user}
            />
            <SegmentedControl<AnalyticsRangePreset>
              ariaLabel="Time range"
              options={(["7d", "30d", "90d", "month"] as AnalyticsRangePreset[])
                .map((range) => ({
                  id: range,
                  label: range === "month" ? "month" : range,
                }))}
              value={overviewController.analyticsRangePreset}
              onChange={overviewController.setAnalyticsRangePreset}
            />
            <AdminIconButton
              disabled={overviewController.isLoading}
              label="Refresh"
              onClick={() => void overviewController.refresh()}
            >
              <RefreshCw
                className={overviewController.isLoading ? "spin" : ""}
                size={17}
                strokeWidth={1.9}
              />
            </AdminIconButton>
            {mode === "live" && (
              <AdminButton
                disabled={isAuthActionPending}
                onClick={() => void handleSignOut()}
              >
                {isAuthActionPending ? "Signing out" : "Sign out"}
              </AdminButton>
            )}
          </form>
        </header>

        {error && (
          <StatusBanner
            icon={<AlertTriangle size={17} strokeWidth={1.9} />}
            tone="error"
          >
            {error}
          </StatusBanner>
        )}
        {notice && (
          <StatusBanner
            icon={<CheckCircle2 size={17} strokeWidth={1.9} />}
            tone="success"
          >
            {notice}
          </StatusBanner>
        )}

        {currentNav === "safety" ? (
          <Suspense fallback={<FeatureLoadingState label="Loading Safety" />}>
            <SafetyTriageScreen
              onError={setError}
              onNotice={setNotice}
            />
          </Suspense>
        ) : currentNav === "marketing-ops" ? (
          <Suspense fallback={<FeatureLoadingState label="Loading Marketing" />}>
            <MarketingOpsScreen
              onError={setError}
              onNotice={setNotice}
            />
          </Suspense>
        ) : currentNav === "access" ? (
          <Suspense fallback={<FeatureLoadingState label="Loading Access" />}>
            <AccessReviewScreen
              onError={setError}
              onNotice={setNotice}
            />
          </Suspense>
        ) : currentNav === "growth" ? (
          <Suspense fallback={<FeatureLoadingState label="Loading Growth" />}>
            <GrowthKpiScreen onError={setError} />
          </Suspense>
        ) : currentNav === "organizer-intake" ? (
          <Suspense fallback={<FeatureLoadingState label="Loading Intake" />}>
            <OrganizerIntakeScreen
              onError={setError}
              onNotice={setNotice}
            />
          </Suspense>
        ) : currentNav === "organizers" ? (
          <Suspense fallback={<FeatureLoadingState label="Loading Organizers" />}>
            <OrganizerPublishingScreen
              onError={setError}
              onNotice={setNotice}
            />
          </Suspense>
        ) : currentNav === "events" ? (
          <Suspense fallback={<FeatureLoadingState label="Loading Events" />}>
            <EventPublishingScreen
              onError={setError}
              onNotice={setNotice}
            />
          </Suspense>
        ) : currentNav === "users" ? (
          <Suspense fallback={<FeatureLoadingState label="Loading Users" />}>
            <UserAnalyticsScreen
              handoffRequestId={userAnalyticsHandoff?.requestId ?? null}
              handoffUserId={userAnalyticsHandoff?.userId ?? null}
              onError={setError}
              onNotice={setNotice}
            />
          </Suspense>
        ) : currentNav === "finance" ? (
          <Suspense fallback={<FeatureLoadingState label="Loading Finance" />}>
            <FinanceOpsScreen onError={setError} />
          </Suspense>
        ) : currentNav === "quality" ? (
          <Suspense fallback={<FeatureLoadingState label="Loading Data quality" />}>
            <DataQualityScreen onError={setError} />
          </Suspense>
        ) : currentNav === "admin-roles" ? (
          <Suspense fallback={<FeatureLoadingState label="Loading Admin roles" />}>
            <AdminRoleManagementScreen
              currentUserUid={user?.uid ?? null}
              onError={setError}
              onNotice={setNotice}
            />
          </Suspense>
        ) : (
          <Suspense fallback={<FeatureLoadingState label="Loading Overview" />}>
            <OverviewScreen
              analyticsClubId={overviewController.analyticsClubId}
              analyticsEndDate={overviewController.analyticsEndDate}
              analyticsEventId={overviewController.analyticsEventId}
              analyticsGranularity={overviewController.analyticsGranularity}
              analyticsRangePreset={overviewController.analyticsRangePreset}
              analyticsStartDate={overviewController.analyticsStartDate}
              hostAnalytics={overviewController.hostAnalytics}
              overview={overviewController.overview}
              onAnalyticsClubIdChange={overviewController.setAnalyticsClubId}
              onAnalyticsEndDateChange={overviewController.setAnalyticsEndDate}
              onAnalyticsEventIdChange={overviewController.setAnalyticsEventId}
              onAnalyticsGranularityChange={overviewController.setAnalyticsGranularity}
              onAnalyticsRangePresetChange={overviewController.setAnalyticsRangePreset}
              onAnalyticsStartDateChange={overviewController.setAnalyticsStartDate}
              onClearAnalyticsScope={overviewController.clearAnalyticsScope}
            />
          </Suspense>
        )}
      </main>
    </div>
  );
}

function FeatureLoadingState({label}: {label: string}) {
  return (
    <div className="marketing-empty-state">
      <RefreshCw className="spin" size={18} strokeWidth={1.9} />
      <span>{label}...</span>
    </div>
  );
}

function AdminAuthStatus({
  mode,
  roles,
  user,
}: {
  mode: DataMode;
  roles: string[];
  user: User | null;
}) {
  if (mode === "sample") {
    return (
      <span className="admin-auth-status sample">
        Sample mode · auth bypassed
      </span>
    );
  }
  return (
    <span className="admin-auth-status live">
      {user?.email ?? user?.uid ?? "Signed in"} · {
        roles.length > 0 ? roles.join(", ") : "no admin claim read yet"
      }
    </span>
  );
}

function copyForAdminSection(activeNav: AdminNavId) {
  if (activeNav === "marketing-ops") {
    return {
      title: "Marketing ops",
      subtitle:
        "Package approved intake records into recommendations, content drafts, media, and manual export packets.",
    };
  }
  if (activeNav === "organizer-intake") {
    return {
      title: "Intake",
      subtitle:
        "Review event and organizer intake before records become canonical, public, or available to Marketing.",
    };
  }
  if (activeNav === "organizers") {
    return {
      title: "Organizers",
      subtitle:
        "Triage canonical organizer projections, claim state, public pages, and app visibility before publishing to Firestore.",
    };
  }
  if (activeNav === "events") {
    return {
      title: "Events",
      subtitle:
        "Review canonical app events, safe display fields, discovery projection, and search indexing before the Flutter app reads them.",
    };
  }
  const sectionCopy = adminSectionCopy[activeNav];
  if (sectionCopy) return sectionCopy;
  return {
    title: "Overview",
    subtitle: "Live operations, cohort health, finance risk, and marketplace signals.",
  };
}

function parseGlobalSearchQuery(
  query: string
): {userId: string} | null {
  const normalized = query.trim().replace(/^\/+/u, "");
  if (!normalized) return null;

  const usersPathMatch = normalized.match(/^users\/([^/\s]+)$/iu);
  if (usersPathMatch) {
    return userAnalyticsSearchResult(usersPathMatch[1]);
  }

  const uidMatch = normalized.match(/^uid[:\s]+([^/\s]+)$/iu);
  if (uidMatch) {
    return userAnalyticsSearchResult(uidMatch[1]);
  }

  if (/^user-[A-Za-z0-9_-]+$/u.test(normalized)) {
    return userAnalyticsSearchResult(normalized);
  }

  return null;
}

function userAnalyticsSearchResult(userId: string): {userId: string} | null {
  const trimmed = userId.trim();
  if (!/^[A-Za-z0-9_-]{3,128}$/u.test(trimmed)) return null;
  return {userId: trimmed};
}

function hasAnyAdminRole(
  roles: string[],
  allowedRoles: readonly AdminRoleClaim[]
): boolean {
  return allowedRoles.some((role) => roles.includes(role));
}

function SignInScreen({
  error,
  isSigningIn,
  onSignIn,
}: {
  error: string | null;
  isSigningIn: boolean;
  onSignIn: () => void;
}) {
  return (
    <main className="signin-screen">
      <section className="signin-panel">
        <div className="brand-mark large">C</div>
        <h1>Catch Ops</h1>
        <p>Internal admin access requires Firebase Auth and an admin claim.</p>
        {error && (
          <StatusBanner
            icon={<AlertTriangle size={17} strokeWidth={1.9} />}
            tone="error"
          >
            {error}
          </StatusBanner>
        )}
        <AdminButton
          disabled={isSigningIn}
          onClick={onSignIn}
          variant="primary"
        >
          {isSigningIn ? "Signing in" : "Sign in with Google"}
        </AdminButton>
      </section>
    </main>
  );
}

function AuthCheckScreen({
  email,
  error,
  isPending,
  onSignOut,
}: {
  email: string;
  error: string | null;
  isPending: boolean;
  onSignOut: () => void;
}) {
  return (
    <main className="signin-screen">
      <section className="signin-panel">
        <div className="brand-mark large">C</div>
        <h1>Checking admin access</h1>
        <p>{email}</p>
        {error ? (
          <StatusBanner
            icon={<AlertTriangle size={17} strokeWidth={1.9} />}
            tone="error"
          >
            {error}
          </StatusBanner>
        ) : (
          <div className="signin-meta">
            <RefreshCw
              className={isPending ? "spin" : ""}
              size={17}
              strokeWidth={1.9}
            />
            <span>Reading Firebase custom claims.</span>
          </div>
        )}
        <AdminButton disabled={isPending} onClick={onSignOut}>
          Sign out
        </AdminButton>
      </section>
    </main>
  );
}

function UnauthorizedAdminScreen({
  email,
  error,
  isPending,
  onRefreshClaims,
  onSignOut,
}: {
  email: string;
  error: string | null;
  isPending: boolean;
  onRefreshClaims: () => void;
  onSignOut: () => void;
}) {
  return (
    <main className="signin-screen">
      <section className="signin-panel">
        <div className="brand-mark large">C</div>
        <h1>Admin claim required</h1>
        <p>
          {email} is signed in, but this Firebase session does not include a
          Catch admin custom claim.
        </p>
        <div className="signin-meta">
          <Lock size={17} strokeWidth={1.9} />
          <span>Ask an admin owner to assign a role, then refresh claims.</span>
        </div>
        {error && (
          <StatusBanner
            icon={<AlertTriangle size={17} strokeWidth={1.9} />}
            tone="error"
          >
            {error}
          </StatusBanner>
        )}
        <div className="signin-actions">
          <AdminButton
            disabled={isPending}
            onClick={onRefreshClaims}
            variant="primary"
          >
            {isPending ? "Refreshing" : "Refresh claims"}
          </AdminButton>
          <AdminButton disabled={isPending} onClick={onSignOut}>
            Sign out
          </AdminButton>
        </div>
      </section>
    </main>
  );
}
