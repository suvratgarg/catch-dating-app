import {useState} from "react";
import type {Meta, StoryObj} from "@storybook/react-vite";
import {EventSmsPreferenceCard} from "../features/eventMessaging/EventSmsPreferencePanel";
import type {EventMessagingState, SmsPreferenceView} from "../features/eventMessaging/eventMessagingModel";
import {EventRuntimeFrame, EventRuntimePanel} from "../shared/ui/primitives";

const meta = {title: "Marketing Website/Event text preferences",
  parameters: {catchComponentRegistry: {path: "design/website/components.json"}},
} satisfies Meta;
export default meta;
type Story = StoryObj<typeof meta>;
const view: SmsPreferenceView = {eventId: "fixture", attendeeId: "fixture-guest",
  serverTime: 1000, revision: null, preference: "notSet", canEnable: true,
  availability: "ready", phoneLastFour: "9999", expiresAt: null,
  consent: {version: "catch-event-service-sms-v1",
    text: "Receive text messages from Catch about joining, changes and follow-up for this event, until 24 hours after it ends. I can turn them off here."}};
const ready: Extract<EventMessagingState, {kind: "ready"}> = {kind: "ready", view,
  pending: false, uncertain: false, notice: ""};

export const Preference: Story = {
  parameters: {catchComponent: {id: "event_sms_preference_card",
    routeIds: ["event_runtime", "event_detail_canonical", "event_invite"],
    states: ["offer", "enabled", "uncertain", "unavailable", "loading", "error"]}},
  render: () => <Preview initial={ready} />,
};
export const Enabled: Story = {render: () => <Preview initial={{...ready,
  view: {...view, preference: "enabled", revision: 1}}} />};
export const Uncertain: Story = {render: () => <Preview initial={{...ready,
  uncertain: true, notice: "We could not confirm the change. Retry to check whether it was saved."}} />};
export const Unavailable: Story = {render: () => <Preview initial={{...ready,
  view: {...view, canEnable: false, availability: "senderUnavailable", preference: "disabled", revision: 2}}} />};
export const Loading: Story = {render: () => <Preview initial={{kind: "loading"}} />};
export const Error: Story = {render: () => <Preview initial={{kind: "error"}} />};

function Preview({initial}: {initial: EventMessagingState}) {
  const [state, setState] = useState(initial);
  const save = (preference: "enabled" | "disabled") => setState({...ready,
    view: {...view, preference, revision: 1}, notice: preference === "enabled" ?
      "Event texts are now on." : "Event texts are now off."});
  return <EventRuntimeFrame brandLabel="Catch events" brandWord="Catch"><EventRuntimePanel kicker="Courtyard Social"
    title="You’re registered" body="Your place on the guest list is confirmed.">
    <EventSmsPreferenceCard state={state} enable={() => save("enabled")}
      disable={() => save("disabled")} retry={() => save("enabled")}
      refresh={() => setState(ready)} />
  </EventRuntimePanel></EventRuntimeFrame>;
}
