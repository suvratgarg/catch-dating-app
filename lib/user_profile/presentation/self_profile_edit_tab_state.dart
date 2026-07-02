import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/format_utils.dart';
import 'package:catch_dating_app/core/labelled.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/callable_request_dtos.g.dart'
    show UpdateUserProfilePatch;
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/image_uploads/domain/photo_upload_state.dart';
import 'package:catch_dating_app/user_profile/domain/profile_photo.dart';
import 'package:catch_dating_app/user_profile/domain/profile_photo_policy.dart';
import 'package:catch_dating_app/user_profile/domain/profile_prompts.dart';
import 'package:catch_dating_app/user_profile/domain/profile_validation.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:catch_dating_app/user_profile/presentation/self_profile_inline_edit_patch_factory.dart';
import 'package:flutter/material.dart'
    show
        AutofillHints,
        FormFieldValidator,
        IconData,
        TextCapitalization,
        TextInputType;

class SelfProfileEditTabState {
  const SelfProfileEditTabState({
    required this.user,
    required this.photoGrid,
    required this.completedPromptCount,
    required this.promptSlots,
    required this.basicRows,
    required this.aboutRows,
    required this.runningRows,
    required this.lifestyleRows,
  });

  factory SelfProfileEditTabState.fromProfile({
    required UserProfile user,
    required DateTime today,
    required PhotoUploadState uploadState,
  }) {
    final promptAnswers = normalizeProfilePromptAnswers(user.profilePrompts);
    const patchFactory = SelfProfileInlineEditPatchFactory();
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
      basicRows: _basicRows(
        user: user,
        today: today,
        patchFactory: patchFactory,
      ),
      aboutRows: _aboutRows(user: user, patchFactory: patchFactory),
      runningRows: _runningRows(user: user, patchFactory: patchFactory),
      lifestyleRows: _lifestyleRows(user: user, patchFactory: patchFactory),
    );
  }

  final UserProfile user;
  final SelfProfilePhotoGridState photoGrid;
  final int completedPromptCount;
  final List<SelfProfilePromptSlotState> promptSlots;
  final List<SelfProfileFieldRowDescriptor> basicRows;
  final List<SelfProfileFieldRowDescriptor> aboutRows;
  final List<SelfProfileFieldRowDescriptor> runningRows;
  final List<SelfProfileFieldRowDescriptor> lifestyleRows;

  List<SelfProfileFieldRowDescriptor> get aboutSectionRows => [
    ...basicRows,
    ...aboutRows,
  ];
}

typedef SelfProfileSingleChoiceFieldRowMapper<R> =
    R Function<T extends Labelled>(
      SelfProfileSingleChoiceFieldRowDescriptor<T> descriptor,
    );

typedef SelfProfileMultiChoiceFieldRowMapper<R> =
    R Function<T extends Labelled>(
      SelfProfileMultiChoiceFieldRowDescriptor<T> descriptor,
    );

sealed class SelfProfileFieldRowDescriptor {
  const SelfProfileFieldRowDescriptor({
    required this.id,
    required this.icon,
    required this.label,
  });

  final String id;
  final IconData icon;
  final String label;

  R map<R>({
    required R Function(SelfProfileReadOnlyFieldRowDescriptor descriptor)
    readOnly,
    required R Function(SelfProfileTextFieldRowDescriptor descriptor) text,
    required R Function(SelfProfileHeightFieldRowDescriptor descriptor) height,
    required SelfProfileSingleChoiceFieldRowMapper<R> singleChoice,
    required SelfProfileMultiChoiceFieldRowMapper<R> multiChoice,
    required R Function(SelfProfileRangeFieldRowDescriptor descriptor) range,
  });
}

class SelfProfileReadOnlyFieldRowDescriptor
    extends SelfProfileFieldRowDescriptor {
  const SelfProfileReadOnlyFieldRowDescriptor({
    required super.id,
    required super.icon,
    required super.label,
    required this.body,
    this.bodyMaxLines = 4,
  });

  final String body;
  final int bodyMaxLines;

  @override
  R map<R>({
    required R Function(SelfProfileReadOnlyFieldRowDescriptor descriptor)
    readOnly,
    required R Function(SelfProfileTextFieldRowDescriptor descriptor) text,
    required R Function(SelfProfileHeightFieldRowDescriptor descriptor) height,
    required SelfProfileSingleChoiceFieldRowMapper<R> singleChoice,
    required SelfProfileMultiChoiceFieldRowMapper<R> multiChoice,
    required R Function(SelfProfileRangeFieldRowDescriptor descriptor) range,
  }) {
    return readOnly(this);
  }
}

class SelfProfileTextFieldRowDescriptor extends SelfProfileFieldRowDescriptor {
  const SelfProfileTextFieldRowDescriptor({
    required super.id,
    required super.icon,
    required super.label,
    required this.value,
    required this.currentValue,
    required this.fieldName,
    required this.patchForValue,
    this.currentFieldValue,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.sentences,
    this.autofillHints,
    this.validator,
    this.toFieldValue,
  });

  final String value;
  final String currentValue;
  final Object? currentFieldValue;
  final String fieldName;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final FormFieldValidator<String>? validator;
  final Object? Function(String value)? toFieldValue;
  final UpdateUserProfilePatch Function(Object? value) patchForValue;

  @override
  R map<R>({
    required R Function(SelfProfileReadOnlyFieldRowDescriptor descriptor)
    readOnly,
    required R Function(SelfProfileTextFieldRowDescriptor descriptor) text,
    required R Function(SelfProfileHeightFieldRowDescriptor descriptor) height,
    required SelfProfileSingleChoiceFieldRowMapper<R> singleChoice,
    required SelfProfileMultiChoiceFieldRowMapper<R> multiChoice,
    required R Function(SelfProfileRangeFieldRowDescriptor descriptor) range,
  }) {
    return text(this);
  }
}

class SelfProfileHeightFieldRowDescriptor
    extends SelfProfileFieldRowDescriptor {
  const SelfProfileHeightFieldRowDescriptor({
    required super.id,
    required super.icon,
    required super.label,
    required this.value,
    required this.currentValue,
    required this.patchForValue,
  });

  final String value;
  final int? currentValue;
  final UpdateUserProfilePatch Function(int value) patchForValue;

  bool get isAddAffordance => currentValue == null;

  @override
  R map<R>({
    required R Function(SelfProfileReadOnlyFieldRowDescriptor descriptor)
    readOnly,
    required R Function(SelfProfileTextFieldRowDescriptor descriptor) text,
    required R Function(SelfProfileHeightFieldRowDescriptor descriptor) height,
    required SelfProfileSingleChoiceFieldRowMapper<R> singleChoice,
    required SelfProfileMultiChoiceFieldRowMapper<R> multiChoice,
    required R Function(SelfProfileRangeFieldRowDescriptor descriptor) range,
  }) {
    return height(this);
  }
}

class SelfProfileSingleChoiceFieldRowDescriptor<T extends Labelled>
    extends SelfProfileFieldRowDescriptor {
  const SelfProfileSingleChoiceFieldRowDescriptor({
    required super.id,
    required super.icon,
    required super.label,
    required this.values,
    required this.value,
    required this.fieldName,
    required this.patchForValue,
    this.placeholder,
  });

  final List<T> values;
  final T? value;
  final String fieldName;
  final UpdateUserProfilePatch Function(T? value) patchForValue;
  final String? placeholder;

  @override
  R map<R>({
    required R Function(SelfProfileReadOnlyFieldRowDescriptor descriptor)
    readOnly,
    required R Function(SelfProfileTextFieldRowDescriptor descriptor) text,
    required R Function(SelfProfileHeightFieldRowDescriptor descriptor) height,
    required SelfProfileSingleChoiceFieldRowMapper<R> singleChoice,
    required SelfProfileMultiChoiceFieldRowMapper<R> multiChoice,
    required R Function(SelfProfileRangeFieldRowDescriptor descriptor) range,
  }) {
    return singleChoice<T>(this);
  }
}

class SelfProfileMultiChoiceFieldRowDescriptor<T extends Labelled>
    extends SelfProfileFieldRowDescriptor {
  const SelfProfileMultiChoiceFieldRowDescriptor({
    required super.id,
    required super.icon,
    required super.label,
    required this.values,
    required this.selected,
    required this.fieldName,
    required this.placeholder,
    required this.patchForValues,
    this.patchForLatestProfile,
    this.isAddAffordanceWhenEmpty = true,
  });

  final List<T> values;
  final List<T> selected;
  final String fieldName;
  final String placeholder;
  final UpdateUserProfilePatch Function(List<T> values) patchForValues;
  final UpdateUserProfilePatch Function(UserProfile user, List<T> values)?
  patchForLatestProfile;
  final bool isAddAffordanceWhenEmpty;

  @override
  R map<R>({
    required R Function(SelfProfileReadOnlyFieldRowDescriptor descriptor)
    readOnly,
    required R Function(SelfProfileTextFieldRowDescriptor descriptor) text,
    required R Function(SelfProfileHeightFieldRowDescriptor descriptor) height,
    required SelfProfileSingleChoiceFieldRowMapper<R> singleChoice,
    required SelfProfileMultiChoiceFieldRowMapper<R> multiChoice,
    required R Function(SelfProfileRangeFieldRowDescriptor descriptor) range,
  }) {
    return multiChoice<T>(this);
  }
}

class SelfProfileRangeFieldRowDescriptor extends SelfProfileFieldRowDescriptor {
  const SelfProfileRangeFieldRowDescriptor({
    required super.id,
    required super.icon,
    required super.label,
    required this.value,
    required this.currentMin,
    required this.currentMax,
    required this.sliderMin,
    required this.sliderMax,
    required this.divisions,
    required this.labelText,
    required this.patchForRange,
    this.patchForLatestProfile,
    this.saveEndValue,
    this.savedCurrentMax,
  });

  final String value;
  final int currentMin;
  final int currentMax;
  final double sliderMin;
  final double sliderMax;
  final int divisions;
  final String Function(double) labelText;
  final int Function(int)? saveEndValue;
  final int? savedCurrentMax;
  final UpdateUserProfilePatch Function(int min, int max) patchForRange;
  final UpdateUserProfilePatch Function(UserProfile user, int min, int max)?
  patchForLatestProfile;

  @override
  R map<R>({
    required R Function(SelfProfileReadOnlyFieldRowDescriptor descriptor)
    readOnly,
    required R Function(SelfProfileTextFieldRowDescriptor descriptor) text,
    required R Function(SelfProfileHeightFieldRowDescriptor descriptor) height,
    required SelfProfileSingleChoiceFieldRowMapper<R> singleChoice,
    required SelfProfileMultiChoiceFieldRowMapper<R> multiChoice,
    required R Function(SelfProfileRangeFieldRowDescriptor descriptor) range,
  }) {
    return range(this);
  }
}

List<SelfProfileFieldRowDescriptor> _basicRows({
  required UserProfile user,
  required DateTime today,
  required SelfProfileInlineEditPatchFactory patchFactory,
}) {
  return [
    SelfProfileTextFieldRowDescriptor(
      id: 'displayName',
      icon: CatchIcons.personOutlined,
      label: 'Display name',
      value: user.publicDisplayName,
      currentValue: user.publicDisplayName,
      currentFieldValue: user.displayName.trim().isEmpty
          ? null
          : user.displayName.trim(),
      fieldName: 'displayName',
      patchForValue: patchFactory.displayName,
      textCapitalization: TextCapitalization.words,
      autofillHints: const [AutofillHints.nickname],
      validator: validateRequiredDisplayName,
      toFieldValue: (value) => value.trim(),
    ),
    SelfProfileReadOnlyFieldRowDescriptor(
      id: 'dateOfBirth',
      icon: CatchIcons.cakeOutlined,
      label: 'Date of birth',
      body:
          '${user.dateOfBirth.day.toString().padLeft(2, '0')}/'
          '${user.dateOfBirth.month.toString().padLeft(2, '0')}/'
          '${user.dateOfBirth.year}  (${user.ageOn(today)} years)',
    ),
    SelfProfileReadOnlyFieldRowDescriptor(
      id: 'gender',
      icon: CatchIcons.wcOutlined,
      label: 'Gender',
      body: user.gender.label,
    ),
    // Phone is the OTP identity credential; editing requires Auth
    // re-verification before Firestore can safely change.
    SelfProfileReadOnlyFieldRowDescriptor(
      id: 'phoneNumber',
      icon: CatchIcons.phoneOutlined,
      label: 'Phone',
      body: user.phoneNumber,
    ),
    SelfProfileTextFieldRowDescriptor(
      id: 'email',
      icon: CatchIcons.emailOutlined,
      label: 'Email',
      value: 'Email',
      currentValue: user.email,
      fieldName: 'email',
      patchForValue: patchFactory.email,
      keyboardType: TextInputType.emailAddress,
      textCapitalization: TextCapitalization.none,
      autofillHints: const [AutofillHints.email],
      validator: validateOptionalEmail,
    ),
    SelfProfileTextFieldRowDescriptor(
      id: 'instagramHandle',
      icon: CatchIcons.alternateEmailOutlined,
      label: 'Instagram',
      value: 'Instagram',
      currentValue: user.instagramHandle?.isNotEmpty == true
          ? '@${user.instagramHandle}'
          : '',
      currentFieldValue: user.instagramHandle,
      fieldName: 'instagramHandle',
      patchForValue: patchFactory.instagramHandle,
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.none,
      validator: validateOptionalInstagramHandle,
      toFieldValue: (value) {
        final handle = normalizeInstagramHandle(value);
        return handle.isEmpty ? null : handle;
      },
    ),
    SelfProfileHeightFieldRowDescriptor(
      id: 'height',
      icon: CatchIcons.heightOutlined,
      label: 'Height',
      value: user.height != null ? '${user.height} cm' : 'Height',
      currentValue: user.height,
      patchForValue: patchFactory.height,
    ),
  ];
}

List<SelfProfileFieldRowDescriptor> _aboutRows({
  required UserProfile user,
  required SelfProfileInlineEditPatchFactory patchFactory,
}) {
  return [
    SelfProfileSingleChoiceFieldRowDescriptor<CityOption>(
      id: 'city',
      icon: CatchIcons.locationOnOutlined,
      label: 'City',
      values: defaultCityOptions
          .where((city) => city.profileSelectable)
          .toList(growable: false),
      value: cityOptionByName(user.city),
      fieldName: 'city',
      patchForValue: patchFactory.city,
    ),
    SelfProfileTextFieldRowDescriptor(
      id: 'occupation',
      icon: CatchIcons.workOutline,
      label: 'Job title',
      value: 'Job title',
      currentValue: user.occupation ?? '',
      fieldName: 'occupation',
      patchForValue: patchFactory.occupation,
      validator: (value) =>
          validateOptionalProfileShortText(value, label: 'Job title'),
    ),
    SelfProfileTextFieldRowDescriptor(
      id: 'company',
      icon: CatchIcons.businessOutlined,
      label: 'Company',
      value: 'Company',
      currentValue: user.company ?? '',
      fieldName: 'company',
      patchForValue: patchFactory.company,
      validator: (value) =>
          validateOptionalProfileShortText(value, label: 'Company'),
    ),
    SelfProfileSingleChoiceFieldRowDescriptor<EducationLevel>(
      id: 'education',
      icon: CatchIcons.schoolOutlined,
      label: 'Education',
      values: EducationLevel.values,
      value: user.education,
      fieldName: 'education',
      patchForValue: patchFactory.education,
    ),
    SelfProfileSingleChoiceFieldRowDescriptor<Religion>(
      id: 'religion',
      icon: CatchIcons.volunteerActivismOutlined,
      label: 'Religion',
      values: Religion.values,
      value: user.religion,
      fieldName: 'religion',
      patchForValue: patchFactory.religion,
    ),
    SelfProfileMultiChoiceFieldRowDescriptor<Language>(
      id: 'languages',
      icon: CatchIcons.languageOutlined,
      label: 'Languages',
      values: Language.values,
      selected: user.languages,
      fieldName: 'languages',
      placeholder: 'Languages',
      patchForValues: patchFactory.languages,
    ),
    SelfProfileSingleChoiceFieldRowDescriptor<RelationshipGoal>(
      id: 'relationshipGoal',
      icon: CatchIcons.favoriteOutline,
      label: 'Looking for',
      values: RelationshipGoal.values,
      value: user.relationshipGoal,
      fieldName: 'relationshipGoal',
      patchForValue: patchFactory.relationshipGoal,
    ),
  ];
}

List<SelfProfileFieldRowDescriptor> _runningRows({
  required UserProfile user,
  required SelfProfileInlineEditPatchFactory patchFactory,
}) {
  return [
    SelfProfileRangeFieldRowDescriptor(
      id: 'pace-range',
      icon: CatchIcons.speedOutlined,
      label: 'Pace range',
      value: formatPaceRange(user.paceMinSecsPerKm, user.paceMaxSecsPerKm),
      currentMin: user.paceMinSecsPerKm,
      currentMax: user.paceMaxSecsPerKm,
      sliderMin: 240,
      sliderMax: 540,
      divisions: 20,
      labelText: (v) => '${formatPace(v.round())}/km',
      patchForRange: (min, max) => patchFactory.paceRange(user, min, max),
      patchForLatestProfile: patchFactory.paceRange,
    ),
    SelfProfileMultiChoiceFieldRowDescriptor<PreferredDistance>(
      id: 'preferredDistances',
      icon: CatchIcons.straightenOutlined,
      label: 'Preferred distances',
      values: PreferredDistance.values,
      selected: user.preferredDistances,
      fieldName: 'preferredDistances',
      placeholder: 'Preferred distances',
      patchForValues: (values) => patchFactory.preferredDistances(user, values),
      patchForLatestProfile: patchFactory.preferredDistances,
    ),
    SelfProfileMultiChoiceFieldRowDescriptor<RunReason>(
      id: 'runningReasons',
      icon: CatchIcons.directionsRunOutlined,
      label: 'Why I event',
      values: RunReason.values,
      selected: user.runningReasons,
      fieldName: 'runningReasons',
      placeholder: 'Why I event',
      patchForValues: (values) => patchFactory.runningReasons(user, values),
      patchForLatestProfile: patchFactory.runningReasons,
    ),
    SelfProfileMultiChoiceFieldRowDescriptor<PreferredRunTime>(
      id: 'preferredRunTimes',
      icon: CatchIcons.wbTwilightOutlined,
      label: 'Favorite event times',
      values: PreferredRunTime.values,
      selected: user.preferredRunTimes,
      fieldName: 'preferredRunTimes',
      placeholder: 'Favorite event times',
      patchForValues: (values) => patchFactory.preferredRunTimes(user, values),
      patchForLatestProfile: patchFactory.preferredRunTimes,
    ),
  ];
}

List<SelfProfileFieldRowDescriptor> _lifestyleRows({
  required UserProfile user,
  required SelfProfileInlineEditPatchFactory patchFactory,
}) {
  return [
    SelfProfileSingleChoiceFieldRowDescriptor<DrinkingHabit>(
      id: 'drinking',
      icon: CatchIcons.localBarOutlined,
      label: 'Drinking',
      values: DrinkingHabit.values,
      value: user.drinking,
      fieldName: 'drinking',
      patchForValue: patchFactory.drinking,
    ),
    SelfProfileSingleChoiceFieldRowDescriptor<SmokingHabit>(
      id: 'smoking',
      icon: CatchIcons.smokeFreeOutlined,
      label: 'Smoking',
      values: SmokingHabit.values,
      value: user.smoking,
      fieldName: 'smoking',
      patchForValue: patchFactory.smoking,
    ),
    SelfProfileSingleChoiceFieldRowDescriptor<WorkoutFrequency>(
      id: 'workout',
      icon: CatchIcons.fitnessCenterOutlined,
      label: 'Workout',
      values: WorkoutFrequency.values,
      value: user.workout,
      fieldName: 'workout',
      patchForValue: patchFactory.workout,
    ),
    SelfProfileSingleChoiceFieldRowDescriptor<DietaryPreference>(
      id: 'diet',
      icon: CatchIcons.restaurantOutlined,
      label: 'Diet',
      values: DietaryPreference.values,
      value: user.diet,
      fieldName: 'diet',
      patchForValue: patchFactory.diet,
    ),
    SelfProfileSingleChoiceFieldRowDescriptor<ChildrenStatus>(
      id: 'children',
      icon: CatchIcons.childCareOutlined,
      label: 'Children',
      values: ChildrenStatus.values,
      value: user.children,
      fieldName: 'children',
      patchForValue: patchFactory.children,
    ),
  ];
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
