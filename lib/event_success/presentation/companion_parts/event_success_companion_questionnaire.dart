part of '../event_success_companion_screen.dart';

class _CompatibilityQuestionnaireSection extends ConsumerStatefulWidget {
  const _CompatibilityQuestionnaireSection({
    required this.event,
    required this.plan,
    required this.response,
  });

  final Event event;
  final EventSuccessPlan plan;
  final EventSuccessCompatibilityResponse? response;

  @override
  ConsumerState<_CompatibilityQuestionnaireSection> createState() =>
      _CompatibilityQuestionnaireSectionState();
}

class _CompatibilityQuestionnaireSectionState
    extends ConsumerState<_CompatibilityQuestionnaireSection> {
  late List<String> _answerIds = _initialAnswerIds;

  @override
  void didUpdateWidget(covariant _CompatibilityQuestionnaireSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.response?.id != widget.response?.id ||
        oldWidget.plan.questionnaireConfig != widget.plan.questionnaireConfig ||
        !_sameAnswers(
          oldWidget.response?.answerIds,
          widget.response?.answerIds,
        )) {
      _answerIds = _initialAnswerIds;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final mutation = ref.watch(
      EventSuccessController.compatibilityResponseMutation,
    );
    final rankingOn = widget.plan.compatibilityAffectsRanking;
    final hasAnswers = _answerIds.isNotEmpty;
    final dirty = !_sameAnswers(_answerIds, widget.response?.answerIds);
    return CatchSurface(
      borderColor: t.line,
      padding: const EdgeInsets.all(CatchSpacing.s4),
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
                style: CatchTextStyles.titleM(context),
              ),
              CatchBadge(
                label: rankingOn ? 'Can guide pairings' : 'Clues only',
                tone: rankingOn
                    ? CatchBadgeTone.success
                    : CatchBadgeTone.neutral,
                icon: rankingOn
                    ? Icons.auto_awesome_rounded
                    : Icons.lightbulb_outline_rounded,
              ),
              if (widget.response != null)
                const CatchBadge(
                  label: 'Saved',
                  tone: CatchBadgeTone.success,
                  icon: Icons.check_rounded,
                ),
            ],
          ),
          gapH6,
          Text(
            rankingOn
                ? 'Your answers can shape reveal clues and help guide pairings. Hosts never see individual answers.'
                : 'Your answers can shape reveal clues. Hosts never see individual answers, and this event will not use them for pairings.',
            style: CatchTextStyles.bodyS(context, color: t.ink2),
          ),
          gapH16,
          for (final question
              in EventSuccessCompatibilityQuestionnaire.questionsFor(
                widget.plan.questionnaireConfig,
              )) ...[
            Text(question.prompt, style: CatchTextStyles.titleS(context)),
            gapH8,
            Wrap(
              spacing: CatchSpacing.s2,
              runSpacing: CatchSpacing.s2,
              children: [
                for (final option in question.options)
                  CatchChip(
                    label: option.label,
                    active: _answerIds.contains(option.id),
                    onTap: () => setState(() {
                      _answerIds = _answersReplacingQuestion(
                        question: question,
                        answerId: option.id,
                      );
                    }),
                  ),
              ],
            ),
            gapH14,
          ],
          if (mutation.hasError) ...[
            Text(
              appErrorMessage(
                (mutation as MutationError).error,
                context: AppErrorContext.event,
              ),
              style: CatchTextStyles.bodyS(context, color: t.danger),
            ),
            gapH10,
          ],
          CatchButton(
            label: widget.response == null ? 'Save answers' : 'Update answers',
            isLoading: mutation.isPending,
            onPressed: !hasAnswers || !dirty || mutation.isPending
                ? null
                : () =>
                      EventSuccessController.compatibilityResponseMutation.run(
                        ref,
                        (tx) => tx
                            .get(eventSuccessControllerProvider.notifier)
                            .saveCompatibilityResponse(
                              event: widget.event,
                              answerIds: _answerIds,
                              questionnaireConfig:
                                  widget.plan.questionnaireConfig,
                            ),
                      ),
            fullWidth: true,
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
}
