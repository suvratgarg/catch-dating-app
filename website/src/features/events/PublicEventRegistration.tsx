import {useFreeEventRegistrationController} from "./useFreeEventRegistrationController";
import {PublicPaidEventRegistration} from "./PublicPaidEventRegistration";
import {EventWhatsappPreferencesPanel} from "../eventMessaging/EventWhatsappPreferencesPanel";
import {EventRcsPreferencesPanel} from "../eventMessaging/EventRcsPreferencesPanel";
import {EventSmsPreferencePanel} from "../eventMessaging/EventSmsPreferencePanel";
import {eventDetailCopy} from "../../content/events";

import {
  Button,
  ButtonLink,
  EventRegistrationConsent,
  EventRegistrationConsents,
  EventRegistrationForm,
  EventRegistrationPrivacy,
  FormStatus,
  TextField,
} from "../../shared/ui/primitives";
import {eventInviteTokenFromLocation} from "../../shared/eventInviteAttribution";

export function PublicEventRegistration({eventId, inviteToken, mode = "free", allowNewBookings = true}: {eventId: string; inviteToken?: string | null; mode?: "free" | "paid"; allowNewBookings?: boolean}) {
  return mode === "paid" ? <PublicPaidEventRegistration key={eventId} eventId={eventId} allowNewBookings={allowNewBookings} inviteToken={inviteToken ?? eventInviteTokenFromLocation()} /> :
    <FreeEventRegistration key={eventId} eventId={eventId} inviteToken={inviteToken} />;
}

function FreeEventRegistration({
  eventId,
  inviteToken: inviteTokenOverride,
}: {
  eventId: string;
  inviteToken?: string | null;
}) {
  const {reactId, recaptchaContainerId, displayName, setDisplayName,
    phoneNumber, setPhoneNumber, code, setCode, whatsappUpdates, setWhatsappUpdates,
    smsUpdates, setSmsUpdates, stage, registeredScope, pending, status,
    verified, handleSubmit} = useFreeEventRegistrationController(eventId, inviteTokenOverride);
  const copy = eventDetailCopy.hero.webRegistration;

  return (
    <EventRegistrationForm onSubmit={handleSubmit}>
      <TextField
        autoComplete="name"
        disabled={pending || stage !== "details"}
        id={`${reactId}-event-registration-name`}
        label={copy.nameLabel}
        maxLength={120}
        onChange={(event) => setDisplayName(event.target.value)}
        placeholder={copy.namePlaceholder}
        value={displayName}
      />
      <TextField
        autoComplete="tel"
        disabled={verified || pending || stage !== "details"}
        id={`${reactId}-event-registration-phone`}
        inputMode="tel"
        label={copy.phoneLabel}
        onChange={(event) => setPhoneNumber(event.target.value)}
        placeholder={copy.phonePlaceholder}
        value={phoneNumber}
      />
      <EventRegistrationConsents>
        <EventRegistrationConsent
          checked={whatsappUpdates}
          disabled={pending || stage !== "details"}
          onChange={(event) => setWhatsappUpdates(event.target.checked)}
        >
          {copy.whatsappConsent}
        </EventRegistrationConsent>
        <EventRegistrationConsent
          checked={smsUpdates}
          disabled={pending || stage !== "details"}
          onChange={(event) => setSmsUpdates(event.target.checked)}
        >
          {copy.smsConsent}
        </EventRegistrationConsent>
        <EventRegistrationPrivacy>{copy.consentDetail}</EventRegistrationPrivacy>
      </EventRegistrationConsents>
      {stage === "code" ? (
        <TextField
          autoComplete="one-time-code"
          disabled={pending}
          id={`${reactId}-event-registration-code`}
          inputMode="numeric"
          label={copy.codeLabel}
          maxLength={6}
          onChange={(event) => setCode(event.target.value.replace(/\D/gu, ""))}
          placeholder={copy.codePlaceholder}
          value={code}
        />
      ) : null}
      <div id={recaptchaContainerId} />
      {stage !== "success" ? (
        <Button
          disabled={pending}
          loading={pending}
          loadingLabel={stage === "details" ?
            copy.sendingCodeAction : copy.registeringAction}
          type="submit"
        >
          {stage === "details" ? verified ? copy.registerAction : copy.sendCodeAction : copy.confirmAction}
        </Button>
      ) : null}
      <FormStatus status={status} />
      {stage === "success" && registeredScope?.eventId === eventId ?
        <>
          <ButtonLink href={`/booking/${encodeURIComponent(eventId)}/`}>{eventDetailCopy.hero.guestAction}</ButtonLink>
          <EventSmsPreferencePanel {...registeredScope} />
          <EventRcsPreferencesPanel {...registeredScope} />
          <EventWhatsappPreferencesPanel {...registeredScope} />
        </> : null}
      <EventRegistrationPrivacy>{copy.privacy}</EventRegistrationPrivacy>
    </EventRegistrationForm>
  );
}
