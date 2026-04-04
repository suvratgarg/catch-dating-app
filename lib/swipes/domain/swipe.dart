import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'swipe.freezed.dart';
part 'swipe.g.dart';

enum SwipeDirection { like, pass }

@freezed
abstract class Swipe with _$Swipe {
  const factory Swipe({
    required String swiperId,
    required String targetId,
    required String runId,
    required SwipeDirection direction,
    @TimestampConverter() required DateTime createdAt,
  }) = _Swipe;

  factory Swipe.fromJson(Map<String, dynamic> json) => _$SwipeFromJson(json);
}
