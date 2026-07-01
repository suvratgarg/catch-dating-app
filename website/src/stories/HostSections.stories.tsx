import type {Meta, StoryObj} from "@storybook/react-vite";
import {HostApplicationFlow} from "../features/host/application/HostApplicationFlow";
import {CreateEventWalkthrough as CreateEventWalkthroughComponent} from "../features/host/sections/CreateEventWalkthrough";
import {EventSuccessShowcase as EventSuccessShowcaseComponent} from "../features/host/sections/EventSuccessShowcase";
import {HostComparisonSection as HostComparisonSectionComponent} from "../features/host/sections/HostComparisonSection";
import {captures, placeholderCaptures} from "./fixtures/marketingCaptures";

const meta = {
  title: "Marketing Website/Host/Sections",
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

export const CreateEventWalkthroughSection: Story = {
  name: "Create event walkthrough",
  parameters: {
    catchComponent: {
      id: "host_create_event_walkthrough",
      routeIds: ["host", "host_preview"],
      states: ["default", "interactive-steps", "capture-fallback"],
    },
  },
  render: () => <CreateEventWalkthroughComponent captures={captures} />,
};

export const CreateEventWalkthroughFallback: Story = {
  name: "Create event walkthrough · fallback captures",
  parameters: {
    catchComponent: {
      id: "host_create_event_walkthrough",
      routeIds: ["host", "host_preview"],
      states: ["capture-fallback"],
    },
  },
  render: () => <CreateEventWalkthroughComponent captures={placeholderCaptures} />,
};

export const EventSuccessShowcaseSection: Story = {
  name: "Event Success showcase",
  parameters: {
    catchComponent: {
      id: "host_event_success_showcase",
      routeIds: ["host"],
      states: ["default", "activity", "after", "debrief"],
    },
  },
  render: () => <EventSuccessShowcaseComponent captures={captures} />,
};

export const HostComparisonSectionStory: Story = {
  name: "Host comparison",
  parameters: {
    catchComponent: {
      id: "host_comparison_section",
      routeIds: ["host", "host_preview"],
      states: ["collapsed", "expanded-interaction"],
    },
  },
  render: () => <HostComparisonSectionComponent />,
};

export const HostApplicationFlowInitial: Story = {
  name: "Host application flow · initial",
  parameters: {
    catchComponent: {
      id: "host_application_flow",
      routeIds: ["host", "host_preview"],
      states: ["initial", "interactive-steps"],
    },
  },
  render: () => (
    <section
      className="waitlist-section"
      id="founding-hosts"
      aria-labelledby="host-application-story-title"
    >
      <div className="waitlist__intro">
        <h2 id="host-application-story-title">
          Bring the format. Catch handles the loop around it.
        </h2>
        <p>
          Apply as a founding host if you run events, communities, venues, or
          formats where the right singles can meet with more context.
        </p>
      </div>
      <HostApplicationFlow />
    </section>
  ),
};
