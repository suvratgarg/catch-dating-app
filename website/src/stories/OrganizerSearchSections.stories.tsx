import type {Meta, StoryObj} from "@storybook/react-vite";
import {MemoryRouter} from "react-router";
import {hostListings} from "./fixtures/hostListings";
import {
  DirectoryClaimPressureStrip,
  OrganizerResultsSection,
  OrganizerSearchHeroSection,
} from "../features/organizers/sections/OrganizerSearchSections";
import {isUnclaimedListing} from "../features/organizers/selectors";
import {useOrganizerDirectoryController} from "../features/organizers/useOrganizerDirectoryController";

const claimableListings = hostListings.filter(isUnclaimedListing).slice(0, 3);

const meta = {
  title: "Marketing Website/Organizers/Search Sections",
  parameters: {
    catchComponentRegistry: {
      path: "design/website/components.json",
    },
    catchRouteContract: {
      path: "design/website/routes.json",
    },
  },
} satisfies Meta;

export default meta;

type Story = StoryObj<typeof meta>;

export const OrganizerSearchHero: Story = {
  name: "Search hero and filters",
  parameters: {
    catchComponent: {
      id: "organizer_search_hero",
      routeIds: ["organizer_search"],
      states: ["default", "filtered"],
    },
  },
  render: () => (
    <MemoryRouter initialEntries={["/organizers/?q=dinner&status=unclaimed"]}>
      <OrganizerSearchHeroFrame />
    </MemoryRouter>
  ),
};

export const DirectoryClaimPressure: Story = {
  name: "Claim pressure strip",
  parameters: {
    catchComponent: {
      id: "organizer_directory_claim_pressure",
      routeIds: ["organizer_search"],
      states: ["default", "claimable-listings"],
    },
  },
  render: () => (
    <DirectoryClaimPressureStrip
      claimableListings={claimableListings}
      eventBackedCount={hostListings.filter((listing) =>
        Boolean(listing.catchEvents?.length || listing.externalEvents?.length || listing.eventEvidence?.length)
      ).length}
      unclaimedCount={claimableListings.length}
    />
  ),
};

export const OrganizerResults: Story = {
  name: "Results list",
  parameters: {
    a11y: {test: "todo"},
    catchComponent: {
      id: "organizer_results_section",
      routeIds: ["organizer_search"],
      states: ["default", "event-backed", "unclaimed"],
    },
  },
  render: () => (
    <OrganizerResultsSection
      appearanceContext="storybook|results"
      clearFilters={() => undefined}
      queryTerms={["run"]}
      results={hostListings}
    />
  ),
};

export const OrganizerResultsEmpty: Story = {
  name: "Results list · empty",
  parameters: {
    catchComponent: {
      id: "organizer_results_section",
      routeIds: ["organizer_search"],
      states: ["empty-results"],
    },
  },
  render: () => (
    <OrganizerResultsSection
      appearanceContext="storybook|empty"
      clearFilters={() => undefined}
      queryTerms={["no-match"]}
      results={[]}
    />
  ),
};

function OrganizerSearchHeroFrame() {
  const controller = useOrganizerDirectoryController(hostListings);
  return <OrganizerSearchHeroSection controller={controller} />;
}
