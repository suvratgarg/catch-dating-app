import {useMutationState, type MutationKey} from "@tanstack/react-query";
import {useMemo} from "react";

type PendingRecordEntry<TValue> = {
  key: string;
  value: TValue;
};

export function usePendingMutationRecord<TVariables, TValue>(
  mutationKey: MutationKey,
  resolveEntry: (variables: TVariables) => PendingRecordEntry<TValue> | null
): Record<string, TValue> {
  const entries = useMutationState({
    filters: {mutationKey, status: "pending"},
    select: (mutation) => {
      const variables = mutation.state.variables;
      return variables === undefined ?
        null :
        resolveEntry(variables as TVariables);
    },
  });

  return useMemo(() => {
    const record: Record<string, TValue> = {};
    for (const entry of entries) {
      if (!entry) continue;
      record[entry.key] = entry.value;
    }
    return record;
  }, [entries]);
}
