# Email 5: Chat Image Sharing

**To:** Suvrat
**Subject:** [Catch Audit #11] Image sharing in chat

---

## What changed

Added image sharing to chat. Users can now pick a photo from their gallery and send it inline. Images upload to Firebase Storage at `chats/{matchId}/images/`, show a loading progress bar, and render in the message bubble with proper borderRadius matching the text bubble shape.

### Files modified (6)

| File | Change |
|------|--------|
| `lib/chats/domain/chat_message.dart` | Added `imageUrl` field (nullable String) |
| `lib/chats/data/chat_repository.dart` | Added `pickImage()` + `sendImageMessage()`, Storage + ImagePicker deps |
| `lib/chats/presentation/chat_controller.dart` | Added `sendImage()` method |
| `lib/chats/presentation/chat_screen.dart` | Added `_sendImage()` + `_sendingImage` state |
| `lib/chats/presentation/widgets/chat_input_bar.dart` | Added image button with loading state |
| `lib/chats/presentation/widgets/message_bubble.dart` | Added image rendering with progress + error states |
| `storage.rules` | Added `chats/{matchId}/images/` path with participant-only access |

**Zero new dependencies.** Reuses `image_picker` (already in pubspec.yaml for onboarding photos).

---

## Why this was made

The audit identified chat as text-only — a significant limitation for a dating app where chat is the primary conversion surface. Users coming from Tinder/Bumble/Hinge expect image sharing. The app already had all the infrastructure needed (Storage bucket, `image_picker` dependency, upload pattern from onboarding photos) — it just needed wiring into the chat flow.

---

## How it was made

### Data model: adding `imageUrl` to ChatMessage

The `ChatMessage` freezed model got one new nullable field:

```dart
@freezed
abstract class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    @JsonKey(includeToJson: false) required String id,
    required String senderId,
    required String text,
    String? imageUrl,           // ← new
    @TimestampConverter() required DateTime sentAt,
  }) = _ChatMessage;
```

`imageUrl` is nullable and optional — text-only messages (all existing messages, all future text messages) don't include it. Image messages have `text: ''` and `imageUrl: 'https://...'`. This is backward-compatible with all existing chat data.

The Firestore document for an image message looks like:

```json
{
  "senderId": "abc123",
  "text": "",
  "imageUrl": "https://storage.googleapis.com/...",
  "sentAt": Timestamp(...)
}
```

The `onMessageCreated` Cloud Function that handles FCM pushes and unread counts already works — it reads `text` and `senderId`, both of which exist on image messages. The `lastMessagePreview` is set to "📷 Image" by the client.

### Repository: upload-then-write pattern

The `sendImageMessage` method follows a multi-step flow:

```
1. Generate a unique message ID (client-side doc ID)
2. Read image bytes from XFile
3. Upload to Storage at chats/{matchId}/images/{messageId}_{timestamp}
4. Get download URL from Storage
5. Write Firestore document with imageUrl in a batch (message + match update)
```

```dart
Future<void> sendImageMessage({...}) => withFirestoreErrorContext(() async {
  final messageId = _db.collection('chats').doc(matchId)
      .collection('messages').doc().id;
  final storagePath = 'chats/$matchId/images/${messageId}_${DateTime.now().millisecondsSinceEpoch}';
  
  final bytes = await image.readAsBytes();
  final ref = _storage.ref(storagePath);
  await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
  final downloadUrl = await ref.getDownloadURL();

  // Batch write: message doc + match preview update
  ...
});
```

**Design decision — client-side doc ID generation:**
The message ID is generated on the client using Firestore's `doc().id` before the upload. This is important because it lets the Storage path include the message ID, creating a bidirectional link: the message doc references the Storage URL, and the Storage path references the message ID. If moderation needs to find the message for a flagged image, the Storage path contains the message ID.

**Design decision — resize on pick, not upload:**
The `pickImage()` method resizes to max 1600×2133 at 85% quality. This matches the onboarding photo resize parameters and keeps images under ~500KB — fast uploads, low bandwidth, below the 8MB Storage limit. For a chat context, 1600px wide is far more than needed (chat bubbles are ~300px wide on most phones).

### UI: three-state image button

The image button in `ChatInputBar` has three states:

| State | Visual | Behavior |
|-------|--------|----------|
| **Idle** | Image icon (ink2) | Tappable, opens gallery |
| **Uploading** | Spinner (20×20, 2px stroke) | Disabled, showing progress |
| **Disabled** | Image icon (greyed out) | Blocked match or while text is sending |

The `sendingImage` state is tracked separately from `sending` (text sending) so the user can't send text while an image is uploading, and vice versa. Both operations write to the same Firestore batch and sharing state prevents race conditions.

### UI: image in message bubble

Images render inside the same `Container` as text, with a `ClipRRect` matching the bubble's corner radius:

```dart
if (imageUrl != null)
  ClipRRect(
    borderRadius: BorderRadius.circular(CatchRadius.md),
    child: Image.network(
      imageUrl!,
      width: 200,
      fit: BoxFit.contain,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return SizedBox(
          width: 200, height: 150,
          child: CircularProgressIndicator(
            value: progress.expectedTotalBytes != null
                ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
    ),
  ),
```

Three states handled:
- **Loading:** Shows a `CircularProgressIndicator` with determinate progress (bytes loaded / total bytes) from `Image.network`'s `loadingBuilder`. No empty white space — the progress indicator fills the 200×150 reserved area.
- **Error:** `SizedBox.shrink()` — the image silently disappears rather than showing a broken image icon. The text (empty or "[image]") still renders below.
- **Success:** The image renders at 200px wide with `BoxFit.contain` (preserves aspect ratio).

**Design decision — `BoxFit.contain`, not `BoxFit.cover`:**
In a chat bubble, the user should see the entire image without cropping. `contain` ensures the full image is visible. `cover` would crop to fill a fixed aspect ratio, which could cut off the subject of the photo. For a dating app where the image could be a selfie, a group photo, or a screenshot — cropping is destructive.

### Security: participant-only Storage access

The `storage.rules` for chat images check that the requesting user is a participant in the match:

```
match /chats/{matchId}/images/{fileName} {
  allow read, write: if isSignedIn()
    && firestore.get(
      /databases/(default)/documents/matches/$(matchId)
    ).data.participantIds.hasAny([request.auth.uid]);
}
```

This prevents user A from guessing match IDs and reading images from matches they're not part of. The `hasAny` check handles the case where `participantIds` is the canonical list (the `Match` document uses both `participantIds` and legacy `user1Id`/`user2Id`).

---

## Verification

```
$ flutter analyze lib/chats/
5 issues found.  (all info-level: import ordering, unnecessary underscores)
```

No errors. The `build_runner` regeneration of `chat_message.freezed.dart` and `chat_message.g.dart` succeeded. All existing chat code compiles unchanged — the nullable `imageUrl` field is backward-compatible.

The `onMessageCreated` Cloud Function trigger is unaffected — it reads `text` and `senderId` from the message doc, both of which are present on image messages.

---

## Files changed

```
 lib/chats/domain/chat_message.dart               |  +1 line
 lib/chats/domain/chat_message.freezed.dart        | (regenerated)
 lib/chats/domain/chat_message.g.dart              | (regenerated)
 lib/chats/data/chat_repository.dart               | +44 lines
 lib/chats/presentation/chat_controller.dart       | +13 lines
 lib/chats/presentation/chat_screen.dart           | +17 lines
 lib/chats/presentation/widgets/chat_input_bar.dart| +14 lines
 lib/chats/presentation/widgets/message_bubble.dart| +28 lines
 storage.rules                                     | +11 lines
```

**128 lines of functional change. No new dependencies.**
