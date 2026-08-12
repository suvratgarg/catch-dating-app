import assert from "node:assert/strict";
import test from "node:test";
import {LumaProvider, LumaProviderError} from "./organizerLumaProvider";

test("verifies calendar and event with a server-side key", async () => {
  const seen: Array<{url: URL; key: string | null}> = [];
  const provider = new LumaProvider(async (input, init) => {
    const url = new URL(input.toString());
    seen.push({
      url,
      key: new Headers(init?.headers).get("x-luma-api-key"),
    });
    if (url.pathname === "/v1/calendars/get") {
      return jsonResponse({id: "cal-1", name: "Sunday Club"});
    }
    return jsonResponse({event: {
      platform: "luma",
      access: "manage",
      id: "evt-1",
      name: "Sunday Social",
    }});
  }, "https://luma.test");

  assert.deepEqual(await provider.getCalendar("secret-key"), {
    id: "cal-1",
    name: "Sunday Club",
  });
  assert.deepEqual(await provider.getEvent("secret-key", "evt-1"), {
    id: "evt-1",
    name: "Sunday Social",
  });
  assert.equal(seen[0].key, "secret-key");
  assert.equal(seen[1].url.searchParams.get("event_id"), "evt-1");
});

test("parses guest identity, ticket and check-in evidence", async () => {
  const provider = new LumaProvider(async () => jsonResponse({
    entries: [{
      id: "gst-1",
      user_email: "ASHA@EXAMPLE.COM",
      user_name: null,
      user_first_name: "Asha",
      user_last_name: "Shah",
      phone_number: "+919876543210",
      approval_status: "approved",
      registered_at: "2026-08-12T08:00:00.000Z",
      event_tickets: [{
        id: "ticket-1",
        name: "General",
        checked_in_at: "2026-08-12T10:00:00.000Z",
      }],
    }],
    has_more: false,
    next_cursor: "",
  }), "https://luma.test");

  const page = await provider.listGuests({
    apiKey: "secret-key",
    eventId: "evt-1",
  });
  assert.deepEqual(page, {
    entries: [{
      id: "gst-1",
      displayName: "Asha Shah",
      phone: "+919876543210",
      email: "asha@example.com",
      approvalStatus: "approved",
      registeredAt: "2026-08-12T08:00:00.000Z",
      checkedInAt: "2026-08-12T10:00:00.000Z",
      ticketType: "General",
    }],
    hasMore: false,
    nextCursor: null,
  });
});

test("lists only manageable Luma events as selection choices", async () => {
  const provider = new LumaProvider(async () => jsonResponse({
    entries: [{
      platform: "luma",
      access: "manage",
      id: "evt-1",
      name: "Sunday Social",
      start_at: "2026-08-16T12:00:00.000Z",
    }],
    has_more: false,
  }), "https://luma.test");

  assert.deepEqual(await provider.listEvents({apiKey: "secret-key"}), {
    entries: [{
      id: "evt-1",
      name: "Sunday Social",
      startAt: "2026-08-16T12:00:00.000Z",
    }],
    hasMore: false,
    nextCursor: null,
  });
});

test("rejects malformed pagination without losing unseen guests", async () => {
  const provider = new LumaProvider(async () => jsonResponse({
    entries: [],
    has_more: true,
  }), "https://luma.test");
  await assert.rejects(
    provider.listGuests({apiKey: "secret-key", eventId: "evt-1"}),
    (error: unknown) => error instanceof LumaProviderError &&
      /without a cursor/.test(error.message),
  );
});

test("sanitizes provider authentication errors", async () => {
  const provider = new LumaProvider(async () => jsonResponse(
    {message: "secret provider response"}, 401
  ), "https://luma.test");
  await assert.rejects(
    provider.getCalendar("secret-key"),
    (error: unknown) => error instanceof LumaProviderError &&
      error.code === "unauthorized" &&
      !error.message.includes("secret provider response"),
  );
});

test("rejects events without calendar management authority", async () => {
  const provider = new LumaProvider(async () => jsonResponse({event: {
    platform: "luma",
    access: "view",
    id: "evt-public",
    name: "Another host's event",
  }}), "https://luma.test");
  await assert.rejects(
    provider.getEvent("secret-key", "evt-public"),
    (error: unknown) => error instanceof LumaProviderError &&
      error.code === "unauthorized",
  );
});

function jsonResponse(value: unknown, status = 200): Response {
  return new Response(JSON.stringify(value), {
    status,
    headers: {"content-type": "application/json"},
  });
}
