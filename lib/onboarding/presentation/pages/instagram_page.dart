import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_controller.dart';
import 'package:catch_dating_app/onboarding/shared/onboarding_step_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InstagramPage extends ConsumerStatefulWidget {
  const InstagramPage({super.key});

  @override
  ConsumerState<InstagramPage> createState() => _InstagramPageState();
}

class _InstagramPageState extends ConsumerState<InstagramPage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final data = ref.read(onboardingControllerProvider);
    _controller = TextEditingController(text: data.instagramHandle ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final raw = _controller.text.trim();
    ref
        .read(onboardingControllerProvider.notifier)
        .advanceToPhotos(instagramHandle: raw.isEmpty ? null : raw);
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return OnboardingStepLayout(
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CatchButton(
            label: 'Continue',
            onPressed: _submit,
            fullWidth: true,
            size: CatchButtonSize.lg,
          ),
          gapH12,
          Center(
            child: CatchButton(
              label: 'Skip for now',
              onPressed: () => ref
                  .read(onboardingControllerProvider.notifier)
                  .advanceToPhotos(),
              variant: CatchButtonVariant.ghost,
              size: CatchButtonSize.sm,
              foregroundColor: t.ink2,
            ),
          ),
        ],
      ),
      children: [
        CatchField.input(
          controller: _controller,
          title: 'HANDLE',
          placeholder: '@yourhandle',
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          prefixText: '@',
        ),
      ],
    );
  }
}
