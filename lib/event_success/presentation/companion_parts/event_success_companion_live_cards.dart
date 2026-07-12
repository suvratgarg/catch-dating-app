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

@immutable
class AssignmentOptOutActionState {
  const AssignmentOptOutActionState({
    required this.optedOut,
    this.isSaving = false,
  });

  final bool optedOut;
  final bool isSaving;

  bool get included => !optedOut;
}

class MicroPodCard extends StatelessWidget {
  const MicroPodCard({
    super.key,
    required this.event,
    required this.assignment,
    required this.peerProfiles,
    required this.peersLoading,
    required this.actionState,
    required this.onIncludeChanged,
  });

  final Event event;
  final EventSuccessAssignment? assignment;
  final List<PublicProfile> peerProfiles;
  final bool peersLoading;
  final AssignmentOptOutActionState actionState;
  final ValueChanged<bool> onIncludeChanged;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final assigned = assignment;
    final optedOut = actionState.optedOut;
    final groupSlots =
        assigned?.groupRotationSlots ?? const <EventSuccessGroupRotationSlot>[];
    final profilesByUid = {
      for (final profile in peerProfiles) profile.uid: profile,
    };
    return StagePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StageSectionLabel(
            icon: CatchIcons.groups2Outlined,
            label: context
                .l10n
                .eventSuccessEventSuccessCompanionLiveCardsLabelStarterGroup,
            color: t.primary,
          ),
          gapH10,
          Text(
            optedOut
                ? context
                      .l10n
                      .eventSuccessEventSuccessCompanionLiveCardsTextStarterGroupsPausedFor
                : assigned?.displayTitle ??
                      context
                          .l10n
                          .eventSuccessEventSuccessCompanionLiveCardsTextYourStarterGroupIs,
            style: CatchTextStyles.titleL(context),
          ),
          gapH6,
          Text(
            optedOut
                ? context
                      .l10n
                      .eventSuccessEventSuccessCompanionLiveCardsTextYouWonTBe
                : assigned?.displaySubtitle ??
                      context
                          .l10n
                          .eventSuccessEventSuccessCompanionLiveCardsTextTheHostWillPublish,
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
          if (assigned != null) ...[
            gapH14,
            if (groupSlots.isNotEmpty)
              if (peersLoading)
                CatchBadge(
                  label: context
                      .l10n
                      .eventSuccessEventSuccessCompanionLiveCardsLabelLoadingGroupMembers,
                  icon: CatchIcons.hourglassEmptyRounded,
                )
              else
                Column(
                  children: [
                    for (final slot in groupSlots)
                      GroupRotationSlotRow(
                        slot: slot,
                        profilesByUid: profilesByUid,
                      ),
                  ],
                )
            else
              PeopleTokenRow(
                countLabel: context.l10n
                    .eventSuccessEventSuccessCompanionLiveCardsVisiblecopyValue1People(
                      value1: assigned.peerUids.length + 1,
                    ),
                loading: peersLoading,
                loadingLabel: context
                    .l10n
                    .eventSuccessEventSuccessCompanionLiveCardsVisiblecopyLoadingGroupMembers,
                profiles: peerProfiles,
              ),
          ],
          gapH14,
          StageActionDock(
            child: IncludeMeToggle(
              label: context
                  .l10n
                  .eventSuccessEventSuccessCompanionLiveCardsLabelIncludeMeInStarter,
              included: actionState.included,
              busy: actionState.isSaving,
              onChanged: onIncludeChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class GroupRotationSlotRow extends StatelessWidget {
  const GroupRotationSlotRow({
    super.key,
    required this.slot,
    required this.profilesByUid,
  });

  final EventSuccessGroupRotationSlot slot;
  final Map<String, PublicProfile> profilesByUid;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final timeRange = context.l10n
        .eventSuccessEventSuccessCompanionLiveCardsVisiblecopyFormatFormat2(
          format: TimeOfDay.fromDateTime(slot.startsAt).format(context),
          format2: TimeOfDay.fromDateTime(slot.endsAt).format(context),
        );
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
                  label: context.l10n
                      .eventSuccessEventSuccessCompanionLiveCardsLabelValue1People(
                        value1: slot.peerUids.length + 1,
                      ),
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

class RotationScheduleCard extends StatelessWidget {
  const RotationScheduleCard({
    super.key,
    required this.event,
    required this.assignment,
    required this.peerProfiles,
    required this.peersLoading,
    required this.actionState,
    required this.onIncludeChanged,
  });

  final Event event;
  final EventSuccessAssignment? assignment;
  final List<PublicProfile> peerProfiles;
  final bool peersLoading;
  final AssignmentOptOutActionState actionState;
  final ValueChanged<bool> onIncludeChanged;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final assigned = assignment;
    final optedOut = actionState.optedOut;
    final profilesByUid = {
      for (final profile in peerProfiles) profile.uid: profile,
    };
    return StagePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StageSectionLabel(
            icon: CatchIcons.syncAltRounded,
            label: context
                .l10n
                .eventSuccessEventSuccessCompanionLiveCardsLabelTimedRotations,
            color: t.primary,
          ),
          gapH10,
          Text(
            optedOut
                ? context
                      .l10n
                      .eventSuccessEventSuccessCompanionLiveCardsTextTimedRotationsPausedFor
                : assigned?.displayTitle ??
                      context
                          .l10n
                          .eventSuccessEventSuccessCompanionLiveCardsTextYourRotationScheduleIs,
            style: CatchTextStyles.titleL(context),
          ),
          gapH6,
          Text(
            optedOut
                ? context
                      .l10n
                      .eventSuccessEventSuccessCompanionLiveCardsTextYouWonTBe
                : assigned?.displaySubtitle ??
                      context
                          .l10n
                          .eventSuccessEventSuccessCompanionLiveCardsTextYourTimedPairingsAppear,
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
          if (assigned != null) ...[
            gapH14,
            if (peersLoading)
              CatchBadge(
                label: context
                    .l10n
                    .eventSuccessEventSuccessCompanionLiveCardsLabelLoadingPartnerNames,
                icon: CatchIcons.hourglassEmptyRounded,
              )
            else
              Column(
                children: [
                  for (final slot in assigned.rotationSlots)
                    RotationSlotRow(
                      slot: slot,
                      peerName:
                          profilesByUid[slot.peerUid]?.name ??
                          context
                              .l10n
                              .eventSuccessEventSuccessCompanionLiveCardsVisiblecopyPartner,
                    ),
                ],
              ),
          ],
          gapH14,
          StageActionDock(
            child: IncludeMeToggle(
              label: context
                  .l10n
                  .eventSuccessEventSuccessCompanionLiveCardsLabelIncludeMeInTimed,
              included: actionState.included,
              busy: actionState.isSaving,
              onChanged: onIncludeChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class RotationSlotRow extends StatelessWidget {
  const RotationSlotRow({
    super.key,
    required this.slot,
    required this.peerName,
  });

  final EventSuccessRotationSlot slot;
  final String peerName;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final timeRange = context.l10n
        .eventSuccessEventSuccessCompanionLiveCardsVisiblecopyFormatFormat2(
          format: TimeOfDay.fromDateTime(slot.startsAt).format(context),
          format2: TimeOfDay.fromDateTime(slot.endsAt).format(context),
        );
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
                context.l10n
                    .eventSuccessEventSuccessCompanionLiveCardsTextTimerangePeername(
                      timeRange: timeRange,
                      peerName: peerName,
                    ),
                style: CatchTextStyles.supporting(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LiveStepContextCard extends StatelessWidget {
  const LiveStepContextCard({super.key, required this.step});

  final EventRunOfShowStep? step;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final activeStep = step;
    return StagePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StageSectionLabel(
            icon: CatchIcons.locationOnOutlined,
            label:
                activeStep?.stage.label ??
                context
                    .l10n
                    .eventSuccessEventSuccessCompanionLiveCardsLabelLiveCue,
            color: t.primary,
          ),
          gapH10,
          Text(
            activeStep == null
                ? context
                      .l10n
                      .eventSuccessEventSuccessCompanionLiveCardsTextEventIsLive
                : activeStep.title,
            style: CatchTextStyles.titleL(context),
          ),
          gapH6,
          Text(
            activeStep?.attendeeExperience ??
                context
                    .l10n
                    .eventSuccessEventSuccessCompanionLiveCardsTextFollowTheHostFor,
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
        ],
      ),
    );
  }
}

/// Informational preview of what the host will guide the attendee through
/// once check-in opens. Opt-out controls live on the at-event cards instead.
class PreCheckInPlanningCard extends StatelessWidget {
  const PreCheckInPlanningCard({
    super.key,
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
    final entries = <PreviewLine>[
      if (microPodsEnabled)
        PreviewLine(
          icon: CatchIcons.groups2Outlined,
          text: context
              .l10n
              .eventSuccessEventSuccessCompanionLiveCardsTextSmallStarterGroupWhen,
        ),
      if (guidedRotationsEnabled)
        PreviewLine(
          icon: CatchIcons.syncAltRounded,
          text: context
              .l10n
              .eventSuccessEventSuccessCompanionLiveCardsTextTimedPartnerRotationsDuring,
        ),
      if (liveRevealEnabled)
        PreviewLine(
          icon: CatchIcons.boltRounded,
          text: context
              .l10n
              .eventSuccessEventSuccessCompanionLiveCardsTextSynchronizedPartnerRevealsAs,
        ),
      if (socialMissionsEnabled)
        PreviewLine(
          icon: CatchIcons.chatBubbleOutlineRounded,
          text: context
              .l10n
              .eventSuccessEventSuccessCompanionLiveCardsTextLiveConversationPromptsFrom,
        ),
      if (wingmanRequestsEnabled)
        PreviewLine(
          icon: CatchIcons.volunteerActivismOutlined,
          text: context
              .l10n
              .eventSuccessEventSuccessCompanionLiveCardsTextYouCanAskThe,
        ),
    ];
    return StagePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StageSectionLabel(
            icon: CatchIcons.eventAvailableOutlined,
            label: context
                .l10n
                .eventSuccessEventSuccessCompanionLiveCardsLabelPreview,
            color: t.primary,
          ),
          gapH10,
          Text(
            context
                .l10n
                .eventSuccessEventSuccessCompanionLiveCardsTextWhatWeLlGuide,
            style: CatchTextStyles.titleL(context),
          ),
          gapH6,
          Text(
            context
                .l10n
                .eventSuccessEventSuccessCompanionLiveCardsTextLivePartnerAndGroup,
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
          gapH14,
          for (final entry in entries) ...[entry, gapH8],
        ],
      ),
    );
  }
}

class PreviewLine extends StatelessWidget {
  const PreviewLine({super.key, required this.icon, required this.text});

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

class IncludeMeToggle extends StatelessWidget {
  const IncludeMeToggle({
    super.key,
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
        CatchToggle(
          value: included,
          semanticLabel: label,
          onChanged: busy ? null : onChanged,
        ),
      ],
    );
  }
}

@immutable
class SelfCheckInActionState {
  const SelfCheckInActionState({this.isCheckingIn = false});

  final bool isCheckingIn;
}

class SelfCheckInCard extends StatefulWidget {
  const SelfCheckInCard({
    super.key,
    required this.event,
    required this.actionState,
    required this.onSelfCheckIn,
  });

  final Event event;
  final SelfCheckInActionState actionState;
  final Future<void> Function() onSelfCheckIn;

  @override
  State<SelfCheckInCard> createState() => _SelfCheckInCardState();
}

class _SelfCheckInCardState extends State<SelfCheckInCard> {
  bool _checkingIn = false;

  @override
  Widget build(BuildContext context) {
    final busy = widget.actionState.isCheckingIn || _checkingIn;
    final t = CatchTokens.of(context);
    return StagePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StageSectionLabel(
            icon: CatchIcons.qrCode2Rounded,
            label: context
                .l10n
                .eventSuccessEventSuccessCompanionLiveCardsLabelArrival,
            color: t.primary,
          ),
          gapH10,
          Text(
            context
                .l10n
                .eventSuccessEventSuccessCompanionLiveCardsTextArrivalCheckIn,
            style: CatchTextStyles.titleL(context),
          ),
          gapH6,
          Text(
            context
                .l10n
                .eventSuccessEventSuccessCompanionLiveCardsTextConfirmYouAreAt,
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
          gapH14,
          StageActionDock(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CatchButton(
                  label: context
                      .l10n
                      .eventSuccessEventSuccessCompanionLiveCardsLabelScanHostQr,
                  icon: Icon(CatchIcons.qrCodeScannerRounded),
                  isLoading: busy,
                  onPressed: busy ? null : () => _scanHostQr(context),
                  fullWidth: true,
                ),
                gapH8,
                CatchButton(
                  label: context
                      .l10n
                      .eventSuccessEventSuccessCompanionLiveCardsLabelCheckIn,
                  variant: CatchButtonVariant.ghost,
                  isLoading: busy,
                  onPressed: busy ? null : _checkIn,
                  fullWidth: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _scanHostQr(BuildContext context) async {
    final matched = await showCatchBottomSheet<bool>(
      context: context,
      builder: (context) =>
          EventCheckInQrScannerSheet(eventId: widget.event.id),
    );
    if (matched == true && context.mounted) {
      await _checkIn();
    }
  }

  Future<void> _checkIn() async {
    setState(() => _checkingIn = true);
    try {
      await widget.onSelfCheckIn();
    } finally {
      if (mounted) setState(() => _checkingIn = false);
    }
  }
}

class EventCheckInQrScannerSheet extends StatefulWidget {
  const EventCheckInQrScannerSheet({super.key, required this.eventId});

  final String eventId;

  @override
  State<EventCheckInQrScannerSheet> createState() =>
      _EventCheckInQrScannerSheetState();
}

class _EventCheckInQrScannerSheetState
    extends State<EventCheckInQrScannerSheet> {
  String? _errorText;

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
                    context
                        .l10n
                        .eventSuccessEventSuccessCompanionLiveCardsTextScanHostQr,
                    style: CatchTextStyles.sectionTitle(context),
                  ),
                ),
                Tooltip(
                  message: context
                      .l10n
                      .eventSuccessEventSuccessCompanionLiveCardsMessageClose,
                  child: CatchIconButton(
                    onTap: () => Navigator.of(context).maybePop(false),
                    child: Icon(
                      CatchIcons.closeRounded,
                      size: CatchIcon.md,
                      color: t.ink2,
                    ),
                  ),
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
                    EventCheckInQrScanner(
                      eventId: widget.eventId,
                      onResult: _handleScanResult,
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
                              color: CatchTokens.editorialWhite,
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
              context
                  .l10n
                  .eventSuccessEventSuccessCompanionLiveCardsTextLocationStillVerifiesThe,
              style: CatchTextStyles.supporting(context, color: t.ink2),
            ),
          ],
        ),
      ),
    );
  }

  void _handleScanResult(EventCheckInQrScanResult result) {
    switch (result) {
      case EventCheckInQrScanResult.ignored:
        return;
      case EventCheckInQrScanResult.invalid:
        setState(
          () => _errorText = context
              .l10n
              .eventSuccessEventSuccessCompanionLiveCardsVisiblecopyThisIsNotA,
        );
      case EventCheckInQrScanResult.wrongEvent:
        setState(
          () => _errorText = context
              .l10n
              .eventSuccessEventSuccessCompanionLiveCardsVisiblecopyThisQrBelongsTo,
        );
      case EventCheckInQrScanResult.matched:
        unawaited(HapticFeedback.lightImpact());
        Navigator.of(context).maybePop(true);
    }
  }
}

class StagePromptCard extends StatelessWidget {
  const StagePromptCard({
    super.key,
    required this.prompt,
    this.title = 'Social mission',
  });

  final String prompt;
  final String title;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return StagePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StageSectionLabel(
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

class StageConversationCueCard extends StatelessWidget {
  const StageConversationCueCard({
    super.key,
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
    return StagePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StageSectionLabel(icon: icon, label: title, color: t.primary),
          if (subtitle != null) ...[
            gapH8,
            Text(
              subtitle!,
              style: CatchTextStyles.supporting(context, color: t.ink2),
            ),
          ],
          gapH14,
          for (final cue in cues.take(3)) StageCueLine(cue: cue),
        ],
      ),
    );
  }
}

class StageCueLine extends StatelessWidget {
  const StageCueLine({super.key, required this.cue});

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
                Tooltip(
                  message:
                      cue.moment == EventSuccessConversationCueMoment.postEvent
                      ? context
                            .l10n
                            .eventSuccessEventSuccessCompanionLiveCardsMessageCopyOpener
                      : context
                            .l10n
                            .eventSuccessEventSuccessCompanionLiveCardsMessageCopyCue,
                  child: CatchIconButton(
                    onTap: () => _copyCue(context, cue),
                    child: Icon(
                      CatchIcons.contentCopyRounded,
                      size: CatchIcon.md,
                      color: t.primary,
                    ),
                  ),
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
    showCatchSnackBar(
      context,
      cue.moment == EventSuccessConversationCueMoment.postEvent
          ? context
                .l10n
                .eventSuccessEventSuccessCompanionLiveCardsVisiblecopyOpenerCopied
          : context
                .l10n
                .eventSuccessEventSuccessCompanionLiveCardsVisiblecopyCueCopied,
    );
  }
}

class StageSectionLabel extends StatelessWidget {
  const StageSectionLabel({
    super.key,
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

class PeopleTokenRow extends StatelessWidget {
  const PeopleTokenRow({
    super.key,
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
