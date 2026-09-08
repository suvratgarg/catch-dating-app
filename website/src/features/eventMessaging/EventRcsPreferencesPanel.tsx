import {EventSenderPreferencesCard} from "./EventSenderPreferencesCard";
import {eventRcsMessagingCopy as copy} from "../../content/eventMessaging";
import {useEventRcsPreferencesController} from "./useEventRcsPreferencesController";

type Scope = {eventId: string; attendeeId: string};
export function EventRcsPreferencesPanel(scope: Scope) {
  return <ScopedPanel key={JSON.stringify(scope)} {...scope} />;
}
function ScopedPanel({eventId, attendeeId}: Scope) {
  return <EventRcsPreferencesCard {...useEventRcsPreferencesController(eventId, attendeeId)} />;
}

export function EventRcsPreferencesCard(props: ReturnType<typeof useEventRcsPreferencesController>) {
  return <EventSenderPreferencesCard {...props} copy={copy} unavailableText={props.state.kind === "ready" ?
    copy.availability[props.state.view.availability] : copy.unavailable} />;
}
