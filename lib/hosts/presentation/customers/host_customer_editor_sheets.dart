part of 'host_customers_screen.dart';

class HostSaveAudienceSheet extends ConsumerStatefulWidget {
  const HostSaveAudienceSheet({
    super.key,
    required this.organizerId,
    required this.suggestedName,
    required this.definition,
  });

  final String organizerId;
  final String suggestedName;
  final HostSavedAudienceDefinition definition;

  @override
  ConsumerState<HostSaveAudienceSheet> createState() =>
      _HostSaveAudienceSheetState();
}

class _HostSaveAudienceSheetState extends ConsumerState<HostSaveAudienceSheet> {
  late final TextEditingController _nameController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.suggestedName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CatchBottomSheetScaffold(
    title: context.l10n.hostSavedAudienceSaveTitle,
    subtitle: context.l10n.hostSavedAudienceSaveBody,
    keyboardSafe: true,
    child: CatchFieldLanes.custom(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CatchField.input(
            key: const ValueKey('host-saved-audience-name'),
            title: context.l10n.hostSavedAudienceName,
            contract: CatchContractConstraints
                .upsertOrganizerSavedAudienceCallablePayloadName,
            controller: _nameController,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => unawaited(_save()),
          ),
          gapH16,
          CatchButton(
            key: const ValueKey('host-saved-audience-save-and-message'),
            label: context.l10n.hostSavedAudienceSaveAndMessage,
            isLoading: _saving,
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    ),
  );

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (_saving || name.isEmpty) return;
    setState(() => _saving = true);
    try {
      final controller = ref.read(hostAudienceControllerProvider);
      final audience = await controller.saveAudience(
        organizerId: widget.organizerId,
        requestId: '${DateTime.now().microsecondsSinceEpoch}-customers',
        name: name,
        definition: widget.definition,
      );
      final preview = await controller.previewAudience(
        organizerId: widget.organizerId,
        audience: audience,
      );
      ref.invalidate(hostSavedAudiencesProvider(widget.organizerId));
      if (mounted) Navigator.of(context).pop(preview.audience);
    } on Object catch (error) {
      if (mounted) {
        showCatchErrorSnackBar(
          context,
          error,
          errorContext: AppErrorContext.customers,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class HostSavedAudiencesSheet extends ConsumerStatefulWidget {
  const HostSavedAudiencesSheet({super.key, required this.organizerId});

  final String organizerId;

  @override
  ConsumerState<HostSavedAudiencesSheet> createState() =>
      _HostSavedAudiencesSheetState();
}

class _HostSavedAudiencesSheetState
    extends ConsumerState<HostSavedAudiencesSheet> {
  final Map<String, HostSavedAudiencePreview> _previews = {};
  String? _busyAudienceId;

  @override
  Widget build(BuildContext context) {
    final audiences = ref.watch(hostSavedAudiencesProvider(widget.organizerId));
    return CatchBottomSheetScaffold(
      title: context.l10n.hostSavedAudiencesManage,
      subtitle: context.l10n.hostSavedAudiencesManageBody,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.65,
        ),
        child: CatchAsyncValueView<HostSavedAudiencePage>(
          value: audiences,
          onRetry: () =>
              ref.invalidate(hostSavedAudiencesProvider(widget.organizerId)),
          initialLoadTimeout: null,
          loadingBuilder: (_) => const CatchSkeletonRows(),
          errorBuilder: (_, error, _) => CatchErrorState.fromError(
            error,
            context: AppErrorContext.customers,
            mode: CatchErrorStateMode.compact,
            onRetry: () =>
                ref.invalidate(hostSavedAudiencesProvider(widget.organizerId)),
          ),
          builder: (context, page) => page.audiences.isEmpty
              ? CatchEmptyState(
                  icon: CatchIcons.groupsOutlined,
                  title: context.l10n.hostSavedAudiencesEmptyTitle,
                  message: context.l10n.hostSavedAudiencesEmptyBody,
                  layout: CatchEmptyStateLayout.inline,
                )
              : SingleChildScrollView(
                  child: CatchSectionList(
                    emptyStateOmitted: true,
                    children: [
                      for (final audience in page.audiences)
                        CatchSection.divided(
                          title: audience.name,
                          child: _HostSavedAudienceRow(
                            audience: audience,
                            preview: _previews[audience.audienceId],
                            busy: _busyAudienceId == audience.audienceId,
                            onPreview: () => _preview(audience),
                            onArchive: () => _archive(audience),
                          ),
                        ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _preview(HostSavedAudience audience) => _run(audience, () async {
    final preview = await ref
        .read(hostAudienceControllerProvider)
        .previewAudience(organizerId: widget.organizerId, audience: audience);
    _previews[audience.audienceId] = preview;
    ref.invalidate(hostSavedAudiencesProvider(widget.organizerId));
  });

  Future<void> _archive(HostSavedAudience audience) => _run(audience, () async {
    await ref
        .read(hostAudienceControllerProvider)
        .archiveAudience(organizerId: widget.organizerId, audience: audience);
    ref.invalidate(hostSavedAudiencesProvider(widget.organizerId));
  });

  Future<void> _run(
    HostSavedAudience audience,
    Future<void> Function() action,
  ) async {
    if (_busyAudienceId != null) return;
    setState(() => _busyAudienceId = audience.audienceId);
    try {
      await action();
    } on Object catch (error) {
      if (mounted) {
        showCatchErrorSnackBar(
          context,
          error,
          errorContext: AppErrorContext.customers,
        );
      }
    } finally {
      if (mounted) setState(() => _busyAudienceId = null);
    }
  }
}

class _HostSavedAudienceRow extends StatelessWidget {
  const _HostSavedAudienceRow({
    required this.audience,
    required this.preview,
    required this.busy,
    required this.onPreview,
    required this.onArchive,
  });

  final HostSavedAudience audience;
  final HostSavedAudiencePreview? preview;
  final bool busy;
  final VoidCallback onPreview;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) {
    final count = preview?.matchCount ?? audience.lastPreviewMatchCount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          count == null
              ? context.l10n.hostSavedAudienceNeverPreviewed
              : context.l10n.hostSavedAudienceExactCount(count: count),
          style: CatchTextStyles.supporting(
            context,
            color: CatchTokens.of(context).ink2,
          ),
        ),
        if (preview != null && preview!.sample.isNotEmpty) ...[
          gapH8,
          Text(
            preview!.sample.map((contact) => contact.displayName).join(' · '),
            style: CatchTextStyles.supporting(
              context,
              color: CatchTokens.of(context).ink2,
            ),
          ),
        ],
        gapH12,
        Wrap(
          spacing: CatchSpacing.s2,
          runSpacing: CatchSpacing.s2,
          children: [
            CatchButton(
              label: context.l10n.hostSavedAudiencePreview,
              variant: CatchButtonVariant.secondary,
              size: CatchButtonSize.sm,
              isLoading: busy,
              onPressed: busy ? null : onPreview,
            ),
            CatchButton(
              label: context.l10n.hostSavedAudienceArchive,
              variant: CatchButtonVariant.ghost,
              size: CatchButtonSize.sm,
              onPressed: busy ? null : onArchive,
            ),
          ],
        ),
      ],
    );
  }
}
