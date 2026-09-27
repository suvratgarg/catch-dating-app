import {act, cleanup, fireEvent, render, screen, waitFor} from
  "@testing-library/react";
import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import userEvent from "@testing-library/user-event";
import {afterEach, expect, it, vi} from "vitest";
import type {DemoBlueprint, DemoIssueInput, DemoManagementApi} from
  "../api/salesDemoManagement";
import {SalesDemoWorkspace} from "./SalesDemoPanel";

afterEach(() => {cleanup(); vi.unstubAllGlobals();});
const blueprint: DemoBlueprint = {blueprintId: "blueprint-001", revision: 2,
  state: "reviewed", organizerId: "organizer-001", candidateId: null,
  opportunityId: null, capabilityRevision: "revision-001",
  evidenceRevision: "evidence-001",
  formCapabilityReview: {questionTypes: "manual", branching: "manual",
    requiredFields: "manual", scoringApproval: "unsupported",
    uploads: "retained"}, fieldMappings: [],
  preview: {brandName: "Example Host", headline: "A private example",
    scenario: "Synthetic application review",
    steps: ["Review", "Reply", "Admit"], retainedTools: [],
    limitations: ["Synthetic only"], cta: "Try example"},
  reviewedAt: "2026-09-28T10:00:00.000Z",
  updatedAt: "2026-09-28T10:00:00.000Z"};
function fixture() {
  const issueInvitation = vi.fn(async (_input: DemoIssueInput) => ({invitationId: "invitation-001",
    blueprintId: blueprint.blueprintId, blueprintRevision: 2,
    previewOnly: false, expiresAt: "2026-09-29T10:00:00.000Z",
    revision: 1, grantToken: "x".repeat(43)}));
  const api = {capability: vi.fn(async () => ({
    capability: "synthetic_forms_v1", revision: "revision-001",
    evidenceRevision: "evidence-001", enabled: true})),
  listBlueprints: vi.fn(async () => ({rows: [blueprint], nextCursor: null})),
  listInvitations: vi.fn(async () => ({rows: [], nextCursor: null})),
  getBlueprint: vi.fn(async () => blueprint), getInvitation: vi.fn(),
  saveBlueprint: vi.fn(), reviewBlueprint: vi.fn(),
  withdrawBlueprint: vi.fn(), issueInvitation,
  revokeInvitation: vi.fn()} as DemoManagementApi;
  const client = new QueryClient({defaultOptions: {queries: {retry: false}}});
  const view = (isAdminOwner: boolean) => render(
    <QueryClientProvider client={client}>
      <SalesDemoWorkspace organizerId="organizer-001"
        organizerName="Example Host" currentUserUid="owner-001"
        isAdminOwner={isAdminOwner} api={api} />
    </QueryClientProvider>);
  return {api, issueInvitation, view};
}

it("explains the owner boundary without reads or controls for staff", () => {
  const {api, view} = fixture();
  view(false);
  expect(screen.getByText("An Admin owner can prepare and issue private demos."))
    .toBeTruthy();
  expect(screen.queryByRole("button")).toBeNull();
  expect(api.capability).not.toHaveBeenCalled();
  expect(api.listBlueprints).not.toHaveBeenCalled();
});

it("offers reviewed mapping and copies a grant only on deliberate click",
  async () => {
    const {issueInvitation, view} = fixture();
    const copy = vi.fn(async (_text: string) => {});
    vi.stubGlobal("navigator", {...navigator, clipboard: {writeText: copy}});
    view(true);
    fireEvent.click(await screen.findByRole("button", {name: "Open"}));
    expect(await screen.findByDisplayValue("A private example")).toBeTruthy();
    expect(screen.getByLabelText("Branching")).toBeTruthy();
    fireEvent.change(await screen.findByLabelText("Who may try it?"),
      {target: {value: "email"}});
    fireEvent.change(screen.getByLabelText("Intended email"),
      {target: {value: "host@example.invalid"}});
    fireEvent.change(screen.getByLabelText("Expires (within seven days)"),
      {target: {value: new Date(Date.now() + 8 * 86_400_000)
        .toISOString().slice(0, 16)}});
    expect(screen.getByText(/Choose a future expiry/u)).toBeTruthy();
    expect(screen.getByRole("button", {name: "Issue invitation"})
      .hasAttribute("disabled")).toBe(true);
    fireEvent.change(screen.getByLabelText("Expires (within seven days)"),
      {target: {value: new Date(Date.now() + 86_400_000)
        .toISOString().slice(0, 16)}});
    fireEvent.click(screen.getByRole("button", {name: "Issue invitation"}));
    await waitFor(() => expect(issueInvitation).toHaveBeenCalledOnce());
    expect(issueInvitation.mock.calls.at(0)?.[0].contactBinding).toEqual({
      kind: "email", value: "host@example.invalid"});
    expect(document.body.textContent).not.toContain("x".repeat(43));
    expect(copy).not.toHaveBeenCalled();
    await act(async () => {
      fireEvent.click(await screen.findByRole("button", {name: "Copy private link"}));
    });
    expect(copy).toHaveBeenCalledOnce();
    expect(copy.mock.calls.at(0)?.[0]).toContain(
      "/demo/invitation-001#grant=" + "x".repeat(43));
  });

it("uncertain save retry unlocks review only at the confirmed revision",
  async () => {
    const {api, view} = fixture();
    let current: DemoBlueprint = {...blueprint, state: "draft", revision: 1,
      reviewedAt: null};
    vi.mocked(api.listBlueprints).mockImplementation(async () =>
      ({rows: [current], nextCursor: null}));
    vi.mocked(api.getBlueprint).mockImplementation(async () => current);
    const save = vi.mocked(api.saveBlueprint);
    save.mockRejectedValueOnce(new Error("network lost"));
    save.mockImplementationOnce(async (input) => {
      current = {...current, revision: 2, preview: input.preview};
      return {blueprintId: current.blueprintId, revision: 2, state: "draft"};
    });
    vi.mocked(api.reviewBlueprint).mockResolvedValue({blueprintId: "blueprint-001",
      revision: 3, state: "reviewed", reviewedAt: "2026-09-28T10:01:00Z"});
    view(true);
    fireEvent.click(await screen.findByRole("button", {name: "Open"}));
    const headline = await screen.findByLabelText("Headline");
    fireEvent.change(headline, {target: {value: "Updated example"}});
    fireEvent.click(screen.getByRole("button", {name: "Save draft"}));
    fireEvent.click(await screen.findByRole("button", {
      name: "Retry unchanged request"}));
    await waitFor(() => expect(screen.getByRole("button", {
      name: "Mark reviewed"}).hasAttribute("disabled")).toBe(false));
    fireEvent.click(screen.getByRole("button", {name: "Mark reviewed"}));
    await waitFor(() => expect(api.reviewBlueprint).toHaveBeenCalledOnce());
    expect(vi.mocked(api.reviewBlueprint).mock.calls.at(0)?.[0].expectedRevision)
      .toBe(2);
    expect(save.mock.calls.at(1)?.[0]).toEqual(save.mock.calls.at(0)?.[0]);
  });

it("preserves multiline typing and normalizes lists only on save", async () => {
  const {api, view} = fixture();
  vi.mocked(api.saveBlueprint).mockResolvedValue({blueprintId: "blueprint-001",
    revision: 3, state: "draft"});
  const user = userEvent.setup();
  view(true);
  await user.click(await screen.findByRole("button", {name: "Open"}));
  const tools = screen.getByLabelText(
    "Tools that stay in place (one per line)") as HTMLTextAreaElement;
  const limits = screen.getByLabelText(
    "Limits to disclose (one per line)") as HTMLTextAreaElement;
  await user.type(tools, "Google Forms{Enter}Sheets");
  await user.clear(limits);
  await user.type(limits, "No real messages  {Enter}{Enter}No charges  ");
  expect(tools.value).toBe("Google Forms\nSheets");
  expect(limits.value).toBe("No real messages  \n\nNo charges  ");
  await user.click(screen.getByRole("button", {name: "Save draft"}));
  await waitFor(() => expect(api.saveBlueprint).toHaveBeenCalledOnce());
  const sent = vi.mocked(api.saveBlueprint).mock.calls.at(0)?.[0];
  expect(sent?.preview.retainedTools).toEqual(["Google Forms", "Sheets"]);
  expect(sent?.preview.limitations).toEqual(
    ["No real messages", "No charges"]);
});
