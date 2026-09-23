/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Operational vendor picker data: id, name and program binding only. Contact and commercial fields stay on manager surfaces.
 */
export interface TransportVendorListCallableResponse {
  /**
   * @maxItems 100
   */
  vendors: {
    vendorId: string;
    name: string;
    active: boolean;
    boundToProgram: boolean;
  }[];
}
