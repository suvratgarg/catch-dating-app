import assert from "node:assert/strict";
import test from "node:test";
import {
  MetaWhatsappProvider,
  MetaProviderError,
  OrganizerTokenStore,
} from "./organizerWhatsappProvider";

const config = {
  appId: "app-id",
  appSecret: "app-secret",
  configId: "config-id",
  graphVersion: "v23.0",
};

test("authorization exchange keeps credentials in server request", async () => {
  let requestedUrl = "";
  const provider = new MetaWhatsappProvider(config, async (input) => {
    requestedUrl = input.toString();
    return new Response(JSON.stringify({access_token: "token-1"}), {
      status: 200,
    });
  });
  assert.equal(await provider.exchangeAuthorizationCode("code-1"), "token-1");
  const requested = new URL(requestedUrl);
  assert.equal(requested.hostname, "graph.facebook.com");
  assert.equal(requested.searchParams.get("client_secret"), "app-secret");
  assert.equal(requested.searchParams.get("code"), "code-1");
});

test("sender verification rejects a phone outside selected WABA", async () => {
  const provider = new MetaWhatsappProvider(config, async (input) => {
    const url = new URL(input.toString());
    if (url.pathname.endsWith("/waba-1")) {
      return jsonResponse({owner_business_info: {id: "business-1"}});
    }
    if (url.pathname.endsWith("/waba-1/phone_numbers")) {
      return jsonResponse({data: [{id: "phone-other"}]});
    }
    throw new Error(`Unexpected URL ${url.toString()}`);
  });
  await assert.rejects(
    provider.verifyAndSubscribe({
      accessToken: "token",
      wabaId: "waba-1",
      phoneNumberId: "phone-1",
      businessId: "business-1",
    }),
    /does not belong/,
  );
});

test("templates preserve named parameter bindings for sending", async () => {
  const requests: Array<{ url: URL; init?: RequestInit }> = [];
  const provider = new MetaWhatsappProvider(config, async (input, init) => {
    const url = new URL(input.toString());
    requests.push({url, init});
    if (url.pathname.endsWith("/message_templates")) {
      return jsonResponse({
        data: [
          {
            id: "template-provider-1",
            name: "event_invite",
            language: "en_US",
            category: "MARKETING",
            status: "APPROVED",
            components: [
              {
                type: "BODY",
                example: {
                  body_text_named_params: [
                    {param_name: "first_name"},
                    {param_name: "invite_url"},
                  ],
                },
              },
            ],
          },
        ],
      });
    }
    return jsonResponse({messages: [{id: "wamid.1"}]});
  });
  const templates = await provider.listTemplates({
    accessToken: "token",
    wabaId: "waba-1",
  });
  assert.deepEqual(templates[0].variableNames, ["first_name", "invite_url"]);
  assert.deepEqual(
    templates[0].parameterBindings.map((item) => ({
      name: item.variableName,
      position: item.position,
    })),
    [
      {name: "first_name", position: 0},
      {name: "invite_url", position: 1},
    ],
  );
  const sent = await provider.sendTemplate({
    accessToken: "token",
    phoneNumberId: "phone-1",
    toE164: "+919999999999",
    template: templates[0],
    variables: {
      first_name: "Maya",
      invite_url: "https://catchdates.com/events/e1?il=token",
    },
  });
  assert.equal(sent.providerMessageId, "wamid.1");
  const payload = JSON.parse(String(requests.at(-1)?.init?.body));
  assert.equal(payload.to, "919999999999");
  assert.deepEqual(payload.template.components[0].parameters, [
    {type: "text", text: "Maya"},
    {type: "text", text: "https://catchdates.com/events/e1?il=token"},
  ]);
});

test("dynamic URL buttons bind only the provider URL suffix", async () => {
  const requests: Array<{ url: URL; init?: RequestInit }> = [];
  const provider = new MetaWhatsappProvider(config, async (input, init) => {
    const url = new URL(input.toString());
    requests.push({url, init});
    if (url.pathname.endsWith("/message_templates")) {
      return jsonResponse({
        data: [
          {
            id: "template-provider-2",
            name: "event_invite_button",
            language: "en_US",
            category: "MARKETING",
            status: "APPROVED",
            components: [
              {
                type: "BUTTONS",
                buttons: [
                  {
                    type: "URL",
                    url: "https://catchdates.com/invite/{{1}}",
                    example: ["example-token"],
                  },
                ],
              },
            ],
          },
        ],
      });
    }
    return jsonResponse({messages: [{id: "wamid.2"}]});
  });
  const [template] = await provider.listTemplates({
    accessToken: "token",
    wabaId: "waba-1",
  });
  assert.deepEqual(template.variableNames, ["invite_token"]);
  assert.deepEqual(template.parameterBindings, [
    {
      variableName: "invite_token",
      component: "button",
      position: 0,
      buttonIndex: 0,
    },
  ]);
  await provider.sendTemplate({
    accessToken: "token",
    phoneNumberId: "phone-1",
    toE164: "+919999999999",
    template,
    variables: {invite_token: "v2_invite_token"},
  });
  const payload = JSON.parse(String(requests.at(-1)?.init?.body));
  assert.deepEqual(payload.template.components, [
    {
      type: "button",
      sub_type: "url",
      index: "0",
      parameters: [{type: "text", text: "v2_invite_token"}],
    },
  ]);
});

test("service-window replies use the free-form text endpoint", async () => {
  let payload: Record<string, unknown> = {};
  const provider = new MetaWhatsappProvider(config, async (_input, init) => {
    payload = JSON.parse(String(init?.body));
    return jsonResponse({messages: [{id: "wamid.reply-1"}]});
  });
  const result = await provider.sendText({
    accessToken: "token",
    phoneNumberId: "phone-1",
    toE164: "+919999999999",
    body: "See you there",
  });

  assert.equal(result.providerMessageId, "wamid.reply-1");
  assert.equal(payload.type, "text");
  assert.deepEqual(payload.text, {
    preview_url: false,
    body: "See you there",
  });
});

test(
  "non-Catch dynamic URL buttons are never treated as invite links",
  async () => {
    const provider = new MetaWhatsappProvider(config, async (input) => {
      const url = new URL(input.toString());
      assert.ok(url.pathname.endsWith("/message_templates"));
      return jsonResponse({
        data: [
          {
            id: "template-provider-3",
            name: "provider_receipt",
            language: "en_US",
            category: "UTILITY",
            status: "APPROVED",
            components: [
              {
                type: "BUTTONS",
                buttons: [
                  {
                    type: "URL",
                    url: "https://tickets.example/receipt/{{1}}",
                    example: ["receipt-1"],
                  },
                ],
              },
            ],
          },
        ],
      });
    });
    const [template] = await provider.listTemplates({
      accessToken: "token",
      wabaId: "waba-1",
    });
    assert.deepEqual(template.variableNames, ["button_1_url"]);
  }
);

test("provider errors are sanitized into typed failures", async () => {
  const provider = new MetaWhatsappProvider(
    config,
    async () =>
      new Response(
        JSON.stringify({
          error: {message: "Template paused", code: 132015},
        }),
        {status: 400},
      ),
  );
  await assert.rejects(
    provider.listTemplates({
      accessToken: "token",
      wabaId: "waba-1",
    }),
    (error: unknown) =>
      error instanceof MetaProviderError &&
      error.providerCode === 132015 &&
      error.httpStatus === 400,
  );
});

test("organizer tokens use a pre-provisioned versioned vault", async () => {
  const calls: Array<{method: string; value: unknown}> = [];
  const client = {
    addSecretVersion: async (value: unknown) => {
      calls.push({method: "add", value});
      return [{
        name: "projects/project-1/secrets/ORGANIZER_WHATSAPP_ACCESS_TOKENS/" +
          "versions/7",
      }];
    },
    accessSecretVersion: async (value: unknown) => {
      calls.push({method: "access", value});
      return [{payload: {data: Buffer.from(JSON.stringify({
        schema: "catch.organizer-whatsapp-token/v1",
        organizerId: "organizer-1",
        connectionId: "connection-1",
        accessToken: "token-1",
      }))}}];
    },
    disableSecretVersion: async (value: unknown) => {
      calls.push({method: "disable", value});
      return [{}];
    },
  };
  const originalProjectId = process.env.GCLOUD_PROJECT;
  process.env.GCLOUD_PROJECT = "project-1";
  try {
    const store = new OrganizerTokenStore(
      client as never,
      "ORGANIZER_WHATSAPP_ACCESS_TOKENS",
    );
    const resource = await store.store({
      organizerId: "organizer-1",
      connectionId: "connection-1",
      accessToken: "token-1",
    });
    assert.equal(
      resource,
      "projects/project-1/secrets/ORGANIZER_WHATSAPP_ACCESS_TOKENS/versions/7",
    );
    assert.equal(await store.access(resource), "token-1");
    await store.disable(resource);
    assert.deepEqual(calls.map((call) => call.method), [
      "add", "access", "disable",
    ]);
    const addRequest = calls[0].value as {
      parent: string;
      payload: {data: Buffer};
    };
    assert.equal(
      addRequest.parent,
      "projects/project-1/secrets/ORGANIZER_WHATSAPP_ACCESS_TOKENS",
    );
    assert.deepEqual(
      JSON.parse(addRequest.payload.data.toString("utf8")),
      {
        schema: "catch.organizer-whatsapp-token/v1",
        organizerId: "organizer-1",
        connectionId: "connection-1",
        accessToken: "token-1",
      },
    );
  } finally {
    if (originalProjectId === undefined) {
      delete process.env.GCLOUD_PROJECT;
    } else {
      process.env.GCLOUD_PROJECT = originalProjectId;
    }
  }
});

function jsonResponse(value: unknown): Response {
  return new Response(JSON.stringify(value), {status: 200});
}
