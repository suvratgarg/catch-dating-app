import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/public_profile/domain/profile_insights.dart';

typedef ProfileQualitySuggestionCopy = ({String title, String detail});

extension ProfileQualitySuggestionCopyX on ProfileQualitySuggestionKind {
  ProfileQualitySuggestionCopy copy(AppLocalizations l10n) => switch (this) {
    ProfileQualitySuggestionKind.photos => (
      title: l10n.profileQualityPhotosTitle,
      detail: l10n.profileQualityPhotosDetail,
    ),
    ProfileQualitySuggestionKind.profilePrompts => (
      title: l10n.profileQualityPromptsTitle,
      detail: l10n.profileQualityPromptsDetail,
    ),
    ProfileQualitySuggestionKind.photoPrompts => (
      title: l10n.profileQualityPhotoPromptsTitle,
      detail: l10n.profileQualityPhotoPromptsDetail,
    ),
    ProfileQualitySuggestionKind.relationshipGoal => (
      title: l10n.profileQualityRelationshipGoalTitle,
      detail: l10n.profileQualityRelationshipGoalDetail,
    ),
    ProfileQualitySuggestionKind.runningIdentity => (
      title: l10n.profileQualityRunningIdentityTitle,
      detail: l10n.profileQualityRunningIdentityDetail,
    ),
    ProfileQualitySuggestionKind.backgroundDetail => (
      title: l10n.profileQualityBackgroundTitle,
      detail: l10n.profileQualityBackgroundDetail,
    ),
    ProfileQualitySuggestionKind.lifestyleDetail => (
      title: l10n.profileQualityLifestyleTitle,
      detail: l10n.profileQualityLifestyleDetail,
    ),
  };
}
