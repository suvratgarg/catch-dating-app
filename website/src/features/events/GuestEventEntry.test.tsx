import {useEffect} from "react";
import {cleanup, fireEvent, render, screen} from "@testing-library/react";
import {afterEach, beforeEach, expect, it, vi} from "vitest";
import {GuestEventEntryView} from "./GuestEventEntry";
const transaction = vi.hoisted(() => ({mounted: vi.fn(), unmounted: vi.fn()}));
vi.mock("./PublicEventRegistration", () => ({PublicEventRegistration: ({mode}: {mode: string}) => {
  useEffect(() => {transaction.mounted(); return () => transaction.unmounted();}, []);
  return <p>{mode} transaction owner</p>;
}}));
type Controller = Parameters<typeof GuestEventEntryView>[0]["controller"];
function controller(action = "bookPaid"): Controller {
  return {user: {uid: "one", phoneNumber: "+919000000001"}, loading: false, error: false,
    viewer: {guest: {action, publicFormId: "application", runtimeId: "runtime", expiresAtMillis: 9e12}},
    pending: false, refresh: vi.fn(), changePhone: vi.fn(), changeAccount: vi.fn(),
    phone: "", code: "", codeSent: false, recaptchaId: "test-phone", message: "",
    setPhone: vi.fn(), setCode: vi.fn(), submit: vi.fn(),
  } as unknown as Controller;
}
function view(c: Controller) {
  return <GuestEventEntryView eventId="event" controller={c} invitation={{title: "Dinner", price: "₹1,500"}} />;
}
beforeEach(() => {
  vi.clearAllMocks();
  HTMLDialogElement.prototype.showModal = function () {this.setAttribute("open", "");};
  HTMLDialogElement.prototype.close = function () {this.removeAttribute("open");};
});
afterEach(cleanup);
it("desktop and mobile actions open one checkout, preserved through status polling", () => {
  const c = controller();
  const {rerender} = render(view(c));
  const actions = screen.getAllByRole("button", {name: "Book now"});
  expect(actions).toHaveLength(2);
  fireEvent.click(actions[1]);
  expect(screen.getAllByRole("dialog")).toHaveLength(1);
  expect(transaction.mounted).toHaveBeenCalledOnce();
  rerender(view(controller("recoverPayment")));
  expect(screen.getByText("paid transaction owner")).toBeTruthy();
  expect(transaction.unmounted).not.toHaveBeenCalled();
  fireEvent.click(screen.getByRole("button", {name: "Close"}));
  expect(screen.queryByRole("dialog")).toBeNull();
  expect(transaction.unmounted).toHaveBeenCalledOnce();
});
it("account changes cannot retain another guest's open checkout", () => {
  const c = controller(); const {rerender} = render(view(c));
  fireEvent.click(screen.getAllByRole("button", {name: "Book now"})[0]);
  rerender(view({...c, user: null, viewer: null}));
  expect(screen.queryByText("paid transaction owner")).toBeNull();
  expect(screen.getByLabelText("Mobile number")).toBeTruthy();
});
it("does not show a booking button before sign-in or while auth resolves", () => {
  const c = {...controller(), user: null, viewer: null};
  const {rerender} = render(view(c));
  expect(screen.queryByRole("button", {name: "Book now"})).toBeNull();
  fireEvent.click(screen.getAllByRole("button", {name: "Sign in to continue"})[0]);
  expect(screen.getByLabelText("Mobile number")).toBeTruthy();
  expect(transaction.mounted).not.toHaveBeenCalled();
  fireEvent.click(screen.getByRole("button", {name: "Close"}));
  expect(c.refresh).not.toHaveBeenCalled();
  rerender(view({...c, loading: true}));
  expect(screen.getAllByRole("button", {name: "Checking your event status…"}).every((button) => button.hasAttribute("disabled"))).toBe(true);
});
it.each(["applicationPending", "applicationWaitlisted", "awaitingOffer", "seatWaitlisted", "closed"])("%s does not start registration", (state) => {
  render(view(controller(state)));
  expect(screen.queryByRole("button", {name: "Book now"})).toBeNull();
  fireEvent.click(screen.getAllByRole("button", {name: "View your status"})[0]);
  expect(transaction.mounted).not.toHaveBeenCalled();
});
it("confirmed guests use the same issued runtime link in both placements", () => {
  render(view(controller("registered")));
  const links = screen.getAllByRole("link", {name: "Prepare for your event"});
  expect(links).toHaveLength(2);
  expect(links.every((link) => link.getAttribute("href") === "/join/runtime")).toBe(true);
});
