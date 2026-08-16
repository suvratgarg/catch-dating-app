import {defineSecret} from "firebase-functions/params";

/** Shared keyed-identity secret for organizer audience writers. */
export const organizerContactIdentityKey = defineSecret(
  "ORGANIZER_CONTACT_IDENTITY_KEY"
);
