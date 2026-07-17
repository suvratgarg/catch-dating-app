import type {Meta, StoryObj} from "@storybook/react-vite";
import {
  ActivityMark,
  AppDownloadCtaGroup,
  Button,
  ContentGrid,
  FeaturedOrganizerCardGrid,
  LiveMeter,
  MarketingConsentBannerShell,
  MarketingLoopList,
  MarketingSection,
  MarketingSectionCopy,
  StatusBadge,
  type ActivityMeta,
  type FeaturedOrganizerCardItem,
} from "../shared/ui/primitives";
import {memberLoop} from "@content/marketing";

const appStoreItems = [
  {
    href: "",
    kicker: "Download on the",
    label: "App Store",
    platform: "ios" as const,
  },
  {
    href: "",
    kicker: "Get it on",
    label: "Google Play",
    platform: "android" as const,
  },
];

const dinnerActivity: ActivityMeta = {
  label: "Dinner",
  short: "DN",
  token: "var(--activity-dinner)",
};

const runActivity: ActivityMeta = {
  label: "Run club",
  short: "SR",
  token: "var(--activity-run)",
};

const featuredOrganizerItems: FeaturedOrganizerCardItem[] = [
  {
    activity: (
      <ActivityMark
        activity={dinnerActivity}
        listing={{logo: {text: "ST"}, status: "verified"}}
      />
    ),
    activityColor: "var(--activity-dinner)",
    detail: "Dinner clubs, hosted introductions, and owner responses.",
    href: "/organizers/club-sales-sunday-table/",
    name: "Sunday Table Club",
    status: <StatusBadge tone="verified">Verified on Catch</StatusBadge>,
  },
  {
    activity: (
      <ActivityMark
        activity={runActivity}
        listing={{logo: {text: "AF"}, status: "unclaimed"}}
      />
    ),
    activityColor: "var(--activity-run)",
    detail: "Source-backed run socials ready for owner claim review.",
    href: "/organizers/afterfly/",
    name: "Afterfly",
    status: <StatusBadge tone="unclaimed">Claimable</StatusBadge>,
  },
];

const meta = {
  title: "Marketing Website/Shared/Marketing Primitives",
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

export const MarketingSectionShellStory: Story = {
  name: "Section shell",
  parameters: {
    catchComponent: {
      id: "shared_marketing_section_shell",
      routeIds: ["home", "host", "organizer_listing_canonical", "organizer_listing_legacy"],
      states: ["section-shell", "section-copy", "live-meter"],
    },
  },
  render: () => (
    <MarketingSection variant="proof" aria-labelledby="storybook-marketing-section-title">
      <MarketingSectionCopy
        eyebrow="Host proof"
        titleId="storybook-marketing-section-title"
        title="A marketing section configures copy, proof, and live signals."
        body="Feature sections provide the content; shared primitives own spacing, copy rails, and repeated shell styling."
        variant="proof"
      >
        <LiveMeter items={["42 source-backed organizers", "9 cities", "3 launch loops"]} />
      </MarketingSectionCopy>
    </MarketingSection>
  ),
};

export const MarketingLoopListStory: Story = {
  name: "Loop list",
  parameters: {
    catchComponent: {
      id: "shared_marketing_loop_list_shell",
      routeIds: ["home", "host"],
      states: ["member-loop", "host-loop"],
    },
  },
  render: () => (
    <MarketingLoopList
      items={memberLoop}
      variant="host"
    />
  ),
};

export const MarketingConsentBannerShellStory: Story = {
  name: "Consent banner shell",
  parameters: {
    catchComponent: {
      id: "shared_marketing_consent_banner_shell",
      routeIds: ["home", "host", "claim", "claim_lookup", "organizer_search", "organizer_listing_canonical", "organizer_listing_legacy"],
      states: ["action-row"],
    },
  },
  render: () => (
    <MarketingConsentBannerShell
      body="Catch uses essential cookies and privacy-safe analytics to understand which public routes are useful."
      actions={(
        <>
          <Button size="small" type="button">Accept</Button>
          <Button size="small" type="button" variant="ghost">Essential only</Button>
        </>
      )}
    />
  ),
};

export const AppDownloadCtaGroupStory: Story = {
  name: "App download CTA group",
  parameters: {
    catchComponent: {
      id: "shared_app_download_shell",
      routeIds: ["home", "organizer_listing_canonical", "organizer_listing_legacy"],
      states: ["default", "panel", "pending-status"],
    },
  },
  render: () => (
    <ContentGrid variant="surface">
      <AppDownloadCtaGroup
        items={appStoreItems}
        placement="storybook_default"
      />
      <AppDownloadCtaGroup
        initialStatus="Store links are queued for launch."
        items={appStoreItems}
        placement="storybook_panel"
        variant="panel"
      />
    </ContentGrid>
  ),
};

export const FeaturedOrganizerCardGridStory: Story = {
  name: "Featured organizer cards",
  parameters: {
    catchComponent: {
      id: "shared_featured_organizer_card_shell",
      routeIds: ["home", "organizer_listing_canonical", "organizer_listing_legacy"],
      states: ["organizer-cards"],
    },
  },
  render: () => (
    <FeaturedOrganizerCardGrid items={featuredOrganizerItems} />
  ),
};
