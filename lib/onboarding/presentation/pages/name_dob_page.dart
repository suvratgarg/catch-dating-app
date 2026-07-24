import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_picker.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_controller.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_form_keys.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/name_dob_page_state.dart';
import 'package:catch_dating_app/onboarding/shared/onboarding_step_layout.dart';
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

  Future<void> _pickDate(OnboardingNameDobDatePickerRequest request) async {
    final picked = await showCatchDatePicker(
      context: context,
      initialDate: request.initialDate,
      firstDate: request.firstDate,
      lastDate: request.lastDate,
      title: request.title,
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = OnboardingNameDobState.formatDate(picked);
      });
    }
  }

  void _seedDraft(OnboardingData data) {
    _firstNameController.text = data.firstName;
    _lastNameController.text = data.lastName;
    _selectedDate = data.dateOfBirth;
    _dateController.text = data.dateOfBirth != null
        ? OnboardingNameDobState.formatDate(data.dateOfBirth!)
        : '';

    _phoneController.text = data.phoneNumber;
  }

  OnboardingNameDobState _stateFor(OnboardingData data) {
    return OnboardingNameDobState.fromDraft(
      l10n: context.l10n,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      phoneNumber: _phoneController.text,
      countryCode: data.countryCode,
      dateOfBirth: _selectedDate,
      step: data.step,
      today: DateTime.now(),
    );
  }

  void _submit() {
    final data = ref.read(onboardingControllerProvider);
    final state = _stateFor(data);
    if (!_formKey.currentState!.validate()) return;
    final intent = state.submitIntent(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      phoneNumber: _phoneController.text,
    );
    if (intent == null) return;

    ref
        .read(onboardingControllerProvider.notifier)
        .advanceToGenderInterest(
          firstName: intent.firstName,
          lastName: intent.lastName,
          dateOfBirth: intent.dateOfBirth,
          phoneNumber: intent.phoneNumber,
          countryCode: intent.countryCode,
        );
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(onboardingControllerProvider);
    final state = _stateFor(data);

    return OnboardingNameDobStep(
      formKey: _formKey,
      state: state,
      controllers: OnboardingNameDobTextControllers(
        firstName: _firstNameController,
        lastName: _lastNameController,
        phone: _phoneController,
        date: _dateController,
      ),
      callbacks: OnboardingNameDobCallbacks(
        onPickDate: (request) {
          _pickDate(request);
        },
        onContinue: _submit,
      ),
    );
  }
}

class OnboardingNameDobStep extends StatelessWidget {
  const OnboardingNameDobStep({
    super.key,
    required this.formKey,
    required this.state,
    required this.controllers,
    required this.callbacks,
  });

  final GlobalKey<FormState> formKey;
  final OnboardingNameDobState state;
  final OnboardingNameDobTextControllers controllers;
  final OnboardingNameDobCallbacks callbacks;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: OnboardingStepLayout(
        footer: CatchButton(
          label: context.l10n.onboardingNameDobPageLabelContinue,
          onPressed: callbacks.onContinue,
          fullWidth: true,
          size: CatchButtonSize.lg,
        ),
        children: [
          CatchSection.fieldRows(
            first: true,
            children: [
              CatchField.input(
                title: context.l10n.onboardingNameDobPageTitleFirstName,
                contract:
                    CatchContractConstraints.onboardingDraftDocumentFirstName,
                controller: controllers.firstName,
                autofocus: state.shouldAutofocus,
                icon: CatchIcons.personOutlineRounded,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.givenName],
                helperText: context
                    .l10n
                    .onboardingNameDobPageHelpertextDisplayedOnYourProfile,
                validator: state.validateFirstName,
              ),
              CatchField.input(
                title: context.l10n.onboardingNameDobPageTitleLastName,
                contract:
                    CatchContractConstraints.onboardingDraftDocumentLastName,
                controller: controllers.lastName,
                icon: CatchIcons.personOutlineRounded,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.familyName],
                helperText: context
                    .l10n
                    .onboardingNameDobPageHelpertextPrivateWeNeverShow,
                validator: state.validateLastName,
              ),
              CatchField.input(
                key: OnboardingFormKeys.dateOfBirth,
                title: context.l10n.onboardingNameDobPageTitleDateOfBirth,
                contract: CatchContractConstraints
                    .mobileFormStateOnboardingDateOfBirthText,
                controller: controllers.date,
                readOnly: true,
                onTap: () => callbacks.onPickDate(state.datePickerRequest),
                icon: CatchIcons.calendarTodayOutlined,
                suffixText: state.ageSuffix,
                helperText:
                    context.l10n.onboardingNameDobPageHelpertextWeNeverShowYour,
                validator: (_) => state.validateDateOfBirth(),
              ),
              CatchField.input(
                key: OnboardingFormKeys.phone,
                title: context.l10n.onboardingNameDobPageTitlePhone,
                contract:
                    CatchContractConstraints.onboardingDraftDocumentPhoneNumber,
                controller: controllers.phone,
                readOnly: true,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.telephoneNumberNational],
                icon: CatchIcons.phoneOutlined,
                prefixText: state.phonePrefix,
                suffixIcon: Icon(CatchIcons.verifiedRounded),
                helperText:
                    context.l10n.onboardingNameDobPageHelpertextVerifiedViaOtp,
                helperTone: CatchFieldSupportTone.success,
                validator: state.validatePhoneNumber,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
