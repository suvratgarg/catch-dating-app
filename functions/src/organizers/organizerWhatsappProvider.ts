import {SecretManagerServiceClient} from "@google-cloud/secret-manager";
import * as admin from "firebase-admin";
import {HttpsError} from "firebase-functions/v2/https";
import {OrganizerMessageTemplateDocument} from
  "../shared/generated/firestoreAdminTypes";

export interface MetaWhatsappConfig {
  appId: string;
  appSecret: string;
  configId: string;
  graphVersion: string;
}

export interface MetaPhoneMetadata {
  id: string;
  businessId: string | null;
  displayPhoneNumber: string | null;
  verifiedName: string | null;
  qualityRating: OrganizerMessageTemplateDocument["status"] | string | null;
  messagingLimitTier: string | null;
}

export interface MetaTemplateSnapshot {
  providerTemplateId: string;
  name: string;
  language: string;
  category: OrganizerMessageTemplateDocument["category"];
  status: OrganizerMessageTemplateDocument["status"];
  variableNames: string[];
  parameterBindings: Array<{
    variableName: string;
    component: "header" | "body" | "button";
    position: number;
    buttonIndex: number | null;
  }>;
  hasMediaHeader: boolean;
  buttonKinds: OrganizerMessageTemplateDocument["buttonKinds"];
}

export interface MetaSendResult {
  providerMessageId: string;
}

export class MetaProviderError extends Error {
  constructor(
    message: string,
    readonly providerCode: number | null,
    readonly httpStatus: number | null,
  ) {
    super(message);
  }
}

export class OrganizerTokenStore {
  constructor(
    private readonly client = new SecretManagerServiceClient(),
    private readonly secretId = (
      process.env.ORGANIZER_WHATSAPP_TOKEN_SECRET_ID ??
        "ORGANIZER_WHATSAPP_ACCESS_TOKENS"
    ),
  ) {}

  async store(params: {
    organizerId: string;
    connectionId: string;
    accessToken: string;
  }): Promise<string> {
    const projectId =
      process.env.GCLOUD_PROJECT ?? admin.app().options.projectId;
    if (!projectId) throw new Error("Firebase project id is unavailable.");
    const secretResource = `projects/${projectId}/secrets/${this.secretId}`;
    const credential = JSON.stringify({
      schema: "catch.organizer-whatsapp-token/v1",
      organizerId: params.organizerId,
      connectionId: params.connectionId,
      accessToken: params.accessToken,
    });
    const [version] = await this.client.addSecretVersion({
      parent: secretResource,
      payload: {data: Buffer.from(credential, "utf8")},
    });
    if (!version.name) throw new Error("Secret Manager returned no version.");
    return version.name;
  }

  async access(versionResource: string): Promise<string> {
    const [version] = await this.client.accessSecretVersion({
      name: versionResource,
    });
    const value = version.payload?.data?.toString("utf8") ?? "";
    const credential = parseStoredCredential(value);
    if (!credential.accessToken) {
      throw new Error("Organizer sender credential is empty.");
    }
    return credential.accessToken;
  }

  async disable(versionResource: string): Promise<void> {
    await this.client.disableSecretVersion({name: versionResource});
  }
}

function parseStoredCredential(value: string): {accessToken: string} {
  try {
    const parsed = JSON.parse(value) as Record<string, unknown>;
    return {
      accessToken: typeof parsed.accessToken === "string" ?
        parsed.accessToken : "",
    };
  } catch {
    // Accept the original raw-token versions during the vault migration.
    return {accessToken: value};
  }
}

/** Narrow Meta Graph adapter. Access tokens never enter logs or Firestore. */
export class MetaWhatsappProvider {
  constructor(
    private readonly config: MetaWhatsappConfig,
    private readonly fetchImpl: typeof fetch = fetch,
  ) {}

  async exchangeAuthorizationCode(code: string): Promise<string> {
    const url = this.graphUrl("oauth/access_token");
    url.searchParams.set("client_id", this.config.appId);
    url.searchParams.set("client_secret", this.config.appSecret);
    url.searchParams.set("code", code);
    const body = await this.requestJson(url, {method: "GET"});
    const accessToken = stringValue(body.access_token);
    if (!accessToken) {
      throw new MetaProviderError(
        "Meta authorization did not return an access token.",
        null,
        null,
      );
    }
    return accessToken;
  }

  async verifyAndSubscribe(params: {
    accessToken: string;
    wabaId: string;
    phoneNumberId: string;
    businessId?: string | null;
  }): Promise<MetaPhoneMetadata> {
    const waba = await this.authorizedRequest(
      params.wabaId,
      params.accessToken,
      {method: "GET", query: {fields: "id,owner_business_info"}},
    );
    const ownerBusinessId = stringValue(
      recordValue(waba.owner_business_info).id,
    );
    if (
      ownerBusinessId &&
      params.businessId &&
      ownerBusinessId !== params.businessId
    ) {
      throw new HttpsError(
        "failed-precondition",
        "The selected WhatsApp account does not belong to the selected " +
          "business.",
      );
    }
    const phoneList = await this.authorizedRequest(
      `${params.wabaId}/phone_numbers`,
      params.accessToken,
      {
        method: "GET",
        query: {fields: "id", limit: "100"},
      },
    );
    const phoneIds = arrayValue(phoneList.data).map((item) =>
      stringValue(recordValue(item).id),
    );
    if (!phoneIds.includes(params.phoneNumberId)) {
      throw new HttpsError(
        "failed-precondition",
        "The selected phone number does not belong to the selected " +
          "WhatsApp account.",
      );
    }
    await this.authorizedRequest(
      `${params.wabaId}/subscribed_apps`,
      params.accessToken,
      {method: "POST"},
    );
    const phone = await this.authorizedRequest(
      params.phoneNumberId,
      params.accessToken,
      {
        method: "GET",
        query: {
          fields:
            "id,display_phone_number,verified_name,quality_rating," +
            "messaging_limit_tier",
        },
      },
    );
    return {
      id: params.phoneNumberId,
      businessId: ownerBusinessId ?? params.businessId ?? null,
      displayPhoneNumber: stringValue(phone.display_phone_number),
      verifiedName: stringValue(phone.verified_name),
      qualityRating: stringValue(phone.quality_rating),
      messagingLimitTier: stringValue(phone.messaging_limit_tier),
    };
  }

  async listTemplates(params: {
    accessToken: string;
    wabaId: string;
  }): Promise<MetaTemplateSnapshot[]> {
    const first = this.graphUrl(`${params.wabaId}/message_templates`);
    first.searchParams.set(
      "fields",
      "id,name,language,status,category,components",
    );
    first.searchParams.set("limit", "200");
    let next: URL | null = first;
    const templates: MetaTemplateSnapshot[] = [];
    for (let page = 0; next && page < 5; page += 1) {
      const body = await this.requestJson(next, {
        method: "GET",
        headers: {Authorization: `Bearer ${params.accessToken}`},
      });
      for (const item of arrayValue(body.data)) {
        const parsed = parseTemplate(recordValue(item));
        if (parsed) templates.push(parsed);
      }
      const nextValue = stringValue(recordValue(body.paging).next);
      next = nextValue ? this.safePagingUrl(nextValue) : null;
    }
    return templates.slice(0, 200);
  }

  async sendTemplate(params: {
    accessToken: string;
    phoneNumberId: string;
    toE164: string;
    template: MetaTemplateSnapshot;
    variables: Record<string, string>;
  }): Promise<MetaSendResult> {
    const components = renderComponents(params.template, params.variables);
    const body = await this.authorizedRequest(
      `${params.phoneNumberId}/messages`,
      params.accessToken,
      {
        method: "POST",
        body: {
          messaging_product: "whatsapp",
          recipient_type: "individual",
          to: params.toE164.slice(1),
          type: "template",
          template: {
            name: params.template.name,
            language: {code: params.template.language},
            ...(components.length === 0 ? {} : {components}),
          },
        },
      },
    );
    const message = recordValue(arrayValue(body.messages)[0]);
    const providerMessageId = stringValue(message.id);
    if (!providerMessageId) {
      throw new MetaProviderError(
        "Meta accepted no message identifier.",
        null,
        null,
      );
    }
    return {providerMessageId};
  }

  async unsubscribe(params: {
    accessToken: string;
    wabaId: string;
  }): Promise<void> {
    await this.authorizedRequest(
      `${params.wabaId}/subscribed_apps`,
      params.accessToken,
      {method: "DELETE"},
    );
  }

  private async authorizedRequest(
    path: string,
    accessToken: string,
    options: {
      method: "GET" | "POST" | "DELETE";
      query?: Record<string, string>;
      body?: Record<string, unknown>;
    },
  ): Promise<Record<string, unknown>> {
    const url = this.graphUrl(path);
    for (const [key, value] of Object.entries(options.query ?? {})) {
      url.searchParams.set(key, value);
    }
    return this.requestJson(url, {
      method: options.method,
      headers: {
        Authorization: `Bearer ${accessToken}`,
        ...(options.body ? {"Content-Type": "application/json"} : {}),
      },
      ...(options.body ? {body: JSON.stringify(options.body)} : {}),
    });
  }

  private graphUrl(path: string): URL {
    return new URL(
      `https://graph.facebook.com/${this.config.graphVersion}/${path}`,
    );
  }

  private safePagingUrl(value: string): URL {
    const url = new URL(value);
    if (url.protocol !== "https:" || url.hostname !== "graph.facebook.com") {
      throw new MetaProviderError("Unsafe Meta pagination URL.", null, null);
    }
    return url;
  }

  private async requestJson(
    url: URL,
    init: RequestInit,
  ): Promise<Record<string, unknown>> {
    let response: Response;
    try {
      response = await this.fetchImpl(url, {
        ...init,
        signal: AbortSignal.timeout(15_000),
      });
    } catch (error) {
      throw new MetaProviderError(
        error instanceof Error ? error.message : "Meta request failed.",
        null,
        null,
      );
    }
    const text = await response.text();
    let body: Record<string, unknown> = {};
    try {
      body = recordValue(JSON.parse(text));
    } catch {
      // Avoid including provider bodies because they may contain credentials.
    }
    if (!response.ok || body.error) {
      const error = recordValue(body.error);
      throw new MetaProviderError(
        stringValue(error.message) ??
          `Meta request failed (${response.status}).`,
        numberValue(error.code),
        response.status,
      );
    }
    return body;
  }
}

export function metaTemplateFromDocument(
  template: OrganizerMessageTemplateDocument,
): MetaTemplateSnapshot {
  return {...template};
}

function renderComponents(
  template: MetaTemplateSnapshot,
  variables: Record<string, string>,
): Array<Record<string, unknown>> {
  const groups = new Map<string, typeof template.parameterBindings>();
  for (const binding of template.parameterBindings) {
    const key = `${binding.component}|${binding.buttonIndex ?? ""}`;
    groups.set(key, [...(groups.get(key) ?? []), binding]);
  }
  return [...groups.entries()].map(([key, bindings]) => {
    const [component, buttonIndex] = key.split("|");
    const sorted = [...bindings].sort((a, b) => a.position - b.position);
    return {
      type: component,
      ...(component === "button" ?
        {sub_type: "url", index: buttonIndex} :
        {}),
      parameters: sorted.map((binding) => ({
        type: "text",
        text: requiredVariable(variables, binding.variableName),
      })),
    };
  });
}

function requiredVariable(
  variables: Record<string, string>,
  variableName: string,
): string {
  const value = variables[variableName]?.trim();
  if (!value) {
    throw new HttpsError(
      "failed-precondition",
      `Template variable ${variableName} is missing.`,
    );
  }
  return value;
}

function parseTemplate(
  item: Record<string, unknown>,
): MetaTemplateSnapshot | null {
  const providerTemplateId = stringValue(item.id);
  const name = stringValue(item.name);
  const language = stringValue(item.language);
  if (!providerTemplateId || !name || !language) return null;
  const bindings: MetaTemplateSnapshot["parameterBindings"] = [];
  const buttonKinds: MetaTemplateSnapshot["buttonKinds"] = [];
  let hasMediaHeader = false;
  for (const rawComponent of arrayValue(item.components)) {
    const component = recordValue(rawComponent);
    const type = (stringValue(component.type) ?? "").toUpperCase();
    if (type === "HEADER" && stringValue(component.format) !== "TEXT") {
      hasMediaHeader = true;
    }
    if (type === "BUTTONS") {
      arrayValue(component.buttons).forEach((rawButton, buttonIndex) => {
        const button = recordValue(rawButton);
        const kind = normalizeButtonKind(stringValue(button.type));
        buttonKinds.push(kind);
        if (kind === "URL") {
          urlButtonParameters(button, buttonIndex).forEach(
            (variableName, position) => {
              bindings.push({
                variableName,
                component: "button",
                position,
                buttonIndex,
              });
            },
          );
        }
      });
      continue;
    }
    if (type !== "HEADER" && type !== "BODY") continue;
    const componentName = type.toLocaleLowerCase("en") as "header" | "body";
    const names = namedParameters(component.example);
    names.forEach((variableName, position) =>
      bindings.push({
        variableName,
        component: componentName,
        position,
        buttonIndex: null,
      }),
    );
  }
  const dedupedNames = [...new Set(bindings.map((item) => item.variableName))];
  return {
    providerTemplateId,
    name,
    language,
    category: normalizeCategory(stringValue(item.category)),
    status: normalizeTemplateStatus(stringValue(item.status)),
    variableNames: dedupedNames,
    parameterBindings: bindings,
    hasMediaHeader,
    buttonKinds,
  };
}

function urlButtonParameters(
  button: Record<string, unknown>,
  buttonIndex: number,
): string[] {
  const url = stringValue(button.url) ?? "";
  if (/^https:\/\/catchdates\.com\/invite\/\{\{1\}\}\/?$/u.test(url)) {
    return ["invite_token"];
  }
  const named = namedParameters(button.example);
  if (named.length > 0) return named;
  const examples = arrayValue(button.example);
  return /\{\{\d+\}\}/u.test(url) || examples.length > 0 ?
    [`button_${buttonIndex + 1}_url`] :
    [];
}

function namedParameters(value: unknown): string[] {
  const example = recordValue(value);
  const named = arrayValue(example.body_text_named_params)
    .map((item) => stringValue(recordValue(item).param_name))
    .filter((item): item is string => item !== null);
  if (named.length > 0) return named;
  const positional = arrayValue(example.body_text)[0];
  return arrayValue(positional).map((_, index) => `body_${index + 1}`);
}

function normalizeCategory(
  value: string | null,
): OrganizerMessageTemplateDocument["category"] {
  return ["MARKETING", "UTILITY", "AUTHENTICATION"].includes(value ?? "") ?
    (value as OrganizerMessageTemplateDocument["category"]) :
    "UNKNOWN";
}

function normalizeTemplateStatus(
  value: string | null,
): OrganizerMessageTemplateDocument["status"] {
  return [
    "APPROVED",
    "PENDING",
    "REJECTED",
    "PAUSED",
    "DISABLED",
    "DELETED",
  ].includes(value ?? "") ?
    (value as OrganizerMessageTemplateDocument["status"]) :
    "UNKNOWN";
}

function normalizeButtonKind(
  value: string | null,
): OrganizerMessageTemplateDocument["buttonKinds"][number] {
  return ["URL", "PHONE_NUMBER", "QUICK_REPLY", "COPY_CODE"].includes(
    value ?? "",
  ) ?
    (value as OrganizerMessageTemplateDocument["buttonKinds"][number]) :
    "UNKNOWN";
}

function recordValue(value: unknown): Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value) ?
    (value as Record<string, unknown>) :
    {};
}

function arrayValue(value: unknown): unknown[] {
  return Array.isArray(value) ? value : [];
}

function stringValue(value: unknown): string | null {
  return typeof value === "string" && value.length > 0 ? value : null;
}

function numberValue(value: unknown): number | null {
  return typeof value === "number" && Number.isFinite(value) ? value : null;
}
