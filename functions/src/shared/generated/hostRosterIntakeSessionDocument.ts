/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private resumable Host review state for one existing event roster upload.
 */
export interface HostRosterIntakeSessionDocument {
  draft: {
    sessionId: string;
    hostUid: string;
    organizerId: string;
    eventId: string;
    fileFingerprint: string;
    fileName: string;
    format: "csv" | "xlsx";
    /**
     * @minItems 1
     * @maxItems 40
     */
    headers: string[];
    mapping: {
      displayName?: number;
      phone?: number;
      email?: number;
      city?: number;
      externalReference?: number;
      arrivalGroup?: number;
      ticketType?: number;
      revenueAmount?: number;
      revenueCurrency?: number;
      status?: number;
    };
    /**
     * @minItems 1
     * @maxItems 250
     */
    sourceManifest: {
      rowId: string;
      sourceRowNumber: number;
      rawEvidenceHash: string;
      originalValue: {
        rowId: string;
        displayName: string;
        phone?: string | null;
        email?: string | null;
        cityMarketId?: string | null;
        externalReference?: string | null;
        arrivalGroup?: string | null;
        ticketType?: string | null;
        revenueAmountMinor?: number | null;
        revenueCurrency?: string | null;
        revenueSource?: "hostImport" | "hostEstimate" | null;
        status: "invited" | "registered" | "waitlisted";
      };
      originalFields: {
        displayName?: {
          column: number;
          header: string;
          origin: "upload" | "hostCorrection" | "modelProposal";
          confidence: number | null;
        };
        phone?: {
          column: number;
          header: string;
          origin: "upload" | "hostCorrection" | "modelProposal";
          confidence: number | null;
        };
        email?: {
          column: number;
          header: string;
          origin: "upload" | "hostCorrection" | "modelProposal";
          confidence: number | null;
        };
        cityMarketId?: {
          column: number;
          header: string;
          origin: "upload" | "hostCorrection" | "modelProposal";
          confidence: number | null;
        };
        externalReference?: {
          column: number;
          header: string;
          origin: "upload" | "hostCorrection" | "modelProposal";
          confidence: number | null;
        };
        arrivalGroup?: {
          column: number;
          header: string;
          origin: "upload" | "hostCorrection" | "modelProposal";
          confidence: number | null;
        };
        ticketType?: {
          column: number;
          header: string;
          origin: "upload" | "hostCorrection" | "modelProposal";
          confidence: number | null;
        };
        revenueAmountMinor?: {
          column: number;
          header: string;
          origin: "upload" | "hostCorrection" | "modelProposal";
          confidence: number | null;
        };
        revenueCurrency?: {
          column: number;
          header: string;
          origin: "upload" | "hostCorrection" | "modelProposal";
          confidence: number | null;
        };
        revenueSource?: {
          column: number;
          header: string;
          origin: "upload" | "hostCorrection" | "modelProposal";
          confidence: number | null;
        };
        status?: {
          column: number;
          header: string;
          origin: "upload" | "hostCorrection" | "modelProposal";
          confidence: number | null;
        };
      };
    }[];
    revision: number;
    state: "review" | "applied";
    /**
     * @minItems 1
     * @maxItems 250
     */
    rows: {
      value: {
        rowId: string;
        displayName: string;
        phone?: string | null;
        email?: string | null;
        cityMarketId?: string | null;
        externalReference?: string | null;
        arrivalGroup?: string | null;
        ticketType?: string | null;
        revenueAmountMinor?: number | null;
        revenueCurrency?: string | null;
        revenueSource?: "hostImport" | "hostEstimate" | null;
        status: "invited" | "registered" | "waitlisted";
      };
      sourceRowNumber: number;
      fields: {
        displayName?: {
          column: number;
          header: string;
          origin: "upload" | "hostCorrection" | "modelProposal";
          confidence: number | null;
        };
        phone?: {
          column: number;
          header: string;
          origin: "upload" | "hostCorrection" | "modelProposal";
          confidence: number | null;
        };
        email?: {
          column: number;
          header: string;
          origin: "upload" | "hostCorrection" | "modelProposal";
          confidence: number | null;
        };
        cityMarketId?: {
          column: number;
          header: string;
          origin: "upload" | "hostCorrection" | "modelProposal";
          confidence: number | null;
        };
        externalReference?: {
          column: number;
          header: string;
          origin: "upload" | "hostCorrection" | "modelProposal";
          confidence: number | null;
        };
        arrivalGroup?: {
          column: number;
          header: string;
          origin: "upload" | "hostCorrection" | "modelProposal";
          confidence: number | null;
        };
        ticketType?: {
          column: number;
          header: string;
          origin: "upload" | "hostCorrection" | "modelProposal";
          confidence: number | null;
        };
        revenueAmountMinor?: {
          column: number;
          header: string;
          origin: "upload" | "hostCorrection" | "modelProposal";
          confidence: number | null;
        };
        revenueCurrency?: {
          column: number;
          header: string;
          origin: "upload" | "hostCorrection" | "modelProposal";
          confidence: number | null;
        };
        revenueSource?: {
          column: number;
          header: string;
          origin: "upload" | "hostCorrection" | "modelProposal";
          confidence: number | null;
        };
        status?: {
          column: number;
          header: string;
          origin: "upload" | "hostCorrection" | "modelProposal";
          confidence: number | null;
        };
      };
      /**
       * @maxItems 40
       */
      rawCells?: string[];
      /**
       * @maxItems 10
       */
      issues?: string[];
    }[];
    /**
     * @maxItems 250
     */
    excludedRowIds: string[];
    appliedImportId: string | null;
  };
  createdAtMillis: number;
  updatedAtMillis: number;
}
