import type {Meta, StoryObj} from "@storybook/react-vite";
import type {FormEvent, ReactNode} from "react";
import type {ListingClaimController} from "../features/claims/useListingClaimController";
import {hostListings} from "./fixtures/hostListings";
import {
  ListingCatchEventsSection,
  ListingEventEvidenceSection,
  ListingEventSuccessSection,
  ListingExternalEventsSection,
} from "../features/organizers/sections/ListingEventsSections";
import {ListingFactsSection} from "../features/organizers/sections/ListingFactsSection";
import {ListingFitSection} from "../features/organizers/sections/ListingFitSection";
import {ListingHeroSection} from "../features/organizers/sections/ListingHeroSection";
import {ListingMissingEvidenceSection} from "../features/organizers/sections/ListingClaimSections";
import {ListingReviewsSection} from "../features/organizers/sections/ListingReviewsSection";
import {ListingSourcesSection} from "../features/organizers/sections/ListingSourcesSection";
import {RecommendedOrganizersSection} from "../features/organizers/sections/RecommendedOrganizersSection";
import {claimHrefForListing} from "../features/organizers/routing";
import {isUnclaimedListing} from "../features/organizers/selectors";
import type {HostListing} from "../features/organizers/types";
import {WebsiteQueryProvider} from "../shared/query/queryClient";

const claimableListing = hostListings.find(isUnclaimedListing) ?? requireListing("afterfly");
const appCreatedListing = requireListing("club-sales-sunday-table");
const publicReviewListing: HostListing = {
  ...claimableListing,
  id: `${claimableListing.id}-public-review-story`,
  reviews: [
    {
      id: "public-review-story",
      reviewerName: "Aarav P.",
      rating: 5,
      comment:
        "The organizer made arrival easy and kept the group moving without pressure.",
      createdAt: "2026-06-18T09:00:00.000Z",
      verificationStatus: "unverified",
      source: "publicListing",
      isAnonymous: false,
      ownerResponse: null,
    },
  ],
};
const eventEvidenceListing: HostListing = {
  ...claimableListing,
  eventEvidence: [
    {
      date: "2026-07-12",
      facts: ["120 RSVPs", "Outdoor social run", "Public source verified"],
      location: `${claimableListing.city}, ${claimableListing.region}`,
      sourceHref: "https://example.com/afterfly-run-club",
      sourceLabel: "Public event page",
      summary: "A public listing ties this organizer to an upcoming run-and-social format.",
      title: "Afterfly twilight run social",
    },
  ],
  externalEvents: [
    {
      activityKind: "run_club",
      availability: "read_only_external",
      date: "Sun, 12 Jul",
      dedupeKey: "afterfly-twilight-run-social-2026-07-12",
      endTime: "2026-07-12T15:30:00.000Z",
      externalLinkCount: 1,
      id: "external-afterfly-twilight-run",
      location: `${claimableListing.city}, ${claimableListing.region}`,
      priceLabel: "Free RSVP",
      sourceHref: "https://example.com/afterfly-run-club",
      sourceLabel: "Luma",
      startTime: "2026-07-12T13:30:00.000Z",
      summary: "Read-only external supply from approved intake; Catch does not run booking for this event.",
      title: "Afterfly twilight run social",
    },
  ],
};
const listingRouteIds = ["organizer_listing_canonical", "organizer_listing_legacy"];

const meta = {
  title: "Marketing Website/Organizers/Listing Sections",
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

export const ListingHero: Story = {
  name: "Hero",
  parameters: {
    catchComponent: {
      id: "listing_hero_section",
      routeIds: listingRouteIds,
      states: ["claimable-unclaimed"],
    },
  },
  render: () => (
    <ListingHeroSection
      claimHref={claimHrefForListing(claimableListing)}
      isAppCreated={false}
      isSaved={false}
      listing={claimableListing}
      onSaveListing={() => undefined}
      onShareListing={() => undefined}
      shareStatus=""
    />
  ),
};

export const ListingFacts: Story = {
  name: "Facts · claimable",
  parameters: {
    catchComponent: {
      id: "listing_facts_section",
      routeIds: listingRouteIds,
      states: ["claimable-unclaimed"],
    },
  },
  render: () => (
    <ListingFactsSection
      isAppCreated={false}
      listing={claimableListing}
    />
  ),
};

export const ListingFactsAppCreated: Story = {
  name: "Facts · app-created",
  parameters: {
    catchComponent: {
      id: "listing_facts_section",
      routeIds: listingRouteIds,
      states: ["app-created"],
    },
  },
  render: () => (
    <ListingFactsSection
      isAppCreated
      listing={appCreatedListing}
    />
  ),
};

export const ListingCatchEvents: Story = {
  name: "Catch events",
  parameters: {
    catchComponent: {
      id: "listing_catch_events_section",
      routeIds: ["organizer_listing_canonical"],
      states: ["app-created-events"],
    },
  },
  render: () => <ListingCatchEventsSection listing={appCreatedListing} />,
};

export const ListingExternalEvents: Story = {
  name: "External events",
  parameters: {
    catchComponent: {
      id: "listing_external_events_section",
      routeIds: listingRouteIds,
      states: ["source-attributed-events"],
    },
  },
  render: () => (
    <ListingExternalEventsSection
      anchorId="external-events"
      listing={eventEvidenceListing}
    />
  ),
};

export const ListingEventEvidence: Story = {
  name: "Event evidence",
  parameters: {
    catchComponent: {
      id: "listing_event_evidence_section",
      routeIds: listingRouteIds,
      states: ["public-event-evidence"],
    },
  },
  render: () => <ListingEventEvidenceSection listing={eventEvidenceListing} />,
};

export const ListingReviews: Story = {
  name: "Reviews · verified",
  parameters: {
    a11y: {test: "todo"},
    catchComponent: {
      id: "listing_reviews_section",
      routeIds: listingRouteIds,
      states: ["verified"],
    },
  },
  render: () => (
    <QueryStoryFrame>
      <ListingReviewsSection listing={appCreatedListing} />
    </QueryStoryFrame>
  ),
};

export const ListingReviewsPublicForm: Story = {
  name: "Reviews · public form",
  parameters: {
    catchComponent: {
      id: "listing_reviews_section",
      routeIds: listingRouteIds,
      states: ["public-form"],
    },
  },
  render: () => (
    <QueryStoryFrame>
      <ListingReviewsSection listing={publicReviewListing} />
    </QueryStoryFrame>
  ),
};

export const ListingReviewsEmpty: Story = {
  name: "Reviews · empty",
  parameters: {
    catchComponent: {
      id: "listing_reviews_section",
      routeIds: listingRouteIds,
      states: ["empty"],
    },
  },
  render: () => (
    <QueryStoryFrame>
      <ListingReviewsSection listing={claimableListing} />
    </QueryStoryFrame>
  ),
};

export const ListingEventSuccess: Story = {
  name: "Playbook outcomes",
  parameters: {
    catchComponent: {
      id: "listing_event_success_section",
      routeIds: ["organizer_listing_canonical"],
      states: ["app-created-aggregate"],
    },
  },
  render: () => (
    <>
      {appCreatedListing.eventSuccessSummary ? (
        <ListingEventSuccessSection summary={appCreatedListing.eventSuccessSummary} />
      ) : null}
    </>
  ),
};

export const ListingFit: Story = {
  name: "Fit · claimable",
  parameters: {
    catchComponent: {
      id: "listing_fit_section",
      routeIds: listingRouteIds,
      states: ["claimable-unclaimed"],
    },
  },
  render: () => (
    <ListingFitSection
      isAppCreated={false}
      listing={claimableListing}
    />
  ),
};

export const ListingFitAppCreated: Story = {
  name: "Fit · app-created",
  parameters: {
    catchComponent: {
      id: "listing_fit_section",
      routeIds: listingRouteIds,
      states: ["app-created"],
    },
  },
  render: () => (
    <ListingFitSection
      isAppCreated
      listing={appCreatedListing}
    />
  ),
};

export const ListingSources: Story = {
  name: "Sources · ledger",
  parameters: {
    catchComponent: {
      id: "listing_sources_section",
      routeIds: ["organizer_listing_canonical", "organizer_listing_legacy"],
      states: ["source-ledger"],
    },
  },
  render: () => <ListingSourcesSection listing={appCreatedListing} />,
};

export const ListingSourcesClaimable: Story = {
  name: "Sources · claimable",
  parameters: {
    catchComponent: {
      id: "listing_sources_section",
      routeIds: ["organizer_listing_canonical", "organizer_listing_legacy"],
      states: ["claimable-unclaimed"],
    },
  },
  render: () => <ListingSourcesSection listing={claimableListing} />,
};

export const ListingMissingEvidence: Story = {
  name: "Missing evidence",
  parameters: {
    catchComponent: {
      id: "listing_missing_evidence_section",
      routeIds: listingRouteIds,
      states: ["missing-evidence"],
    },
  },
  render: () => (
    <ListingMissingEvidenceSection
      claimController={mockListingClaimController()}
      listing={claimableListing}
    />
  ),
};

export const ListingMissingEvidenceUnavailable: Story = {
  name: "Missing evidence · claim unavailable",
  parameters: {
    catchComponent: {
      id: "listing_missing_evidence_section",
      routeIds: listingRouteIds,
      states: ["claim-unavailable"],
    },
  },
  render: () => (
    <ListingMissingEvidenceSection
      claimController={mockListingClaimController({
        isConfigured: false,
        notConfiguredReason: "Firebase claim requests are disabled in this environment.",
        presentation: {panel: "runtimeFallback"},
        publicApiEnabled: true,
      })}
      listing={claimableListing}
    />
  ),
};

export const ListingRecommendedOrganizers: Story = {
  name: "Recommended organizers",
  parameters: {
    catchComponent: {
      id: "listing_recommended_organizers_section",
      routeIds: listingRouteIds,
      states: ["verified-nearby"],
    },
  },
  render: () => (
    <RecommendedOrganizersSection
      current={claimableListing}
      listings={hostListings}
    />
  ),
};

function QueryStoryFrame({children}: {children: ReactNode}) {
  return <WebsiteQueryProvider>{children}</WebsiteQueryProvider>;
}

function mockListingClaimController(
  overrides: Partial<ListingClaimController> = {}
): ListingClaimController {
  return {
    authReady: true,
    handleSignIn: async () => undefined,
    handleSignOut: async () => undefined,
    handleSubmit: async (event: FormEvent<HTMLFormElement>) => {
      event.preventDefault();
    },
    isConfigured: true,
    isSigningIn: false,
    isSubmitting: false,
    notConfiguredReason: "",
    presentation: {panel: "form"},
    publicApiEnabled: true,
    status: {message: "", tone: ""},
    user: null,
    ...overrides,
  };
}

function requireListing(id: string): HostListing {
  const listing = hostListings.find((item) => item.id === id);
  if (!listing) {
    throw new Error(`Missing generated organizer listing fixture: ${id}`);
  }
  return listing;
}
