import {cleanup, fireEvent, render, screen, waitFor} from
  "@testing-library/react";
import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import {afterEach, expect, it, vi} from "vitest";
import {AdminPendingOperationProvider} from
  "../../../shared/pendingOperation";
import type {PrivacyApi} from "../api/salesPrivacyTypes";
import {renderSalesPrivacyWorkspace} from "./SalesPrivacyWorkspace";

const mocks = vi.hoisted(() => ({mode: "live" as "live" | "sample",
  search: vi.fn()}));
vi.mock("../../../shared/api/dataMode", () => ({dataMode: () => mocks.mode}));
vi.mock("../api/salesRepository", () => ({
  searchCanonicalOrganizers: mocks.search,
}));
afterEach(() => {cleanup(); vi.clearAllMocks(); mocks.mode = "live";});

function fixture(organizerId?: string) {
  const api: PrivacyApi = {
    getCase: vi.fn().mockResolvedValue({organizerId: "org-a",
      restricted: false, plan: null, policy: null, completeDeletion: false}),
    reviewPolicy: vi.fn(), restrict: vi.fn().mockResolvedValue({}),
    preview: vi.fn(), reviewPlan: vi.fn(), applyBatch: vi.fn(),
  };
  const client = new QueryClient({defaultOptions: {queries: {retry: false}}});
  render(<QueryClientProvider client={client}>
    <AdminPendingOperationProvider>
      {renderSalesPrivacyWorkspace({actorUid: "owner-a",
        isAdminOwner: true, organizerId,
        organizerName: organizerId ? "Sample Harbor" : undefined, api})}
    </AdminPendingOperationProvider>
  </QueryClientProvider>);
  return api;
}

it("keeps sample privacy mutations unavailable", () => {
  mocks.mode = "sample";
  const api = fixture("org-a");
  expect(screen.getByText(/Sample hosts cannot be restricted/u)).toBeTruthy();
  expect(api.getCase).not.toHaveBeenCalled();
});

it("finds a canonical organizer after its Sales account is absent", async () => {
  mocks.search.mockResolvedValue([{clubId: "org-a", name: "Sample Harbor",
    cityName: "Example City"}]);
  const api = fixture();
  fireEvent.change(screen.getByLabelText("Host name"),
    {target: {value: "Sample"}});
  fireEvent.click(screen.getByRole("button", {name: "Search hosts"}));
  await waitFor(() => expect(screen.getByRole("button",
    {name: /Sample Harbor/u})).toBeTruthy());
  fireEvent.click(screen.getByRole("button", {name: /Sample Harbor/u}));
  await waitFor(() => expect(api.getCase).toHaveBeenCalledWith("org-a"));
  expect(screen.getByText(/does not delete product organizers/u)).toBeTruthy();
});

it("requires exact host-name confirmation before restriction", async () => {
  const api = fixture("org-a");
  await waitFor(() => expect(screen.getByLabelText("Reason for restriction"))
    .toBeTruthy());
  fireEvent.change(screen.getByLabelText("Reason for restriction"),
    {target: {value: "Approved internal hold"}});
  const submit = screen.getByRole("button",
    {name: "Restrict private Sales processing"});
  expect((submit as HTMLButtonElement).disabled).toBe(true);
  fireEvent.change(screen.getByLabelText(/Type “Sample Harbor”/u),
    {target: {value: "Sample Harbor"}});
  expect((submit as HTMLButtonElement).disabled).toBe(false);
  fireEvent.click(submit);
  await waitFor(() => expect(api.restrict).toHaveBeenCalledWith(
    expect.objectContaining({organizerId: "org-a",
      reason: "Approved internal hold"})));
});
