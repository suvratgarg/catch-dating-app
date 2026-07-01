import 'package:catch_dating_app/image_uploads/presentation/photo_upload_controller.dart';
import 'package:catch_dating_app/user_profile/domain/profile_photo.dart';
import 'package:catch_dating_app/user_profile/domain/profile_photo_policy.dart';
import 'package:catch_dating_app/user_profile/domain/profile_prompts.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';

class SelfProfileEditTabState {
  const SelfProfileEditTabState({
    required this.user,
    required this.photoGrid,
    required this.completedPromptCount,
    required this.promptSlots,
  });

  factory SelfProfileEditTabState.fromProfile({
    required UserProfile user,
    required PhotoUploadState uploadState,
  }) {
    final promptAnswers = normalizeProfilePromptAnswers(user.profilePrompts);
    return SelfProfileEditTabState(
      user: user,
      photoGrid: SelfProfilePhotoGridState.fromProfile(
        user: user,
        uploadState: uploadState,
      ),
      completedPromptCount: promptAnswers
          .where((prompt) => prompt.answer.trim().isNotEmpty)
          .length,
      promptSlots: List<SelfProfilePromptSlotState>.generate(
        maxProfilePromptAnswers,
        (index) {
          final answer = index < promptAnswers.length
              ? promptAnswers[index]
              : null;
          final usedPromptIds = {
            for (final prompt in promptAnswers)
              if (prompt.promptId != answer?.promptId) prompt.promptId,
          };
          final definition = _profilePromptDefinitionForSlot(
            index: index,
            answer: answer,
            usedPromptIds: usedPromptIds,
          );
          final currentPromptId = answer?.promptId ?? definition.id;
          return SelfProfilePromptSlotState(
            index: index,
            definition: definition,
            answer: answer,
            usedPromptIds: usedPromptIds,
            fieldName: 'profilePrompt:$index',
            availablePromptIds: _availableProfilePromptIds(
              usedPromptIds: usedPromptIds,
              currentPromptId: currentPromptId,
            ),
          );
        },
        growable: false,
      ),
    );
  }

  final UserProfile user;
  final SelfProfilePhotoGridState photoGrid;
  final int completedPromptCount;
  final List<SelfProfilePromptSlotState> promptSlots;
}

class SelfProfilePhotoGridState {
  const SelfProfilePhotoGridState({
    required this.profilePhotos,
    required this.loadingIndices,
    required this.canDeletePhotos,
  });

  factory SelfProfilePhotoGridState.fromProfile({
    required UserProfile user,
    required PhotoUploadState uploadState,
  }) {
    final profilePhotos = user.effectiveProfilePhotos;
    return SelfProfilePhotoGridState(
      profilePhotos: profilePhotos,
      loadingIndices: uploadState.loadingIndices,
      canDeletePhotos: profilePhotos.length > minimumProfilePhotoCount,
    );
  }

  final List<ProfilePhoto> profilePhotos;
  final Set<int> loadingIndices;
  final bool canDeletePhotos;
}

class SelfProfilePromptSlotState {
  const SelfProfilePromptSlotState({
    required this.index,
    required this.definition,
    required this.answer,
    required this.usedPromptIds,
    required this.fieldName,
    required this.availablePromptIds,
  });

  final int index;
  final ProfilePromptDefinition definition;
  final ProfilePromptAnswer? answer;
  final Set<String> usedPromptIds;
  final String fieldName;
  final List<String> availablePromptIds;

  String get displayText => answer?.answer ?? '';
  String get currentPromptId => answer?.promptId ?? definition.id;
  bool get isAddAffordance => displayText.isEmpty;
}

ProfilePromptDefinition _profilePromptDefinitionForSlot({
  required int index,
  required ProfilePromptAnswer? answer,
  required Set<String> usedPromptIds,
}) {
  final promptId = answer?.promptId;
  if (promptId != null) return profilePromptDefinition(promptId);
  final defaultPromptId = index < defaultProfilePromptIds.length
      ? defaultProfilePromptIds[index]
      : null;
  if (defaultPromptId != null && !usedPromptIds.contains(defaultPromptId)) {
    return profilePromptDefinition(defaultPromptId);
  }
  return profilePromptCatalog.firstWhere(
    (definition) => !usedPromptIds.contains(definition.id),
    orElse: () => profilePromptCatalog.first,
  );
}

List<String> _availableProfilePromptIds({
  required Set<String> usedPromptIds,
  required String currentPromptId,
}) {
  final ids = <String>[
    if (!profilePromptCatalog.any(
      (definition) => definition.id == currentPromptId,
    ))
      currentPromptId,
    for (final definition in profilePromptCatalog)
      if (!usedPromptIds.contains(definition.id) ||
          definition.id == currentPromptId)
        definition.id,
  ];
  return ids.isNotEmpty ? ids : <String>[profilePromptCatalog.first.id];
}
