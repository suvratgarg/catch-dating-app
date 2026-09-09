import {validateOrganizerSenderConnectionDocument} from
  "../../shared/generated/validators/organizerSenderConnectionDocument";
import {Permission} from "./whatsappPermissionRecords";
import {parseWhatsappPolicy, WhatsappPolicy} from "./whatsappTemplate";

export interface ConsentSender {
  identity: Permission["sender"];
  connectionReady: boolean;
  policy: WhatsappPolicy | null;
}

/** Invalid provisioning cannot obstruct withdrawal of saved consent. */
export function whatsappConsentSender(senderId: string, organizerId: string,
  connection: unknown, policyValue: unknown): ConsentSender | null {
  if (!validateOrganizerSenderConnectionDocument(connection) ||
      connection.organizerId !== organizerId ||
      !numericId(connection.wabaId) ||
      !numericId(connection.phoneNumberId) ||
      !displayText(connection.verifiedName, 1, 160) ||
      !displayText(connection.displayPhoneNumber, 7, 32)) return null;
  let policy: WhatsappPolicy | null = null;
  try {
    const candidate = parseWhatsappPolicy(policyValue);
    if (candidate.senderId === senderId &&
        candidate.organizerId === organizerId &&
        candidate.providerAccountId === connection.wabaId &&
        candidate.providerPhoneNumberId === connection.phoneNumberId) {
      policy = candidate;
    }
  } catch {/* An invalid policy supplies no grant authority. */}
  const secret = connection.secretVersionResource;
  const credentialBound = typeof secret === "string" &&
    /^projects\/[^/\s]+\/secrets\/[^/\s]+\/versions\/[1-9][0-9]*$/
      .exec(secret)?.[0] === secret;
  return {identity: {providerAccountId: connection.wabaId!,
    providerPhoneNumberId: connection.phoneNumberId!,
    displayName: connection.verifiedName!,
    displayPhoneNumber: connection.displayPhoneNumber!}, policy,
  connectionReady: connection.status === "active" &&
    connection.webhookStatus === "subscribed" &&
    connection.testStatus === "delivered" && credentialBound};
}

function numericId(value: unknown): boolean {
  return typeof value === "string" &&
    /^[0-9]{5,40}$/.exec(value)?.[0] === value;
}

function displayText(value: unknown, min: number, max: number): boolean {
  return typeof value === "string" && value.trim().length >= min &&
    value.length <= max && Array.from(value).every((char) =>
    char.charCodeAt(0) >= 32 && char.charCodeAt(0) !== 127);
}
