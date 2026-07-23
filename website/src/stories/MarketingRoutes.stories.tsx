import type {Meta, StoryObj} from "@storybook/react-vite";
import {MemoryRouter} from "react-router";
import {useRevealAnimations} from "../app/usePageLifecycle";
import {ClaimPage} from "../features/claims/ClaimPage";
import {emptyClaimRouteState} from "../features/claims/claimRouting";
import {HomePage} from "../features/home/HomePage";
import {HostPage} from "../features/host/HostPage";
import {EventDetailPage} from "../features/events/EventDetailPage";
import {NotFoundPage} from "../features/notFound/NotFoundPage";
import {LegalPage} from "../features/legal/LegalPage";
import {publishedLegalContent} from "../content/legal";
import {hostListings} from "./fixtures/hostListings";
import {HostListingPage} from "../features/organizers/HostListingPage";
import {OrganizerSearchPage} from "../features/organizers/OrganizerSearchPage";
import type {HostListing} from "../features/organizers/types";
import {WebsiteQueryProvider} from "../shared/query/queryClient";
import {PageShell} from "../shared/site";
import {captures} from "./fixtures/marketingCaptures";
import {
  catchEventDetailFixture,
  externalEventDetailFixture,
} from "./fixtures/eventDetails";
import type {EventDetailRecord} from "../features/events/eventDetailModel";

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
  render: () => (
    <PageShell pageClassName="not-found-page">
      <NotFoundPage />
    </PageShell>
  ),
};

export const Privacy: Story = {
  name: "/privacy/",
  parameters: {
    catchRoute: {
      id: "privacy",
      path: "/privacy/",
      reviewStates: ["published"],
      stateCoverage: {storybook: ["published"], manual: []},
    },
    catchComponent: {
      id: "route_legal",
      routeIds: ["privacy", "terms", "help"],
      states: ["privacy", "terms", "help"],
    },
  },
  render: () => <LegalStoryPage pageKey="privacy" />,
};

export const Terms: Story = {
  name: "/terms/",
  parameters: {
    catchRoute: {
      id: "terms",
      path: "/terms/",
      reviewStates: ["published"],
      stateCoverage: {storybook: ["published"], manual: []},
    },
  },
  render: () => <LegalStoryPage pageKey="terms" />,
};

export const Help: Story = {
  name: "/help/",
  parameters: {
    catchRoute: {
      id: "help",
      path: "/help/",
      reviewStates: ["published"],
      stateCoverage: {storybook: ["published"], manual: []},
    },
  },
  render: () => <LegalStoryPage pageKey="help" />,
};

export const LegalDocumentShell: Story = {
  name: "Legal document shell",
  parameters: {
    catchComponent: {
      id: "shared_legal_document_shell",
      routeIds: ["privacy", "terms", "help"],
      states: ["document", "sections", "contact"],
    },
  },
  render: () => <LegalStoryPage pageKey="privacy" />,
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
      <OrganizerSearchPage listings={hostListings} />
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

export const EventDetailCatch: Story = {
  name: "/events/:eventId/ · Catch",
  parameters: {
    catchRoute: {
      id: "event_detail_canonical",
      path: catchEventDetailFixture.path,
      reviewStates: [
        "catch-native",
        "external-source",
        "event-reviews",
        "missing-event",
      ],
      stateCoverage: {
        storybook: ["catch-native", "external-source", "event-reviews"],
        manual: ["missing-event"],
      },
    },
    catchComponent: {
      id: "route_event_detail",
      routeIds: ["event_detail_canonical"],
      states: ["catch-native", "external-source", "event-reviews"],
    },
  },
  render: () => <EventDetailRouteStory event={catchEventDetailFixture} />,
};

export const EventDetailExternal: Story = {
  name: "/events/:eventId/ · external",
  render: () => <EventDetailRouteStory event={externalEventDetailFixture} />,
};

function EventDetailRouteStory({event}: {event: EventDetailRecord}) {
  useRevealAnimations("event_detail", event.eventId);
  return <EventDetailPage event={event} />;
}

function requireListing(id: string): HostListing {
  const listing = hostListings.find((item) => item.id === id);
  if (!listing) {
    throw new Error(`Missing generated organizer listing fixture: ${id}`);
  }
  return listing;
}

function LegalStoryPage({pageKey}: {pageKey: "privacy" | "terms" | "help"}) {
  return (
    <PageShell pageClassName="legal-page">
      <LegalPage
        page={publishedLegalContent.pages[pageKey]}
        effectiveDate={publishedLegalContent.effectiveDate}
      />
    </PageShell>
  );
}
