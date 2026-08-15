import assert from "node:assert/strict";
import test from "node:test";
import {isModeratedPhotoPath} from "./moderatedPhotoPath";

test("canonical and legacy organizer media paths are moderated", () => {
  assert.equal(
    isModeratedPhotoPath("organizers/organizer-1/photos/0_photo.jpg"),
    true
  );
  assert.equal(
    isModeratedPhotoPath("organizers/organizer-1/logo/logo.jpg"),
    true
  );
  assert.equal(
    isModeratedPhotoPath("clubs/club-1/photos/0_photo.jpg"),
    true
  );
  assert.equal(
    isModeratedPhotoPath("clubs/club-1/logo/logo.jpg"),
    true
  );
});

test("moderation path recognition preserves other image surfaces", () => {
  for (const path of [
    "users/user-1/photos/profile.jpg",
    "users/user-1/hostedMedia/legacy.jpg",
    "events/event-1/photos/cover.jpg",
    "matches/match-1/images/message-1.jpg",
  ]) {
    assert.equal(isModeratedPhotoPath(path), true, path);
  }

  assert.equal(
    isModeratedPhotoPath("organizers/organizer-1/logoThumbnails/logo.jpg"),
    false
  );
});
