import {CancelledError, useMutation, useQuery, useQueryClient, type QueryClient} from "@tanstack/react-query";
import {act, cleanup, render, screen, waitFor} from "@testing-library/react";
import {StrictMode, useState} from "react";
import {afterEach, describe, expect, it, vi} from "vitest";
import {AdminQueryProvider} from "./queryClient";

const key = ["admin", "protected-read"];

afterEach(cleanup);

describe("AdminQueryProvider", () => {
  it("retains a cache within one epoch and rotates cache and local state with its scope", async () => {
    const clients: QueryClient[] = [];
    const load = vi.fn().mockResolvedValue("owner-only");
    function Probe() {
      const client = useQueryClient();
      if (!clients.includes(client)) clients.push(client);
      const query = useQuery({queryKey: key, queryFn: load, retry: false});
      const [initial] = useState(clients.length);
      return <p>{initial}:{query.data ?? "empty"}</p>;
    }
    const tree = (scope: string) => <StrictMode>
      <AdminQueryProvider isCurrentSession={() => true} sessionKey={scope}><Probe /></AdminQueryProvider>
    </StrictMode>;
    const view = render(tree("owner:1"));
    await screen.findByText("1:owner-only");
    const owner = clients[0]!;
    owner.getMutationCache().build(owner, {mutationKey: key});
    view.rerender(tree("owner:1"));
    expect(clients).toHaveLength(1);

    load.mockResolvedValue("finance-only");
    view.rerender(tree("finance:2"));
    expect(screen.queryByText(/owner-only/u)).toBeNull();
    await screen.findByText("2:finance-only");
    expect(clients[1]).not.toBe(owner);
    expect(owner.getQueryCache().getAll()).toEqual([]);
    expect(owner.getMutationCache().getAll()).toEqual([]);
  });

  it("cancels protected requests and fences transports that finish after rotation", async () => {
    const clients: QueryClient[] = [];
    let finish!: (value: string) => void;
    let signal!: AbortSignal;
    const oldRequest = new Promise<string>((resolve) => { finish = resolve; });
    function Probe({enabled}: {enabled: boolean}) {
      const client = useQueryClient();
      if (!clients.includes(client)) clients.push(client);
      const query = useQuery({
        queryKey: key,
        queryFn: (context) => { signal = context.signal; return oldRequest; },
        enabled,
      });
      return <p>{query.data ?? "empty"}</p>;
    }
    const view = render(<AdminQueryProvider isCurrentSession={() => true} sessionKey="owner:1">
      <Probe enabled />
    </AdminQueryProvider>);
    await waitFor(() => expect(signal).toBeDefined());
    view.rerender(<AdminQueryProvider isCurrentSession={() => true} sessionKey="owner:2">
      <Probe enabled={false} />
    </AdminQueryProvider>);
    expect(signal.aborted).toBe(true);
    await act(async () => { finish("forbidden late data"); });
    expect(screen.getByText("empty")).not.toBeNull();
    for (const client of clients) {
      expect(client.getQueryData(key)).toBeUndefined();
    }
    expect(clients[0]!.getQueryCache().getAll()).toEqual([]);
  });
  it("fences mutation completion and new starts as soon as the authorization epoch changes", async () => {
    let current = true;
    let complete!: (value: string) => void;
    const write = vi.fn().mockReturnValue(new Promise<string>((resolve) => { complete = resolve; }));
    const onSuccess = vi.fn();
    let mutation!: ReturnType<typeof useMutation<string, Error, void>>;
    function Probe() {
      mutation = useMutation({mutationFn: write, onSuccess});
      return null;
    }
    render(<AdminQueryProvider sessionKey="owner:1" isCurrentSession={() => current}><Probe /></AdminQueryProvider>);
    let result!: Promise<unknown>;
    act(() => { result = mutation.mutateAsync().catch((error: unknown) => error); });
    await waitFor(() => expect(write).toHaveBeenCalledOnce());
    // No rerender yet: the auth listener invalidates the epoch synchronously.
    current = false;
    await act(async () => {
      complete("private result");
      expect(await result).toBeInstanceOf(CancelledError);
    });
    expect(onSuccess).not.toHaveBeenCalled();
    await act(async () => {
      await expect(mutation.mutateAsync()).rejects.toBeInstanceOf(CancelledError);
    });
    expect(write).toHaveBeenCalledOnce();
  });

});
