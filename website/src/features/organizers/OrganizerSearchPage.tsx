import {websiteCopy} from "@content/generated";
import {SiteFooter, SiteHeader, WebsitePageMain} from "../../shared/site";
import {
  DirectoryClaimPressureStrip,
  OrganizerResultsSection,
  OrganizerSearchHeroSection,
} from "./sections/OrganizerSearchSections";
import {useOrganizerDirectoryController} from "./useOrganizerDirectoryController";

export function OrganizerSearchPage() {
  const controller = useOrganizerDirectoryController();
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
        nav={[
          {href: "/host/", label: websiteCopy["organizersearchpage_0349"]},
          {href: "/", label: websiteCopy["organizersearchpage_0350"]},
        ]}
        ctaHref="/host/#founding-hosts"
        ctaLabel={websiteCopy["organizersearchpage_0347"]}
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
          {href: "/", label: websiteCopy["organizersearchpage_0350"]},
          {href: "/organizers/?q=run", label: websiteCopy["organizersearchpage_0351"]},
          {href: "/organizers/?q=dinner", label: websiteCopy["organizersearchpage_0348"]},
        ]}
      />
    </>
  );
}
