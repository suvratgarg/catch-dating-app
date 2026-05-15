export interface DemoMetadata {
  demoOps?: boolean;
  demoOpsId?: string;
  demoOpsCommand?: string;
  seedPrefix?: string;
  scenario?: string;
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
    assignFirstDefined(result, "demoOps", data?.demoOps);
    assignFirstDefined(result, "demoOpsId", data?.demoOpsId);
    assignFirstDefined(result, "demoOpsCommand", data?.demoOpsCommand);
    assignFirstDefined(result, "seedPrefix", data?.seedPrefix);
    assignFirstDefined(result, "scenario", data?.scenario);
    assignFirstDefined(result, "synthetic", data?.synthetic);
  }
  return result;
}

/**
 * Copies a metadata field once, but never materializes undefined properties.
 * @param {DemoMetadata} target Metadata result.
 * @param {string} key Metadata field.
 * @param {unknown} value Candidate value.
 */
function assignFirstDefined(
  target: DemoMetadata,
  key: keyof DemoMetadata,
  value: DemoMetadata[keyof DemoMetadata] | undefined
): void {
  if (target[key] !== undefined || value === undefined) return;
  (target as Record<keyof DemoMetadata, unknown>)[key] = value;
}
