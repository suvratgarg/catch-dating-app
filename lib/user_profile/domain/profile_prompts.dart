import 'package:catch_dating_app/user_profile/domain/profile_validation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_prompts.freezed.dart';
part 'profile_prompts.g.dart';

/// Editorial source of truth for profile and photo prompts.
///
/// Add, remove, or reorder prompts here before changing UI code. The stored
/// profile documents keep stable ids; display copy resolves through this file.
const profilePromptPerfectRunId = 'perfectRun';
const maxProfilePromptAnswers = 3;
const maxPhotoPromptCaptions = 6;

class ProfilePromptDefinition {
  const ProfilePromptDefinition({
    required this.id,
    required this.title,
    required this.placeholder,
  });

  final String id;
  final String title;
  final String placeholder;
}

class PhotoPromptDefinition {
  const PhotoPromptDefinition({
    required this.id,
    required this.title,
    required this.placeholder,
  });

  final String id;
  final String title;
  final String placeholder;
}

const profilePromptCatalog = [
  ProfilePromptDefinition(
    id: profilePromptPerfectRunId,
    title: 'A perfect run with me looks like...',
    placeholder: 'Tell runners what kind of run feels like you.',
  ),
  ProfilePromptDefinition(
    id: 'afterRun',
    title: 'After a run, you can usually find me...',
    placeholder: 'Coffee, dosa, stretching, playlists...',
  ),
  ProfilePromptDefinition(
    id: 'greenFlag',
    title: 'My green flag is...',
    placeholder: 'Share something specific and easy to respond to.',
  ),
  ProfilePromptDefinition(
    id: 'getAlongIf',
    title: "We'll get along if...",
    placeholder: 'Name the energy, habits, or humor you like.',
  ),
  ProfilePromptDefinition(
    id: 'favoriteRoute',
    title: 'My favorite running route has...',
    placeholder: 'Shade, chaos, hills, street food, sunrise...',
  ),
];

const defaultProfilePromptIds = [
  profilePromptPerfectRunId,
  'afterRun',
  'greenFlag',
];

const photoPromptCatalog = [
  PhotoPromptDefinition(
    id: 'proofIRun',
    title: 'Proof I actually run',
    placeholder: 'Add a caption for this running photo.',
  ),
  PhotoPromptDefinition(
    id: 'finishLine',
    title: 'After the finish line',
    placeholder: 'What was happening in this moment?',
  ),
  PhotoPromptDefinition(
    id: 'notRunning',
    title: "When I'm not running",
    placeholder: 'Show another side of your life.',
  ),
  PhotoPromptDefinition(
    id: 'favoritePeople',
    title: 'My favorite people know me as',
    placeholder: 'A small detail friends would recognize.',
  ),
  PhotoPromptDefinition(
    id: 'weekendEnergy',
    title: 'Weekend energy',
    placeholder: 'What does this photo say about your weekends?',
  ),
  PhotoPromptDefinition(
    id: 'captionThis',
    title: 'Caption this',
    placeholder: 'Give people an easy opening line.',
  ),
];

@freezed
abstract class ProfilePromptAnswer with _$ProfilePromptAnswer {
  const ProfilePromptAnswer._();

  const factory ProfilePromptAnswer({
    required String promptId,
    required String prompt,
    @Default('') String answer,
  }) = _ProfilePromptAnswer;

  factory ProfilePromptAnswer.fromJson(Map<String, dynamic> json) =>
      _$ProfilePromptAnswerFromJson(json);

  String get displayPrompt => profilePromptTitle(promptId, fallback: prompt);
}

@freezed
abstract class PhotoPromptAnswer with _$PhotoPromptAnswer {
  const PhotoPromptAnswer._();

  const factory PhotoPromptAnswer({
    required int photoIndex,
    required String promptId,
    required String prompt,
    @Default('') String caption,
  }) = _PhotoPromptAnswer;

  factory PhotoPromptAnswer.fromJson(Map<String, dynamic> json) =>
      _$PhotoPromptAnswerFromJson(json);

  String get displayPrompt => photoPromptTitle(promptId, fallback: prompt);
}

ProfilePromptDefinition profilePromptDefinition(String promptId) {
  return profilePromptCatalog.firstWhere(
    (definition) => definition.id == promptId,
    orElse: () => ProfilePromptDefinition(
      id: promptId,
      title: promptId,
      placeholder: 'Answer this prompt.',
    ),
  );
}

PhotoPromptDefinition photoPromptDefinition(String promptId) {
  return photoPromptCatalog.firstWhere(
    (definition) => definition.id == promptId,
    orElse: () => PhotoPromptDefinition(
      id: promptId,
      title: promptId,
      placeholder: 'Add a caption.',
    ),
  );
}

PhotoPromptDefinition defaultPhotoPromptForIndex(int index) {
  if (index < 0) return photoPromptCatalog.first;
  return photoPromptCatalog[index % photoPromptCatalog.length];
}

String profilePromptTitle(String promptId, {String? fallback}) {
  final definition = profilePromptCatalog
      .where((definition) => definition.id == promptId)
      .firstOrNull;
  return definition?.title ?? fallback ?? promptId;
}

String photoPromptTitle(String promptId, {String? fallback}) {
  final definition = photoPromptCatalog
      .where((definition) => definition.id == promptId)
      .firstOrNull;
  return definition?.title ?? fallback ?? promptId;
}

ProfilePromptAnswer profilePromptAnswerFor({
  required ProfilePromptDefinition definition,
  required String answer,
}) {
  return ProfilePromptAnswer(
    promptId: definition.id,
    prompt: definition.title,
    answer: normalizeProfilePromptAnswer(answer),
  );
}

PhotoPromptAnswer photoPromptAnswerFor({
  required int photoIndex,
  required PhotoPromptDefinition definition,
  required String caption,
}) {
  return PhotoPromptAnswer(
    photoIndex: photoIndex,
    promptId: definition.id,
    prompt: definition.title,
    caption: normalizePhotoPromptCaption(caption),
  );
}

List<ProfilePromptAnswer> normalizeProfilePromptAnswers(
  Iterable<ProfilePromptAnswer> answers, {
  String? legacyBio,
}) {
  final byPromptId = <String, ProfilePromptAnswer>{};

  for (final answer in answers) {
    final promptId = answer.promptId.trim();
    if (promptId.isEmpty) continue;
    final normalizedAnswer = normalizeProfilePromptAnswer(answer.answer);
    if (normalizedAnswer.isEmpty) continue;
    final definition = profilePromptDefinition(promptId);
    byPromptId[promptId] = answer.copyWith(
      promptId: promptId,
      prompt: definition.title,
      answer: normalizedAnswer,
    );
  }

  if (byPromptId.isEmpty) {
    final migratedBio = normalizeProfilePromptAnswer(legacyBio ?? '');
    if (migratedBio.isNotEmpty) {
      final definition = profilePromptDefinition(profilePromptPerfectRunId);
      byPromptId[definition.id] = profilePromptAnswerFor(
        definition: definition,
        answer: migratedBio,
      );
    }
  }

  final ordered = <ProfilePromptAnswer>[
    for (final promptId in defaultProfilePromptIds)
      if (byPromptId.containsKey(promptId)) byPromptId.remove(promptId)!,
    ...byPromptId.values,
  ];
  return ordered.take(maxProfilePromptAnswers).toList(growable: false);
}

List<PhotoPromptAnswer> normalizePhotoPromptAnswers(
  Iterable<PhotoPromptAnswer> answers,
) {
  final byPhotoIndex = <int, PhotoPromptAnswer>{};

  for (final answer in answers) {
    final index = answer.photoIndex;
    if (index < 0 || index >= maxPhotoPromptCaptions) continue;
    final normalizedCaption = normalizePhotoPromptCaption(answer.caption);
    if (normalizedCaption.isEmpty) continue;
    final definition = photoPromptDefinition(answer.promptId.trim());
    byPhotoIndex[index] = answer.copyWith(
      photoIndex: index,
      promptId: definition.id,
      prompt: definition.title,
      caption: normalizedCaption,
    );
  }

  return byPhotoIndex.values.toList(growable: false)
    ..sort((a, b) => a.photoIndex.compareTo(b.photoIndex));
}

List<Map<String, dynamic>> profilePromptsToJson(
  Iterable<ProfilePromptAnswer> answers,
) {
  return normalizeProfilePromptAnswers(
    answers,
  ).map((answer) => answer.toJson()).toList(growable: false);
}

List<Map<String, dynamic>> photoPromptsToJson(
  Iterable<PhotoPromptAnswer> answers,
) {
  return normalizePhotoPromptAnswers(
    answers,
  ).map((answer) => answer.toJson()).toList(growable: false);
}

ProfilePromptAnswer? profilePromptById(
  Iterable<ProfilePromptAnswer> answers,
  String promptId,
) {
  for (final answer in normalizeProfilePromptAnswers(answers)) {
    if (answer.promptId == promptId) return answer;
  }
  return null;
}

PhotoPromptAnswer? photoPromptByIndex(
  Iterable<PhotoPromptAnswer> answers,
  int photoIndex,
) {
  for (final answer in normalizePhotoPromptAnswers(answers)) {
    if (answer.photoIndex == photoIndex) return answer;
  }
  return null;
}

List<ProfilePromptAnswer> replaceProfilePromptAnswer({
  required Iterable<ProfilePromptAnswer> current,
  required ProfilePromptDefinition definition,
  required String answer,
}) {
  final byPromptId = {
    for (final prompt in normalizeProfilePromptAnswers(current))
      prompt.promptId: prompt,
  };
  final normalized = normalizeProfilePromptAnswer(answer);
  if (normalized.isEmpty) {
    byPromptId.remove(definition.id);
  } else {
    byPromptId[definition.id] = profilePromptAnswerFor(
      definition: definition,
      answer: normalized,
    );
  }
  return normalizeProfilePromptAnswers(byPromptId.values);
}

List<PhotoPromptAnswer> replacePhotoPromptAnswer({
  required Iterable<PhotoPromptAnswer> current,
  required int photoIndex,
  required PhotoPromptDefinition definition,
  required String caption,
}) {
  final byPhotoIndex = {
    for (final prompt in normalizePhotoPromptAnswers(current))
      prompt.photoIndex: prompt,
  };
  final normalized = normalizePhotoPromptCaption(caption);
  if (normalized.isEmpty) {
    byPhotoIndex.remove(photoIndex);
  } else {
    byPhotoIndex[photoIndex] = photoPromptAnswerFor(
      photoIndex: photoIndex,
      definition: definition,
      caption: normalized,
    );
  }
  return normalizePhotoPromptAnswers(byPhotoIndex.values);
}

String normalizeProfilePromptAnswer(String value) =>
    collapseStackedPromptBlankLines(value).trim();

String normalizePhotoPromptCaption(String value) =>
    collapseStackedPromptBlankLines(value).trim();
