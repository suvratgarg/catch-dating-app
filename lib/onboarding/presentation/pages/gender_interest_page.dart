import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/chip_field.dart';
import 'package:catch_dating_app/core/widgets/error_banner.dart';
import 'package:catch_dating_app/core/widgets/mutation_error_util.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_controller.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_form_keys.dart';
import 'package:catch_dating_app/onboarding/presentation/widgets/onboarding_step_header.dart';
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
    if (!_formKey.currentState!.validate()) {
      return;
    }
    ref
        .read(onboardingControllerProvider.notifier)
        .setGenderInterest(
          gender: _gender!,
          interestedInGenders: _interestedIn.toList(),
        );

    OnboardingController.saveProfileMutation.run(ref, (tx) async {
      await tx.get(onboardingControllerProvider.notifier).saveProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mutation = ref.watch(OnboardingController.saveProfileMutation);

    return Form(
      key: _formKey,
      child: OnboardingStepFrame(
        children: [
          gapH32,
          const OnboardingStepHeader(title: 'How do you identify?'),
          gapH32,
          ChipField<Gender>(
            label: 'I am a...',
            values: Gender.values,
            selected: _gender != null ? {_gender!} : {},
            multiSelect: false,
            chipKeyBuilder: OnboardingFormKeys.genderChip,
            validator: (_) =>
                _gender == null ? 'Please select your gender' : null,
            onChanged: (next) {
              OnboardingController.saveProfileMutation.reset(ref);
              setState(() => _gender = next.isEmpty ? null : next.first);
            },
          ),
          gapH24,
          ChipField<Gender>(
            label: 'Show me',
            values: Gender.values,
            selected: _interestedIn,
            multiSelect: true,
            chipKeyBuilder: OnboardingFormKeys.interestedInChip,
            validator: (_) => _interestedIn.isEmpty
                ? 'Please select who you want to see'
                : null,
            onChanged: (next) {
              OnboardingController.saveProfileMutation.reset(ref);
              setState(() => _interestedIn = next);
            },
          ),
          if (mutation.hasError) ...[
            gapH16,
            ErrorBanner(message: mutationErrorMessage(mutation)),
          ],
          gapH40,
          CatchButton(
            label: 'Continue',
            onPressed: _submit,
            isLoading: mutation.isPending,
            fullWidth: true,
            size: CatchButtonSize.lg,
          ),
          gapH32,
        ],
      ),
    );
  }
}
