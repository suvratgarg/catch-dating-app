# Email Draft: Test mock migration — fake_cloud_firestore + firebase_auth_mocks

## Why

The project has 513 lines of hand-rolled Firestore and FirebaseAuth test
doubles across two files:

- `test/chats/firestore_repository_test_helpers.dart` (347 lines):
  `TestFirebaseFirestore`, `TestRawCollection`, `TestTypedCollection`,
  `TestTypedQuery`, `TestWriteBatch`, etc.

- `test/auth/auth_test_helpers.dart` (166 lines):
  `TestFirebaseAuth`, `TestUser`, `TestUserCredential`, `FakeAuthRepository`

These are essentially reimplementations of what `fake_cloud_firestore` and
`firebase_auth_mocks` already provide as well-maintained, community-tested
packages.

## What to add

```yaml
# pubspec.yaml dev_dependencies
fake_cloud_firestore: ^3.0.0
firebase_auth_mocks: ^0.14.0
```

## Migration plan

### Step 1: Replace Firestore test infrastructure

`fake_cloud_firestore` provides `FakeFirebaseFirestore` which supports:
- `collection().doc().set()/get()/update()/delete()`
- `where()`, `orderBy()`, `limit()` queries
- `snapshots()` streams
- Batch writes and transactions
- Subcollections

The 347-line `firestore_repository_test_helpers.dart` can be deleted and
replaced with `FakeFirebaseFirestore()` in test setup code.

```dart
// Before
final firestore = TestFirebaseFirestore();
firestore.collection('users').doc('uid-1').set({'name': 'Alice'});

// After
final firestore = FakeFirebaseFirestore();
await firestore.collection('users').doc('uid-1').set({'name': 'Alice'});
```

### Step 2: Replace Auth test infrastructure

`firebase_auth_mocks` provides `MockFirebaseAuth` which supports:
- `signInWithCredential()` / `signOut()`
- `authStateChanges()` stream
- `currentUser` getter
- `verifyPhoneNumber()` for testing phone auth flows

The 166-line `auth_test_helpers.dart` can be deleted and replaced with
`MockFirebaseAuth()`.

### Step 3: Update test imports

Each test file currently importing from the local helpers should import from
the packages instead. The test logic (assertions, test cases) stays unchanged.

## Risk assessment

- **Medium risk** — test infrastructure changes can break tests in subtle ways
- **Mitigation:** Run the full test suite after migration
  ```bash
  flutter test
  cd functions && npm test
  ```
- **Rollback:** If packages don't cover a specific edge case, keep the local
  helper for that case and migrate the rest

## Estimated effort

~2-3 hours. The largest chunk is updating the chat repository tests which
use `TestTypedCollection` and `TestTypedQuery` extensively.
