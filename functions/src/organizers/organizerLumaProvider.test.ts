import assert from "node:assert/strict";
import test from "node:test";
import {LumaProvider, LumaProviderError, OrganizerProviderCredentialStore} from
  "./organizerLumaProvider";
import {SecretVersionReferenceGuard} from "../shared/secretVersionReference";

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


test("provider reads and disables require local numbered provider secrets",
  async () => {
    const calls: string[] = [];
    const store = new OrganizerProviderCredentialStore({
      accessSecretVersion: async () => {
        calls.push("access");
        return [{payload: {data: Buffer.from("fake-api-key")}}];
      },
      disableSecretVersion: async () => {
        calls.push("disable"); return [{}];
      },
    } as never, new SecretVersionReferenceGuard(() => "local-project",
      async () => "123456"));
    const name = "organizer-provider-" + "a".repeat(32);
    const ref = `projects/local-project/secrets/${name}/versions/7`;
    for (const invalid of [ref.replace("local-project", "other-project"),
      ref.replace("local-project", "654321"), ref.replace("/7", "/latest"),
      ref.replace(name, "UNRELATED"), ref.replace(name, "organizer-provider-x"),
      ref + "\n"]) {
      await assert.rejects(store.access(invalid),
        /^Error: Secret version reference unavailable\.$/);
      await assert.rejects(store.disable(invalid),
        /^Error: Secret version reference unavailable\.$/);
    }
    assert.deepEqual(calls, []);
    assert.equal(await store.access(ref), "fake-api-key");
    await store.disable(ref.replace("local-project", "123456"));
    assert.deepEqual(calls, ["access", "disable"]);
  });
