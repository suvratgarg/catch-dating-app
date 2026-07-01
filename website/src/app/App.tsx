import {lazy, Suspense} from "react";
import {BrowserRouter, Route, Routes, useLocation} from "react-router";
import {
  getPageKey,
  pageClassFor,
  pageMeta,
  pageMetaForListing,
  type PageKey,
} from "./pageMeta";
import {
  useDocumentMeta,
  useHashScroll,
  useMarketingAnalytics,
  useMarketingCaptures,
  useRevealAnimations,
} from "./usePageLifecycle";
import {isHostPreviewPath, marketingRoutePaths} from "./routeRegistry";
import {MarketingConsentBanner} from "../features/marketing/MarketingConsentBanner";
import {
  getHostListingRouteForPath,
} from "../features/organizers/routing";

const ClaimPage = lazy(async () => ({
  default: (await import("../features/claims/ClaimPage")).ClaimPage,
}));
const HomePage = lazy(async () => ({
  default: (await import("../features/home/HomePage")).HomePage,
}));
const HostListingPage = lazy(async () => ({
  default: (await import("../features/organizers/HostListingPage")).HostListingPage,
}));
const HostPage = lazy(async () => ({
  default: (await import("../features/host/HostPage")).HostPage,
}));
const HostPreviewPage = lazy(async () => ({
  default: (await import("../features/host/HostPreviewPage")).HostPreviewPage,
}));
const OrganizerSearchPage = lazy(async () => ({
  default: (await import("../features/organizers/OrganizerSearchPage")).OrganizerSearchPage,
}));

function App() {
  return (
    <BrowserRouter>
      <MarketingRouteShell />
    </BrowserRouter>
  );
}

function MarketingRouteShell() {
  const location = useLocation();
  const listingRoute = getHostListingRouteForPath(location.pathname);
  const listing = listingRoute?.listing ?? null;
  const fallbackPage = getPageKey(location.pathname);
  const page: PageKey = listing ? "listing" : fallbackPage;
  const isHostPreview = isHostPreviewPath(location.pathname);
  const captures = useMarketingCaptures();
  const routeKey = `${location.pathname}${location.search}${location.hash}`;
  const meta = listingRoute ?
    pageMetaForListing(listingRoute.listing, {
      noindexOverride: listingRoute.isLegacyPath,
    }) :
    pageMeta[fallbackPage];
  const shellClassName = isHostPreview
    ? `${pageClassFor(page)} host-preview-page`
    : pageClassFor(page);

  useMarketingAnalytics(page, routeKey);
  useDocumentMeta(meta);

  return (
    <div className={`page-shell ${shellClassName}`}>
      <Suspense fallback={<RouteLoadingState />}>
        <RouteLifecycleEffects
          page={page}
          routeKey={routeKey}
          hash={location.hash}
        />
        <Routes>
          <Route
            path={marketingRoutePaths.home}
            element={<HomePage captures={captures} />}
          />
          <Route
            path={marketingRoutePaths.host_preview}
            element={<HostPreviewPage captures={captures} />}
          />
          <Route
            path={marketingRoutePaths.host}
            element={<HostPage captures={captures} />}
          />
          <Route
            path={marketingRoutePaths.organizer_search}
            element={<OrganizerSearchPage />}
          />
          <Route
            path={marketingRoutePaths.organizer_listing}
            element={listing ? (
              <HostListingPage listing={listing} />
            ) : (
              <OrganizerSearchPage />
            )}
          />
          <Route
            path={marketingRoutePaths.claim}
            element={<ClaimPage />}
          />
          <Route
            path={marketingRoutePaths.claim_lookup}
            element={<ClaimPage />}
          />
          <Route
            path={marketingRoutePaths.fallback}
            element={<HomePage captures={captures} />}
          />
        </Routes>
      </Suspense>
      <MarketingConsentBanner />
    </div>
  );
}

function RouteLifecycleEffects({
  page,
  routeKey,
  hash,
}: {
  page: PageKey;
  routeKey: string;
  hash: string;
}) {
  useRevealAnimations(page, routeKey);
  useHashScroll(page, hash);
  return null;
}

function RouteLoadingState() {
  return <div className="route-loading" aria-busy="true" />;
}

export default App;
