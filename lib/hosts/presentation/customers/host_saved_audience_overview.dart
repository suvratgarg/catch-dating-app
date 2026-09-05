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
    final current = catchAsyncStateFromAsyncValue(members).value;
    return CatchRouteScaffold(
      topBarBuilder: (context, scrolledUnder) => CatchTopBar(
        title: context.l10n.hostAudienceGroupTitle,
        leadingType: CatchTopBarLeading.back,
        divider: scrolledUnder,
      ),
      bottomNavigationBar: current == null
          ? null
          : CatchBottomAction(
              buttonKey: const ValueKey('host-saved-audience-message'),
              label: context.l10n.hostAudienceOpenInbox,
              onPressed:
                  current.preview.matchCount == 0 ||
                      current.loadMoreError != null
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
      body: CatchRouteBody.standardConstrained(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(audience.name, style: CatchTextStyles.headline(context)),
            gapH8,
            Text(
              _savedAudienceDirectoryBody(
                context,
                current?.preview.audience ?? audience,
              ),
              style: CatchTextStyles.supporting(context),
            ),
            gapH24,
            CatchSection.divided(
              first: true,
              title: context.l10n.hostAudienceMembershipMode,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!audience.definition.isStatic &&
                      audience.definition.predicates.length > 1)
                    Text(
                      audience.definition.join == HostSavedAudienceJoin.all
                          ? context.l10n.hostSavedAudienceMatchAll
                          : context.l10n.hostSavedAudienceMatchAny,
                      style: CatchTextStyles.recordContext(context),
                    ),
                  for (final predicate in audience.definition.predicates)
                    Padding(
                      padding: CatchInsets.contentVerticalCompact,
                      child: Text(
                        _savedAudienceRuleSummary(context, predicate, options),
                        style: CatchTextStyles.recordBody(context),
                      ),
                    ),
                  CatchButton.command(
                    key: const ValueKey('host-saved-audience-edit'),
                    label: context.l10n.hostSavedAudienceEditRules,
                    onPressed: onEdit,
                  ),
                ],
              ),
            ),
            gapH24,
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
                  CatchSection.divided(
                    first: true,
                    title: context.l10n.hostSavedAudienceMembers,
                    count: state.preview.matchCount,
                    trailing: CatchTextButton(
                      key: const ValueKey(
                        'host-saved-audience-refresh-preview',
                      ),
                      label: context.l10n.hostSavedAudiencePreview,
                      onPressed: () => ref.invalidate(provider),
                    ),
                    children: [
                      if (state.members.isEmpty)
                        Text(
                          context.l10n.hostSavedAudienceNoMembers,
                          style: CatchTextStyles.supporting(context),
                        ),
                      for (final member in state.members)
                        CatchPersonRow.directory(
                          key: ValueKey(
                            'host-saved-audience-member-${member.contactId}',
                          ),
                          data: CatchPersonRowData(
                            name: member.displayName,
                            seed: member.contactId,
                          ),
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
                    CatchButton.command(
                      key: const ValueKey('host-saved-audience-more-members'),
                      label: context.l10n.hostApplicationsLoadMore,
                      onPressed: state.loadingMore
                          ? null
                          : () => ref.read(provider.notifier).loadMore(),
                    ),
                  ],
                  gapH24,
                  CatchSection.divided(
                    title: context.l10n.hostAudienceGroupReach,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _savedAudienceReachBody(
                            context,
                            state.preview.reachSummary,
                          ),
                          style: CatchTextStyles.recordBody(context),
                        ),
                        gapH8,
                        Text(
                          context.l10n.hostAudienceGroupInboxHelp,
                          style: CatchTextStyles.supporting(context),
                        ),
                        gapH8,
                        Text(
                          context.l10n.hostAudienceGroupChecked(
                            date: DateFormat.yMMMd().add_jm().format(
                              state.preview.evaluatedAt,
                            ),
                          ),
                          style: CatchTextStyles.recordContext(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _savedAudienceReachBody(
  BuildContext context,
  HostAudienceReachSummary? reach,
) {
  if (reach == null) return context.l10n.hostAudienceGroupReachUnknown;
  return [
    if (reach.inCatch > 0)
      context.l10n.hostAudienceReachCountInCatch(count: reach.inCatch),
    if (reach.automatic > 0)
      context.l10n.hostAudienceReachCountAutomatic(count: reach.automatic),
    if (reach.byHand > 0)
      context.l10n.hostAudienceReachCountByHand(count: reach.byHand),
    if (reach.unavailable > 0)
      context.l10n.hostAudienceReachCountUnavailable(count: reach.unavailable),
    if (reach.total == 0) context.l10n.hostSavedAudienceNoMembers,
  ].join(' · ');
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
