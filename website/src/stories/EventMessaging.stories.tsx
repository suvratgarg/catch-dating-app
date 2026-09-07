import {EventMessageWithdrawalCard} from "../features/eventMessaging/EventMessageWithdrawalPanel";
import {EventAssistanceView} from "../features/eventAssistance/EventAssistancePage";
import {eventMessagingCopy, eventWhatsappMessagingCopy} from "../content/eventMessaging";
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

export const MessageWithdrawal: Story = {
  parameters: {catchComponent: {id: "event_message_withdrawal_card",
    routeIds: ["event_assistance"], states: ["enabled", "disabled", "uncertain", "error", "loading", "closed-instructions"]}},
  render: () => <WithdrawalPreview />,
};
export const MessageWithdrawalSaved: Story = {render: () => <WithdrawalPreview preference="disabled" />};
export const MessageWithdrawalUncertain: Story = {render: () => <WithdrawalPreview uncertain />};
export const MessageWithdrawalError: Story = {render: () => <WithdrawalPreview kind="error" />};
export const MessageWithdrawalLoading: Story = {render: () => <WithdrawalPreview kind="loading" />};

function WithdrawalPreview({preference = "enabled", uncertain = false, kind = "ready", channel = "sms"}: {
  channel?: "sms" | "whatsapp";
  preference?: "enabled" | "disabled"; uncertain?: boolean; kind?: "ready" | "error" | "loading";
}) {
  const [saved, setSaved] = useState(false);
  const copy = channel === "sms" ? eventMessagingCopy : eventWhatsappMessagingCopy;
  const card = <EventMessageWithdrawalCard channel={channel} state={kind !== "ready" ? {kind} : {kind,
    view: {preference: saved ? "disabled" : preference, revision: 1, serverTime: 1000, expiresAt: 100_000},
    pending: false, uncertain: uncertain && !saved, notice: uncertain && !saved ? copy.uncertain : ""}}
    withdraw={() => setSaved(true)} refresh={() => undefined} />;
  return <EventAssistanceView screen={{kind: "unavailable", reason: "eventClosed"}}
    refreshing={false} refresh={() => undefined} submit={() => undefined} textPreferences={card} />;
}

export const EventSectionStack: Story = {
  parameters: {catchComponent: {id: "event_runtime_section_stack",
    routeIds: ["event_assistance"], states: ["sections", "closed-instructions"]}},
  render: () => <WithdrawalPreview />,
};


export const WhatsappMessageWithdrawal: Story = {
  parameters: {catchComponent: {id: "event_message_withdrawal_card",
    routeIds: ["event_assistance"], states: ["whatsapp", "closed-instructions"]}},
  render: () => <WithdrawalPreview channel="whatsapp" />,
};
export const WhatsappMessageWithdrawalSaved: Story = {
  render: () => <WithdrawalPreview channel="whatsapp" preference="disabled" />,
};
export const WhatsappMessageWithdrawalUncertain: Story = {
  render: () => <WithdrawalPreview channel="whatsapp" uncertain />,
};
