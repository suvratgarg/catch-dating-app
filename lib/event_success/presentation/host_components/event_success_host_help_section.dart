import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/event_success/domain/event_success_wingman_request.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

class EventSuccessHostHelpSection extends StatelessWidget {
  const EventSuccessHostHelpSection({
    super.key,
    required this.requests,
    required this.profiles,
    required this.rotationsEnabled,
  });

  final List<EventSuccessWingmanRequest> requests;
  final List<PublicProfile> profiles;
  final bool rotationsEnabled;

  @override
  Widget build(BuildContext context) {
    final activeRequests =
        requests.where((request) => request.isActive).toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final profileByUid = {for (final profile in profiles) profile.uid: profile};
    return CatchSection.fieldRows(
      title: context.l10n.eventSuccessEventSuccessHostSharedTextHelpMeSayHi,
      count: context.l10n.eventSuccessEventSuccessHostSharedLabelLengthActive(
        length: activeRequests.length,
      ),
      children: [
        if (activeRequests.isEmpty)
          CatchField.content(
            copy: catchFieldCopy(context.l10n),
            title: context
                .l10n
                .eventSuccessEventSuccessHostSharedTextNoHostHelpRequests,
            body: rotationsEnabled
                ? context
                      .l10n
                      .eventSuccessEventSuccessHostSharedTextAttendeesExplicitlyAskedThe
                : context
                      .l10n
                      .eventSuccessEventSuccessHostSharedTextAttendeesExplicitlyAskedThef44110,
            icon: CatchIcons.volunteerActivismOutlined,
          ),
        for (final request in activeRequests)
          EventSuccessHostHelpRow(
            request: request,
            requester: profileByUid[request.requesterUid],
            target: profileByUid[request.targetUid],
          ),
      ],
    );
  }
}

class EventSuccessHostHelpRow extends StatelessWidget {
  const EventSuccessHostHelpRow({
    super.key,
    required this.request,
    required this.requester,
    required this.target,
  });

  final EventSuccessWingmanRequest request;
  final PublicProfile? requester;
  final PublicProfile? target;

  @override
  Widget build(BuildContext context) {
    final targetName =
        target?.name ??
        context.l10n.eventSuccessEventSuccessHostSharedVisiblecopyThisAttendee;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatchPersonRow(
          copy: catchPersonRowCopy(context.l10n),
          data: CatchPersonRowData(
            name:
                requester?.name ??
                context
                    .l10n
                    .eventSuccessEventSuccessHostSharedVisiblecopyAttendee,
            imageUrl: requester?.primaryPhotoThumbnailUrl,
            seed: request.requesterUid,
            metaLine: context.l10n
                .eventSuccessEventSuccessHostSharedVisiblecopyAskedForHelpMeeting(
                  targetName: targetName,
                ),
          ),
          avatarSize: 40,
          trailing: CatchBadge.functional(
            label:
                context.l10n.eventSuccessEventSuccessHostSharedLabelHostVisible,
            tone: CatchBadgeTone.brand,
            icon: CatchIcons.visibilityOutlined,
          ),
        ),
        if (request.note != null && request.note!.trim().isNotEmpty) ...[
          Padding(
            padding: _hostWingmanRequestNotePadding,
            child: Text(
              request.note!,
              style: CatchTextStyles.supporting(
                context,
                color: CatchTokens.of(context).ink2,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

final EdgeInsets _hostWingmanRequestNotePadding = CatchInsets.pageHorizontal
    .copyWith(bottom: CatchSpacing.s2);
