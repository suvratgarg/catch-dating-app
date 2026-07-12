import type {Meta, StoryObj} from "@storybook/react-vite";
import {
  HomeCapturesSection as HomeCapturesSectionComponent,
  HomeDiscoverySection as HomeDiscoverySectionComponent,
  HomeDownloadSection as HomeDownloadSectionComponent,
  HomeFeaturedOrganizersSection as HomeFeaturedOrganizersSectionComponent,
  HomeFormatsSection as HomeFormatsSectionComponent,
  HomeHeroSection as HomeHeroSectionComponent,
  HomeHostProofSection as HomeHostProofSectionComponent,
  HomeMemberLoopSection as HomeMemberLoopSectionComponent,
  HomeTrustSection as HomeTrustSectionComponent,
  HomeWaitlistSection as HomeWaitlistSectionComponent,
} from "../features/home/sections/HomePageSections";
import type {PublicEventCardModel} from "../shared/ui/primitives";
import {captures, placeholderCaptures} from "./fixtures/marketingCaptures";

const eligibleEventFixture: PublicEventCardModel = {
  activityLabel: "Dinner",
  activityToken: "var(--activity-dinner)",
  bookedCount: 18,
  capacityLimit: 24,
  city: "Mumbai",
  date: "18 Jul 2026",
  hostName: "Sunday Table Club",
  href: "/organizers/club-sales-sunday-table/#event-story-dinner",
  id: "story-dinner",
  location: "Bandra West",
  priceLabel: "₹1,200",
  summary: "A hosted long-table dinner fixture for Storybook event coverage.",
  title: "Friday long-table dinner",
  waitlistedCount: 3,
};

const meta = {
  title: "Marketing Website/Home/Sections",
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

export const HomeHeroSectionStory: Story = {
  name: "Hero",
  parameters: {
    catchComponent: {
      id: "home_hero_section",
      routeIds: ["home"],
      states: ["default", "app-download-ctas"],
    },
  },
  render: () => <HomeHeroSectionComponent />,
};

export const HomeDiscoverySectionStory: Story = {
  name: "Discovery",
  parameters: {
    catchComponent: {
      id: "home_discovery_section",
      routeIds: ["home"],
      states: ["event-grid", "search-suggestions"],
    },
  },
  render: () => <HomeDiscoverySectionComponent events={[eligibleEventFixture]} />,
};

export const HomeDiscoveryEmptyStateStory: Story = {
  name: "Discovery · empty inventory",
  parameters: {
    catchComponent: {
      id: "home_discovery_section",
      routeIds: ["home"],
      states: ["empty-state"],
    },
  },
  render: () => <HomeDiscoverySectionComponent events={[]} />,
};

export const HomeFormatsSectionStory: Story = {
  name: "Formats",
  parameters: {
    catchComponent: {
      id: "home_formats_section",
      routeIds: ["home"],
      states: ["format-grid"],
    },
  },
  render: () => <HomeFormatsSectionComponent />,
};

export const HomeFeaturedOrganizersSectionStory: Story = {
  name: "Featured organizers",
  parameters: {
    catchComponent: {
      id: "home_featured_organizers_section",
      routeIds: ["home"],
      states: ["directory-cards", "directory-cta"],
    },
  },
  render: () => <HomeFeaturedOrganizersSectionComponent />,
};

export const HomeMemberLoopSectionStory: Story = {
  name: "Member loop",
  parameters: {
    catchComponent: {
      id: "home_member_loop_section",
      routeIds: ["home"],
      states: ["loop-list"],
    },
  },
  render: () => <HomeMemberLoopSectionComponent />,
};

export const HomeHostProofSectionStory: Story = {
  name: "Host proof",
  parameters: {
    catchComponent: {
      id: "home_host_proof_section",
      routeIds: ["home"],
      states: ["host-cta", "product-board"],
    },
  },
  render: () => <HomeHostProofSectionComponent />,
};

export const HomeCapturesSectionStory: Story = {
  name: "Captures",
  parameters: {
    catchComponent: {
      id: "home_captures_section",
      routeIds: ["home"],
      states: ["capture-grid"],
    },
  },
  render: () => <HomeCapturesSectionComponent captures={captures} />,
};

export const HomeCapturesFallback: Story = {
  name: "Captures · fallback",
  parameters: {
    catchComponent: {
      id: "home_captures_section",
      routeIds: ["home"],
      states: ["capture-fallback"],
    },
  },
  render: () => <HomeCapturesSectionComponent captures={placeholderCaptures} />,
};

export const HomeDownloadSectionStory: Story = {
  name: "Download",
  parameters: {
    catchComponent: {
      id: "home_download_section",
      routeIds: ["home"],
      states: ["app-download-pending"],
    },
  },
  render: () => <HomeDownloadSectionComponent />,
};

export const HomeTrustSectionStory: Story = {
  name: "Trust",
  parameters: {
    catchComponent: {
      id: "home_trust_section",
      routeIds: ["home"],
      states: ["trust-grid"],
    },
  },
  render: () => <HomeTrustSectionComponent />,
};

export const HomeWaitlistSectionStory: Story = {
  name: "Waitlist",
  parameters: {
    a11y: {test: "todo"},
    catchComponent: {
      id: "home_waitlist_section",
      routeIds: ["home"],
      states: ["waitlist-form"],
    },
  },
  render: () => <HomeWaitlistSectionComponent />,
};
