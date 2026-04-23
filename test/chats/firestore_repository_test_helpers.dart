// ignore_for_file: must_be_immutable, override_on_non_overriding_member, subtype_of_sealed_class

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

class TestFirebaseFirestore extends Fake implements FirebaseFirestore {
  TestFirebaseFirestore({required this.collectionsByPath, this.batchValue});

  final Map<String, CollectionReference<Map<String, dynamic>>> collectionsByPath;
  TestWriteBatch? batchValue;

  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    final collection = collectionsByPath[collectionPath];
    if (collection == null) {
      throw UnimplementedError('Unexpected collection path: $collectionPath');
    }
    return collection;
  }

  @override
  WriteBatch batch() => batchValue!;
}

class TestRawCollection<T extends Object?> extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  TestRawCollection({
    required this.pathPrefix,
    this.convertedCollection,
    this.autoDocId = 'generated-id',
  });

  final String pathPrefix;
  final CollectionReference<T>? convertedCollection;
  final String autoDocId;
  final docsById = <String, TestRawDocumentReference>{};

  @override
  String get path => pathPrefix;

  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) {
    final id = path ?? autoDocId;
    return docsById.putIfAbsent(
      id,
      () => TestRawDocumentReference(pathPrefix: pathPrefix, id: id),
    );
  }

  @override
  CollectionReference<R> withConverter<R extends Object?>({
    required FromFirestore<R> fromFirestore,
    required ToFirestore<R> toFirestore,
  }) {
    if (convertedCollection == null || R != T) {
      throw UnimplementedError('Unexpected converter type: $R');
    }
    return convertedCollection! as CollectionReference<R>;
  }
}

class TestRawDocumentReference extends Fake
    implements DocumentReference<Map<String, dynamic>> {
  TestRawDocumentReference({required this.pathPrefix, required this.id});

  final String pathPrefix;

  @override
  final String id;

  final subcollections = <String, CollectionReference<Map<String, dynamic>>>{};

  @override
  String get path => '$pathPrefix/$id';

  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    final collection = subcollections[collectionPath];
    if (collection == null) {
      throw UnimplementedError(
        'Unexpected subcollection path: $collectionPath for $path',
      );
    }
    return collection;
  }
}

class TestTypedCollection<T extends Object?> extends Fake
    implements CollectionReference<T> {
  TestTypedCollection({required this.pathPrefix, this.autoDocId = 'generated-id'});

  final String pathPrefix;
  final String autoDocId;
  final docsById = <String, TestTypedDocumentReference<T>>{};
  Query<T>? nextWhereResult;
  Query<T>? nextOrderByResult;
  Object? lastWhereField;
  Object? lastArrayContains;
  Object? lastOrderByField;
  bool? lastOrderByDescending;

  @override
  String get path => pathPrefix;

  @override
  DocumentReference<T> doc([String? path]) {
    final id = path ?? autoDocId;
    return docsById.putIfAbsent(
      id,
      () => TestTypedDocumentReference<T>(pathPrefix: pathPrefix, id: id),
    );
  }

  @override
  Query<T> where(
    Object field, {
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isLessThan,
    Object? isLessThanOrEqualTo,
    Object? isGreaterThan,
    Object? isGreaterThanOrEqualTo,
    Object? arrayContains,
    Iterable<Object?>? arrayContainsAny,
    Iterable<Object?>? whereIn,
    Iterable<Object?>? whereNotIn,
    bool? isNull,
  }) {
    lastWhereField = field;
    lastArrayContains = arrayContains;
    return nextWhereResult!;
  }

  @override
  Query<T> orderBy(Object field, {bool descending = false}) {
    lastOrderByField = field;
    lastOrderByDescending = descending;
    return nextOrderByResult!;
  }
}

class TestTypedDocumentReference<T extends Object?> extends Fake
    implements DocumentReference<T> {
  TestTypedDocumentReference({required this.pathPrefix, required this.id});

  final String pathPrefix;

  @override
  final String id;

  Stream<DocumentSnapshot<T>> snapshotStream = const Stream.empty();
  final updateCalls = <Map<Object, Object?>>[];
  Object? updateError;

  @override
  String get path => '$pathPrefix/$id';

  @override
  Stream<DocumentSnapshot<T>> snapshots({
    bool includeMetadataChanges = false,
    ListenSource source = ListenSource.defaultSource,
  }) => snapshotStream;

  @override
  Future<void> update(Map<Object, Object?> data) async {
    if (updateError != null) {
      throw updateError!;
    }
    updateCalls.add(data);
  }
}

class TestTypedDocumentSnapshot<T extends Object?> extends Fake
    implements DocumentSnapshot<T> {
  TestTypedDocumentSnapshot({
    required this.referenceValue,
    required this.existsValue,
    required this.dataValue,
  });

  @override
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

class TestTypedQueryDocumentSnapshot<T extends Object?> extends Fake
    implements QueryDocumentSnapshot<T> {
  TestTypedQueryDocumentSnapshot({
    required this.referenceValue,
    required this.dataValue,
  });

  @override
  final DocumentReference<T> referenceValue;
  final T dataValue;

  @override
  bool get exists => true;

  @override
  String get id => referenceValue.id;

  @override
  DocumentReference<T> get reference => referenceValue;

  @override
  T data() => dataValue;
}

class TestTypedQuerySnapshot<T extends Object?> extends Fake
    implements QuerySnapshot<T> {
  TestTypedQuerySnapshot(this.docsValue);

  final List<QueryDocumentSnapshot<T>> docsValue;

  @override
  List<QueryDocumentSnapshot<T>> get docs => docsValue;
}

class TestTypedQuery<T extends Object?> extends Fake implements Query<T> {
  TestTypedQuery({required this.snapshotStream});

  final Stream<QuerySnapshot<T>> snapshotStream;
  Object? lastOrderByField;
  bool? lastOrderByDescending;

  @override
  Query<T> orderBy(Object field, {bool descending = false}) {
    lastOrderByField = field;
    lastOrderByDescending = descending;
    return this;
  }

  @override
  Stream<QuerySnapshot<T>> snapshots({
    bool includeMetadataChanges = false,
    ListenSource source = ListenSource.defaultSource,
  }) => snapshotStream;
}

class RecordedSetCall {
  const RecordedSetCall({
    required this.document,
    required this.data,
    this.options,
  });

  final Object document;
  final Object? data;
  final SetOptions? options;
}

class RecordedUpdateCall {
  const RecordedUpdateCall({required this.document, required this.data});

  final Object document;
  final Map<String, dynamic> data;
}

class TestWriteBatch extends Fake implements WriteBatch {
  final setCalls = <RecordedSetCall>[];
  final updateCalls = <RecordedUpdateCall>[];
  bool commitCalled = false;

  @override
  void set<T>(DocumentReference<T> document, T data, [SetOptions? options]) {
    setCalls.add(
      RecordedSetCall(document: document, data: data, options: options),
    );
  }

  @override
  void update(DocumentReference document, Map<String, dynamic> data) {
    updateCalls.add(RecordedUpdateCall(document: document, data: data));
  }

  @override
  Future<void> commit() async {
    commitCalled = true;
  }
}
