export interface DemoMetadata {
  demoOps?: boolean;
  demoOpsId?: string;
  demoOpsCommand?: string;
  seedPrefix?: string;
  synthetic?: boolean;
}

/**
 * Copies internal demo-operation metadata from source documents to derived
 * backend-owned projections. This keeps demo cleanup precise even when a
 * Firestore trigger creates the derived document.
 * @param {unknown[]} sources Source docs, in precedence order.
 * @return {DemoMetadata} Demo metadata fields to copy.
 */
export function demoMetadataFromSources(...sources: unknown[]): DemoMetadata {
  const result: DemoMetadata = {};
  for (const source of sources) {
    const data = source as DemoMetadata | undefined;
    result.demoOps ??= data?.demoOps;
    result.demoOpsId ??= data?.demoOpsId;
    result.demoOpsCommand ??= data?.demoOpsCommand;
    result.seedPrefix ??= data?.seedPrefix;
    result.synthetic ??= data?.synthetic;
  }
  return result;
}
