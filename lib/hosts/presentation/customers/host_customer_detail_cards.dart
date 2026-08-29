part of 'host_customers_screen.dart';

typedef HostCustomerDetailsSaveCallback =
    Future<void> Function({
      required String displayName,
      String? phoneE164,
      String? email,
    });

class HostCustomerIdentityCard extends StatefulWidget {
  const HostCustomerIdentityCard({
    super.key,
    required this.customer,
    required this.onSave,
    this.initiallyEditing = false,
  });

  final HostAudienceContactDetail customer;
  final HostCustomerDetailsSaveCallback onSave;
  final bool initiallyEditing;

  @override
  State<HostCustomerIdentityCard> createState() =>
      _HostCustomerIdentityCardState();
}

class _HostCustomerIdentityCardState extends State<HostCustomerIdentityCard> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  late bool _editing;
  bool _saving = false;
  bool _hasOptimisticDetails = false;
  String _optimisticDisplayName = '';
  String? _optimisticPhoneE164;
  String? _optimisticEmail;

  @override
  void initState() {
    super.initState();
    _editing = widget.initiallyEditing;
    _resetDraft();
  }

  @override
  void didUpdateWidget(covariant HostCustomerIdentityCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final customerChanged =
        oldWidget.customer.contactId != widget.customer.contactId ||
        oldWidget.customer.revision != widget.customer.revision;
    if (customerChanged) {
      _hasOptimisticDetails = false;
      if (!_editing) _resetDraft();
    }
    if (!oldWidget.initiallyEditing && widget.initiallyEditing && !_editing) {
      _resetDraft();
      _editing = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String get _displayName => _hasOptimisticDetails
      ? _optimisticDisplayName
      : widget.customer.displayName;

  String get _editableDisplayName => _hasOptimisticDetails
      ? _optimisticDisplayName
      : widget.customer.displayNameOverride ??
            widget.customer.sourceDisplayName;

  String? get _phoneE164 =>
      _hasOptimisticDetails ? _optimisticPhoneE164 : widget.customer.phoneE164;

  String? get _email =>
      _hasOptimisticDetails ? _optimisticEmail : widget.customer.email;

  @override
  Widget build(BuildContext context) {
    final phoneTitle = widget.customer.isIdentityVerified
        ? context.l10n.hostsHostAudienceContactVerifiedPhone
        : context.l10n.hostCustomersPhone;
    final phonePlaceholder = widget.customer.contactDetailsEditable
        ? CatchField.defaultEmptyValueText(
            context,
            context.l10n.hostCustomersPhone,
          )
        : context.l10n.hostCustomersNotSaved;
    final emailPlaceholder = widget.customer.contactDetailsEditable
        ? CatchField.defaultEmptyValueText(
            context,
            context.l10n.hostCustomersEmail,
          )
        : context.l10n.hostCustomersNotSaved;
    return Form(
      key: _formKey,
      child: CatchSection.containedFieldRows(
        key: const ValueKey('host-customer-contact-details'),
        title: context.l10n.hostCustomersContactDetails,
        focused: _editing,
        trailing: _editing
            ? null
            : CatchButton(
                key: const ValueKey('host-customer-edit-details'),
                label: context.l10n.hostCustomersEditDetails,
                variant: CatchButtonVariant.ghost,
                size: CatchButtonSize.sm,
                onPressed: _beginEditing,
              ),
        footer: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.customer.contactDetailsEditable
                  ? context.l10n.hostCustomersUnverifiedContactDetails
                  : context.l10n.hostCustomersVerifiedDetailsManagedByCatch,
              style: CatchTextStyles.supporting(context),
            ),
            if (_editing) ...[
              gapH12,
              CatchFieldActionBar(
                loading: _saving,
                onCancel: _cancelEditing,
                onSubmit: () => unawaited(_saveDetails()),
              ),
            ],
          ],
        ),
        children: _editing
            ? [
                CatchField.input(
                  key: const ValueKey('host-customer-edit-name'),
                  title: context.l10n.hostsHostAudienceContactName,
                  contract: CatchContractConstraints
                      .mutateOrganizerContactCallablePayloadDisplayNameOverride,
                  controller: _nameController,
                  helperText: context.l10n.hostsHostAudienceContactNameHelp,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  autofocus: true,
                  enabled: !_saving,
                  validator: (value) => (value ?? '').trim().isEmpty
                      ? context.l10n.hostCustomersNameRequired
                      : null,
                ),
                if (widget.customer.contactDetailsEditable) ...[
                  CatchField.input(
                    key: const ValueKey('host-customer-edit-phone'),
                    title: context.l10n.hostCustomersPhone,
                    contract: CatchContractConstraints
                        .mutateOrganizerContactCallablePayloadPhoneE164,
                    controller: _phoneController,
                    isOptional: true,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    placeholder: '+919876543210',
                    helperText: context.l10n.hostCustomersPhoneHelp,
                    enabled: !_saving,
                    validator: (value) => _manualPhoneError(context, value),
                  ),
                  CatchField.input(
                    key: const ValueKey('host-customer-edit-email'),
                    title: context.l10n.hostCustomersEmail,
                    contract: CatchContractConstraints
                        .mutateOrganizerContactCallablePayloadEmail,
                    controller: _emailController,
                    isOptional: true,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    enabled: !_saving,
                    validator: (value) => _manualEmailError(context, value),
                    onSubmitted: (_) => unawaited(_saveDetails()),
                  ),
                ] else ...[
                  CatchField.read(
                    key: const ValueKey('host-customer-phone-field'),
                    title: phoneTitle,
                    body: _phoneE164,
                    placeholder: phonePlaceholder,
                  ),
                  CatchField.read(
                    key: const ValueKey('host-customer-email-field'),
                    title: context.l10n.hostsHostAudienceContactEmail,
                    body: _email,
                    placeholder: emailPlaceholder,
                  ),
                ],
              ]
            : [
                CatchField.read(
                  key: const ValueKey('host-customer-name-field'),
                  title: context.l10n.hostsHostAudienceContactName,
                  body: _displayName,
                ),
                CatchField.read(
                  key: const ValueKey('host-customer-phone-field'),
                  title: phoneTitle,
                  body: _phoneE164,
                  placeholder: phonePlaceholder,
                ),
                CatchField.read(
                  key: const ValueKey('host-customer-email-field'),
                  title: context.l10n.hostsHostAudienceContactEmail,
                  body: _email,
                  placeholder: emailPlaceholder,
                ),
              ],
      ),
    );
  }

  void _beginEditing() {
    _resetDraft();
    setState(() => _editing = true);
  }

  void _cancelEditing() {
    if (_saving) return;
    _resetDraft();
    setState(() => _editing = false);
  }

  void _resetDraft() {
    _nameController.text = _editableDisplayName;
    _phoneController.text = _phoneE164 ?? '';
    _emailController.text = _email ?? '';
  }

  bool _draftChanged({
    required String displayName,
    required String? phoneE164,
    required String? email,
  }) =>
      displayName != _editableDisplayName ||
      (widget.customer.contactDetailsEditable &&
          (phoneE164 != _phoneE164 || email != _email));

  Future<void> _saveDetails() async {
    if (_saving || !(_formKey.currentState?.validate() ?? false)) return;
    final displayName = _nameController.text.trim();
    final phoneE164 = _optionalManualPhone(_phoneController.text);
    final email = _optionalNormalizedEmail(_emailController.text);
    if (!_draftChanged(
      displayName: displayName,
      phoneE164: phoneE164,
      email: email,
    )) {
      _cancelEditing();
      return;
    }

    setState(() => _saving = true);
    try {
      await widget.onSave(
        displayName: displayName,
        phoneE164: phoneE164,
        email: email,
      );
      if (!mounted) return;
      setState(() {
        _hasOptimisticDetails = true;
        _optimisticDisplayName = displayName;
        _optimisticPhoneE164 = widget.customer.contactDetailsEditable
            ? phoneE164
            : widget.customer.phoneE164;
        _optimisticEmail = widget.customer.contactDetailsEditable
            ? email
            : widget.customer.email;
        _editing = false;
      });
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

class HostCustomerConversationCard extends StatelessWidget {
  const HostCustomerConversationCard({
    super.key,
    required this.customer,
    required this.communicationPlan,
    required this.communicationPlanLoading,
    required this.communicationPlanFailed,
    required this.loading,
    required this.onOpen,
    required this.onOpenWhatsapp,
    required this.onRetryCommunicationPlan,
    required this.onMessagingEnabledChanged,
    this.onReview,
  });

  final HostAudienceContactDetail customer;
  final HostCommunicationPlan? communicationPlan;
  final bool communicationPlanLoading;
  final bool communicationPlanFailed;
  final bool loading;
  final VoidCallback onOpen;
  final VoidCallback onOpenWhatsapp;
  final VoidCallback onRetryCommunicationPlan;
  final VoidCallback? onReview;
  final ValueChanged<bool>? onMessagingEnabledChanged;

  @override
  Widget build(BuildContext context) {
    final recipient = communicationPlan?.singleRecipient;
    final catchRoute = recipient?.route(HostCommunicationRouteId.catchChat);
    final handoffRoute = recipient?.route(
      HostCommunicationRouteId.personalWhatsappHandoff,
    );
    return CatchSection.containedFieldRows(
      key: const ValueKey('host-customer-messaging'),
      title: context.l10n.hostInboxTitle,
      children: [
        if (communicationPlanLoading)
          CatchField.read(
            key: const ValueKey('host-customer-message-plan-loading'),
            title: context.l10n.hostCustomersMessageOptions,
            body: context.l10n.hostCustomersMessageOptionsLoading,
            icon: CatchIcons.tabChats,
          )
        else if (communicationPlanFailed || recipient == null)
          CatchField.action(
            key: const ValueKey('host-customer-message-plan-retry'),
            title: context.l10n.hostCustomersMessageOptionsUnavailable,
            body: context.l10n.hostCustomersMessageOptionsRetry,
            icon: CatchIcons.refresh,
            onTap: onRetryCommunicationPlan,
          )
        else ...[
          _communicationRouteField(
            context,
            route: catchRoute!,
            key: const ValueKey('host-customer-new-conversation'),
            title: context.l10n.hostCustomersMessageInCatch,
            availableBody: context.l10n.hostCustomersMessageInCatchBody,
            icon: CatchIcons.tabChats,
            loading: loading,
            onTap: onOpen,
          ),
          _communicationRouteField(
            context,
            route: handoffRoute!,
            key: const ValueKey('host-customer-open-whatsapp'),
            title: context.l10n.hostCustomersMessageByHand,
            availableBody: context.l10n.hostCustomersWhatsappHandoffDisclosure,
            icon: CatchIcons.sendRounded,
            loading: false,
            onTap: onOpenWhatsapp,
          ),
        ],
        if (customer.ambiguousCandidateCount > 0 && onReview != null)
          CatchField.action(
            key: const ValueKey('host-customer-review-duplicates'),
            title: context.l10n.hostCustomersReviewDuplicates,
            icon: CatchIcons.peopleOutlineRounded,
            onTap: onReview,
          ),
        CatchField.toggle(
          key: const ValueKey('host-customer-organizer-messages'),
          title: context.l10n.hostCustomersOrganizerMessages,
          contract: CatchContractConstraints
              .mutateOrganizerContactCallablePayloadWhatsappAdminSuppressed,
          body: customer.whatsappAdminSuppressed
              ? context.l10n.hostsHostAudienceContactConsentPaused
              : context.l10n.hostsHostAudienceContactConsentActive,
          value: !customer.whatsappAdminSuppressed,
          onChanged: onMessagingEnabledChanged,
        ),
      ],
    );
  }
}

Widget _communicationRouteField(
  BuildContext context, {
  required HostCommunicationRouteOption route,
  required Key key,
  required String title,
  required String availableBody,
  required IconData icon,
  required bool loading,
  required VoidCallback onTap,
}) {
  if (!route.isAvailable) {
    return CatchField.read(
      key: key,
      title: title,
      body: _communicationRouteBlockerLabel(context, route.blocker),
      icon: icon,
    );
  }
  return CatchField.action(
    key: key,
    title: title,
    body: availableBody,
    icon: icon,
    onTap: loading ? null : onTap,
  );
}

String _communicationRouteBlockerLabel(
  BuildContext context,
  HostCommunicationRouteBlocker? blocker,
) => switch (blocker) {
  HostCommunicationRouteBlocker.catchAccountRequired =>
    context.l10n.hostCustomersConversationUnlinked,
  HostCommunicationRouteBlocker.identityAmbiguous =>
    context.l10n.hostCustomersConversationAmbiguous,
  HostCommunicationRouteBlocker.missingPhone =>
    context.l10n.hostCustomersWhatsappMissingPhone,
  HostCommunicationRouteBlocker.organizerSuppressed =>
    context.l10n.hostCustomersWhatsappOrganizerSuppressed,
  HostCommunicationRouteBlocker.contactOptedOut =>
    context.l10n.hostCustomersWhatsappContactOptedOut,
  HostCommunicationRouteBlocker.permissionRequired =>
    context.l10n.hostCustomersMessagePermissionRequired,
  HostCommunicationRouteBlocker.senderUnavailable =>
    context.l10n.hostCustomersMessageSenderUnavailable,
  HostCommunicationRouteBlocker.intentUnsupported ||
  null => context.l10n.hostCustomersMessageOptionsUnavailable,
};

class HostCustomerAttendanceCard extends StatelessWidget {
  const HostCustomerAttendanceCard({super.key, required this.customer});

  final HostAudienceContactDetail customer;

  @override
  Widget build(BuildContext context) {
    final traits = customer.traits;
    final attendanceRate = traits.attendanceRate == null
        ? '—'
        : '${(traits.attendanceRate! * 100).round()}%';
    return CatchSection.plain(
      title: context.l10n.hostCustomersDetailAttendance,
      child: Row(
        children: [
          Expanded(
            child: CatchStatColumn(
              value: '${traits.attendedEventCount}',
              label: context.l10n.hostsHostAudienceAttended,
              monoValue: true,
            ),
          ),
          Expanded(
            child: CatchStatColumn(
              value: '${traits.expectedEventCount}',
              label: context.l10n.hostCustomersExpected,
              monoValue: true,
            ),
          ),
          Expanded(
            child: CatchStatColumn(
              value: attendanceRate,
              label: context.l10n.hostCustomersAttendanceRate,
              monoValue: true,
            ),
          ),
        ],
      ),
    );
  }
}

class HostCustomerRevenueCard extends StatelessWidget {
  const HostCustomerRevenueCard({super.key, required this.revenue});

  final HostCustomerRevenue revenue;

  @override
  Widget build(BuildContext context) => CatchSection.plain(
    title: context.l10n.hostCustomersDetailRevenue,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (revenue.coverage == HostCustomerRevenueCoverage.unavailable)
          Text(
            context.l10n.hostCustomersDetailRevenueUnavailable,
            style: CatchTextStyles.supporting(context),
          )
        else if (revenue.amounts.isEmpty)
          Text(
            context.l10n.hostCustomersDetailNoRevenue,
            style: CatchTextStyles.supporting(context),
          )
        else
          CatchFieldLanes.divided(
            children: [
              for (final amount in revenue.amounts)
                CatchField.read(
                  title: NumberFormat.simpleCurrency(
                    name: amount.currency,
                  ).format(amount.amountMinor / 100),
                  body: [
                    context.l10n.hostCustomersDetailRevenueFacts(
                      count: amount.factCount,
                    ),
                    ...amount.sources.map(
                      (source) => _customerRevenueSourceSummary(
                        context,
                        source,
                        amount.currency,
                      ),
                    ),
                  ].join(' · '),
                  valueText: amount.currency,
                ),
            ],
          ),
        if (revenue.coverage == HostCustomerRevenueCoverage.partial) ...[
          gapH12,
          CatchNotice(
            notice: CatchNoticeData(
              id: 'host.customers.revenue.partial',
              title: context.l10n.hostsHostAudienceCoveragePartial,
              message: context.l10n.hostCustomersDetailRevenuePartial,
              tone: CatchNoticeTone.warning,
            ),
          ),
        ],
      ],
    ),
  );
}

class HostCustomerAttendanceHistory extends StatelessWidget {
  const HostCustomerAttendanceHistory({super.key, required this.customer});

  final HostAudienceContactDetail customer;

  @override
  Widget build(BuildContext context) {
    final events = customer.events;
    return CatchSection.plain(
      title: context.l10n.hostCustomersEventHistory,
      child: events.isEmpty
          ? Text(
              context.l10n.hostCustomersNoAttendance,
              style: CatchTextStyles.supporting(context),
            )
          : CatchFieldLanes.divided(
              children: [
                for (final event in events)
                  CatchField.nav(
                    title: event.displayName,
                    body: [
                      if (event.eventStartAt != null)
                        AppTimeFormatters.shortDate(event.eventStartAt!),
                      _customerEventOriginLabel(context, event.eventOrigin),
                      if (event.eventOrigin ==
                              HostCustomerEventOrigin.externalCompanion &&
                          event.eventProvider != null)
                        _customerEventProviderLabel(
                          context,
                          event.eventProvider!,
                        ),
                      for (final revenue in event.revenues)
                        _customerEventRevenueLabel(context, revenue),
                    ].join(' · '),
                    valueText: event.checkedIn
                        ? context.l10n.hostCustomersCheckedIn
                        : event.status,
                    onTap: () => context.pushNamed(
                      Routes.hostAppEventDetailScreen.name,
                      pathParameters: {
                        'clubId': customer.organizerId,
                        'eventId': event.eventId,
                      },
                    ),
                  ),
              ],
            ),
    );
  }
}

String _customerRevenueSourceLabel(
  BuildContext context,
  HostCustomerRevenueSource source,
) => switch (source) {
  HostCustomerRevenueSource.catchPayment =>
    context.l10n.hostCustomersRevenueSourceCatch,
  HostCustomerRevenueSource.providerOrder =>
    context.l10n.hostCustomersRevenueSourceProvider,
  HostCustomerRevenueSource.hostImport =>
    context.l10n.hostCustomersRevenueSourceImport,
  HostCustomerRevenueSource.hostEstimate =>
    context.l10n.hostCustomersRevenueSourceEstimate,
};

String _customerRevenueSourceSummary(
  BuildContext context,
  HostCustomerRevenueSourceAmount source,
  String currency,
) =>
    '${_customerRevenueSourceLabel(context, source.source)} '
    '${NumberFormat.simpleCurrency(name: currency).format(source.amountMinor / 100)}';

String _customerEventRevenueLabel(
  BuildContext context,
  HostCustomerEventRevenue revenue,
) => [
  NumberFormat.simpleCurrency(
    name: revenue.currency,
  ).format(revenue.amountMinor / 100),
  _customerRevenueSourceLabel(context, revenue.source),
  if (revenue.allocation == HostCustomerRevenueAllocation.sharedOrder)
    context.l10n.hostCustomersRevenueSharedOrder,
].join(' · ');

String _customerEventOriginLabel(
  BuildContext context,
  HostCustomerEventOrigin origin,
) => switch (origin) {
  HostCustomerEventOrigin.catchNative =>
    context.l10n.hostCustomersEventOriginCatch,
  HostCustomerEventOrigin.externalCompanion =>
    context.l10n.hostCustomersEventOriginExternal,
  HostCustomerEventOrigin.unknown =>
    context.l10n.hostCustomersEventOriginUnknown,
};

String _customerEventProviderLabel(
  BuildContext context,
  String provider,
) => switch (provider) {
  'luma' => context.l10n.hostsEventDetailsStepExternalProviderLuma,
  'eventbrite' => context.l10n.hostsEventDetailsStepExternalProviderEventbrite,
  'partiful' => context.l10n.hostsEventDetailsStepExternalProviderPartiful,
  'posh' => context.l10n.hostsEventDetailsStepExternalProviderPosh,
  'bookmyshow' => context.l10n.hostsEventDetailsStepExternalProviderBookMyShow,
  'district' => context.l10n.hostsEventDetailsStepExternalProviderDistrict,
  'sortmyscene' =>
    context.l10n.hostsEventDetailsStepExternalProviderSortMyScene,
  'airbnb' =>
    context.l10n.hostsEventDetailsStepExternalProviderAirbnbExperiences,
  _ => context.l10n.hostsEventDetailsStepExternalProviderOther,
};
