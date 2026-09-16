import {EventSenderPreferencesCard} from "./EventSenderPreferencesCard";
import {eventWhatsappMessagingCopy as copy} from "../../content/eventMessaging";
import {useEventWhatsappPreferencesController} from "./useEventWhatsappPreferencesController";

type Scope = {eventId: string; attendeeId: string};
export function EventWhatsappPreferencesPanel(scope: Scope) {
  return <ScopedPanel key={JSON.stringify(scope)} {...scope} />;
}
function ScopedPanel({eventId, attendeeId}: Scope) {
  return <EventWhatsappPreferencesCard {...useEventWhatsappPreferencesController(eventId, attendeeId)} />;
}

export function EventWhatsappPreferencesCard(props: ReturnType<typeof useEventWhatsappPreferencesController>) {
  return <EventSenderPreferencesCard {...props} copy={copy} unavailableText={props.state.kind === "ready" ?
    copy.availability[props.state.view.availability] : copy.unavailable} />;
}
