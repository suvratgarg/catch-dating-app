import {FieldPath, Firestore, Transaction} from "firebase-admin/firestore";
import type {EventAssistanceRuntimeConfigCallableResponse as Response} from
  "../../shared/generated/eventAssistanceRuntimeConfigCallableResponse";
import {validateOrganizerMessageTemplateDocument} from
  "../../shared/generated/validators/organizerMessageTemplateDocument";
import {operationContentHash} from "../../operations/durableActions";
import {parseSmsConfig} from "./smsProtocol";
import {smsCollections} from "./smsPermissionRecords";
import {parseRcsConfig} from "./rcsProtocol";
import {rcsConsentCollections} from "./rcsConsent";
import {whatsappConsentSender} from "./whatsappConsentSender";
import {WHATSAPP_POLICIES, whatsappTemplateSnapshot} from "./whatsappTemplate";
import type {RuntimeConfiguration, RuntimeContext} from
  "./runtimeConfigRecords";

type Setup = NonNullable<Response["view"]["senderSetup"]>;
export type RuntimeSenderChoice = Setup["choices"][number];
export type RuntimeSenderCursors = Setup["nextCursors"];
type Route = RuntimeSenderChoice["routeId"];
type Availability = RuntimeSenderChoice["availability"];
const routes: readonly Route[] = ["catchEventSms", "organizerEventWhatsapp",
  "catchEventRcs"];
const collections: Record<Route, string> = {
  catchEventSms: smsCollections.senders,
  organizerEventWhatsapp: "organizerSenderConnections",
  catchEventRcs: rcsConsentCollections.senders,
};
const pageSize = 20;

/** Bounded manager discovery with safe display metadata only. */
export async function readRuntimeSenderSetup(db: Firestore, tx: Transaction,
  context: RuntimeContext, now: number, cursors: RuntimeSenderCursors = {},
  saved: RuntimeConfiguration["options"]["routes"] = []): Promise<Setup> {
  const choices: RuntimeSenderChoice[] = [];
  const nextCursors: RuntimeSenderCursors = {};
  for (const route of routes) {
    let query = db.collection(collections[route])
      .orderBy(FieldPath.documentId());
    if (route === "organizerEventWhatsapp") {
      query = query.where("organizerId", "==", context.organizerId);
    }
    if (cursors[route]) query = query.startAfter(cursors[route]);
    const page = await tx.get(query.limit(pageSize + 1));
    const scanned = page.docs.slice(0, pageSize);
    for (const doc of scanned) {
      const choice = await projectSender(db, tx, context, route, doc.id,
        doc.data(), now);
      if (choice) choices.push(choice);
    }
    if (page.docs.length > pageSize) {
      nextCursors[route] = scanned.at(-1)!.id;
    }
  }
  // Existing selections stay reviewable outside the current directory pages.
  // Missing/foreign records supply neither a made-up name nor select authority.
  for (const selection of saved) {
    if (choices.some((c) => c.routeId === selection.routeId &&
        c.senderId === selection.senderId)) continue;
    const choice = await readRuntimeSenderChoice(db, tx, context,
      selection, now);
    if (choice) choices.push(choice);
  }
  return {choices, nextCursors};
}

/** Configure-time review validates current selections from any page. */
export async function readRuntimeSenderChoice(db: Firestore, tx: Transaction,
  context: RuntimeContext,
  selection: RuntimeConfiguration["options"]["routes"][number], now: number) {
  const snap = await tx.get(db.collection(collections[selection.routeId])
    .doc(selection.senderId));
  return projectSender(db, tx, context, selection.routeId, selection.senderId,
    snap.data(), now);
}

async function projectSender(db: Firestore, tx: Transaction,
  context: RuntimeContext, routeId: Route, senderId: string,
  value: unknown, now: number): Promise<RuntimeSenderChoice | null> {
  if (!/^[A-Za-z0-9][A-Za-z0-9._:-]{0,159}$/.test(senderId)) return null;
  const choice = (displayName: string, displayAddress: string | null,
    availability: Availability, evidence: unknown): RuntimeSenderChoice => ({
    routeId, senderId, displayName, displayAddress, availability,
    reviewHash: operationContentHash([context, routeId, senderId, evidence]),
  });
  switch (routeId) {
  case "catchEventSms": {
    let sender;
    try {
      sender = parseSmsConfig(value);
    } catch {
      return null;
    }
    if (sender.senderId !== senderId) return null;
    return choice("Catch", sender.mask,
      status(sender.status === "ready", sender.activation, sender.quote, now,
        sender.templates.some((t) => t.purpose === "joiningUpdate" &&
          t.status === "approved")), sender);
  }
  case "catchEventRcs": {
    let sender;
    try {
      sender = parseRcsConfig(value);
    } catch {
      return null;
    }
    if (sender.senderId !== senderId) return null;
    return choice(sender.displayName, null,
      status(sender.status === "ready", sender.activation, sender.quote, now,
        sender.allowedPurposes.includes("joiningUpdate")), sender);
  }
  case "organizerEventWhatsapp": {
    // Validate ownership before reading its private policy/template bindings.
    const identity = whatsappConsentSender(senderId, context.organizerId,
      value, null);
    if (!identity) return null;
    const policySnap = await tx.get(db.collection(WHATSAPP_POLICIES)
      .doc(senderId));
    const sender = whatsappConsentSender(senderId, context.organizerId,
      value, policySnap.data())!;
    const policy = sender.policy;
    const templatePolicy = policy?.templates.find((t) =>
      t.purpose === "joiningUpdate");
    const template = templatePolicy ? (await tx.get(db
      .collection("organizerMessageTemplates")
      .doc(templatePolicy.templateDocumentId))).data() : null;
    let templateAvailable = false;
    if (policy && templatePolicy &&
        validateOrganizerMessageTemplateDocument(template)) {
      const synced = template.syncedAt._seconds * 1000 +
        template.syncedAt._nanoseconds / 1_000_000;
      templateAvailable = template.organizerId === context.organizerId &&
        template.connectionId === senderId && template.status === "APPROVED" &&
        template.category === "UTILITY" && !template.hasMediaHeader &&
        Number.isSafeInteger(synced) && synced <= now &&
        now < synced + policy.maxTemplateAgeSeconds * 1000 &&
        operationContentHash(whatsappTemplateSnapshot(template)) ===
          templatePolicy.templateHash;
    }
    return choice(sender.identity.displayName,
      sender.identity.displayPhoneNumber, policy ?
        status(sender.connectionReady && policy.status === "ready",
          policy.activation, policy.quote, now, templateAvailable) :
        "setupRequired", [value, policySnap.data() ?? null, template ?? null]);
  }
  }
}

function status(active: boolean,
  activation: {approvedAt: number; validUntil: number},
  quote: {validUntil: number}, now: number,
  hasTemplate: boolean): Availability {
  if (!active) return "setupRequired";
  if (activation.approvedAt > now ||
      now >= Math.min(activation.validUntil, quote.validUntil)) {
    return "approvalExpired";
  }
  return hasTemplate ? "eligible" : "joiningTemplateMissing";
}
