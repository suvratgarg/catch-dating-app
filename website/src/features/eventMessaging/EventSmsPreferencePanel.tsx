import {Button, EventRuntimeModule, FormStatus} from "../../shared/ui/primitives";
import {eventMessagingCopy as copy} from "../../content/eventMessaging";
import type {EventMessagingState} from "./eventMessagingModel";
import {useEventSmsPreferenceController} from "./useEventSmsPreferenceController";

type Scope = {eventId: string; attendeeId: string};

export function EventSmsPreferencePanel(scope: Scope) {
  return <ScopedSmsPreferencePanel key={JSON.stringify(scope)} {...scope} />;
}

function ScopedSmsPreferencePanel({eventId, attendeeId}: Scope) {
  const controller = useEventSmsPreferenceController(eventId, attendeeId);
  return <EventSmsPreferenceCard {...controller} />;
}

export function EventSmsPreferenceCard({state, enable, disable, retry, refresh}: {
  state: EventMessagingState;
  enable: () => void; disable: () => void; retry: () => void; refresh: () => void;
}) {
  if (state.kind === "hidden") return null;
  return (
    <EventRuntimeModule title={copy.title}>
      {state.kind === "loading" ? <FormStatus status={{tone: "", message: copy.loading}} /> : null}
      {state.kind === "error" ? <>
        <FormStatus status={{tone: "is-error", message: copy.loadFailed}} />
        <Button onClick={refresh} type="button" variant="ghost">{copy.refresh}</Button>
      </> : null}
      {state.kind === "ready" ? <>
        <p>{state.view.consent.text}</p>
        {state.view.phoneLastFour ? <p>
          {copy.phonePrefix} {state.view.phoneLastFour}.
        </p> : null}
        {state.view.preference !== "notSet" ? <FormStatus status={{tone: "", message: state.view.preference === "enabled" ? copy.enabled :
          state.view.preference === "disabled" ? copy.disabled :
            state.view.preference === "expired" ? copy.expired : ""}} /> : null}
        {state.uncertain ? (
          <Button onClick={retry} type="button">{copy.retry}</Button>
        ) : state.view.preference === "enabled" ? (
          <Button onClick={disable} type="button" variant="ghost"
            disabled={state.pending} loading={state.pending} loadingLabel={copy.saving}>
            {copy.turnOff}
          </Button>
        ) : state.view.canEnable ? (
          <Button onClick={enable} type="button" disabled={state.pending}
            loading={state.pending} loadingLabel={copy.saving}>
            {copy.turnOn}
          </Button>
        ) : <p>{copy.unavailable}</p>}
        {state.notice ? <FormStatus status={{tone: state.uncertain || state.notice === copy.rejected ? "is-error" : "is-success", message: state.notice}} /> : null}
      </> : null}
    </EventRuntimeModule>
  );
}
