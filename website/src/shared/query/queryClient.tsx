import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import type {ReactNode} from "react";

const websiteQueryClient = new QueryClient({
  defaultOptions: {
    mutations: {
      retry: 0,
    },
    queries: {
      gcTime: 10 * 60 * 1000,
      refetchOnWindowFocus: false,
      retry: 1,
      staleTime: 5 * 60 * 1000,
    },
  },
});

export function WebsiteQueryProvider({children}: {children: ReactNode}) {
  return (
    <QueryClientProvider client={websiteQueryClient}>
      {children}
    </QueryClientProvider>
  );
}
