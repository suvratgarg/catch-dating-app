import {SALES_ACTION_SCHEMAS, SALES_READ_SCHEMAS} from
  "../admin/sales/schemas";
import {ASSISTANT_ACTIONS, READ_ACTIONS} from "./actions";

const actionPaths = Object.fromEntries(ASSISTANT_ACTIONS.map((action) => {
  const read = READ_ACTIONS.includes(action as typeof READ_ACTIONS[number]);
  const schema = read ? SALES_READ_SCHEMAS[
    action as keyof typeof SALES_READ_SCHEMAS] : SALES_ACTION_SCHEMAS[
    action as keyof typeof SALES_ACTION_SCHEMAS];
  return [`/v1/actions/${action}`, {post: {
    operationId: action.replace(".", "_"),
    security: [{clientBearer: []}],
    description: "Requires a live delegation containing the exact action, " +
      "explicit host IDs, optional private field IDs, expiry, and budgets. " +
      "Mutations require a stable requestId for receipt replay.",
    parameters: [
      {in: "header", name: "X-Assistant-Client-ID", required: true,
        schema: {type: "string"}},
      {in: "header", name: "X-Assistant-Delegation-ID", required: true,
        schema: {type: "string"}},
    ],
    requestBody: {required: true, content: {"application/json": {schema}}},
    responses: {
      "200": {description: "Shared sales service result or receipt"},
      "400": {description: "Invalid payload"},
      "401": {description: "Missing or invalid Firebase client identity"},
      "403": {description: "Current authority or scope denied"},
      "409": {description: "Revision or request material conflict"},
      "429": {description: "Delegation budget exceeded"},
    },
  }}];
}));

/** Public protocol shape; authorization still gates every business call. */
export const SALES_ASSISTANT_OPENAPI = {
  openapi: "3.1.0",
  info: {title: "Catch Sales Assistant API", version: "1.0.0",
    description: "Bounded sales actions for approved delegated assistants. " +
      "Client vendor connectivity requires separate verification. Client " +
      "Firebase ID tokens must be renewed before expiry. The employee token " +
      "is never supplied to the external client."},
  servers: [{url: "/"}],
  paths: {
    "/v1/openapi.json": {get: {operationId: "describeSalesAssistantApi",
      responses: {"200": {description: "OpenAPI description"}}}},
    ...actionPaths,
    "/v1/clients/{clientId}": {get: {
      operationId: "getSalesAssistantClient",
      security: [{ownerBearer: []}],
      parameters: [{in: "path", name: "clientId", required: true,
        schema: {type: "string"}}],
      responses: {"200": {description: "Exact client state"}},
    }, put: {
      operationId: "registerSalesAssistantClient",
      security: [{ownerBearer: []}],
      description: "Admin Owner binds an existing non-admin Firebase Auth UID.",
      parameters: [{in: "path", name: "clientId", required: true,
        schema: {type: "string"}}],
      requestBody: {required: true, content: {"application/json": {schema: {
        type: "object", additionalProperties: false,
        required: ["requestId", "expectedRevision", "authUid", "active"],
        properties: {requestId: {type: "string"},
          expectedRevision: {type: "integer", minimum: 0},
          authUid: {type: "string"}, active: {type: "boolean"}},
      }}}},
      responses: {"200": {description: "Client registration"}},
    }},
    "/v1/delegations": {post: {
      operationId: "issueSalesAssistantDelegation",
      security: [{ownerBearer: []}],
      description: "Admin Owner issues a bounded, expiring delegation.",
      requestBody: {required: true, content: {"application/json": {schema: {
        type: "object", additionalProperties: false,
        required: ["requestId", "expectedRevision", "delegationId",
          "actorUid", "clientId",
          "allowedActions", "organizerIds", "expiresAt",
          "maxRequestsPerMinute", "maxRequestsPerDay"],
        properties: {
          requestId: {type: "string"},
          expectedRevision: {const: 0},
          delegationId: {type: "string"}, actorUid: {type: "string"},
          clientId: {type: "string"},
          allowedActions: {type: "array", uniqueItems: true,
            items: {type: "string", enum: ASSISTANT_ACTIONS}},
          organizerIds: {type: "array", minItems: 1, maxItems: 30,
            uniqueItems: true, items: {type: "string"}},
          fieldIds: {type: "array", maxItems: 50, uniqueItems: true,
            items: {type: "string", pattern: "^sales\\."}},
          expiresAt: {type: "string", format: "date-time"},
          maxRequestsPerMinute: {type: "integer", minimum: 1, maximum: 60},
          maxRequestsPerDay: {type: "integer", minimum: 1, maximum: 1000},
        },
      }}}},
      responses: {"200": {description: "Delegation issued"}},
    }},
    "/v1/delegations/{delegationId}": {get: {
      operationId: "getSalesAssistantDelegation",
      security: [{ownerBearer: []}],
      parameters: [{in: "path", name: "delegationId", required: true,
        schema: {type: "string"}}],
      responses: {"200": {description: "Exact delegation state"}},
    }},
    "/v1/delegations/{delegationId}/revoke": {post: {
      operationId: "revokeSalesAssistantDelegation",
      security: [{ownerBearer: []}],
      parameters: [{in: "path", name: "delegationId", required: true,
        schema: {type: "string"}}],
      requestBody: {required: true, content: {"application/json": {schema: {
        type: "object", additionalProperties: false,
        required: ["requestId", "expectedRevision"],
        properties: {requestId: {type: "string"},
          expectedRevision: {type: "integer", minimum: 1}},
      }}}},
      responses: {"200": {description: "Delegation revoked"}},
    }},
    "/v1/management/receipts/{requestId}": {get: {
      operationId: "getSalesAssistantManagementReceipt",
      security: [{ownerBearer: []}],
      parameters: [{in: "path", name: "requestId", required: true,
        schema: {type: "string"}}],
      responses: {"200": {description: "Owner's exact management receipt"}},
    }},
  },
  components: {securitySchemes: {
    ownerBearer: {type: "http", scheme: "bearer",
      bearerFormat: "Firebase admin owner ID token"},
    clientBearer: {type: "http", scheme: "bearer",
      bearerFormat: "Firebase registered client ID token"},
  }},
} as const;
