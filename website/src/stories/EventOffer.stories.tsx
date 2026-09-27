import {useState} from "react";
import type {Meta, StoryObj} from "@storybook/react-vite";
import {EventOfferView} from "../features/eventOffers/EventOfferPage";
import type {useOfferCheckoutController} from "../features/eventOffers/useOfferCheckoutController";
const meta = {title: "Marketing Website/Event invitation"} satisfies Meta;
export default meta;
type Story = StoryObj<typeof meta>;
const empty = () => undefined;
const fixture: ReturnType<typeof useOfferCheckoutController> = {
  hasInvitation: true, phase: "ready", phone: "+91 98765 43210", setPhone: empty, code: "", setCode: empty,
  grant: {grantId: "a".repeat(64), eventId: "demo", eventName: "Sunday morning at Lodhi",
    startTimeMillis: 1791075600000, amountPaise: 85000, currency: "INR", expiresAtMillis: 9e12},
  payment: null, pending: false, status: {message: "", tone: ""}, recaptchaId: "preview-otp",
  sendCode: async () => undefined, verifyCode: async () => undefined, changePhone: empty,
  pay: async () => undefined, check: async () => undefined, load: async () => undefined,
};
const payment = {paymentId: `ep_${"a".repeat(32)}`, status: "verifying" as const,
  amountPaise: 85000, currency: "INR" as const, mode: "test" as const,
  refundedAmountPaise: 0, expiresAtMillis: 9e12, checkout: null};
export const EventOffer: Story = {parameters: {
  catchRoute: {id: "event_offer", path: "/offer/", reviewStates: ["phone", "otp", "ready", "pending", "admitted", "refund", "unavailable"],
    stateCoverage: {storybook: ["phone", "otp", "ready", "pending", "admitted", "refund", "unavailable"], manual: []}},
  catchComponent: {id: "route_event_offer", routeIds: ["event_offer"], states: ["phone", "otp", "ready", "pending", "admitted", "refund", "unavailable"]}},
render: () => <EventOfferView {...fixture} />};
export const Invitation: Story = {parameters: {catchComponent: {id: "event_offer_view",
  routeIds: ["event_offer"], states: ["phone", "otp", "ready", "pending", "admitted", "refund", "unavailable"]}}, render: () => <EventOfferView {...fixture} />};
export const Phone: Story = {render: function PhonePreview() {
  const [phase, setPhase] = useState<"phone" | "otp" | "ready">("phone");
  const [phone, setPhone] = useState("");
  const [code, setCode] = useState("");
  return <EventOfferView {...fixture} grant={phase === "ready" ? fixture.grant : null}
    phase={phase} phone={phone} setPhone={setPhone} code={code} setCode={setCode}
    sendCode={async (event) => {event.preventDefault(); setPhase("otp");}}
    verifyCode={async (event) => {event.preventDefault(); setPhase("ready");}}
    changePhone={() => setPhase("phone")} />;
}};
export const Otp: Story = {render: () => <EventOfferView {...fixture} grant={null} phase="otp" />};
export const Pending: Story = {render: () => <EventOfferView {...fixture} payment={payment} />};
export const Admitted: Story = {render: () => <EventOfferView {...fixture} payment={{...payment, status: "admitted"}} />};
export const Refund: Story = {render: () => <EventOfferView {...fixture} payment={{...payment, status: "refundPending"}} />};
export const Unavailable: Story = {render: () => <EventOfferView {...fixture} grant={null} phase="unavailable" />};
