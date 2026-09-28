import {eventOfferCopy as text, offerCodeSent, offerHoldEnds, offerRefundDeadline, offerCancellationRefund} from "../../content/eventOffer";
import type {OfferCredential} from "./offerCredential";
import {useOfferCheckoutController} from "./useOfferCheckoutController";
import {formatOfferAmount, paymentCopy} from "./offerCheckoutModel";
import {Button, ButtonLink, TextField, FormStatus, EventRuntimeFrame,
  EventRuntimePanel, EventRuntimeLoading, EventRuntimeForm,
  EventRuntimeModule, EventRuntimeSectionStack, EventRuntimeActionGrid} from
  "../../shared/ui/primitives";

export function EventOfferPage({credential}: {credential: OfferCredential | null}) {
  const controller = useOfferCheckoutController(credential);
  return <EventOfferView {...controller} />;
}
export function EventOfferView(controller: ReturnType<typeof useOfferCheckoutController>) {
  const {phase, pending, grant, payment, cancellationReview} = controller;
  const policy = payment?.cancellationPolicy ?? grant?.cancellationPolicy;
  const copy = cancellationReview ? {title: text.cancelTitle,
    body: cancellationReview.refundAmountPaise > 0 ?
      offerCancellationRefund(formatOfferAmount(cancellationReview.refundAmountPaise)) : text.noRefund} : payment ? paymentCopy(payment) : {
    title: grant?.eventName ?? text.invitationTitle,
    body: text.invitationBody,
  };
  return <EventRuntimeFrame brandLabel={text.brandLabel} brandWord={text.brandWord}
    eventTitle={grant?.eventName}>
    {phase === "loading" ? <EventRuntimeLoading label={text.loading} /> :
      phase === "phone" ? <EventRuntimePanel kicker={text.phoneKicker}
        title={text.phoneTitle} body={text.phoneBody}>
        <EventRuntimeForm onSubmit={controller.sendCode} pending={pending}>
          <TextField id="offer-phone" label={text.phoneLabel} type="tel" inputMode="tel"
            autoComplete="tel" placeholder={text.phonePlaceholder} value={controller.phone}
            onChange={(event) => controller.setPhone(event.target.value.replace(/\s/gu, ""))} />
          <div id={controller.recaptchaId} />
          <Button type="submit" loading={pending} loadingLabel={text.sending}>{text.send}</Button>
          <FormStatus status={controller.status} />
        </EventRuntimeForm>
      </EventRuntimePanel> : phase === "otp" ? <EventRuntimePanel kicker={text.otpKicker}
        title={text.otpTitle} body={offerCodeSent(controller.phone)}>
        <EventRuntimeForm onSubmit={controller.verifyCode} pending={pending}>
          <TextField id="offer-code" label={text.codeLabel} inputMode="numeric"
            autoComplete="one-time-code" maxLength={6} value={controller.code}
            onChange={(event) => controller.setCode(event.target.value.replace(/\D/gu, ""))} />
          <Button type="submit" loading={pending} loadingLabel={text.verifying} disabled={controller.code.length !== 6}>{text.verify}</Button>
          <Button type="button" variant="ghost" disabled={pending} onClick={controller.changePhone}>{text.changeNumber}</Button>
          <FormStatus status={controller.status} />
        </EventRuntimeForm>
      </EventRuntimePanel> : phase === "unavailable" ? <EventRuntimePanel kicker={text.privateKicker}
        title={text.unavailableTitle} body={text.unavailableBody}>
        <EventRuntimeSectionStack>
          <FormStatus status={controller.status} />
          <EventRuntimeActionGrid>
            {controller.hasInvitation ? <Button type="button" onClick={() => void controller.load()} loading={pending} loadingLabel={text.checking}>{text.retry}</Button> : null}
            {controller.hasInvitation ? <Button type="button" variant="ghost" disabled={pending} onClick={controller.changePhone}>{text.verifyAnother}</Button> : null}
            <ButtonLink href="/help" variant="ghost">{text.help}</ButtonLink>
          </EventRuntimeActionGrid>
        </EventRuntimeSectionStack>
      </EventRuntimePanel> : <EventRuntimePanel kicker={cancellationReview ? text.cancellation : payment?.status === "admitted" ? text.confirmed : text.admission}
        title={copy.title} body={copy.body}>
        <EventRuntimeSectionStack>
          <EventRuntimeModule title={payment?.status === "refunded" ? text.refund : text.bookingAmount}>
            <p>{formatOfferAmount(payment?.amountPaise ?? grant!.amountPaise)}</p>
            {grant ? <p>{new Intl.DateTimeFormat("en-IN", {dateStyle: "full", timeStyle: "short"}).format(grant.startTimeMillis)}</p> : null}
            {payment?.mode === "test" ? <p role="status">{text.testMode}</p> : null}
            {payment?.checkout ? <p>{offerHoldEnds(new Intl.DateTimeFormat("en-IN", {timeStyle: "short"}).format(payment.expiresAtMillis))}</p> : null}
          </EventRuntimeModule>
          {policy && !cancellationReview ? <EventRuntimeModule title={text.cancellationTerms}>
            <p>{offerRefundDeadline(new Intl.DateTimeFormat("en-IN", {dateStyle: "medium", timeStyle: "short"}).format(policy.refundDeadlineMillis))}</p>
          </EventRuntimeModule> : null}
          {cancellationReview ? <EventRuntimeActionGrid>
              <Button type="button" onClick={() => void controller.cancelAdmission()} loading={pending} loadingLabel={text.cancelling}>{text.confirmCancellation}</Button>
              <Button type="button" variant="ghost" onClick={controller.dismissCancellation} disabled={pending} autoFocus>{text.keepAdmission}</Button>
          </EventRuntimeActionGrid> : null}
          <FormStatus status={controller.status} />
          <EventRuntimeActionGrid>
            {payment?.cancellationQuote && !cancellationReview ? <Button type="button" variant="ghost"
              onClick={() => void controller.reviewCancellation()} disabled={pending}>{text.cancelAdmission}</Button> : null}
            {!payment || payment.checkout ? <Button type="button" onClick={() => void controller.pay()}
              loading={pending} loadingLabel={text.checkingPayment}>{payment ? text.continueCheckout : text.reservePay}</Button> : null}
            {payment && !cancellationReview && !["refunded", "cancelled"].includes(payment.status) ? <Button type="button"
              variant="ghost" onClick={() => void controller.check()} disabled={pending}>{text.refresh}</Button> : null}
            {payment?.status === "admitted" || payment?.status === "refunded" || payment?.status === "cancelled" || payment?.status === "reviewRequired" ?
              <ButtonLink href="/help" variant="ghost">{text.help}</ButtonLink> : null}
          </EventRuntimeActionGrid>
        </EventRuntimeSectionStack>
      </EventRuntimePanel>}
  </EventRuntimeFrame>;
}
