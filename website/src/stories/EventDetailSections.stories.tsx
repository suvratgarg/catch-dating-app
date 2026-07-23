import type {Meta, StoryObj} from "@storybook/react-vite";
import type {ReactNode} from "react";
import {useRevealAnimations} from "../app/usePageLifecycle";
import {useAppDownloadCtas} from "../features/marketing/useAppDownloadCtas";
import {
  EventDetailFactsSection,
  EventDetailHeroSection,
  EventDetailProvenanceSection,
  EventDetailReviewsSection,
} from "../features/events/sections/EventDetailSections";
import {
  catchEventDetailFixture,
  externalEventDetailFixture,
} from "./fixtures/eventDetails";

const meta = {
  title: "Marketing Website/Events/Event Detail Sections",
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

export const EventDetailShells: Story = {
  name: "Shared shells",
  parameters: {
    catchComponent: {
      id: "shared_event_detail_shells",
      routeIds: ["event_detail_canonical"],
      states: [
        "catch-native",
        "external-source",
        "fact-grid",
        "provenance",
        "event-media",
        "organizer-panel",
        "review-preview",
      ],
    },
  },
  render: () => (
    <EventDetailRevealStory routeKey="shared-shells">
      <EventDetailFactsSection event={externalEventDetailFixture} />
      <EventDetailProvenanceSection event={externalEventDetailFixture} />
    </EventDetailRevealStory>
  ),
};

export const EventDetailHero: Story = {
  name: "Hero · Catch",
  parameters: {
    catchComponent: {
      id: "event_detail_hero_section",
      routeIds: ["event_detail_canonical"],
      states: [
        "catch-native",
        "external-source",
        "desktop-ticket-rail",
        "mobile-single-column",
        "review-preview",
      ],
    },
  },
  render: () => <CatchHeroStory />,
};

export const EventDetailHeroExternal: Story = {
  name: "Hero · external",
  render: () => <ExternalHeroStory />,
};

export const EventDetailFacts: Story = {
  name: "Facts",
  parameters: {
    catchComponent: {
      id: "event_detail_facts_section",
      routeIds: ["event_detail_canonical"],
      states: ["complete", "missing-optional-details"],
    },
  },
  render: () => (
    <EventDetailRevealStory routeKey="facts">
      <EventDetailFactsSection event={externalEventDetailFixture} />
    </EventDetailRevealStory>
  ),
};

export const EventDetailReviews: Story = {
  name: "Reviews",
  parameters: {
    catchComponent: {
      id: "event_detail_reviews_section",
      routeIds: ["event_detail_canonical"],
      states: ["verified-event-reviews", "empty"],
    },
  },
  render: () => (
    <EventDetailRevealStory routeKey="reviews">
      <EventDetailReviewsSection event={catchEventDetailFixture} />
    </EventDetailRevealStory>
  ),
};

export const EventDetailProvenance: Story = {
  name: "Provenance",
  parameters: {
    catchComponent: {
      id: "event_detail_provenance_section",
      routeIds: ["event_detail_canonical"],
      states: ["catch-native", "external-source"],
    },
  },
  render: () => (
    <EventDetailRevealStory routeKey="provenance">
      <EventDetailProvenanceSection event={externalEventDetailFixture} />
    </EventDetailRevealStory>
  ),
};

function CatchHeroStory() {
  useRevealAnimations("event_detail", "hero-catch");
  const appDownloadCtas = useAppDownloadCtas({
    placement: "event-detail-story-catch",
  });
  return (
    <EventDetailHeroSection
      appDownloadCtas={appDownloadCtas}
      event={catchEventDetailFixture}
    />
  );
}

function ExternalHeroStory() {
  useRevealAnimations("event_detail", "hero-external");
  const appDownloadCtas = useAppDownloadCtas({
    placement: "event-detail-story-external",
  });
  return (
    <EventDetailHeroSection
      appDownloadCtas={appDownloadCtas}
      event={externalEventDetailFixture}
    />
  );
}

function EventDetailRevealStory({
  children,
  routeKey,
}: {
  children: ReactNode;
  routeKey: string;
}) {
  useRevealAnimations("event_detail", routeKey);
  return children;
}
