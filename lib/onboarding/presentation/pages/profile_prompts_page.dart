import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/mutation_error_util.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_controller.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/profile_prompts_page_state.dart';
import 'package:catch_dating_app/onboarding/shared/onboarding_step_layout.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/profile_prompts.dart';
import 'package:catch_dating_app/user_profile/domain/profile_validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
          ? mutationErrorMessage(mutation, l10n: context.l10n)
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
            label: context.l10n.onboardingProfilePromptsPageLabelContinue,
            onPressed: state.canSubmit ? callbacks.onContinue : null,
            isLoading: state.isCompleting,
          ),
        ],
      ),
      children: [
        CatchSectionList(
          gap: CatchSpacing.s3,
          children: [
            for (var index = 0; index < maxProfilePromptAnswers; index += 1)
              PromptField(
                index: index,
                definition: state.definitionForSlot(index),
                controller: controllers.answers[index],
                availablePromptIds: state.availablePromptIds(index),
                selectedPromptId: state.selectedPromptIdForSlot(index),
                onPromptChanged: (promptId) {
                  callbacks.onPromptChanged(index, promptId);
                },
              ),
            if (state.hasCompleteError)
              CatchSection.plain(
                child: CatchErrorBanner(message: state.completeErrorMessage!),
              ),
          ],
        ),
      ],
    );
  }
}

class PromptField extends StatelessWidget {
  const PromptField({
    super.key,
    required this.index,
    required this.definition,
    required this.controller,
    required this.availablePromptIds,
    required this.selectedPromptId,
    required this.onPromptChanged,
  });

  final int index;
  final ProfilePromptDefinition definition;
  final TextEditingController controller;
  final List<String> availablePromptIds;
  final String selectedPromptId;
  final ValueChanged<String> onPromptChanged;

  @override
  Widget build(BuildContext context) {
    return CatchSection.containedFieldRows(
      key: ValueKey('onboarding-prompt-card-$index'),
      children: [
        CatchField.choices<String>(
          key: ValueKey('onboarding-prompt-question-$index'),
          icon: CatchIcons.formatQuoteRounded,
          title: context.l10n.onboardingProfilePromptsPageTitleProfilePrompt,
          body: definition.title,
          values: availablePromptIds,
          itemLabel: (promptId) => profilePromptDefinition(promptId).title,
          selected: {selectedPromptId},
          onSelectionChanged: (selection) {
            if (selection.isEmpty) return;
            onPromptChanged(selection.single);
          },
        ),
        CatchField.input(
          key: ValueKey('onboarding-prompt-answer-$index'),
          title: context.l10n.onboardingProfilePromptsPageTitleAnswer,
          controller: controller,
          inputHint: definition.placeholder,
          helperText: context.l10n
              .onboardingProfilePromptsPageHelpertextLengthMaximumprofilepromptanswerlength(
                length: controller.text.length,
                maximumProfilePromptAnswerLength:
                    maximumProfilePromptAnswerLength,
              ),
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          textCapitalization: TextCapitalization.sentences,
          maxLines: 4,
          minLines: 3,
          inputFormatters: [
            LengthLimitingTextInputFormatter(maximumProfilePromptAnswerLength),
          ],
        ),
      ],
    );
  }
}
