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
    return LayoutBuilder(
      builder: (context, constraints) => Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: CatchSpacing.s4,
        children: [
          CatchAdaptiveSelectionMenu<HostCustomerSort>(
            title: context.l10n.hostCustomersSort,
            subtitle: context.l10n.hostCustomersSortSheetSubtitle,
            value: sort,
            items: [
              for (final option in HostCustomerSort.values)
                CatchSelectionMenuItem(
                  value: option,
                  label: _customerSortLabel(context, option),
                ),
            ],
            onSelected: onSortChanged,
            builder: (context, selected, open, toggle) =>
                _HostCustomerDirectoryCommand(
                  key: const ValueKey('host-customers-sort'),
                  label: context.l10n.hostCustomersSortControl(
                    label: selected.label,
                  ),
                  icon: CatchIcons.expandMoreRounded,
                  maxWidth: constraints.maxWidth,
                  trailingIcon: true,
                  onTap: toggle,
                ),
          ),
          _HostCustomerDirectoryCommand(
            key: const ValueKey('host-customers-filters'),
            label: context.l10n.hostCustomersFilters,
            icon: CatchIcons.tuneRounded,
            maxWidth: constraints.maxWidth,
            onTap: onOpenFilters,
          ),
        ],
      ),
    );
  }
}

class _HostCustomerDirectoryCommand extends StatelessWidget {
  const _HostCustomerDirectoryCommand({
    super.key,
    required this.label,
    required this.icon,
    required this.maxWidth,
    required this.onTap,
    this.trailingIcon = false,
  });

  final String label;
  final IconData icon;
  final double maxWidth;
  final VoidCallback? onTap;
  final bool trailingIcon;

  @override
  Widget build(BuildContext context) => CatchRowPressSurface(
    onTap: onTap,
    expandToMaxWidth: false,
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
        minHeight: Theme.of(context).platform == TargetPlatform.iOS
            ? CatchSpacing.s11
            : CatchSpacing.s12,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: CatchSpacing.s2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!trailingIcon) ...[Icon(icon, size: CatchIcon.sm), gapW8],
            Flexible(
              child: Text(
                label,
                style: HostCustomerTypography.control(context),
              ),
            ),
            if (trailingIcon) ...[gapW8, Icon(icon, size: CatchIcon.sm)],
          ],
        ),
      ),
    ),
  );
}

class HostCustomersNoOrganizer extends StatelessWidget {
  const HostCustomersNoOrganizer({
    super.key,
    this.selected = HostAudienceView.people,
    this.onChanged,
  });

  final HostAudienceView selected;
  final ValueChanged<HostAudienceView>? onChanged;

  @override
  Widget build(BuildContext context) => HostAudienceStateScaffold(
    selected: selected,
    scrollKey: const PageStorageKey<String>('host-customers-no-organizer'),
    onChanged: onChanged,
    slivers: [
      CatchSliverEmptyState(
        icon: CatchIcons.groupsOutlined,
        title: context.l10n.hostsHostEventsScaffoldTitleCreateYourFirstClub,
        message: context.l10n.hostsHostEventsScaffoldBodyCreateAClubTo,
        action: CatchButton(
          label: context.l10n.hostsHostEventsScaffoldLabelCreateClub,
          onPressed: () => context.pushNamed(Routes.hostCreateClubScreen.name),
        ),
      ),
    ],
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
    this.newCustomerCount,
  });

  final AsyncValue<HostCrmSummary> summary;
  final VoidCallback onRetry;
  final HostCustomerFilter? selectedFilter;
  final ValueChanged<HostCustomerFilter> onFilterSelected;
  final HostCustomerSegmentCount? newCustomerCount;

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
      String countLabel(int count) => value.truncated ? '$count+' : '$count';
      final newCount = newCustomerCount;
      final stats = <({HostCustomerFilter filter, String label, String? value})>[
        (
          filter: HostCustomerFilter.all,
          value: countLabel(value.contactCount),
          label: context.l10n.hostsHostAudienceAll,
        ),
        (
          filter: HostCustomerFilter.repeat,
          value: countLabel(value.repeatAttendeeCount),
          label: context.l10n.hostsOperationalRosterInsightReturning,
        ),
        (
          filter: HostCustomerFilter.newToOrganizer,
          value: newCount == null
              ? null
              : '${newCount.count}${newCount.coverage == HostCustomerMatchCountCoverage.atLeast ? '+' : ''}',
          label: context.l10n.hostsHostEventManageScreenStateLabelNew,
        ),
      ];
      return Wrap(
        spacing: CatchSpacing.s2,
        runSpacing: CatchSpacing.s2,
        children: [
          for (final stat in stats)
            _HostCustomerSummaryFilterTile(
              key: ValueKey('host-customers-summary-${stat.filter.name}'),
              value: stat.value,
              label: stat.label,
              selected: selectedFilter == stat.filter,
              onTap: () => onFilterSelected(stat.filter),
            ),
        ],
      );
    },
  );
}

class _HostCustomerSummaryFilterTile extends StatelessWidget {
  const _HostCustomerSummaryFilterTile({
    super.key,
    required this.value,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String? value;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final text = value == null ? label : '$label  $value';
    return Semantics(
      button: true,
      selected: selected,
      label: text,
      child: ExcludeSemantics(
        child: CatchSurface(
          tone: CatchSurfaceTone.transparent,
          backgroundColor: selected
              ? t.ink
              : t.ink.withValues(alpha: CatchOpacity.controlOverlayHover),
          radius: CatchRadius.pill,
          padding: EdgeInsets.symmetric(
            horizontal: CatchSpacing.s4,
            vertical: Theme.of(context).platform == TargetPlatform.iOS
                ? CatchSpacing.s3
                : CatchSpacing.micro14,
          ),
          onTap: onTap,
          child: Text(
            text,
            style: HostCustomerTypography.group(context, selected: selected),
          ),
        ),
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
