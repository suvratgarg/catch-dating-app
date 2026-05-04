import * as admin from "firebase-admin";

interface FcmParams {
  token: string;
  title: string;
  body: string;
  type: string;
  matchId: string;
}

/**
 * Sends a single FCM notification with the shared APNs / Android sound config.
 * @param {FcmParams} params The notification parameters.
 * @return {Promise<void>}
 */
export async function sendFcmNotification(params: FcmParams): Promise<void> {
  await admin.messaging().send({
    token: params.token,
    notification: {title: params.title, body: params.body},
    data: {type: params.type, matchId: params.matchId},
    apns: {payload: {aps: {sound: "default"}}},
    android: {notification: {sound: "default"}},
  });
}
