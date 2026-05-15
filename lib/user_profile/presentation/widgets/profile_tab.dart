import 'dart:async';

import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/format_utils.dart';
import 'package:catch_dating_app/core/labelled.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/section_header.dart';
import 'package:catch_dating_app/image_uploads/presentation/photo_grid.dart';
import 'package:catch_dating_app/image_uploads/presentation/photo_upload_controller.dart';
import 'package:catch_dating_app/public_profile/domain/profile_insights.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/user_profile/domain/profile_photo.dart';
import 'package:catch_dating_app/user_profile/domain/profile_prompts.dart';
import 'package:catch_dating_app/user_profile/domain/profile_validation.dart';
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
        children: children,
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
        sliver: SliverList.list(children: children),
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
    final photoUrls = profilePhotoUrls(profilePhotos);
    final profileQuality = profileQualitySummary(
      publicProfileFromUserProfile(user),
    );
    final basics = [
      _textEntry(
        context: context,
        icon: Icons.person_outlined,
        label: 'Display name',
        value: user.publicDisplayName,
        currentValue: user.publicDisplayName,
        currentFieldValue: user.displayName.trim().isEmpty
            ? null
            : user.displayName.trim(),
        fieldName: 'displayName',
        textCapitalization: TextCapitalization.words,
        autofillHints: const [AutofillHints.nickname],
        validator: validateRequiredDisplayName,
        toFieldValue: (value) => value.trim(),
      ),
      ProfileInfoEntry(
        icon: Icons.cake_outlined,
        label: 'Date of birth',
        value:
            '${user.dateOfBirth.day.toString().padLeft(2, '0')}/${user.dateOfBirth.month.toString().padLeft(2, '0')}/${user.dateOfBirth.year}  (${user.age} years)',
      ),
      ProfileInfoEntry(
        icon: Icons.wc_outlined,
        label: 'Gender',
        value: user.gender.label,
      ),
      _textEntry(
        context: context,
        icon: Icons.phone_outlined,
        label: 'Phone',
        value: user.phoneNumber,
        title: 'Phone number',
        fieldName: 'phoneNumber',
        keyboardType: TextInputType.phone,
        autofillHints: const [AutofillHints.telephoneNumber],
        validator: validateRequiredPhoneNumber,
      ),
      _textEntry(
        context: context,
        icon: Icons.email_outlined,
        label: 'Email',
        value: user.email.isNotEmpty ? user.email : 'Email',
        currentValue: user.email,
        fieldName: 'email',
        isAddAffordance: user.email.isEmpty,
        keyboardType: TextInputType.emailAddress,
        autofillHints: const [AutofillHints.email],
        validator: validateOptionalEmail,
      ),
      _textEntry(
        context: context,
        icon: Icons.alternate_email_outlined,
        label: 'Instagram',
        value: user.instagramHandle?.isNotEmpty == true
            ? '@${user.instagramHandle}'
            : 'Instagram',
        currentValue: user.instagramHandle ?? '',
        currentFieldValue: user.instagramHandle,
        fieldName: 'instagramHandle',
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
          icon: Icons.height_outlined,
          label: 'Height',
          value: user.height != null ? '${user.height} cm' : 'Height',
          currentValue: user.height,
          isExpanded: _isExpanded('height'),
          isAddAffordance: user.height == null,
          onTap: () => _toggleField('height'),
          onSaved: _collapseField,
          onCancel: _collapseField,
        ),
        icon: Icons.height_outlined,
        label: 'Height',
        value: user.height != null ? '${user.height} cm' : 'Height',
      ),
    ];
    final background = [
      _textEntry(
        context: context,
        icon: Icons.work_outline,
        label: 'Job title',
        value: user.occupation ?? 'Job title',
        currentValue: user.occupation ?? '',
        fieldName: 'occupation',
        isAddAffordance: user.occupation == null,
      ),
      _textEntry(
        context: context,
        icon: Icons.business_outlined,
        label: 'Company',
        value: user.company ?? 'Company',
        currentValue: user.company ?? '',
        fieldName: 'company',
        isAddAffordance: user.company == null,
      ),
      _singleEnumEntry<EducationLevel>(
        context: context,
        icon: Icons.school_outlined,
        label: 'Education',
        values: EducationLevel.values,
        value: user.education,
        fieldName: 'education',
      ),
      _singleEnumEntry<Religion>(
        context: context,
        icon: Icons.volunteer_activism_outlined,
        label: 'Religion',
        values: Religion.values,
        value: user.religion,
        fieldName: 'religion',
      ),
      _multiEnumEntry<Language>(
        context: context,
        icon: Icons.language_outlined,
        label: 'Languages',
        values: Language.values,
        selected: user.languages,
        fieldName: 'languages',
        placeholder: 'Languages',
      ),
    ];
    final intentions = [
      _singleEnumEntry<RelationshipGoal>(
        context: context,
        icon: Icons.favorite_outline,
        label: 'Looking for',
        values: RelationshipGoal.values,
        value: user.relationshipGoal,
        fieldName: 'relationshipGoal',
      ),
    ];
    final lifestyle = [
      _singleEnumEntry<DrinkingHabit>(
        context: context,
        icon: Icons.local_bar_outlined,
        label: 'Drinking',
        values: DrinkingHabit.values,
        value: user.drinking,
        fieldName: 'drinking',
      ),
      _singleEnumEntry<SmokingHabit>(
        context: context,
        icon: Icons.smoke_free_outlined,
        label: 'Smoking',
        values: SmokingHabit.values,
        value: user.smoking,
        fieldName: 'smoking',
      ),
      _singleEnumEntry<WorkoutFrequency>(
        context: context,
        icon: Icons.fitness_center_outlined,
        label: 'Workout',
        values: WorkoutFrequency.values,
        value: user.workout,
        fieldName: 'workout',
      ),
      _singleEnumEntry<DietaryPreference>(
        context: context,
        icon: Icons.restaurant_outlined,
        label: 'Diet',
        values: DietaryPreference.values,
        value: user.diet,
        fieldName: 'diet',
      ),
      _singleEnumEntry<ChildrenStatus>(
        context: context,
        icon: Icons.child_care_outlined,
        label: 'Children',
        values: ChildrenStatus.values,
        value: user.children,
        fieldName: 'children',
      ),
    ];
    final location = [
      _singleEnumEntry<CityOption>(
        context: context,
        icon: Icons.location_on_outlined,
        label: 'City',
        values: defaultCityOptions,
        value: cityOptionByName(user.city),
        fieldName: 'city',
      ),
    ];
    final running = [
      ProfileInfoEntry(
        builder: (_) => ProfileInlineRangeEditor(
          key: const ValueKey('inline-pace-range-editor'),
          icon: Icons.speed_outlined,
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
          onSaved: _collapseField,
          onCancel: _collapseField,
        ),
        icon: Icons.speed_outlined,
        label: 'Pace range',
        value: formatPaceRange(user.paceMinSecsPerKm, user.paceMaxSecsPerKm),
      ),
      _multiEnumEntry<PreferredDistance>(
        context: context,
        icon: Icons.straighten_outlined,
        label: 'Preferred distances',
        values: PreferredDistance.values,
        selected: user.preferredDistances,
        fieldName: 'preferredDistances',
        placeholder: 'Preferred distances',
      ),
      _multiEnumEntry<RunReason>(
        context: context,
        icon: Icons.directions_run_outlined,
        label: 'Why I run',
        values: RunReason.values,
        selected: user.runningReasons,
        fieldName: 'runningReasons',
        placeholder: 'Why I run',
      ),
      _multiEnumEntry<PreferredRunTime>(
        context: context,
        icon: Icons.wb_twilight_outlined,
        label: 'Favorite run times',
        values: PreferredRunTime.values,
        selected: user.preferredRunTimes,
        fieldName: 'preferredRunTimes',
        placeholder: 'Favorite run times',
      ),
    ];
    final prompts = defaultProfilePromptIds
        .map((promptId) {
          final definition = profilePromptDefinition(promptId);
          return _profilePromptEntry(
            context: context,
            user: user,
            definition: definition,
          );
        })
        .toList(growable: false);
    final photoCaptions = profilePhotos
        .map((photo) {
          final index = photo.position;
          return _photoPromptEntry(
            context: context,
            user: user,
            photoIndex: index,
            definition: defaultPhotoPromptForIndex(index),
          );
        })
        .toList(growable: false);

    return widget.builder(context, [
      _ProfileQualityGuidanceCard(summary: profileQuality),
      gapH14,
      PhotoGrid(
        photoUrls: photoUrls,
        loadingIndices: uploadState.loadingIndices,
        onSlotTapped: (index) {
          unawaited(
            PhotoUploadController.uploadPhotoMutation.run(ref, (tx) async {
              await tx
                  .get(photoUploadControllerProvider.notifier)
                  .pickAndUpload(index);
            }),
          );
        },
      ),
      gapH14,
      SectionHeader(title: 'Profile prompts'),
      ProfileInfoSection(entries: prompts, grouped: true),
      if (photoCaptions.isNotEmpty) ...[
        gapH20,
        SectionHeader(title: 'Photo captions'),
        ProfileInfoSection(entries: photoCaptions, grouped: true),
      ],
      gapH20,
      SectionHeader(title: 'About'),
      ProfileInfoSection(entries: basics, grouped: true),
      gapH20,
      SectionHeader(title: 'Location'),
      ProfileInfoSection(entries: location, grouped: true),
      gapH20,
      SectionHeader(title: 'Background'),
      ProfileInfoSection(entries: background, grouped: true),
      gapH20,
      SectionHeader(title: 'Intentions'),
      ProfileInfoSection(entries: intentions, grouped: true),
      gapH20,
      SectionHeader(title: 'Lifestyle'),
      ProfileInfoSection(entries: lifestyle, grouped: true),
      gapH20,
      SectionHeader(title: 'Running Details'),
      ProfileInfoSection(entries: running, grouped: true),
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
    Map<String, dynamic> Function(String value)? toFields,
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
        toFields: toFields,
        onSaved: _collapseField,
        onCancel: _collapseField,
      ),
      icon: icon,
      label: editorTitle,
      value: value,
      isAddAffordance: isAddAffordance,
    );
  }

  ProfileInfoEntry _profilePromptEntry({
    required BuildContext context,
    required UserProfile user,
    required ProfilePromptDefinition definition,
  }) {
    final answer = profilePromptById(user.profilePrompts, definition.id);
    final text = answer?.answer ?? '';
    return _textEntry(
      context: context,
      icon: Icons.format_quote_rounded,
      label: definition.title,
      value: text.isNotEmpty ? text : definition.placeholder,
      currentValue: text,
      fieldName: 'profilePrompts',
      expansionKey: 'profilePrompt:${definition.id}',
      isAddAffordance: text.isEmpty,
      maxLines: null,
      maxLength: maximumProfilePromptAnswerLength,
      showCounter: true,
      collapseStackedBlankLines: true,
      normalizeInput: normalizeProfilePromptAnswer,
      keyboardType: TextInputType.multiline,
      validator: validateOptionalProfilePromptAnswer,
      toFieldValue: (value) => profilePromptsToJson(
        replaceProfilePromptAnswer(
          current: user.profilePrompts,
          definition: definition,
          answer: value,
        ),
      ),
    );
  }

  ProfileInfoEntry _photoPromptEntry({
    required BuildContext context,
    required UserProfile user,
    required int photoIndex,
    required PhotoPromptDefinition definition,
  }) {
    final answer =
        user.effectiveProfilePhotos
            .where((photo) => photo.position == photoIndex)
            .firstOrNull
            ?.prompt ??
        photoPromptByIndex(user.photoPrompts, photoIndex);
    final caption = answer?.caption ?? '';
    return _textEntry(
      context: context,
      icon: Icons.photo_camera_outlined,
      label: definition.title,
      value: caption.isNotEmpty ? caption : definition.placeholder,
      currentValue: caption,
      fieldName: 'photoPrompts',
      expansionKey: 'photoPrompt:$photoIndex',
      isAddAffordance: caption.isEmpty,
      maxLines: 2,
      maxLength: maximumPhotoPromptCaptionLength,
      showCounter: true,
      collapseStackedBlankLines: true,
      normalizeInput: normalizePhotoPromptCaption,
      keyboardType: TextInputType.multiline,
      validator: validateOptionalPhotoPromptCaption,
      toFieldValue: (value) => photoPromptsToJson(
        replacePhotoPromptAnswer(
          current: user.photoPrompts,
          photoIndex: photoIndex,
          definition: definition,
          caption: value,
        ),
      ),
      toFields: (value) {
        final photoPromptJson = photoPromptsToJson(
          replacePhotoPromptAnswer(
            current: user.photoPrompts,
            photoIndex: photoIndex,
            definition: definition,
            caption: value,
          ),
        );
        final updatedProfilePhotos = [
          for (final photo in user.effectiveProfilePhotos)
            if (photo.position == photoIndex)
              replaceProfilePhotoPrompt(
                photo: photo,
                definition: definition,
                caption: value,
              )
            else
              photo,
        ];
        return {
          'photoPrompts': photoPromptJson,
          'profilePhotos': profilePhotosToJson(updatedProfilePhotos),
        };
      },
    );
  }

  ProfileInfoEntry _singleEnumEntry<T extends Labelled>({
    required BuildContext context,
    required IconData icon,
    required String label,
    required List<T> values,
    required T? value,
    required String fieldName,
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

class _ProfileQualityGuidanceCard extends StatelessWidget {
  const _ProfileQualityGuidanceCard({required this.summary});

  final ProfileQualitySummary summary;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final progress = summary.score / 100;
    final suggestions = summary.suggestions.take(2).toList(growable: false);

    return CatchSurface(
      borderColor: t.line,
      padding: const EdgeInsets.all(CatchSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Profile strength',
                  style: CatchTextStyles.labelL(context, color: t.ink2),
                ),
              ),
              Text(
                summary.isStrong ? 'Strong' : '${summary.score}%',
                style: CatchTextStyles.titleS(context, color: t.ink),
              ),
            ],
          ),
          gapH10,
          ClipRRect(
            borderRadius: BorderRadius.circular(CatchRadius.pill),
            child: LinearProgressIndicator(
              minHeight: 7,
              value: progress,
              backgroundColor: t.line.withValues(alpha: 0.7),
              valueColor: AlwaysStoppedAnimation<Color>(
                summary.isStrong ? t.success : t.primary,
              ),
            ),
          ),
          gapH10,
          Text(
            '${summary.completedItems} of ${summary.totalItems} profile basics complete',
            style: CatchTextStyles.bodyS(context, color: t.ink2),
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
          padding: const EdgeInsets.only(top: 2),
          child: Icon(
            Icons.add_circle_outline_rounded,
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
                style: CatchTextStyles.labelL(context, color: t.ink),
              ),
              gapH2,
              Text(
                suggestion.detail,
                style: CatchTextStyles.bodyS(context, color: t.ink2),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
