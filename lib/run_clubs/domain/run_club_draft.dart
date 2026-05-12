import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'run_club_draft.freezed.dart';
part 'run_club_draft.g.dart';

@freezed
abstract class RunClubDraft with _$RunClubDraft {
  const factory RunClubDraft({
    required DateTime savedAt,
    String? name,
    String? area,
    String? description,
    String? location,
    String? instagramHandle,
    String? phoneNumber,
    String? email,
  }) = _RunClubDraft;

  factory RunClubDraft.fromJson(Map<String, dynamic> json) =>
      _$RunClubDraftFromJson(json);

  static RunClubDraft? fromJsonString(String jsonString) =>
      RunClubDraft.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);

  static String toJsonString(RunClubDraft draft) => jsonEncode(draft.toJson());
}

extension RunClubDraftX on RunClubDraft {
  bool get isEmpty =>
      name == null &&
      area == null &&
      description == null &&
      location == null &&
      instagramHandle == null &&
      phoneNumber == null &&
      email == null;
}
