import {cleanup, render} from "@testing-library/react";
import {useQueryClient, type QueryClient} from "@tanstack/react-query";
import {createWebQueryClient} from "@catch/web-config/query";
import {afterEach, describe, expect, it} from "vitest";
import {WebsiteQueryProvider} from "./queryClient";

afterEach(cleanup);

describe("public query ownership", () => {
  it("retains one client on rerender and isolates independent roots and remounts", () => {
    const clients: QueryClient[] = [];
    function Capture() {
      clients.push(useQueryClient());
      return null;
    }
    const root = render(<WebsiteQueryProvider><Capture /></WebsiteQueryProvider>);
    clients[0].setQueryData(["private-fixture"], "first root only");
    root.rerender(<WebsiteQueryProvider><Capture /></WebsiteQueryProvider>);
    expect(clients[1]).toBe(clients[0]);
    render(<WebsiteQueryProvider><Capture /></WebsiteQueryProvider>);
    expect(clients[2]).not.toBe(clients[0]);
    expect(clients[2].getQueryData(["private-fixture"])).toBeUndefined();
    root.unmount();
    render(<WebsiteQueryProvider><Capture /></WebsiteQueryProvider>);
    expect(clients[3].getQueryData(["private-fixture"])).toBeUndefined();
    clients.forEach((client) => client.clear());
  });

  it("shares retry policy while allowing a private surface's shorter freshness window", () => {
    const publicClient = createWebQueryClient();
    const privateClient = createWebQueryClient({staleTime: 60_000});
    expect(publicClient.getDefaultOptions().queries).toMatchObject({
      staleTime: 300_000, gcTime: 600_000, retry: 1, refetchOnWindowFocus: false,
    });
    expect(privateClient.getDefaultOptions().queries?.staleTime).toBe(60_000);
    expect(publicClient.getDefaultOptions().mutations?.retry).toBe(0);
    expect(privateClient.getDefaultOptions().mutations?.retry).toBe(0);
  });
});
