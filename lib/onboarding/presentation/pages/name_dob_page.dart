import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_controller.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_step.dart';
import 'package:catch_dating_app/onboarding/presentation/widgets/onboarding_step_header.dart';
import 'package:catch_dating_app/user_profile/domain/profile_validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NameDobPage extends ConsumerStatefulWidget {
  const NameDobPage({super.key});

  @override
  ConsumerState<NameDobPage> createState() => _NameDobPageState();
}

class _NameDobPageState extends ConsumerState<NameDobPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dateController = TextEditingController();
  DateTime? _selectedDate;
  bool _phoneVerified = false;

  @override
  void initState() {
    super.initState();
    _seedDraft(ref.read(onboardingControllerProvider));
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _dateController.dispose();
    super.dispose();
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
        _dateController.text = _formatDate(picked);
      });
    }
  }

  int? _age() {
    if (_selectedDate == null) return null;
    return calculateAge(_selectedDate!);
  }

  void _seedDraft(OnboardingData data) {
    _firstNameController.text = data.firstName;
    _lastNameController.text = data.lastName;
    _selectedDate = data.dateOfBirth;
    _dateController.text = data.dateOfBirth != null
        ? _formatDate(data.dateOfBirth!)
        : '';

    _phoneController.text = data.phoneNumber;
    _phoneVerified = data.phoneVerified;
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ref
          .read(onboardingControllerProvider.notifier)
          .setNameDob(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            dateOfBirth: _selectedDate!,
            phoneNumber: _phoneController.text.trim(),
          );
      ref
          .read(onboardingControllerProvider.notifier)
          .goToStep(OnboardingStep.genderInterest);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shouldAutofocus = ref.watch(
      onboardingControllerProvider.select(
        (data) => data.step == OnboardingStep.nameDob,
      ),
    );
    final age = _age();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            const OnboardingStepHeader(title: 'What\'s your name?'),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: CatchTextField(
                    label: 'First name',
                    controller: _firstNameController,
                    autofocus: shouldAutofocus,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.givenName],
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                gapW12,
                Expanded(
                  child: CatchTextField(
                    label: 'Last name',
                    controller: _lastNameController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.familyName],
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            gapH24,
            CatchTextField(
              label: 'Date of birth',
              controller: _dateController,
              readOnly: true,
              onTap: _pickDate,
              prefixIcon: const Icon(Icons.calendar_today_outlined),
              suffixText: age != null ? 'Age $age' : null,
              validator: (v) => v == null || v.isEmpty
                  ? 'Please select your date of birth'
                  : _selectedDate == null || !isAtLeastAge(_selectedDate!)
                  ? 'You must be at least $minimumProfileAge years old'
                  : null,
            ),
            gapH24,
            CatchTextField(
              label: 'Mobile number',
              controller: _phoneController,
              readOnly: true,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.telephoneNumberNational],
              prefixIcon: const Icon(Icons.phone_outlined),
              prefixText: '+91 ',
              helperText: _phoneVerified ? 'Verified via OTP' : null,
              helperTone: CatchTextFieldSupportTone.brand,
              validator: (v) {
                if (!_phoneVerified || v == null || v.trim().isEmpty) {
                  return 'Please verify your phone number before continuing.';
                }
                return null;
              },
            ),
            const SizedBox(height: 40),
            CatchButton(
              label: 'Continue',
              onPressed: _submit,
              fullWidth: true,
              size: CatchButtonSize.lg,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
