part of 'host_customers_screen.dart';

class HostSavedAudiencesWorkspace extends ConsumerWidget
    implements CatchRootScreenPageOwner {
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
  Widget build(BuildContext context, WidgetRef ref) =>
      CatchRootScreenPageScrollView.standard(
        scrollKey: const PageStorageKey<String>('host-customers-audiences'),
        onRefresh: () async {
          ref.invalidate(hostSavedAudiencesProvider(organizerId));
          ref.invalidate(hostAllSavedAudiencesProvider(organizerId));
          await ref.read(hostAllSavedAudiencesProvider(organizerId).future);
        },
        slivers: [
          HostSavedAudiencesDirectory(
            organizerId: organizerId,
            query: query,
            onCreate: onCreate,
            onOpen: onOpen,
          ),
        ],
      );
}

class HostSavedAudiencesDirectory extends ConsumerStatefulWidget {
  const HostSavedAudiencesDirectory({
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
  ConsumerState<HostSavedAudiencesDirectory> createState() =>
      _HostSavedAudiencesDirectoryState();
}

class _HostSavedAudiencesDirectoryState
    extends ConsumerState<HostSavedAudiencesDirectory> {
  String _membership = 'all';
  bool _byName = false;
  String get organizerId => widget.organizerId;
  String? get query => widget.query;
  VoidCallback get onCreate => widget.onCreate;
  ValueChanged<HostSavedAudience> get onOpen => widget.onOpen;

  @override
  Widget build(BuildContext context) {
    final audiences = ref.watch(hostAllSavedAudiencesProvider(organizerId));
    return SliverList.list(
      children: [
        Wrap(
          spacing: CatchSpacing.s4,
          runSpacing: CatchSpacing.s2,
          children: [
            CatchButton.command(
              label: _byName
                  ? context.l10n.hostCustomersSortName
                  : context.l10n.hostAudienceRecentlyChecked,
              icon: Icon(CatchIcons.sort),
              onPressed: () => setState(() => _byName = !_byName),
            ),
            CatchButton.command(
              label: switch (_membership) {
                'automatic' => context.l10n.hostAudienceAutomaticGroup,
                'manual' => context.l10n.hostAudienceManualGroup,
                _ => context.l10n.hostAudienceAllGroups,
              },
              icon: Icon(CatchIcons.tune),
              onPressed: _chooseMembership,
            ),
          ],
        ),
        gapH16,
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
            final visible =
                _matchingSavedAudiences(page.audiences, query)
                    .where(
                      (audience) => switch (_membership) {
                        'automatic' => !audience.definition.isStatic,
                        'manual' => audience.definition.isStatic,
                        _ => true,
                      },
                    )
                    .toList()
                  ..sort(
                    (a, b) => _byName
                        ? a.name.toLowerCase().compareTo(b.name.toLowerCase())
                        : (b.lastPreviewAt ?? DateTime(0)).compareTo(
                            a.lastPreviewAt ?? DateTime(0),
                          ),
                  );
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
                        title: query == null && _membership == 'all'
                            ? context.l10n.hostSavedAudiencesEmptyTitle
                            : context.l10n.hostSavedAudiencesSearchEmptyTitle,
                        message: query == null && _membership == 'all'
                            ? context.l10n.hostSavedAudiencesEmptyBody
                            : context.l10n.hostSavedAudiencesSearchEmptyBody,
                        layout: CatchEmptyStateLayout.inline,
                      ),
                    ]
                  : [
                      for (final audience in visible)
                        CatchRecordRow(
                          key: ValueKey(
                            'host-saved-audience-${audience.audienceId}',
                          ),
                          title: audience.name,
                          facts: [
                            _savedAudienceDirectoryBody(context, audience),
                          ],
                          icon: CatchIcons.groupsOutlined,
                          metadata: audience.definition.isStatic
                              ? context.l10n.hostAudienceManualGroup
                              : context.l10n.hostAudienceAutomaticGroup,
                          onTap: () => onOpen(audience),
                        ),
                    ],
            );
          },
        ),
        gapH24,
        Text(
          context.l10n.hostAudienceGroupMembershipHelp,
          style: CatchTextStyles.supporting(context),
        ),
        gapH24,
        CatchSection.fieldRows(
          children: [
            CatchField.nav(
              title: context.l10n.hostFormAutomationsTitle,
              onTap: () => context.pushNamed(
                Routes.hostAudienceAutomationsScreen.name,
                queryParameters: {'organizerId': organizerId},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _chooseMembership() async {
    final selected = await showCatchSelectionSheet<String>(
      context: context,
      title: context.l10n.hostAudienceMembershipMode,
      value: _membership,
      items: [
        CatchSelectionMenuItem(
          value: 'all',
          label: context.l10n.hostAudienceAllGroups,
        ),
        CatchSelectionMenuItem(
          value: 'automatic',
          label: context.l10n.hostAudienceAutomaticGroup,
        ),
        CatchSelectionMenuItem(
          value: 'manual',
          label: context.l10n.hostAudienceManualGroup,
        ),
      ],
    );
    if (selected != null && mounted) setState(() => _membership = selected);
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
  final checked = audience.lastPreviewAt;
  return checked == null
      ? countLabel
      : '$countLabel · ${context.l10n.hostAudienceGroupChecked(date: DateFormat.MMMd().format(checked))}';
}
