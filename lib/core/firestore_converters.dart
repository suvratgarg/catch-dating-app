import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

typedef FirestoreFromJson<T> = T Function(Map<String, dynamic> json);
typedef FirestoreToJson<T> = Map<String, dynamic> Function(T value);

class TimestampConverter implements JsonConverter<DateTime, Object?> {
  const TimestampConverter();

  @override
  DateTime fromJson(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    throw FormatException('Expected Firestore Timestamp, got $value.');
  }

  @override
  Timestamp toJson(DateTime dt) => Timestamp.fromDate(dt);
}

class NullableTimestampConverter implements JsonConverter<DateTime?, Object?> {
  const NullableTimestampConverter();

  @override
  DateTime? fromJson(Object? value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    throw FormatException('Expected Firestore Timestamp or null, got $value.');
  }

  @override
  Timestamp? toJson(DateTime? dt) => dt != null ? Timestamp.fromDate(dt) : null;
}

extension DocumentIdCollectionConverter
    on CollectionReference<Map<String, dynamic>> {
  CollectionReference<T> withDocumentIdConverter<T>({
    required String idField,
    required FirestoreFromJson<T> fromJson,
    required FirestoreToJson<T> toJson,
  }) {
    return withConverter<T>(
      fromFirestore: (doc, _) {
        final data = doc.data();
        if (data == null) {
          throw StateError(
            'Missing Firestore data for ${doc.reference.path}; cannot decode $T.',
          );
        }
        return fromJson({...data, idField: doc.id});
      },
      toFirestore: (value, _) => toJson(value),
    );
  }
}
