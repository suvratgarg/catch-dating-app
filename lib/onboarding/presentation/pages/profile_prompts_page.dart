import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_controller.dart';
import 'package:catch_dating_app/onboarding/presentation/widgets/onboarding_step_header.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/profile_prompts.dart';
import 'package:catch_dating_app/user_profile/domain/profile_validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilePromptsPage extends ConsumerStatefulWidget {
  const ProfilePromptsPage({super.key});

  @override
  ConsumerState<ProfilePromptsPage> createState() => _ProfilePromptsPageState();
}

class _ProfilePromptsPageState extends ConsumerState<ProfilePromptsPage> {
  late final Map<String, TextEditingController> _controllers = {
    for (final promptId in defaultProfilePromptIds)
      promptId: TextEditingController(),
  };
  bool _didSeed = false;

  @override
  void initState() {
    super.initState();
    for (final controller in _controllers.values) {
      controller.addListener(_handlePromptChanged);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller
        ..removeListener(_handlePromptChanged)
        ..dispose();
    }
    super.dispose();
  }

  void _handlePromptChanged() => setState(() {});

  void _seedPrompts() {
    if (_didSeed) return;
    _didSeed = true;

    final draftPrompts = ref.read(onboardingControllerProvider).profilePrompts;
    final profilePrompts =
        ref.read(watchUserProfileProvider).asData?.value?.profilePrompts ??
        const <ProfilePromptAnswer>[];
    final seed = draftPrompts.isNotEmpty ? draftPrompts : profilePrompts;
    for (final prompt in normalizeProfilePromptAnswers(seed)) {
      _controllers[prompt.promptId]?.text = prompt.answer;
    }
  }

  List<ProfilePromptAnswer> _answers() {
    return normalizeProfilePromptAnswers(
      defaultProfilePromptIds.map((promptId) {
        final definition = profilePromptDefinition(promptId);
        return profilePromptAnswerFor(
          definition: definition,
          answer: _controllers[promptId]?.text ?? '',
        );
      }),
    );
  }

  void _continue() {
    final answers = _answers();
    ref
        .read(onboardingControllerProvider.notifier)
        .advanceToRunningPrefs(prompts: answers);
  }

  @override
  Widget build(BuildContext context) {
    _seedPrompts();

    final t = CatchTokens.of(context);
    final answers = _answers();
    final canContinue = answers.length == defaultProfilePromptIds.length;
    final answeredCount = answers.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),
          const OnboardingStepHeader(
            title: 'Add your profile prompts',
            subtitle:
                'Give people specific things to like, comment on, and ask about.',
          ),
          gapH24,
          for (final promptId in defaultProfilePromptIds) ...[
            _PromptField(
              definition: profilePromptDefinition(promptId),
              controller: _controllers[promptId]!,
            ),
            gapH18,
          ],
          Text(
            '$answeredCount / ${defaultProfilePromptIds.length} prompts answered',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: canContinue ? t.success : t.ink2,
            ),
            textAlign: TextAlign.center,
          ),
          gapH16,
          CatchButton(
            label: 'Continue',
            onPressed: canContinue ? _continue : null,
            fullWidth: true,
            size: CatchButtonSize.lg,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _PromptField extends StatelessWidget {
  const _PromptField({required this.definition, required this.controller});

  final ProfilePromptDefinition definition;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return CatchTextField(
      label: definition.title,
      controller: controller,
      hintText: definition.placeholder,
      helperText:
          '${controller.text.length} / $maximumProfilePromptAnswerLength',
      helperTone: CatchTextFieldSupportTone.neutral,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      textCapitalization: TextCapitalization.sentences,
      maxLines: 4,
      minLines: 3,
      inputFormatters: [
        LengthLimitingTextInputFormatter(maximumProfilePromptAnswerLength),
      ],
    );
  }
}
