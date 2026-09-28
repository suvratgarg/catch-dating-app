import {useQuery} from "@tanstack/react-query";
import {useState} from "react";
import {getSalesFunnelReport} from "../api/salesFunnelRepository";
export function useSalesFunnelController(actorUid: string) {
  const [since] = useState(() => new Date(Date.now() - 30 * 86400000).toISOString());
  return useQuery({queryKey: ["sales", "funnel", actorUid, since],
    queryFn: () => getSalesFunnelReport(since), staleTime: 60000,
    refetchOnWindowFocus: false, retry: false});
}
