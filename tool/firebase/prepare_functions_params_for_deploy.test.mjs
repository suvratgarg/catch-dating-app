import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";

import {prepareFunctionsParamsForDeploy} from
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

test("Catch consumers reject enablement without atomic ingress and malformed overrides", () => {
  for (const value of ["true", " TRUE ", "1", "yes", "false\nINJECTED=true"]) {
    const functionsDir = fixture();
    const output = path.join(functionsDir, ".env.catchdates-dev");
    const environment = {...publicIds, CATCH_WHATSAPP_WABA_ID: "123",
      CATCH_WHATSAPP_PHONE_NUMBER_ID: "456",
      CATCH_WHATSAPP_RECEIPT_CONSUMERS_ENABLED: value};
    const generate = () => prepareFunctionsParamsForDeploy({
      functionsDir, projectId: "catchdates-dev", environment,
    });
    assert.throws(generate, /CATCH_WHATSAPP_RECEIPT_CONSUMERS_ENABLED (must|requires)/);
    assert.equal(fs.existsSync(output), false);
    fs.writeFileSync(output, "previous-file-must-survive\n");
    assert.throws(generate, /CATCH_WHATSAPP_RECEIPT_CONSUMERS_ENABLED (must|requires)/);
    assert.equal(fs.readFileSync(output, "utf8"), "previous-file-must-survive\n");
  }
});


const catchSender = {
  CATCH_WHATSAPP_WABA_ID: "123",
  CATCH_WHATSAPP_PHONE_NUMBER_ID: "456",
};
const catchReplyScope = {
  CATCH_WHATSAPP_REPLY_ACTOR_UID: "support_actor",
  CATCH_WHATSAPP_REPLY_RECIPIENT_UID: "trial_recipient",
  CATCH_WHATSAPP_REPLY_RECIPIENT_E164: "+919876543210",
  CATCH_WHATSAPP_REPLY_CREDENTIAL_VERSION:
    "projects/catchdates-dev/secrets/CATCH_WHATSAPP_ACCESS_TOKEN/versions/12",
  CATCH_WHATSAPP_REPLY_GRAPH_VERSION: "v24.0",
  CATCH_WHATSAPP_REPLY_EVIDENCE_SHA256: "a".repeat(64),
};

function rejectsCatchConfig(patch, pattern = /Catch|CATCH_WHATSAPP/) {
  const functionsDir = fixture();
  const output = path.join(functionsDir, ".env.catchdates-dev");
  const generate = () => prepareFunctionsParamsForDeploy({
    functionsDir, projectId: "catchdates-dev",
    environment: {...publicIds, ...patch},
  });
  assert.throws(generate, pattern);
  assert.equal(fs.existsSync(output), false);
  fs.writeFileSync(output, "previous-file-must-survive\n");
  assert.throws(generate, pattern);
  assert.equal(fs.readFileSync(output, "utf8"), "previous-file-must-survive\n");
}

test("complete Catch scope can be staged or retained during all-gates-off rollback", () => {
  const functionsDir = fixture();
  const result = prepareFunctionsParamsForDeploy({
    functionsDir, projectId: "catchdates-dev",
    environment: {...publicIds, ...catchSender, ...catchReplyScope},
  });
  const contents = fs.readFileSync(result.outputPath, "utf8");
  for (const [name, value] of Object.entries(catchReplyScope)) {
    assert.ok(contents.includes(`${name}=${JSON.stringify(value)}\n`));
  }
  for (const name of ["WEBHOOK_ENABLED", "RECEIPT_CONSUMERS_ENABLED",
    "REPLIES_ENABLED", "ATOMIC_STOP_INGRESS_READY"]) {
    assert.ok(contents.includes(`CATCH_WHATSAPP_${name}="false"\n`));
  }
});

test("clearing Catch configuration removes every previous activation and scope value", () => {
  const functionsDir = fixture();
  const generate = (environment) => prepareFunctionsParamsForDeploy({
    functionsDir, projectId: "catchdates-dev", environment: {...publicIds, ...environment},
  });
  generate({...catchSender, ...catchReplyScope,
    CATCH_WHATSAPP_WEBHOOK_ENABLED: "true",
    CATCH_WHATSAPP_ATOMIC_STOP_INGRESS_READY: "true",
    CATCH_WHATSAPP_RECEIPT_CONSUMERS_ENABLED: "true",
    CATCH_WHATSAPP_REPLIES_ENABLED: "true"});
  const result = generate(Object.fromEntries([
    ...Object.keys(catchSender), ...Object.keys(catchReplyScope),
    "CATCH_WHATSAPP_WEBHOOK_ENABLED", "CATCH_WHATSAPP_ATOMIC_STOP_INGRESS_READY",
    "CATCH_WHATSAPP_RECEIPT_CONSUMERS_ENABLED", "CATCH_WHATSAPP_REPLIES_ENABLED",
  ].map((name) => [name, ""])));
  const contents = fs.readFileSync(result.outputPath, "utf8");
  const defaults = prepareFunctionsParamsForDeploy({
    functionsDir: fixture(), projectId: "catchdates-dev", environment: publicIds,
  });
  assert.equal(contents, fs.readFileSync(defaults.outputPath, "utf8"));
  assert.equal(fs.statSync(result.outputPath).mode & 0o777, 0o600);
});

test("Catch gate combinations fail closed without coupling organizer or other channels", () => {
  const names = ["WEBHOOK_ENABLED", "ATOMIC_STOP_INGRESS_READY",
    "RECEIPT_CONSUMERS_ENABLED", "REPLIES_ENABLED"];
  for (let bits = 0; bits < 16; bits++) {
    const on = names.map((_, index) => Boolean(bits & (1 << index)));
    const gates = Object.fromEntries(names.map((name, index) =>
      [`CATCH_WHATSAPP_${name}`, String(on[index])]));
    const environment = {...catchSender, ...catchReplyScope, ...gates};
    // Valid progression: disabled, receiver, atomic ingress, consumers, replies.
    if (!new Set([0, 1, 3, 7, 15]).has(bits)) {
      rejectsCatchConfig(environment);
      continue;
    }
    const result = prepareFunctionsParamsForDeploy({
      functionsDir: fixture(), projectId: "catchdates-dev",
      environment: {...publicIds, ...environment,
        CATCH_WHATSAPP_ACCESS_TOKEN: "must-not-be-emitted"},
    });
    const contents = fs.readFileSync(result.outputPath, "utf8");
    for (const [name, value] of Object.entries(gates)) {
      assert.ok(contents.includes(`${name}="${value}"\n`));
    }
    for (const name of ["META_WHATSAPP_ENABLED", "EVENT_ASSISTANCE_RCS_ENABLED",
      "EVENT_ASSISTANCE_RCS_WEBHOOK_ENABLED", "EVENT_ASSISTANCE_SMS_REPORTS_ENABLED"]) {
      assert.ok(contents.includes(`${name}="false"\n`));
    }
    assert.doesNotMatch(contents, /CATCH_WHATSAPP_ACCESS_TOKEN=|must-not-be-emitted/);
  }
});

test("atomic ingress and consumers can precede recipient readiness without replies", () => {
  const result = prepareFunctionsParamsForDeploy({
    functionsDir: fixture(), projectId: "catchdates-dev",
    environment: {...publicIds, ...catchSender,
      CATCH_WHATSAPP_WEBHOOK_ENABLED: "true",
      CATCH_WHATSAPP_ATOMIC_STOP_INGRESS_READY: "true",
      CATCH_WHATSAPP_RECEIPT_CONSUMERS_ENABLED: "true"},
  });
  const contents = fs.readFileSync(result.outputPath, "utf8");
  assert.match(contents, /^CATCH_WHATSAPP_REPLIES_ENABLED="false"$/m);
  assert.match(contents, /^CATCH_WHATSAPP_REPLY_EVIDENCE_SHA256=" "$/m);
});

test("partial Catch reply scope and unpaired sender ids never overwrite config", () => {
  for (const name of Object.keys(catchReplyScope)) {
    rejectsCatchConfig({...catchSender, [name]: catchReplyScope[name]});
    rejectsCatchConfig({...catchSender, ...catchReplyScope, [name]: " "});
  }
  rejectsCatchConfig({...catchReplyScope});
  rejectsCatchConfig({...catchReplyScope, CATCH_WHATSAPP_WABA_ID: "123"});
  rejectsCatchConfig({CATCH_WHATSAPP_PHONE_NUMBER_ID: "456"});
  rejectsCatchConfig({...catchSender, CATCH_WHATSAPP_WEBHOOK_ENABLED: "true",
    CATCH_WHATSAPP_ATOMIC_STOP_INGRESS_READY: "true",
    CATCH_WHATSAPP_RECEIPT_CONSUMERS_ENABLED: "true",
    CATCH_WHATSAPP_REPLIES_ENABLED: "true"});
});

test("malformed Catch scope rejects unsafe identities endpoints digests and versions", () => {
  const credential = catchReplyScope.CATCH_WHATSAPP_REPLY_CREDENTIAL_VERSION;
  const invalid = {
    CATCH_WHATSAPP_REPLY_ACTOR_UID: ["bad/uid", "x".repeat(129), "a\nb"],
    CATCH_WHATSAPP_REPLY_RECIPIENT_UID: ["bad uid", "x".repeat(129)],
    CATCH_WHATSAPP_REPLY_RECIPIENT_E164: ["919876543210", "+01234567",
      "+123456", "+" + "1".repeat(16), "+919876543210\nx=y"],
    CATCH_WHATSAPP_REPLY_CREDENTIAL_VERSION: [
      credential.replace("catchdates-dev", "catchdates-staging"),
      credential.replace("CATCH_WHATSAPP_ACCESS_TOKEN", "ORGANIZER_WHATSAPP_ACCESS_TOKENS"),
      ...["latest", "0", "01", "-1", "12/extra"].map((value) =>
        credential.replace("/12", `/${value}`)), "token-value", `${credential}\nx=y`],
    CATCH_WHATSAPP_REPLY_GRAPH_VERSION: ["latest", "v0.0", "v24", "v24.0/path"],
    CATCH_WHATSAPP_REPLY_EVIDENCE_SHA256: ["A".repeat(64), "a".repeat(63),
      "g".repeat(64), "a".repeat(64) + "\nx=y"],
  };
  for (const [name, values] of Object.entries(invalid)) {
    for (const value of values) {
      rejectsCatchConfig({...catchSender, ...catchReplyScope, [name]: value});
    }
  }
});

test("Catch gates reject non-booleans even with complete valid scope", () => {
  for (const name of ["WEBHOOK_ENABLED", "RECEIPT_CONSUMERS_ENABLED",
    "REPLIES_ENABLED", "ATOMIC_STOP_INGRESS_READY"]) {
    for (const value of ["1", "yes", "false\nINJECTED=true"]) {
      rejectsCatchConfig({...catchSender, ...catchReplyScope,
        [`CATCH_WHATSAPP_${name}`]: value}, /must be true or false/);
    }
  }
});

test("promotion forwards scoped Catch non-secret configuration without secret payloads", () => {
  const promotion = fs.readFileSync(new URL(
    "../../.github/workflows/_firebase-promote.yml", import.meta.url), "utf8");
  const step = promotion.slice(
    promotion.indexOf("      - name: Materialize non-secret Functions params"),
    promotion.indexOf("      - name: Gate Functions param coverage"));
  for (const name of [...Object.keys(catchSender), ...Object.keys(catchReplyScope),
    "CATCH_WHATSAPP_WEBHOOK_ENABLED", "CATCH_WHATSAPP_RECEIPT_CONSUMERS_ENABLED",
    "CATCH_WHATSAPP_REPLIES_ENABLED", "CATCH_WHATSAPP_ATOMIC_STOP_INGRESS_READY"]) {
    assert.ok(step.includes(name + ": ${{ vars." + name + " }}"));
  }
  assert.doesNotMatch(step, /secrets\.|CATCH_WHATSAPP_ACCESS_TOKEN:|CATCH_WHATSAPP_APP_SECRET:|CATCH_WHATSAPP_WEBHOOK_VERIFY_TOKEN:/);
});
