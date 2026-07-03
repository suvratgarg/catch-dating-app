import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_chip_field.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/core/widgets/mutation_error_util.dart';
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
    final state = _stateFor(isSaving: false);
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
    String? saveErrorMessage,
  }) {
    return OnboardingGenderInterestState.fromDraft(
      gender: _gender,
      interestedIn: _interestedIn,
      isSaving: isSaving,
      saveErrorMessage: saveErrorMessage,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mutation = ref.watch(OnboardingController.saveProfileMutation);
    final state = _stateFor(
      isSaving: mutation.isPending,
      saveErrorMessage: mutation.hasError
          ? mutationErrorMessage(mutation)
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
          label: 'Continue',
          onPressed: callbacks.onContinue,
          isLoading: state.isSaving,
          fullWidth: true,
          size: CatchButtonSize.lg,
        ),
        children: [
          CatchChipField<Gender>(
            label: 'I AM A',
            values: Gender.values,
            selected: state.selectedGender,
            multiSelect: false,
            chipKeyBuilder: OnboardingFormKeys.genderChip,
            validator: state.validateGender,
            onChanged: callbacks.onGenderChanged,
          ),
          gapH28,
          CatchChipField<Gender>(
            label: 'SHOW ME',
            values: Gender.values,
            selected: state.interestedIn,
            multiSelect: true,
            chipKeyBuilder: OnboardingFormKeys.interestedInChip,
            validator: state.validateInterestedIn,
            onChanged: callbacks.onInterestedInChanged,
          ),
          if (state.hasSaveError) ...[
            gapH16,
            CatchErrorBanner(message: state.saveErrorMessage!),
          ],
        ],
      ),
    );
  }
}
