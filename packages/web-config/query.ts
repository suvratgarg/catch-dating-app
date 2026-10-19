import {QueryClient, type MutationCache} from "@tanstack/react-query";

// Share transport/cache policy, never an account's cache instance. The caller
// owns this client for the lifetime of its public root or private session.
export function createWebQueryClient({
  staleTime = 5 * 60 * 1000,
  mutationCache,
}: {staleTime?: number; mutationCache?: MutationCache} = {}) {
  return new QueryClient({
    mutationCache,
    defaultOptions: {
      mutations: {retry: 0},
      queries: {
        gcTime: 10 * 60 * 1000,
        refetchOnWindowFocus: false,
        retry: 1,
        staleTime,
      },
    },
  });
}
