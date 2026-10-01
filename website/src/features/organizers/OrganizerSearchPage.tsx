import {websiteCopy} from "@content/generated";
import {PublicSiteFooter, PublicSiteHeader, WebsitePageMain} from "../../shared/site";
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
      <PublicSiteHeader />

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

      <PublicSiteFooter
        body={websiteCopy["organizersearchpage_0352"]}
        links={[
          {href: "/host/", label: websiteCopy["organizersearchpage_0349"]},
          {href: "/explore/", label: websiteCopy["organizersearchpage_0350"]},
          {href: "/organizers/?q=run", label: websiteCopy["organizersearchpage_0351"]},
          {href: "/organizers/?q=dinner", label: websiteCopy["organizersearchpage_0348"]},
        ]}
      />
    </>
  );
}
