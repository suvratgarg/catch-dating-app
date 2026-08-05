import assert from "node:assert/strict";
import test from "node:test";
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {
  adminListCrossPathsShowcaseCandidatesHandler,
  adminSetCrossPathsShowcaseEligibilityHandler,
} from "./crossPathsShowcaseEligibility";

type FakeData = Record<string, unknown>;

class FakeTimestamp {
  constructor(private readonly iso: string) {}

  toDate(): Date {
    return new Date(this.iso);
  }

  toMillis(): number {
    return this.toDate().getTime();
  }
}

class FakeSnapshot {
  readonly id: string;

  constructor(readonly path: string, private readonly value?: FakeData) {
    this.id = path.split("/").at(-1) ?? "";
  }

  get exists(): boolean {
    return this.value !== undefined;
  }

  data(): FakeData | undefined {
    return this.value === undefined ? undefined : structuredClone(this.value);
  }
}

class FakeDocRef {
  readonly id: string;

  constructor(readonly firestore: FakeFirestore, readonly path: string) {
    this.id = path.split("/").at(-1) ?? "";
  }

  async get(): Promise<FakeSnapshot> {
    return new FakeSnapshot(this.path, this.firestore.get(this.path));
  }
}

class FakeCollectionRef {
  constructor(
    private readonly firestore: FakeFirestore,
    private readonly path: string
  ) {}

  doc(id?: string): FakeDocRef {
    return new FakeDocRef(
      this.firestore,
      `${this.path}/${id ?? this.firestore.autoId()}`
    );
  }
}

class FakeTransaction {
  private readonly writes: Array<() => void> = [];

  constructor(private readonly firestore: FakeFirestore) {}

  async get(ref: FakeDocRef): Promise<FakeSnapshot> {
    return new FakeSnapshot(ref.path, this.firestore.get(ref.path));
  }

  set(ref: FakeDocRef, data: FakeData): void {
    this.writes.push(() => this.firestore.set(ref.path, data));
  }

  commit(): void {
    this.writes.forEach((write) => write());
  }
}

class FakeFirestore {
  private nextId = 0;

  constructor(private readonly docs: Record<string, FakeData | undefined>) {}

  collection(path: string): FakeCollectionRef {
    return new FakeCollectionRef(this, path);
  }

  async getAll(...refs: FakeDocRef[]): Promise<FakeSnapshot[]> {
    return refs.map((ref) => new FakeSnapshot(ref.path, this.get(ref.path)));
  }

  async runTransaction<T>(
    callback: (transaction: FakeTransaction) => Promise<T>
  ): Promise<T> {
    const transaction = new FakeTransaction(this);
    const result = await callback(transaction);
    transaction.commit();
    return result;
  }

  get(path: string): FakeData | undefined {
    const value = this.docs[path];
    return value === undefined ? undefined : structuredClone(value);
  }

  set(path: string, value: FakeData): void {
    this.docs[path] = structuredClone(value);
  }

  autoId(): string {
    this.nextId += 1;
    return `auto-${this.nextId}`;
  }

  auditLogs(): FakeData[] {
    return Object.entries(this.docs)
      .filter(([path, value]) =>
        path.startsWith("adminAuditLogs/") && value !== undefined
      )
      .map(([, value]) => value as FakeData);
  }
}

test("reviewers can list a score-free exact candidate projection", async () => {
  const harness = createHarness({
    "publicProfiles/rhea": readyProfile(),
  });

  const result = await adminListCrossPathsShowcaseCandidatesHandler(
    request({uid: "rhea"}, "support"),
    harness.deps
  );

  assert.equal(result.candidates.length, 1);
  assert.equal(result.candidates[0]?.name, "Rhea");
  assert.equal(result.candidates[0]?.automaticStatus, "ready");
  assert.equal(result.candidates[0]?.effectiveStatus, "needsReview");
  assert.equal("score" in (result.candidates[0] ?? {}), false);
});

test(
  "an eligible decision is fingerprint-bound, versioned, and audited",
  async () => {
    const harness = createHarness({
      "publicProfiles/rhea": readyProfile(),
    });

    const result = await adminSetCrossPathsShowcaseEligibilityHandler(
      request({
        uid: "rhea",
        status: "eligible",
        reviewChecklist: completeChecklist(),
        reviewNote: "Primary portrait and current profile reviewed.",
      }, "safetyReviewer"),
      harness.deps
    );

    assert.equal(result.status, "eligible");
    assert.equal(result.reviewVersion, 1);
    assert.match(result.profileFingerprint, /^[a-f0-9]{64}$/u);
    assert.equal(
      harness.firestore.get("crossPathsShowcaseEligibility/rhea")?.status,
      "eligible"
    );
    assert.equal(harness.firestore.auditLogs().length, 1);
    assert.equal(
      harness.firestore.auditLogs()[0]?.action,
      "adminSetCrossPathsShowcaseEligibility"
    );
  }
);

test("objective blockers prevent approval", async () => {
  const profile = readyProfile();
  profile.profilePhotos = [photo("one")];
  const harness = createHarness({"publicProfiles/rhea": profile});

  await assert.rejects(
    () => adminSetCrossPathsShowcaseEligibilityHandler(
      request({
        uid: "rhea",
        status: "eligible",
        reviewChecklist: completeChecklist(),
        reviewNote: "Attempted review.",
      }, "admin"),
      harness.deps
    ),
    (error: unknown) => error instanceof HttpsError &&
      error.code === "failed-precondition"
  );
});

test(
  "support can read the queue but cannot make eligibility decisions",
  async () => {
    const harness = createHarness({"publicProfiles/rhea": readyProfile()});

    await assert.rejects(
      () => adminSetCrossPathsShowcaseEligibilityHandler(
        request({
          uid: "rhea",
          status: "paused",
          reviewChecklist: {
            primaryPortraitClear: false,
            profileRepresentsCurrentMember: false,
            showcasePolicyReviewed: false,
          },
          reviewNote: "Pause for reviewer follow-up.",
        }, "support"),
        harness.deps
      ),
      (error: unknown) => error instanceof HttpsError &&
      error.code === "permission-denied"
    );
  }
);

function createHarness(initialDocs: Record<string, FakeData | undefined>) {
  const firestore = new FakeFirestore(initialDocs);
  const now = new FakeTimestamp("2026-08-05T10:00:00.000Z");
  return {
    firestore,
    deps: {
      firestore: () =>
        firestore as unknown as FirebaseFirestore.Firestore,
      now: () => now as unknown as FirebaseFirestore.Timestamp,
      serverTimestamp: () =>
        now as unknown as FirebaseFirestore.FieldValue,
      documentIdField: () =>
        "__name__" as unknown as FirebaseFirestore.FieldPath,
    },
  };
}

function request(
  data: unknown,
  role: "admin" | "adminOwner" | "safetyReviewer" | "support"
): CallableRequest<unknown> {
  return {
    data,
    auth: {uid: "reviewer-1", token: {[role]: true}},
  } as unknown as CallableRequest<unknown>;
}

function completeChecklist() {
  return {
    primaryPortraitClear: true,
    profileRepresentsCurrentMember: true,
    showcasePolicyReviewed: true,
  };
}

function readyProfile(): FakeData {
  return {
    name: "Rhea",
    age: 28,
    gender: "woman",
    city: "mumbai",
    relationshipGoal: "longTermRelationship",
    activityPreferences: {running: {}},
    profilePhotos: [photo("one"), photo("two"), photo("three")],
    profilePrompts: [
      {prompt: "Ideal Sunday", answer: "A long walk and dosa."},
      {prompt: "Together we could", answer: "Try every quiz night."},
      {prompt: "I am known for", answer: "Making the plan happen."},
    ],
  };
}

function photo(id: string): FakeData {
  return {
    id,
    url: `https://images.example/${id}.jpg`,
    thumbnailUrl: `https://images.example/${id}-thumb.jpg`,
    storagePath: `profiles/rhea/${id}.jpg`,
    thumbnailStoragePath: `profiles/rhea/${id}-thumb.jpg`,
    moderation: {status: "approved"},
  };
}
