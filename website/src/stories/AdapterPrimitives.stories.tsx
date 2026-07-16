import type {Meta, StoryObj} from "@storybook/react-vite";
import {MarketingConsentBanner} from "../features/marketing/MarketingConsentBanner";
import {hostListings} from "./fixtures/hostListings";
import {
  ActivityMark as OrganizerActivityMark,
  StatusBadge as OrganizerStatusBadge,
} from "../features/organizers/OrganizerIdentity";
import type {HostListing} from "../features/organizers/types";
import {
  CaptureCard as HostCaptureCard,
  PhoneCaptureFrame,
  type HostCaptureMap,
} from "../features/host/sections/CaptureFrames";
import {
  BadgeRow,
  CaptureCard,
  CaptureGrid,
  ContentGrid,
  PhoneCaptureShell,
} from "../shared/ui/primitives";

const captures: HostCaptureMap = {
  "member-event-discovery": {
    id: "member-event-discovery",
    alt: "Catch member event discovery screen",
    caption: "Members browse source-backed hosted events before any dating surface opens.",
    walkthroughStep: "Discover",
    webPath: "/assets/app-screenshots/member-event-discovery.png",
  },
  "host-live-console": {
    id: "host-live-console",
    alt: "Catch host live console screen",
    caption: "Hosts reconcile check-ins, waitlist movement, and live event notes.",
    walkthroughStep: "Run",
    webPath: "/assets/app-screenshots/host-live-console.png",
  },
};

const unclaimedListing = requireListing("afterfly");
const verifiedListing = requireListing("sunday-table-club");
const claimedListing: HostListing = {
  ...verifiedListing,
  listingVariant: "unclaimedScraped",
  sourceConfidence: "medium",
  status: "claimed",
};

const meta = {
  title: "Marketing Website/Shared/Adapters",
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

export const CaptureShellStory: Story = {
  name: "Capture shell",
  parameters: {
    catchComponent: {
      id: "shared_capture_card_shell",
      routeIds: ["home", "host"],
      states: ["shared-capture", "fallback", "phone-shell"],
    },
  },
  render: () => (
    <CaptureGrid variant="host">
      <CaptureCard
        id="member-event-discovery"
        fallbackStep="Discover"
        captures={captures}
      />
      <CaptureCard
        id="missing-capture-slot"
        fallbackStep="Fallback"
        captures={captures}
      />
      <PhoneCaptureShell
        captureSlotId="host-live-console"
        caption="Phone capture shells keep the device frame canonical."
      >
        <img
          src="/assets/app-screenshots/host-live-console.png"
          alt="Catch host live console screen"
          loading="lazy"
        />
      </PhoneCaptureShell>
    </CaptureGrid>
  ),
};

export const HostCaptureCardAdapterStory: Story = {
  name: "Host capture card adapter",
  parameters: {
    catchComponent: {
      id: "host_capture_card_adapter",
      routeIds: ["home", "host"],
      states: ["shared-capture-adapter"],
    },
  },
  render: () => (
    <CaptureGrid variant="host">
      <HostCaptureCard
        id="member-event-discovery"
        fallbackStep="Discover"
        captures={captures}
      />
      <HostCaptureCard
        id="host-live-console"
        fallbackStep="Run"
        captures={captures}
      />
    </CaptureGrid>
  ),
};

export const HostPhoneCaptureFrameAdapterStory: Story = {
  name: "Host phone capture frame adapter",
  parameters: {
    catchComponent: {
      id: "host_phone_capture_frame_adapter",
      routeIds: ["host"],
      states: ["shared-phone-capture-adapter"],
    },
  },
  render: () => (
    <CaptureGrid variant="host">
      <PhoneCaptureFrame
        id="host-live-console"
        fallbackStep="Run live event"
        captures={captures}
      />
      <PhoneCaptureFrame
        id="host-post-event-report"
        fallbackStep="Review outcome"
        captures={captures}
      />
    </CaptureGrid>
  ),
};

export const MarketingConsentBannerAdapterStory: Story = {
  name: "Marketing consent adapter",
  parameters: {
    catchComponent: {
      id: "marketing_consent_banner_adapter",
      routeIds: ["home", "host", "claim", "claim_lookup", "not_found", "organizer_search", "organizer_listing_canonical", "organizer_listing_legacy"],
      states: ["app-shell-consent-state"],
    },
  },
  render: () => <MarketingConsentBanner />,
};

export const OrganizerActivityMarkAdapterStory: Story = {
  name: "Organizer activity mark adapter",
  parameters: {
    a11y: {test: "todo"},
    catchComponent: {
      id: "organizer_activity_mark_adapter",
      routeIds: ["home", "claim", "claim_lookup", "organizer_search", "organizer_listing_canonical", "organizer_listing_legacy"],
      states: ["listing-activity-derived"],
    },
  },
  render: () => (
    <ContentGrid variant="surface">
      <article>
        <OrganizerActivityMark listing={verifiedListing} size="lg" />
        <h3>{verifiedListing.name}</h3>
        <p>Activity copy is derived from generated listing data before rendering the shared mark.</p>
      </article>
      <article>
        <OrganizerActivityMark listing={unclaimedListing} size="lg" />
        <h3>{unclaimedListing.name}</h3>
        <p>Unclaimed public profiles still route through the same canonical visual primitive.</p>
      </article>
    </ContentGrid>
  ),
};

export const OrganizerStatusBadgeAdapterStory: Story = {
  name: "Organizer status badge adapter",
  parameters: {
    a11y: {test: "todo"},
    catchComponent: {
      id: "organizer_status_badge_adapter",
      routeIds: ["home", "claim", "claim_lookup", "organizer_search", "organizer_listing_canonical", "organizer_listing_legacy"],
      states: ["verified", "claimed", "unclaimed"],
    },
  },
  render: () => (
    <BadgeRow>
      <OrganizerStatusBadge listing={verifiedListing} />
      <OrganizerStatusBadge listing={claimedListing} />
      <OrganizerStatusBadge listing={unclaimedListing} compact />
    </BadgeRow>
  ),
};

function requireListing(slug: string) {
  const listing = hostListings.find((item) => item.slug === slug);
  if (!listing) {
    throw new Error(`Missing organizer listing fixture: ${slug}`);
  }
  return listing;
}
