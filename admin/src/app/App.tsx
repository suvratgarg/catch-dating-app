import {
  lazy,
  Suspense,
  useCallback,
  useEffect,
  useMemo,
  useState,
} from "react";
import {
  BrowserRouter,
  useLocation,
  useNavigate,
} from "react-router";
import {
  Activity,
  AlertTriangle,
  BarChart3,
  Bot,
  CheckCircle2,
  CircleDollarSign,
  Database,
  FolderSearch,
  LineChart,
  Lock,
  Megaphone,
  ShieldAlert,
  Sparkles,
  UserCheck,
  Users,
} from "lucide-react";
import {getIdTokenResult, onAuthStateChanged, User} from "firebase/auth";
import {
  AdminAccountMenu,
  AdminAppShell,
  AdminBrandBlock,
  AdminBrandCopy,
  AdminBrandMark,
  AdminBrandTitle,
  AdminButton,
  AdminEnvironmentStatus,
  AdminFeatureLoadingState,
  AdminLoadingIcon,
  AdminNavButton,
  AdminNavGroup,
  AdminNavList,
  AdminSidebar,
  AdminSidebarToggle,
  AdminSignInActions,
  AdminSignInMeta,
  AdminSignInPanel,
  AdminSignInScreen,
  AdminTopbar,
  AdminTopbarActions,
  AdminWorkspace,
  StatusBanner,
} from "../shared/ui/AdminPrimitives";
import {auth, signInWithGoogle, signOutAdmin} from "../shared/api/firebase";
import {dataMode} from "../shared/api/dataMode";
import {
  AdminRoleClaim,
  DataMode,
  adminRoleClaimKeys,
} from "../shared/types/adminTypes";
import {AdminFeedbackProvider} from "../shared/feedback/AdminFeedbackContext";
import type {OverviewQueueDestination} from
  "../features/overview/ui/OverviewScreen";

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
  | "operations"
  | "admin-roles";

const MarketingOpsScreen = lazy(() =>
  import("../features/marketing/ui/MarketingOpsScreen").then((module) => ({
    default: module.MarketingOpsScreen,
  }))
);

const IntakeWorkspaceScreen = lazy(() =>
  import("../features/intake/ui/IntakeWorkspaceScreen").then(
    (module) => ({
      default: module.IntakeWorkspaceScreen,
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
const OverviewRouteScreen = lazy(() =>
  import("../features/overview/ui/OverviewRouteScreen").then((module) => ({
    default: module.OverviewRouteScreen,
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
const AdminActionExecutionsScreen = lazy(() =>
  import("../features/operations/ui/AdminActionExecutionsScreen").then(
    (module) => ({default: module.AdminActionExecutionsScreen})
  )
);

interface AdminNavigationItem {
  id: AdminNavId;
  label: string;
  icon: typeof Activity;
}

const navigationGroups: Array<{
  id: string;
  label: string;
  items: AdminNavigationItem[];
}> = [
  {
    id: "queues",
    label: "Work queues",
    items: [
      {id: "overview", label: "Overview", icon: Activity},
      {id: "safety", label: "Safety", icon: ShieldAlert},
      {id: "access", label: "Launch access", icon: UserCheck},
    ],
  },
  {
    id: "supply",
    label: "Supply",
    items: [
      {id: "organizer-intake", label: "Intake", icon: FolderSearch},
      {id: "organizers", label: "Organizers", icon: Users},
      {id: "events", label: "Events", icon: BarChart3},
    ],
  },
  {
    id: "growth",
    label: "Growth & insights",
    items: [
      {id: "growth", label: "Growth", icon: LineChart},
      {id: "marketing-ops", label: "Marketing", icon: Megaphone},
      {id: "users", label: "Users", icon: Sparkles},
      {id: "finance", label: "Finance", icon: CircleDollarSign},
    ],
  },
  {
    id: "automation",
    label: "Automation",
    items: [
      {id: "operations", label: "Agent activity", icon: Bot},
    ],
  },
  {
    id: "governance",
    label: "Governance",
    items: [
      {id: "quality", label: "Data quality", icon: Database},
      {id: "admin-roles", label: "Admin roles", icon: Lock},
    ],
  },
];

const navigation = navigationGroups.flatMap((group) => group.items);

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
  operations: ["admin", "adminOwner", "support"],
  "admin-roles": ["adminOwner"],
};

const hostAnalyticsRoles: readonly AdminRoleClaim[] = [
  "adminOwner",
  "analyticsViewer",
];

const adminSidebarPreferenceKey = "catch-admin.sidebar-collapsed.v1";

function readAdminSidebarPreference(): boolean {
  if (typeof window === "undefined") return false;
  try {
    return window.localStorage.getItem(adminSidebarPreferenceKey) === "true";
  } catch {
    return false;
  }
}

function writeAdminSidebarPreference(collapsed: boolean): void {
  try {
    window.localStorage.setItem(
      adminSidebarPreferenceKey,
      String(collapsed)
    );
  } catch {
    // The in-memory preference still works when storage is unavailable.
  }
}

const adminSectionTitles: Record<AdminNavId, string> = {
  overview: "Overview",
  safety: "Safety",
  access: "Launch access",
  growth: "Growth",
  "marketing-ops": "Marketing",
  "organizer-intake": "Intake",
  organizers: "Organizers",
  events: "Events",
  users: "Users",
  finance: "Finance",
  quality: "Data quality",
  operations: "Agent activity",
  "admin-roles": "Admin roles",
};

export function App() {
  return (
    <BrowserRouter>
      <AdminRouteApp />
    </BrowserRouter>
  );
}

function AdminRouteApp() {
  const mode = dataMode();
  const location = useLocation();
  const navigate = useNavigate();
  const adminEnvironment = String(
    import.meta.env.VITE_ADMIN_FIREBASE_ENV ?? "dev"
  );
  const [error, setError] = useState<string | null>(null);
  const [notice, setNotice] = useState<string | null>(null);
  const [authError, setAuthError] = useState<string | null>(null);
  const [isAuthActionPending, setIsAuthActionPending] = useState(false);
  const [isRoleCheckPending, setIsRoleCheckPending] = useState(false);
  const [rolesResolved, setRolesResolved] = useState(mode === "sample");
  const [user, setUser] = useState<User | null>(null);
  const [adminRoles, setAdminRoles] = useState<string[]>([]);
  const [isSidebarCollapsed, setIsSidebarCollapsed] =
    useState(readAdminSidebarPreference);

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
  const routeNav = adminNavForPath(location.pathname);
  const routeNavVisible = routeNav !== null &&
    visibleNavigation.some((item) => item.id === routeNav);
  const currentNav: AdminNavId = routeNavVisible ?
    routeNav :
    visibleNavigation[0]?.id ?? "overview";
  const canResolveNavigation = mode !== "live" ||
    (user !== null && rolesResolved && adminRoles.length > 0);

  useEffect(() => {
    if (!canResolveNavigation) return;
    if (routeNav === currentNav) return;
    navigate(adminPathForNav(currentNav), {replace: true});
  }, [canResolveNavigation, currentNav, navigate, routeNav]);

  const setActiveNav = useCallback((nextNav: AdminNavId) => {
    navigate(adminPathForNav(nextNav));
  }, [navigate]);

  const handleSidebarCollapsedChange = useCallback((collapsed: boolean) => {
    setIsSidebarCollapsed(collapsed);
    writeAdminSidebarPreference(collapsed);
  }, []);

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

  const handleOverviewQueueOpen = useCallback((
    destination: OverviewQueueDestination,
    targetPath?: string | null
  ) => {
    const destinationItem = visibleNavigation.find((item) =>
      item.id === destination
    );
    if (!destinationItem) {
      setNotice(null);
      setError(`Your admin role cannot open the ${destination} workflow.`);
      return;
    }
    setError(null);
    setNotice(null);
    if (targetPath && destination === "safety") {
      navigate(`/safety/${encodeURIComponent(targetPath)}`);
      return;
    }
    const targetId = targetPath?.split("/").filter(Boolean).at(-1) ?? null;
    if (targetId && destination === "access") {
      navigate(`/access/${encodeURIComponent(targetId)}`);
      return;
    }
    if (targetId && destination === "organizers") {
      navigate(targetPath?.startsWith("clubClaimRequests/") ?
        `/organizers/claims/${encodeURIComponent(targetId)}` :
        `/organizers/${encodeURIComponent(targetId)}`);
      return;
    }
    if (targetPath && destination === "finance") {
      navigate(`/finance/issues/${encodeURIComponent(targetPath)}`);
      return;
    }
    setActiveNav(destination);
  }, [navigate, setActiveNav, visibleNavigation]);

  const topbarTitle = titleForAdminSection(currentNav, location.pathname);

  useEffect(() => {
    const nextTitle = mode === "live" && !user ?
      "Catch Admin" :
      `${topbarTitle} — Catch Admin`;
    document.title = nextTitle;
  }, [mode, topbarTitle, user]);

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

  return (
    <AdminAppShell sidebarCollapsed={isSidebarCollapsed}>
      <AdminSidebar aria-label="Admin sections" id="admin-sidebar">
        <AdminBrandBlock>
          <AdminBrandMark>C</AdminBrandMark>
          <AdminBrandCopy>
            <AdminBrandTitle>Catch Admin</AdminBrandTitle>
          </AdminBrandCopy>
        </AdminBrandBlock>
        <AdminNavList aria-label="Admin navigation">
          {navigationGroups.map((group) => {
            const visibleItems = group.items.filter((item) =>
              visibleNavigation.some((visibleItem) =>
                visibleItem.id === item.id
              )
            );
            if (visibleItems.length === 0) return null;
            return (
              <AdminNavGroup key={group.id} label={group.label}>
                {visibleItems.map((item) => {
                  const Icon = item.icon;
                  const selected = currentNav === item.id;
                  return (
                    <AdminNavButton
                      icon={<Icon aria-hidden="true" size={17} strokeWidth={1.8} />}
                      key={item.id}
                      label={item.label}
                      onClick={() => setActiveNav(item.id)}
                      selected={selected}
                      title={isSidebarCollapsed ? item.label : undefined}
                    />
                  );
                })}
              </AdminNavGroup>
            );
          })}
        </AdminNavList>
        <AdminSidebarToggle
          collapsed={isSidebarCollapsed}
          controlsId="admin-sidebar"
          onCollapsedChange={handleSidebarCollapsedChange}
        />
      </AdminSidebar>

      <AdminWorkspace>
        <AdminTopbar>
          <h1>{topbarTitle}</h1>
          <AdminTopbarActions>
            <AdminEnvironmentStatus
              environment={adminEnvironment}
            />
            <AdminAccountMenu
              isSigningOut={isAuthActionPending}
              mode={mode}
              onSignOut={mode === "live" ?
                () => void handleSignOut() :
                undefined}
              roles={adminRoles}
              userLabel={
                user?.displayName ??
                user?.email ??
                user?.phoneNumber ??
                user?.uid ??
                "Local preview"
              }
            />
          </AdminTopbarActions>
        </AdminTopbar>

        <AdminFeedbackProvider onError={setError} onNotice={setNotice}>
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
          <Suspense fallback={<AdminFeatureLoadingState label="Loading Safety" />}>
            <SafetyTriageScreen
              onError={setError}
              onNotice={setNotice}
              selectedTargetPath={safetyTargetPathForPath(location.pathname)}
              onBackToList={() => navigate(adminPathForNav("safety"))}
              onSelectTargetPath={(targetPath) => {
                navigate(
                  `${adminPathForNav("safety")}/${encodeURIComponent(targetPath)}`
                );
              }}
            />
          </Suspense>
        ) : currentNav === "marketing-ops" ? (
          <Suspense fallback={<AdminFeatureLoadingState label="Loading Marketing" />}>
            <MarketingOpsScreen
              activeTab={marketingTabForPath(location.pathname)}
              composerStep={marketingComposerStepForPath(location.pathname)}
              onComposerStepChange={(step) => {
                const draftId = marketingDraftIdForPath(location.pathname);
                if (draftId) {
                  navigate(`/marketing/drafts/${encodeURIComponent(draftId)}/${step}`);
                }
              }}
              onDraftOpen={(draftId, step) => {
                navigate(`/marketing/drafts/${encodeURIComponent(draftId)}/${step}`);
              }}
              onError={setError}
              onNotice={setNotice}
              onTabChange={(tab) => navigate(marketingPathForTab(tab))}
              selectedDraftId={marketingDraftIdForPath(location.pathname)}
            />
          </Suspense>
        ) : currentNav === "access" ? (
          <Suspense fallback={<AdminFeatureLoadingState label="Loading Access" />}>
            <AccessReviewScreen
              selectedApplicationUid={accessApplicationUidForPath(location.pathname)}
              onBackToList={() => navigate(adminPathForNav("access"))}
              onError={setError}
              onNotice={setNotice}
              onSelectApplicationUid={(applicationUid) => {
                navigate(`${adminPathForNav("access")}/${encodeURIComponent(applicationUid)}`);
              }}
            />
          </Suspense>
        ) : currentNav === "growth" ? (
          <Suspense fallback={<AdminFeatureLoadingState label="Loading Growth" />}>
            <GrowthKpiScreen
              onBackToList={() => navigate(adminPathForNav("growth"))}
              onError={setError}
              onSelectSignalId={(signalId) => {
                navigate(`/growth/signals/${encodeURIComponent(signalId)}`);
              }}
              selectedSignalId={growthSignalIdForPath(location.pathname)}
            />
          </Suspense>
        ) : currentNav === "organizer-intake" ? (
          <Suspense fallback={<AdminFeatureLoadingState label="Loading Intake" />}>
            <IntakeWorkspaceScreen />
          </Suspense>
        ) : currentNav === "organizers" ? (
          <Suspense fallback={<AdminFeatureLoadingState label="Loading Organizers" />}>
            <OrganizerPublishingScreen
              activeWorkspace={isOrganizerClaimsPath(location.pathname) ?
                "claims" :
                "directory"}
              selectedClubId={organizerClubIdForPath(location.pathname)}
              onBackToList={() => navigate(adminPathForNav("organizers"))}
              onBackToClaims={() => navigate(`${adminPathForNav("organizers")}/claims`)}
              onSelectClaimRequestId={(requestId) => {
                navigate(
                  `${adminPathForNav("organizers")}/claims/${encodeURIComponent(requestId)}`
                );
              }}
              onSelectClubId={(clubId) => {
                navigate(`${adminPathForNav("organizers")}/${encodeURIComponent(clubId)}`);
              }}
              onWorkspaceChange={(workspace) => {
                navigate(workspace === "claims" ?
                  `${adminPathForNav("organizers")}/claims` :
                  adminPathForNav("organizers"));
              }}
              selectedClaimRequestId={organizerClaimRequestIdForPath(location.pathname)}
            />
          </Suspense>
        ) : currentNav === "events" ? (
          <Suspense fallback={<AdminFeatureLoadingState label="Loading Events" />}>
            <EventPublishingScreen
              activeWorkspace={eventWorkspaceForPath(location.pathname)}
              selectedEventId={eventIdForPath(location.pathname)}
              selectedExternalEventId={externalEventIdForPath(location.pathname)}
              selectedReadinessActionId={readinessActionIdForPath(location.pathname)}
              onBackToList={() => navigate(
                `${adminPathForNav("events")}${location.search}`
              )}
              onSelectEventId={(eventId) => {
                navigate(
                  `${adminPathForNav("events")}/${encodeURIComponent(eventId)}` +
                  location.search
                );
              }}
              onSelectExternalEventId={(eventId) => {
                navigate(eventId ?
                  `${adminPathForNav("events")}/external/${encodeURIComponent(eventId)}` +
                    location.search :
                  `${adminPathForNav("events")}/external${location.search}`);
              }}
              onSelectReadinessActionId={(sourceActionId) => {
                navigate(sourceActionId ?
                  `${adminPathForNav("events")}/readiness/${encodeURIComponent(sourceActionId)}` +
                    location.search :
                  `${adminPathForNav("events")}/readiness${location.search}`);
              }}
              onWorkspaceChange={(workspace) => {
                navigate(workspace === "directory" ?
                  adminPathForNav("events") :
                  `${adminPathForNav("events")}/${workspace}`);
              }}
            />
          </Suspense>
        ) : currentNav === "users" ? (
          <Suspense fallback={<AdminFeatureLoadingState label="Loading Users" />}>
            <UserAnalyticsScreen
              handoffRequestId={null}
              handoffUserId={null}
              onError={setError}
              onNotice={setNotice}
            />
          </Suspense>
        ) : currentNav === "finance" ? (
          <Suspense fallback={<AdminFeatureLoadingState label="Loading Finance" />}>
            <FinanceOpsScreen
              onBackToList={() => navigate(adminPathForNav("finance"))}
              onError={setError}
              onSelectIssueId={(issueId) => {
                navigate(`/finance/issues/${encodeURIComponent(issueId)}`);
              }}
              selectedIssueId={financeIssueIdForPath(location.pathname)}
            />
          </Suspense>
        ) : currentNav === "quality" ? (
          <Suspense fallback={<AdminFeatureLoadingState label="Loading Data quality" />}>
            <DataQualityScreen
              onBackToList={() => navigate(adminPathForNav("quality"))}
              onError={setError}
              onOpenOwningWorkflow={(path) => navigate(path)}
              onSelectSignalId={(signalId) => {
                navigate(`/quality/signals/${encodeURIComponent(signalId)}`);
              }}
              selectedSignalId={qualitySignalIdForPath(location.pathname)}
            />
          </Suspense>
        ) : currentNav === "admin-roles" ? (
          <Suspense fallback={<AdminFeatureLoadingState label="Loading Admin roles" />}>
            <AdminRoleManagementScreen
              currentUserUid={user?.uid ?? null}
              onBackToRegister={() => navigate(adminPathForNav("admin-roles"))}
              onError={setError}
              onNotice={setNotice}
              onSelectTargetUid={(targetUid) => {
                navigate(`/admin-roles/${encodeURIComponent(targetUid)}`);
              }}
              selectedTargetUid={adminRoleTargetUidForPath(location.pathname)}
            />
          </Suspense>
        ) : currentNav === "operations" ? (
          <Suspense fallback={<AdminFeatureLoadingState label="Loading Agent activity" />}>
            <AdminActionExecutionsScreen onError={setError} />
          </Suspense>
        ) : (
          <Suspense fallback={<AdminFeatureLoadingState label="Loading Overview" />}>
            <OverviewRouteScreen
              adminRoles={adminRoles}
              isSessionReady={mode === "sample" ||
                (rolesResolved && adminRoles.length > 0)}
              mode={mode}
              onError={setError}
              onNotice={setNotice}
              onOpenQueue={handleOverviewQueueOpen}
            />
          </Suspense>
        )}
        </AdminFeedbackProvider>
      </AdminWorkspace>
    </AdminAppShell>
  );
}

function titleForAdminSection(activeNav: AdminNavId, pathname = ""): string {
  if (activeNav === "safety" && safetyTargetPathForPath(pathname)) {
    return "Safety case";
  }
  if (activeNav === "organizer-intake") {
    if (pathname.startsWith("/intake/events")) return "Event intake";
    if (pathname.startsWith("/intake/operations")) {
      return "Supply intake operations";
    }
    return "Organizer intake";
  }
  if (activeNav === "events") {
    if (eventIdForPath(pathname)) return "Event detail";
    if (eventWorkspaceForPath(pathname) === "readiness") {
      return readinessActionIdForPath(pathname) ?
        "Event readiness review" :
        "Event readiness";
    }
    if (eventWorkspaceForPath(pathname) === "external") {
      return externalEventIdForPath(pathname) ?
        "External event" :
        "External inventory";
    }
  }
  if (activeNav === "growth" && growthSignalIdForPath(pathname)) {
    return "Growth signal";
  }
  if (activeNav === "finance" && financeIssueIdForPath(pathname)) {
    return "Finance issue";
  }
  if (activeNav === "quality" && qualitySignalIdForPath(pathname)) {
    return "Data quality signal";
  }
  if (activeNav === "admin-roles" && adminRoleTargetUidForPath(pathname)) {
    return "Admin role assignment";
  }
  if (activeNav === "marketing-ops" && marketingDraftIdForPath(pathname)) {
    return "Marketing draft";
  }
  return adminSectionTitles[activeNav];
}

function adminNavForPath(pathname: string): AdminNavId | null {
  const segment = pathname.replace(/^\/+|\/+$/gu, "").split("/")[0] ?? "";
  if (segment === "") return "overview";
  if (segment === "marketing") return "marketing-ops";
  if (segment === "intake") return "organizer-intake";
  if (segment === "admin-roles") return "admin-roles";
  if (isAdminNavId(segment)) return segment;
  return null;
}

function adminPathForNav(nav: AdminNavId): string {
  if (nav === "overview") return "/overview";
  if (nav === "marketing-ops") return "/marketing";
  if (nav === "organizer-intake") return "/intake/organizers";
  return `/${nav}`;
}

function isAdminNavId(value: string): value is AdminNavId {
  return navigation.some((item) => item.id === value);
}

function organizerClubIdForPath(pathname: string): string | null {
  const match = pathname.match(/^\/organizers\/([^/]+)\/?$/u);
  if (!match || match[1] === "claims") return null;
  try {
    return decodeURIComponent(match[1]);
  } catch {
    return match[1];
  }
}

function isOrganizerClaimsPath(pathname: string): boolean {
  return /^\/organizers\/claims(?:\/|$)/u.test(pathname);
}

function organizerClaimRequestIdForPath(pathname: string): string | null {
  const match = pathname.match(/^\/organizers\/claims\/([^/]+)\/?$/u);
  if (!match) return null;
  try {
    return decodeURIComponent(match[1]);
  } catch {
    return match[1];
  }
}

function accessApplicationUidForPath(pathname: string): string | null {
  const match = pathname.match(/^\/access\/([^/]+)\/?$/u);
  if (!match) return null;
  try {
    return decodeURIComponent(match[1]);
  } catch {
    return match[1];
  }
}

function eventWorkspaceForPath(
  pathname: string
): "directory" | "readiness" | "external" {
  if (/^\/events\/readiness(?:\/|$)/u.test(pathname)) return "readiness";
  if (/^\/events\/external(?:\/|$)/u.test(pathname)) return "external";
  return "directory";
}

function growthSignalIdForPath(pathname: string): string | null {
  const match = pathname.match(/^\/growth\/signals\/([^/]+)\/?$/u);
  if (!match) return null;
  try {
    return decodeURIComponent(match[1]);
  } catch {
    return match[1];
  }
}

function financeIssueIdForPath(pathname: string): string | null {
  const match = pathname.match(/^\/finance\/issues\/([^/]+)\/?$/u);
  if (!match) return null;
  try {
    return decodeURIComponent(match[1]);
  } catch {
    return match[1];
  }
}

function qualitySignalIdForPath(pathname: string): string | null {
  const match = pathname.match(/^\/quality\/signals\/([^/]+)\/?$/u);
  if (!match) return null;
  try {
    return decodeURIComponent(match[1]);
  } catch {
    return match[1];
  }
}

function adminRoleTargetUidForPath(pathname: string): string | null {
  const match = pathname.match(/^\/admin-roles\/([^/]+)\/?$/u);
  if (!match) return null;
  try {
    return decodeURIComponent(match[1]);
  } catch {
    return match[1];
  }
}

type MarketingRouteTab =
  | "posts"
  | "new"
  | "events"
  | "media"
  | "activity"
  | "diagnostics"
  | "draft";
type MarketingRouteStep = "source" | "copy" | "compliance" | "export";

function marketingTabForPath(pathname: string): MarketingRouteTab {
  if (/^\/marketing\/drafts\//u.test(pathname)) return "draft";
  const segment = pathname.match(/^\/marketing\/([^/]+)\/?/u)?.[1] ?? "posts";
  if (["new", "events", "media", "activity", "diagnostics"].includes(segment)) {
    return segment as Exclude<MarketingRouteTab, "posts" | "draft">;
  }
  return "posts";
}

function marketingDraftIdForPath(pathname: string): string | null {
  const match = pathname.match(/^\/marketing\/drafts\/([^/]+)(?:\/|$)/u);
  if (!match) return null;
  try {
    return decodeURIComponent(match[1]);
  } catch {
    return match[1];
  }
}

function marketingComposerStepForPath(pathname: string): MarketingRouteStep {
  const match = pathname.match(/^\/marketing\/drafts\/[^/]+\/([^/]+)\/?$/u);
  const step = match?.[1] ?? "source";
  return ["source", "copy", "compliance", "export"].includes(step) ?
    step as MarketingRouteStep : "source";
}

function marketingPathForTab(tab: Exclude<MarketingRouteTab, "draft">): string {
  return tab === "posts" ? "/marketing/posts" : `/marketing/${tab}`;
}

function eventIdForPath(pathname: string): string | null {
  const match = pathname.match(/^\/events\/([^/]+)\/?$/u);
  if (!match || match[1] === "readiness" || match[1] === "external") {
    return null;
  }
  try {
    return decodeURIComponent(match[1]);
  } catch {
    return match[1];
  }
}

function externalEventIdForPath(pathname: string): string | null {
  const match = pathname.match(/^\/events\/external\/([^/]+)\/?$/u);
  if (!match) return null;
  try {
    return decodeURIComponent(match[1]);
  } catch {
    return match[1];
  }
}

function readinessActionIdForPath(pathname: string): string | null {
  const match = pathname.match(/^\/events\/readiness\/([^/]+)\/?$/u);
  if (!match) return null;
  try {
    return decodeURIComponent(match[1]);
  } catch {
    return match[1];
  }
}

function safetyTargetPathForPath(pathname: string): string | null {
  const match = pathname.match(/^\/safety\/([^/]+)\/?$/u);
  if (!match) return null;
  try {
    return decodeURIComponent(match[1]);
  } catch {
    return match[1];
  }
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
    <AdminSignInScreen>
      <AdminSignInPanel>
        <AdminBrandMark size="large">C</AdminBrandMark>
        <h1>Catch Admin</h1>
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
      </AdminSignInPanel>
    </AdminSignInScreen>
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
    <AdminSignInScreen>
      <AdminSignInPanel>
        <AdminBrandMark size="large">C</AdminBrandMark>
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
          <AdminSignInMeta>
            <AdminLoadingIcon active={isPending} />
            <span>Reading Firebase custom claims.</span>
          </AdminSignInMeta>
        )}
        <AdminButton disabled={isPending} onClick={onSignOut}>
          Sign out
        </AdminButton>
      </AdminSignInPanel>
    </AdminSignInScreen>
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
    <AdminSignInScreen>
      <AdminSignInPanel>
        <AdminBrandMark size="large">C</AdminBrandMark>
        <h1>Admin claim required</h1>
        <p>
          {email} is signed in, but this Firebase session does not include a
          Catch admin custom claim.
        </p>
        <AdminSignInMeta>
          <Lock size={17} strokeWidth={1.9} />
          <span>Ask an admin owner to assign a role, then refresh claims.</span>
        </AdminSignInMeta>
        {error && (
          <StatusBanner
            icon={<AlertTriangle size={17} strokeWidth={1.9} />}
            tone="error"
          >
            {error}
          </StatusBanner>
        )}
        <AdminSignInActions>
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
        </AdminSignInActions>
      </AdminSignInPanel>
    </AdminSignInScreen>
  );
}
