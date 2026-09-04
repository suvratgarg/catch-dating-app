/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerCampaignActionCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/organizer_campaign_action_payload.schema.json",
  "title": "OrganizerCampaignActionCallablePayload",
  "description": "Revision-bound campaign preview, approval, dispatch, cancellation or report request.",
  "x-callable-aliases": [
    "previewOrganizerCampaign",
    "approveOrganizerCampaign",
    "dispatchOrganizerCampaign",
    "cancelOrganizerCampaign",
    "getOrganizerCampaignReport"
  ],
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "campaignId"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "campaignId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "expectedRevision": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 1,
      "maximum": 9007199254740991
    }
  }
} as const;
