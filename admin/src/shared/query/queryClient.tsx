import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import {type ReactNode, useLayoutEffect, useState} from "react";

function createAdminQueryClient() {
  return new QueryClient({
    defaultOptions: {
      mutations: {
        retry: 0,
      },
      queries: {
        gcTime: 10 * 60 * 1000,
        refetchOnWindowFocus: false,
        retry: 1,
        staleTime: 60 * 1000,
      },
    },
  });
}

// The route shell supplies principal + authorization epoch. Remount the entire
// private subtree so query observers and controller-local state rotate together.
export function AdminQueryProvider({children, sessionKey}: {
  children: ReactNode;
  sessionKey: string;
}) {
  return <SessionQueryProvider key={sessionKey}>{children}</SessionQueryProvider>;
}

function SessionQueryProvider({children}: {children: ReactNode}) {
  const [client] = useState(createAdminQueryClient);
  useLayoutEffect(() => () => {
    // Cancellation fences promises even when the callable transport cannot
    // abort. A late completion can never populate the next session's client.
    void client.cancelQueries();
    client.clear();
  }, [client]);
  return <QueryClientProvider client={client}>{children}</QueryClientProvider>;
}
