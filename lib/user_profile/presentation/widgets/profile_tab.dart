import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/format_utils.dart';
import 'package:catch_dating_app/core/indian_city.dart';
import 'package:catch_dating_app/core/labelled.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/section_header.dart';
import 'package:catch_dating_app/image_uploads/presentation/photo_grid.dart';
import 'package:catch_dating_app/image_uploads/presentation/photo_upload_controller.dart';
import 'package:catch_dating_app/user_profile/domain/profile_validation.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/profile_edit_sheet.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/profile_info_section.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/profile_prompt_card.dart';
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
    final basics = [
      _textEntry(
        context: context,
        ref: ref,
        icon: Icons.person_outlined,
        label: 'Name',
        value: user.name,
        fieldName: 'name',
        validator: (v) => (v ?? '').trim().isEmpty ? 'Name is required' : null,
      ),
      ProfileInfoEntry(
        icon: Icons.cake_outlined,
        label: 'Date of birth',
        value:
            '${user.dateOfBirth.day.toString().padLeft(2, '0')}/${user.dateOfBirth.month.toString().padLeft(2, '0')}/${user.dateOfBirth.year}  (${user.age} years)',
        onTap: () => showDateOfBirthEdit(
          context: context,
          ref: ref,
          currentDate: user.dateOfBirth,
          firstDate: DateTime(1920),
          lastDate: latestAllowedDateOfBirth(),
        ),
      ),
      _singleEnumEntry<Gender>(
        context: context,
        ref: ref,
        icon: Icons.wc_outlined,
        label: 'Gender',
        values: Gender.values,
        value: user.gender,
        fallback: Gender.values.first,
        fieldName: 'gender',
      ),
      _textEntry(
        context: context,
        ref: ref,
        icon: Icons.phone_outlined,
        label: 'Phone',
        value: user.phoneNumber,
        title: 'Phone number',
        fieldName: 'phoneNumber',
        validator: (v) => (v ?? '').trim().isEmpty ? 'Phone is required' : null,
      ),
      _textEntry(
        context: context,
        ref: ref,
        icon: Icons.email_outlined,
        label: 'Email',
        value: user.email.isNotEmpty ? user.email : 'Email',
        currentValue: user.email,
        fieldName: 'email',
        isAddAffordance: user.email.isEmpty,
      ),
      _intEntry(
        context: context,
        ref: ref,
        icon: Icons.height_outlined,
        label: 'Height',
        value: user.height != null ? '${user.height} cm' : 'Height',
        currentValue: user.height,
        fieldName: 'height',
        validator: (v) {
          final trimmed = (v ?? '').trim();
          if (trimmed.isEmpty) return null;
          final n = int.tryParse(trimmed);
          if (n == null) return 'Enter a number';
          if (n < 50) return 'Too short';
          if (n > 300) return 'Too tall';
          return null;
        },
        isAddAffordance: user.height == null,
      ),
    ];
    final background = [
      _textEntry(
        context: context,
        ref: ref,
        icon: Icons.work_outline,
        label: 'Job title',
        value: user.occupation ?? 'Job title',
        currentValue: user.occupation ?? '',
        fieldName: 'occupation',
        isAddAffordance: user.occupation == null,
      ),
      _textEntry(
        context: context,
        ref: ref,
        icon: Icons.business_outlined,
        label: 'Company',
        value: user.company ?? 'Company',
        currentValue: user.company ?? '',
        fieldName: 'company',
        isAddAffordance: user.company == null,
      ),
      _singleEnumEntry<EducationLevel>(
        context: context,
        ref: ref,
        icon: Icons.school_outlined,
        label: 'Education',
        values: EducationLevel.values,
        value: user.education,
        fallback: EducationLevel.values.first,
        fieldName: 'education',
      ),
      _singleEnumEntry<Religion>(
        context: context,
        ref: ref,
        icon: Icons.volunteer_activism_outlined,
        label: 'Religion',
        values: Religion.values,
        value: user.religion,
        fallback: Religion.values.first,
        fieldName: 'religion',
      ),
      _multiEnumEntry<Language>(
        context: context,
        ref: ref,
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
        ref: ref,
        icon: Icons.favorite_outline,
        label: 'Looking for',
        values: RelationshipGoal.values,
        value: user.relationshipGoal,
        fallback: RelationshipGoal.values.first,
        fieldName: 'relationshipGoal',
      ),
    ];
    final lifestyle = [
      _singleEnumEntry<DrinkingHabit>(
        context: context,
        ref: ref,
        icon: Icons.local_bar_outlined,
        label: 'Drinking',
        values: DrinkingHabit.values,
        value: user.drinking,
        fallback: DrinkingHabit.values.first,
        fieldName: 'drinking',
      ),
      _singleEnumEntry<SmokingHabit>(
        context: context,
        ref: ref,
        icon: Icons.smoke_free_outlined,
        label: 'Smoking',
        values: SmokingHabit.values,
        value: user.smoking,
        fallback: SmokingHabit.values.first,
        fieldName: 'smoking',
      ),
      _singleEnumEntry<WorkoutFrequency>(
        context: context,
        ref: ref,
        icon: Icons.fitness_center_outlined,
        label: 'Workout',
        values: WorkoutFrequency.values,
        value: user.workout,
        fallback: WorkoutFrequency.values.first,
        fieldName: 'workout',
      ),
      _singleEnumEntry<DietaryPreference>(
        context: context,
        ref: ref,
        icon: Icons.restaurant_outlined,
        label: 'Diet',
        values: DietaryPreference.values,
        value: user.diet,
        fallback: DietaryPreference.values.first,
        fieldName: 'diet',
      ),
      _singleEnumEntry<ChildrenStatus>(
        context: context,
        ref: ref,
        icon: Icons.child_care_outlined,
        label: 'Children',
        values: ChildrenStatus.values,
        value: user.children,
        fallback: ChildrenStatus.values.first,
        fieldName: 'children',
      ),
    ];
    final discovery = [
      _multiEnumEntry<Gender>(
        context: context,
        ref: ref,
        icon: Icons.people_outline,
        label: 'Interested in',
        values: Gender.values,
        selected: user.interestedInGenders,
        fieldName: 'interestedInGenders',
        placeholder: 'Everyone',
        isAddAffordanceWhenEmpty: false,
      ),
      ProfileInfoEntry(
        icon: Icons.cake_outlined,
        label: 'Age range',
        value: '${user.minAgePreference} – ${user.maxAgePreference}',
        onTap: () => showAgeRangeSheet(
          context: context,
          ref: ref,
          currentMin: user.minAgePreference,
          currentMax: user.maxAgePreference,
        ),
      ),
    ];
    final location = [
      _singleEnumEntry<IndianCity>(
        context: context,
        ref: ref,
        icon: Icons.location_on_outlined,
        label: 'City',
        values: IndianCity.values,
        value: user.city,
        fallback: IndianCity.values.first,
        fieldName: 'city',
      ),
    ];
    final running = [
      ProfileInfoEntry(
        icon: Icons.speed_outlined,
        label: 'Pace range',
        value: formatPaceRange(user.paceMinSecsPerKm, user.paceMaxSecsPerKm),
        onTap: () => showPaceEditSheet(
          context: context,
          ref: ref,
          currentMin: user.paceMinSecsPerKm,
          currentMax: user.paceMaxSecsPerKm,
        ),
      ),
      _multiEnumEntry<PreferredDistance>(
        context: context,
        ref: ref,
        icon: Icons.straighten_outlined,
        label: 'Preferred distances',
        values: PreferredDistance.values,
        selected: user.preferredDistances,
        fieldName: 'preferredDistances',
        placeholder: 'Preferred distances',
      ),
      _multiEnumEntry<RunReason>(
        context: context,
        ref: ref,
        icon: Icons.directions_run_outlined,
        label: 'Why I run',
        values: RunReason.values,
        selected: user.runningReasons,
        fieldName: 'runningReasons',
        placeholder: 'Why I run',
      ),
    ];

    return ListView(
      key: scrollViewKey,
      physics: physics,
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.s5,
        Sizes.p8,
        CatchSpacing.s5,
        Sizes.p32,
      ),
      children: [
        PhotoGrid(
          photoUrls: user.photoUrls,
          loadingIndices: uploadState.loadingIndices,
          onSlotTapped: (index) => ref
              .read(photoUploadControllerProvider.notifier)
              .pickAndUpload(index),
        ),
        gapH14,
        SectionHeader(title: 'Bio'),
        ProfilePromptCard(
          eyebrow: 'On a perfect run',
          text: user.bio.isNotEmpty
              ? user.bio
              : 'Add a bio to tell runners about yourself',
          isPrompt: user.bio.isEmpty,
          onTap: () => showTextEditSheet(
            context: context,
            ref: ref,
            title: 'Bio',
            currentValue: user.bio,
            fieldName: 'bio',
          ),
        ),
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
        SectionHeader(title: 'Discovery'),
        ProfileInfoSection(entries: discovery, grouped: true),
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
      ],
    );
  }

  ProfileInfoEntry _textEntry({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required String label,
    required String value,
    required String fieldName,
    String? title,
    String? currentValue,
    bool isAddAffordance = false,
    FormFieldValidator<String>? validator,
  }) {
    return ProfileInfoEntry(
      icon: icon,
      label: label,
      value: value,
      onTap: () => showTextEditSheet(
        context: context,
        ref: ref,
        title: title ?? label,
        currentValue: currentValue ?? value,
        fieldName: fieldName,
        validator: validator,
      ),
      isAddAffordance: isAddAffordance,
    );
  }

  ProfileInfoEntry _intEntry({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required String label,
    required String value,
    required int? currentValue,
    required String fieldName,
    bool isAddAffordance = false,
    FormFieldValidator<String>? validator,
  }) {
    return ProfileInfoEntry(
      icon: icon,
      label: label,
      value: value,
      onTap: () => showIntEditSheet(
        context: context,
        ref: ref,
        title: label,
        currentValue: currentValue,
        fieldName: fieldName,
        validator: validator,
      ),
      isAddAffordance: isAddAffordance,
    );
  }

  ProfileInfoEntry _singleEnumEntry<T extends Labelled>({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required String label,
    required List<T> values,
    required T? value,
    required T fallback,
    required String fieldName,
    String? title,
    String? placeholder,
  }) {
    return ProfileInfoEntry(
      icon: icon,
      label: label,
      value: value?.label ?? placeholder ?? label,
      onTap: () => showSingleEnumSheet<T>(
        context: context,
        ref: ref,
        title: title ?? label,
        values: values,
        currentValue: value ?? fallback,
        fieldName: fieldName,
      ),
      isAddAffordance: value == null,
    );
  }

  ProfileInfoEntry _multiEnumEntry<T extends Labelled>({
    required BuildContext context,
    required WidgetRef ref,
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
    return ProfileInfoEntry(
      icon: icon,
      label: label,
      value: isEmpty ? placeholder : selected.map((v) => v.label).join(', '),
      onTap: () => showMultiEnumSheet<T>(
        context: context,
        ref: ref,
        title: title ?? label,
        values: values,
        currentValues: selected,
        fieldName: fieldName,
      ),
      isAddAffordance: isEmpty && isAddAffordanceWhenEmpty,
    );
  }
}
