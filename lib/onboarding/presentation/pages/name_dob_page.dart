import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_picker.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_controller.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_step.dart';
import 'package:catch_dating_app/onboarding/shared/onboarding_step_layout.dart';
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
    final picked = await showCatchDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: latestAllowedDateOfBirth(),
      title: 'Date of birth',
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
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '$day ${months[date.month - 1]} ${date.year}';
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) return;
      final data = ref.read(onboardingControllerProvider);
      ref
          .read(onboardingControllerProvider.notifier)
          .advanceToGenderInterest(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            dateOfBirth: _selectedDate!,
            phoneNumber: _phoneController.text.trim(),
            countryCode: data.countryCode,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(onboardingControllerProvider);
    final shouldAutofocus = data.step == OnboardingStep.nameDob;
    final age = _age();

    return Form(
      key: _formKey,
      child: OnboardingStepLayout(
        footer: CatchButton(
          label: 'Continue',
          onPressed: _submit,
          fullWidth: true,
          size: CatchButtonSize.lg,
        ),
        children: [
          CatchField.input(
            title: 'FIRST NAME',
            controller: _firstNameController,
            autofocus: shouldAutofocus,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.givenName],
            helperText: 'Displayed on your profile.',
            validator: (v) =>
                validateRequiredProfileName(v, label: 'First name'),
          ),
          gapH16,
          CatchField.input(
            title: 'LAST NAME',
            controller: _lastNameController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.familyName],
            helperText: 'Private. We never show this on your public profile.',
            validator: (v) =>
                validateRequiredProfileName(v, label: 'Last name'),
          ),
          gapH16,
          CatchField.input(
            title: 'DATE OF BIRTH',
            controller: _dateController,
            readOnly: true,
            onTap: _pickDate,
            prefixIcon: Icon(CatchIcons.calendarTodayOutlined),
            suffixText: age != null ? 'AGE $age' : null,
            helperText: 'We never show your birth year.',
            validator: (_) => validateRequiredDateOfBirth(_selectedDate),
          ),
          gapH16,
          CatchField.input(
            title: 'PHONE',
            controller: _phoneController,
            readOnly: true,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.telephoneNumberNational],
            prefixIcon: Icon(CatchIcons.phoneOutlined),
            prefixText: '${data.countryCode} ',
            suffixIcon: Icon(CatchIcons.verifiedRounded),
            helperText: 'Verified via OTP.',
            helperTone: CatchFieldSupportTone.success,
            validator: validateRequiredPhoneNumber,
          ),
        ],
      ),
    );
  }
}
