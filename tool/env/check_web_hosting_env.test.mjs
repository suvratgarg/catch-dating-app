import assert from "node:assert/strict";
import {spawnSync} from "node:child_process";
import test from "node:test";
import {fileURLToPath} from "node:url";

const scriptPath = fileURLToPath(
  new URL("./check_web_hosting_env.mjs", import.meta.url)
);

const validMarketingEnv = {
  VITE_FIREBASE_API_KEY: "api-key",
  VITE_FIREBASE_AUTH_DOMAIN: "catch.example",
  VITE_FIREBASE_PROJECT_ID: "catch-dating-app-64e51",
  VITE_FIREBASE_STORAGE_BUCKET: "catch.example",
  VITE_FIREBASE_MESSAGING_SENDER_ID: "123",
  VITE_FIREBASE_APP_ID: "app-id",
  VITE_FIREBASE_MEASUREMENT_ID: "measurement-id",
  VITE_WEBSITE_APPCHECK_SITE_KEY: "site-key",
  VITE_APP_STORE_URL: "https://apps.apple.com/in/app/catch/id1234567890",
  VITE_PLAY_STORE_URL:
    "https://play.google.com/store/apps/details?id=com.catchdating.catch",
};

test("marketing deploy validation requires both live store product URLs", () => {
  const missing = runMarketing({
    VITE_APP_STORE_URL: "",
    VITE_PLAY_STORE_URL: "",
  });
  assert.equal(missing.status, 1);
  assert.match(missing.stderr, /VITE_APP_STORE_URL is required/u);
  assert.match(missing.stderr, /VITE_PLAY_STORE_URL is required/u);

  const invalid = runMarketing({
    VITE_APP_STORE_URL: "https://example.com/app",
    VITE_PLAY_STORE_URL: "https://play.google.com/store/apps/details",
  });
  assert.equal(invalid.status, 1);
  assert.match(invalid.stderr, /VITE_APP_STORE_URL must be an HTTPS apps\.apple\.com/u);
  assert.match(invalid.stderr, /VITE_PLAY_STORE_URL must be an HTTPS play\.google\.com/u);

  const valid = runMarketing();
  assert.equal(valid.status, 0, valid.stderr);
  assert.match(valid.stdout, /marketing hosting environment validation passed/u);
});

function runMarketing(overrides = {}) {
  return spawnSync(process.execPath, [scriptPath, "marketing"], {
    cwd: fileURLToPath(new URL("../..", import.meta.url)),
    encoding: "utf8",
    env: {...process.env, ...validMarketingEnv, ...overrides},
  });
}
