#!/usr/bin/env node
import {createHash} from "node:crypto";
import fs from "node:fs";
import path from "node:path";
import {createRequire} from "node:module";
import {fileURLToPath} from "node:url";

const toolPath = fileURLToPath(import.meta.url);
const repoRoot = path.resolve(path.dirname(toolPath), "../..");
const requireFromFunctions = createRequire(
  path.join(repoRoot, "functions/package.json")
);

if (process.argv[1] && path.resolve(process.argv[1]) === toolPath) {
  await main();
}

export async function main(argv = process.argv.slice(2)) {
  const args = parseArgs(argv);
  if (args.help) return printHelp();
  const projectId = resolveProjectId(args);
  if (args.apply && isProductionTarget(args, projectId) && !args.allowProd) {
    throw new Error(
      "Refusing to backfill prod without --allow-prod. " +
      "Run a dry run first, then rerun with --apply --allow-prod."
    );
  }
  if (args.emulatorHost) {
    process.env.FIRESTORE_EMULATOR_HOST = args.emulatorHost;
  }
  const admin = requireFromFunctions("firebase-admin");
  admin.initializeApp({projectId});
  const db = admin.firestore();
  const plan = await buildOrganizerCrmAuthorityV2Plan(db);
  console.log(JSON.stringify(plan.summary, null, 2));
  if (!args.apply) {
    console.log("\nDry run only. Re-run with --apply to write repairs.");
    return;
  }
  await applyOrganizerCrmAuthorityV2Plan(db, plan);
  console.log("\nApplied organizer CRM authority v2 repairs.");
}

export async function buildOrganizerCrmAuthorityV2Plan(firestore) {
  const [
    attendees,
    edges,
    contacts,
    origins,
    preferences,
    permissionReceipts,
    formConversionReceipts,
    formResponses,
  ] =
    await Promise.all([
      firestore.collection("eventAttendees").get(),
      firestore.collection("organizerContactEventEdges").get(),
      firestore.collection("organizerContacts").get(),
      firestore.collection("organizerContactOrigins").get(),
      firestore.collection("organizerCommunicationPreferences").get(),
      firestore.collection("organizerCommunicationPermissionReceipts").get(),
      firestore.collection("organizerFormConversionReceipts").get(),
      firestore.collection("organizerFormResponses").get(),
    ]);
  const edgeById = new Map(edges.docs.map((doc) => [doc.id, doc.data()]));
  const contactById = new Map(contacts.docs.map((doc) => [doc.id, doc.data()]));
  const responseById = new Map(
    formResponses.docs.map((doc) => [doc.id, doc.data()])
  );
  const originById = new Map(origins.docs.map((doc) => [doc.id, doc.data()]));
  const plannedOriginIds = new Set(originById.keys());
  const receiptIds = new Set(permissionReceipts.docs.map((doc) => doc.id));
  const originCreates = [];
  const attendeeGaps = [];
  for (const doc of attendees.docs) {
    const attendee = doc.data();
    const edge = edgeById.get(doc.id);
    if (!edge?.contactId || !edge?.originContactId) {
      attendeeGaps.push(doc.ref.path);
      continue;
    }
    const currentContact = contactById.get(edge.contactId);
    const originContact = contactById.get(edge.originContactId);
    if (currentContact?.organizerId !== attendee.organizerId ||
        originContact?.organizerId !== attendee.organizerId) {
      attendeeGaps.push(doc.ref.path);
      continue;
    }
    const origin = attendeeOrigin(doc.id, attendee, edge);
    const id = contactOriginId(origin);
    if (!plannedOriginIds.has(id)) {
      originCreates.push({
        path: `organizerContactOrigins/${id}`,
        document: origin,
      });
      plannedOriginIds.add(id);
    }
  }

  const formConversionGaps = [];
  for (const doc of formConversionReceipts.docs) {
    const receipt = doc.data();
    if (receipt.kind !== "crmContact" || receipt.status !== "completed") {
      continue;
    }
    const response = responseById.get(receipt.responseId);
    const originContact = typeof receipt.resultId === "string" ?
      contactById.get(receipt.resultId) : null;
    const currentContactId = typeof receipt.resultId === "string" ?
      resolveCurrentContactId({
        contactId: receipt.resultId,
        organizerId: receipt.organizerId,
        contactById,
      }) : null;
    if (!response ||
        response.organizerId !== receipt.organizerId ||
        response.formId !== receipt.formId ||
        originContact?.organizerId !== receipt.organizerId ||
        !currentContactId ||
        typeof receipt.actorUid !== "string" ||
        !response.submittedAt) {
      formConversionGaps.push(doc.ref.path);
      continue;
    }
    const origin = formResponseOrigin({
      receipt,
      response,
      currentContactId,
    });
    const id = contactOriginId(origin);
    if (!plannedOriginIds.has(id)) {
      originCreates.push({
        path: `organizerContactOrigins/${id}`,
        document: origin,
      });
      plannedOriginIds.add(id);
    }
  }

  const plannedOrigins = [
    ...originById.values(),
    ...originCreates.map((item) => item.document),
  ];
  const contactIdsWithAnyOrigin = new Set(plannedOrigins.flatMap((origin) =>
    [origin.currentContactId, origin.originContactId]
  ));
  const contactsWithoutAnyOrigin = contacts.docs
    .filter((doc) => !contactIdsWithAnyOrigin.has(doc.id))
    .map((doc) => doc.ref.path);
  const orphanOriginPaths = origins.docs
    .filter((doc) => !validOriginContacts(doc.data(), contactById))
    .map((doc) => doc.ref.path);

  const preferenceUpdates = [];
  const receiptCreates = [];
  for (const doc of preferences.docs) {
    const preference = doc.data();
    const patch = {};
    for (const channel of ["whatsapp", "sms"]) {
      const value = preference[channel];
      if (isCurrentChannel(value)) continue;
      if (!value || value.status === "unknown") {
        patch[channel] = unknownChannel();
        continue;
      }
      const sourceTimestamp = value.updatedAt ?? preference.updatedAt ??
        preference.createdAt;
      const sourceIdentity = [
        doc.id,
        channel,
        value.status,
        timestampMillis(sourceTimestamp),
      ].join("|");
      const receiptId = communicationReceiptId({
        organizerId: preference.organizerId,
        uid: preference.uid,
        channel,
        decision: value.status,
        source: "legacyIncomplete",
        sourceIdentity,
      });
      if (!receiptIds.has(receiptId)) {
        receiptCreates.push({
          path: `organizerCommunicationPermissionReceipts/${receiptId}`,
          document: legacyPermissionReceipt({
            preference,
            channel,
            value,
            receiptId,
            sourceTimestamp,
          }),
        });
      }
      patch[channel] = {
        status: value.status,
        evidenceStatus: "incomplete",
        currentReceiptId: receiptId,
        termsVersion: value.termsVersion ?? null,
        source: "legacyIncomplete",
        sourceEventId: value.sourceEventId ?? null,
        updatedAt: sourceTimestamp ?? null,
      };
    }
    if (Object.keys(patch).length > 0) {
      preferenceUpdates.push({path: doc.ref.path, patch});
    }
  }
  return {
    originCreates,
    receiptCreates,
    preferenceUpdates,
    summary: {
      attendeesScanned: attendees.size,
      contactsScanned: contacts.size,
      contactOriginsToCreate: originCreates.length,
      attendeeOriginGaps: attendeeGaps.length,
      attendeeGapPaths: attendeeGaps.slice(0, 100),
      formConversionReceiptsScanned: formConversionReceipts.size,
      formConversionOriginGaps: formConversionGaps.length,
      formConversionGapPaths: formConversionGaps.slice(0, 100),
      contactsWithoutAnyOrigin: contactsWithoutAnyOrigin.length,
      contactOriginGapPaths: contactsWithoutAnyOrigin.slice(0, 100),
      orphanOrigins: orphanOriginPaths.length,
      orphanOriginPaths: orphanOriginPaths.slice(0, 100),
      preferencesScanned: preferences.size,
      permissionReceiptsToCreate: receiptCreates.length,
      preferencesToUpdate: preferenceUpdates.length,
      inferredGrants: 0,
    },
  };
}

function formResponseOrigin({receipt, response, currentContactId}) {
  return {
    organizerId: receipt.organizerId,
    currentContactId,
    originContactId: receipt.resultId,
    sourceKind: "hostForm",
    sourceEntityKind: "hostFormResponse",
    sourceEntityId: receipt.responseId,
    eventId: null,
    formId: receipt.formId,
    responseId: receipt.responseId,
    actorClass: "organizerManager",
    actorUid: receipt.actorUid,
    observedAt: response.submittedAt,
    originVersion: 1,
    createdAt: receipt.completedAt ?? receipt.createdAt ?? response.submittedAt,
  };
}

function resolveCurrentContactId({contactId, organizerId, contactById}) {
  const visited = new Set();
  let candidateId = contactId;
  while (candidateId && !visited.has(candidateId)) {
    visited.add(candidateId);
    const contact = contactById.get(candidateId);
    if (!contact || contact.organizerId !== organizerId) return null;
    if (!contact.mergedIntoContactId) return candidateId;
    candidateId = contact.mergedIntoContactId;
  }
  return null;
}

function validOriginContacts(origin, contactById) {
  const current = contactById.get(origin.currentContactId);
  const original = contactById.get(origin.originContactId);
  return current?.organizerId === origin.organizerId &&
    original?.organizerId === origin.organizerId;
}

export async function applyOrganizerCrmAuthorityV2Plan(firestore, plan) {
  const writes = [
    ...plan.originCreates.map((item) => ({...item, operation: "set"})),
    ...plan.receiptCreates.map((item) => ({...item, operation: "set"})),
    ...plan.preferenceUpdates.map((item) => ({...item, operation: "update"})),
  ];
  for (let index = 0; index < writes.length; index += 400) {
    const batch = firestore.batch();
    for (const write of writes.slice(index, index + 400)) {
      const ref = firestore.doc(write.path);
      if (write.operation === "set") batch.set(ref, write.document);
      else batch.update(ref, write.patch);
    }
    await batch.commit();
  }
}

function attendeeOrigin(attendeeId, attendee, edge) {
  const actorClass = attendee.source === "webOtp" ? "participant" :
    attendee.source === "providerSync" ? "provider" :
      attendee.source === "hostImport" || attendee.source === "hostManual" ?
        "organizerManager" : "system";
  return {
    organizerId: attendee.organizerId,
    currentContactId: edge.contactId,
    originContactId: edge.originContactId,
    sourceKind: attendee.source,
    sourceEntityKind: "eventAttendee",
    sourceEntityId: attendeeId,
    eventId: attendee.eventId,
    formId: null,
    responseId: null,
    actorClass,
    actorUid: attendee.source === "webOtp" ? attendee.linkedUid ?? null : null,
    observedAt: attendee.createdAt,
    originVersion: 1,
    createdAt: attendee.createdAt,
  };
}

function legacyPermissionReceipt(params) {
  const decision = params.value.status;
  return {
    organizerId: params.preference.organizerId,
    uid: params.preference.uid,
    channel: params.channel,
    decision,
    evidenceStatus: "incomplete",
    termsVersion: params.value.termsVersion ?? null,
    consentCopyHash: null,
    source: "legacyIncomplete",
    sourceEventId: params.value.sourceEventId ?? null,
    sourceFormId: null,
    sourceResponseId: null,
    sourceProviderEventId: null,
    actorClass: "system",
    actorUid: null,
    identityStrength: "unknown",
    grantedAt: decision === "optedIn" ? params.sourceTimestamp ?? null : null,
    revokedAt: decision === "optedOut" ? params.sourceTimestamp ?? null : null,
    supersedesReceiptId: null,
    createdAt: params.sourceTimestamp ?? params.preference.createdAt,
  };
}

function unknownChannel() {
  return {
    status: "unknown",
    evidenceStatus: "notApplicable",
    currentReceiptId: null,
    termsVersion: null,
    source: null,
    sourceEventId: null,
    updatedAt: null,
  };
}

function isCurrentChannel(value) {
  return value?.status === "unknown" ?
    value.evidenceStatus === "notApplicable" &&
      value.currentReceiptId === null :
    ["complete", "incomplete"].includes(value?.evidenceStatus) &&
      typeof value?.currentReceiptId === "string";
}

function contactOriginId(origin) {
  return `oco_${sha256([
    origin.organizerId,
    origin.sourceKind,
    origin.sourceEntityKind,
    origin.sourceEntityId,
  ].join("|")).slice(0, 48)}`;
}

function communicationReceiptId(params) {
  return `ocpr_${sha256([
    params.organizerId,
    params.uid,
    params.channel,
    params.decision,
    params.source,
    params.sourceIdentity,
  ].join("|")).slice(0, 48)}`;
}

function timestampMillis(value) {
  return typeof value?.toMillis === "function" ? value.toMillis() :
    value?._seconds ? value._seconds * 1000 : "unknown";
}

function sha256(value) {
  return createHash("sha256").update(value).digest("hex");
}

function parseArgs(argv) {
  const parsed = {
    env: null,
    project: null,
    emulatorHost: null,
    apply: false,
    allowProd: false,
    help: false,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--help" || arg === "-h") parsed.help = true;
    else if (arg === "--apply") parsed.apply = true;
    else if (arg === "--allow-prod") parsed.allowProd = true;
    else if (arg === "--emulator") {
      parsed.emulatorHost = "127.0.0.1:8080";
    } else if (arg === "--emulator-host") {
      parsed.emulatorHost = requireValue(argv, ++index, arg);
    } else if (arg === "--env") {
      parsed.env = requireValue(argv, ++index, arg);
    } else if (arg === "--project") {
      parsed.project = requireValue(argv, ++index, arg);
    } else throw new Error(`Unknown argument: ${arg}`);
  }
  return parsed;
}

function requireValue(argv, index, flag) {
  const value = argv[index];
  if (!value || value.startsWith("--")) {
    throw new Error(`${flag} requires a value.`);
  }
  return value;
}

function resolveProjectId(args) {
  if (args.project) return args.project;
  if (args.env) {
    const project = readFirebaseRc().projects?.[args.env];
    if (!project) throw new Error(`No Firebase project for env: ${args.env}`);
    return project;
  }
  return process.env.GCLOUD_PROJECT ||
    process.env.GOOGLE_CLOUD_PROJECT || "catchdates-dev";
}

function isProductionTarget(args, projectId) {
  return args.env === "prod" || projectId === readFirebaseRc().projects?.prod;
}

function readFirebaseRc() {
  return JSON.parse(fs.readFileSync(path.join(repoRoot, ".firebaserc"), "utf8"));
}

function printHelp() {
  console.log(`Usage: node tool/data/backfill_organizer_crm_authority_v2.mjs [options]

Backfills contact provenance only from canonical attendee edges and completed
reviewed Host Form CRM conversion receipts, reports unresolved contact/origin
gaps, and marks legacy organizer communication decisions incomplete. It never
infers a grant. The tool is dry-run by default.

Options:
  --apply                 Write repairs. Default is dry-run.
  --allow-prod            Required with --apply against prod.
  --env <dev|staging|prod> Resolve project id from .firebaserc.
  --project <id>          Firebase project id.
  --emulator              Use Firestore emulator at 127.0.0.1:8080.
  --emulator-host <host>  Use a custom Firestore emulator host.
  -h, --help              Show this help.
`);
}
