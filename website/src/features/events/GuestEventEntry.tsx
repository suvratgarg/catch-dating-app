import {Button, ButtonLink, TextField, FormStatus, EventRegistrationForm,
  EventRegistrationPrivacy, ActionGroup} from "../../shared/ui/primitives";
import {guestEventCopy as copy} from "../../content/events";
import {useGuestEventController} from "./useGuestEventController";
import {PublicEventRegistration} from "./PublicEventRegistration";
import type {GetEventViewerStateCallableResponse} from "../../shared/contracts/generated/getEventViewerStateCallableResponse";

type Guest = NonNullable<GetEventViewerStateCallableResponse["viewer"]["guest"]>;
export function GuestEventEntry({eventId}: {eventId: string}) {
  const controller = useGuestEventController(eventId);
  return <GuestEventEntryView eventId={eventId} controller={controller} />;
}
export function GuestEventEntryView({eventId, controller: c}: {
  eventId: string; controller: ReturnType<typeof useGuestEventController>;
}) {
  if (c.loading) return <p role="status">{copy.loading}</p>;
  if (!c.user?.phoneNumber) return <EventRegistrationForm onSubmit={c.submit}>
    <TextField id={`${c.recaptchaId}-phone`} label={copy.phone} autoComplete="tel"
      type="tel" value={c.phone} disabled={c.pending || c.codeSent}
      onChange={(event) => c.setPhone(event.target.value)} />
    {c.codeSent ? <TextField id={`${c.recaptchaId}-code`} label={copy.code}
      autoComplete="one-time-code" inputMode="numeric" maxLength={6}
      value={c.code} onChange={(event) => c.setCode(event.target.value.replace(/\D/gu, ""))} /> : null}
    <div id={c.recaptchaId} />
    <Button type="submit" loading={c.pending}>{c.codeSent ? copy.verify : copy.continue}</Button>
    <FormStatus status={{message: c.message, tone: "is-error"}} />
    <EventRegistrationPrivacy>{copy.privacy}</EventRegistrationPrivacy>
  </EventRegistrationForm>;
  const guest = c.viewer?.guest;
  if (!guest || c.error) return <>
    <p role="status">{copy.unavailable}</p>
    <Button onClick={() => void c.refresh()}>{copy.refresh}</Button>
  </>;
  return <>
    <GuestStatus guest={guest} eventId={eventId} />
    <Button variant="ghost" onClick={() => void c.refresh()}>{copy.refresh}</Button>
    <Button variant="ghost" onClick={() => void c.changeAccount()}>{copy.changeAccount}</Button>
  </>;
}
function GuestStatus({guest, eventId}: {guest: Guest; eventId: string}) {
  if (guest.action === "registerFree" || guest.action === "bookPaid") {
    return <PublicEventRegistration eventId={eventId}
      mode={guest.action === "bookPaid" ? "paid" : "free"} />;
  }
  return <>
    <p role="status">{copy.status[guest.action]}</p>
    <ActionGroup variant="flow">
      {guest.action === "apply" && guest.publicFormId ?
        <ButtonLink href={`/f/${encodeURIComponent(guest.publicFormId)}/`}>{copy.apply}</ButtonLink> : null}
      {guest.action === "offer" && guest.offerGrantId ?
        <ButtonLink href={`/offer/?grant=${encodeURIComponent(guest.offerGrantId)}`}>{copy.offer}</ButtonLink> : null}
      {guest.offerPaymentId ? <ButtonLink href={`/offer/?payment=${encodeURIComponent(guest.offerPaymentId)}`}>
        {copy.payment}</ButtonLink> : null}
      {guest.publicPaymentId ? <ButtonLink href={`/booking/${encodeURIComponent(eventId)}/?payment=${encodeURIComponent(guest.publicPaymentId)}`}>
        {copy.payment}</ButtonLink> : null}
      {guest.action === "registered" && guest.runtimeId ?
        <ButtonLink href={`/join/${encodeURIComponent(guest.runtimeId)}`}>{copy.runtime}</ButtonLink> : null}
      {["unsupported", "unavailable", "awaitingOffer", "declined"].includes(guest.action) ?
        <ButtonLink href="/help/" variant="ghost">{copy.help}</ButtonLink> : null}
    </ActionGroup>
  </>;
}
