part of 'host_customers_screen.dart';

class HostAddCustomerSheet extends ConsumerStatefulWidget {
  const HostAddCustomerSheet({super.key, required this.organizerId});

  final String organizerId;

  @override
  ConsumerState<HostAddCustomerSheet> createState() =>
      _HostAddCustomerSheetState();
}

class _HostAddCustomerSheetState extends ConsumerState<HostAddCustomerSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _noteController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CatchBottomSheetScaffold(
    title: context.l10n.hostCustomersAddTitle,
    subtitle: context.l10n.hostCustomersAddHelp,
    keyboardSafe: true,
    child: SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: CatchFieldLanes.custom(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CatchField.input(
                key: const ValueKey('host-add-customer-name'),
                title: context.l10n.hostCustomersName,
                contract: CatchContractConstraints
                    .createOrganizerContactCallablePayloadDisplayName,
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                validator: (value) => (value ?? '').trim().isEmpty
                    ? context.l10n.hostCustomersNameRequired
                    : null,
              ),
              gapH12,
              CatchField.input(
                key: const ValueKey('host-add-customer-phone'),
                title: context.l10n.hostCustomersPhone,
                contract: CatchContractConstraints
                    .createOrganizerContactCallablePayloadPhoneE164,
                controller: _phoneController,
                isOptional: true,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.telephoneNumber],
                placeholder: '+919876543210',
                helperText: context.l10n.hostCustomersPhoneHelp,
                validator: (value) => _manualPhoneError(context, value),
              ),
              gapH12,
              CatchField.input(
                key: const ValueKey('host-add-customer-email'),
                title: context.l10n.hostCustomersEmail,
                contract: CatchContractConstraints
                    .createOrganizerContactCallablePayloadEmail,
                controller: _emailController,
                isOptional: true,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                validator: (value) => _manualEmailError(context, value),
              ),
              gapH12,
              CatchField.input(
                key: const ValueKey('host-add-customer-note'),
                title: context.l10n.hostCustomersInitialNote,
                contract: CatchContractConstraints
                    .createOrganizerContactCallablePayloadInitialNote,
                controller: _noteController,
                isOptional: true,
                minLines: 3,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => unawaited(_submit()),
              ),
              gapH16,
              CatchButton(
                key: const ValueKey('host-add-customer-submit'),
                label: context.l10n.hostCustomersAdd,
                isLoading: _saving,
                onPressed: _saving ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (_saving || !(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      final customer = await ref
          .read(hostCustomersControllerProvider)
          .createCustomer(
            organizerId: widget.organizerId,
            displayName: name,
            phoneE164: _optionalManualPhone(_phoneController.text),
            email: _optionalNormalizedEmail(_emailController.text),
            initialNote: _optionalTrimmed(_noteController.text),
          );
      if (mounted) Navigator.of(context).pop(customer);
    } on Object catch (error) {
      if (mounted) {
        showCatchErrorSnackBar(
          context,
          error,
          errorContext: AppErrorContext.club,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
