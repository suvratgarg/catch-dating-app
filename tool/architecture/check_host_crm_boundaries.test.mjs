import assert from "node:assert/strict";
import test from "node:test";
import {
  applicationRouteOwnershipFindings,
  hostCrmCountCopyFindings,
  manualSendContractFindings,
  scanBackendFile,
  scanPresentationFile,
} from "./check_host_crm_boundaries.mjs";

test("flags saved-audience mutation outside Customers", () => {
  const findings = scanPresentationFile({
    relativePath: "lib/hosts/presentation/inbox/broadcast.dart",
    source: "await controller.saveAudience(definition);",
  });
  assert.match(findings[0].reason, /belong to Customers/u);
});

test("flags host-visible communication route pickers", () => {
  const findings = scanPresentationFile({
    relativePath: "lib/hosts/presentation/inbox/channel_picker.dart",
    source: "CatchField.select<HostCommunicationRouteId>(items: routes)",
  });
  assert.ok(findings.some((item) => /server-resolved/u.test(item.reason)));
  assert.ok(findings.some((item) => /choose communication intent/u.test(item.reason)));
});

test("flags manual-send queues outside Sends", () => {
  const findings = scanPresentationFile({
    relativePath: "lib/hosts/presentation/inbox/host_inbox_screen.dart",
    source: "const HostManualSendQueue()",
  });
  assert.match(findings[0].reason, /Sends workspace/u);
});

test("flags unreviewed permission-authority access", () => {
  const findings = scanBackendFile({
    relativePath: "functions/src/organizers/formGrant.ts",
    source: 'db.collection("organizerCommunicationPreferences").doc(id)',
  });
  assert.match(findings[0].reason, /explicit reviewed owner/u);
});

test("flags direct contact creation outside canonical projection owners", () => {
  const findings = scanBackendFile({
    relativePath: "functions/src/organizers/shortcut.ts",
    source: [
      'const contactRef = db.collection("organizerContacts").doc();',
      "tx.create(contactRef, contact);",
    ].join("\n"),
  });
  assert.match(findings[0].reason, /canonical server owner/u);
});

test("flags saved-audience and manual-task writes outside their owners", () => {
  for (const [collection, alias] of [
    ["organizerSavedAudiences", "audienceRef"],
    ["organizerManualSendTasks", "taskRef"],
  ]) {
    const findings = scanBackendFile({
      relativePath: "functions/src/organizers/shortcut.ts",
      source: [
        `const ${alias} = db.collection("${collection}").doc(id);`,
        `tx.set(${alias}, document);`,
      ].join("\n"),
    });
    assert.match(findings[0].reason, /canonical server owner/u);
  }
});

test("flags form automations that dispatch outreach", () => {
  const findings = scanBackendFile({
    relativePath: "functions/src/organizers/organizerFormAutomations.ts",
    source: 'import {dispatchOrganizerCampaign} from "./organizerCampaignDispatcher";\ndispatchOrganizerCampaign();',
  });
  assert.ok(findings.some((item) => /cannot dispatch outreach/u.test(item.reason)));
});

test("flags provider delivery states on manual handoffs", () => {
  const findings = manualSendContractFindings({
    relativePath: "manual.json",
    schema: {definitions: {status: {enum: ["queued", "delivered", "read"]}}},
  });
  assert.match(findings[0].reason, /delivered\/read states are forbidden/u);
});

test("flags visible Host CRM counts without ICU plurals", () => {
  const findings = hostCrmCountCopyFindings({
    relativePath: "lib/l10n/app_en.arb",
    catalog: {
      hostSendsRecipients: "{count} people",
      "@hostSendsRecipients": {
        placeholders: {count: {type: "int"}},
      },
    },
  });
  assert.match(findings[0].reason, /without ICU plural ownership/u);
});

test("flags application queue ownership under Customers", () => {
  const findings = applicationRouteOwnershipFindings({
    routeContractPath: "lib/routing/route_contract.dart",
    routeContractSource:
      "hostApplicationsScreen('/host/customers/applications'",
    routerPath: "lib/routing/go_router.dart",
    routerSource: [
      "navigatorKey: keys.hostCustomers",
      "name: Routes.hostApplicationsScreen.name",
      "name: Routes.hostApplicationDetailScreen.name",
      "navigatorKey: keys.hostForms",
      "navigatorKey: keys.hostInbox",
    ].join("\n"),
  });
  assert.ok(findings.some((item) => /canonically Forms-owned/u.test(item.reason)));
  assert.ok(findings.some((item) => /Forms shell branch/u.test(item.reason)));
  assert.ok(findings.some((item) => /Legacy Customers/u.test(item.reason)));
});
