import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/mutation_error_util.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_controller.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_form_keys.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/gender_interest_page_state.dart';
import 'package:catch_dating_app/onboarding/shared/onboarding_step_layout.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GenderInterestPage extends ConsumerStatefulWidget {
  const GenderInterestPage({super.key});

  @override
  ConsumerState<GenderInterestPage> createState() => _GenderInterestPageState();
}

class _GenderInterestPageState extends ConsumerState<GenderInterestPage> {
  final _formKey = GlobalKey<FormState>();
  Gender? _gender;
  Set<Gender> _interestedIn = {};

  @override
  void initState() {
    super.initState();
    final data = ref.read(onboardingControllerProvider);
    _gender = data.gender;
    _interestedIn = {...data.interestedInGenders};
  }

  void _submit() {
    final state = _stateFor(isSaving: false, l10n: context.l10n);
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final intent = state.submitIntent();
    if (intent == null) return;
    ref
        .read(onboardingControllerProvider.notifier)
        .setGenderInterest(
          gender: intent.gender,
          interestedInGenders: intent.interestedInGenders,
        );

    OnboardingController.saveProfileMutation.run(ref, (tx) async {
      await tx.get(onboardingControllerProvider.notifier).saveProfile();
    });
  }

  OnboardingGenderInterestState _stateFor({
    required bool isSaving,
    required AppLocalizations l10n,
    String? saveErrorMessage,
  }) {
    return OnboardingGenderInterestState.fromDraft(
      gender: _gender,
      interestedIn: _interestedIn,
      l10n: l10n,
      isSaving: isSaving,
      saveErrorMessage: saveErrorMessage,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mutation = ref.watch(OnboardingController.saveProfileMutation);
    final state = _stateFor(
      isSaving: mutation.isPending,
      l10n: context.l10n,
      saveErrorMessage: mutation.hasError
          ? mutationErrorMessage(mutation, l10n: context.l10n)
          : null,
    );

    return OnboardingGenderInterestStep(
      formKey: _formKey,
      state: state,
      callbacks: OnboardingGenderInterestCallbacks(
        onGenderChanged: (next) {
          OnboardingController.saveProfileMutation.reset(ref);
          setState(() => _gender = next.isEmpty ? null : next.first);
        },
        onInterestedInChanged: (next) {
          OnboardingController.saveProfileMutation.reset(ref);
          setState(() => _interestedIn = next);
        },
        onContinue: _submit,
      ),
    );
  }
}

class OnboardingGenderInterestStep extends StatelessWidget {
  const OnboardingGenderInterestStep({
    super.key,
    required this.formKey,
    required this.state,
    required this.callbacks,
  });

  final GlobalKey<FormState> formKey;
  final OnboardingGenderInterestState state;
  final OnboardingGenderInterestCallbacks callbacks;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: OnboardingStepLayout(
        footer: CatchButton(
          label: context.l10n.onboardingGenderInterestPageLabelContinue,
          onPressed: callbacks.onContinue,
          isLoading: state.isSaving,
          fullWidth: true,
          size: CatchButtonSize.lg,
        ),
        children: [
          CatchSectionList(
            gap: CatchSpacing.s4,
            children: [
              CatchSection.fieldRows(
                first: true,
                children: [
                  FormField<Set<Gender>>(
                    initialValue: state.selectedGender,
                    validator: state.validateGender,
                    builder: (field) => CatchField.choices<Gender>(
                      key: OnboardingFormKeys.gender,
                      title: context.l10n.onboardingGenderInterestPageLabelIAmA,
                      body: _orderedGenderLabels(state.selectedGender),
                      values: Gender.values,
                      itemLabel: (gender) => gender.label,
                      selected: state.selectedGender,
                      onSelectionChanged: (selection) {
                        callbacks.onGenderChanged(selection);
                        field.didChange(selection);
                      },
                      initiallyOpen: true,
                      error: field.errorText,
                    ),
                  ),
                  FormField<Set<Gender>>(
                    initialValue: state.interestedIn,
                    validator: state.validateInterestedIn,
                    builder: (field) => CatchField.choices<Gender>(
                      key: OnboardingFormKeys.interestedIn,
                      title:
                          context.l10n.onboardingGenderInterestPageLabelShowMe,
                      body: _orderedGenderLabels(state.interestedIn),
                      values: Gender.values,
                      itemLabel: (gender) => gender.label,
                      selected: state.interestedIn,
                      onSelectionChanged: (selection) {
                        callbacks.onInterestedInChanged(selection);
                        field.didChange(selection);
                      },
                      multi: true,
                      initiallyOpen: true,
                      error: field.errorText,
                    ),
                  ),
                ],
              ),
              if (state.hasSaveError)
                CatchSection.plain(
                  child: CatchErrorBanner(message: state.saveErrorMessage!),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

String? _orderedGenderLabels(Set<Gender> selected) {
  final labels = Gender.values
      .where(selected.contains)
      .map((gender) => gender.label)
      .toList(growable: false);
  return labels.isEmpty ? null : labels.join(', ');
}
