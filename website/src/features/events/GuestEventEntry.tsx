import {CatchField} from "@catch/web-ui";
import {useEffect, useState, type ReactNode} from "react";
import {EventGuestActions, EventGuestDialog} from "../../shared/ui/primitives/eventDetail";
import {guestEventAction} from "./guestEventAction";
import {
  Button,
  ButtonLink,
  FormStatus,
  EventRegistrationForm,
  EventRegistrationPrivacy,
  ActionGroup,
  CheckboxField,
} from "../../shared/ui/primitives";
import {guestEventCopy as copy, approvalNotificationCopy as notificationCopy} from "../../content/events";
import {useGuestEventController} from "./useGuestEventController";
import {PublicEventRegistration} from "./PublicEventRegistration";
import type {GetEventViewerStateCallableResponse} from "../../shared/contracts/generated/getEventViewerStateCallableResponse";

import {useApprovalNotificationsController} from "./useApprovalNotificationsController";
import type {User} from "../../firebase";

type Guest = NonNullable<GetEventViewerStateCallableResponse["viewer"]["guest"]>;
export function GuestEventEntry({eventId, invitation}: {
  eventId: string; invitation?: {price: string; title: string};
}) {
  const controller = useGuestEventController(eventId);
  const notifications = controller.user?.phoneNumber && controller.viewer?.guest?.applicationStatus ?
    <ApprovalNotifications key={`${eventId}:${controller.user.uid}`} eventId={eventId} user={controller.user} /> : null;
  return invitation ? <GuestInvitation eventId={eventId} controller={controller}
    invitation={invitation} notifications={notifications} /> : <>
    <GuestEventEntryView eventId={eventId} controller={controller} />{notifications}
  </>;
}
function GuestInvitation({eventId, controller: c, invitation, notifications}: {
  eventId: string; controller: ReturnType<typeof useGuestEventController>;
  invitation: {price: string; title: string}; notifications: ReactNode;
}) {
  const [open, setOpen] = useState(false);
  const [visited, setVisited] = useState(false);
  // A refresh may discover a held payment while checkout is open. Keep its
  // transaction controller mounted until the guest leaves or changes identity.
  const [flow, setFlow] = useState<{uid: string; mode: "free" | "paid"} | null>(null);
  useEffect(() => {
    if (flow && flow.uid !== c.user?.uid) setFlow(null);
  }, [flow, c.user?.uid]);
  const guest = c.viewer?.guest;
  const action = !c.user?.phoneNumber ? {label: copy.signIn, status: copy.ready, href: undefined} :
    guest && !c.error ? guestEventAction(guest, eventId) : {label: copy.refresh, status: copy.unavailable, href: undefined};
  function beginRegistration() {
    if (c.user && (guest?.action === "registerFree" || guest?.action === "bookPaid")) {
      setFlow({uid: c.user.uid, mode: guest.action === "bookPaid" ? "paid" : "free"});
    }
  }
  function show() {
    setVisited(true); setOpen(true); beginRegistration();
  }
  return <>
    <EventGuestActions price={invitation.price} status={c.loading ? copy.loading : action.status}>
      {action.href && !c.loading ? <ButtonLink href={action.href}>{action.label}</ButtonLink> :
        <Button disabled={c.loading} onClick={show}>{c.loading ? copy.loading : action.label}</Button>}
    </EventGuestActions>
    {c.user?.phoneNumber && (notifications || action.href || action.label !== copy.details) ? <Button variant="ghost" onClick={() => {setVisited(true); setOpen(true);}}>
      {notifications ? copy.updates : copy.details}</Button> : null}
    <EventGuestDialog open={open} title={invitation.title} closeLabel={copy.close}
      onClose={() => {setOpen(false); setFlow(null); if (!c.pending) c.changePhone(); if (c.user?.phoneNumber) void c.refresh();}}>
      {visited ? <>
        {flow && flow.uid === c.user?.uid ? <PublicEventRegistration key={`${eventId}:${flow.uid}`}
          eventId={eventId} mode={flow.mode} /> : <GuestEventEntryView eventId={eventId}
          controller={c} onBeginRegistration={beginRegistration} />}
        {notifications}
      </> : null}
    </EventGuestDialog>
  </>;
}
export function GuestEventEntryView({eventId, controller: c, onBeginRegistration, invitation}: {
  eventId: string; controller: ReturnType<typeof useGuestEventController>; onBeginRegistration?: () => void;
  invitation?: {price: string; title: string};
}) {
  if (invitation) return <GuestInvitation eventId={eventId} controller={c} invitation={invitation} notifications={null} />;
  if (c.loading) return <p role="status">{copy.loading}</p>;
  if (!c.user?.phoneNumber) return <EventRegistrationForm onSubmit={c.submit}>
    <CatchField
      recipe="input"
      id={`${c.recaptchaId}-phone`}
      title={copy.phone}
      autoComplete="tel"
      value={c.phone}
      inputMode={c.pending || c.codeSent ? "inactive" : "editable"}
      onChanged={(value) => c.setPhone(value)}
      keyboardType="phone"
    />
    {c.codeSent ? <CatchField
      recipe="input"
      id={`${c.recaptchaId}-code`}
      title={copy.code}
      autoComplete="one-time-code"
      maxLength={6}
      value={c.code}
      onChanged={(value) => c.setCode(value.replace(/\D/gu, ""))}
      keyboardType="number"
    /> : null}
    <div id={c.recaptchaId} />
    <Button type="submit" loading={c.pending}>{c.codeSent ? copy.verify : copy.continue}</Button>
    {c.codeSent ? <Button type="button" variant="ghost" disabled={c.pending}
      onClick={c.changePhone}>{copy.changePhone}</Button> : null}
    <FormStatus status={{message: c.message, tone: "is-error"}} />
    <EventRegistrationPrivacy>{copy.privacy}</EventRegistrationPrivacy>
  </EventRegistrationForm>;
  const guest = c.viewer?.guest;
  if (!guest || c.error) return <>
    <p role="status">{copy.unavailable}</p>
    <Button onClick={() => void c.refresh()}>{copy.refresh}</Button>
    <Button variant="ghost" onClick={() => void c.changeAccount()}>{copy.changeAccount}</Button>
  </>;
  return <>
    <GuestStatus guest={guest} eventId={eventId} onBeginRegistration={onBeginRegistration} />
    <Button variant="ghost" onClick={() => void c.refresh()}>{copy.refresh}</Button>
    <Button variant="ghost" onClick={() => void c.changeAccount()}>{copy.changeAccount}</Button>
  </>;
}
function GuestStatus({guest, eventId, onBeginRegistration}: {guest: Guest; eventId: string; onBeginRegistration?: () => void}) {
  if (guest.action === "registerFree" || guest.action === "bookPaid") {
    if (onBeginRegistration) return <Button onClick={onBeginRegistration}>{guestEventAction(guest, eventId).label}</Button>;
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

function ApprovalNotifications({eventId, user}: {eventId: string; user: User}) {
  const c = useApprovalNotificationsController(eventId, user);
  const copy = notificationCopy;
  if (c.loading) return <p role="status">{copy.loading}</p>;
  return <EventRegistrationForm onSubmit={c.save}>
    <h3>{copy.title}</h3>
    <p>{copy.explanation}</p>
    {c.value && c.choices ? <>
      {!c.value.available ? <p>{copy.unavailable}</p> : null}
      <CheckboxField checked={c.choices.phoneUpdates}
        disabled={c.pending || !c.value.phoneVerified && !c.choices.phoneUpdates}
        onChange={(event) => c.choose("phoneUpdates", event.target.checked)}>{c.value.terms.phone}</CheckboxField>
      <CheckboxField checked={c.choices.emailUpdates}
        disabled={c.pending || !c.value.emailVerified && !c.choices.emailUpdates}
        onChange={(event) => c.choose("emailUpdates", event.target.checked)}>{c.value.terms.email}</CheckboxField>
      {!c.value.emailVerified ? <>
        <p>{copy.verifyFirst}</p>
        <CatchField recipe="input" id={`${c.id}-email`} title={copy.email} keyboardType="emailAddress"
          autoComplete="email" value={c.email}
          inputMode={c.pending ? "inactive" : user.email ? "readOnly" : "editable"}
          onChanged={(value) => c.setEmail(value)} />
        <Button type="button" disabled={c.pending || !c.email.trim()}
          onClick={() => void c.verify()}>{copy.verify}</Button>
      </> : null}
      <Button type="submit" formNoValidate loading={c.pending}>{copy.save}</Button>
    </> : null}
    <Button type="button" variant="ghost" disabled={c.pending}
      onClick={() => void c.refresh()}>{copy.refresh}</Button>
    <FormStatus status={{message: c.message || (c.error ? copy.error : ""), tone: ""}} />
  </EventRegistrationForm>;
}
