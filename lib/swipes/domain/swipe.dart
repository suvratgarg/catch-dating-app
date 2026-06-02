import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'swipe.freezed.dart';
part 'swipe.g.dart';

enum SwipeDirection { like, pass }

enum SwipeReactionTargetType {
  heroPhoto,
  photo,
  profilePrompt,
  compatibility,
  running,
  details,
  lifestyle,
}

const maxSwipeReactionCommentLength = 240;

String? normalizeSwipeReactionComment(String? comment) {
  final trimmed = comment?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  if (trimmed.length > maxSwipeReactionCommentLength) {
    throw ArgumentError.value(
      comment,
      'comment',
      'Reaction comments must be $maxSwipeReactionCommentLength characters or fewer.',
    );
  }
  return trimmed;
}

class ProfileReactionTarget {
  const ProfileReactionTarget({
    required this.id,
    required this.type,
    required this.label,
    required this.preview,
  });

  final String id;
  final SwipeReactionTargetType type;
  final String label;
  final String preview;
}

@freezed
abstract class Swipe with _$Swipe {
  const factory Swipe({
    required String swiperId,
    required String targetId,
    required String eventId,
    required SwipeDirection direction,
    String? reactionTargetId,
    @JsonKey()
    SwipeReactionTargetType? reactionTargetType,
    String? reactionTargetLabel,
    String? reactionTargetPreview,
    String? comment,
    @TimestampConverter() required DateTime createdAt,
  }) = _Swipe;

  factory Swipe.fromJson(Map<String, dynamic> json) => _$SwipeFromJson(json);
}
