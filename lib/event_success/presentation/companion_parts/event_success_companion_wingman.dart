part of '../event_success_companion_screen.dart';

const EdgeInsets _wingmanCandidateRowGap = EdgeInsets.only(
  bottom: CatchSpacing.s2,
);

@immutable
class WingmanRequestActionState {
  const WingmanRequestActionState({this.isSaving = false});

  final bool isSaving;
}

class WingmanRequestSection extends StatefulWidget {
  const WingmanRequestSection({
    required this.event,
    required this.candidates,
    required this.actionState,
    required this.onSaveRequest,
    required this.onWithdrawRequest,
    this.existingRequest,
  });

  final Event event;
  final List<PublicProfile> candidates;
  final WingmanRequestActionState actionState;
  final Future<void> Function(PublicProfile target, String note) onSaveRequest;
  final Future<void> Function() onWithdrawRequest;
  final EventSuccessWingmanRequest? existingRequest;

  @override
  State<WingmanRequestSection> createState() => _WingmanRequestSectionState();
}

class _WingmanRequestSectionState extends State<WingmanRequestSection> {
  late final TextEditingController _noteController = TextEditingController(
    text: widget.existingRequest?.isActive == true
        ? widget.existingRequest?.note ?? ''
        : '',
  );
  String? _optimisticTargetUid;
  String? _savingTargetUid;
  bool _withdrawing = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final saving = widget.actionState.isSaving || _savingTargetUid != null;
    final withdrawing = widget.actionState.isSaving || _withdrawing;
    final activeRequest = widget.existingRequest?.isActive == true
        ? widget.existingRequest
        : null;
    final requestedTargetUid = _optimisticTargetUid ?? activeRequest?.targetUid;
    final requestedTargetName = requestedTargetUid == null
        ? null
        : _profileNameForUid(widget.candidates, requestedTargetUid);

    final t = CatchTokens.of(context);
    return StagePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context
                      .l10n
                      .eventSuccessEventSuccessCompanionWingmanTextAskTheHostFor,
                  style: CatchTextStyles.titleL(context),
                ),
              ),
              const CatchPrivacyBadge(kind: CatchPrivacyBadgeKind.hostCanSee),
            ],
          ),
          gapH4,
          Text(
            context
                .l10n
                .eventSuccessEventSuccessCompanionWingmanTextTellTheHostWho,
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
          if (requestedTargetUid != null) ...[
            gapH12,
            StageSoftBand(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      context.l10n
                          .eventSuccessEventSuccessCompanionWingmanTextRequestSentForValue1(
                            value1:
                                requestedTargetName ??
                                context
                                    .l10n
                                    .eventSuccessEventSuccessCompanionWingmanTextThisAttendee,
                          ),
                      style: CatchTextStyles.supporting(context),
                    ),
                  ),
                  gapW8,
                  CatchButton(
                    label: context
                        .l10n
                        .eventSuccessEventSuccessCompanionWingmanLabelWithdraw,
                    size: CatchButtonSize.sm,
                    variant: CatchButtonVariant.secondary,
                    isLoading: withdrawing,
                    onPressed: withdrawing ? null : _withdrawRequest,
                  ),
                ],
              ),
            ),
          ],
          gapH12,
          StageSoftBand(
            child: CatchField.input(
              title: context
                  .l10n
                  .eventSuccessEventSuccessCompanionWingmanTitlePrivateNoteToHost,
              contract: CatchContractConstraints
                  .eventSuccessWingmanRequestDocumentNote,
              controller: _noteController,
              maxLines: 2,
            ),
          ),
          gapH12,
          if (widget.candidates.isEmpty)
            Text(
              context
                  .l10n
                  .eventSuccessEventSuccessCompanionWingmanTextNoCheckedInAttendees,
              style: CatchTextStyles.supporting(context),
            )
          else
            for (final candidate in widget.candidates)
              Padding(
                padding: _wingmanCandidateRowGap,
                child: CatchPersonRow(
                  data: CatchPersonRowData(
                    name: candidate.name,
                    imageUrl: candidate.primaryPhotoThumbnailUrl,
                    seed: candidate.uid,
                    metaLine: candidate.uid == requestedTargetUid
                        ? context
                              .l10n
                              .eventSuccessEventSuccessCompanionWingmanVisiblecopyHostHelpRequestActive
                        : context
                              .l10n
                              .eventSuccessEventSuccessCompanionWingmanVisiblecopyCheckedInToThis,
                  ),
                  avatarSize: 40,
                  trailing: CatchButton(
                    label: candidate.uid == requestedTargetUid
                        ? context
                              .l10n
                              .eventSuccessEventSuccessCompanionWingmanLabelRequested
                        : requestedTargetUid == null
                        ? context
                              .l10n
                              .eventSuccessEventSuccessCompanionWingmanLabelAskHost
                        : context
                              .l10n
                              .eventSuccessEventSuccessCompanionWingmanLabelSwitch,
                    size: CatchButtonSize.sm,
                    variant: CatchButtonVariant.secondary,
                    isLoading: saving && candidate.uid != requestedTargetUid,
                    onPressed: saving || candidate.uid == requestedTargetUid
                        ? null
                        : () => _saveRequest(candidate),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Future<void> _saveRequest(PublicProfile candidate) async {
    setState(() => _savingTargetUid = candidate.uid);
    try {
      await widget.onSaveRequest(candidate, _noteController.text);
      if (!mounted) return;
      setState(() => _optimisticTargetUid = candidate.uid);
    } finally {
      if (mounted) setState(() => _savingTargetUid = null);
    }
  }

  Future<void> _withdrawRequest() async {
    setState(() => _withdrawing = true);
    try {
      await widget.onWithdrawRequest();
      if (!mounted) return;
      setState(() => _optimisticTargetUid = null);
    } finally {
      if (mounted) setState(() => _withdrawing = false);
    }
  }
}

String? _profileNameForUid(List<PublicProfile> profiles, String uid) {
  for (final profile in profiles) {
    if (profile.uid == uid) return profile.name;
  }
  return null;
}
