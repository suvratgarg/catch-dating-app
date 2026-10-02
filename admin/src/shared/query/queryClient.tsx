import {CancelledError, MutationCache, QueryClient, QueryClientProvider} from "@tanstack/react-query";
import {type ReactNode, useLayoutEffect, useRef, useState} from "react";

function createAdminQueryClient(requireCurrentSession: () => void) {
  return new QueryClient({
    mutationCache: new MutationCache({
      // Clearing MutationCache does not cancel an already-running mutation.
      // Fence its result and any follow-up mutation after this client retires.
      onMutate: requireCurrentSession,
      onSuccess: requireCurrentSession,
    }),
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
export function AdminQueryProvider({children, sessionKey, isCurrentSession}: {
  children: ReactNode;
  sessionKey: string;
  isCurrentSession: () => boolean;
}) {
  return <SessionQueryProvider key={sessionKey} isCurrentSession={isCurrentSession}>
    {children}
  </SessionQueryProvider>;
}

function SessionQueryProvider({children, isCurrentSession}: {
  children: ReactNode;
  isCurrentSession: () => boolean;
}) {
  const active = useRef(true);
  const [client] = useState(() => createAdminQueryClient(() => {
    if (!active.current || !isCurrentSession()) {
      throw new CancelledError({silent: true});
    }
  }));
  useLayoutEffect(() => {
    active.current = true;
    return () => {
      active.current = false;
      // Cancellation fences promises even when the callable transport cannot
      // abort. A late completion can never populate the next session's client.
      void client.cancelQueries();
      client.clear();
    };
  }, [client]);
  return <QueryClientProvider client={client}>{children}</QueryClientProvider>;
}
