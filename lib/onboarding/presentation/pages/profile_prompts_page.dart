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
    _defaultPromptIdForSlot,
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
    final normalizedSeed = normalizeProfilePromptAnswers(seed);
    for (final indexedPrompt in normalizedSeed.indexed) {
      final index = indexedPrompt.$1;
      if (index >= maxProfilePromptAnswers) break;
      final prompt = indexedPrompt.$2;
      _selectedPromptIds[index] = prompt.promptId;
      _controllers[index].text = prompt.answer;
    }
    _fillUnusedPromptDefaults();
  }

  List<ProfilePromptAnswer> _answers() {
    return normalizeProfilePromptAnswers(
      Iterable<ProfilePromptAnswer>.generate(maxProfilePromptAnswers, (index) {
        final definition = profilePromptDefinition(_selectedPromptIds[index]);
        return profilePromptAnswerFor(
          definition: definition,
          answer: _controllers[index].text,
        );
      }),
    );
  }

  void _continue() {
    final answers = _answers();
    OnboardingController.completeMutation.run(ref, (tx) async {
      await tx
          .get(onboardingControllerProvider.notifier)
          .completeSocialProfile(prompts: answers);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final answers = _answers();
    final canContinue = answers.length == maxProfilePromptAnswers;
    final answeredCount = answers.length;
    final mutation = ref.watch(OnboardingController.completeMutation);

    return OnboardingStepLayout(
      footer: Row(
        children: [
          Expanded(
            child: Text(
              '$answeredCount / $maxProfilePromptAnswers prompts answered',
              style: CatchTextStyles.monoLabel(context, color: t.ink3),
            ),
          ),
          gapW12,
          CatchButton(
            label: 'Continue',
            onPressed: canContinue && !mutation.isPending ? _continue : null,
            isLoading: mutation.isPending,
          ),
        ],
      ),
      children: [
        for (var index = 0; index < maxProfilePromptAnswers; index += 1) ...[
          PromptField(
            definition: profilePromptDefinition(_selectedPromptIds[index]),
            controller: _controllers[index],
            availablePromptIds: _availablePromptIds(index),
            selectedPromptId: _selectedPromptIds[index],
            onPromptChanged: (promptId) => _selectPrompt(index, promptId),
          ),
          if (index < maxProfilePromptAnswers - 1) gapH12,
        ],
        if (mutation.hasError) ...[
          gapH16,
          CatchErrorBanner(message: mutationErrorMessage(mutation)),
        ],
      ],
    );
  }

  void _selectPrompt(int index, String promptId) {
    setState(() => _selectedPromptIds[index] = promptId);
  }

  List<String> _availablePromptIds(int index) {
    final currentPromptId = _selectedPromptIds[index];
    final usedPromptIds = {
      for (final entry in _selectedPromptIds.indexed)
        if (entry.$1 != index) entry.$2,
    };
    return [
      if (!profilePromptCatalog.any(
        (definition) => definition.id == currentPromptId,
      ))
        currentPromptId,
      for (final definition in profilePromptCatalog)
        if (!usedPromptIds.contains(definition.id) ||
            definition.id == currentPromptId)
          definition.id,
    ];
  }

  void _fillUnusedPromptDefaults() {
    final usedPromptIds = <String>{};
    for (var index = 0; index < _selectedPromptIds.length; index += 1) {
      final selected = _selectedPromptIds[index];
      if (usedPromptIds.add(selected)) continue;
      _selectedPromptIds[index] = _defaultPromptIdForSlot(index, usedPromptIds);
      usedPromptIds.add(_selectedPromptIds[index]);
    }
  }

  static String _defaultPromptIdForSlot(
    int index, [
    Set<String>? usedPromptIds,
  ]) {
    final used = usedPromptIds ?? const <String>{};
    final defaultPromptId = index < defaultProfilePromptIds.length
        ? defaultProfilePromptIds[index]
        : null;
    if (defaultPromptId != null && !used.contains(defaultPromptId)) {
      return defaultPromptId;
    }
    return profilePromptCatalog
        .firstWhere(
          (definition) => !used.contains(definition.id),
          orElse: () => profilePromptCatalog.first,
        )
        .id;
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
