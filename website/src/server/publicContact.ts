import "server-only";
import {cache} from "react";
import {fallbackPublicContact, publicContactFromDocument, type PublicContact} from "../content/publicContact";
import {publicFirestore} from "./publicCatalog";

/** One uncached Firestore read per legal-page request; no module-level last-good value. */
export async function loadPublicContact(read: () => Promise<unknown>): Promise<PublicContact> {
  let timer: ReturnType<typeof setTimeout> | undefined;
  try {
    const raw = await Promise.race([read(), new Promise<never>((_, reject) => {
      timer = setTimeout(() => reject(new Error("PUBLIC_CONTACT_READ_TIMEOUT")), 2_000);
    })]);
    return publicContactFromDocument(raw) ?? fallbackPublicContact;
  } catch {
    return fallbackPublicContact;
  } finally {
    clearTimeout(timer);
  }
}

async function loadFromFirestore(): Promise<PublicContact> {
  return loadPublicContact(async () => {
    const snapshot = await publicFirestore().doc("config/publicContact").get();
    return snapshot.exists ? snapshot.data() : null;
  });
}

export const readPublicContact = cache(loadFromFirestore);
