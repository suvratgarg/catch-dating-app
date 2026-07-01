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
import 'package:catch_dating_app/user_profile/domain/profile_photo_policy.dart';
import 'package:catch_dating_app/user_profile/domain/profile_prompts.dart';
import 'package:catch_dating_app/user_profile/domain/profile_validation.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:catch_dating_app/user_profile/presentation/self_profile_edit_tab_state.dart';
import 'package:catch_dating_app/user_profile/presentation/self_profile_inline_edit_patch_factory.dart';
import 'package:catch_dating_app/user_profile/presentation/self_profile_photo_action_controller.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/profile_info_section.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/profile_inline_editors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:catch_dating_app/user_profile/presentation/widgets/profile_tab_skeleton.dart';

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
    final editState = SelfProfileEditTabState.fromProfile(
      user: user,
      uploadState: uploadState,
    );
    const photoActions = SelfProfilePhotoActionController();
    const patchFactory = SelfProfileInlineEditPatchFactory();
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
        patchForValue: patchFactory.displayName,
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
        patchForValue: patchFactory.email,
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
        patchForValue: patchFactory.instagramHandle,
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
        patchForValue: patchFactory.height,
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
        patchForValue: patchFactory.city,
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
        patchForValue: patchFactory.occupation,
        validator: (value) =>
            validateOptionalProfileShortText(value, label: 'Job title'),
      ),
      _ProfileDirectTextEntry(
        icon: CatchIcons.businessOutlined,
        label: 'Company',
        value: 'Company',
        currentValue: user.company ?? '',
        fieldName: 'company',
        patchForValue: patchFactory.company,
        validator: (value) =>
            validateOptionalProfileShortText(value, label: 'Company'),
      ),
      _ProfileSingleEnumEntry<EducationLevel>(
        icon: CatchIcons.schoolOutlined,
        label: 'Education',
        values: EducationLevel.values,
        value: user.education,
        fieldName: 'education',
        patchForValue: patchFactory.education,
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
        patchForValue: patchFactory.religion,
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
        patchForValues: patchFactory.languages,
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
        patchForValue: patchFactory.relationshipGoal,
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
        patchForValue: patchFactory.drinking,
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
        patchForValue: patchFactory.smoking,
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
        patchForValue: patchFactory.workout,
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
        patchForValue: patchFactory.diet,
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
        patchForValue: patchFactory.children,
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
        patchForRange: (min, max) => patchFactory.paceRange(user, min, max),
        patchForLatestProfile: patchFactory.paceRange,
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
        patchForValues: (values) =>
            patchFactory.preferredDistances(user, values),
        patchForLatestProfile: patchFactory.preferredDistances,
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
        patchForValues: (values) => patchFactory.runningReasons(user, values),
        patchForLatestProfile: patchFactory.runningReasons,
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
        patchForValues: (values) =>
            patchFactory.preferredRunTimes(user, values),
        patchForLatestProfile: patchFactory.preferredRunTimes,
        isExpanded: _isExpanded('preferredRunTimes'),
        onTap: () => _toggleField('preferredRunTimes'),
        onSaved: _collapseField,
        onCancel: _collapseField,
      ),
    ];
    final prompts = [
      for (final slot in editState.promptSlots)
        _ProfilePromptEntry(
          user: user,
          slot: slot,
          isExpanded: _isExpanded(slot.fieldName),
          onTap: () => _toggleField(slot.fieldName),
          onSaved: _collapseField,
          onCancel: _collapseField,
        ),
    ];

    return widget.builder(context, [
      CatchSectionList(
        gap: 0,
        children: [
          ProfilePhotosSection(
            first: true,
            state: editState.photoGrid,
            onSlotTapped: (index) => unawaited(
              photoActions.openEditor(
                context: context,
                ref: ref,
                state: editState.photoGrid,
                index: index,
              ),
            ),
            onDeletePhoto: (index) =>
                unawaited(photoActions.deletePhoto(ref: ref, index: index)),
            onReorderPhoto: (fromIndex, toIndex) => unawaited(
              photoActions.reorderPhoto(
                ref: ref,
                fromIndex: fromIndex,
                toIndex: toIndex,
              ),
            ),
          ),
          profileInfoSection(
            context: context,
            title: 'Prompts',
            subtitle:
                '${editState.completedPromptCount} of $maxProfilePromptAnswers answered',
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
    required this.slot,
    required this.isExpanded,
    required this.onTap,
    required this.onSaved,
    required this.onCancel,
  });

  final UserProfile user;
  final SelfProfilePromptSlotState slot;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onSaved;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final text = slot.displayText;
    return ProfileInlinePromptEntryEditor(
      key: ValueKey('inline-${slot.fieldName}-entry-editor'),
      icon: CatchIcons.formatQuoteRounded,
      label: slot.definition.title,
      value: text.isNotEmpty ? text : slot.definition.placeholder,
      currentAnswer: text,
      currentPromptId: slot.currentPromptId,
      currentPrompts: user.profilePrompts,
      promptIndex: slot.index,
      availablePromptIds: slot.availablePromptIds,
      fieldName: slot.fieldName,
      isExpanded: isExpanded,
      isAddAffordance: slot.isAddAffordance,
      onTap: onTap,
      onSaved: onSaved,
      onCancel: onCancel,
    );
  }
}

class ProfilePhotosSection extends StatelessWidget {
  const ProfilePhotosSection({
    super.key,
    required this.first,
    required this.state,
    required this.onSlotTapped,
    required this.onDeletePhoto,
    required this.onReorderPhoto,
  });

  final bool first;
  final SelfProfilePhotoGridState state;
  final void Function(int index) onSlotTapped;
  final void Function(int index) onDeletePhoto;
  final void Function(int fromIndex, int toIndex) onReorderPhoto;

  @override
  Widget build(BuildContext context) {
    final completedCount = state.profilePhotos.length;

    return CatchSection.divided(
      title: 'Photos',
      count: '$completedCount of $maximumProfilePhotoCount added',
      first: first,
      child: PhotoGrid(
        profilePhotos: state.profilePhotos,
        loadingIndices: state.loadingIndices,
        onSlotTapped: onSlotTapped,
        canDeletePhotos: state.canDeletePhotos,
        onDeletePhoto: state.canDeletePhotos ? onDeletePhoto : null,
        onReorderPhoto: onReorderPhoto,
      ),
    );
  }
}
