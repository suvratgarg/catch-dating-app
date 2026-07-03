import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/mutation_error_util.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_controller.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/profile_prompts_page_state.dart';
import 'package:catch_dating_app/onboarding/shared/onboarding_step_layout.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/profile_prompts.dart';
import 'package:catch_dating_app/user_profile/domain/profile_validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const EdgeInsets _promptAnswerCardPadding = EdgeInsets.all(CatchSpacing.s3);

class ProfilePromptsPage extends ConsumerStatefulWidget {
  const ProfilePromptsPage({super.key, this.profileCompletionOnly = false});

  final bool profileCompletionOnly;

  @override
  ConsumerState<ProfilePromptsPage> createState() => _ProfilePromptsPageState();
}

class _ProfilePromptsPageState extends ConsumerState<ProfilePromptsPage> {
  late final List<TextEditingController> _controllers = List.generate(
    maxProfilePromptAnswers,
    (_) => TextEditingController(),
  );
  late final List<String> _selectedPromptIds = List.generate(
    maxProfilePromptAnswers,
    OnboardingProfilePromptsState.defaultPromptIdForSlot,
  );
  @override
  void initState() {
    super.initState();
    for (final controller in _controllers) {
      controller.addListener(_handlePromptChanged);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _seedPrompts();
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller
        ..removeListener(_handlePromptChanged)
        ..dispose();
    }
    super.dispose();
  }

  void _handlePromptChanged() => setState(() {});

  void _seedPrompts() {
    final draftPrompts = ref.read(onboardingControllerProvider).profilePrompts;
    final profilePrompts =
        ref.read(watchUserProfileProvider).asData?.value?.profilePrompts ??
        const <ProfilePromptAnswer>[];
    final seed = draftPrompts.isNotEmpty ? draftPrompts : profilePrompts;
    final state = OnboardingProfilePromptsState.fromPromptAnswers(
      prompts: seed,
    );
    for (var index = 0; index < maxProfilePromptAnswers; index += 1) {
      _selectedPromptIds[index] = state.selectedPromptIdForSlot(index);
      _controllers[index].text = state.answerTextForSlot(index);
    }
  }

  OnboardingProfilePromptsState _stateFor({
    required bool isCompleting,
    String? completeErrorMessage,
  }) {
    return OnboardingProfilePromptsState.fromSelections(
      selectedPromptIds: _selectedPromptIds,
      answerTexts: [for (final controller in _controllers) controller.text],
      isCompleting: isCompleting,
      completeErrorMessage: completeErrorMessage,
    );
  }

  void _continue() {
    final intent = _stateFor(isCompleting: false).submitIntent();
    if (intent == null) return;
    OnboardingController.completeMutation.run(ref, (tx) async {
      await tx
          .get(onboardingControllerProvider.notifier)
          .completeSocialProfile(prompts: intent.prompts);
    });
  }

  @override
  Widget build(BuildContext context) {
    final mutation = ref.watch(OnboardingController.completeMutation);
    final state = _stateFor(
      isCompleting: mutation.isPending,
      completeErrorMessage: mutation.hasError
          ? mutationErrorMessage(mutation)
          : null,
    );

    return OnboardingProfilePromptsStep(
      state: state,
      controllers: OnboardingProfilePromptsTextControllers(
        answers: _controllers,
      ),
      callbacks: OnboardingProfilePromptsCallbacks(
        onPromptChanged: _selectPrompt,
        onContinue: _continue,
      ),
    );
  }

  void _selectPrompt(int index, String promptId) {
    setState(() => _selectedPromptIds[index] = promptId);
  }
}

class OnboardingProfilePromptsStep extends StatelessWidget {
  const OnboardingProfilePromptsStep({
    super.key,
    required this.state,
    required this.controllers,
    required this.callbacks,
  });

  final OnboardingProfilePromptsState state;
  final OnboardingProfilePromptsTextControllers controllers;
  final OnboardingProfilePromptsCallbacks callbacks;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return OnboardingStepLayout(
      footer: Row(
        children: [
          Expanded(
            child: Text(
              state.progressLabel,
              style: CatchTextStyles.monoLabel(context, color: t.ink3),
            ),
          ),
          gapW12,
          CatchButton(
            label: 'Continue',
            onPressed: state.canSubmit ? callbacks.onContinue : null,
            isLoading: state.isCompleting,
          ),
        ],
      ),
      children: [
        for (var index = 0; index < maxProfilePromptAnswers; index += 1) ...[
          PromptField(
            definition: state.definitionForSlot(index),
            controller: controllers.answers[index],
            availablePromptIds: state.availablePromptIds(index),
            selectedPromptId: state.selectedPromptIdForSlot(index),
            onPromptChanged: (promptId) {
              callbacks.onPromptChanged(index, promptId);
            },
          ),
          if (index < maxProfilePromptAnswers - 1) gapH12,
        ],
        if (state.hasCompleteError) ...[
          gapH16,
          CatchErrorBanner(message: state.completeErrorMessage!),
        ],
      ],
    );
  }
}

class PromptField extends StatelessWidget {
  const PromptField({
    super.key,
    required this.definition,
    required this.controller,
    required this.availablePromptIds,
    required this.selectedPromptId,
    required this.onPromptChanged,
  });

  final ProfilePromptDefinition definition;
  final TextEditingController controller;
  final List<String> availablePromptIds;
  final String selectedPromptId;
  final ValueChanged<String> onPromptChanged;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      radius: CatchRadius.md,
      borderColor: t.line,
      backgroundColor: t.surface,
      padding: _promptAnswerCardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CatchField.select<String>(
            title: 'Profile prompt',
            values: availablePromptIds,
            value: selectedPromptId,
            itemLabel: (promptId) => profilePromptDefinition(promptId).title,
            prefixIcon: Icon(CatchIcons.formatQuoteRounded),
            showLabel: false,
            onChanged: (promptId) {
              if (promptId == null) return;
              onPromptChanged(promptId);
            },
          ),
          gapH10,
          CatchField.input(
            title: definition.title,
            showLabel: false,
            controller: controller,
            placeholder: definition.placeholder,
            helperText:
                '${controller.text.length} / $maximumProfilePromptAnswerLength',
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            textCapitalization: TextCapitalization.sentences,
            maxLines: 4,
            minLines: 3,
            inputFormatters: [
              LengthLimitingTextInputFormatter(
                maximumProfilePromptAnswerLength,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
