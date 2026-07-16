import {renderHook, waitFor} from "@testing-library/react";
import {describe, expect, it, vi} from "vitest";

import {createQueryHarness} from
  "../../../../shared/test/queryHarness";
import {sampleIntakeOperations} from
  "../../../../shared/operations/sampleIntakeOperations";
import {
  loadCompleteIntakeOperations,
  loadNextIntakeOperationsPage,
  useIntakeOperationsController,
} from
  "./useIntakeOperationsController";

describe("useIntakeOperationsController", () => {
  it("loads the persisted-stage projection with safe capabilities", async () => {
    const {wrapper} = createQueryHarness();
    const onError = vi.fn();
    const {result} = renderHook(() => useIntakeOperationsController({onError}), {
      wrapper,
    });

    await waitFor(() => expect(result.current.data).not.toBeNull());
    expect(result.current.data?.summary.stages).toEqual({
      incoming: 1,
      verify: 1,
      resolve: 1,
      ready: 1,
    });
    expect(result.current.data?.capabilities).toMatchObject({
      requestRuns: false,
      networkFetches: false,
      modelCalls: false,
      publicWrites: false,
    });
    expect(onError).toHaveBeenLastCalledWith(null);
  });

  it("drains the selected run so a later-page human exception is accessible", async () => {
    const sample = sampleIntakeOperations();
    const ordinary = sample.workItems.find((item) =>
      !item.taskFlags.includes("human_review_required"));
    const exception = sample.workItems.find((item) =>
      item.taskFlags.includes("human_review_required"));
    expect(ordinary).toBeTruthy();
    expect(exception).toBeTruthy();
    if (!ordinary || !exception) throw new Error("sample inventory is incomplete");
    const summary = {
      ...sample.summary,
      workItemCount: 2,
      humanReviewCount: 1,
    };
    const loader = vi.fn()
      .mockResolvedValueOnce({
        ...sample,
        summary,
        workItems: [ordinary],
        nextWorkItemCursor: "work-page-2",
      })
      .mockResolvedValueOnce({
        ...sample,
        summary,
        workItems: [exception],
        nextWorkItemCursor: null,
      });

    const result = await loadCompleteIntakeOperations(loader);
    expect(loader).toHaveBeenCalledTimes(2);
    expect(loader.mock.calls[1]?.[0]).toMatchObject({
      runId: sample.runs[0].runId,
      runCursor: null,
      workItemCursor: "work-page-2",
      humanReviewRequired: true,
    });
    expect(result.workItems).toHaveLength(2);
    expect(result.workItems.some((item) =>
      item.workItemId === exception.workItemId)).toBe(true);
    expect(result.nextWorkItemCursor).toBeNull();
  });

  it("keeps a maximum ordinary run lazy after the first page", async () => {
    const sample = sampleIntakeOperations();
    const template = sample.workItems.find((item) =>
      !item.taskFlags.includes("human_review_required"));
    expect(template).toBeTruthy();
    if (!template) throw new Error("sample inventory is incomplete");
    const capacity = 10_000;
    const pageSize = 200;
    const firstPage = Array.from({length: pageSize}, (_, itemIndex) => ({
        ...template,
        workItemId: `capacity-0-${itemIndex}`,
        externalKey: `capacity-0-${itemIndex}`,
        taskFlags: [],
        blockerCodes: [],
        normalizedPayload: {
          ...template.normalizedPayload,
          owner: "system",
        },
      }));
    const summary = {
      ...sample.summary,
      workItemCount: capacity,
      humanReviewCount: 0,
      stages: {
        incoming: capacity,
        verify: 0,
        resolve: 0,
        ready: 0,
      },
    };
    const loader = vi.fn(async () => ({
      ...sample,
      summary,
      workItems: firstPage,
      nextWorkItemCursor: "capacity-page-1",
    }));

    const result = await loadCompleteIntakeOperations(loader);
    expect(loader).toHaveBeenCalledTimes(1);
    expect(result.workItems).toHaveLength(pageSize);
    expect(result.nextWorkItemCursor).toBe("capacity-page-1");
  });

  it("hydrates every exception in a maximum shard before handoff", async () => {
    const sample = sampleIntakeOperations();
    const template = sample.workItems.find((item) =>
      item.taskFlags.includes("human_review_required"));
    expect(template).toBeTruthy();
    if (!template) throw new Error("sample exception is missing");
    const capacity = 10_000;
    const pageSize = 200;
    const summary = {
      ...sample.summary,
      workItemCount: capacity,
      humanReviewCount: capacity,
      stages: {
        incoming: 0,
        verify: 0,
        resolve: capacity,
        ready: 0,
      },
    };
    const loader = vi.fn(async (payload) => {
      const pageIndex = payload.workItemCursor ?
        Number(payload.workItemCursor.replace("exception-page-", "")) : 0;
      const workItems = Array.from({length: pageSize}, (_, itemIndex) => ({
        ...template,
        workItemId: `exception-${pageIndex}-${itemIndex}`,
        externalKey: `exception-${pageIndex}-${itemIndex}`,
      }));
      return {
        ...sample,
        summary,
        workItems,
        nextWorkItemCursor: pageIndex + 1 < capacity / pageSize ?
          `exception-page-${pageIndex + 1}` : null,
      };
    });

    const result = await loadCompleteIntakeOperations(loader);
    expect(loader).toHaveBeenCalledTimes(50);
    expect(loader.mock.calls.slice(1).every(([payload]) =>
      payload.humanReviewRequired === true &&
      payload.workItemLimit === 200)).toBe(true);
    expect(result.workItems).toHaveLength(capacity);
    expect(result.nextWorkItemCursor).toBeNull();
  });

  it("loads one ordinary page and merges already-hydrated exceptions", async () => {
    const sample = sampleIntakeOperations();
    const summary = {
      ...sample.summary,
      workItemCount: 5,
      stages: {...sample.summary.stages, incoming: 2},
    };
    const current = {
      ...sample,
      summary,
      nextWorkItemCursor: "ordinary-page-2",
    };
    const pageItem = {
      ...sample.workItems[0],
      workItemId: "ordinary-page-2-item",
      externalKey: "ordinary-page-2-item",
    };
    const loader = vi.fn(async () => ({
      ...sample,
      summary,
      workItems: [pageItem],
      nextWorkItemCursor: null,
    }));

    const result = await loadNextIntakeOperationsPage(current, loader);
    expect(loader).toHaveBeenCalledWith(expect.objectContaining({
      runId: sample.runs[0].runId,
      workItemCursor: "ordinary-page-2",
      humanReviewRequired: false,
    }));
    expect(result.workItems.some((item) =>
      item.workItemId === pageItem.workItemId)).toBe(true);
    expect(result.nextWorkItemCursor).toBeNull();
  });

  it("fails when the initial cursor ends before inventory cardinality", async () => {
    const sample = sampleIntakeOperations();
    const loader = vi.fn(async () => ({
      ...sample,
      summary: {
        ...sample.summary,
        workItemCount: sample.workItems.length + 1,
      },
      nextWorkItemCursor: null,
    }));
    await expect(loadCompleteIntakeOperations(loader)).rejects.toThrow(
      "ended before the persisted inventory was complete"
    );
  });

  it.each([
    {label: "ends early", cursor: null, duplicateOnly: false},
    {label: "repeats its cursor", cursor: "ordinary-page-2", duplicateOnly: false},
    {label: "returns only duplicates", cursor: "ordinary-page-3", duplicateOnly: true},
  ])("fails when ordinary pagination $label", async ({
    cursor,
    duplicateOnly,
  }) => {
    const sample = sampleIntakeOperations();
    const summary = {
      ...sample.summary,
      workItemCount: sample.workItems.length + 2,
    };
    const current = {
      ...sample,
      summary,
      nextWorkItemCursor: "ordinary-page-2",
    };
    const pageItem = duplicateOnly ? sample.workItems[0] : {
      ...sample.workItems[0],
      workItemId: "ordinary-new-item",
      externalKey: "ordinary-new-item",
    };
    const loader = vi.fn(async () => ({
      ...sample,
      summary,
      workItems: [pageItem],
      nextWorkItemCursor: cursor,
    }));
    await expect(
      loadNextIntakeOperationsPage(current, loader)
    ).rejects.toThrow("ended or stalled");
  });
});
