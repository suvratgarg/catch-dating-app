import {onDocumentCreated} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {AppUserDoc, MatchDoc} from "../types/firestore";

export const onMatchCreated = onDocumentCreated(
  "matches/{matchId}",
  async (event) => {
    const {matchId} = event.params;
    const match = event.data?.data() as MatchDoc | undefined;
    if (!match) return;

    const {user1Id, user2Id} = match;

    // Fetch both users' FCM tokens concurrently
    const [user1Doc, user2Doc] = await Promise.all([
      admin.firestore().collection("users").doc(user1Id).get(),
      admin.firestore().collection("users").doc(user2Id).get(),
    ]);

    const tokens = [
      (user1Doc.data() as AppUserDoc | undefined)?.fcmToken,
      (user2Doc.data() as AppUserDoc | undefined)?.fcmToken,
    ].filter((t): t is string => !!t);

    if (tokens.length === 0) return;

    logger.info("Sending match notifications", {matchId, tokenCount: tokens.length});

    await Promise.allSettled(
      tokens.map((token) =>
        admin.messaging().send({
          token,
          notification: {
            title: "It's a match! 🎉",
            body: "You both liked each other. Say hi!",
          },
          data: {type: "match", matchId},
          apns: {payload: {aps: {sound: "default"}}},
          android: {notification: {sound: "default"}},
        })
      )
    );
  }
);
