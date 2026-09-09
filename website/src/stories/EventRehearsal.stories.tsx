import {useState} from "react";
import {expect, userEvent, within} from "storybook/test";
import {eventRehearsalCopy} from "../content/eventRehearsal";
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
        "unavailable", "joining-instruction", "reply-saved", "reply-uncertain", "reply-closed",
      ],
      stateCoverage: {
        storybook: ["live-moment", "joining-instruction", "reply-saved", "reply-uncertain", "reply-closed"],
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
        "unavailable", "joining-instruction", "reply-saved", "reply-uncertain", "reply-closed",
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
      states: ["live-moment", "fault", "complete", "joining-instruction", "reply-saved", "reply-uncertain", "reply-closed"],
    },
  },
  render: () => <EventRehearsalPreviewStory />,
};

function EventRehearsalPreviewStory() {
  return (
    <EventRehearsalPreview
      bootstrap={fixture}
      onAction={() => undefined}
      onReply={() => undefined}
      onRefresh={() => undefined}
      pending={false}
      status={{message: "", tone: ""}}
    />
  );
}

const joining: EventRehearsalGuestBootstrap = {
  ...fixture, session: {...fixture.session, title: "Friday neighbourhood crawl"},
  actor: {...fixture.actor, status: "expected", guestMoment: "checkIn",
    assistanceMessage: {messageId: `outbox:${"a".repeat(64)}`,
      intentId: `message:${"b".repeat(64)}`, intentRevision: 1,
      text: "We have left the meetup point. Join us at The Courtyard, 24 Market Road. We will be here until 8:40 pm.",
      choices: [{choiceId: "on-my-way", label: "On my way"},
        {choiceId: "later", label: "Join at the next stop"},
        {choiceId: "not-coming", label: "I can’t make it"},
        {choiceId: "help", label: "I need help"}],
      lifecycle: "active", canRespond: true, responseChoiceId: null,
      expiresAt: fixture.session.virtualNowMillis + 3_600_000}},
};
export const JoiningInstructions: Story = {
  render: () => <JoiningStory mode="ready" />,
  play: async ({canvasElement}) => {
    const canvas = within(canvasElement);
    await userEvent.click(canvas.getByRole("button", {name: "On my way"}));
    await expect(canvas.getByText("Reply saved: On my way")).toBeVisible();
    await expect(canvas.getByText("Rhea · Expected")).toBeVisible();
    await expect(canvas.queryByRole("button", {name: "On my way"})).toBeNull();
  },
};
export const SavedReply: Story = {render: () => <JoiningStory mode="saved" />};
export const UncertainReply: Story = {
  render: () => <JoiningStory mode="uncertain" />,
  play: async ({canvasElement}) => {
    const canvas = within(canvasElement);
    await expect(canvas.getByRole("button", {name: "Join at the next stop"})).toBeDisabled();
    await userEvent.click(canvas.getByRole("button", {name: "On my way"}));
    await expect(canvas.getByText("Reply saved: On my way")).toBeVisible();
  },
};
export const ClosedReply: Story = {
  render: () => <JoiningStory mode="closed" />,
  play: async ({canvasElement}) => {
    const canvas = within(canvasElement);
    await expect(canvas.getByText(eventRehearsalCopy.replyClosed)).toBeVisible();
    await expect(canvas.queryByRole("button", {name: "On my way"})).toBeNull();
  },
};
function JoiningStory({mode}: {mode: "ready" | "saved" | "uncertain" | "closed"}) {
  const [response, setResponse] = useState<string | null>(mode === "saved" ? "on-my-way" : null);
  const message = joining.actor.assistanceMessage!;
  const bootstrap: EventRehearsalGuestBootstrap = {...joining, actor: {...joining.actor,
    assistanceMessage: {...message, responseChoiceId: response,
      lifecycle: response ? "responded" : "active", canRespond: !response && mode !== "closed"}}};
  return <EventRehearsalPreview bootstrap={bootstrap} onAction={() => undefined}
    onReply={(reply) => setResponse(reply.choiceId)} onRefresh={() => undefined}
    pending={false} status={{message: "", tone: ""}}
    replyState={{fresh: true, pendingChoice: null,
      retryChoice: mode === "uncertain" && !response ? "on-my-way" : null,
      notice: mode === "uncertain" && !response ? eventRehearsalCopy.replyUncertain : ""}} />;
}

export const JoiningPhone: Story = {render: () => <JoiningStory mode="ready" />};
