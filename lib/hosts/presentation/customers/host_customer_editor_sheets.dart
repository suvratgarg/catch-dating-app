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
