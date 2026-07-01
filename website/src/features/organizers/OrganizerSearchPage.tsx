import {SiteFooter, SiteHeader} from "../../shared/site";
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
          {href: "/host/", label: "For hosts"},
          {href: "/", label: "Member site"},
        ]}
        ctaHref="/host/#founding-hosts"
        ctaLabel="Apply as host"
      />

      <main id="top">
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
      </main>

      <SiteFooter
        brandHref="/"
        body="Searchable profiles for hosts, clubs, venues, and social organizers."
        links={[
          {href: "/host/", label: "For hosts"},
          {href: "/", label: "Member site"},
          {href: "/organizers/?q=run", label: "Run clubs"},
          {href: "/organizers/?q=dinner", label: "Dinners"},
        ]}
      />
    </>
  );
}
