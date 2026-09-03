part of 'host_customers_screen.dart';

class HostSavedAudiencesWorkspace extends ConsumerWidget
    implements CatchTabbedPageOwner {
  const HostSavedAudiencesWorkspace({
    super.key,
    required this.organizerId,
    required this.query,
    required this.onCreate,
    required this.onOpen,
  });

  final String organizerId;
  final String? query;
  final VoidCallback onCreate;
  final ValueChanged<HostSavedAudience> onOpen;

  @override
  CatchScreenBodyLayout get bodyLayout => CatchScreenBodyLayout.standard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audiences = ref.watch(hostAllSavedAudiencesProvider(organizerId));
    return CatchTabbedPageScrollView(
      scrollKey: const PageStorageKey<String>('host-customers-audiences'),
      bodyLayout: bodyLayout,
      constrainToContentWidth: true,
      onRefresh: () async {
        ref.invalidate(hostSavedAudiencesProvider(organizerId));
        ref.invalidate(hostAllSavedAudiencesProvider(organizerId));
        await ref.read(hostAllSavedAudiencesProvider(organizerId).future);
      },
      slivers: [
        SliverList.list(
          children: [
            Text(
              context.l10n.hostSavedAudiencesWorkspaceBody,
              style: CatchTextStyles.proseM(
                context,
                color: CatchTokens.of(context).ink2,
              ),
            ),
            gapH24,
            CatchSection.fieldRows(
              children: [
                CatchField.nav(
                  title: context.l10n.hostFormAutomationsTitle,
                  body: context.l10n.hostAutomationOverview,
                  onTap: () => context.pushNamed(
                    Routes.hostAudienceAutomationsScreen.name,
                    queryParameters: {'organizerId': organizerId},
                  ),
                ),
              ],
            ),
            gapH24,
            CatchAsyncValueView<HostSavedAudiencePage>(
              value: audiences,
              onRetry: () =>
                  ref.invalidate(hostAllSavedAudiencesProvider(organizerId)),
              initialLoadTimeout: null,
              loadingBuilder: (_) => const CatchSkeletonRows(count: 4),
              errorBuilder: (_, error, _) => CatchErrorState.fromError(
                error,
                context: AppErrorContext.customers,
                mode: CatchErrorStateMode.compact,
                onRetry: () =>
                    ref.invalidate(hostAllSavedAudiencesProvider(organizerId)),
              ),
              builder: (context, page) {
                final visible = _matchingSavedAudiences(page.audiences, query);
                return CatchSection.divided(
                  key: const ValueKey('host-saved-audiences-directory'),
                  first: true,
                  title: context.l10n.hostSavedAudiencesManage,
                  count: visible.length,
                  trailing: CatchTextButton(
                    key: const ValueKey('host-saved-audience-create'),
                    label: context.l10n.hostSavedAudienceNew,
                    onPressed: onCreate,
                  ),
                  children: visible.isEmpty
                      ? [
                          CatchEmptyState(
                            icon: CatchIcons.groupsOutlined,
                            title: query == null
                                ? context.l10n.hostSavedAudiencesEmptyTitle
                                : context
                                      .l10n
                                      .hostSavedAudiencesSearchEmptyTitle,
                            message: query == null
                                ? context.l10n.hostSavedAudiencesEmptyBody
                                : context
                                      .l10n
                                      .hostSavedAudiencesSearchEmptyBody,
                            layout: CatchEmptyStateLayout.inline,
                          ),
                        ]
                      : [
                          for (final audience in visible)
                            CatchField.nav(
                              key: ValueKey(
                                'host-saved-audience-${audience.audienceId}',
                              ),
                              title: audience.name,
                              body: _savedAudienceDirectoryBody(
                                context,
                                audience,
                              ),
                              emphasis: CatchFieldEmphasis.title,
                              onTap: () => onOpen(audience),
                            ),
                        ],
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

List<HostSavedAudience> _matchingSavedAudiences(
  List<HostSavedAudience> audiences,
  String? query,
) {
  final normalized = query?.trim().toLowerCase();
  if (normalized == null || normalized.isEmpty) return audiences;
  return audiences
      .where((audience) => audience.name.toLowerCase().contains(normalized))
      .toList(growable: false);
}

String _savedAudienceDirectoryBody(
  BuildContext context,
  HostSavedAudience audience,
) {
  final count = audience.lastPreviewMatchCount;
  final countLabel = count == null
      ? context.l10n.hostSavedAudienceNeverPreviewed
      : context.l10n.hostSavedAudiencePeopleCount(count: count);
  final reach = audience.lastPreviewReachSummary;
  if (reach == null) return countLabel;
  final clauses = <String>[
    if (reach.inCatch > 0)
      context.l10n.hostAudienceReachCountInCatch(count: reach.inCatch),
    if (reach.automatic > 0)
      context.l10n.hostAudienceReachCountAutomatic(count: reach.automatic),
    if (reach.byHand > 0)
      context.l10n.hostAudienceReachCountByHand(count: reach.byHand),
    if (reach.unavailable > 0)
      context.l10n.hostAudienceReachCountUnavailable(count: reach.unavailable),
  ];
  return clauses.isEmpty ? countLabel : '$countLabel\n${clauses.join(' · ')}';
}
