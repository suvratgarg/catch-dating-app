import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _phoneReadOnly = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final data = ref.read(onboardingControllerProvider);
      if (data.phoneNumber.isNotEmpty) {
        _phoneController.text = data.phoneNumber;
        _phoneReadOnly = true;
        setState(() {});
      }
    });
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

  int? _age() {
    if (_selectedDate == null) return null;
    final today = DateTime.now();
    int age = today.year - _selectedDate!.year;
    if (today.month < _selectedDate!.month ||
        (today.month == _selectedDate!.month &&
            today.day < _selectedDate!.day)) {
      age--;
    }
    return age;
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
      ref.read(onboardingControllerProvider.notifier).goToStep(4);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final age = _age();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            Text(
              'What\'s your name?',
              style: CatchTextStyles.displaySm(
                context,
              ).copyWith(fontWeight: FontWeight.bold, color: t.ink),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'First name'),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                gapW12,
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Last name'),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            gapH24,
            TextFormField(
              controller: _dateController,
              readOnly: true,
              onTap: _pickDate,
              decoration: InputDecoration(
                labelText: 'Date of birth',
                prefixIcon: const Icon(Icons.calendar_today_outlined),
                suffixText: age != null ? 'Age $age' : null,
              ),
              validator: (v) => v == null || v.isEmpty
                  ? 'Please select your date of birth'
                  : null,
            ),
            gapH24,
            TextFormField(
              controller: _phoneController,
              readOnly: _phoneReadOnly,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              inputFormatters: _phoneReadOnly
                  ? null
                  : [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
              decoration: InputDecoration(
                labelText: 'Mobile number',
                prefixIcon: const Icon(Icons.phone_outlined),
                prefixText: '+91 ',
                helperText: _phoneReadOnly ? 'Verified via OTP' : null,
                helperStyle: TextStyle(color: t.primary),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Please enter your phone number';
                }
                if (!_phoneReadOnly && v.trim().length != 10) {
                  return 'Please enter a valid 10-digit number';
                }
                return null;
              },
            ),
            const SizedBox(height: 40),
            FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              child: const Text('Continue'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
