part of '../event_success_companion_screen.dart';

const EdgeInsets _companionRotationSlotGap = EdgeInsets.only(
  bottom: CatchSpacing.s2,
);
const EdgeInsets _companionPreviewIconInset = EdgeInsets.only(
  top: CatchSpacing.micro2,
);
const EdgeInsets _companionQrSheetPadding = EdgeInsets.fromLTRB(
  CatchSpacing.s4,
  CatchSpacing.s4,
  CatchSpacing.s4,
  CatchSpacing.s5,
);
const EdgeInsets _companionStageCueGap = EdgeInsets.only(
  bottom: CatchSpacing.s3,
);

class _MicroPodCard extends ConsumerWidget {
  const _MicroPodCard({
    required this.event,
    required this.assignment,
    required this.peerProfiles,
    required this.peersLoading,
    required this.microPodsOptedOut,
  });

  final Event event;
  final EventSuccessAssignment? assignment;
  final List<PublicProfile> peerProfiles;
  final bool peersLoading;
  final bool microPodsOptedOut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final assigned = assignment;
    final mutation = ref.watch(EventSuccessController.microPodsOptOutMutation);
    final groupSlots =
        assigned?.groupRotationSlots ?? const <EventSuccessGroupRotationSlot>[];
    final profilesByUid = {
      for (final profile in peerProfiles) profile.uid: profile,
    };
    return _StagePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StageSectionLabel(
            icon: CatchIcons.groups2Outlined,
            label: 'Starter group',
            color: t.primary,
          ),
          gapH10,
          Text(
            microPodsOptedOut
                ? 'Starter groups paused for you'
                : assigned?.displayTitle ?? 'Your starter group is forming',
            style: CatchTextStyles.titleL(context),
          ),
          gapH6,
          Text(
            microPodsOptedOut
                ? 'You won\'t be included when the host runs the generator.'
                : assigned?.displaySubtitle ??
                      'The host will publish starter groups once everyone is checked in.',
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
          if (assigned != null) ...[
            gapH14,
            if (groupSlots.isNotEmpty)
              if (peersLoading)
                CatchBadge(
                  label: 'Loading group members',
                  icon: CatchIcons.hourglassEmptyRounded,
                )
              else
                Column(
                  children: [
                    for (final slot in groupSlots)
                      _GroupRotationSlotRow(
                        slot: slot,
                        profilesByUid: profilesByUid,
                      ),
                  ],
                )
            else
              _PeopleTokenRow(
                countLabel: '${assigned.peerUids.length + 1} people',
                loading: peersLoading,
                loadingLabel: 'Loading group members',
                profiles: peerProfiles,
              ),
          ],
          gapH14,
          _StageActionDock(
            child: _IncludeMeToggle(
              label: 'Include me in starter groups',
              included: !microPodsOptedOut,
              busy: mutation.isPending,
              onChanged: (include) =>
                  EventSuccessController.microPodsOptOutMutation.run(
                    ref,
                    (tx) => tx
                        .get(eventSuccessControllerProvider.notifier)
                        .setMicroPodsOptOut(event: event, optedOut: !include),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupRotationSlotRow extends StatelessWidget {
  const _GroupRotationSlotRow({
    required this.slot,
    required this.profilesByUid,
  });

  final EventSuccessGroupRotationSlot slot;
  final Map<String, PublicProfile> profilesByUid;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final timeRange =
        '${TimeOfDay.fromDateTime(slot.startsAt).format(context)}-'
        '${TimeOfDay.fromDateTime(slot.endsAt).format(context)}';
    final peerNames = slot.peerUids
        .map((uid) => profilesByUid[uid]?.name)
        .whereType<String>()
        .toList(growable: false);
    return Padding(
      padding: _companionRotationSlotGap,
      child: CatchSurface(
        backgroundColor: t.primarySoft,
        radius: CatchRadius.sm,
        borderWidth: 0,
        padding: CatchInsets.contentDense,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: CatchSpacing.s2,
              runSpacing: CatchSpacing.s2,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                CatchBadge(
                  label: slot.label,
                  tone: _isStrongRotationSignal(slot.compatibility)
                      ? CatchBadgeTone.success
                      : CatchBadgeTone.neutral,
                ),
                CatchBadge(
                  label: slot.unitLabel,
                  icon: CatchIcons.tableRestaurantOutlined,
                ),
              ],
            ),
            gapH8,
            Text(timeRange, style: CatchTextStyles.supporting(context)),
            gapH8,
            Wrap(
              spacing: CatchSpacing.s2,
              runSpacing: CatchSpacing.s2,
              children: [
                CatchBadge(
                  label: '${slot.peerUids.length + 1} people',
                  icon: CatchIcons.groupOutlined,
                ),
                for (final name in peerNames)
                  CatchBadge(
                    label: name,
                    icon: CatchIcons.personOutlineRounded,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RotationScheduleCard extends ConsumerWidget {
  const _RotationScheduleCard({
    required this.event,
    required this.assignment,
    required this.peerProfiles,
    required this.peersLoading,
    required this.guidedRotationsOptedOut,
  });

  final Event event;
  final EventSuccessAssignment? assignment;
  final List<PublicProfile> peerProfiles;
  final bool peersLoading;
  final bool guidedRotationsOptedOut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final assigned = assignment;
    final mutation = ref.watch(
      EventSuccessController.guidedRotationsOptOutMutation,
    );
    final profilesByUid = {
      for (final profile in peerProfiles) profile.uid: profile,
    };
    return _StagePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StageSectionLabel(
            icon: CatchIcons.syncAltRounded,
            label: 'Timed rotations',
            color: t.primary,
          ),
          gapH10,
          Text(
            guidedRotationsOptedOut
                ? 'Timed rotations paused for you'
                : assigned?.displayTitle ?? 'Your rotation schedule is forming',
            style: CatchTextStyles.titleL(context),
          ),
          gapH6,
          Text(
            guidedRotationsOptedOut
                ? 'You won\'t be included when the host runs the generator.'
                : assigned?.displaySubtitle ??
                      'Your timed pairings appear once the host generates rotations.',
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
          if (assigned != null) ...[
            gapH14,
            if (peersLoading)
              CatchBadge(
                label: 'Loading partner names',
                icon: CatchIcons.hourglassEmptyRounded,
              )
            else
              Column(
                children: [
                  for (final slot in assigned.rotationSlots)
                    _RotationSlotRow(
                      slot: slot,
                      peerName: profilesByUid[slot.peerUid]?.name ?? 'Partner',
                    ),
                ],
              ),
          ],
          gapH14,
          _StageActionDock(
            child: _IncludeMeToggle(
              label: 'Include me in timed rotations',
              included: !guidedRotationsOptedOut,
              busy: mutation.isPending,
              onChanged: (include) =>
                  EventSuccessController.guidedRotationsOptOutMutation.run(
                    ref,
                    (tx) => tx
                        .get(eventSuccessControllerProvider.notifier)
                        .setGuidedRotationsOptOut(
                          event: event,
                          optedOut: !include,
                        ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RotationSlotRow extends StatelessWidget {
  const _RotationSlotRow({required this.slot, required this.peerName});

  final EventSuccessRotationSlot slot;
  final String peerName;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final timeRange =
        '${TimeOfDay.fromDateTime(slot.startsAt).format(context)}-'
        '${TimeOfDay.fromDateTime(slot.endsAt).format(context)}';
    return Padding(
      padding: _companionRotationSlotGap,
      child: CatchSurface(
        backgroundColor: t.primarySoft,
        radius: CatchRadius.sm,
        borderWidth: 0,
        padding: CatchInsets.contentDense,
        child: Row(
          children: [
            CatchBadge(
              label: slot.label,
              tone: _isStrongRotationSignal(slot.compatibility)
                  ? CatchBadgeTone.success
                  : CatchBadgeTone.neutral,
            ),
            gapW8,
            Expanded(
              child: Text(
                '$timeRange · $peerName',
                style: CatchTextStyles.supporting(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveStepContextCard extends StatelessWidget {
  const _LiveStepContextCard({required this.step});

  final EventRunOfShowStep? step;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final activeStep = step;
    return _StagePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StageSectionLabel(
            icon: CatchIcons.locationOnOutlined,
            label: activeStep?.stage.label ?? 'Live cue',
            color: t.primary,
          ),
          gapH10,
          Text(
            activeStep == null ? 'Event is live' : activeStep.title,
            style: CatchTextStyles.titleL(context),
          ),
          gapH6,
          Text(
            activeStep?.attendeeExperience ??
                'Follow the host for the next event moment.',
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
        ],
      ),
    );
  }
}

/// Informational preview of what the host will guide the attendee through
/// once check-in opens. Opt-out controls live on the at-event cards instead.
class _PreCheckInPlanningCard extends StatelessWidget {
  const _PreCheckInPlanningCard({
    required this.microPodsEnabled,
    required this.guidedRotationsEnabled,
    required this.liveRevealEnabled,
    required this.socialMissionsEnabled,
    required this.wingmanRequestsEnabled,
  });

  final bool microPodsEnabled;
  final bool guidedRotationsEnabled;
  final bool liveRevealEnabled;
  final bool socialMissionsEnabled;
  final bool wingmanRequestsEnabled;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final entries = <_PreviewLine>[
      if (microPodsEnabled)
        _PreviewLine(
          icon: CatchIcons.groups2Outlined,
          text: 'Small starter group when you check in.',
        ),
      if (guidedRotationsEnabled)
        _PreviewLine(
          icon: CatchIcons.syncAltRounded,
          text: 'Timed partner rotations during the event.',
        ),
      if (liveRevealEnabled)
        _PreviewLine(
          icon: CatchIcons.boltRounded,
          text: 'Synchronized partner reveals as the event unfolds.',
        ),
      if (socialMissionsEnabled)
        _PreviewLine(
          icon: CatchIcons.chatBubbleOutlineRounded,
          text: 'Live conversation prompts from the host.',
        ),
      if (wingmanRequestsEnabled)
        _PreviewLine(
          icon: CatchIcons.volunteerActivismOutlined,
          text: 'You can ask the host for an intro to someone specific.',
        ),
    ];
    return _StagePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StageSectionLabel(
            icon: CatchIcons.eventAvailableOutlined,
            label: 'Preview',
            color: t.primary,
          ),
          gapH10,
          Text(
            'What we\'ll guide you through',
            style: CatchTextStyles.titleL(context),
          ),
          gapH6,
          Text(
            'Live partner and group details unlock after check-in. Here\'s what to expect at the event:',
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
          gapH14,
          for (final entry in entries) ...[entry, gapH8],
        ],
      ),
    );
  }
}

class _PreviewLine extends StatelessWidget {
  const _PreviewLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: _companionPreviewIconInset,
          child: Icon(icon, size: CatchIcon.xs, color: t.ink2),
        ),
        gapW6,
        Expanded(child: Text(text, style: CatchTextStyles.supporting(context))),
      ],
    );
  }
}

class _IncludeMeToggle extends StatelessWidget {
  const _IncludeMeToggle({
    required this.label,
    required this.included,
    required this.busy,
    required this.onChanged,
  });

  final String label;
  final bool included;
  final bool busy;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: CatchTextStyles.labelL(context, color: t.surface),
          ),
        ),
        Switch.adaptive(value: included, onChanged: busy ? null : onChanged),
      ],
    );
  }
}

class _SelfCheckInCard extends ConsumerWidget {
  const _SelfCheckInCard({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mutation = ref.watch(EventBookingController.selfCheckInMutation);
    final t = CatchTokens.of(context);
    return _StagePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StageSectionLabel(
            icon: CatchIcons.qrCode2Rounded,
            label: 'Arrival',
            color: t.primary,
          ),
          gapH10,
          Text('Arrival check-in', style: CatchTextStyles.titleL(context)),
          gapH6,
          Text(
            'Confirm you are at the event so post-event follow-up only includes actual attendees.',
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
          gapH14,
          _StageActionDock(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CatchButton(
                  label: 'Scan host QR',
                  icon: Icon(CatchIcons.qrCodeScannerRounded),
                  isLoading: mutation.isPending,
                  onPressed: mutation.isPending
                      ? null
                      : () => _scanHostQr(context, ref),
                  fullWidth: true,
                ),
                gapH8,
                CatchButton(
                  label: 'Check in',
                  variant: CatchButtonVariant.ghost,
                  isLoading: mutation.isPending,
                  onPressed: mutation.isPending ? null : () => _checkIn(ref),
                  fullWidth: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _scanHostQr(BuildContext context, WidgetRef ref) async {
    final matched = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _EventCheckInQrScannerSheet(eventId: event.id),
    );
    if (matched == true && context.mounted) {
      _checkIn(ref);
    }
  }

  void _checkIn(WidgetRef ref) {
    unawaited(
      ref
          .read(eventSuccessLiveEffectsControllerProvider)
          .play(EventSuccessLiveEffectKind.liveEntry),
    );
    EventBookingController.selfCheckInMutation.run(
      ref,
      (tx) => tx
          .get(eventBookingControllerProvider.notifier)
          .selfCheckIn(eventId: event.id),
    );
  }
}

class _EventCheckInQrScannerSheet extends StatefulWidget {
  const _EventCheckInQrScannerSheet({required this.eventId});

  final String eventId;

  @override
  State<_EventCheckInQrScannerSheet> createState() =>
      _EventCheckInQrScannerSheetState();
}

class _EventCheckInQrScannerSheetState
    extends State<_EventCheckInQrScannerSheet> {
  late final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );
  bool _handled = false;
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final height = math.min(MediaQuery.sizeOf(context).height * 0.72, 560.0);
    return SizedBox(
      height: height,
      child: Padding(
        padding: _companionQrSheetPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(CatchIcons.qrCodeScannerRounded, color: t.primary),
                gapW10,
                Expanded(
                  child: Text(
                    'Scan host QR',
                    style: CatchTextStyles.sectionTitle(context),
                  ),
                ),
                IconButton(
                  icon: Icon(CatchIcons.closeRounded),
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).maybePop(false),
                ),
              ],
            ),
            gapH10,
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(CatchRadius.sm),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    MobileScanner(
                      controller: _controller,
                      onDetect: _handleCapture,
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(color: t.primary, width: 3),
                        borderRadius: BorderRadius.circular(CatchRadius.sm),
                      ),
                    ),
                    if (_errorText != null)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: CatchSurface(
                          width: double.infinity,
                          padding: CatchInsets.contentDense,
                          backgroundColor: t.ink.withValues(
                            alpha: CatchOpacity.eventSuccessQrErrorFill,
                          ),
                          borderWidth: 0,
                          radius: CatchRadius.none,
                          child: Text(
                            _errorText!,
                            style: CatchTextStyles.supporting(
                              context,
                              color: CatchTokens.editorialLight,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            gapH10,
            Text(
              'Location still verifies the venue after the QR is scanned.',
              style: CatchTextStyles.supporting(context, color: t.ink2),
            ),
          ],
        ),
      ),
    );
  }

  void _handleCapture(BarcodeCapture capture) {
    if (_handled) return;
    for (final barcode in capture.barcodes) {
      final rawValue = barcode.rawValue;
      if (rawValue == null) continue;
      final payload = EventCheckInQrPayload.tryParse(rawValue);
      if (payload == null) {
        setState(() => _errorText = 'This is not a Catch event QR.');
        continue;
      }
      if (payload.eventId != widget.eventId) {
        setState(() => _errorText = 'This QR belongs to another event.');
        continue;
      }
      _handled = true;
      unawaited(HapticFeedback.lightImpact());
      Navigator.of(context).maybePop(true);
      return;
    }
  }
}

class _StagePromptCard extends StatelessWidget {
  const _StagePromptCard({required this.prompt, this.title = 'Social mission'});

  final String prompt;
  final String title;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return _StagePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StageSectionLabel(
            icon: CatchIcons.chatBubbleOutlineRounded,
            label: title,
            color: t.primary,
          ),
          gapH12,
          Text(prompt, style: CatchTextStyles.titleL(context)),
        ],
      ),
    );
  }
}

class _StageConversationCueCard extends StatelessWidget {
  const _StageConversationCueCard({
    required this.title,
    required this.cues,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final List<EventSuccessConversationCue> cues;

  @override
  Widget build(BuildContext context) {
    if (cues.isEmpty) return const SizedBox.shrink();

    final t = CatchTokens.of(context);
    final moment = cues.first.moment;
    final icon = switch (moment) {
      EventSuccessConversationCueMoment.live => CatchIcons.forumOutlined,
      EventSuccessConversationCueMoment.postEvent => CatchIcons.chatOutlined,
    };
    return _StagePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StageSectionLabel(icon: icon, label: title, color: t.primary),
          if (subtitle != null) ...[
            gapH8,
            Text(
              subtitle!,
              style: CatchTextStyles.supporting(context, color: t.ink2),
            ),
          ],
          gapH14,
          for (final cue in cues.take(3)) _StageCueLine(cue: cue),
        ],
      ),
    );
  }
}

class _StageCueLine extends StatelessWidget {
  const _StageCueLine({required this.cue});

  final EventSuccessConversationCue cue;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Padding(
      padding: _companionStageCueGap,
      child: CatchSurface(
        backgroundColor: t.primarySoft,
        radius: CatchRadius.sm,
        borderWidth: 0,
        padding: CatchInsets.contentDense,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    cue.title,
                    style: CatchTextStyles.sectionTitle(context),
                  ),
                ),
                IconButton(
                  tooltip:
                      cue.moment == EventSuccessConversationCueMoment.postEvent
                      ? 'Copy opener'
                      : 'Copy cue',
                  icon: Icon(CatchIcons.contentCopyRounded, size: CatchIcon.md),
                  onPressed: () => _copyCue(context, cue),
                ),
              ],
            ),
            gapH4,
            Text(
              cue.body,
              style: CatchTextStyles.supporting(context, color: t.ink2),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copyCue(
    BuildContext context,
    EventSuccessConversationCue cue,
  ) async {
    await Clipboard.setData(ClipboardData(text: cue.body));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          cue.moment == EventSuccessConversationCueMoment.postEvent
              ? 'Opener copied.'
              : 'Cue copied.',
          style: CatchTextStyles.labelL(
            context,
            color: CatchTokens.of(context).bg,
          ),
        ),
      ),
    );
  }
}

class _StageSectionLabel extends StatelessWidget {
  const _StageSectionLabel({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: CatchIcon.md, color: color),
        gapW6,
        Expanded(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: CatchTextStyles.labelL(context, color: color),
          ),
        ),
      ],
    );
  }
}

class _PeopleTokenRow extends StatelessWidget {
  const _PeopleTokenRow({
    required this.countLabel,
    required this.loading,
    required this.loadingLabel,
    required this.profiles,
  });

  final String countLabel;
  final bool loading;
  final String loadingLabel;
  final List<PublicProfile> profiles;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: CatchSpacing.s2,
      runSpacing: CatchSpacing.s2,
      children: [
        CatchBadge(label: countLabel, icon: CatchIcons.groupOutlined),
        if (loading)
          CatchBadge(
            label: loadingLabel,
            icon: CatchIcons.hourglassEmptyRounded,
          )
        else
          for (final profile in profiles)
            CatchBadge(
              label: profile.name,
              icon: CatchIcons.personOutlineRounded,
            ),
      ],
    );
  }
}
