import 'package:catch_dating_app/appUser/domain/app_user.dart';
import 'package:catch_dating_app/appUser/presentation/create_profile_controller.dart';
import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:catch_dating_app/commonWidgets/app_form_layout.dart';
import 'package:catch_dating_app/commonWidgets/chip_field.dart';
import 'package:catch_dating_app/commonWidgets/enum_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateProfileScreen extends ConsumerStatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  ConsumerState<CreateProfileScreen> createState() =>
      _CreateProfileScreenState();
}

class _CreateProfileScreenState extends ConsumerState<CreateProfileScreen> {
  static const _fieldSpacing = 16.0;
  static const _buttonTopSpacing = 24.0;

  final _formKey = GlobalKey<FormState>();

  // Required
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _dateController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  DateTime? _selectedDate;
  Gender? _selectedGender;
  SexualOrientation? _selectedOrientation;

  // Optional
  final _heightController = TextEditingController();
  final _occupationController = TextEditingController();
  final _companyController = TextEditingController();
  RelationshipGoal? _selectedGoal;
  EducationLevel? _selectedEducation;
  DrinkingHabit? _selectedDrinking;
  SmokingHabit? _selectedSmoking;
  WorkoutFrequency? _selectedWorkout;
  DietaryPreference? _selectedDiet;
  ChildrenStatus? _selectedChildren;
  Religion? _selectedReligion;
  final Set<Language> _selectedLanguages = {};

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _dateController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _heightController.dispose();
    _occupationController.dispose();
    _companyController.dispose();
    super.dispose();
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
      CreateProfileController.submitMutation.run(ref, (transaction) async {
        await transaction
            .get(createProfileControllerProvider.notifier)
            .submit(
              email: _emailController.text.trim(),
              name: _nameController.text.trim(),
              dateOfBirth: _selectedDate!,
              bio: _bioController.text.trim(),
              gender: _selectedGender!,
              sexualOrientation: _selectedOrientation!,
              phoneNumber: _phoneController.text.trim(),
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
    final authUser = ref.watch(authStateChangesProvider).asData?.value;
    final email = authUser?.email ?? '';
    if (_emailController.text.isEmpty && email.isNotEmpty) {
      _emailController.text = email;
    }

    final submitMutation = ref.watch(CreateProfileController.submitMutation);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: AppFormLayout(
        formKey: _formKey,
        children: [
          Text(
            'Your profile',
            style: textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Tell us a bit about yourself',
            style: textTheme.titleMedium
                ?.copyWith(color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),

          // ── Required ───────────────────────────────────────────────────────

          TextFormField(
            controller: _emailController,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: _fieldSpacing),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              prefixIcon: Icon(Icons.person_outlined),
            ),
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Please enter your name' : null,
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
            selected: _selectedGender != null ? {_selectedGender!} : {},
            multiSelect: false,
            validator: (_) =>
                _selectedGender == null ? 'Please select your gender' : null,
            onChanged: (v) =>
                setState(() => _selectedGender = v.isEmpty ? null : v.first),
          ),
          const SizedBox(height: _fieldSpacing),
          ChipField<SexualOrientation>(
            label: 'Sexual orientation',
            values: SexualOrientation.values,
            selected:
                _selectedOrientation != null ? {_selectedOrientation!} : {},
            multiSelect: false,
            validator: (_) => _selectedOrientation == null
                ? 'Please select your sexual orientation'
                : null,
            onChanged: (v) =>
                setState(() => _selectedOrientation = v.isEmpty ? null : v.first),
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
            textInputAction: TextInputAction.newline,
            validator: (v) => v == null || v.trim().isEmpty
                ? 'Please write a short bio'
                : null,
          ),

          // ── Optional ───────────────────────────────────────────────────────

          const SizedBox(height: 40),
          const Divider(),
          const SizedBox(height: 24),
          Text(
            'More about you',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Optional — fill in now or from your profile later.',
            style: textTheme.bodySmall
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
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
          const SizedBox(height: _fieldSpacing),
          ChipField<Language>(
            label: 'Languages',
            values: Language.values,
            selected: _selectedLanguages,
            multiSelect: true,
            onChanged: (v) => setState(() {
              _selectedLanguages
                ..clear()
                ..addAll(v);
            }),
          ),

          // ── Submit ─────────────────────────────────────────────────────────

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
                      style: textTheme.bodySmall
                          ?.copyWith(color: colorScheme.onErrorContainer),
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
                const Text('Save profile'),
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
      ),
    );
  }
}
