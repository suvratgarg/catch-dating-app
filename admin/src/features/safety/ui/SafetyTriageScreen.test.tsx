import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import {cleanup, fireEvent, render, screen, within} from "@testing-library/react";
import {afterEach, beforeEach, describe, expect, it, vi} from "vitest";
import {sampleOverview} from "../../../shared/api/sampleData";
import {SafetyTriageScreen} from "./SafetyTriageScreen";

const repository = vi.hoisted(() => ({
  assignSafetyTriageItemOwner: vi.fn(),
  decideSafetyTriageItemStatus: vi.fn(),
  loadSafetyTriageItem: vi.fn(),
  loadSafetyTriageSnapshot: vi.fn(),
}));
vi.mock("../api/safetyTriageRepository", () => repository);

afterEach(cleanup);
beforeEach(() => {
  Object.values(repository).forEach((mock) => mock.mockReset());
});

function renderQueue({empty = false} = {}) {
  const snapshot = structuredClone(sampleOverview);
  snapshot.metrics = [
    {id: "openReports", label: "Open reports", value: 14},
    {id: "pendingModerationFlags", label: "Moderation", value: 9},
    {id: "eventSafetyReports", label: "Event reports", value: 3},
  ];
  snapshot.queues.safetyReports = empty ? [] :
    snapshot.queues.safetyReports.slice(0, 1);
  snapshot.queues.moderationFlags = [];
  snapshot.queues.eventSafetyReports = empty ? [] :
    snapshot.queues.eventSafetyReports.slice(0, 1);
  repository.loadSafetyTriageSnapshot.mockResolvedValue(snapshot);
  const client = new QueryClient({defaultOptions: {queries: {retry: false}}});
  const onSelect = vi.fn();
  render(<QueryClientProvider client={client}>
    <SafetyTriageScreen onBackToList={vi.fn()} onError={vi.fn()}
      onNotice={vi.fn()} onSelectTargetPath={onSelect} selectedTargetPath={null} />
  </QueryClientProvider>);
  return {snapshot, onSelect};
}

function expectAuthoritativeTotals(returned: number[]) {
  const totals = screen.getByRole("region", {name: "Authoritative open safety totals"});
  const cards = within(totals).getAllByRole("article");
  for (const [index, [label, value]] of [
    ["User reports", "14"], ["Moderation", "9"], ["Event reports", "3"],
  ].entries()) {
    const card = within(cards[index]!);
    expect(card.getByText(label!)).toBeTruthy();
    expect(card.getByText(value!, {exact: true})).toBeTruthy();
    expect(card.getByText(`${returned[index]} preview rows returned`)).toBeTruthy();
  }
}

describe("SafetyTriageScreen preview evidence", () => {
  it("renders aggregate totals separately from two loaded rows and filters only the preview", async () => {
    const {snapshot, onSelect} = renderQueue();
    await screen.findByText("2 shown of 2 preview rows");
    expectAuthoritativeTotals([1, 0, 1]);
    const table = screen.getByRole("table", {name: "Safety triage queue"});
    expect(within(table).getAllByRole("row")).toHaveLength(3);
    expect(within(table).queryByRole("columnheader", {name: /priority/i})).toBeNull();
    expect(screen.queryByText(/priority distribution|age distribution/i)).toBeNull();
    expect(screen.getByText(/Search applies only to these 2 loaded rows/)).toBeTruthy();

    fireEvent.click(screen.getByRole("button", {name: "User reports"}));
    await screen.findByText("1 shown of 2 preview rows");
    expectAuthoritativeTotals([1, 0, 1]);
    fireEvent.click(within(table).getByRole("button", {name: "Open"}));
    expect(onSelect).toHaveBeenCalledWith(snapshot.queues.safetyReports[0]!.targetPath);

    fireEvent.change(screen.getByRole("textbox", {name: "Search safety queues"}),
      {target: {value: "no matching loaded row"}});
    await screen.findByText("0 shown of 2 preview rows");
    expect(screen.getByText("No safety queue rows match this filter.")).toBeTruthy();
    expectAuthoritativeTotals([1, 0, 1]);
    expect(repository.loadSafetyTriageSnapshot).toHaveBeenCalledTimes(1);
  });

  it("does not replace nonzero aggregate totals with an empty returned preview", async () => {
    renderQueue({empty: true});
    await screen.findByText("0 shown of 0 preview rows");
    expectAuthoritativeTotals([0, 0, 0]);
    expect(screen.getByText("No safety queue rows match this filter.")).toBeTruthy();
  });
});
