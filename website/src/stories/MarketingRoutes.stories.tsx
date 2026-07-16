import type {Meta, StoryObj} from "@storybook/react-vite";
import {MemoryRouter} from "react-router";
import {ClaimPage} from "../features/claims/ClaimPage";
import {emptyClaimRouteState} from "../features/claims/claimRouting";
import {HomePage} from "../features/home/HomePage";
import {HostPage} from "../features/host/HostPage";
import {NotFoundPage} from "../features/notFound/NotFoundPage";
import {hostListings} from "./fixtures/hostListings";
import {HostListingPage} from "../features/organizers/HostListingPage";
import {OrganizerSearchPage} from "../features/organizers/OrganizerSearchPage";
import type {HostListing} from "../features/organizers/types";
import {WebsiteQueryProvider} from "../shared/query/queryClient";
import {captures} from "./fixtures/marketingCaptures";

const generatedOrganizerListing = requireListing("afterfly");

const meta = {
  title: "Marketing Website/Routes",
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

export const Home: Story = {
  name: "/",
  parameters: {
    a11y: {test: "todo"},
    catchRoute: {
      id: "home",
      path: "/",
      reviewStates: ["default", "app-download-pending", "waitlist-form"],
      stateCoverage: {
        storybook: ["default"],
        manual: ["app-download-pending", "waitlist-form"],
      },
    },
    catchComponent: {
      id: "route_home",
      routeIds: ["home"],
      states: ["default", "app-download-pending", "waitlist-form"],
    },
  },
  render: () => <HomePage captures={captures} />,
};

export const Host: Story = {
  name: "/host/",
  parameters: {
    a11y: {test: "todo"},
    catchRoute: {
      id: "host",
      path: "/host/",
      reviewStates: [
        "default",
        "founding-host-offer",
        "host-application",
        "capture-placeholders",
      ],
      stateCoverage: {
        storybook: ["default"],
        manual: ["founding-host-offer", "host-application", "capture-placeholders"],
      },
    },
    catchComponent: {
      id: "route_host",
      routeIds: ["host"],
      states: [
        "default",
        "founding-host-offer",
        "host-application",
        "capture-placeholders",
      ],
    },
  },
  render: () => <HostPage captures={captures} />,
};

export const Claim: Story = {
  name: "/claim/",
  parameters: {
    a11y: {test: "todo"},
    catchRoute: {
      id: "claim",
      path: "/claim/",
      reviewStates: [
        "default",
        "not-found",
        "pending-claim",
        "already-claimed",
        "claim-unavailable",
      ],
      stateCoverage: {
        storybook: ["default"],
        manual: [
          "not-found",
          "pending-claim",
          "already-claimed",
          "claim-unavailable",
        ],
      },
    },
    catchComponent: {
      id: "route_claim",
      routeIds: ["claim", "claim_lookup"],
      states: [
        "default",
        "not-found",
        "pending-claim",
        "already-claimed",
        "claim-unavailable",
      ],
    },
  },
  render: () => (
    <WebsiteQueryProvider>
      <MemoryRouter initialEntries={["/claim/"]}>
        <ClaimPage routeState={emptyClaimRouteState} />
      </MemoryRouter>
    </WebsiteQueryProvider>
  ),
};

export const NotFound: Story = {
  name: "/404/",
  parameters: {
    catchRoute: {
      id: "not_found",
      path: "/404/",
      reviewStates: ["unknown-route", "missing-organizer-listing"],
      stateCoverage: {
        storybook: ["unknown-route"],
        manual: ["missing-organizer-listing"],
      },
    },
    catchComponent: {
      id: "route_not_found",
      routeIds: ["not_found"],
      states: ["unknown-route"],
    },
  },
  render: () => <NotFoundPage />,
};

export const OrganizerSearch: Story = {
  name: "/organizers/",
  parameters: {
    a11y: {test: "todo"},
    catchRoute: {
      id: "organizer_search",
      path: "/organizers/",
      reviewStates: ["default", "filtered", "empty-results", "saved-organizers"],
      stateCoverage: {
        storybook: ["default"],
        manual: ["filtered", "empty-results", "saved-organizers"],
      },
    },
    catchComponent: {
      id: "route_organizer_search",
      routeIds: ["organizer_search"],
      states: ["default", "filtered", "empty-results", "saved-organizers"],
    },
  },
  render: () => (
    <MemoryRouter initialEntries={["/organizers/"]}>
      <OrganizerSearchPage />
    </MemoryRouter>
  ),
};

export const OrganizerListing: Story = {
  name: "/organizers/:slug/",
  parameters: {
    catchRoute: {
      id: "organizer_listing_canonical",
      path: generatedOrganizerListing.path,
      reviewStates: [
        "indexable",
        "noindex",
        "public-api-disabled",
        "external-events",
        "claim-cta",
      ],
      stateCoverage: {
        storybook: ["claim-cta"],
        manual: [
          "indexable",
          "noindex",
          "public-api-disabled",
          "external-events",
        ],
      },
    },
    catchComponent: {
      id: "route_organizer_listing",
      routeIds: ["organizer_listing_canonical", "organizer_listing_legacy"],
      states: ["claimable-unclaimed", "missing-evidence", "listing-reviews"],
    },
  },
  render: () => (
    <WebsiteQueryProvider>
      <MemoryRouter initialEntries={[generatedOrganizerListing.path]}>
        <HostListingPage listing={generatedOrganizerListing} />
      </MemoryRouter>
    </WebsiteQueryProvider>
  ),
};

function requireListing(id: string): HostListing {
  const listing = hostListings.find((item) => item.id === id);
  if (!listing) {
    throw new Error(`Missing generated organizer listing fixture: ${id}`);
  }
  return listing;
}
