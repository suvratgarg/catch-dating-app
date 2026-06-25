import assert from "node:assert/strict";
import test from "node:test";
import {CallableRequest} from "firebase-functions/v2/https";
import {BigQueryClient} from "../shared/bigQuery";
import {recordOrganizerAnalyticsEventHandler} from "./organizerAnalyticsEvents";

type FakeData = Record<string, unknown>;

class FakeDocRef {
  constructor(readonly firestore: FakeFirestore, readonly path: string) {}

  async get(): Promise<FakeSnapshot> {
    return new FakeSnapshot(this.firestore.get(this.path));
  }
}

class FakeSnapshot {
  constructor(private readonly value: FakeData | undefined) {}

  get exists(): boolean {
    return this.value !== undefined;
  }

  get(field: string): unknown {
    return this.value?.[field];
  }

  data(): FakeData | undefined {
    return this.value === undefined ? undefined : clone(this.value);
  }
}

class FakeCollectionRef {
  constructor(
    private readonly firestore: FakeFirestore,
    private readonly path: string
  ) {}

  doc(docId: string): FakeDocRef {
    return new FakeDocRef(this.firestore, `${this.path}/${docId}`);
  }
}

class FakeFirestore {
  constructor(private readonly docs: Record<string, FakeData | undefined>) {}

  collection(collectionPath: string): FakeCollectionRef {
    return new FakeCollectionRef(this, collectionPath);
  }

  get(path: string): FakeData | undefined {
    const data = this.docs[path];
    return data === undefined ? undefined : clone(data);
  }
}

class FakeBigQuery implements BigQueryClient {
  readonly inserted: Array<{
    datasetId: string;
    tableId: string;
    rows: Array<{insertId: string; json: Record<string, unknown>}>;
  }> = [];

  async query<T>(): Promise<T[]> {
    return [];
  }

  async insertRows(
    datasetId: string,
    tableId: string,
    rows: Array<{insertId: string; json: Record<string, unknown>}>
  ): Promise<void> {
    this.inserted.push({datasetId, tableId, rows});
  }
}

test("recordOrganizerAnalyticsEvent writes a BigQuery row", async () => {
  const bigQuery = new FakeBigQuery();

  await recordOrganizerAnalyticsEventHandler(
    callableRequest({
      clubId: "club-1",
      eventName: "eventView",
      eventId: "event-1",
      pagePath: "/organizers/saket-run-club/",
      source: "catch_event_card",
      sessionId: "browser-session-1",
      platform: "web",
    }),
    deps(new FakeFirestore(baseDocs()), bigQuery)
  );

  assert.equal(bigQuery.inserted.length, 1);
  assert.equal(bigQuery.inserted[0].datasetId, "catch_analytics");
  assert.equal(bigQuery.inserted[0].tableId, "host_analytics_events");
  assert.deepEqual(bigQuery.inserted[0].rows[0], {
    insertId: "club-1_event-1_eventView_1781776800000_event-id-1",
    json: {
      analytics_event_id:
        "club-1_event-1_eventView_1781776800000_event-id-1",
      occurred_at: "2026-06-18T10:00:00.000Z",
      event_date: "2026-06-18",
      event_name: "eventView",
      club_id: "club-1",
      target_event_id: "event-1",
      page_path: "/organizers/saket-run-club/",
      source: "catch_event_card",
      session_hash:
        "ef003991504917232e858519f5d90e2b814b2c54d6d4d7c62256ac937b83f99e",
      platform: "web",
      ingested_at: "2026-06-18T10:00:00.000Z",
    },
  });
});

test("recordOrganizerAnalyticsEvent rejects mismatched scope", async () => {
  await assert.rejects(
    () => recordOrganizerAnalyticsEventHandler(
      callableRequest({
        clubId: "club-1",
        eventId: "event-2",
        eventName: "eventView",
        pagePath: "/organizers/saket-run-club/",
      }),
      deps(new FakeFirestore({
        ...baseDocs(),
        "events/event-2": {clubId: "club-2"},
      }), new FakeBigQuery())
    ),
    (error: unknown) =>
      typeof error === "object" &&
      error !== null &&
      "code" in error &&
      error.code === "invalid-argument"
  );
});

test("recordOrganizerAnalyticsEvent rejects unpublished pages", async () => {
  await assert.rejects(
    () => recordOrganizerAnalyticsEventHandler(
      callableRequest({
        clubId: "club-1",
        eventName: "listingView",
        pagePath: "/organizers/saket-run-club/",
      }),
      deps(new FakeFirestore({
        ...baseDocs(),
        "clubs/club-1": clubDoc({
          publishStatus: "qa",
          robots: "noindex, follow",
        }),
      }), new FakeBigQuery())
    ),
    (error: unknown) =>
      typeof error === "object" &&
      error !== null &&
      "code" in error &&
      error.code === "failed-precondition"
  );
});

test("recordOrganizerAnalyticsEvent rejects noncanonical paths", async () => {
  await assert.rejects(
    () => recordOrganizerAnalyticsEventHandler(
      callableRequest({
        clubId: "club-1",
        eventName: "listingView",
        pagePath: "/organizers/other-club/",
      }),
      deps(new FakeFirestore(baseDocs()), new FakeBigQuery())
    ),
    (error: unknown) =>
      typeof error === "object" &&
      error !== null &&
      "code" in error &&
      error.code === "invalid-argument"
  );
});

test("recordOrganizerAnalyticsEvent accepts search appearances", async () => {
  const bigQuery = new FakeBigQuery();

  await recordOrganizerAnalyticsEventHandler(
    callableRequest({
      clubId: "club-1",
      eventName: "searchAppearance",
      pagePath: "/organizers/?q=saket",
    }),
    deps(new FakeFirestore(baseDocs()), bigQuery)
  );

  assert.equal(bigQuery.inserted.length, 1);
});

test("recordOrganizerAnalyticsEvent rejects rate-limited clients", async () => {
  await assert.rejects(
    () => recordOrganizerAnalyticsEventHandler(
      callableRequest({
        clubId: "club-1",
        eventName: "listingView",
        pagePath: "/organizers/saket-run-club/",
      }),
      deps(new FakeFirestore(baseDocs()), new FakeBigQuery(), false)
    ),
    (error: unknown) =>
      typeof error === "object" &&
      error !== null &&
      "code" in error &&
      error.code === "resource-exhausted"
  );
});

function deps(
  firestore: FakeFirestore,
  bigQuery: FakeBigQuery,
  allow = true
) {
  return {
    firestore: () =>
      firestore as unknown as FirebaseFirestore.Firestore,
    bigQuery,
    now: () => new Date("2026-06-18T10:00:00.000Z"),
    randomId: () => "event-id-1",
    checkIpRateLimit: () => allow,
  };
}

function baseDocs(): Record<string, FakeData> {
  return {
    "clubs/club-1": clubDoc(),
    "events/event-1": {clubId: "club-1"},
  };
}

function clubDoc(publicPageOverrides: FakeData = {}): FakeData {
  return {
    name: "Saket Run Club",
    status: "active",
    archived: false,
    claim: {
      state: "unclaimed",
      claimHref: "/host/#founding-hosts",
      lastClaimRequestId: null,
    },
    publicPage: {
      slug: "saket-run-club",
      citySlug: "delhi",
      canonicalPath: "/organizers/saket-run-club/",
      publishStatus: "published",
      indexStatus: "indexReady",
      robots: "index, follow",
      seoTitle: null,
      seoDescription: null,
      lastRenderedAt: null,
      ...publicPageOverrides,
    },
  };
}

function callableRequest(data: unknown): CallableRequest<unknown> {
  return {
    data,
    rawRequest: {
      get: (header: string) =>
        header === "x-forwarded-for" ? "203.0.113.10" : undefined,
      ip: "203.0.113.11",
      socket: {},
    },
  } as unknown as CallableRequest<unknown>;
}

function clone(data: FakeData): FakeData {
  return JSON.parse(JSON.stringify(data)) as FakeData;
}
