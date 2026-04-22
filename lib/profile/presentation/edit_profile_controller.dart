import 'package:catch_dating_app/profile/presentation/edit_profile_form_data.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/profile_validation.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'edit_profile_controller.g.dart';

@riverpod
class EditProfileController extends _$EditProfileController {
  static final submitMutation = Mutation<void>();

  @override
  void build() {}

  Future<void> submit({required EditProfileFormData formData}) async {
    final current = ref.read(userProfileStreamProvider).asData?.value;
    if (current == null) {
      throw StateError('User profile not loaded. Please try again.');
    }
    if (!isAtLeastAge(formData.dateOfBirth)) {
      throw ArgumentError('You must be at least $minimumProfileAge years old.');
    }
    if (!isValidAgePreferenceRange(
      minAgePreference: formData.minAgePreference,
      maxAgePreference: formData.maxAgePreference,
    )) {
      throw ArgumentError(
        'Age preference range must stay between $minimumProfileAge and '
        '$maximumPreferredMatchAge, with min age less than or equal to max age.',
      );
    }
    await ref
        .read(userProfileRepositoryProvider)
        .setUserProfile(userProfile: formData.applyTo(current));
  }
}
