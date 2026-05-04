# Email Draft: Extracting shared FCM notification helper

## Why

`onMatchCreated.ts` and `onMessageCreated.ts` both constructed FCM
notification payloads with identical APNs sound config, Android sound
config, and data envelope structure. The 8-line `admin.messaging().send({...})`
block was duplicated verbatim except for the title/body/type fields.

## What changed

Created `functions/src/shared/notifications.ts`:

```ts
import * as admin from "firebase-admin";

interface FcmParams {
  token: string;
  title: string;
  body: string;
  type: string;
  matchId: string;
}

export async function sendFcmNotification(params: FcmParams): Promise<void> {
  await admin.messaging().send({
    token: params.token,
    notification: {title: params.title, body: params.body},
    data: {type: params.type, matchId: params.matchId},
    apns: {payload: {aps: {sound: "default"}}},
    android: {notification: {sound: "default"}},
  });
}
```

Callers simplified from 8 lines to 6:

```ts
// onMatchCreated.ts
await Promise.allSettled(
  tokens.map((token) =>
    sendFcmNotification({
      token, title: "It's a match! 🎉",
      body: "You both liked each other. Say hi!",
      type: "match", matchId,
    })
  )
);

// onMessageCreated.ts
await sendFcmNotification({
  token: fcmToken, title: senderName, body,
  type: "message", matchId,
});
```

## Design decision

The helper accepts a simple interface (`FcmParams`) rather than the full
`admin.messaging.Message` type. This enforces the shared APNs/Android config
for all chat notification callers. If a caller needs a different sound or
platform config, it should use `admin.messaging().send()` directly.

## How to verify

```bash
cd functions && npx tsc --noEmit
```
