import {lazy, Suspense} from "react";
import {BrowserRouter, Route, Routes, useLocation, useParams} from "react-router";
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
import {isOrganizerSearchPath, marketingRoutePaths} from "./routeRegistry";
import {MarketingConsentBanner} from "../features/marketing/MarketingConsentBanner";
import {publishedLegalContent} from "../content/legal";
import {claimRouteStateForLocation} from "../features/claims/claimRouting";
import {
  getHostListingRouteForPath,
} from "../features/organizers/routing";
import {PageShell} from "../shared/site";
import {RouteLoadingState} from "../shared/ui/primitives";

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
const NotFoundPage = lazy(async () => ({
  default: (await import("../features/notFound/NotFoundPage")).NotFoundPage,
}));
const OrganizerSearchPage = lazy(async () => ({
  default: (await import("../features/organizers/OrganizerSearchPage")).OrganizerSearchPage,
}));
const LegalPage = lazy(async () => ({
  default: (await import("../features/legal/LegalPage")).LegalPage,
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
  const fallbackPage = pageKeyForCurrentRoute(location.pathname, Boolean(listing));
  const page: PageKey = listing ? "listing" : fallbackPage;
  const captures = useMarketingCaptures();
  const routeKey = `${location.pathname}${location.search}${location.hash}`;
  const meta = listingRoute ?
    pageMetaForListing(listingRoute.listing, {
      noindexOverride: listingRoute.isLegacyPath,
    }) :
    pageMeta[fallbackPage];

  useMarketingAnalytics(page, routeKey);
  useDocumentMeta(meta);

  return (
    <PageShell pageClassName={pageClassFor(page)}>
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
              <NotFoundPage />
            )}
          />
          <Route
            path={marketingRoutePaths.claim}
            element={<ClaimRoute />}
          />
          <Route
            path={marketingRoutePaths.claim_lookup}
            element={<ClaimRoute />}
          />
          <Route
            path={marketingRoutePaths.privacy}
            element={(
              <LegalPage
                page={publishedLegalContent.pages.privacy}
                effectiveDate={publishedLegalContent.effectiveDate}
              />
            )}
          />
          <Route
            path={marketingRoutePaths.terms}
            element={(
              <LegalPage
                page={publishedLegalContent.pages.terms}
                effectiveDate={publishedLegalContent.effectiveDate}
              />
            )}
          />
          <Route
            path={marketingRoutePaths.help}
            element={(
              <LegalPage
                page={publishedLegalContent.pages.help}
                effectiveDate={publishedLegalContent.effectiveDate}
              />
            )}
          />
          <Route
            path={marketingRoutePaths.not_found}
            element={<NotFoundPage />}
          />
        </Routes>
      </Suspense>
      <MarketingConsentBanner />
    </PageShell>
  );
}

function pageKeyForCurrentRoute(
  pathname: string,
  hasListing: boolean
): Exclude<PageKey, "listing"> {
  if (!hasListing && pathname.startsWith("/organizers/") && !isOrganizerSearchPath(pathname)) {
    return "not_found";
  }
  return getPageKey(pathname);
}

function ClaimRoute() {
  const location = useLocation();
  const {listing} = useParams<{listing?: string}>();
  const routeState = claimRouteStateForLocation(location, listing);
  return (
    <ClaimPage
      key={`${location.pathname}${location.search}`}
      routeState={routeState}
    />
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

export default App;
