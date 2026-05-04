/**
 * Photo moderation via Google Cloud Vision SafeSearch.
 *
 * Triggered automatically on every Storage object finalize event. Downloads
 * the uploaded image bytes, runs SafeSearch detection, and takes one of
 * three actions:
 *
 *   **Allow** — No adult/violent/racy content detected. The upload proceeds
 *   normally; no moderation doc is written.
 *
 *   **Flag (likely)** — Elevated but not certain detection. The image is
 *   left in place and a `moderationFlags` doc is written with status
 *   `"pending"` for human review.
 *
 *   **Block (very likely)** — High-confidence detection of explicit or
 *   violent content. The image is deleted from Storage, a moderation flag
 *   is written with status `"pending"`, and (for profile photos) the
 *   photo URL is removed from the user's `photoUrls` array.
 *
 * ## Storage paths moderated
 *
 *   - `users/{uid}/photos/{fileName}` — profile photos
 *   - `runClubs/{clubId}/{fileName}` — club images
 *   - `chats/{matchId}/images/{messageId}` — chat images (future)
 *
 * ## Costs
 *
 * Cloud Vision SafeSearch pricing (as of 2026):
 *   - First 1000 units / month: free
 *   - 1001–5M units / month: $1.50 per 1000
 *   Each image analysed = 1 unit.
 *
 * ## Cold-start behaviour
 *
 * The ImageAnnotatorClient is instantiated at module scope so it is reused
 * across warm invocations. Application Default Credentials are auto-
 * discovered via the admin SDK's service account — no explicit key needed.
 */

import {onObjectFinalized} from "firebase-functions/v2/storage";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import * as vision from "@google-cloud/vision";
import type {ModerationFlagDoc} from "../shared/firestore";

// ── Client ─────────────────────────────────────────────────────────────────

const visionClient = new vision.ImageAnnotatorClient();

// ── Helpers ────────────────────────────────────────────────────────────────

/**
 * Likelihood values from Cloud Vision SafeSearch, ordered from least to
 * most severe. We block at VERY_LIKELY and flag at LIKELY.
 */
type Likelihood = "UNKNOWN" | "VERY_UNLIKELY" | "UNLIKELY" | "POSSIBLE"
  | "LIKELY" | "VERY_LIKELY";

const BLOCK_LIKELIHOODS: ReadonlySet<Likelihood> = new Set([
  "VERY_LIKELY",
]);

const FLAG_LIKELIHOODS: ReadonlySet<Likelihood> = new Set([
  "LIKELY",
  "VERY_LIKELY",
]);

interface SafeSearchCategory {
  name: string;
  likelihood: Likelihood;
}

/**
 * Returns the highest SafeSearch severity across all categories.
 * @param {SafeSearchCategory[]} categories SafeSearch results.
 * @return {"block"|"flag"|"allow"} The highest severity found.
 */
function highestSeverity(
  categories: SafeSearchCategory[]
): "block" | "flag" | "allow" {
  let worst: "block" | "flag" | "allow" = "allow";
  for (const cat of categories) {
    if (BLOCK_LIKELIHOODS.has(cat.likelihood)) return "block";
    if (FLAG_LIKELIHOODS.has(cat.likelihood)) worst = "flag";
  }
  return worst;
}

/**
 * Extracts uid from a `users/{uid}/photos/...` Storage path.
 * @param {string} filePath The Storage object path.
 * @return {string|null} The uid, or null if not a user photo path.
 */
function uidFromPath(filePath: string): string | null {
  const parts = filePath.split("/");
  if (parts[0] === "users" && parts[1]) return parts[1];
  return null;
}

// ── Handler ────────────────────────────────────────────────────────────────

/**
 * Storage finalize handler that runs SafeSearch on every uploaded image.
 *
 * When a photo is blocked (VERY_LIKELY explicit/violent), this handler
 * deletes the Storage object and removes the URL from the user's
 * `photoUrls` array so the client does not show a broken reference.
 */
export const moderatePhotoOnUpload = onObjectFinalized(
  async (event) => {
    const filePath = event.data.name;
    if (!filePath) return;

    // Only moderate recognized image paths.
    const isProfilePhoto = filePath.startsWith("users/") &&
      filePath.includes("/photos/");
    const isClubImage = filePath.startsWith("runClubs/");
    const isChatImage = filePath.startsWith("chats/");

    if (!isProfilePhoto && !isClubImage && !isChatImage) return;

    const bucket = admin.storage().bucket(event.data.bucket);
    const file = bucket.file(filePath);

    try {
      const [exists] = await file.exists();
      if (!exists) return;

      // Download just enough bytes for SafeSearch (the Vision API
      // accepts up to 20 MB; Storage limit is 8 MB for our rules).
      const [buffer] = await file.download();

      const [result] = await visionClient.safeSearchDetection({
        image: {content: buffer},
      });

      const safeSearch = result.safeSearchAnnotation;
      if (!safeSearch) return;

      const categories: SafeSearchCategory[] = [
        {name: "adult", likelihood: safeSearch.adult as Likelihood},
        {name: "violence", likelihood: safeSearch.violence as Likelihood},
        {name: "racy", likelihood: safeSearch.racy as Likelihood},
        {name: "medical", likelihood: safeSearch.medical as Likelihood},
      ];

      const severity = highestSeverity(categories);

      if (severity === "allow") return;

      // ── Build moderation flag ──────────────────────────────────────────

      const flagData = {
        targetUserId: uidFromPath(filePath) ?? "unknown",
        flagType: "explicit_photo" as const,
        source: (
          isProfilePhoto ? "profile_photo" :
            isClubImage ? "club_image" : "chat_message"
        ) as ModerationFlagDoc["source"],
        status: "pending" as const,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        contextId: filePath,
        safeSearchResults: Object.fromEntries(
          categories.map((c) => [c.name, c.likelihood])
        ),
      };

      const flagRef = await admin.firestore()
        .collection("moderationFlags")
        .add(flagData);

      // ── Block: delete the photo ────────────────────────────────────────

      if (severity === "block") {
        await file.delete();

        // Remove the URL from the user's photoUrls if it's a profile photo.
        if (isProfilePhoto) {
          const uid = uidFromPath(filePath);
          if (uid) {
            const publicUrl = `https://storage.googleapis.com/${bucket.name}/${filePath}`;
            await admin.firestore()
              .collection("users")
              .doc(uid)
              .update({
                photoUrls: admin.firestore.FieldValue
                  .arrayRemove(publicUrl),
              });
          }
        }

        logger.info(
          `[moderation] BLOCKED photo ${filePath} → flag ${flagRef.id}`
        );
      } else {
        logger.info(
          `[moderation] FLAGGED photo ${filePath} → flag ${flagRef.id}`
        );
      }
    } catch (err) {
      // SafeSearch or download failure should not break the upload flow.
      // The photo stays; the error is logged for ops visibility.
      logger.error(
        `[moderation] SafeSearch failed for ${filePath}:`,
        err
      );
    }
  }
);
