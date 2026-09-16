import {EventSenderPreferencesCard} from "./EventSenderPreferencesCard";
import {eventMessagingCopy as copy} from "../../content/eventMessaging";
import {useEventSmsPreferenceController} from "./useEventSmsPreferenceController";

type Scope = {eventId: string; attendeeId: string};
export function EventSmsPreferencePanel(scope: Scope) {
  return <ScopedSmsPreferencePanel key={JSON.stringify(scope)} {...scope} />;
}
function ScopedSmsPreferencePanel({eventId, attendeeId}: Scope) {
  return <EventSmsPreferenceCard {...useEventSmsPreferenceController(eventId, attendeeId)} />;
}

export function EventSmsPreferenceCard(props: ReturnType<typeof useEventSmsPreferenceController>) {
  const state = props.state.kind === "ready" ? {...props.state,
    view: {...props.state.view, sender: {displayName: copy.senderName}}} : props.state;
  return <EventSenderPreferencesCard {...props} state={state} copy={copy}
    unavailableText={props.state.kind === "ready" ?
      copy.availability[props.state.view.availability] : copy.unavailable} />;
}
