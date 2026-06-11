import 'dart:async';

import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/format_utils.dart';
import 'package:catch_dating_app/core/labelled.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_section_card.dart';
import 'package:catch_dating_app/image_uploads/presentation/photo_grid.dart';
import 'package:catch_dating_app/image_uploads/presentation/photo_upload_controller.dart';
import 'package:catch_dating_app/image_uploads/presentation/profile_photo_editor_screen.dart';
import 'package:catch_dating_app/public_profile/domain/profile_insights.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/user_profile/domain/profile_photo.dart';
import 'package:catch_dating_app/user_profile/domain/profile_photo_policy.dart';
import 'package:catch_dating_app/user_profile/domain/profile_prompts.dart';
import 'package:catch_dating_app/user_profile/domain/profile_readiness.dart';
import 'package:catch_dating_app/user_profile/domain/profile_validation.dart';
import 'package:catch_dating_app/user_profile/domain/update_user_profile_patch.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/profile_info_section.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/profile_inline_editors.dart';
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
    return _ProfileTabContent(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
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
    return _ProfileTabContent(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

typedef _ProfileTabContentBuilder =
    Widget Function(BuildContext context, List<Widget> children);

const profileTabBodyPadding = EdgeInsets.fromLTRB(
  CatchSpacing.s5,
  CatchSpacing.s2,
  CatchSpacing.s5,
  CatchSpacing.s8,
);

class _ProfileTabContent extends ConsumerStatefulWidget {
  const _ProfileTabContent({
    required this.user,
    required this.uploadState,
    required this.builder,
  });

  final UserProfile user;
  final PhotoUploadState uploadState;
  final _ProfileTabContentBuilder builder;

  @override
  ConsumerState<_ProfileTabContent> createState() => _ProfileTabContentState();
}

class _ProfileTabContentState extends ConsumerState<_ProfileTabContent> {
  String? _expandedField;

  bool _isExpanded(String fieldName) => _expandedField == fieldName;

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
    final profileQuality = profileQualitySummary(
      publicProfileFromUserProfile(user),
    );
    final completedPromptCount = user.profilePrompts
        .where((prompt) => prompt.answer.trim().isNotEmpty)
        .length;
    final showRunningDetails = user.hasCurrentRunPreferences;
    final basics = [
      _textEntry(
        context: context,
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
      ProfileInfoEntry(
        icon: CatchIcons.cakeOutlined,
        label: 'Date of birth',
        value:
            '${user.dateOfBirth.day.toString().padLeft(2, '0')}/${user.dateOfBirth.month.toString().padLeft(2, '0')}/${user.dateOfBirth.year}  (${user.age} years)',
      ),
      ProfileInfoEntry(
        icon: CatchIcons.wcOutlined,
        label: 'Gender',
        value: user.gender.label,
      ),
      _textEntry(
        context: context,
        icon: CatchIcons.phoneOutlined,
        label: 'Phone',
        value: user.phoneNumber,
        title: 'Phone number',
        fieldName: 'phoneNumber',
        patchForValue: (value) =>
            UpdateUserProfilePatch(phoneNumber: value as String),
        keyboardType: TextInputType.phone,
        autofillHints: const [AutofillHints.telephoneNumber],
        validator: validateRequiredPhoneNumber,
      ),
      _textEntry(
        context: context,
        icon: CatchIcons.emailOutlined,
        label: 'Email',
        value: user.email.isNotEmpty ? user.email : 'Email',
        currentValue: user.email,
        fieldName: 'email',
        patchForValue: (value) =>
            UpdateUserProfilePatch(email: value as String),
        isAddAffordance: user.email.isEmpty,
        keyboardType: TextInputType.emailAddress,
        autofillHints: const [AutofillHints.email],
        validator: validateOptionalEmail,
      ),
      _textEntry(
        context: context,
        icon: CatchIcons.alternateEmailOutlined,
        label: 'Instagram',
        value: user.instagramHandle?.isNotEmpty == true
            ? '@${user.instagramHandle}'
            : 'Instagram',
        currentValue: user.instagramHandle ?? '',
        currentFieldValue: user.instagramHandle,
        fieldName: 'instagramHandle',
        patchForValue: (value) =>
            UpdateUserProfilePatch(instagramHandle: value as String?),
        isAddAffordance: user.instagramHandle?.isNotEmpty != true,
        keyboardType: TextInputType.text,
        textCapitalization: TextCapitalization.none,
        validator: validateOptionalInstagramHandle,
        toFieldValue: (value) {
          final handle = normalizeInstagramHandle(value);
          return handle.isEmpty ? null : handle;
        },
      ),
      ProfileInfoEntry(
        builder: (_) => ProfileInlineHeightEditor(
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
        icon: CatchIcons.heightOutlined,
        label: 'Height',
        value: user.height != null ? '${user.height} cm' : 'Height',
      ),
    ];
    final background = [
      _textEntry(
        context: context,
        icon: CatchIcons.workOutline,
        label: 'Job title',
        value: user.occupation ?? 'Job title',
        currentValue: user.occupation ?? '',
        fieldName: 'occupation',
        patchForValue: (value) =>
            UpdateUserProfilePatch(occupation: value as String),
        isAddAffordance: user.occupation == null,
      ),
      _textEntry(
        context: context,
        icon: CatchIcons.businessOutlined,
        label: 'Company',
        value: user.company ?? 'Company',
        currentValue: user.company ?? '',
        fieldName: 'company',
        patchForValue: (value) =>
            UpdateUserProfilePatch(company: value as String),
        isAddAffordance: user.company == null,
      ),
      _singleEnumEntry<EducationLevel>(
        context: context,
        icon: CatchIcons.schoolOutlined,
        label: 'Education',
        values: EducationLevel.values,
        value: user.education,
        fieldName: 'education',
        patchForValue: (value) => UpdateUserProfilePatch(education: value),
      ),
      _singleEnumEntry<Religion>(
        context: context,
        icon: CatchIcons.volunteerActivismOutlined,
        label: 'Religion',
        values: Religion.values,
        value: user.religion,
        fieldName: 'religion',
        patchForValue: (value) => UpdateUserProfilePatch(religion: value),
      ),
      _multiEnumEntry<Language>(
        context: context,
        icon: CatchIcons.languageOutlined,
        label: 'Languages',
        values: Language.values,
        selected: user.languages,
        fieldName: 'languages',
        placeholder: 'Languages',
        patchForValues: (values) => UpdateUserProfilePatch(languages: values),
      ),
    ];
    final intentions = [
      _singleEnumEntry<RelationshipGoal>(
        context: context,
        icon: CatchIcons.favoriteOutline,
        label: 'Looking for',
        values: RelationshipGoal.values,
        value: user.relationshipGoal,
        fieldName: 'relationshipGoal',
        patchForValue: (value) =>
            UpdateUserProfilePatch(relationshipGoal: value),
      ),
    ];
    final lifestyle = [
      _singleEnumEntry<DrinkingHabit>(
        context: context,
        icon: CatchIcons.localBarOutlined,
        label: 'Drinking',
        values: DrinkingHabit.values,
        value: user.drinking,
        fieldName: 'drinking',
        patchForValue: (value) => UpdateUserProfilePatch(drinking: value),
      ),
      _singleEnumEntry<SmokingHabit>(
        context: context,
        icon: CatchIcons.smokeFreeOutlined,
        label: 'Smoking',
        values: SmokingHabit.values,
        value: user.smoking,
        fieldName: 'smoking',
        patchForValue: (value) => UpdateUserProfilePatch(smoking: value),
      ),
      _singleEnumEntry<WorkoutFrequency>(
        context: context,
        icon: CatchIcons.fitnessCenterOutlined,
        label: 'Workout',
        values: WorkoutFrequency.values,
        value: user.workout,
        fieldName: 'workout',
        patchForValue: (value) => UpdateUserProfilePatch(workout: value),
      ),
      _singleEnumEntry<DietaryPreference>(
        context: context,
        icon: CatchIcons.restaurantOutlined,
        label: 'Diet',
        values: DietaryPreference.values,
        value: user.diet,
        fieldName: 'diet',
        patchForValue: (value) => UpdateUserProfilePatch(diet: value),
      ),
      _singleEnumEntry<ChildrenStatus>(
        context: context,
        icon: CatchIcons.childCareOutlined,
        label: 'Children',
        values: ChildrenStatus.values,
        value: user.children,
        fieldName: 'children',
        patchForValue: (value) => UpdateUserProfilePatch(children: value),
      ),
    ];
    final location = [
      _singleEnumEntry<CityOption>(
        context: context,
        icon: CatchIcons.locationOnOutlined,
        label: 'City',
        values: defaultCityOptions,
        value: cityOptionByName(user.city),
        fieldName: 'city',
        patchForValue: (value) => UpdateUserProfilePatch(city: value?.name),
      ),
    ];
    final running = [
      ProfileInfoEntry(
        builder: (_) => ProfileInlineRangeEditor(
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
          minFieldName: 'paceMinSecsPerKm',
          maxFieldName: 'paceMaxSecsPerKm',
          patchForRange: (min, max) => UpdateUserProfilePatch(
            activityPreferences: user.activityPreferences.copyWith(
              running: user.runningPreferences.copyWith(
                paceMinSecsPerKm: min,
                paceMaxSecsPerKm: max,
                version: currentRunPreferencesVersion,
              ),
            ),
          ),
          onSaved: _collapseField,
          onCancel: _collapseField,
        ),
        icon: CatchIcons.speedOutlined,
        label: 'Pace range',
        value: formatPaceRange(user.paceMinSecsPerKm, user.paceMaxSecsPerKm),
      ),
      _multiEnumEntry<PreferredDistance>(
        context: context,
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
      ),
      _multiEnumEntry<RunReason>(
        context: context,
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
      ),
      _multiEnumEntry<PreferredRunTime>(
        context: context,
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
      ),
    ];
    final promptAnswers = normalizeProfilePromptAnswers(user.profilePrompts);
    final prompts = List<ProfileInfoEntry>.generate(maxProfilePromptAnswers, (
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
      return _profilePromptEntry(
        context: context,
        user: user,
        index: index,
        definition: definition,
        answer: answer,
        usedPromptIds: usedPromptIds,
      );
    }, growable: false);

    return widget.builder(context, [
      _ProfileQualityGuidanceCard(summary: profileQuality),
      gapH14,
      _ProfilePhotosSection(
        profilePhotos: profilePhotos,
        uploadState: uploadState,
        onSlotTapped: (index) => unawaited(
          openProfilePhotoEditor(
            context: context,
            ref: ref,
            index: index,
            photo: index < profilePhotos.length ? profilePhotos[index] : null,
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
      gapH14,
      ProfileInfoSection(
        title: 'Profile prompts',
        subtitle: '$completedPromptCount of $maxProfilePromptAnswers answered',
        entries: prompts,
        grouped: true,
      ),
      gapH14,
      ProfileInfoSection(
        title: 'About',
        subtitle: 'Private basics and visible profile details',
        entries: basics,
        grouped: true,
      ),
      gapH14,
      ProfileInfoSection(
        title: 'Location',
        subtitle: 'Used for local runs and discovery',
        entries: location,
        grouped: true,
      ),
      gapH14,
      ProfileInfoSection(
        title: 'Background',
        subtitle: 'Work, education, and community context',
        entries: background,
        grouped: true,
      ),
      gapH14,
      ProfileInfoSection(
        title: 'Intentions',
        subtitle: 'What you want people to know upfront',
        entries: intentions,
        grouped: true,
      ),
      gapH14,
      ProfileInfoSection(
        title: 'Lifestyle',
        subtitle: 'Everyday habits that shape compatibility',
        entries: lifestyle,
        grouped: true,
      ),
      if (showRunningDetails) ...[
        gapH14,
        ProfileInfoSection(
          title: 'Running details',
          subtitle: 'Your pace, distances, and running rhythm',
          entries: running,
          grouped: true,
        ),
      ],
      gapH32,
    ]);
  }

  ProfileInfoEntry _textEntry({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required String fieldName,
    String? title,
    String? expansionKey,
    String? currentValue,
    Object? currentFieldValue,
    bool isAddAffordance = false,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.sentences,
    Iterable<String>? autofillHints,
    int? maxLines = 1,
    int? minLines,
    int? maxLength,
    bool showCounter = false,
    bool collapseStackedBlankLines = false,
    String Function(String value)? normalizeInput,
    FormFieldValidator<String>? validator,
    Object? Function(String value)? toFieldValue,
    required UpdateUserProfilePatch Function(Object? value) patchForValue,
  }) {
    final editorTitle = title ?? label;
    final editorKey = expansionKey ?? fieldName;
    return ProfileInfoEntry(
      builder: (_) => ProfileInlineTextEntryEditor(
        key: ValueKey('inline-$editorKey-entry-editor'),
        icon: icon,
        label: label,
        value: value,
        currentValue: currentValue ?? value,
        currentFieldValue: currentFieldValue ?? currentValue ?? value,
        fieldName: fieldName,
        isExpanded: _isExpanded(editorKey),
        isAddAffordance: isAddAffordance,
        onTap: () => _toggleField(editorKey),
        maxLines: maxLines,
        minLines: minLines,
        maxLength: maxLength,
        showCounter: showCounter,
        collapseStackedBlankLines: collapseStackedBlankLines,
        normalizeInput: normalizeInput,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        autofillHints: autofillHints,
        validator: validator,
        toFieldValue: toFieldValue,
        patchForValue: patchForValue,
        onSaved: _collapseField,
        onCancel: _collapseField,
      ),
      icon: icon,
      label: editorTitle,
      value: value,
      isAddAffordance: isAddAffordance,
    );
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

  ProfileInfoEntry _profilePromptEntry({
    required BuildContext context,
    required UserProfile user,
    required int index,
    required ProfilePromptDefinition definition,
    required ProfilePromptAnswer? answer,
    required Set<String> usedPromptIds,
  }) {
    final text = answer?.answer ?? '';
    final fieldName = 'profilePrompt:$index';
    final availablePromptIds = _availableProfilePromptIds(
      usedPromptIds: usedPromptIds,
      currentPromptId: answer?.promptId ?? definition.id,
    );
    return ProfileInfoEntry(
      builder: (_) => ProfileInlinePromptEntryEditor(
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
        isExpanded: _isExpanded(fieldName),
        isAddAffordance: text.isEmpty,
        onTap: () => _toggleField(fieldName),
        onSaved: _collapseField,
        onCancel: _collapseField,
      ),
      icon: CatchIcons.formatQuoteRounded,
      label: definition.title,
      value: text.isNotEmpty ? text : definition.placeholder,
      isAddAffordance: text.isEmpty,
    );
  }

  ProfileInfoEntry _singleEnumEntry<T extends Labelled>({
    required BuildContext context,
    required IconData icon,
    required String label,
    required List<T> values,
    required T? value,
    required String fieldName,
    required UpdateUserProfilePatch Function(T? value) patchForValue,
    String? title,
    String? placeholder,
  }) {
    final displayValue = value?.label ?? placeholder ?? label;
    return ProfileInfoEntry(
      builder: (_) => ProfileInlineSingleChoiceEntryEditor<T>(
        key: ValueKey('inline-$fieldName-entry-editor'),
        icon: icon,
        label: label,
        value: displayValue,
        values: values,
        currentValue: value,
        fieldName: fieldName,
        patchForValue: patchForValue,
        isExpanded: _isExpanded(fieldName),
        isAddAffordance: value == null,
        onTap: () => _toggleField(fieldName),
        onSaved: _collapseField,
        onCancel: _collapseField,
      ),
      icon: icon,
      label: title ?? label,
      value: displayValue,
      isAddAffordance: value == null,
    );
  }

  ProfileInfoEntry _multiEnumEntry<T extends Labelled>({
    required BuildContext context,
    required IconData icon,
    required String label,
    required List<T> values,
    required List<T> selected,
    required String fieldName,
    required String placeholder,
    required UpdateUserProfilePatch Function(List<T> values) patchForValues,
    String? title,
    bool isAddAffordanceWhenEmpty = true,
  }) {
    final isEmpty = selected.isEmpty;
    final displayValue = isEmpty
        ? placeholder
        : selected.map((v) => v.label).join(', ');
    return ProfileInfoEntry(
      builder: (_) => ProfileInlineMultiChoiceEntryEditor<T>(
        key: ValueKey('inline-$fieldName-entry-editor'),
        icon: icon,
        label: label,
        value: displayValue,
        values: values,
        currentValues: selected,
        fieldName: fieldName,
        patchForValues: patchForValues,
        isExpanded: _isExpanded(fieldName),
        isAddAffordance: isEmpty && isAddAffordanceWhenEmpty,
        onTap: () => _toggleField(fieldName),
        onSaved: _collapseField,
        onCancel: _collapseField,
      ),
      icon: icon,
      label: title ?? label,
      value: displayValue,
      isAddAffordance: isEmpty && isAddAffordanceWhenEmpty,
    );
  }
}

class _ProfilePhotosSection extends StatelessWidget {
  const _ProfilePhotosSection({
    required this.profilePhotos,
    required this.uploadState,
    required this.onSlotTapped,
    required this.onDeletePhoto,
    required this.onReorderPhoto,
  });

  final List<ProfilePhoto> profilePhotos;
  final PhotoUploadState uploadState;
  final void Function(int index) onSlotTapped;
  final void Function(int index) onDeletePhoto;
  final void Function(int fromIndex, int toIndex) onReorderPhoto;

  @override
  Widget build(BuildContext context) {
    final completedCount = profilePhotos.length;
    final canDeletePhotos = completedCount > minimumProfilePhotoCount;

    return CatchSectionCard(
      title: 'Photos',
      subtitle: '$completedCount of $maximumProfilePhotoCount added',
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

class _ProfileQualityGuidanceCard extends StatelessWidget {
  const _ProfileQualityGuidanceCard({required this.summary});

  final ProfileQualitySummary summary;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final progress = summary.score / 100;
    final suggestions = summary.suggestions.take(2).toList(growable: false);

    return CatchSectionCard(
      title: 'Profile strength',
      trailing: Text(
        summary.isStrong ? 'Strong' : '${summary.score}%',
        style: CatchTextStyles.statCompact(context, color: t.ink),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(CatchRadius.pill),
            child: LinearProgressIndicator(
              minHeight: 7,
              value: progress,
              backgroundColor: t.line.withValues(
                alpha: CatchOpacity.profileProgressTrack,
              ),
              valueColor: AlwaysStoppedAnimation<Color>(
                summary.isStrong ? t.success : t.primary,
              ),
            ),
          ),
          gapH10,
          Text(
            '${summary.completedItems} of ${summary.totalItems} profile basics complete',
            style: CatchTextStyles.proseM(context, color: t.ink2),
          ),
          if (suggestions.isNotEmpty) ...[
            gapH12,
            for (final suggestion in suggestions.indexed) ...[
              _ProfileQualitySuggestionRow(suggestion: suggestion.$2),
              if (suggestion.$1 < suggestions.length - 1) gapH8,
            ],
          ],
        ],
      ),
    );
  }
}

class _ProfileQualitySuggestionRow extends StatelessWidget {
  const _ProfileQualitySuggestionRow({required this.suggestion});

  final ProfileQualitySuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: CatchSpacing.micro2),
          child: Icon(
            CatchIcons.addCircleOutlineRounded,
            size: 16,
            color: t.primary,
          ),
        ),
        gapW8,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                suggestion.title,
                style: CatchTextStyles.sectionTitle(context, color: t.ink),
              ),
              gapH2,
              Text(
                suggestion.detail,
                style: CatchTextStyles.proseM(context, color: t.ink2),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
