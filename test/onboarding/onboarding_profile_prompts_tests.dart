part of 'onboarding_widgets_test.dart';

void _registerProfilePromptsPageTests() {
  group('ProfilePromptsPage', () {
    test(
      'state derives prompt progress, available prompts, and submit intent',
      () {
        final answers = List<String>.generate(
          maxProfilePromptAnswers,
          (index) => 'Answer ${index + 1}',
        );
        final complete = OnboardingProfilePromptsState.fromSelections(
          selectedPromptIds: defaultProfilePromptIds,
          answerTexts: answers,
          isCompleting: true,
          completeErrorMessage: 'Could not save prompts.',
        );

        expect(complete.answeredCount, maxProfilePromptAnswers);
        expect(complete.canContinue, isTrue);
        expect(complete.canSubmit, isFalse);
        expect(
          complete.progressLabel,
          '$maxProfilePromptAnswers / $maxProfilePromptAnswers prompts answered',
        );
        expect(complete.hasCompleteError, isTrue);
        expect(
          complete.availablePromptIds(1),
          isNot(contains(complete.selectedPromptIdForSlot(0))),
        );
        expect(
          complete.availablePromptIds(1),
          contains(complete.selectedPromptIdForSlot(1)),
        );
        expect(
          complete.submitIntent()?.prompts.map((prompt) => prompt.answer),
          answers,
        );

        final partial = OnboardingProfilePromptsState.fromSelections(
          selectedPromptIds: defaultProfilePromptIds,
          answerTexts: const ['Only one answer'],
        );
        expect(partial.canContinue, isFalse);
        expect(partial.submitIntent(), isNull);

        final deduped = OnboardingProfilePromptsState.fromSelections(
          selectedPromptIds: List<String>.filled(
            maxProfilePromptAnswers,
            defaultProfilePromptIds.first,
          ),
          answerTexts: const [],
        );
        expect(
          deduped.selectedPromptIds.toSet(),
          hasLength(maxProfilePromptAnswers),
        );
      },
    );

    testWidgets('provider-free step shows progress and forwards continue', (
      tester,
    ) async {
      final controllers = OnboardingProfilePromptsTextControllers(
        answers: [
          for (var index = 0; index < maxProfilePromptAnswers; index += 1)
            TextEditingController(text: 'Answer ${index + 1}'),
        ],
      );
      for (final controller in controllers.answers) {
        addTearDown(controller.dispose);
      }
      final state = OnboardingProfilePromptsState.fromSelections(
        selectedPromptIds: defaultProfilePromptIds,
        answerTexts: [
          for (var index = 0; index < maxProfilePromptAnswers; index += 1)
            'Answer ${index + 1}',
        ],
        completeErrorMessage: 'Could not save prompts.',
      );
      var continueCount = 0;
      (int, String)? promptChange;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: OnboardingProfilePromptsStep(
              state: state,
              controllers: controllers,
              callbacks: OnboardingProfilePromptsCallbacks(
                onPromptChanged: (index, promptId) {
                  promptChange = (index, promptId);
                },
                onContinue: () => continueCount += 1,
              ),
            ),
          ),
        ),
      );
      await pumpOnboardingUi(tester);

      expect(
        find.text(
          '$maxProfilePromptAnswers / $maxProfilePromptAnswers prompts answered',
        ),
        findsOneWidget,
      );
      expect(find.text('Could not save prompts.'), findsOneWidget);

      await tester.tap(find.widgetWithText(CatchButton, 'Continue'));
      await pumpOnboardingUi(tester);

      expect(continueCount, 1);
      expect(promptChange, isNull);
    });

    testWidgets('pending completion freezes prompt questions and answers', (
      tester,
    ) async {
      final controllers = OnboardingProfilePromptsTextControllers(
        answers: [
          for (var index = 0; index < maxProfilePromptAnswers; index += 1)
            TextEditingController(text: 'Answer ${index + 1}'),
        ],
      );
      for (final controller in controllers.answers) {
        addTearDown(controller.dispose);
      }
      final state = OnboardingProfilePromptsState.fromSelections(
        selectedPromptIds: defaultProfilePromptIds,
        answerTexts: [
          for (var index = 0; index < maxProfilePromptAnswers; index += 1)
            'Answer ${index + 1}',
        ],
        isCompleting: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: OnboardingProfilePromptsStep(
              state: state,
              controllers: controllers,
              callbacks: OnboardingProfilePromptsCallbacks(
                onPromptChanged: (_, _) {},
                onContinue: () {},
              ),
            ),
          ),
        ),
      );
      await pumpOnboardingUi(tester);

      expect(
        tester
            .widget<CatchField>(
              find.byKey(const ValueKey('onboarding-prompt-question-0')),
            )
            .enabled,
        isFalse,
      );
      expect(
        tester
            .widget<CatchField>(
              find.byKey(const ValueKey('onboarding-prompt-answer-0')),
            )
            .enabled,
        isFalse,
      );
      expect(
        tester.widget<CatchButton>(find.byType(CatchButton)).onPressed,
        isNull,
      );
    });

    testWidgets('explains prompts as part of catches completion', (
      tester,
    ) async {
      final container = createOnboardingTestContainer();
      addTearDown(container.dispose);

      await pumpOnboardingPage(
        tester,
        container: container,
        child: const ProfilePromptsPage(profileCompletionOnly: true),
      );

      // The mode-specific copy now lives in the flow header (see
      // onboarding_step_test `headerCopy`); the page renders its prompt
      // selectors and Continue affordance in completion mode.
      for (var index = 0; index < maxProfilePromptAnswers; index += 1) {
        expect(
          find.byKey(ValueKey('onboarding-prompt-question-$index')),
          findsOneWidget,
        );
        expect(
          find.byKey(ValueKey('onboarding-prompt-answer-$index')),
          findsOneWidget,
        );
      }
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('prompt pickers hide prompts selected in other slots', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1080, 2200);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final container = createOnboardingTestContainer();
      addTearDown(container.dispose);

      await pumpOnboardingPage(
        tester,
        container: container,
        child: const ProfilePromptsPage(),
      );

      final secondPrompt = find.byKey(
        const ValueKey('onboarding-prompt-question-1'),
      );
      await tester.tap(secondPrompt);
      await pumpOnboardingUi(tester);

      expect(
        _catchFieldChoiceIn(
          const ValueKey('onboarding-prompt-question-1'),
          profilePromptDefinition(profilePromptPerfectEventId).title,
        ),
        findsNothing,
      );
      final unusedPrompt = profilePromptCatalog.firstWhere(
        (definition) => !defaultProfilePromptIds.contains(definition.id),
      );
      final unusedSecondPromptChoice = _catchFieldChoiceIn(
        const ValueKey('onboarding-prompt-question-1'),
        unusedPrompt.title,
      );
      await tester.ensureVisible(unusedSecondPromptChoice);
      await pumpOnboardingUi(tester);
      await tester.tap(unusedSecondPromptChoice);
      await pumpOnboardingUi(tester);

      final thirdPrompt = find.byKey(
        const ValueKey('onboarding-prompt-question-2'),
      );
      await tester.ensureVisible(thirdPrompt);
      await pumpOnboardingUi(tester);
      await tester.tap(thirdPrompt);
      await pumpOnboardingUi(tester);

      expect(
        _catchFieldChoiceIn(
          const ValueKey('onboarding-prompt-question-2'),
          unusedPrompt.title,
        ),
        findsNothing,
      );
    });
  });
}
