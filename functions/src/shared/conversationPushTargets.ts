import type {UserProfileDocument} from "./generated/firestoreAdminTypes";

export type ConversationPushRole = "consumer" | "host";

/** Selects unique app-specific addresses; legacy tokens are Consumer-only. */
export function conversationPushTokens(
  installations: ReadonlyArray<Record<string, unknown>>,
  role: ConversationPushRole,
  legacyToken?: string
): string[] {
  const tokens = installations.flatMap((installation) =>
    installation.appRole === role &&
      typeof installation.token === "string" &&
      installation.token.trim().length > 0 ? [installation.token] : []
  );
  // Do not fall back to a legacy token known to belong to another app.
  const belongsToOtherRole = installations.some((installation) =>
    installation.token === legacyToken && installation.appRole !== role
  );
  if (role === "consumer" && legacyToken?.trim() && !belongsToOtherRole) {
    tokens.push(legacyToken);
  }
  return [...new Set(tokens)];
}

/** Reads per-user installations for conversation pushes. */
export async function resolveConversationPushTokens(
  db: FirebaseFirestore.Firestore,
  uid: string,
  role: ConversationPushRole,
  user: UserProfileDocument | undefined
): Promise<string[]> {
  const snapshot = await db.collection("users").doc(uid)
    .collection("pushInstallations").get();
  return conversationPushTokens(
    snapshot.docs.map((document) => document.data()), role, user?.fcmToken
  );
}
