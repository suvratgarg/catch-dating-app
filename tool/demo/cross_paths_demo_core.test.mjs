import assert from "node:assert/strict";
import test from "node:test";
import {
  buildCrossPathsDemoDocuments,
  ensureCrossPathsDemoTestLogin,
} from "./cross_paths_demo_core.mjs";
import {loadFirebaseAdmin} from "./demo_ops_core.mjs";

const admin = loadFirebaseAdmin();

test("Cross Paths fixture writes only explicit synthetic consent and review", () => {
  const timestamp = admin.firestore.Timestamp.fromMillis(1_700_000_000_000);
  const helpers = {
    currentCrossPathsTermsVersion: 1,
    crossPathsShowcaseRuleVersion: 1,
  };
  const docs = buildCrossPathsDemoDocuments({
    viewer: user("viewer"),
    candidates: [candidate("candidate-a", "a".repeat(64)), candidate(
      "candidate-b",
      "b".repeat(64)
    )],
    eventId: "demo-event",
    nowTimestamp: timestamp,
    testPhone: "+16505550101",
    helpers,
  });

  assert.deepEqual(docs.map((doc) => doc.path), [
    "users/viewer",
    "users/candidate-a",
    "users/candidate-b",
    "eventCrossPathsConsents/demo-event_candidate-a",
    "crossPathsShowcaseEligibility/candidate-a",
    "eventCrossPathsConsents/demo-event_candidate-b",
    "crossPathsShowcaseEligibility/candidate-b",
  ]);
  assert.deepEqual(docs[0].data, {
    prefsShowInCrossPaths: true,
    prefsCrossPathsInvitations: true,
    phoneNumber: "+16505550101",
  });
  assert.equal(docs[1].data.phoneNumber, undefined);
  assert.equal(docs[3].data.enabled, true);
  assert.equal(docs[3].data.termsVersion, 1);
  assert.equal(docs[4].data.status, "eligible");
  assert.equal(docs[4].data.profileFingerprint, "a".repeat(64));
  assert.equal(docs[4].data.reviewedByUid, "cross-paths-demo-seed");
});

test("unchanged eligible review remains idempotent", () => {
  const originalTimestamp =
    admin.firestore.Timestamp.fromMillis(1_700_000_000_000);
  const rerunTimestamp =
    admin.firestore.Timestamp.fromMillis(1_700_000_100_000);
  const fingerprint = "c".repeat(64);
  const path = "crossPathsShowcaseEligibility/candidate";
  const docs = buildCrossPathsDemoDocuments({
    viewer: user("viewer"),
    candidates: [candidate("candidate", fingerprint)],
    eventId: "demo-event",
    nowTimestamp: rerunTimestamp,
    testPhone: null,
    helpers: {
      currentCrossPathsTermsVersion: 1,
      crossPathsShowcaseRuleVersion: 1,
    },
    existingRecords: new Map([[path, {
      status: "eligible",
      ruleVersion: 1,
      reviewVersion: 4,
      profileFingerprint: fingerprint,
      reviewedAt: originalTimestamp,
    }]]),
  });
  const review = docs.find((doc) => doc.path === path).data;

  assert.equal(review.reviewVersion, 4);
  assert.equal(review.reviewedAt.toMillis(), originalTimestamp.toMillis());
  assert.equal(review.updatedAt.toMillis(), rerunTimestamp.toMillis());
});

test("test login merges Identity config and creates only the named Auth user",
  async () => {
    const requests = [];
    const auth = fakeAuth();
    const adminStub = {
      auth: () => auth,
      app: () => ({
        options: {
          credential: {
            getAccessToken: async () => ({access_token: "token"}),
          },
        },
      }),
    };
    const fetchImpl = async (url, options = {}) => {
      requests.push({url, options});
      if (!options.method) {
        return response({
          signIn: {phone: {testPhoneNumbers: {"+16505550100": "111111"}}},
        });
      }
      return response({});
    };

    const result = await ensureCrossPathsDemoTestLogin({
      admin: adminStub,
      projectId: "catchdates-dev",
      viewerUid: "demo-viewer",
      phoneNumber: "+16505550101",
      smsCode: "604219",
      fetchImpl,
    });

    assert.equal(result.viewerUid, "demo-viewer");
    assert.equal(result.phoneSuffix, "0101");
    assert.equal(result.testPhoneConfigChanged, true);
    assert.deepEqual(auth.created, [{
      uid: "demo-viewer",
      phoneNumber: "+16505550101",
      displayName: "Cross Paths Demo Viewer",
      disabled: false,
    }]);
    assert.equal(requests.length, 2);
    const patch = JSON.parse(requests[1].options.body);
    assert.deepEqual(patch.signIn.phone.testPhoneNumbers, {
      "+16505550100": "111111",
      "+16505550101": "604219",
    });
  }
);

test("test login refuses to replace an existing Auth phone", async () => {
  const adminStub = {
    auth: () => ({
      getUser: async () => ({
        uid: "demo-viewer",
        phoneNumber: "+16505550109",
      }),
    }),
  };

  await assert.rejects(
    ensureCrossPathsDemoTestLogin({
      admin: adminStub,
      projectId: "catchdates-dev",
      viewerUid: "demo-viewer",
      phoneNumber: "+16505550101",
      smsCode: "604219",
    }),
    /already uses a different phone number/
  );
});

test("test login refuses phone numbers outside the fictional fixture range",
  async () => {
    await assert.rejects(
      ensureCrossPathsDemoTestLogin({
        admin: {},
        projectId: "catchdates-dev",
        viewerUid: "demo-viewer",
        phoneNumber: "+14155550100",
        smsCode: "604219",
      }),
      /fictional \+1 650-555-01xx range/
    );
  }
);

function user(uid) {
  return {uid, data: {synthetic: true, profileComplete: true}};
}

function candidate(uid, profileFingerprint) {
  return {
    ...user(uid),
    publicProfile: {name: uid},
    readiness: {automaticStatus: "ready", profileFingerprint},
  };
}

function fakeAuth() {
  return {
    created: [],
    async getUser() {
      const error = new Error("missing");
      error.code = "auth/user-not-found";
      throw error;
    },
    async createUser(input) {
      this.created.push(input);
      return {
        ...input,
        metadata: {creationTime: "2026-08-09T00:00:00.000Z"},
      };
    },
  };
}

function response(value, status = 200) {
  return {
    ok: status >= 200 && status < 300,
    status,
    json: async () => value,
  };
}
