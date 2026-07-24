import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_controller.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/instagram_page_state.dart';
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
    final state = OnboardingInstagramState.fromDraft(
      handle: data.instagramHandle,
    );
    _controller = TextEditingController(text: state.handleText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _continue() {
    final intent = OnboardingInstagramState.fromDraft(
      handle: _controller.text,
    ).continueIntent(handle: _controller.text);
    ref
        .read(onboardingControllerProvider.notifier)
        .advanceToPhotos(instagramHandle: intent.instagramHandle);
  }

  void _skip() {
    final intent = OnboardingInstagramState.fromDraft(
      handle: _controller.text,
    ).skipIntent;
    ref
        .read(onboardingControllerProvider.notifier)
        .advanceToPhotos(instagramHandle: intent.instagramHandle);
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingInstagramStep(
      controllers: OnboardingInstagramTextControllers(handle: _controller),
      callbacks: OnboardingInstagramCallbacks(
        onContinue: _continue,
        onSkip: _skip,
      ),
    );
  }
}

class OnboardingInstagramStep extends StatelessWidget {
  const OnboardingInstagramStep({
    super.key,
    required this.controllers,
    required this.callbacks,
  });

  final OnboardingInstagramTextControllers controllers;
  final OnboardingInstagramCallbacks callbacks;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return OnboardingStepLayout(
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CatchButton(
            label: context.l10n.onboardingInstagramPageLabelContinue,
            onPressed: callbacks.onContinue,
            fullWidth: true,
            size: CatchButtonSize.lg,
          ),
          gapH12,
          Center(
            child: CatchButton(
              label: context.l10n.onboardingInstagramPageLabelSkipForNow,
              onPressed: callbacks.onSkip,
              variant: CatchButtonVariant.ghost,
              size: CatchButtonSize.sm,
              foregroundColor: t.ink2,
            ),
          ),
        ],
      ),
      children: [
        CatchSection.fieldRows(
          first: true,
          child: CatchField.input(
            controller: controllers.handle,
            title: context.l10n.onboardingInstagramPageTitleHandle,
            contract:
                CatchContractConstraints.updateUserProfilePatchInstagramHandle,
            inputHint:
                context.l10n.onboardingInstagramPagePlaceholderYourhandle,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => callbacks.onContinue(),
            prefixText: '@',
          ),
        ),
      ],
    );
  }
}
