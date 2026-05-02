import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/widgets/app_form_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_dropdown_field.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/core/widgets/chip_field.dart';
import 'package:catch_dating_app/core/widgets/error_banner.dart';
import 'package:catch_dating_app/profile/presentation/edit_profile_controller.dart';
import 'package:catch_dating_app/profile/presentation/edit_profile_form_data.dart';
import 'package:catch_dating_app/profile/presentation/widgets/edit_profile_section.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/profile_validation.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _dateController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _heightController = TextEditingController();
  final _occupationController = TextEditingController();
  final _companyController = TextEditingController();
  final _minAgeController = TextEditingController();
  final _maxAgeController = TextEditingController();

  DateTime? _selectedDate;
  Gender? _selectedGender;
  SexualOrientation? _selectedOrientation;
  Set<Gender> _interestedInGenders = {};
  RelationshipGoal? _selectedGoal;
  EducationLevel? _selectedEducation;
  DrinkingHabit? _selectedDrinking;
  SmokingHabit? _selectedSmoking;
  WorkoutFrequency? _selectedWorkout;
  DietaryPreference? _selectedDiet;
  ChildrenStatus? _selectedChildren;
  Religion? _selectedReligion;
  Set<Language> _selectedLanguages = {};

  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _heightController.dispose();
    _occupationController.dispose();
    _companyController.dispose();
    _minAgeController.dispose();
    _maxAgeController.dispose();
    super.dispose();
  }

  void _initFromUser(UserProfile user) {
    if (_initialized) return;
    _initialized = true;

    _applyFormData(EditProfileFormData.fromUserProfile(user));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: latestAllowedDateOfBirth(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      EditProfileController.submitMutation.run(ref, (transaction) async {
        await transaction
            .get(editProfileControllerProvider.notifier)
            .submit(formData: _buildFormData());
      });
    }
  }

  EditProfileFormData _buildFormData() => EditProfileFormData(
    name: _nameController.text.trim(),
    dateOfBirth: _selectedDate!,
    bio: _bioController.text.trim(),
    gender: _selectedGender!,
    sexualOrientation: _selectedOrientation!,
    phoneNumber: _phoneController.text.trim(),
    interestedInGenders: _interestedInGenders.toList(),
    minAgePreference:
        parseAgePreference(_minAgeController.text) ?? minimumProfileAge,
    maxAgePreference:
        parseAgePreference(_maxAgeController.text) ?? maximumPreferredMatchAge,
    height: _parseOptionalInt(_heightController.text),
    occupation: _trimToNull(_occupationController.text),
    company: _trimToNull(_companyController.text),
    education: _selectedEducation,
    relationshipGoal: _selectedGoal,
    drinking: _selectedDrinking,
    smoking: _selectedSmoking,
    workout: _selectedWorkout,
    diet: _selectedDiet,
    children: _selectedChildren,
    religion: _selectedReligion,
    languages: _selectedLanguages.toList(),
  );

  void _applyFormData(EditProfileFormData formData) {
    _nameController.text = formData.name;
    _phoneController.text = formData.phoneNumber;
    _bioController.text = formData.bio;
    _selectedDate = formData.dateOfBirth;
    _dateController.text = _formatDate(formData.dateOfBirth);
    _selectedGender = formData.gender;
    _selectedOrientation = formData.sexualOrientation;
    _interestedInGenders = formData.interestedInGenders.toSet();
    _minAgeController.text = formData.minAgePreference.toString();
    _maxAgeController.text = formData.maxAgePreference.toString();
    _heightController.text = formData.height?.toString() ?? '';
    _occupationController.text = formData.occupation ?? '';
    _companyController.text = formData.company ?? '';
    _selectedGoal = formData.relationshipGoal;
    _selectedEducation = formData.education;
    _selectedDrinking = formData.drinking;
    _selectedSmoking = formData.smoking;
    _selectedWorkout = formData.workout;
    _selectedDiet = formData.diet;
    _selectedChildren = formData.children;
    _selectedReligion = formData.religion;
    _selectedLanguages = formData.languages.toSet();
  }

  static String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  static int? _parseOptionalInt(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed);
  }

  static String? _trimToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProfileStreamProvider);
    final submitMutation = ref.watch(EditProfileController.submitMutation);

    ref.listen(EditProfileController.submitMutation, (previous, current) {
      if (previous?.isPending == true && current.isSuccess) {
        Navigator.of(context).pop();
      }
    });

    if (userAsync.asData?.value != null) {
      _initFromUser(userAsync.asData!.value!);
    }

    return Scaffold(
      appBar: const CatchTopBar(title: 'Edit profile'),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (user) {
          if (user == null) return const SizedBox.shrink();

          return AppFormLayout(
            formKey: _formKey,
            children: [
              EditProfileSection(
                children: [
                  CatchTextField(
                    label: 'Name',
                    controller: _nameController,
                    prefixIcon: const Icon(Icons.person_outlined),
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Please enter your name'
                        : null,
                  ),
                  gapH16,
                  CatchTextField(
                    label: 'Date of birth',
                    controller: _dateController,
                    readOnly: true,
                    onTap: _pickDate,
                    prefixIcon: const Icon(Icons.calendar_today_outlined),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Please select your date of birth';
                      }
                      if (_selectedDate == null ||
                          !isAtLeastAge(_selectedDate!)) {
                        return 'You must be at least $minimumProfileAge years old';
                      }
                      return null;
                    },
                  ),
                  gapH16,
                  ChipField<Gender>(
                    label: 'Gender',
                    values: Gender.values,
                    selected: _selectedGender != null ? {_selectedGender!} : {},
                    multiSelect: false,
                    validator: (_) => _selectedGender == null
                        ? 'Please select your gender'
                        : null,
                    onChanged: (v) => setState(
                      () => _selectedGender = v.isEmpty ? null : v.first,
                    ),
                  ),
                  gapH16,
                  ChipField<SexualOrientation>(
                    label: 'Sexual orientation',
                    values: SexualOrientation.values,
                    selected: _selectedOrientation != null
                        ? {_selectedOrientation!}
                        : {},
                    multiSelect: false,
                    validator: (_) => _selectedOrientation == null
                        ? 'Please select your sexual orientation'
                        : null,
                    onChanged: (v) => setState(
                      () => _selectedOrientation = v.isEmpty ? null : v.first,
                    ),
                  ),
                  gapH16,
                  CatchTextField(
                    label: 'Phone number',
                    controller: _phoneController,
                    prefixIcon: const Icon(Icons.phone_outlined),
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Please enter your phone number'
                        : null,
                  ),
                  gapH16,
                  CatchTextField(
                    label: 'Bio',
                    controller: _bioController,
                    prefixIcon: const Icon(Icons.edit_note_outlined),
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Please write a short bio'
                        : null,
                  ),
                ],
              ),
              EditProfileSection(
                title: 'Who you want to meet',
                showDivider: true,
                children: [
                  ChipField<Gender>(
                    label: 'Interested in',
                    isOptional: true,
                    values: Gender.values,
                    selected: _interestedInGenders,
                    multiSelect: true,
                    onChanged: (v) => setState(() => _interestedInGenders = v),
                  ),
                  gapH16,
                  Row(
                    children: [
                      Expanded(
                        child: CatchTextField(
                          label: 'Min age',
                          isOptional: true,
                          controller: _minAgeController,
                          prefixIcon: const Icon(Icons.cake_outlined),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          textInputAction: TextInputAction.next,
                          validator: (value) => validateAgePreferenceInput(
                            value,
                            otherValue: _maxAgeController.text,
                            isMinimumField: true,
                          ),
                        ),
                      ),
                      gapW12,
                      Expanded(
                        child: CatchTextField(
                          label: 'Max age',
                          isOptional: true,
                          controller: _maxAgeController,
                          prefixIcon: const Icon(Icons.cake_outlined),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          textInputAction: TextInputAction.next,
                          validator: (value) => validateAgePreferenceInput(
                            value,
                            otherValue: _minAgeController.text,
                            isMinimumField: false,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              EditProfileSection(
                title: 'About you',
                showDivider: true,
                children: [
                  CatchDropdownField<RelationshipGoal>(
                    values: RelationshipGoal.values,
                    label: 'Looking for',
                    isOptional: true,
                    prefixIcon: const Icon(Icons.favorite_outline),
                    value: _selectedGoal,
                    onChanged: (v) => setState(() => _selectedGoal = v),
                  ),
                  gapH16,
                  CatchTextField(
                    label: 'Height',
                    isOptional: true,
                    controller: _heightController,
                    prefixIcon: const Icon(Icons.height_outlined),
                    suffixText: 'cm',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textInputAction: TextInputAction.next,
                  ),
                  gapH16,
                  CatchTextField(
                    label: 'Job title',
                    isOptional: true,
                    controller: _occupationController,
                    prefixIcon: const Icon(Icons.work_outline),
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                  ),
                  gapH16,
                  CatchTextField(
                    label: 'Company',
                    isOptional: true,
                    controller: _companyController,
                    prefixIcon: const Icon(Icons.business_outlined),
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                  ),
                  gapH16,
                  CatchDropdownField<EducationLevel>(
                    values: EducationLevel.values,
                    label: 'Education',
                    isOptional: true,
                    prefixIcon: const Icon(Icons.school_outlined),
                    value: _selectedEducation,
                    onChanged: (v) => setState(() => _selectedEducation = v),
                  ),
                  gapH16,
                  CatchDropdownField<Religion>(
                    values: Religion.values,
                    label: 'Religion',
                    isOptional: true,
                    prefixIcon: const Icon(Icons.volunteer_activism_outlined),
                    value: _selectedReligion,
                    onChanged: (v) => setState(() => _selectedReligion = v),
                  ),
                  gapH16,
                  ChipField<Language>(
                    label: 'Languages',
                    isOptional: true,
                    values: Language.values,
                    selected: _selectedLanguages,
                    multiSelect: true,
                    onChanged: (v) => setState(() => _selectedLanguages = v),
                  ),
                ],
              ),
              EditProfileSection(
                title: 'Lifestyle',
                showDivider: true,
                children: [
                  CatchDropdownField<DrinkingHabit>(
                    values: DrinkingHabit.values,
                    label: 'Drinking',
                    isOptional: true,
                    prefixIcon: const Icon(Icons.local_bar_outlined),
                    value: _selectedDrinking,
                    onChanged: (v) => setState(() => _selectedDrinking = v),
                  ),
                  gapH16,
                  CatchDropdownField<SmokingHabit>(
                    values: SmokingHabit.values,
                    label: 'Smoking',
                    isOptional: true,
                    prefixIcon: const Icon(Icons.smoke_free_outlined),
                    value: _selectedSmoking,
                    onChanged: (v) => setState(() => _selectedSmoking = v),
                  ),
                  gapH16,
                  CatchDropdownField<WorkoutFrequency>(
                    values: WorkoutFrequency.values,
                    label: 'Workout',
                    isOptional: true,
                    prefixIcon: const Icon(Icons.fitness_center_outlined),
                    value: _selectedWorkout,
                    onChanged: (v) => setState(() => _selectedWorkout = v),
                  ),
                  gapH16,
                  CatchDropdownField<DietaryPreference>(
                    values: DietaryPreference.values,
                    label: 'Diet',
                    isOptional: true,
                    prefixIcon: const Icon(Icons.restaurant_outlined),
                    value: _selectedDiet,
                    onChanged: (v) => setState(() => _selectedDiet = v),
                  ),
                  gapH16,
                  CatchDropdownField<ChildrenStatus>(
                    values: ChildrenStatus.values,
                    label: 'Children',
                    isOptional: true,
                    prefixIcon: const Icon(Icons.child_care_outlined),
                    value: _selectedChildren,
                    onChanged: (v) => setState(() => _selectedChildren = v),
                  ),
                ],
              ),
              if (submitMutation.hasError) ...[
                gapH16,
                ErrorBanner(
                  message: (submitMutation as MutationError).error.toString(),
                ),
              ],
              gapH24,
              CatchButton(
                label: 'Save changes',
                onPressed: _submit,
                isLoading: submitMutation.isPending,
                fullWidth: true,
              ),
              gapH48,
            ],
          );
        },
      ),
    );
  }
}
