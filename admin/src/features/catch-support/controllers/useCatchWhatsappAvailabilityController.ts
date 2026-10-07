import {useQuery} from "@tanstack/react-query";
import {catchWhatsappSupportAvailable, refreshCatchWhatsappAvailability} from
  "../api/catchWhatsappAvailability";
import type {CatchTrialScope} from "../api/catchWhatsappTrialRepository";

export function useCatchWhatsappAvailabilityController(scope: CatchTrialScope, override?: boolean): boolean {
  const query = useQuery({queryKey: ["catch-support", "availability", scope.projectId,
    scope.actorUid, scope.sessionKey],
  enabled: override === undefined && Boolean(scope.actorUid && scope.sessionKey),
  queryFn: () => refreshCatchWhatsappAvailability(scope),
  retry: false, staleTime: 0, refetchInterval: 15000, gcTime: 0});
  return override ?? (query.data === true && catchWhatsappSupportAvailable(scope));
}
