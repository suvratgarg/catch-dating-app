import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";

import {prepareFunctionsParamsForDeploy, functionsParamsProvenance} from
  "./prepare_functions_params_for_deploy.mjs";

const publicIds = {
  ALGOLIA_APPLICATION_ID: "CATCHDEV01",
  RAZORPAY_PUBLIC_KEY_ID: "rzp_test_example123",
};

function fixture() {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "catch-params-"));
  fs.writeFileSync(path.join(directory, "package.json"), "{}\n");
  return directory;
}

test("disabled legacy Meta params remain visibly unconfigured", () => {
  const functionsDir = fixture();
  const result = prepareFunctionsParamsForDeploy({
    functionsDir,
    projectId: "catchdates-dev",
    environment: publicIds,
  });
  assert.equal(result.enabled, false);
  assert.equal(path.basename(result.outputPath), ".env.catchdates-dev");
  assert.equal(fs.readFileSync(result.outputPath, "utf8"), [
    'ALGOLIA_APPLICATION_ID="CATCHDEV01"',
    'RAZORPAY_PUBLIC_KEY_ID="rzp_test_example123"',
    'FORM_RAZORPAY_PARTNER_CONFIG_VERSION=" "',
    'RAZORPAY_PLATFORM_PAYMENT_CONFIG_VERSION=" "',
    "META_WHATSAPP_APP_ID=\" \"",
    "META_WHATSAPP_EMBEDDED_SIGNUP_CONFIG_ID=\" \"",
    "META_WHATSAPP_GRAPH_VERSION=\"v23.0\"",
    "META_WHATSAPP_ENABLED=\"false\"",
    'CATCH_WHATSAPP_WEBHOOK_ENABLED="false"',
    'CATCH_WHATSAPP_RECEIPT_CONSUMERS_ENABLED="false"',
    'CATCH_WHATSAPP_REPLIES_ENABLED="false"',
    'CATCH_WHATSAPP_ATOMIC_STOP_INGRESS_READY="false"',
    'CATCH_WHATSAPP_REPLY_ACTOR_UID=" "',
    'CATCH_WHATSAPP_REPLY_RECIPIENT_UID=" "',
    'CATCH_WHATSAPP_REPLY_RECIPIENT_E164=" "',
    'CATCH_WHATSAPP_REPLY_CREDENTIAL_VERSION=" "',
    'CATCH_WHATSAPP_REPLY_GRAPH_VERSION=" "',
    'CATCH_WHATSAPP_REPLY_EVIDENCE_SHA256=" "',
    'CATCH_WHATSAPP_WABA_ID=" "',
    'CATCH_WHATSAPP_PHONE_NUMBER_ID=" "',
    'EVENT_ASSISTANCE_RCS_ENABLED="false"',
    'EVENT_ASSISTANCE_RCS_WEBHOOK_ENABLED="false"',
    'EVENT_ASSISTANCE_SMS_REPORTS_ENABLED="false"',
    'FORM_DOMAIN_CNAME_TARGET=" "',
    'FLIGHT_WEBHOOK_BASE_URL=" "',
    'FLIGHT_PROVIDER_CONFIG_VERSION=" "',
    'FLIGHT_PROVIDER_POLICY=" "',
    "",
  ].join("\n"));
  assert.equal(fs.statSync(result.outputPath).mode & 0o777, 0o600);
});

test("empty GitHub repository variables default Meta to disabled", () => {
  const functionsDir = fixture();
  const result = prepareFunctionsParamsForDeploy({
    functionsDir,
    projectId: "catchdates-staging",
    environment: {
      ...publicIds,
      META_WHATSAPP_ENABLED: "",
      META_WHATSAPP_APP_ID: "",
      META_WHATSAPP_EMBEDDED_SIGNUP_CONFIG_ID: "",
      META_WHATSAPP_GRAPH_VERSION: "",
    },
  });
  assert.equal(result.enabled, false);
  assert.equal(fs.readFileSync(result.outputPath, "utf8"), [
    'ALGOLIA_APPLICATION_ID="CATCHDEV01"',
    'RAZORPAY_PUBLIC_KEY_ID="rzp_test_example123"',
    'FORM_RAZORPAY_PARTNER_CONFIG_VERSION=" "',
    'RAZORPAY_PLATFORM_PAYMENT_CONFIG_VERSION=" "',
    "META_WHATSAPP_APP_ID=\" \"",
    "META_WHATSAPP_EMBEDDED_SIGNUP_CONFIG_ID=\" \"",
    "META_WHATSAPP_GRAPH_VERSION=\"v23.0\"",
    "META_WHATSAPP_ENABLED=\"false\"",
    'CATCH_WHATSAPP_WEBHOOK_ENABLED="false"',
    'CATCH_WHATSAPP_RECEIPT_CONSUMERS_ENABLED="false"',
    'CATCH_WHATSAPP_REPLIES_ENABLED="false"',
    'CATCH_WHATSAPP_ATOMIC_STOP_INGRESS_READY="false"',
    'CATCH_WHATSAPP_REPLY_ACTOR_UID=" "',
    'CATCH_WHATSAPP_REPLY_RECIPIENT_UID=" "',
    'CATCH_WHATSAPP_REPLY_RECIPIENT_E164=" "',
    'CATCH_WHATSAPP_REPLY_CREDENTIAL_VERSION=" "',
    'CATCH_WHATSAPP_REPLY_GRAPH_VERSION=" "',
    'CATCH_WHATSAPP_REPLY_EVIDENCE_SHA256=" "',
    'CATCH_WHATSAPP_WABA_ID=" "',
    'CATCH_WHATSAPP_PHONE_NUMBER_ID=" "',
    'EVENT_ASSISTANCE_RCS_ENABLED="false"',
    'EVENT_ASSISTANCE_RCS_WEBHOOK_ENABLED="false"',
    'EVENT_ASSISTANCE_SMS_REPORTS_ENABLED="false"',
    'FORM_DOMAIN_CNAME_TARGET=" "',
    'FLIGHT_WEBHOOK_BASE_URL=" "',
    'FLIGHT_PROVIDER_CONFIG_VERSION=" "',
    'FLIGHT_PROVIDER_POLICY=" "',
    "",
  ].join("\n"));
});

test("enabled provider requires and preserves real non-secret ids", () => {
  const functionsDir = fixture();
  const environment = {
    ...publicIds,
    META_WHATSAPP_ENABLED: "true",
    META_WHATSAPP_APP_ID: "12345",
    META_WHATSAPP_EMBEDDED_SIGNUP_CONFIG_ID: "67890",
    META_WHATSAPP_GRAPH_VERSION: "v24.0",
  };
  const result = prepareFunctionsParamsForDeploy({
    functionsDir,
    projectId: "catchdates-prod",
    environment,
  });
  assert.equal(result.enabled, true);
  const contents = fs.readFileSync(result.outputPath, "utf8");
  assert.match(contents, /META_WHATSAPP_APP_ID="12345"/);
  assert.match(contents, /META_WHATSAPP_ENABLED="true"/);
});

test("custom form target is operator supplied and otherwise disabled", () => {
  const functionsDir = fixture();
  const result = prepareFunctionsParamsForDeploy({
    functionsDir, projectId: "catchdates-dev",
    environment: {...publicIds,
      FORM_DOMAIN_CNAME_TARGET: "custom.catchdates.com"},
  });
  assert.match(fs.readFileSync(result.outputPath, "utf8"),
    /FORM_DOMAIN_CNAME_TARGET="custom.catchdates.com"/);
  assert.throws(() => prepareFunctionsParamsForDeploy({
    functionsDir, projectId: "catchdates-dev",
    environment: {...publicIds,
      FORM_DOMAIN_CNAME_TARGET: "attacker.example/path"},
  }));
});

test("provider enablement without real ids fails closed", () => {
  assert.throws(() => prepareFunctionsParamsForDeploy({
    functionsDir: fixture(),
    projectId: "catchdates-prod",
    environment: {...publicIds, META_WHATSAPP_ENABLED: "true"},
  }), /real Meta app and embedded-signup config ids are required/);
});

test("invalid project names and parameter shapes are rejected", () => {
  assert.throws(() => prepareFunctionsParamsForDeploy({
    functionsDir: fixture(),
    projectId: "../prod",
    environment: publicIds,
  }), /invalid Firebase project id/);
  assert.throws(() => prepareFunctionsParamsForDeploy({
    functionsDir: fixture(),
    projectId: "catchdates-prod",
    environment: {...publicIds, META_WHATSAPP_GRAPH_VERSION: "latest"},
  }), /must look like v23.0/);
});

test("plain provider ids never collide with legacy secret parameter names", () => {
  const result = prepareFunctionsParamsForDeploy({
    functionsDir: fixture(),
    projectId: "catchdates-dev",
    environment: {
      ...publicIds,
      ALGOLIA_APP_ID: "legacy-id",
      RAZORPAY_KEY_ID: "legacy-key-id",
      ALGOLIA_SEARCH_API_KEY: "must-not-be-emitted",
      RAZORPAY_KEY_SECRET: "must-not-be-emitted",
    },
  });
  const contents = fs.readFileSync(result.outputPath, "utf8");
  assert.match(contents, /ALGOLIA_APPLICATION_ID="CATCHDEV01"/);
  assert.match(contents, /RAZORPAY_PUBLIC_KEY_ID="rzp_test_example123"/);
  assert.doesNotMatch(contents,
    /ALGOLIA_APP_ID=|RAZORPAY_KEY_ID=|API_KEY=|KEY_SECRET=|must-not-be-emitted/);
});

test("missing or unsafe public provider ids fail before writing deployment config", () => {
  for (const environment of [
    {},
    {...publicIds, ALGOLIA_APPLICATION_ID: ""},
    {...publicIds, ALGOLIA_APPLICATION_ID: "INVALID\nENV"},
    {...publicIds, RAZORPAY_PUBLIC_KEY_ID: ""},
    {...publicIds, RAZORPAY_PUBLIC_KEY_ID: "rzp_test_key\nINJECTED=value"},
  ]) {
    const functionsDir = fixture();
    assert.throws(() => prepareFunctionsParamsForDeploy({
      functionsDir,
      projectId: "catchdates-dev",
      environment,
    }), /ALGOLIA_APPLICATION_ID|RAZORPAY_PUBLIC_KEY_ID/);
    assert.equal(fs.existsSync(path.join(functionsDir, ".env.catchdates-dev")),
      false);
  }
});

test("event assistance flags default false and accept explicit enablement", () => {
  const functionsDir = fixture();
  const result = prepareFunctionsParamsForDeploy({
    functionsDir,
    projectId: "catchdates-dev",
    environment: {
      ...publicIds,
      EVENT_ASSISTANCE_RCS_ENABLED: " TRUE ",
      EVENT_ASSISTANCE_RCS_WEBHOOK_ENABLED: "true",
    },
  });
  const contents = fs.readFileSync(result.outputPath, "utf8");
  assert.match(contents, /EVENT_ASSISTANCE_RCS_ENABLED="true"/);
  assert.match(contents, /EVENT_ASSISTANCE_RCS_WEBHOOK_ENABLED="true"/);
  assert.match(contents, /EVENT_ASSISTANCE_SMS_REPORTS_ENABLED="false"/);
});

test("event assistance flags reject non-boolean values before writing", () => {
  const functionsDir = fixture();
  assert.throws(() => prepareFunctionsParamsForDeploy({
    functionsDir,
    projectId: "catchdates-dev",
    environment: {
      ...publicIds,
      EVENT_ASSISTANCE_SMS_REPORTS_ENABLED: "1",
    },
  }), /EVENT_ASSISTANCE_SMS_REPORTS_ENABLED must be true or false/);
  assert.equal(fs.existsSync(path.join(functionsDir, ".env.catchdates-dev")),
    false);
});

test("form partner config is opt-in and pins only a project-local version", () => {
  const version = "projects/catchdates-dev/secrets/FORM_PARTNER/versions/12";
  const result = prepareFunctionsParamsForDeploy({
    functionsDir: fixture(), projectId: "catchdates-dev",
    environment: {...publicIds, FORM_RAZORPAY_PARTNER_CONFIG_VERSION: version},
  });
  assert.ok(fs.readFileSync(result.outputPath, "utf8").includes(
    `FORM_RAZORPAY_PARTNER_CONFIG_VERSION="${version}"`));
  for (const value of [version.replace("catchdates-dev", "catchdates-prod"),
    version.replace("/12", "/latest"), "private-secret-value", `${version}\nx=y`]) {
    const functionsDir = fixture();
    assert.throws(() => prepareFunctionsParamsForDeploy({
      functionsDir, projectId: "catchdates-dev",
      environment: {...publicIds, FORM_RAZORPAY_PARTNER_CONFIG_VERSION: value},
    }), /must pin a secret in this project/);
    assert.equal(fs.existsSync(path.join(functionsDir, ".env.catchdates-dev")),
      false);
  }
});

test("flight provider config is opt-in and pins only a project-local version", () => {
  const version = "projects/catchdates-dev/secrets/FLIGHT_PROVIDER/versions/12";
  const result = prepareFunctionsParamsForDeploy({
    functionsDir: fixture(), projectId: "catchdates-dev",
    environment: {...publicIds, FLIGHT_PROVIDER_CONFIG_VERSION: version},
  });
  assert.ok(fs.readFileSync(result.outputPath, "utf8").includes(
    `FLIGHT_PROVIDER_CONFIG_VERSION="${version}"`));
  for (const value of [version.replace("catchdates-dev", "catchdates-prod"),
    version.replace("/12", "/latest"), "private-secret-value", `${version}\nx=y`]) {
    const functionsDir = fixture();
    assert.throws(() => prepareFunctionsParamsForDeploy({
      functionsDir, projectId: "catchdates-dev",
      environment: {...publicIds, FLIGHT_PROVIDER_CONFIG_VERSION: value},
    }), /must pin a secret in this project/);
    assert.equal(fs.existsSync(path.join(functionsDir, ".env.catchdates-dev")),
      false);
  }
});

test("platform Route config is opt-in and pins only a project-local version", () => {
  const version = "projects/catchdates-dev/secrets/PLATFORM_PAYMENTS/versions/12";
  const result = prepareFunctionsParamsForDeploy({
    functionsDir: fixture(), projectId: "catchdates-dev",
    environment: {...publicIds, RAZORPAY_PLATFORM_PAYMENT_CONFIG_VERSION: version},
  });
  assert.ok(fs.readFileSync(result.outputPath, "utf8").includes(
    `RAZORPAY_PLATFORM_PAYMENT_CONFIG_VERSION="${version}"`));
  for (const value of [version.replace("catchdates-dev", "catchdates-prod"),
    version.replace("/12", "/latest"), "private-secret-value", `${version}\nx=y`]) {
    const functionsDir = fixture();
    assert.throws(() => prepareFunctionsParamsForDeploy({
      functionsDir, projectId: "catchdates-dev",
      environment: {...publicIds, RAZORPAY_PLATFORM_PAYMENT_CONFIG_VERSION: value},
    }), /must pin a secret in this project/);
    assert.equal(fs.existsSync(path.join(functionsDir, ".env.catchdates-dev")),
      false);
  }
});


test("Catch webhook activation is independent and never writes secrets", () => {
  const result = prepareFunctionsParamsForDeploy({
    functionsDir: fixture(), projectId: "catchdates-dev",
    environment: {...publicIds,
      CATCH_WHATSAPP_WEBHOOK_ENABLED: "true",
      CATCH_WHATSAPP_WABA_ID: "123",
      CATCH_WHATSAPP_PHONE_NUMBER_ID: "456",
      CATCH_WHATSAPP_APP_SECRET: "must-not-be-emitted",
      CATCH_WHATSAPP_WEBHOOK_VERIFY_TOKEN: "must-not-be-emitted"},
  });
  const contents = fs.readFileSync(result.outputPath, "utf8");
  assert.equal(result.enabled, false);
  assert.match(contents, /META_WHATSAPP_ENABLED="false"/);
  assert.match(contents, /CATCH_WHATSAPP_WEBHOOK_ENABLED="true"/);
  assert.match(contents, /CATCH_WHATSAPP_WABA_ID="123"/);
  assert.match(contents, /CATCH_WHATSAPP_PHONE_NUMBER_ID="456"/);
  assert.doesNotMatch(contents, /APP_SECRET|VERIFY_TOKEN|must-not-be-emitted/);
});

test("Catch webhook activation rejects absent or unsafe sender ids", () => {
  for (const patch of [
    {}, {CATCH_WHATSAPP_WABA_ID: "123"},
    {CATCH_WHATSAPP_WABA_ID: "bad", CATCH_WHATSAPP_PHONE_NUMBER_ID: "456"},
    {CATCH_WHATSAPP_WABA_ID: "123", CATCH_WHATSAPP_PHONE_NUMBER_ID: "bad"},
  ]) {
    const functionsDir = fixture();
    assert.throws(() => prepareFunctionsParamsForDeploy({
      functionsDir, projectId: "catchdates-dev",
      environment: {...publicIds, CATCH_WHATSAPP_WEBHOOK_ENABLED: "true",
        ...patch},
    }), /Catch WABA|numeric Meta/);
    assert.equal(fs.existsSync(path.join(functionsDir, ".env.catchdates-dev")),
      false);
  }
});


test("Catch receipt consumers materialize false independently of ingress", () => {
  for (const value of [undefined, "", "  ", "false", " FALSE "]) {
    const functionsDir = fixture();
    // Regeneration must replace a stale file, not preserve a prior true value.
    const output = path.join(functionsDir, ".env.catchdates-dev");
    fs.writeFileSync(output, 'CATCH_WHATSAPP_RECEIPT_CONSUMERS_ENABLED="true"\n');
    const result = prepareFunctionsParamsForDeploy({
      functionsDir, projectId: "catchdates-dev",
      environment: {...publicIds, CATCH_WHATSAPP_WEBHOOK_ENABLED: "true",
        CATCH_WHATSAPP_WABA_ID: "123", CATCH_WHATSAPP_PHONE_NUMBER_ID: "456",
        CATCH_WHATSAPP_RECEIPT_CONSUMERS_ENABLED: value},
    });
    const contents = fs.readFileSync(result.outputPath, "utf8");
    assert.match(contents, /^CATCH_WHATSAPP_RECEIPT_CONSUMERS_ENABLED="false"$/m);
    assert.match(contents, /^CATCH_WHATSAPP_WEBHOOK_ENABLED="true"$/m);
    assert.equal(result.enabled, false);
  }
});

test("Catch consumer enablement and malformed overrides fail before writing", () => {
  for (const value of ["true", " TRUE ", "1", "yes", "false\nINJECTED=true"]) {
    const functionsDir = fixture();
    const output = path.join(functionsDir, ".env.catchdates-dev");
    const environment = {...publicIds, CATCH_WHATSAPP_WABA_ID: "123",
      CATCH_WHATSAPP_PHONE_NUMBER_ID: "456",
      CATCH_WHATSAPP_RECEIPT_CONSUMERS_ENABLED: value};
    const generate = () => prepareFunctionsParamsForDeploy({
      functionsDir, projectId: "catchdates-dev", environment,
    });
    assert.throws(generate, /CATCH_WHATSAPP_RECEIPT_CONSUMERS_ENABLED must/);
    assert.equal(fs.existsSync(output), false);
    fs.writeFileSync(output, "previous-file-must-survive\n");
    assert.throws(generate, /CATCH_WHATSAPP_RECEIPT_CONSUMERS_ENABLED must/);
    assert.equal(fs.readFileSync(output, "utf8"), "previous-file-must-survive\n");
  }
});


test("offline reply gates and scoped configuration cannot be provisioned", () => {
  const names = ["CATCH_WHATSAPP_REPLIES_ENABLED", "CATCH_WHATSAPP_ATOMIC_STOP_INGRESS_READY", "CATCH_WHATSAPP_REPLY_ACTOR_UID", "CATCH_WHATSAPP_REPLY_RECIPIENT_UID", "CATCH_WHATSAPP_REPLY_RECIPIENT_E164", "CATCH_WHATSAPP_REPLY_CREDENTIAL_VERSION", "CATCH_WHATSAPP_REPLY_GRAPH_VERSION", "CATCH_WHATSAPP_REPLY_EVIDENCE_SHA256"];
  for (const name of names) {
    const functionsDir = fixture();
    assert.throws(() => prepareFunctionsParamsForDeploy({functionsDir,
      projectId: "catchdates-dev", environment: {...publicIds, [name]: "true"},
    }), /must remain/);
    assert.equal(fs.existsSync(path.join(functionsDir, ".env.catchdates-dev")),
      false);
  }
});


test("flight policy stays blank across environments even with stored credentials", () => {
  for (const projectId of ["catchdates-dev", "catchdates-staging",
    "catch-dating-app-64e51"]) {
    for (const policy of [undefined, "", "  "]) {
      const functionsDir = fixture();
      const output = path.join(functionsDir, `.env.${projectId}`);
      fs.writeFileSync(output, 'FLIGHT_PROVIDER_POLICY="old-pilot"\n');
      const version = `projects/${projectId}/secrets/FLIGHT_PROVIDER_CONFIG/versions/1`;
      const result = prepareFunctionsParamsForDeploy({functionsDir, projectId,
        environment: {...publicIds, FLIGHT_PROVIDER_CONFIG_VERSION: version,
          FLIGHT_PROVIDER_POLICY: policy},
      });
      const contents = fs.readFileSync(result.outputPath, "utf8");
      assert.match(contents, /^FLIGHT_PROVIDER_POLICY=" "$/m);
      assert.doesNotMatch(contents, /old-pilot/);
      assert.ok(contents.includes(`FLIGHT_PROVIDER_CONFIG_VERSION="${version}"`));
    }
  }
});

test("flight activation overrides fail before writing deployment config", () => {
  for (const policy of ["true", "polling-pilot", "{}", JSON.stringify({
    schema: "catch.flight-policy/v1", mode: "polling-pilot",
    programIds: ["program-1"], legIds: ["leg-1"],
    startsAt: "2026-10-03T11:00:00Z", expiresAt: "2026-10-03T12:00:00Z",
    maxRequestsPerDay: 5,
  })]) {
    const functionsDir = fixture();
    const output = path.join(functionsDir, ".env.catchdates-dev");
    const generate = () => prepareFunctionsParamsForDeploy({
      functionsDir, projectId: "catchdates-dev",
      environment: {...publicIds, FLIGHT_PROVIDER_POLICY: policy},
    });
    assert.throws(generate, /FLIGHT_PROVIDER_POLICY must remain unconfigured/);
    assert.equal(fs.existsSync(output), false);
    fs.writeFileSync(output, "previous-file-must-survive\n");
    assert.throws(generate, /FLIGHT_PROVIDER_POLICY must remain unconfigured/);
    assert.equal(fs.readFileSync(output, "utf8"), "previous-file-must-survive\n");
  }
});

test("provenance allowlists names and references without public IDs, private values or arbitrary environment fields", () => {
  const sourceSha = "a".repeat(40);
  const environment = {...publicIds, PRIVATE_KEY: "never-print-private",
    GOOGLE_APPLICATION_CREDENTIALS: "/private/never-read.json",
    FLIGHT_PROVIDER_CONFIG_VERSION: "projects/catchdates-dev/secrets/FLIGHT_PROVIDER_CONFIG/versions/7"};
  const receipt = functionsParamsProvenance({projectId: "catchdates-dev", sourceSha, environment});
  const serialized = JSON.stringify(receipt);
  assert.doesNotMatch(serialized, /never-print-private|never-read|CATCHDEV01|rzp_test_example123|PRIVATE_KEY/u);
  assert.equal(receipt.references.FLIGHT_PROVIDER_CONFIG_VERSION, environment.FLIGHT_PROVIDER_CONFIG_VERSION);
  assert.equal(receipt.names.find((entry) => entry.name === "ALGOLIA_APPLICATION_ID").source, "deployment-environment");
  assert.equal(receipt.names.find((entry) => entry.name === "FLIGHT_PROVIDER_POLICY").source, "source-disabled");
  assert.match(receipt.paramsSha256, /^[a-f0-9]{64}$/u);
  assert.equal(receipt.sourceSha, sourceSha);
});

test("materialization refuses changed provenance before writing and never follows a symlink", (t) => {
  const functionsDir = fixture(); t.after(() => fs.rmSync(functionsDir, {recursive: true, force: true}));
  const sourceSha = "b".repeat(40), projectId = "catchdates-dev";
  const expectedProvenance = functionsParamsProvenance({projectId, sourceSha, environment: publicIds});
  const output = path.join(functionsDir, `.env.${projectId}`);
  assert.throws(() => prepareFunctionsParamsForDeploy({functionsDir, projectId, sourceSha, expectedProvenance,
    environment: {...publicIds, META_WHATSAPP_GRAPH_VERSION: "v24.0"}}), /provenance changed/u);
  assert.equal(fs.existsSync(output), false);
  const result = prepareFunctionsParamsForDeploy({functionsDir, projectId, sourceSha, expectedProvenance, environment: publicIds});
  assert.equal(fs.statSync(result.outputPath).mode & 0o777, 0o600);
  fs.unlinkSync(output);
  const sentinel = path.join(functionsDir, "fake-existing.txt"); fs.writeFileSync(sentinel, "preserve");
  fs.symlinkSync(sentinel, output);
  assert.throws(() => prepareFunctionsParamsForDeploy({functionsDir, projectId, environment: publicIds}));
  assert.equal(fs.readFileSync(sentinel, "utf8"), "preserve");
});
