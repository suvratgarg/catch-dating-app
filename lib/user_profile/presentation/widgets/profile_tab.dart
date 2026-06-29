import 'dart:async';

import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/format_utils.dart';
import 'package:catch_dating_app/core/labelled.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/callable_request_dtos.g.dart'
    show UpdateUserProfilePatch;
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/image_uploads/presentation/photo_grid.dart';
import 'package:catch_dating_app/image_uploads/presentation/photo_upload_controller.dart';
import 'package:catch_dating_app/image_uploads/presentation/profile_photo_editor_screen.dart';
import 'package:catch_dating_app/user_profile/domain/profile_photo.dart';
import 'package:catch_dating_app/user_profile/domain/profile_photo_policy.dart';
import 'package:catch_dating_app/user_profile/domain/profile_prompts.dart';
import 'package:catch_dating_app/user_profile/domain/profile_validation.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/profile_info_section.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/profile_inline_editors.dart';
export 'package:catch_dating_app/user_profile/presentation/widgets/profile_tab_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({
    super.key,
    required this.user,
    required this.uploadState,
    this.physics,
  });

  static const scrollViewKey = ValueKey('profile-tab-scroll-view');

  final UserProfile user;
  final PhotoUploadState uploadState;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProfileTabContent(
      user: user,
      uploadState: uploadState,
      builder: (context, children) => ListView(
        key: scrollViewKey,
        physics: physics,
        padding: profileTabBodyPadding,
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: CatchLayout.maxContentWidth,
              ),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileTabSliverBody extends ConsumerWidget {
  const ProfileTabSliverBody({
    super.key,
    required this.user,
    required this.uploadState,
  });

  final UserProfile user;
  final PhotoUploadState uploadState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProfileTabContent(
      user: user,
      uploadState: uploadState,
      builder: (context, children) => SliverPadding(
        padding: profileTabBodyPadding,
        sliver: SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: CatchLayout.maxContentWidth,
              ),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

typedef ProfileTabContentBuilder =
    Widget Function(BuildContext context, List<Widget> children);

class ProfileTabContent extends ConsumerStatefulWidget {
  const ProfileTabContent({
    super.key,
    required this.user,
    required this.uploadState,
    required this.builder,
  });

  final UserProfile user;
  final PhotoUploadState uploadState;
  final ProfileTabContentBuilder builder;

  @override
  ConsumerState<ProfileTabContent> createState() => _ProfileTabContentState();
}

class _ProfileTabContentState extends ConsumerState<ProfileTabContent> {
  String? _expandedField;

  bool _isExpanded(String fieldName) => _expandedField == fieldName;

  UpdateUserProfilePatch _runningActivityPatch(
    UserProfile user,
    RunningPreferences Function(RunningPreferences running) update,
  ) {
    return UpdateUserProfilePatch(
      activityPreferences: user.activityPreferences.copyWith(
        running: update(user.runningPreferences),
      ),
    );
  }

  void _toggleField(String fieldName) {
    setState(() {
      _expandedField = _expandedField == fieldName ? null : fieldName;
    });
  }

  void _collapseField() {
    if (_expandedField == null) return;
    setState(() => _expandedField = null);
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final uploadState = widget.uploadState;
    final profilePhotos = user.effectiveProfilePhotos;
    final completedPromptCount = user.profilePrompts
        .where((prompt) => prompt.answer.trim().isNotEmpty)
        .length;
    final basics = [
      _ProfileDirectTextEntry(
        icon: CatchIcons.personOutlined,
        label: 'Display name',
        value: user.publicDisplayName,
        currentValue: user.publicDisplayName,
        currentFieldValue: user.displayName.trim().isEmpty
            ? null
            : user.displayName.trim(),
        fieldName: 'displayName',
        patchForValue: (value) =>
            UpdateUserProfilePatch(displayName: value as String),
        textCapitalization: TextCapitalization.words,
        autofillHints: const [AutofillHints.nickname],
        validator: validateRequiredDisplayName,
        toFieldValue: (value) => value.trim(),
      ),
      CatchField.nav(
        icon: CatchIcons.cakeOutlined,
        title: 'Date of birth',
        body:
            '${user.dateOfBirth.day.toString().padLeft(2, '0')}/${user.dateOfBirth.month.toString().padLeft(2, '0')}/${user.dateOfBirth.year}  (${user.age} years)',
        bodyMaxLines: 4,
      ),
      CatchField.nav(
        icon: CatchIcons.wcOutlined,
        title: 'Gender',
        body: user.gender.label,
        bodyMaxLines: 4,
      ),
      // Phone is the OTP identity credential. It is display-only here; editing
      // it inline would let Firestore phoneNumber diverge from the Firebase Auth
      // identity with no re-verification. Changing it requires an OTP
      // re-verification flow that updates the Auth credential first.
      CatchField.nav(
        icon: CatchIcons.phoneOutlined,
        title: 'Phone',
        body: user.phoneNumber,
        bodyMaxLines: 4,
      ),
      _ProfileDirectTextEntry(
        icon: CatchIcons.emailOutlined,
        label: 'Email',
        value: 'Email',
        currentValue: user.email,
        fieldName: 'email',
        patchForValue: (value) =>
            UpdateUserProfilePatch(email: value as String),
        keyboardType: TextInputType.emailAddress,
        textCapitalization: TextCapitalization.none,
        autofillHints: const [AutofillHints.email],
        validator: validateOptionalEmail,
      ),
      _ProfileDirectTextEntry(
        icon: CatchIcons.alternateEmailOutlined,
        label: 'Instagram',
        value: 'Instagram',
        currentValue: user.instagramHandle?.isNotEmpty == true
            ? '@${user.instagramHandle}'
            : '',
        currentFieldValue: user.instagramHandle,
        fieldName: 'instagramHandle',
        patchForValue: (value) =>
            UpdateUserProfilePatch(instagramHandle: value as String?),
        keyboardType: TextInputType.text,
        textCapitalization: TextCapitalization.none,
        validator: validateOptionalInstagramHandle,
        toFieldValue: (value) {
          final handle = normalizeInstagramHandle(value);
          return handle.isEmpty ? null : handle;
        },
      ),
      ProfileInlineHeightEditor(
        key: const ValueKey('inline-height-editor'),
        icon: CatchIcons.heightOutlined,
        label: 'Height',
        value: user.height != null ? '${user.height} cm' : 'Height',
        currentValue: user.height,
        isExpanded: _isExpanded('height'),
        isAddAffordance: user.height == null,
        patchForValue: (value) => UpdateUserProfilePatch(height: value),
        onTap: () => _toggleField('height'),
        onSaved: _collapseField,
        onCancel: _collapseField,
      ),
    ];
    final about = [
      ...basics,
      _ProfileSingleEnumEntry<CityOption>(
        icon: CatchIcons.locationOnOutlined,
        label: 'City',
        values: defaultCityOptions
            .where((city) => city.profileSelectable)
            .toList(growable: false),
        value: cityOptionByName(user.city),
        fieldName: 'city',
        patchForValue: (value) =>
            UpdateUserProfilePatch(city: value?.effectiveMarketId),
        isExpanded: _isExpanded('city'),
        onTap: () => _toggleField('city'),
        onSaved: _collapseField,
        onCancel: _collapseField,
      ),
      _ProfileDirectTextEntry(
        icon: CatchIcons.workOutline,
        label: 'Job title',
        value: 'Job title',
        currentValue: user.occupation ?? '',
        fieldName: 'occupation',
        patchForValue: (value) =>
            UpdateUserProfilePatch(occupation: value as String),
        validator: (value) =>
            validateOptionalProfileShortText(value, label: 'Job title'),
      ),
      _ProfileDirectTextEntry(
        icon: CatchIcons.businessOutlined,
        label: 'Company',
        value: 'Company',
        currentValue: user.company ?? '',
        fieldName: 'company',
        patchForValue: (value) =>
            UpdateUserProfilePatch(company: value as String),
        validator: (value) =>
            validateOptionalProfileShortText(value, label: 'Company'),
      ),
      _ProfileSingleEnumEntry<EducationLevel>(
        icon: CatchIcons.schoolOutlined,
        label: 'Education',
        values: EducationLevel.values,
        value: user.education,
        fieldName: 'education',
        patchForValue: (value) => UpdateUserProfilePatch(education: value),
        isExpanded: _isExpanded('education'),
        onTap: () => _toggleField('education'),
        onSaved: _collapseField,
        onCancel: _collapseField,
      ),
      _ProfileSingleEnumEntry<Religion>(
        icon: CatchIcons.volunteerActivismOutlined,
        label: 'Religion',
        values: Religion.values,
        value: user.religion,
        fieldName: 'religion',
        patchForValue: (value) => UpdateUserProfilePatch(religion: value),
        isExpanded: _isExpanded('religion'),
        onTap: () => _toggleField('religion'),
        onSaved: _collapseField,
        onCancel: _collapseField,
      ),
      _ProfileMultiEnumEntry<Language>(
        icon: CatchIcons.languageOutlined,
        label: 'Languages',
        values: Language.values,
        selected: user.languages,
        fieldName: 'languages',
        placeholder: 'Languages',
        patchForValues: (values) => UpdateUserProfilePatch(languages: values),
        isExpanded: _isExpanded('languages'),
        onTap: () => _toggleField('languages'),
        onSaved: _collapseField,
        onCancel: _collapseField,
      ),
      _ProfileSingleEnumEntry<RelationshipGoal>(
        icon: CatchIcons.favoriteOutline,
        label: 'Looking for',
        values: RelationshipGoal.values,
        value: user.relationshipGoal,
        fieldName: 'relationshipGoal',
        patchForValue: (value) =>
            UpdateUserProfilePatch(relationshipGoal: value),
        isExpanded: _isExpanded('relationshipGoal'),
        onTap: () => _toggleField('relationshipGoal'),
        onSaved: _collapseField,
        onCancel: _collapseField,
      ),
    ];
    final lifestyle = [
      _ProfileSingleEnumEntry<DrinkingHabit>(
        icon: CatchIcons.localBarOutlined,
        label: 'Drinking',
        values: DrinkingHabit.values,
        value: user.drinking,
        fieldName: 'drinking',
        patchForValue: (value) => UpdateUserProfilePatch(drinking: value),
        isExpanded: _isExpanded('drinking'),
        onTap: () => _toggleField('drinking'),
        onSaved: _collapseField,
        onCancel: _collapseField,
      ),
      _ProfileSingleEnumEntry<SmokingHabit>(
        icon: CatchIcons.smokeFreeOutlined,
        label: 'Smoking',
        values: SmokingHabit.values,
        value: user.smoking,
        fieldName: 'smoking',
        patchForValue: (value) => UpdateUserProfilePatch(smoking: value),
        isExpanded: _isExpanded('smoking'),
        onTap: () => _toggleField('smoking'),
        onSaved: _collapseField,
        onCancel: _collapseField,
      ),
      _ProfileSingleEnumEntry<WorkoutFrequency>(
        icon: CatchIcons.fitnessCenterOutlined,
        label: 'Workout',
        values: WorkoutFrequency.values,
        value: user.workout,
        fieldName: 'workout',
        patchForValue: (value) => UpdateUserProfilePatch(workout: value),
        isExpanded: _isExpanded('workout'),
        onTap: () => _toggleField('workout'),
        onSaved: _collapseField,
        onCancel: _collapseField,
      ),
      _ProfileSingleEnumEntry<DietaryPreference>(
        icon: CatchIcons.restaurantOutlined,
        label: 'Diet',
        values: DietaryPreference.values,
        value: user.diet,
        fieldName: 'diet',
        patchForValue: (value) => UpdateUserProfilePatch(diet: value),
        isExpanded: _isExpanded('diet'),
        onTap: () => _toggleField('diet'),
        onSaved: _collapseField,
        onCancel: _collapseField,
      ),
      _ProfileSingleEnumEntry<ChildrenStatus>(
        icon: CatchIcons.childCareOutlined,
        label: 'Children',
        values: ChildrenStatus.values,
        value: user.children,
        fieldName: 'children',
        patchForValue: (value) => UpdateUserProfilePatch(children: value),
        isExpanded: _isExpanded('children'),
        onTap: () => _toggleField('children'),
        onSaved: _collapseField,
        onCancel: _collapseField,
      ),
    ];
    final running = [
      ProfileInlineRangeEditor(
        key: const ValueKey('inline-pace-range-editor'),
        icon: CatchIcons.speedOutlined,
        title: 'Pace range',
        value: formatPaceRange(user.paceMinSecsPerKm, user.paceMaxSecsPerKm),
        currentMin: user.paceMinSecsPerKm,
        currentMax: user.paceMaxSecsPerKm,
        isExpanded: _isExpanded('paceRange'),
        onTap: () => _toggleField('paceRange'),
        sliderMin: 240,
        sliderMax: 540,
        divisions: 20,
        labelText: (v) => '${formatPace(v.round())}/km',
        patchForRange: (min, max) => UpdateUserProfilePatch(
          activityPreferences: user.activityPreferences.copyWith(
            running: user.runningPreferences.copyWith(
              paceMinSecsPerKm: min,
              paceMaxSecsPerKm: max,
              version: currentRunPreferencesVersion,
            ),
          ),
        ),
        patchForLatestProfile: (latest, min, max) => _runningActivityPatch(
          latest,
          (running) => running.copyWith(
            paceMinSecsPerKm: min,
            paceMaxSecsPerKm: max,
            version: currentRunPreferencesVersion,
          ),
        ),
        onSaved: _collapseField,
        onCancel: _collapseField,
      ),
      _ProfileMultiEnumEntry<PreferredDistance>(
        icon: CatchIcons.straightenOutlined,
        label: 'Preferred distances',
        values: PreferredDistance.values,
        selected: user.preferredDistances,
        fieldName: 'preferredDistances',
        placeholder: 'Preferred distances',
        patchForValues: (values) => UpdateUserProfilePatch(
          activityPreferences: user.activityPreferences.copyWith(
            running: user.runningPreferences.copyWith(
              preferredDistances: values,
              version: currentRunPreferencesVersion,
            ),
          ),
        ),
        patchForLatestProfile: (latest, values) => _runningActivityPatch(
          latest,
          (running) => running.copyWith(
            preferredDistances: values,
            version: currentRunPreferencesVersion,
          ),
        ),
        isExpanded: _isExpanded('preferredDistances'),
        onTap: () => _toggleField('preferredDistances'),
        onSaved: _collapseField,
        onCancel: _collapseField,
      ),
      _ProfileMultiEnumEntry<RunReason>(
        icon: CatchIcons.directionsRunOutlined,
        label: 'Why I event',
        values: RunReason.values,
        selected: user.runningReasons,
        fieldName: 'runningReasons',
        placeholder: 'Why I event',
        patchForValues: (values) => UpdateUserProfilePatch(
          activityPreferences: user.activityPreferences.copyWith(
            running: user.runningPreferences.copyWith(
              runningReasons: values,
              version: currentRunPreferencesVersion,
            ),
          ),
        ),
        patchForLatestProfile: (latest, values) => _runningActivityPatch(
          latest,
          (running) => running.copyWith(
            runningReasons: values,
            version: currentRunPreferencesVersion,
          ),
        ),
        isExpanded: _isExpanded('runningReasons'),
        onTap: () => _toggleField('runningReasons'),
        onSaved: _collapseField,
        onCancel: _collapseField,
      ),
      _ProfileMultiEnumEntry<PreferredRunTime>(
        icon: CatchIcons.wbTwilightOutlined,
        label: 'Favorite event times',
        values: PreferredRunTime.values,
        selected: user.preferredRunTimes,
        fieldName: 'preferredRunTimes',
        placeholder: 'Favorite event times',
        patchForValues: (values) => UpdateUserProfilePatch(
          activityPreferences: user.activityPreferences.copyWith(
            running: user.runningPreferences.copyWith(
              preferredRunTimes: values,
              version: currentRunPreferencesVersion,
            ),
          ),
        ),
        patchForLatestProfile: (latest, values) => _runningActivityPatch(
          latest,
          (running) => running.copyWith(
            preferredRunTimes: values,
            version: currentRunPreferencesVersion,
          ),
        ),
        isExpanded: _isExpanded('preferredRunTimes'),
        onTap: () => _toggleField('preferredRunTimes'),
        onSaved: _collapseField,
        onCancel: _collapseField,
      ),
    ];
    final promptAnswers = normalizeProfilePromptAnswers(user.profilePrompts);
    final prompts = List<Widget>.generate(maxProfilePromptAnswers, (
      index,
    ) {
      final answer = index < promptAnswers.length ? promptAnswers[index] : null;
      final usedPromptIds = {
        for (final prompt in promptAnswers)
          if (prompt.promptId != answer?.promptId) prompt.promptId,
      };
      final definition = _profilePromptDefinitionForSlot(
        index: index,
        answer: answer,
        usedPromptIds: usedPromptIds,
      );
      final promptFieldName = 'profilePrompt:$index';
      return _ProfilePromptEntry(
        user: user,
        index: index,
        definition: definition,
        answer: answer,
        usedPromptIds: usedPromptIds,
        isExpanded: _isExpanded(promptFieldName),
        onTap: () => _toggleField(promptFieldName),
        onSaved: _collapseField,
        onCancel: _collapseField,
      );
    }, growable: false);

    return widget.builder(context, [
      CatchSectionList(
        gap: 0,
        children: [
          ProfilePhotosSection(
            first: true,
            profilePhotos: profilePhotos,
            uploadState: uploadState,
            onSlotTapped: (index) => unawaited(
              openProfilePhotoEditor(
                context: context,
                ref: ref,
                index: index,
                photo: index < profilePhotos.length
                    ? profilePhotos[index]
                    : null,
                canDelete: profilePhotos.length > minimumProfilePhotoCount,
              ),
            ),
            onDeletePhoto: (index) => unawaited(
              PhotoUploadController.uploadPhotoMutation.run(ref, (tx) async {
                await tx
                    .get(photoUploadControllerProvider.notifier)
                    .deletePhoto(index);
              }),
            ),
            onReorderPhoto: (fromIndex, toIndex) => unawaited(
              PhotoUploadController.uploadPhotoMutation.run(ref, (tx) async {
                await tx
                    .get(photoUploadControllerProvider.notifier)
                    .reorderPhoto(fromIndex: fromIndex, toIndex: toIndex);
              }),
            ),
          ),
          profileInfoSection(
            context: context,
            title: 'Prompts',
            subtitle:
                '$completedPromptCount of $maxProfilePromptAnswers answered',
            children: prompts,
            grouped: true,
            fullBleedRows: true,
          ),
          profileInfoSection(
            context: context,
            title: 'About you',
            children: about,
            grouped: true,
            fullBleedRows: true,
          ),
          profileInfoSection(
            context: context,
            title: 'Running',
            children: running,
            grouped: true,
            fullBleedRows: true,
          ),
          profileInfoSection(
            context: context,
            title: 'Lifestyle',
            children: lifestyle,
            grouped: true,
            fullBleedRows: true,
          ),
        ],
      ),
      gapH32,
    ]);
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
}

class _ProfileDirectTextEntry extends StatelessWidget {
  const _ProfileDirectTextEntry({
    required this.icon,
    required this.label,
    required this.value,
    required this.fieldName,
    this.currentValue,
    this.currentFieldValue,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.sentences,
    this.autofillHints,
    this.validator,
    this.toFieldValue,
    required this.patchForValue,
  });

  final IconData icon;
  final String label;
  final String value;
  final String fieldName;
  final String? currentValue;
  final Object? currentFieldValue;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final FormFieldValidator<String>? validator;
  final Object? Function(String value)? toFieldValue;
  final UpdateUserProfilePatch Function(Object? value) patchForValue;

  @override
  Widget build(BuildContext context) {
    return ProfileDirectTextEntryField(
      icon: icon,
      label: label,
      value: value,
      currentValue: currentValue ?? value,
      currentFieldValue: currentFieldValue ?? currentValue ?? value,
      fieldName: fieldName,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      autofillHints: autofillHints,
      validator: validator,
      toFieldValue: toFieldValue,
      patchForValue: patchForValue,
    );
  }
}

class _ProfileSingleEnumEntry<T extends Labelled> extends StatelessWidget {
  const _ProfileSingleEnumEntry({
    required this.icon,
    required this.label,
    required this.values,
    required this.fieldName,
    required this.patchForValue,
    required this.isExpanded,
    required this.onTap,
    required this.onSaved,
    required this.onCancel,
    this.value,
    this.placeholder,
  });

  final IconData icon;
  final String label;
  final List<T> values;
  final T? value;
  final String fieldName;
  final UpdateUserProfilePatch Function(T? value) patchForValue;
  final String? placeholder;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onSaved;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final displayValue = value?.label ?? placeholder ?? label;
    return ProfileInlineSingleChoiceEntryEditor<T>(
      key: ValueKey('inline-$fieldName-entry-editor'),
      icon: icon,
      label: label,
      value: displayValue,
      values: values,
      currentValue: value,
      fieldName: fieldName,
      patchForValue: patchForValue,
      isExpanded: isExpanded,
      isAddAffordance: value == null,
      onTap: onTap,
      onSaved: onSaved,
      onCancel: onCancel,
    );
  }
}

class _ProfileMultiEnumEntry<T extends Labelled> extends StatelessWidget {
  const _ProfileMultiEnumEntry({
    required this.icon,
    required this.label,
    required this.values,
    required this.selected,
    required this.fieldName,
    required this.placeholder,
    required this.patchForValues,
    required this.isExpanded,
    required this.onTap,
    required this.onSaved,
    required this.onCancel,
    this.patchForLatestProfile,
    this.isAddAffordanceWhenEmpty = true,
  });

  final IconData icon;
  final String label;
  final List<T> values;
  final List<T> selected;
  final String fieldName;
  final String placeholder;
  final UpdateUserProfilePatch Function(List<T> values) patchForValues;
  final UpdateUserProfilePatch Function(UserProfile user, List<T> values)?
      patchForLatestProfile;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onSaved;
  final VoidCallback onCancel;
  final bool isAddAffordanceWhenEmpty;

  @override
  Widget build(BuildContext context) {
    final isEmpty = selected.isEmpty;
    final displayValue = isEmpty
        ? placeholder
        : selected.map((v) => v.label).join(', ');
    return ProfileInlineMultiChoiceEntryEditor<T>(
      key: ValueKey('inline-$fieldName-entry-editor'),
      icon: icon,
      label: label,
      value: displayValue,
      values: values,
      currentValues: selected,
      fieldName: fieldName,
      patchForValues: patchForValues,
      patchForLatestProfile: patchForLatestProfile,
      isExpanded: isExpanded,
      isAddAffordance: isEmpty && isAddAffordanceWhenEmpty,
      onTap: onTap,
      onSaved: onSaved,
      onCancel: onCancel,
    );
  }
}

class _ProfilePromptEntry extends StatelessWidget {
  const _ProfilePromptEntry({
    required this.user,
    required this.index,
    required this.definition,
    required this.answer,
    required this.usedPromptIds,
    required this.isExpanded,
    required this.onTap,
    required this.onSaved,
    required this.onCancel,
  });

  final UserProfile user;
  final int index;
  final ProfilePromptDefinition definition;
  final ProfilePromptAnswer? answer;
  final Set<String> usedPromptIds;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onSaved;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final text = answer?.answer ?? '';
    final fieldName = 'profilePrompt:$index';
    final availablePromptIds = _availableProfilePromptIds(
      usedPromptIds: usedPromptIds,
      currentPromptId: answer?.promptId ?? definition.id,
    );
    return ProfileInlinePromptEntryEditor(
      key: ValueKey('inline-$fieldName-entry-editor'),
      icon: CatchIcons.formatQuoteRounded,
      label: definition.title,
      value: text.isNotEmpty ? text : definition.placeholder,
      currentAnswer: text,
      currentPromptId: answer?.promptId ?? definition.id,
      currentPrompts: user.profilePrompts,
      promptIndex: index,
      availablePromptIds: availablePromptIds,
      fieldName: fieldName,
      isExpanded: isExpanded,
      isAddAffordance: text.isEmpty,
      onTap: onTap,
      onSaved: onSaved,
      onCancel: onCancel,
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
}

class ProfilePhotosSection extends StatelessWidget {
  const ProfilePhotosSection({
    super.key,
    required this.first,
    required this.profilePhotos,
    required this.uploadState,
    required this.onSlotTapped,
    required this.onDeletePhoto,
    required this.onReorderPhoto,
  });

  final bool first;
  final List<ProfilePhoto> profilePhotos;
  final PhotoUploadState uploadState;
  final void Function(int index) onSlotTapped;
  final void Function(int index) onDeletePhoto;
  final void Function(int fromIndex, int toIndex) onReorderPhoto;

  @override
  Widget build(BuildContext context) {
    final completedCount = profilePhotos.length;
    final canDeletePhotos = completedCount > minimumProfilePhotoCount;

    return CatchSection.divided(
      title: 'Photos',
      count: '$completedCount of $maximumProfilePhotoCount added',
      first: first,
      child: PhotoGrid(
        profilePhotos: profilePhotos,
        loadingIndices: uploadState.loadingIndices,
        onSlotTapped: onSlotTapped,
        canDeletePhotos: canDeletePhotos,
        onDeletePhoto: canDeletePhotos ? onDeletePhoto : null,
        onReorderPhoto: onReorderPhoto,
      ),
    );
  }
}
