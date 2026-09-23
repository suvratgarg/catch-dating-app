import assert from "node:assert/strict";
import test from "node:test";
import sharp from "sharp";
import {Timestamp} from "firebase-admin/firestore";
import {assertClaimPhotoAsset, normalizeFormProfilePhoto,
  assertFormPhotoSafety} from
  "./formProfilePhoto";
import type {OrganizerFormAssetDocument as Asset,
  OrganizerFormResponseDocument as Response} from
  "../shared/generated/firestoreAdminTypes";

function fixture() {
  const response = {respondentUid: "person", organizerId: "org",
    formId: "form", versionId: "version", draftId: "draft",
    status: "submitted", withdrawnAt: null, answers: {photo: ["asset"]}} as
    unknown as Response;
  const asset = {respondentUid: "person", organizerId: "org", formId: "form",
    versionId: "version", draftId: "draft", questionId: "photo",
    status: "ready", deletedAt: null, expiresAt: Timestamp.fromMillis(2000),
    sizeBytes: 1000, contentType: "image/jpeg",
    storagePath: "organizerForms/form/draft/asset"} as Asset;
  return {uid: "person", questionId: "photo", assetId: "asset", response,
    asset, now: Timestamp.fromMillis(1000)};
}

test("photo claims bind every asset owner and source dimension", () => {
  assert.doesNotThrow(() => assertClaimPhotoAsset(fixture()));
  for (const patch of [{respondentUid: "foreign"}, {organizerId: "foreign"},
    {formId: "foreign"}, {versionId: "foreign"}, {draftId: "foreign"},
    {questionId: "foreign"}, {status: "deleted"},
    {deletedAt: Timestamp.fromMillis(500)},
    {expiresAt: Timestamp.fromMillis(500)}, {sizeBytes: 0},
    {sizeBytes: 10 * 1024 * 1024 + 1}, {contentType: "application/pdf"},
    {storagePath: "users/another/photos/private.jpg"}]) {
    const input = fixture();
    assert.throws(() => assertClaimPhotoAsset({...input,
      asset: {...input.asset, ...patch} as Asset}), /unavailable/u);
  }
  for (const patch of [{respondentUid: "foreign"}, {status: "withdrawn"},
    {withdrawnAt: Timestamp.fromMillis(500)}, {answers: {photo: ["other"]}},
    {answers: {photo: ["asset", "second"]}}]) {
    const input = fixture();
    assert.throws(() => assertClaimPhotoAsset({...input,
      response: {...input.response, ...patch} as Response}), /unavailable/u);
  }
});

test("owned profile copies strip metadata and provide bounded JPEG derivatives",
  async () => {
    const source = await sharp({create: {width: 2400, height: 3000,
      channels: 3, background: "#8877aa"}})
      .withExif({IFD0: {Artist: "Private form source"}}).jpeg().toBuffer();
    assert.ok((await sharp(source).metadata()).exif);
    const copied = await normalizeFormProfilePhoto(source);
    const full = await sharp(copied.full).metadata();
    const thumb = await sharp(copied.thumbnail).metadata();
    assert.equal(full.format, "jpeg");
    assert.equal(full.width, 1600);
    assert.equal(full.height, 2000);
    assert.equal(full.exif, undefined);
    assert.equal(thumb.width, 160);
    assert.equal(thumb.height, 160);
    assert.equal(thumb.exif, undefined);
    await assert.rejects(normalizeFormProfilePhoto(
      Buffer.from("not an image")));
  });

test("photo safety rejects missing, unknown or blocked categories", () => {
  const safe = {adult: "VERY_UNLIKELY", violence: 1, racy: 2, medical: 3};
  assert.doesNotThrow(() => assertFormPhotoSafety(safe));
  for (const missing of [null, undefined, {}]) {
    assert.throws(() => assertFormPhotoSafety(missing));
  }
  for (const category of ["adult", "violence", "racy", "medical"]) {
    for (const value of [null, 0, "UNKNOWN", 5, "VERY_LIKELY"]) {
      assert.throws(() => assertFormPhotoSafety({...safe, [category]: value}));
    }
  }
});
