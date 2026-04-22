import 'package:catch_dating_app/app_user/domain/app_user.dart';
import 'package:catch_dating_app/common_widgets/chip_field.dart';
import 'package:catch_dating_app/common_widgets/error_banner.dart';
import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GenderInterestPage extends ConsumerStatefulWidget {
  const GenderInterestPage({super.key});

  @override
  ConsumerState<GenderInterestPage> createState() => _GenderInterestPageState();
}

class _GenderInterestPageState extends ConsumerState<GenderInterestPage> {
  Gender? _gender;
  SexualOrientation? _orientation;
  Set<Gender> _interestedIn = {};

  String? _error;

  void _submit() {
    if (_gender == null) {
      setState(() => _error = 'Please select your gender');
      return;
    }
    if (_orientation == null) {
      setState(() => _error = 'Please select your orientation');
      return;
    }

    setState(() => _error = null);
    ref.read(onboardingControllerProvider.notifier).setGenderInterest(
      gender: _gender!,
      sexualOrientation: _orientation!,
      interestedInGenders: _interestedIn.toList(),
    );

    OnboardingController.saveProfileMutation.run(ref, (tx) async {
      await tx.get(onboardingControllerProvider.notifier).saveProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mutation = ref.watch(OnboardingController.saveProfileMutation);
    final t = CatchTokens.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),
          Text(
            'How do you identify?',
            style: CatchTextStyles.displaySm(context).copyWith(
              fontWeight: FontWeight.bold,
              color: t.ink,
            ),
          ),
          const SizedBox(height: 32),
          _SectionLabel(label: 'I am a...', tokens: t),
          gapH12,
          ChipField<Gender>(
            label: '',
            values: Gender.values,
            selected: _gender != null ? {_gender!} : {},
            multiSelect: false,
            onChanged: (v) =>
                setState(() => _gender = v.isEmpty ? null : v.first),
          ),
          gapH24,
          _SectionLabel(label: 'Sexual orientation', tokens: t),
          gapH12,
          ChipField<SexualOrientation>(
            label: '',
            values: SexualOrientation.values,
            selected: _orientation != null ? {_orientation!} : {},
            multiSelect: false,
            onChanged: (v) =>
                setState(() => _orientation = v.isEmpty ? null : v.first),
          ),
          gapH24,
          _SectionLabel(label: 'Show me', tokens: t),
          gapH12,
          ChipField<Gender>(
            label: '',
            values: Gender.values,
            selected: _interestedIn,
            multiSelect: true,
            onChanged: (v) => setState(() => _interestedIn = v),
          ),
          if (_error != null) ...[
            gapH16,
            ErrorBanner(message: _error!),
          ],
          if (mutation.hasError) ...[
            gapH16,
            ErrorBanner(
              message: (mutation as MutationError).error.toString(),
            ),
          ],
          const SizedBox(height: 40),
          FilledButton(
            onPressed: mutation.isPending ? null : _submit,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            child: mutation.isPending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Continue'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.tokens});
  final String label;
  final CatchTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: CatchTextStyles.labelMd(context, color: tokens.ink2),
    );
  }
}
