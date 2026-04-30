import assert from "node:assert/strict";
import test from "node:test";
import {
  resolveWaitlistCorsOrigin,
  waitlistAllowedOrigins,
} from "./joinWaitlist";

test("waitlistAllowedOrigins includes production custom domains", () => {
  const origins = waitlistAllowedOrigins("catch-dating-app-64e51");

  assert.equal(origins.has("https://catchdates.com"), true);
  assert.equal(origins.has("https://www.catchdates.com"), true);
  assert.equal(
    origins.has("https://catch-dating-app-64e51.web.app"),
    true
  );
});

test("waitlistAllowedOrigins scopes non-prod projects", () => {
  const origins = waitlistAllowedOrigins("catchdates-dev");

  assert.equal(origins.has("https://catchdates-dev.web.app"), true);
  assert.equal(origins.has("https://catchdates-dev.firebaseapp.com"), true);
  assert.equal(origins.has("https://catchdates.com"), false);
});

test("resolveWaitlistCorsOrigin rejects unknown origins", () => {
  assert.equal(
    resolveWaitlistCorsOrigin(
      "https://attacker.example",
      "catch-dating-app-64e51"
    ),
    null
  );
});
