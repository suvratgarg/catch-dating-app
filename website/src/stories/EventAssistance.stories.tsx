import {useState} from "react";
import type {Meta, StoryObj} from "@storybook/react-vite";
import {EventAssistanceView} from "../features/eventAssistance/EventAssistancePage";
import {guestUpdateFixture} from "../content/eventAssistance";
import type {AssistanceScreen} from "../features/eventAssistance/eventAssistanceModel";

const states = ["loading", "instructions", "responded", "stale", "unavailable"];
const meta = {
  title: "Marketing Website/Event update",
  parameters: {
    catchComponentRegistry: {path: "design/website/components.json"},
    catchRouteContract: {path: "design/website/routes.json"},
  },
} satisfies Meta;
export default meta;
type Story = StoryObj<typeof meta>;
const ready: Extract<AssistanceScreen, {kind: "ready"}> = {kind: "ready", view: guestUpdateFixture,
  fresh: true, pending: false, pendingChoice: null, retryChoice: null, notice: ""};

export const EventAssistance: Story = {
  name: "/event-update/:linkId/",
  parameters: {
    catchRoute: {id: "event_assistance", path: "/event-update/fixture-link/",
      reviewStates: states, stateCoverage: {storybook: states, manual: []}},
    catchComponent: {id: "route_event_assistance", routeIds: ["event_assistance"], states},
  },
  render: () => preview(ready),
};
export const GuestInstructions: Story = {
  parameters: {catchComponent: {id: "event_assistance_view",
    routeIds: ["event_assistance"], states}},
  render: () => preview(ready),
};
export const Responded: Story = {
  render: () => preview({...ready, view: {...guestUpdateFixture,
    response: {label: "I’m on my way", receivedAt: 1_000_100}, choices: []}}),
};
export const Stale: Story = {
  render: () => preview({...ready, fresh: false}),
};
export const Unavailable: Story = {
  render: () => preview({kind: "unavailable", reason: "invalid"}),
};
export const Loading: Story = {
  render: () => preview({kind: "loading"}),
};

function preview(screen: AssistanceScreen) {
  return <EventAssistanceView screen={screen} submit={() => undefined}
    refresh={() => undefined} refreshing={false} />;
}

export const GuestReply: Story = {
  name: "Reply and confirmation",
  render: () => <ReplyPreview />,
};

function ReplyPreview() {
  const [screen, setScreen] = useState<AssistanceScreen>(ready);
  return <EventAssistanceView screen={screen} refreshing={false}
    refresh={() => setScreen(ready)} submit={(choiceId) => {
      const choice = guestUpdateFixture.choices.find((item) => item.choiceId === choiceId);
      if (!choice) return;
      setScreen({...ready, view: {...guestUpdateFixture, choices: [],
        response: {label: choice.label, receivedAt: 1_000_100}}});
    }} />;
}
