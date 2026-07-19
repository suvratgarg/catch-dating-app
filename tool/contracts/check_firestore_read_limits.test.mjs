import assert from "node:assert/strict";
import test from "node:test";

import {
  hardcodedReadLimits,
  unboundedCollectionReads,
  validateReadLimits,
} from "./check_firestore_read_limits.mjs";

test("known-bad numeric repository limit is detected", () => {
  const findings = hardcodedReadLimits(
    "Future<void> load() async { query.limit(50); }",
    "lib/example/data/example_repository.dart"
  );
  assert.equal(findings.length, 1);
  assert.equal(findings[0].value, 50);
  assert.equal(findings[0].line, 1);
});

test("known-bad numeric limit default is detected", () => {
  const findings = validateReadLimits([
    {
      path: "lib/example/data/example_repository.dart",
      contents: "void load({int limit = 20}) {}",
    },
  ]);
  assert.equal(findings.length, 1);
  assert.equal(findings[0].value, 20);
});

test("ReadLimitPolicy references pass", () => {
  const findings = hardcodedReadLimits(
    "query.limit(ReadLimitPolicy.historyPage); " +
      "void load({int limit = ReadLimitPolicy.historyPage}) {}"
  );
  assert.deepEqual(findings, []);
});

test("unbounded collection reads are detected", () => {
  const findings = unboundedCollectionReads(`
    () => collection
      .where('uid', isEqualTo: uid)
      .snapshots()
  `);
  assert.equal(findings.length, 1);
  assert.equal(findings[0].kind, "unbounded");
});

test("bounded, point, and reviewed-exception reads pass", () => {
  const findings = unboundedCollectionReads(`
    () => collection.where('uid', isEqualTo: uid)
      .limit(ReadLimitPolicy.historyPage)
      .snapshots()
    () => collection.doc(uid).snapshots()
    // firestore-read-exception: READ-EXCEPTION-BOUNDED-SET
    () => collection.where('uid', isEqualTo: uid).get()
  `);
  assert.deepEqual(findings, []);
});
