part of '../event_success_companion_screen.dart';

class _WingmanRequestSection extends ConsumerStatefulWidget {
  const _WingmanRequestSection({
    required this.event,
    required this.candidates,
    this.existingRequest,
  });

  final Event event;
  final List<PublicProfile> candidates;
  final EventSuccessWingmanRequest? existingRequest;

  @override
  ConsumerState<_WingmanRequestSection> createState() =>
      _WingmanRequestSectionState();
}

class _WingmanRequestSectionState
    extends ConsumerState<_WingmanRequestSection> {
  late final TextEditingController _noteController = TextEditingController(
    text: widget.existingRequest?.isActive == true
        ? widget.existingRequest?.note ?? ''
        : '',
  );
  String? _optimisticTargetUid;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mutation = ref.watch(EventSuccessController.wingmanRequestMutation);
    final activeRequest = widget.existingRequest?.isActive == true
        ? widget.existingRequest
        : null;
    final requestedTargetUid = _optimisticTargetUid ?? activeRequest?.targetUid;
    final requestedTargetName = requestedTargetUid == null
        ? null
        : _profileNameForUid(widget.candidates, requestedTargetUid);

    return CatchSurface(
      borderColor: CatchTokens.of(context).line,
      padding: const EdgeInsets.all(CatchSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Ask the host to help',
                  style: CatchTextStyles.titleM(context),
                ),
              ),
              CatchBadge(
                label: 'Host visible',
                tone: CatchBadgeTone.live,
                icon: Icons.visibility_outlined,
              ),
            ],
          ),
          gapH4,
          Text(
            'Pick someone you would like help getting paired with. The host can see this request; the other person is not notified.',
            style: CatchTextStyles.bodyS(context),
          ),
          if (requestedTargetUid != null) ...[
            gapH12,
            CatchSurface(
              backgroundColor: CatchTokens.of(context).primarySoft,
              borderWidth: 0,
              padding: const EdgeInsets.all(CatchSpacing.s3),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Request sent for ${requestedTargetName ?? 'this attendee'}.',
                      style: CatchTextStyles.bodyS(context),
                    ),
                  ),
                  gapW8,
                  CatchButton(
                    label: 'Withdraw',
                    size: CatchButtonSize.sm,
                    variant: CatchButtonVariant.secondary,
                    isLoading: mutation.isPending,
                    onPressed: mutation.isPending
                        ? null
                        : () => EventSuccessController.wingmanRequestMutation
                              .run(ref, (tx) async {
                                await tx
                                    .get(
                                      eventSuccessControllerProvider.notifier,
                                    )
                                    .withdrawWingmanRequest(
                                      event: widget.event,
                                    );
                                if (!mounted) return;
                                setState(() => _optimisticTargetUid = null);
                              }),
                  ),
                ],
              ),
            ),
          ],
          gapH12,
          CatchTextField(
            label: 'Private note to host',
            controller: _noteController,
            maxLines: 2,
            inputFormatters: [LengthLimitingTextInputFormatter(240)],
          ),
          gapH12,
          if (widget.candidates.isEmpty)
            Text(
              'No checked-in attendees available yet.',
              style: CatchTextStyles.bodyS(context),
            )
          else
            for (final candidate in widget.candidates)
              Padding(
                padding: const EdgeInsets.only(bottom: CatchSpacing.s2),
                child: PersonRow(
                  data: PersonRowData(
                    name: candidate.name,
                    imageUrl: candidate.primaryPhotoThumbnailUrl,
                    seed: candidate.uid,
                    metaLine: candidate.uid == requestedTargetUid
                        ? 'Host-help request active'
                        : 'Checked in to this event',
                  ),
                  avatarSize: 40,
                  trailing: CatchButton(
                    label: candidate.uid == requestedTargetUid
                        ? 'Requested'
                        : requestedTargetUid == null
                        ? 'Ask host'
                        : 'Switch',
                    size: CatchButtonSize.sm,
                    variant: CatchButtonVariant.secondary,
                    isLoading:
                        mutation.isPending &&
                        candidate.uid != requestedTargetUid,
                    onPressed:
                        mutation.isPending ||
                            candidate.uid == requestedTargetUid
                        ? null
                        : () => _saveRequest(candidate),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  void _saveRequest(PublicProfile candidate) {
    EventSuccessController.wingmanRequestMutation.run(ref, (tx) async {
      await tx
          .get(eventSuccessControllerProvider.notifier)
          .saveWingmanRequest(
            event: widget.event,
            target: candidate,
            note: _noteController.text,
          );
      if (!mounted) return;
      setState(() => _optimisticTargetUid = candidate.uid);
    });
  }
}

String? _profileNameForUid(List<PublicProfile> profiles, String uid) {
  for (final profile in profiles) {
    if (profile.uid == uid) return profile.name;
  }
  return null;
}

List<PublicProfile> _wingmanCandidatesForViewer({
  required UserProfile viewer,
  required List<PublicProfile> candidates,
}) {
  final interestedIn = viewer.interestedInGenders.toSet();
  if (interestedIn.isEmpty) return const [];
  return [
    for (final candidate in candidates)
      if (candidate.uid != viewer.uid &&
          interestedIn.contains(candidate.gender))
        candidate,
  ];
}
