import {CatchField, CatchGap} from "@catch/web-ui";
import { usePublicCheckoutController } from "./usePublicCheckoutController";
import {
  eventDetailCopy,
  publicCheckoutCopy as copy,
} from "../../content/events";
import {
  eventOfferCopy as text,
  offerCodeSent,
  offerHoldEnds,
  offerRefundDeadline,
  offerCancellationRefund,
  offerPaymentCopy,
} from "../../content/eventOffer";
import {
  Button,
  ButtonLink,
  FormStatus,
  EventRuntimeLoading,
  EventRuntimeForm,
  EventRuntimeModule,
} from "../../shared/ui/primitives";
import { EventSmsPreferencePanel } from "../eventMessaging/EventSmsPreferencePanel";
import { EventRcsPreferencesPanel } from "../eventMessaging/EventRcsPreferencesPanel";
import { EventWhatsappPreferencesPanel } from "../eventMessaging/EventWhatsappPreferencesPanel";
const money = (amount: number) =>
  new Intl.NumberFormat("en-IN", { style: "currency", currency: "INR" }).format(
    amount / 100,
  );
const date = (value: number) =>
  new Intl.DateTimeFormat(undefined, {
    dateStyle: "medium",
    timeStyle: "short",
  }).format(value);

export function PublicPaidEventRegistration({
  eventId,
  inviteToken,
  allowNewBookings = true,
  initialPaymentId = null,
  initialDisplayName = "",
}: {
  eventId: string;
  inviteToken: string | null;
  allowNewBookings?: boolean;
  initialPaymentId?: string | null;
  initialDisplayName?: string;
}) {
  return (
    <PublicPaidRegistrationView
      {...usePublicCheckoutController(
        eventId,
        inviteToken,
        allowNewBookings,
        initialPaymentId,
        initialDisplayName,
      )}
    />
  );
}
export function PublicPaidRegistrationView(
  c: ReturnType<typeof usePublicCheckoutController>,
) {
  const { phase, pending, quote, payment, admission, cancellationReview } = c;
  const policy = payment?.cancellationPolicy ?? quote?.cancellationPolicy;
  const display = cancellationReview
    ? {
        title: text.cancelTitle,
        body:
          cancellationReview.refundAmountPaise > 0
            ? offerCancellationRefund(
                money(cancellationReview.refundAmountPaise),
              )
            : text.noRefund,
      }
    : payment?.status === "admitted" && !admission
      ? { title: text.checkingPayment, body: copy.admissionUnavailable }
      : payment
        ? offerPaymentCopy(
            payment.status,
            payment.checkout !== null,
            payment.cancellationReason,
          )
        : admission
          ? { title: text.confirmed, body: copy.alreadyRegistered }
          : !c.allowNewBookings
            ? { title: copy.noBookingTitle, body: copy.noBooking }
            : { title: copy.reviewTitle, body: copy.reviewBody };
  return (
    <CatchGap size="section">
      {!c.allowNewBookings && (phase === "phone" || phase === "otp") ? (
        <p>{copy.closedRecovery}</p>
      ) : null}
      {phase === "phone" || phase === "otp" ? (
        <EventRuntimeForm
          pending={pending}
          onSubmit={phase === "phone" ? c.sendCode : c.verifyCode}
        >
          {phase === "phone" ? (
            <CatchField
              recipe="input"
              id={`${c.recaptchaId}-phone`}
              title={text.phoneLabel}
              autoComplete="tel"
              inputHint={text.phonePlaceholder}
              value={c.phone}
              onChanged={(value) => c.setPhone(value.replace(/\s/gu, ""))}
              keyboardType="phone"
            />
          ) : (
            <>
              <p>{offerCodeSent(c.phone)}</p>
              <CatchField
                recipe="input"
                id={`${c.recaptchaId}-code`}
                title={text.codeLabel}
                autoComplete="one-time-code"
                maxLength={6}
                value={c.code}
                onChanged={(value) => c.setCode(value.replace(/\D/gu, ""))}
                keyboardType="number"
              />
            </>
          )}
          <div id={c.recaptchaId} />
          <Button
            type="submit"
            loading={pending}
            loadingLabel={phase === "phone" ? text.sending : text.verifying}
            disabled={phase === "otp" && c.code.length !== 6}
          >
            {phase === "phone" ? text.send : text.verify}
          </Button>
          {phase === "otp" ? (
            <Button
              type="button"
              variant="ghost"
              disabled={pending}
              onClick={c.changePhone}
            >
              {text.changeNumber}
            </Button>
          ) : null}
        </EventRuntimeForm>
      ) : phase === "loading" || phase === "unavailable" ? (
        <>
          {pending || !c.status.message ? (
            <EventRuntimeLoading label={copy.loading} />
          ) : null}
          {c.status.message ? (
            <Button
              type="button"
              disabled={pending}
              onClick={() => void c.load()}
            >
              {text.retry}
            </Button>
          ) : null}
        </>
      ) : (
        <>
          <EventRuntimeModule title={display.title}>
            <p>{display.body}</p>
            {quote || payment ? (
              <>
                <p>
                  <strong>
                    {money(payment?.amountPaise ?? quote!.amountPaise)}
                  </strong>
                </p>
                <p>
                  {date(payment?.startTimeMillis ?? quote!.startTimeMillis)}
                </p>
                {payment?.mode === "test" ? (
                  <p role="status">{text.testMode}</p>
                ) : null}
                {payment?.checkout ? (
                  <p>{offerHoldEnds(date(payment.expiresAtMillis))}</p>
                ) : null}
              </>
            ) : null}
            {policy && !cancellationReview ? (
              <p>
                <strong>{text.cancellationTerms}</strong>
                <br />
                {offerRefundDeadline(date(policy.refundDeadlineMillis))}
              </p>
            ) : null}
          </EventRuntimeModule>
          {c.previousPayment ? (
            <>
              <p>
                {copy.previousCheckout(money(c.previousPayment.amountPaise))}
              </p>
              <ButtonLink
                href={`/booking/${encodeURIComponent(c.previousPayment.eventId)}/?payment=${c.previousPayment.paymentId}`}
                variant="ghost"
              >
                {copy.previousBookingLink}
              </ButtonLink>
            </>
          ) : null}
          {quote && !admission ? (
            <>
              <CatchField
                recipe="input"
                id={`${c.recaptchaId}-name`}
                title={eventDetailCopy.hero.webRegistration.nameLabel}
                autoComplete="name"
                maxLength={120}
                inputMode={pending || c.nameLocked ? "inactive" : "editable"}
                value={c.name}
                onChanged={(value) => c.setName(value)}
              />
              <p>{copy.signedIn(c.user?.phoneNumber ?? c.phone)}</p>
            </>
          ) : null}
          <CatchGap direction="horizontal" size="related" wrap
            key={cancellationReview ? "cancel" : "checkout"}
          >
            {cancellationReview ? (
              <>
                <Button
                  type="button"
                  loading={pending}
                  loadingLabel={text.cancelling}
                  onClick={() => void c.cancelAdmission()}
                >
                  {text.confirmCancellation}
                </Button>
                <Button
                  type="button"
                  variant="ghost"
                  disabled={pending}
                  autoFocus
                  onClick={c.dismissCancellation}
                >
                  {text.keepAdmission}
                </Button>
              </>
            ) : (
              <>
                {c.allowNewBookings &&
                payment &&
                ["expired", "refunded", "cancelled"].includes(
                  payment.status,
                ) ? (
                  <Button
                    type="button"
                    disabled={pending}
                    onClick={() => void c.startAgain()}
                  >
                    {copy.startAgain}
                  </Button>
                ) : null}
                {!payment && !admission ? (
                  <Button
                    type="button"
                    variant="ghost"
                    disabled={pending}
                    onClick={c.changePhone}
                  >
                    {text.verifyAnother}
                  </Button>
                ) : null}
                {quote && c.status.tone === "is-error" ? (
                  <Button
                    type="button"
                    variant="ghost"
                    disabled={pending}
                    onClick={() => void c.load(true)}
                  >
                    {copy.reviewCurrentTerms}
                  </Button>
                ) : null}
                {!admission && (quote || payment?.checkout) ? (
                  <Button
                    type="button"
                    loading={pending}
                    loadingLabel={text.checkingPayment}
                    onClick={() => void c.pay()}
                  >
                    {payment
                      ? text.continueCheckout
                      : copy.pay(money(quote!.amountPaise))}
                  </Button>
                ) : null}
                {payment ? (
                  <ButtonLink
                    href={`/booking/${encodeURIComponent(payment.eventId)}/?payment=${payment.paymentId}`}
                    variant="ghost"
                  >
                    {copy.bookingLink}
                  </ButtonLink>
                ) : null}
                {payment ? (
                  <Button
                    type="button"
                    variant="ghost"
                    disabled={pending}
                    onClick={() => void c.check()}
                  >
                    {text.refresh}
                  </Button>
                ) : null}
                {admission ? <ButtonLink href={`/booking/${encodeURIComponent(admission.eventId)}/`}>
                  {copy.eventAccess}
                </ButtonLink> : null}
                {admission && payment?.cancellationQuote ? (
                  <Button
                    type="button"
                    variant="ghost"
                    disabled={pending}
                    onClick={() => void c.reviewCancellation()}
                  >
                    {text.cancelAdmission}
                  </Button>
                ) : null}
              </>
            )}
          </CatchGap>
          {admission && !cancellationReview ? (
            <>
              <EventSmsPreferencePanel
                eventId={admission.eventId}
                attendeeId={admission.attendeeId}
              />
              <EventRcsPreferencesPanel
                eventId={admission.eventId}
                attendeeId={admission.attendeeId}
              />
              <EventWhatsappPreferencesPanel
                eventId={admission.eventId}
                attendeeId={admission.attendeeId}
              />
            </>
          ) : null}
        </>
      )}
      <FormStatus status={c.status} />
    </CatchGap>
  );
}
