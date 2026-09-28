import assert from "node:assert/strict";
import test from "node:test";
import {privateEventReleaseKeys, readPrivateEventReleaseReadiness} from
  "./privateEventReleaseConfig";

const parameter = (value: unknown) => ({defaultValue: {value}});

test("only exact server template default true opens each independent gate",
  async () => {
    const result = await readPrivateEventReleaseReadiness(async () => ({
      parameters: {
        [privateEventReleaseKeys.privacy]: parameter("true"),
        [privateEventReleaseKeys.seatWriters]: parameter(true),
        [privateEventReleaseKeys.offers]: {
          conditionalValues: {client: {value: "true"}},
        },
      },
    }));
    assert.deepEqual(result, {privacy: true, seatWriters: false,
      offers: false});
  });

test("missing, failed and timed-out Admin reads are closed without caching",
  async () => {
    const open = async () => ({parameters: {
      [privateEventReleaseKeys.privacy]: parameter("true"),
      [privateEventReleaseKeys.seatWriters]: parameter("true"),
      [privateEventReleaseKeys.offers]: parameter("true"),
    }});
    assert.deepEqual(await readPrivateEventReleaseReadiness(open),
      {privacy: true, seatWriters: true, offers: true});
    assert.deepEqual(await readPrivateEventReleaseReadiness(async () => {
      throw new Error("unavailable");
    }), {privacy: false, seatWriters: false, offers: false});
    let finishLateRead: ((value: unknown) => void) | undefined;
    const lateRead = new Promise<unknown>((resolve) => {
      finishLateRead = resolve;
    });
    assert.deepEqual(await readPrivateEventReleaseReadiness(
      () => lateRead, 1),
    {privacy: false, seatWriters: false, offers: false});
    finishLateRead?.(await open());
    assert.deepEqual(await readPrivateEventReleaseReadiness(async () => {
      throw new Error("later read failed");
    }), {privacy: false, seatWriters: false, offers: false});
    assert.deepEqual(await readPrivateEventReleaseReadiness(async () => ({})),
      {privacy: false, seatWriters: false, offers: false});
  });
