import type {Firestore} from "firebase-admin/firestore";
import {MetaWhatsappProvider} from
  "../../organizers/organizerWhatsappProvider";
import {GuestAssistanceStore} from "./guestAssistanceStore";
import {GuestLinkKeyStore} from "./guestLinkKeyStore";
import type {GuestLinkSigningKeys} from "./guestLinkTokens";
import {threadIdentity} from "./guestRecords";
import {hasAutomaticDelivery} from "./deliveryWorkRecords";
import type {MessageRecord} from "./messageOutbox";
import {EventMessageWorker} from "./messageWorker";
import {EventSmsWorker} from "./smsWorker";
import {SmsDispatchStore} from "./smsDispatchStore";
import {EventWhatsappWorker} from "./whatsappWorker";
import {WhatsappDispatchStore} from "./whatsappDispatchStore";

/** Stable per-message grant across retries, workers and fallback channels. */
export const deliveryGrantOperation = (messageId: string) =>
  "delivery:" + messageId;

type WorkerFactory = (message: MessageRecord, keys: GuestLinkSigningKeys) =>
  Pick<EventMessageWorker, "dispatch">;

export class LiveMessageDispatcher {
  constructor(private readonly db: Firestore,
    private readonly clock: () => number = Date.now,
    private readonly keyStore: Pick<GuestLinkKeyStore, "access"> =
    new GuestLinkKeyStore(),
    private readonly factory?: WorkerFactory) {}

  async dispatch(message: MessageRecord, deadline: number) {
    if (!hasAutomaticDelivery(message)) {
      throw new Error("Automatic delivery authority unavailable");
    }
    const keys = await this.keyStore.access();
    if (this.clock() >= deadline) throw new Error("Delivery execution expired");
    const link = await new GuestAssistanceStore(this.db, this.clock).issueLink(
      threadIdentity(message.intent), deliveryGrantOperation(message.messageId),
      keys);
    // The secret only passes through the signing/rendering boundary in memory.
    const worker = this.factory ? this.factory(message, keys) :
      this.worker(message, keys);
    if (this.clock() >= deadline) throw new Error("Delivery execution expired");
    return worker.dispatch(message.messageId, link.linkId, deadline);
  }

  private worker(message: MessageRecord, keys: GuestLinkSigningKeys) {
    if (message.intent.kind !== "joiningUpdate" ||
        !message.intent.automation?.runtimeBinding) {
      throw new Error("Automatic sender selection unavailable");
    }
    const workers: ConstructorParameters<typeof EventMessageWorker>[1] = {};
    for (const route of message.intent.automation.routes) {
      if (route.routeId === "catchEventSms") {
        workers.sms = new EventSmsWorker(new SmsDispatchStore(this.db,
          route.senderId, keys, this.clock), undefined, undefined, this.clock);
      } else if (route.routeId === "organizerEventWhatsapp" &&
          process.env.META_WHATSAPP_ENABLED === "true") {
        // Template sends use the organizer's bound token. App credentials are
        // needed by onboarding, not by this restricted sendTemplate port.
        const provider = new MetaWhatsappProvider({appId: "", appSecret: "",
          configId: "", graphVersion:
            process.env.META_WHATSAPP_GRAPH_VERSION ?? "v23.0"},
        fetch, this.clock);
        workers.whatsapp = new EventWhatsappWorker(new WhatsappDispatchStore(
          this.db, route.senderId, keys, this.clock), provider, undefined,
        this.clock);
      }
    }
    return new EventMessageWorker(this.db, workers, this.clock);
  }
}
