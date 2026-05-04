import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/format_utils.dart';
import 'package:catch_dating_app/core/indian_city.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/section_header.dart';
import 'package:catch_dating_app/image_uploads/presentation/photo_grid.dart';
import 'package:catch_dating_app/image_uploads/presentation/photo_upload_controller.dart';
import 'package:catch_dating_app/user_profile/domain/profile_validation.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/profile_edit_sheet.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/profile_info_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key, required this.user, required this.uploadState});

  final UserProfile user;
  final PhotoUploadState uploadState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final basics = [
      ProfileInfoEntry(
        icon: Icons.person_outlined,
        label: 'Name',
        value: user.name,
        onTap: () => showTextEditSheet(
          context: context,
          ref: ref,
          title: 'Name',
          currentValue: user.name,
          fieldName: 'name',
          validator: (v) =>
              (v ?? '').trim().isEmpty ? 'Name is required' : null,
        ),
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
      ProfileInfoEntry(
        icon: Icons.wc_outlined,
        label: 'Gender',
        value: user.gender.label,
        onTap: () => showSingleEnumSheet<Gender>(
          context: context,
          ref: ref,
          title: 'Gender',
          values: Gender.values,
          currentValue: user.gender,
          fieldName: 'gender',
        ),
      ),
      ProfileInfoEntry(
        icon: Icons.phone_outlined,
        label: 'Phone',
        value: user.phoneNumber,
        onTap: () => showTextEditSheet(
          context: context,
          ref: ref,
          title: 'Phone number',
          currentValue: user.phoneNumber,
          fieldName: 'phoneNumber',
          validator: (v) =>
              (v ?? '').trim().isEmpty ? 'Phone is required' : null,
        ),
      ),
      ProfileInfoEntry(
        icon: Icons.email_outlined,
        label: 'Email',
        value: user.email.isNotEmpty ? user.email : 'Email',
        onTap: () => showTextEditSheet(
          context: context,
          ref: ref,
          title: 'Email',
          currentValue: user.email,
          fieldName: 'email',
        ),
        isAddAffordance: user.email.isEmpty,
      ),
      ProfileInfoEntry(
        icon: Icons.height_outlined,
        label: 'Height',
        value: user.height != null ? '${user.height} cm' : 'Height',
        onTap: () => showIntEditSheet(
          context: context,
          ref: ref,
          title: 'Height',
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
        ),
        isAddAffordance: user.height == null,
      ),
    ];
    final background = [
      ProfileInfoEntry(
        icon: Icons.work_outline,
        label: 'Job title',
        value: user.occupation ?? 'Job title',
        onTap: () => showTextEditSheet(
          context: context,
          ref: ref,
          title: 'Job title',
          currentValue: user.occupation ?? '',
          fieldName: 'occupation',
        ),
        isAddAffordance: user.occupation == null,
      ),
      ProfileInfoEntry(
        icon: Icons.business_outlined,
        label: 'Company',
        value: user.company ?? 'Company',
        onTap: () => showTextEditSheet(
          context: context,
          ref: ref,
          title: 'Company',
          currentValue: user.company ?? '',
          fieldName: 'company',
        ),
        isAddAffordance: user.company == null,
      ),
      ProfileInfoEntry(
        icon: Icons.school_outlined,
        label: 'Education',
        value: user.education?.label ?? 'Education',
        onTap: () => showSingleEnumSheet<EducationLevel>(
          context: context,
          ref: ref,
          title: 'Education',
          values: EducationLevel.values,
          currentValue: user.education ?? EducationLevel.values.first,
          fieldName: 'education',
        ),
        isAddAffordance: user.education == null,
      ),
      ProfileInfoEntry(
        icon: Icons.volunteer_activism_outlined,
        label: 'Religion',
        value: user.religion?.label ?? 'Religion',
        onTap: () => showSingleEnumSheet<Religion>(
          context: context,
          ref: ref,
          title: 'Religion',
          values: Religion.values,
          currentValue: user.religion ?? Religion.values.first,
          fieldName: 'religion',
        ),
        isAddAffordance: user.religion == null,
      ),
      ProfileInfoEntry(
        icon: Icons.language_outlined,
        label: 'Languages',
        value: user.languages.isNotEmpty
            ? user.languages.map((l) => l.label).join(', ')
            : 'Languages',
        onTap: () => showMultiEnumSheet<Language>(
          context: context,
          ref: ref,
          title: 'Languages',
          values: Language.values,
          currentValues: user.languages,
          fieldName: 'languages',
        ),
        isAddAffordance: user.languages.isEmpty,
      ),
    ];
    final intentions = [
      ProfileInfoEntry(
        icon: Icons.favorite_outline,
        label: 'Looking for',
        value: user.relationshipGoal?.label ?? 'Looking for',
        onTap: () => showSingleEnumSheet<RelationshipGoal>(
          context: context,
          ref: ref,
          title: 'Looking for',
          values: RelationshipGoal.values,
          currentValue: user.relationshipGoal ?? RelationshipGoal.values.first,
          fieldName: 'relationshipGoal',
        ),
        isAddAffordance: user.relationshipGoal == null,
      ),
    ];
    final lifestyle = [
      ProfileInfoEntry(
        icon: Icons.local_bar_outlined,
        label: 'Drinking',
        value: user.drinking?.label ?? 'Drinking',
        onTap: () => showSingleEnumSheet<DrinkingHabit>(
          context: context,
          ref: ref,
          title: 'Drinking',
          values: DrinkingHabit.values,
          currentValue: user.drinking ?? DrinkingHabit.values.first,
          fieldName: 'drinking',
        ),
        isAddAffordance: user.drinking == null,
      ),
      ProfileInfoEntry(
        icon: Icons.smoke_free_outlined,
        label: 'Smoking',
        value: user.smoking?.label ?? 'Smoking',
        onTap: () => showSingleEnumSheet<SmokingHabit>(
          context: context,
          ref: ref,
          title: 'Smoking',
          values: SmokingHabit.values,
          currentValue: user.smoking ?? SmokingHabit.values.first,
          fieldName: 'smoking',
        ),
        isAddAffordance: user.smoking == null,
      ),
      ProfileInfoEntry(
        icon: Icons.fitness_center_outlined,
        label: 'Workout',
        value: user.workout?.label ?? 'Workout',
        onTap: () => showSingleEnumSheet<WorkoutFrequency>(
          context: context,
          ref: ref,
          title: 'Workout',
          values: WorkoutFrequency.values,
          currentValue: user.workout ?? WorkoutFrequency.values.first,
          fieldName: 'workout',
        ),
        isAddAffordance: user.workout == null,
      ),
      ProfileInfoEntry(
        icon: Icons.restaurant_outlined,
        label: 'Diet',
        value: user.diet?.label ?? 'Diet',
        onTap: () => showSingleEnumSheet<DietaryPreference>(
          context: context,
          ref: ref,
          title: 'Diet',
          values: DietaryPreference.values,
          currentValue: user.diet ?? DietaryPreference.values.first,
          fieldName: 'diet',
        ),
        isAddAffordance: user.diet == null,
      ),
      ProfileInfoEntry(
        icon: Icons.child_care_outlined,
        label: 'Children',
        value: user.children?.label ?? 'Children',
        onTap: () => showSingleEnumSheet<ChildrenStatus>(
          context: context,
          ref: ref,
          title: 'Children',
          values: ChildrenStatus.values,
          currentValue: user.children ?? ChildrenStatus.values.first,
          fieldName: 'children',
        ),
        isAddAffordance: user.children == null,
      ),
    ];
    final discovery = [
      ProfileInfoEntry(
        icon: Icons.people_outline,
        label: 'Interested in',
        value: user.interestedInGenders.isEmpty
            ? 'Everyone'
            : user.interestedInGenders.map((g) => g.label).join(', '),
        onTap: () => showMultiEnumSheet<Gender>(
          context: context,
          ref: ref,
          title: 'Interested in',
          values: Gender.values,
          currentValues: user.interestedInGenders,
          fieldName: 'interestedInGenders',
        ),
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
      ProfileInfoEntry(
        icon: Icons.location_on_outlined,
        label: 'City',
        value: user.city?.label ?? 'City',
        onTap: () => showSingleEnumSheet<IndianCity>(
          context: context,
          ref: ref,
          title: 'City',
          values: IndianCity.values,
          currentValue: user.city ?? IndianCity.values.first,
          fieldName: 'city',
        ),
        isAddAffordance: user.city == null,
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
      ProfileInfoEntry(
        icon: Icons.straighten_outlined,
        label: 'Preferred distances',
        value: user.preferredDistances.isEmpty
            ? 'Preferred distances'
            : user.preferredDistances.map((d) => d.label).join(', '),
        onTap: () => showMultiEnumSheet<PreferredDistance>(
          context: context,
          ref: ref,
          title: 'Preferred distances',
          values: PreferredDistance.values,
          currentValues: user.preferredDistances,
          fieldName: 'preferredDistances',
        ),
        isAddAffordance: user.preferredDistances.isEmpty,
      ),
      ProfileInfoEntry(
        icon: Icons.directions_run_outlined,
        label: 'Why I run',
        value: user.runningReasons.isEmpty
            ? 'Why I run'
            : user.runningReasons.map((r) => r.label).join(', '),
        onTap: () => showMultiEnumSheet<RunReason>(
          context: context,
          ref: ref,
          title: 'Why I run',
          values: RunReason.values,
          currentValues: user.runningReasons,
          fieldName: 'runningReasons',
        ),
        isAddAffordance: user.runningReasons.isEmpty,
      ),
    ];

    return ListView(
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
        CatchSurface(
          borderColor: t.line,
          child: _PromptCard(
            eyebrow: 'On a perfect run',
            text: user.bio.isNotEmpty
                ? user.bio
                : 'Add a bio to tell runners about yourself',
            tokens: t,
            isPrompt: user.bio.isEmpty,
            onTap: () => showTextEditSheet(
              context: context,
              ref: ref,
              title: 'Bio',
              currentValue: user.bio,
              fieldName: 'bio',
            ),
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
}

class _PromptCard extends StatelessWidget {
  const _PromptCard({
    required this.eyebrow,
    required this.text,
    required this.tokens,
    this.isPrompt = false,
    this.onTap,
  });

  final String eyebrow;
  final String text;
  final CatchTokens tokens;
  final bool isPrompt;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.all(Sizes.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(eyebrow.toUpperCase(), style: CatchTextStyles.labelM(context)),
          gapH6,
          Text(
            text,
            style: CatchTextStyles.titleL(
              context,
              color: isPrompt ? tokens.ink3 : null,
            ).copyWith(height: 1.2),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(CatchRadius.lg),
        child: content,
      );
    }

    return content;
  }
}
