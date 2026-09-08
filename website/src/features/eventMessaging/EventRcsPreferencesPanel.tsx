import {Button, EventRuntimeModule, FormStatus} from "../../shared/ui/primitives";
import {eventRcsMessagingCopy as copy} from "../../content/eventMessaging";
import {useEventRcsPreferencesController} from "./useEventRcsPreferencesController";

type Scope = {eventId: string; attendeeId: string};
export function EventRcsPreferencesPanel(scope: Scope) {
  return <ScopedPanel key={JSON.stringify(scope)} {...scope} />;
}
function ScopedPanel({eventId, attendeeId}: Scope) {
  return <EventRcsPreferencesCard {...useEventRcsPreferencesController(eventId, attendeeId)} />;
}

export function EventRcsPreferencesCard({state, navigation, enable, disable, retry,
  refresh, next, previous, current, manageEarlier}: ReturnType<typeof useEventRcsPreferencesController>) {
  if (state.kind === "hidden" && !navigation.showNext) return null;
  return <EventRuntimeModule title={navigation.earlier ? copy.earlierTitle : copy.title}>
    {state.kind === "loading" ? <FormStatus status={{tone: "", message: copy.loading}} /> : null}
    {state.kind === "error" ? <>
      <FormStatus status={{tone: "is-error", message: copy.loadFailed}} />
      <Button type="button" variant="ghost" onClick={refresh} disabled={navigation.busy}>{copy.refresh}</Button>
    </> : null}
    {state.kind === "ready" ? <>
      <p><strong>{state.view.sender?.displayName ?? copy.senderUnavailable}</strong><br />{state.view.eventTitle}</p>
      {state.earlier ? <p>{copy.earlierExplanation}</p> : <p>{copy.explanation}</p>}
      {state.view.phoneLastFour ? <p>{copy.phonePrefix} {state.view.phoneLastFour}.</p> : null}
      {!state.earlier ? <p>{state.view.consent.text}</p> : null}
      {state.view.preference !== "notSet" ? <FormStatus status={{tone: "", message:
        state.view.preference === "enabled" ? copy.enabled :
          state.view.preference === "disabled" ? copy.disabled : copy.expired}} /> : null}
      {state.uncertain ? <Button type="button" onClick={retry}>{copy.retry}</Button> :
        state.view.preference === "enabled" ?
          <Button type="button" variant="ghost" onClick={disable} disabled={state.pending}
            loading={state.pending} loadingLabel={copy.saving}>{copy.turnOff}</Button> :
          !state.earlier && state.view.canEnable ?
            <Button type="button" onClick={enable} disabled={state.pending}
              loading={state.pending} loadingLabel={copy.saving}>{copy.turnOn}</Button> :
            !state.earlier ? <p>{copy.availability[state.view.availability]}</p> : null}
      {state.notice ? <FormStatus status={{tone: state.uncertain || state.notice === copy.rejected ||
        state.notice === copy.changed ? "is-error" : "is-success", message: state.notice}} /> : null}
    </> : null}
    {navigation.showEarlier ? <Button type="button" variant="ghost" onClick={manageEarlier}
      disabled={navigation.busy}>{copy.manageEarlier}</Button> : null}
    {navigation.showPrevious ? <Button type="button" variant="ghost" onClick={previous}
      disabled={navigation.busy}>{copy.previousSender}</Button> : null}
    {navigation.showNext ? <Button type="button" variant="ghost" onClick={() => void next()}
      disabled={navigation.busy}>{copy.nextSender}</Button> : null}
    {navigation.showCurrent ? <Button type="button" variant="ghost" onClick={current}
      disabled={navigation.busy}>{copy.backToCurrent}</Button> : null}
  </EventRuntimeModule>;
}
