/* eslint-disable require-jsdoc */
import assert from "node:assert/strict";
import test from "node:test";
import {storagePathFromDownloadUrl} from "./accountDeletion";

test(
  "storagePathFromDownloadUrl extracts Firebase Storage object paths",
  () => {
    assert.equal(
      storagePathFromDownloadUrl(
        "https://firebasestorage.googleapis.com/v0/b/demo.appspot.com/o/" +
          "users%2Frunner-1%2Fphotos%2F0_123.jpg?alt=media&token=abc"
      ),
      "users/runner-1/photos/0_123.jpg"
    );
  }
);

test("storagePathFromDownloadUrl returns null for invalid urls", () => {
  assert.equal(storagePathFromDownloadUrl("not a url"), null);
});
