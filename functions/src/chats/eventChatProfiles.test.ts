import assert from "node:assert/strict";
import test from "node:test";
import {Timestamp} from "firebase-admin/firestore";
import type {CallableRequest} from "firebase-functions/v2/https";
import type {
  UserProfileDocument as User,
  ProfilePhoto,
} from "../shared/generated/firestoreAdminTypes";
import {
  getEventChatProfileSharingHandler as settings,
  updateEventChatProfileSharingHandler as update,
  getEventChatProfileHandler as profile,
} from "./eventChatProfiles";
import {
  eventProfileCoreFields,
  eventProfileCoreIds,
  eventProfilePhotos,
} from "./eventChatProfileProjection";
import {validateUpdateEventChatProfileSharingCallablePayload as valid} from
  "../shared/generated/validators/updateEventChatProfileSharingInput";

const now = Timestamp.fromDate(new Date("2026-09-23T12:00:00Z"));
const selection = {
  profileRevision: 1,
  membershipRevision: 1,
  coreFieldIds: ["age"],
  photoId: null,
  card: null,
  termsVersion: "event-profile-sharing-v1",
};
const request = (data: object) =>
  ({
    auth: {uid: "person", token: {phone_number: "+919000000001"}},
    data,
  }) as CallableRequest<unknown>;
const data = {
  eventId: "event",
  expectedUid: "person",
  expectedRevision: 0,
  requestId: "decision",
  selection,
};

test("profile selection allowlist excludes contact, CRM and dating preferences",
  () => {
    const fields = eventProfileCoreFields(
    {
      displayName: "Sara",
      dateOfBirth: Timestamp.fromDate(new Date("1994-09-24T00:00:00Z")),
      occupation: " Founder ",
      languages: ["english"],
      phoneNumber: "+919000000001",
      email: "private@example.test",
      firstName: "Private",
      interestedInGenders: ["man"],
      activityPreferences: {running: {preferredDistances: ["fiveK"]}},
    } as User,
    now.toDate(),
    );
    assert.deepEqual(fields, [
      {fieldId: "age", value: 31},
      {fieldId: "occupation", value: "Founder"},
      {fieldId: "languages", value: ["english"]},
    ]);
    for (const fieldId of eventProfileCoreIds) {
      assert.equal(
        valid({...data, selection: {...selection, coreFieldIds: [fieldId]}}),
        true,
      );
    }
    for (const fieldId of [
      "email",
      "phoneNumber",
      "crmNotes",
      "dateOfBirth",
      "interestedInGenders",
      "activityPreferences",
      "__proto__",
    ]) {
      assert.equal(
        valid({...data, selection: {...selection, coreFieldIds: [fieldId]}}),
        false,
      );
    }
    assert.equal(
      valid({...data, selection: {...selection, coreFieldIds: ["age", "age"]}}),
      false,
    );
    assert.equal(
      valid({...data, selection: {...selection, termsVersion: "old"}}),
      false,
    );
  });

test("profile endpoints reject stale accounts before database work",
  async () => {
    let reads = 0;
    const deps = {
      db: () => {
        reads++;
        throw new Error("Unexpected database");
      },
      rateLimit: async () => undefined,
      now: () => now,
      readPhoto: async () => {
        throw new Error("Unexpected media");
      },
    };
    await assert.rejects(
      settings(request({eventId: "event", expectedUid: "old"}), deps),
      {code: "permission-denied"},
    );
    await assert.rejects(update(request({...data, expectedUid: "old"}), deps), {
      code: "permission-denied",
    });
    await assert.rejects(
      profile(
        request({eventId: "event", expectedUid: "old", participantUid: "peer"}),
        deps,
      ),
      {code: "permission-denied"},
    );
    await assert.rejects(
      update(
      {
        ...request(data),
        auth: {uid: "person", token: {}},
      } as CallableRequest<unknown>,
      deps,
      ),
      {code: "failed-precondition"},
    );
    assert.equal(reads, 0);
  });

test("event photos require approved owned profile paths, never private uploads",
  () => {
    const photo = {
      id: "photo",
      storagePath: "users/person/photos/photo.jpg",
      thumbnailStoragePath: "users/person/photoThumbnails/photo.jpg",
      position: 0,
      moderation: {status: "approved"},
    } as ProfilePhoto;
    for (const patch of [
      {},
      {moderation: {status: "pending"}},
      {moderation: {status: "rejected"}},
      {moderation: null},
      {storagePath: "users/other/photos/photo.jpg"},
      {thumbnailStoragePath: "organizerForms/private/asset"},
    ]) {
      const result = eventProfilePhotos(
      {profilePhotos: [{...photo, ...patch}]} as User,
      "person",
      );
      assert.equal(result.length, Object.keys(patch).length ? 0 : 1);
    }
  });
