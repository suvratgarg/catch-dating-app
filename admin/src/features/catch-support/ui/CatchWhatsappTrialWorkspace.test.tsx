import {act, fireEvent, render, screen, waitFor} from "@testing-library/react";
import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import {expect, it, vi} from "vitest";
import {AdminPendingOperationProvider} from "../../../shared/pendingOperation";
import type {CatchTrialApi} from "../api/catchWhatsappTrialRepository";
import {CatchWhatsappTrialWorkspace} from "./CatchWhatsappTrialWorkspace";
const scope = {actorUid: "staff", projectId: "catchdates-dev",
  sessionKey: "session", isCurrent: () => true};
function mount(enabled = false) {
  const api: CatchTrialApi = {
    prepare: vi.fn().mockResolvedValue(() => undefined),
    review: vi.fn().mockResolvedValue({purpose: "serviceSupport",
      inboundEventId: "cwhe_" + "a".repeat(64), inboundText: "Please help me.",
      reviewedInboundTextHash: "b".repeat(64), deadlineMillis: Date.now() + 60000}),
    send: vi.fn().mockResolvedValue({operationId: "cwreply_" + "c".repeat(64),
      providerMessageId: "wamid.test", deliveryStatus: "accepted", replayed: false}),
  };
  render(<QueryClientProvider client={new QueryClient()}>
    <AdminPendingOperationProvider>
      <CatchWhatsappTrialWorkspace scope={scope} enabled={enabled} api={api} />
    </AdminPendingOperationProvider>
  </QueryClientProvider>);
  return api;
}
it("shows the default-disabled trial without interactive sending controls", () => {
  const api = mount();
  expect(screen.getByText(/trial is not enabled/)).toBeTruthy();
  expect(screen.queryByRole("button")).toBeNull();
  expect(api.prepare).not.toHaveBeenCalled();
});
it("requires visible exact review, reply and confirmation before the one send",
  async () => {
    const api = mount(true);
    fireEvent.change(screen.getByLabelText("Support request ID"),
      {target: {value: "cwhe_" + "a".repeat(64)}});
    fireEvent.click(screen.getByRole("button", {name: "Review request"}));
    await screen.findByDisplayValue("Please help me.");
    const send = screen.getByRole("button", {name: "Send this reply once"});
    expect((send as HTMLButtonElement).disabled).toBe(true);
    fireEvent.change(screen.getByLabelText("Exact reply"),
      {target: {value: "Here is the requested help."}});
    fireEvent.click(screen.getByRole("checkbox"));
    expect((send as HTMLButtonElement).disabled).toBe(false);
    await act(async () => {fireEvent.click(send);});
    await waitFor(() => expect(api.send).toHaveBeenCalledOnce());
    expect((send as HTMLButtonElement).disabled).toBe(true);
    expect(screen.getByText(/Reply recorded/)).toBeTruthy();
  });
