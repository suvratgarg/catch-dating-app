import {
  QueryClient,
  QueryClientProvider,
  useMutation,
} from "@tanstack/react-query";
import {act, renderHook, waitFor} from "@testing-library/react";
import type {PropsWithChildren} from "react";
import {describe, expect, it} from "vitest";
import {usePendingMutationRecord} from "./usePendingMutationRecord";

type Variables = {id: string; decision: string};

describe("usePendingMutationRecord", () => {
  it("indexes only pending mutations by the resolved domain key", async () => {
    const resolvers: Array<() => void> = [];
    const client = new QueryClient({
      defaultOptions: {mutations: {retry: false}},
    });
    function Wrapper({children}: PropsWithChildren) {
      return <QueryClientProvider client={client}>{children}</QueryClientProvider>;
    }
    const {result} = renderHook(() => {
      const mutation = useMutation({
        mutationKey: ["admin", "decision"],
        mutationFn: (_variables: Variables) =>
          new Promise<void>((resolve) => resolvers.push(resolve)),
      });
      const pending = usePendingMutationRecord<Variables, string>(
        ["admin", "decision"],
        (variables) => ({key: variables.id, value: variables.decision})
      );
      return {mutation, pending};
    }, {wrapper: Wrapper});

    act(() => {
      result.current.mutation.mutate({id: "one", decision: "hold"});
      result.current.mutation.mutate({id: "two", decision: "approve"});
    });

    await waitFor(() => expect(result.current.pending).toEqual({
      one: "hold",
      two: "approve",
    }));

    act(() => resolvers[0]?.());
    await waitFor(() => expect(result.current.pending).toEqual({two: "approve"}));
    act(() => resolvers[1]?.());
    await waitFor(() => expect(result.current.pending).toEqual({}));
  });
});
