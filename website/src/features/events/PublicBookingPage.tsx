import { useParams, useSearchParams } from "react-router";
import { publicCheckoutCopy as copy } from "../../content/events";
import {
  EventRuntimeFrame,
  EventRuntimePanel,
} from "../../shared/ui/primitives";
import { PublicPaidEventRegistration } from "./PublicPaidEventRegistration";

/** A listing can close or disappear while its guest still needs their receipt. */
export function PublicBookingPage() {
  const { eventId = "" } = useParams<{ eventId: string }>();
  const [search] = useSearchParams();
  const paymentId = search.get("payment");
  const validPayment =
    paymentId === null || /^pp_[a-f0-9]{32}$/u.test(paymentId);
  return (
    <EventRuntimeFrame
      brandLabel={copy.bookingTitle}
      brandWord={copy.bookingBrand}
    >
      <EventRuntimePanel
        kicker={copy.bookingBrand}
        title={copy.bookingTitle}
        body={copy.bookingBody}
      >
        {validPayment && /^[A-Za-z0-9_:-]{1,180}$/u.test(eventId) ? (
          <PublicPaidEventRegistration
            key={`${eventId}:${paymentId ?? "latest"}`}
            initialPaymentId={paymentId}
            eventId={eventId}
            inviteToken={null}
            allowNewBookings={false}
          />
        ) : (
          <p>{copy.unavailable}</p>
        )}
      </EventRuntimePanel>
    </EventRuntimeFrame>
  );
}
