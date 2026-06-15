import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_select_menu.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/core/widgets/error_banner.dart';
import 'package:catch_dating_app/core/widgets/mutation_error_util.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_controller.dart';
import 'package:catch_dating_app/onboarding/presentation/widgets/onboarding_step_header.dart';
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
    _defaultPromptIdForSlot,
  );
  bool _didSeed = false;

  @override
  void initState() {
    super.initState();
    for (final controller in _controllers) {
      controller.addListener(_handlePromptChanged);
    }
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
    if (_didSeed) return;
    _didSeed = true;

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
    _seedPrompts();

    final t = CatchTokens.of(context);
    final answers = _answers();
    final canContinue = answers.length == maxProfilePromptAnswers;
    final answeredCount = answers.length;
    final mutation = ref.watch(OnboardingController.completeMutation);

    return OnboardingStepFrame(
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
        OnboardingStepHeader(
          title: widget.profileCompletionOnly
              ? 'Add prompts to start catching'
              : 'Show your personality',
          subtitle: widget.profileCompletionOnly
              ? 'Prompts give people something real to respond to before you match.'
              : 'Answer 3 prompts to complete your profile.',
        ),
        gapH20,
        for (var index = 0; index < maxProfilePromptAnswers; index += 1) ...[
          _PromptField(
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

class _PromptField extends StatelessWidget {
  const _PromptField({
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
      padding: const EdgeInsets.all(CatchSpacing.s3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CatchSelectMenu<String>(
            values: availablePromptIds,
            value: selectedPromptId,
            itemLabel: (promptId) => profilePromptDefinition(promptId).title,
            semanticLabel: 'Profile prompt',
            prefixIcon: Icon(CatchIcons.formatQuoteRounded),
            onChanged: (promptId) {
              if (promptId == null) return;
              onPromptChanged(promptId);
            },
          ),
          gapH10,
          CatchTextField(
            label: definition.title,
            showLabel: false,
            controller: controller,
            hintText: definition.placeholder,
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
