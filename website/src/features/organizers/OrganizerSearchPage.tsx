import {organiserHomeCopy} from "@content/marketingOrganization";
import {websiteCopy} from "@content/generated";
import {siteFooterLegalLinks} from "@content/site";
import {SiteFooter, SiteHeader, WebsitePageMain} from "../../shared/site";
import {
  DirectoryClaimPressureStrip,
  OrganizerResultsSection,
  OrganizerSearchHeroSection,
} from "./sections/OrganizerSearchSections";
import type {HostListing} from "./types";
import {useOrganizerDirectoryController} from "./useOrganizerDirectoryController";

interface OrganizerSearchPageProps {
  listings?: readonly HostListing[];
}

export function OrganizerSearchPage({listings}: OrganizerSearchPageProps = {}) {
  const controller = useOrganizerDirectoryController(listings);
  const {
    appearanceContext,
    queryTerms,
    results,
    summary,
  } = controller;
  const {
    claimableListings,
    eventBackedCount,
    unclaimedCount,
  } = summary;

  return (
    <>
      <SiteHeader
        brandHref="/"
        menuCopy={organiserHomeCopy.menu}
        nav={organiserHomeCopy.nav.map((item) => ({...item, href: `/${item.href}`}))}
        actions={[
          {...organiserHomeCopy.actions.signIn, variant: "secondary"},
          organiserHomeCopy.actions.start,
        ]}
      />

      <WebsitePageMain id="top">
        <OrganizerSearchHeroSection controller={controller} />

        <DirectoryClaimPressureStrip
          claimableListings={claimableListings}
          eventBackedCount={eventBackedCount}
          unclaimedCount={unclaimedCount}
        />

        <OrganizerResultsSection
          appearanceContext={appearanceContext}
          clearFilters={controller.clearFilters}
          queryTerms={queryTerms}
          results={results}
        />
      </WebsitePageMain>

      <SiteFooter
        brandHref="/"
        body={websiteCopy["organizersearchpage_0352"]}
        links={[
          {href: "/host/", label: websiteCopy["organizersearchpage_0349"]},
          {href: "/explore/", label: websiteCopy["organizersearchpage_0350"]},
          {href: "/organizers/?q=run", label: websiteCopy["organizersearchpage_0351"]},
          {href: "/organizers/?q=dinner", label: websiteCopy["organizersearchpage_0348"]},
          ...siteFooterLegalLinks,
        ]}
      />
    </>
  );
}
