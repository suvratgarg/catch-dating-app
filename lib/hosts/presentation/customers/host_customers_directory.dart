part of 'host_customers_screen.dart';

class HostCustomerDirectoryControls extends StatelessWidget {
  const HostCustomerDirectoryControls({
    super.key,
    required this.sort,
    required this.onSortChanged,
    required this.onOpenFilters,
    this.shrinkWrap = false,
    this.condensed = false,
  });

  final HostCustomerSort sort;
  final ValueChanged<HostCustomerSort> onSortChanged;
  final VoidCallback? onOpenFilters;
  final bool shrinkWrap;
  final bool condensed;

  @override
  Widget build(BuildContext context) {
    final usesLargeText = MediaQuery.textScalerOf(context).scale(1) >= 1.5;
    if (shrinkWrap && !usesLargeText) {
      return _HostCustomerDirectoryInlineControls(
        sort: sort,
        compactCopy: condensed,
        onSortChanged: onSortChanged,
        onOpenFilters: onOpenFilters,
      );
    }
    return ComponentResponsiveBuilder(
      breakpoint:
          ComponentBreakpoints.hostCustomerDirectoryControlsCompactBreakpoint,
      compact: (context) => _HostCustomerDirectoryWrappingControls(
        sort: sort,
        compactCopy: true,
        onSortChanged: onSortChanged,
        onOpenFilters: onOpenFilters,
      ),
      expanded: (context) => _HostCustomerDirectoryWrappingControls(
        sort: sort,
        compactCopy: false,
        onSortChanged: onSortChanged,
        onOpenFilters: onOpenFilters,
      ),
    );
  }
}

class _HostCustomerDirectoryInlineControls extends StatelessWidget {
  const _HostCustomerDirectoryInlineControls({
    required this.sort,
    required this.compactCopy,
    required this.onSortChanged,
    required this.onOpenFilters,
  });

  final HostCustomerSort sort;
  final bool compactCopy;
  final ValueChanged<HostCustomerSort> onSortChanged;
  final VoidCallback? onOpenFilters;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      _HostCustomerDirectoryFilterButton(
        compactCopy: compactCopy,
        onOpenFilters: onOpenFilters,
      ),
      gapW8,
      _HostCustomerDirectorySortControl(
        sort: sort,
        compactCopy: compactCopy,
        onSortChanged: onSortChanged,
      ),
    ],
  );
}

class _HostCustomerDirectoryWrappingControls extends StatelessWidget {
  const _HostCustomerDirectoryWrappingControls({
    required this.sort,
    required this.compactCopy,
    required this.onSortChanged,
    required this.onOpenFilters,
  });

  final HostCustomerSort sort;
  final bool compactCopy;
  final ValueChanged<HostCustomerSort> onSortChanged;
  final VoidCallback? onOpenFilters;

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.end,
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: CatchSpacing.s2,
    runSpacing: CatchSpacing.s2,
    children: [
      _HostCustomerDirectoryFilterButton(
        compactCopy: compactCopy,
        onOpenFilters: onOpenFilters,
      ),
      _HostCustomerDirectorySortControl(
        sort: sort,
        compactCopy: compactCopy,
        onSortChanged: onSortChanged,
      ),
    ],
  );
}

class _HostCustomerDirectoryFilterButton extends StatelessWidget {
  const _HostCustomerDirectoryFilterButton({
    required this.compactCopy,
    required this.onOpenFilters,
  });

  final bool compactCopy;
  final VoidCallback? onOpenFilters;

  @override
  Widget build(BuildContext context) => CatchButton(
    key: const ValueKey('host-customers-filters'),
    label: context.l10n.hostCustomersFilters,
    icon: compactCopy ? null : Icon(CatchIcons.tuneRounded),
    variant: CatchButtonVariant.secondary,
    size: CatchButtonSize.sm,
    onPressed: onOpenFilters,
  );
}

class _HostCustomerDirectorySortControl extends StatelessWidget {
  const _HostCustomerDirectorySortControl({
    required this.sort,
    required this.compactCopy,
    required this.onSortChanged,
  });

  final HostCustomerSort sort;
  final bool compactCopy;
  final ValueChanged<HostCustomerSort> onSortChanged;

  @override
  Widget build(BuildContext context) =>
      CatchAdaptiveSelectionControl<HostCustomerSort>(
        buttonKey: const ValueKey('host-customers-sort'),
        title: context.l10n.hostCustomersSort,
        subtitle: context.l10n.hostCustomersSortSheetSubtitle,
        tooltip: context.l10n.hostCustomersSort,
        value: sort,
        items: [
          for (final option in HostCustomerSort.values)
            CatchSelectionMenuItem(
              value: option,
              label: _customerSortLabel(context, option),
            ),
        ],
        triggerLabel: (selected) => compactCopy
            ? selected.label
            : context.l10n.hostCustomersSortControl(label: selected.label),
        onSelected: onSortChanged,
      );
}

class HostCustomersNoOrganizer extends StatelessWidget {
  const HostCustomersNoOrganizer({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: CatchScreenHeaderTitle.block(
              title: context.l10n.hostNavigationAudience,
            ),
          ),
          CatchSliverEmptyState(
            icon: CatchIcons.groupsOutlined,
            title: context.l10n.hostsHostEventsScaffoldTitleCreateYourFirstClub,
            message: context.l10n.hostsHostEventsScaffoldBodyCreateAClubTo,
            action: CatchButton(
              label: context.l10n.hostsHostEventsScaffoldLabelCreateClub,
              onPressed: () =>
                  context.pushNamed(Routes.hostCreateClubScreen.name),
            ),
          ),
        ],
      ),
    ),
  );
}

class HostCustomerFilterSummary extends StatelessWidget {
  const HostCustomerFilterSummary({
    super.key,
    required this.filter,
    this.manualTag,
    required this.count,
    required this.countCoverage,
    required this.campaignBlocker,
    required this.onMessage,
    required this.onReviewSenderSetup,
    this.onClear,
    this.trailing,
  });

  final HostCustomerFilter filter;
  final HostCustomerManualTag? manualTag;
  final int count;
  final HostCustomerMatchCountCoverage countCoverage;
  final String? campaignBlocker;
  final VoidCallback? onMessage;
  final VoidCallback? onReviewSenderSetup;
  final VoidCallback? onClear;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final countLabel = _customerPeopleCountLabel(context, count, countCoverage);
    final header = context.l10n.hostCustomersFilterSummary(
      label: manualTag?.label ?? _customerFilterLabel(context, filter),
      countLabel: countLabel,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: CatchSpacing.s3,
          runSpacing: CatchSpacing.s1,
          children: [
            Text(header, style: CatchTextStyles.labelL(context)),
            if (onClear != null || trailing != null)
              Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: CatchSpacing.s2,
                runSpacing: CatchSpacing.s2,
                children: [
                  if (onClear case final clear?)
                    CatchButton(
                      label: context.l10n.hostCustomersClearFilter,
                      variant: CatchButtonVariant.ghost,
                      size: CatchButtonSize.sm,
                      onPressed: clear,
                    ),
                  ?trailing,
                ],
              ),
          ],
        ),
        if (campaignBlocker != null ||
            onMessage != null ||
            onReviewSenderSetup != null) ...[
          gapH12,
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: CatchSpacing.s3,
            runSpacing: CatchSpacing.s2,
            children: [
              if (campaignBlocker case final String blocker)
                Text(
                  hostCampaignBlockerLabel(context, blocker),
                  style: CatchTextStyles.supporting(
                    context,
                    color: CatchTokens.of(context).warning,
                  ),
                ),
              if (onMessage case final message?)
                CatchButton(
                  key: const ValueKey('host-customers-messaging-action'),
                  label: countCoverage == HostCustomerMatchCountCoverage.exact
                      ? context.l10n.hostCustomersMessageThese(count: count)
                      : context.l10n.hostCustomersMessageTheseAtLeast(
                          count: count,
                        ),
                  size: CatchButtonSize.sm,
                  onPressed: message,
                )
              else if (onReviewSenderSetup case final review?)
                CatchButton(
                  key: const ValueKey('host-customers-sender-setup-action'),
                  label: context.l10n.hostCustomersSetUpWhatsappBusiness,
                  variant: CatchButtonVariant.secondary,
                  size: CatchButtonSize.sm,
                  onPressed: review,
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class HostCustomerFilterSheet extends StatelessWidget {
  const HostCustomerFilterSheet({
    super.key,
    required this.selectedFilter,
    required this.selectedManualTag,
    required this.manualTagVocabulary,
    required this.selectedCount,
    required this.smsReadiness,
  });

  final HostCustomerFilter selectedFilter;
  final HostCustomerManualTag? selectedManualTag;
  final List<HostCustomerManualTag> manualTagVocabulary;
  final HostCustomerSegmentCount selectedCount;
  final HostCrmChannelReadiness? smsReadiness;

  @override
  Widget build(BuildContext context) {
    final groups = hostCustomerFilterGroupsForSmsReadiness(smsReadiness);
    final maxHeight =
        MediaQuery.sizeOf(context).height * CatchLayout.sheetMaxHeightFraction;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: CatchBottomSheetScaffold(
        title: context.l10n.hostCustomersFilterSheetTitle,
        subtitle: context.l10n.hostCustomersFilterSheetSubtitle,
        child: Flexible(
          child: ListView(
            key: const ValueKey('host-customer-filter-scroll'),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            children: [
              CatchSectionList(
                emptyStateOmitted: true,
                children: [
                  for (final entry in groups.entries)
                    CatchSection.divided(
                      title: _customerFilterGroupLabel(context, entry.key),
                      child: Wrap(
                        spacing: CatchSpacing.s2,
                        runSpacing: CatchSpacing.s2,
                        children: [
                          for (final filter in entry.value)
                            _HostCustomerFilterChip(
                              filter: filter,
                              selected:
                                  selectedManualTag == null &&
                                  selectedFilter == filter,
                              selectedCount: selectedCount,
                            ),
                        ],
                      ),
                    ),
                  if (manualTagVocabulary.isNotEmpty)
                    CatchSection.divided(
                      title: context.l10n.hostCustomersFilterGroupYourTags,
                      child: Wrap(
                        spacing: CatchSpacing.s2,
                        runSpacing: CatchSpacing.s2,
                        children: [
                          for (final tag in manualTagVocabulary)
                            _HostCustomerManualTagChip(
                              tag: tag,
                              selected: selectedManualTag?.tagId == tag.tagId,
                              selectedCount: selectedCount,
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HostCustomerFilterChip extends StatelessWidget {
  const _HostCustomerFilterChip({
    required this.filter,
    required this.selected,
    required this.selectedCount,
  });

  final HostCustomerFilter filter;
  final bool selected;
  final HostCustomerSegmentCount selectedCount;

  @override
  Widget build(BuildContext context) {
    final filterLabel = _customerFilterLabel(context, filter);
    return CatchChip.selectable(
      key: ValueKey('host-customer-filter-${filter.name}'),
      label: selected
          ? context.l10n.hostCustomersFilterOption(
              label: filterLabel,
              countLabel: _customerPeopleCountLabel(
                context,
                selectedCount.count,
                selectedCount.coverage,
              ),
            )
          : filterLabel,
      selected: selected,
      contractExemption: 'Customer filters map to reviewed CRM segments.',
      onChanged: (_) => Navigator.of(
        context,
      ).pop(HostCustomerFilterSelection.computed(filter)),
    );
  }
}

class _HostCustomerManualTagChip extends StatelessWidget {
  const _HostCustomerManualTagChip({
    required this.tag,
    required this.selected,
    required this.selectedCount,
  });

  final HostCustomerManualTag tag;
  final bool selected;
  final HostCustomerSegmentCount selectedCount;

  @override
  Widget build(BuildContext context) {
    return CatchChip.selectable(
      key: ValueKey('host-customer-manual-tag-${tag.tagId}'),
      label: selected
          ? context.l10n.hostCustomersFilterOption(
              label: tag.label,
              countLabel: _customerPeopleCountLabel(
                context,
                selectedCount.count,
                selectedCount.coverage,
              ),
            )
          : tag.label,
      leading: Icon(CatchIcons.editNoteOutlined),
      selected: selected,
      accent: CatchTokens.of(context).ink2,
      contractExemption: 'Manual tags are organizer-owned CRM vocabulary.',
      onChanged: (_) =>
          Navigator.of(context).pop(HostCustomerFilterSelection.manual(tag)),
    );
  }
}

class HostCustomersDirectory extends StatelessWidget {
  const HostCustomersDirectory({
    super.key,
    required this.state,
    required this.hasActiveQuery,
    required this.onCustomerSelected,
    required this.onLoadMore,
    required this.onRefreshCoverage,
  });

  final HostCustomersDirectoryState state;
  final bool hasActiveQuery;
  final ValueChanged<HostCustomerDirectoryContact> onCustomerSelected;
  final VoidCallback? onLoadMore;
  final VoidCallback onRefreshCoverage;

  @override
  Widget build(BuildContext context) {
    final contacts = state.contacts;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.sourceCoverage != HostCustomerDirectoryCoverage.exact) ...[
          CatchSurface.message(
            title: context.l10n.hostsHostAudienceCoveragePartial,
            message: context.l10n.hostsHostAudienceCoveragePartialBody,
            messageIcon: CatchIcons.infoOutlineRounded,
            messageTone: CatchSurfaceMessageTone.warning,
          ),
          gapH8,
          Align(
            alignment: Alignment.centerLeft,
            child: CatchButton(
              key: const ValueKey('host-customers-refresh-coverage'),
              label: context.l10n.hostCustomersCoverageRefresh,
              variant: CatchButtonVariant.secondary,
              size: CatchButtonSize.sm,
              onPressed: onRefreshCoverage,
            ),
          ),
          gapH12,
        ],
        if (contacts.isEmpty)
          CatchEmptyState(
            icon: CatchIcons.peopleOutlineRounded,
            title: hasActiveQuery
                ? context.l10n.hostCustomersNoResults
                : context.l10n.hostCustomersEmpty,
            message: hasActiveQuery ? null : context.l10n.hostCustomersIntro,
            layout: CatchEmptyStateLayout.inline,
          )
        else
          CatchSection.divided(
            key: const ValueKey('host-customers-directory-list'),
            first: true,
            children: [
              for (final contact in contacts)
                HostCustomerRow(
                  contact: contact,
                  divider: false,
                  onTap: () => onCustomerSelected(contact),
                ),
            ],
          ),
        if (onLoadMore != null) ...[
          gapH12,
          CatchButton(
            label: context.l10n.hostCustomersLoadMore,
            variant: CatchButtonVariant.secondary,
            size: CatchButtonSize.sm,
            isLoading: state.loadingMore,
            onPressed: state.loadingMore ? null : onLoadMore,
          ),
        ],
        if (state.loadMoreError != null) ...[
          gapH8,
          CatchErrorState.fromError(
            state.loadMoreError!,
            context: AppErrorContext.club,
            mode: CatchErrorStateMode.compact,
            onRetry: onLoadMore,
          ),
        ],
      ],
    );
  }
}

class HostCustomersSummary extends StatelessWidget {
  const HostCustomersSummary({
    super.key,
    required this.summary,
    required this.onRetry,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  final AsyncValue<HostCrmSummary> summary;
  final VoidCallback onRetry;
  final HostCustomerFilter? selectedFilter;
  final ValueChanged<HostCustomerFilter> onFilterSelected;

  @override
  Widget build(BuildContext context) => CatchAsyncValueView<HostCrmSummary>(
    value: summary,
    onRetry: onRetry,
    initialLoadTimeout: null,
    loadingBuilder: (_) => const CatchSkeletonRows(count: 1),
    errorBuilder: (_, error, _) => CatchErrorState.fromError(
      error,
      context: AppErrorContext.customers,
      mode: CatchErrorStateMode.compact,
      onRetry: onRetry,
    ),
    builder: (context, value) {
      final usesLargeText = MediaQuery.textScalerOf(context).scale(1) >= 1.5;
      final compactMetrics =
          ScreenSize.fromWidth(MediaQuery.sizeOf(context).width).isCompact &&
          !usesLargeText;
      String countLabel(int count) => value.truncated ? '$count+' : '$count';
      final stats = <({HostCustomerFilter filter, String label, String value})>[
        (
          filter: HostCustomerFilter.all,
          value: countLabel(value.contactCount),
          label: context.l10n.hostsHostAudienceContacts,
        ),
        (
          filter: HostCustomerFilter.attended,
          value: countLabel(value.pastAttendeeCount),
          label: context.l10n.hostsHostAudienceAttended,
        ),
        (
          filter: HostCustomerFilter.repeat,
          value: countLabel(value.repeatAttendeeCount),
          label: context.l10n.hostsHostAudienceRepeat,
        ),
      ];
      final statTiles = <Widget>[
        for (final stat in stats)
          _HostCustomerSummaryFilterTile(
            key: ValueKey('host-customers-summary-${stat.filter.name}'),
            value: stat.value,
            label: stat.label,
            selected: selectedFilter == stat.filter,
            compact: compactMetrics,
            onTap: () => onFilterSelected(stat.filter),
          ),
      ];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (usesLargeText)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var index = 0; index < statTiles.length; index++) ...[
                  if (index > 0) gapH8,
                  statTiles[index],
                ],
              ],
            )
          else
            Row(
              children: [
                for (var index = 0; index < statTiles.length; index++) ...[
                  if (index > 0) compactMetrics ? gapW4 : gapW8,
                  Expanded(child: statTiles[index]),
                ],
              ],
            ),
          gapH20,
          CatchMetaRow(
            icon: CatchIcons.tabChats,
            label: context.l10n.hostCustomersWhatsappReadyCount(
              count: value.whatsappOptInCount,
            ),
            maxLines: 2,
          ),
          gapH8,
          CatchMetaRow(
            icon: CatchIcons.infoOutlineRounded,
            label: context.l10n.hostCustomersSourceSummary(
              importedCount: value.importedContactCount,
              linkedCount: value.linkedAccountCount,
            ),
            maxLines: 3,
          ),
        ],
      );
    },
  );
}

class _HostCustomerSummaryFilterTile extends StatefulWidget {
  const _HostCustomerSummaryFilterTile({
    super.key,
    required this.value,
    required this.label,
    required this.selected,
    required this.compact,
    required this.onTap,
  });

  final String value;
  final String label;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  @override
  State<_HostCustomerSummaryFilterTile> createState() =>
      _HostCustomerSummaryFilterTileState();
}

class _HostCustomerSummaryFilterTileState
    extends State<_HostCustomerSummaryFilterTile> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final border = _focused
        ? CatchBorder.resolve(t, CatchBorderRole.focus)
        : widget.selected
        ? CatchBorder.resolve(t, CatchBorderRole.selected)
        : CatchBorder.interactive(t, CatchInteractiveBorderState.resting);
    final surface = CatchSurface(
      tone: CatchSurfaceTone.transparent,
      backgroundColor: widget.selected
          ? t.ink.withValues(alpha: CatchOpacity.controlOverlayHover)
          : null,
      radius: CatchRadius.md,
      padding: widget.compact
          ? CatchInsets.statChipContent
          : CatchInsets.cardContent,
      borderSpec: widget.compact && !_focused ? null : border,
      onTap: widget.onTap,
      onFocusChange: (focused) {
        if (_focused != focused) setState(() => _focused = focused);
      },
      child: widget.compact
          ? Center(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: widget.value,
                      style: CatchTextStyles.monoLabel(context, color: t.ink),
                    ),
                    TextSpan(
                      text: ' ${widget.label}',
                      style: CatchTextStyles.supporting(
                        context,
                        color: widget.selected ? t.ink : t.ink2,
                      ),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )
          : CatchStatColumn(
              value: widget.value,
              label: widget.label,
              monoValue: true,
            ),
    );
    return Semantics(
      button: true,
      selected: widget.selected,
      label: '${widget.label}, ${widget.value}',
      onTap: widget.onTap,
      child: ExcludeSemantics(
        child: widget.compact
            ? SizedBox(height: CatchSpacing.s12, child: surface)
            : surface,
      ),
    );
  }
}

String _customerFilterLabel(
  BuildContext context,
  HostCustomerFilter filter,
) => switch (filter) {
  HostCustomerFilter.all => context.l10n.hostsHostAudienceAll,
  HostCustomerFilter.newToOrganizer => context.l10n.hostsHostAudienceSegmentNew,
  HostCustomerFilter.attended => context.l10n.hostsHostAudienceAttended,
  HostCustomerFilter.firstTime =>
    context.l10n.hostsHostAudienceSegmentFirstTime,
  HostCustomerFilter.repeat => context.l10n.hostsHostAudienceSegmentRepeat,
  HostCustomerFilter.regular => context.l10n.hostsHostAudienceSegmentRegular,
  HostCustomerFilter.atRisk => context.l10n.hostCustomersFilterAtRisk,
  HostCustomerFilter.reliable => context.l10n.hostsHostAudienceSegmentReliable,
  HostCustomerFilter.needsConfirmation =>
    context.l10n.hostsHostAudienceSegmentNeedsConfirmation,
  HostCustomerFilter.advocate => context.l10n.hostsHostAudienceSegmentAdvocate,
  HostCustomerFilter.highImpactAdvocate =>
    context.l10n.hostsHostAudienceSegmentHighImpact,
  HostCustomerFilter.whatsappReachable =>
    context.l10n.hostsHostAudienceSegmentWhatsapp,
  HostCustomerFilter.smsReachable => context.l10n.hostsHostAudienceSegmentSms,
};

String _customerSortLabel(BuildContext context, HostCustomerSort sort) =>
    switch (sort) {
      HostCustomerSort.lastSeen => context.l10n.hostCustomersSortLastSeen,
      HostCustomerSort.mostAttended =>
        context.l10n.hostCustomersSortMostAttended,
      HostCustomerSort.name => context.l10n.hostCustomersSortName,
    };

String _customerFilterGroupLabel(
  BuildContext context,
  HostCustomerFilterGroup group,
) => switch (group) {
  HostCustomerFilterGroup.attendance =>
    context.l10n.hostCustomersFilterGroupAttendance,
  HostCustomerFilterGroup.reliability =>
    context.l10n.hostCustomersFilterGroupReliability,
  HostCustomerFilterGroup.advocacy =>
    context.l10n.hostCustomersFilterGroupAdvocacy,
  HostCustomerFilterGroup.reachable =>
    context.l10n.hostCustomersFilterGroupReachable,
};

String _customerPeopleCountLabel(
  BuildContext context,
  int count,
  HostCustomerMatchCountCoverage coverage,
) => switch (coverage) {
  HostCustomerMatchCountCoverage.exact => context.l10n.hostCustomersPeopleCount(
    count: count,
  ),
  HostCustomerMatchCountCoverage.atLeast =>
    context.l10n.hostCustomersPeopleCountAtLeast(count: count),
};
