part of 'host_customers_screen.dart';

enum HostCustomerIdentityInputMode { create, edit }

class HostAddCustomerScreen extends ConsumerStatefulWidget {
  const HostAddCustomerScreen({super.key, required this.organizerId});

  final String organizerId;

  @override
  ConsumerState<HostAddCustomerScreen> createState() =>
      _HostAddCustomerScreenState();
}

class _HostAddCustomerScreenState extends ConsumerState<HostAddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _noteFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _noteController = TextEditingController();
  bool _saving = false;
  String? _contactMethodError;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_saving,
    child: CatchRouteScaffold(
      resizeToAvoidBottomInset: true,
      topBarBuilder: (context, scrolledUnder) => CatchScreenTopBar(
        context: context,
        title: context.l10n.hostCustomersAddTitle,
        leadingType: CatchTopBarLeading.back,
        divider: scrolledUnder,
      ),
      bottomNavigationBar: CatchBottomAction(
        label: context.l10n.hostCustomersAdd,
        buttonKey: const ValueKey('host-add-customer-submit'),
        isLoading: _saving,
        onPressed: _saving ? null : _submit,
      ),
      body: CatchRouteBody.standard(
        child: Form(
          key: _formKey,
          child: CatchResponsiveSectionLayout(
            sections: [
              CatchResponsiveSectionItem(
                child: HostCustomerIdentityInputSection(
                  key: const ValueKey('host-add-customer-details'),
                  title: context.l10n.hostCustomersContactDetails,
                  mode: HostCustomerIdentityInputMode.create,
                  nameController: _nameController,
                  phoneController: _phoneController,
                  emailController: _emailController,
                  enabled: !_saving,
                  onContactMethodChanged: _clearContactMethodError,
                  onSubmitted: () => unawaited(_submit()),
                  footer: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        context.l10n.hostAudienceAddedContactPermission,
                        style: CatchTextStyles.supporting(context),
                      ),
                      if (_contactMethodError != null) ...[
                        gapH12,
                        CatchErrorBanner(message: _contactMethodError!),
                      ],
                    ],
                  ),
                ),
              ),
              CatchResponsiveSectionItem(
                child: CatchFieldLanes.single(
                  child: CatchField.control(
                    key: const ValueKey('host-add-customer-memory'),
                    title: context.l10n.hostCustomersInitialNote,
                    contractExemption:
                        'Disclosure for the nested initial-note input, which uses the generated create-contact binding.',
                    isOptional: true,
                    control: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          context.l10n.hostCustomersInitialNoteHelp,
                          style: CatchTextStyles.supporting(context),
                        ),
                        gapH12,
                        Form(
                          key: _noteFormKey,
                          child: CatchField.input(
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
                            enabled: !_saving,
                            onSubmitted: (_) => unawaited(_submit()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  void _clearContactMethodError() {
    if (_contactMethodError == null) return;
    setState(() => _contactMethodError = null);
  }

  Future<void> _submit() async {
    if (_saving) return;
    final formValid = _formKey.currentState?.validate() ?? false;
    final initialNote = _optionalTrimmed(_noteController.text);
    // The optional payload key is required only when a note is supplied.
    final noteValid =
        initialNote == null || (_noteFormKey.currentState?.validate() ?? true);
    final name = _nameController.text.trim();
    final phoneE164 = _optionalManualPhone(_phoneController.text);
    final email = _optionalNormalizedEmail(_emailController.text);
    if (phoneE164 == null && email == null) {
      setState(
        () => _contactMethodError =
            context.l10n.hostCustomersContactMethodRequired,
      );
    }
    if (!formValid || !noteValid || phoneE164 == null && email == null) return;

    setState(() {
      _saving = true;
      _contactMethodError = null;
    });
    try {
      final customer = await ref
          .read(hostCustomersControllerProvider)
          .createCustomer(
            organizerId: widget.organizerId,
            displayName: name,
            phoneE164: phoneE164,
            email: email,
            initialNote: initialNote,
          );
      if (mounted) context.pop(customer);
    } on Object catch (error) {
      if (mounted) {
        showCatchErrorSnackBar(
          context,
          error,
          errorContext: AppErrorContext.customer,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class HostCustomerIdentityInputSection extends StatelessWidget {
  const HostCustomerIdentityInputSection({
    super.key,
    required this.title,
    required this.mode,
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.enabled,
    required this.onContactMethodChanged,
    required this.onSubmitted,
    required this.footer,
    this.autofocusName = false,
    this.includeEndpoints = true,
    this.focused = false,
    this.readPhoneTitle,
    this.readPhone,
    this.readPhonePlaceholder,
    this.readEmail,
    this.readEmailPlaceholder,
  });

  final String title;
  final HostCustomerIdentityInputMode mode;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final bool enabled;
  final VoidCallback onContactMethodChanged;
  final VoidCallback onSubmitted;
  final Widget footer;
  final bool autofocusName;
  final bool includeEndpoints;
  final bool focused;
  final String? readPhoneTitle;
  final String? readPhone;
  final String? readPhonePlaceholder;
  final String? readEmail;
  final String? readEmailPlaceholder;

  @override
  Widget build(BuildContext context) {
    final create = mode == HostCustomerIdentityInputMode.create;
    final fields = <Widget>[
      CatchFieldLanes.single(
        child: CatchField.input(
          key: ValueKey(
            create ? 'host-add-customer-name' : 'host-customer-edit-name',
          ),
          title: context.l10n.hostCustomersName,
          contract: create
              ? CatchContractConstraints
                    .createOrganizerContactCallablePayloadDisplayName
              : CatchContractConstraints
                    .mutateOrganizerContactCallablePayloadDisplayNameOverride,
          controller: nameController,
          helperText: create
              ? null
              : context.l10n.hostsHostAudienceContactNameHelp,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.name],
          autofocus: autofocusName,
          enabled: enabled,
          validator: (value) => (value ?? '').trim().isEmpty
              ? context.l10n.hostCustomersNameRequired
              : null,
        ),
      ),
      if (includeEndpoints) ...[
        CatchFieldLanes.single(
          child: CatchField.input(
            key: ValueKey(
              create ? 'host-add-customer-phone' : 'host-customer-edit-phone',
            ),
            title: context.l10n.hostCustomersPhone,
            contract: create
                ? CatchContractConstraints
                      .createOrganizerContactCallablePayloadPhoneE164
                : CatchContractConstraints
                      .mutateOrganizerContactCallablePayloadPhoneE164,
            controller: phoneController,
            isOptional: true,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.telephoneNumber],
            placeholder: '+919876543210',
            helperText: create ? null : context.l10n.hostCustomersPhoneHelp,
            enabled: enabled,
            validator: (value) => _manualPhoneError(context, value),
            onChanged: (_) => onContactMethodChanged(),
          ),
        ),
        CatchFieldLanes.single(
          child: CatchField.input(
            key: ValueKey(
              create ? 'host-add-customer-email' : 'host-customer-edit-email',
            ),
            title: context.l10n.hostCustomersEmail,
            contract: create
                ? CatchContractConstraints
                      .createOrganizerContactCallablePayloadEmail
                : CatchContractConstraints
                      .mutateOrganizerContactCallablePayloadEmail,
            controller: emailController,
            isOptional: true,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            enabled: enabled,
            validator: (value) => _manualEmailError(context, value),
            onChanged: (_) => onContactMethodChanged(),
            onSubmitted: (_) => onSubmitted(),
          ),
        ),
      ] else ...[
        CatchFieldLanes.single(
          child: CatchField.read(
            key: const ValueKey('host-customer-phone-field'),
            title: readPhoneTitle ?? context.l10n.hostCustomersPhone,
            body: readPhone,
            placeholder: readPhonePlaceholder,
          ),
        ),
        CatchFieldLanes.single(
          child: CatchField.read(
            key: const ValueKey('host-customer-email-field'),
            title: context.l10n.hostsHostAudienceContactEmail,
            body: readEmail,
            placeholder: readEmailPlaceholder,
          ),
        ),
      ],
    ];
    if (create) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          fields.first,
          gapH24,
          CatchSection.plain(
            title: context.l10n.hostAudienceContactMethod,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.l10n.hostAudienceContactRequirement,
                  style: CatchTextStyles.supporting(context),
                ),
                gapH16,
                CatchSection.fieldRows(children: fields.skip(1).toList()),
                gapH16,
                footer,
              ],
            ),
          ),
        ],
      );
    }
    return CatchSection.containedFieldRows(
      title: title,
      focused: focused,
      footer: footer,
      children: fields,
    );
  }
}

String? _optionalTrimmed(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String? _optionalManualPhone(String value) {
  final trimmed = _optionalTrimmed(value);
  return trimmed?.replaceAll(RegExp(r'[()\s-]+'), '');
}

String? _optionalNormalizedEmail(String value) =>
    _optionalTrimmed(value)?.toLowerCase();

String? _manualPhoneError(BuildContext context, String? value) {
  final phone = _optionalManualPhone(value ?? '');
  if (phone == null) return null;
  return RegExp(r'^\+[1-9][0-9]{7,14}$').hasMatch(phone)
      ? null
      : context.l10n.hostCustomersPhoneInvalid;
}

String? _manualEmailError(BuildContext context, String? value) {
  final email = _optionalNormalizedEmail(value ?? '');
  if (email == null) return null;
  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)
      ? null
      : context.l10n.hostCustomersEmailInvalid;
}
