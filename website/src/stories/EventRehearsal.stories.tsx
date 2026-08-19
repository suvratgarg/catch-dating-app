import type {Meta, StoryObj} from "@storybook/react-vite";
import type {EventRehearsalGuestBootstrap} from "../firebase";
import {EventRehearsalPreview} from
  "../features/eventRehearsal/EventRehearsalPage";

const fixture: EventRehearsalGuestBootstrap = {
  slotToken: "slot_1234567890123456_token_12345678901234567890",
  practiceBanner: "Practice mode · Nothing here affects a real event",
  session: {
    title: "Courtyard social dress rehearsal",
    locationName: "Practice venue",
    status: "running",
    activeStepIndex: 3,
    virtualNowMillis: Date.parse("2026-08-19T18:45:00+05:30"),
    attendeePrompt: "Introduce yourself to someone you have not met yet.",
    moduleIds: ["arrival", "firstHello", "pods", "rotations", "reveal"],
    runtimeRevision: 8,
    faultId: "none",
  },
  actor: {
    actorId: "actor-03",
    displayName: "Rhea",
    status: "late",
    guestMoment: "assignment",
    optedOut: false,
    helpRequested: false,
    promptCompleted: false,
  },
};

const meta = {
  title: "Marketing Website/Event rehearsal",
  parameters: {
    catchComponentRegistry: {path: "design/website/components.json"},
    catchRouteContract: {path: "design/website/routes.json"},
  },
} satisfies Meta;

export default meta;
type Story = StoryObj<typeof meta>;

export const EventRehearsalLive: Story = {
  name: "/rehearse/:publicRehearsalId/",
  parameters: {
    catchRoute: {
      id: "event_rehearsal",
      path: "/rehearse/practice-link/",
      reviewStates: [
        "loading",
        "welcome",
        "live-moment",
        "fault",
        "complete",
        "unavailable",
      ],
      stateCoverage: {
        storybook: ["live-moment"],
        manual: ["loading", "welcome", "fault", "complete", "unavailable"],
      },
    },
    catchComponent: {
      id: "route_event_rehearsal",
      routeIds: ["event_rehearsal"],
      states: [
        "loading",
        "welcome",
        "live-moment",
        "fault",
        "complete",
        "unavailable",
      ],
    },
  },
  render: () => <EventRehearsalPreviewStory />,
};

export const EventRehearsalPreviewShell: Story = {
  name: "Guest phone shell",
  parameters: {
    catchComponent: {
      id: "event_rehearsal_preview",
      routeIds: ["event_rehearsal"],
      states: ["live-moment", "fault", "complete"],
    },
  },
  render: () => <EventRehearsalPreviewStory />,
};

function EventRehearsalPreviewStory() {
  return (
    <EventRehearsalPreview
      bootstrap={fixture}
      onAction={() => undefined}
      pending={false}
      status={{message: "", tone: ""}}
    />
  );
}
