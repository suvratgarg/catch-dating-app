import {useMemo} from "react";
import type {GetEventAssistanceSmsWithdrawalCallablePayload as Credential} from "../../shared/contracts/generated/getEventAssistanceSmsWithdrawalCallablePayload";
import {Button, EventRuntimeModule, FormStatus} from "../../shared/ui/primitives";
import {eventMessagingCopy, eventWhatsappMessagingCopy} from "../../content/eventMessaging";
import {useEventMessageWithdrawalController, type MessageWithdrawalState, type MessageWithdrawalChannel} from "./useEventMessageWithdrawalController";

export function EventMessageWithdrawalPanel({credential, channel = "sms"}: {credential: Credential | null; channel?: MessageWithdrawalChannel}) {
  // An opaque React key discards the prior scope without exposing its secret.
  const scope = useMemo(() => crypto.randomUUID(), [credential?.linkId, credential?.secret, channel]);
  return <ScopedMessageWithdrawalPanel key={scope} credential={credential} channel={channel} />;
}
function ScopedMessageWithdrawalPanel({credential, channel}: {credential: Credential | null; channel: MessageWithdrawalChannel}) {
  return <EventMessageWithdrawalCard channel={channel} {...useEventMessageWithdrawalController(credential, channel)} />;
}
export function EventMessageWithdrawalCard({state, withdraw, refresh, channel = "sms"}: {
  channel?: MessageWithdrawalChannel;
  state: MessageWithdrawalState; withdraw: () => void; refresh: () => void;
}) {
  const copy = channel === "sms" ? eventMessagingCopy : eventWhatsappMessagingCopy;
  if (state.kind === "hidden") return null;
  return <EventRuntimeModule title={copy.title}>
    {state.kind === "loading" ? <p role="status">{copy.loading}</p> : null}
    {state.kind === "error" ? <>
      <FormStatus status={{tone: "is-error", message: copy.loadFailed}} />
      <Button type="button" variant="ghost" onClick={refresh}>{copy.refresh}</Button>
    </> : null}
    {state.kind === "ready" ? <>
      {state.uncertain || state.view.preference === "enabled" ? <p>{copy.withdrawalScope}</p> : null}
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
