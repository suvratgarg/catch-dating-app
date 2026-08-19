import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";
import {
  applyThumbnailToPhotos,
  v2ThumbnailPath,
} from "./generateAttachedMediaThumbnails";

test("v2 thumbnail paths remain beside stable original objects", () => {
  assert.equal(
    v2ThumbnailPath("organizers/org-1/media/media-1/original.heic"),
    "organizers/org-1/media/media-1/thumbnail.jpg"
  );
  assert.equal(
    v2ThumbnailPath("organizers/org-1/logo/logo-1/original.png"),
    "organizers/org-1/logo/logo-1/thumbnail.jpg"
  );
  assert.equal(
    v2ThumbnailPath("events/event-1/media/media-1/original.jpg"),
    "events/event-1/media/media-1/thumbnail.jpg"
  );
  assert.equal(
    v2ThumbnailPath("events/event-1/media/media-1/thumbnail.jpg"),
    null
  );
});

test("thumbnail attachment updates only the matching photo object", () => {
  const timestamp = admin.firestore.Timestamp.now();
  const result = applyThumbnailToPhotos({
    photos: [
      {id: "one", storagePath: "events/event-1/media/one/original.jpg"},
      {id: "two", storagePath: "events/event-1/media/two/original.jpg"},
    ],
    sourcePath: "events/event-1/media/two/original.jpg",
    thumbnailPath: "events/event-1/media/two/thumbnail.jpg",
    thumbnailUrl: "https://example.com/two-thumb.jpg",
    timestamp,
  });

  assert.equal(result.matched, true);
  assert.deepEqual(result.photos[0], {
    id: "one",
    storagePath: "events/event-1/media/one/original.jpg",
  });
  assert.deepEqual(result.photos[1], {
    id: "two",
    storagePath: "events/event-1/media/two/original.jpg",
    thumbnailUrl: "https://example.com/two-thumb.jpg",
    thumbnailStoragePath: "events/event-1/media/two/thumbnail.jpg",
    updatedAt: timestamp,
  });
});
