/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import type {OutreachDraftingSelection} from "./outreachDraftingSelection";

/**
 * Private internal writing preparation intent and validated result. One immutable identity per job/stage survives lease renewal and crashes. No rendered draft, activation or send authority. Privacy deletion requires the permanent processing fence.
 */
export type SalesProviderAttemptDocument = {
  [k: string]: unknown;
} & {
  schemaVersion: 1;
  classification: "sales_private";
  attemptId: string;
  jobId: string;
  actorUid: string;
  organizerId: string;
  stage: "writing";
  bindingHash: string;
  binding: {
    materialHash: string;
    sourceHash: string;
    publicMaterialHash: string;
    policyHash: string;
    stageHash: string;
    providerId: "deepseek" | "openai" | "anthropic";
    modelId: string;
    promptVersion: string;
    ownerUid: string;
    authorizationId: string;
    publicReviewId: string;
    participantScope: {
      partnerUid: string;
      assignmentRevision: number;
    } | null;
    runLimitsHash: string;
    monthlyLimitsHash: string;
    inputTokenCeiling: number;
  };
  status: "intent" | "completed";
  submissionNonce: string;
  leaseOwner: string;
  month: string;
  runBucketId: string;
  monthlyBucketId: string;
  reservation: {
    modelCalls: number;
    networkRequests: number;
    modelInputTokens: number;
    modelOutputTokens: number;
    modelCostMicros: number;
  };
  createdAt: string;
  updatedAt: string;
  cache: {
    schemaVersion: 1;
    output: {
      observationAlias: string | null;
      capabilityAlias: string | null;
      referenceAlias: string | null;
      ctaAlias: string | null;
      reasonToBlock: string | null;
      /**
       * @maxItems 100
       */
      omittedAliases: string[];
    };
    provenance: {
      task: string;
      promptVersion: string;
      modelId: string;
      providerId: "deepseek" | "openai" | "anthropic";
      cacheKey: string;
      cacheHit: false;
      usage: {
        inputTokens: number;
        outputTokens: number;
        costMicros: number;
      };
      metadata: {
        providerId: "deepseek" | "openai" | "anthropic";
        modelId: string;
        requestId: string | null;
        attemptCount: 1;
        durationMs: number;
        finishReason: "stop";
        costBasis: "reserved_ceiling";
        estimatedCostMicros: null;
        tokens: {
          inputTotal: number;
          ordinaryInput: number | null;
          cacheRead: number | null;
          cacheWrite: number | null;
          outputTotal: number;
          reasoningOutput: number | null;
        };
      };
      request: {
        maxInputBytes: 32768;
        estimatedInputTokens: number;
        maxOutputTokens: number;
        maxCostMicros: number;
        maxNetworkRequests: 1;
      };
      monthlyWindow: string;
    };
  } | null;
  result: {
    selection: OutreachDraftingSelection;
    selectionHash: string;
    policyHash: string;
    stageHash: string;
    authorizationId: string;
    stage: "writing";
    sendAuthority: false;
  } | null;
};
