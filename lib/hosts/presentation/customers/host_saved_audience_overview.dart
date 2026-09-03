part of 'host_customers_screen.dart';

class HostSavedAudienceWorkspace extends StatefulWidget {
  const HostSavedAudienceWorkspace({super.key, required this.audience});
  final HostSavedAudience audience;

  @override
  State<HostSavedAudienceWorkspace> createState() =>
      _HostSavedAudienceWorkspaceState();
}

class _HostSavedAudienceWorkspaceState
    extends State<HostSavedAudienceWorkspace> {
  late HostSavedAudience _audience = widget.audience;
  bool _editing = false;

  @override
  Widget build(BuildContext context) => _editing
      ? _HostSavedAudienceEditorForm(
          organizerId: _audience.organizerId,
          initialAudience: _audience,
          onSaved: (audience) => setState(() {
            _audience = audience;
            _editing = false;
          }),
        )
      : HostSavedAudienceOverview(
          audience: _audience,
          onEdit: () => setState(() => _editing = true),
        );
}

class HostSavedAudienceOverview extends ConsumerWidget {
  const HostSavedAudienceOverview({
    super.key,
    required this.audience,
    required this.onEdit,
  });

  final HostSavedAudience audience;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = hostSavedAudienceMembersControllerProvider(audience);
    final members = ref.watch(provider);
    final options =
        catchAsyncStateFromAsyncValue(
          ref.watch(
            hostSavedAudienceFilterOptionsProvider(audience.organizerId),
          ),
        ).value ??
        const HostSavedAudienceFilterOptions.empty();
    return CatchRouteScaffold(
      topBarBuilder: (context, scrolledUnder) => CatchScreenTopBar(
        context: context,
        title: audience.name,
        leadingType: CatchTopBarLeading.back,
        divider: scrolledUnder,
      ),
      body: CatchRouteBody.standard(
        child: CatchSectionList(
          emptyStateOmitted: true,
          children: [
            CatchSection.fieldRows(
              children: [
                CatchField.action(
                  key: const ValueKey('host-saved-audience-edit'),
                  title: context.l10n.hostSavedAudienceEditRules,
                  onTap: onEdit,
                ),
                CatchField.action(
                  key: const ValueKey('host-saved-audience-refresh-preview'),
                  title: context.l10n.hostSavedAudiencePreview,
                  onTap: () => ref.invalidate(provider),
                ),
              ],
            ),
            CatchSection.fieldRows(
              title: audience.definition.isStatic
                  ? context.l10n.hostAudienceStaticMembership
                  : audience.definition.join == HostSavedAudienceJoin.all
                  ? context.l10n.hostSavedAudienceMatchAll
                  : context.l10n.hostSavedAudienceMatchAny,
              children: [
                for (var i = 0; i < audience.definition.predicates.length; i++)
                  CatchField.read(
                    title: context.l10n.hostSavedAudienceCondition(
                      number: i + 1,
                    ),
                    body: _savedAudienceRuleSummary(
                      context,
                      audience.definition.predicates[i],
                      options,
                    ),
                  ),
              ],
            ),
            CatchAsyncValueView<HostSavedAudienceMembersState>(
              value: members,
              initialLoadTimeout: null,
              onRetry: () => ref.invalidate(provider),
              loadingBuilder: (_) => const CatchSkeletonRows(count: 4),
              errorBuilder: (_, error, _) => CatchErrorState.fromError(
                error,
                context: AppErrorContext.customers,
                onRetry: () => ref.invalidate(provider),
              ),
              builder: (context, state) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CatchSection.fieldRows(
                    children: [
                      CatchField.read(
                        title: context.l10n.hostSavedAudiencePeople,
                        body: _savedAudienceDirectoryBody(
                          context,
                          state.preview.audience,
                        ),
                      ),
                      CatchField.read(
                        title: context.l10n.hostSavedAudienceEvaluated,
                        body: DateFormat.yMMMd().add_jm().format(
                          state.preview.evaluatedAt,
                        ),
                      ),
                      CatchField.action(
                        key: const ValueKey('host-saved-audience-message'),
                        title: context.l10n.hostSavedAudienceMessage,
                        body: context.l10n.hostSavedAudiencePreviewDisclosure,
                        onTap:
                            state.preview.matchCount == 0 ||
                                state.loadMoreError != null
                            ? null
                            : () => context.goNamed(
                                Routes.hostInboxScreen.name,
                                queryParameters: {
                                  'workspace': 'campaigns',
                                  'compose': '1',
                                  'audienceId': audience.audienceId,
                                  'organizerId': audience.organizerId,
                                },
                              ),
                      ),
                    ],
                  ),
                  gapH24,
                  CatchSection.fieldRows(
                    title: context.l10n.hostSavedAudienceMembers,
                    children: [
                      if (state.members.isEmpty)
                        CatchField.read(
                          title: context.l10n.hostSavedAudienceNoMembers,
                        ),
                      for (final member in state.members)
                        CatchField.nav(
                          key: ValueKey(
                            'host-saved-audience-member-${member.contactId}',
                          ),
                          title: member.displayName,
                          onTap: () => context.pushNamed(
                            Routes.hostCustomerDetailScreen.name,
                            pathParameters: {'contactId': member.contactId},
                            queryParameters: {
                              'organizerId': audience.organizerId,
                            },
                          ),
                        ),
                    ],
                  ),
                  if (state.loadMoreError case final error?) ...[
                    gapH16,
                    CatchErrorState.fromError(
                      error,
                      context: AppErrorContext.customers,
                      onRetry: () => ref.invalidate(provider),
                    ),
                  ],
                  if (state.preview.nextCursor != null &&
                      state.loadMoreError == null) ...[
                    gapH16,
                    CatchButton(
                      key: const ValueKey('host-saved-audience-more-members'),
                      label: context.l10n.hostApplicationsLoadMore,
                      variant: CatchButtonVariant.secondary,
                      isLoading: state.loadingMore,
                      onPressed: state.loadingMore
                          ? null
                          : () => ref.read(provider.notifier).loadMore(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _savedAudienceRuleSummary(
  BuildContext context,
  HostSavedAudiencePredicate predicate,
  HostSavedAudienceFilterOptions options,
) => switch (predicate) {
  HostSavedAudienceStaticMembers(:final contactIds) =>
    context.l10n.hostAudienceSelectedCount(count: contactIds.length),
  HostSavedAudienceSpend(
    :final operator,
    :final currency,
    :final amountMinor,
    :final withinDays,
  ) =>
    '${operator == HostSavedAudienceAttendanceOperator.atLeast ? context.l10n.hostSavedAudienceAtLeast : context.l10n.hostSavedAudienceAtMost} '
        '${formatMinorCurrency(amountMinor, currencyCode: currency)} $currency · '
        '${withinDays == null ? context.l10n.hostAudienceSpendLifetime : context.l10n.hostAudienceSpendWindow(days: withinDays)}',

  HostSavedAudienceApplicationStatusRule(:final formId, :final reviewStatus) =>
    '${options.forms.where((f) => f.id == formId).firstOrNull?.title ?? context.l10n.hostAudienceSourceUnavailable} · '
        '${_audienceApplicationStatusLabel(context, reviewStatus)}',
  HostSavedAudienceFormAnswer() => _savedAudienceAnswerSummary(
    context,
    predicate,
    options,
  ),
  HostSavedAudienceAttendedEvent(:final eventId) =>
    '${context.l10n.hostAudienceRuleNamedEvent}: '
        '${options.events.where((e) => e.id == eventId).firstOrNull?.title ?? context.l10n.hostAudienceSourceUnavailable}',

  HostSavedAudienceComputedSegment(:final segment) => _customerFilterLabel(
    context,
    hostCustomerFilterForAudienceSegment(segment),
  ),
  HostSavedAudienceManualTag(:final manualTagId) =>
    '${context.l10n.hostSavedAudienceRuleTag}: '
        '${options.tags.where((t) => t.tagId == manualTagId).firstOrNull?.label ?? context.l10n.hostAudienceSourceUnavailable}',
  HostSavedAudienceAttendanceCount(:final operator, :final eventCount) =>
    '${operator == HostSavedAudienceAttendanceOperator.atLeast ? context.l10n.hostSavedAudienceAtLeast : context.l10n.hostSavedAudienceAtMost} $eventCount '
        '${context.l10n.hostSavedAudienceEventsUnit}',
  HostSavedAudienceLastSeenWithinDays(:final days) =>
    '${context.l10n.hostSavedAudienceLastSeenWithin} $days '
        '${context.l10n.hostSavedAudienceDaysUnit}',
  HostSavedAudienceCampaignReachable() =>
    context.l10n.hostSavedAudienceManagedReach,
};

String _savedAudienceAnswerSummary(
  BuildContext context,
  HostSavedAudienceFormAnswer rule,
  HostSavedAudienceFilterOptions options,
) {
  final question = options.questions
      .where(
        (q) =>
            q.formId == rule.formId &&
            q.versionId == rule.versionId &&
            q.questionId == rule.questionId,
      )
      .firstOrNull;
  if (question == null) return context.l10n.hostAudienceSourceUnavailable;
  final answer = question.options
      .where((o) => o.value == rule.value)
      .firstOrNull;
  return '${question.formTitle} · v${question.version} · ${question.label}: '
      '${answer == null ? context.l10n.hostAudienceSourceUnavailable : _audienceAnswerLabel(context, answer)}';
}
