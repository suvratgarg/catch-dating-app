import assert from "node:assert/strict";
import test from "node:test";
import type {CallableRequest} from "firebase-functions/v2/https";
import {readFlightProviderConfig} from "./flightProviderConfig";
import {refreshProgramFlightStatuses, refreshProgramTravelLegHandler} from
  "./programFlightRefresh";
import {flightAlertWebhookHandler, FlightAlertAuthError} from "./flightAlerts";

const projectId = "catchdates-dev";
const version = `projects/${projectId}/secrets/FLIGHT_PROVIDER/versions/1`;
const config = {schema: "catch.flight-provider/v1", apiKey: "provider-key",
  webhookSecret: "a".repeat(48)};

test("unconfigured flight sync never reads a secret", async () => {
  assert.equal(await readFlightProviderConfig({version: " ",
    projectId: undefined, readSecret: async () => {
      throw new Error("must not access Secret Manager");
    }}), null);
});

test("flight credentials require a pinned version in this project",
  async () => {
    for (const invalid of [version.replace(projectId, "catchdates-prod"),
      version.replace("/1", "/latest"), `${version}\nx=y`,
      "private-key-value"]) {
      let reads = 0;
      await assert.rejects(readFlightProviderConfig({
        version: invalid, projectId,
        readSecret: async () => {
          reads++; return JSON.stringify(config);
        }}),
      {code: "failed-precondition"});
      assert.equal(reads, 0);
    }
    assert.deepEqual(await readFlightProviderConfig({version, projectId,
      readSecret: async (name) => {
        assert.equal(name, version);
        return JSON.stringify(config);
      }}), {apiKey: config.apiKey, webhookSecret: config.webhookSecret});
  });

test("bad or unavailable flight credentials fail closed without secret content",
  async () => {
    for (const raw of ["not-json", "null", "[]", JSON.stringify({...config,
      webhookSecret: "short"}), JSON.stringify({...config, apiKey: ""}),
    JSON.stringify({...config, extra: "unexpected"}), "x".repeat(33 * 1024)]) {
      await assert.rejects(readFlightProviderConfig({version, projectId,
        readSecret: async () => raw}), {code: "failed-precondition",
        message: "Flight sync is not configured. Use manual arrival updates."});
    }
    await assert.rejects(readFlightProviderConfig({version, projectId,
      readSecret: async () => {
        throw new Error("sensitive-provider-error");
      }}),
    {message: "Flight sync is not configured. Use manual arrival updates."});
  });

test("disabled flight entry points never access Firestore or a provider",
  async () => {
    const previous = process.env.FLIGHT_PROVIDER_CONFIG_VERSION;
    process.env.FLIGHT_PROVIDER_CONFIG_VERSION = " ";
    try {
    // No Firebase app or service credentials exist in this test process.
      await refreshProgramFlightStatuses.run({
        scheduleTime: "2026-09-23T00:00:00Z",
      });
      await assert.rejects(refreshProgramTravelLegHandler({
        auth: {uid: "test-actor"}, data: {},
      } as CallableRequest<unknown>), {code: "failed-precondition"});
      await assert.rejects(flightAlertWebhookHandler({key: "guess"}, {}),
        FlightAlertAuthError);
    } finally {
      if (previous === undefined) {
        delete process.env.FLIGHT_PROVIDER_CONFIG_VERSION;
      } else {
        process.env.FLIGHT_PROVIDER_CONFIG_VERSION = previous;
      }
    }
  });
