import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import {cleanup, fireEvent, render, screen} from "@testing-library/react";
import type {PropsWithChildren} from "react";
import {afterEach, expect, it, vi} from "vitest";
const api = vi.hoisted(() => ({get: vi.fn(), withdraw: vi.fn(), waGet: vi.fn(), waWithdraw: vi.fn(), guestGet: vi.fn()}));
vi.mock("../../firebase", () => ({getEventAssistanceSmsWithdrawal: api.get,
  withdrawEventAssistanceSms: api.withdraw, getEventWhatsappWithdrawal: api.waGet,
  withdrawEventWhatsapp: api.waWithdraw,
  getEventAssistanceGuestView: api.guestGet,
  submitEventAssistanceGuestChoice: vi.fn()}));
import {EventAssistancePage} from "./EventAssistancePage";
import {eventMessagingCopy as copy, eventWhatsappMessagingCopy as waCopy} from "../../content/eventMessaging";
const credential = {linkId: "a".repeat(32), secret: "b".repeat(43)};
function setup() {
  api.guestGet.mockResolvedValue({status: "unavailable", reason: "eventClosed", serverTime: 1000});
  const client = new QueryClient({defaultOptions: {queries: {retry: false}}});
  const wrapper = ({children}: PropsWithChildren) =>
    <QueryClientProvider client={client}>{children}</QueryClientProvider>;
  api.waGet.mockResolvedValue({outcome: "read", view: {serverTime: 1000,
    expiresAt: 100_000, revision: 1, preference: "enabled"}});
  api.waWithdraw.mockResolvedValue({outcome: "applied", view: {serverTime: 1001,
    expiresAt: 100_000, revision: 2, preference: "disabled"}});
  return {wrapper};
}
afterEach(cleanup);

it("the closed event page retains WhatsApp withdrawal and hides unissued SMS", async () => {
  api.get.mockRejectedValue(Object.assign(new Error("Unavailable"), {code: "functions/not-found"}));
  const h = setup();
  render(<EventAssistancePage credential={credential} />, h);
  await screen.findByText("This update is unavailable");
  fireEvent.click(await screen.findByRole("button", {name: waCopy.turnOff}));
  await screen.findByText(waCopy.withdrawalSaved);
  expect(screen.queryByRole("button", {name: copy.turnOff})).toBeNull();
  expect(screen.queryByRole("button", {name: waCopy.turnOn})).toBeNull();
  expect(api.waWithdraw).toHaveBeenCalledOnce();
  expect(api.withdraw).not.toHaveBeenCalled();
});
