part of '../host_operations_screen.dart';

class HostWhatsappSetupPane extends ConsumerStatefulWidget {
  const HostWhatsappSetupPane({
    super.key,
    required this.club,
    this.onBusyChanged,
  });

  final Club club;
  final ValueChanged<bool>? onBusyChanged;

  @override
  ConsumerState<HostWhatsappSetupPane> createState() =>
      _HostWhatsappSetupPaneState();
}

class _HostWhatsappSetupPaneState extends ConsumerState<HostWhatsappSetupPane> {
  final _testPhoneController = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _testPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messaging = ref.watch(hostMessagingSetupProvider(widget.club.id));
    return CatchSection.divided(
      title: context.l10n.hostsHostAudienceWhatsappSender,
      child: CatchAsyncValueView<HostMessagingSetup>(
        value: messaging,
        onRetry: () =>
            ref.invalidate(hostMessagingSetupProvider(widget.club.id)),
        initialLoadTimeout: null,
        loadingBuilder: (_) => const CatchSkeletonRows(count: 2),
        errorBuilder: (_, error, _) => CatchErrorState.fromError(
          error,
          context: AppErrorContext.club,
          mode: CatchErrorStateMode.compact,
          onRetry: () =>
              ref.invalidate(hostMessagingSetupProvider(widget.club.id)),
        ),
        builder: (context, setup) {
          final connection = setup.connection;
          return CatchFieldLanes.custom(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.hostsHostAudienceWhatsappOwnedSender,
                  style: CatchTextStyles.supporting(
                    context,
                    color: CatchTokens.of(context).ink2,
                  ),
                ),
                gapH12,
                if (!setup.providerConfigured)
                  CatchNotice(
                    notice: CatchNoticeData(
                      id: 'host.audience.whatsapp.provider-unavailable',
                      title: context.l10n.hostsHostAudienceProviderUnavailable,
                      message:
                          context.l10n.hostsHostAudienceProviderUnavailableBody,
                      tone: CatchNoticeTone.warning,
                    ),
                  )
                else if (connection == null)
                  CatchButton(
                    label: context.l10n.hostsHostAudienceConnectWhatsapp,
                    onPressed: _busy ? null : () => _connectWhatsapp(setup),
                    isLoading: _busy,
                  )
                else ...[
                  CatchField.read(
                    title:
                        connection.verifiedName ??
                        context.l10n.hostsHostAudienceWhatsappSender,
                    body: connection.displayPhoneNumber,
                    valueText: _connectionStatusLabel(context, connection),
                  ),
                  CatchField.read(
                    title: context.l10n.hostsHostAudienceTemplates,
                    body: context.l10n.hostsHostAudienceApprovedTemplates(
                      count: setup.approvedTemplates.length,
                    ),
                    valueText: connection.templateSyncStatus,
                  ),
                  Wrap(
                    spacing: CatchSpacing.s2,
                    runSpacing: CatchSpacing.s2,
                    children: [
                      CatchButton(
                        label: context.l10n.hostsHostAudienceSyncTemplates,
                        variant: CatchButtonVariant.secondary,
                        size: CatchButtonSize.sm,
                        onPressed: _busy
                            ? null
                            : () => _syncTemplates(connection.connectionId),
                        isLoading: _busy,
                      ),
                      CatchButton(
                        label: context.l10n.hostsHostAudienceDisconnect,
                        variant: CatchButtonVariant.ghost,
                        size: CatchButtonSize.sm,
                        onPressed: _busy
                            ? null
                            : () =>
                                  _disconnectWhatsapp(connection.connectionId),
                      ),
                    ],
                  ),
                  if (!connection.isActive &&
                      setup.approvedTemplates.isNotEmpty) ...[
                    gapH16,
                    CatchField.input(
                      title: context.l10n.hostsHostAudienceTestPhone,
                      contract: CatchContractConstraints
                          .sendOrganizerWhatsappTestCallablePayloadToE164,
                      controller: _testPhoneController,
                      keyboardType: TextInputType.phone,
                      placeholder: '+919876543210',
                      helperText: context.l10n.hostsHostAudienceTestPhoneHelp,
                    ),
                    gapH8,
                    CatchButton(
                      label: context.l10n.hostsHostAudienceSendTest,
                      onPressed: _busy
                          ? null
                          : () =>
                                _sendTest(setup, setup.approvedTemplates.first),
                      isLoading: _busy,
                    ),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _connectWhatsapp(HostMessagingSetup setup) async {
    await _run(() async {
      if (!hostWhatsappEmbeddedSignupSupported) {
        final openFailedMessage =
            context.l10n.hostsHostAudienceWebSignupOpenFailed;
        final opened = await ref
            .read(externalLinkControllerProvider)
            .openHostMessagingSetup(widget.club.id);
        if (!opened) {
          throw ExternalActionException(openFailedMessage);
        }
        if (mounted) {
          showCatchSnackBar(
            context,
            context.l10n.hostsHostAudienceWebSignupOpened,
          );
        }
        return;
      }
      final result = await startHostWhatsappEmbeddedSignup(
        setup.embeddedSignup,
      );
      await ref
          .read(hostAudienceControllerProvider)
          .completeWhatsappConnection(
            organizerId: widget.club.id,
            result: result,
          );
      ref.invalidate(hostMessagingSetupProvider(widget.club.id));
    });
  }

  Future<void> _syncTemplates(String connectionId) => _run(() async {
    await ref
        .read(hostAudienceControllerProvider)
        .syncWhatsappTemplates(
          organizerId: widget.club.id,
          connectionId: connectionId,
        );
    ref.invalidate(hostMessagingSetupProvider(widget.club.id));
  });

  Future<void> _disconnectWhatsapp(String connectionId) => _run(() async {
    await ref
        .read(hostAudienceControllerProvider)
        .disconnectWhatsapp(
          organizerId: widget.club.id,
          connectionId: connectionId,
        );
    ref.invalidate(hostMessagingSetupProvider(widget.club.id));
  });

  Future<void> _sendTest(
    HostMessagingSetup setup,
    HostWhatsappTemplate template,
  ) => _run(() async {
    final connection = setup.connection!;
    final variables = {
      for (final variable in template.variableNames)
        variable: _isInviteVariable(variable)
            ? variable == 'invite_token'
                  ? 'catch-test'
                  : 'https://catchdates.com'
            : 'Catch test',
    };
    await ref
        .read(hostAudienceControllerProvider)
        .sendWhatsappTest(
          organizerId: widget.club.id,
          connectionId: connection.connectionId,
          templateId: template.templateId,
          toE164: _testPhoneController.text.trim(),
          templateVariables: variables,
        );
    ref.invalidate(hostMessagingSetupProvider(widget.club.id));
    if (mounted) {
      showCatchSnackBar(context, context.l10n.hostsHostAudienceTestPending);
    }
  });

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    widget.onBusyChanged?.call(true);
    try {
      await action();
    } on Object catch (error) {
      if (mounted) {
        showCatchErrorSnackBar(
          context,
          error,
          errorContext: AppErrorContext.club,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
      widget.onBusyChanged?.call(false);
    }
  }
}

bool _isInviteVariable(String name) =>
    name == 'invite_url' || name == 'invite_token';

String _connectionStatusLabel(
  BuildContext context,
  HostWhatsappConnection connection,
) => switch (connection.status) {
  'active' => context.l10n.hostsHostAudienceSenderActive,
  'testing' => context.l10n.hostsHostAudienceSenderTesting,
  'degraded' => context.l10n.hostsHostAudienceSenderDegraded,
  'blocked' ||
  'tokenRevoked' => context.l10n.hostsHostAudienceSenderNeedsAttention,
  _ => connection.status,
};
