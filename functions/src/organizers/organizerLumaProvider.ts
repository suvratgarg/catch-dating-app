import {SecretManagerServiceClient} from "@google-cloud/secret-manager";
import {createHash} from "node:crypto";
import * as admin from "firebase-admin";

export interface LumaCalendar {
  id: string;
  name: string;
}

export interface LumaEvent {
  id: string;
  name: string;
}

export interface LumaEventChoice extends LumaEvent {
  startAt: string;
}

export interface LumaEventPage {
  entries: LumaEventChoice[];
  hasMore: boolean;
  nextCursor: string | null;
}

export interface LumaGuest {
  id: string;
  displayName: string;
  phone: string | null;
  email: string | null;
  approvalStatus:
    "approved" | "session" | "pending_approval" | "invited" |
    "declined" | "waitlist";
  registeredAt: string | null;
  checkedInAt: string | null;
  ticketType: string | null;
}

export interface LumaGuestPage {
  entries: LumaGuest[];
  hasMore: boolean;
  nextCursor: string | null;
}

export class LumaProviderError extends Error {
  constructor(
    message: string,
    readonly status: number | null,
    readonly code: "unauthorized" | "notFound" | "rateLimited" | "invalid",
  ) {
    super(message);
  }
}

export class OrganizerProviderCredentialStore {
  constructor(private readonly client = new SecretManagerServiceClient()) {}

  async store(params: {
    organizerId: string;
    connectionId: string;
    credential: string;
  }): Promise<string> {
    const projectId = process.env.GCLOUD_PROJECT ??
      admin.app().options.projectId;
    if (!projectId) throw new Error("Firebase project id is unavailable.");
    const parent = `projects/${projectId}`;
    const secretId = `organizer-provider-${createHash("sha256")
      .update(`${params.organizerId}|${params.connectionId}`)
      .digest("hex").slice(0, 32)}`;
    try {
      await this.client.createSecret({
        parent,
        secretId,
        secret: {replication: {automatic: {}}},
      });
    } catch (error) {
      if (grpcCode(error) !== 6) throw error;
    }
    const [version] = await this.client.addSecretVersion({
      parent: `${parent}/secrets/${secretId}`,
      payload: {data: Buffer.from(params.credential, "utf8")},
    });
    if (!version.name) throw new Error("Secret Manager returned no version.");
    return version.name;
  }

  async access(versionResource: string): Promise<string> {
    const [version] = await this.client.accessSecretVersion({
      name: versionResource,
    });
    const value = version.payload?.data?.toString("utf8") ?? "";
    if (!value) throw new Error("Organizer provider credential is empty.");
    return value;
  }

  async disable(versionResource: string): Promise<void> {
    await this.client.disableSecretVersion({name: versionResource});
  }
}

export class LumaProvider {
  constructor(
    private readonly fetchImpl: typeof fetch = fetch,
    private readonly baseUrl = "https://public-api.luma.com",
  ) {}

  async getCalendar(apiKey: string): Promise<LumaCalendar> {
    const body = await this.getJson("/v1/calendars/get", apiKey);
    return {
      id: requiredString(body.id, "calendar id"),
      name: requiredString(body.name, "calendar name"),
    };
  }

  async getEvent(apiKey: string, eventId: string): Promise<LumaEvent> {
    const body = await this.getJson("/v1/events/get", apiKey, {
      event_id: eventId,
    });
    const event = record(body.event) ?? body;
    if (event.platform !== "luma" || event.access !== "manage") {
      throw new LumaProviderError(
        "The Luma calendar cannot manage this event.", null, "unauthorized"
      );
    }
    return {
      id: requiredString(event.id, "event id"),
      name: requiredString(event.name, "event name"),
    };
  }

  async listEvents(params: {
    apiKey: string;
    cursor?: string | null;
    limit?: number;
  }): Promise<LumaEventPage> {
    const body = await this.getJson(
      "/v1/calendars/events/list",
      params.apiKey,
      {
        pagination_limit: String(params.limit ?? 50),
        sort_column: "start_at",
        sort_direction: "desc",
        ...(params.cursor ? {pagination_cursor: params.cursor} : {}),
      },
    );
    if (!Array.isArray(body.entries) || typeof body.has_more !== "boolean") {
      throw new LumaProviderError(
        "Luma returned an invalid event page.", null, "invalid"
      );
    }
    const entries = body.entries.map((value) => {
      const event = record(value);
      if (!event || event.platform !== "luma" || event.access !== "manage") {
        throw new LumaProviderError(
          "Luma returned an event Catch cannot manage.", null, "invalid"
        );
      }
      return {
        id: requiredString(event.id, "event id"),
        name: requiredString(event.name, "event name"),
        startAt: requiredString(event.start_at, "event start time"),
      };
    });
    const nextCursor = nullableString(body.next_cursor);
    if (body.has_more && !nextCursor) {
      throw new LumaProviderError(
        "Luma returned a paginated page without a cursor.", null, "invalid"
      );
    }
    return {entries, hasMore: body.has_more, nextCursor};
  }

  async listGuests(params: {
    apiKey: string;
    eventId: string;
    cursor?: string | null;
    limit?: number;
  }): Promise<LumaGuestPage> {
    const body = await this.getJson("/v1/events/guests/list", params.apiKey, {
      event_id: params.eventId,
      pagination_limit: String(params.limit ?? 100),
      ...(params.cursor ? {pagination_cursor: params.cursor} : {}),
    });
    if (!Array.isArray(body.entries) || typeof body.has_more !== "boolean") {
      throw new LumaProviderError(
        "Luma returned an invalid guest page.", null, "invalid"
      );
    }
    const entries = body.entries.map(parseGuest);
    const nextCursor = nullableString(body.next_cursor);
    if (body.has_more && !nextCursor) {
      throw new LumaProviderError(
        "Luma returned a paginated page without a cursor.", null, "invalid"
      );
    }
    return {entries, hasMore: body.has_more, nextCursor};
  }

  private async getJson(
    path: string,
    apiKey: string,
    query: Record<string, string> = {},
  ): Promise<Record<string, unknown>> {
    const url = new URL(path, this.baseUrl);
    for (const [key, value] of Object.entries(query)) {
      url.searchParams.set(key, value);
    }
    const response = await this.fetchImpl(url, {
      headers: {"x-luma-api-key": apiKey, "accept": "application/json"},
    });
    if (!response.ok) {
      const code = response.status === 401 || response.status === 403 ?
        "unauthorized" : response.status === 404 ? "notFound" :
          response.status === 429 ? "rateLimited" : "invalid";
      throw new LumaProviderError(
        `Luma request failed (${response.status}).`, response.status, code
      );
    }
    const value: unknown = await response.json();
    const result = record(value);
    if (!result) {
      throw new LumaProviderError(
        "Luma returned a non-object response.", response.status, "invalid"
      );
    }
    return result;
  }
}

function parseGuest(value: unknown): LumaGuest {
  const guest = record(value);
  if (!guest) {
    throw new LumaProviderError(
      "Luma returned an invalid guest.", null, "invalid"
    );
  }
  const approvalStatus = requiredString(
    guest.approval_status, "guest approval status"
  );
  if (![
    "approved", "session", "pending_approval", "invited", "declined",
    "waitlist",
  ].includes(approvalStatus)) {
    throw new LumaProviderError(
      "Luma returned an unsupported guest status.", null, "invalid"
    );
  }
  const tickets = Array.isArray(guest.event_tickets) ?
    guest.event_tickets.map(record).filter(isRecord) : [];
  const checkedInAt = tickets.map((ticket) => nullableString(
    ticket.checked_in_at
  )).find((value) => value !== null) ?? null;
  const ticketType = tickets.map((ticket) => nullableString(ticket.name))
    .find((value) => value !== null) ?? null;
  const email = nullableString(guest.user_email)?.toLowerCase() ?? null;
  const componentName = [
    nullableString(guest.user_first_name), nullableString(guest.user_last_name),
  ].filter((part): part is string => part !== null).join(" ");
  const fallbackName = componentName || email?.split("@")[0] || "Luma guest";
  const displayName = nullableString(guest.user_name) ?? fallbackName;
  return {
    id: requiredString(guest.id, "guest id"),
    displayName: displayName.trim().slice(0, 120),
    phone: nullableString(guest.phone_number),
    email,
    approvalStatus: approvalStatus as LumaGuest["approvalStatus"],
    registeredAt: nullableString(guest.registered_at),
    checkedInAt,
    ticketType,
  };
}

function record(value: unknown): Record<string, unknown> | null {
  return typeof value === "object" && value !== null && !Array.isArray(value) ?
    value as Record<string, unknown> : null;
}

function isRecord(
  value: Record<string, unknown> | null
): value is Record<string, unknown> {
  return value !== null;
}

function requiredString(value: unknown, label: string): string {
  const result = nullableString(value);
  if (!result) {
    throw new LumaProviderError(`Luma omitted ${label}.`, null, "invalid");
  }
  return result;
}

function nullableString(value: unknown): string | null {
  return typeof value === "string" && value.trim() ? value.trim() : null;
}

function grpcCode(error: unknown): number | null {
  if (typeof error !== "object" || error === null || !("code" in error)) {
    return null;
  }
  return typeof error.code === "number" ? error.code : null;
}
