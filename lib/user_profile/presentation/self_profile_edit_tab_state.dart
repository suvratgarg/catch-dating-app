import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/format_utils.dart';
import 'package:catch_dating_app/core/labelled.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/callable_request_dtos.g.dart'
    show UpdateUserProfilePatch;
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/image_uploads/domain/photo_upload_state.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
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
    required AppLocalizations l10n,
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
            fieldName: l10n
                .userProfileSelfProfileEditTabStateVisiblecopyProfilepromptIndex(
                  index: index,
                ),
            availablePromptIds: _availableProfilePromptIds(
              usedPromptIds: usedPromptIds,
              currentPromptId: currentPromptId,
            ),
          );
        },
        growable: false,
      ),
      basicRows: _basicRows(
        l10n: l10n,
        user: user,
        today: today,
        patchFactory: patchFactory,
      ),
      aboutRows: _aboutRows(l10n: l10n, user: user, patchFactory: patchFactory),
      runningRows: _runningRows(
        l10n: l10n,
        user: user,
        patchFactory: patchFactory,
      ),
      lifestyleRows: _lifestyleRows(
        l10n: l10n,
        user: user,
        patchFactory: patchFactory,
      ),
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
    required this.currentValue,
    required this.fieldName,
    required this.patchForValue,
    this.emptyValueText,
    this.inputHint,
    this.leadingUnit,
    this.showClearButton = false,
    this.currentFieldValue,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.sentences,
    this.autofillHints,
    this.validator,
    this.toFieldValue,
  });

  final String currentValue;
  final String? emptyValueText;
  final String? inputHint;
  final String? leadingUnit;
  final bool showClearButton;
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
    this.emptyValueText,
    this.allowEmptySelection = true,
    this.showOptionalLabel = false,
  });

  final List<T> values;
  final T? value;
  final String fieldName;
  final UpdateUserProfilePatch Function(T? value) patchForValue;
  final String? emptyValueText;
  final bool allowEmptySelection;
  final bool showOptionalLabel;

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
    required this.patchForValues,
    this.emptyValueText,
    this.patchForLatestProfile,
    this.isAddAffordanceWhenEmpty = true,
    this.allowEmptySelection = true,
    this.showOptionalLabel = false,
  });

  final List<T> values;
  final List<T> selected;
  final String fieldName;
  final String? emptyValueText;
  final UpdateUserProfilePatch Function(List<T> values) patchForValues;
  final UpdateUserProfilePatch Function(UserProfile user, List<T> values)?
  patchForLatestProfile;
  final bool isAddAffordanceWhenEmpty;
  final bool allowEmptySelection;
  final bool showOptionalLabel;

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
  required AppLocalizations l10n,
  required UserProfile user,
  required DateTime today,
  required SelfProfileInlineEditPatchFactory patchFactory,
}) {
  return [
    SelfProfileTextFieldRowDescriptor(
      id: 'displayName',
      icon: CatchIcons.personOutlined,
      label: l10n.userProfileSelfProfileEditTabStateLabelDisplayName,
      currentValue: user.publicDisplayName,
      currentFieldValue: user.displayName.trim().isEmpty
          ? null
          : user.displayName.trim(),
      fieldName: l10n.userProfileSelfProfileEditTabStateVisiblecopyDisplayname,
      patchForValue: patchFactory.displayName,
      textCapitalization: TextCapitalization.words,
      autofillHints: const [AutofillHints.nickname],
      validator: validateRequiredDisplayName,
      toFieldValue: (value) => value.trim(),
      showClearButton: true,
    ),
    SelfProfileReadOnlyFieldRowDescriptor(
      id: 'dateOfBirth',
      icon: CatchIcons.cakeOutlined,
      label: l10n.userProfileSelfProfileEditTabStateLabelDateOfBirth,
      body: l10n.userProfileSelfProfileEditTabStateBodyPadleftPadleft2YearAgeon(
        padLeft: user.dateOfBirth.day.toString().padLeft(2, '0'),
        padLeft2: user.dateOfBirth.month.toString().padLeft(2, '0'),
        year: user.dateOfBirth.year,
        ageOn: user.ageOn(today),
      ),
    ),
    SelfProfileReadOnlyFieldRowDescriptor(
      id: 'gender',
      icon: CatchIcons.wcOutlined,
      label: l10n.userProfileSelfProfileEditTabStateLabelGender,
      body: user.gender.label,
    ),
    // Phone is the OTP identity credential; editing requires Auth
    // re-verification before Firestore can safely change.
    SelfProfileReadOnlyFieldRowDescriptor(
      id: 'phoneNumber',
      icon: CatchIcons.phoneOutlined,
      label: l10n.userProfileSelfProfileEditTabStateLabelPhone,
      body: user.phoneNumber,
    ),
    SelfProfileTextFieldRowDescriptor(
      id: 'email',
      icon: CatchIcons.emailOutlined,
      label: l10n.userProfileSelfProfileEditTabStateLabelEmail,
      currentValue: user.email,
      fieldName: l10n.userProfileSelfProfileEditTabStateVisiblecopyEmaile69bb2,
      patchForValue: patchFactory.email,
      keyboardType: TextInputType.emailAddress,
      textCapitalization: TextCapitalization.none,
      autofillHints: const [AutofillHints.email],
      validator: validateOptionalEmail,
    ),
    SelfProfileTextFieldRowDescriptor(
      id: 'instagramHandle',
      icon: CatchIcons.alternateEmailOutlined,
      label: l10n.userProfileSelfProfileEditTabStateLabelInstagram,
      currentValue: user.instagramHandle ?? '',
      currentFieldValue: user.instagramHandle,
      fieldName: l10n
          .userProfileSelfProfileEditTabStateVisiblecopyInstagramhandle71eebb,
      patchForValue: patchFactory.instagramHandle,
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.none,
      validator: validateOptionalInstagramHandle,
      leadingUnit: '@',
      showClearButton: true,
      toFieldValue: (value) {
        final handle = normalizeInstagramHandle(value);
        return handle.isEmpty ? null : handle;
      },
    ),
    SelfProfileHeightFieldRowDescriptor(
      id: 'height',
      icon: CatchIcons.heightOutlined,
      label: l10n.userProfileSelfProfileEditTabStateLabelHeight,
      value: user.height != null
          ? l10n.userProfileSelfProfileEditTabStateVisiblecopyHeightCm(
              height: user.height!,
            )
          : l10n.userProfileSelfProfileEditTabStateVisiblecopyHeight,
      currentValue: user.height,
      patchForValue: patchFactory.height,
    ),
  ];
}

List<SelfProfileFieldRowDescriptor> _aboutRows({
  required AppLocalizations l10n,
  required UserProfile user,
  required SelfProfileInlineEditPatchFactory patchFactory,
}) {
  return [
    SelfProfileSingleChoiceFieldRowDescriptor<CityOption>(
      id: 'city',
      icon: CatchIcons.locationOnOutlined,
      label: l10n.userProfileSelfProfileEditTabStateLabelCity,
      values: defaultCityOptions
          .where((city) => city.profileSelectable)
          .toList(growable: false),
      value: cityOptionByName(user.city),
      fieldName: l10n.userProfileSelfProfileEditTabStateVisiblecopyCity,
      patchForValue: patchFactory.city,
    ),
    SelfProfileTextFieldRowDescriptor(
      id: 'occupation',
      icon: CatchIcons.workOutline,
      label: l10n.userProfileSelfProfileEditTabStateLabelJobTitle,
      currentValue: user.occupation ?? '',
      fieldName: l10n.userProfileSelfProfileEditTabStateVisiblecopyOccupation,
      patchForValue: patchFactory.occupation,
      validator: (value) => validateOptionalProfileShortText(
        value,
        label: l10n.userProfileSelfProfileEditTabStateLabelJobTitle,
      ),
    ),
    SelfProfileTextFieldRowDescriptor(
      id: 'company',
      icon: CatchIcons.businessOutlined,
      label: l10n.userProfileSelfProfileEditTabStateLabelCompany,
      currentValue: user.company ?? '',
      fieldName:
          l10n.userProfileSelfProfileEditTabStateVisiblecopyCompanyfd8aec,
      patchForValue: patchFactory.company,
      validator: (value) => validateOptionalProfileShortText(
        value,
        label: l10n.userProfileSelfProfileEditTabStateLabelCompany,
      ),
    ),
    SelfProfileSingleChoiceFieldRowDescriptor<EducationLevel>(
      id: 'education',
      icon: CatchIcons.schoolOutlined,
      label: l10n.userProfileSelfProfileEditTabStateLabelEducation,
      values: EducationLevel.values,
      value: user.education,
      fieldName: l10n.userProfileSelfProfileEditTabStateVisiblecopyEducation,
      patchForValue: patchFactory.education,
    ),
    SelfProfileSingleChoiceFieldRowDescriptor<Religion>(
      id: 'religion',
      icon: CatchIcons.volunteerActivismOutlined,
      label: l10n.userProfileSelfProfileEditTabStateLabelReligion,
      values: Religion.values,
      value: user.religion,
      fieldName: l10n.userProfileSelfProfileEditTabStateVisiblecopyReligion,
      patchForValue: patchFactory.religion,
      showOptionalLabel: true,
    ),
    SelfProfileMultiChoiceFieldRowDescriptor<Language>(
      id: 'languages',
      icon: CatchIcons.languageOutlined,
      label: l10n.userProfileSelfProfileEditTabStateLabelLanguages,
      values: Language.values,
      selected: user.languages,
      fieldName: l10n.userProfileSelfProfileEditTabStateVisiblecopyLanguages,
      patchForValues: patchFactory.languages,
    ),
    SelfProfileSingleChoiceFieldRowDescriptor<RelationshipGoal>(
      id: 'relationshipGoal',
      icon: CatchIcons.favoriteOutline,
      label: l10n.userProfileSelfProfileEditTabStateLabelLookingFor,
      values: RelationshipGoal.values,
      value: user.relationshipGoal,
      fieldName:
          l10n.userProfileSelfProfileEditTabStateVisiblecopyRelationshipgoal,
      patchForValue: patchFactory.relationshipGoal,
    ),
  ];
}

List<SelfProfileFieldRowDescriptor> _runningRows({
  required AppLocalizations l10n,
  required UserProfile user,
  required SelfProfileInlineEditPatchFactory patchFactory,
}) {
  return [
    SelfProfileRangeFieldRowDescriptor(
      id: 'pace-range',
      icon: CatchIcons.speedOutlined,
      label: l10n.userProfileSelfProfileEditTabStateLabelPaceRange,
      value: formatPaceRange(user.paceMinSecsPerKm, user.paceMaxSecsPerKm),
      currentMin: user.paceMinSecsPerKm,
      currentMax: user.paceMaxSecsPerKm,
      sliderMin: 240,
      sliderMax: 540,
      divisions: 20,
      labelText: (v) =>
          l10n.userProfileSelfProfileEditTabStateVisiblecopyFormatpaceKm(
            formatPace: formatPace(v.round()),
          ),
      patchForRange: (min, max) => patchFactory.paceRange(user, min, max),
      patchForLatestProfile: patchFactory.paceRange,
    ),
    SelfProfileMultiChoiceFieldRowDescriptor<PreferredDistance>(
      id: 'preferredDistances',
      icon: CatchIcons.straightenOutlined,
      label: l10n.userProfileSelfProfileEditTabStateLabelPreferredDistances,
      values: PreferredDistance.values,
      selected: user.preferredDistances,
      fieldName:
          l10n.userProfileSelfProfileEditTabStateVisiblecopyPreferreddistances,
      patchForValues: (values) => patchFactory.preferredDistances(user, values),
      patchForLatestProfile: patchFactory.preferredDistances,
    ),
    SelfProfileMultiChoiceFieldRowDescriptor<RunReason>(
      id: 'runningReasons',
      icon: CatchIcons.directionsRunOutlined,
      label: l10n.userProfileSelfProfileEditTabStateLabelWhyIEvent,
      values: RunReason.values,
      selected: user.runningReasons,
      fieldName:
          l10n.userProfileSelfProfileEditTabStateVisiblecopyRunningreasons,
      patchForValues: (values) => patchFactory.runningReasons(user, values),
      patchForLatestProfile: patchFactory.runningReasons,
    ),
    SelfProfileMultiChoiceFieldRowDescriptor<PreferredRunTime>(
      id: 'preferredRunTimes',
      icon: CatchIcons.wbTwilightOutlined,
      label: l10n.userProfileSelfProfileEditTabStateLabelFavoriteEventTimes,
      values: PreferredRunTime.values,
      selected: user.preferredRunTimes,
      fieldName:
          l10n.userProfileSelfProfileEditTabStateVisiblecopyPreferredruntimes,
      patchForValues: (values) => patchFactory.preferredRunTimes(user, values),
      patchForLatestProfile: patchFactory.preferredRunTimes,
    ),
  ];
}

List<SelfProfileFieldRowDescriptor> _lifestyleRows({
  required AppLocalizations l10n,
  required UserProfile user,
  required SelfProfileInlineEditPatchFactory patchFactory,
}) {
  return [
    SelfProfileSingleChoiceFieldRowDescriptor<DrinkingHabit>(
      id: 'drinking',
      icon: CatchIcons.localBarOutlined,
      label: l10n.userProfileSelfProfileEditTabStateLabelDrinking,
      values: DrinkingHabit.values,
      value: user.drinking,
      fieldName: l10n.userProfileSelfProfileEditTabStateVisiblecopyDrinking,
      patchForValue: patchFactory.drinking,
    ),
    SelfProfileSingleChoiceFieldRowDescriptor<SmokingHabit>(
      id: 'smoking',
      icon: CatchIcons.smokeFreeOutlined,
      label: l10n.userProfileSelfProfileEditTabStateLabelSmoking,
      values: SmokingHabit.values,
      value: user.smoking,
      fieldName: l10n.userProfileSelfProfileEditTabStateVisiblecopySmoking,
      patchForValue: patchFactory.smoking,
    ),
    SelfProfileSingleChoiceFieldRowDescriptor<WorkoutFrequency>(
      id: 'workout',
      icon: CatchIcons.fitnessCenterOutlined,
      label: l10n.userProfileSelfProfileEditTabStateLabelWorkout,
      values: WorkoutFrequency.values,
      value: user.workout,
      fieldName: l10n.userProfileSelfProfileEditTabStateVisiblecopyWorkout,
      patchForValue: patchFactory.workout,
    ),
    SelfProfileSingleChoiceFieldRowDescriptor<DietaryPreference>(
      id: 'diet',
      icon: CatchIcons.restaurantOutlined,
      label: l10n.userProfileSelfProfileEditTabStateLabelDiet,
      values: DietaryPreference.values,
      value: user.diet,
      fieldName: l10n.userProfileSelfProfileEditTabStateVisiblecopyDiet,
      patchForValue: patchFactory.diet,
    ),
    SelfProfileSingleChoiceFieldRowDescriptor<ChildrenStatus>(
      id: 'children',
      icon: CatchIcons.childCareOutlined,
      label: l10n.userProfileSelfProfileEditTabStateLabelChildren,
      values: ChildrenStatus.values,
      value: user.children,
      fieldName: l10n.userProfileSelfProfileEditTabStateVisiblecopyChildren,
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
  String? get currentPromptId => answer?.promptId;
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
