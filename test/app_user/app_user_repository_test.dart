// ignore_for_file: must_be_immutable, override_on_non_overriding_member, subtype_of_sealed_class

import 'package:catch_dating_app/app_user/data/app_user_repository.dart';
import 'package:catch_dating_app/app_user/domain/app_user.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import '../runs/runs_test_helpers.dart';

class TestFirebaseFirestore extends Fake implements FirebaseFirestore {
  TestFirebaseFirestore({
    required this.usersCollection,
    required this.publicProfilesCollection,
  });

  final CollectionReference<Map<String, dynamic>> usersCollection;
  final CollectionReference<Map<String, dynamic>> publicProfilesCollection;

  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    switch (collectionPath) {
      case 'users':
        return usersCollection;
      case 'publicProfiles':
        return publicProfilesCollection;
      default:
        throw UnimplementedError('Unexpected collection path: $collectionPath');
    }
  }
}

class TestRawCollection<T> extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  TestRawCollection(this.convertedCollection);

  final TestTypedCollection<T> convertedCollection;
  FromFirestore<T>? lastFromFirestore;
  ToFirestore<T>? lastToFirestore;

  @override
  CollectionReference<R> withConverter<R>({
    required FromFirestore<R> fromFirestore,
    required ToFirestore<R> toFirestore,
  }) {
    if (R != T) {
      throw UnimplementedError('Unexpected converter type: $R');
    }
    lastFromFirestore = fromFirestore as FromFirestore<T>;
    lastToFirestore = toFirestore as ToFirestore<T>;
    return convertedCollection as CollectionReference<R>;
  }
}

class TestTypedCollection<T> extends Fake implements CollectionReference<T> {
  TestTypedCollection(this.pathPrefix);

  final String pathPrefix;
  final docsById = <String, TestTypedDocumentReference<T>>{};

  @override
  DocumentReference<T> doc([String? path]) {
    final id = path ?? 'generated-id';
    return docsById.putIfAbsent(
      id,
      () => TestTypedDocumentReference<T>(pathPrefix: pathPrefix, id: id),
    );
  }
}

class TestTypedDocumentReference<T> extends Fake
    implements DocumentReference<T> {
  TestTypedDocumentReference({required this.pathPrefix, required this.id});

  final String pathPrefix;

  @override
  final String id;

  T? getResultData;
  bool getResultExists = true;
  final setCalls = <T>[];
  final updateCalls = <Map<Object, Object?>>[];

  @override
  String get path => '$pathPrefix/$id';

  @override
  Future<DocumentSnapshot<T>> get([GetOptions? options]) async =>
      TestTypedDocumentSnapshot<T>(
        referenceValue: this,
        existsValue: getResultExists,
        dataValue: getResultData,
      );

  @override
  Future<void> set(T data, [SetOptions? options]) async {
    setCalls.add(data);
  }

  @override
  Future<void> update(Map<Object, Object?> data) async {
    updateCalls.add(data);
  }
}

class TestTypedDocumentSnapshot<T> extends Fake implements DocumentSnapshot<T> {
  TestTypedDocumentSnapshot({
    required this.referenceValue,
    required this.existsValue,
    required this.dataValue,
  });

  final DocumentReference<T> referenceValue;
  final bool existsValue;
  final T? dataValue;

  @override
  bool get exists => existsValue;

  @override
  String get id => referenceValue.id;

  @override
  DocumentReference<T> get reference => referenceValue;

  @override
  T? data() => dataValue;
}

void main() {
  group('AppUserRepository', () {
    late TestTypedCollection<AppUser> usersCollection;
    late TestTypedCollection<PublicProfile> publicProfilesCollection;
    late AppUserRepository repository;

    setUp(() {
      usersCollection = TestTypedCollection<AppUser>('users');
      publicProfilesCollection = TestTypedCollection<PublicProfile>(
        'publicProfiles',
      );
      repository = AppUserRepository(
        TestFirebaseFirestore(
          usersCollection: TestRawCollection<AppUser>(usersCollection),
          publicProfilesCollection: TestRawCollection<PublicProfile>(
            publicProfilesCollection,
          ),
        ),
      );
    });

    test('setAppUser keeps the public profile projection in sync', () async {
      final user =
          buildUser(
            uid: 'runner-42',
            name: 'Asha',
            photoUrls: const ['https://img.example/1.jpg'],
          ).copyWith(
            bio: 'Long runs, coffee, and easy Sunday plans.',
            occupation: 'Product Designer',
            company: 'Catch',
            relationshipGoal: RelationshipGoal.relationship,
            drinking: DrinkingHabit.socially,
          );
      final userDoc =
          usersCollection.doc(user.uid) as TestTypedDocumentReference<AppUser>;
      final publicProfileDoc =
          publicProfilesCollection.doc(user.uid)
              as TestTypedDocumentReference<PublicProfile>;

      await repository.setAppUser(appUser: user);

      expect(userDoc.setCalls, [user]);
      expect(publicProfileDoc.setCalls, [publicProfileFromAppUser(user)]);
    });

    test('updatePhotoUrls updates the user and public profile docs', () async {
      final urls = ['https://img.example/2.jpg', 'https://img.example/3.jpg'];
      final userDoc =
          usersCollection.doc('runner-42')
              as TestTypedDocumentReference<AppUser>;
      final publicProfileDoc =
          publicProfilesCollection.doc('runner-42')
              as TestTypedDocumentReference<PublicProfile>;
      final existingUser = buildUser(
        uid: 'runner-42',
        photoUrls: const ['https://img.example/old.jpg'],
      );
      userDoc.getResultData = existingUser;
      userDoc.getResultExists = true;

      await repository.updatePhotoUrls(uid: 'runner-42', photoUrls: urls);

      expect(userDoc.updateCalls, [
        {'photoUrls': urls},
      ]);
      expect(publicProfileDoc.setCalls, [
        publicProfileFromAppUser(existingUser.copyWith(photoUrls: urls)),
      ]);
    });
  });
}
