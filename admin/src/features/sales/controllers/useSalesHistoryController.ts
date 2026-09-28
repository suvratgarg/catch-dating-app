import {useQuery} from "@tanstack/react-query";
import {useCallback, useMemo, useState} from "react";
import {salesHistoryApi} from "../api/salesHistoryRepository";
import type {SalesHistoryApi} from "../api/salesHistoryTypes";

const pageSize = 25;
type PageState = {scope: string; cursor?: string;
  back: Array<string | undefined>};

/** Host and actor changes reset cursors before their next queries run. */
export function useSalesHistoryController({organizerId, actorUid,
  api = salesHistoryApi}: {organizerId: string; actorUid: string;
  api?: SalesHistoryApi}) {
  const scopeKey = `${actorUid}\u0000${organizerId}`;
  const scope = useMemo(() => ["sales-imported-history", actorUid,
    organizerId] as const, [actorUid, organizerId]);
  const [recordState, setRecordState] = useState<PageState>({scope: scopeKey,
    back: []});
  const [rowState, setRowState] = useState<PageState>({scope: scopeKey,
    back: []});
  const recordPage = recordState.scope === scopeKey ? recordState :
    {scope: scopeKey, back: []};
  const rowPage = rowState.scope === scopeKey ? rowState :
    {scope: scopeKey, back: []};
  const recordCursor = recordPage.cursor;
  const rowCursor = rowPage.cursor;
  const records = useQuery({queryKey: [...scope, "records", recordCursor],
    queryFn: () => api.listRecords({organizerId, cursor: recordCursor,
      limit: pageSize}), retry: false, enabled: Boolean(organizerId)});
  const rows = useQuery({queryKey: [...scope, "rows", rowCursor],
    queryFn: () => api.listRows({organizerId, cursor: rowCursor,
      limit: pageSize}), retry: false, enabled: Boolean(organizerId)});
  const nextRecords = useCallback(() => {
    if (!records.data?.nextCursor) return;
    setRecordState({scope: scopeKey, cursor: records.data.nextCursor,
      back: [...recordPage.back, recordCursor]});
  }, [recordCursor, recordPage.back, records.data, scopeKey]);
  const previousRecords = useCallback(() => {
    if (!recordPage.back.length) return;
    setRecordState({scope: scopeKey, cursor: recordPage.back.at(-1),
      back: recordPage.back.slice(0, -1)});
  }, [recordPage.back, scopeKey]);
  const nextRows = useCallback(() => {
    if (!rows.data?.nextCursor) return;
    setRowState({scope: scopeKey, cursor: rows.data.nextCursor,
      back: [...rowPage.back, rowCursor]});
  }, [rowCursor, rowPage.back, rows.data, scopeKey]);
  const previousRows = useCallback(() => {
    if (!rowPage.back.length) return;
    setRowState({scope: scopeKey, cursor: rowPage.back.at(-1),
      back: rowPage.back.slice(0, -1)});
  }, [rowPage.back, scopeKey]);
  return {records, rows, nextRecords, previousRecords,
    nextRows, previousRows, recordBack: recordPage.back,
    rowBack: rowPage.back};
}
