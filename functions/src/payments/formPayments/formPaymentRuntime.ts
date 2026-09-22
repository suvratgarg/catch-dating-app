import * as admin from "firebase-admin";
import {FormPaymentRuntimeConfig, formRazorpayPartnerConfigVersion} from
  "./formPaymentRuntimeConfig";
import {FormPaymentCredentials} from "./formPaymentCredentials";
import {FormPaymentProcessor} from "./formPaymentProcessor";
import {OrganizerRazorpayConnectionService} from
  "./organizerRazorpayConnection";

let config: FormPaymentRuntimeConfig | undefined;

export function formPaymentsConfigured(): boolean {
  return formRazorpayPartnerConfigVersion.value().trim().length > 0;
}

export async function formPaymentRuntime() {
  const projectId = admin.app().options.projectId ??
    process.env.GCLOUD_PROJECT ?? process.env.GOOGLE_CLOUD_PROJECT ?? "";
  config ??= new FormPaymentRuntimeConfig(projectId);
  const runtime = await config.load(
    formRazorpayPartnerConfigVersion.value().trim());
  const db = admin.firestore();
  const credentials = new FormPaymentCredentials({...runtime, db});
  const processor = new FormPaymentProcessor({...runtime, db, credentials});
  const connections = new OrganizerRazorpayConnectionService({...runtime, db});
  return {...runtime, db, credentials, processor, connections};
}
