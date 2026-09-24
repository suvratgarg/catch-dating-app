part of '../host_operations_screen.dart';

// The current updateOrganizer contract rejects progressive default fields.
// Show these controls only with the versioned defaults save command.
bool _progressiveEventDefaultsAvailable() => false;

/// Editor for a manager-authorized setup-preferences projection. No field is
/// read from the public Club document, and a null onChanged disables writes
/// until a revision-fenced manager settings command is available.
class HostManagerEventSetupPreferencesEditor extends StatelessWidget {
  const HostManagerEventSetupPreferencesEditor({
    super.key,
    required this.preferences,
    this.venueLabel,
    this.onChanged,
  });

  final ManagerEventSetupPreferences preferences;
  final String? venueLabel;
  final ValueChanged<ManagerEventSetupPreferences>? onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final copy = catchFieldCopy(l10n);
    final editable = onChanged != null;
    final inputMode = editable
        ? CatchTextInputMode.editable
        : CatchTextInputMode.inactive;
    const durationChoices = <int>[15, 30, 45, 60, 90, 120, 180, 240];
    const validityChoices = <int>[5, 15, 30, 60, 120, 1440, 2880, 10080];
    String minutes(int value) => l10n.hostsEventDefaultsMinutes(minutes: value);
    String collectionLabel(EventCollectionPreference value) => switch (value) {
      EventCollectionPreference.manualInstructions =>
        l10n.hostsEventDefaultsManualInstructions,
      EventCollectionPreference.reusablePage =>
        l10n.hostsEventDefaultsReusablePage,
      EventCollectionPreference.personalRequest =>
        l10n.hostsEventDefaultsPersonalRequest,
      EventCollectionPreference.catchCheckout =>
        l10n.hostsEventDefaultsCatchCheckout,
    };
    void update(ManagerEventSetupPreferences next) => onChanged?.call(next);

    return CatchSectionList(
      emptyStateOmitted: true,
      children: [
        CatchSection.fieldRows(
          first: true,
          title: l10n.hostsEventDefaultsBasics,
          children: [
            CatchField<int>.choices(
              copy: copy,
              title: l10n.hostsEventDefaultsUsualDuration,
              body: preferences.usualDurationMinutes == null
                  ? l10n.hostsEventDefaultsChooseEachEvent
                  : minutes(preferences.usualDurationMinutes!),
              values: durationChoices,
              itemLabelBuilder: minutes,
              selected: preferences.usualDurationMinutes == null
                  ? const <int>{}
                  : {preferences.usualDurationMinutes!},
              onSelectionChanged: editable
                  ? (selection) {
                      if (selection.isNotEmpty) {
                        update(preferences.copyWith(
                          usualDurationMinutes: selection.single,
                        ));
                      }
                    }
                  : null,
              icon: CatchIcons.scheduleOutlined,
            ),
            if (preferences.usualDurationMinutes != null)
              CatchField.action(
                copy: copy,
                title: l10n.hostsEventDefaultsClearDuration,
                body: l10n.hostsEventDefaultsChooseEachEvent,
                onTap: editable
                    ? () => update(preferences.copyWith(
                        usualDurationMinutes: null,
                      ))
                    : null,
              ),
            CatchField.read(
              copy: copy,
              title: l10n.hostsEventDefaultsPreferredVenue,
              body: preferences.preferredVenueId == null
                  ? l10n.hostsEventDefaultsVenueUnavailable
                  : venueLabel ?? l10n.hostsEventDefaultsVenueSaved,
              icon: CatchIcons.locationOnOutlined,
            ),
            if (preferences.preferredVenueId != null)
              CatchField.action(
                copy: copy,
                title: l10n.hostsEventDefaultsClearVenue,
                body: l10n.hostsEventDefaultsChooseEachEvent,
                onTap: editable
                    ? () => update(preferences.copyWith(preferredVenueId: null))
                    : null,
              ),
          ],
        ),
        CatchSection.fieldRows(
          title: l10n.hostsEventDefaultsOffersHeading,
          children: [
            CatchField<int>.choices(
              copy: copy,
              title: l10n.hostsEventDefaultsOfferValidity,
              body: preferences.offerValidityMinutes == null
                  ? l10n.hostsEventDefaultsChooseEachEvent
                  : minutes(preferences.offerValidityMinutes!),
              values: validityChoices,
              itemLabelBuilder: minutes,
              selected: preferences.offerValidityMinutes == null
                  ? const <int>{}
                  : {preferences.offerValidityMinutes!},
              onSelectionChanged: editable
                  ? (selection) {
                      if (selection.isNotEmpty) {
                        update(preferences.copyWith(
                          offerValidityMinutes: selection.single,
                        ));
                      }
                    }
                  : null,
              icon: CatchIcons.scheduleOutlined,
            ),
            if (preferences.offerValidityMinutes != null)
              CatchField.action(
                copy: copy,
                title: l10n.hostsEventDefaultsClearValidity,
                body: l10n.hostsEventDefaultsChooseEachEvent,
                onTap: editable
                    ? () => update(preferences.copyWith(
                        offerValidityMinutes: null,
                      ))
                    : null,
              ),
            CatchField.input(
              copy: copy,
              key: ValueKey('manager-offer-template-${preferences.offerMessageTemplate}'),
              title: l10n.hostsEventDefaultsMessageTemplate,
              contractExemption: 'Manager-only offer handoff text.',
              initialValue: preferences.offerMessageTemplate ?? '',
              inputHint: l10n.hostsEventDefaultsMessageTemplateHint,
              inputMode: inputMode,
              maxLines: 3,
              onSubmitted: editable
                  ? (value) => update(preferences.copyWith(
                      offerMessageTemplate: value.trim().isEmpty
                          ? null
                          : value.trim(),
                    ))
                  : null,
            ),
          ],
        ),
        CatchSection.fieldRows(
          title: l10n.hostsEventDefaultsPaymentHeading,
          children: [
            CatchField<EventCollectionPreference>.choices(
              copy: copy,
              title: l10n.hostsEventDefaultsCollectionPreference,
              body: preferences.collectionPreference == null
                  ? l10n.hostsEventDefaultsChooseEachEvent
                  : collectionLabel(preferences.collectionPreference!),
              values: EventCollectionPreference.values,
              itemLabelBuilder: collectionLabel,
              selected: preferences.collectionPreference == null
                  ? const <EventCollectionPreference>{}
                  : {preferences.collectionPreference!},
              onSelectionChanged: editable
                  ? (selection) {
                      if (selection.isNotEmpty) {
                        update(preferences.copyWith(
                          collectionPreference: selection.single,
                        ));
                      }
                    }
                  : null,
              helperText: l10n.hostsEventDefaultsCollectionSuggestionHint,
              icon: CatchIcons.paymentsOutlined,
            ),
            if (preferences.collectionPreference != null)
              CatchField.action(
                copy: copy,
                title: l10n.hostsEventDefaultsClearCollection,
                body: l10n.hostsEventDefaultsChooseEachEvent,
                onTap: editable
                    ? () => update(preferences.copyWith(
                        collectionPreference: null,
                      ))
                    : null,
              ),
            CatchField.input(
              copy: copy,
              key: ValueKey('manager-currency-${preferences.currency}'),
              title: l10n.hostsEventDefaultsCurrency,
              contractExemption: 'Manager-only currency suggestion.',
              initialValue: preferences.currency ?? '',
              inputHint: 'INR',
              inputMode: inputMode,
              maxLength: 3,
              textCapitalization: TextCapitalization.characters,
              onValidate: (value) => value == null || value.trim().isEmpty ||
                      RegExp(r'^[A-Z]{3}$').hasMatch(value.trim().toUpperCase())
                  ? null
                  : l10n.hostsEventDefaultsInvalidCurrency,
              onSubmitted: editable
                  ? (value) {
                      final normalized = value.trim().toUpperCase();
                      if (normalized.isNotEmpty &&
                          !RegExp(r'^[A-Z]{3}$').hasMatch(normalized)) return;
                      update(preferences.copyWith(
                        currency: normalized.isEmpty ? null : normalized,
                      ));
                    }
                  : null,
            ),
            CatchField.input(
              copy: copy,
              key: ValueKey('manager-payment-instructions-${preferences.paymentInstructions}'),
              title: l10n.hostsEventDefaultsPaymentInstructions,
              contractExemption: 'Manager-only external payment instructions.',
              initialValue: preferences.paymentInstructions ?? '',
              inputHint: l10n.hostsEventDefaultsPaymentInstructionsHint,
              inputMode: inputMode,
              maxLines: 3,
              onSubmitted: editable
                  ? (value) => update(preferences.copyWith(
                      paymentInstructions: value.trim().isEmpty
                          ? null
                          : value.trim(),
                    ))
                  : null,
            ),
            CatchField.input(
              copy: copy,
              key: ValueKey('manager-reusable-page-${preferences.reusablePaymentPage?.url}'),
              title: l10n.hostsEventDefaultsReusablePaymentPage,
              contractExemption: 'Only a reusable public organizer payment page.',
              initialValue: preferences.reusablePaymentPage?.url ?? '',
              inputHint: l10n.hostsEventDefaultsReusablePageHint,
              helperText: l10n.hostsEventDefaultsReusablePagePrivacyNote,
              inputMode: inputMode,
              keyboardType: TextInputType.url,
              onValidate: (value) {
                if (value == null || value.trim().isEmpty) return null;
                final uri = Uri.tryParse(value.trim());
                return uri != null && uri.scheme == 'https' && uri.host.isNotEmpty
                    ? null
                    : l10n.hostsEventDefaultsInvalidReusablePage;
              },
              onSubmitted: editable
                  ? (value) {
                      final trimmed = value.trim();
                      final uri = Uri.tryParse(trimmed);
                      if (trimmed.isNotEmpty &&
                          (uri == null || uri.scheme != 'https' || uri.host.isEmpty)) {
                        return;
                      }
                      update(preferences.copyWith(
                        reusablePaymentPage: trimmed.isEmpty
                            ? null
                            : ReusableOrganizerPaymentPage(trimmed),
                      ));
                    }
                  : null,
            ),
          ],
        ),
      ],
    );
  }
}

class HostClubEventDefaultsScreen extends StatelessWidget {
  const HostClubEventDefaultsScreen({
    super.key,
    required this.clubId,
    this.managerEventSetupPreferences,
    this.onManagerEventSetupPreferencesChanged,
  });

  final String clubId;
  /// Supplied only by a manager-authorized preferences read.
  final ManagerEventSetupPreferences? managerEventSetupPreferences;
  /// Supplied only after a revision-fenced manager settings writer exists.
  final ValueChanged<ManagerEventSetupPreferences>?
      onManagerEventSetupPreferencesChanged;

  @override
  Widget build(BuildContext context) {
    return HostClubSpokeResolver._(
      clubId: clubId,
      title: context.l10n.hostsHostClubEditTabLabelEventDefaults,
      builder: (context, club, _, isOwner) => isOwner
          ? HostClubDefaultsEditor._(
              club: club,
              builder: (context, defaults, apply, errorMessage, _) =>
                  CatchSectionList(
                    emptyStateOmitted: true,
                    children: [
                      if (_progressiveEventDefaultsAvailable())
                        CatchSection.fieldRows(
                        first: true,
                        title: context.l10n.hostsEventDefaultsBasics,
                        children: [
                          CatchField.read(
                            copy: catchFieldCopy(context.l10n),
                            title: context.l10n.hostsPrivateEventCity,
                            body: club.location,
                            icon: CatchIcons.locationOnOutlined,
                          ),
                          CatchField.input(
                            copy: catchFieldCopy(context.l10n),
                            key: ValueKey(
                              'host-event-default-timezone-${club.id}-${defaults.timezone}',
                            ),
                            title: context.l10n.hostsPrivateEventTimezone,
                            contractExemption:
                                'Organizer event timezone default awaits generated schema constraints.',
                            initialValue: defaults.timezone ?? '',
                            inputHint: context.l10n.hostsPrivateEventTimezoneHint,
                            onSubmitted: (value) => apply(
                              (current) => current.copyWith(
                                timezone: value.trim().isEmpty
                                    ? null
                                    : value.trim(),
                              ),
                            ),
                            helperText: context.l10n.hostsEventDefaultsTimezoneHint,
                            icon: CatchIcons.languageOutlined,
                          ),
                        ],
                      ),
                      ClubPolicyDefaultsCard(
                        defaults: defaults.eventPolicy,
                        currencyCode: currencyCodeForCityName(club.location),
                        activityKind: defaults.primaryActivityKind,
                        onActivityChanged: (activityKind) => apply(
                          (current) =>
                              _hostDefaultsWithActivity(current, activityKind),
                        ),
                        onChanged: (update) => apply(
                          (current) => current.copyWith(
                            eventPolicy: update(current.eventPolicy),
                          ),
                        ),
                      ),
                      if (_progressiveEventDefaultsAvailable())
                        if (managerEventSetupPreferences != null)
                          HostManagerEventSetupPreferencesEditor(
                            preferences: managerEventSetupPreferences!,
                            onChanged: onManagerEventSetupPreferencesChanged,
                          )
                        else
                          CatchSection.fieldRows(
                            title: context.l10n.hostsEventDefaultsPaymentHeading,
                            children: [
                              CatchField.read(
                                copy: catchFieldCopy(context.l10n),
                                title: context.l10n.hostsEventDefaultsManagerUnavailable,
                                body: context.l10n.hostsEventDefaultsManagerUnavailableBody,
                                icon: CatchIcons.lockOutline,
                              ),
                            ],
                          ),
                      if (errorMessage != null)
                        CatchFieldSupportRow(
                          text: errorMessage,
                          color: CatchTokens.of(context).danger,
                          showErrorIcon: true,
                        ),
                    ],
                  ),
            )
          : HostClubReadOnlyEventDefaults._(club: club),
    );
  }
}

class HostClubSpokeResolver extends ConsumerWidget {
  const HostClubSpokeResolver._({
    required this.clubId,
    required this.title,
    required this.builder,
  });

  final String clubId;
  final String title;
  final Widget Function(
    BuildContext context,
    Club club,
    String currentUid,
    bool isOwner,
  )
  builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uidAsync = ref.watch(uidProvider);
    final uidState = catchAsyncStateFromAsyncValue(uidAsync);
    if (uidState.hasError) {
      return CatchRouteScaffold(
        topBarBuilder: (context, scrolledUnder) => CatchTopBar.route(
          title: title,
          navigation: const CatchTopBarNavigation(
            mode: CatchTopBarNavigationMode.back,
          ),
          emphasis: scrolledUnder
              ? CatchTopBarEmphasis.divided
              : CatchTopBarEmphasis.plain,
        ),
        body: CatchRouteBody.standardViewport(
          child: CatchLocalizedErrorState(
            uidState.error!,
            context: AppErrorContext.auth,
            onRetry: () => ref.invalidate(uidProvider),
          ),
        ),
      );
    }
    if (uidState.isLoading) return HostLoadingScreen(title: title);
    final uid = uidState.value;
    if (uid == null) {
      return CatchRouteScaffold(
        topBarBuilder: (context, scrolledUnder) => CatchTopBar.route(
          title: title,
          navigation: const CatchTopBarNavigation(
            mode: CatchTopBarNavigationMode.back,
          ),
          emphasis: scrolledUnder
              ? CatchTopBarEmphasis.divided
              : CatchTopBarEmphasis.plain,
        ),
        body: CatchRouteBody.standardViewport(
          child: CatchErrorState(
            title: context.l10n.hostsHostAuthRequiredScreenTitleSignInRequired,
            message:
                context.l10n.hostsHostAuthRequiredScreenMessageSignInToManage,
            retryLabel:
                context.l10n.hostsHostAuthRequiredScreenVisiblecopySignIn,
            onRetry: () => context.go(Routes.authScreen.path),
          ),
        ),
      );
    }

    final clubsAsync = ref.watch(_hostClubsForUserProvider(uid));
    return CatchAsyncBoundary<List<Club>>(
      value: clubsAsync,
      onRetry: () => ref.invalidate(_hostClubsForUserProvider(uid)),
      loadingBuilder: (_) => HostLoadingScreen(title: title),
      errorBuilder: (_, error, _, onBoundaryRetry) => CatchRouteScaffold(
        topBarBuilder: (context, scrolledUnder) => CatchTopBar.route(
          title: title,
          navigation: const CatchTopBarNavigation(
            mode: CatchTopBarNavigationMode.back,
          ),
          emphasis: scrolledUnder
              ? CatchTopBarEmphasis.divided
              : CatchTopBarEmphasis.plain,
        ),
        body: CatchRouteBody.standardViewport(
          child: CatchLocalizedErrorState(
            error,
            context: AppErrorContext.club,
            onRetry: onBoundaryRetry,
          ),
        ),
      ),
      builder: (context, clubs) {
        final club = clubs.where((item) => item.id == clubId).firstOrNull;
        if (club == null) {
          return CatchRouteScaffold(
            topBarBuilder: (context, scrolledUnder) => CatchTopBar.route(
              title: title,
              navigation: const CatchTopBarNavigation(
                mode: CatchTopBarNavigationMode.back,
              ),
              emphasis: scrolledUnder
                  ? CatchTopBarEmphasis.divided
                  : CatchTopBarEmphasis.plain,
            ),
            body: CatchRouteBody.standardViewport(
              child: CatchLocalizedErrorState(
                StateError('Organizer unavailable'),
                context: AppErrorContext.club,
                onRetry: () => ref.invalidate(_hostClubsForUserProvider(uid)),
              ),
            ),
          );
        }
        return HostClubSpokeScaffold._(
          club: club,
          title: title,
          child: builder(context, club, uid, club.isOwnedBy(uid)),
        );
      },
    );
  }
}

class HostClubSpokeScaffold extends StatelessWidget {
  const HostClubSpokeScaffold._({
    required this.club,
    required this.title,
    required this.child,
  });

  final Club club;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CatchRouteScaffold(
      topBarBuilder: (context, scrolledUnder) => CatchTopBar.route(
        title: title,
        subtitle: club.name,
        navigation: const CatchTopBarNavigation(
          mode: CatchTopBarNavigationMode.back,
        ),
        emphasis: scrolledUnder
            ? CatchTopBarEmphasis.divided
            : CatchTopBarEmphasis.plain,
      ),
      body: CatchRouteBody.standardSections(
        sections: [CatchSectionListItem(child: child)],
      ),
    );
  }
}

class HostClubDefaultsEditor extends ConsumerStatefulWidget {
  const HostClubDefaultsEditor._({required this.club, required this.builder});

  final Club club;
  final Widget Function(
    BuildContext context,
    ClubHostDefaults defaults,
    ValueChanged<ClubHostDefaultsUpdate> apply,
    String? errorMessage,
    bool isSaving,
  )
  builder;

  @override
  ConsumerState<HostClubDefaultsEditor> createState() =>
      _HostClubDefaultsEditorState();
}

class _HostClubDefaultsEditorState
    extends ConsumerState<HostClubDefaultsEditor> {
  HostClubDefaultsSaver? _saver;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _saver ??= _createSaver();
  }

  HostClubDefaultsSaver _createSaver() {
    return HostClubDefaultsSaver(
      initial: widget.club.hostDefaults,
      writer: (defaults) => HostClubEditController.updateClubMutation.run(
        ref,
        (tx) => tx
            .get(hostClubEditControllerProvider)
            .updateClub(
              clubId: widget.club.id,
              patch: UpdateClubPatch(hostDefaults: defaults),
            ),
      ),
      errorMessageFor: (error) => appErrorMessage(
        error,
        l10n: context.l10n,
        context: AppErrorContext.club,
      ),
    )..addListener(_handleSaverChanged);
  }

  @override
  void didUpdateWidget(covariant HostClubDefaultsEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.club.id != widget.club.id) {
      _saver
        ?..removeListener(_handleSaverChanged)
        ..dispose();
      _saver = _createSaver();
    } else {
      _saver?.reconcile(widget.club.hostDefaults);
    }
  }

  @override
  void dispose() {
    _saver
      ?..removeListener(_handleSaverChanged)
      ..dispose();
    super.dispose();
  }

  void _handleSaverChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final saver = _saver!;
    return widget.builder(
      context,
      saver.optimistic,
      saver.apply,
      saver.errorMessage,
      saver.isSaving,
    );
  }
}

class HostClubReadOnlyEventDefaults extends StatelessWidget {
  const HostClubReadOnlyEventDefaults._({required this.club});

  final Club club;

  @override
  Widget build(BuildContext context) {
    final policy = club.hostDefaults.eventPolicy;
    return CatchSection.fieldRows(
      first: true,
      title: context.l10n.hostsHostClubEditTabLabelEventDefaults,
      children: [
        if (_progressiveEventDefaultsAvailable()) CatchField.read(
          copy: catchFieldCopy(context.l10n),
          title: context.l10n.hostsPrivateEventCity,
          body: club.location,
          icon: CatchIcons.locationOnOutlined,
        ),
        if (_progressiveEventDefaultsAvailable()) CatchField.read(
          copy: catchFieldCopy(context.l10n),
          title: context.l10n.hostsPrivateEventTimezone,
          body: club.hostDefaults.timezone ??
              context.l10n.hostsEventDefaultsChooseEachEvent,
          icon: CatchIcons.languageOutlined,
        ),
        CatchField.read(
          copy: catchFieldCopy(context.l10n),
          title: context.l10n.hostsHostClubProfileTitleDefaultActivity,
          valueText: club.hostDefaults.primaryActivityKind.label,
          icon: CatchIcons.eventOutlined,
        ),
        CatchField.read(
          copy: catchFieldCopy(context.l10n),
          title: context.l10n.hostsHostClubProfileTitleAdmission,
          body: _admissionDefaultDescription(
            policy.admissionPreset,
            context.l10n,
          ),
          valueText: _admissionDefaultLabel(
            policy.admissionPreset,
            context.l10n,
          ),
          icon: CatchIcons.eventSeatOutlined,
        ),
        CatchField.read(
          copy: catchFieldCopy(context.l10n),
          title: context.l10n.hostsHostClubProfileTitleAgeRange,
          valueText: context.l10n.hostsHostClubProfileVisiblecopyMinageMaxage(
            minAge: policy.minAge,
            maxAge: policy.maxAge,
          ),
          icon: CatchIcons.cakeOutlined,
        ),
        CatchField.read(
          copy: catchFieldCopy(context.l10n),
          title: context.l10n.hostsHostClubProfileTitleCancellationPolicy,
          body: policy.cancellationPolicy.attendeeSummary,
          valueText: policy.cancellationPolicy.title,
          icon: CatchIcons.eventBusyOutlined,
        ),
      ],
    );
  }
}
