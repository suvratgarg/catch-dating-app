part of 'private_event_create_screen.dart';

typedef CreatePrivateEvent =
    Future<PrivateEventCreateReceipt> Function({
      required String organizerId,
      required String requestId,
      required PrivateEventBasics basics,
    });

typedef UpdatePrivateEventBasics =
    Future<PrivateEventCreateReceipt> Function(
      PrivateEventBasicsUpdateRequest request,
    );

typedef ReadPrivateEventBasics =
    Future<PrivateEventBasicSummary> Function({
      required String organizerId,
      required String eventId,
    });

extension _PrivateEventCreateBody on _PrivateEventCreateScreenState {
  Widget _buildPrivateEventCreateBody(BuildContext context) {
    final t = CatchTokens.of(context);
    final receipt = _receipt;
    if (_loadingSavedEvent) {
      return const HostCreateEventRouteLoadingScreen();
    }
    if (_readError != null) {
      return CatchScaffold.stepFlow(
        body: CatchErrorState(
          title: context.l10n.hostsHostCreateEventScreenTitleEventSetupUnavailable,
          message: _readError!,
          actions: const [CatchErrorBackButton()],
        ),
      );
    }
    if (receipt != null && !_editingSavedBasics) {
      return PrivateEventSetupScreen(
        club: widget.club,
        receipt: receipt,
        name: _nameController.text.trim(),
        date: _date!,
        start: _start!,
        cityLabel: _city?.label ?? _savedCityLabel ?? widget.club.location,
        pendingRosterFileName: widget.initialRosterImportPlan?.fileName,
        onEditBasics: _canEditSavedBasics
            ? () => setState(() => _editingSavedBasics = true)
            : null,
        onClose: _close,
      );
    }
    final fieldCopy = catchFieldCopy(context.l10n);
    final city = _city;
    final date = _date;
    final start = _start;
    final cityOptions = defaultCityOptions
        .where((option) => option.eventCreatable)
        .toList();

    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: CatchScaffold.stepFlow(
        backgroundColor: t.bg,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CatchStepHeader(
              title: receipt == null
                  ? context.l10n.hostsHostEventsListLabelNewEvent
                  : context.l10n.hostsPrivateEventEditBasics,
              subtitle: widget.club.name,
              stepLabelBuilder: catchStepHeaderLabelBuilder(context.l10n),
              compactStepLabelBuilder:
                  catchStepHeaderCompactLabelBuilder(context.l10n),
              onBack: _saving ? null : _close,
              leadingType: CatchTopBarNavigationMode.back,
            ),
            Expanded(
              child: AbsorbPointer(
                absorbing: _saving ||
                    (receipt == null
                        ? _submittedSignature != null
                        : _pendingUpdate != null),
                child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: CatchLayout.hostCreateEventFormLaneMaxWidth,
                  ),
                  child: ListView(
                    padding: CatchInsets.formStepBodyWithBottomActions,
                    children: [
                      if (_defaultsChanged) ...[
                        CatchBanner.error(
                            message: context.l10n.hostsPrivateEventDefaultsChanged,
                        ),
                        CatchButton(
                          label: context.l10n.hostsPrivateEventReviewDefaults,
                          onPressed: _reviewCurrentDefaults,
                          variant: CatchButtonVariant.secondary,
                        ),
                        gapH4,
                      ],
                      if (receipt == null && _submittedSignature != null) ...[
                        CatchBanner.error(
                          message: context.l10n.hostsPrivateEventPendingRequest,
                        ),
                        gapH4,
                      ],
                      if (_pendingUpdate != null) ...[
                        CatchBanner.error(
                          message: context.l10n.hostsPrivateEventPendingUpdate,
                        ),
                        gapH4,
                      ],
                      CatchSectionList(
                        emptyStateOmitted: true,
                        children: [
                          CatchSection.fieldRows(
                            first: true,
                            title: context.l10n.hostsPrivateEventBasicsHeading,
                            children: [
                              CatchField.input(
                                copy: fieldCopy,
                                key: const ValueKey('private-event-name'),
                                title: context
                                    .l10n.hostsEventDetailsStepTitleEventName,
                                contractExemption:
                                    'Private event first-save schema is owned by the event setup command.',
                                controller: _nameController,
                                inputHint: context
                                    .l10n.hostsEventDetailsStepPlaceholderEventName,
                                textCapitalization: TextCapitalization.words,
                                error: _showErrors &&
                                        _nameController.text.trim().isEmpty
                                    ? context.l10n
                                        .hostsEventDetailsStepVisiblecopyRequired
                                    : null,
                              ),
                              CatchField<CityOption>.control(
                                copy: fieldCopy,
                                key: const ValueKey('private-event-city'),
                                title: context.l10n.hostsPrivateEventCity,
                                contractExemption:
                                    'Private event city is validated by the event setup command.',
                                body: _cityInherited
                                    ? '${city?.label ?? widget.club.location} · ${context.l10n.hostsPrivateEventFromOrganizer}'
                                    : city?.label ?? _savedCityLabel ??
                                        context.l10n.hostsPrivateEventChooseCity,
                                disclosureMode: _cityAccordion.isExpanded('city')
                                    ? CatchFieldMode.controlledExpanded
                                    : CatchFieldMode.controlledCollapsed,
                                onOpenChanged: (open) {
                                  if (open) {
                                    _cityAccordion.toggle('city');
                                  } else {
                                    _cityAccordion.collapse();
                                  }
                                },
                                icon: CatchIcons.locationOnOutlined,
                                error: _showErrors && city == null &&
                                        _savedCity == null &&
                                        !_cityInherited
                                    ? context.l10n.hostsPrivateEventChooseCity
                                    : null,
                                child: CatchChoiceInput<CityOption>(
                                  values: cityOptions,
                                  itemLabelBuilder: (option) => option.label,
                                  selected: city == null
                                      ? const <CityOption>{}
                                      : {city},
                                  mode: CatchChipMode.single,
                                  autoClose: true,
                                  onChanged: (selection) {
                                    if (selection.isEmpty) return;
                                    final picked = selection.single;
                                    setState(() {
                                      _city = picked;
                                      _cityInherited = false;
                                      _timezoneController.text = picked.timeZone;
                                      _timezoneInherited = false;
                                    });
                                  },
                                ),
                              ),
                              if (!_cityInherited &&
                                  widget.club.locationCityId.isNotEmpty)
                                CatchField.action(
                                  copy: fieldCopy,
                                  title: context.l10n.hostsPrivateEventUseOrganizerCity,
                                  body: widget.club.location,
                                  onTap: _restoreOrganizerCity,
                                ),
                              CatchField.nav(
                                copy: fieldCopy,
                                key: const ValueKey('private-event-date'),
                                title: context.l10n.hostsWhenStepLabelDate,
                                body: date == null
                                    ? context
                                        .l10n.hostsWhenStepPlaceholderSelectADate
                                    : MaterialLocalizations.of(context)
                                        .formatMediumDate(date),
                                icon: CatchIcons.calendarTodayOutlined,
                                error: _showErrors && date == null
                                    ? context.l10n
                                        .hostsWhenStepVisiblecopyPleaseSelectADate
                                    : null,
                                onTap: _saving ? null : _pickDate,
                              ),
                              CatchField.nav(
                                copy: fieldCopy,
                                key: const ValueKey('private-event-start'),
                                title: context.l10n.hostsWhenStepLabelStartTime,
                                body: start == null
                                    ? context.l10n
                                        .hostsWhenStepPlaceholderSelectStartTime
                                    : start.format(context),
                                icon: CatchIcons.scheduleOutlined,
                                error: _showErrors && start == null
                                    ? context.l10n.hostsWhenStepVisiblecopyRequired
                                    : null,
                                onTap: _saving ? null : _pickStart,
                              ),
                              CatchField.input(
                                copy: fieldCopy,
                                key: const ValueKey('private-event-timezone'),
                                title: context.l10n.hostsPrivateEventTimezone,
                                contractExemption:
                                    'Private event IANA timezone schema is pending generated constraints.',
                                controller: _timezoneController,
                                inputHint: context.l10n.hostsPrivateEventTimezoneHint,
                                helperText: context.l10n.hostsPrivateEventTimezoneSuggestion,
                                onChanged: (_) {
                                  if (_timezoneInherited) {
                                    setState(() => _timezoneInherited = false);
                                  }
                                },
                                error: _showErrors &&
                                        _timezoneController.text.trim().isEmpty &&
                                        !_timezoneInherited
                                    ? context.l10n
                                        .hostsWhenStepVisiblecopyRequired
                                    : null,
                              ),
                              if (_timezoneInherited)
                                CatchField.read(
                                  copy: fieldCopy,
                                  title: context.l10n.hostsPrivateEventFromOrganizer,
                                  body: widget.club.hostDefaults.timezone,
                                )
                              else if (widget.club.hostDefaults.timezone != null)
                                CatchField.action(
                                  copy: fieldCopy,
                                  title: context.l10n.hostsPrivateEventUseOrganizerTimezone,
                                  body: widget.club.hostDefaults.timezone,
                                  onTap: _restoreOrganizerTimezone,
                                ),
                              CatchField.nav(
                                copy: fieldCopy,
                                title: context.l10n.hostsPrivateEventMoreBasics,
                                body: context.l10n.hostsPrivateEventMoreBasicsBody,
                                icon: CatchIcons.tuneRounded,
                                onTap: () => setState(
                                  () => _moreBasicsOpen = !_moreBasicsOpen,
                                ),
                              ),
                              if (_moreBasicsOpen)
                                CatchField.read(
                                  copy: fieldCopy,
                                  title: context.l10n.hostsPrivateEventAfterSave,
                                  body: context.l10n.hostsPrivateEventAfterSaveBody,
                                ),
                            ],
                          ),
                        ],
                      ),
                      gapH4,
                      Text(
                        context.l10n.hostsPrivateEventSaveHint,
                        style: Theme.of(context)
                            .textTheme.bodyMedium?.copyWith(color: t.ink2),
                      ),
                      if (_error != null) ...[
                        gapH4,
                        CatchBanner.error(message: _error!),
                      ],
                    ],
                  ),
                ),
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: CatchInsets.pageBodyTight,
                child: CatchButton(
                  key: const ValueKey('private-event-save'),
                  label: receipt != null
                      ? (_pendingUpdate == null
                          ? context.l10n.hostsEventEditSaveChanges
                          : context.l10n.hostsPrivateEventRetrySave)
                      : (_submittedSignature == null
                          ? context.l10n.hostsPrivateEventSaveContinue
                          : context.l10n.hostsPrivateEventRetrySave),
                  onPressed: _saving ||
                          (receipt != null && !_canEditSavedBasics)
                      ? null
                      : _save,
                  status: _saving
                      ? CatchButtonStatus.loading
                      : CatchButtonStatus.idle,
                  fullWidth: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _newRequestId() {
  final random = Random.secure();
  return List<int>.generate(24, (_) => random.nextInt(256))
      .map((value) => value.toRadixString(16).padLeft(2, '0'))
      .join();
}
