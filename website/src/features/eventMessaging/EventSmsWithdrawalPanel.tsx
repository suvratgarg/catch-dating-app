import {useMemo} from "react";
import type {GetEventAssistanceSmsWithdrawalCallablePayload as Credential} from "../../shared/contracts/generated/getEventAssistanceSmsWithdrawalCallablePayload";
import {Button, EventRuntimeModule, FormStatus} from "../../shared/ui/primitives";
import {eventMessagingCopy as copy} from "../../content/eventMessaging";
import {useEventSmsWithdrawalController, type SmsWithdrawalState} from "./useEventSmsWithdrawalController";

export function EventSmsWithdrawalPanel({credential}: {credential: Credential | null}) {
  // An opaque React key discards the prior scope without exposing its secret.
  const scope = useMemo(() => crypto.randomUUID(), [credential?.linkId, credential?.secret]);
  return <ScopedSmsWithdrawalPanel key={scope} credential={credential} />;
}
function ScopedSmsWithdrawalPanel({credential}: {credential: Credential | null}) {
  return <EventSmsWithdrawalCard {...useEventSmsWithdrawalController(credential)} />;
}
export function EventSmsWithdrawalCard({state, withdraw, refresh}: {
  state: SmsWithdrawalState; withdraw: () => void; refresh: () => void;
}) {
  if (state.kind === "hidden") return null;
  return <EventRuntimeModule title={copy.title}>
    {state.kind === "loading" ? <p role="status">{copy.loading}</p> : null}
    {state.kind === "error" ? <>
      <FormStatus status={{tone: "is-error", message: copy.loadFailed}} />
      <Button type="button" variant="ghost" onClick={refresh}>{copy.refresh}</Button>
    </> : null}
    {state.kind === "ready" ? <>
      <p>{copy.withdrawalScope}</p>
      {state.uncertain || state.view.preference === "enabled" ?
        <Button type="button" variant="ghost" onClick={withdraw} disabled={state.pending}
          loading={state.pending} loadingLabel={copy.saving}>
          {state.uncertain ? copy.retry : copy.turnOff}
        </Button> : <p role="status">{state.view.preference === "expired" ? copy.expired : copy.withdrawalSaved}</p>}
      {state.notice ? <FormStatus status={{tone: state.uncertain || state.notice === copy.rejected ?
        "is-error" : "", message: state.notice}} /> : null}
    </> : null}
  </EventRuntimeModule>;
}
