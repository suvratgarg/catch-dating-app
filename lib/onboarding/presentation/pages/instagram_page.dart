import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_controller.dart';
import 'package:catch_dating_app/onboarding/presentation/widgets/onboarding_step_header.dart';
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
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),
          const OnboardingStepHeader(
            title: "What's your Instagram?",
          ),
          const SizedBox(height: 8),
          Text(
            'This helps us verify you for early access. Your handle is never shown to other users.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 32),
          CatchTextField(
            controller: _controller,
            label: 'Instagram handle',
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            prefixText: '@',
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
    );
  }
}
