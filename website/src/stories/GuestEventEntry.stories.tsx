import type {Meta, StoryObj} from "@storybook/react-vite";
import {GuestEventEntryView} from "../features/events/GuestEventEntry";
const noop = () => undefined;
const controller = {user: null, phone: "", setPhone: noop, code: "", setCode: noop,
  codeSent: false, submit: async () => undefined, message: "", pending: false,
  recaptchaId: "preview", viewer: null, loading: false, error: false,
  refresh: async () => ({}),
} as unknown as Parameters<typeof GuestEventEntryView>[0]["controller"];
const meta = {title: "Events/Guest entry", component: GuestEventEntryView,
  args: {eventId: "preview-event", controller},
} satisfies Meta<typeof GuestEventEntryView>;
export default meta;
type Story = StoryObj<typeof meta>;
export const GuestEntry: Story = {parameters: {
  catchComponent: {id: "event_guest_entry", routeIds: ["event_detail_canonical", "event_booking"],
    states: ["phone", "status", "unavailable"]}}};
export const GuestStatus: Story = {parameters: {
  catchComponent: {id: "event_guest_entry_view", routeIds: ["event_detail_canonical", "event_booking"],
    states: ["phone", "status", "unavailable"]}},
  args: {controller: {...controller, user: {uid: "preview", phoneNumber: "+919000000000"},
    viewer: {guest: {action: "applicationPending"}}} as typeof controller}};
export const Unavailable: Story = {args: {controller: {...controller,
  user: {uid: "preview", phoneNumber: "+919000000000"}, error: true} as typeof controller}};
