import {
  getPageKey,
  pageClassFor,
  pageMeta,
  pageMetaForListing,
  type PageKey,
} from "./app/pageMeta";
import {
  useDocumentMeta,
  useHashScroll,
  useMarketingAnalytics,
  useMarketingCaptures,
  useRevealAnimations,
} from "./app/usePageLifecycle";
import {ClaimPage} from "./features/claims/ClaimPage";
import {MarketingConsentBanner} from "./features/marketing/MarketingConsentBanner";
import {
  getHostListingRouteForPath,
} from "./features/organizers/routing";
import {HostPage, HostPreviewPage} from "./features/host/HostPages";
import {HomePage} from "./features/home/HomePage";
import {HostListingPage} from "./features/organizers/HostListingPage";
import {OrganizerSearchPage} from "./features/organizers/OrganizerSearchPage";

function App() {
  const listingRoute = getHostListingRouteForPath(window.location.pathname);
  const listing = listingRoute?.listing ?? null;
  const fallbackPage = getPageKey();
  const page: PageKey = listing ? "listing" : fallbackPage;
  const isHostPreview = window.location.pathname.startsWith("/host/preview");
  const captures = useMarketingCaptures();
  const meta = listingRoute ?
    pageMetaForListing(listingRoute.listing, {
      noindexOverride: listingRoute.isLegacyPath,
    }) :
    pageMeta[fallbackPage];
  const shellClassName = isHostPreview
    ? `${pageClassFor(page)} host-preview-page`
    : pageClassFor(page);

  useMarketingAnalytics(page);
  useDocumentMeta(meta);
  useRevealAnimations(page);
  useHashScroll(page);

  return (
    <div className={`page-shell ${shellClassName}`}>
      {listing ? (
        <HostListingPage listing={listing} />
      ) : isHostPreview ? (
        <HostPreviewPage captures={captures} />
      ) : page === "host" ? (
        <HostPage captures={captures} />
      ) : page === "organizers" ? (
        <OrganizerSearchPage />
      ) : page === "claim" ? (
        <ClaimPage />
      ) : (
        <HomePage captures={captures} />
      )}
      <MarketingConsentBanner />
    </div>
  );
}

export default App;
