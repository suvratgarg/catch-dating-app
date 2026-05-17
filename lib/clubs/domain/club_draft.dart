import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'club_draft.freezed.dart';
part 'club_draft.g.dart';

@freezed
abstract class ClubDraft with _$ClubDraft {
  const factory ClubDraft({
    required DateTime savedAt,
    String? name,
    String? area,
    String? description,
    String? location,
    String? instagramHandle,
    String? phoneNumber,
    String? email,
  }) = _ClubDraft;

  factory ClubDraft.fromJson(Map<String, dynamic> json) =>
      _$ClubDraftFromJson(json);

  static ClubDraft? fromJsonString(String jsonString) =>
      ClubDraft.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);

  static String toJsonString(ClubDraft draft) => jsonEncode(draft.toJson());
}

extension ClubDraftX on ClubDraft {
  bool get isEmpty =>
      name == null &&
      area == null &&
      description == null &&
      location == null &&
      instagramHandle == null &&
      phoneNumber == null &&
      email == null;
}
