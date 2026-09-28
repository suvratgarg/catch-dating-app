import {useState} from "react";
import type {Meta, StoryObj} from "@storybook/react-vite";
import {PublicPaidRegistrationView} from "../features/events/PublicPaidEventRegistration";
import type {usePublicCheckoutController} from "../features/events/usePublicCheckoutController";
import {EventRuntimePanel, EventRuntimeFrame} from "../shared/ui/primitives";
const meta = {title: "Marketing Website/Public paid registration"} satisfies Meta;
export default meta;
type Story = StoryObj<typeof meta>;
const empty = () => undefined;
const fixture: ReturnType<typeof usePublicCheckoutController> = {
  allowNewBookings: true, phase: "ready", phone: "+91 98765 43210", setPhone: empty, code: "", setCode: empty,
  nameLocked: false, name: "Maya Rao", setName: empty, user: null,
  quote: {eventId: "demo", eventName: "Sunday morning at Lodhi", registrationRevision: 1,
    cancellationPolicy: {refundDeadlineMillis: 1790989200000, eventStartsAtMillis: 1791075600000},
    startTimeMillis: 1791075600000, amountPaise: 85000, currency: "INR"},
  payment: null, previousPayment: null, admission: null, pending: false, status: {message: "", tone: ""}, recaptchaId: "preview-public-otp",
  sendCode: async () => undefined, verifyCode: async () => undefined, changePhone: empty,
  cancellationReview: null, reviewCancellation: async () => undefined,
  cancelAdmission: async () => undefined, dismissCancellation: empty,
  startAgain: async () => undefined, pay: async () => undefined, check: async () => undefined, load: async () => undefined,
};
const payment = {paymentId: `pp_${"a".repeat(32)}`, status: "verifying" as const,
  eventId: "demo", eventName: "Sunday morning at Lodhi", startTimeMillis: 1791075600000,
  amountPaise: 85000, currency: "INR" as const, mode: "test" as const,
  refundedAmountPaise: 0, cancellationReason: null, cancellationPolicy: fixture.quote!.cancellationPolicy,
  cancellationQuote: null, expiresAtMillis: 1790989200000, checkout: null};
function Preview(props: Partial<typeof fixture>) {
  return <EventRuntimeFrame brandLabel="Event registration" brandWord="Catch" eventTitle="Sunday morning at Lodhi">
    <EventRuntimePanel kicker="Open registration" title="Your event registration" body="Book or manage your place with your verified phone number.">
      <PublicPaidRegistrationView {...fixture} {...props} />
    </EventRuntimePanel>
  </EventRuntimeFrame>;
}
export const PublicCheckout: Story = {parameters: {catchComponent: {id: "public_paid_registration",
  routeIds: ["event_detail_canonical"], states: ["phone", "otp", "review", "pending", "cancel-review", "refunded"]}}, render: () => <Preview />};
export const Review: Story = {parameters: {catchComponent: {id: "public_paid_registration_view",
  routeIds: ["event_detail_canonical"], states: ["phone", "otp", "review", "pending", "cancel-review", "refunded"]}}, render: function ReviewPreview() {
  const [name, setName] = useState("Maya Rao");
  return <Preview name={name} setName={setName} />;
}};
export const Phone: Story = {render: () => <Preview phase="phone" />};
export const Otp: Story = {render: () => <Preview phase="otp" />};
export const Pending: Story = {render: () => <Preview quote={null} payment={payment} />};
export const Cancellation: Story = {render: () => <Preview quote={null}
  payment={{...payment, status: "admitted", cancellationQuote: {refundAmountPaise: 0}}}
  cancellationReview={{paymentId: payment.paymentId, refundAmountPaise: 0}} />};
export const Refunded: Story = {render: () => <Preview quote={null}
  payment={{...payment, status: "refunded", refundedAmountPaise: 85000, cancellationReason: "guestCancelled"}} />};

export const BookingManagement: Story = {parameters: {
  catchRoute: {id: "event_booking", path: "/booking/event1/", reviewStates: ["phone", "pending", "cancel-review", "refunded"], stateCoverage: {storybook: ["phone", "pending", "cancel-review", "refunded"], manual: []}},
  catchComponent: {id: "route_event_booking", routeIds: ["event_booking"], states: ["phone", "pending", "cancel-review", "refunded"]}},
  render: () => <Preview allowNewBookings={false} phase="phone" quote={null} />};
