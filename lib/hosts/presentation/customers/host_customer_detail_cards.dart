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
    this.showName = true,
    this.primaryAction,
  });

  final HostAudienceContactDetail customer;
  final HostCustomerDetailsSaveCallback onSave;
  final bool initiallyEditing;
  final bool showName;
  final Widget? primaryAction;

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
  String? _contactMethodError;

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
      _contactMethodError = null;
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
      child: _editing
          ? HostCustomerIdentityInputSection(
              key: const ValueKey('host-customer-contact-details'),
              title: context.l10n.hostCustomersContactDetails,
              mode: HostCustomerIdentityInputMode.edit,
              nameController: _nameController,
              phoneController: _phoneController,
              emailController: _emailController,
              enabled: !_saving,
              autofocusName: true,
              includeEndpoints: widget.customer.contactDetailsEditable,
              focused: true,
              readPhoneTitle: phoneTitle,
              readPhone: _phoneE164,
              readPhonePlaceholder: phonePlaceholder,
              readEmail: _email,
              readEmailPlaceholder: emailPlaceholder,
              onContactMethodChanged: _clearContactMethodError,
              onSubmitted: () => unawaited(_saveDetails()),
              footer: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.customer.contactDetailsEditable
                        ? context.l10n.hostCustomersUnverifiedContactDetails
                        : context
                              .l10n
                              .hostCustomersVerifiedDetailsManagedByCatch,
                    style: CatchTextStyles.supporting(context),
                  ),
                  gapH12,
                  if (_contactMethodError != null) ...[
                    CatchErrorBanner(message: _contactMethodError!),
                    gapH12,
                  ],
                  CatchFieldActionBar(
                    loading: _saving,
                    onCancel: _cancelEditing,
                    onSubmit: () => unawaited(_saveDetails()),
                  ),
                ],
              ),
            )
          : CatchSection.plain(
              key: const ValueKey('host-customer-contact-details'),
              child: _HostCustomerIdentitySummary(
                customer: widget.customer,
                displayName: _displayName,
                phoneE164: _phoneE164,
                phonePlaceholder: phonePlaceholder,
                email: _email,
                emailPlaceholder: emailPlaceholder,
                onEdit: _beginEditing,
                primaryAction: widget.primaryAction,
                showName: widget.showName,
              ),
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
    _contactMethodError = null;
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
    final hadContactMethod = _phoneE164 != null || _email != null;
    if (widget.customer.contactDetailsEditable &&
        hadContactMethod &&
        phoneE164 == null &&
        email == null) {
      setState(
        () => _contactMethodError =
            context.l10n.hostCustomersContactMethodRequired,
      );
      return;
    }
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
        _contactMethodError = null;
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

  void _clearContactMethodError() {
    if (_contactMethodError == null) return;
    setState(() => _contactMethodError = null);
  }
}

class _HostCustomerIdentitySummary extends StatelessWidget {
  const _HostCustomerIdentitySummary({
    required this.customer,
    required this.displayName,
    required this.phoneE164,
    required this.phonePlaceholder,
    required this.email,
    required this.emailPlaceholder,
    required this.onEdit,
    required this.showName,
    this.primaryAction,
  });

  final HostAudienceContactDetail customer;
  final String displayName;
  final String? phoneE164;
  final String phonePlaceholder;
  final String? email;
  final String emailPlaceholder;
  final VoidCallback onEdit;
  final bool showName;
  final Widget? primaryAction;

  @override
  Widget build(BuildContext context) {
    final usesLargeText = MediaQuery.textScalerOf(context).scale(1) >= 1.5;
    final segment = _hostCustomerPrimarySegment(customer.traits.segments);
    final segmentLabel = segment == null
        ? null
        : segment == HostAudienceSegment.regular
        ? context.l10n.hostsOperationalRosterInsightRegular
        : _customerFilterLabel(
            context,
            hostCustomerFilterForAudienceSegment(segment),
          );
    final segmentColor = switch (segment) {
      HostAudienceSegment.lapsedRegular => HostCustomerPalette.atRisk(context),
      HostAudienceSegment.regular => HostCustomerPalette.regular(context),
      HostAudienceSegment.newToOrganizer => HostCustomerPalette.newCustomer(
        context,
      ),
      _ => CatchTokens.of(context).ink2,
    };
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showName) ...[
          Text(displayName, style: HostCustomerTypography.name(context)),
          gapH4,
        ],
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: CatchSpacing.s2,
          children: [
            if (segmentLabel != null)
              Align(
                widthFactor: 1,
                alignment: AlignmentDirectional.centerStart,
                child: CatchSurface(
                  radius: CatchRadius.sm,
                  backgroundColor: segmentColor.withValues(
                    alpha: CatchOpacity.subtleFill,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: CatchSpacing.s2,
                    vertical: CatchSpacing.s1,
                  ),
                  child: Text(
                    segmentLabel,
                    style: HostCustomerTypography.status(
                      context,
                      color: segmentColor,
                    ),
                  ),
                ),
              ),
            CatchButton(
              key: const ValueKey('host-customer-edit-details'),
              label: context.l10n.hostCustomersEditDetails,
              variant: CatchButtonVariant.ghost,
              size: CatchButtonSize.sm,
              onPressed: onEdit,
            ),
            ?primaryAction,
          ],
        ),
        gapH4,
        Text(
          phoneE164 ?? phonePlaceholder,
          key: const ValueKey('host-customer-phone-summary'),
          style: HostCustomerTypography.body(context),
        ),
        gapH4,
        Text(
          email ?? emailPlaceholder,
          key: const ValueKey('host-customer-email-summary'),
          style: HostCustomerTypography.body(context),
        ),
      ],
    );
    if (usesLargeText) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatchPersonAvatar(size: CatchSpacing.s16, name: displayName),
          gapH16,
          details,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatchPersonAvatar(size: CatchSpacing.s16, name: displayName),
        gapW16,
        Expanded(child: details),
      ],
    );
  }
}

HostAudienceSegment? _hostCustomerPrimarySegment(
  Set<HostAudienceSegment> segments,
) {
  const priority = [
    HostAudienceSegment.highImpactAdvocate,
    HostAudienceSegment.lapsedRegular,
    HostAudienceSegment.needsConfirmation,
    HostAudienceSegment.regular,
    HostAudienceSegment.reliableAttendee,
    HostAudienceSegment.repeatAttendee,
    HostAudienceSegment.firstTimeAttendee,
    HostAudienceSegment.newToOrganizer,
    HostAudienceSegment.advocate,
    HostAudienceSegment.pastAttendee,
  ];
  for (final segment in priority) {
    if (segments.contains(segment)) {
      return segment;
    }
  }
  return null;
}

class HostCustomerAttendanceCard extends StatelessWidget {
  const HostCustomerAttendanceCard({super.key, required this.customer});

  final HostAudienceContactDetail customer;

  @override
  Widget build(BuildContext context) {
    final traits = customer.traits;
    final attendanceRate = traits.attendanceRate == null
        ? '—'
        : '${(traits.attendanceRate! * 100).round()}%';
    final metrics = [
      (
        value: '${traits.attendedEventCount}',
        label: context.l10n.hostsHostAudienceAttended,
      ),
      (
        value: '${traits.expectedEventCount}',
        label: context.l10n.hostCustomersExpected,
      ),
      (value: attendanceRate, label: context.l10n.hostCustomersAttendanceRate),
    ];
    Widget metric(({String value, String label}) item) => Column(
      children: [
        Text(item.value, style: HostCustomerTypography.metric(context)),
        gapH4,
        Text(
          item.label,
          style: HostCustomerTypography.secondary(context),
          textAlign: TextAlign.center,
        ),
      ],
    );
    final largeText = MediaQuery.textScalerOf(context).scale(1) >= 1.5;
    return CatchSection.plain(
      key: const ValueKey('host-customer-activity'),
      title: context.l10n.hostCustomersDetailAttendance,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: CatchSpacing.s2),
        child: largeText
            ? Column(
                children: [
                  for (final (index, item) in metrics.indexed) ...[
                    if (index > 0) ...[gapH12, const CatchDivider(), gapH12],
                    metric(item),
                  ],
                ],
              )
            : Row(
                children: [
                  for (final (index, item) in metrics.indexed) ...[
                    if (index > 0)
                      SizedBox(
                        width: CatchStroke.hairline,
                        height: CatchSpacing.s10,
                        child: ColoredBox(color: CatchTokens.of(context).line),
                      ),
                    Expanded(child: metric(item)),
                  ],
                ],
              ),
      ),
    );
  }
}

class HostCustomerRecentEvents extends StatelessWidget {
  const HostCustomerRecentEvents({
    super.key,
    required this.customer,
    required this.onOpenEvent,
  });

  final HostAudienceContactDetail customer;
  final ValueChanged<String> onOpenEvent;

  @override
  Widget build(BuildContext context) {
    final events =
        customer.events
            .where((event) => event.checkedIn || event.status == 'attended')
            .toList()
          ..sort(
            (a, b) => (b.eventStartAt ?? DateTime(0)).compareTo(
              a.eventStartAt ?? DateTime(0),
            ),
          );
    if (events.isEmpty) return const SizedBox.shrink();
    return CatchSection.divided(
      key: const ValueKey('host-customer-recent-events'),
      title: context.l10n.hostCustomersRecentEvents,
      first: true,
      children: [
        for (final event in events.take(3))
          CatchRowPressSurface(
            key: ValueKey('host-customer-recent-event-${event.eventId}'),
            onTap: () => onOpenEvent(event.eventId),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: CatchSpacing.s3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CatchSurface(
                    radius: CatchRadius.pill,
                    tone: CatchSurfaceTone.raised,
                    padding: const EdgeInsets.all(CatchSpacing.s2),
                    child: Icon(CatchIcons.tabEvents, size: CatchIcon.md),
                  ),
                  gapW12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          event.displayName,
                          style: HostCustomerTypography.name(context),
                        ),
                        gapH4,
                        if (event.eventStartAt != null)
                          Text(
                            AppTimeFormatters.dateTime(event.eventStartAt!),
                            style: HostCustomerTypography.secondary(context),
                          ),
                        gapH4,
                        Text(
                          context.l10n.hostsHostAudienceAttended,
                          style: HostCustomerTypography.context(context),
                        ),
                      ],
                    ),
                  ),
                  gapW8,
                  Icon(
                    CatchIcons.chevronRightRounded,
                    size: CatchIcon.sm,
                    color: CatchTokens.of(context).ink3,
                  ),
                ],
              ),
            ),
          ),
      ],
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
