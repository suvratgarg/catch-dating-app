part of '../event_success_companion_screen.dart';

@immutable
class CompatibilityQuestionnaireActionState {
  const CompatibilityQuestionnaireActionState({
    this.isSaving = false,
    this.error,
  });

  final bool isSaving;
  final Object? error;
}

class CompatibilityQuestionnaireSection extends StatefulWidget {
  const CompatibilityQuestionnaireSection({
    required this.event,
    required this.plan,
    required this.response,
    required this.actionState,
    required this.onSaveAnswers,
  });

  final Event event;
  final EventSuccessPlan plan;
  final EventSuccessCompatibilityResponse? response;
  final CompatibilityQuestionnaireActionState actionState;
  final Future<void> Function(List<String> answerIds) onSaveAnswers;

  @override
  State<CompatibilityQuestionnaireSection> createState() =>
      _CompatibilityQuestionnaireSectionState();
}

class _CompatibilityQuestionnaireSectionState
    extends State<CompatibilityQuestionnaireSection> {
  late List<String> _answerIds = _initialAnswerIds;
  int _activeQuestionIndex = 0;
  bool _fixtureSavePending = false;

  @override
  void didUpdateWidget(covariant CompatibilityQuestionnaireSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.response?.id != widget.response?.id ||
        oldWidget.plan.questionnaireConfig != widget.plan.questionnaireConfig ||
        !_sameAnswers(
          oldWidget.response?.answerIds,
          widget.response?.answerIds,
        )) {
      _answerIds = _initialAnswerIds;
      _activeQuestionIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final rankingOn = widget.plan.compatibilityAffectsRanking;
    final questions = EventSuccessCompatibilityQuestionnaire.questionsFor(
      widget.plan.questionnaireConfig,
    );
    final activeQuestion =
        questions[_activeQuestionIndex.clamp(0, questions.length - 1).toInt()];
    final answeredQuestionCount = questions
        .where((question) => _answerForQuestion(question) != null)
        .length;
    final hasAnswers = _answerIds.isNotEmpty;
    final dirty = !_sameAnswers(_answerIds, widget.response?.answerIds);
    final saving = widget.actionState.isSaving || _fixtureSavePending;
    return StagePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'A few quick questions',
                style: CatchTextStyles.sectionTitle(context),
              ),
              const CatchPrivacyBadge(kind: CatchPrivacyBadgeKind.catchPrivate),
              CatchBadge(
                label: rankingOn ? 'Can guide pairings' : 'Clues only',
                tone: rankingOn
                    ? CatchBadgeTone.success
                    : CatchBadgeTone.neutral,
                icon: rankingOn
                    ? CatchIcons.autoAwesomeRounded
                    : CatchIcons.lightbulbOutlineRounded,
              ),
              if (widget.response != null)
                CatchBadge(
                  label: 'Saved',
                  tone: CatchBadgeTone.success,
                  icon: CatchIcons.checkRounded,
                ),
            ],
          ),
          gapH10,
          Text(
            rankingOn
                ? 'Your answers can shape reveal clues and help guide pairings. Hosts never see individual answers.'
                : 'Your answers can shape reveal clues. Hosts never see individual answers, and this event will not use them for pairings.',
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
          gapH16,
          QuestionProgressRail(
            activeIndex: _activeQuestionIndex,
            answeredCount: answeredQuestionCount,
            questionCount: questions.length,
            onSelect: (index) => setState(() => _activeQuestionIndex = index),
          ),
          if ((widget.event.checkedInCount ?? 0) > 0) ...[
            gapH8,
            LiveOthersInRoomLine(
              checkedInCount: widget.event.checkedInCount ?? 0,
            ),
          ],
          gapH16,
          AnimatedSwitcher(
            duration: CatchMotion.base,
            switchInCurve: CatchMotion.springCurve,
            switchOutCurve: CatchMotion.easeInCubicCurve,
            child: KeyedSubtree(
              key: ValueKey(activeQuestion.id),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activeQuestion.prompt,
                    style: CatchTextStyles.titleL(context),
                  ),
                  gapH12,
                  Wrap(
                    spacing: CatchSpacing.s2,
                    runSpacing: CatchSpacing.s2,
                    children: [
                      for (final option in activeQuestion.options)
                        StageBouncyChip(
                          label: option.label,
                          active: _answerIds.contains(option.id),
                          onTap: () => setState(() {
                            _answerIds = _answersReplacingQuestion(
                              question: activeQuestion,
                              answerId: option.id,
                            );
                            if (_activeQuestionIndex < questions.length - 1) {
                              _activeQuestionIndex++;
                            }
                          }),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (widget.actionState.error != null) ...[
            gapH14,
            Text(
              appErrorMessage(
                widget.actionState.error!,
                context: AppErrorContext.event,
              ),
              style: CatchTextStyles.supporting(context, color: t.danger),
            ),
            gapH10,
          ],
          gapH16,
          StageActionDock(
            child: CatchButton(
              label: widget.response == null ? 'Save clues' : 'Update clues',
              isLoading: saving,
              onPressed: !hasAnswers || !dirty || saving
                  ? null
                  : () async {
                      setState(() => _fixtureSavePending = true);
                      try {
                        await widget.onSaveAnswers(_answerIds);
                      } finally {
                        if (mounted) {
                          setState(() => _fixtureSavePending = false);
                        }
                      }
                    },
              fullWidth: true,
            ),
          ),
        ],
      ),
    );
  }

  List<String> get _initialAnswerIds =>
      EventSuccessCompatibilityQuestionnaire.normalizedAnswerIds(
        widget.response?.answerIds ?? const [],
        config: widget.plan.questionnaireConfig,
      );

  List<String> _answersReplacingQuestion({
    required EventSuccessCompatibilityQuestion question,
    required String answerId,
  }) {
    final optionIds = question.options.map((option) => option.id).toSet();
    final next = _answerIds
        .where((existing) => !optionIds.contains(existing))
        .toList();
    next.add(answerId);
    return EventSuccessCompatibilityQuestionnaire.normalizedAnswerIds(
      next,
      config: widget.plan.questionnaireConfig,
    );
  }

  String? _answerForQuestion(EventSuccessCompatibilityQuestion question) {
    final optionIds = question.options.map((option) => option.id).toSet();
    for (final answerId in _answerIds) {
      if (optionIds.contains(answerId)) return answerId;
    }
    return null;
  }
}

class QuestionProgressRail extends StatelessWidget {
  const QuestionProgressRail({
    required this.activeIndex,
    required this.answeredCount,
    required this.questionCount,
    required this.onSelect,
  });

  final int activeIndex;
  final int answeredCount;
  final int questionCount;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(CatchRadius.pill),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: questionCount == 0 ? 0 : answeredCount / questionCount,
              backgroundColor: t.line,
              valueColor: AlwaysStoppedAnimation<Color>(t.primary),
            ),
          ),
        ),
        gapW10,
        for (var index = 0; index < questionCount; index++) ...[
          Tooltip(
            message: 'Question ${index + 1}',
            child: Semantics(
              button: true,
              selected: index == activeIndex,
              label: 'Question ${index + 1}',
              child: InkWell(
                borderRadius: BorderRadius.circular(CatchRadius.pill),
                onTap: () => onSelect(index),
                child: CatchSurface(
                  width: CatchLayout.questionnaireDotExtent,
                  height: CatchLayout.questionnaireDotExtent,
                  radius: CatchRadius.pill,
                  backgroundColor: index == activeIndex
                      ? t.primary
                      : index < answeredCount
                      ? t.primarySoft
                      : t.surface,
                  borderColor: t.line,
                  child: Text(
                    '${index + 1}',
                    style: CatchTextStyles.labelS(
                      context,
                      color: index == activeIndex ? t.surface : t.ink2,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (index < questionCount - 1) gapW4,
        ],
      ],
    );
  }
}
