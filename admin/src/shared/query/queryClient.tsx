import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import type {ReactNode} from "react";

const adminQueryClient = new QueryClient({
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

export function AdminQueryProvider({children}: {children: ReactNode}) {
  return (
    <QueryClientProvider client={adminQueryClient}>
      {children}
    </QueryClientProvider>
  );
}
