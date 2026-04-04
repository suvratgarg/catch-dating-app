import 'package:catch_dating_app/appUser/data/app_user_repository.dart';
import 'package:catch_dating_app/appUser/domain/app_user.dart';
import 'package:catch_dating_app/commonWidgets/app_form_layout.dart';
import 'package:catch_dating_app/commonWidgets/chip_field.dart';
import 'package:catch_dating_app/commonWidgets/enum_dropdown.dart';
import 'package:catch_dating_app/profile/presentation/edit_profile_controller.dart';
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
  static const _fieldSpacing = 16.0;
  static const _buttonTopSpacing = 24.0;

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

  void _initFromUser(AppUser user) {
    if (_initialized) return;
    _initialized = true;

    _nameController.text = user.name;
    _phoneController.text = user.phoneNumber;
    _bioController.text = user.bio;
    _selectedDate = user.dateOfBirth;
    _dateController.text =
        '${user.dateOfBirth.day.toString().padLeft(2, '0')}/${user.dateOfBirth.month.toString().padLeft(2, '0')}/${user.dateOfBirth.year}';
    _selectedGender = user.gender;
    _selectedOrientation = user.sexualOrientation;
    _interestedInGenders = user.interestedInGenders.toSet();
    _minAgeController.text = user.minAgePreference.toString();
    _maxAgeController.text = user.maxAgePreference.toString();

    if (user.height != null) _heightController.text = user.height.toString();
    if (user.occupation != null) _occupationController.text = user.occupation!;
    if (user.company != null) _companyController.text = user.company!;

    _selectedGoal = user.relationshipGoal;
    _selectedEducation = user.education;
    _selectedDrinking = user.drinking;
    _selectedSmoking = user.smoking;
    _selectedWorkout = user.workout;
    _selectedDiet = user.diet;
    _selectedChildren = user.children;
    _selectedReligion = user.religion;
    _selectedLanguages = user.languages.toSet();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
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
            .submit(
              name: _nameController.text.trim(),
              dateOfBirth: _selectedDate!,
              bio: _bioController.text.trim(),
              gender: _selectedGender!,
              sexualOrientation: _selectedOrientation!,
              phoneNumber: _phoneController.text.trim(),
              interestedInGenders: _interestedInGenders.toList(),
              minAgePreference:
                  int.tryParse(_minAgeController.text) ?? 18,
              maxAgePreference:
                  int.tryParse(_maxAgeController.text) ?? 99,
              height: _heightController.text.isNotEmpty
                  ? int.tryParse(_heightController.text)
                  : null,
              occupation: _occupationController.text.trim().isNotEmpty
                  ? _occupationController.text.trim()
                  : null,
              company: _companyController.text.trim().isNotEmpty
                  ? _companyController.text.trim()
                  : null,
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(appUserStreamProvider);
    final submitMutation = ref.watch(EditProfileController.submitMutation);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    ref.listen(EditProfileController.submitMutation, (previous, current) {
      if (previous?.isPending == true && current.isSuccess) {
        Navigator.of(context).pop();
      }
    });

    if (userAsync.asData?.value != null) {
      _initFromUser(userAsync.asData!.value!);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (user) {
          if (user == null) return const SizedBox.shrink();

          return AppFormLayout(
            formKey: _formKey,
            children: [
              // ── Identity ───────────────────────────────────────────────────

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person_outlined),
                ),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Please enter your name'
                    : null,
              ),
              const SizedBox(height: _fieldSpacing),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                onTap: _pickDate,
                decoration: const InputDecoration(
                  labelText: 'Date of birth',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
                validator: (v) => v == null || v.isEmpty
                    ? 'Please select your date of birth'
                    : null,
              ),
              const SizedBox(height: _fieldSpacing),
              ChipField<Gender>(
                label: 'Gender',
                values: Gender.values,
                selected:
                    _selectedGender != null ? {_selectedGender!} : {},
                multiSelect: false,
                validator: (_) => _selectedGender == null
                    ? 'Please select your gender'
                    : null,
                onChanged: (v) => setState(
                    () => _selectedGender = v.isEmpty ? null : v.first),
              ),
              const SizedBox(height: _fieldSpacing),
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
                    () => _selectedOrientation = v.isEmpty ? null : v.first),
              ),
              const SizedBox(height: _fieldSpacing),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Please enter your phone number'
                    : null,
              ),
              const SizedBox(height: _fieldSpacing),
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  prefixIcon: Icon(Icons.edit_note_outlined),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Please write a short bio'
                    : null,
              ),

              // ── Matching preferences ───────────────────────────────────────

              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              Text('Who you want to meet',
                  style: textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ChipField<Gender>(
                label: 'Interested in',
                values: Gender.values,
                selected: _interestedInGenders,
                multiSelect: true,
                onChanged: (v) =>
                    setState(() => _interestedInGenders = v),
              ),
              const SizedBox(height: _fieldSpacing),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minAgeController,
                      decoration: const InputDecoration(
                        labelText: 'Min age',
                        prefixIcon: Icon(Icons.cake_outlined),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _maxAgeController,
                      decoration: const InputDecoration(
                        labelText: 'Max age',
                        prefixIcon: Icon(Icons.cake_outlined),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                ],
              ),

              // ── About you ──────────────────────────────────────────────────

              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              Text('About you',
                  style: textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              EnumDropdownField<RelationshipGoal>(
                values: RelationshipGoal.values,
                label: 'Looking for',
                prefixIcon: const Icon(Icons.favorite_outline),
                initialValue: _selectedGoal,
                onChanged: (v) => setState(() => _selectedGoal = v),
              ),
              const SizedBox(height: _fieldSpacing),
              TextFormField(
                controller: _heightController,
                decoration: const InputDecoration(
                  labelText: 'Height',
                  prefixIcon: Icon(Icons.height_outlined),
                  suffixText: 'cm',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: _fieldSpacing),
              TextFormField(
                controller: _occupationController,
                decoration: const InputDecoration(
                  labelText: 'Job title',
                  prefixIcon: Icon(Icons.work_outline),
                ),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: _fieldSpacing),
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(
                  labelText: 'Company',
                  prefixIcon: Icon(Icons.business_outlined),
                ),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: _fieldSpacing),
              EnumDropdownField<EducationLevel>(
                values: EducationLevel.values,
                label: 'Education',
                prefixIcon: const Icon(Icons.school_outlined),
                initialValue: _selectedEducation,
                onChanged: (v) => setState(() => _selectedEducation = v),
              ),
              const SizedBox(height: _fieldSpacing),
              EnumDropdownField<Religion>(
                values: Religion.values,
                label: 'Religion',
                prefixIcon: const Icon(Icons.volunteer_activism_outlined),
                initialValue: _selectedReligion,
                onChanged: (v) => setState(() => _selectedReligion = v),
              ),
              const SizedBox(height: _fieldSpacing),
              ChipField<Language>(
                label: 'Languages',
                values: Language.values,
                selected: _selectedLanguages,
                multiSelect: true,
                onChanged: (v) =>
                    setState(() => _selectedLanguages = v),
              ),

              // ── Lifestyle ──────────────────────────────────────────────────

              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              Text('Lifestyle',
                  style: textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              EnumDropdownField<DrinkingHabit>(
                values: DrinkingHabit.values,
                label: 'Drinking',
                prefixIcon: const Icon(Icons.local_bar_outlined),
                initialValue: _selectedDrinking,
                onChanged: (v) => setState(() => _selectedDrinking = v),
              ),
              const SizedBox(height: _fieldSpacing),
              EnumDropdownField<SmokingHabit>(
                values: SmokingHabit.values,
                label: 'Smoking',
                prefixIcon: const Icon(Icons.smoke_free_outlined),
                initialValue: _selectedSmoking,
                onChanged: (v) => setState(() => _selectedSmoking = v),
              ),
              const SizedBox(height: _fieldSpacing),
              EnumDropdownField<WorkoutFrequency>(
                values: WorkoutFrequency.values,
                label: 'Workout',
                prefixIcon: const Icon(Icons.fitness_center_outlined),
                initialValue: _selectedWorkout,
                onChanged: (v) => setState(() => _selectedWorkout = v),
              ),
              const SizedBox(height: _fieldSpacing),
              EnumDropdownField<DietaryPreference>(
                values: DietaryPreference.values,
                label: 'Diet',
                prefixIcon: const Icon(Icons.restaurant_outlined),
                initialValue: _selectedDiet,
                onChanged: (v) => setState(() => _selectedDiet = v),
              ),
              const SizedBox(height: _fieldSpacing),
              EnumDropdownField<ChildrenStatus>(
                values: ChildrenStatus.values,
                label: 'Children',
                prefixIcon: const Icon(Icons.child_care_outlined),
                initialValue: _selectedChildren,
                onChanged: (v) => setState(() => _selectedChildren = v),
              ),

              // ── Submit ─────────────────────────────────────────────────────

              if (submitMutation.hasError) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          color: colorScheme.onErrorContainer, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          (submitMutation as MutationError).error.toString(),
                          style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onErrorContainer),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: _buttonTopSpacing),
              FilledButton(
                onPressed: submitMutation.isPending ? null : _submit,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Save changes'),
                    if (submitMutation.isPending) ...[
                      const SizedBox(width: 8),
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 48),
            ],
          );
        },
      ),
    );
  }
}
