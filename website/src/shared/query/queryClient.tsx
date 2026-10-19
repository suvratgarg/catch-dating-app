import {QueryClient, QueryClientProvider} from "@tanstack/react-query";
import {useState, type ReactNode} from "react";

function createWebsiteQueryClient() { return new QueryClient({
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
}

export function WebsiteQueryProvider({children}: {children: ReactNode}) {
  const [websiteQueryClient] = useState(createWebsiteQueryClient);
  return (
    <QueryClientProvider client={websiteQueryClient}>
      {children}
    </QueryClientProvider>
  );
}
